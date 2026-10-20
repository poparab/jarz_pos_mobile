import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_handover_models.dart';
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

    group('submitTransfer pending handover', () {
      const path = '/api/method/jarz_pos.api.transfer.submit_transfer';

      test('a branch-bound transfer answers pending with a handover', () async {
        mockDio.setResponse(path, {
          'message': {
            'ok': true,
            'stock_entry': null,
            'handover': 'HND-2026-00001',
            'pending': true,
          },
        });

        final res = await service.submitTransfer(
          sourceWarehouse: 'Finished Goods - J',
          targetWarehouse: 'Dokki - J',
          lines: [
            {'item_code': 'JAR-L', 'qty': 4},
          ],
        );
        final outcome = TransferSubmitOutcome.fromJson(res);

        expect(outcome.pending, isTrue);
        expect(outcome.handover, equals('HND-2026-00001'));
        expect(outcome.stockEntry, isNull,
            reason: 'nothing has moved until the branch confirms');
      });

      test('the old posted shape still reads as posted', () {
        final outcome = TransferSubmitOutcome.fromJson(
          {'ok': true, 'stock_entry': 'MAT-STE-0009'},
        );

        expect(outcome.pending, isFalse);
        expect(outcome.stockEntry, equals('MAT-STE-0009'));
        expect(outcome.handover, isNull);
      });

      test('a handover name alone means pending, whatever the flag says', () {
        final outcome = TransferSubmitOutcome.fromJson(
          {'ok': true, 'handover': 'HND-2026-00002'},
        );

        expect(outcome.pending, isTrue);
      });
    });

    group('getHandoverContext', () {
      const path = '/api/method/jarz_pos.api.stock_handover.get_context';

      test('parses sides, counterparts and can_manage', () async {
        mockDio.setResponse(path, {
          'message': {
            'my_sides': [
              {
                'warehouse': 'Dokki - J',
                'label': 'Dokki',
                'kind': 'branch',
                'pos_profile': 'Dokki',
              },
            ],
            'counterparts': [
              {'warehouse': 'Dokki - J', 'label': 'Dokki', 'kind': 'branch'},
              {'warehouse': 'Zayed - J', 'label': 'Zayed', 'kind': 'branch'},
              {
                'warehouse': 'Finished Goods - J',
                'label': 'Factory',
                'kind': 'factory',
              },
            ],
            'can_manage': false,
          },
        });

        final ctx = await service.getHandoverContext(posProfile: 'Dokki');

        expect(mockDio.requestLog.first['data']['pos_profile'], 'Dokki');
        expect(ctx.canManage, isFalse);
        expect(ctx.canDeclare, isTrue);
        expect(ctx.mySides.single.isBranch, isTrue);
        expect(ctx.mySides.single.posProfile, 'Dokki');

        final others = ctx.counterpartsFor(ctx.mySides.single);
        expect(others.map((c) => c.label), ['Factory', 'Zayed'],
            reason: 'own side excluded, factory first');
      });

      test('omits pos_profile when there is none', () async {
        mockDio.setResponse(path, {
          'message': {'my_sides': [], 'counterparts': [], 'can_manage': true},
        });

        final ctx = await service.getHandoverContext();

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data.containsKey('pos_profile'), isFalse);
        expect(ctx.canManage, isTrue);
        expect(ctx.canDeclare, isFalse);
      });

      test('an unexpected shape reads as no sides rather than throwing',
          () async {
        mockDio.setResponse(path, {'message': 'nope'});

        final ctx = await service.getHandoverContext();

        expect(ctx.mySides, isEmpty);
        expect(ctx.canManage, isFalse);
      });
    });

    group('listHandoverItems', () {
      const path = '/api/method/jarz_pos.api.stock_handover.list_items';

      test('sends both sides and parses the items', () async {
        mockDio.setResponse(path, {
          'message': {
            'items': [
              {
                'item_code': 'JAR-L-CHOC',
                'item_name': 'Chocolate Large',
                'item_group': 'Large',
                'stock_uom': 'Nos',
              },
              {'item_code': 'JAR-M-LOT', 'item_group': 'Medium'},
              {'item_name': 'no code'},
            ],
          },
        });

        final items = await service.listHandoverItems(
          myWarehouse: 'Dokki - J',
          counterpartWarehouse: 'Finished Goods - J',
          search: '  ',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['my_warehouse'], 'Dokki - J');
        expect(data['counterpart_warehouse'], 'Finished Goods - J');
        expect(data.containsKey('search'), isFalse,
            reason: 'a blank search must not narrow the list');
        expect(items, hasLength(2), reason: 'a row without a code is dropped');
        expect(items.first.itemGroup, 'Large');
        expect(items.first.stockUom, 'Nos');
        expect(items.last.itemName, 'JAR-M-LOT',
            reason: 'a missing name falls back to the code');
      });

      test('returns nothing on an unexpected shape', () async {
        mockDio.setResponse(path, {'message': 'nope'});

        final items = await service.listHandoverItems(
          myWarehouse: 'A',
          counterpartWarehouse: 'B',
        );

        expect(items, isEmpty);
      });
    });

    group('declareHandover', () {
      const path = '/api/method/jarz_pos.api.stock_handover.declare';

      test('sends only positive lines and parses the handover', () async {
        mockDio.setResponse(path, {
          'message': {
            'ok': true,
            'handover': {
              'name': 'HND-2026-00003',
              'status': 'Pending',
              'from_warehouse': 'Finished Goods - J',
              'from_label': 'Factory',
              'to_warehouse': 'Dokki - J',
              'to_label': 'Dokki',
              'awaiting_side': 'From',
              'awaiting_label': 'Factory',
              'declared_by_name': 'Mona',
              'declared_at': '2026-10-20 10:15:00',
              'changed': false,
              'can_respond': false,
              'can_cancel': true,
              'items': [
                {
                  'item_code': 'JAR-L-CHOC',
                  'item_name': 'Chocolate Large',
                  'stock_uom': 'Nos',
                  'qty': 12,
                  'declared_qty': 12,
                },
              ],
            },
          },
        });

        final h = await service.declareHandover(
          myWarehouse: 'Dokki - J',
          counterpartWarehouse: 'Finished Goods - J',
          direction: 'in',
          posProfile: 'Dokki',
          lines: [
            {'item_code': 'JAR-L-CHOC', 'qty': 12},
            {'item_code': 'JAR-M-LOT', 'qty': 0},
            {'item_code': 'JAR-S-X', 'qty': -2},
            {'item_code': 'JAR-S-Y', 'qty': double.nan},
          ],
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['direction'], 'in');
        expect(data['pos_profile'], 'Dokki');
        expect(data['lines'], [
          {'item_code': 'JAR-L-CHOC', 'qty': 12.0},
        ]);
        expect(h, isNotNull);
        expect(h!.name, 'HND-2026-00003');
        expect(h.isPending, isTrue);
        expect(h.canCancel, isTrue);
        expect(h.canRespond, isFalse);
        expect(h.awaitingWarehouse, 'Finished Goods - J');
        expect(h.proposingWarehouse, 'Dokki - J');
        expect(h.declaredAt, DateTime(2026, 10, 20, 10, 15));
        expect(h.items.single.qty, 12);
        expect(h.items.single.isChanged, isFalse);
        expect(h.totalQty, 12);
      });
    });

    group('listHandovers', () {
      const path = '/api/method/jarz_pos.api.stock_handover.list_handovers';

      test('parses the three lists, including a changed handover', () async {
        mockDio.setResponse(path, {
          'message': {
            'waiting_for_me': [
              {
                'name': 'HND-1',
                'status': 'Pending',
                'from_warehouse': 'Finished Goods - J',
                'to_warehouse': 'Dokki - J',
                'changed': 1,
                'can_respond': true,
                'items': [
                  {'item_code': 'A', 'qty': '10', 'declared_qty': 12},
                ],
              },
            ],
            'waiting_for_them': [],
            'recent': [
              {
                'name': 'HND-0',
                'status': 'Confirmed',
                'stock_entry': 'MAT-STE-1',
                'items': [],
              },
            ],
          },
        });

        final lists = await service.listHandovers(
          myWarehouse: 'Dokki - J',
          posProfile: 'Dokki',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['my_warehouse'], 'Dokki - J');
        expect(data['pos_profile'], 'Dokki');
        expect(data['limit'], 30);

        final h = lists.waitingForMe.single;
        expect(h.changed, isTrue);
        expect(h.canRespond, isTrue);
        expect(h.fromLabel, 'Finished Goods - J',
            reason: 'a missing label falls back to the warehouse');
        expect(h.items.single.qty, 10);
        expect(h.items.single.declaredQty, 12);
        expect(h.items.single.isChanged, isTrue);
        expect(lists.waitingForThem, isEmpty);
        expect(lists.recent.single.isConfirmed, isTrue);
        expect(lists.recent.single.stockEntry, 'MAT-STE-1');
      });

      test('a manager without a side sends no my_warehouse', () async {
        mockDio.setResponse(path, {'message': {}});

        final lists = await service.listHandovers();

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data.containsKey('my_warehouse'), isFalse);
        expect(data.containsKey('pos_profile'), isFalse);
        expect(lists.isEmpty, isTrue);
      });
    });

    group('respondToHandover / cancelHandover', () {
      const respondPath = '/api/method/jarz_pos.api.stock_handover.respond';
      const cancelPath = '/api/method/jarz_pos.api.stock_handover.cancel';

      test('confirm returns the handover with its stock entry', () async {
        mockDio.setResponse(respondPath, {
          'message': {
            'ok': true,
            'handover': {
              'name': 'HND-1',
              'status': 'Confirmed',
              'stock_entry': 'MAT-STE-77',
              'items': [],
            },
          },
        });

        final h = await service.respondToHandover(
          name: 'HND-1',
          action: 'confirm',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['name'], 'HND-1');
        expect(data['action'], 'confirm');
        expect(data.containsKey('lines'), isFalse);
        expect(data.containsKey('reason'), isFalse);
        expect(h!.isConfirmed, isTrue);
        expect(h.stockEntry, 'MAT-STE-77');
      });

      test('change sends positive lines; reject sends a trimmed reason',
          () async {
        mockDio.setResponse(respondPath, {
          'message': {'ok': true},
        });

        final changed = await service.respondToHandover(
          name: 'HND-1',
          action: 'change',
          lines: [
            {'item_code': 'A', 'qty': 9},
            {'item_code': 'B', 'qty': 0},
          ],
        );
        await service.respondToHandover(
          name: 'HND-1',
          action: 'reject',
          reason: '  wrong branch  ',
        );
        await service.respondToHandover(
          name: 'HND-1',
          action: 'reject',
          reason: '   ',
        );

        expect(changed, isNull,
            reason: 'an answer without a handover reads as null, not a crash');
        final log = mockDio.requestLog;
        expect(log[0]['data']['lines'], [
          {'item_code': 'A', 'qty': 9.0},
        ]);
        expect(log[1]['data']['reason'], 'wrong branch');
        expect((log[2]['data'] as Map).containsKey('reason'), isFalse);
      });

      test('a rejected handover carries its reason', () async {
        mockDio.setResponse(respondPath, {
          'message': {
            'ok': true,
            'handover': {
              'name': 'HND-1',
              'status': 'Rejected',
              'reject_reason': 'wrong branch',
              'items': [],
            },
          },
        });

        final h = await service.respondToHandover(
          name: 'HND-1',
          action: 'reject',
          reason: 'wrong branch',
        );

        expect(h!.isRejected, isTrue);
        expect(h.rejectReason, 'wrong branch');
      });

      test('cancel posts the name', () async {
        mockDio.setResponse(cancelPath, {
          'message': {
            'ok': true,
            'handover': {'name': 'HND-5', 'status': 'Cancelled', 'items': []},
          },
        });

        final h =
            await service.cancelHandover(name: 'HND-5', posProfile: 'Dokki');

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['name'], 'HND-5');
        expect(data['pos_profile'], 'Dokki');
        expect(h!.isCancelled, isTrue);
      });
    });

    group('positiveHandoverLines', () {
      test('keeps finite positive quantities as doubles', () {
        expect(
          positiveHandoverLines([
            {'item_code': 'A', 'qty': 2},
            {'item_code': 'B', 'qty': 1.5},
            {'item_code': 'C', 'qty': 0},
            {'item_code': 'D', 'qty': double.infinity},
            {'item_code': 'E', 'qty': '3'},
            {'qty': 4},
          ]),
          [
            {'item_code': 'A', 'qty': 2.0},
            {'item_code': 'B', 'qty': 1.5},
          ],
        );
      });
    });
  });
}
