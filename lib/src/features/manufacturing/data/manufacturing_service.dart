import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/constants/api_endpoints.dart';

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
