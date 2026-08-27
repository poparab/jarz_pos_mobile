import 'dart:async';

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
///
/// [preview] is the same set, ordered and costed by the SERVER. It is what
/// makes the builder a route rather than a shopping list: the rep sees the map
/// line, the sequence and the day's length while they are still choosing, and
/// what they approve is exactly what gets saved.
class VisitBuilderState {
  const VisitBuilderState({
    required this.visitDate,
    this.suggestion,
    this.selected = const <String, VisitTarget>{},
    this.preview,
    this.previewing = false,
    this.manualOrder,
    this.maxStops = 12,
    this.dayMinutes = 360,
    this.category,
    this.tier,
    this.area,
    this.specialtyOnly = false,
    this.includeCustomers = true,
    this.neverVisitedOnly = false,
    this.minFitScore = 0,
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

  /// The server's ordering and costing of [selected]. Null until the first
  /// preview returns.
  final RoutePreview? preview;

  /// A preview is in flight. Deliberately separate from [busy] so the current
  /// route stays on screen while the next one is computed — blanking it on
  /// every checkbox tick would make the screen strobe.
  final bool previewing;

  /// Door keys in the order the rep dragged them, or null while the optimiser
  /// owns the order. Its presence is what tells the preview call not to
  /// re-solve: a rep who moved a stop has overruled the machine, and quietly
  /// re-sorting them is the single fastest way to lose their trust.
  final List<String>? manualOrder;

  final int maxStops;
  final int dayMinutes;

  // ── Filters ──────────────────────────────────────────────────────────
  final String? category;
  final String? tier;
  final String? area;
  final bool specialtyOnly;
  final bool includeCustomers;
  final bool neverVisitedOnly;
  final double minFitScore;

  /// Seed the cluster at the rep's live position. Off means "anywhere" — the
  /// planner then picks the densest high-value cluster in the corpus, which is
  /// the right answer for planning next Saturday from the sofa.
  final bool useMyLocation;

  final bool busy;
  final String? error;

  bool get hasSelection => selected.isNotEmpty;
  int get selectedCount => selected.length;
  String get isoDate => JourneyFormat.iso(visitDate);
  bool get isManualOrder => manualOrder != null;

  /// Whether any filter narrows the candidate pool, for the badge on the
  /// filter button.
  int get activeFilterCount => [
        category != null,
        tier != null,
        area != null,
        specialtyOnly,
        neverVisitedOnly,
        minFitScore > 0,
        !includeCustomers,
      ].where((on) => on).length;

  bool isSelected(VisitTarget target) => selected.containsKey(target.key);

  VisitBuilderState copyWith({
    DateTime? visitDate,
    VisitSuggestion? suggestion,
    Map<String, VisitTarget>? selected,
    RoutePreview? preview,
    bool? previewing,
    List<String>? manualOrder,
    int? maxStops,
    int? dayMinutes,
    String? category,
    String? tier,
    String? area,
    bool? specialtyOnly,
    bool? includeCustomers,
    bool? neverVisitedOnly,
    double? minFitScore,
    bool? useMyLocation,
    bool? busy,
    String? error,
    bool clearError = false,
    bool clearFilters = false,
    bool clearManualOrder = false,
    bool clearPreview = false,
  }) =>
      VisitBuilderState(
        visitDate: visitDate ?? this.visitDate,
        suggestion: suggestion ?? this.suggestion,
        selected: selected ?? this.selected,
        preview: clearPreview ? null : (preview ?? this.preview),
        previewing: previewing ?? this.previewing,
        manualOrder: clearManualOrder ? null : (manualOrder ?? this.manualOrder),
        maxStops: maxStops ?? this.maxStops,
        dayMinutes: dayMinutes ?? this.dayMinutes,
        category: clearFilters ? null : (category ?? this.category),
        tier: clearFilters ? null : (tier ?? this.tier),
        area: clearFilters ? null : (area ?? this.area),
        specialtyOnly: clearFilters ? false : (specialtyOnly ?? this.specialtyOnly),
        includeCustomers:
            clearFilters ? true : (includeCustomers ?? this.includeCustomers),
        neverVisitedOnly:
            clearFilters ? false : (neverVisitedOnly ?? this.neverVisitedOnly),
        minFitScore: clearFilters ? 0 : (minFitScore ?? this.minFitScore),
        useMyLocation: useMyLocation ?? this.useMyLocation,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

final visitBuilderProvider =
    NotifierProvider.autoDispose<VisitBuilderNotifier, VisitBuilderState>(
        VisitBuilderNotifier.new);

class VisitBuilderNotifier extends AutoDisposeNotifier<VisitBuilderState> {
  Timer? _debounce;

  /// Guards against an out-of-order preview overwriting a newer one. Every
  /// request takes a ticket; only the newest ticket may publish its result.
  /// Without this, a slow response for three doors can land after a fast one
  /// for nine and silently show the rep the wrong day.
  int _previewTicket = 0;

  @override
  VisitBuilderState build() {
    final engine = ref.watch(routeEngineStatusProvider).valueOrNull;
    ref.onDispose(() => _debounce?.cancel());
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

  // ── Day settings ─────────────────────────────────────────────────────
  void setDate(DateTime date) => state = state.copyWith(visitDate: date);
  void setMaxStops(int value) => state = state.copyWith(maxStops: value);
  void setDayMinutes(int value) => state = state.copyWith(dayMinutes: value);
  void setUseMyLocation(bool value) {
    state = state.copyWith(useMyLocation: value);
    _schedulePreview();
  }

  // ── Filters ──────────────────────────────────────────────────────────
  void setCategory(String? value) => state = state.copyWith(category: value);
  void setTier(String? value) => state = state.copyWith(tier: value);
  void setArea(String? value) => state = state.copyWith(area: value);
  void setSpecialtyOnly(bool value) =>
      state = state.copyWith(specialtyOnly: value);
  void setIncludeCustomers(bool value) =>
      state = state.copyWith(includeCustomers: value);
  void setNeverVisitedOnly(bool value) =>
      state = state.copyWith(neverVisitedOnly: value);
  void setMinFitScore(double value) =>
      state = state.copyWith(minFitScore: value);
  void clearFilters() => state = state.copyWith(clearFilters: true);

  // ── Selection ────────────────────────────────────────────────────────
  void toggle(VisitTarget target) {
    final next = Map<String, VisitTarget>.from(state.selected);
    if (next.containsKey(target.key)) {
      next.remove(target.key);
    } else {
      next[target.key] = target;
    }
    // Adding or dropping a door invalidates a hand-made order: the sequence
    // the rep arranged no longer describes this set.
    state = state.copyWith(selected: next, clearManualOrder: true);
    _schedulePreview();
  }

  void addAll(Iterable<VisitTarget> targets) {
    final next = Map<String, VisitTarget>.from(state.selected);
    for (final target in targets) {
      next[target.key] = target;
    }
    state = state.copyWith(selected: next, clearManualOrder: true);
    _schedulePreview();
  }

  void removeKey(String key) {
    final next = Map<String, VisitTarget>.from(state.selected)..remove(key);
    state = state.copyWith(selected: next, clearManualOrder: true);
    _schedulePreview();
  }

  void clearSelection() {
    state = state.copyWith(
      selected: const <String, VisitTarget>{},
      clearManualOrder: true,
      clearPreview: true,
    );
  }

  // ── Ordering ─────────────────────────────────────────────────────────

  /// Move a stop within the previewed route and keep that order.
  ///
  /// Recomputes with `optimize: false`, so the server costs exactly the
  /// sequence the rep arranged rather than quietly putting it back.
  Future<void> moveStop(int oldIndex, int newIndex) async {
    final preview = state.preview;
    if (preview == null) return;
    final keys = preview.stops.map((s) => s.key).toList();
    if (oldIndex < 0 || oldIndex >= keys.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target >= keys.length) target = keys.length - 1;
    if (target == oldIndex) return;

    final moved = keys.removeAt(oldIndex);
    keys.insert(target, moved);
    state = state.copyWith(manualOrder: keys);
    await _refreshPreview();
  }

  /// Hand the order back to the optimiser.
  Future<void> optimise() async {
    state = state.copyWith(clearManualOrder: true);
    await _refreshPreview();
  }

  // ── Preview ──────────────────────────────────────────────────────────

  /// Coalesce bursts of checkbox ticks into one request.
  ///
  /// A rep selecting eight doors produces eight state changes in a couple of
  /// seconds; without this, that is eight round trips whose answers race each
  /// other.
  void _schedulePreview() {
    _debounce?.cancel();
    if (state.selected.isEmpty) {
      state = state.copyWith(clearPreview: true, previewing: false);
      return;
    }
    state = state.copyWith(previewing: true);
    _debounce = Timer(const Duration(milliseconds: 350), _refreshPreview);
  }

  Future<void> _refreshPreview() async {
    final ticket = ++_previewTicket;
    final chosen = state.selected;
    if (chosen.isEmpty) {
      state = state.copyWith(clearPreview: true, previewing: false);
      return;
    }

    // Honour a hand-made order by sending the stops in it.
    final order = state.manualOrder;
    final targets = <VisitTarget>[];
    if (order != null) {
      for (final key in order) {
        final target = chosen[key];
        if (target != null) targets.add(target);
      }
      for (final entry in chosen.entries) {
        if (!order.contains(entry.key)) targets.add(entry.value);
      }
    } else {
      targets.addAll(chosen.values);
    }

    final payload = targets.map((t) {
      final row = t.toStopPayload();
      row['key'] = t.key;
      return row;
    }).toList();

    double? lat;
    double? lng;
    if (state.useMyLocation) {
      final located = ref.read(myLocationProvider).position;
      lat = located?.latitude;
      lng = located?.longitude;
    }

    try {
      final preview = await _repo.previewRoute(
        stops: payload,
        startLatitude: lat,
        startLongitude: lng,
        optimize: order == null,
      );
      if (ticket != _previewTicket) return; // a newer request already won
      state = state.copyWith(preview: preview, previewing: false, clearError: true);
    } catch (error) {
      if (ticket != _previewTicket) return;
      // A failed preview must not lose the selection — the rep's choices are
      // the valuable part; the costing can be retried.
      state = state.copyWith(previewing: false, error: _message(error));
    }
  }

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
        minFitScore: state.minFitScore,
        includeCustomers: state.includeCustomers,
        dayMinutes: state.dayMinutes,
      );
      state = state.copyWith(
        suggestion: suggestion,
        selected: {for (final t in suggestion.targets) t.key: t},
        busy: false,
        clearManualOrder: true,
      );
      await _refreshPreview();
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
    }
  }

  /// Commit the selection as a real plan. Returns its name, or null on failure.
  ///
  /// Stops go up in the order the PREVIEW shows, and `optimize` is off when the
  /// rep arranged that order themselves — otherwise the route they just
  /// approved would be re-solved into a different one on the way in.
  Future<String?> createPlan({String? title, String? status}) async {
    if (!state.hasSelection) return null;
    state = state.copyWith(busy: true, clearError: true);

    final preview = state.preview;
    final ordered = <Map<String, dynamic>>[];
    if (preview != null && preview.stops.isNotEmpty) {
      for (final stop in preview.stops) {
        final target = state.selected[stop.key];
        ordered.add(target?.toStopPayload() ?? stop.toStopPayload());
      }
      // Anything the preview skipped (no pin) still belongs to the rep's
      // selection; the server refuses it with a clear message rather than us
      // dropping it silently here.
      final shown = preview.stops.map((s) => s.key).toSet();
      for (final entry in state.selected.entries) {
        if (!shown.contains(entry.key)) {
          ordered.add(entry.value.toStopPayload());
        }
      }
    } else {
      ordered.addAll(state.selected.values.map((t) => t.toStopPayload()));
    }

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
        stops: ordered,
        startLatitude: lat,
        startLongitude: lng,
        startLabel: lat != null ? 'Current location' : null,
        startMode: lat != null ? 'Fixed Point' : 'Current Location',
        status: status ?? 'Planned',
        optimize: !state.isManualOrder,
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

/// Doors matching the builder's filters, ranked best first.
///
/// Separate from the suggestion so a rep can browse and hand-pick without ever
/// asking for a proposal — the two paths feed the same selection.
final visitTargetsProvider =
    FutureProvider.autoDispose<List<VisitTarget>>((ref) async {
  final state = ref.watch(visitBuilderProvider);
  final targets = await ref.watch(visitsRepositoryProvider).getTargets(
        category: state.category,
        tier: state.tier,
        area: state.area,
        specialtyOnly: state.specialtyOnly,
        minFitScore: state.minFitScore,
        includeCustomers: state.includeCustomers,
        limit: 300,
      );
  // "Never visited" is a client-side cut: the server already tells every target
  // whether it has been visited, so asking it again would be a round trip for
  // something already in hand.
  if (!state.neverVisitedOnly) return targets;
  return targets.where((t) => t.neverVisited).toList();
});
