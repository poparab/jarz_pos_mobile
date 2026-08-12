import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/journey/presentation/journey_format.dart';

void main() {
  // Every relative assertion pins "now" explicitly. A test that asked the clock
  // would flip at midnight and around month boundaries.
  final now = DateTime(2026, 8, 12);

  group('JourneyFormat.iso', () {
    test('pads month and day to the backend wire format', () {
      expect(JourneyFormat.iso(DateTime(2026, 1, 5)), '2026-01-05');
      expect(JourneyFormat.iso(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('JourneyFormat.parse', () {
    test('accepts a bare date and a full datetime', () {
      expect(JourneyFormat.parse('2026-08-10'), DateTime(2026, 8, 10));
      expect(
        JourneyFormat.parse('2026-08-10 18:04:11')?.day,
        10,
      );
    });

    test('returns null for missing or unparseable values', () {
      expect(JourneyFormat.parse(null), isNull);
      expect(JourneyFormat.parse(''), isNull);
      expect(JourneyFormat.parse('   '), isNull);
      expect(JourneyFormat.parse('not a date'), isNull);
    });
  });

  group('JourneyFormat.pretty', () {
    test('formats a date for a human', () {
      expect(JourneyFormat.pretty('2026-08-10'), '10 Aug 2026');
      expect(JourneyFormat.pretty('2026-01-01'), '1 Jan 2026');
    });

    test('falls back to the raw string rather than showing a blank', () {
      expect(JourneyFormat.pretty('sometime'), 'sometime');
      expect(JourneyFormat.pretty(null), '');
    });
  });

  group('JourneyFormat.relativePast', () {
    test('labels the recent past', () {
      expect(JourneyFormat.relativePast('2026-08-12', now: now), 'Today');
      expect(JourneyFormat.relativePast('2026-08-11', now: now), 'Yesterday');
      expect(JourneyFormat.relativePast('2026-08-09', now: now), '3 days ago');
    });

    test('collapses to weeks then months', () {
      expect(JourneyFormat.relativePast('2026-08-05', now: now), '1 week ago');
      expect(JourneyFormat.relativePast('2026-07-25', now: now), '2 weeks ago');
      expect(JourneyFormat.relativePast('2026-06-01', now: now), '2 months ago');
    });

    test('a future date reads as a future date, not "-3 days ago"', () {
      expect(JourneyFormat.relativePast('2026-08-16', now: now), 'In 4 days');
    });

    test('an unusable date produces no label at all', () {
      expect(JourneyFormat.relativePast(null, now: now), '');
      expect(JourneyFormat.relativePast('nonsense', now: now), '');
    });
  });

  group('JourneyFormat.relativeFuture', () {
    test('labels what is coming up', () {
      expect(JourneyFormat.relativeFuture('2026-08-12', now: now), 'Today');
      expect(JourneyFormat.relativeFuture('2026-08-13', now: now), 'Tomorrow');
      expect(JourneyFormat.relativeFuture('2026-08-16', now: now), 'In 4 days');
    });

    test('labels what is late', () {
      expect(
        JourneyFormat.relativeFuture('2026-08-09', now: now),
        'Overdue by 3 days',
      );
      expect(JourneyFormat.relativeFuture('2026-05-01', now: now), 'Overdue');
    });
  });

  group('JourneyFormat.isDue', () {
    test('today and the past are due; the future is not', () {
      expect(JourneyFormat.isDue('2026-08-12', now: now), isTrue);
      expect(JourneyFormat.isDue('2026-08-01', now: now), isTrue);
      expect(JourneyFormat.isDue('2026-08-13', now: now), isFalse);
    });

    test('an unusable date is never due', () {
      expect(JourneyFormat.isDue(null, now: now), isFalse);
      expect(JourneyFormat.isDue('', now: now), isFalse);
      expect(JourneyFormat.isDue('whenever', now: now), isFalse);
    });
  });

  group('JourneyFormat.typeIcon', () {
    test('each entry type gets its own icon', () {
      expect(JourneyFormat.typeIcon('Call'), Icons.call);
      expect(JourneyFormat.typeIcon('Visit'), Icons.directions_walk);
      expect(JourneyFormat.typeIcon('Sample Drop'), Icons.science_outlined);
      expect(JourneyFormat.typeIcon('WhatsApp'), Icons.chat_bubble_outline);
    });

    test('matching is case-insensitive and unknown types fall back to Visit', () {
      expect(JourneyFormat.typeIcon('call'), Icons.call);
      // A Select option added in Desk must not crash the card.
      expect(JourneyFormat.typeIcon('Carrier Pigeon'), Icons.directions_walk);
      expect(JourneyFormat.typeIcon(''), Icons.directions_walk);
    });
  });

  group('JourneyFormat.outcomeColors', () {
    test('positive, warning and rejected outcomes are visually distinct', () {
      final good = JourneyFormat.outcomeColors('Interested');
      final warn = JourneyFormat.outcomeColors('Needs Follow-up');
      final bad = JourneyFormat.outcomeColors('Rejected');
      expect(good.bg, isNot(warn.bg));
      expect(warn.bg, isNot(bad.bg));
      expect(good.bg, isNot(bad.bg));
    });

    test('an unrecognised outcome renders neutral rather than throwing', () {
      final unknown = JourneyFormat.outcomeColors('Sent a carrier pigeon');
      final notNow = JourneyFormat.outcomeColors('Not Now');
      expect(unknown.bg, notNow.bg);
    });
  });
}
