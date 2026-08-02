import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';
import 'package:jarz_pos/src/features/printing/printer_compatibility.dart';

/// Pure byte-builder tests: no Bluetooth, no transport, no queue. Everything
/// here is the document, which is the only part that differs from an invoice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PrintableBatchSheet sheet({
    String workOrder = 'MFG-WO-0001',
    String itemName = 'Cake A',
    double plannedQty = 30,
    String uom = 'Nos',
    String? sopVersion,
    List<PrintableBatchComponent> components = const [],
    String? notes,
  }) =>
      PrintableBatchSheet(
        workOrder: workOrder,
        itemName: itemName,
        itemCode: 'CAKE-A',
        plannedQty: plannedQty,
        uom: uom,
        bom: 'BOM-CAKE-A-001',
        startedAt: DateTime(2026, 8, 2, 7, 15),
        startedBy: 'baker@jarz.test',
        sopVersion: sopVersion,
        components: components,
        notes: notes,
      );

  group('batch sheet bytes', () {
    test('prints what to make, how much, and against which work order',
        () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(_contains(bytes, 'BATCH SHEET'), isTrue);
      expect(_contains(bytes, 'Cake A'), isTrue);
      expect(_contains(bytes, 'CAKE-A'), isTrue);
      expect(_contains(bytes, 'MFG-WO-0001'), isTrue);
      expect(_contains(bytes, '30 Nos'), isTrue);
      expect(_contains(bytes, 'BOM-CAKE-A-001'), isTrue);
      expect(_contains(bytes, '2026-08-02 07:15'), isTrue);
      expect(_contains(bytes, 'baker@jarz.test'), isTrue);
    });

    test('carries no invoice furniture', () async {
      // A batch sheet shaped like a receipt is unreadable as a work
      // instruction — no customer, no money, no paid/unpaid.
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(_contains(bytes, 'Customer'), isFalse);
      expect(_contains(bytes, 'Total'), isFalse);
      expect(_contains(bytes, 'PAID'), isFalse);
      expect(_contains(bytes, 'UNPAID'), isFalse);
      expect(_contains(bytes, 'Thank you for Your Order'), isFalse);
    });

    test('leaves blanks for the numbers recorded at the bench', () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(_contains(bytes, 'Actual produced'), isTrue);
      expect(_contains(bytes, 'Scrap / waste'), isTrue);
      expect(_contains(bytes, '________'), isTrue);
    });

    test('prints the material list when one is supplied', () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(
        sheet(
          components: const [
            PrintableBatchComponent(name: 'Flour', qty: 4.5, uom: 'Kg'),
            PrintableBatchComponent(name: 'Sugar', qty: 2, uom: 'Kg'),
          ],
        ),
      );

      expect(_contains(bytes, 'MATERIALS'), isTrue);
      expect(_contains(bytes, 'Flour'), isTrue);
      expect(_contains(bytes, '4.5 Kg'), isTrue);
      expect(_contains(bytes, 'Sugar'), isTrue);
      expect(_contains(bytes, '2 Kg'), isTrue);
    });

    test('omits the material block entirely when there is nothing to pick',
        () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(_contains(bytes, 'MATERIALS'), isFalse);
    });

    test('prints the SOP version the batch was started against', () async {
      // Ties the paper on the bench back to the method, so editing an SOP
      // cannot silently rewrite how a finished batch was made.
      final service = PosPrinterService(autoInit: false);

      final bytes =
          await service.buildBatchSheetBytesForTest(sheet(sopVersion: 'SOP-0007#3'));

      expect(_contains(bytes, 'SOP-0007#3'), isTrue);
    });

    test('opens with a reset and ends with a cut', () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(bytes.sublist(0, 2), [0x1B, 0x40]);
      expect(
        _containsSequence(bytes, const [0x1D, 0x56, 0x42, 0x00]),
        isTrue,
      );
    });

    test('stays on the text path for ascii — no raster blocks', () async {
      // The legacy ESC/POS text path, deliberately: the canvas renderer is
      // invoice-shaped and rasterising a whole sheet is slow on a belt printer.
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(_countSequence(bytes, const [0x1D, 0x76, 0x30, 0x00]), 0);
    });

    test('rasterizes an Arabic item name rather than dropping it', () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(
        sheet(itemName: 'كيكة الشوكولاتة'),
      );

      expect(_countSequence(bytes, const [0x1D, 0x76, 0x30, 0x00]),
          greaterThan(0));
    });

    test('applies the paper width and code table from compatibility settings',
        () async {
      final service = PosPrinterService(autoInit: false);
      await service.updateCompatibilitySettings(
        service.compatibilitySettings.copyWith(printLogo: false, codeTable: 16),
      );

      final bytes = await service.buildBatchSheetBytesForTest(sheet());

      expect(service.compatibilitySettings.paperSize, PrinterPaperSize.mm80);
      expect(_containsSequence(bytes, const [0x1D, 0x57, 0x40, 0x02]), isTrue);
      expect(_containsSequence(bytes, const [0x1B, 0x74, 0x10]), isTrue);
    });

    test('strips control characters before native text printing', () async {
      final service = PosPrinterService(autoInit: false);

      final bytes = await service.buildBatchSheetBytesForTest(
        sheet(notes: 'Watch\u0000the\u001Boven'),
      );

      expect(_contains(bytes, 'Watch the oven'), isTrue);
    });
  });
}

bool _contains(Uint8List bytes, String text) =>
    _containsSequence(bytes, latin1.encode(text));

bool _containsSequence(Uint8List bytes, List<int> sequence) =>
    _countSequence(bytes, sequence) > 0;

int _countSequence(Uint8List bytes, List<int> sequence) {
  if (sequence.isEmpty || sequence.length > bytes.length) return 0;

  var count = 0;
  for (var start = 0; start <= bytes.length - sequence.length; start++) {
    var matched = true;
    for (var offset = 0; offset < sequence.length; offset++) {
      if (bytes[start + offset] != sequence[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) count++;
  }
  return count;
}
