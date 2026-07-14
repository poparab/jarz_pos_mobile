import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/models/unconfirmed_online_order.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/presentation/widgets/confirm_payment_sheet.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  Future<bool?>? Function() openSheet,
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
                onPressed: () => openSheet(),
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

UnconfirmedOnlineOrder _order({
  String? receiptName,
  String? receiptImageUrl,
}) {
  return UnconfirmedOnlineOrder(
    invoice: 'INV-0001',
    customer: 'CUST-0001',
    customerName: 'Test Customer',
    amount: 150,
    paymentMethod: 'Instapay',
    receiptName: receiptName,
    receiptImageUrl: receiptImageUrl,
    canConfirm: true,
  );
}

ElevatedButton _confirmButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Confirm received'),
  );
}

void main() {
  group('ConfirmPaymentSheet gating', () {
    testWidgets(
      'Confirm stays disabled without a receipt even after a reference is typed',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(), // no receipt attached
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Initially disabled (no receipt, no reference).
        expect(_confirmButton(tester).onPressed, isNull);

        // Typing a reference is not enough without a receipt screenshot.
        await tester.enterText(find.byType(TextField), 'REF-123');
        await tester.pumpAndSettle();
        expect(_confirmButton(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'Confirm enables only once BOTH a receipt and a reference are present',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(
              receiptName: 'PPR-0001',
              receiptImageUrl: '/files/receipt.png',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Receipt present but no reference yet → still disabled.
        expect(_confirmButton(tester).onPressed, isNull);

        // Add the bank reference → now enabled.
        await tester.enterText(find.byType(TextField), 'REF-123');
        await tester.pumpAndSettle();
        expect(_confirmButton(tester).onPressed, isNotNull);
      },
    );
  });
}
