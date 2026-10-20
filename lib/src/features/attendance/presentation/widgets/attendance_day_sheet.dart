import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../branch_access/presentation/server_error_text.dart';
import '../../data/attendance_repository.dart';
import '../../models/attendance_models.dart';
import '../../state/attendance_providers.dart';
import '../attendance_format.dart';
import 'attendance_checkout_badge.dart';
import 'attendance_device_flag.dart';
import 'attendance_states.dart';
import 'attendance_status_style.dart';

/// Stable keys so the tests can drive the approve flow.
const Key attendanceApproveDeviceKey = ValueKey<String>(
  'attendance-approve-device',
);
const Key attendanceLogTypeNoteKey = ValueKey<String>(
  'attendance-log-type-note',
);

/// One employee, one day: scheduled against actual.
///
/// The sheet exists because the grid cell can only carry a status. The
/// question a manager actually asks — "they are amber, how late, and were they
/// even at the branch?" — is answered here.
///
/// With [employee] given, a "New Device" day offers "Approve this phone" to a
/// user the bootstrap says may approve (`can_approve_device`).
class AttendanceDaySheet extends ConsumerStatefulWidget {
  const AttendanceDaySheet({
    super.key,
    required this.employeeName,
    required this.cell,
    this.employee,
    this.designation,
    this.graceMinutes = 15,
  });

  final String employeeName;

  /// The Employee id (`HR-EMP-00001`). Without it there is nothing to
  /// approve the phone for, so the button never shows.
  final String? employee;
  final String? designation;
  final AttendanceCell cell;
  final int graceMinutes;

  @override
  ConsumerState<AttendanceDaySheet> createState() => _AttendanceDaySheetState();
}

class _AttendanceDaySheetState extends ConsumerState<AttendanceDaySheet> {
  bool _approving = false;
  String? _approveError;

  AttendanceCell get cell => widget.cell;
  String get employeeName => widget.employeeName;
  String? get designation => widget.designation;
  int get graceMinutes => widget.graceMinutes;

  bool get _canOfferApproval {
    final employee = (widget.employee ?? '').trim();
    if (employee.isEmpty || cell.date.isEmpty) return false;
    if (!cell.deviceFlags.contains(kDeviceFlagNew)) return false;
    final bootstrap = ref.watch(attendanceBootstrapProvider).valueOrNull;
    return bootstrap?.canApproveDevice ?? false;
  }

  Future<void> _approve() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.attendanceApproveDeviceConfirmTitle),
        content: Text(l10n.attendanceApproveDeviceConfirmBody(employeeName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.attendanceApproveDevice),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _approving = true;
      _approveError = null;
    });
    try {
      await ref
          .read(attendanceRepositoryProvider)
          .approveDevice(employee: widget.employee!.trim(), date: cell.date);
      if (!mounted) return;
      // The flag is gone server-side; everything that drew it reloads.
      ref.invalidate(attendanceMonthDataProvider);
      ref.invalidate(attendanceDayDataProvider);
      ref.invalidate(attendanceEmployeeDataProvider);
      ref.invalidate(attendanceSummaryDataProvider);
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.of(context).pop();
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.attendanceApproveDeviceDone(employeeName))),
      );
    } catch (error) {
      if (!mounted) return;
      // Shown inside the sheet: a snackbar would sit behind it.
      setState(() {
        _approving = false;
        _approveError = l10n.attendanceApproveDeviceFailed(
          serverErrorText(context, error),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = AttendanceStatusStyle.of(
      context,
      cell.status,
      lateMinutes: cell.lateMinutes,
      graceMinutes: graceMinutes,
    );
    final lateMinutes = cell.lateMinutes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        attendanceDateLabel(
                          context,
                          cell.date,
                          pattern: 'EEEE, d MMMM yyyy',
                        ),
                        style: attendanceNumeric(
                          theme.textTheme.bodySmall,
                        )?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if ((designation ?? '').isNotEmpty)
                        Text(
                          designation!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                AttendanceStatusChip(
                  status: cell.status,
                  lateMinutes: cell.lateMinutes,
                  graceMinutes: graceMinutes,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cell.status == AttendanceStatus.unknown &&
                      cell.rawStatus.isNotEmpty
                  // An unrecognised status is shown verbatim next to its
                  // explanation, so a backend that grew a ninth status is
                  // diagnosable from the phone rather than invisible.
                  ? '${style.explanation} (${cell.rawStatus})'
                  : style.explanation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),

            // Scheduled vs actual, side by side — the comparison the whole
            // screen is about.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TimeBlock(
                    caption: l10n.attendanceScheduled,
                    start: cell.scheduledStart,
                    end: cell.scheduledEnd,
                  ),
                ),
                Icon(
                  Icons.compare_arrows,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                Expanded(
                  child: _TimeBlock(
                    caption: l10n.attendanceActual,
                    start: cell.firstIn,
                    end: cell.lastOut,
                    emphasize: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (lateMinutes != null && lateMinutes != 0)
              _DetailRow(
                icon: lateMinutes > 0 ? Icons.schedule : Icons.bolt,
                label: lateMinutes > 0
                    ? l10n.attendanceLateBy
                    : l10n.attendanceEarlyBy,
                value:
                    '${attendanceCount(context, lateMinutes.abs())} '
                    '${l10n.attendanceMinutesUnit}',
                tone: lateMinutes > 0
                    ? AttendanceMessageTone.warning
                    : AttendanceMessageTone.neutral,
              ),
            _DetailRow(
              icon: Icons.timelapse,
              label: l10n.attendanceWorkedHours,
              value: cell.workedHours == null
                  ? attendanceEmptyValue
                  : '${attendanceHours(context, cell.workedHours)} '
                        '${l10n.attendanceHoursUnit}',
            ),
            _DetailRow(
              icon: Icons.fingerprint,
              label: l10n.attendanceCheckinCount,
              value: attendanceCount(context, cell.checkinCount),
            ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: l10n.attendanceGeoLabel,
              value: switch (cell.geoOk) {
                true => l10n.attendanceGeoInside,
                false => l10n.attendanceGeoOutside,
                // Tri-state on purpose: no coordinates is not "outside".
                null => l10n.attendanceGeoUnknown,
              },
              tone: cell.geoOk == false
                  ? AttendanceMessageTone.warning
                  : AttendanceMessageTone.neutral,
            ),
            if (cell.offshift)
              _DetailRow(
                icon: Icons.timer_off,
                label: l10n.attendanceOffshiftLabel,
                value: l10n.attendanceOffshiftValue,
                tone: AttendanceMessageTone.warning,
              ),
            _DetailRow(
              icon: Icons.badge_outlined,
              label: l10n.attendanceShiftType,
              value: cell.shiftType ?? attendanceEmptyValue,
            ),
            _DetailRow(
              icon: Icons.store_outlined,
              label: l10n.attendanceBranch,
              value: cell.shiftLocation == null
                  ? attendanceBranchLabel(context, null)
                  : cell.shiftLocation!,
            ),
            if (cell.hasCheckoutIssue) AttendanceCheckoutBadges(cell: cell),
            if ((cell.logTypeNote ?? '').isNotEmpty)
              Padding(
                key: attendanceLogTypeNoteKey,
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Text(
                  l10n.attendanceLogTypeNote(cell.logTypeNote!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (cell.hasDeviceFlag)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: AttendanceDeviceFlagChips(
                  flags: cell.deviceFlags,
                  detail: cell.deviceFlagDetail,
                ),
              ),
            if (_canOfferApproval) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.tonalIcon(
                  key: attendanceApproveDeviceKey,
                  onPressed: _approving ? null : _approve,
                  icon: _approving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_outlined),
                  label: Text(l10n.attendanceApproveDevice),
                ),
              ),
              if (_approveError != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6),
                  child: Text(
                    _approveError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            if (cell.isCover)
              _DetailRow(
                icon: Icons.swap_horiz,
                label: l10n.attendanceCoverDay,
                value: l10n.attendanceCoverDayValue,
              ),
            if (cell.dayOff != null) ...[
              const Divider(height: 24),
              _DetailRow(
                icon: Icons.weekend,
                label: l10n.attendanceOffType,
                value: cell.dayOff!.offType,
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: l10n.attendanceCoveredBy,
                value:
                    cell.dayOff!.coveredByName ??
                    cell.dayOff!.coveredBy ??
                    l10n.attendanceNobodyCovering,
                tone: cell.dayOff!.isCovered
                    ? AttendanceMessageTone.neutral
                    : AttendanceMessageTone.warning,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.caption,
    required this.start,
    required this.end,
    this.emphasize = false,
  });

  final String caption;
  final String? start;
  final String? end;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          // Times are server-local strings, printed as sent. The separator is
          // a bullet rather than an arrow so the line does not need a
          // direction to be read correctly in Arabic.
          '${attendanceClock(context, start)} • ${attendanceClock(context, end)}',
          style: attendanceNumeric(theme.textTheme.titleSmall)?.copyWith(
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.tone = AttendanceMessageTone.neutral,
  });

  final IconData icon;
  final String label;
  final String value;
  final AttendanceMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      AttendanceMessageTone.neutral => theme.colorScheme.onSurface,
      AttendanceMessageTone.warning => theme.colorScheme.tertiary,
      AttendanceMessageTone.error => theme.colorScheme.error,
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: attendanceNumeric(
              theme.textTheme.bodyMedium,
            )?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

Future<void> showAttendanceDaySheet(
  BuildContext context, {
  required String employeeName,
  required AttendanceCell cell,
  String? employee,
  String? designation,
  int graceMinutes = 15,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SingleChildScrollView(
      child: AttendanceDaySheet(
        employeeName: employeeName,
        employee: employee,
        cell: cell,
        designation: designation,
        graceMinutes: graceMinutes,
      ),
    ),
  );
}
