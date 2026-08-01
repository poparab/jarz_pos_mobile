import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';

import '../../../helpers/mock_services.dart';

/// Covers the Production Board endpoints. The pre-existing
/// `manufacturing_service_test.dart` covers the older work-order methods.
void main() {
  late MockDio mockDio;
  late ManufacturingService service;

  setUp(() {
    mockDio = MockDio();
    service = ManufacturingService(mockDio);
  });

  group('getProductionSuggestions', () {
    const path =
        '/api/method/jarz_pos.api.production.get_production_suggestions';

    test('parses the ranked board from the message envelope', () async {
      mockDio.setResponse(path, {
        'message': {
          'company': 'Jarz Co',
          'season': {'name': 'Ramadan', 'multiplier': 1.8},
          'default_target_days': 10,
          'velocity_updated_on': '2026-07-28 03:00:00',
          'items': [
            {
              'item_code': 'PIST-CAKE',
              'item_name': 'Pistachio cake',
              'status': 'critical',
              'suggested_batches': 7,
              'can_make_now_batches': 3,
              'bom_qty': 10,
            },
          ],
          'summary': {'critical': 1, 'total_suggested_batches': 7},
        },
      });

      final page = await service.getProductionSuggestions();

      expect(page.items, hasLength(1));
      expect(page.items.first.itemCode, 'PIST-CAKE');
      expect(page.items.first.achievableBatches, 3);
      expect(page.season.name, 'Ramadan');
      expect(page.summary.critical, 1);
    });

    test('sends capacity and refresh flags as the ints the API expects',
        () async {
      mockDio.setResponse(path, {
        'message': {'items': <dynamic>[]},
      });

      await service.getProductionSuggestions(
        includeCapacity: false,
        forceRefresh: true,
        search: 'cake',
        status: 'critical',
      );

      final body = mockDio.requestLog.first['data'] as Map;
      expect(body['include_capacity'], 0);
      expect(body['force_refresh'], 1);
      expect(body['search'], 'cake');
      expect(body['status'], 'critical');
    });

    test('omits empty search and status rather than sending blanks', () async {
      mockDio.setResponse(path, {
        'message': {'items': <dynamic>[]},
      });

      await service.getProductionSuggestions(search: '', status: '');

      final body = mockDio.requestLog.first['data'] as Map;
      expect(body.containsKey('search'), isFalse);
      expect(body.containsKey('status'), isFalse);
      // capacity defaults on
      expect(body['include_capacity'], 1);
    });

    test('surfaces the Frappe error message on failure', () async {
      mockDio.setError(
        path,
        createMockDioException(
          statusCode: 403,
          type: DioExceptionType.badResponse,
          data: {'message': 'Not permitted: production access required'},
        ),
      );

      expect(
        () => service.getProductionSuggestions(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('production access required'),
        )),
      );
    });
  });

  group('getBasketMaterialRollup', () {
    const path =
        '/api/method/jarz_pos.api.production.get_basket_material_rollup';

    test('reports a shortage no single line would have shown', () async {
      mockDio.setResponse(path, {
        'message': {
          'ok': false,
          'components': [
            {
              'item_code': 'FLOUR',
              'required_qty': 12.0,
              'available_qty': 10.0,
              'missing_qty': 2.0,
              'reason': 'insufficient_stock',
              'contributing_lines': [
                {'line_index': 0, 'item_code': 'CAKE-A'},
                {'line_index': 1, 'item_code': 'CAKE-B'},
              ],
            },
          ],
          'shortages': [
            {'item_code': 'FLOUR', 'missing_qty': 2.0},
          ],
        },
      });

      final rollup = await service.getBasketMaterialRollup([
        {'item_code': 'CAKE-A', 'bom_name': 'BOM-A', 'item_qty': 10},
        {'item_code': 'CAKE-B', 'bom_name': 'BOM-B', 'item_qty': 10},
      ]);

      expect(rollup.ok, isFalse);
      expect(rollup.shortages, hasLength(1));
      expect(rollup.components.first.isSharedAcrossLines, isTrue);
    });

    test('posts the lines under a lines key', () async {
      mockDio.setResponse(path, {
        'message': {
          'ok': true,
          'components': <dynamic>[],
          'shortages': <dynamic>[],
        },
      });

      await service.getBasketMaterialRollup([
        {'item_code': 'CAKE-A', 'bom_name': 'BOM-A', 'item_qty': 10},
      ]);

      final body = mockDio.requestLog.first['data'] as Map;
      expect(body['lines'], hasLength(1));
      expect((body['lines'] as List).first['item_code'], 'CAKE-A');
    });
  });

  group('setItemTargetDays', () {
    const path = '/api/method/jarz_pos.api.production.set_item_target_days';

    test('sends the override', () async {
      mockDio.setResponse(path, {
        'message': {'ok': true, 'target_days': 5, 'uses_default': false},
      });

      final result = await service.setItemTargetDays(
        itemCode: 'PIST-CAKE',
        targetDays: 5,
      );

      final body = mockDio.requestLog.first['data'] as Map;
      expect(body['item_code'], 'PIST-CAKE');
      expect(body['target_days'], 5);
      expect(result['target_days'], 5);
    });

    test('a null target sends 0, which the backend reads as "use default"',
        () async {
      mockDio.setResponse(path, {
        'message': {'ok': true, 'uses_default': true},
      });

      await service.setItemTargetDays(itemCode: 'PIST-CAKE');

      expect((mockDio.requestLog.first['data'] as Map)['target_days'], 0);
    });
  });

  group('typed wrappers', () {
    test('searchBomItems maps rows onto BomItemSummary', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
        {
          'message': [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Product A',
              'stock_uom': 'Nos',
              'default_bom': 'BOM-001',
              'bom_qty': 10,
            },
          ],
        },
      );

      final items = await service.searchBomItems('product');

      expect(items, hasLength(1));
      expect(items.first.defaultBom, 'BOM-001');
      expect(items.first.bomQty, 10.0);
    });

    test('fetchBomDetails maps components and scales them', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.manufacturing.get_bom_details',
        {
          'message': {
            'item_code': 'PIST-CAKE',
            'item_name': 'Pistachio cake',
            'stock_uom': 'Nos',
            'default_bom': 'BOM-PIST',
            'bom_qty': 10,
            'components': [
              {
                'item_code': 'PIST-SPR',
                'item_name': 'Pistachio spread',
                'uom': 'Kg',
                'qty_per_bom': 1.83,
                'available_qty': 5.0,
                'source_warehouse': 'Raw Material - J',
              },
            ],
          },
        },
      );

      final bom = await service.fetchBomDetails('PIST-CAKE');

      expect(bom.bomQty, 10.0);
      expect(bom.components, hasLength(1));
      expect(bom.components.first.qtyPerBom, 1.83);
      expect(bom.components.first.totalForBatches(3), closeTo(5.49, 1e-9));
    });
  });
}
