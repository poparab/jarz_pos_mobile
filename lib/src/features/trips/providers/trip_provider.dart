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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trip = await _service.getTripDetails(tripName);
      state = state.copyWith(selectedTrip: trip, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
      return null;
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
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }
}
