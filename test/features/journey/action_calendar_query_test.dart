import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/journey/state/action_calendar_notifier.dart';

void main() {
  group('ActionCalendarQuery window', () {
    test('spans the whole visible month', () {
      final query = ActionCalendarQuery(month: DateTime(2026, 8, 17));
      expect(query.fromDate, '2026-08-01');
      expect(query.toDate, '2026-08-31');
    });

    test('handles a 30-day month and a leap February', () {
      expect(
        ActionCalendarQuery(month: DateTime(2026, 4, 3)).toDate,
        '2026-04-30',
      );
      expect(
        ActionCalendarQuery(month: DateTime(2028, 2, 1)).toDate,
        '2028-02-29',
      );
    });

    test('paging crosses the year boundary in both directions', () {
      final december = ActionCalendarQuery(month: DateTime(2026, 12, 5));
      expect(december.shiftedBy(1).fromDate, '2027-01-01');
      expect(december.shiftedBy(1).toDate, '2027-01-31');

      final january = ActionCalendarQuery(month: DateTime(2027, 1, 20));
      expect(january.shiftedBy(-1).fromDate, '2026-12-01');
    });

    test('paging keeps the filters, which are what the server is asked for',
        () {
      final query = ActionCalendarQuery(
        month: DateTime(2026, 8, 1),
        scope: 'all',
        includeDone: true,
      );
      final next = query.shiftedBy(1);
      expect(next.scope, 'all');
      expect(next.includeDone, isTrue);
    });

    test('equality ignores the day, so the same month is the same query', () {
      // The provider is keyed on this: two rebuilds inside one month must not
      // look like two different windows and refetch.
      expect(
        ActionCalendarQuery(month: DateTime(2026, 8, 1)),
        ActionCalendarQuery(month: DateTime(2026, 8, 29)),
      );
      expect(
        ActionCalendarQuery(month: DateTime(2026, 8, 1)).hashCode,
        ActionCalendarQuery(month: DateTime(2026, 8, 29)).hashCode,
      );
      expect(
        ActionCalendarQuery(month: DateTime(2026, 8, 1)) ==
            ActionCalendarQuery(month: DateTime(2026, 9, 1)),
        isFalse,
      );
      expect(
        ActionCalendarQuery(month: DateTime(2026, 8, 1)) ==
            ActionCalendarQuery(month: DateTime(2026, 8, 1), scope: 'all'),
        isFalse,
      );
    });
  });
}
