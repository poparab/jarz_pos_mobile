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

/// Null when nothing is selected — the normal state, where a tap opens the
/// single-cell sheet exactly as before.
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
