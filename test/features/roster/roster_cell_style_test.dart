import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_cell_style.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_shift_palette.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_legend.dart';

/// The roster grid's whole claim is that it explains itself: the legend
/// describes every cell the grid can draw, no two states look alike in both
/// channels at once, and a colour somebody chose in Desk beats one the app
/// invented. These are the tests that make those properties hold, because all
/// three of them had already quietly stopped being true.

RosterShift _shift(String name, {String? color, double hours = 9}) =>
    RosterShift(
      shiftType: name,
      startTime: '09:00:00',
      endTime: '18:00:00',
      hours: hours,
      color: color,
    );

RosterEmployee _employee({double standardHours = 9}) => RosterEmployee(
  employee: 'HR-EMP-00001',
  employeeName: 'Mona Adel',
  standardHours: standardHours,
  days: const {},
);

Future<RosterStyleResolver> _resolver(
  WidgetTester tester, {
  RosterShiftPalette? palette,
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
    palette: palette ?? RosterShiftPalette.from(catalog: const []),
    today: today,
  );
}

void main() {
  group('RosterShiftPalette', () {
    test('a colour configured in Desk beats the fallback palette', () {
      final palette = RosterShiftPalette.from(
        catalog: [
          _shift('Branch Opening', color: '#112233'),
          _shift('Branch Closing'),
        ],
      );

      final configured = palette.styleFor('Branch Opening');
      expect(configured.color, const Color(0xFF112233));
      expect(configured.fromBackend, isTrue);

      final fallback = palette.styleFor('Branch Closing');
      expect(fallback.fromBackend, isFalse);
      expect(
        RosterShiftPalette.fallbackPalette.contains(fallback.color),
        isTrue,
      );
    });

    test('#RGB and #AARRGGBB are both honoured', () {
      expect(RosterShiftPalette.parseHexColor('#0F0'), const Color(0xFF00FF00));
      expect(
        RosterShiftPalette.parseHexColor('80112233'),
        const Color(0x80112233),
      );
    });

    test('a malformed hex degrades to the palette instead of throwing', () {
      for (final bad in <String?>[
        null,
        '',
        '   ',
        '#ZZZZZZ',
        'not a colour',
        '#12345',
        '#',
      ]) {
        expect(RosterShiftPalette.parseHexColor(bad), isNull, reason: '$bad');
      }

      late RosterShiftPalette palette;
      expect(
        () => palette = RosterShiftPalette.from(
          catalog: [_shift('Branch Opening', color: '#ZZZZZZ')],
        ),
        returnsNormally,
      );
      final style = palette.styleFor('Branch Opening');
      expect(style.fromBackend, isFalse);
      expect(RosterShiftPalette.fallbackPalette.contains(style.color), isTrue);
    });

    test('no two shift types in a month share a colour or a code', () {
      // Deliberately more shift types than there are palette entries, and with
      // repeated initials: the old `name.hashCode % 8` could not see either
      // problem, so two 12h shifts could land on the same pastel and become
      // identical in both channels at once.
      final names = <String>[
        'Branch Opening',
        'Branch Closing',
        'Branch Cover Full Day',
        'Bakery Night',
        'Courier Morning',
        'Courier Evening',
        'Deliveries',
        'Evening Split',
        'Factory Day',
        'Factory Night',
        'Gardens Mid',
        'Head Office',
        'وردية صباحية',
      ];
      final palette = RosterShiftPalette.from(
        catalog: [for (final name in names) _shift(name)],
      );

      expect(palette.entries.length, names.length);
      expect(
        palette.entries.map((e) => e.color.toARGB32()).toSet().length,
        names.length,
      );
      expect(palette.entries.map((e) => e.code).toSet().length, names.length);
    });

    test('a configured colour is not handed out again as a fallback', () {
      final taken = RosterShiftPalette.fallbackPalette.first;
      final palette = RosterShiftPalette.from(
        catalog: [
          _shift(
            'Aaa Configured',
            color:
                '#${taken.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
          ),
          _shift('Bbb Fallback'),
        ],
      );

      expect(palette.styleFor('Aaa Configured').color, taken);
      expect(palette.styleFor('Bbb Fallback').color, isNot(taken));
    });

    test('the same shift keeps its colour whatever order it arrives in', () {
      final a = RosterShiftPalette.from(
        catalog: [_shift('Alpha'), _shift('Beta'), _shift('Gamma')],
      );
      final b = RosterShiftPalette.from(
        catalog: [_shift('Gamma'), _shift('Alpha'), _shift('Beta')],
      );
      for (final name in ['Alpha', 'Beta', 'Gamma']) {
        expect(a.styleFor(name).color, b.styleFor(name).color, reason: name);
        expect(a.styleFor(name).code, b.styleFor(name).code, reason: name);
      }
    });

    test('a shift type only the cells know about still gets a style', () {
      // Retired in Desk, still sitting on days already worked.
      final month = RosterMonth.fromJson({
        'month': '2026-09',
        'shift_catalog': [
          {'shift_type': 'Branch Opening', 'hours': 9},
        ],
        'employees': [
          {
            'employee': 'HR-EMP-00001',
            'employee_name': 'Mona Adel',
            'days': {
              '2026-09-01': {
                'date': '2026-09-01',
                'shift_type': 'Retired Split',
                'hours': 6,
              },
            },
          },
        ],
      });
      final palette = RosterShiftPalette.fromMonth(month);

      expect(palette.entries.map((e) => e.shiftType), [
        'Branch Opening',
        'Retired Split',
      ]);
      expect(
        palette.styleFor('Retired Split').color,
        isNot(palette.styleFor('Branch Opening').color),
      );
    });

    test('ink is picked for contrast, not assumed', () {
      expect(
        RosterShiftPalette.readableOn(const Color(0xFF1B1B1B)),
        const Color(0xFFFFFFFF),
      );
      expect(
        RosterShiftPalette.readableOn(const Color(0xFFFFF9C4)),
        const Color(0xFF1B1B1B),
      );
    });
  });

  group('RosterStyleResolver states', () {
    testWidgets('every state maps to its own (colour, glyph) pair', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final styles = [
        for (final state in RosterCellState.values) resolver.styleFor(state),
      ];

      // Colour-blindness, glare and cheap screens: no two states may be
      // separated by hue alone, and none may be separated by form alone.
      expect(
        styles.map((s) => s.background.toARGB32()).toSet().length,
        RosterCellState.values.length,
        reason: 'two states share a fill',
      );
      expect(
        styles.map((s) => '${s.icon?.codePoint}|${s.token}').toSet().length,
        RosterCellState.values.length,
        reason: 'two states share a glyph and a token',
      );
      for (final style in styles) {
        // The working cell's form channel is the hours it prints and the shift
        // code in its corner, which is why it is the one state with neither a
        // glyph nor a fixed token.
        if (style.state != RosterCellState.working) {
          expect(
            style.icon != null || style.token.isNotEmpty,
            isTrue,
            reason: '${style.state} is colour-only',
          );
        }
        expect(style.label.trim(), isNotEmpty, reason: '${style.state}');
      }
    });

    testWidgets('the working cell takes the shift type\'s own colour', (
      tester,
    ) async {
      final palette = RosterShiftPalette.from(
        catalog: [_shift('Branch Opening', color: '#445566')],
      );
      final resolver = await _resolver(tester, palette: palette);

      final style = resolver.styleFor(
        RosterCellState.working,
        shiftType: 'Branch Opening',
      );
      expect(style.background, const Color(0xFF445566));
      expect(style.shiftCode, 'B');
      expect(style.foreground, RosterShiftPalette.readableOn(style.background));
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

      RosterCell cell(Map<String, dynamic> json) => RosterCell.fromJson({
        'date': '2026-09-20',
        ...json,
      });

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
        resolver.stateFor(
          cell: cell({'is_holiday': true}),
          date: '2026-09-20',
        ),
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
      expect(covered.icon, Icons.check_circle);
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

      expect(markers, containsAll(<RosterCellMarker>{
        RosterCellMarker.overtime,
        RosterCellMarker.cover,
        RosterCellMarker.holidayWorked,
      }));
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
    testWidgets('legend entries are exactly the resolver\'s states + markers', (
      tester,
    ) async {
      final resolver = await _resolver(tester);
      final entries = resolver.legendEntries();

      expect(
        entries.length,
        RosterCellState.values.length + RosterCellMarker.values.length,
      );
      expect(
        entries.where((e) => e.state != null).map((e) => e.state).toSet(),
        RosterCellState.values.toSet(),
      );
      expect(
        entries.where((e) => e.marker != null).map((e) => e.marker).toSet(),
        RosterCellMarker.values.toSet(),
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
      final palette = RosterShiftPalette.from(
        catalog: [_shift('Branch Opening', color: '#445566')],
      );
      final resolver = await _resolver(tester, palette: palette);

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

    testWidgets('the rendered legend shows every state, marker and shift', (
      tester,
    ) async {
      final palette = RosterShiftPalette.from(
        catalog: [_shift('Branch Opening'), _shift('Branch Closing')],
      );

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
                entries = RosterStyleResolver.of(
                  context,
                  palette: palette,
                ).legendEntries();
                return RosterLegend(palette: palette);
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
      expect(find.text('Branch Opening'), findsOneWidget);
      expect(find.text('Branch Closing'), findsOneWidget);
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
