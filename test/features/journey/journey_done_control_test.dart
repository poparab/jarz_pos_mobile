import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/journey/data/journey_repository.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_note.dart';
import 'package:jarz_pos/src/features/journey/presentation/widgets/journey_notes_section.dart';

/// Stands in for the HTTP layer: the timeline reloads after every write, so the
/// fake keeps its own list and serves the updated row back exactly like the
/// endpoint does.
class _FakeJourneyRepository extends JourneyRepository {
  _FakeJourneyRepository(this._notes) : super(Dio());

  List<JourneyNote> _notes;
  final List<String> calls = [];

  @override
  Future<List<JourneyNote>> getNotes({
    required String referenceDoctype,
    required String referenceName,
  }) async =>
      _notes;

  @override
  Future<JourneyNote> setActionDone({
    required String name,
    required bool done,
  }) async {
    calls.add('$name:$done');
    _notes = _notes
        .map(
          (n) => n.name == name
              ? n.copyWith(
                  nextActionDone: done,
                  nextActionDoneOn: done ? '2026-08-15' : null,
                  nextActionDoneByName: done ? 'Sales Rep' : '',
                )
              : n,
        )
        .toList();
    return _notes.firstWhere((n) => n.name == name);
  }
}

const _base = JourneyNote(
  name: 'JRN-1',
  referenceDoctype: 'Lead',
  referenceName: 'LEAD-0001',
  entryDate: '2026-08-10',
  entryType: 'Visit',
  note: 'Left 3 jars with the barista.',
  nextAction: 'Call to confirm the trial order',
  nextActionDate: '2026-08-14',
);

Future<_FakeJourneyRepository> _pump(
  WidgetTester tester,
  JourneyNote note,
) async {
  final repo = _FakeJourneyRepository([note]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [journeyRepositoryProvider.overrideWithValue(repo)],
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
  return repo;
}

void main() {
  testWidgets('an open action offers the done control and closes it',
      (tester) async {
    final repo = await _pump(tester, _base.copyWith(canComplete: true));

    expect(find.byTooltip('Mark done'), findsOneWidget);
    expect(find.byTooltip('Mark as not done'), findsNothing);

    await tester.tap(find.byTooltip('Mark done'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['JRN-1:true']);
    // The reloaded row reads as settled: who closed it and when.
    expect(find.textContaining('Done 15 Aug 2026'), findsOneWidget);
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testWidgets('a done action is undoable by tapping again', (tester) async {
    final repo = await _pump(
      tester,
      _base.copyWith(
        canComplete: true,
        nextActionDone: true,
        nextActionDoneOn: '2026-08-15',
        nextActionDoneByName: 'Sales Rep',
      ),
    );

    await tester.tap(find.byTooltip('Mark as not done'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['JRN-1:false']);
    expect(find.byTooltip('Mark done'), findsOneWidget);
  });

  testWidgets('without can_complete the state shows but no control does',
      (tester) async {
    await _pump(
      tester,
      _base.copyWith(
        nextActionDone: true,
        nextActionDoneOn: '2026-08-15',
        nextActionDoneByName: 'Sales Rep',
      ),
    );

    // Permission is the server's answer, never the app's guess.
    expect(find.byTooltip('Mark done'), findsNothing);
    expect(find.byTooltip('Mark as not done'), findsNothing);
    expect(find.textContaining('Done 15 Aug 2026'), findsOneWidget);
  });
}
