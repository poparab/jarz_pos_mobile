import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/label_models.dart';

final labelsRepositoryProvider = Provider<LabelsRepository>((ref) {
  return LabelsRepository(ref.watch(dioProvider));
});

/// Item Groups a label can be scoped to. Small and stable, so it is fetched once
/// and cached for the life of the provider rather than on every sheet open.
final labelItemGroupsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(labelsRepositoryProvider).getItemGroups();
});

/// HTTP repository for `jarz_pos.api.labels.*`. Every call is gated server-side
/// on B2B or manager access and throws otherwise.
class LabelsRepository {
  final Dio _dio;
  LabelsRepository(this._dio);

  /// Unwraps Frappe's `{ "message": ... }` envelope.
  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  Future<LabelDashboard> getDashboard({
    String? customer,
    bool onlyAttention = false,
    bool includeUntracked = true,
  }) async {
    final response = await _dio.post(ApiEndpoints.getLabelDashboard, data: {
      if (customer != null && customer.trim().isNotEmpty) 'customer': customer.trim(),
      'only_attention': onlyAttention ? 1 : 0,
      'include_untracked': includeUntracked ? 1 : 0,
    });
    return LabelDashboard.fromJson(_asMap(_unwrap(response)));
  }

  /// Badge count only — deliberately a separate, cheaper call than the board so
  /// the drawer can ask for it without pulling every label's ledger.
  Future<LabelSummary> getAlertCount() async {
    final response =
        await _dio.post(ApiEndpoints.getLabelAlertCount, data: const {});
    final payload = _asMap(_unwrap(response));
    return LabelSummary.fromJson({
      'needs_attention': payload['needs_attention'],
      'out_of_stock': payload['out_of_stock'],
      'reorder_now': payload['reorder_now'],
      'reorder_soon': payload['reorder_soon'],
    });
  }

  Future<CustomerLabel> getDetail(String label) async {
    final response = await _dio
        .post(ApiEndpoints.getLabelDetail, data: {'label': label});
    return CustomerLabel.fromJson(_asMap(_unwrap(response)));
  }

  Future<List<LabelCustomerOption>> searchCustomers(String query) async {
    final response = await _dio
        .post(ApiEndpoints.searchLabelCustomers, data: {'query': query});
    final payload = _asMap(_unwrap(response));
    return (payload['customers'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => LabelCustomerOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<String>> getItemGroups() async {
    final response =
        await _dio.post(ApiEndpoints.getLabelItemGroups, data: const {});
    final payload = _asMap(_unwrap(response));
    return (payload['item_groups'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
  }

  Future<CustomerLabel> createLabel({
    required String customer,
    String labelTitle = 'Default',
    bool wePrint = true,
    String? appliesToItemGroup,
    double labelsPerUnit = 1,
    int minStockQty = 0,
    int reorderQty = 0,
    int openingQty = 0,
    String? notes,
  }) async {
    final response = await _dio.post(ApiEndpoints.createLabel, data: {
      'customer': customer,
      'label_title': labelTitle,
      'we_print': wePrint ? 1 : 0,
      if (appliesToItemGroup != null && appliesToItemGroup.trim().isNotEmpty)
        'applies_to_item_group': appliesToItemGroup.trim(),
      'labels_per_unit': labelsPerUnit,
      'min_stock_qty': minStockQty,
      'reorder_qty': reorderQty,
      'opening_qty': openingQty,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return CustomerLabel.fromJson(_asMap(_unwrap(response)));
  }

  /// Only the fields actually passed are written, so a caller can flip one
  /// switch without having to resend the whole policy.
  Future<CustomerLabel> updateLabel({
    required String label,
    String? labelTitle,
    bool? enabled,
    bool? wePrint,
    String? appliesToItemGroup,
    double? labelsPerUnit,
    int? minStockQty,
    int? reorderQty,
    String? notes,
  }) async {
    final response = await _dio.post(ApiEndpoints.updateLabel, data: {
      'label': label,
      if (labelTitle != null) 'label_title': labelTitle,
      if (enabled != null) 'enabled': enabled ? 1 : 0,
      if (wePrint != null) 'we_print': wePrint ? 1 : 0,
      // An empty string is meaningful: it clears the scope back to catch-all.
      if (appliesToItemGroup != null) 'applies_to_item_group': appliesToItemGroup,
      if (labelsPerUnit != null) 'labels_per_unit': labelsPerUnit,
      if (minStockQty != null) 'min_stock_qty': minStockQty,
      if (reorderQty != null) 'reorder_qty': reorderQty,
      if (notes != null) 'notes': notes,
    });
    return CustomerLabel.fromJson(_asMap(_unwrap(response)));
  }

  Future<CustomerLabel> recordMovement({
    required String label,
    required String movementType,
    required int qty,
    String? postingDate,
    String? remarks,
  }) async {
    final response = await _dio.post(ApiEndpoints.recordLabelMovement, data: {
      'label': label,
      'movement_type': movementType,
      'qty': qty,
      if (postingDate != null) 'posting_date': postingDate,
      if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
    });
    final payload = _asMap(_unwrap(response));
    return CustomerLabel.fromJson(_asMap(payload['label']));
  }

  /// Reconciles the ledger to a physical count; the server posts the difference.
  Future<CustomerLabel> recordCount({
    required String label,
    required int countedQty,
    String? remarks,
  }) async {
    final response = await _dio.post(ApiEndpoints.recordLabelCount, data: {
      'label': label,
      'counted_qty': countedQty,
      if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
    });
    final payload = _asMap(_unwrap(response));
    return CustomerLabel.fromJson(_asMap(payload['label']));
  }

  Future<CustomerLabel> createPrintOrder({
    required String label,
    required int qty,
    String? printerName,
    String? requestedOn,
    String? notes,
  }) async {
    final response = await _dio.post(ApiEndpoints.createLabelPrintOrder, data: {
      'label': label,
      'qty': qty,
      if (printerName != null && printerName.trim().isNotEmpty)
        'printer_name': printerName.trim(),
      if (requestedOn != null) 'requested_on': requestedOn,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    final payload = _asMap(_unwrap(response));
    return CustomerLabel.fromJson(_asMap(payload['label']));
  }

  Future<CustomerLabel> updatePrintOrder({
    required String printOrder,
    String? status,
    int? receivedQty,
    String? receivedOn,
    String? printerName,
    String? notes,
  }) async {
    final response = await _dio.post(ApiEndpoints.updateLabelPrintOrder, data: {
      'print_order': printOrder,
      if (status != null) 'status': status,
      if (receivedQty != null) 'received_qty': receivedQty,
      if (receivedOn != null) 'received_on': receivedOn,
      if (printerName != null) 'printer_name': printerName,
      if (notes != null) 'notes': notes,
    });
    final payload = _asMap(_unwrap(response));
    return CustomerLabel.fromJson(_asMap(payload['label']));
  }
}
