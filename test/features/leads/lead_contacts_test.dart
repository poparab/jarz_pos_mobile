import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/lead_contacts_section.dart';

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<LeadContact> contacts,
  required Future<void> Function(List<LeadContact>) onSave,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LeadContactsSection(contacts: contacts, onSave: onSave),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

const _omar = LeadContact(
  contactName: 'Omar',
  role: 'Owner',
  phone: '0100000001',
  isPrimary: true,
);
const _sara = LeadContact(
  contactName: 'Sara',
  role: 'Shift Manager',
  phone: '0100000002',
);
const _ali = LeadContact(contactName: 'Ali', role: 'Barista');

void main() {
  group('LeadContact model', () {
    test('decodes a get_lead contacts row', () {
      final contact = LeadContact.fromJson(const {
        'contact_name': 'Omar',
        'role': 'Owner',
        'phone': '0100000001',
        'email': 'omar@example.com',
        'is_primary': true,
        'notes': 'decides',
      });

      expect(contact.contactName, 'Omar');
      expect(contact.role, 'Owner');
      expect(contact.phone, '0100000001');
      expect(contact.email, 'omar@example.com');
      expect(contact.isPrimary, isTrue);
      expect(contact.notes, 'decides');
      expect(contact.canCall, isTrue);
    });

    test('a missing/partial row decodes to null-safe defaults', () {
      final contact = LeadContact.fromJson(const {'contact_name': 'Ali'});

      expect(contact.role, '');
      expect(contact.phone, '');
      expect(contact.isPrimary, isFalse);
      expect(contact.canCall, isFalse);
    });

    test('displayName falls back to the number when saved without a name', () {
      const contact = LeadContact(phone: '0100000009');
      expect(contact.displayName, '0100000009');
    });

    test('round-trips through toJson with the backend key names', () {
      final json = _omar.toJson();
      expect(json['contact_name'], 'Omar');
      expect(json['is_primary'], true);
      expect(LeadContact.fromJson(json), _omar);
    });
  });

  group('Lead contacts wiring', () {
    test('a lead payload without contacts decodes to an empty list', () {
      final lead = Lead.fromJson(const {'name': 'L-1', 'lead_name': 'Brand'});
      expect(lead.contacts, isEmpty);
      expect(lead.primaryContact, isNull);
      expect(lead.callablePhone, '');
    });

    test('contacts decode off a catalog row', () {
      final lead = Lead.fromJson(const {
        'name': 'L-1',
        'lead_name': 'Brand',
        'contacts': [
          {'contact_name': 'Omar', 'role': 'Owner', 'phone': '0100000001',
           'is_primary': true},
          {'contact_name': 'Ali', 'role': 'Barista'},
        ],
      });

      expect(lead.contacts, hasLength(2));
      expect(lead.contacts.first.role, 'Owner');
      expect(lead.primaryContact?.contactName, 'Omar');
    });

    test('callablePhone prefers the lead line over the primary contact', () {
      const lead = Lead(
        name: 'L-1',
        phone: '0100000900',
        contacts: [_omar],
      );
      expect(lead.callablePhone, '0100000900');
    });

    test('callablePhone falls back to the primary contact', () {
      const lead = Lead(name: 'L-1', contacts: [_ali, _omar]);
      // Ali has no number, so the flagged primary Omar is the one to ring.
      expect(lead.primaryContact?.contactName, 'Omar');
      expect(lead.callablePhone, '0100000001');
    });

    test('callablePhone falls back to any contact with a number', () {
      const lead = Lead(name: 'L-1', contacts: [_ali, _sara]);
      expect(lead.callablePhone, '0100000002');
    });
  });

  group('LeadContactsSection', () {
    testWidgets('lists every person with their title', (tester) async {
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara, _ali],
        onSave: (_) async {},
      );

      expect(find.text('Omar'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Shift Manager'), findsOneWidget);
      expect(find.text('Barista'), findsOneWidget);
      expect(find.text('Contacts (3)'), findsOneWidget);
    });

    testWidgets('shows an empty prompt when nobody is recorded',
        (tester) async {
      await _pumpSection(tester, contacts: const [], onSave: (_) async {});

      expect(find.text('Contacts'), findsOneWidget);
      expect(find.textContaining('No people recorded yet'), findsOneWidget);
      expect(find.text('Add contact'), findsOneWidget);
    });

    testWidgets('the call button is disabled for a contact with no number',
        (tester) async {
      await _pumpSection(
        tester,
        contacts: const [_omar, _ali],
        onSave: (_) async {},
      );

      final buttons = tester
          .widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.call))
          .toList();
      expect(buttons, hasLength(2));
      expect(buttons[0].onPressed, isNotNull); // Omar has a number.
      expect(buttons[1].onPressed, isNull); // Ali does not.
    });

    testWidgets('"make primary" sends exactly one primary contact',
        (tester) async {
      List<LeadContact>? saved;
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara],
        onSave: (rows) async => saved = rows,
      );

      // Sara's row is the second one, so its overflow menu is the second.
      await tester.tap(find.byIcon(Icons.more_vert).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Make primary'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.map((c) => c.isPrimary).toList(), [false, true]);
    });

    testWidgets('removing a contact drops it and re-seats the primary',
        (tester) async {
      List<LeadContact>? saved;
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara],
        onSave: (rows) async => saved = rows,
      );

      // Omar is the primary; removing him must leave Sara as the primary.
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!, hasLength(1));
      expect(saved!.single.contactName, 'Sara');
      expect(saved!.single.isPrimary, isTrue);
    });

    testWidgets('cancelling the remove dialog changes nothing', (tester) async {
      var saves = 0;
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara],
        onSave: (_) async => saves++,
      );

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(saves, 0);
    });

    testWidgets('adding a person appends them as the primary when first',
        (tester) async {
      List<LeadContact>? saved;
      await _pumpSection(
        tester,
        contacts: const [],
        onSave: (rows) async => saved = rows,
      );

      await tester.tap(find.text('Add contact'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Name'), 'Mahmoud');
      await tester.enterText(
          find.widgetWithText(TextField, 'Phone'), '0100000005');
      // The role suggestion chips fill the free-text title in one tap.
      await tester.tap(find.widgetWithText(ActionChip, 'Manager'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!, hasLength(1));
      expect(saved!.single.contactName, 'Mahmoud');
      expect(saved!.single.phone, '0100000005');
      expect(saved!.single.role, 'Manager');
      expect(saved!.single.isPrimary, isTrue);
    });

    testWidgets('an empty person is refused rather than saved', (tester) async {
      var saves = 0;
      await _pumpSection(
        tester,
        contacts: const [],
        onSave: (_) async => saves++,
      );

      await tester.tap(find.text('Add contact'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(saves, 0);
      expect(find.textContaining('Add a name or a phone number'),
          findsOneWidget);
    });

    testWidgets('editing a person keeps their position in the list',
        (tester) async {
      List<LeadContact>? saved;
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara],
        onSave: (rows) async => saved = rows,
      );

      await tester.tap(find.byIcon(Icons.more_vert).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit contact'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Role / title'), 'Head Barista');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.map((c) => c.contactName).toList(), ['Omar', 'Sara']);
      expect(saved![1].role, 'Head Barista');
      // Omar stays the primary — editing Sara did not move the flag.
      expect(saved!.map((c) => c.isPrimary).toList(), [true, false]);
    });

    testWidgets('a failed save surfaces the error instead of swallowing it',
        (tester) async {
      await _pumpSection(
        tester,
        contacts: const [_omar, _sara],
        onSave: (_) async => throw Exception('boom'),
      );

      await tester.tap(find.byIcon(Icons.more_vert).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Make primary'));
      await tester.pumpAndSettle();

      // The failure is shown, as the localised line - 'boom' is not user copy.
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.userErrorUnexpected), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
    });
  });
}
