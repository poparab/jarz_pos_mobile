import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final manufacturingServiceProvider = Provider<ManufacturingService>((ref) {
  final dio = ref.watch(dioProvider);
  return ManufacturingService(dio);
});

class ManufacturingService {
  final Dio _dio;
  ManufacturingService(this._dio);

  Future<List<Map<String, dynamic>>> listDefaultBomItems(String search) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.manufacturing.list_default_bom_items',
      data: {'search': search},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> getBomDetails(String itemCode) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.manufacturing.get_bom_details',
      data: {'item_code': itemCode},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected BOM details response');
  }

  Future<Map<String, dynamic>> submitWorkOrders(List<Map<String, dynamic>> lines) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.manufacturing.submit_work_orders',
      data: {'lines': lines},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected submit response');
  }

  Future<Map<String, dynamic>> submitSingleWorkOrder({
    required String itemCode,
    required String bomName,
    required double itemQty,
    String? scheduledAt,
  }) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.manufacturing.submit_single_work_order',
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
  }

  Future<List<Map<String, dynamic>>> listRecentWorkOrders({int limit = 50}) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders',
      data: {"limit": limit},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }
}
