import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/woo_sync_dashboard.dart';
import '../../data/models/woo_sync_event.dart';
import '../../data/repositories/woo_sync_repository.dart';
import 'woo_sync_filters.dart';

final wooSyncConsoleProvider =
    StateNotifierProvider<WooSyncConsoleNotifier, WooSyncConsoleState>((ref) {
  final repo = ref.watch(wooSyncRepositoryProvider);
  return WooSyncConsoleNotifier(repo);
});

class WooSyncConsoleState {
  final WooSyncDashboard? dashboard;
  final bool dashboardLoading;
  final String? dashboardError;

  final List<WooSyncEvent> events;
  final bool eventsLoading;
  final String? eventsError;

  final WooSyncFilters filters;

  /// Names of events currently checked for a bulk action.
  final Set<String> selected;

  /// Names of events with a single-row action in flight (retry / process
  /// now / review-state save) — used to show a per-row spinner and disable
  /// that row's actions without freezing the rest of the list.
  final Set<String> busyEventNames;

  final bool bulkActionBusy;

  /// True while `run_worker` or `clear_outbound_breaker` is in flight — both
  /// are system-wide actions, so the whole console's action buttons disable
  /// rather than just one row.
  final bool consoleActionBusy;

  const WooSyncConsoleState({
    this.dashboard,
    this.dashboardLoading = false,
    this.dashboardError,
    this.events = const [],
    this.eventsLoading = false,
    this.eventsError,
    this.filters = const WooSyncFilters(),
    this.selected = const {},
    this.busyEventNames = const {},
    this.bulkActionBusy = false,
    this.consoleActionBusy = false,
  });

  WooSyncConsoleState copyWith({
    WooSyncDashboard? dashboard,
    bool? dashboardLoading,
    String? dashboardError,
    bool clearDashboardError = false,
    List<WooSyncEvent>? events,
    bool? eventsLoading,
    String? eventsError,
    bool clearEventsError = false,
    WooSyncFilters? filters,
    Set<String>? selected,
    Set<String>? busyEventNames,
    bool? bulkActionBusy,
    bool? consoleActionBusy,
  }) {
    return WooSyncConsoleState(
      dashboard: dashboard ?? this.dashboard,
      dashboardLoading: dashboardLoading ?? this.dashboardLoading,
      dashboardError: clearDashboardError ? null : (dashboardError ?? this.dashboardError),
      events: events ?? this.events,
      eventsLoading: eventsLoading ?? this.eventsLoading,
      eventsError: clearEventsError ? null : (eventsError ?? this.eventsError),
      filters: filters ?? this.filters,
      selected: selected ?? this.selected,
      busyEventNames: busyEventNames ?? this.busyEventNames,
      bulkActionBusy: bulkActionBusy ?? this.bulkActionBusy,
      consoleActionBusy: consoleActionBusy ?? this.consoleActionBusy,
    );
  }
}

class WooSyncConsoleNotifier extends StateNotifier<WooSyncConsoleState> {
  final WooSyncRepository _repo;
  WooSyncConsoleNotifier(this._repo) : super(const WooSyncConsoleState()) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([refreshDashboard(), refreshEvents()]);
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(dashboardLoading: true, clearDashboardError: true);
    try {
      final dashboard = await _repo.getDashboard();
      state = state.copyWith(dashboard: dashboard, dashboardLoading: false);
    } catch (e) {
      state = state.copyWith(dashboardLoading: false, dashboardError: e.toString());
    }
  }

  Future<void> refreshEvents() async {
    state = state.copyWith(eventsLoading: true, clearEventsError: true);
    try {
      final f = state.filters;
      final events = await _repo.getEvents(
        status: f.status,
        direction: f.direction,
        eventType: f.eventType,
        reviewState: f.reviewState,
        search: f.search,
        // Comfortably above the 100-name bulk-action cap so "select all" can
        // actually exceed it — the UI enforces that cap itself rather than
        // silently truncating the selection to match.
        limit: 200,
      );
      // `attentionOnly` has no single server-side status filter to ask for —
      // "needs attention" is Failed + NeedsReview + DeadLetter together — so
      // it is applied client-side, and only when the operator has not picked
      // a specific status of their own.
      final visible = (f.status == null && f.attentionOnly)
          ? events.where((e) => e.needsAttention).toList()
          : events;
      // Selection can only ever shrink on a reload — an event that dropped
      // out of the visible list (retried, resolved, filtered away) has
      // nothing left for a bulk action to apply to.
      final visibleNames = visible.map((e) => e.name).toSet();
      final selected = state.selected.intersection(visibleNames);
      state = state.copyWith(events: visible, eventsLoading: false, selected: selected);
    } catch (e) {
      state = state.copyWith(eventsLoading: false, eventsError: e.toString());
    }
  }

  void setFilters(WooSyncFilters filters) {
    state = state.copyWith(filters: filters);
    refreshEvents();
  }

  void toggleSelected(String eventName) {
    final next = Set<String>.from(state.selected);
    if (!next.add(eventName)) next.remove(eventName);
    state = state.copyWith(selected: next);
  }

  void clearSelection() => state = state.copyWith(selected: const {});

  void selectAllVisible() {
    state = state.copyWith(selected: state.events.map((e) => e.name).toSet());
  }

  Future<void> retrySingle(String eventName) async {
    final busy = Set<String>.from(state.busyEventNames)..add(eventName);
    state = state.copyWith(busyEventNames: busy);
    try {
      await _repo.retryEvent(eventName);
      await refreshAll();
    } finally {
      final cleared = Set<String>.from(state.busyEventNames)..remove(eventName);
      state = state.copyWith(busyEventNames: cleared);
    }
  }

  Future<void> processNow(String eventName) async {
    final busy = Set<String>.from(state.busyEventNames)..add(eventName);
    state = state.copyWith(busyEventNames: busy);
    try {
      await _repo.processEventNow(eventName);
      await refreshAll();
    } finally {
      final cleared = Set<String>.from(state.busyEventNames)..remove(eventName);
      state = state.copyWith(busyEventNames: cleared);
    }
  }

  Future<void> setReviewStateSingle(
    String eventName,
    String reviewState, {
    String? notes,
  }) async {
    final busy = Set<String>.from(state.busyEventNames)..add(eventName);
    state = state.copyWith(busyEventNames: busy);
    try {
      await _repo.setReviewState(eventName, reviewState, resolutionNotes: notes);
      await refreshAll();
    } finally {
      final cleared = Set<String>.from(state.busyEventNames)..remove(eventName);
      state = state.copyWith(busyEventNames: cleared);
    }
  }

  /// Throws [ArgumentError] before ever calling the server if the selection
  /// exceeds [WooSyncRepository.bulkNameLimit] — the caller (the screen)
  /// turns that into the "narrow your selection" message rather than the
  /// server silently acting on only the first 100.
  Future<Map<String, dynamic>> retrySelected() async {
    final names = state.selected.toList();
    state = state.copyWith(bulkActionBusy: true);
    try {
      final result = await _repo.retryEvents(names);
      clearSelection();
      await refreshAll();
      return result;
    } finally {
      state = state.copyWith(bulkActionBusy: false);
    }
  }

  Future<Map<String, dynamic>> setReviewStateSelected(String reviewState, {String? notes}) async {
    final names = state.selected.toList();
    state = state.copyWith(bulkActionBusy: true);
    try {
      final result = await _repo.setReviewStateBulk(names, reviewState, resolutionNotes: notes);
      clearSelection();
      await refreshAll();
      return result;
    } finally {
      state = state.copyWith(bulkActionBusy: false);
    }
  }

  Future<Map<String, dynamic>> runWorker() async {
    state = state.copyWith(consoleActionBusy: true);
    try {
      final result = await _repo.runWorker();
      await refreshAll();
      return result;
    } finally {
      state = state.copyWith(consoleActionBusy: false);
    }
  }

  Future<Map<String, dynamic>> clearBreaker() async {
    state = state.copyWith(consoleActionBusy: true);
    try {
      final result = await _repo.clearOutboundBreaker();
      await refreshAll();
      return result;
    } finally {
      state = state.copyWith(consoleActionBusy: false);
    }
  }

  Future<Map<String, dynamic>> pushInvoice(String invoiceName) async {
    return _repo.pushSalesInvoice(invoiceName);
  }
}
