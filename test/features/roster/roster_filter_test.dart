import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_cell_style.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_filter_sheet.dart';
import 'package:jarz_pos/src/features/roster/state/roster_filter.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Shift Distribution people/branch filter: which rows it shows, how the
/// totals and hours follow it, and that it survives a restart.
const _ana = 'HR-EMP-00001'; // Dokki, linked
const _bassem = 'HR-EMP-00002'; // Nasr City, linked; covers Dokki on the 6th
const _carla = 'HR-EMP-00003'; // Factory by schedule location only
const _dina = 'HR-EMP-00004'; // Nasr City, never at Dokki

String _oct(int day) => '2026-10-${day.toString().padLeft(2, '0')}';

Map<String, dynamic> _working(String date, String at) => {
  'date': date,
  'shift_type': 'Branch Opening',
  'shift_location': at,
  'hours': 9,
};

RosterMonth _month({
  String month = '2026-10',
  List<Map<String, dynamic>>? employees,
  List<Map<String, dynamic>> gaps = const [],
}) => RosterMonth.fromJson({
  'hrms_available': true,
  'month': month,
  'month_start': '$month-01',
  'month_end': '$month-31',
  'employees':
      employees ??
      [
        {
          'employee': _ana,
          'employee_name': 'Ana',
          'shift_locations': ['Dokki'],
          'days': {_oct(5): _working(_oct(5), 'Dokki')},
        },
        {
          'employee': _bassem,
          'employee_name': 'Bassem',
          'shift_locations': ['Nasr City'],
          'days': {
            _oct(5): _working(_oct(5), 'Nasr City'),
            _oct(6): _working(_oct(6), 'Dokki'),
          },
        },
        {
          'employee': _carla,
          'employee_name': 'Carla',
          'schedule_location': 'Factory',
          'days': const {},
        },
        {
          'employee': _dina,
          'employee_name': 'Dina',
          'shift_locations': ['Nasr City'],
          'days': {_oct(6): _working(_oct(6), 'Nasr City')},
        },
      ],
  'shift_locations': [
    {'shift_location': 'Dokki'},
    {'shift_location': 'Nasr City'},
    {'shift_location': 'Factory'},
  ],
  'uncovered': gaps,
  'scope': {'configured': true, 'unrestricted': true},
});

List<String> _ids(RosterMonth month) => [
  for (final e in month.employees) e.employee,
];

RosterHours _hours() => RosterHours.fromJson({
  'month': '2026-10',
  'rows': [
    {
      'employee': _ana,
      'worked_hours': 10,
      'overtime_hours': 1,
      'credited_hours': 11,
    },
    {
      'employee': _bassem,
      'worked_hours': 20,
      'overtime_hours': 2,
      'credited_hours': 22,
    },
    {
      'employee': _dina,
      'worked_hours': 40,
      'overtime_hours': 4,
      'credited_hours': 44,
    },
  ],
  'totals': {'worked_hours': 70, 'overtime_hours': 7, 'credited_hours': 77},
});

void main() {
  group('which rows show', () {
    final month = _month();

    test('an empty filter shows everyone', () {
      expect(_ids(rosterApplyFilter(month, RosterFilter.empty)), [
        _ana,
        _bassem,
        _carla,
        _dina,
      ]);
    });

    test('a branch shows the people who belong to it', () {
      // Ana is linked to Dokki; Bassem covers a Dokki shift on the 6th.
      expect(
        _ids(
          rosterApplyFilter(month, const RosterFilter(locations: {'Dokki'})),
        ),
        [_ana, _bassem],
      );
      // Carla belongs to the factory through her schedule location alone.
      expect(
        _ids(
          rosterApplyFilter(month, const RosterFilter(locations: {'Factory'})),
        ),
        [_carla],
      );
    });

    test('people picked by name show whatever their branch', () {
      expect(
        _ids(rosterApplyFilter(month, const RosterFilter(employees: {_dina}))),
        [_dina],
      );
    });

    test('branches and people together: picked OR belonging', () {
      expect(
        _ids(
          rosterApplyFilter(
            month,
            const RosterFilter(locations: {'Factory'}, employees: {_ana}),
          ),
        ),
        [_ana, _carla],
      );
    });

    test('the belongs rule: linked, schedule location, or a loaded shift', () {
      final byId = {for (final e in month.employees) e.employee: e};
      expect(rosterEmployeeBelongsTo(byId[_ana]!, {'Dokki'}), isTrue);
      expect(rosterEmployeeBelongsTo(byId[_bassem]!, {'Dokki'}), isTrue);
      expect(rosterEmployeeBelongsTo(byId[_carla]!, {'Factory'}), isTrue);
      expect(rosterEmployeeBelongsTo(byId[_dina]!, {'Dokki'}), isFalse);
      expect(rosterEmployeeBelongsTo(byId[_ana]!, const {}), isFalse);
    });

    test('gaps follow the visible rows', () {
      final withGaps = _month(
        gaps: [
          {'employee': _ana, 'off_date': _oct(5), 'off_type': 'Vacation'},
          {'employee': _dina, 'off_date': _oct(6), 'off_type': 'Vacation'},
        ],
      );
      final shown = rosterApplyFilter(
        withGaps,
        const RosterFilter(locations: {'Dokki'}),
      );
      expect([for (final g in shown.gaps) g.employee], [_ana]);
    });
  });

  group('stale ids are dropped, not obeyed', () {
    test('a branch or person that no longer exists stops counting', () {
      final effective = rosterEffectiveFilter(
        const RosterFilter(
          locations: {'Dokki', 'Old Branch'},
          employees: {_ana, 'HR-EMP-09999'},
        ),
        knownLocations: {'Dokki', 'Nasr City'},
        knownEmployees: {_ana, _bassem},
      );
      expect(effective.locations, {'Dokki'});
      expect(effective.employees, {_ana});
    });

    test('nothing is pruned before the lists have loaded', () {
      const saved = RosterFilter(locations: {'Dokki'}, employees: {_ana});
      expect(
        rosterEffectiveFilter(
          saved,
          knownLocations: const {},
          knownEmployees: null,
        ),
        saved,
      );
    });

    test('a filter whose every id is stale shows everyone', () {
      final effective = rosterEffectiveFilter(
        const RosterFilter(locations: {'Gone'}, employees: {'HR-EMP-09999'}),
        knownLocations: {'Dokki'},
        knownEmployees: {_ana},
      );
      expect(effective.isEmpty, isTrue);
    });
  });

  group('hours and totals follow the filter', () {
    test('hours rows and totals are re-added from the visible people', () {
      final hours = rosterFilterHours(_hours(), {_ana, _bassem});
      expect([for (final r in hours.rows) r.employee], [_ana, _bassem]);
      expect(hours.totalWorkedHours, 30);
      expect(hours.totalOvertimeHours, 3);
      expect(hours.totalCreditedHours, 33);
      // No filter: untouched, totals as the server sent them.
      expect(rosterFilterHours(_hours(), null).totalWorkedHours, 70);
    });

    test(
      'the visible-hours provider uses the roster to find branch members',
      () async {
        final container = ProviderContainer(
          overrides: [
            rosterMonthDataProvider.overrideWith((ref) async => _month()),
            rosterHoursProvider.overrideWith((ref) async => _hours()),
            rosterBootstrapProvider.overrideWith(
              (ref) async => RosterBootstrap.fromJson(const {
                'hrms_available': true,
                'shift_locations': [],
              }),
            ),
            rosterFilterStoreProvider.overrideWithValue(
              MemoryRosterFilterStore(),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(rosterMonthDataProvider.future);
        await container.read(rosterHoursProvider.future);
        await container.read(rosterBootstrapProvider.future);
        await container
            .read(rosterFilterProvider.notifier)
            .apply(const RosterFilter(locations: {'Dokki'}));

        final hours = container.read(rosterVisibleHoursProvider).requireValue;
        expect([for (final r in hours.rows) r.employee], [_ana, _bassem]);
        expect(hours.totalWorkedHours, 30);
        final month = container.read(rosterVisibleMonthProvider).requireValue;
        expect(_ids(month), [_ana, _bassem]);
      },
    );

    test('on-duty totals count a branch-picked row only on its days at a '
        'picked branch', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final resolver = RosterStyleResolver(
        l10n: l10n,
        today: DateTime(2026, 10, 1),
      );
      final month = rosterApplyFilter(
        _month(),
        const RosterFilter(locations: {'Dokki'}),
      );
      final totals = RosterGrid.dayTotals(
        month,
        [_oct(5), _oct(6)],
        resolver,
        filter: const RosterFilter(locations: {'Dokki'}),
      );
      // The 5th: Ana at Dokki counts; Bassem is at Nasr City that day.
      expect(totals[_oct(5)]!.onDuty, 1);
      // The 6th: Bassem covers Dokki; Ana has no cell, so her own branch
      // decides and she counts as at risk, not on duty.
      expect(totals[_oct(6)]!.onDuty, 1);

      // Picked by name: every working day counts, wherever it is.
      final byName = RosterGrid.dayTotals(
        rosterApplyFilter(_month(), const RosterFilter(employees: {_bassem})),
        [_oct(5)],
        resolver,
        filter: const RosterFilter(employees: {_bassem}),
      );
      expect(byName[_oct(5)]!.onDuty, 1);
    });
  });

  group('two months merge into one week', () {
    test('people are merged by id, days unioned, gaps de-duplicated', () {
      final september = _month(
        month: '2026-09',
        employees: [
          {
            'employee': _ana,
            'employee_name': 'Ana',
            'shift_locations': ['Dokki'],
            'days': {'2026-09-30': _working('2026-09-30', 'Dokki')},
          },
          {
            'employee': 'HR-EMP-00009',
            'employee_name': 'Left In September',
            'days': const {},
          },
        ],
        gaps: [
          {'employee': _ana, 'off_date': '2026-09-29', 'off_type': 'Vacation'},
        ],
      );
      final october = _month(
        gaps: [
          {'employee': _ana, 'off_date': '2026-09-29', 'off_type': 'Vacation'},
        ],
      );
      final merged = rosterMergeMonths([september, october]);
      expect(merged.month, '2026-09');
      expect(merged.monthStart, '2026-09-01');
      expect(merged.monthEnd, '2026-10-31');
      expect(_ids(merged), [_ana, 'HR-EMP-00009', _bassem, _carla, _dina]);
      final ana = merged.employees.first;
      expect(ana.days.keys, containsAll(['2026-09-30', _oct(5)]));
      expect(merged.gaps, hasLength(1));
      expect(merged.shiftLocations, hasLength(3));
      expect(rosterMergeMonths([october]), same(october));
    });
  });

  group('saved per user and site', () {
    test('the key is roster_filter_v1:<site>:<user>, lower-cased', () {
      expect(
        rosterFilterPrefsKey(site: 'ERP.orderjarz.com', user: 'Ana@Jarz.com'),
        'roster_filter_v1:erp.orderjarz.com:ana@jarz.com',
      );
    });

    test('JSON round trip, and junk reads as no filter', () {
      const filter = RosterFilter(
        locations: {'Nasr City', 'Dokki'},
        employees: {_ana},
      );
      final json = jsonDecode(jsonEncode(filter.toJson()));
      expect(RosterFilter.fromJson(json), filter);
      expect(RosterFilter.fromJson(null), RosterFilter.empty);
      expect(RosterFilter.fromJson('nonsense'), RosterFilter.empty);
      expect(
        RosterFilter.fromJson({
          'locations': 'Dokki',
          'employees': [null, '', ' $_ana '],
        }),
        const RosterFilter(employees: {_ana}),
      );
    });

    test(
      'apply saves; a new controller for the same user restores it',
      () async {
        final store = MemoryRosterFilterStore();
        const key = 'roster_filter_v1:erp.example:ana';
        const filter = RosterFilter(locations: {'Dokki'}, employees: {_bassem});

        final first = RosterFilterController(store);
        await first.restore(key);
        expect(first.state, RosterFilter.empty);
        await first.apply(filter);
        expect(store.values.containsKey(key), isTrue);
        first.dispose();

        final second = RosterFilterController(store);
        await second.restore(key);
        expect(second.state, filter);

        // Another user on the same phone starts from everyone.
        await second.restore('roster_filter_v1:erp.example:bassem');
        expect(second.state, RosterFilter.empty);

        // Clearing removes the saved entry.
        await second.restore(key);
        expect(second.state, filter);
        await second.apply(RosterFilter.empty);
        expect(store.values.containsKey(key), isFalse);
        second.dispose();
      },
    );

    test(
      'a filter chosen before the user is known is kept and saved',
      () async {
        final store = MemoryRosterFilterStore({
          'k': jsonEncode(const RosterFilter(locations: {'Factory'}).toJson()),
        });
        final controller = RosterFilterController(store);
        await controller.apply(const RosterFilter(locations: {'Dokki'}));
        await controller.restore('k');
        expect(controller.state, const RosterFilter(locations: {'Dokki'}));
        expect(await store.load('k'), const RosterFilter(locations: {'Dokki'}));
        controller.dispose();
      },
    );

    test('SharedPreferences store round trip', () async {
      SharedPreferences.setMockInitialValues({});
      const store = SharedPrefsRosterFilterStore();
      const key = 'roster_filter_v1:erp.example:ana';
      expect(await store.load(key), isNull);
      await store.save(key, const RosterFilter(locations: {'Dokki'}));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key), isNotNull);
      expect(await store.load(key), const RosterFilter(locations: {'Dokki'}));
      await store.save(key, RosterFilter.empty);
      expect(prefs.getString(key), isNull);

      await prefs.setString(key, '{not json');
      expect(await store.load(key), isNull);
    });

    test(
      'the screen restores the saved filter once the user is known',
      () async {
        const key = 'roster_filter_v1:erp.example:ana';
        final store = MemoryRosterFilterStore({
          key: jsonEncode(const RosterFilter(employees: {_dina}).toJson()),
        });
        final container = ProviderContainer(
          overrides: [
            rosterFilterStoreProvider.overrideWithValue(store),
            rosterFilterKeyProvider.overrideWith((ref) async => key),
          ],
        );
        addTearDown(container.dispose);
        container.read(rosterFilterRestoreProvider);
        await container.read(rosterFilterKeyProvider.future);
        await Future<void>.delayed(Duration.zero);
        expect(
          container.read(rosterFilterProvider),
          const RosterFilter(employees: {_dina}),
        );
      },
    );
  });

  group('the button and the sheet', () {
    test('the summary names up to two, then counts', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(rosterFilterSummary(l10n, RosterFilter.empty), 'All');
      expect(
        rosterFilterSummary(
          l10n,
          const RosterFilter(locations: {'Factory', 'Dokki'}),
        ),
        'Dokki, Factory',
      );
      expect(
        rosterFilterSummary(
          l10n,
          const RosterFilter(employees: {_ana}),
          names: const {_ana: 'Ana'},
        ),
        'Ana',
      );
      expect(
        rosterFilterSummary(
          l10n,
          const RosterFilter(
            locations: {'Dokki'},
            employees: {_ana, _bassem, _carla},
          ),
        ),
        '3 people + 1 branch',
      );
      expect(
        rosterFilterSummary(
          l10n,
          const RosterFilter(locations: {'A', 'B', 'C'}),
        ),
        '3 branches',
      );
    });

    testWidgets('ticking a branch and applying filters and saves', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final store = MemoryRosterFilterStore();
      final container = ProviderContainer(
        overrides: [
          rosterMonthDataProvider.overrideWith((ref) async => _month()),
          rosterBootstrapProvider.overrideWith(
            (ref) async => RosterBootstrap.fromJson(const {
              'hrms_available': true,
              'shift_locations': [
                {'shift_location': 'Dokki'},
                {'shift_location': 'Nasr City'},
                {'shift_location': 'Factory'},
              ],
            }),
          ),
          rosterFilterStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Center(child: RosterFilterButton())),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);

      await tester.tap(find.byKey(rosterFilterButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(rosterFilterBranchKey('Factory')), findsOneWidget);
      expect(find.byKey(rosterFilterPersonKey(_ana)), findsOneWidget);

      await tester.tap(find.byKey(rosterFilterBranchKey('Dokki')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(rosterFilterApplyKey));
      await tester.pumpAndSettle();

      expect(
        container.read(rosterFilterProvider),
        const RosterFilter(locations: {'Dokki'}),
      );
      expect(find.text('Dokki'), findsOneWidget);
      expect(_ids(container.read(rosterVisibleMonthProvider).requireValue), [
        _ana,
        _bassem,
      ]);
    });
  });
}
