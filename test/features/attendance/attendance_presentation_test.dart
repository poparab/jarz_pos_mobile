import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/presentation/attendance_format.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_states.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_status_style.dart';

/// The half of the design contract that needs a locale: the words attached to
/// each status, the "no branch resolved" label, and the rule that one locale
/// gets exactly one numeral system.
Future<T> _withContext<T>(
  WidgetTester tester,
  Locale locale,
  T Function(BuildContext context) body,
) async {
  late T result;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            result = body(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}

/// Any Western digit at all, which in an Arabic rendering is the bug.
final _asciiDigits = RegExp(r'[0-9]');
final _arabicIndicDigits = RegExp(r'[٠-٩]');

void main() {
  group('status wording', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('every status has a label, token and explanation in '
          '${locale.languageCode}', (tester) async {
        final styles = await _withContext(
          tester,
          locale,
          (context) => <AttendanceStatus, AttendanceStatusStyle>{
            for (final status in AttendanceStatus.values)
              status: AttendanceStatusStyle.of(context, status),
          },
        );

        for (final entry in styles.entries) {
          expect(
            entry.value.label.trim(),
            isNotEmpty,
            reason: '${entry.key} has no label',
          );
          expect(
            entry.value.token.trim(),
            isNotEmpty,
            reason: '${entry.key} has no short token — a cell would then be '
                'distinguished by colour alone',
          );
          expect(
            entry.value.explanation.trim(),
            isNotEmpty,
            reason: '${entry.key} has no explanation for the legend',
          );
        }
      });

      testWidgets('no two statuses share a label in ${locale.languageCode}', (
        tester,
      ) async {
        final labels = await _withContext(
          tester,
          locale,
          (context) => [
            for (final status in AttendanceStatus.values)
              AttendanceStatusStyle.of(context, status).label,
          ],
        );

        expect(labels.toSet(), hasLength(labels.length));
      });
    }

    testWidgets('absent and not_rostered are worded differently too', (
      tester,
    ) async {
      final pair = await _withContext(tester, const Locale('ar'), (context) {
        return [
          AttendanceStatusStyle.of(context, AttendanceStatus.absent),
          AttendanceStatusStyle.of(context, AttendanceStatus.notRostered),
        ];
      });

      expect(pair.first.label, isNot(pair.last.label));
      expect(pair.first.token, isNot(pair.last.token));
      expect(pair.first.explanation, isNot(pair.last.explanation));
    });

    testWidgets('the legend covers every status the grid can draw', (
      tester,
    ) async {
      final covered = await _withContext(tester, const Locale('en'), (context) {
        return {
          for (final status in kAttendanceStatusOrder)
            AttendanceStatusStyle.of(context, status).label,
        };
      });

      expect(covered, hasLength(kAttendanceStatusOrder.length));
    });
  });

  group('branch labelling', () {
    testWidgets('a null branch is named, never blank', (tester) async {
      final labels = await _withContext(tester, const Locale('ar'), (context) {
        return [
          attendanceBranchLabel(context, null),
          attendanceBranchLabel(context, '   '),
          attendanceBranchLabel(context, 'Nasr City'),
        ];
      });

      expect(labels[0].trim(), isNotEmpty);
      // Whitespace is the same thing as null here: the server sent nothing.
      expect(labels[1], labels[0]);
      expect(labels[2], 'Nasr City');
      expect(labels[0], isNot('Nasr City'));
    });
  });

  group('rates', () {
    testWidgets('render as percentages', (tester) async {
      final rendered = await _withContext(tester, const Locale('en'), (
        context,
      ) {
        return [
          attendanceRate(context, 0.0),
          attendanceRate(context, 0.5),
          attendanceRate(context, 0.8333),
          attendanceRate(context, 1.0),
        ];
      });

      expect(rendered[0], '0%');
      expect(rendered[1], '50%');
      expect(rendered[2], '83%');
      expect(rendered[3], '100%');
    });

    testWidgets('a zero denominator says "no roster", not "missing"', (
      tester,
    ) async {
      // Now that the printed numbers add up to the rate, a zero denominator is
      // a fact about the period — nobody was rostered — and not a gap in the
      // payload. The em dash claimed the latter.
      final rendered = await _withContext(tester, const Locale('en'), (
        context,
      ) {
        return [
          attendanceRateOrNoRoster(context, 0.0, 0),
          attendanceRateOrNoRoster(context, 0.0, 4),
          attendanceRateOrNoRoster(context, 0.75, 4),
        ];
      });

      expect(rendered[0], isNot(attendanceEmptyValue));
      expect(rendered[0].trim(), isNotEmpty);
      expect(rendered[0], isNot(contains('%')));
      // A genuine zero out of a real denominator still reads as 0%.
      expect(rendered[1], '0%');
      expect(rendered[2], '75%');
    });

    testWidgets('the no-roster wording is Arabic in Arabic', (tester) async {
      final rendered = await _withContext(
        tester,
        const Locale('ar'),
        (context) => attendanceRateOrNoRoster(context, 0.0, 0),
      );

      expect(RegExp(r'[؀-ۿ]').hasMatch(rendered), isTrue);
      expect(RegExp(r'[A-Za-z]').hasMatch(rendered), isFalse);
    });

    test('a zero denominator is not a zero rate', () {
      // `attendance_rate` is 0.0 both when nobody showed up and when nobody
      // was rostered. Printing 0% for the second reads as a failure, so the
      // screens print an em dash instead.
      expect(attendanceRateIsMeaningful(0), isFalse);
      expect(attendanceRateIsMeaningful(1), isTrue);
    });

    testWidgets('an out-of-range rate is clamped rather than printed raw', (
      tester,
    ) async {
      final rendered = await _withContext(
        tester,
        const Locale('en'),
        (context) => [
          attendanceRate(context, -0.2),
          attendanceRate(context, 1.4),
        ],
      );

      expect(rendered[0], '0%');
      expect(rendered[1], '100%');
    });
  });

  group('times and hours', () {
    testWidgets('a server timestamp renders as HH:mm with no timezone maths', (
      tester,
    ) async {
      final rendered = await _withContext(
        tester,
        const Locale('en'),
        (context) => [
          attendanceClock(context, '2026-09-12 08:35:00'),
          attendanceClock(context, '09:00'),
          attendanceClock(context, '9:05'),
          attendanceClock(context, null),
          attendanceClock(context, ''),
        ],
      );

      // 08:35 as sent — NOT shifted into the device's zone.
      expect(rendered[0], '08:35');
      expect(rendered[1], '09:00');
      expect(rendered[2], '09:05');
      expect(rendered[3], attendanceEmptyValue);
      expect(rendered[4], attendanceEmptyValue);
    });

    testWidgets('null hours read as missing, zero hours as zero', (
      tester,
    ) async {
      final rendered = await _withContext(
        tester,
        const Locale('en'),
        (context) => [
          attendanceHours(context, null),
          attendanceHours(context, 0),
          attendanceHours(context, 8.5),
          attendanceHours(context, 8.0),
        ],
      );

      expect(rendered[0], attendanceEmptyValue);
      expect(rendered[1], '0');
      expect(rendered[2], '8.5');
      expect(rendered[3], '8');
    });
  });

  group('one numeral system per locale', () {
    testWidgets('English renders Western digits everywhere', (tester) async {
      final rendered = await _withContext(
        tester,
        const Locale('en'),
        (context) => [
          attendanceMonthLabel(context, '2026-09'),
          attendanceDayNumber(context, '2026-09-07'),
          attendanceClock(context, '2026-09-12 08:35:00'),
          attendanceCount(context, 1234),
          attendanceRate(context, 0.83),
          attendanceHours(context, 8.5),
        ],
      );

      for (final value in rendered) {
        expect(
          _arabicIndicDigits.hasMatch(value),
          isFalse,
          reason: '"$value" mixes numeral systems',
        );
      }
      expect(rendered[1], '7');
      expect(rendered[3], '1,234');
    });

    testWidgets('Arabic uses ONE system for every number on the screen', (
      tester,
    ) async {
      // The roster screen currently mixes numeral systems within a single
      // screen. Everything the attendance screens print goes through these
      // helpers, so month title, day number, clock, counts, percentages and
      // hours are always in whichever system `intl` uses for this locale —
      // today that is Western digits for `ar`, and the point is that it is the
      // same one everywhere, not which one it is.
      final rendered = await _withContext(
        tester,
        const Locale('ar'),
        (context) => [
          attendanceMonthLabel(context, '2026-09'),
          attendanceDayNumber(context, '2026-09-07'),
          attendanceClock(context, '2026-09-12 08:35:00'),
          attendanceDateLabel(context, '2026-09-12'),
          attendanceCount(context, 1234),
          attendanceRate(context, 0.83),
          attendanceHours(context, 8.5),
          // The reference: whatever this prints "zero" as is the locale's
          // numeral system, taken from intl rather than assumed.
          attendanceCount(context, 0),
        ],
      );

      final localeUsesAscii = _asciiDigits.hasMatch(rendered.last);
      for (final value in rendered) {
        expect(
          localeUsesAscii
              ? _arabicIndicDigits.hasMatch(value)
              : _asciiDigits.hasMatch(value),
          isFalse,
          reason: '"$value" mixes numeral systems inside one Arabic screen',
        );
      }
    });

    testWidgets('digit translation leaves everything that is not a digit '
        'alone', (tester) async {
      final rendered = await _withContext(
        tester,
        const Locale('ar'),
        (context) => [
          attendanceDigits(context, 'HR-EMP-00001 / 2026-09-12'),
          attendanceCount(context, 0),
        ],
      );

      expect(rendered.first.contains('HR-EMP-'), isTrue);
      expect(rendered.first.contains('/'), isTrue);
      // The digits are in the locale's own system; the punctuation and the
      // employee ID's letters are untouched.
      final localeUsesAscii = _asciiDigits.hasMatch(rendered.last);
      expect(
        localeUsesAscii
            ? _arabicIndicDigits.hasMatch(rendered.first)
            : _asciiDigits.hasMatch(rendered.first),
        isFalse,
      );
    });

    testWidgets('a malformed month or date degrades to the raw string', (
      tester,
    ) async {
      final rendered = await _withContext(
        tester,
        const Locale('en'),
        (context) => [
          attendanceMonthLabel(context, 'nonsense'),
          attendanceDayNumber(context, 'nonsense'),
          attendanceDateLabel(context, null),
        ],
      );

      expect(rendered[0], 'nonsense');
      expect(rendered[1], 'nonsense');
      expect(rendered[2], attendanceEmptyValue);
    });
  });

  group('numeric styling', () {
    test('tabular figures are applied to every number style', () {
      final style = attendanceNumeric(const TextStyle(fontSize: 12));

      expect(style!.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(style.fontSize, 12);
    });

    test('a null base style still gets tabular figures', () {
      expect(
        attendanceNumeric(null)!.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });
  });
}
