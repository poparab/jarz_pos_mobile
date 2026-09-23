import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../data/cash_custody_repository.dart';
import '../models/cash_custody_models.dart';

/// The caller's custody picture, cached for the session.
///
/// Kept alive on purpose: the side menu, the Expenses form and the Purchase
/// payment dialog all read it, and one fetch per session is the cheapest way
/// to answer "is this user a holder?". Every mutation invalidates it, and
/// logout invalidates it with the rest of the user-scoped state.
final custodyOverviewProvider = FutureProvider<CustodyOverview>((ref) async {
  final repo = ref.watch(cashCustodyRepositoryProvider);
  return repo.fetchOverview();
});

/// Whether the side menu offers Cash Custody.
///
/// Answered by the server (a manager, or someone holding a custody). Until
/// the overview arrives -- or if the endpoint is unreachable -- it falls back
/// to the Cash Transfer tier, so a manager never loses the entry to a slow
/// first load, and a plain cashier is not shown a tile that only 403s.
final custodyMenuVisibleProvider = Provider<bool>((ref) {
  final fallback = ref.watch(canAccessCashTransferProvider);
  final overview = ref.watch(custodyOverviewProvider);
  return overview.when(
    data: (o) => o.hasAccess,
    loading: () => fallback,
    error: (_, _) => fallback,
  );
});

/// Force a fresh overview and return it; on failure fall back to the last one
/// seen (the server still enforces the balance, so a stale pre-check is only
/// a hint).
Future<CustodyOverview?> refreshCustodyOverview(WidgetRef ref) async {
  try {
    return await ref
        .refresh(custodyOverviewProvider.future)
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    return ref.read(custodyOverviewProvider).valueOrNull;
  }
}

// ── Statement ───────────────────────────────────────────────────────────

class CustodyStatementState {
  final bool isLoading;
  final Object? error;
  final CustodyStatement? statement;

  /// The filter the user chose. Null means "the server's default window".
  final DateTime? fromDate;
  final DateTime? toDate;

  const CustodyStatementState({
    this.isLoading = false,
    this.error,
    this.statement,
    this.fromDate,
    this.toDate,
  });

  bool get hasRange => fromDate != null && toDate != null;

  CustodyStatementState copyWith({
    bool? isLoading,
    Object? error,
    bool clearError = false,
    CustodyStatement? statement,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearRange = false,
  }) {
    return CustodyStatementState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statement: statement ?? this.statement,
      fromDate: clearRange ? null : (fromDate ?? this.fromDate),
      toDate: clearRange ? null : (toDate ?? this.toDate),
    );
  }
}

final custodyStatementProvider = StateNotifierProvider.autoDispose
    .family<CustodyStatementNotifier, CustodyStatementState, String>(
  (ref, holder) {
    final repo = ref.watch(cashCustodyRepositoryProvider);
    return CustodyStatementNotifier(repo, holder)..load();
  },
);

class CustodyStatementNotifier extends StateNotifier<CustodyStatementState> {
  final CashCustodyRepository _repository;
  final String holder;

  CustodyStatementNotifier(this._repository, this.holder)
      : super(const CustodyStatementState());

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final statement = await _repository.fetchStatement(
        holder: holder,
        fromDate: state.fromDate == null ? null : _fmt(state.fromDate!),
        toDate: state.toDate == null ? null : _fmt(state.toDate!),
      );
      if (!mounted) return;
      state = state.copyWith(isLoading: false, statement: statement);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> setRange(DateTime from, DateTime to) async {
    state = state.copyWith(fromDate: from, toDate: to);
    await load();
  }

  Future<void> clearRange() async {
    state = state.copyWith(clearRange: true);
    await load();
  }
}

// ── Mutations ───────────────────────────────────────────────────────────

class CustodyActionsState {
  final bool isSubmitting;
  const CustodyActionsState({this.isSubmitting = false});
}

final custodyActionsProvider =
    StateNotifierProvider<CustodyActionsNotifier, CustodyActionsState>((ref) {
  final repo = ref.watch(cashCustodyRepositoryProvider);
  return CustodyActionsNotifier(repo, (holder) {
    ref.invalidate(custodyOverviewProvider);
    // Reload an open statement in place rather than invalidating it, so the
    // date range the user picked survives the refresh.
    if (holder != null && ref.exists(custodyStatementProvider(holder))) {
      ref.read(custodyStatementProvider(holder).notifier).load();
    }
  });
});

/// Issue, return, and holder administration.
///
/// Every method rethrows: the screen hands the original exception to the
/// shared error presenter, which needs the `DioException` itself to surface
/// the server's own sentence (a stringified copy loses it).
class CustodyActionsNotifier extends StateNotifier<CustodyActionsState> {
  final CashCustodyRepository _repository;
  final void Function(String? holder) _onChanged;

  CustodyActionsNotifier(this._repository, this._onChanged)
      : super(const CustodyActionsState());

  Future<T> _run<T>(String? holder, Future<T> Function() call) async {
    state = const CustodyActionsState(isSubmitting: true);
    try {
      final result = await call();
      _onChanged(holder);
      return result;
    } finally {
      if (mounted) state = const CustodyActionsState();
    }
  }

  Future<CustodyHolder> addHolder(String employee) =>
      _run(null, () => _repository.addHolder(employee));

  Future<CustodyHolder> setHolderEnabled(String holder, bool enabled) =>
      _run(holder, () => _repository.setHolderEnabled(holder, enabled));

  Future<CustodyMovementResult> issue({
    required String holder,
    required String fromAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) =>
      _run(
        holder,
        () => _repository.issue(
          holder: holder,
          fromAccount: fromAccount,
          amount: amount,
          postingDate: postingDate,
          remark: remark,
        ),
      );

  Future<CustodyMovementResult> returnCash({
    required String holder,
    required String toAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) =>
      _run(
        holder,
        () => _repository.returnCash(
          holder: holder,
          toAccount: toAccount,
          amount: amount,
          postingDate: postingDate,
          remark: remark,
        ),
      );
}
