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
    hasUnsettledCourierTxn: true,
  );
}

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
  });
}