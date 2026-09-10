import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/replenishment/data/replenishment_service.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late MockDio dio;
  late ReplenishmentService service;

  setUp(() {
    dio = MockDio();
    service = ReplenishmentService(dio);
  });

  test('reads the plan off the Frappe message envelope', () async {
    dio.setResponse(
      ApiEndpoints.getBranchReplenishment,
      createSuccessResponse(
        data: {
          'generated_on': '2026-09-11 08:00:00',
          'company': 'Jarz',
          // Sent as bare ints by the server; the model must not choke on the
          // absence of a decimal point.
          'cover_days': 14,
          'sales_days': 30,
          'notice': null,
          'source': {
            'warehouse': 'Finished Goods - J',
            'available': {'JAR-LOTUS': 30, 'JAR-MANGO': 12.5},
          },
          'branches': [
            {
              'warehouse': 'Nasr - J',
              'branch': 'Nasr City',
              'items': [
                {
                  'item_code': 'JAR-LOTUS',
                  'item_name': 'Lotus Jar',
                  'stock_uom': 'Nos',
                  'on_hand': -3,
                  'stock_is_negative': true,
                  'sells_per_day': 4.5,
                  'days_of_cover': null,
                  'target_days': 14,
                  'suggested_qty': 63,
                  'available_at_source': 30,
                  'send_now': 20,
                  'short_by': 43,
                },
              ],
              'summary': {
                'items_below_cover': 1,
                'total_suggested': 63,
                'total_send_now': 20,
                'negative_bins': 1,
              },
            },
          ],
          'summary': {
            'items_below_cover': 1,
            'total_suggested': 63,
            'total_send_now': 20,
            'negative_bins': 1,
            'branches': 1,
            'total_short_by': 43,
          },
        },
      ),
    );

    final plan = await service.getPlan();

    expect(plan.coverDays, 14);
    expect(plan.source.warehouse, 'Finished Goods - J');
    expect(plan.source.available['JAR-LOTUS'], 30.0);
    expect(plan.notice, isNull);
    final item = plan.branches.single.items.single;
    expect(item.onHand, -3.0);
    expect(item.stockIsNegative, isTrue);
    // Null cover has to survive parsing as null. Defaulting it to zero here is
    // the bug that would make "never sold" read as "sold out".
    expect(item.daysOfCover, isNull);
    expect(item.hasSalesHistory, isFalse);
    expect(item.shortBy, 43.0);
    expect(plan.summary.totalShortBy, 43.0);
  });

  test('keeps the notice when the run produced nothing', () async {
    dio.setResponse(
      ApiEndpoints.getBranchReplenishment,
      createSuccessResponse(
        data: {
          'notice': 'No POS profile has a branch warehouse set.',
          'branches': <dynamic>[],
        },
      ),
    );

    final plan = await service.getPlan();

    expect(plan.hasBranches, isFalse);
    expect(plan.notice, 'No POS profile has a branch warehouse set.');
  });

  test('passes the tuning parameters through as query parameters', () async {
    dio.setResponse(
      ApiEndpoints.getBranchReplenishment,
      createSuccessResponse(data: {'branches': <dynamic>[]}),
    );

    await service.getPlan(coverDays: 7, salesDays: 60);

    final call = dio.requestLog.single;
    expect(call['method'], 'GET');
    expect(call['queryParameters'], {'cover_days': 7, 'sales_days': 60});
  });

  test('surfaces the server message rather than a raw Dio error', () async {
    dio.setError(
      ApiEndpoints.getBranchReplenishment,
      createMockDioException(
        statusCode: 417,
        data: {'exception': 'ValidationError: Company is not set'},
        type: DioExceptionType.badResponse,
      ),
    );

    expect(
      () => service.getPlan(),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Company is not set'),
        ),
      ),
    );
  });
}
