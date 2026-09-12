import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/localization_extensions.dart';

/// Number, time and rate formatting for the attendance screens.
///
/// Two rules, applied everywhere without exception:
///
/// 1. **One numeral system per locale.** Arabic renders Arabic-Indic digits in
///    the month title, the day headers, the clock times, the counts and the
///    percentages, or it renders Western digits in all of them — never a mix.
///    `DateFormat`/`NumberFormat` already localise the digits they produce, so
///    the only gap is text the server sent as ASCII (`"08:35:00"`), and
///    [attendanceDigits] closes it by translating those digits into whatever
///    system `intl` is using for this locale.
/// 2. **Tabular figures on every number**, so a column of counts lines up
///    instead of shimmering as the digits change width.
abstract final class AttendanceFormat {
  /// Numeric columns use tabular figures so digits line up.
  static const tabular = <FontFeature>[FontFeature.tabularFigures()];
}

/// Applies tabular figures to an existing style.
///
/// Takes the nullable style straight from `theme.textTheme.x` so call sites
/// stay one expression long.
TextStyle? attendanceNumeric(TextStyle? style) =>
    (style ?? const TextStyle()).copyWith(
      fontFeatures: AttendanceFormat.tabular,
    );

/// Re-renders the ASCII digits in [raw] in the locale's own numeral system.
///
/// Used on server strings only (times, ISO dates). Letters, colons and
/// separators are untouched, so `"08:35:00"` becomes `"٠٨:٣٥:٠٠"` in Arabic
/// and stays `"08:35:00"` in English, with no parsing and no timezone maths.
String attendanceDigits(BuildContext context, String raw) {
  final zero = _localeZero(context.l10n.localeName);
  if (zero == 0x30) return raw;
  final buffer = StringBuffer();
  for (final unit in raw.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      buffer.writeCharCode(zero + (unit - 0x30));
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// The code unit of this locale's "0", discovered from `intl` itself rather
/// than hardcoded, so the app and the date formatter can never disagree.
int _localeZero(String localeName) {
  final formatted = NumberFormat.decimalPattern(localeName).format(0);
  return formatted.isEmpty ? 0x30 : formatted.codeUnitAt(0);
}

/// A whole number: head counts, days, minutes.
String attendanceCount(BuildContext context, num value) =>
    NumberFormat.decimalPattern(context.l10n.localeName).format(value);

/// Hours worked, to one decimal. Null renders as the em dash, which on these
/// screens means "the server had nothing", never zero.
String attendanceHours(BuildContext context, double? value) {
  if (value == null) return attendanceEmptyValue;
  final formatter = NumberFormat.decimalPattern(context.l10n.localeName)
    ..minimumFractionDigits = value == value.roundToDouble() ? 0 : 1
    ..maximumFractionDigits = 1;
  return formatter.format(value);
}

/// A 0..1 rate as a percentage.
///
/// The server sends 0.0 for both "nothing was rostered" (divide by zero) and
/// "nobody showed up", so a bare 0% is ambiguous — call sites pair this with
/// the rostered count, and [attendanceRateIsMeaningful] says when the number
/// is worth printing at all.
String attendanceRate(BuildContext context, double rate) {
  final formatter = NumberFormat.percentPattern(context.l10n.localeName)
    ..maximumFractionDigits = 0;
  return formatter.format(rate.clamp(0, 1));
}

/// False when the denominator was zero, i.e. nothing was rostered — printing
/// "0%" then would read as a failure rather than as an empty question.
bool attendanceRateIsMeaningful(int denominator) => denominator > 0;

/// A rate, or the reason there isn't one.
///
/// A zero denominator is a real, explicable state — nobody was rostered — and
/// it deserves to be said. The em dash used to stand in for it, which reads as
/// "the server did not send this", a different and wronger claim now that the
/// numbers on screen are verifiable against each other.
String attendanceRateOrNoRoster(
  BuildContext context,
  double rate,
  int denominator,
) {
  if (!attendanceRateIsMeaningful(denominator)) {
    return context.l10n.attendanceRateNoRoster;
  }
  return attendanceRate(context, rate);
}

/// The placeholder for a value the server did not send.
const String attendanceEmptyValue = '—';

/// `HH:mm` out of a server-local `YYYY-MM-DD HH:mm:ss` (or a bare `HH:mm`).
///
/// String surgery on purpose. These timestamps are already in the site's own
/// timezone; parsing them into a `DateTime` would let the device's zone shift
/// them, which is how a 08:00 check-in becomes 06:00 on a phone left on UTC.
String attendanceClock(BuildContext context, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return attendanceEmptyValue;
  final timePart = value.contains(' ') ? value.split(' ').last : value;
  final pieces = timePart.split(':');
  if (pieces.length < 2) return attendanceDigits(context, value);
  return attendanceDigits(
    context,
    '${pieces[0].padLeft(2, '0')}:${pieces[1].padLeft(2, '0')}',
  );
}

/// The date half of a server timestamp, formatted for the locale.
String attendanceDateLabel(
  BuildContext context,
  String? isoDate, {
  String pattern = 'MMM d',
}) {
  final value = isoDate?.trim() ?? '';
  if (value.isEmpty) return attendanceEmptyValue;
  final datePart = value.contains(' ') ? value.split(' ').first : value;
  final parsed = DateTime.tryParse(datePart);
  if (parsed == null) return attendanceDigits(context, datePart);
  return DateFormat(pattern, context.l10n.localeName).format(parsed);
}

/// "September 2026" / "سبتمبر ٢٠٢٦" from a `YYYY-MM`.
String attendanceMonthLabel(BuildContext context, String month) {
  final parts = month.split('-');
  if (parts.length < 2) return attendanceDigits(context, month);
  final year = int.tryParse(parts[0]);
  final monthNumber = int.tryParse(parts[1]);
  if (year == null || monthNumber == null) {
    return attendanceDigits(context, month);
  }
  return DateFormat(
    'MMMM yyyy',
    context.l10n.localeName,
  ).format(DateTime(year, monthNumber, 1));
}

/// The day-of-month number for a grid column header, in the locale's digits.
String attendanceDayNumber(BuildContext context, String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return attendanceDigits(context, isoDate);
  return attendanceCount(context, parsed.day);
}

/// The weekday abbreviation for a grid column header.
String attendanceWeekdayLabel(BuildContext context, String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return '';
  return DateFormat('E', context.l10n.localeName).format(parsed);
}
