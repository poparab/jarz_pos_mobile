import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/reports/data/customer_segments_repository.dart';

import '../../helpers/mock_services.dart';

void main() {
  group('CustomerSegmentsRepository', () {
    late MockDio mockDio;
    late CustomerSegmentsRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = CustomerSegmentsRepository(mockDio);
    });

    group('fetchSegmentSummary', () {
      test('parses a list message envelope (not a map)', () async {
        mockDio.setResponse(ApiEndpoints.segmentSummary, {
          'message': [
            {'segment': 'Champion', 'count': 12},
            {'segment': 'Loyal', 'count': 30},
            {'segment': 'Unclassified', 'count': 4},
          ],
        });

        final rows = await repo.fetchSegmentSummary();

        expect(rows, hasLength(3));
        expect(rows.first.segment, 'Champion');
        expect(rows.first.count, 12);
        expect(rows.last.segment, 'Unclassified');
      });

      test('falls back to a bare (unwrapped) list payload', () async {
        mockDio.setResponse(ApiEndpoints.segmentSummary, [
          {'segment': 'Lost', 'count': 5},
        ]);

        final rows = await repo.fetchSegmentSummary();

        expect(rows, hasLength(1));
        expect(rows.single.segment, 'Lost');
        expect(rows.single.count, 5);
      });

      test('unexpected payload shape yields an empty list', () async {
        mockDio.setResponse(ApiEndpoints.segmentSummary, {
          'message': {'not': 'a list'},
        });

        final rows = await repo.fetchSegmentSummary();

        expect(rows, isEmpty);
      });
    });

    group('exportSegment', () {
      test('sends segment and parses the customer rows', () async {
        mockDio.setResponse(ApiEndpoints.segmentExport, {
          'message': [
            {
              'customer_id': 'CUST-1',
              'customer_name': 'Alice',
              'mobile_no': '0100',
              'territory': 'Cairo',
              'customer_segment': 'Champion',
              'rfm_recency_days': 3,
              'rfm_frequency_count': 8,
              'rfm_avg_order_value': 250.5,
              'segment_updated_on': '2026-09-01',
            },
          ],
        });

        final rows = await repo.exportSegment('Champion');

        expect(rows, hasLength(1));
        expect(rows.single['customer_name'], 'Alice');
        expect(
          mockDio.requestLog.single['data']['segment'],
          'Champion',
        );
      });

      test('empty segment returns an empty list', () async {
        mockDio.setResponse(ApiEndpoints.segmentExport, {'message': []});

        final rows = await repo.exportSegment('Unclassified');

        expect(rows, isEmpty);
      });
    });

    group('runSegmentationNow', () {
      test('returns the raw recalculation summary', () async {
        mockDio.setResponse(ApiEndpoints.segmentRunNow, {
          'message': {
            'updated': 40,
            'skipped_override': 2,
            'total_customers': 42,
          },
        });

        final result = await repo.runSegmentationNow();

        expect(result['updated'], 40);
        expect(result['skipped_override'], 2);
        expect(result['total_customers'], 42);
      });
    });

    group('setSegmentOverride', () {
      test('pin sends override=1 and manual_segment', () async {
        mockDio.setResponse(ApiEndpoints.segmentSetOverride, {
          'message': {'status': 'ok', 'customer': 'CUST-1'},
        });

        await repo.setSegmentOverride(
          customer: 'CUST-1',
          override: true,
          manualSegment: 'Champion',
        );

        final sent = mockDio.requestLog.single['data'] as Map;
        expect(sent['customer'], 'CUST-1');
        expect(sent['override'], 1);
        expect(sent['manual_segment'], 'Champion');
      });

      test('unpin sends override=0 and omits manual_segment', () async {
        mockDio.setResponse(ApiEndpoints.segmentSetOverride, {
          'message': {'status': 'ok', 'customer': 'CUST-1'},
        });

        await repo.setSegmentOverride(customer: 'CUST-1', override: false);

        final sent = mockDio.requestLog.single['data'] as Map;
        expect(sent['override'], 0);
        expect(sent.containsKey('manual_segment'), isFalse);
      });
    });
  });
}
