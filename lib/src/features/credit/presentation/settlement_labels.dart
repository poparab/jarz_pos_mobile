import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../data/models/settlement_models.dart';

/// Display mapping for settlement cycles and collection states. The raw value
/// is what travels to and from the server; these only decide what is shown.

String settlementCycleLabel(AppLocalizations l10n, String cycle) =>
    switch (cycle) {
      SettlementCycle.onDelivery => l10n.settlementCycleOnDelivery,
      SettlementCycle.invoiceAfterInvoice =>
        l10n.settlementCycleInvoiceAfterInvoice,
      SettlementCycle.weekly => l10n.settlementCycleWeekly,
      SettlementCycle.daysOfMonth => l10n.settlementCycleDaysOfMonth,
      SettlementCycle.everyNDays => l10n.settlementCycleEveryNDays,
      _ => cycle,
    };

String settlementStateLabel(AppLocalizations l10n, String state) =>
    switch (state) {
      SettlementState.overdue => l10n.settlementStateOverdue,
      SettlementState.dueToday => l10n.settlementStateDueToday,
      SettlementState.dueSoon => l10n.settlementStateDueSoon,
      SettlementState.ok => l10n.settlementStateOk,
      SettlementState.none => l10n.settlementStateNone,
      _ => l10n.settlementStateUnscheduled,
    };

/// Overdue red, due today orange, due soon amber, on track green, not
/// scheduled grey. The amber is darkened so it stays readable as text.
Color settlementStateColor(String state) => switch (state) {
      SettlementState.overdue => const Color(0xFFC62828),
      SettlementState.dueToday => const Color(0xFFEF6C00),
      SettlementState.dueSoon => const Color(0xFFB28704),
      SettlementState.ok => const Color(0xFF2E7D32),
      SettlementState.none => const Color(0xFF2E7D32),
      _ => const Color(0xFF757575),
    };

IconData settlementStateIcon(String state) => switch (state) {
      SettlementState.overdue => Icons.error_outline,
      SettlementState.dueToday => Icons.today_outlined,
      SettlementState.dueSoon => Icons.schedule,
      SettlementState.ok => Icons.check_circle_outline,
      SettlementState.none => Icons.check_circle_outline,
      _ => Icons.event_busy_outlined,
    };

bool _isArabic(AppLocalizations l10n) => l10n.localeName.startsWith('ar');

/// Weekday name for a `Mon..Sun` token in the UI language. 2024-01-01 was a
/// Monday, so offsetting from it yields the right weekday for every token.
String settlementWeekdayName(
  AppLocalizations l10n,
  String token, {
  bool short = false,
}) {
  final index = weekdayTokens.indexOf(token);
  if (index < 0) return token;
  final date = DateTime(2024, 1, 1 + index);
  return (short ? DateFormat.E(l10n.localeName) : DateFormat.EEEE(l10n.localeName))
      .format(date);
}

/// "A, B and C" in English, "A وB وC" in Arabic.
String _joinList(AppLocalizations l10n, List<String> items) {
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  if (_isArabic(l10n)) return items.join(' و');
  return '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}';
}

String _englishOrdinal(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) return '${day}th';
  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}

/// A sentence for the schedule in the UI language — "Every Thursday",
/// "Every month on the 15th and the last day". Built on the client because
/// the server's `description` is English only; [fallback] (that server
/// sentence) is used for a cycle this build does not know.
String settlementDescription(
  AppLocalizations l10n,
  SettlementTerms? terms, {
  String fallback = '',
}) {
  if (terms == null) return fallback;
  switch (terms.cycle) {
    case SettlementCycle.onDelivery:
      return l10n.settlementDescOnDelivery;
    case SettlementCycle.invoiceAfterInvoice:
      return l10n.settlementDescInvoiceAfterInvoice;
    case SettlementCycle.weekly:
      final days = terms.weekdayList;
      if (days.isEmpty) return fallback;
      final names = _joinList(
        l10n,
        [for (final d in days) settlementWeekdayName(l10n, d)],
      );
      return terms.weekInterval > 1
          ? l10n.settlementDescWeeklyInterval(terms.weekInterval, names)
          : l10n.settlementDescWeekly(names);
    case SettlementCycle.daysOfMonth:
      final days = terms.monthDayList;
      if (days.isEmpty) return fallback;
      final parts = [
        for (final d in days)
          d == monthDayLast
              ? l10n.settlementDescMonthDayLast
              : l10n.settlementDescMonthDayNumber(
                  _isArabic(l10n) ? d : _englishOrdinal(int.parse(d)),
                ),
      ];
      return l10n.settlementDescMonthDays(_joinList(l10n, parts));
    case SettlementCycle.everyNDays:
      final n = terms.intervalDays;
      if (n == null || n < 1) return fallback;
      return l10n.settlementDescEveryNDays(n);
    default:
      return fallback;
  }
}
