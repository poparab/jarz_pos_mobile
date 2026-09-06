import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/reports/data/warehouse_alignment_service.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('WarehouseAlignmentService', () {
    late MockDio mockDio;
    late WarehouseAlignmentService service;

    setUp(() {
      mockDio = MockDio();
      service = WarehouseAlignmentService(mockDio);
    });

    test('parses rows from a message-wrapped {rows: [...]} envelope',
        () async {
      mockDio.setResponse(
        ApiEndpoints.warehouseAlignmentReport,
        createSuccessResponse(data: {
          'success': true,
          'rows': [
            {
              'name': 'ACC-SINV-2026-00042',
              'company': 'Jarz Bakery',
              'customer': 'Ahmad',
              'posting_date': '2026-09-01',
              'amount': 350.0,
              'operational_profile': 'Nasr City',
              'target_warehouse': 'Nasr City - JB',
              'actual_warehouses': ['Maadi - JB', 'Nasr City - JB', 'Maadi - JB'],
            },
          ],
        }),
      );

      final result = await service.fetchWarehouseAlignmentReport(
        branch: 'Nasr City',
        limit: 50,
      );

      expect(result, hasLength(1));
      final row = result.single;
      expect(row.name, 'ACC-SINV-2026-00042');
      expect(row.displayId, '2026-00042');
      expect(row.customer, 'Ahmad');
      expect(row.targetWarehouse, 'Nasr City - JB');
      // Deduped.
      expect(row.actualWarehouses, ['Maadi - JB', 'Nasr City - JB']);

      final req = mockDio.requestLog.single;
      expect(req['path'], ApiEndpoints.warehouseAlignmentReport);
      expect(req['data']['branch'], 'Nasr City');
      expect(req['data']['limit'], 50);
    });

    test('parses a bare list message (no wrapper key)', () async {
      mockDio.setResponse(
        ApiEndpoints.warehouseAlignmentReport,
        createSuccessResponse(data: [
          {
            'name': 'ACC-SINV-2026-00099',
            'amount': 10,
            'target_warehouse': 'Nasr City - JB',
            'actual_warehouses': ['Maadi - JB'],
          },
        ]),
      );

      final result = await service.fetchWarehouseAlignmentReport();

      expect(result, hasLength(1));
      expect(result.single.name, 'ACC-SINV-2026-00099');
    });

    test('falls back to a bare (unwrapped) payload list', () async {
      mockDio.setResponse(
        ApiEndpoints.warehouseAlignmentReport,
        [
          {
            'name': 'ACC-SINV-2026-00100',
            'amount': 5,
            'actual_warehouses': ['Maadi - JB'],
          },
        ],
      );

      final result = await service.fetchWarehouseAlignmentReport();

      expect(result, hasLength(1));
      expect(result.single.name, 'ACC-SINV-2026-00100');
    });

    test('defaults limit to 100 and omits branch when not provided',
        () async {
      mockDio.setResponse(
        ApiEndpoints.warehouseAlignmentReport,
        createSuccessResponse(data: {'success': true, 'rows': []}),
      );

      final result = await service.fetchWarehouseAlignmentReport();

      expect(result, isEmpty);
      final req = mockDio.requestLog.single;
      expect(req['data']['limit'], 100);
      expect((req['data'] as Map).containsKey('branch'), isFalse);
    });

    test('throws cleaned message on failure envelope', () async {
      mockDio.setResponse(
        ApiEndpoints.warehouseAlignmentReport,
        createSuccessResponse(data: {
          'success': false,
          'error': 'Not permitted',
        }),
      );

      expect(
        () => service.fetchWarehouseAlignmentReport(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not permitted'),
          ),
        ),
      );
    });
  });
}
