import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/roster/data/roster_repository.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

import '../../helpers/mock_services.dart';

/// The win `bulk_assign` exists for: a run of N single-day changes goes out as
/// ONE request, and a partial failure is surfaced rather than swallowed into a
/// blanket "done".
void main() {
  group('RosterRepository.bulkAssign', () {
    const path = '/api/method/jarz_pos.api.roster.bulk_assign';

    late MockDio mockDio;
    late RosterRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = RosterRepository(mockDio);
    });

    test('a run of N day changes produces exactly ONE request', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'applied': [
            {'index': 0, 'employee': 'HR-EMP-0001', 'date': '2026-09-10'},
            {'index': 1, 'employee': 'HR-EMP-0001', 'date': '2026-09-11'},
            {'index': 2, 'employee': 'HR-EMP-0001', 'date': '2026-09-12'},
          ],
          'failed': [],
          'applied_count': 3,
          'failed_count': 0,
        },
      });

      final changes = [
        {
          'employee': 'HR-EMP-0001',
          'date': '2026-09-10',
          'action': 'assign',
          'shift_type': 'Branch Opening',
        },
        {
          'employee': 'HR-EMP-0001',
          'date': '2026-09-11',
          'action': 'assign',
          'shift_type': 'Branch Opening',
        },
        {
          'employee': 'HR-EMP-0001',
          'date': '2026-09-12',
          'action': 'assign',
          'shift_type': 'Branch Opening',
        },
      ];

      final result = await repository.bulkAssign(changes);

      // Exactly one HTTP call for the whole run — the entire point of the
      // endpoint versus calling assignShift three times.
      expect(mockDio.requestLog, hasLength(1));
      expect(result.appliedCount, 3);
      expect(result.isFullSuccess, isTrue);
    });

    test('the list argument is sent JSON-encoded, matching bulk_assign\'s '
        'own json.loads(payload) fallback for a string body', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'applied': [],
          'failed': [],
          'applied_count': 0,
          'failed_count': 0,
        },
      });

      final changes = [
        {'employee': 'HR-EMP-0001', 'date': '2026-09-10', 'action': 'day_off'},
      ];
      await repository.bulkAssign(changes);

      final sent = mockDio.requestLog.first['data'] as Map;
      expect(sent['payload'], isA<String>());
      final decoded = jsonDecode(sent['payload'] as String) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect(decoded.first['employee'], 'HR-EMP-0001');
      expect(decoded.first['action'], 'day_off');
    });

    test('a partial failure is surfaced, not collapsed into success', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'applied': [
            {'index': 0, 'employee': 'HR-EMP-0001', 'date': '2026-09-10'},
          ],
          'failed': [
            {
              'index': 1,
              'employee': 'HR-EMP-0001',
              'date': '2026-09-11',
              'error': '2026-09-11 is not at one of your branches.',
            },
          ],
          'applied_count': 1,
          'failed_count': 1,
        },
      });

      final result = await repository.bulkAssign([
        {
          'employee': 'HR-EMP-0001',
          'date': '2026-09-10',
          'action': 'assign',
          'shift_type': 'Branch Opening',
        },
        {
          'employee': 'HR-EMP-0001',
          'date': '2026-09-11',
          'action': 'assign',
          'shift_type': 'Branch Opening',
        },
      ]);

      expect(result.isFullSuccess, isFalse);
      expect(result.isFullFailure, isFalse);
      expect(result.appliedCount, 1);
      expect(result.failedCount, 1);
      expect(result.failures, hasLength(1));
      expect(result.failures.single.date, '2026-09-11');
      expect(
        result.failures.single.error,
        contains('not at one of your branches'),
      );
    });

    test('a total failure is distinguishable from a total success', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'applied': [],
          'failed': [
            {
              'index': 0,
              'employee': 'HR-EMP-0002',
              'date': '2026-09-10',
              'error': 'Shift type is required.',
            },
          ],
          'applied_count': 0,
          'failed_count': 1,
        },
      });

      final result = await repository.bulkAssign([
        {'employee': 'HR-EMP-0002', 'date': '2026-09-10', 'action': 'assign'},
      ]);

      expect(result.isFullFailure, isTrue);
      expect(result.isFullSuccess, isFalse);
    });

    test('falls back to a bare payload with no message envelope', () async {
      mockDio.setResponse(path, {
        'success': true,
        'applied': [],
        'failed': [],
        'applied_count': 0,
        'failed_count': 0,
      });

      final result = await repository.bulkAssign(const []);

      expect(result.appliedCount, 0);
      expect(result.failedCount, 0);
    });
  });

  group('RosterSelection', () {
    test('toggle adds a date not yet selected', () {
      const selection = RosterSelection(
        employee: 'HR-EMP-0001',
        employeeName: 'Ahmed Samir',
        dates: {'2026-09-10'},
      );

      final next = selection.toggle('2026-09-11');

      expect(next.dates, {'2026-09-10', '2026-09-11'});
      expect(next.count, 2);
    });

    test('toggle removes a date already selected', () {
      const selection = RosterSelection(
        employee: 'HR-EMP-0001',
        employeeName: 'Ahmed Samir',
        dates: {'2026-09-10', '2026-09-11'},
      );

      final next = selection.toggle('2026-09-10');

      expect(next.dates, {'2026-09-11'});
    });
  });
}
