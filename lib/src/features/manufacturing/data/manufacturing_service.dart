import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/basket_rollup.dart';
import 'models/bom_details.dart';
import 'models/production_suggestion.dart';

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
