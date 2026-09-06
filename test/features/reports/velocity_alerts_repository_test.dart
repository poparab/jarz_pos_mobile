import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/reports/data/velocity_alerts_repository.dart';

import '../../helpers/mock_services.dart';

void main() {
  group('VelocityAlertsRepository', () {
    late MockDio mockDio;
    late VelocityAlertsRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = VelocityAlertsRepository(mockDio);
    });

    group('fetchAlertSummary', () {
      test('parses all four buckets from the message envelope', () async {
        mockDio.setResponse(ApiEndpoints.forecastAlertSummary, {
          'message': {
            'critical': [
              {
                'item_code': 'ITEM-1',
                'item_name': 'Item One',
                'item_group': 'Snacks',
                'replenishment_type': 'Purchase',
                'daily_velocity': 2.5,
                'stock_on_hand': 3,
                'days_remaining': 1,
              },
            ],
            'watch_list': [
              {'item_code': 'ITEM-2', 'days_remaining': 10},
            ],
            'slow_movers': [
              {'item_code': 'ITEM-3', 'trend': 'No Sales'},
            ],
            'overstocked': [
              {'item_code': 'ITEM-4', 'stock_value': 5000},
            ],
          },
        });

        final summary = await repo.fetchAlertSummary();

        expect(summary.critical, hasLength(1));
        expect(summary.critical.single['item_name'], 'Item One');
        expect(summary.watchList, hasLength(1));
        expect(summary.slowMovers, hasLength(1));
        expect(summary.overstocked, hasLength(1));
        expect(summary.totalCount, 4);
      });

      test('falls back to a bare (unwrapped) map payload', () async {
        mockDio.setResponse(ApiEndpoints.forecastAlertSummary, {
          'critical': [
            {'item_code': 'ITEM-5'},
          ],
          'watch_list': <Map<String, dynamic>>[],
          'slow_movers': <Map<String, dynamic>>[],
          'overstocked': <Map<String, dynamic>>[],
        });

        final summary = await repo.fetchAlertSummary();

        expect(summary.critical, hasLength(1));
        expect(summary.totalCount, 1);
      });

      test('missing/unexpected buckets default to empty lists', () async {
        mockDio.setResponse(ApiEndpoints.forecastAlertSummary, {
          'message': <String, dynamic>{},
        });

        final summary = await repo.fetchAlertSummary();

        expect(summary.critical, isEmpty);
        expect(summary.watchList, isEmpty);
        expect(summary.slowMovers, isEmpty);
        expect(summary.overstocked, isEmpty);
      });
    });

    group('fetchItemVelocity', () {
      test('parses velocity detail and sends item_code', () async {
        mockDio.setResponse(ApiEndpoints.forecastItemVelocity, {
          'message': {
            'velocity_30d': 1.5,
            'velocity_60d': 1.2,
            'trend': 'Accelerating',
            'stock_on_hand': 42,
          },
        });

        final detail = await repo.fetchItemVelocity('ITEM-1');

        expect(detail.velocity30d, 1.5);
        expect(detail.velocity60d, 1.2);
        expect(detail.trend, 'Accelerating');
        expect(detail.stockOnHand, 42);
        expect(
          mockDio.requestLog.single['data']['item_code'],
          'ITEM-1',
        );
      });

      test('numeric-string values still parse', () async {
        mockDio.setResponse(ApiEndpoints.forecastItemVelocity, {
          'message': {
            'velocity_30d': '2.0',
            'velocity_60d': '1.0',
            'trend': 'Stable',
            'stock_on_hand': '10',
          },
        });

        final detail = await repo.fetchItemVelocity('ITEM-1');

        expect(detail.velocity30d, 2.0);
        expect(detail.stockOnHand, 10.0);
      });
    });

    group('runVelocityUpdateNow', () {
      test('returns the updated item count', () async {
        mockDio.setResponse(ApiEndpoints.forecastRunVelocityNow, {
          'message': {'updated': 137},
        });

        final count = await repo.runVelocityUpdateNow();

        expect(count, 137);
      });

      test('defaults to 0 on an unexpected payload', () async {
        mockDio.setResponse(ApiEndpoints.forecastRunVelocityNow, 'oops');

        final count = await repo.runVelocityUpdateNow();

        expect(count, 0);
      });
    });
  });
}
