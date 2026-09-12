import 'package:flutter/material.dart';

import '../../models/attendance_models.dart';

/// The single source of truth for what an attendance status looks like.
///
/// Every cell, chip, row and legend entry on this feature is generated from
/// here, so the grid and its legend cannot drift apart — the failure mode the
/// sibling roster screen is being fixed for right now.
///
/// Three rules it enforces:
///
/// * **One semantic hue per meaning.** `present` is the positive hue,
///   `late`/`late_unmatched` share the warning hue, `absent` is the loudest
///   negative, `pending` is neutral-awaiting, and `off`/`holiday`/
///   `not_rostered` are muted informational. Nothing borrows another
///   meaning's colour.
/// * **Never colour alone.** Each status also carries a glyph and a short text
///   token, so the grid survives colour blindness, a dim screen in a kitchen,
///   and a printout.
/// * **`absent` and `not_rostered` must never look alike.** One is somebody
///   who was expected and did not come; the other is a day nobody was asked to
///   work. Telling those two apart is the entire point of the feature, so they
///   sit at opposite ends of the palette — solid error versus flat muted grey.
@immutable
class AttendanceStatusVisual {
  const AttendanceStatusVisual({
    required this.status,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.severity,
  });

  final AttendanceStatus status;
  final Color background;
  final Color foreground;
  final IconData icon;

  /// 0 = informational, 1 = warning, 2 = bad, 3 = worst.
  ///
  /// For [AttendanceStatus.late] it is read from `late_minutes`: ten minutes
  /// over and an hour over are not the same event, and a screen that paints
  /// them identically teaches people to ignore the colour.
  final int severity;

  @override
  bool operator ==(Object other) =>
      other is AttendanceStatusVisual &&
      other.status == status &&
      other.background == background &&
      other.foreground == foreground &&
      other.icon == icon &&
      other.severity == severity;

  @override
  int get hashCode =>
      Object.hash(status, background, foreground, icon, severity);
}

/// Lateness severity thresholds, expressed in multiples of the grace window so
/// a site that widens its grace does not suddenly paint everyone amber.
///
/// With the default 15-minute grace: up to 30 minutes late is severity 1,
/// up to 60 is severity 2, beyond that severity 3.
int attendanceLateSeverity(int? lateMinutes, {int graceMinutes = 15}) {
  final minutes = lateMinutes ?? 0;
  if (minutes <= 0) return 1;
  final grace = graceMinutes > 0 ? graceMinutes : 15;
  if (minutes > grace * 4) return 3;
  if (minutes > grace * 2) return 2;
  return 1;
}

/// Resolves colour + glyph for a status, from a [ColorScheme] rather than a
/// [BuildContext] so it is unit-testable and so no raw hex ever appears in a
/// widget — the same discipline as `manufacturing/.../status_chip.dart`.
AttendanceStatusVisual attendanceStatusVisual(
  ColorScheme scheme,
  AttendanceStatus status, {
  int? lateMinutes,
  int graceMinutes = 15,
}) {
  switch (status) {
    // Good. The positive hue, and the only one that carries it.
    case AttendanceStatus.present:
      return AttendanceStatusVisual(
        status: status,
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
        icon: Icons.check_circle,
        severity: 0,
      );

    // Warning, escalating with the minutes. The hue stays amber and leans
    // toward error as it gets worse, so a row of late cells reads as one
    // worsening thing rather than as three unrelated colours.
    case AttendanceStatus.late:
      final severity = attendanceLateSeverity(
        lateMinutes,
        graceMinutes: graceMinutes,
      );
      return AttendanceStatusVisual(
        status: status,
        background: switch (severity) {
          3 => Color.alphaBlend(
            scheme.error.withValues(alpha: 0.36),
            scheme.tertiaryContainer,
          ),
          2 => Color.alphaBlend(
            scheme.error.withValues(alpha: 0.18),
            scheme.tertiaryContainer,
          ),
          _ => scheme.tertiaryContainer,
        },
        foreground: scheme.onTertiaryContainer,
        icon: Icons.schedule,
        severity: severity,
      );

    // A punch exists, but outside the shift window — the server could not
    // match it to a start time. Same warning family, its own glyph, because
    // the action it asks for is different: somebody has to look at the punch.
    case AttendanceStatus.lateUnmatched:
      return AttendanceStatusVisual(
        status: status,
        background: Color.alphaBlend(
          scheme.tertiary.withValues(alpha: 0.22),
          scheme.surfaceContainerHighest,
        ),
        foreground: scheme.onSurface,
        icon: Icons.timer_off,
        severity: 2,
      );

    // The loudest thing on the screen: rostered, the day has gone, nobody came.
    case AttendanceStatus.absent:
      return AttendanceStatusVisual(
        status: status,
        background: scheme.error,
        foreground: scheme.onError,
        icon: Icons.person_off,
        severity: 3,
      );

    // Rostered, today or later — nothing has gone wrong yet.
    case AttendanceStatus.pending:
      return AttendanceStatusVisual(
        status: status,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        icon: Icons.hourglass_bottom,
        severity: 0,
      );

    // Granted leave. Muted informational: an approved day off is not an alarm,
    // and painting it like one is how a screen full of red stops meaning
    // anything.
    case AttendanceStatus.off:
      return AttendanceStatusVisual(
        status: status,
        background: Color.alphaBlend(
          scheme.secondary.withValues(alpha: 0.14),
          scheme.surfaceContainerHighest,
        ),
        foreground: scheme.onSurfaceVariant,
        icon: Icons.weekend,
        severity: 0,
      );

    case AttendanceStatus.holiday:
      return AttendanceStatusVisual(
        status: status,
        background: Color.alphaBlend(
          scheme.primary.withValues(alpha: 0.12),
          scheme.surfaceContainerHighest,
        ),
        foreground: scheme.onSurfaceVariant,
        icon: Icons.flag,
        severity: 0,
      );

    // Nobody was expected. Flat and quiet, and deliberately as far from
    // `absent` as the palette goes.
    case AttendanceStatus.notRostered:
      return AttendanceStatusVisual(
        status: status,
        background: scheme.surfaceContainerHighest,
        foreground: scheme.outline,
        icon: Icons.remove,
        severity: 0,
      );

    // A status string this build has never heard of. Renders as a visible
    // question rather than throwing inside a list builder.
    case AttendanceStatus.unknown:
      return AttendanceStatusVisual(
        status: status,
        background: scheme.surfaceContainerLow,
        foreground: scheme.onSurfaceVariant,
        icon: Icons.help_outline,
        severity: 0,
      );
  }
}
