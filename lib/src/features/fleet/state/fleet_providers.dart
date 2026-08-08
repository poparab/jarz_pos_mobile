import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fleet_repository.dart';
import '../data/models/fleet_models.dart';

/// How often the map re-reads positions while it is on screen.
///
/// The endpoint only touches Redis, so this is cheap; it is still stopped the
/// moment the screen is hidden, because a dispatcher leaves this open all day.
const Duration kFleetPollInterval = Duration(seconds: 20);

/// Optional server-side branch scope for the tracking call.
///
/// Left null by the UI today, which makes the backend answer with the caller's
/// own scope. It is a real seam rather than dead code: set it and the next poll
/// is scoped. Note that an empty scope yields *nothing*, not everything — so
/// nothing here may "helpfully" retry unscoped when a branch comes back empty.
final fleetBranchFilterProvider = StateProvider<String?>((ref) => null);

/// Everything the live map needs to render one frame.
class FleetState {
  const FleetState({
    this.snapshot,
    this.error,
    this.isLoading = false,
    this.isRefreshing = false,
  });

  const FleetState.initial() : this(isLoading: true);

  /// Last successful read. Deliberately kept across a failed poll so the map
  /// does not blank out — the dots simply keep ageing towards stale, which is
  /// the honest thing to show when the server has gone quiet.
  final FleetSnapshot? snapshot;

  /// Error from the most recent attempt, cleared by the next success.
  final Object? error;

  /// First load, with nothing on screen yet.
  final bool isLoading;

  /// A poll is in flight over data we already have.
  final bool isRefreshing;

  /// Whether the failure is the permanent, supervisor-only one.
  bool get isPermissionDenied => error is FleetPermissionDeniedException;

  /// A poll failed and we are showing data from before it.
  bool get isShowingStaleAfterFailure => error != null && snapshot != null;

  FleetState copyWith({
    FleetSnapshot? snapshot,
    Object? error,
    bool clearError = false,
    bool? isLoading,
    bool? isRefreshing,
  }) {
    return FleetState(
      snapshot: snapshot ?? this.snapshot,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Polls the tracking endpoint while the map is visible.
class FleetController extends StateNotifier<FleetState> {
  FleetController({
    required FleetRepository repository,
    String? branch,
    Duration pollInterval = kFleetPollInterval,
  }) : _repository = repository,
       _branch = branch,
       _pollInterval = pollInterval,
       super(const FleetState.initial()) {
    unawaited(_load());
    _startTimer();
  }

  final FleetRepository _repository;
  final String? _branch;
  final Duration _pollInterval;

  Timer? _timer;
  bool _active = true;

  /// Whether the poll timer is currently running. Exposed for tests.
  bool get isPolling => _timer != null;

  /// Called by the screen when it is covered, backgrounded, or revealed again.
  ///
  /// Hiding cancels the timer outright rather than skipping ticks, so a screen
  /// left open behind another one costs the server nothing.
  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (active) {
      unawaited(_load());
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  /// Manual refresh from the app bar / retry button.
  Future<void> refresh() => _load();

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(_pollInterval, (_) {
      if (_active) unawaited(_load());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _load() async {
    if (!mounted || state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);

    try {
      final snapshot = await _repository.getLivePositions(branch: _branch);
      if (!mounted) return;
      state = FleetState(snapshot: snapshot);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        error: error,
        isLoading: false,
        isRefreshing: false,
      );
      // A 403 is a role decision, not a hiccup: polling it again just burns
      // requests to be told "no" once every 20 seconds.
      if (error is FleetPermissionDeniedException) _stopTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// Auto-disposed so leaving the screen tears the poll timer down with it.
final fleetControllerProvider =
    StateNotifierProvider.autoDispose<FleetController, FleetState>((ref) {
      return FleetController(
        repository: ref.watch(fleetRepositoryProvider),
        branch: ref.watch(fleetBranchFilterProvider),
      );
    });
