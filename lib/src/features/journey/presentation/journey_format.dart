import 'package:flutter/material.dart';

import '../../leads/presentation/leads_theme.dart';

/// Date and label formatting shared by every journey surface (the timeline, the
/// editor, the pipeline card badge), so a date reads the same everywhere.
abstract final class JourneyFormat {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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

  /// Human date: `12 Aug 2026`. Falls back to the raw string when unparseable
  /// so a rep still sees *something* rather than a blank.
  static String pretty(String? value) {
    final date = parse(value);
    if (date == null) return (value ?? '').trim();
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Relative label for a past date: `Today`, `Yesterday`, `5 days ago`,
  /// `3 weeks ago`. Empty when the date is unusable.
  static String relativePast(String? value, {DateTime? now}) {
    final date = parse(value);
    if (date == null) return '';
    final days = _dayDelta(date, now ?? DateTime.now());
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 0) return relativeFuture(value, now: now);
    if (days < 7) return '$days days ago';
    if (days < 30) {
      final weeks = days ~/ 7;
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    final months = days ~/ 30;
    return months <= 1 ? '1 month ago' : '$months months ago';
  }

  /// Relative label for a due date: `Overdue by 3 days`, `Today`, `In 4 days`.
  static String relativeFuture(String? value, {DateTime? now}) {
    final date = parse(value);
    if (date == null) return '';
    final days = _dayDelta(date, now ?? DateTime.now());
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days > 1) {
      return days < 30 ? 'Overdue by $days days' : 'Overdue';
    }
    final ahead = -days;
    if (ahead == 1) return 'Tomorrow';
    if (ahead < 30) return 'In $ahead days';
    return 'In ${ahead ~/ 30} months';
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
