import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PosPrinterService receipt rendering', () {
    test('should emit default ascii footer as plain text bytes', () async {
      final service = PosPrinterService(autoInit: false);
      final invoice = PrintableInvoice(
        id: 'ACC-SINV-TEST-15703',
        date: DateTime(2026, 5, 5, 19, 0),
        customer: 'Abdalla Ayman',
        customerAddress: '6, 2 الدور الاول شقة 18 Magd elmstafa building',
        customerPhone: '+201091653779',
        territory: '6 October',
        deliveryDateTime: DateTime(2026, 5, 5, 19, 0),
        total: 380,
        paid: 380,
        outstanding: 0,
        shipping: 60,
        items: [
          PrintableInvoiceItem(name: 'Hibiscus Kunafa Large', qty: 2, rate: 160),
        ],
      );

      final bytes = await service.buildReceiptBytesForTest(invoice);

      expect(
        _containsSequence(bytes, latin1.encode('Thank you for Your Order')),
        isTrue,
      );
    });

    test('should use the compatibility raster width for image text blocks', () async {
      final service = PosPrinterService(autoInit: false);
      final invoice = PrintableInvoice(
        id: 'ACC-SINV-TEST-15754',
        date: DateTime(2026, 5, 6, 14, 30),
        customer: 'Manal Mahmoud Issa',
        customerAddress: 'حدائق أكتوبر بداية كمباوند كاميوا عماره 14',
        customerPhone: '01064260665',
        territory: 'حدائق أكتوبر - Hadayek October',
        deliveryDateTime: DateTime(2026, 5, 6, 14, 30),
        total: 415,
        paid: 415,
        outstanding: 0,
        shipping: 55,
        items: [
          PrintableInvoiceItem(name: 'Pistachio Medium', qty: 1, rate: 120),
        ],
      );

      final bytes = await service.buildReceiptBytesForTest(invoice);

      expect(
        _containsSequence(bytes, [0x1D, 0x76, 0x30, 0x00, 0x30, 0x00]),
        isTrue,
      );
      expect(
        _containsSequence(bytes, [0x1D, 0x76, 0x30, 0x00, 0x48, 0x00]),
        isFalse,
      );
    });

    test('should render compact child bundle lines in preview output', () async {
      final service = PosPrinterService(autoInit: false);
      final invoice = PrintableInvoice(
        id: 'ACC-SINV-TEST-15723',
        date: DateTime(2026, 5, 5, 13, 0),
        customer: 'Moaz Mohamed',
        customerAddress: 'زهراء المعادي, Maadi - المعادي',
        customerPhone: '01023743348',
        total: 720,
        paid: 0,
        outstanding: 720,
        shipping: 60,
        items: [
          PrintableInvoiceItem(name: 'Chocolate Hazelnut Medium', qty: 1, rate: 120, amount: 120),
          PrintableInvoiceItem(name: 'Jarz Sweet Six', qty: 1, rate: 600, amount: 600, bold: true),
          PrintableInvoiceItem(name: 'Blueberry Medium', qty: 3, rate: 100, amount: 300, showPricing: false, indentLevel: 1),
          PrintableInvoiceItem(name: 'Lotus Medium', qty: 2, rate: 100, amount: 200, showPricing: false, indentLevel: 1),
          PrintableInvoiceItem(name: 'Redvelvet Medium', qty: 1, rate: 100, amount: 100, showPricing: false, indentLevel: 1),
        ],
      );

      final preview = await service.buildReceiptPreview(invoice);

      expect(preview, contains('- Blueberry Medium x3'));
      expect(preview, isNot(contains('- Blueberry Medium x3 @')));
      expect(preview, contains('Jarz Sweet Six x1 @ 600.00 = 600.00'));
    });
  });
}

bool _containsSequence(Uint8List bytes, List<int> sequence) {
  if (sequence.isEmpty || sequence.length > bytes.length) {
    return false;
  }

  for (var start = 0; start <= bytes.length - sequence.length; start++) {
    var matched = true;
    for (var offset = 0; offset < sequence.length; offset++) {
      if (bytes[start + offset] != sequence[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      return true;
    }
  }

  return false;
}