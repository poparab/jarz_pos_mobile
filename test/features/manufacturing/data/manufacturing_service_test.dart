import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('ManufacturingService', () {
    late MockDio mockDio;
    late ManufacturingService service;

    setUp(() {
      mockDio = MockDio();
      service = ManufacturingService(mockDio);
    });

    group('listDefaultBomItems', () {
      test('returns list of BOM items from message', () async {
        final items = [
          {'item_code': 'ITEM-001', 'item_name': 'Product A', 'has_bom': true},
          {'item_code': 'ITEM-002', 'item_name': 'Product B', 'has_bom': true},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
          {'message': items},
        );

        final result = await service.listDefaultBomItems('product');

        expect(result, hasLength(2));
        expect(result[0]['item_code'], equals('ITEM-001'));
      });

      test('sends search parameter correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
          {'message': []},
        );

        await service.listDefaultBomItems('laptop');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['search'], equals('laptop'));
      });

      test('returns list when response is directly a list', () async {
        final items = [{'item_code': 'ITEM-001'}];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
          items,
        );

        final result = await service.listDefaultBomItems('search');

        expect(result, hasLength(1));
      });

      test('returns empty list on unexpected format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
          'unexpected',
        );

        final result = await service.listDefaultBomItems('search');

        expect(result, isEmpty);
      });
    });

    group('getBomDetails', () {
      test('returns BOM details from message', () async {
        final bomDetails = {
          'bom_name': 'BOM-ITEM-001',
          'items': [
            {'item_code': 'RM-001', 'qty': 2},
          ],
        };
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.get_bom_details',
          {'message': bomDetails},
        );

        final result = await service.getBomDetails('ITEM-001');

        expect(result['bom_name'], equals('BOM-ITEM-001'));
        expect(result['items'], hasLength(1));
      });

      test('sends item_code parameter correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.get_bom_details',
          {'message': {}},
        );

        await service.getBomDetails('ITEM-123');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['item_code'], equals('ITEM-123'));
      });

      test('handles direct map response', () async {
        final bomDetails = {'bom_name': 'BOM-001'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.get_bom_details',
          bomDetails,
        );

        final result = await service.getBomDetails('ITEM-001');

        expect(result['bom_name'], equals('BOM-001'));
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.get_bom_details',
          'unexpected',
        );

        expect(
          () => service.getBomDetails('ITEM-001'),
          throwsException,
        );
      });
    });

    group('submitWorkOrders', () {
      test('submits multiple work orders successfully', () async {
        final response = {'created': 2, 'work_orders': ['WO-001', 'WO-002']};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_work_orders',
          {'message': response},
        );

        final lines = [
          {'item_code': 'ITEM-001', 'qty': 10},
          {'item_code': 'ITEM-002', 'qty': 5},
        ];

        final result = await service.submitWorkOrders(lines);

        expect(result['created'], equals(2));
        expect(result['work_orders'], hasLength(2));
      });

      test('sends lines parameter correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_work_orders',
          {'message': {}},
        );

        final lines = [{'item_code': 'ITEM-001', 'qty': 5}];
        await service.submitWorkOrders(lines);

        final requests = mockDio.requestLog;
        expect(requests.first['data']['lines'], equals(lines));
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_work_orders',
          'unexpected',
        );

        expect(
          () => service.submitWorkOrders([]),
          throwsException,
        );
      });
    });

    group('submitSingleWorkOrder', () {
      test('submits single work order with required parameters', () async {
        final response = {'name': 'WO-001', 'status': 'Draft'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_single_work_order',
          {'message': response},
        );

        final result = await service.submitSingleWorkOrder(
          itemCode: 'ITEM-001',
          bomName: 'BOM-ITEM-001',
          itemQty: 10.0,
        );

        expect(result['name'], equals('WO-001'));
        expect(result['status'], equals('Draft'));
      });

      test('sends all parameters correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_single_work_order',
          {'message': {}},
        );

        await service.submitSingleWorkOrder(
          itemCode: 'ITEM-001',
          bomName: 'BOM-001',
          itemQty: 15.0,
          scheduledAt: '2025-05-01',
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['item_code'], equals('ITEM-001'));
        expect(data['bom_name'], equals('BOM-001'));
        expect(data['item_qty'], equals(15.0));
        expect(data['scheduled_at'], equals('2025-05-01'));
      });

      test('omits scheduledAt when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_single_work_order',
          {'message': {}},
        );

        await service.submitSingleWorkOrder(
          itemCode: 'ITEM-001',
          bomName: 'BOM-001',
          itemQty: 10.0,
        );

        final requests = mockDio.requestLog;
        expect(requests.first['data'].containsKey('scheduled_at'), isFalse);
      });

      test('throws exception on unexpected response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.submit_single_work_order',
          'unexpected',
        );

        expect(
          () => service.submitSingleWorkOrder(
            itemCode: 'ITEM-001',
            bomName: 'BOM-001',
            itemQty: 10.0,
          ),
          throwsException,
        );
      });
    });

    group('listRecentWorkOrders', () {
      test('returns recent work orders with default limit', () async {
        final orders = [
          {'name': 'WO-001', 'status': 'Submitted'},
          {'name': 'WO-002', 'status': 'In Progress'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders',
          {'message': orders},
        );

        final result = await service.listRecentWorkOrders();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('WO-001'));
      });

      test('uses custom limit when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders',
          {'message': []},
        );

        await service.listRecentWorkOrders(limit: 100);

        final requests = mockDio.requestLog;
        expect(requests.first['data']['limit'], equals(100));
      });

      test('uses default limit of 50 when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders',
          {'message': []},
        );

        await service.listRecentWorkOrders();

        final requests = mockDio.requestLog;
        expect(requests.first['data']['limit'], equals(50));
      });

      test('returns empty list on unexpected format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders',
          'unexpected',
        );

        final result = await service.listRecentWorkOrders();

        expect(result, isEmpty);
      });
    });
  });
}
