import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/journey/data/journey_repository.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_note.dart';
import 'package:jarz_pos/src/features/journey/presentation/widgets/journey_notes_section.dart';

class _FakeJourneyRepository extends JourneyRepository {
  _FakeJourneyRepository(this._notes) : super(Dio());

  final List<JourneyNote> _notes;

  @override
  Future<List<JourneyNote>> getNotes({
    required String referenceDoctype,
    required String referenceName,
  }) async =>
      _notes;
}

JourneyNote _note(
  int i, {
  String nextAction = '',
  String? nextActionDate,
  bool done = false,
}) =>
    JourneyNote(
      name: 'JRN-$i',
      referenceDoctype: 'Lead',
      referenceName: 'LEAD-0001',
      entryDate: '2026-09-${(20 - i).toString().padLeft(2, '0')}',
      entryType: 'Visit',
      note: 'Log number $i',
      nextAction: nextAction,
      nextActionDate: nextActionDate,
      nextActionDone: done,
    );

Future<void> _pump(WidgetTester tester, List<JourneyNote> notes) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journeyRepositoryProvider
            .overrideWithValue(_FakeJourneyRepository(notes)),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: JourneyNotesSection(
              referenceDoctype: 'Lead',
              referenceName: 'LEAD-0001',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('openJourneyTasks', () {
    test('keeps only undone next actions, soonest first, undated last', () {
      final tasks = openJourneyTasks([
        _note(1, nextAction: 'Later', nextActionDate: '2026-09-30'),
        _note(2, nextAction: 'No date'),
        _note(3, nextAction: 'Done', nextActionDate: '2026-09-01', done: true),
        _note(4, nextAction: 'Soon', nextActionDate: '2026-09-22'),
        _note(5),
      ]);
      expect(tasks.map((n) => n.name), ['JRN-4', 'JRN-1', 'JRN-2']);
    });
  });

  testWidgets('shows only the latest logs until Show all is tapped',
      (tester) async {
    await _pump(tester, [for (var i = 1; i <= 5; i++) _note(i)]);

    expect(find.text('Log number 1'), findsOneWidget);
    expect(find.text('Log number 3'), findsOneWidget);
    expect(find.text('Log number 4'), findsNothing);
    expect(find.text('No open tasks'), findsOneWidget);

    await tester.tap(find.text('Show all 5 logs'));
    await tester.pumpAndSettle();
    expect(find.text('Log number 5'), findsOneWidget);
    expect(find.text('Show latest only'), findsOneWidget);
  });

  testWidgets('an old log\'s unfinished task is still pinned on top',
      (tester) async {
    await _pump(tester, [
      for (var i = 1; i <= 4; i++) _note(i),
      _note(5, nextAction: 'Send the price list', nextActionDate: '2026-09-10'),
    ]);

    // The log itself is past the latest three, but its promise is not.
    expect(find.text('Log number 5'), findsNothing);
    expect(find.text('1 open task'), findsOneWidget);
    expect(find.text('Send the price list'), findsOneWidget);
  });
}
