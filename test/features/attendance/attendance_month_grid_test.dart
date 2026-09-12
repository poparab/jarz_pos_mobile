import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_grid_metrics.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_month_tab.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_status_style.dart';

/// The month grid must stay aligned with its names and dates.
///
/// The bug this guards against: each cell was 46x54 plus a 1px outer margin,
/// so it really took 48x56 while the date headers and name cells were 46x54.
/// Every row slipped 2px against its name and every column 2px against its
/// date. By row 14 an absence sat beside the wrong person, and by day 24 the
/// dates were a full column off. Managers judge staff from this screen.
///
/// The test pumps a real grid large enough for that error to show (24
/// employees, 31 days) and checks, with `tester.getRect`, that every cell sits
/// within 0.5px of its employee's name row and its day's header.
const _month = '2026-10'; // 31 days
const _employeeCount = 24;
const _tolerance = 0.5;

String _date(int day) => '$_month-${day.toString().padLeft(2, '0')}';

String _employeeId(int index) =>
    'HR-EMP-${(index + 1).toString().padLeft(5, '0')}';

/// A realistic mix: every status, late cells showing a minutes line (the
/// tallest cell content), and cover days drawing a border. Anything that could
/// change a cell's size is included.
AttendanceMonth _buildMonth() {
  const statuses = [
    'present',
    'late',
    'late_unmatched',
    'absent',
    'pending',
    'off',
    'holiday',
    'not_rostered',
  ];
  final employees = <Map<String, dynamic>>[];
  for (var e = 0; e < _employeeCount; e++) {
    final days = <String, dynamic>{};
    for (var d = 1; d <= 31; d++) {
      // Leave a few days out entirely, so the grid also draws its own
      // "not rostered" fallback cells.
      if ((e + d) % 17 == 0) continue;
      final status = statuses[(e * 3 + d) % statuses.length];
      days[_date(d)] = {
        'date': _date(d),
        'status': status,
        'late_minutes': status == 'late' ? 5 + (e * 7 + d) % 120 : null,
        'checkin_count': status == 'absent' ? 0 : 1,
        'is_cover': (e + d) % 11 == 0,
      };
    }
    // Force every date key onto at least the first row, so the column set
    // is always all 31 days.
    if (e == 0) {
      for (var d = 1; d <= 31; d++) {
        days.putIfAbsent(_date(d), () => {'date': _date(d), 'status': 'present'});
      }
    }
    employees.add({
      'employee': _employeeId(e),
      'employee_name': 'Employee number ${e + 1} with a long name',
      'days': days,
      'totals': {'rostered_days': 20, 'attendance_rate': 0.5},
    });
  }
  return AttendanceMonth.fromJson({
    'hrms_available': true,
    'month': _month,
    'month_start': _date(1),
    'month_end': _date(31),
    'grace_minutes': 15,
    'employees': employees,
    'totals': <String, dynamic>{},
  });
}

Future<void> _pumpGrid(
  WidgetTester tester,
  AttendanceMonth month,
  Locale locale,
) async {
  // A phone-sized surface: the grid is much bigger than the screen, which is
  // how it is really used. Offscreen cells are still laid out, and
  // skipOffstage: false below finds them.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

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
      home: Scaffold(body: AttendanceMonthGrid(month: month)),
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
    reason: '$where: cell bottom ${cell.bottom} vs name row bottom ${name.bottom}',
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
    // nearly a full row and more than a full column.
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
        cell: _rect(tester, attendanceGridCellKey(lastEmployee, lastDay)),
        name: _rect(tester, attendanceGridNameKey(lastEmployee)),
        header: _rect(tester, attendanceGridHeaderKey(lastDay)),
        where: '$lastEmployee / $lastDay',
      );
    });

    testWidgets('$dir: every cell in the grid lines up with its row and '
        'column', (tester) async {
      await _pumpGrid(tester, month, locale);

      final names = {
        for (final e in month.employees)
          e.employee: _rect(tester, attendanceGridNameKey(e.employee)),
      };
      final headers = {
        for (final d in month.dates) d: _rect(tester, attendanceGridHeaderKey(d)),
      };

      for (final employee in month.employees) {
        for (final date in month.dates) {
          _expectAligned(
            cell: _rect(tester, attendanceGridCellKey(employee.employee, date)),
            name: names[employee.employee]!,
            header: headers[date]!,
            where: '${employee.employee} / $date',
          );
        }
      }
    });

    testWidgets('$dir: cells, headers and name cells take exactly their '
        'metric slots', (tester) async {
      await _pumpGrid(tester, month, locale);

      final employee = _employeeId(7);
      final date = _date(14);

      expect(
        _rect(tester, attendanceGridCellKey(employee, date)).size,
        AttendanceGridMetrics.slot,
      );
      expect(
        _rect(tester, attendanceGridHeaderKey(date)).size,
        AttendanceGridMetrics.headerSlot,
      );
      expect(
        _rect(tester, attendanceGridNameKey(employee)).size,
        AttendanceGridMetrics.nameSlot,
      );
    });

    testWidgets('$dir: rows and columns are evenly spaced, one slot apart', (
      tester,
    ) async {
      await _pumpGrid(tester, month, locale);

      final first = _rect(tester, attendanceGridCellKey(_employeeId(0), _date(1)));
      final lastRow = _rect(
        tester,
        attendanceGridCellKey(_employeeId(_employeeCount - 1), _date(1)),
      );
      final lastColumn = _rect(
        tester,
        attendanceGridCellKey(_employeeId(0), _date(31)),
      );

      expect(
        (lastRow.top - first.top).abs(),
        closeTo((_employeeCount - 1) * AttendanceGridMetrics.rowHeight, _tolerance),
      );
      expect(
        (lastColumn.left - first.left).abs(),
        closeTo(30 * AttendanceGridMetrics.cellWidth, _tolerance),
      );
    });
  }

  testWidgets('the status square has no outer margin: its footprint is its '
      'size, whatever the content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AttendanceStatusSquare(
                  key: ValueKey('late'),
                  status: AttendanceStatus.late,
                  lateMinutes: 118,
                  isCover: true,
                ),
                AttendanceStatusSquare(
                  key: ValueKey('absent'),
                  status: AttendanceStatus.absent,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final late = tester.getRect(find.byKey(const ValueKey('late')));
    final absent = tester.getRect(find.byKey(const ValueKey('absent')));

    expect(late.size, AttendanceGridMetrics.slot);
    expect(absent.size, AttendanceGridMetrics.slot);
    // Placed side by side, with no margin in between.
    expect(absent.left - late.right, closeTo(0, _tolerance));
  });
}
