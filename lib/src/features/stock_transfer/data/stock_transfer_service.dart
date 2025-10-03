import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final stockTransferServiceProvider = Provider<StockTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return StockTransferService(dio);
});

class StockTransferService {
  final Dio _dio;
  StockTransferService(this._dio);

  Future<List<Map<String, dynamic>>> listPosProfiles() async {
    final resp = await _dio.post('/api/method/jarz_pos.api.transfer.list_pos_profiles', data: {});
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> listItemGroups({String? search}) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.transfer.list_item_groups', data: { if (search != null) 'search': search });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> searchItemsWithStock({
    required String sourceWarehouse,
    required String targetWarehouse,
    String? search,
    String? itemGroup,
  }) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.transfer.search_items_with_stock', data: {
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      if (search != null) 'search': search,
      if (itemGroup != null) 'item_group': itemGroup,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> submitTransfer({
    required String sourceWarehouse,
    required String targetWarehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
  }) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.transfer.submit_transfer', data: {
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      'lines': lines,
      if (postingDate != null) 'posting_date': postingDate,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) return Map<String, dynamic>.from(payload['message'] as Map);
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected submit transfer response');
  }
}
