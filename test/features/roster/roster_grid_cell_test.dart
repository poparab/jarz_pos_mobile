import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_shift_palette.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

/// One day cell, up close: what it draws in its bottom corners, and what a
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

/// The worst case for the bottom corners: a working day that is a cover day
/// on a public holiday with overtime. That is the maximum of three corner
/// markers, and it is a working day, so the branch token is drawn as well.
RosterMonth _month() {
  Map<String, dynamic> working(String date, {bool crowded = false}) => {
    'date': date,
    'shift_type': 'Branch Opening',
    'shift_location': 'Nasr City',
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
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  final month = _month();

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
            month: month,
            palette: RosterShiftPalette.fromMonth(month),
            coverIndex: RosterCoverIndex.fromMonth(month),
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

/// The corner marker glyphs. The widget is private to the screen, so it is
/// matched by name rather than by type.
Finder _markers(Finder cell) => _in(
  cell,
  find.byWidgetPredicate((w) => w.runtimeType.toString() == '_MarkerGlyph'),
);

void main() {
  group('bottom corners of a crowded cell', () {
    // Asserted at the default text scale only. At 1.5x and above the grid's
    // pinned NAME cells and DATE header cells overflow their fixed heights
    // (a pre-existing bug, not the day cell's), so a whole-grid pump at that
    // scale fails on those before this test could say anything about the
    // corners. The day cell itself does not overflow at 2x.
    for (final locale in const [Locale('en'), Locale('ar')]) {
      final dir = locale.languageCode == 'ar' ? 'RTL' : 'LTR';

      testWidgets('$dir: three markers never overlap the branch token, and '
          'both stay inside the cell', (tester) async {
        await _pump(tester, locale: locale);

        final cell = _cell(_employee, _crowdedDay);
        final cellRect = tester.getRect(cell);
        final markers = _markers(cell);
        expect(
          markers,
          findsNWidgets(3),
          reason: 'cover + holiday worked + overtime is the worst case',
        );

        final token = _in(cell, find.text('NC'));
        expect(token, findsOneWidget, reason: 'the branch token is drawn');
        final tokenRect = tester.getRect(token);

        for (var i = 0; i < 3; i++) {
          final markerRect = tester.getRect(markers.at(i));
          expect(
            tokenRect.overlaps(markerRect),
            isFalse,
            reason:
                'marker $i $markerRect overlaps the branch token $tokenRect',
          );
          expect(
            cellRect.inflate(0.5).contains(markerRect.topLeft) &&
                cellRect.inflate(0.5).contains(markerRect.bottomRight),
            isTrue,
            reason: 'marker $i $markerRect escapes the cell $cellRect',
          );
        }
        expect(
          cellRect.inflate(0.5).contains(tokenRect.topLeft) &&
              cellRect.inflate(0.5).contains(tokenRect.bottomRight),
          isTrue,
          reason: 'branch token $tokenRect escapes the cell $cellRect',
        );
      });
    }

    testWidgets('the branch token yields to the markers without vanishing', (
      tester,
    ) async {
      // Two things the fix must not do. It must not shrink the common case: a
      // plain working day has no markers competing for the corner, so its
      // token is unscaled. And "does not overlap" must not be satisfied by
      // scaling the token down to an unreadable speck. Measured when the fix
      // landed: 18.4x9.0 plain, 13.0x6.4 with three markers (71%). The floor
      // leaves room for font metrics to move, and fails long before illegible.
      await _pump(tester);

      final plain = tester.getRect(
        _in(_cell(_employee, _plainDay), find.text('NC')),
      );
      final crowded = tester.getRect(
        _in(_cell(_employee, _crowdedDay), find.text('NC')),
      );
      expect(_markers(_cell(_employee, _plainDay)), findsNothing);
      expect(
        crowded.height,
        lessThanOrEqualTo(plain.height + 0.01),
        reason: 'the crowded token can shrink, never grow',
      );
      expect(
        crowded.height / plain.height,
        greaterThanOrEqualTo(0.6),
        reason:
            'crowded token ${crowded.size} is under 60% of plain ${plain.size}',
      );
    });
  });

  group('tapping and long-pressing a cell', () {
    testWidgets('a long-press starts a selection on that person and day', (
      tester,
    ) async {
      final container = await _pump(tester);

      await tester.longPress(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();

      final selection = container.read(rosterSelectionProvider);
      expect(selection, isNotNull);
      expect(selection!.employee, _employee);
      expect(selection.dates, {_plainDay});
    });

    testWidgets('with a selection on the row, a tap adds a day and a second '
        'tap removes it', (tester) async {
      final container = await _pump(tester);

      await tester.longPress(_cell(_employee, _plainDay));
      await tester.pumpAndSettle();

      await tester.tap(_cell(_employee, _nextDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider)!.dates, {
        _plainDay,
        _nextDay,
      });

      await tester.tap(_cell(_employee, _nextDay));
      await tester.pumpAndSettle();
      expect(container.read(rosterSelectionProvider)!.dates, {_plainDay});
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
