import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final inventoryCountServiceProvider = Provider<InventoryCountService>((ref) {
  final dio = ref.watch(dioProvider);
  return InventoryCountService(dio);
});

class InventoryCountService {
  final Dio _dio;
  InventoryCountService(this._dio);

  Future<List<Map<String, dynamic>>> listWarehouses({String? company}) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.inventory_count.list_warehouses', data: {
      if (company != null) 'company': company,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> listItemsForCount({
    required String warehouse,
    String? search,
    String? itemGroup,
    int? limit,
  }) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.inventory_count.list_items_for_count', data: {
      'warehouse': warehouse,
      if (search != null) 'search': search,
      if (itemGroup != null) 'item_group': itemGroup,
      if (limit != null) 'limit': limit,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> submitReconciliation({
    required String warehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
    bool enforceAll = true,
  }) async {
    // Debug logging
    print('🔍 submit_reconciliation called with:');
    print('   warehouse: $warehouse');
    print('   lines count: ${lines.length}');
    print('   lines: $lines');
    print('   postingDate: $postingDate');
    print('   enforceAll: $enforceAll');
    
    final requestData = {
      'warehouse': warehouse,
      'lines': lines,
      if (postingDate != null) 'posting_date': postingDate,
      'enforce_all': enforceAll ? 1 : 0,
    };
    
    print('🚀 Request data: $requestData');
    
    // CRITICAL FIX: Explicitly encode JSON and set Content-Type
    // This ensures proper serialization across different environments
    final jsonData = jsonEncode(requestData);
    print('📦 JSON encoded data: $jsonData');
    
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.inventory_count.submit_reconciliation',
      data: jsonData,
      options: Options(
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) return Map<String, dynamic>.from(payload['message'] as Map);
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected submit reconciliation response');
  }
}
