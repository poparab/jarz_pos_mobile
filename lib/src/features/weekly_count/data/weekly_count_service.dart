import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'weekly_count_models.dart';

/// `jarz_pos.api.branch_weekly_count` endpoints.
///
/// Kept beside the feature rather than in `core/constants/api_endpoints.dart`
/// so this feature lands as one self-contained slice.
abstract final class WeeklyCountEndpoints {
  static const _base = '/api/method/jarz_pos.api.branch_weekly_count';
  static const getStatus = '$_base.get_weekly_count_status';
  static const getSheet = '$_base.get_weekly_count_sheet';
  static const submit = '$_base.submit_weekly_count';
  static const list = '$_base.list_weekly_counts';
  static const get = '$_base.get_weekly_count';
  static const approve = '$_base.approve_weekly_count';
  static const reject = '$_base.reject_weekly_count';
}

final weeklyCountServiceProvider = Provider<WeeklyCountService>((ref) {
  return WeeklyCountService(ref.watch(dioProvider));
});

class WeeklyCountService {
  final Dio _dio;
  WeeklyCountService(this._dio);

  /// Frappe wraps whitelisted return values in `{"message": ...}`, but not
  /// always — unwrap defensively rather than assuming either shape.
  static Map<String, dynamic> _unwrap(dynamic payload) {
    final body = payload is Map && payload['message'] is Map
        ? payload['message']
        : payload;
    if (body is! Map) {
      throw Exception('Unexpected response shape: ${body.runtimeType}');
    }
    return Map<String, dynamic>.from(body);
  }

  Future<WeeklyCountStatus> getStatus() async {
    final resp = await _dio.get(WeeklyCountEndpoints.getStatus);
    return WeeklyCountStatus.fromJson(_unwrap(resp.data));
  }

  Future<WeeklyCountSheet> getSheet(String posProfile) async {
    final resp = await _dio.get(
      WeeklyCountEndpoints.getSheet,
      queryParameters: {'pos_profile': posProfile},
    );
    return WeeklyCountSheet.fromJson(_unwrap(resp.data));
  }

  Future<WeeklyCountSubmitResult> submit({
    required String posProfile,
    required List<Map<String, dynamic>> lines,
    required String clientRequestId,
    List<Map<String, dynamic>>? labelLines,
  }) async {
    final resp = await _dio.post(
      WeeklyCountEndpoints.submit,
      data: jsonEncode({
        'pos_profile': posProfile,
        'lines': lines,
        'client_request_id': clientRequestId,
        // Only a branch that stores labels sends them; the server wants every
        // label on the sheet when the list is present.
        if (labelLines != null && labelLines.isNotEmpty)
          'label_lines': labelLines,
      }),
      options: Options(contentType: 'application/json'),
    );
    return WeeklyCountSubmitResult.fromJson(_unwrap(resp.data));
  }

  Future<List<WeeklyCountSummary>> list({
    String? status,
    String? posProfile,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      WeeklyCountEndpoints.list,
      queryParameters: {
        if (status != null) 'status': status,
        if (posProfile != null) 'pos_profile': posProfile,
        'limit': limit,
      },
    );
    final body = _unwrap(resp.data);
    final rows = body['counts'];
    return (rows is List ? rows : const [])
        .whereType<Map>()
        .map((e) => WeeklyCountSummary.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<WeeklyCountDetail> getDetail(String name) async {
    final resp = await _dio.get(
      WeeklyCountEndpoints.get,
      queryParameters: {'name': name},
    );
    return WeeklyCountDetail.fromJson(_unwrap(resp.data));
  }

  Future<Map<String, dynamic>> approve(String name) async {
    final resp = await _dio.post(
      WeeklyCountEndpoints.approve,
      data: jsonEncode({'name': name}),
      options: Options(contentType: 'application/json'),
    );
    return _unwrap(resp.data);
  }

  Future<Map<String, dynamic>> reject(String name, String reason) async {
    final resp = await _dio.post(
      WeeklyCountEndpoints.reject,
      data: jsonEncode({'name': name, 'reason': reason}),
      options: Options(contentType: 'application/json'),
    );
    return _unwrap(resp.data);
  }
}

// ── Refusal codes ───────────────────────────────────────────────────────────

/// The `[error_code]` prefixes the backend puts on its refusals.
abstract final class WeeklyCountErrorCodes {
  static const missingItems = 'missing_items';
  static const unknownItems = 'unknown_items';
  static const invalidQty = 'invalid_qty';
  static const alreadyPending = 'already_pending';
  static const alreadyDone = 'already_done';
  static const noAccess = 'no_access';
  static const noWarehouse = 'no_warehouse';
  static const reasonRequired = 'reason_required';

  /// approve / reject: the count is no longer Pending Approval (already
  /// reviewed, often by a retry after a lost response).
  static const notPending = 'not_pending';
  static const notFound = 'not_found';

  /// approve / auto-approve: the Stock Reconciliation could not be posted.
  static const postFailed = 'post_failed';

  /// sheet / submit: the branch has nothing to count.
  static const noItems = 'no_items';

  /// approve / reject: the caller counted this one; someone else decides.
  static const ownCount = 'own_count';
}

final RegExp _errorCodePattern = RegExp(r'\[([a-z][a-z0-9_]*)\]');

/// Every text a failure carries that could hold the server's message:
/// `_server_messages` (a JSON list of JSON objects), `exception`, `message`,
/// and the error's own string.
List<String> weeklyCountErrorTexts(Object? error) {
  final out = <String>[];

  // `_server_messages` alone is six levels deep: body map -> JSON string ->
  // list -> JSON string -> map -> message. The cap only stops a cycle.
  void addRaw(dynamic value, [int depth = 0]) {
    if (value == null || depth > 10) return;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      if ((trimmed.startsWith('[') && !_errorCodePattern.hasMatch(trimmed)) ||
          trimmed.startsWith('{') ||
          trimmed.startsWith('["') ||
          trimmed.startsWith('[{')) {
        try {
          addRaw(jsonDecode(trimmed), depth + 1);
          return;
        } catch (_) {
          // Not JSON after all: keep the text.
        }
      }
      out.add(trimmed);
      return;
    }
    if (value is List) {
      for (final v in value) {
        addRaw(v, depth + 1);
      }
      return;
    }
    if (value is Map) {
      for (final key in const [
        '_server_messages',
        'message',
        'exception',
        'exc',
        '_error_message',
      ]) {
        if (value.containsKey(key)) addRaw(value[key], depth + 1);
      }
    }
  }

  if (error is DioException) {
    addRaw(error.response?.data);
    addRaw(error.message);
  } else if (error is String) {
    addRaw(error);
  } else if (error != null) {
    addRaw(error.toString());
  }
  return out;
}

/// The first `[error_code]` in a failure, or null.
String? weeklyCountErrorCode(Object? error) {
  for (final text in weeklyCountErrorTexts(error)) {
    final match = _errorCodePattern.firstMatch(text);
    if (match != null) return match.group(1);
  }
  return null;
}

/// The server's own text after the `[error_code]` prefix (for `missing_items`
/// that is the list of item names), or null.
String? weeklyCountErrorDetail(Object? error) {
  for (final text in weeklyCountErrorTexts(error)) {
    final match = _errorCodePattern.firstMatch(text);
    if (match == null) continue;
    final rest = text.substring(match.end).trim();
    final cleaned = rest.replaceFirst(RegExp(r'^[:\-–—\s]+'), '').trim();
    return cleaned.isEmpty ? null : cleaned;
  }
  return null;
}
