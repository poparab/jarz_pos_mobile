import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';
import 'attendance_controls.dart';
import 'attendance_day_sheet.dart';
import 'attendance_grid_metrics.dart';
import 'attendance_legend.dart';
import 'attendance_states.dart';
import 'attendance_status_style.dart';

/// Tab 1 — the month, as a calendar grid.
///
/// People down the side, days across the top: the shape a rota is read in,
/// with attendance in the cells instead of the roster. The employee column is
/// pinned while the days scroll, because the one thing a manager must never
/// lose track of while scanning a month is whose row they are on.
class AttendanceMonthTab extends ConsumerWidget {
  const AttendanceMonthTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAsync = ref.watch(attendanceMonthDataProvider);

    return Column(
      children: [
        const AttendanceMonthBar(),
        Expanded(
          child: monthAsync.when(
            data: (month) => _MonthBody(month: month),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AttendanceErrorState(
              error: error,
              onRetry: () => ref.invalidate(attendanceMonthDataProvider),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthBody extends StatelessWidget {
  const _MonthBody({required this.month});

  final AttendanceMonth month;

  @override
  Widget build(BuildContext context) {
    final blocking = attendanceBlockingState(
      context,
      hrmsAvailable: month.hrmsAvailable,
      notice: month.notice,
      scope: month.scope,
      hasRows: month.employees.isNotEmpty,
    );
    if (blocking != null) return blocking;

    return Column(
      children: [
        if (month.notice != null) AttendanceNoticeBanner(notice: month.notice!),
        // Said out loud, rather than left to be inferred from a wall of red:
        // with nobody clocking in, every past rostered day is `absent`, and
        // that means "no data", not "the whole team stayed home".
        if (!month.hasAnyCheckin) const AttendanceNoCheckinsBanner(),
        _MonthTotalsStrip(totals: month.totals),
        Row(
          children: [
            Expanded(child: AttendanceLegend(graceMinutes: month.graceMinutes)),
            IconButton(
              tooltip: context.l10n.attendanceLegendTitle,
              icon: const Icon(Icons.help_outline, size: 18),
              onPressed: () => showAttendanceLegendSheet(
                context,
                graceMinutes: month.graceMinutes,
              ),
            ),
          ],
        ),
        Expanded(child: AttendanceMonthGrid(month: month)),
      ],
    );
  }
}

/// The month's headline numbers, in one line.
class _MonthTotalsStrip extends StatelessWidget {
  const _MonthTotalsStrip({required this.totals});

  final AttendanceTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            AttendanceMetric(
              label: l10n.attendanceMetricRostered,
              value: attendanceCount(context, totals.rosteredDays),
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricPresent,
              value: attendanceCount(context, totals.presentDays),
              status: AttendanceStatus.present,
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricLate,
              value: attendanceCount(context, totals.lateDays),
              status: AttendanceStatus.late,
            ),
            // Counted since the backend started returning them. Without these
            // two the strip does not add up to `rostered`, and a manager who
            // adds the columns finds days that belong to nobody.
            AttendanceMetric(
              label: l10n.attendanceMetricLateUnmatched,
              value: attendanceCount(context, totals.lateUnmatchedDays),
              status: AttendanceStatus.lateUnmatched,
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricAbsent,
              value: attendanceCount(context, totals.absentDays),
              status: AttendanceStatus.absent,
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricPending,
              value: attendanceCount(context, totals.pendingDays),
              status: AttendanceStatus.pending,
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricAttendanceRate,
              value: attendanceRateOrNoRoster(
                context,
                totals.attendanceRate,
                totals.rosteredDays,
              ),
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricPunctualityRate,
              value: attendanceRateOrNoRoster(
                context,
                totals.punctualityRate,
                // Everybody who showed up, `late_unmatched` included — they
                // did arrive, just not inside a window the server could match.
                totals.punctualityDenominator,
              ),
            ),
            AttendanceMetric(
              label: l10n.attendanceMetricWorkedHours,
              value: attendanceHours(context, totals.workedHours),
            ),
          ],
        ),
      ),
    );
  }
}

/// One number with its caption, optionally tinted by the status it counts.
class AttendanceMetric extends StatelessWidget {
  const AttendanceMetric({
    super.key,
    required this.label,
    required this.value,
    this.status,
  });

  final String label;
  final String value;
  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = status == null
        ? null
        : AttendanceStatusStyle.of(context, status!);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (style != null) ...[
                Icon(style.icon, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: attendanceNumeric(
              theme.textTheme.titleMedium,
            )?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Key of an employee's name cell in the month grid.
Key attendanceGridNameKey(String employee) =>
    ValueKey<String>('attendance-grid-name-$employee');

/// Key of a date's header cell in the month grid.
Key attendanceGridHeaderKey(String date) =>
    ValueKey<String>('attendance-grid-header-$date');

/// Key of one (employee, date) cell in the month grid.
Key attendanceGridCellKey(String employee, String date) =>
    ValueKey<String>('attendance-grid-cell-$employee-$date');

/// A pinned employee column beside horizontally scrolling days.
///
/// Both halves sit inside one vertical scroll view. Keeping two separate
/// vertical controllers in sync is the usual way a table like this ends up
/// one row out.
///
/// The halves are separate strips that line up only because every piece
/// takes its size from [AttendanceGridMetrics]. See that class for the rules,
/// and `attendance_month_grid_test.dart` for the test that checks them.
class AttendanceMonthGrid extends StatelessWidget {
  const AttendanceMonthGrid({super.key, required this.month});

  final AttendanceMonth month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dates = month.dates;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: AttendanceGridMetrics.nameWidth,
                height: AttendanceGridMetrics.headerHeight,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Text(
                  context.l10n.attendanceEmployeeColumn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              for (final employee in month.employees)
                _EmployeeNameCell(
                  key: attendanceGridNameKey(employee.employee),
                  employee: employee,
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (final date in dates)
                        _DayHeaderCell(
                          key: attendanceGridHeaderKey(date),
                          date: date,
                        ),
                    ],
                  ),
                  for (final employee in month.employees)
                    Row(
                      children: [
                        for (final date in dates)
                          _MonthCell(
                            key: attendanceGridCellKey(employee.employee, date),
                            employee: employee,
                            date: date,
                            cell: employee.cellFor(date),
                            graceMinutes: month.graceMinutes,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeNameCell extends StatelessWidget {
  const _EmployeeNameCell({super.key, required this.employee});

  final AttendanceEmployeeMonth employee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rate = employee.totals.attendanceRate;
    // Exactly one row slot. The divider is a border painted inside it, so it
    // adds nothing to the height.
    return Container(
      width: AttendanceGridMetrics.nameSlot.width,
      height: AttendanceGridMetrics.nameSlot.height,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            employee.employeeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            // Rate first: it is the row's own summary, and it is what a
            // manager scans the left column for.
            attendanceRateIsMeaningful(employee.totals.rosteredDays)
                ? '${l10n.attendanceMetricAttendanceRate} '
                      '${attendanceRate(context, rate)}'
                // Not a dash: nobody was rostered, which is a fact about the
                // month rather than a gap in the data.
                : l10n.attendanceNotRosteredThisMonth,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: attendanceNumeric(theme.textTheme.labelSmall)?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = DateTime.tryParse(date);
    final isFriday = parsed != null && parsed.weekday == DateTime.friday;

    // Exactly one column slot, the same width as the cells under it.
    return Container(
      width: AttendanceGridMetrics.headerSlot.width,
      height: AttendanceGridMetrics.headerSlot.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFriday
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              attendanceDayNumber(context, date),
              style: attendanceNumeric(
                theme.textTheme.labelMedium,
              )?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              attendanceWeekdayLabel(context, date),
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    super.key,
    required this.employee,
    required this.date,
    required this.cell,
    required this.graceMinutes,
  });

  final AttendanceEmployeeMonth employee;
  final String date;
  final AttendanceCell? cell;
  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    // A day the server did not send for this employee is still not a blank:
    // it means nobody was rostered, which is a different statement from
    // "absent" and has to look different.
    final data =
        cell ??
        AttendanceCell(
          date: date,
          status: AttendanceStatus.notRostered,
          rawStatus: 'not_rostered',
        );

    // The InkWell adds no size, so the footprint is the square's: one slot.
    return InkWell(
      onTap: () => showAttendanceDaySheet(
        context,
        employeeName: employee.employeeName,
        designation: employee.designation,
        cell: data,
        graceMinutes: graceMinutes,
      ),
      child: AttendanceStatusSquare(
        status: data.status,
        lateMinutes: data.lateMinutes,
        graceMinutes: graceMinutes,
        width: AttendanceGridMetrics.slot.width,
        height: AttendanceGridMetrics.slot.height,
        isCover: data.isCover,
      ),
    );
  }
}
