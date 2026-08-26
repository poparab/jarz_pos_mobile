import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journey/presentation/journey_format.dart';
import '../../leads/state/my_location_notifier.dart';
import '../data/models/visit_plan.dart';
import '../data/visits_repository.dart';
import 'visit_plans_notifier.dart';

/// The day being assembled, before it becomes a plan.
///
/// Suggestion and hand-picking are the same state on purpose. A rep almost
/// never wants purely one or the other: the planner proposes nine doors, the
/// rep drops two they know are shut on Saturdays and adds one they promised to
/// drop in on. Modelling "suggested" and "chosen" as one editable set is what
/// makes that a single gesture instead of two modes.
class VisitBuilderState {
  const VisitBuilderState({
    required this.visitDate,
    this.suggestion,
    this.selected = const <String, VisitTarget>{},
    this.maxStops = 12,
    this.dayMinutes = 360,
    this.category,
    this.tier,
    this.area,
    this.specialtyOnly = false,
    this.includeCustomers = true,
    this.useMyLocation = true,
    this.busy = false,
    this.error,
  });

  final DateTime visitDate;
  final VisitSuggestion? suggestion;

  /// Chosen doors, keyed by [VisitTarget.key]. A map, not a list, because the
  /// same door reached from the suggestion and from the catalog must be one
  /// entry — a route with a duplicate stop wastes a slot in a finite day.
  final Map<String, VisitTarget> selected;

  final int maxStops;
  final int dayMinutes;
  final String? category;
  final String? tier;
  final String? area;
  final bool specialtyOnly;
  final bool includeCustomers;

  /// Seed the cluster at the rep's live position. Off means "anywhere" — the
  /// planner then picks the densest high-value cluster in the corpus, which is
  /// the right answer for planning next Saturday from the sofa.
  final bool useMyLocation;

  final bool busy;
  final String? error;

  bool get hasSelection => selected.isNotEmpty;
  int get selectedCount => selected.length;
  String get isoDate => JourneyFormat.iso(visitDate);

  bool isSelected(VisitTarget target) => selected.containsKey(target.key);

  VisitBuilderState copyWith({
    DateTime? visitDate,
    VisitSuggestion? suggestion,
    Map<String, VisitTarget>? selected,
    int? maxStops,
    int? dayMinutes,
    String? category,
    String? tier,
    String? area,
    bool? specialtyOnly,
    bool? includeCustomers,
    bool? useMyLocation,
    bool? busy,
    String? error,
    bool clearError = false,
    bool clearFilters = false,
  }) =>
      VisitBuilderState(
        visitDate: visitDate ?? this.visitDate,
        suggestion: suggestion ?? this.suggestion,
        selected: selected ?? this.selected,
        maxStops: maxStops ?? this.maxStops,
        dayMinutes: dayMinutes ?? this.dayMinutes,
        category: clearFilters ? null : (category ?? this.category),
        tier: clearFilters ? null : (tier ?? this.tier),
        area: clearFilters ? null : (area ?? this.area),
        specialtyOnly: specialtyOnly ?? this.specialtyOnly,
        includeCustomers: includeCustomers ?? this.includeCustomers,
        useMyLocation: useMyLocation ?? this.useMyLocation,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

final visitBuilderProvider =
    NotifierProvider.autoDispose<VisitBuilderNotifier, VisitBuilderState>(
        VisitBuilderNotifier.new);

class VisitBuilderNotifier extends AutoDisposeNotifier<VisitBuilderState> {
  @override
  VisitBuilderState build() {
    final engine = ref.watch(routeEngineStatusProvider).valueOrNull;
    return VisitBuilderState(
      visitDate: _nextVisitDay(engine?.visitDays ?? const <String>[]),
      maxStops: engine?.maxStops ?? 12,
      dayMinutes: engine?.dayMinutes ?? 360,
    );
  }

  VisitsRepository get _repo => ref.read(visitsRepositoryProvider);

  /// The next day the team actually does field visits.
  ///
  /// With no configured days this is simply tomorrow. With them, it is the
  /// soonest one — opening the builder on a Wednesday when the team visits on
  /// Saturdays should not default to Thursday and quietly propose a day nobody
  /// will drive.
  static DateTime _nextVisitDay(List<String> visitDays) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (visitDays.isEmpty) return tomorrow;
    const names = <String>[
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final wanted = visitDays
        .map((d) => names.indexWhere((n) => n.toLowerCase() == d.toLowerCase()) + 1)
        .where((n) => n > 0)
        .toSet();
    if (wanted.isEmpty) return tomorrow;
    var candidate = tomorrow;
    for (var i = 0; i < 7; i++) {
      if (wanted.contains(candidate.weekday)) return candidate;
      candidate = candidate.add(const Duration(days: 1));
    }
    return tomorrow;
  }

  void setDate(DateTime date) => state = state.copyWith(visitDate: date);
  void setMaxStops(int value) => state = state.copyWith(maxStops: value);
  void setDayMinutes(int value) => state = state.copyWith(dayMinutes: value);
  void setCategory(String? value) => state = state.copyWith(category: value);
  void setTier(String? value) => state = state.copyWith(tier: value);
  void setArea(String? value) => state = state.copyWith(area: value);
  void setSpecialtyOnly(bool value) =>
      state = state.copyWith(specialtyOnly: value);
  void setIncludeCustomers(bool value) =>
      state = state.copyWith(includeCustomers: value);
  void setUseMyLocation(bool value) =>
      state = state.copyWith(useMyLocation: value);

  void clearFilters() => state = state.copyWith(clearFilters: true);

  void toggle(VisitTarget target) {
    final next = Map<String, VisitTarget>.from(state.selected);
    if (next.containsKey(target.key)) {
      next.remove(target.key);
    } else {
      next[target.key] = target;
    }
    state = state.copyWith(selected: next);
  }

  void addAll(Iterable<VisitTarget> targets) {
    final next = Map<String, VisitTarget>.from(state.selected);
    for (final target in targets) {
      next[target.key] = target;
    }
    state = state.copyWith(selected: next);
  }

  void clearSelection() =>
      state = state.copyWith(selected: const <String, VisitTarget>{});

  /// Ask the server to propose a day, and adopt what it proposes.
  ///
  /// The proposal REPLACES the selection rather than merging into it: "suggest
  /// me a day" means exactly that, and silently keeping earlier picks would
  /// blow past the stop limit the suggestion was solved against.
  Future<void> suggest() async {
    state = state.copyWith(busy: true, clearError: true);
    double? lat;
    double? lng;
    if (state.useMyLocation) {
      // locate() returns void and publishes into the provider's state, so the
      // fix is read back rather than returned. A refusal leaves position null,
      // which the server reads as "no anchor" — the suggestion still comes
      // back, just clustered on value instead of on where the rep is standing.
      await ref.read(myLocationProvider.notifier).locate();
      final located = ref.read(myLocationProvider).position;
      lat = located?.latitude;
      lng = located?.longitude;
    }
    try {
      final suggestion = await _repo.suggest(
        visitDate: state.isoDate,
        maxStops: state.maxStops,
        startLatitude: lat,
        startLongitude: lng,
        category: state.category,
        tier: state.tier,
        area: state.area,
        specialtyOnly: state.specialtyOnly,
        includeCustomers: state.includeCustomers,
        dayMinutes: state.dayMinutes,
      );
      state = state.copyWith(
        suggestion: suggestion,
        selected: {for (final t in suggestion.targets) t.key: t},
        busy: false,
      );
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
    }
  }

  /// Commit the selection as a real plan. Returns its name, or null on failure.
  ///
  /// The stops go up in the order they were chosen and the server optimises
  /// them — the selection is a SET of doors, and the sequence is the router's
  /// job, not the order the rep happened to tick boxes in.
  Future<String?> createPlan({String? title}) async {
    if (!state.hasSelection) return null;
    state = state.copyWith(busy: true, clearError: true);
    double? lat;
    double? lng;
    if (state.useMyLocation) {
      final located = ref.read(myLocationProvider).position;
      lat = located?.latitude;
      lng = located?.longitude;
    }
    try {
      final plan = await _repo.createPlan(
        visitDate: state.isoDate,
        title: title,
        stops: state.selected.values.map((t) => t.toStopPayload()).toList(),
        startLatitude: lat,
        startLongitude: lng,
        startLabel: lat != null ? 'Current location' : null,
        startMode: lat != null ? 'Fixed Point' : 'Current Location',
        status: 'Planned',
        optimize: true,
      );
      state = state.copyWith(busy: false);
      ref.invalidate(visitPlansProvider);
      return plan.name;
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
      return null;
    }
  }

  String _message(Object error) {
    final text = error.toString();
    final match = RegExp(r'"message":\s*"([^"]+)"').firstMatch(text);
    if (match != null) return match.group(1)!.replaceAll(r'\n', ' ');
    return text;
  }
}

/// Doors matching the builder's coarse filters, ranked best first.
///
/// Separate from the suggestion so a rep can browse and hand-pick without ever
/// asking for a proposal — the two paths feed the same selection.
final visitTargetsProvider =
    FutureProvider.autoDispose<List<VisitTarget>>((ref) async {
  final state = ref.watch(visitBuilderProvider);
  return ref.watch(visitsRepositoryProvider).getTargets(
        category: state.category,
        tier: state.tier,
        area: state.area,
        specialtyOnly: state.specialtyOnly,
        includeCustomers: state.includeCustomers,
        limit: 300,
      );
});
