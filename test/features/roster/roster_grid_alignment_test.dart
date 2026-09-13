import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_grid_metrics.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_screen.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_shift_palette.dart';

/// The shift distribution grid must stay aligned with its names and dates.
///
/// The bug this guards against: each day cell was 56x62 plus a 1px outer
/// margin, so it really took 58x64 while the date headers were 56 wide and the
/// name cells 62 tall. Every row slipped 2px against its name and every column
/// 2px against its date, so by day 29 a whole column sat under the wrong date
/// and the lower rows had slid past their owners. A manager reading "off" beside
/// one person was reading a neighbour's day. It was live on production for
/// weeks; the attendance month grid had the identical bug and the identical fix.
///
/// Pumps a real month large enough for the drift to show (24 employees x 31
/// days) and checks, with `tester.getRect`, that every cell sits within 0.5px of
/// its employee's name row and its day's header.
const _month = '2026-10'; // 31 days
const _employeeCount = 24;
const _tolerance = 0.5;

String _date(int day) => '$_month-${day.toString().padLeft(2, '0')}';

String _employeeId(int index) =>
    'HR-EMP-${(index + 1).toString().padLeft(5, '0')}';

/// A realistic mix of every cell shape the grid draws: working days on three
/// shift types across two branches (with a corner code and a branch token),
/// overtime days (a marker glyph), days off both covered and uncovered, a
/// holiday, flagged cover days, and unrostered days. Anything that could change
/// a cell's size is in here.
RosterMonth _buildMonth() {
  const shifts = ['Branch Opening', 'Branch Closing', 'Branch Cover Full Day'];
  const branches = ['Nasr City', 'Dokki'];

  final employees = <Map<String, dynamic>>[];
  for (var e = 0; e < _employeeCount; e++) {
    final days = <String, dynamic>{};
    for (var d = 1; d <= 31; d++) {
      final date = _date(d);
      final kind = (e * 5 + d) % 9;
      switch (kind) {
        case 0:
          days[date] = {
            'date': date,
            'day_off': {
              'name': 'RDO-$e-$d',
              'off_type': 'Weekly Off',
              // Half the days off are covered, half are not.
              if ((e + d).isEven)
                'covered_by': _employeeId((e + 1) % _employeeCount),
              if ((e + d).isEven) 'covered_by_name': 'Colleague ${e + 2}',
            },
          };
        case 1:
          days[date] = {'date': date, 'is_holiday': 1};
        case 2:
          // Unrostered: a date with nothing on it.
          days[date] = {'date': date};
        default:
          days[date] = {
            'date': date,
            'shift_type': shifts[(e + d) % shifts.length],
            'shift_location': branches[(e + d) % branches.length],
            // 12 on some days, over the 9-hour standard: the overtime marker.
            'hours': (e + d) % 4 == 0 ? 12 : 9,
            'is_cover': (e + d) % 13 == 0,
          };
      }
    }
    employees.add({
      'employee': _employeeId(e),
      'employee_name': 'Employee number ${e + 1} with a long name',
      'standard_hours': 9,
      'is_courier': e % 6 == 0,
      'shift_locations': branches,
      'days': days,
    });
  }

  return RosterMonth.fromJson({
    'hrms_available': true,
    'month': _month,
    'month_start': _date(1),
    'month_end': _date(31),
    'employees': employees,
    'shift_catalog': [
      for (final s in shifts)
        {
          'shift_type': s,
          'start_time': '09:00:00',
          'end_time': '18:00:00',
          'hours': 9,
        },
    ],
    'scope': {'configured': true, 'unrestricted': true},
  });
}

Future<void> _pumpGrid(
  WidgetTester tester,
  RosterMonth month,
  Locale locale, {
  double textScale = 1.0,
}) async {
  // Phone-sized: the grid is far bigger than the screen, which is how it is
  // really used. Offscreen cells are still laid out (neither scroll view here
  // is lazy), and skipOffstage: false below finds them.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
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
}

Rect _rect(WidgetTester tester, Key key) =>
    tester.getRect(find.byKey(key, skipOffstage: false));

void _expectAligned({
  required Rect cell,
  required Rect name,
  required Rect header,
  required String where,
}) {
  expect(
    (cell.top - name.top).abs(),
    lessThanOrEqualTo(_tolerance),
    reason: '$where: cell top ${cell.top} vs name row top ${name.top}',
  );
  expect(
    (cell.bottom - name.bottom).abs(),
    lessThanOrEqualTo(_tolerance),
    reason:
        '$where: cell bottom ${cell.bottom} vs name row bottom ${name.bottom}',
  );
  expect(
    (cell.left - header.left).abs(),
    lessThanOrEqualTo(_tolerance),
    reason: '$where: cell left ${cell.left} vs header left ${header.left}',
  );
  expect(
    (cell.right - header.right).abs(),
    lessThanOrEqualTo(_tolerance),
    reason: '$where: cell right ${cell.right} vs header right ${header.right}',
  );
}

void main() {
  final month = _buildMonth();

  test('the fixture is big enough to expose the drift', () {
    // At the old 2px per step, 24 rows and 31 columns drift by 46px and 60px:
    // most of a row, and more than a whole 56px column.
    expect(month.employees, hasLength(_employeeCount));
    expect(month.dates, hasLength(31));
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    final dir = locale.languageCode == 'ar' ? 'RTL' : 'LTR';

    testWidgets('$dir: the last employee on day 31 lines up with their name '
        'and that date', (tester) async {
      await _pumpGrid(tester, month, locale);

      final lastEmployee = _employeeId(_employeeCount - 1);
      final lastDay = _date(31);

      _expectAligned(
        cell: _rect(tester, rosterGridCellKey(lastEmployee, lastDay)),
        name: _rect(tester, rosterGridNameKey(lastEmployee)),
        header: _rect(tester, rosterGridHeaderKey(lastDay)),
        where: '$lastEmployee / $lastDay',
      );
    });

    testWidgets('$dir: every cell in the grid lines up with its row and '
        'column', (tester) async {
      await _pumpGrid(tester, month, locale);

      final names = {
        for (final e in month.employees)
          e.employee: _rect(tester, rosterGridNameKey(e.employee)),
      };
      final headers = {
        for (final d in month.dates) d: _rect(tester, rosterGridHeaderKey(d)),
      };

      for (final employee in month.employees) {
        for (final date in month.dates) {
          _expectAligned(
            cell: _rect(tester, rosterGridCellKey(employee.employee, date)),
            name: names[employee.employee]!,
            header: headers[date]!,
            where: '${employee.employee} / $date',
          );
        }
      }
    });

    testWidgets('$dir: the totals row lines up with the date headers', (
      tester,
    ) async {
      await _pumpGrid(tester, month, locale);

      for (final date in month.dates) {
        final totals = _rect(tester, rosterGridTotalsKey(date));
        final header = _rect(tester, rosterGridHeaderKey(date));
        expect(
          (totals.left - header.left).abs(),
          lessThanOrEqualTo(_tolerance),
          reason: '$date: totals left ${totals.left} vs header ${header.left}',
        );
        expect(
          (totals.right - header.right).abs(),
          lessThanOrEqualTo(_tolerance),
          reason:
              '$date: totals right ${totals.right} vs header ${header.right}',
        );
      }
    });

    testWidgets('$dir: cells, headers, totals and names take exactly their '
        'metric slots', (tester) async {
      await _pumpGrid(tester, month, locale);

      final employee = _employeeId(7);
      final date = _date(14);

      expect(
        _rect(tester, rosterGridCellKey(employee, date)).size,
        RosterGridMetrics.slot,
      );
      expect(
        _rect(tester, rosterGridHeaderKey(date)).size,
        RosterGridMetrics.headerSlot,
      );
      expect(
        _rect(tester, rosterGridTotalsKey(date)).size,
        RosterGridMetrics.totalsSlot,
      );
      expect(
        _rect(tester, rosterGridNameKey(employee)).size,
        RosterGridMetrics.nameSlot,
      );
    });

    testWidgets('$dir: rows and columns are evenly spaced, one slot apart', (
      tester,
    ) async {
      await _pumpGrid(tester, month, locale);

      final first = _rect(tester, rosterGridCellKey(_employeeId(0), _date(1)));
      final lastRow = _rect(
        tester,
        rosterGridCellKey(_employeeId(_employeeCount - 1), _date(1)),
      );
      final lastColumn = _rect(
        tester,
        rosterGridCellKey(_employeeId(0), _date(31)),
      );

      expect(
        (lastRow.top - first.top).abs(),
        closeTo((_employeeCount - 1) * RosterGridMetrics.rowHeight, _tolerance),
      );
      expect(
        (lastColumn.left - first.left).abs(),
        closeTo(30 * RosterGridMetrics.cellWidth, _tolerance),
      );
    });
  }

  // Large system text. Android's font-size setting reaches 2x, and the grid's
  // cells have FIXED heights — they must, or the strips drift apart (see
  // RosterGridMetrics). So content that does not fit has to shrink inside its
  // cell rather than spill out of it. At 1.5x and 2x the pinned name cells and
  // the date headers used to overflow by 3-37px, painting over the row below.
  group('large system text', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      final dir = locale.languageCode == 'ar' ? 'RTL' : 'LTR';

      testWidgets(
        '$dir @ 1.0x: nothing is scaled down at the normal text size',
        (tester) async {
          // The fit-to-cell shrink must be invisible when content fits. A
          // FittedBox(scaleDown) scales by exactly 1 when its child is no larger
          // than the box, so that is what is checked for every name, header and
          // totals cell in the month.
          await _pumpGrid(tester, month, locale);

          final keys = <Key>[
            for (final e in month.employees) rosterGridNameKey(e.employee),
            for (final d in month.dates) rosterGridHeaderKey(d),
            for (final d in month.dates) rosterGridTotalsKey(d),
          ];
          var checked = 0;
          for (final key in keys) {
            final boxes = tester.renderObjectList<RenderFittedBox>(
              find.descendant(
                of: find.byKey(key, skipOffstage: false),
                matching: find.byType(FittedBox, skipOffstage: false),
              ),
            );
            for (final box in boxes) {
              final child = box.child!;
              expect(
                child.size.width <= box.size.width + 0.01 &&
                    child.size.height <= box.size.height + 0.01,
                isTrue,
                reason:
                    '$key: content ${child.size} is scaled into ${box.size}',
              );
              checked++;
            }
          }
          // One per name, header and totals cell — the check actually ran.
          expect(checked, keys.length);
        },
      );
    }

    for (final scale in const [1.5, 2.0]) {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        final dir = locale.languageCode == 'ar' ? 'RTL' : 'LTR';

        testWidgets(
          '$dir @ ${scale}x: nothing in the grid overflows its cell',
          (tester) async {
            await _pumpGrid(tester, month, locale, textScale: scale);
            // A RenderFlex overflow is reported through FlutterError; the test
            // framework fails the test on it even without this line, which is
            // here to make the intent explicit.
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets('$dir @ ${scale}x: the grid keeps its geometry and stays '
            'aligned', (tester) async {
          await _pumpGrid(tester, month, locale, textScale: scale);

          final employee = _employeeId(_employeeCount - 1);
          final date = _date(31);
          expect(
            _rect(tester, rosterGridCellKey(employee, date)).size,
            RosterGridMetrics.slot,
          );
          expect(
            _rect(tester, rosterGridHeaderKey(date)).size,
            RosterGridMetrics.headerSlot,
          );
          expect(
            _rect(tester, rosterGridNameKey(employee)).size,
            RosterGridMetrics.nameSlot,
          );
          _expectAligned(
            cell: _rect(tester, rosterGridCellKey(employee, date)),
            name: _rect(tester, rosterGridNameKey(employee)),
            header: _rect(tester, rosterGridHeaderKey(date)),
            where: '$employee / $date @ ${scale}x',
          );
        });
      }
    }
  });
}
