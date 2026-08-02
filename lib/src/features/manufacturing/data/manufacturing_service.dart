import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/basket_rollup.dart';
import 'models/bom_details.dart';
import 'models/production_suggestion.dart';
import 'models/running_batch.dart';
import 'models/sop.dart';

final manufacturingServiceProvider = Provider<ManufacturingService>((ref) {
  final dio = ref.watch(dioProvider);
  return ManufacturingService(dio);
});

class ManufacturingService {
  final Dio _dio;
  ManufacturingService(this._dio);

  Exception _friendlyError(Object error, {required String fallback}) {
    return mapFrappeError(error, fallback: fallback);
  }

  Future<List<Map<String, dynamic>>> listDefaultBomItems(String search) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.listDefaultBomItems,
        data: {'search': search},
      );
      final payload = resp.data;
      if (payload is Map && payload['message'] is List) {
        return (payload['message'] as List).cast<Map<String, dynamic>>();
      }
      if (payload is List) return payload.cast<Map<String, dynamic>>();
      return [];
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load manufacturing items');
    }
  }

  Future<Map<String, dynamic>> getBomDetails(String itemCode) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getBomDetails,
        data: {'item_code': itemCode},
      );
      final payload = resp.data;
      if (payload is Map && payload['message'] is Map) {
        return Map<String, dynamic>.from(payload['message'] as Map);
      }
      if (payload is Map) return Map<String, dynamic>.from(payload);
      throw Exception('Unexpected BOM details response');
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load BOM details');
    }
  }

  Future<Map<String, dynamic>> submitWorkOrders(List<Map<String, dynamic>> lines) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.submitWorkOrders,
        data: {'lines': lines},
      );
      final payload = resp.data;
      if (payload is Map && payload['message'] is Map) {
        return Map<String, dynamic>.from(payload['message'] as Map);
      }
      if (payload is Map) return Map<String, dynamic>.from(payload);
      throw Exception('Unexpected submit response');
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to submit manufacturing work orders');
    }
  }

  Future<Map<String, dynamic>> submitSingleWorkOrder({
    required String itemCode,
    required String bomName,
    required double itemQty,
    String? scheduledAt,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.submitSingleWorkOrder,
        data: {
          'item_code': itemCode,
          'bom_name': bomName,
          'item_qty': itemQty,
          if (scheduledAt != null) 'scheduled_at': scheduledAt,
        },
      );
      final payload = resp.data;
      if (payload is Map && payload['message'] is Map) {
        return Map<String, dynamic>.from(payload['message'] as Map);
      }
      if (payload is Map) return Map<String, dynamic>.from(payload);
      throw Exception('Unexpected single submit response');
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to submit manufacturing work order');
    }
  }

  /// Ranked production suggestions with quantities already computed.
  ///
  /// [includeCapacity] false skips the per-BOM explosion server-side and
  /// returns null capacities — the escape hatch if the board gets slow.
  Future<ProductionSuggestionsPage> getProductionSuggestions({
    String? company,
    String? search,
    String? status,
    bool includeCapacity = true,
    bool forceRefresh = false,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getProductionSuggestions,
        data: {
          if (company != null) 'company': company,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          'include_capacity': includeCapacity ? 1 : 0,
          'force_refresh': forceRefresh ? 1 : 0,
        },
      );
      return ProductionSuggestionsPage.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load production suggestions');
    }
  }

  /// Consolidated material demand across every line in the basket.
  ///
  /// The per-line check cannot see two lines drawing on the same pile.
  Future<BasketRollup> getBasketMaterialRollup(
    List<Map<String, dynamic>> lines, {
    String? company,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getBasketMaterialRollup,
        data: {
          'lines': lines,
          if (company != null) 'company': company,
        },
      );
      return BasketRollup.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to check batch materials');
    }
  }

  /// Overrides the cover target for one item. Null or 0 restores the default.
  Future<Map<String, dynamic>> setItemTargetDays({
    required String itemCode,
    int? targetDays,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.setItemTargetDays,
        data: {'item_code': itemCode, 'target_days': targetDays ?? 0},
      );
      return _unwrapMap(resp.data);
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to update target days of cover');
    }
  }

  /// Typed wrapper over [listDefaultBomItems] for the manual search path.
  Future<List<BomItemSummary>> searchBomItems(String search) async {
    final rows = await listDefaultBomItems(search);
    return rows.map(BomItemSummary.fromJson).toList(growable: false);
  }

  /// Typed wrapper over [getBomDetails].
  Future<BomDetails> fetchBomDetails(String itemCode) async {
    return BomDetails.fromJson(await getBomDetails(itemCode));
  }

  // ── Start / finish (stage 2) ────────────────────────────────────────

  /// Starts a batch: creates the Work Order and files the material transfer
  /// ONLY. No Manufacture entry until [finishProductionBatch].
  Future<StartBatchResult> startProductionBatch({
    required String itemCode,
    required String bomName,
    required double itemQty,
    String? scheduledAt,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.startProductionBatch,
        data: {
          'item_code': itemCode,
          'bom_name': bomName,
          'item_qty': itemQty,
          if (scheduledAt != null) 'scheduled_at': scheduledAt,
        },
      );
      return StartBatchResult.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to start the batch');
    }
  }

  /// Finishes a batch with the quantity that actually came out.
  ///
  /// [actualQty] drives the Manufacture entry; [scrapQty] is recorded on the
  /// Work Order as a reported figure and does not post stock.
  Future<FinishBatchResult> finishProductionBatch({
    required String workOrder,
    required double actualQty,
    double scrapQty = 0,
    String? scheduledAt,
    String? notes,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.finishProductionBatch,
        data: {
          'work_order': workOrder,
          'actual_qty': actualQty,
          'scrap_qty': scrapQty,
          if (scheduledAt != null) 'scheduled_at': scheduledAt,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return FinishBatchResult.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to finish the batch');
    }
  }

  Future<List<RunningBatch>> listRunningWorkOrders({int limit = 50}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.listRunningWorkOrders,
        data: {'limit': limit},
      );
      return _unwrapList(resp.data).map(RunningBatch.fromJson).toList();
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load running batches');
    }
  }

  Future<BatchCost> getBatchCost(String workOrder) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getBatchCost,
        data: {'work_order': workOrder},
      );
      return BatchCost.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load batch cost');
    }
  }

  /// Manager-only: returns un-consumed WIP material to its source warehouse.
  Future<Map<String, dynamic>> returnWipToStore(String workOrder) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.returnWipToStore,
        data: {'work_order': workOrder},
      );
      return _unwrapMap(resp.data);
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to return WIP material');
    }
  }

  // ── SOPs (stage 3) ──────────────────────────────────────────────────

  /// Returns `hasSop: false` rather than throwing when an item has no SOP —
  /// most do not, and the board asks for every item.
  Future<SopDocument> getSopForItem({
    required String itemCode,
    String? bom,
    double batches = 1,
    double? units,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getSopForItem,
        data: {
          'item_code': itemCode,
          if (bom != null) 'bom': bom,
          'batches': batches,
          if (units != null) 'units': units,
        },
      );
      return SopDocument.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load the SOP');
    }
  }

  /// Returns the SOP version stamped on the Work Order when it started, not
  /// whatever is active now — otherwise editing an SOP silently rewrites the
  /// method every past batch was made by.
  Future<SopDocument> getSopForWorkOrder(String workOrder) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getSopForWorkOrder,
        data: {'work_order': workOrder},
      );
      return SopDocument.fromJson(_unwrapMap(resp.data));
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load the SOP');
    }
  }

  Future<Map<String, dynamic>> recordSopStepCapture({
    required String workOrder,
    required int stepNo,
    double? value,
    String? fileUrl,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.recordSopStepCapture,
        data: {
          'work_order': workOrder,
          'step_no': stepNo,
          if (value != null) 'value': value,
          if (fileUrl != null) 'file_url': fileUrl,
        },
      );
      return _unwrapMap(resp.data);
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to record the reading');
    }
  }

  /// Unwraps Frappe's `{"message": [...]}` envelope down to a List of Maps.
  List<Map<String, dynamic>> _unwrapList(dynamic payload) {
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (payload is List) {
      return payload.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  /// Unwraps Frappe's `{"message": ...}` envelope down to a Map.
  Map<String, dynamic> _unwrapMap(dynamic payload) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected response shape');
  }

  Future<List<Map<String, dynamic>>> listRecentWorkOrders({int limit = 50}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.listRecentWorkOrders,
        data: {"limit": limit},
      );
      final payload = resp.data;
      if (payload is Map && payload['message'] is List) {
        return (payload['message'] as List).cast<Map<String, dynamic>>();
      }
      if (payload is List) return payload.cast<Map<String, dynamic>>();
      return [];
    } catch (error) {
      throw _friendlyError(error, fallback: 'Failed to load recent work orders');
    }
  }
}
