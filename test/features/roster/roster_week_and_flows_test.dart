import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_day_off_form.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_day_sheet.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

/// The simplified Shift Distribution screen: week windowing, the cover-shift
/// default in the day-off form, and the gap banner's jump to the day sheet.
const _alice = 'HR-EMP-00001';
const _bob = 'HR-EMP-00002';
const _gapDay = '2026-10-20'; // a Tuesday, in the week Sat 17 – Fri 23

String _oct(int day) => '2026-10-${day.toString().padLeft(2, '0')}';

RosterMonth _october() {
  Map<String, dynamic> days(String id) => {
    for (var d = 1; d <= 31; d++)
      _oct(d): _oct(d) == _gapDay && id == _alice
          ? {
              'date': _gapDay,
              'day_off': {'name': 'RDO-1', 'off_type': 'Vacation'},
            }
          : {
              'date': _oct(d),
              'shift_type': 'Branch Opening',
              'shift_location': 'Nasr City',
              'hours': 9,
            },
  };

  return RosterMonth.fromJson({
    'hrms_available': true,
    'month': '2026-10',
    'month_start': _oct(1),
    'month_end': _oct(31),
    'employees': [
      {
        'employee': _alice,
        'employee_name': 'Alice Absent',
        'standard_hours': 9,
        'shift_locations': ['Nasr City'],
        'days': days(_alice),
      },
      {
        'employee': _bob,
        'employee_name': 'Bob Busy',
        'standard_hours': 9,
        'shift_locations': ['Nasr City'],
        'days': days(_bob),
      },
    ],
    'shift_catalog': [
      {
        'shift_type': 'Branch Opening',
        'start_time': '09:00:00',
        'end_time': '18:00:00',
        'hours': 9,
      },
      {
        'shift_type': 'Branch Closing',
        'start_time': '14:00:00',
        'end_time': '23:00:00',
        'hours': 9,
      },
    ],
    'uncovered': [
      {'employee': _alice, 'off_date': _gapDay, 'off_type': 'Vacation'},
    ],
    'scope': {'configured': true, 'unrestricted': true},
  });
}

Widget _app({required Widget home, List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('en'),
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

Future<ProviderContainer> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final month = _october();
  await tester.pumpWidget(
    _app(
      overrides: [
        canActAsLineManagerProvider.overrideWithValue(true),
        rosterMonthDataProvider.overrideWith((ref) async => month),
        rosterBootstrapProvider.overrideWith(
          (ref) async => RosterBootstrap.fromJson({
            'hrms_available': true,
            'shift_catalog': const [],
            'shift_locations': const [],
            'scope': const {'configured': true, 'unrestricted': true},
          }),
        ),
      ],
      home: const RosterScreen(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(RosterScreen)));
}

void main() {
  group('week windowing', () {
    test('weeks run Saturday to Friday, clipped to the month', () {
      // 1 Oct 2026 is a Thursday: the first week is just Thu 1 – Fri 2.
      final weeks = rosterWeeksOfMonth('2026-10');
      expect(weeks.first, [_oct(1), _oct(2)]);
      expect(weeks[1], [for (var d = 3; d <= 9; d++) _oct(d)]);
      // 31 Oct is a Saturday: the last week is that one day.
      expect(weeks.last, [_oct(31)]);
      expect(weeks.expand((w) => w).toList(), [
        for (var d = 1; d <= 31; d++) _oct(d),
      ]);
      for (final week in weeks.skip(1)) {
        expect(DateTime.parse(week.first).weekday, DateTime.saturday);
      }
      for (final week in weeks.take(weeks.length - 1)) {
        expect(DateTime.parse(week.last).weekday, DateTime.friday);
      }
    });

    test('a month that starts on a Saturday has no stub first week', () {
      // 1 Aug 2026 is a Saturday.
      expect(rosterWeeksOfMonth('2026-08').first, [
        for (var d = 1; d <= 7; d++) '2026-08-0$d',
      ]);
    });

    test('the default week holds today in the current month, else the '
        'first week', () {
      expect(rosterDefaultWeekIndex('2026-10', DateTime(2026, 10, 12)), 2);
      expect(rosterDefaultWeekIndex('2026-11', DateTime(2026, 10, 12)), 0);
      // A focus inside the month wins over the default; a stale one does not.
      expect(
        rosterVisibleWeekIndex('2026-10', _gapDay, DateTime(2026, 10, 12)),
        3,
      );
      expect(
        rosterVisibleWeekIndex('2026-10', '2026-09-30', DateTime(2026, 10, 12)),
        2,
      );
    });

    test('the arrows step a week, and cross into the neighbouring month', () {
      final today = DateTime(2026, 10, 12);
      // Inside the month.
      expect(
        rosterStepWeek(
          month: '2026-10',
          focus: _oct(5),
          delta: 1,
          today: today,
        ),
        (month: '2026-10', focus: _oct(10)),
      );
      // Back from the first week lands on September's LAST week (Sat 26–30).
      expect(
        rosterStepWeek(
          month: '2026-10',
          focus: _oct(1),
          delta: -1,
          today: today,
        ),
        (month: '2026-09', focus: '2026-09-26'),
      );
      // Forward from the last week lands on November's FIRST week.
      expect(
        rosterStepWeek(
          month: '2026-10',
          focus: _oct(31),
          delta: 1,
          today: today,
        ),
        (month: '2026-11', focus: '2026-11-01'),
      );
      // December → January rolls the year.
      expect(
        rosterStepWeek(
          month: '2026-12',
          focus: '2026-12-31',
          delta: 1,
          today: today,
        ).month,
        '2027-01',
      );
    });

    testWidgets('on screen: week view by default, the title is the range, and '
        'the arrows cross months', (tester) async {
      final container = await _pumpScreen(tester);
      expect(container.read(rosterViewModeProvider), RosterViewMode.week);

      container.read(rosterMonthProvider.notifier).state = '2026-10';
      container.read(rosterWeekFocusProvider.notifier).state = _oct(5);
      await tester.pumpAndSettle();
      expect(find.text('3–9 Oct 2026'), findsOneWidget);
      // Only that week is drawn.
      expect(find.byKey(rosterGridHeaderKey(_oct(5))), findsOneWidget);
      expect(
        find.byKey(rosterGridHeaderKey(_oct(12)), skipOffstage: false),
        findsNothing,
      );

      await tester.tap(find.byKey(rosterPreviousKey));
      await tester.pumpAndSettle();
      expect(container.read(rosterWeekFocusProvider), _oct(1));
      expect(find.text('1–2 Oct 2026'), findsOneWidget);

      await tester.tap(find.byKey(rosterPreviousKey));
      await tester.pumpAndSettle();
      expect(container.read(rosterMonthProvider), '2026-09');
      expect(container.read(rosterWeekFocusProvider), '2026-09-26');
    });

    testWidgets('changing the week, the view or leaving select mode clears '
        'the selection', (tester) async {
      final container = await _pumpScreen(tester);
      container.read(rosterMonthProvider.notifier).state = '2026-10';
      container.read(rosterWeekFocusProvider.notifier).state = _oct(5);
      await tester.pumpAndSettle();

      RosterSelection select() => RosterSelection(
        employee: _alice,
        employeeName: 'Alice Absent',
        dates: {_oct(5)},
      );

      container.read(rosterSelectionProvider.notifier).state = select();
      await tester.pump();
      await tester.tap(find.byKey(rosterNextKey));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider), isNull);

      container.read(rosterSelectionProvider.notifier).state = select();
      await tester.pump();
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider), isNull);
      expect(container.read(rosterViewModeProvider), RosterViewMode.month);

      // The visible toggle enters select mode; turning it off drops the
      // selection with it.
      await tester.tap(find.byKey(rosterSelectDaysKey));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectModeProvider), isTrue);
      container.read(rosterSelectionProvider.notifier).state = select();
      await tester.pump();
      await tester.tap(find.byKey(rosterSelectDaysKey));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectModeProvider), isFalse);
      expect(container.read(rosterSelectionProvider), isNull);
    });
  });

  group('cover-shift default', () {
    test('bulk: the most common shift across the selected dates', () {
      final employee = RosterEmployee.fromJson({
        'employee': _alice,
        'employee_name': 'Alice',
        'days': {
          _oct(5): {'date': _oct(5), 'shift_type': 'Branch Closing'},
          _oct(6): {'date': _oct(6), 'shift_type': 'Branch Opening'},
          _oct(7): {'date': _oct(7), 'shift_type': 'Branch Opening'},
          _oct(8): {'date': _oct(8)},
        },
      });
      expect(
        rosterMostCommonShift(employee, [_oct(5), _oct(6), _oct(7), _oct(8)]),
        'Branch Opening',
      );
      // A tie goes to the earliest date's shift.
      expect(
        rosterMostCommonShift(employee, [_oct(6), _oct(5)]),
        'Branch Closing',
      );
      // Nothing rostered: no default, so the form falls back to asking.
      expect(rosterMostCommonShift(employee, [_oct(8)]), isNull);
      expect(rosterMostCommonShift(null, [_oct(5)]), isNull);
    });

    Future<RosterDayOffChoice?> runForm(
      WidgetTester tester, {
      String? defaultCoverShift,
    }) async {
      final month = _october();
      RosterDayOffChoice? result;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showRosterDayOffForm(
                    context,
                    title: 'Day off',
                    offTypes: rosterDefaultOffTypes,
                    colleagues: [month.employees[1]],
                    catalog: month.shiftCatalog,
                    dates: [_oct(6)],
                    defaultCoverShift: defaultCoverShift,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Pick Bob as the coverer.
      await tester.tap(find.byKey(rosterCoveredByFieldKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob Busy').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(rosterDayOffSaveKey));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('picking a coverer fills the cover shift with the absent '
        'person\'s own shift, tucked under More options', (tester) async {
      final choice = await runForm(tester, defaultCoverShift: 'Branch Closing');
      expect(choice, isNotNull, reason: 'Save was enabled and returned');
      expect(choice!.coveredBy, _bob);
      expect(choice.coverShiftType, 'Branch Closing');
    });

    testWidgets('the cover shift and notes start collapsed', (tester) async {
      final month = _october();
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: RosterDayOffForm(
              title: 'Day off',
              offTypes: rosterDefaultOffTypes,
              colleagues: [month.employees[1]],
              catalog: month.shiftCatalog,
              dates: [_oct(6)],
              defaultCoverShift: 'Branch Closing',
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(rosterCoveredByFieldKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob Busy').last);
      await tester.pumpAndSettle();

      expect(find.byKey(rosterMoreOptionsKey), findsOneWidget);
      expect(find.text('Cover shift: Branch Closing'), findsOneWidget);
      expect(find.byKey(rosterCoverShiftFieldKey), findsNothing);
      await tester.tap(find.byKey(rosterMoreOptionsKey));
      await tester.pumpAndSettle();
      expect(find.byKey(rosterCoverShiftFieldKey), findsOneWidget);
    });

    testWidgets('with no default, the cover shift is asked for up front and '
        'Save waits for it', (tester) async {
      final choice = await runForm(tester);
      // Save was disabled, so the tap did nothing and the form is still open.
      expect(choice, isNull);
      expect(find.byKey(rosterCoverShiftFieldKey), findsOneWidget);
    });
  });

  group('the gap banner', () {
    testWidgets('Fix lists the gaps, and picking one opens that person\'s day '
        'sheet in that day\'s week', (tester) async {
      final container = await _pumpScreen(tester);
      container.read(rosterMonthProvider.notifier).state = '2026-10';
      container.read(rosterWeekFocusProvider.notifier).state = _oct(5);
      await tester.pumpAndSettle();
      expect(
        find.byKey(rosterGridHeaderKey(_gapDay), skipOffstage: false),
        findsNothing,
      );

      await tester.tap(find.byKey(rosterUncoveredBannerKey));
      await tester.pumpAndSettle();
      final tile = find.byKey(rosterGapTileKey(_alice, _gapDay));
      expect(tile, findsOneWidget);
      expect(
        find.descendant(of: tile, matching: find.text('Alice Absent')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tile, matching: find.textContaining('Vacation')),
        findsOneWidget,
      );

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(container.read(rosterWeekFocusProvider), _gapDay);
      expect(find.byKey(rosterGridHeaderKey(_gapDay)), findsOneWidget);
      final sheet = tester.widget<RosterDaySheet>(find.byType(RosterDaySheet));
      expect(sheet.employee.employee, _alice);
      expect(sheet.date, _gapDay);
    });
  });
}
