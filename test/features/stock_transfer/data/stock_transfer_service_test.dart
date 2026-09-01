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

    group('listTransfers', () {
      const path = '/api/method/jarz_pos.api.transfer.list_transfers';

      test('unwraps the rows and the filtered total', () async {
        mockDio.setResponse(path, {
          'message': {
            'transfers': [
              {'name': 'MAT-STE-0001', 'total_qty': 5.0, 'items': []},
            ],
            'total': 12,
          },
        });

        final result = await service.listTransfers();

        expect(result.transfers, hasLength(1));
        expect(result.transfers.first['name'], equals('MAT-STE-0001'));
        expect(result.total, equals(12),
            reason: 'the sheet pages against total, not the row count');
      });

      test('falls back to the row count when total is missing', () async {
        mockDio.setResponse(path, {
          'message': {
            'transfers': [
              {'name': 'A'},
              {'name': 'B'},
            ],
          },
        });

        final result = await service.listTransfers();

        expect(result.total, equals(2));
      });

      test('returns nothing rather than throwing on an unexpected shape',
          () async {
        mockDio.setResponse(path, {'message': 'nope'});

        final result = await service.listTransfers();

        expect(result.transfers, isEmpty);
        expect(result.total, equals(0));
      });

      test('omits filters that were not supplied', () async {
        mockDio.setResponse(path, {
          'message': {'transfers': [], 'total': 0},
        });

        await service.listTransfers(limit: 10, page: 2);

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['limit'], equals(10));
        expect(data['page'], equals(2));
        expect(data.containsKey('source_warehouse'), isFalse);
        expect(data.containsKey('from_date'), isFalse);
        expect(data.containsKey('search'), isFalse);
      });

      test('sends every filter it is given, and drops an empty search',
          () async {
        mockDio.setResponse(path, {
          'message': {'transfers': [], 'total': 0},
        });

        await service.listTransfers(
          sourceWarehouse: 'Stores - J',
          targetWarehouse: 'Finished Goods - J',
          fromDate: '2026-01-01',
          toDate: '2026-01-31',
          search: '',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['source_warehouse'], equals('Stores - J'));
        expect(data['target_warehouse'], equals('Finished Goods - J'));
        expect(data['from_date'], equals('2026-01-01'));
        expect(data['to_date'], equals('2026-01-31'));
        expect(data.containsKey('search'), isFalse,
            reason: 'an empty box must not narrow the results');
      });
    });
  });
}
