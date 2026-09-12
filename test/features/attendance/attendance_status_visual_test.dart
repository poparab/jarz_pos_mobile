import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_status_visual.dart';

/// The status resolver is the feature's one point of truth about what a status
/// looks like. These tests hold the three properties the screens depend on:
/// every status is distinguishable, the distinction that matters most
/// (`absent` vs `not_rostered`) is the loudest one, and nothing ever renders
/// on colour alone.
///
/// Resolved from a plain [ColorScheme] rather than a pumped widget precisely so
/// this can be asserted without a screen.
void main() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3F6FA6));

  group('attendanceStatusVisual', () {
    test('every status resolves to its own colour + glyph pair', () {
      final pairs = <String>{};
      for (final status in AttendanceStatus.values) {
        final visual = attendanceStatusVisual(scheme, status);
        expect(
          visual.status,
          status,
          reason: 'the resolver must not silently remap a status',
        );
        pairs.add('${visual.background.toARGB32()}|${visual.icon.codePoint}');
      }

      expect(
        pairs,
        hasLength(AttendanceStatus.values.length),
        reason: 'two statuses that look identical cannot be told apart',
      );
    });

    test('every status carries a glyph, so colour is never the only channel', () {
      for (final status in AttendanceStatus.values) {
        final visual = attendanceStatusVisual(scheme, status);
        expect(visual.icon.codePoint, isNonZero);
      }
    });

    test('absent and not_rostered look nothing alike', () {
      // The whole point of the feature: somebody who was expected and did not
      // come, versus a day nobody was asked to work.
      final absent = attendanceStatusVisual(scheme, AttendanceStatus.absent);
      final notRostered = attendanceStatusVisual(
        scheme,
        AttendanceStatus.notRostered,
      );

      expect(absent.background, isNot(notRostered.background));
      expect(absent.foreground, isNot(notRostered.foreground));
      expect(absent.icon, isNot(notRostered.icon));
      expect(absent.severity, 3);
      expect(notRostered.severity, 0);
    });

    test('absent is the loudest negative on the screen', () {
      final absent = attendanceStatusVisual(scheme, AttendanceStatus.absent);
      final everythingElse = AttendanceStatus.values
          .where((s) => s != AttendanceStatus.absent)
          .map((s) => attendanceStatusVisual(scheme, s).severity);

      expect(everythingElse.every((s) => s < absent.severity), isTrue);
      // Solid error, not a tinted container — nothing else on the feature uses
      // the raw error role.
      expect(absent.background, scheme.error);
    });

    test('off, holiday and not_rostered are muted, never alarms', () {
      for (final status in const [
        AttendanceStatus.off,
        AttendanceStatus.holiday,
        AttendanceStatus.notRostered,
      ]) {
        final visual = attendanceStatusVisual(scheme, status);
        expect(visual.severity, 0, reason: '$status must not read as a fault');
        expect(visual.background, isNot(scheme.error));
      }
    });

    test('off and holiday are still distinct from each other', () {
      expect(
        attendanceStatusVisual(scheme, AttendanceStatus.off).background,
        isNot(attendanceStatusVisual(scheme, AttendanceStatus.holiday).background),
      );
    });

    test('present is the only positive hue', () {
      final present = attendanceStatusVisual(scheme, AttendanceStatus.present);

      expect(present.background, scheme.primaryContainer);
      expect(present.severity, 0);
      for (final status in AttendanceStatus.values) {
        if (status == AttendanceStatus.present) continue;
        expect(
          attendanceStatusVisual(scheme, status).background,
          isNot(scheme.primaryContainer),
        );
      }
    });

    test('pending is neutral-awaiting, not a warning', () {
      final pending = attendanceStatusVisual(scheme, AttendanceStatus.pending);

      expect(pending.severity, 0);
      expect(pending.background, scheme.secondaryContainer);
    });

    test('late_unmatched warns, with its own outside-the-window glyph', () {
      final late = attendanceStatusVisual(scheme, AttendanceStatus.late);
      final unmatched = attendanceStatusVisual(
        scheme,
        AttendanceStatus.lateUnmatched,
      );

      expect(unmatched.severity, greaterThan(0));
      expect(unmatched.icon, isNot(late.icon));
      expect(unmatched.icon, Icons.timer_off);
    });

    test('an unknown status is muted and neutral rather than an error', () {
      final unknown = attendanceStatusVisual(scheme, AttendanceStatus.unknown);

      expect(unknown.severity, 0);
      expect(unknown.icon, Icons.help_outline);
      expect(unknown.background, isNot(scheme.error));
    });

    test('a status parsed from a garbage string still resolves', () {
      // The end-to-end version of the degradation: unrecognised wire value ->
      // unknown -> a real, drawable style. Never an exception in a builder.
      final status = attendanceStatusFromWire('invented_by_a_later_backend');
      expect(
        () => attendanceStatusVisual(scheme, status),
        returnsNormally,
      );
      expect(attendanceStatusVisual(scheme, status).status,
          AttendanceStatus.unknown);
    });

    test('the visual value type compares by value', () {
      expect(
        attendanceStatusVisual(scheme, AttendanceStatus.present),
        attendanceStatusVisual(scheme, AttendanceStatus.present),
      );
    });
  });

  group('lateness severity', () {
    test('reads from the minutes, in multiples of the grace window', () {
      expect(attendanceLateSeverity(5, graceMinutes: 15), 1);
      expect(attendanceLateSeverity(30, graceMinutes: 15), 1);
      expect(attendanceLateSeverity(45, graceMinutes: 15), 2);
      expect(attendanceLateSeverity(90, graceMinutes: 15), 3);
    });

    test('scales with a site that widened its grace', () {
      // 45 minutes late is severity 2 on a 15-minute grace and severity 1 on a
      // 30-minute one. The thresholds follow the rule, not a hardcoded number.
      expect(attendanceLateSeverity(45, graceMinutes: 30), 1);
      expect(attendanceLateSeverity(70, graceMinutes: 30), 2);
    });

    test('null, zero and negative minutes are the mildest case', () {
      expect(attendanceLateSeverity(null), 1);
      expect(attendanceLateSeverity(0), 1);
      expect(attendanceLateSeverity(-20), 1);
    });

    test('a worse lateness paints a different colour', () {
      final mild = attendanceStatusVisual(
        scheme,
        AttendanceStatus.late,
        lateMinutes: 5,
      );
      final bad = attendanceStatusVisual(
        scheme,
        AttendanceStatus.late,
        lateMinutes: 45,
      );
      final worst = attendanceStatusVisual(
        scheme,
        AttendanceStatus.late,
        lateMinutes: 200,
      );

      expect(mild.background, isNot(bad.background));
      expect(bad.background, isNot(worst.background));
      // Same hue family throughout: one meaning, one colour, escalating.
      expect(mild.icon, bad.icon);
      expect(bad.icon, worst.icon);
    });
  });
}
