import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';
import '../attendance_format.dart';
import 'attendance_status_visual.dart';

export 'attendance_status_visual.dart';

/// A resolved status, with its words attached.
@immutable
class AttendanceStatusStyle {
  const AttendanceStatusStyle({
    required this.visual,
    required this.label,
    required this.token,
    required this.explanation,
  });

  final AttendanceStatusVisual visual;

  /// The full name: "Late", "متأخر".
  final String label;

  /// One or two characters for a calendar cell. Present in ADDITION to the
  /// colour and the glyph, never instead of them.
  final String token;

  /// Why this status happened, in a sentence — the legend and the day sheet
  /// both print it, so nobody has to guess what "outside window" means.
  final String explanation;

  AttendanceStatus get status => visual.status;
  Color get background => visual.background;
  Color get foreground => visual.foreground;
  IconData get icon => visual.icon;
  int get severity => visual.severity;

  static AttendanceStatusStyle of(
    BuildContext context,
    AttendanceStatus status, {
    int? lateMinutes,
    int graceMinutes = 15,
  }) {
    final l10n = context.l10n;
    final visual = attendanceStatusVisual(
      Theme.of(context).colorScheme,
      status,
      lateMinutes: lateMinutes,
      graceMinutes: graceMinutes,
    );
    final (label, token, explanation) = switch (status) {
      AttendanceStatus.present => (
        l10n.attendanceStatusPresent,
        l10n.attendanceTokenPresent,
        l10n.attendanceStatusPresentWhy,
      ),
      AttendanceStatus.late => (
        l10n.attendanceStatusLate,
        l10n.attendanceTokenLate,
        l10n.attendanceStatusLateWhy,
      ),
      AttendanceStatus.lateUnmatched => (
        l10n.attendanceStatusLateUnmatched,
        l10n.attendanceTokenLateUnmatched,
        l10n.attendanceStatusLateUnmatchedWhy,
      ),
      AttendanceStatus.absent => (
        l10n.attendanceStatusAbsent,
        l10n.attendanceTokenAbsent,
        l10n.attendanceStatusAbsentWhy,
      ),
      AttendanceStatus.pending => (
        l10n.attendanceStatusPending,
        l10n.attendanceTokenPending,
        l10n.attendanceStatusPendingWhy,
      ),
      AttendanceStatus.off => (
        l10n.attendanceStatusOff,
        l10n.attendanceTokenOff,
        l10n.attendanceStatusOffWhy,
      ),
      AttendanceStatus.holiday => (
        l10n.attendanceStatusHoliday,
        l10n.attendanceTokenHoliday,
        l10n.attendanceStatusHolidayWhy,
      ),
      AttendanceStatus.notRostered => (
        l10n.attendanceStatusNotRostered,
        l10n.attendanceTokenNotRostered,
        l10n.attendanceStatusNotRosteredWhy,
      ),
      AttendanceStatus.unknown => (
        l10n.attendanceStatusUnknown,
        l10n.attendanceTokenUnknown,
        l10n.attendanceStatusUnknownWhy,
      ),
    };
    return AttendanceStatusStyle(
      visual: visual,
      label: label,
      token: token,
      explanation: explanation,
    );
  }
}

/// Colour + glyph + word, for a row or a header.
class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({
    super.key,
    required this.status,
    this.lateMinutes,
    this.graceMinutes = 15,
    this.compact = false,
  });

  final AttendanceStatus status;
  final int? lateMinutes;
  final int graceMinutes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = AttendanceStatusStyle.of(
      context,
      status,
      lateMinutes: lateMinutes,
      graceMinutes: graceMinutes,
    );
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 12 : 14, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one square the month grid is made of.
///
/// Token first, glyph under it — the colour is the third channel, not the only
/// one.
class AttendanceStatusSquare extends StatelessWidget {
  const AttendanceStatusSquare({
    super.key,
    required this.status,
    this.lateMinutes,
    this.graceMinutes = 15,
    this.width = 46,
    this.height = 52,
    this.isCover = false,
  });

  final AttendanceStatus status;
  final int? lateMinutes;
  final int graceMinutes;
  final double width;
  final double height;

  /// A day somebody worked in place of a colleague who was off.
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AttendanceStatusStyle.of(
      context,
      status,
      lateMinutes: lateMinutes,
      graceMinutes: graceMinutes,
    );
    final minutes = lateMinutes ?? 0;
    final showMinutes = status == AttendanceStatus.late && minutes > 0;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
        border: isCover
            ? Border.all(color: theme.colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            style.token,
            style: attendanceNumeric(
              theme.textTheme.labelMedium,
            )?.copyWith(color: style.foreground, fontWeight: FontWeight.w700),
          ),
          Icon(style.icon, size: 10, color: style.foreground),
          if (showMinutes)
            Text(
              attendanceCount(context, minutes),
              style: attendanceNumeric(theme.textTheme.labelSmall)?.copyWith(
                color: style.foreground,
                fontSize: 9,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}
