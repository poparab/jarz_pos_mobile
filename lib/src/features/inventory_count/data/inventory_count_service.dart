import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final inventoryCountServiceProvider = Provider<InventoryCountService>((ref) {
  final dio = ref.watch(dioProvider);
  return InventoryCountService(dio);
});

class InventoryCountService {
  final Dio _dio;
  InventoryCountService(this._dio);

  void _debugLog(String message, {Object? data}) {
    assert(() {
      developer.log(
        data == null ? message : '$message: $data',
        name: 'InventoryCountService',
      );
      return true;
    }());
  }

  Future<List<Map<String, dynamic>>> listWarehouses({String? company}) async {
    final resp = await _dio.post(ApiEndpoints.listWarehouses, data: {
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
    final resp = await _dio.post(ApiEndpoints.listItemsForCount, data: {
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

  /// Past stock counts, newest first.
  ///
  /// A submitted reconciliation only carries the lines that actually differed,
  /// so this is the record of what each count corrected.
  Future<({List<Map<String, dynamic>> counts, int total})> listReconciliations({
    int limit = 30,
    int page = 0,
    String? warehouse,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final resp = await _dio.post(ApiEndpoints.listReconciliations, data: {
      'limit': limit,
      'page': page,
      if (warehouse != null) 'warehouse': warehouse,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final payload = resp.data;
    final message = (payload is Map && payload['message'] is Map)
        ? Map<String, dynamic>.from(payload['message'] as Map)
        : (payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{});
    final rows = (message['counts'] as List?) ?? const [];
    return (
      counts: rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      total: (message['total'] as num?)?.toInt() ?? rows.length,
    );
  }

  Future<Map<String, dynamic>> submitReconciliation({
    required String warehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
    bool enforceAll = true,
  }) async {
    _debugLog(
      'submit_reconciliation request',
      data: {
        'warehouse': warehouse,
        'linesCount': lines.length,
        'lines': lines,
        'postingDate': postingDate,
        'enforceAll': enforceAll,
      },
    );
    
    final requestData = {
      'warehouse': warehouse,
      'lines': lines,
      if (postingDate != null) 'posting_date': postingDate,
      'enforce_all': enforceAll ? 1 : 0,
    };
    
  _debugLog('submit_reconciliation data map', data: requestData);

    final jsonData = jsonEncode(requestData);
  _debugLog('submit_reconciliation json payload', data: jsonData);
    
    final resp = await _dio.post(
      ApiEndpoints.submitReconciliation,
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
