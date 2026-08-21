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

    test('prints UNPAID for a COD order the courier has yet to collect', () {
      // Out for Delivery settles the invoice against Courier Outstanding, so
      // outstanding is already 0 while the customer has not paid a pound.
      final card = _invoiceCard(
        status: 'Out for Delivery',
        docStatus: 'Paid',
        paymentMethod: 'Cash',
        actualPaymentMethod: 'Cash',
        outstandingAmount: 0,
        hasUnsettledCourierTxn: true,
        hasUnsettledCustomerAmount: true,
      );

      final printable = buildPrintableInvoiceFromCards(
        source: card,
        details: card,
        fallbackItemLabel: 'Items',
      );

      expect(printable.outstanding, printable.total);
      expect(printable.paid, 0);
    });

    test('prints PAID with the new method after the collection method changes', () {
      // The courier transaction stays unsettled for the SHIPPING leg, but the
      // customer leg is zeroed because the transfer already landed.
      final card = _invoiceCard(
        status: 'Out for Delivery',
        docStatus: 'Paid',
        paymentMethod: 'Instapay',
        actualPaymentMethod: 'Instapay',
        outstandingAmount: 0,
        hasUnsettledCourierTxn: true,
        hasUnsettledCustomerAmount: false,
      );

      final printable = buildPrintableInvoiceFromCards(
        source: card,
        details: card,
        fallbackItemLabel: 'Items',
      );

      expect(printable.outstanding, 0);
      expect(printable.paid, printable.total);
      expect(printable.paymentMethod, 'Instapay');
    });

    test('falls back to the board card when details omits the actual method', () {
      // An un-upgraded backend leaves actual_payment_method off get_invoice_details.
      final source = _invoiceCard(
        status: 'Out for Delivery',
        docStatus: 'Paid',
        paymentMethod: 'Instapay',
        actualPaymentMethod: 'Instapay',
        outstandingAmount: 0,
      );
      final details = _invoiceCard(
        status: 'Out for Delivery',
        docStatus: 'Paid',
        paymentMethod: 'Instapay',
        outstandingAmount: 0,
      );

      final printable = buildPrintableInvoiceFromCards(
        source: source,
        details: details,
        fallbackItemLabel: 'Items',
      );

      expect(printable.paymentMethod, 'Instapay');
      expect(printable.paid, printable.total);
    });

    test('prints UNPAID for an order still carrying an outstanding balance', () {
      final card = _invoiceCard(
        status: 'Received',
        docStatus: 'Unpaid',
        paymentMethod: 'Cash',
        outstandingAmount: 720,
      );

      final printable = buildPrintableInvoiceFromCards(
        source: card,
        details: card,
        fallbackItemLabel: 'Items',
      );

      expect(printable.outstanding, 720);
      expect(printable.paid, 0);
      expect(printable.paymentMethod, 'Cash');
    });
  });
}

InvoiceCard _invoiceCard({
  String territory = 'EGMAADI',
  String fullAddress = '1 Example St, Cairo',
  String? territoryNameAr,
  List<InvoiceItem> items = const <InvoiceItem>[],
  String status = 'Received',
  String? docStatus,
  String? paymentMethod,
  String? actualPaymentMethod,
  double outstandingAmount = 0,
  bool hasUnsettledCourierTxn = false,
  bool hasUnsettledCustomerAmount = false,
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-15723',
    invoiceIdShort: '15723',
    customerName: 'Moaz Mohamed',
    customer: 'CUST-0001',
    territory: territory,
    deliveryDate: '2026-05-05',
    deliveryTimeFrom: '13:00:00',
    status: status,
    docStatus: docStatus,
    paymentMethod: paymentMethod,
    actualPaymentMethod: actualPaymentMethod,
    outstandingAmount: outstandingAmount,
    hasUnsettledCourierTxn: hasUnsettledCourierTxn,
    hasUnsettledCustomerAmount: hasUnsettledCustomerAmount,
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