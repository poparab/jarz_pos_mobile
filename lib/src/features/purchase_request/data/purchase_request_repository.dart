import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/purchase_request_models.dart';

final purchaseRequestRepositoryProvider =
    Provider<PurchaseRequestRepository>((ref) {
  return PurchaseRequestRepository(ref.watch(dioProvider));
});

class PurchaseRequestRepository {
  final Dio _dio;
  PurchaseRequestRepository(this._dio);

  /// Frappe wraps whitelisted return values in a `message` envelope, but not
  /// always — unwrap defensively rather than assuming either shape.
  Map<String, dynamic> _unwrap(dynamic payload) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected response shape: ${payload.runtimeType}');
  }

  List<Map<String, dynamic>> _unwrapList(dynamic payload) {
    final raw = (payload is Map && payload.containsKey('message'))
        ? payload['message']
        : payload;
    if (raw is List) {
      return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
    return const [];
  }

  Future<ItemRequestPage> listRequests({
    String? status,
    String? posProfile,
    bool mineOnly = false,
    int limit = 50,
    int page = 0,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.listItemRequests,
      data: {
        if (status != null) 'status': status,
        if (posProfile != null) 'pos_profile': posProfile,
        'mine_only': mineOnly ? 1 : 0,
        'limit': limit,
        'page': page,
      },
    );
    return ItemRequestPage.fromJson(_unwrap(response.data));
  }

  Future<ItemRequest> createRequest({
    required List<DraftRequestLine> items,
    String? scheduleDate,
    String? note,
    String? posProfile,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createItemRequest,
      data: {
        'items': items.map((e) => e.toJson()).toList(),
        if (scheduleDate != null) 'schedule_date': scheduleDate,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (posProfile != null) 'pos_profile': posProfile,
      },
    );
    final payload = _unwrap(response.data);
    return ItemRequest.fromJson(
      Map<String, dynamic>.from(payload['request'] as Map),
    );
  }

  Future<ItemRequest> stopRequest(String name, {String? reason}) async {
    final response = await _dio.post(
      ApiEndpoints.stopItemRequest,
      data: {'name': name, if (reason != null) 'reason': reason},
    );
    final payload = _unwrap(response.data);
    return ItemRequest.fromJson(
      Map<String, dynamic>.from(payload['request'] as Map),
    );
  }

  Future<ItemRequest> reopenRequest(String name) async {
    final response = await _dio.post(
      ApiEndpoints.reopenItemRequest,
      data: {'name': name},
    );
    final payload = _unwrap(response.data);
    return ItemRequest.fromJson(
      Map<String, dynamic>.from(payload['request'] as Map),
    );
  }

  /// The consolidated buying list — one row per item, demand summed across
  /// every open request.
  Future<List<RequestDemandLine>> getOpenDemand() async {
    final response = await _dio.post(ApiEndpoints.getOpenRequestLines, data: {});
    final payload = _unwrap(response.data);
    return ((payload['lines'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => RequestDemandLine.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Item search scoped to requesters — `for_request` widens the server-side
  /// role gate so floor staff can search without buyer permissions.
  Future<List<Map<String, dynamic>>> searchItems(
    String search, {
    int limit = 30,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.searchItems,
      data: {'search': search, 'limit': limit, 'for_request': 1},
    );
    return _unwrapList(response.data);
  }
}
