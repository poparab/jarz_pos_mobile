import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_shift_palette.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_day_sheet.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_legend.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

/// One day cell, up close: what it draws (one thing), and what a
/// tap or long-press on it does.
///
/// The alignment test (`roster_grid_alignment_test.dart`) proves where each
/// cell lands. It says nothing about what happens INSIDE a cell, or about the
/// tap target — and the day cell was restructured to fix that alignment
/// (`SizedBox > InkWell > Padding > Container`), which is exactly the kind of
/// change that silently shrinks a tap area or crowds its content.
const _employee = 'HR-EMP-00001';
const _other = 'HR-EMP-00002';
const _plainDay = '2026-10-05';
const _crowdedDay = '2026-10-06';
const _nextDay = '2026-10-07';

/// The crowded day is a cover day on a public holiday with overtime: the case
/// that used to pack a code chip, a branch token and three marker glyphs into
/// one cell. It must now draw just the hours and the overtime dot.
RosterMonth _month({String location = 'Nasr City'}) {
  Map<String, dynamic> working(String date, {bool crowded = false}) => {
    'date': date,
    'shift_type': 'Branch Opening',
    'shift_location': location,
    'hours': crowded ? 12 : 9,
    if (crowded) 'is_holiday': 1,
    if (crowded) 'is_cover': 1,
  };

  Map<String, dynamic> employee(String id, String name) => {
    'employee': id,
    'employee_name': name,
    'standard_hours': 9,
    'shift_locations': ['Nasr City'],
    'days': {
      _plainDay: working(_plainDay),
      _crowdedDay: working(_crowdedDay, crowded: true),
      _nextDay: working(_nextDay),
    },
  };

  return RosterMonth.fromJson({
    'hrms_available': true,
    'month': '2026-10',
    'month_start': '2026-10-01',
    'month_end': '2026-10-31',
    'employees': [
      employee(_employee, 'First Employee'),
      employee(_other, 'Second Employee'),
    ],
    'shift_catalog': [
      {
        'shift_type': 'Branch Opening',
        'start_time': '09:00:00',
        'end_time': '21:00:00',
        'hours': 9,
      },
    ],
    'scope': {'configured': true, 'unrestricted': true},
  });
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  RosterMonth? month,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  final grid = month ?? _month();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RosterGrid(
            month: grid,
            palette: RosterShiftPalette.fromMonth(grid),
            coverIndex: RosterCoverIndex.fromMonth(grid),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _cell(String employee, String date) =>
    find.byKey(rosterGridCellKey(employee, date));

Finder _in(Finder cell, Finder matching) =>
    find.descendant(of: cell, matching: matching);

void main() {
  group('a cell draws one thing', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      final dir = locale.languageCode == 'ar' ? 'RTL' : 'LTR';

      testWidgets('$dir: a crowded working day shows only its hours and the '
          'overtime dot, inside the cell', (tester) async {
        await _pump(tester, locale: locale);
        final grid = _month();
        final code = RosterShiftPalette.fromMonth(
          grid,
        ).styleFor('Branch Opening').code;

        final cell = _cell(_employee, _crowdedDay);
        final cellRect = tester.getRect(cell);

        // Cover + holiday worked + overtime used to draw a code chip, a
        // branch token and three marker glyphs. Now: one number, one dot.
        final texts = tester
            .widgetList<Text>(_in(cell, find.byType(Text)))
            .map((t) => t.data)
            .toList();
        expect(texts, hasLength(1), reason: 'drawn texts: $texts');
        expect(texts.single, isNot('NC'));
        expect(texts.single, isNot(code));
        expect(_in(cell, find.text('NC')), findsNothing);
        expect(_in(cell, find.text(code)), findsNothing);

        final dot = _in(cell, find.byType(RosterOvertimeDot));
        expect(dot, findsOneWidget, reason: '12h against a 9h standard day');
        final dotRect = tester.getRect(dot);
        final hoursRect = tester.getRect(_in(cell, find.byType(Text)));
        for (final rect in [dotRect, hoursRect]) {
          expect(
            cellRect.inflate(0.5).contains(rect.topLeft) &&
                cellRect.inflate(0.5).contains(rect.bottomRight),
            isTrue,
            reason: '$rect escapes the cell $cellRect',
          );
        }
        // The dot comes AFTER the hours in reading order.
        final isRtl = locale.languageCode == 'ar';
        expect(
          isRtl
              ? dotRect.center.dx < hoursRect.center.dx
              : dotRect.center.dx > hoursRect.center.dx,
          isTrue,
        );
      });
    }

    testWidgets('a plain working day has no overtime dot', (tester) async {
      await _pump(tester);
      final cell = _cell(_employee, _plainDay);
      expect(_in(cell, find.text('9')), findsOneWidget);
      expect(_in(cell, find.byType(RosterOvertimeDot)), findsNothing);
    });

    testWidgets('the Semantics label still says everything the cell no longer '
        'draws', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      final label = tester
          .getSemantics(_cell(_employee, _crowdedDay))
          .getSemanticsData()
          .label;
      expect(label, contains('Branch Opening'));
      expect(label, contains('Nasr City'));
      handle.dispose();
    });
  });

  group('a branch name with no letters in it', () {
    testWidgets('renders its cells instead of throwing', (tester) async {
      // A Shift Location named "-" (or " / ") used to throw a StateError from
      // branchToken inside the day cell's build. The cell no longer draws a
      // branch token at all; this guards the regression anyway.
      await _pump(tester, month: _month(location: ' - / '));

      expect(tester.takeException(), isNull);
      expect(_cell(_employee, _crowdedDay), findsOneWidget);
      expect(_in(_cell(_employee, _crowdedDay), find.text('')), findsNothing);
    });
  });

  group('tapping and long-pressing a cell', () {
    testWidgets('outside select mode a tap opens the day sheet and selects '
        'nothing', (tester) async {
      final container = await _pump(tester);

      await tester.tap(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();

      expect(find.byType(RosterDaySheet), findsOneWidget);
      expect(container.read(rosterSelectionProvider), isNull);
      expect(container.read(rosterSelectModeProvider), isFalse);
    });

    testWidgets('a long-press enters select mode and selects that person and '
        'day', (tester) async {
      final container = await _pump(tester);

      await tester.longPress(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();

      expect(container.read(rosterSelectModeProvider), isTrue);
      final selection = container.read(rosterSelectionProvider);
      expect(selection, isNotNull);
      expect(selection!.employee, _employee);
      expect(selection.dates, {_plainDay});
      expect(find.byType(RosterDaySheet), findsNothing);
    });

    testWidgets('in select mode a tap adds a day, a second tap removes it, and '
        'removing the last day leaves nothing selected', (tester) async {
      final container = await _pump(tester);
      container.read(rosterSelectModeProvider.notifier).state = true;
      await tester.pump();

      await tester.tap(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider)!.dates, {_plainDay});

      await tester.tap(_cell(_employee, _nextDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider)!.dates, {
        _plainDay,
        _nextDay,
      });

      await tester.tap(_cell(_employee, _nextDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider)!.dates, {_plainDay});

      await tester.tap(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider), isNull);
      // Still in select mode: emptying the selection is not leaving it.
      expect(container.read(rosterSelectModeProvider), isTrue);
      expect(find.byType(RosterDaySheet), findsNothing);
    });

    testWidgets('in select mode, tapping another person starts a new '
        'selection for them', (tester) async {
      final container = await _pump(tester);

      await tester.longPress(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();
      await tester.tap(_cell(_other, _nextDay));
      await tester.pumpAndSettle();

      final selection = container.read(rosterSelectionProvider)!;
      expect(selection.employee, _other);
      expect(selection.dates, {_nextDay});
    });

    testWidgets('long-pressing another person moves the selection to them', (
      tester,
    ) async {
      final container = await _pump(tester);

      await tester.longPress(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();
      await tester.longPress(_cell(_other, _nextDay));
      await tester.pumpAndSettle();

      final selection = container.read(rosterSelectionProvider)!;
      expect(selection.employee, _other);
      expect(selection.dates, {_nextDay});
    });

    for (final corner in const ['top-left', 'bottom-right']) {
      testWidgets('the whole slot is the tap target, including the $corner '
          'edge inside the 1px gap', (tester) async {
        // The visible box is inset 1px from the slot; the InkWell sits
        // OUTSIDE that padding. Pressing 0.5px from the slot's edge lands in
        // the gap, outside the coloured box, and must still count. If the
        // InkWell ever moves inside the padding, this is what breaks.
        final container = await _pump(tester);

        final rect = tester.getRect(_cell(_other, _plainDay));
        final point = corner == 'top-left'
            ? rect.topLeft + const Offset(0.5, 0.5)
            : rect.bottomRight - const Offset(0.5, 0.5);

        await tester.longPressAt(point);
        await tester.pumpAndSettle();

        final selection = container.read(rosterSelectionProvider);
        expect(selection, isNotNull, reason: 'a press at $point was ignored');
        expect(selection!.employee, _other);
        expect(selection.dates, {_plainDay});
      });
    }
  });
}
