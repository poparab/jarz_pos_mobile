import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/master_orders_repository.dart';

class MasterOrdersFilters {
  final String? search;
  final String? status;
  final String? branch;
  final String? fromDate;
  final String? toDate;
  final String? paymentStatus;
  final int page;

  const MasterOrdersFilters({
    this.search,
    this.status,
    this.branch,
    this.fromDate,
    this.toDate,
    this.paymentStatus,
    this.page = 1,
  });

  MasterOrdersFilters copyWith({
    String? search,
    String? status,
    String? branch,
    String? fromDate,
    String? toDate,
    String? paymentStatus,
    int? page,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearBranch = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearPaymentStatus = false,
  }) {
    return MasterOrdersFilters(
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      branch: clearBranch ? null : (branch ?? this.branch),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      page: page ?? this.page,
    );
  }
}

final masterOrdersFiltersProvider =
    StateProvider<MasterOrdersFilters>((ref) => const MasterOrdersFilters());

final masterOrdersProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final filters = ref.watch(masterOrdersFiltersProvider);
  final repo = ref.watch(masterOrdersRepositoryProvider);
  return repo.fetchOrders(
    search: filters.search,
    status: filters.status,
    branch: filters.branch,
    fromDate: filters.fromDate,
    toDate: filters.toDate,
    paymentStatus: filters.paymentStatus,
    page: filters.page,
  );
});
