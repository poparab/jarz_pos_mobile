import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_policy.dart';

/// The app used to hardcode its own backdating window while the server read a
/// different one from Jarz POS Settings. On production those two were 3 and 0,
/// so the picker offered yesterday and every submit of it was refused — and the
/// floor learned that the date on the screen means nothing.
///
/// These tests pin the parts of that disagreement that can recur: a zero that
/// must not be read as "unset", a server date that must beat the device's, and
/// a System Manager who must not be clamped to a ceiling they are not bound by.
void main() {
  ProductionPolicy policy({
    int maxDays = 30,
    bool canBackDate = true,
    bool unlimited = false,
    String? serverDate = '2026-09-07',
  }) {
    return ProductionPolicy.fromJson({
      'max_backdate_days': maxDays,
      'can_backdate': canBackDate,
      'can_execute': true,
      'unlimited_backdate': unlimited,
      if (serverDate != null) 'server_date': serverDate,
    });
  }

  group('parsing', () {
    test('reads the window the server reported', () {
      expect(policy(maxDays: 30).maxBackDateDays, 30);
    });

    test('a zero window is a real answer, not a missing one', () {
      // "Today only". Substituting a default here is the exact bug: the client
      // would offer dates `_assert_posting_date_allowed` refuses.
      final p = policy(maxDays: 0);
      expect(p.maxBackDateDays, 0);
      expect(p.earliestPostable(), p.today());
    });

    test('an absent payload denies everything rather than guessing', () {
      const p = ProductionPolicy();
      expect(p.canBackDate, isFalse);
      expect(p.canExecute, isFalse);
      expect(p.maxBackDateDays, 0);
    });

    test('an unparseable server date falls back to the device clock', () {
      final p = ProductionPolicy.fromJson({'server_date': 'not a date'});
      final now = DateTime.now();
      expect(p.today(), DateTime(now.year, now.month, now.day));
    });
  });

  group('earliestPostable', () {
    test('counts back from the SERVER date, not the device one', () {
      // A tablet a day fast would otherwise build a picker whose last
      // selectable day the server calls the future.
      expect(policy(maxDays: 7).today(), DateTime(2026, 9, 7));
      expect(policy(maxDays: 7).earliestPostable(), DateTime(2026, 8, 31));
    });

    test('a role that may not backdate is locked to today', () {
      final p = policy(maxDays: 30, canBackDate: false);
      expect(p.earliestPostable(), p.today());
    });

    test('a System Manager is not clamped to the day ceiling', () {
      // The server binds them only by "not the future"; clamping their picker
      // to `max_backdate_days` would refuse a date it would have accepted.
      final p = policy(maxDays: 3, unlimited: true);
      expect(
        p.earliestPostable().isBefore(DateTime(2026, 1, 1)),
        isTrue,
        reason: 'unlimited backdating must not stop three days back',
      );
    });
  });

  group('isBackDated', () {
    test('yesterday is, today is not, and the time of day is ignored', () {
      final p = policy();
      expect(p.isBackDated(DateTime(2026, 9, 6)), isTrue);
      expect(p.isBackDated(DateTime(2026, 9, 7)), isFalse);
      expect(p.isBackDated(DateTime(2026, 9, 7, 23, 59)), isFalse);
    });
  });
}
