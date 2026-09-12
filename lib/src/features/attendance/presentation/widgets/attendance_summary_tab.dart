import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';
import 'attendance_controls.dart';
import 'attendance_states.dart';

/// Tab 4 — aggregates for a range, grouped by branch, employee or day.
///
/// The same nine numbers under three different groupings, because the same
/// question ("who is not turning up on time") is asked of a branch, a person
/// and a date, and re-deriving the numbers per view is how three views end up
/// disagreeing.
class AttendanceSummaryTab extends ConsumerWidget {
  const AttendanceSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(attendanceRangeProvider);
    final groupBy = ref.watch(attendanceGroupByProvider);
    final location = ref.watch(attendanceLocationFilterProvider);
    final query = AttendanceSummaryQuery(
      fromDate: range.fromDate,
      toDate: range.toDate,
      groupBy: groupBy,
      shiftLocation: location,
    );
    final summaryAsync = ref.watch(attendanceSummaryDataProvider(query));

    return Column(
      children: [
        const AttendanceRangeBar(showBranchFilter: true),
        const _GroupByToggle(),
        Expanded(
          child: summaryAsync.when(
            data: (summary) => _SummaryBody(summary: summary),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AttendanceErrorState(
              error: error,
              onRetry: () =>
                  ref.invalidate(attendanceSummaryDataProvider(query)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupByToggle extends ConsumerWidget {
  const _GroupByToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupBy = ref.watch(attendanceGroupByProvider);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: SegmentedButton<AttendanceGroupBy>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: AttendanceGroupBy.branch,
            icon: const Icon(Icons.store_outlined, size: 16),
            label: Text(l10n.attendanceGroupByBranch),
          ),
          ButtonSegment(
            value: AttendanceGroupBy.employee,
            icon: const Icon(Icons.person_outline, size: 16),
            label: Text(l10n.attendanceGroupByEmployee),
          ),
          ButtonSegment(
            value: AttendanceGroupBy.day,
            icon: const Icon(Icons.today_outlined, size: 16),
            label: Text(l10n.attendanceGroupByDay),
          ),
        ],
        selected: {groupBy},
        onSelectionChanged: (selection) =>
            ref.read(attendanceGroupByProvider.notifier).state =
                selection.first,
      ),
    );
  }
}

class _SummaryBody extends ConsumerWidget {
  const _SummaryBody({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sort = ref.watch(attendanceSummarySortProvider);

    final blocking = attendanceBlockingState(
      context,
      hrmsAvailable: summary.hrmsAvailable,
      notice: summary.notice,
      scope: summary.scope,
      hasRows: summary.rows.isNotEmpty,
    );
    if (blocking != null) return blocking;

    final rows = sortAttendanceSummaryRows(summary.rows, sort);

    return Column(
      children: [
        if (summary.notice != null)
          AttendanceNoticeBanner(notice: summary.notice!),
        if (!summary.hasAnyAttendance) const AttendanceNoCheckinsBanner(dense: true),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _columnIndex(sort.column),
                sortAscending: sort.ascending,
                headingRowHeight: 44,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 48,
                columns: [
                  for (final column in _columns)
                    DataColumn(
                      label: Text(
                        _columnLabel(context, column),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      numeric: column != AttendanceSummaryColumn.label,
                      onSort: (_, _) =>
                          ref
                                  .read(attendanceSummarySortProvider.notifier)
                                  .state =
                              sort.toggled(column),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    _dataRow(context, row, groupBy: summary.groupBy),
                  // The totals line, visually separated: it is the only row
                  // that is not one of the groups.
                  _dataRow(
                    context,
                    summary.totals,
                    groupBy: summary.groupBy,
                    label: l10n.attendanceTotalsRow,
                    isTotals: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _dataRow(
    BuildContext context,
    AttendanceSummaryRow row, {
    required AttendanceGroupBy groupBy,
    String? label,
    bool isTotals = false,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final weight = isTotals ? FontWeight.w800 : FontWeight.w400;
    final numberStyle = attendanceNumeric(
      theme.textTheme.bodySmall,
    )?.copyWith(fontWeight: weight);

    // A group with nothing rostered has no rate, only a divide by zero the
    // server already resolved to 0.0. Printing "0%" there would read as a
    // failure and an em dash would read as missing data; it is neither, so the
    // cell says "no roster" outright.
    final rateDenominator = row.rosteredDays;
    // Everybody who turned up, `late_unmatched` included.
    final punctualityDenominator = row.attendedDays;

    return DataRow(
      cells: [
        DataCell(
          Text(
            label ?? _groupLabel(context, row, groupBy),
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: weight),
          ),
        ),
        DataCell(
          Text(attendanceCount(context, row.rosteredDays), style: numberStyle),
        ),
        DataCell(
          Text(attendanceCount(context, row.presentDays), style: numberStyle),
        ),
        DataCell(
          Text(attendanceCount(context, row.lateDays), style: numberStyle),
        ),
        DataCell(
          Text(
            attendanceCount(context, row.lateUnmatchedDays),
            style: numberStyle,
          ),
        ),
        DataCell(
          Text(attendanceCount(context, row.absentDays), style: numberStyle),
        ),
        DataCell(
          Text(attendanceCount(context, row.pendingDays), style: numberStyle),
        ),
        DataCell(
          Text(attendanceHours(context, row.workedHours), style: numberStyle),
        ),
        DataCell(
          Text(
            attendanceCount(context, row.avgLateMinutes.round()),
            style: numberStyle,
          ),
        ),
        DataCell(
          Tooltip(
            message: attendanceRateIsMeaningful(rateDenominator)
                ? ''
                : l10n.attendanceRateNoRosterWhy,
            child: Text(
              attendanceRateOrNoRoster(
                context,
                row.attendanceRate,
                rateDenominator,
              ),
              style: numberStyle,
            ),
          ),
        ),
        DataCell(
          Text(
            attendanceRateOrNoRoster(
              context,
              row.punctualityRate,
              punctualityDenominator,
            ),
            style: numberStyle,
          ),
        ),
      ],
    );
  }
}

const List<AttendanceSummaryColumn> _columns = <AttendanceSummaryColumn>[
  AttendanceSummaryColumn.label,
  AttendanceSummaryColumn.rosteredDays,
  AttendanceSummaryColumn.presentDays,
  AttendanceSummaryColumn.lateDays,
  AttendanceSummaryColumn.lateUnmatchedDays,
  AttendanceSummaryColumn.absentDays,
  AttendanceSummaryColumn.pendingDays,
  AttendanceSummaryColumn.workedHours,
  AttendanceSummaryColumn.avgLateMinutes,
  AttendanceSummaryColumn.attendanceRate,
  AttendanceSummaryColumn.punctualityRate,
];

int _columnIndex(AttendanceSummaryColumn column) => _columns.indexOf(column);

String _columnLabel(BuildContext context, AttendanceSummaryColumn column) {
  final l10n = context.l10n;
  return switch (column) {
    AttendanceSummaryColumn.label => l10n.attendanceColumnGroup,
    AttendanceSummaryColumn.rosteredDays => l10n.attendanceMetricRostered,
    AttendanceSummaryColumn.presentDays => l10n.attendanceMetricPresent,
    AttendanceSummaryColumn.lateDays => l10n.attendanceMetricLate,
    AttendanceSummaryColumn.lateUnmatchedDays =>
      l10n.attendanceMetricLateUnmatched,
    AttendanceSummaryColumn.absentDays => l10n.attendanceMetricAbsent,
    AttendanceSummaryColumn.pendingDays => l10n.attendanceMetricPending,
    AttendanceSummaryColumn.workedHours => l10n.attendanceMetricWorkedHours,
    AttendanceSummaryColumn.avgLateMinutes => l10n.attendanceMetricAvgLate,
    AttendanceSummaryColumn.attendanceRate =>
      l10n.attendanceMetricAttendanceRate,
    AttendanceSummaryColumn.punctualityRate =>
      l10n.attendanceMetricPunctualityRate,
  };
}

/// What to print in the first column.
///
/// Three different things, deliberately:
/// * `group_by=day` — the server guarantees `key` is a bare `YYYY-MM-DD`, so
///   the client formats it with its own locale formatter. Printing the
///   server's `label` there would put an English, Western-digit date in the
///   middle of an Arabic table.
/// * the unresolved-branch bucket — labelled client-side, because whatever the
///   backend put in `label` for it is English.
/// * everything else — the server's `label` verbatim: a branch or a person's
///   name is not the client's to reword.
String _groupLabel(
  BuildContext context,
  AttendanceSummaryRow row,
  AttendanceGroupBy groupBy,
) {
  if (groupBy == AttendanceGroupBy.day && (row.key ?? '').isNotEmpty) {
    return attendanceDateLabel(context, row.key, pattern: 'EEE d MMM');
  }
  if (row.isUnresolvedBranch || row.label.isEmpty) {
    return attendanceBranchLabel(context, row.shiftLocation);
  }
  return row.label;
}
