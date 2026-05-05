import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PosPrinterService footer rendering', () {
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