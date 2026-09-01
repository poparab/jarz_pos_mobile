import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/widgets/payment_collection_change_dialog.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  Future<PaymentCollectionChangeRequest?>? Function() openDialog,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => openDialog(),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

InvoiceCard _invoice({
  String? paymentMethod,
  String? actualPaymentMethod,
  String? paymentReceiptName,
  String? paymentReceiptMethod,
  String? paymentReceiptStatus,
  String? paymentReceiptImageUrl,
  String? paymentConfirmationStatus,
  double outstandingAmount = 0,
  bool hasUnsettledCourierTxn = true,
}) {
  return InvoiceCard(
    id: 'INV-0001',
    invoiceIdShort: '0001',
    customerName: 'Test Customer',
    customer: 'CUST-0001',
    territory: 'Cairo',
    status: 'Out For Delivery',
    postingDate: '2026-05-18',
    grandTotal: 150,
    netTotal: 130,
    totalTaxesAndCharges: 20,
    fullAddress: 'Test address',
    items: const [],
    paymentMethod: paymentMethod,
    actualPaymentMethod: actualPaymentMethod,
    paymentReceiptName: paymentReceiptName,
    paymentReceiptMethod: paymentReceiptMethod,
    paymentReceiptStatus: paymentReceiptStatus,
    paymentReceiptImageUrl: paymentReceiptImageUrl,
    paymentConfirmationStatus: paymentConfirmationStatus,
    outstandingAmount: outstandingAmount,
    hasUnsettledCourierTxn: hasUnsettledCourierTxn,
  );
}

/// An order taken Out for Delivery on the promise of an InstaPay transfer that has
/// still not arrived: nobody has paid anything, so there is no screenshot to demand
/// and no courier holding the customer's money.
InvoiceCard _awaitingOnlinePayment({bool courierStillOpen = true}) => _invoice(
  paymentMethod: 'Instapay',
  paymentConfirmationStatus: 'Awaiting Payment',
  outstandingAmount: 150,
  hasUnsettledCourierTxn: courierStillOpen,
);

void main() {
  group('PaymentCollectionChangeDialog', () {
    testWidgets('should require uploaded receipt when online method is selected', (
      tester,
    ) async {
      Future<PaymentCollectionChangeRequest?>? dialogFuture;

      await _pumpHost(tester, () {
        dialogFuture = PaymentCollectionChangeDialog.show(
          tester.element(find.text('open')),
          invoice: _invoice(paymentMethod: 'Cash'),
          posProfile: 'Nasr City',
        );
        return dialogFuture!;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final submitBefore = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit'),
      );
      expect(submitBefore.onPressed, isNull);
      expect(find.text('Upload Receipt Image'), findsAtLeastNWidgets(1));
      expect(dialogFuture, isNotNull);
    });

    testWidgets('should allow online change when uploaded receipt is already available', (
      tester,
    ) async {
      Future<PaymentCollectionChangeRequest?>? dialogFuture;

      await _pumpHost(tester, () {
        dialogFuture = PaymentCollectionChangeDialog.show(
          tester.element(find.text('open')),
          invoice: _invoice(
            paymentMethod: 'Cash',
            paymentReceiptName: 'PPR-0001',
            paymentReceiptMethod: 'InstaPay',
            paymentReceiptStatus: 'Unconfirmed',
            paymentReceiptImageUrl: '/files/receipt.png',
          ),
          posProfile: 'Nasr City',
        );
        return dialogFuture!;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit'),
      );
      expect(submitButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?.method, 'Instapay');
      expect(result?.receiptName, 'PPR-0001');
    });

    testWidgets('should allow cash change without reference', (tester) async {
      Future<PaymentCollectionChangeRequest?>? dialogFuture;

      await _pumpHost(tester, () {
        dialogFuture = PaymentCollectionChangeDialog.show(
          tester.element(find.text('open')),
          invoice: _invoice(paymentMethod: 'Instapay'),
          posProfile: 'Nasr City',
        );
        return dialogFuture!;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit'),
      );
      expect(submitButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?.method, 'Cash');
      expect(result?.referenceNo, isNull);
    });

    testWidgets(
      'should offer replace and remove while the receipt is unconfirmed',
      (tester) async {
        await _pumpHost(tester, () {
          return PaymentCollectionChangeDialog.show(
            tester.element(find.text('open')),
            invoice: _invoice(
              paymentMethod: 'Cash',
              paymentReceiptName: 'PPR-0001',
              paymentReceiptMethod: 'InstaPay',
              paymentReceiptStatus: 'Unconfirmed',
              paymentReceiptImageUrl: '/files/receipt.png',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // With an image already attached the primary action becomes a swap,
        // and the screenshot can be dropped outright.
        expect(find.text('Replace Image'), findsOneWidget);
        expect(find.text('Remove Image'), findsOneWidget);
        expect(find.text('Upload Receipt Image'), findsNothing);
      },
    );

    testWidgets(
      'should not demand a receipt to retarget an order nobody has paid yet',
      (tester) async {
        Future<PaymentCollectionChangeRequest?>? dialogFuture;

        await _pumpHost(tester, () {
          dialogFuture = PaymentCollectionChangeDialog.show(
            tester.element(find.text('open')),
            invoice: _awaitingOnlinePayment(),
            posProfile: 'Nasr City',
          );
          return dialogFuture!;
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Defaults to Cash for an Instapay order, so pick an online method to prove
        // the online branch no longer blocks.
        await tester.tap(find.text('Mobile Wallet'));
        await tester.pumpAndSettle();

        expect(find.text('Upload Receipt Image'), findsNothing);
        final submit = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Submit'),
        );
        expect(submit.onPressed, isNotNull);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
        await tester.pumpAndSettle();

        final result = await dialogFuture;
        expect(result?.method, 'Mobile Wallet');
        expect(result?.receiptName, isNull);
      },
    );

    testWidgets(
      'should say the cash lands in the branch drawer once the courier closed out',
      (tester) async {
        await _pumpHost(tester, () {
          return PaymentCollectionChangeDialog.show(
            tester.element(find.text('open')),
            invoice: _awaitingOnlinePayment(courierStillOpen: false),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('recorded as received at the branch'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should stay silent about the drawer while the courier can still carry it',
      (tester) async {
        await _pumpHost(tester, () {
          return PaymentCollectionChangeDialog.show(
            tester.element(find.text('open')),
            invoice: _awaitingOnlinePayment(),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('recorded as received at the branch'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'should not offer replace or remove once the receipt is confirmed',
      (tester) async {
        await _pumpHost(tester, () {
          return PaymentCollectionChangeDialog.show(
            tester.element(find.text('open')),
            invoice: _invoice(
              paymentMethod: 'Cash',
              paymentReceiptName: 'PPR-0001',
              paymentReceiptMethod: 'InstaPay',
              paymentReceiptStatus: 'Confirmed',
              paymentReceiptImageUrl: '/files/receipt.png',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Replace Image'), findsNothing);
        expect(find.text('Remove Image'), findsNothing);
        expect(find.text('Upload Receipt Image'), findsNothing);
        // Preview survives — a confirmed screenshot is still viewable.
        expect(find.text('Preview'), findsOneWidget);
      },
    );
  });
}