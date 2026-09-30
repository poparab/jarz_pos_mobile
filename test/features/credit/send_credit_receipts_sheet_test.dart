import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/credit/data/models/credit_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/send_credit_receipts_sheet.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_provider.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';

const _invoices = [
  CreditInvoice(invoice: 'ACC-SINV-2026-00010', postingDate: '2026-09-01', grandTotal: 500, outstandingAmount: 500),
  CreditInvoice(invoice: 'ACC-SINV-2026-00020', postingDate: '2026-09-10', grandTotal: 300, outstandingAmount: 200),
  CreditInvoice(invoice: 'ACC-SINV-2026-00030', postingDate: '2026-09-20', grandTotal: 150, outstandingAmount: 150),
];

PrintableInvoice _printable(CreditInvoice i) => PrintableInvoice(
      id: i.invoice,
      date: DateTime(2026, 9, 1),
      customer: 'Cafe Nour',
      customerPhone: '01111034268',
      total: i.grandTotal,
      paid: i.grandTotal - i.outstandingAmount,
      outstanding: i.outstandingAmount,
      items: [PrintableInvoiceItem(name: 'Mango Jar', qty: 1, rate: i.grandTotal)],
    );

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        // No Dio: receipt branding falls back to the defaults, no network.
        posPrinterServiceProvider.overrideWith((ref) => PosPrinterService(autoInit: false)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('starts with every open order ticked, consolidated, and totals what is due', (tester) async {
    await tester.pumpWidget(_wrap(const SendCreditReceiptsSheet(customerName: 'Cafe Nour', invoices: _invoices)));

    expect(find.text('3 of 3 selected'), findsOneWidget);
    expect(find.textContaining('Total due:'), findsOneWidget);
    expect(find.textContaining('850.00'), findsOneWidget);
    expect(find.text('All the orders you choose in one statement, with the total due.'), findsOneWidget);
  });

  testWidgets('a single open order defaults to its own receipt', (tester) async {
    await tester.pumpWidget(
      _wrap(SendCreditReceiptsSheet(customerName: 'Cafe Nour', invoices: [_invoices.first])),
    );
    expect(find.text('One receipt for each order you choose.'), findsOneWidget);
  });

  testWidgets('unticking an order drops it from the total and from what is sent', (tester) async {
    List<String>? loaded;
    await tester.pumpWidget(
      _wrap(
        SendCreditReceiptsSheet(
          customerName: 'Cafe Nour',
          invoices: _invoices,
          loadInvoices: (invoices) async {
            loaded = invoices.map((i) => i.invoice).toList();
            return invoices.map(_printable).toList();
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('credit-send-ACC-SINV-2026-00020')));
    await tester.pump();
    expect(find.text('2 of 3 selected'), findsOneWidget);
    expect(find.textContaining('650.00'), findsOneWidget);

    await tester.tap(find.text('Individual receipts'));
    await tester.pump();
    expect(find.text('One receipt for each order you choose.'), findsOneWidget);

    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();
    // Oldest first, the unticked order left out.
    expect(loaded, ['ACC-SINV-2026-00010', 'ACC-SINV-2026-00030']);
  });

  testWidgets('nothing ticked means nothing can be sent', (tester) async {
    await tester.pumpWidget(_wrap(const SendCreditReceiptsSheet(customerName: 'Cafe Nour', invoices: _invoices)));
    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(find.text('0 of 3 selected'), findsOneWidget);
    final whatsapp = tester.widget<FilledButton>(find.ancestor(of: find.text('WhatsApp'), matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(whatsapp.onPressed, isNull);
  });

  testWidgets('a failed load says so and keeps the sheet open', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SendCreditReceiptsSheet(
          customerName: 'Cafe Nour',
          invoices: _invoices,
          loadInvoices: (_) async => throw Exception('503'),
        ),
      ),
    );
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load the orders. Try again.'), findsOneWidget);
    expect(find.text('3 of 3 selected'), findsOneWidget);
  });

  testWidgets('a load that comes back short is refused, not sent misaligned', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SendCreditReceiptsSheet(
          customerName: 'Cafe Nour',
          invoices: _invoices,
          loadInvoices: (invoices) async => [_printable(invoices.first)],
        ),
      ),
    );
    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load the orders. Try again.'), findsOneWidget);
    final whatsapp = tester.widget<FilledButton>(find.ancestor(of: find.text('WhatsApp'), matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(whatsapp.onPressed, isNotNull);
  });
}
