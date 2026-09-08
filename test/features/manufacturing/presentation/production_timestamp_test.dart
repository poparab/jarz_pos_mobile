import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/production_timestamp.dart';

void main() {
  // The property under test is the one a code review found untested: a
  // Manufacture entry stamped before the Material Transfer that fed it is
  // refused by ERPNext for negative WIP.
  group('finishScheduledAt', () {
    final today = DateTime(2026, 9, 8);

    test('sends nothing for today when no time was chosen', () {
      // Null is what lets the SERVER stamp now_datetime() to the microsecond.
      expect(
        finishScheduledAt(DateTime(2026, 9, 8), today, explicitTime: false),
        isNull,
      );
    });

    test('sends nothing for today even when the value carries a clock', () {
      // A defaulted or Hive-restored clock component must not read as a choice.
      expect(
        finishScheduledAt(
          DateTime(2026, 9, 8, 14, 30),
          today,
          explicitTime: false,
        ),
        isNull,
      );
    });

    test('stamps a past day at 23:59, after any transfer posted that day', () {
      expect(
        finishScheduledAt(DateTime(2026, 9, 7), today, explicitTime: false),
        '2026-09-07 23:59:00',
      );
    });

    test('midnight on a past day is still 23:59, not 00:00', () {
      // Midnight is the value a restored basket carries; honouring it would put
      // the Manufacture entry at the start of the day, before its transfer.
      expect(
        finishScheduledAt(
          DateTime(2026, 9, 7, 0, 0),
          today,
          explicitTime: false,
        ),
        '2026-09-07 23:59:00',
      );
    });

    test('honours a chosen time on a past day', () {
      expect(
        finishScheduledAt(
          DateTime(2026, 9, 7, 9, 5),
          today,
          explicitTime: true,
        ),
        '2026-09-07 09:05:00',
      );
    });

    test('honours a chosen time on today, rather than returning null', () {
      expect(
        finishScheduledAt(
          DateTime(2026, 9, 8, 16, 45),
          today,
          explicitTime: true,
        ),
        '2026-09-08 16:45:00',
      );
    });

    test('honours a deliberately chosen midnight', () {
      expect(
        finishScheduledAt(DateTime(2026, 9, 7), today, explicitTime: true),
        '2026-09-07 00:00:00',
      );
    });

    test('pads every component to two digits', () {
      expect(
        finishScheduledAt(
          DateTime(2026, 1, 2, 3, 4),
          DateTime(2026, 1, 3),
          explicitTime: true,
        ),
        '2026-01-02 03:04:00',
      );
    });
  });

  group('startScheduledAt', () {
    test('uses the clock of now when no time was chosen', () {
      expect(
        startScheduledAt(
          DateTime(2026, 9, 7),
          explicitTime: false,
          now: DateTime(2026, 9, 8, 10, 15),
        ),
        // The DAY comes from the chosen date, the CLOCK from now: a back-dated
        // batch lands mid-morning rather than at midnight.
        '2026-09-07 10:15:00',
      );
    });

    test('uses the chosen clock when a time was chosen', () {
      expect(
        startScheduledAt(
          DateTime(2026, 9, 7, 6, 30),
          explicitTime: true,
          now: DateTime(2026, 9, 8, 10, 15),
        ),
        '2026-09-07 06:30:00',
      );
    });

    test('never returns null, unlike the finish side', () {
      expect(
        startScheduledAt(
          DateTime(2026, 9, 8),
          explicitTime: false,
          now: DateTime(2026, 9, 8, 23, 59),
        ),
        isNotNull,
      );
    });
  });
}
