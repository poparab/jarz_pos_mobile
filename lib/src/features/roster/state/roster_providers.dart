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

final rosterBootstrapProvider = FutureProvider<RosterBootstrap>((ref) async {
  return ref.watch(rosterRepositoryProvider).getBootstrap();
});

/// The months the grid needs loaded, as `primary,other` (`YYYY-MM` each).
///
/// Month view: just [rosterMonthProvider]. Week view: every month the visible
/// Saturday-to-Friday week touches, the week's majority month first (see
/// [rosterWeekMonth]), so a week that straddles a month end still draws all
/// seven days.
///
/// A plain string on purpose: stepping to another week inside the same months
/// yields an EQUAL string, Riverpod does not notify, and nothing is refetched.
final rosterLoadedMonthsProvider = Provider<String>((ref) {
  final month = ref.watch(rosterMonthProvider);
  if (ref.watch(rosterViewModeProvider) != RosterViewMode.week) return month;
  final week = rosterWeekDates(
    month: month,
    focus: ref.watch(rosterWeekFocusProvider),
    today: DateTime.now(),
  );
  final primary = rosterWeekMonth(week);
  final others = {for (final d in week) d.substring(0, 7)}.toList()
    ..remove(primary)
    ..sort();
  return [primary, ...others].join(',');
});

/// The roster for every month in [rosterLoadedMonthsProvider], merged into
/// one [RosterMonth] (see [rosterMergeMonths]).
///
/// Always fetched UNFILTERED: the people/branch filter is applied on the
/// client (`rosterVisibleMonthProvider` in `roster_filter.dart`), so changing
/// it costs no request and a list of branches never has to be sent.
final rosterMonthDataProvider = FutureProvider<RosterMonth>((ref) async {
  final months = ref.watch(rosterLoadedMonthsProvider).split(',');
  final repository = ref.watch(rosterRepositoryProvider);
  final loaded = await Future.wait([
    for (final month in months) repository.getMonth(month: month),
  ]);
  return rosterMergeMonths(loaded);
});

/// Hours for [rosterMonthProvider], unfiltered. The filtered view the hours
/// sheet draws is `rosterVisibleHoursProvider` in `roster_filter.dart`.
final rosterHoursProvider = FutureProvider<RosterHours>((ref) async {
  final month = ref.watch(rosterMonthProvider);
  return ref.watch(rosterRepositoryProvider).getMonthHours(month: month);
});

/// Several months' rosters as one: employees merged by id (first appearance
/// sets the order and the person's details, later months only add days),
/// gaps de-duplicated, branches and shifts unioned. The first month is the
/// primary one; its month string, scope and notice win.
RosterMonth rosterMergeMonths(List<RosterMonth> months) {
  if (months.isEmpty) {
    throw ArgumentError.value(months, 'months', 'must not be empty');
  }
  if (months.length == 1) return months.first;
  final primary = months.first;

  final order = <String>[];
  final byId = <String, RosterEmployee>{};
  for (final month in months) {
    for (final employee in month.employees) {
      final existing = byId[employee.employee];
      if (existing == null) {
        order.add(employee.employee);
        byId[employee.employee] = employee;
        continue;
      }
      byId[employee.employee] = RosterEmployee(
        employee: existing.employee,
        employeeName: existing.employeeName,
        designation: existing.designation,
        department: existing.department,
        shiftLocations: existing.shiftLocations,
        scheduleLocation: existing.scheduleLocation,
        standardHours: existing.standardHours,
        isCourier: existing.isCourier,
        overtimeMultiplier: existing.overtimeMultiplier,
        days: {...existing.days, ...employee.days},
      );
    }
  }

  final gapKeys = <String>{};
  final gaps = <RosterGap>[
    for (final month in months)
      for (final gap in month.gaps)
        if (gapKeys.add('${gap.employee}|${gap.date}')) gap,
  ];
  final locationKeys = <String>{};
  final locations = <RosterLocation>[
    for (final month in months)
      for (final location in month.shiftLocations)
        if (locationKeys.add(location.shiftLocation)) location,
  ];
  final shiftKeys = <String>{};
  final catalog = <RosterShift>[
    for (final month in months)
      for (final shift in month.shiftCatalog)
        if (shiftKeys.add(shift.shiftType)) shift,
  ];
  final starts = months.map((m) => m.monthStart).where((d) => d.isNotEmpty);
  final ends = months.map((m) => m.monthEnd).where((d) => d.isNotEmpty);

  return RosterMonth(
    month: primary.month,
    monthStart: starts.isEmpty
        ? primary.monthStart
        : starts.reduce((a, b) => a.compareTo(b) <= 0 ? a : b),
    monthEnd: ends.isEmpty
        ? primary.monthEnd
        : ends.reduce((a, b) => a.compareTo(b) >= 0 ? a : b),
    employees: [for (final id in order) byId[id]!],
    shiftCatalog: catalog,
    shiftLocations: locations,
    gaps: gaps,
    scope: primary.scope,
    hrmsAvailable: months.every((m) => m.hrmsAvailable),
    notice: months.map((m) => m.notice).whereType<String>().firstOrNull,
  );
}

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

/// Week or month. The backend serves months; week view loads every month the
/// week touches (see [rosterLoadedMonthsProvider]) and draws seven days.
enum RosterViewMode { week, month }

/// Week by default: a line manager plans the coming days, and a 31-column grid
/// on a phone is a wall of cells they have to scroll to find today in.
final rosterViewModeProvider = StateProvider<RosterViewMode>(
  (ref) => RosterViewMode.week,
);

/// Any ISO date inside the week being shown, or null for "the default week"
/// (today's week when [rosterMonthProvider] is the current month, otherwise
/// the week holding the month's 1st). See [rosterWeekDates].
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

/// [iso] as a UTC midnight, or null when it is not a date.
DateTime? _isoDay(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return null;
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

/// The month's weeks, Saturday to Friday, clipped to the month.
///
/// Saturday-first because the Egyptian working week starts on Saturday (the
/// weekend is Friday AND Saturday, see `isRosterWeekend`; a Saturday-first week
/// keeps the Friday at its end). The grid's week view does NOT clip any more
/// (see [rosterWeekDates]); this stays for the layout tests and anything that
/// needs a month cut into weeks.
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

/// The full Saturday-to-Friday week holding [day]: always seven ISO dates,
/// crossing a month (or year) boundary when the week does.
List<String> rosterFullWeek(DateTime day) {
  final utc = DateTime.utc(day.year, day.month, day.day);
  // Dart's % is non-negative for a positive divisor: Sat 0, Sun 1 ... Fri 6.
  final back = (utc.weekday - DateTime.saturday) % 7;
  final start = utc.subtract(Duration(days: back));
  return [
    for (var i = 0; i < 7; i++) rosterIsoDate(start.add(Duration(days: i))),
  ];
}

/// The month a week belongs to: its Tuesday's. Tuesday is the 4th day of a
/// Saturday-first week, so its month always holds at least four of the seven
/// days, i.e. the majority.
String rosterWeekMonth(List<String> week) {
  if (week.isEmpty) return '';
  final pick = week.length > 3 ? week[3] : week.first;
  return pick.length >= 7 ? pick.substring(0, 7) : pick;
}

/// The seven days week view draws.
///
/// The week holding [focus] when that week touches [month]; otherwise the
/// default: today's week when [month] holds today, else the week holding the
/// month's 1st. A stale focus (a week nowhere near [month]) falls back rather
/// than showing a week the arrows did not lead to.
List<String> rosterWeekDates({
  required String month,
  required String? focus,
  required DateTime today,
}) {
  final focusDay = focus == null ? null : _isoDay(focus);
  if (focusDay != null) {
    final week = rosterFullWeek(focusDay);
    if (week.any((d) => d.startsWith('$month-'))) return week;
  }
  if (rosterIsoDate(today).startsWith('$month-')) return rosterFullWeek(today);
  return rosterFullWeek(_isoDay('$month-01') ?? today);
}

/// Where the arrows go in week mode: exactly seven days back or forward,
/// straight across month ends, with the month set to the new week's majority
/// month ([rosterWeekMonth]) so the hours sheet and a switch to month view
/// follow the week.
({String month, String focus}) rosterStepWeek({
  required String month,
  required String? focus,
  required int delta,
  required DateTime today,
}) {
  final week = rosterWeekDates(month: month, focus: focus, today: today);
  final start = _isoDay(week.first)!;
  final next = rosterFullWeek(start.add(Duration(days: 7 * delta)));
  return (month: rosterWeekMonth(next), focus: next.first);
}

/// Point week view at the week holding [date] (a gap picked from the list,
/// say), moving [rosterMonthProvider] with it so the focus is never stale.
void rosterFocusWeekOn(WidgetRef ref, String date) {
  final day = _isoDay(date);
  if (day == null) return;
  ref.read(rosterMonthProvider.notifier).state = rosterWeekMonth(
    rosterFullWeek(day),
  );
  ref.read(rosterWeekFocusProvider.notifier).state = date;
}

/// The shift a person most often works across [dates], or null when none of
/// them is a working day. Ties go to the earliest date's shift.
///
/// Used as the cover-shift default for a bulk day off: whoever covers normally
/// steps onto the absent person's own shift.
String? rosterMostCommonShift(
  RosterEmployee? employee,
  Iterable<String> dates,
) {
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
