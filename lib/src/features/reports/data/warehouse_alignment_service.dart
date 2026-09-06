import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/warehouse_alignment_row.dart';

final warehouseAlignmentServiceProvider =
    Provider<WarehouseAlignmentService>((ref) {
  final dio = ref.watch(dioProvider);
  return WarehouseAlignmentService(dio);
});

/// Dio-backed client for the read-only warehouse-alignment watchlist. Kept as
/// its own small service (rather than folded into the shared
/// `ReportsRepository`) because this report answers to the manager-dashboard
/// role tier, not the stricter `canViewAllReports` gate the rest of the
/// Reports hub uses.
class WarehouseAlignmentService {
  final Dio _dio;
  WarehouseAlignmentService(this._dio);

  /// Submitted invoices whose item warehouses disagree with their branch.
  /// Deliberately does NOT expose the repair action — that endpoint kept a
  /// stricter admin gate and must never be called from mobile.
  Future<List<WarehouseAlignmentRow>> fetchWarehouseAlignmentReport({
    String? company,
    String? branch,
    int limit = 100,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.warehouseAlignmentReport,
        data: {
          if (company != null && company.trim().isNotEmpty)
            'company': company.trim(),
          if (branch != null && branch.trim().isNotEmpty)
            'branch': branch.trim(),
          'limit': limit,
        },
      );
      return _parseRows(resp.data);
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load warehouse alignment report',
      );
    }
  }

  /// Unwraps the Frappe `{"message": ...}` envelope defensively: the payload
  /// may be a bare list, a list under a common key (`rows` / `invoices` /
  /// `data` / `results`), or — if success/error framing is ever added — an
  /// envelope map carrying one of those keys plus a `success`/`error` field.
  List<WarehouseAlignmentRow> _parseRows(dynamic payload) {
    dynamic envelope = payload;
    if (envelope is Map && envelope.containsKey('message')) {
      envelope = envelope['message'];
    }

    if (envelope is Map) {
      final map = Map<String, dynamic>.from(envelope);
      final error = map['error'];
      if (map['success'] == false ||
          (error != null && error.toString().trim().isNotEmpty)) {
        throw Exception(
          extractFrappeErrorMessage(
            error ?? map,
            fallback: 'Failed to load warehouse alignment report',
          ),
        );
      }
      final candidate =
          map['rows'] ?? map['invoices'] ?? map['data'] ?? map['results'];
      envelope = candidate is List ? candidate : const [];
    }

    if (envelope is! List) return const [];
    return envelope
        .whereType<Map>()
        .map((e) =>
            WarehouseAlignmentRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// Filter state for the warehouse-alignment watchlist: branch (optional) and
/// row limit. Kept as a value type so it can key a [FutureProvider.family]
/// the same way [ReportRange] keys the analytics dashboards.
class WarehouseAlignmentFilter {
  final String? branch;
  final int limit;

  const WarehouseAlignmentFilter({this.branch, this.limit = 100});

  WarehouseAlignmentFilter copyWith({String? branch, int? limit}) =>
      WarehouseAlignmentFilter(
        branch: branch ?? this.branch,
        limit: limit ?? this.limit,
      );

  @override
  bool operator ==(Object other) =>
      other is WarehouseAlignmentFilter &&
      other.branch == branch &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(branch, limit);
}

final warehouseAlignmentFilterProvider = StateProvider<WarehouseAlignmentFilter>(
  (ref) => const WarehouseAlignmentFilter(),
);

final warehouseAlignmentReportProvider = FutureProvider.autoDispose
    .family<List<WarehouseAlignmentRow>, WarehouseAlignmentFilter>(
        (ref, filter) async {
  final service = ref.watch(warehouseAlignmentServiceProvider);
  return service.fetchWarehouseAlignmentReport(
    branch: filter.branch,
    limit: filter.limit,
  );
});
