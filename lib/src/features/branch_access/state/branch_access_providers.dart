import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/branch_access_repository.dart';
import '../models/branch_access_models.dart';

/// The whole access picture. Re-fetched after every change rather than patched
/// locally: the server may have done more than was asked (a manual add turns a
/// day access permanent; a remove cancels one), and only it knows.
final branchAccessOverviewProvider =
    FutureProvider.autoDispose<BranchAccessOverview>((ref) async {
      return ref.watch(branchAccessRepositoryProvider).getOverview();
    });

/// Free-text filter on the people list.
final branchAccessSearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// History filter by branch. Null means every branch the caller can see.
final branchAccessLogBranchProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class BranchAccessLogState {
  const BranchAccessLogState({
    this.rows = const [],
    this.hasMore = true,
    this.loading = false,
    this.error,
  });

  final List<BranchAccessLogEntry> rows;
  final bool hasMore;
  final bool loading;
  final Object? error;

  BranchAccessLogState copyWith({
    List<BranchAccessLogEntry>? rows,
    bool? hasMore,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) => BranchAccessLogState(
    rows: rows ?? this.rows,
    hasMore: hasMore ?? this.hasMore,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

/// The change history, paged for infinite scroll.
class BranchAccessLogNotifier extends StateNotifier<BranchAccessLogState> {
  BranchAccessLogNotifier(this._repository, this._posProfile)
    : super(const BranchAccessLogState()) {
    loadMore();
  }

  static const pageSize = 50;

  final BranchAccessRepository _repository;
  final String? _posProfile;

  /// Bumped by [refresh] so a page still in flight from before it cannot be
  /// appended to the fresh list.
  int _generation = 0;

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final generation = _generation;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final page = await _repository.getAccessLog(
        posProfile: _posProfile,
        limit: pageSize,
        start: state.rows.length,
      );
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
        rows: [...state.rows, ...page.rows],
        hasMore: page.hasMore,
        loading: false,
      );
    } catch (error) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(loading: false, error: error);
    }
  }

  Future<void> refresh() async {
    _generation++;
    state = const BranchAccessLogState();
    await loadMore();
  }
}

final branchAccessLogProvider =
    StateNotifierProvider.autoDispose<
      BranchAccessLogNotifier,
      BranchAccessLogState
    >((ref) {
      return BranchAccessLogNotifier(
        ref.watch(branchAccessRepositoryProvider),
        ref.watch(branchAccessLogBranchProvider),
      );
    });
