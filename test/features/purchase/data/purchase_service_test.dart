import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/data/purchase_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('PurchaseService', () {
    late MockDio mockDio;
    late PurchaseService service;

    setUp(() {
      mockDio = MockDio();
      service = PurchaseService(mockDio);
    });

    group('getSuppliers', () {
      test('returns list of suppliers', () async {
        final suppliers = [
          {'name': 'SUP-001', 'supplier_name': 'Supplier A'},
          {'name': 'SUP-002', 'supplier_name': 'Supplier B'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_suppliers',
          {'message': suppliers},
        );

        final result = await service.getSuppliers('supplier');

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('SUP-001'));
      });

      test('sends search parameter', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_suppliers',
          {'message': []},
        );

        await service.getSuppliers('test search');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['search'], equals('test search'));
      });
    });

    group('getRecentSuppliers', () {
      test('returns recent suppliers', () async {
        final suppliers = [
          {'name': 'SUP-001', 'supplier_name': 'Recent Supplier'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_recent_suppliers',
          {'message': suppliers},
        );

        final result = await service.getRecentSuppliers();

        expect(result, hasLength(1));
        expect(result[0]['name'], equals('SUP-001'));
      });

      test('returns empty list on no recent suppliers', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_recent_suppliers',
          {'message': []},
        );

        final result = await service.getRecentSuppliers();

        expect(result, isEmpty);
      });
    });

    group('searchItems', () {
      test('returns list of items', () async {
        final items = [
          {'item_code': 'ITEM-001', 'item_name': 'Item A'},
          {'item_code': 'ITEM-002', 'item_name': 'Item B'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.search_items',
          {'message': items},
        );

        final result = await service.searchItems('item');

        expect(result, hasLength(2));
        expect(result[0]['item_code'], equals('ITEM-001'));
      });

      test('sends search parameter', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.search_items',
          {'message': []},
        );

        await service.searchItems('laptop');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['search'], equals('laptop'));
      });
    });

    group('getItemDetails', () {
      test('returns item details', () async {
        final itemDetails = {
          'item_code': 'ITEM-001',
          'item_name': 'Product',
          'stock_uom': 'Nos',
        };
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_item_details',
          {'message': itemDetails},
        );

        final result = await service.getItemDetails('ITEM-001');

        expect(result['item_code'], equals('ITEM-001'));
        expect(result['stock_uom'], equals('Nos'));
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_item_details',
          'unexpected',
        );

        expect(
          () => service.getItemDetails('ITEM-001'),
          throwsException,
        );
      });
    });

    group('getItemPrice', () {
      test('returns item price without UOM', () async {
        final priceInfo = {'price': 100.0, 'currency': 'USD'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_item_price',
          {'message': priceInfo},
        );

        final result = await service.getItemPrice('ITEM-001');

        expect(result['price'], equals(100.0));
        expect(result['currency'], equals('USD'));
      });

      test('sends UOM when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_item_price',
          {'message': {}},
        );

        await service.getItemPrice('ITEM-001', uom: 'Box');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['uom'], equals('Box'));
      });

      test('omits UOM when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.get_item_price',
          {'message': {}},
        );

        await service.getItemPrice('ITEM-001');

        final requests = mockDio.requestLog;
        expect(requests.first['data'].containsKey('uom'), isFalse);
      });
    });

    group('createPurchaseInvoice', () {
      test('creates purchase invoice with required parameters', () async {
        final response = {'name': 'PINV-001', 'status': 'Submitted'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
          {'message': response},
        );

        final items = [
          {'item_code': 'ITEM-001', 'qty': 10, 'rate': 100},
        ];

        final result = await service.createPurchaseInvoice(
          supplier: 'SUP-001',
          postingDate: '2025-05-01',
          isPaid: true,
          items: items,
        );

        expect(result['name'], equals('PINV-001'));
        expect(result['status'], equals('Submitted'));
      });

      test('sends all parameters correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
          {'message': {}},
        );

        final items = [
          {'item_code': 'ITEM-001', 'qty': 5, 'rate': 50},
        ];

        await service.createPurchaseInvoice(
          supplier: 'SUP-001',
          postingDate: '2025-05-01',
          isPaid: true,
          items: items,
          company: 'Test Company',
          paymentOption: 'Cash',
          shippingAmount: 25.0,
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['supplier'], equals('SUP-001'));
        expect(data['posting_date'], equals('2025-05-01'));
        expect(data['is_paid'], equals(1));
        expect(data['items'], equals(items));
        expect(data['company'], equals('Test Company'));
        expect(data['payment_option'], equals('Cash'));
        expect(data['shipping_amount'], equals(25.0));
      });

      test('converts isPaid boolean to integer', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
          {'message': {}},
        );

        await service.createPurchaseInvoice(
          supplier: 'SUP-001',
          postingDate: '2025-05-01',
          isPaid: false,
          items: [],
        );

        final requests = mockDio.requestLog;
        expect(requests.first['data']['is_paid'], equals(0));
      });

      test('omits optional parameters when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
          {'message': {}},
        );

        await service.createPurchaseInvoice(
          supplier: 'SUP-001',
          postingDate: '2025-05-01',
          isPaid: true,
          items: [],
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data.containsKey('company'), isFalse);
        expect(data.containsKey('payment_option'), isFalse);
        expect(data.containsKey('shipping_amount'), isFalse);
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
          'unexpected',
        );

        expect(
          () => service.createPurchaseInvoice(
            supplier: 'SUP-001',
            postingDate: '2025-05-01',
            isPaid: true,
            items: [],
          ),
          throwsException,
        );
      });
    });
  });
}
