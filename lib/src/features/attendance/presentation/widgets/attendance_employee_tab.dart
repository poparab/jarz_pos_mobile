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

/// Tab 3 — one person, over a range.
///
/// The by-branch breakdown is the reason this tab is not just a filtered month
/// grid: somebody who covered two branches in a week has their days split
/// across locations, and no other view shows that.
class AttendanceEmployeeTab extends ConsumerWidget {
  const AttendanceEmployeeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final options = ref.watch(attendanceEmployeeOptionsProvider);
    final selected = ref.watch(attendanceSelectedEmployeeProvider);
    final range = ref.watch(attendanceRangeProvider);
    final monthAsync = ref.watch(attendanceMonthDataProvider);

    return Column(
      children: [
        _EmployeePicker(options: options, selected: selected),
        const AttendanceRangeBar(),
        Expanded(
          child: switch ((selected, options.isEmpty, monthAsync.isLoading)) {
            // The picker's options come from the month payload, so an empty
            // list while that call is still in flight is "not yet", not "no
            // employees".
            (_, true, true) => const Center(child: CircularProgressIndicator()),
            (_, true, false) => AttendanceMessageState(
              icon: Icons.person_search_outlined,
              message: l10n.attendanceNoEmployeesToPick,
              detail: l10n.attendanceNoEmployeesToPickHint,
            ),
            (null, _, _) => AttendanceMessageState(
              icon: Icons.person_outline,
              message: l10n.attendancePickEmployee,
            ),
            (final String employee, _, _) => _EmployeeBody(
              query: AttendanceEmployeeQuery(
                employee: employee,
                fromDate: range.fromDate,
                toDate: range.toDate,
              ),
            ),
          },
        ),
      ],
    );
  }
}

class _EmployeePicker extends ConsumerWidget {
  const _EmployeePicker({required this.options, required this.selected});

  final List<AttendanceEmployeeOption> options;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // A selection that is no longer in the list (the month or branch filter
    // moved) must not be handed to DropdownButton — it asserts on a value with
    // no matching item.
    final value = options.any((o) => o.employee == selected) ? selected : null;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  hint: Text(l10n.attendancePickEmployee),
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.employee,
                          child: Text(
                            option.employeeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (next) => ref
                      .read(attendanceSelectedEmployeeProvider.notifier)
                      .state = next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeBody extends ConsumerWidget {
  const _EmployeeBody({required this.query});

  final AttendanceEmployeeQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(attendanceEmployeeDataProvider(query));
    return detailAsync.when(
      data: (detail) => _EmployeeDetailView(detail: detail),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AttendanceErrorState(
        error: error,
        onRetry: () => ref.invalidate(attendanceEmployeeDataProvider(query)),
      ),
    );
  }
}

class _EmployeeDetailView extends StatelessWidget {
  const _EmployeeDetailView({required this.detail});

  final AttendanceEmployeeDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // `get_employee` now carries the same `scope` block as the other three,
    // so this tab can finally tell "your account is scoped to no branch" from
    // "this person has no days in the range" — two empty screens that ask for
    // completely different things to be done about them.
    //
    // `hasRows: true` keeps the generic "nobody is rostered" case switched
    // off here: an employee with no days in the range is reported by the
    // timeline section itself, in the singular, which reads correctly for one
    // named person.
    final blocking = attendanceBlockingState(
      context,
      hrmsAvailable: detail.hrmsAvailable,
      notice: detail.notice,
      scope: detail.scope,
      hasRows: true,
    );
    if (blocking != null) return blocking;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (detail.notice != null)
          AttendanceNoticeBanner(notice: detail.notice!),
        if (!detail.hasAnyCheckin) const AttendanceNoCheckinsBanner(),

        // Header: who, where they normally are, and the range in force.
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.employeeName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                [
                  if ((detail.designation ?? '').isNotEmpty) detail.designation!,
                  if ((detail.department ?? '').isNotEmpty) detail.department!,
                  if (detail.shiftLocations.isNotEmpty)
                    detail.shiftLocations.join(' · '),
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        _EmployeeTotals(totals: detail.totals),

        _SectionHeader(title: l10n.attendanceByBranchTitle),
        if (detail.byBranch.isEmpty)
          _EmptyLine(text: l10n.attendanceByBranchEmpty)
        else
          for (final branch in detail.byBranch)
            _BranchBreakdownTile(breakdown: branch),

        _SectionHeader(title: l10n.attendanceTimelineTitle),
        if (detail.days.isEmpty)
          _EmptyLine(text: l10n.attendanceTimelineEmpty)
        else
          for (final day in detail.days)
            _TimelineTile(
              day: day,
              employeeName: detail.employeeName,
              designation: detail.designation,
              graceMinutes: detail.graceMinutes,
            ),

        _SectionHeader(title: l10n.attendanceCheckinsTitle),
        if (detail.checkins.isEmpty)
          _EmptyLine(text: l10n.attendanceCheckinsEmpty)
        else
          for (final checkin in detail.checkins) _CheckinTile(checkin: checkin),
      ],
    );
  }
}

class _EmployeeTotals extends StatelessWidget {
  const _EmployeeTotals({required this.totals});

  final AttendanceTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        children: [
          _Stat(
            label: l10n.attendanceMetricRostered,
            value: attendanceCount(context, totals.rosteredDays),
          ),
          _Stat(
            label: l10n.attendanceMetricPresent,
            value: attendanceCount(context, totals.presentDays),
            status: AttendanceStatus.present,
          ),
          _Stat(
            label: l10n.attendanceMetricLate,
            value: attendanceCount(context, totals.lateDays),
            status: AttendanceStatus.late,
          ),
          _Stat(
            label: l10n.attendanceMetricLateUnmatched,
            value: attendanceCount(context, totals.lateUnmatchedDays),
            status: AttendanceStatus.lateUnmatched,
          ),
          _Stat(
            label: l10n.attendanceMetricAbsent,
            value: attendanceCount(context, totals.absentDays),
            status: AttendanceStatus.absent,
          ),
          _Stat(
            label: l10n.attendanceMetricPending,
            value: attendanceCount(context, totals.pendingDays),
            status: AttendanceStatus.pending,
          ),
          _Stat(
            label: l10n.attendanceMetricOff,
            value: attendanceCount(context, totals.offDays),
            status: AttendanceStatus.off,
          ),
          _Stat(
            label: l10n.attendanceMetricWorkedHours,
            value: attendanceHours(context, totals.workedHours),
          ),
          _Stat(
            label: l10n.attendanceMetricLateMinutes,
            value: attendanceCount(context, totals.lateMinutes),
          ),
          _Stat(
            label: l10n.attendanceMetricAttendanceRate,
            value: attendanceRateOrNoRoster(
              context,
              totals.attendanceRate,
              totals.rosteredDays,
            ),
          ),
          _Stat(
            label: l10n.attendanceMetricPunctualityRate,
            value: attendanceRateOrNoRoster(
              context,
              totals.punctualityRate,
              totals.punctualityDenominator,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.status});

  final String label;
  final String value;
  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = status == null
        ? null
        : AttendanceStatusStyle.of(context, status!);
    return Column(
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
    );
  }
}

class _BranchBreakdownTile extends StatelessWidget {
  const _BranchBreakdownTile({required this.breakdown});

  final AttendanceBranchBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
      child: Row(
        children: [
          Icon(
            Icons.store_outlined,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attendanceBranchLabel(context, breakdown.shiftLocation),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          _MiniStat(
            label: l10n.attendanceMetricRostered,
            value: attendanceCount(context, breakdown.rosteredDays),
          ),
          _MiniStat(
            label: l10n.attendanceMetricPresent,
            value: attendanceCount(context, breakdown.presentDays),
          ),
          _MiniStat(
            label: l10n.attendanceMetricLate,
            value: attendanceCount(context, breakdown.lateDays),
          ),
          _MiniStat(
            label: l10n.attendanceMetricAbsent,
            value: attendanceCount(context, breakdown.absentDays),
          ),
          _MiniStat(
            label: l10n.attendanceMetricWorkedHours,
            value: attendanceHours(context, breakdown.workedHours),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10),
      child: Column(
        children: [
          Text(
            value,
            style: attendanceNumeric(
              theme.textTheme.labelLarge,
            )?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.day,
    required this.employeeName,
    required this.designation,
    required this.graceMinutes,
  });

  final AttendanceCell day;
  final String employeeName;
  final String? designation;
  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AttendanceStatusStyle.of(
      context,
      day.status,
      lateMinutes: day.lateMinutes,
      graceMinutes: graceMinutes,
    );

    return InkWell(
      onTap: () => showAttendanceDaySheet(
        context,
        employeeName: employeeName,
        designation: designation,
        cell: day,
        graceMinutes: graceMinutes,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                attendanceDateLabel(context, day.date, pattern: 'E d MMM'),
                style: attendanceNumeric(theme.textTheme.labelSmall),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(style.icon, size: 14, color: style.foreground),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${attendanceClock(context, day.firstIn)} • '
                '${attendanceClock(context, day.lastOut)}',
                style: attendanceNumeric(theme.textTheme.bodySmall),
              ),
            ),
            Text(
              day.workedHours == null
                  ? attendanceEmptyValue
                  : '${attendanceHours(context, day.workedHours)} '
                        '${context.l10n.attendanceHoursUnit}',
              style: attendanceNumeric(theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckinTile extends StatelessWidget {
  const _CheckinTile({required this.checkin});

  final AttendanceCheckin checkin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            attendanceDateLabel(context, checkin.time, pattern: 'd MMM'),
            style: attendanceNumeric(theme.textTheme.labelSmall),
          ),
          const SizedBox(width: 8),
          Text(
            attendanceClock(context, checkin.time),
            style: attendanceNumeric(
              theme.textTheme.bodyMedium,
            )?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              checkin.logType ?? attendanceEmptyValue,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (checkin.offshift)
            Tooltip(
              message: l10n.attendanceOffshiftValue,
              child: Icon(
                Icons.timer_off,
                size: 14,
                color: theme.colorScheme.tertiary,
              ),
            ),
          const SizedBox(width: 6),
          // Tri-state, and each state gets its own glyph: inside the fence,
          // outside it, or no coordinates recorded at all.
          Tooltip(
            message: switch (checkin.geoOk) {
              true => l10n.attendanceGeoInside,
              false => l10n.attendanceGeoOutside,
              null => l10n.attendanceGeoUnknown,
            },
            child: Icon(
              switch (checkin.geoOk) {
                true => Icons.location_on,
                false => Icons.wrong_location_outlined,
                null => Icons.location_searching,
              },
              size: 14,
              color: switch (checkin.geoOk) {
                true => theme.colorScheme.primary,
                false => theme.colorScheme.error,
                null => theme.colorScheme.outline,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 6),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
