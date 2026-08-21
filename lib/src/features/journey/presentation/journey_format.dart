import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../leads/presentation/leads_theme.dart';

/// Date and label formatting shared by every journey surface (the timeline, the
/// editor, the pipeline card badge), so a date reads the same everywhere.
abstract final class JourneyFormat {
  /// Backend wire format: ISO `yyyy-MM-dd`, the only shape the API accepts.
  static String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Parses a backend date, tolerating a full datetime string. Null when the
  /// value is missing or unparseable — never throws on a surprise payload.
  static DateTime? parse(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw.length > 10 ? raw : '${raw}T00:00:00');
  }

  /// Human date: `12 Aug 2026`, in the reader's locale. Falls back to the raw
  /// string when unparseable so a rep still sees *something* rather than a
  /// blank.
  static String pretty(BuildContext context, String? value) {
    final date = parse(value);
    if (date == null) return (value ?? '').trim();
    return DateFormat('d MMM yyyy', context.l10n.localeName).format(date);
  }

  /// Relative label for a past date: `Today`, `Yesterday`, `5 days ago`,
  /// `3 weeks ago`. Empty when the date is unusable.
  static String relativePast(
    BuildContext context,
    String? value, {
    DateTime? now,
  }) {
    final date = parse(value);
    if (date == null) return '';
    final l10n = context.l10n;
    final days = _dayDelta(date, now ?? DateTime.now());
    if (days == 0) return l10n.journeyToday;
    if (days == 1) return l10n.journeyYesterday;
    if (days < 0) return relativeFuture(context, value, now: now);
    if (days < 7) return l10n.journeyDaysAgo(days);
    if (days < 30) return l10n.journeyWeeksAgo(days ~/ 7);
    return l10n.journeyMonthsAgo(days ~/ 30);
  }

  /// Relative label for a due date: `Overdue by 3 days`, `Today`, `In 4 days`.
  static String relativeFuture(
    BuildContext context,
    String? value, {
    DateTime? now,
  }) {
    final date = parse(value);
    if (date == null) return '';
    final l10n = context.l10n;
    final days = _dayDelta(date, now ?? DateTime.now());
    if (days == 0) return l10n.journeyToday;
    if (days == 1) return l10n.journeyYesterday;
    if (days > 1) {
      return days < 30 ? l10n.journeyOverdueByDays(days) : l10n.journeyOverdue;
    }
    final ahead = -days;
    if (ahead == 1) return l10n.journeyTomorrow;
    if (ahead < 30) return l10n.journeyInDays(ahead);
    return l10n.journeyInMonths(ahead ~/ 30);
  }

  /// Whether a next-action date is today or already past — i.e. the rep owes
  /// somebody a call right now. An unparseable date is never "due".
  static bool isDue(String? value, {DateTime? now}) {
    final date = parse(value);
    if (date == null) return false;
    return _dayDelta(date, now ?? DateTime.now()) >= 0;
  }

  /// Whole days between [date] and [now], positive when [date] is in the past.
  static int _dayDelta(DateTime date, DateTime now) {
    final a = DateTime(now.year, now.month, now.day);
    final b = DateTime(date.year, date.month, date.day);
    return a.difference(b).inDays;
  }

  /// Icon for a journey entry type — a visit and a phone call should not be
  /// distinguishable only by reading the chip text.
  static IconData typeIcon(String type) {
    switch (type.trim().toLowerCase()) {
      case 'call':
        return Icons.call;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'sample drop':
        return Icons.science_outlined;
      case 'meeting':
        return Icons.groups_outlined;
      case 'email':
        return Icons.mail_outline;
      case 'other':
        return Icons.more_horiz;
      case 'visit':
      default:
        return Icons.directions_walk;
    }
  }

  /// Colour for an outcome chip. Neutral for anything unrecognised, so a new
  /// Select option added in Desk renders sanely without an app release.
  static ({Color bg, Color fg}) outcomeColors(String outcome) {
    switch (outcome.trim().toLowerCase()) {
      case 'interested':
      case 'order placed':
        return (bg: const Color(0xFFE7F3EA), fg: const Color(0xFF2E7D45));
      case 'sample requested':
      case 'needs follow-up':
        return (bg: const Color(0xFFFDF2E3), fg: const Color(0xFF9A6B12));
      case 'rejected':
        return (bg: LeadsTheme.rejectedBg, fg: LeadsTheme.rejected);
      case 'not now':
        return (bg: const Color(0xFFEDECEA), fg: LeadsTheme.muted);
      default:
        return (bg: const Color(0xFFEDECEA), fg: LeadsTheme.muted);
    }
  }
}
