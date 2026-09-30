import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_branding.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_canvas_renderer.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_share.dart';

PrintableInvoice _invoice({double outstanding = 0, double paid = 470}) => PrintableInvoice(
      id: 'ACC-SINV-2026-17612',
      date: DateTime(2026, 9, 30, 19),
      customer: 'Abdalla Ayman',
      customerAddress: '6 October, Building 18, Flat 2',
      customerPhone: '01111034268',
      total: 470,
      paid: paid,
      outstanding: outstanding,
      shipping: 70,
      orderNo: '17612',
      paymentMethod: 'Cash',
      orderDate: '30/09/2026',
      deliveryDateFormatted: 'Wednesday, September 30, 2026',
      deliveryTimeRange: '22:00 - 23:30',
      items: [
        PrintableInvoiceItem(name: 'Mango Jar', qty: 2, rate: 150, description: 'Size : Large'),
        PrintableInvoiceItem(name: 'Party Box', qty: 1, rate: 100, bold: true),
        PrintableInvoiceItem(name: 'Berry Jar', qty: 3, rate: 0, showPricing: false, indentLevel: 1),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('whatsappMsisdn', () {
    test('every stored spelling of one Egyptian mobile collapses to one MSISDN', () {
      for (final stored in [
        '01111034268',
        '+201111034268',
        '201111034268',
        '00201111034268',
        '+20 111 103 4268',
        '0111 103 4268',
        '1111034268',
      ]) {
        expect(whatsappMsisdn(stored), '201111034268', reason: stored);
      }
    });

    test('blank is blank, not a guess', () {
      for (final value in [null, '', '   ', 'n/a']) {
        expect(whatsappMsisdn(value), '');
      }
    });

    test('a foreign number is not handed an Egyptian country code', () {
      expect(whatsappMsisdn('+966512345678'), '966512345678');
    });
  });

  group('whatsappReceiptUri', () {
    test('targets the customer chat with the text encoded', () {
      final uri = whatsappReceiptUri('01111034268', 'Total: EGP 470.00\n& more');
      expect(uri.toString(), startsWith('https://wa.me/201111034268?text='));
      expect(uri.queryParameters['text'], 'Total: EGP 470.00\n& more');
    });

    test('without a number it still opens WhatsApp with the message', () {
      final uri = whatsappReceiptUri(null, 'hi');
      expect(uri.toString(), 'https://wa.me/?text=hi');
    });
  });

  group('buildReceiptShareText', () {
    const branding = ReceiptBranding.defaults();

    test('carries the order, lines, totals and shop footer', () {
      final text = buildReceiptShareText(_invoice(), branding);
      expect(text, startsWith('*ORDER RECEIPT*\nOrder #17612'));
      expect(text, contains('Delivery: Wednesday, September 30, 2026, 22:00 - 23:30'));
      expect(text, contains('2 × Mango Jar — EGP 300.00'));
      expect(text, contains('   Size : Large'));
      expect(text, contains('   - 3 × Berry Jar'));
      expect(text, contains('Subtotal: EGP 400.00'));
      expect(text, contains('Shipping: EGP 70.00'));
      expect(text, contains('*Total: EGP 470.00*'));
      expect(text, contains('Status: PAID'));
      expect(text, isNot(contains('Amount due')));
      expect(text, endsWith('Call us 01061332266\nwww.orderjarz.com'));
    });

    test('a partly paid order says what is still due', () {
      final text = buildReceiptShareText(_invoice(outstanding: 170, paid: 300), branding);
      expect(text, contains('Status: UNPAID'));
      expect(text, contains('Amount due: EGP 170.00'));
    });

    test('an unpaid order does not repeat the total as amount due', () {
      final text = buildReceiptShareText(_invoice(outstanding: 470, paid: 0), branding);
      expect(text, contains('Status: UNPAID'));
      expect(text, isNot(contains('Amount due')));
    });

    test('falls back to the invoice id when there is no order number', () {
      final inv = PrintableInvoice(
        id: 'ACC-SINV-2026-00001',
        date: DateTime(2026, 9, 30),
        customer: 'Walk-in',
        total: 50,
        paid: 50,
        outstanding: 0,
        items: [PrintableInvoiceItem(name: 'Tea', qty: 1, rate: 50)],
      );
      expect(buildReceiptShareText(inv, branding), contains('Order #ACC-SINV-2026-00001'));
      expect(receiptShareCaption(inv, branding), 'ORDER RECEIPT — Order #ACC-SINV-2026-00001');
    });
  });

  test('renderPng produces a 576px-wide PNG of the receipt', () async {
    final png = await ReceiptCanvasRenderer.renderPng(
      inv: _invoice(),
      header: 'ORDER RECEIPT',
      footer: 'Thank you for Your Order',
      phone: '01061332266',
      website: 'www.orderjarz.com',
    );
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    // IHDR width, big-endian at bytes 16..19.
    final width = (png[16] << 24) | (png[17] << 16) | (png[18] << 8) | png[19];
    expect(width, 576);
  });
}
