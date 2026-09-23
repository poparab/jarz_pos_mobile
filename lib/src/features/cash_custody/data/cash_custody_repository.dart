import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/cash_custody_models.dart';

final cashCustodyRepositoryProvider = Provider<CashCustodyRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CashCustodyRepository(dio);
});

/// HTTP access to `jarz_pos.api.cash_custody.*`.
class CashCustodyRepository {
  final Dio _dio;
  CashCustodyRepository(this._dio);

  Future<CustodyOverview> fetchOverview() async {
    final message = await _post(ApiEndpoints.custodyOverview, const {});
    return CustodyOverview.fromJson(message);
  }

  Future<List<CustodyCandidate>> listCandidates({String? search}) async {
    final message = await _post(ApiEndpoints.custodyListCandidates, {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    final rows = message['employees'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((e) => CustodyCandidate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CustodyHolder> addHolder(String employee) async {
    final message =
        await _post(ApiEndpoints.custodyAddHolder, {'employee': employee});
    return _holderFrom(message);
  }

  Future<CustodyHolder> setHolderEnabled(String holder, bool enabled) async {
    final message = await _post(ApiEndpoints.custodySetHolderEnabled, {
      'holder': holder,
      'enabled': enabled ? 1 : 0,
    });
    return _holderFrom(message);
  }

  Future<CustodyMovementResult> issue({
    required String holder,
    required String fromAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    final message = await _post(ApiEndpoints.custodyIssue, {
      'holder': holder,
      'from_account': fromAccount,
      'amount': amount,
      if (postingDate != null) 'posting_date': postingDate,
      if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
    });
    return CustodyMovementResult.fromJson(message);
  }

  Future<CustodyMovementResult> returnCash({
    required String holder,
    required String toAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    final message = await _post(ApiEndpoints.custodyReturn, {
      'holder': holder,
      'to_account': toAccount,
      'amount': amount,
      if (postingDate != null) 'posting_date': postingDate,
      if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
    });
    return CustodyMovementResult.fromJson(message);
  }

  Future<CustodyStatement> fetchStatement({
    required String holder,
    String? fromDate,
    String? toDate,
    int? limit,
  }) async {
    final message = await _post(ApiEndpoints.custodyStatement, {
      'holder': holder,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (limit != null) 'limit': limit,
    });
    return CustodyStatement.fromJson(message);
  }

  CustodyHolder _holderFrom(Map<String, dynamic> message) {
    final holder = message['holder'];
    if (holder is Map) {
      return CustodyHolder.fromJson(Map<String, dynamic>.from(holder));
    }
    throw Exception('Unexpected custody holder response');
  }

  /// Frappe wraps a whitelisted method's return in `{"message": ...}`.
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(endpoint, data: body);
    final payload = response.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected cash custody response');
  }
}
