import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shift_repository.dart';
import '../models/shift_models.dart';

class ShiftState {
  final ShiftEntry? activeShift;
  final List<Map<String, dynamic>> paymentMethods;
  final String? paymentMethodsProfile;
  final bool isLoading;
  final String? error;

  const ShiftState({
    this.activeShift,
    this.paymentMethods = const [],
    this.paymentMethodsProfile,
    this.isLoading = false,
    this.error,
  });

  ShiftState copyWith({
    ShiftEntry? activeShift,
    List<Map<String, dynamic>>? paymentMethods,
    String? paymentMethodsProfile,
    bool? isLoading,
    String? error,
    bool clearActiveShift = false,
    bool clearError = false,
    bool clearPaymentMethodsProfile = false,
  }) {
    return ShiftState(
      activeShift: clearActiveShift ? null : (activeShift ?? this.activeShift),
      paymentMethods: paymentMethods ?? this.paymentMethods,
      paymentMethodsProfile: clearPaymentMethodsProfile
          ? null
          : (paymentMethodsProfile ?? this.paymentMethodsProfile),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier(this._repository) : super(const ShiftState());

  final ShiftRepository _repository;

  Future<ShiftEntry?> checkActiveShift() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final active = await _repository.getActiveShift();
      state = state.copyWith(activeShift: active, isLoading: false);
      return active;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadPaymentMethods(String posProfile) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final methods = await _repository.getShiftPaymentMethods(posProfile);
      state = state.copyWith(
        paymentMethods: methods,
        paymentMethodsProfile: posProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> startShift({
    required String posProfile,
    required List<Map<String, dynamic>> openingBalances,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final openingEntry = await _repository.startShift(
        posProfile: posProfile,
        openingBalances: openingBalances,
      );
      final active = await _repository.getActiveShift();
      state = state.copyWith(activeShift: active, isLoading: false);
      return openingEntry;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<ShiftSummary?> getCurrentShiftSummary() async {
    final active = state.activeShift ?? await _repository.getActiveShift();
    if (active == null) return null;
    return _repository.getShiftSummary(active.name);
  }

  Future<ShiftSummary?> endShift({required List<Map<String, dynamic>> closingBalances}) async {
    final active = state.activeShift ?? await _repository.getActiveShift();
    if (active == null) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary = await _repository.endShift(
        openingEntry: active.name,
        closingBalances: closingBalances,
      );
      state = state.copyWith(isLoading: false, clearActiveShift: true);
      return summary;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final shiftNotifierProvider = StateNotifierProvider<ShiftNotifier, ShiftState>((ref) {
  final repo = ref.watch(shiftRepositoryProvider);
  return ShiftNotifier(repo);
});

final activeShiftProvider = FutureProvider<ShiftEntry?>((ref) async {
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.getActiveShift();
});
