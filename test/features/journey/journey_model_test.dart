import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_note.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';

void main() {
  group('JourneyNote.fromJson', () {
    final fullJson = <String, dynamic>{
      'name': 'JRN-2026-00042',
      'reference_doctype': 'Lead',
      'reference_name': 'LEAD-0001',
      'entry_date': '2026-08-10',
      'entry_type': 'Sample Drop',
      'note': 'Left 3 jars. Barista asked about wholesale pricing.',
      'contact_person': 'Mostafa',
      'contact_role': 'Branch Manager',
      'contact_phone': '01000000009',
      'next_action': 'Call to confirm the trial order',
      'next_action_date': '2026-08-14',
      'outcome': 'Interested',
      'logged_by': 'rep@jarz.com',
      'logged_by_name': 'Sales Rep',
      'creation': '2026-08-10 18:04:11',
      'modified': '2026-08-10 18:04:11',
      'can_edit': true,
    };

    test('maps every snake_case key', () {
      final note = JourneyNote.fromJson(fullJson);
      expect(note.name, 'JRN-2026-00042');
      expect(note.referenceDoctype, 'Lead');
      expect(note.referenceName, 'LEAD-0001');
      expect(note.entryDate, '2026-08-10');
      expect(note.entryType, 'Sample Drop');
      expect(note.contactPerson, 'Mostafa');
      expect(note.contactRole, 'Branch Manager');
      expect(note.contactPhone, '01000000009');
      expect(note.nextAction, 'Call to confirm the trial order');
      expect(note.nextActionDate, '2026-08-14');
      expect(note.outcome, 'Interested');
      expect(note.loggedByName, 'Sales Rep');
      expect(note.canEdit, isTrue);
    });

    test('a minimal payload decodes to safe defaults', () {
      final note = JourneyNote.fromJson({'name': 'JRN-1'});
      expect(note.note, '');
      expect(note.entryDate, isNull);
      expect(note.contactPerson, '');
      expect(note.canEdit, isFalse);
      expect(note.hasNextAction, isFalse);
    });

    test('contactLabel joins person and role, tolerating either missing', () {
      expect(JourneyNote.fromJson(fullJson).contactLabel,
          'Mostafa (Branch Manager)');
      expect(
        JourneyNote.fromJson({...fullJson, 'contact_role': ''}).contactLabel,
        'Mostafa',
      );
      expect(
        JourneyNote.fromJson({...fullJson, 'contact_person': ''}).contactLabel,
        'Branch Manager',
      );
      expect(
        JourneyNote.fromJson({
          ...fullJson,
          'contact_person': '',
          'contact_role': '',
        }).contactLabel,
        '',
      );
    });

    test('hasNextAction is true for a date alone or text alone', () {
      expect(
        JourneyNote.fromJson({...fullJson, 'next_action': ''}).hasNextAction,
        isTrue,
      );
      expect(
        JourneyNote.fromJson({...fullJson, 'next_action_date': null})
            .hasNextAction,
        isTrue,
      );
      expect(
        JourneyNote.fromJson({
          ...fullJson,
          'next_action': '',
          'next_action_date': null,
        }).hasNextAction,
        isFalse,
      );
    });
  });

  group('JourneySummary on cards', () {
    test('a B2bCard folds the flat journey keys into a summary', () {
      final card = B2bCard.fromJson({
        'doctype': 'Lead',
        'name': 'LEAD-0001',
        'title': 'Zooba',
        'stage': 'Sample',
        'journey_count': 3,
        'last_journey_date': '2026-08-10',
        'last_journey_type': 'Call',
        'last_journey_note': 'Manager wants a price list',
        'last_journey_contact': 'Mostafa',
        'next_action_date': '2026-08-14',
        'next_action': 'Send the price list',
      });

      expect(card.journey.journeyCount, 3);
      expect(card.journey.lastJourneyDate, '2026-08-10');
      expect(card.journey.lastJourneyType, 'Call');
      expect(card.journey.lastJourneyContact, 'Mostafa');
      expect(card.journey.nextActionDate, '2026-08-14');
      expect(card.journey.hasNextAction, isTrue);
      expect(card.journey.isEmpty, isFalse);
    });

    test('a card with no diary reports an empty summary', () {
      final card = B2bCard.fromJson({
        'doctype': 'Lead',
        'name': 'LEAD-0002',
        'title': 'Nobody visited',
        'stage': 'Lead',
      });
      expect(card.journey.isEmpty, isTrue);
      expect(card.journey.hasNextAction, isFalse);
    });

    test('a Lead row carries the same summary shape', () {
      final lead = Lead.fromJson({
        'name': 'LEAD-0003',
        'lead_name': 'Cilantro',
        'journey_count': 1,
        'last_journey_date': '2026-08-09',
        'next_action_date': '2026-08-20',
      });
      expect(lead.journey.journeyCount, 1);
      expect(lead.journey.lastJourneyDate, '2026-08-09');
      expect(lead.journey.hasNextAction, isTrue);
    });

    test('a lead detail payload decodes its note list', () {
      final lead = Lead.fromJson({
        'name': 'LEAD-0004',
        'lead_name': 'Espresso Lab',
        'journey_notes': [
          {'name': 'JRN-1', 'note': 'Second visit', 'entry_date': '2026-08-10'},
          {'name': 'JRN-2', 'note': 'First visit', 'entry_date': '2026-08-01'},
        ],
      });
      expect(lead.journeyNotes, hasLength(2));
      expect(lead.journeyNotes.first.note, 'Second visit');
    });

    test('a lead with no journey_notes key decodes to an empty list', () {
      final lead = Lead.fromJson({'name': 'LEAD-0005'});
      expect(lead.journeyNotes, isEmpty);
    });
  });

  group('JourneyOptions', () {
    test('decodes the editor Select lists', () {
      final options = JourneyOptions.fromJson({
        'entry_types': ['Visit', 'Call'],
        'outcomes': ['Interested'],
      });
      expect(options.entryTypes, ['Visit', 'Call']);
      expect(options.outcomes, ['Interested']);
    });

    test('an empty payload decodes to empty lists, never null', () {
      final options = JourneyOptions.fromJson(const {});
      expect(options.entryTypes, isEmpty);
      expect(options.outcomes, isEmpty);
    });
  });
}
