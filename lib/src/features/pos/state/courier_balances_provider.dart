import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/courier_balance.dart';
import '../data/repositories/courier_repository.dart';

class CourierBalancesState {
  final bool loading;
  final List<CourierBalance> balances;
  final String? error;

  const CourierBalancesState({
    required this.loading,
    required this.balances,
    this.error,
  });

  bool get hasUnsettled => balances.any((b) => (b.balance).abs() > 0.0001);
  int get unsettledCount => balances.where((b) => (b.balance).abs() > 0.0001).length;

  CourierBalancesState copyWith({bool? loading, List<CourierBalance>? balances, String? error}) =>
      CourierBalancesState(
        loading: loading ?? this.loading,
        balances: balances ?? this.balances,
        error: error,
      );

  factory CourierBalancesState.initial() => const CourierBalancesState(loading: false, balances: [], error: null);
}

class CourierBalancesNotifier extends StateNotifier<CourierBalancesState> {
  final CourierRepository _repo;
  CourierBalancesNotifier(this._repo) : super(CourierBalancesState.initial()) {
    // initial load
    load();
  }

  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final result = await _repo.getBalances();
      state = state.copyWith(loading: false, balances: result, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final courierBalancesProvider = StateNotifierProvider<CourierBalancesNotifier, CourierBalancesState>((ref) {
  final repo = ref.watch(courierRepositoryProvider);
  return CourierBalancesNotifier(repo);
});
