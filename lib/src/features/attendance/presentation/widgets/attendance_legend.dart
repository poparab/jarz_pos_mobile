import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import 'attendance_status_style.dart';

/// What the cells mean, generated from [kAttendanceStatusOrder] and the same
/// resolver the cells use.
///
/// Generated rather than hand-listed on purpose: a legend written out by hand
/// is one status away from describing a colour the grid no longer paints, and
/// this feature's whole value rests on the reader trusting that `absent` and
/// `not_rostered` really are different things.
class AttendanceLegend extends StatelessWidget {
  const AttendanceLegend({super.key, this.graceMinutes = 15});

  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Row(
          children: [
            for (final status in kAttendanceStatusOrder)
              _LegendChip(status: status, graceMinutes: graceMinutes),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.status, required this.graceMinutes});

  final AttendanceStatus status;
  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AttendanceStatusStyle.of(
      context,
      status,
      graceMinutes: graceMinutes,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Tooltip(
        message: style.explanation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(style.icon, size: 11, color: style.foreground),
            ),
            const SizedBox(width: 5),
            Text(style.label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// The legend as a vertical list with explanations — shown from the month
/// tab's "what do these mean?" action, where there is room for the sentences.
class AttendanceLegendSheet extends StatelessWidget {
  const AttendanceLegendSheet({super.key, this.graceMinutes = 15});

  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.attendanceLegendTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final status in kAttendanceStatusOrder)
              _LegendRow(status: status, graceMinutes: graceMinutes),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.status, required this.graceMinutes});

  final AttendanceStatus status;
  final int graceMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AttendanceStatusStyle.of(
      context,
      status,
      graceMinutes: graceMinutes,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(style.icon, size: 14, color: style.foreground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  style.explanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the explained legend.
Future<void> showAttendanceLegendSheet(
  BuildContext context, {
  int graceMinutes = 15,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SingleChildScrollView(
      child: AttendanceLegendSheet(graceMinutes: graceMinutes),
    ),
  );
}
