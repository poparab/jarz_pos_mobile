import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/followups/data/followups_repository.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';

import '../../helpers/mock_services.dart';

void main() {
  group('FollowupsRepository', () {
    late MockDio mockDio;
    late FollowupsRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = FollowupsRepository(mockDio);
    });

    test('fetchToday unwraps the message envelope', () async {
      mockDio.setResponse(ApiEndpoints.followupsToday, {
        'message': {
          'summary': {'due': 1, 'overdue': 0, 'calls': 0, 'messages': 1},
          'rows': [
            {'name': 'CF-1', 'customer': 'C1', 'channel': 'Message'},
          ],
        },
      });

      final today = await repo.fetchToday();

      expect(today.summary.due, 1);
      expect(today.rows.single.name, 'CF-1');
    });

    test('logTouch sends wire values and parses the extras', () async {
      mockDio.setResponse(ApiEndpoints.followupLogTouch, {
        'message': {
          'name': 'CF-1',
          'apology_code': 'SORRY-1',
          'escalation_task': 'TASK-9',
        },
      });

      final result = await repo.logTouch(
        name: 'CF-1',
        outcome: FollowupOutcome.quality,
        reached: FollowupReach.notReached,
        notes: '  cake was dry  ',
      );

      expect(result.apologyCode, 'SORRY-1');
      expect(result.escalationTask, 'TASK-9');
      final sent = mockDio.requestLog.last['data'] as Map;
      expect(sent['name'], 'CF-1');
      expect(sent['outcome'], 'Quality');
      expect(sent['reached'], 'Not Reached');
      expect(sent['notes'], 'cake was dry');
    });

    test('logTouch omits reached and blank notes for a message', () async {
      mockDio.setResponse(ApiEndpoints.followupLogTouch, {'message': {}});

      await repo.logTouch(
        name: 'CF-2',
        outcome: FollowupOutcome.happy,
        notes: '   ',
      );

      final sent = mockDio.requestLog.last['data'] as Map;
      expect(sent.containsKey('reached'), isFalse);
      expect(sent.containsKey('notes'), isFalse);
    });

    test('skipTouch sends the reason', () async {
      mockDio.setResponse(ApiEndpoints.followupSkipTouch, {'message': null});

      await repo.skipTouch(name: 'CF-3', reason: 'traveling');

      final sent = mockDio.requestLog.last['data'] as Map;
      expect(sent, {'name': 'CF-3', 'reason': 'traveling'});
    });

    test('fetchStats sends the date range', () async {
      mockDio.setResponse(ApiEndpoints.followupStats, {
        'message': {'calls_total': 3, 'calls_reached': 2},
      });

      final stats =
          await repo.fetchStats(fromDate: '2026-10-06', toDate: '2026-10-12');

      expect(stats.callsTotal, 3);
      final sent = mockDio.requestLog.last['data'] as Map;
      expect(sent, {'from_date': '2026-10-06', 'to_date': '2026-10-12'});
    });

    test('fetchSentReport sends the date range', () async {
      mockDio.setResponse(ApiEndpoints.followupSentReport, {
        'message': {
          'totals': {'sent': 5, 'read': 2},
        },
      });

      final report = await repo.fetchSentReport(
          fromDate: '2026-10-21', toDate: '2026-10-27');

      expect(report.total('sent'), 5);
      final sent = mockDio.requestLog.last['data'] as Map;
      expect(sent, {'from_date': '2026-10-21', 'to_date': '2026-10-27'});
    });
  });
}
