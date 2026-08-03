import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/purchase_request_repository.dart';
import '../models/purchase_request_models.dart';

/// Which slice of the request queue the list is showing.
enum RequestFilter {
  open,
  mine,
  all;

  String? get serverStatus => this == RequestFilter.all ? null : 'open';
  bool get mineOnly => this == RequestFilter.mine;
}

class PurchaseRequestState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isLoadingMore;
  final String? error;
  final bool initialized;
  final bool canReview;
  final RequestFilter filter;
  final List<ItemRequest> requests;
  final int total;
  final int page;

  const PurchaseRequestState({
    required this.isLoading,
    required this.isSubmitting,
    required this.isLoadingMore,
    required this.error,
    required this.initialized,
    required this.canReview,
    required this.filter,
    required this.requests,
    required this.total,
    required this.page,
  });

  factory PurchaseRequestState.initial() => const PurchaseRequestState(
        isLoading: false,
        isSubmitting: false,
        isLoadingMore: false,
        error: null,
        initialized: false,
        canReview: false,
        filter: RequestFilter.open,
        requests: [],
        total: 0,
        page: 0,
      );

  bool get hasMore => requests.length < total;

  int get openCount => requests.where((r) => r.status.isOpen).length;
  int get overdueCount => requests.where((r) => r.isOverdue).length;

  PurchaseRequestState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    bool? initialized,
    bool? canReview,
    RequestFilter? filter,
    List<ItemRequest>? requests,
    int? total,
    int? page,
  }) {
    return PurchaseRequestState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      initialized: initialized ?? this.initialized,
      canReview: canReview ?? this.canReview,
      filter: filter ?? this.filter,
      requests: requests ?? this.requests,
      total: total ?? this.total,
      page: page ?? this.page,
    );
  }
}

final purchaseRequestNotifierProvider =
    StateNotifierProvider<PurchaseRequestNotifier, PurchaseRequestState>((ref) {
  return PurchaseRequestNotifier(ref.watch(purchaseRequestRepositoryProvider));
});

class PurchaseRequestNotifier extends StateNotifier<PurchaseRequestState> {
  final PurchaseRequestRepository _repository;
  static const _pageSize = 30;

  PurchaseRequestNotifier(this._repository)
      : super(PurchaseRequestState.initial());

  Future<void> load({RequestFilter? filter}) async {
    final target = filter ?? state.filter;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filter: target,
      page: 0,
    );
    try {
      final page = await _repository.listRequests(
        status: target.serverStatus,
        mineOnly: target.mineOnly,
        limit: _pageSize,
        page: 0,
      );
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        canReview: page.canReview,
        requests: page.requests,
        total: page.total,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        error: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _repository.listRequests(
        status: state.filter.serverStatus,
        mineOnly: state.filter.mineOnly,
        limit: _pageSize,
        page: nextPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        page: nextPage,
        requests: [...state.requests, ...page.requests],
        total: page.total,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }

  Future<ItemRequest?> submitRequest({
    required List<DraftRequestLine> items,
    String? scheduleDate,
    String? note,
    String? posProfile,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final created = await _repository.createRequest(
        items: items,
        scheduleDate: scheduleDate,
        note: note,
        posProfile: posProfile,
      );
      // Prepend rather than refetch: the new request is always newest-first
      // under the list's ordering, and a refetch would lose scroll position.
      state = state.copyWith(
        isSubmitting: false,
        requests: [created, ...state.requests],
        total: state.total + 1,
      );
      return created;
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: error.toString());
      return null;
    }
  }

  Future<bool> stopRequest(String name, {String? reason}) async {
    try {
      final updated = await _repository.stopRequest(name, reason: reason);
      _replace(updated);
      return true;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return false;
    }
  }

  Future<bool> reopenRequest(String name) async {
    try {
      final updated = await _repository.reopenRequest(name);
      _replace(updated);
      return true;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return false;
    }
  }

  void _replace(ItemRequest updated) {
    final next = [
      for (final request in state.requests)
        if (request.name == updated.name) updated else request,
    ];
    // A stopped request drops out of the open-only views immediately, so the
    // list reflects the action without a round-trip.
    final visible = state.filter == RequestFilter.all
        ? next
        : next.where((r) => !r.status.isRejected).toList();
    state = state.copyWith(
      requests: visible,
      total: visible.length < next.length ? state.total - 1 : state.total,
      clearError: true,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

/// The consolidated buying list. Kept separate from the queue state because the
/// purchase screen consumes it without caring about the request list at all.
final openDemandProvider =
    FutureProvider.autoDispose<List<RequestDemandLine>>((ref) async {
  return ref.watch(purchaseRequestRepositoryProvider).getOpenDemand();
});
