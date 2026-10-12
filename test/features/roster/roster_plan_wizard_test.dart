import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/roster/data/roster_repository.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/models/roster_plan_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_plan_wizard.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_plan_person_card.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_plan_review.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

import '../../helpers/mock_services.dart';

/// The rota plan wizard end to end against a fake repository:
/// When → Who → Their week → Check & apply.
const _ali = 'HR-EMP-0001';
const _omar = 'HR-EMP-0002';
const _sara = 'HR-EMP-0003';

class _FakeRosterRepository extends RosterRepository {
  _FakeRosterRepository() : super(MockDio());

  final List<({Map<String, dynamic> plan, bool dryRun})> calls = [];

  @override
  Future<RosterPlanDefaults> getPlanDefaults({String? shiftLocation}) async {
    return RosterPlanDefaults.fromJson({
      'suggested_start': '2026-11-01',
      'employees': [
        {
          'employee': _ali,
          'employee_name': 'Ali',
          'shift_location': 'Nasr City',
          'shift_type': 'Branch Opening',
          'off_days': ['Friday'],
          'friday_shift_type': 'Branch Opening - Friday',
          'use_friday_variant': true,
          'covers': [
            {
              'weekday': 'Friday',
              'covered_by': _omar,
              'covered_by_name': 'Omar',
              'cover_shift_type': 'Branch Cover Full Day',
            },
          ],
          'has_standing_rota': true,
        },
        {
          'employee': _omar,
          'employee_name': 'Omar',
          'shift_location': 'Nasr City',
          'shift_type': 'Branch Closing',
          'off_days': ['Tuesday'],
          'has_standing_rota': true,
        },
        {
          'employee': _sara,
          'employee_name': 'Sara',
          'shift_location': 'Dokki',
          'shift_type': 'Branch Opening',
          'off_days': ['Saturday'],
          'has_standing_rota': false,
        },
      ],
    });
  }

  /// Mimics the server's `cover_is_off` rule: a coverer who is off on the
  /// weekday they are asked to cover is an error.
  @override
  Future<RosterPlanResult> applyPlan(
    Map<String, dynamic> plan, {
    required bool dryRun,
  }) async {
    calls.add((plan: plan, dryRun: dryRun));
    final rows = (plan['rows'] as List).cast<Map<String, dynamic>>();
    final offByEmployee = {
      for (final r in rows) r['employee']: (r['off_days'] as List).toSet(),
    };
    final issues = <Map<String, dynamic>>[];
    for (final r in rows) {
      for (final c in (r['covers'] as List).cast<Map<String, dynamic>>()) {
        if (offByEmployee[c['covered_by']]?.contains(c['weekday']) ?? false) {
          issues.add({
            'employee': r['employee'],
            'employee_name': 'Ali',
            'date': '2026-11-06',
            'code': 'cover_is_off',
            'severity': 'error',
            'message': 'Omar is off that day',
          });
        }
      }
    }
    issues.add({
      'employee': _ali,
      'employee_name': 'Ali',
      'date': '2026-11-07',
      'code': 'same_day_off',
      'severity': 'warning',
      'message': 'Two people off together',
    });
    final hasErrors = issues.any((i) => i['severity'] == 'error');
    final replace = plan['replace_manual'] == true;
    return RosterPlanResult.fromJson({
      'dry_run': dryRun,
      'applied': !dryRun && !hasErrors,
      'start': plan['start'],
      'end': plan['end'],
      'summary': {
        'people': rows.length,
        'shift_days': 50,
        'day_offs': 8,
        'covers': 4,
        'manual_kept': replace ? 0 : 1,
        'manual_replaced': replace ? 1 : 0,
        'errors': hasErrors ? 1 : 0,
        'warnings': 1,
      },
      'rows': [
        {
          'employee': _ali,
          'employee_name': 'Ali',
          'manual_days': [
            {'date': '2026-11-12', 'current': 'Evening', 'kind': 'shift'},
          ],
        },
      ],
      'issues': issues,
    });
  }
}

RosterBootstrap _bootstrap() => RosterBootstrap.fromJson({
  'hrms_available': true,
  'shift_catalog': [
    for (final name in [
      'Branch Opening',
      'Branch Opening - Friday',
      'Branch Closing',
      'Branch Cover Full Day',
    ])
      {
        'shift_type': name,
        'start_time': '09:00:00',
        'end_time': '18:00:00',
        'hours': 9,
      },
  ],
  'shift_locations': [
    {'shift_location': 'Nasr City'},
    {'shift_location': 'Dokki'},
  ],
  'scope': {'configured': true, 'unrestricted': true},
});

Widget _app({
  required Widget home,
  required List<Override> overrides,
  Locale locale = const Locale('en'),
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

FilledButton _button(WidgetTester tester, Key key) =>
    tester.widget<FilledButton>(find.byKey(key));

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  // scrollUntilVisible stops once the widget is BUILT, which in a lazy list
  // can still be below the fold.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('When → Who → Their week → Check & apply', (tester) async {
    tester.view.physicalSize = const Size(1080, 2700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = _FakeRosterRepository();
    bool? popped;
    await tester.pumpWidget(
      _app(
        overrides: [
          rosterRepositoryProvider.overrideWithValue(repo),
          rosterBootstrapProvider.overrideWith((ref) async => _bootstrap()),
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  popped = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          RosterPlanWizard(today: DateTime(2026, 10, 12)),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // ── 1. When: next month by default, from the server's suggested start.
    expect(find.text('Which days are you planning?'), findsOneWidget);
    expect(find.textContaining('(30 days)'), findsOneWidget);
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();

    // ── 2. Who: grouped by branch, nobody pre-ticked.
    expect(find.text('Who are you planning for?'), findsOneWidget);
    expect(find.text('Nasr City'), findsOneWidget);
    expect(find.text('Dokki'), findsOneWidget);
    expect(_button(tester, rosterPlanNextKey).onPressed, isNull);
    await tester.tap(find.byKey(rosterPlanBranchToggleKey('Nasr City')));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();

    // ── 3. Their week: pre-filled from the defaults.
    Finder card(String id, {bool skipOffstage = true}) => find.byKey(
      ValueKey<String>('roster-plan-card-$id'),
      skipOffstage: skipOffstage,
    );
    expect(card(_ali), findsOneWidget);
    expect(card(_sara, skipOffstage: false), findsNothing);
    final aliFriday = tester.widget<FilterChip>(
      find.byKey(rosterPlanOffChipKey(_ali, 'Friday')),
    );
    expect(aliFriday.selected, isTrue);
    expect(find.text('Who covers Friday?'), findsOneWidget);

    // "Same for everyone" puts Omar off on Friday too — the day he covers.
    await tester.tap(find.byKey(rosterPlanSameForEveryoneKey));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(rosterPlanOffChipKey(_omar, 'Friday')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(card(_omar), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.byKey(rosterPlanOffChipKey(_omar, 'Friday')))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<FilterChip>(
            find.byKey(rosterPlanOffChipKey(_omar, 'Tuesday')),
          )
          .selected,
      isFalse,
    );

    // ── 4. Check: the dry run runs by itself and the error blocks Apply.
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();
    expect(repo.calls, hasLength(1));
    expect(repo.calls.single.dryRun, isTrue);
    final firstPlan = repo.calls.single.plan;
    expect(firstPlan['start'], '2026-11-01');
    expect(firstPlan['end'], '2026-11-30');
    final sentRows = (firstPlan['rows'] as List).cast<Map>();
    expect(sentRows.map((r) => r['employee']), [_ali, _omar]);
    expect(sentRows.last['shift_type'], 'Branch Opening');
    expect(sentRows.last['off_days'], ['Friday']);
    expect(find.text('Omar is off that day'), findsOneWidget);
    expect(find.text('Fix these first'), findsOneWidget);
    expect(_button(tester, rosterPlanApplyKey).onPressed, isNull);

    // Back to the week: Omar takes Saturday off instead of Friday.
    await tester.tap(find.byKey(rosterPlanBackKey));
    await tester.pumpAndSettle();
    await _tapVisible(
      tester,
      find.byKey(rosterPlanOffChipKey(_omar, 'Friday')),
    );
    await _tapVisible(
      tester,
      find.byKey(rosterPlanOffChipKey(_omar, 'Saturday')),
    );
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();

    expect(repo.calls, hasLength(2));
    expect(((repo.calls.last.plan['rows'] as List).last as Map)['off_days'], [
      'Saturday',
    ]);
    expect(find.text('Omar is off that day'), findsNothing);
    expect(find.text('Two people off together'), findsOneWidget);
    expect(find.text('Days changed by hand'), findsOneWidget);
    expect(find.textContaining('Evening'), findsOneWidget);
    expect(_button(tester, rosterPlanApplyKey).onPressed, isNotNull);

    // "Replace these too" re-runs the preview with replace_manual.
    await _tapVisible(tester, find.byKey(rosterPlanReplaceManualKey));
    expect(repo.calls, hasLength(3));
    expect(repo.calls.last.dryRun, isTrue);
    expect(repo.calls.last.plan['replace_manual'], isTrue);

    // Apply: written for real, the wizard closes and says so.
    await tester.tap(find.byKey(rosterPlanApplyKey));
    await tester.pumpAndSettle();
    expect(repo.calls, hasLength(4));
    expect(repo.calls.last.dryRun, isFalse);
    expect(repo.calls.last.plan['replace_manual'], isTrue);
    expect(popped, isTrue);
    expect(find.byType(RosterPlanWizard), findsNothing);
    expect(find.text('Rota planned for 2 people.'), findsOneWidget);
  });

  testWidgets('the Shift Distribution screen offers "Plan the rota"', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        overrides: [
          canActAsLineManagerProvider.overrideWithValue(true),
          rosterRepositoryProvider.overrideWithValue(_FakeRosterRepository()),
          rosterBootstrapProvider.overrideWith((ref) async => _bootstrap()),
          rosterMonthDataProvider.overrideWith(
            (ref) async => RosterMonth.fromJson(const {
              'month': '2026-10',
              'employees': [],
              'scope': {'configured': true, 'unrestricted': true},
            }),
          ),
        ],
        home: const RosterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(rosterPlanActionKey));
    await tester.pumpAndSettle();
    expect(find.byType(RosterPlanWizard), findsOneWidget);
    expect(find.text('Which days are you planning?'), findsOneWidget);
  });

  testWidgets('lays out in Arabic on a phone through every step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = _FakeRosterRepository();
    await tester.pumpWidget(
      _app(
        locale: const Locale('ar'),
        overrides: [
          rosterRepositoryProvider.overrideWithValue(repo),
          rosterBootstrapProvider.overrideWith((ref) async => _bootstrap()),
        ],
        home: RosterPlanWizard(today: DateTime(2026, 10, 12)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('بتخطط لأنهي أيام؟'), findsOneWidget);
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(rosterPlanBranchToggleKey('Nasr City')));
    await tester.tap(find.byKey(rosterPlanBranchToggleKey('Dokki')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();
    expect(find.text('مين هيغطي يوم الجمعة؟'), findsOneWidget);
    await tester.tap(find.byKey(rosterPlanNextKey));
    await tester.pumpAndSettle();
    expect(find.text('اللي هيحصل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
