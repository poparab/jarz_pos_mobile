import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';

/// Month stepper + branch filter, for the Month tab.
class AttendanceMonthBar extends ConsumerWidget {
  const AttendanceMonthBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final month = ref.watch(attendanceMonthProvider);

    return _ControlSurface(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.attendancePreviousPeriod,
            onPressed: () => ref.read(attendanceMonthProvider.notifier).state =
                shiftAttendanceMonth(month, -1),
          ),
          Expanded(
            child: Text(
              attendanceMonthLabel(context, month),
              textAlign: TextAlign.center,
              style: attendanceNumeric(
                theme.textTheme.titleMedium,
              )?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.attendanceNextPeriod,
            onPressed: () => ref.read(attendanceMonthProvider.notifier).state =
                shiftAttendanceMonth(month, 1),
          ),
          const AttendanceBranchFilter(),
        ],
      ),
    );
  }
}

/// Day stepper + calendar picker + branch filter, for the Day tab.
class AttendanceDateBar extends ConsumerWidget {
  const AttendanceDateBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final date = ref.watch(attendanceDayProvider);
    final today = attendanceIsoDate(DateTime.now());

    return _ControlSurface(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.attendancePreviousPeriod,
            onPressed: () => ref.read(attendanceDayProvider.notifier).state =
                shiftAttendanceDay(date, -1),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await _pickDate(context, date);
                if (picked != null) {
                  ref.read(attendanceDayProvider.notifier).state = picked;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      attendanceDateLabel(
                        context,
                        date,
                        pattern: 'EEEE, d MMMM',
                      ),
                      textAlign: TextAlign.center,
                      style: attendanceNumeric(
                        theme.textTheme.titleSmall,
                      )?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (date == today)
                      Text(
                        l10n.attendanceToday,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.attendanceNextPeriod,
            onPressed: () => ref.read(attendanceDayProvider.notifier).state =
                shiftAttendanceDay(date, 1),
          ),
          const AttendanceBranchFilter(),
        ],
      ),
    );
  }
}

/// From/to range picker, for the Employee and Summary tabs.
class AttendanceRangeBar extends ConsumerWidget {
  const AttendanceRangeBar({super.key, this.showBranchFilter = false});

  final bool showBranchFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(attendanceRangeProvider);

    return _ControlSurface(
      child: Row(
        children: [
          Expanded(
            child: _RangeButton(
              caption: l10n.attendanceFromDate,
              value: range.fromDate,
              onPick: (picked) =>
                  ref.read(attendanceRangeProvider.notifier).state = range
                      .copyWith(fromDate: picked),
            ),
          ),
          Expanded(
            child: _RangeButton(
              caption: l10n.attendanceToDate,
              value: range.toDate,
              onPick: (picked) =>
                  ref.read(attendanceRangeProvider.notifier).state = range
                      .copyWith(toDate: picked),
            ),
          ),
          IconButton(
            tooltip: l10n.attendanceThisMonth,
            icon: const Icon(Icons.calendar_month),
            onPressed: () => ref.read(attendanceRangeProvider.notifier).state =
                AttendanceRange.ofMonth(attendanceMonthOf(DateTime.now())),
          ),
          if (showBranchFilter) const AttendanceBranchFilter(),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.caption,
    required this.value,
    required this.onPick,
  });

  final String caption;
  final String value;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final picked = await _pickDate(context, value);
        if (picked != null) onPick(picked);
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 6,
          vertical: 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              attendanceDateLabel(context, value, pattern: 'd MMM yyyy'),
              style: attendanceNumeric(
                theme.textTheme.bodyMedium,
              )?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// The branch dropdown, shared by every tab that filters by location.
///
/// Hidden entirely when the caller can only see one branch: a filter with a
/// single option is a control that cannot change anything.
class AttendanceBranchFilter extends ConsumerWidget {
  const AttendanceBranchFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final bootstrap = ref.watch(attendanceBootstrapProvider);
    final selected = ref.watch(attendanceLocationFilterProvider);
    final branches =
        bootstrap.asData?.value.shiftLocations
            .map((l) => l.shiftLocation)
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];

    if (branches.length < 2) return const SizedBox.shrink();

    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: selected,
        hint: Text(l10n.attendanceAllBranches),
        items: <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(
            value: null,
            child: Text(l10n.attendanceAllBranches),
          ),
          ...branches.map(
            (b) => DropdownMenuItem<String?>(value: b, child: Text(b)),
          ),
        ],
        onChanged: (value) =>
            ref.read(attendanceLocationFilterProvider.notifier).state = value,
      ),
    );
  }
}

class _ControlSurface extends StatelessWidget {
  const _ControlSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: child,
      ),
    );
  }
}

/// Opens the platform date picker on [isoDate] and returns `YYYY-MM-DD`.
///
/// Everything in and out is a plain date string: the picker's `DateTime` never
/// escapes this function, so no part of the feature can start doing timezone
/// arithmetic on a server-local day.
Future<String?> _pickDate(BuildContext context, String isoDate) async {
  final current = DateTime.tryParse(isoDate) ?? DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(current.year - 3),
    lastDate: DateTime(DateTime.now().year + 1, 12, 31),
  );
  return picked == null ? null : attendanceIsoDate(picked);
}
