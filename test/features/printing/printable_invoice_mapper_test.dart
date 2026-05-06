import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/printing/printable_invoice_mapper.dart';

void main() {
  group('buildPrintableInvoiceFromCards', () {
    test('should collapse bundle children under the bundle parent', () {
      final source = _invoiceCard(
        items: [
          InvoiceItem(
            itemCode: 'CHO-MED',
            itemName: 'Chocolate Hazelnut Medium',
            qty: 1,
            rate: 120,
            amount: 120,
          ),
          InvoiceItem(
            itemCode: 'BUNDLE-1',
            itemName: 'Jarz Sweet Six',
            qty: 1,
            rate: 0,
            amount: 0,
            isBundleParent: true,
            bundleCode: 'bundle-abc',
          ),
          InvoiceItem(
            itemCode: 'BLUE-MED',
            itemName: 'Blueberry Medium',
            qty: 3,
            rate: 100,
            amount: 300,
            isBundleChild: true,
            parentBundle: 'bundle-abc',
          ),
          InvoiceItem(
            itemCode: 'LOTUS-MED',
            itemName: 'Lotus Medium',
            qty: 2,
            rate: 100,
            amount: 200,
            isBundleChild: true,
            parentBundle: 'bundle-abc',
          ),
        ],
      );

      final printable = buildPrintableInvoiceFromCards(
        source: source,
        fallbackItemLabel: 'Items',
      );

      expect(printable.items, hasLength(4));
      expect(printable.items[1].name, 'Jarz Sweet Six');
      expect(printable.items[1].amount, 500);
      expect(printable.items[1].showPricing, isTrue);
      expect(printable.items[2].name, 'Blueberry Medium');
      expect(printable.items[2].showPricing, isFalse);
      expect(printable.items[2].indentLevel, 1);
      expect(printable.items[3].name, 'Lotus Medium');
      expect(printable.items[3].showPricing, isFalse);
    });

    test('should suppress raw internal territory codes when address already contains the city', () {
      final source = _invoiceCard(
        territory: 'EGMAADI',
        territoryNameAr: 'المعادي',
        fullAddress: 'زهراء المعادي, Maadi - المعادي',
      );
      final details = _invoiceCard(
        territory: 'EGMAADI',
        fullAddress: 'زهراء المعادي, Maadi - المعادي',
      );

      final printable = buildPrintableInvoiceFromCards(
        source: source,
        details: details,
        fallbackItemLabel: 'Items',
      );

      expect(printable.territory, isNull);
    });
  });
}

InvoiceCard _invoiceCard({
  String territory = 'EGMAADI',
  String fullAddress = '1 Example St, Cairo',
  String? territoryNameAr,
  List<InvoiceItem> items = const <InvoiceItem>[],
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-15723',
    invoiceIdShort: '15723',
    customerName: 'Moaz Mohamed',
    customer: 'CUST-0001',
    territory: territory,
    deliveryDate: '2026-05-05',
    deliveryTimeFrom: '13:00:00',
    status: 'Received',
    postingDate: '2026-05-05',
    grandTotal: 720,
    netTotal: 660,
    totalTaxesAndCharges: 0,
    fullAddress: fullAddress,
    items: items,
    shippingIncome: 60,
    customerPhone: '01023743348',
    territoryNameAr: territoryNameAr,
  );
}