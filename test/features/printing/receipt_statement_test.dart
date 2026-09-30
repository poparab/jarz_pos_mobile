import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_branding.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_canvas_renderer.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_statement.dart';

PrintableInvoice _order(String no, double total, {double shipping = 0, String date = '01/09/2026'}) => PrintableInvoice(
      id: 'ACC-SINV-2026-$no',
      date: DateTime(2026, 9, 1),
      customer: 'Cafe Nour',
      total: total,
      paid: 0,
      outstanding: total,
      shipping: shipping,
      orderNo: no,
      orderDate: date,
      items: [
        PrintableInvoiceItem(name: 'Mango Jar', qty: 2, rate: (total - shipping) / 2),
        PrintableInvoiceItem(name: 'Berry Jar', qty: 1, rate: 0, showPricing: false, indentLevel: 1),
      ],
    );

final _statement = PrintableStatement(
  customer: 'Cafe Nour',
  date: DateTime(2026, 9, 30),
  entries: [
    StatementEntry(invoice: _order('17001', 570, shipping: 70), outstanding: 570),
    StatementEntry(invoice: _order('17002', 300, date: '10/09/2026'), outstanding: 200),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const branding = ReceiptBranding.defaults();

  test('statement lists each order with its due, then the total due', () {
    final text = buildStatementShareText(_statement, branding);
    expect(text, startsWith('*ACCOUNT STATEMENT*\nCafe Nour\nDate: 30/09/2026'));
    expect(text, contains('*Order #17001* · 01/09/2026\n2 × Mango Jar — EGP 500.00\n   - 1 × Berry Jar\nShipping: EGP 70.00\nOrder total: EGP 570.00\nDue: EGP 570.00'));
    // Partly paid: the paid line appears, and the due is the ledger's figure.
    expect(text, contains('Order total: EGP 300.00\nPaid: EGP 100.00\nDue: EGP 200.00'));
    expect(text, contains('*Total due: EGP 770.00*\n2 orders'));
    expect(text, endsWith('www.orderjarz.com'));
  });

  test('a fully unpaid order carries no paid line', () {
    final text = buildStatementShareText(_statement, branding);
    final first = text.substring(text.indexOf('*Order #17001*'), text.indexOf('*Order #17002*'));
    expect(first, isNot(contains('Paid:')));
  });

  test('a discounted order shows the discount so its lines add up to its total', () {
    // Lines 2 × 250 = 500 + shipping 70 = 570, but the order came to 520.
    final discounted = PrintableStatement(
      customer: 'Cafe Nour',
      date: DateTime(2026, 9, 30),
      entries: [
        StatementEntry(
          invoice: PrintableInvoice(
            id: 'ACC-SINV-2026-17003',
            date: DateTime(2026, 9, 1),
            customer: 'Cafe Nour',
            total: 520,
            paid: 0,
            outstanding: 520,
            shipping: 70,
            orderNo: '17003',
            items: [PrintableInvoiceItem(name: 'Mango Jar', qty: 2, rate: 250)],
          ),
          outstanding: 520,
        ),
      ],
    );
    expect(discounted.entries.single.discount, closeTo(50, 0.001));
    expect(
      buildStatementShareText(discounted, branding),
      contains('Shipping: EGP 70.00\nDiscount: -EGP 50.00\nOrder total: EGP 520.00'),
    );
    expect(_statement.entries.first.discount, 0);
  });

  test('individual receipts on WhatsApp go one after another in one message', () {
    final text = buildReceiptsBundleText([_order('17001', 570), _order('17002', 300)], branding);
    expect(RegExp(r'\*ORDER RECEIPT\*').allMatches(text).length, 2);
    expect(text, contains('— — — — —'));
    expect(text.indexOf('Order #17001'), lessThan(text.indexOf('Order #17002')));
  });

  test('renderStatementPng produces a receipt-width PNG', () async {
    final png = await ReceiptCanvasRenderer.renderStatementPng(
      statement: _statement,
      footer: 'Thank you for Your Order',
      phone: '01061332266',
      website: 'www.orderjarz.com',
    );
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final width = (png[16] << 24) | (png[17] << 16) | (png[18] << 8) | png[19];
    expect(width, 576);
  });
}
