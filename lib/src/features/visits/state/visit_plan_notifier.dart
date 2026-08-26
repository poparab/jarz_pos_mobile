import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/visit_plan.dart';
import '../data/visits_repository.dart';
import 'visit_plans_notifier.dart';

/// One plan, plus every mutation that can be made to it.
///
/// Every write returns the whole plan from the server and replaces the state
/// with it, rather than patching the local copy. That is not laziness: the
/// server recomputes leg distances, arrival times and day totals on every
/// save, so a locally-patched plan would show a stale route the moment
/// anything moved. One round trip is cheap; a screen that disagrees with the
/// route is not.
///
/// [busy] is separate from the async state so the screen can keep showing the
/// current route while a re-optimise is in flight — replacing it with a
/// spinner loses the rep's place in a list they are working down.
class VisitPlanState {
  const VisitPlanState({this.plan, this.busy = false, this.error});

  final VisitPlan? plan;
  final bool busy;
  final String? error;

  VisitPlanState copyWith({
    VisitPlan? plan,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      VisitPlanState(
        plan: plan ?? this.plan,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

final visitPlanProvider = NotifierProvider.autoDispose
    .family<VisitPlanNotifier, VisitPlanState, String>(VisitPlanNotifier.new);

class VisitPlanNotifier
    extends AutoDisposeFamilyNotifier<VisitPlanState, String> {
  @override
  VisitPlanState build(String planName) {
    Future.microtask(load);
    return const VisitPlanState(busy: true);
  }

  VisitsRepository get _repo => ref.read(visitsRepositoryProvider);

  /// Fetch the plan. [withGeometry] asks for the drawn road path, which is
  /// only worth the extra hop once the map is actually on screen.
  Future<void> load({bool withGeometry = true}) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final plan = await _repo.getPlan(arg, withGeometry: withGeometry);
      state = VisitPlanState(plan: plan);
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
    }
  }

  Future<void> _mutate(Future<VisitPlan> Function() action) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final plan = await action();
      state = VisitPlanState(plan: plan);
      // The calendar shows this plan's stop count and totals, so any write
      // here makes its cached month stale.
      ref.invalidate(visitPlansProvider);
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
    }
  }

  /// Reorder into the fastest sequence.
  ///
  /// [startLatitude]/[startLongitude] carry the rep's live position for a
  /// "start from where I am" optimise. They are sent per call rather than
  /// saved on the plan, because that point is different every morning.
  Future<void> optimize({double? startLatitude, double? startLongitude}) =>
      _mutate(() => _repo.optimize(
            arg,
            startLatitude: startLatitude,
            startLongitude: startLongitude,
          ));

  /// Persist a hand-dragged order. `optimize: false` is the whole point — the
  /// rep has overruled the optimiser and a quiet re-shuffle would be a bug.
  Future<void> reorder(List<VisitStop> stops) => _mutate(
        () => _repo.setStops(
          arg,
          stops.map((s) => s.toPayload()).toList(),
          optimize: false,
        ),
      );

  /// Move a stop from [oldIndex] to [newIndex] and save the result.
  ///
  /// Applies the move optimistically so the list settles under the finger
  /// instead of snapping back while the write is in flight; a failed write
  /// still replaces the state with the server's truth.
  Future<void> moveStop(int oldIndex, int newIndex) async {
    final current = state.plan;
    if (current == null) return;
    final stops = [...current.stops];
    if (oldIndex < 0 || oldIndex >= stops.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target >= stops.length) target = stops.length - 1;
    if (target == oldIndex) return;

    final moved = stops.removeAt(oldIndex);
    stops.insert(target, moved);
    state = state.copyWith(plan: current.copyWith(stops: stops));
    await reorder(stops);
  }

  Future<void> addStops(List<Map<String, dynamic>> stops,
          {bool optimize = true}) =>
      _mutate(() => _repo.addStops(arg, stops, optimize: optimize));

  Future<void> removeStop(String stopName) {
    final current = state.plan;
    if (current == null) return Future.value();
    final remaining =
        current.stops.where((s) => s.name != stopName).map((s) => s.toPayload());
    return _mutate(
      () => _repo.setStops(arg, remaining.toList(), optimize: false),
    );
  }

  /// Pin or unpin a stop's position in the route.
  Future<void> setLocked(String stopName, bool locked) {
    final current = state.plan;
    if (current == null) return Future.value();
    final payload = current.stops
        .map((s) => s.name == stopName
            ? s.copyWith(locked: locked).toPayload()
            : s.toPayload())
        .toList();
    return _mutate(() => _repo.setStops(arg, payload, optimize: false));
  }

  Future<void> checkIn({
    required String stopName,
    required String status,
    String? outcome,
    bool logNote = false,
    String? noteText,
    String? nextAction,
    String? nextActionDate,
  }) =>
      _mutate(() => _repo.setStopStatus(
            plan: arg,
            stop: stopName,
            status: status,
            outcome: outcome,
            logNote: logNote,
            noteText: noteText,
            nextAction: nextAction,
            nextActionDate: nextActionDate,
          ));

  Future<void> updateHeader({
    String? visitDate,
    String? title,
    String? status,
    String? notes,
    String? plannedStartTime,
    int? defaultVisitMinutes,
    bool? returnToStart,
    String? rep,
  }) =>
      _mutate(() => _repo.updatePlan(
            arg,
            visitDate: visitDate,
            title: title,
            status: status,
            notes: notes,
            plannedStartTime: plannedStartTime,
            defaultVisitMinutes: defaultVisitMinutes,
            returnToStart: returnToStart,
            rep: rep,
          ));

  Future<bool> deletePlan() async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repo.deletePlan(arg);
      ref.invalidate(visitPlansProvider);
      return true;
    } catch (error) {
      state = state.copyWith(busy: false, error: _message(error));
      return false;
    }
  }

  /// Frappe puts the useful half of an error in `_server_messages`; the raw
  /// DioException reads as "http 417" and tells a rep nothing they can act on.
  String _message(Object error) {
    final text = error.toString();
    final match = RegExp(r'"message":\s*"([^"]+)"').firstMatch(text);
    if (match != null) return match.group(1)!.replaceAll(r'\n', ' ');
    return text;
  }
}
