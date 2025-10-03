import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final cashTransferServiceProvider = Provider<CashTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return CashTransferService(dio);
});

class CashTransferService {
  final Dio _dio;
  CashTransferService(this._dio);

  Future<List<Map<String, dynamic>>> listAccounts({String? asOf, String? company}) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.cash_transfer.list_accounts', data: {
      if (asOf != null) 'as_of': asOf,
      if (company != null) 'company': company,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> submitCashTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    final resp = await _dio.post('/api/method/jarz_pos.api.cash_transfer.submit_transfer', data: {
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
