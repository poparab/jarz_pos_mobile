import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_action.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_note.dart';

void main() {
  group('JourneyNote done keys', () {
    final doneJson = <String, dynamic>{
      'name': 'JRN-2026-00042',
      'next_action': 'Call to confirm the trial order',
      'next_action_date': '2026-08-14',
      // Real JSON booleans: the backend casts its 0/1 Check fields before
      // serialising, so the model must NOT coerce ints.
      'next_action_done': true,
      'next_action_done_on': '2026-08-15',
      'next_action_done_by': 'rep@jarz.com',
      'next_action_done_by_name': 'Sales Rep',
      'can_complete': true,
    };

    test('maps every done key', () {
      final note = JourneyNote.fromJson(doneJson);
      expect(note.nextActionDone, isTrue);
      expect(note.nextActionDoneOn, '2026-08-15');
      expect(note.nextActionDoneBy, 'rep@jarz.com');
      expect(note.nextActionDoneByName, 'Sales Rep');
      expect(note.canComplete, isTrue);
      // The promise still exists once kept — done is a state, not a delete.
      expect(note.hasNextAction, isTrue);
    });

    test('an open action decodes as not done and not completable', () {
      final note = JourneyNote.fromJson({
        'name': 'JRN-1',
        'next_action': 'Send the price list',
        'next_action_date': '2026-08-20',
        'next_action_done': false,
        'next_action_done_by': '',
        'next_action_done_by_name': '',
        'can_complete': false,
      });
      expect(note.nextActionDone, isFalse);
      expect(note.nextActionDoneOn, isNull);
      expect(note.nextActionDoneBy, '');
      expect(note.canComplete, isFalse);
    });

    test('a payload from a site without the done fields is safe', () {
      final note = JourneyNote.fromJson({'name': 'JRN-2'});
      expect(note.nextActionDone, isFalse);
      expect(note.nextActionDoneOn, isNull);
      expect(note.nextActionDoneByName, '');
      expect(note.canComplete, isFalse);
    });
  });

  group('JourneyAction', () {
    final journeyRow = <String, dynamic>{
      'source': 'journey',
      'note': 'JRN-2026-00042',
      'reference_doctype': 'Lead',
      'reference_name': 'LEAD-0001',
      'title': 'Zooba',
      'date': '2026-08-14',
      'action': 'Call to confirm the trial order',
      'contact_person': 'Mostafa',
      'entry_type': 'Sample Drop',
      'done': false,
      'overdue': true,
      'owner': 'rep@jarz.com',
      'owner_name': 'Sales Rep',
      'can_complete': true,
    };

    test('maps every key of a journey-backed row', () {
      final action = JourneyAction.fromJson(journeyRow);
      expect(action.source, 'journey');
      expect(action.note, 'JRN-2026-00042');
      expect(action.referenceDoctype, 'Lead');
      expect(action.referenceName, 'LEAD-0001');
      expect(action.title, 'Zooba');
      expect(action.date, '2026-08-14');
      expect(action.action, 'Call to confirm the trial order');
      expect(action.contactPerson, 'Mostafa');
      expect(action.entryType, 'Sample Drop');
      expect(action.done, isFalse);
      expect(action.overdue, isTrue);
      expect(action.ownerName, 'Sales Rep');
      expect(action.canComplete, isTrue);
      expect(action.isJourney, isTrue);
      expect(action.key, 'JRN-2026-00042');
    });

    test('a bare follow-up carries no note and is not journey-backed', () {
      final action = JourneyAction.fromJson({
        'source': 'followup',
        'note': '',
        'reference_doctype': 'Customer',
        'reference_name': 'CUST-0009',
        'title': 'Cilantro',
        'date': '2026-08-16',
        'action': 'Follow up',
        'done': false,
        'overdue': false,
        'can_complete': true,
      });
      expect(action.isJourney, isFalse);
      // Its key falls back to the account so two follow-ups never collide.
      expect(action.key, 'followup:Customer:CUST-0009:2026-08-16');
    });

    test('an empty row decodes to safe defaults', () {
      final action = JourneyAction.fromJson(const {});
      expect(action.source, '');
      expect(action.title, '');
      expect(action.date, '');
      expect(action.done, isFalse);
      expect(action.overdue, isFalse);
      expect(action.canComplete, isFalse);
      expect(action.isJourney, isFalse);
    });
  });

  group('JourneyActionCalendar', () {
    test('decodes the window, the rows and the counts', () {
      final calendar = JourneyActionCalendar.fromJson({
        'from_date': '2026-08-01',
        'to_date': '2026-08-31',
        'scope': 'all',
        'actions': [
          {
            'source': 'journey',
            'note': 'JRN-1',
            'reference_doctype': 'Lead',
            'reference_name': 'LEAD-0001',
            'title': 'Zooba',
            'date': '2026-08-14',
            'overdue': true,
          },
          {
            'source': 'followup',
            'reference_doctype': 'Customer',
            'reference_name': 'CUST-0009',
            'title': 'Cilantro',
            'date': '2026-08-14',
            'done': true,
          },
          {
            'source': 'journey',
            'note': 'JRN-2',
            'reference_doctype': 'Opportunity',
            'reference_name': 'OPP-0002',
            'title': 'Espresso Lab',
            'date': '2026-08-20',
          },
        ],
        'counts': {'pending': 2, 'overdue': 1, 'done': 1},
      });

      expect(calendar.fromDate, '2026-08-01');
      expect(calendar.toDate, '2026-08-31');
      expect(calendar.scope, 'all');
      expect(calendar.actions, hasLength(3));
      expect(calendar.counts.pending, 2);
      expect(calendar.counts.overdue, 1);
      expect(calendar.counts.done, 1);
      // overdue is a SUBSET of pending server-side, so the header's three
      // chips must read off the disjoint remainder or they double-count.
      expect(calendar.counts.upcoming, 1);
      expect(calendar.isEmpty, isFalse);
    });

    test('byDay buckets the rows the grid draws', () {
      final calendar = JourneyActionCalendar.fromJson({
        'actions': [
          {'note': 'JRN-1', 'date': '2026-08-14'},
          {'note': 'JRN-2', 'date': '2026-08-14'},
          {'note': 'JRN-3', 'date': '2026-08-20'},
          // A row with no date cannot be placed on a cell and is dropped.
          {'note': 'JRN-4', 'date': ''},
        ],
      });
      final byDay = calendar.byDay;
      expect(byDay.keys, containsAll(<String>['2026-08-14', '2026-08-20']));
      expect(byDay['2026-08-14'], hasLength(2));
      expect(byDay['2026-08-20'], hasLength(1));
      expect(byDay.containsKey(''), isFalse);
    });

    test('a missing payload decodes to an empty month, never null', () {
      final calendar = JourneyActionCalendar.fromJson(const {});
      expect(calendar.actions, isEmpty);
      expect(calendar.isEmpty, isTrue);
      expect(calendar.fromDate, '');
      // Defaults to the rep's own actions rather than the whole company.
      expect(calendar.scope, 'mine');
      expect(calendar.counts.pending, 0);
      expect(calendar.counts.overdue, 0);
      expect(calendar.counts.done, 0);
      expect(calendar.byDay, isEmpty);
    });
  });

  group('JourneyActionCounts.upcoming', () {
    test('is pending minus the overdue subset', () {
      const counts = JourneyActionCounts(pending: 5, overdue: 2, done: 3);
      expect(counts.upcoming, 3);
    });

    test('is zero when every pending action is overdue', () {
      const counts = JourneyActionCounts(pending: 4, overdue: 4);
      expect(counts.upcoming, 0);
    });

    test('never goes negative on an inconsistent payload', () {
      const counts = JourneyActionCounts(pending: 1, overdue: 3);
      expect(counts.upcoming, 0);
    });
  });
}
