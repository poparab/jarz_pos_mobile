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
