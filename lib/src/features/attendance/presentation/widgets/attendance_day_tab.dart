import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';
import 'attendance_controls.dart';
import 'attendance_day_sheet.dart';
import 'attendance_states.dart';
import 'attendance_status_style.dart';

/// Tab 2 — one day, branch by branch.
///
/// The question this tab answers is "who actually came in today, and were they
/// on time", so lateness is the loudest thing on it: the minutes are printed
/// at title size next to the person's name, and the rows arrive worst-first
/// from the server.
class AttendanceDayTab extends ConsumerWidget {
  const AttendanceDayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(attendanceDayDataProvider);

    return Column(
      children: [
        const AttendanceDateBar(),
        Expanded(
          child: dayAsync.when(
            data: (day) => _DayBody(day: day),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AttendanceErrorState(
              error: error,
              onRetry: () => ref.invalidate(attendanceDayDataProvider),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final blocking = attendanceBlockingState(
      context,
      hrmsAvailable: day.hrmsAvailable,
      notice: day.notice,
      scope: day.scope,
      hasRows: day.hasAnyRow,
    );
    if (blocking != null) return blocking;

    // The server already sends the unresolved bucket last. Partitioning here
    // as well keeps that guarantee visible on the client, and keeps every
    // other branch in exactly the order the server chose.
    final named = day.branches.where((b) => !b.isUnresolvedBranch).toList();
    final unresolved = day.branches.where((b) => b.isUnresolvedBranch).toList();
    final ordered = [...named, ...unresolved];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (day.notice != null) AttendanceNoticeBanner(notice: day.notice!),
        if (!day.hasAnyCheckin) const AttendanceNoCheckinsBanner(),
        _DayTotalsHeader(totals: day.totals, isOverall: true, label: null),
        for (final branch in ordered) _BranchSection(branch: branch, day: day),
      ],
    );
  }
}

/// Rostered / present / late / absent / pending / off, for a branch or for the
/// whole day.
class _DayTotalsHeader extends StatelessWidget {
  const _DayTotalsHeader({
    required this.totals,
    required this.isOverall,
    required this.label,
  });

  final AttendanceDayTotals totals;
  final bool isOverall;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      color: isOverall
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
          : theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOverall ? Icons.groups_outlined : Icons.store_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label ?? l10n.attendanceWholeDay,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TotalPill(
                  label: l10n.attendanceMetricRostered,
                  value: totals.rostered,
                ),
                _TotalPill(
                  label: l10n.attendanceMetricPresent,
                  value: totals.present,
                  status: AttendanceStatus.present,
                ),
                _TotalPill(
                  label: l10n.attendanceMetricLate,
                  value: totals.late,
                  status: AttendanceStatus.late,
                ),
                // The bucket that used to be missing from the header while
                // its rows were listed below it — the head-count that did not
                // add up.
                _TotalPill(
                  label: l10n.attendanceMetricLateUnmatched,
                  value: totals.lateUnmatched,
                  status: AttendanceStatus.lateUnmatched,
                ),
                _TotalPill(
                  label: l10n.attendanceMetricAbsent,
                  value: totals.absent,
                  status: AttendanceStatus.absent,
                ),
                _TotalPill(
                  label: l10n.attendanceMetricPending,
                  value: totals.pending,
                  status: AttendanceStatus.pending,
                ),
                _TotalPill(
                  label: l10n.attendanceMetricOff,
                  value: totals.off,
                  status: AttendanceStatus.off,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalPill extends StatelessWidget {
  const _TotalPill({required this.label, required this.value, this.status});

  final String label;
  final int value;
  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = status == null
        ? null
        : AttendanceStatusStyle.of(context, status!);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: style?.background ?? theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (style != null) ...[
              Icon(style.icon, size: 12, color: style.foreground),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: style?.foreground ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              attendanceCount(context, value),
              style: attendanceNumeric(theme.textTheme.labelLarge)?.copyWith(
                color: style?.foreground ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchSection extends StatelessWidget {
  const _BranchSection({required this.branch, required this.day});

  final AttendanceBranchDay branch;
  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayTotalsHeader(
          // `headerTotals` is the server's own tally while it is
          // self-consistent, and the rows' tally when it is not (an older
          // backend with no `late_unmatched` counter). The header must never
          // disagree with the list printed directly underneath it.
          totals: branch.headerTotals,
          isOverall: false,
          // Never a blank heading: the null bucket is named for what it is.
          label: attendanceBranchLabel(context, branch.shiftLocation),
        ),
        if (branch.isUnresolvedBranch)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
            child: Text(
              l10n.attendanceNoBranchResolvedHint,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (branch.rows.isEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
            child: Text(
              l10n.attendanceBranchNobodyRostered,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final row in branch.rows)
          AttendanceDayRowTile(row: row, graceMinutes: day.graceMinutes),
      ],
    );
  }
}

/// One person's line on the day view.
class AttendanceDayRowTile extends StatelessWidget {
  const AttendanceDayRowTile({
    super.key,
    required this.row,
    required this.graceMinutes,
  });

  final AttendanceDayRow row;
  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cell = row.cell;
    final style = AttendanceStatusStyle.of(
      context,
      cell.status,
      lateMinutes: cell.lateMinutes,
      graceMinutes: graceMinutes,
    );
    final lateMinutes = cell.lateMinutesPositive;
    final isLate =
        cell.status == AttendanceStatus.late ||
        cell.status == AttendanceStatus.lateUnmatched;

    return InkWell(
      onTap: () => showAttendanceDaySheet(
        context,
        employeeName: row.employeeName,
        designation: row.designation,
        cell: cell,
        graceMinutes: graceMinutes,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
          // A hairline in the status colour on the leading edge, so a scan
          // down the list finds the bad rows without reading a word.
          color: isLate || cell.status == AttendanceStatus.absent
              ? style.background.withValues(alpha: 0.22)
              : null,
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          row.employeeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (cell.isCover) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.swap_horiz,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                      if (cell.geoOk == false) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: l10n.attendanceGeoOutside,
                          child: Icon(
                            Icons.wrong_location_outlined,
                            size: 14,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Scheduled -> actual, both server-local strings.
                    '${attendanceClock(context, cell.scheduledStart)} '
                    '• ${attendanceClock(context, cell.firstIn)}'
                    '${cell.lastOut == null ? '' : ' • ${attendanceClock(context, cell.lastOut)}'}',
                    style: attendanceNumeric(theme.textTheme.labelSmall)
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Lateness, loud. The minutes are the headline for a late row;
            // everyone else just gets their status chip.
            if (cell.status == AttendanceStatus.late && lateMinutes > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    attendanceCount(context, lateMinutes),
                    style: attendanceNumeric(theme.textTheme.headlineSmall)
                        ?.copyWith(
                          color: style.foreground,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                  ),
                  Text(
                    l10n.attendanceMinutesLateShort,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            else
              AttendanceStatusChip(
                status: cell.status,
                lateMinutes: cell.lateMinutes,
                graceMinutes: graceMinutes,
                compact: true,
              ),
          ],
        ),
      ),
    );
  }
}
