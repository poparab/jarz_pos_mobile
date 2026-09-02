import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/courier_balance.dart';
import '../data/repositories/courier_repository.dart';
import 'pos_notifier.dart';

class CourierBalancesState {
  final bool loading;
  final List<CourierBalance> balances;
  final String? error;
  final bool hasLoaded;

  const CourierBalancesState({
    required this.loading,
    required this.balances,
    this.error,
    this.hasLoaded = false,
  });

  bool get hasUnsettled => balances.any((b) => (b.balance).abs() > 0.0001);
  int get unsettledCount => balances.where((b) => (b.balance).abs() > 0.0001).length;

  CourierBalancesState copyWith({bool? loading, List<CourierBalance>? balances, String? error, bool? hasLoaded}) =>
      CourierBalancesState(
        loading: loading ?? this.loading,
        balances: balances ?? this.balances,
        error: error,
        hasLoaded: hasLoaded ?? this.hasLoaded,
      );

  factory CourierBalancesState.initial() => const CourierBalancesState(loading: false, balances: [], error: null, hasLoaded: false);
}

class CourierBalancesNotifier extends StateNotifier<CourierBalancesState> {
  final CourierRepository _repo;

  /// The branch these balances belong to. Settlement is funded by this branch's
  /// cash account, so the list must show only this branch's courier money —
  /// never another branch's.
  final String? posProfile;

  CourierBalancesNotifier(this._repo, {this.posProfile}) : super(CourierBalancesState.initial()) {
    // initial load
    load();
  }

  Future<void> load() async {
    if (state.loading) return; // guard against concurrent loads
    try {
      state = state.copyWith(loading: true, error: null);
      final result = await _repo.getBalances(posProfile: posProfile);
      state = state.copyWith(loading: false, balances: result, error: null, hasLoaded: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString(), hasLoaded: true);
    }
  }
}

final courierBalancesProvider = StateNotifierProvider<CourierBalancesNotifier, CourierBalancesState>((ref) {
  final repo = ref.watch(courierRepositoryProvider);
  // Watched, not read: switching branch rebuilds the notifier, which reloads the
  // list for the branch now open instead of leaving the previous one's rows on
  // screen next to a Settle button that would post against the new drawer.
  final posProfile = ref.watch(
    posNotifierProvider.select((s) => s.selectedProfile?['name'] as String?),
  );
  return CourierBalancesNotifier(repo, posProfile: posProfile);
});
