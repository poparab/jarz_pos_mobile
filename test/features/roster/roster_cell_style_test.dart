import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_cell_style.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_formats.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_legend.dart';

/// The roster grid's whole claim is that it explains itself: colour means
/// "needs fixing" and nothing else, every other cell says what it is in words,
/// and the legend describes every cell the grid can draw. These are the tests
/// that make those properties hold.

RosterShift _shift(
  String name, {
  String start = '09:00:00',
  String end = '18:00:00',
  double hours = 9,
}) => RosterShift(
  shiftType: name,
  startTime: start,
  endTime: end,
  hours: hours,
);

RosterEmployee _employee({double standardHours = 9}) => RosterEmployee(
  employee: 'HR-EMP-00001',
  employeeName: 'Mona Adel',
  standardHours: standardHours,
  days: const {},
);

Future<RosterStyleResolver> _resolver(
  WidgetTester tester, {
  List<RosterShift> catalog = const [],
  DateTime? today,
  Locale locale = const Locale('en'),
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return RosterStyleResolver.of(
    captured,
    catalog: RosterShiftCatalog(catalog),
    today: today,
  );
}

String _en(String raw) =>
    rosterClockShort(raw, localeName: 'en', am: 'a', pm: 'p')!;

void main() {
  group('rosterClockShort', () {
    test('drops :00, keeps real minutes, 12-hour with a/p', () {
      expect(_en('09:00:00'), '9a');
      expect(_en('12:30:00'), '12:30p');
      expect(_en('00:00:00'), '12a');
      expect(_en('13:00:00'), '1p');
      expect(_en('12:00'), '12p');
      expect(_en('23:45:00'), '11:45p');
      expect(_en('00:05:00'), '12:05a');
      // Frappe can send 24:00:00 for a midnight end.
      expect(_en('24:00:00'), '12a');
    });

    test('anything that is not a time is null, not junk', () {
      for (final bad in ['', '9', 'abc', 'x:y', '25:00', '10:75']) {
        expect(
          rosterClockShort(bad, localeName: 'en', am: 'a', pm: 'p'),
          isNull,
          reason: bad,
        );
      }
    });
  });

  group('rosterShiftTimeText', () {
    testWidgets('English: start–end in the week, start alone in the month', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final l10n = resolver.l10n;

      final day = _shift('Day');
      final late = _shift('Late', start: '12:30:00', end: '01:00:00');
      expect(rosterShiftTimeText(day, l10n, withEnd: true), '9a\u20136p');
      expect(rosterShiftTimeText(day, l10n, withEnd: false), '9a');
      expect(rosterShiftTimeText(late, l10n, withEnd: true), '12:30p\u20131a');
      expect(rosterShiftTimeText(late, l10n, withEnd: false), '12:30p');
      // An en dash, never an arrow: an arrow points the wrong way in Arabic.
      expect(rosterShiftTimeText(day, l10n, withEnd: true), isNot(contains('→')));
    });

    testWidgets('Arabic: ص/م suffixes, in the same digits as every other '
        'number on the roster', (tester) async {
      final resolver = await _resolver(tester, locale: const Locale('ar'));
      final l10n = resolver.l10n;
      expect(l10n.rosterTimeAmShort, 'ص');
      expect(l10n.rosterTimePmShort, 'م');

      String n(num v) => rosterNumberIn('ar', v);
      final day = _shift('Day');
      final late = _shift('Late', start: '12:30:00', end: '01:00:00');
      expect(
        rosterShiftTimeText(day, l10n, withEnd: true),
        '${n(9)}ص\u2013${n(6)}م',
      );
      expect(rosterShiftTimeText(day, l10n, withEnd: false), '${n(9)}ص');
      expect(
        rosterShiftTimeText(late, l10n, withEnd: true),
        '${n(12)}:${n(3)}${n(0)}م\u2013${n(1)}ص',
      );
    });

    testWidgets('a missing end time still shows the start; a missing start '
        'shows nothing', (tester) async {
      final resolver = await _resolver(tester);
      final l10n = resolver.l10n;
      expect(
        rosterShiftTimeText(_shift('X', end: ''), l10n, withEnd: true),
        '9a',
      );
      expect(
        rosterShiftTimeText(_shift('X', start: ''), l10n, withEnd: true),
        isNull,
      );
    });
  });

  group('RosterStyleResolver states', () {
    testWidgets('every state has its own (glyph, word) pair and a label', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final styles = [
        for (final state in RosterCellState.values) resolver.styleFor(state),
      ];

      // Colour is not a channel any more except for the two problems, so the
      // form channel alone must tell every state apart.
      expect(
        styles.map((s) => '${s.icon?.codePoint}|${s.token}').toSet().length,
        RosterCellState.values.length,
        reason: 'two states share a glyph and a word',
      );
      for (final style in styles) {
        if (style.state != RosterCellState.working) {
          expect(style.token, isNotEmpty, reason: '${style.state} says nothing');
        }
        expect(style.label.trim(), isNotEmpty, reason: '${style.state}');
      }
    });

    testWidgets('a working cell has no shift colour fill, and writes the time', (
      tester,
    ) async {
      final resolver = await _resolver(
        tester,
        catalog: [_shift('Branch Opening'), _shift('Branch Closing',
            start: '15:00:00', end: '23:30:00')],
      );

      final opening = resolver.styleFor(
        RosterCellState.working,
        shiftType: 'Branch Opening',
        hours: 9,
      );
      final closing = resolver.styleFor(
        RosterCellState.working,
        shiftType: 'Branch Closing',
        hours: 8.5,
      );
      // Two different shifts, one look: the difference is written, not filled.
      for (final style in [opening, closing]) {
        expect(style.background.a, 0, reason: 'working cell is filled');
        expect(style.background, RosterColors.emptyFill);
        expect(style.borderColor, RosterColors.emptyLine);
        expect(style.foreground, RosterColors.markerInk);
        expect(style.isProblem, isFalse);
      }
      expect(opening.token, '9a\u20136p');
      expect(closing.token, '3p\u201311:30p');
      expect(
        resolver
            .styleFor(
              RosterCellState.working,
              shiftType: 'Branch Closing',
              withEnd: false,
            )
            .token,
        '3p',
      );
    });

    testWidgets('a shift type missing from the catalog falls back to hours', (
      tester,
    ) async {
      final resolver = await _resolver(tester, catalog: [_shift('Known')]);
      expect(
        resolver
            .styleFor(
              RosterCellState.working,
              shiftType: 'Retired Split',
              hours: 12.5,
            )
            .token,
        '12.5',
      );
      expect(
        resolver.styleFor(RosterCellState.working, shiftType: 'Retired').token,
        '',
      );
    });

    testWidgets('only offUncovered and unrosteredFuture have coloured fills', (
      tester,
    ) async {
      final resolver = await _resolver(tester, catalog: [_shift('Day')]);
      for (final state in RosterCellState.values) {
        final style = resolver.styleFor(state, shiftType: 'Day');
        final filled = style.background.a > 0;
        expect(
          filled,
          RosterStyleResolver.problemStates.contains(state),
          reason: '$state',
        );
        expect(style.isProblem, filled, reason: '$state');
      }
      expect(RosterStyleResolver.problemStates, {
        RosterCellState.offUncovered,
        RosterCellState.unrosteredFuture,
      });
    });

    testWidgets('a future day nobody set says "Not set", not "?"', (
      tester,
    ) async {
      final en = await _resolver(tester);
      expect(en.styleFor(RosterCellState.unrosteredFuture).token, 'Not set');
      final ar = await _resolver(tester, locale: const Locale('ar'));
      expect(ar.styleFor(RosterCellState.unrosteredFuture).token, 'غير محدد');
    });

    testWidgets('an unrostered day is past history or a future problem', (
      tester,
    ) async {
      final resolver = await _resolver(tester, today: DateTime(2026, 9, 12));

      expect(
        resolver.stateFor(cell: null, date: '2026-09-11'),
        RosterCellState.unrosteredPast,
      );
      // Today is never "past": today is the day an empty cell turns somebody
      // away at the door.
      expect(
        resolver.stateFor(cell: null, date: '2026-09-12'),
        RosterCellState.unrosteredFuture,
      );
      expect(
        resolver.stateFor(cell: null, date: '2026-09-13'),
        RosterCellState.unrosteredFuture,
      );
    });

    testWidgets('off, covered off, holiday and working each resolve', (
      tester,
    ) async {
      final resolver = await _resolver(tester, today: DateTime(2026, 9, 12));

      RosterCell cell(Map<String, dynamic> json) =>
          RosterCell.fromJson({'date': '2026-09-20', ...json});

      expect(
        resolver.stateFor(
          cell: cell({'shift_type': 'Branch Opening', 'hours': 9}),
          date: '2026-09-20',
        ),
        RosterCellState.working,
      );
      expect(
        resolver.stateFor(
          cell: cell({
            'day_off': {'off_type': 'Weekly Off', 'covered_by': 'HR-EMP-2'},
          }),
          date: '2026-09-20',
        ),
        RosterCellState.offCovered,
      );
      expect(
        resolver.stateFor(
          cell: cell({
            'day_off': {'off_type': 'Weekly Off'},
          }),
          date: '2026-09-20',
        ),
        RosterCellState.offUncovered,
      );
      expect(
        resolver.stateFor(cell: cell({'is_holiday': true}), date: '2026-09-20'),
        RosterCellState.holiday,
      );
      // A holiday that is also worked is a working day with a marker, not a
      // holiday cell — the hours are what payroll argues about.
      expect(
        resolver.stateFor(
          cell: cell({
            'is_holiday': true,
            'shift_type': 'Branch Opening',
            'hours': 9,
          }),
          date: '2026-09-20',
        ),
        RosterCellState.working,
      );
    });

    testWidgets('an uncovered day off is heavier than a covered one', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final covered = resolver.styleFor(RosterCellState.offCovered);
      final uncovered = resolver.styleFor(RosterCellState.offUncovered);

      expect(uncovered.background, RosterColors.riskFill);
      expect(uncovered.icon, Icons.warning_amber_rounded);
      expect(uncovered.borderWidth, greaterThan(covered.borderWidth));
      // A covered day off is handled: muted words, no fill.
      expect(covered.background, RosterColors.emptyFill);
      expect(covered.foreground, RosterColors.emptyInk);
      expect(covered.token, uncovered.token);
    });

    testWidgets('red means exactly one thing, and amber another', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final reds = RosterCellState.values
          .map(resolver.styleFor)
          .where((s) => s.background == RosterColors.attentionFill)
          .map((s) => s.state)
          .toList();
      final ambers = RosterCellState.values
          .map(resolver.styleFor)
          .where((s) => s.background == RosterColors.riskFill)
          .map((s) => s.state)
          .toList();

      expect(reds, [RosterCellState.unrosteredFuture]);
      expect(ambers, [RosterCellState.offUncovered]);
    });
  });

  group('RosterStyleResolver markers', () {
    testWidgets('over the normal day, covering, and holiday working', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final employee = _employee(standardHours: 9);

      final long = RosterCell.fromJson({
        'date': '2026-09-20',
        'shift_type': 'Branch Cover Full Day',
        'hours': 12.5,
        'is_holiday': true,
      });
      final markers = resolver.markersFor(
        cell: long,
        employee: employee,
        isCover: true,
      );

      expect(
        markers,
        containsAll(<RosterCellMarker>{
          RosterCellMarker.overtime,
          RosterCellMarker.cover,
          RosterCellMarker.holidayWorked,
        }),
      );
      expect(markers.contains(RosterCellMarker.selected), isFalse);
    });

    testWidgets('an exactly-normal day is not overtime', (tester) async {
      final resolver = await _resolver(tester);
      final cell = RosterCell.fromJson({
        'date': '2026-09-20',
        'shift_type': 'Branch Opening',
        'hours': 9,
      });

      expect(
        resolver.isOvertime(cell: cell, employee: _employee(standardHours: 9)),
        isFalse,
      );
      // Nobody set a baseline: inventing one would mark every shift as
      // overtime.
      expect(
        resolver.isOvertime(cell: cell, employee: _employee(standardHours: 0)),
        isFalse,
      );
    });

    testWidgets('markers are told apart by glyph, not by colour', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final styles = RosterCellMarker.values.map(resolver.markerStyle).toList();

      expect(
        styles.map((s) => s.icon.codePoint).toSet().length,
        RosterCellMarker.values.length,
      );
      for (final style in styles) {
        expect(style.label.trim(), isNotEmpty, reason: '${style.marker}');
      }
    });
  });

  group('the legend and the grid cannot drift apart', () {
    testWidgets('legend entries are the two problems first, then the text '
        'states, then the markers the grid draws', (tester) async {
      // Cover and holiday-worked are still markers (the day sheet and the
      // Semantics label use them), but the plain grid cell does not draw
      // them, so the legend must not explain them either.
      final resolver = await _resolver(tester);
      final entries = resolver.legendEntries();

      expect(
        entries.length,
        RosterCellState.values.length + RosterStyleResolver.gridMarkers.length,
      );
      expect(entries.take(2).map((e) => e.state), [
        RosterCellState.offUncovered,
        RosterCellState.unrosteredFuture,
      ]);
      expect(entries.take(2).every((e) => e.isProblem), isTrue);
      expect(
        entries.skip(2).where((e) => e.state != null).every((e) => !e.isProblem),
        isTrue,
      );
      expect(
        entries.where((e) => e.state != null).map((e) => e.state).toSet(),
        RosterCellState.values.toSet(),
      );
      expect(
        entries.where((e) => e.marker != null).map((e) => e.marker).toSet(),
        RosterStyleResolver.gridMarkers.toSet(),
      );
      expect(
        RosterStyleResolver.gridMarkers,
        isNot(contains(RosterCellMarker.cover)),
      );
      expect(
        RosterStyleResolver.gridMarkers,
        isNot(contains(RosterCellMarker.holidayWorked)),
      );
      // Nothing in the legend that is neither.
      expect(
        entries.every((e) => (e.state == null) != (e.marker == null)),
        isTrue,
      );
    });

    testWidgets('every legend swatch is the style the cell would draw', (
      tester,
    ) async {
      final resolver = await _resolver(tester, catalog: [_shift('Day')]);

      for (final entry in resolver.legendEntries()) {
        if (entry.state == null) continue;
        final style = resolver.styleFor(entry.state!);
        expect(entry.background, style.background, reason: '${entry.state}');
        expect(entry.foreground, style.foreground, reason: '${entry.state}');
        expect(entry.icon, style.icon, reason: '${entry.state}');
        expect(entry.token, style.token, reason: '${entry.state}');
        expect(entry.label, style.label, reason: '${entry.state}');
      }
    });

    testWidgets('the rendered legend shows every state and marker, and no '
        'per-shift colour strip', (tester) async {
      late List<RosterLegendEntry> entries;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                entries = RosterStyleResolver.of(context).legendEntries();
                return const RosterLegend();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      for (final entry in entries) {
        expect(
          find.text(entry.label),
          findsOneWidget,
          reason: 'legend is missing "${entry.label}"',
        );
      }
      expect(find.text('Needs fixing'), findsOneWidget);
      expect(find.text('Written in the cell'), findsOneWidget);
      // The working sample is written the way a week cell writes it.
      expect(find.text('9a\u20136p'), findsOneWidget);
      expect(find.text('Not set'), findsOneWidget);
      // The problems section comes before the text section.
      expect(
        tester.getTopLeft(find.text('Needs fixing')).dy,
        lessThan(tester.getTopLeft(find.text('Written in the cell')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('the calendar itself', () {
    test('the weekend is Friday AND Saturday', () {
      // 2026-09-11 is a Friday.
      expect(isRosterWeekend(DateTime(2026, 9, 11)), isTrue);
      expect(isRosterWeekend(DateTime(2026, 9, 12)), isTrue);
      expect(isRosterWeekend(DateTime(2026, 9, 13)), isFalse);
      expect(isRosterWeekend(DateTime(2026, 9, 10)), isFalse);
    });

    test('cover days are read off the colleague whose day it was', () {
      final month = RosterMonth.fromJson({
        'month': '2026-09',
        'employees': [
          {
            'employee': 'HR-EMP-00001',
            'employee_name': 'Mona Adel',
            'days': {
              '2026-09-20': {
                'date': '2026-09-20',
                'day_off': {
                  'off_type': 'Weekly Off',
                  'covered_by': 'HR-EMP-00002',
                  'covered_by_name': 'Ahmed Samir',
                },
              },
            },
          },
          {
            'employee': 'HR-EMP-00002',
            'employee_name': 'Ahmed Samir',
            'days': {
              '2026-09-20': {
                'date': '2026-09-20',
                'shift_type': 'Branch Cover Full Day',
                'hours': 12.5,
              },
            },
          },
        ],
      });

      final index = RosterCoverIndex.fromMonth(month);
      expect(index.isCoverDay('HR-EMP-00002', '2026-09-20'), isTrue);
      expect(index.coveredColleague('HR-EMP-00002', '2026-09-20'), 'Mona Adel');
      // The person who is off is not covering anybody.
      expect(index.isCoverDay('HR-EMP-00001', '2026-09-20'), isFalse);
      expect(index.isCoverDay('HR-EMP-00002', '2026-09-21'), isFalse);
    });
  });
}
