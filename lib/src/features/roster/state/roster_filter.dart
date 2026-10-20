import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/user_service.dart';
import '../models/roster_models.dart';
import 'roster_providers.dart';

/// Who the Shift Distribution grid shows: some branches, some people, both,
/// or (empty) everyone.
///
/// Applied on the CLIENT. The month is always fetched unfiltered, so the
/// filter costs no request and no list is ever sent to the backend.
///
/// A row is visible when the filter is empty, when the person is picked by
/// name, or when the person BELONGS to a picked branch
/// ([rosterEmployeeBelongsTo]).
@immutable
class RosterFilter {
  const RosterFilter({
    this.locations = const <String>{},
    this.employees = const <String>{},
  });

  static const empty = RosterFilter();

  /// Shift Location names (the branch names, plus the factory).
  final Set<String> locations;

  /// Employee ids (`HR-EMP-00001`), not names.
  final Set<String> employees;

  bool get isEmpty => locations.isEmpty && employees.isEmpty;

  Map<String, dynamic> toJson() => {
    'locations': locations.toList()..sort(),
    'employees': employees.toList()..sort(),
  };

  /// Tolerant on purpose: whatever is in storage was written by some earlier
  /// build, and a bad value must read as "no filter", never as a crash.
  factory RosterFilter.fromJson(Object? json) {
    if (json is! Map) return empty;
    Set<String> strings(Object? value) => value is List
        ? value
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toSet()
        : <String>{};
    return RosterFilter(
      locations: strings(json['locations']),
      employees: strings(json['employees']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RosterFilter &&
      setEquals(other.locations, locations) &&
      setEquals(other.employees, employees);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(locations),
    Object.hashAllUnordered(employees),
  );

  @override
  String toString() =>
      'RosterFilter(locations: $locations, employees: $employees)';
}

/// Whether [employee] belongs to any of [locations].
///
/// "Belongs to branch L" means ANY of:
/// 1. L is one of the person's linked shift locations (`shift_locations`, the
///    branches their POS profiles / HR record tie them to);
/// 2. L is their schedule location (`schedule_location`, where an unrostered
///    day of theirs lands);
/// 3. one of their LOADED day cells is assigned at L, i.e. they have a shift
///    there somewhere in the loaded month (both months, in a week that
///    straddles a month end). This is what puts a person covering at another
///    branch into that branch's view.
bool rosterEmployeeBelongsTo(RosterEmployee employee, Set<String> locations) {
  if (locations.isEmpty) return false;
  if (employee.shiftLocations.any(locations.contains)) return true;
  final schedule = employee.scheduleLocation;
  if (schedule != null && locations.contains(schedule)) return true;
  for (final cell in employee.days.values) {
    final at = cell.shiftLocation;
    if (at != null && locations.contains(at)) return true;
  }
  return false;
}

/// The row rule: everyone when [filter] is empty, otherwise picked by name OR
/// belonging to a picked branch.
bool rosterRowVisible(RosterEmployee employee, RosterFilter filter) =>
    filter.isEmpty ||
    filter.employees.contains(employee.employee) ||
    rosterEmployeeBelongsTo(employee, filter.locations);

/// Every branch name the screen knows about: the bootstrap's list (the
/// filter sheet's source, factory included) plus any the month payload names.
Set<String> rosterKnownLocations({
  RosterBootstrap? bootstrap,
  RosterMonth? month,
}) => {
  ...?bootstrap?.shiftLocations.map((l) => l.shiftLocation),
  ...?month?.shiftLocations.map((l) => l.shiftLocation),
};

/// [filter] minus anything that no longer exists, so a saved branch that was
/// renamed or a person who left silently stops counting instead of hiding
/// everybody.
///
/// Branches are pruned only once some branch list has loaded (an empty
/// [knownLocations] means "not loaded yet", not "no branches"); people only
/// once a month has ([knownEmployees] null).
RosterFilter rosterEffectiveFilter(
  RosterFilter filter, {
  required Set<String> knownLocations,
  required Set<String>? knownEmployees,
}) {
  if (filter.isEmpty) return filter;
  return RosterFilter(
    locations: knownLocations.isEmpty
        ? filter.locations
        : filter.locations.intersection(knownLocations),
    employees: knownEmployees == null
        ? filter.employees
        : filter.employees.intersection(knownEmployees),
  );
}

/// [month] with only the visible rows (and only their gaps).
RosterMonth rosterApplyFilter(RosterMonth month, RosterFilter filter) {
  if (filter.isEmpty) return month;
  final employees = month.employees
      .where((e) => rosterRowVisible(e, filter))
      .toList();
  final ids = {for (final e in employees) e.employee};
  return RosterMonth(
    month: month.month,
    monthStart: month.monthStart,
    monthEnd: month.monthEnd,
    employees: employees,
    shiftCatalog: month.shiftCatalog,
    shiftLocations: month.shiftLocations,
    gaps: month.gaps.where((g) => ids.contains(g.employee)).toList(),
    scope: month.scope,
    hrmsAvailable: month.hrmsAvailable,
    notice: month.notice,
  );
}

/// [hours] narrowed to [visibleEmployees], with the totals re-added from the
/// rows that are left. Null [visibleEmployees] means "no filter".
RosterHours rosterFilterHours(
  RosterHours hours,
  Set<String>? visibleEmployees,
) {
  if (visibleEmployees == null) return hours;
  final rows = hours.rows
      .where((r) => visibleEmployees.contains(r.employee))
      .toList();
  var worked = 0.0;
  var overtime = 0.0;
  var credited = 0.0;
  for (final row in rows) {
    worked += row.workedHours;
    overtime += row.overtimeHours;
    credited += row.creditedHours;
  }
  return RosterHours(
    month: hours.month,
    rows: rows,
    totalWorkedHours: worked,
    totalOvertimeHours: overtime,
    totalCreditedHours: credited,
  );
}

// ── Persistence ─────────────────────────────────────────────────────────

/// The site this build talks to, as `host[:port]`, so one phone used against
/// staging and production keeps two separate filters. Empty when the env is
/// not loaded (tests).
String rosterFilterSite() {
  try {
    final raw = dotenv.get('ERP_BASE_URL', fallback: '').trim();
    final uri = Uri.tryParse(raw);
    final host = uri?.host ?? '';
    if (host.isEmpty) return raw.toLowerCase();
    return (uri!.hasPort ? '$host:${uri.port}' : host).toLowerCase();
  } catch (_) {
    return '';
  }
}

/// `roster_filter_v1:<site>:<user>`, one saved filter per user per site.
String rosterFilterPrefsKey({required String site, required String user}) =>
    '${PrefKeys.rosterFilterPrefix}:${site.trim().toLowerCase()}:'
    '${user.trim().toLowerCase()}';

/// Where a filter is saved between visits.
abstract class RosterFilterStore {
  Future<RosterFilter?> load(String key);
  Future<void> save(String key, RosterFilter filter);
}

/// SharedPreferences, as JSON. An empty filter removes the key rather than
/// storing `{}`, so "show everyone" leaves nothing behind.
class SharedPrefsRosterFilterStore implements RosterFilterStore {
  const SharedPrefsRosterFilterStore();

  @override
  Future<RosterFilter?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return RosterFilter.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String key, RosterFilter filter) async {
    final prefs = await SharedPreferences.getInstance();
    if (filter.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(filter.toJson()));
    }
  }
}

/// In-memory store for tests. Holds the same JSON the real store writes, so a
/// round trip through it exercises the same encoding.
class MemoryRosterFilterStore implements RosterFilterStore {
  MemoryRosterFilterStore([Map<String, String>? values])
    : values = values ?? <String, String>{};

  final Map<String, String> values;

  @override
  Future<RosterFilter?> load(String key) async {
    final raw = values[key];
    if (raw == null) return null;
    return RosterFilter.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> save(String key, RosterFilter filter) async {
    if (filter.isEmpty) {
      values.remove(key);
    } else {
      values[key] = jsonEncode(filter.toJson());
    }
  }
}

final rosterFilterStoreProvider = Provider<RosterFilterStore>(
  (ref) => const SharedPrefsRosterFilterStore(),
);

/// The prefs key for the signed-in user on this site, or null while the user
/// is unknown (then nothing is restored or saved).
final rosterFilterKeyProvider = FutureProvider<String?>((ref) async {
  final roles = await ref.watch(userRolesFutureProvider.future);
  final user = roles.user.trim();
  if (user.isEmpty) return null;
  return rosterFilterPrefsKey(site: rosterFilterSite(), user: user);
});

/// Holds the filter, restores it from [RosterFilterStore] and saves it on
/// [apply].
///
/// Deliberately has no provider dependencies of its own: the plan wizard and
/// the grid read it without pulling in the user/HTTP stack. Restoring is
/// driven by [rosterFilterRestoreProvider], which the screen watches.
class RosterFilterController extends StateNotifier<RosterFilter> {
  RosterFilterController(this._store) : super(RosterFilter.empty);

  final RosterFilterStore _store;
  String? _key;

  /// Set once the user applies a filter, so a slow restore cannot overwrite
  /// what they just chose.
  bool _touched = false;

  /// Load the filter saved under [key]. A different key (another user) starts
  /// from empty first.
  Future<void> restore(String key) async {
    if (key == _key) return;
    final hadKey = _key != null;
    _key = key;
    if (hadKey) {
      _touched = false;
      state = RosterFilter.empty;
    }
    if (_touched) {
      // Chosen before the user was known: keep it, and save it now.
      await _save(key, state);
      return;
    }
    RosterFilter? saved;
    try {
      saved = await _store.load(key);
    } catch (_) {
      saved = null;
    }
    if (!mounted || _touched || _key != key || saved == null) return;
    state = saved;
  }

  /// Show [filter] and remember it for next time.
  Future<void> apply(RosterFilter filter) async {
    _touched = true;
    state = filter;
    final key = _key;
    if (key != null) await _save(key, filter);
  }

  Future<void> _save(String key, RosterFilter filter) async {
    try {
      await _store.save(key, filter);
    } catch (_) {
      // Persistence is a convenience; the filter on screen already applies.
    }
  }
}

/// The filter as the user set it (or as restored). The grid draws the pruned
/// [rosterEffectiveFilterProvider], not this.
final rosterFilterProvider =
    StateNotifierProvider<RosterFilterController, RosterFilter>(
      (ref) => RosterFilterController(ref.watch(rosterFilterStoreProvider)),
    );

/// Watched by the screen: once the user is known, restore their saved filter.
final rosterFilterRestoreProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<String?>>(rosterFilterKeyProvider, (_, next) {
    final key = next.valueOrNull;
    if (key != null) ref.read(rosterFilterProvider.notifier).restore(key);
  }, fireImmediately: true);
});

/// [rosterFilterProvider] pruned against what is loaded
/// ([rosterEffectiveFilter]). What the grid, totals, hours and the filter
/// button all use.
final rosterEffectiveFilterProvider = Provider<RosterFilter>((ref) {
  final filter = ref.watch(rosterFilterProvider);
  if (filter.isEmpty) return filter;
  final bootstrap = ref.watch(rosterBootstrapProvider).valueOrNull;
  final month = ref.watch(rosterMonthDataProvider).valueOrNull;
  return rosterEffectiveFilter(
    filter,
    knownLocations: rosterKnownLocations(bootstrap: bootstrap, month: month),
    knownEmployees: month == null
        ? null
        : {for (final e in month.employees) e.employee},
  );
});

/// The loaded roster with the filter applied. Synchronous over
/// [rosterMonthDataProvider], so changing the filter never shows a spinner.
final rosterVisibleMonthProvider = Provider<AsyncValue<RosterMonth>>((ref) {
  final filter = ref.watch(rosterEffectiveFilterProvider);
  return ref
      .watch(rosterMonthDataProvider)
      .whenData((month) => rosterApplyFilter(month, filter));
});

/// The month's hours, narrowed to the people the grid shows.
///
/// Hours rows carry no branch, so "who is visible" is worked out from the
/// loaded roster: the people picked by name plus everyone the roster says
/// belongs to a picked branch.
final rosterVisibleHoursProvider = Provider<AsyncValue<RosterHours>>((ref) {
  final filter = ref.watch(rosterEffectiveFilterProvider);
  final hours = ref.watch(rosterHoursProvider);
  if (filter.isEmpty) return hours;
  final month = ref.watch(rosterMonthDataProvider).valueOrNull;
  final visible = <String>{
    ...filter.employees,
    ...?month?.employees
        .where((e) => rosterRowVisible(e, filter))
        .map((e) => e.employee),
  };
  return hours.whenData((h) => rosterFilterHours(h, visible));
});
