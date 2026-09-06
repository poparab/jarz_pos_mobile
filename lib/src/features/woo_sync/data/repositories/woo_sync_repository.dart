import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/woo_duplicate_group.dart';
import '../models/woo_sync_dashboard.dart';
import '../models/woo_sync_event.dart';

final wooSyncRepositoryProvider = Provider<WooSyncRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WooSyncRepository(dio);
});

/// HTTP client for the `jarz_woocommerce_integration` sync-operations API.
///
/// That app is a completely separate Frappe app from the POS backend this
/// client talks to everywhere else — calling it over HTTP is the sanctioned
/// way to reach it from Flutter (see the domain-isolation rule: it forbids
/// the two *Python* apps importing each other, not client network calls).
///
/// Every Frappe `@frappe.whitelist` response is unwrapped defensively: the
/// normal shape is `{"message": <payload>}`, but a bare payload is accepted
/// too so a future proxy/cache layer that strips the envelope doesn't break
/// every call site here.
class WooSyncRepository {
  final Dio _dio;
  WooSyncRepository(this._dio);

  /// Both `retry_events` and `set_review_state_bulk` slice `event_names` to
  /// their first 100 entries server-side and silently ignore the rest — so a
  /// larger selection must be rejected client-side with a clear message
  /// rather than quietly acting on only part of it.
  static const bulkNameLimit = 100;

  dynamic _unwrap(dynamic payload) {
    if (payload is Map && payload.containsKey('message')) return payload['message'];
    return payload;
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    final message = _unwrap(payload);
    if (message is Map) return Map<String, dynamic>.from(message);
    return <String, dynamic>{};
  }

  List<dynamic> _asRawList(dynamic payload) {
    final message = _unwrap(payload);
    if (message is List) return message;
    return const [];
  }

  void _assertWithinBulkLimit(List<String> eventNames) {
    if (eventNames.isEmpty) {
      throw ArgumentError('event_names must not be empty');
    }
    if (eventNames.length > bulkNameLimit) {
      throw ArgumentError(
        'Cannot act on ${eventNames.length} events at once; the server caps bulk '
        'operations at $bulkNameLimit. Narrow the selection and retry.',
      );
    }
  }

  Future<WooSyncDashboard> getDashboard({int windowHours = 24, int limit = 20}) async {
    final resp = await _dio.post(
      ApiEndpoints.wooSyncDashboard,
      data: {'window_hours': windowHours, 'limit': limit},
    );
    return WooSyncDashboard.fromJson(_asMap(resp.data));
  }

  Future<List<WooSyncEvent>> getEvents({
    String? status,
    String? direction,
    String? eventType,
    String? objectType,
    String? localDoctype,
    String? reviewState,
    String? search,
    int limit = 50,
  }) async {
    final filters = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (direction != null && direction.isNotEmpty) 'direction': direction,
      if (eventType != null && eventType.isNotEmpty) 'event_type': eventType,
      if (objectType != null && objectType.isNotEmpty) 'object_type': objectType,
      if (localDoctype != null && localDoctype.isNotEmpty) 'local_doctype': localDoctype,
      if (reviewState != null && reviewState.isNotEmpty) 'review_state': reviewState,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final resp = await _dio.post(
      ApiEndpoints.wooSyncEvents,
      data: {
        // The backend parses this as a JSON string via `_parse_json_arg` but
        // also accepts an already-decoded dict — send it encoded so a plain
        // Dio JSON body (which would otherwise post the filters as nested
        // form fields) round-trips exactly like the Desk page's call does.
        'filters': jsonEncode(filters),
        'limit': limit,
      },
    );
    return _asRawList(resp.data)
        .whereType<Map>()
        .map((e) => WooSyncEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> retryEvent(String eventName) async {
    final resp = await _dio.post(ApiEndpoints.wooSyncRetryEvent, data: {'event_name': eventName});
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> retryEvents(List<String> eventNames) async {
    _assertWithinBulkLimit(eventNames);
    final resp = await _dio.post(
      ApiEndpoints.wooSyncRetryEvents,
      data: {'event_names': jsonEncode(eventNames)},
    );
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> processEventNow(String eventName) async {
    final resp = await _dio.post(ApiEndpoints.wooSyncProcessNow, data: {'event_name': eventName});
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> setReviewState(
    String eventName,
    String reviewState, {
    String? resolutionNotes,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.wooSyncSetReviewState,
      data: {
        'event_name': eventName,
        'review_state': reviewState,
        if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      },
    );
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> setReviewStateBulk(
    List<String> eventNames,
    String reviewState, {
    String? resolutionNotes,
  }) async {
    _assertWithinBulkLimit(eventNames);
    final resp = await _dio.post(
      ApiEndpoints.wooSyncSetReviewStateBulk,
      data: {
        'event_names': jsonEncode(eventNames),
        'review_state': reviewState,
        if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      },
    );
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> runWorker({int? batchSize}) async {
    final resp = await _dio.post(
      ApiEndpoints.wooSyncRunWorker,
      data: {if (batchSize != null) 'batch_size': batchSize},
    );
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> clearOutboundBreaker() async {
    final resp = await _dio.post(ApiEndpoints.wooSyncClearBreaker);
    return _asMap(resp.data);
  }

  Future<Map<String, dynamic>> pushSalesInvoice(String invoiceName) async {
    final resp = await _dio.post(
      ApiEndpoints.wooPushSalesInvoice,
      data: {'invoice_name': invoiceName},
    );
    return _asMap(resp.data);
  }

  Future<List<WooDuplicateGroup>> getDuplicateReview() async {
    final resp = await _dio.post(ApiEndpoints.wooDuplicateReview);
    return _asRawList(resp.data)
        .whereType<Map>()
        .map((e) => WooDuplicateGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
