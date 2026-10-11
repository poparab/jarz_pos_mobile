import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/roster_repository.dart';
import '../models/roster_models.dart';

/// The month being rostered, as `YYYY-MM`.
///
/// Seeded from the device clock only as an opening guess; every request sends
/// the string explicitly, so the server's idea of "now" and the phone's cannot
/// drift apart mid-session.
final rosterMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}';
});

/// Branch filter. Null means "every branch I can see".
final rosterLocationFilterProvider = StateProvider<String?>((ref) => null);

final rosterBootstrapProvider = FutureProvider<RosterBootstrap>((ref) async {
  return ref.watch(rosterRepositoryProvider).getBootstrap();
});

final rosterMonthDataProvider = FutureProvider<RosterMonth>((ref) async {
  final month = ref.watch(rosterMonthProvider);
  final location = ref.watch(rosterLocationFilterProvider);
  return ref
      .watch(rosterRepositoryProvider)
      .getMonth(month: month, shiftLocation: location);
});

final rosterHoursProvider = FutureProvider<RosterHours>((ref) async {
  final month = ref.watch(rosterMonthProvider);
  final location = ref.watch(rosterLocationFilterProvider);
  return ref
      .watch(rosterRepositoryProvider)
      .getMonthHours(month: month, shiftLocation: location);
});

/// A run of days selected on ONE employee's row, waiting for a bulk action.
///
/// Deliberately scoped to a single employee: the backend re-checks branch
/// scope per row anyway, but a selection that could span rows would make
/// "assign this shift to everyone selected" read as one instruction while
/// silently touching several different people's rotas — exactly the kind of
/// side effect the destructive-clear guard below exists to prevent.
class RosterSelection {
  const RosterSelection({
    required this.employee,
    required this.employeeName,
    required this.dates,
  });

  final String employee;
  final String employeeName;
  final Set<String> dates;

  int get count => dates.length;

  /// Add or remove [date], keeping the same employee.
  RosterSelection toggle(String date) {
    final next = Set<String>.from(dates);
    if (!next.remove(date)) next.add(date);
    return RosterSelection(
      employee: employee,
      employeeName: employeeName,
      dates: next,
    );
  }
}

/// Null when nothing is selected. Outside select mode (see
/// [rosterSelectModeProvider]) it is always null and a tap opens the
/// single-cell sheet; in select mode a tap adds or removes a day here, and the
/// bulk bar acts on whatever it holds.
final rosterSelectionProvider = StateProvider<RosterSelection?>((ref) => null);

/// Shift the visible month by [delta] months.
///
/// Done with a `DateTime` round-trip rather than by adding to the month number
/// so December → January rolls the year, which hand-rolled arithmetic on the
/// `YYYY-MM` string routinely gets wrong.
String shiftMonth(String month, int delta) {
  final parts = month.split('-');
  final year = int.tryParse(parts.first) ?? DateTime.now().year;
  final monthNumber = parts.length > 1
      ? (int.tryParse(parts[1]) ?? DateTime.now().month)
      : DateTime.now().month;
  final shifted = DateTime(year, monthNumber + delta, 1);
  return '${shifted.year.toString().padLeft(4, '0')}-'
      '${shifted.month.toString().padLeft(2, '0')}';
}

/// Week or month. The grid always FETCHES a month (the backend serves months);
/// this only decides how much of it is drawn at once.
enum RosterViewMode { week, month }

/// Week by default: a line manager plans the coming days, and a 31-column grid
/// on a phone is a wall of cells they have to scroll to find today in.
final rosterViewModeProvider = StateProvider<RosterViewMode>(
  (ref) => RosterViewMode.week,
);

/// Any ISO date inside the week being shown, or null for "the default week"
/// (today's week in the current month, otherwise the month's first week).
///
/// Stored as a date rather than a week index so it survives a month change:
/// a date from another month simply stops matching and the default applies.
final rosterWeekFocusProvider = StateProvider<String?>((ref) => null);

/// Whether a tap selects days (true) or opens the day sheet (false).
///
/// A selection only ever exists while this is on: entering it is the visible
/// "Select days" toggle, or a long-press as a shortcut.
final rosterSelectModeProvider = StateProvider<bool>((ref) => false);

/// `YYYY-MM-DD`, the key every roster payload uses for a day.
String rosterIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The month's weeks, Saturday to Friday, clipped to the month.
///
/// Saturday-first because the Egyptian working week starts on Saturday (the
/// weekend is Friday AND Saturday, see `isRosterWeekend`; a Saturday-first week
/// keeps the Friday at its end). Clipping means the first and last weeks can be
/// short: the grid only has this month's data, so a week never borrows days
/// from the neighbouring month.
///
/// Calendar arithmetic is done in UTC: Egypt observes daylight saving, and a
/// local-time `add(Duration(days: 1))` across the change lands an hour off and
/// can repeat or skip a date.
List<List<String>> rosterWeeksOfMonth(String month) {
  final parts = month.split('-');
  final year = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
  final monthNumber = parts.length > 1 ? int.tryParse(parts[1]) : null;
  if (year == null || monthNumber == null) return const [];

  final weeks = <List<String>>[];
  var current = <String>[];
  var day = DateTime.utc(year, monthNumber, 1);
  while (day.month == monthNumber) {
    if (day.weekday == DateTime.saturday && current.isNotEmpty) {
      weeks.add(current);
      current = <String>[];
    }
    current.add(rosterIsoDate(day));
    day = day.add(const Duration(days: 1));
  }
  if (current.isNotEmpty) weeks.add(current);
  return weeks;
}

/// The index into [rosterWeeksOfMonth] the grid opens on: the week holding
/// [today] when [month] is the current month, else the first week.
int rosterDefaultWeekIndex(String month, DateTime today) {
  final weeks = rosterWeeksOfMonth(month);
  final iso = rosterIsoDate(today);
  for (var i = 0; i < weeks.length; i++) {
    if (weeks[i].contains(iso)) return i;
  }
  return 0;
}

/// The week to draw: the one containing [focus] if it is in [month], else the
/// default week.
int rosterVisibleWeekIndex(String month, String? focus, DateTime today) {
  final weeks = rosterWeeksOfMonth(month);
  if (focus != null) {
    for (var i = 0; i < weeks.length; i++) {
      if (weeks[i].contains(focus)) return i;
    }
  }
  return rosterDefaultWeekIndex(month, today);
}

/// Where the ‹ › arrows go in week mode.
///
/// One week at a time; stepping past the month's first or last week moves to
/// the neighbouring month's LAST or FIRST week, so walking backwards from the
/// 1st lands on the end of the previous month rather than its start.
({String month, String focus}) rosterStepWeek({
  required String month,
  required String? focus,
  required int delta,
  required DateTime today,
}) {
  final weeks = rosterWeeksOfMonth(month);
  final index = rosterVisibleWeekIndex(month, focus, today);
  final target = index + delta;
  if (target >= 0 && target < weeks.length) {
    return (month: month, focus: weeks[target].first);
  }
  final nextMonth = shiftMonth(month, delta < 0 ? -1 : 1);
  final nextWeeks = rosterWeeksOfMonth(nextMonth);
  if (nextWeeks.isEmpty) return (month: nextMonth, focus: '');
  return (
    month: nextMonth,
    focus: delta < 0 ? nextWeeks.last.first : nextWeeks.first.first,
  );
}

/// The shift a person most often works across [dates], or null when none of
/// them is a working day. Ties go to the earliest date's shift.
///
/// Used as the cover-shift default for a bulk day off: whoever covers normally
/// steps onto the absent person's own shift.
String? rosterMostCommonShift(RosterEmployee? employee, Iterable<String> dates) {
  if (employee == null) return null;
  final counts = <String, int>{};
  final firstSeen = <String, String>{};
  for (final date in dates.toList()..sort()) {
    final type = (employee.cellFor(date)?.shiftType ?? '').trim();
    if (type.isEmpty) continue;
    counts[type] = (counts[type] ?? 0) + 1;
    firstSeen.putIfAbsent(type, () => date);
  }
  if (counts.isEmpty) return null;
  final ranked = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : firstSeen[a]!.compareTo(firstSeen[b]!);
    });
  return ranked.first;
}
