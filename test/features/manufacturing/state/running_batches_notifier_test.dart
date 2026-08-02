import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

import '../../../helpers/mock_services.dart';

Map<String, dynamic> _batch({
  String workOrder = 'MFG-WO-0001',
  double qty = 30,
  double producedQty = 0,
  double wipLeftoverQty = 0,
}) =>
    {
      'name': workOrder,
      'production_item': 'CAKE-A',
      'item_name': 'Cake A',
      'bom_no': 'BOM-CAKE-A-001',
      'stock_uom': 'Nos',
      'qty': qty,
      'produced_qty': producedQty,
      'status': 'In Process',
      'jarz_started_by': 'baker@jarz.test',
      'jarz_started_at': '2026-08-02 07:15:00',
      'elapsed_minutes': 95,
      'wip_leftover_qty': wipLeftoverQty,
    };

ProviderContainer _container(MockDio dio) {
  final container = ProviderContainer(
    overrides: [
      manufacturingServiceProvider.overrideWithValue(ManufacturingService(dio)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockDio dio;

  setUp(() {
    dio = MockDio();
    dio.setResponse(ApiEndpoints.listRunningWorkOrders, {
      'message': [_batch()],
    });
  });

  group('RunningBatchesNotifier', () {
    test('loads running batches on first read', () async {
      final container = _container(dio);

      final batches = await container.read(runningBatchesProvider.future);

      expect(batches, hasLength(1));
      expect(batches.single.workOrder, 'MFG-WO-0001');
      expect(batches.single.itemName, 'Cake A');
      expect(batches.single.outstandingQty, 30);
      expect(batches.single.hasWipLeftover, isFalse);
    });

    test('refresh re-reads the list from the server', () async {
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);

      dio.setResponse(ApiEndpoints.listRunningWorkOrders, {
        'message': [_batch(workOrder: 'MFG-WO-0002')],
      });
      await container.read(runningBatchesProvider.notifier).refresh();

      final batches = container.read(runningBatchesProvider).requireValue;
      expect(batches.single.workOrder, 'MFG-WO-0002');
    });

    test('finish posts the payload keys the backend expects', () async {
      dio.setResponse(ApiEndpoints.finishProductionBatch, {
        'message': {
          'work_order': 'MFG-WO-0001',
          'manufacture_entry': 'MAT-STE-0002',
          'actual_qty': 28.0,
          'scrap_qty': 2.0,
          'status': 'Completed',
          'wip_leftover_qty': 0.0,
        },
      });
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);
      dio.clearLog();

      final result = await container.read(runningBatchesProvider.notifier).finish(
            workOrder: 'MFG-WO-0001',
            actualQty: 28,
            scrapQty: 2,
            notes: 'oven ran cold',
          );

      final finishCall = dio.requestLog
          .firstWhere((r) => r['path'] == ApiEndpoints.finishProductionBatch);
      final payload = finishCall['data'] as Map<String, dynamic>;
      expect(payload['work_order'], 'MFG-WO-0001');
      expect(payload['actual_qty'], 28);
      expect(payload['scrap_qty'], 2);
      expect(payload['notes'], 'oven ran cold');
      expect(result.manufactureEntry, 'MAT-STE-0002');
      expect(result.hasWipLeftover, isFalse);
    });

    test('finish reports leftover WIP rather than swallowing it', () async {
      dio.setResponse(ApiEndpoints.finishProductionBatch, {
        'message': {
          'work_order': 'MFG-WO-0001',
          'manufacture_entry': 'MAT-STE-0003',
          'actual_qty': 20.0,
          'scrap_qty': 0.0,
          'status': 'Completed',
          'wip_leftover_qty': 4.5,
        },
      });
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);

      final result = await container.read(runningBatchesProvider.notifier).finish(
            workOrder: 'MFG-WO-0001',
            actualQty: 20,
          );

      expect(result.hasWipLeftover, isTrue);
      expect(result.wipLeftoverQty, 4.5);
    });

    test('finish refreshes the list so a completed batch drops off', () async {
      dio.setResponse(ApiEndpoints.finishProductionBatch, {
        'message': {'work_order': 'MFG-WO-0001', 'status': 'Completed'},
      });
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);

      dio.setResponse(ApiEndpoints.listRunningWorkOrders, {'message': []});
      await container
          .read(runningBatchesProvider.notifier)
          .finish(workOrder: 'MFG-WO-0001', actualQty: 30);

      expect(container.read(runningBatchesProvider).requireValue, isEmpty);
    });

    test('a failing finish surfaces the error instead of a silent no-op',
        () async {
      dio.setError(
        ApiEndpoints.finishProductionBatch,
        createMockDioException(
          statusCode: 417,
          data: {'exception': 'Not enough material in WIP'},
        ),
      );
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);

      await expectLater(
        container
            .read(runningBatchesProvider.notifier)
            .finish(workOrder: 'MFG-WO-0001', actualQty: 30),
        throwsA(isA<Exception>()),
      );
      // The list is untouched: nothing posted, so nothing may look posted.
      expect(
        container.read(runningBatchesProvider).requireValue.single.workOrder,
        'MFG-WO-0001',
      );
    });

    test('returnWip posts the work order and reloads', () async {
      dio.setResponse(ApiEndpoints.returnWipToStore, {
        'message': {'stock_entry': 'MAT-STE-0009', 'returned_qty': 4.5},
      });
      final container = _container(dio);
      await container.read(runningBatchesProvider.future);
      dio.clearLog();

      dio.setResponse(ApiEndpoints.listRunningWorkOrders, {
        'message': [_batch(wipLeftoverQty: 0)],
      });
      await container
          .read(runningBatchesProvider.notifier)
          .returnWip('MFG-WO-0001');

      final call = dio.requestLog
          .firstWhere((r) => r['path'] == ApiEndpoints.returnWipToStore);
      expect((call['data'] as Map)['work_order'], 'MFG-WO-0001');
      expect(
        container.read(runningBatchesProvider).requireValue.single.hasWipLeftover,
        isFalse,
      );
    });
  });

  group('batchCostProvider', () {
    test('keeps a missing per-unit cost null rather than inventing a zero',
        () async {
      dio.setResponse(ApiEndpoints.getBatchCost, {
        'message': {
          'work_order': 'MFG-WO-0001',
          'material_cost': 812.5,
          'produced_qty': 0.0,
          'cost_per_unit': null,
          'standard_per_unit': null,
          'currency': 'EGP',
        },
      });
      final container = _container(dio);

      final cost = await container.read(batchCostProvider('MFG-WO-0001').future);

      expect(cost.materialCost, 812.5);
      expect(cost.costPerUnit, isNull);
      expect(cost.standardPerUnit, isNull);
      expect(cost.hasStandard, isFalse);
      expect(cost.isComparable, isFalse);
    });

    test('reads a variance over standard', () async {
      dio.setResponse(ApiEndpoints.getBatchCost, {
        'message': {
          'work_order': 'MFG-WO-0001',
          'material_cost': 900.0,
          'produced_qty': 30.0,
          'cost_per_unit': 30.0,
          'standard_per_unit': 25.0,
          'variance_amount': 5.0,
          'variance_pct': 20.0,
          'currency': 'EGP',
        },
      });
      final container = _container(dio);

      final cost = await container.read(batchCostProvider('MFG-WO-0001').future);

      expect(cost.isComparable, isTrue);
      expect(cost.isOverStandard, isTrue);
      expect(cost.variancePct, 20.0);
    });
  });
}
