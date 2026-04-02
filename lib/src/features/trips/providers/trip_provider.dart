import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_models.dart';
import '../services/trip_service.dart';
import '../../../core/network/dio_provider.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final tripServiceProvider = Provider<TripService>((ref) {
  final dio = ref.watch(dioProvider);
  return TripService(dio);
});

final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  final svc = ref.watch(tripServiceProvider);
  return TripNotifier(svc);
});

/// Isolated provider for a single trip's details.
/// Uses autoDispose + family so each detail screen has independent loading state
/// and no race with the trip-list provider.
final tripDetailProvider =
    FutureProvider.autoDispose.family<DeliveryTrip, String>((ref, tripName) async {
  final svc = ref.watch(tripServiceProvider);
  return svc.getTripDetails(tripName);
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class TripState {
  final List<DeliveryTrip> trips;
  final DeliveryTrip? selectedTrip;
  final bool isLoading;
  final String? error;
  /// Multi-select mode: invoice IDs currently checked
  final Set<String> selectedInvoiceIds;
  final bool multiSelectActive;

  const TripState({
    this.trips = const [],
    this.selectedTrip,
    this.isLoading = false,
    this.error,
    this.selectedInvoiceIds = const {},
    this.multiSelectActive = false,
  });

  TripState copyWith({
    List<DeliveryTrip>? trips,
    DeliveryTrip? selectedTrip,
    bool? isLoading,
    String? error,
    Set<String>? selectedInvoiceIds,
    bool? multiSelectActive,
    bool clearSelectedTrip = false,
    bool clearError = false,
  }) {
    return TripState(
      trips: trips ?? this.trips,
      selectedTrip: clearSelectedTrip ? null : (selectedTrip ?? this.selectedTrip),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedInvoiceIds: selectedInvoiceIds ?? this.selectedInvoiceIds,
      multiSelectActive: multiSelectActive ?? this.multiSelectActive,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class TripNotifier extends StateNotifier<TripState> {
  final TripService _service;
  bool _didInitialAutoRetry = false;

  TripNotifier(this._service) : super(const TripState());

  // ── Multi-select ──────────────────────────────────────────────────────

  void toggleMultiSelect() {
    if (state.multiSelectActive) {
      // Turning off → clear selections
      state = state.copyWith(multiSelectActive: false, selectedInvoiceIds: {});
    } else {
      state = state.copyWith(multiSelectActive: true);
    }
  }

  void toggleInvoiceSelection(String invoiceId) {
    final ids = Set<String>.from(state.selectedInvoiceIds);
    if (ids.contains(invoiceId)) {
      ids.remove(invoiceId);
    } else {
      ids.add(invoiceId);
    }
    state = state.copyWith(selectedInvoiceIds: ids);
  }

  void clearSelection() {
    state = state.copyWith(selectedInvoiceIds: {}, multiSelectActive: false);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────

  Future<void> loadTrips({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trips = await _service.getTrips(status: status);
      state = state.copyWith(trips: trips, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTripDetails(String tripName) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedTrip: true,
    );
    try {
      final trip = await _service.getTripDetails(tripName);
      state = state.copyWith(selectedTrip: trip, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> ensureInitialTripsLoaded() async {
    if (state.trips.isNotEmpty || state.isLoading) {
      return;
    }

    await loadTrips();

    // One automatic retry helps when first call races session/profile initialization.
    if ((state.trips.isEmpty || state.error != null) && !_didInitialAutoRetry) {
      _didInitialAutoRetry = true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await loadTrips();
    }
  }

  Future<DeliveryTrip?> createTrip({
    required List<String> invoiceNames,
    required String partyType,
    required String party,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trip = await _service.createTrip(
        invoiceNames: invoiceNames,
        partyType: partyType,
        party: party,
      );
      // Refresh list and clear multi-select
      final updated = [trip, ...state.trips];
      state = state.copyWith(
        trips: updated,
        isLoading: false,
        selectedInvoiceIds: {},
        multiSelectActive: false,
      );
      return trip;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> sendForDelivery(String tripName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.sendForDelivery(tripName);
      // Refresh trip details
      await loadTripDetails(tripName);
      await loadTrips();
      return result;
    } catch (e) {
      // Always refresh from server — the backend may have partially or
      // fully completed before the client timed out / errored.
      try { await loadTripDetails(tripName); } catch (_) {}
      try { await loadTrips(); } catch (_) {}
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }

  Future<Map<String, dynamic>?> markAsDelivered(String tripName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.markAsDelivered(tripName);
      await loadTripDetails(tripName);
      await loadTrips();
      return result;
    } catch (e) {
      // Same as above — always refresh to reflect actual backend state.
      try { await loadTripDetails(tripName); } catch (_) {}
      try { await loadTrips(); } catch (_) {}
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }
}
