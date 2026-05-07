import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/printer_compatibility.dart';
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
        customerAddress: '6 October, Building 18, First Floor, Flat 2',
        customerPhone: '01000000000',
        territory: '6 October',
        deliveryDateTime: DateTime(2026, 5, 5, 19, 0),
        total: 120,
        paid: 120,
        outstanding: 0,
        shipping: 0,
        items: [
          PrintableInvoiceItem(name: 'Connection Test', qty: 1, rate: 120),
        ],
      );

      final bytes = await service.buildReceiptBytesForTest(invoice);

      expect(
        _containsSequence(bytes, latin1.encode('Thank you for Your Order')),
        isTrue,
      );
    });

    test(
      'should keep ascii receipts text-only even with long address lines',
      () async {
        final service = PosPrinterService(autoInit: false);
        final invoice = PrintableInvoice(
          id: 'ACC-SINV-2026-15785',
          date: DateTime(2026, 5, 7, 17, 9),
          customer: 'E2E Staff 20260507140919',
          customerAddress:
              'E2E Address 20260507140919, Location: https://maps.example/20260507140919, EG6OCT',
          customerPhone: '01507140919',
          territory: 'EG6OCT',
          deliveryDateTime: DateTime(2026, 5, 7, 17, 9),
          total: 180,
          paid: 180,
          outstanding: 0,
          shipping: 60,
          items: [
            PrintableInvoiceItem(
              name: 'Strawberry Medium',
              qty: 1,
              rate: 120,
              amount: 120,
            ),
          ],
        );

        final bytes = await service.buildReceiptBytesForTest(invoice);

        expect(_countSequence(bytes, [0x1D, 0x76, 0x30, 0x00]), 0);
        expect(
          _containsSequence(bytes, latin1.encode('E2E Address 20260507140919')),
          isTrue,
        );
        expect(
          _containsSequence(
            bytes,
            latin1.encode('Location: https://maps.example/20260507140919'),
          ),
          isTrue,
        );
      },
    );

    test(
      'should preserve structure when receipt contains Arabic text',
      () async {
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
          _containsSequence(bytes, latin1.encode('Thank you for Your Order')),
          isTrue,
        );
        expect(_countSequence(bytes, [0x1D, 0x76, 0x30, 0x00]), greaterThan(0));
        expect(_countSequence(bytes, [0x1D, 0x76, 0x30, 0x00]), lessThan(10));
      },
    );

    test(
      'should use the compatibility raster width for image text blocks',
      () async {
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
      },
    );

    test(
      'should apply paper width and code table from compatibility settings',
      () async {
        final service = PosPrinterService(autoInit: false);
        await service.updateCompatibilitySettings(
          service.compatibilitySettings.copyWith(
            paperSize: PrinterPaperSize.mm58,
            printLogo: false,
            codeTable: 16,
          ),
        );
        final invoice = PrintableInvoice(
          id: 'ACC-SINV-TEST-15790',
          date: DateTime(2026, 5, 7, 18, 0),
          customer: 'Paper Width Test',
          customerAddress: '58mm printer',
          total: 120,
          paid: 120,
          outstanding: 0,
          items: [
            PrintableInvoiceItem(name: 'Strawberry Medium', qty: 1, rate: 120),
          ],
        );

        final bytes = await service.buildReceiptBytesForTest(invoice);

        expect(service.compatibilitySettings.paperSize, PrinterPaperSize.mm80);
        expect(_containsSequence(bytes, [0x1D, 0x57, 0x40, 0x02]), isTrue);
        expect(_containsSequence(bytes, [0x1B, 0x74, 0x10]), isTrue);
      },
    );

    test(
      'should strip ascii control characters before native text printing',
      () async {
        final service = PosPrinterService(autoInit: false);
        final invoice = PrintableInvoice(
          id: 'ACC-SINV-TEST-15792',
          date: DateTime(2026, 5, 7, 18, 20),
          customer: 'AB\u0000CD\u001B',
          customerAddress: 'Addr\u0007Block\u001BTest',
          customerPhone: '01000000000',
          territory: 'EG6OCT',
          total: 120,
          paid: 120,
          outstanding: 0,
          items: [
            PrintableInvoiceItem(name: 'Item\u0002Name', qty: 1, rate: 120),
          ],
        );

        final bytes = await service.buildReceiptBytesForTest(invoice);

        expect(_containsSequence(bytes, latin1.encode('AB CD')), isTrue);
        expect(
          _containsSequence(bytes, latin1.encode('Addr Block Test')),
          isTrue,
        );
        expect(_containsSequence(bytes, latin1.encode('Item Name')), isTrue);
      },
    );

    test(
      'should rasterize styled ascii text only when compatibility setting enables it',
      () async {
        final service = PosPrinterService(autoInit: false);
        await service.updateCompatibilitySettings(
          service.compatibilitySettings.copyWith(
            printLogo: false,
            rasterizeStyledText: true,
          ),
        );
        final invoice = PrintableInvoice(
          id: 'ACC-SINV-TEST-15791',
          date: DateTime(2026, 5, 7, 18, 15),
          customer: 'Styled Header',
          customerAddress:
              'Address block that should become raster when enabled',
          total: 120,
          paid: 120,
          outstanding: 0,
          items: [
            PrintableInvoiceItem(name: 'Strawberry Medium', qty: 1, rate: 120),
          ],
        );

        final bytes = await service.buildReceiptBytesForTest(invoice);

        expect(_countSequence(bytes, [0x1D, 0x76, 0x30, 0x00]), greaterThan(0));
      },
    );

    test(
      'should render compact child bundle lines in preview output',
      () async {
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
            PrintableInvoiceItem(
              name: 'Chocolate Hazelnut Medium',
              qty: 1,
              rate: 120,
              amount: 120,
            ),
            PrintableInvoiceItem(
              name: 'Jarz Sweet Six',
              qty: 1,
              rate: 600,
              amount: 600,
              bold: true,
            ),
            PrintableInvoiceItem(
              name: 'Blueberry Medium',
              qty: 3,
              rate: 100,
              amount: 300,
              showPricing: false,
              indentLevel: 1,
            ),
            PrintableInvoiceItem(
              name: 'Lotus Medium',
              qty: 2,
              rate: 100,
              amount: 200,
              showPricing: false,
              indentLevel: 1,
            ),
            PrintableInvoiceItem(
              name: 'Redvelvet Medium',
              qty: 1,
              rate: 100,
              amount: 100,
              showPricing: false,
              indentLevel: 1,
            ),
          ],
        );

        final preview = await service.buildReceiptPreview(invoice);

        expect(preview, contains('- Blueberry Medium x3'));
        expect(preview, isNot(contains('- Blueberry Medium x3 @')));
        expect(preview, contains('Jarz Sweet Six x1 @ 600.00 = 600.00'));
      },
    );
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

int _countSequence(Uint8List bytes, List<int> sequence) {
  if (sequence.isEmpty || sequence.length > bytes.length) {
    return 0;
  }

  var count = 0;
  for (var start = 0; start <= bytes.length - sequence.length; start++) {
    var matched = true;
    for (var offset = 0; offset < sequence.length; offset++) {
      if (bytes[start + offset] != sequence[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      count++;
    }
  }

  return count;
}
