import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/inventory_count/data/inventory_count_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('InventoryCountService', () {
    late MockDio mockDio;
    late InventoryCountService service;

    setUp(() {
      mockDio = MockDio();
      service = InventoryCountService(mockDio);
    });

    group('listWarehouses', () {
      test('returns list of warehouses', () async {
        final warehouses = [
          {'name': 'Main Warehouse', 'company': 'Test Company'},
          {'name': 'Branch Warehouse', 'company': 'Test Company'},
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_warehouses',
          {'message': warehouses},
        );

        final result = await service.listWarehouses();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Main Warehouse'));
      });

      test('sends company parameter when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_warehouses',
          {'message': []},
        );

        await service.listWarehouses(company: 'Test Company');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['company'], equals('Test Company'));
      });

      test('omits company when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_warehouses',
          {'message': []},
        );

        await service.listWarehouses();

        final requests = mockDio.requestLog;
        expect(requests.first['data'].containsKey('company'), isFalse);
      });

      test('returns empty list on unexpected format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_warehouses',
          'unexpected',
        );

        final result = await service.listWarehouses();

        expect(result, isEmpty);
      });
    });

    group('listItemsForCount', () {
      test('returns items for count with required parameters', () async {
        final items = [
          {'item_code': 'ITEM-001', 'item_name': 'Product A', 'stock_qty': 10},
          {'item_code': 'ITEM-002', 'item_name': 'Product B', 'stock_qty': 5},
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_items_for_count',
          {'message': items},
        );

        final result = await service.listItemsForCount(warehouse: 'Main Warehouse');

        expect(result, hasLength(2));
        expect(result[0]['item_code'], equals('ITEM-001'));
      });

      test('sends all optional parameters when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_items_for_count',
          {'message': []},
        );

        await service.listItemsForCount(
          warehouse: 'Main Warehouse',
          search: 'laptop',
          itemGroup: 'Electronics',
          limit: 50,
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['warehouse'], equals('Main Warehouse'));
        expect(data['search'], equals('laptop'));
        expect(data['item_group'], equals('Electronics'));
        expect(data['limit'], equals(50));
      });

      test('omits optional parameters when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_items_for_count',
          {'message': []},
        );

        await service.listItemsForCount(warehouse: 'Main Warehouse');

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data.containsKey('search'), isFalse);
        expect(data.containsKey('item_group'), isFalse);
        expect(data.containsKey('limit'), isFalse);
      });

      test('returns empty list on unexpected format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.list_items_for_count',
          'unexpected',
        );

        final result = await service.listItemsForCount(warehouse: 'Main');

        expect(result, isEmpty);
      });
    });

    group('submitReconciliation', () {
      Map<String, dynamic> decodeSubmitPayload() {
        final requests = mockDio.requestLog;
        expect(requests, hasLength(1));
        expect(
          requests.single['path'],
          equals('/api/method/jarz_pos.api.inventory_count.submit_reconciliation'),
        );
        expect(requests.single['data'], isA<String>());
        return Map<String, dynamic>.from(
          jsonDecode(requests.single['data'] as String) as Map,
        );
      }

      test('submits reconciliation with required parameters', () async {
        final response = {
          'name': 'SR-001',
          'status': 'Submitted',
          'difference_amount': 100.0,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          {'message': response},
        );

        final lines = [
          {'item_code': 'ITEM-001', 'counted_qty': 10, 'system_qty': 8},
        ];

        final result = await service.submitReconciliation(
          warehouse: 'Main Warehouse',
          lines: lines,
        );

        expect(result['name'], equals('SR-001'));
        expect(result['status'], equals('Submitted'));
      });

      test('encodes posting date, enforce flag, and lines into JSON payload', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          {'message': {}},
        );

        final lines = [
          {
            'item_code': 'ITEM-001',
            'counted_qty': 10,
            'uom': 'Box',
            'valuation_rate': 12.5,
          },
        ];

        await service.submitReconciliation(
          warehouse: 'Main Warehouse',
          lines: lines,
          postingDate: '2025-05-01',
          enforceAll: false,
        );

        final payload = decodeSubmitPayload();
        final payloadLines = (payload['lines'] as List)
            .map((line) => Map<String, dynamic>.from(line as Map))
            .toList();

        expect(payload['warehouse'], equals('Main Warehouse'));
        expect(payload['posting_date'], equals('2025-05-01'));
        expect(payload['enforce_all'], equals(0));
        expect(payloadLines, hasLength(1));
        expect(payloadLines.single['item_code'], equals('ITEM-001'));
        expect(payloadLines.single['counted_qty'], equals(10));
        expect(payloadLines.single['uom'], equals('Box'));
        expect(payloadLines.single['valuation_rate'], equals(12.5));
      });

      test('encodes enforceAll true as integer 1', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          {'message': {}},
        );

        await service.submitReconciliation(
          warehouse: 'Main',
          lines: [
            {'item_code': 'ITEM-001', 'counted_qty': 2},
          ],
          enforceAll: true,
        );

        final payload = decodeSubmitPayload();

        expect(payload['enforce_all'], equals(1));
      });

      test('defaults enforceAll to 1', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          {'message': {}},
        );

        await service.submitReconciliation(
          warehouse: 'Main',
          lines: [],
        );

        final payload = decodeSubmitPayload();

        expect(payload['enforce_all'], equals(1));
      });

      test('handles direct map response', () async {
        final response = {'name': 'SR-002'};

        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          response,
        );

        final result = await service.submitReconciliation(
          warehouse: 'Main',
          lines: [],
        );

        expect(result['name'], equals('SR-002'));
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          'unexpected',
        );

        expect(
          () => service.submitReconciliation(
            warehouse: 'Main',
            lines: [],
          ),
          throwsException,
        );
      });

      test('omits posting_date when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
          {'message': {}},
        );

        await service.submitReconciliation(
          warehouse: 'Main',
          lines: [],
        );

        final payload = decodeSubmitPayload();

        expect(payload.containsKey('posting_date'), isFalse);
      });
    });
  });
}
