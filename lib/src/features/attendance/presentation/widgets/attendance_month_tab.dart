import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';
import 'attendance_controls.dart';
import 'attendance_day_sheet.dart';
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
        Expanded(child: _MonthGrid(month: month)),
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

/// A pinned employee column beside horizontally scrolling days.
///
/// One outer vertical scroll wraps both halves so they cannot drift out of
/// alignment — synchronising two vertical controllers is the usual way this
/// kind of table ends up one row out.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month});

  final AttendanceMonth month;

  static const double _rowHeight = 54;
  static const double _headerHeight = 44;
  static const double _cellWidth = 46;
  static const double _nameWidth = 136;

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
                width: _nameWidth,
                height: _headerHeight,
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
                  style: theme.textTheme.labelSmall,
                ),
              ),
              ...month.employees.map(
                (employee) => _EmployeeNameCell(
                  employee: employee,
                  width: _nameWidth,
                  height: _rowHeight,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final date in dates)
                        _DayHeaderCell(
                          date: date,
                          width: _cellWidth,
                          height: _headerHeight,
                        ),
                    ],
                  ),
                  for (final employee in month.employees)
                    Row(
                      children: [
                        for (final date in dates)
                          _MonthCell(
                            employee: employee,
                            date: date,
                            cell: employee.cellFor(date),
                            graceMinutes: month.graceMinutes,
                            width: _cellWidth,
                            height: _rowHeight,
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
  const _EmployeeNameCell({
    required this.employee,
    required this.width,
    required this.height,
  });

  final AttendanceEmployeeMonth employee;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rate = employee.totals.attendanceRate;
    return Container(
      width: width,
      height: height,
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
                // Not "—": nobody was rostered, which is a fact about the
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
  const _DayHeaderCell({
    required this.date,
    required this.width,
    required this.height,
  });

  final String date;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = DateTime.tryParse(date);
    final isFriday = parsed != null && parsed.weekday == DateTime.friday;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFriday
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.employee,
    required this.date,
    required this.cell,
    required this.graceMinutes,
    required this.width,
    required this.height,
  });

  final AttendanceEmployeeMonth employee;
  final String date;
  final AttendanceCell? cell;
  final int graceMinutes;
  final double width;
  final double height;

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
        width: width,
        height: height,
        isCover: data.isCover,
      ),
    );
  }
}
