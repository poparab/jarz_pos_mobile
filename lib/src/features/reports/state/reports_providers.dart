import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reports_repository.dart';
import '../data/models/shipping_analytics.dart';
import '../data/models/inventory_intelligence.dart';
import '../data/models/product_analytics.dart';
import '../data/models/customer_analytics.dart';
import '../data/models/executive_overview.dart';
import '../data/models/b2b_sales_clients.dart';

final finalProductsReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchFinalProductsReport();
});

final materialsReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchMaterialsReport();
});

// ── Shared date range for the analytics dashboards ────────────────────────

/// An immutable, value-comparable inclusive date range used as the family key
/// for every analytics dashboard provider. Dates are date-only (time ignored).
@immutable
class ReportRange {
  final DateTime from;
  final DateTime to;

  const ReportRange({required this.from, required this.to});

  /// The current calendar month (1st → today).
  factory ReportRange.thisMonth([DateTime? now]) {
    final n = now ?? DateTime.now();
    return ReportRange(from: DateTime(n.year, n.month, 1), to: DateTime(n.year, n.month, n.day));
  }

  /// The trailing [days] days ending today (inclusive).
  factory ReportRange.lastDays(int days, [DateTime? now]) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return ReportRange(
      from: today.subtract(Duration(days: days - 1)),
      to: today,
    );
  }

  String get fromIso => _fmt(from);
  String get toIso => _fmt(to);

  ReportRange copyWith({DateTime? from, DateTime? to}) =>
      ReportRange(from: from ?? this.from, to: to ?? this.to);

  static String _fmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  bool operator ==(Object other) =>
      other is ReportRange &&
      other.from.year == from.year &&
      other.from.month == from.month &&
      other.from.day == from.day &&
      other.to.year == to.year &&
      other.to.month == to.month &&
      other.to.day == to.day;

  @override
  int get hashCode => Object.hash(
        from.year,
        from.month,
        from.day,
        to.year,
        to.month,
        to.day,
      );
}

/// The date range currently selected in the reports date-range bar. Shared
/// across all dashboards so the picker state persists while navigating.
final reportRangeProvider = StateProvider<ReportRange>(
  (ref) => ReportRange.thisMonth(),
);

// ── Per-dashboard data providers (keyed by the selected range) ────────────

final shippingAnalyticsProvider = FutureProvider.autoDispose
    .family<ShippingAnalytics, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchShippingAnalytics(
    fromDate: range.fromIso,
    toDate: range.toIso,
  );
});

final inventoryIntelligenceProvider = FutureProvider.autoDispose
    .family<InventoryIntelligence, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchInventoryIntelligence(
    dateFrom: range.fromIso,
    dateTo: range.toIso,
  );
});

final productAnalyticsProvider = FutureProvider.autoDispose
    .family<ProductAnalytics, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchProductAnalytics(
    dateFrom: range.fromIso,
    dateTo: range.toIso,
  );
});

final customerAnalyticsProvider = FutureProvider.autoDispose
    .family<CustomerAnalytics, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchCustomerAnalytics(
    dateFrom: range.fromIso,
    dateTo: range.toIso,
  );
});

final executiveOverviewProvider = FutureProvider.autoDispose
    .family<ExecutiveOverview, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchExecutiveOverview(
    dateFrom: range.fromIso,
    dateTo: range.toIso,
  );
});

final b2bSalesClientsProvider = FutureProvider.autoDispose
    .family<B2bSalesAnalytics, ReportRange>((ref, range) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchB2bSalesClients(
    dateFrom: range.fromIso,
    dateTo: range.toIso,
  );
});
