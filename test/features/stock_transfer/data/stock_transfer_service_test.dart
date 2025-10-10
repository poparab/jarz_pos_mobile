import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_transfer_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('StockTransferService', () {
    late MockDio mockDio;
    late StockTransferService service;

    setUp(() {
      mockDio = MockDio();
      service = StockTransferService(mockDio);
    });

    group('listPosProfiles', () {
      test('returns list of POS profiles from message', () async {
        final profiles = [
          {'name': 'Main POS', 'warehouse': 'Main Store'},
          {'name': 'Branch POS', 'warehouse': 'Branch Store'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_pos_profiles',
          {'message': profiles},
        );

        final result = await service.listPosProfiles();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Main POS'));
      });

      test('returns list when response is directly a list', () async {
        final profiles = [{'name': 'POS 1'}];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_pos_profiles',
          profiles,
        );

        final result = await service.listPosProfiles();

        expect(result, hasLength(1));
      });

      test('returns empty list on unexpected format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_pos_profiles',
          'unexpected',
        );

        final result = await service.listPosProfiles();

        expect(result, isEmpty);
      });
    });

    group('listItemGroups', () {
      test('returns list of item groups', () async {
        final groups = [
          {'name': 'Electronics', 'parent_item_group': ''},
          {'name': 'Food', 'parent_item_group': ''},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_item_groups',
          {'message': groups},
        );

        final result = await service.listItemGroups();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Electronics'));
      });

      test('sends search parameter when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_item_groups',
          {'message': []},
        );

        await service.listItemGroups(search: 'electronics');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['search'], equals('electronics'));
      });

      test('omits search parameter when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.list_item_groups',
          {'message': []},
        );

        await service.listItemGroups();

        final requests = mockDio.requestLog;
        expect(requests.first['data'].containsKey('search'), isFalse);
      });
    });

    group('searchItemsWithStock', () {
      test('returns items with stock information', () async {
        final items = [
          {'item_code': 'ITEM-001', 'stock_qty': 10},
          {'item_code': 'ITEM-002', 'stock_qty': 5},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.search_items_with_stock',
          {'message': items},
        );

        final result = await service.searchItemsWithStock(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
        );

        expect(result, hasLength(2));
        expect(result[0]['item_code'], equals('ITEM-001'));
      });

      test('sends all required parameters', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.search_items_with_stock',
          {'message': []},
        );

        await service.searchItemsWithStock(
          sourceWarehouse: 'Main Store',
          targetWarehouse: 'Branch Store',
          search: 'laptop',
          itemGroup: 'Electronics',
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['source_warehouse'], equals('Main Store'));
        expect(data['target_warehouse'], equals('Branch Store'));
        expect(data['search'], equals('laptop'));
        expect(data['item_group'], equals('Electronics'));
      });

      test('omits optional parameters when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.search_items_with_stock',
          {'message': []},
        );

        await service.searchItemsWithStock(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data.containsKey('search'), isFalse);
        expect(data.containsKey('item_group'), isFalse);
      });
    });

    group('submitTransfer', () {
      test('submits stock transfer successfully', () async {
        final response = {'name': 'STE-001', 'status': 'Submitted'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.submit_transfer',
          {'message': response},
        );

        final result = await service.submitTransfer(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
          lines: [
            {'item_code': 'ITEM-001', 'qty': 5},
          ],
        );

        expect(result['name'], equals('STE-001'));
        expect(result['status'], equals('Submitted'));
      });

      test('sends all parameters correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.submit_transfer',
          {'message': {}},
        );

        final lines = [
          {'item_code': 'ITEM-001', 'qty': 10},
          {'item_code': 'ITEM-002', 'qty': 5},
        ];

        await service.submitTransfer(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
          lines: lines,
          postingDate: '2025-05-01',
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['source_warehouse'], equals('Main'));
        expect(data['target_warehouse'], equals('Branch'));
        expect(data['lines'], equals(lines));
        expect(data['posting_date'], equals('2025-05-01'));
      });

      test('handles direct map response', () async {
        final response = {'name': 'STE-002'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.submit_transfer',
          response,
        );

        final result = await service.submitTransfer(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
          lines: [],
        );

        expect(result['name'], equals('STE-002'));
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.submit_transfer',
          'unexpected',
        );

        expect(
          () => service.submitTransfer(
            sourceWarehouse: 'Main',
            targetWarehouse: 'Branch',
            lines: [],
          ),
          throwsException,
        );
      });

      test('omits posting_date when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.transfer.submit_transfer',
          {'message': {}},
        );

        await service.submitTransfer(
          sourceWarehouse: 'Main',
          targetWarehouse: 'Branch',
          lines: [],
        );

        final requests = mockDio.requestLog;
        expect(requests.first['data'].containsKey('posting_date'), isFalse);
      });
    });
  });
}
