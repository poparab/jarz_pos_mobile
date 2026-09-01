import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final stockTransferServiceProvider = Provider<StockTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return StockTransferService(dio);
});

class StockTransferService {
  final Dio _dio;
  StockTransferService(this._dio);

  Future<List<Map<String, dynamic>>> listPosProfiles() async {
    final resp = await _dio.post(ApiEndpoints.transferListPosProfiles, data: {});
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> listItemGroups({String? search}) async {
    final resp = await _dio.post(ApiEndpoints.transferListItemGroups, data: { if (search != null) 'search': search });
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
    final resp = await _dio.post(ApiEndpoints.searchItemsWithStock, data: {
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

  /// Past Material Transfer entries, newest first.
  ///
  /// Returns `(transfers, total)`; `total` is the count matching the filters,
  /// which is what the caller pages against.
  Future<({List<Map<String, dynamic>> transfers, int total})> listTransfers({
    int limit = 30,
    int page = 0,
    String? sourceWarehouse,
    String? targetWarehouse,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final resp = await _dio.post(ApiEndpoints.transferListHistory, data: {
      'limit': limit,
      'page': page,
      if (sourceWarehouse != null) 'source_warehouse': sourceWarehouse,
      if (targetWarehouse != null) 'target_warehouse': targetWarehouse,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final payload = resp.data;
    final message = (payload is Map && payload['message'] is Map)
        ? Map<String, dynamic>.from(payload['message'] as Map)
        : (payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{});
    final rows = (message['transfers'] as List?) ?? const [];
    return (
      transfers: rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      total: (message['total'] as num?)?.toInt() ?? rows.length,
    );
  }

  Future<Map<String, dynamic>> submitTransfer({
    required String sourceWarehouse,
    required String targetWarehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
  }) async {
    final resp = await _dio.post(ApiEndpoints.submitTransfer, data: {
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
