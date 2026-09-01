import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final cashTransferServiceProvider = Provider<CashTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return CashTransferService(dio);
});

class CashTransferService {
  final Dio _dio;
  CashTransferService(this._dio);

  Future<List<Map<String, dynamic>>> listAccounts({String? asOf, String? company}) async {
    final resp = await _dio.post(ApiEndpoints.cashTransferListAccounts, data: {
      if (asOf != null) 'as_of': asOf,
      if (company != null) 'company': company,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  /// Past cash transfers, newest first.
  ///
  /// The backend recognises a transfer by its shape (a two-line journal entry
  /// between two transferable accounts), so this also surfaces the transfers
  /// posted before the history existed.
  Future<({List<Map<String, dynamic>> transfers, int total})> listTransfers({
    int limit = 30,
    int page = 0,
    String? account,
    String? company,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final resp = await _dio.post(ApiEndpoints.cashTransferListHistory, data: {
      'limit': limit,
      'page': page,
      if (account != null) 'account': account,
      if (company != null) 'company': company,
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

  Future<Map<String, dynamic>> submitCashTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    final resp = await _dio.post(ApiEndpoints.cashTransferSubmit, data: {
      'from_account': fromAccount,
      'to_account': toAccount,
      'amount': amount,
      if (postingDate != null) 'posting_date': postingDate,
      if (remark != null) 'remark': remark,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) return Map<String, dynamic>.from(payload['message'] as Map);
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected cash transfer response');
  }
}
