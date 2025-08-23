import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';

final courierServiceProvider = Provider<CourierService>((ref) {
  final dio = ref.watch(dioProvider);
  return CourierService(dio);
});

class CourierService {
  final Dio _dio;
  CourierService(this._dio);

  Future<List<dynamic>> getBalances() async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.jarz_pos.api.couriers.get_courier_balances',
      data: {},
    );
    // Frappe packs data in 'message' for /api/method
    final payload = resp.data;
    if (payload is Map && payload.containsKey('message')) {
      return (payload['message'] as List).cast<dynamic>();
    }
    if (payload is List) return payload;
    return [];
  }

  Future<Map<String, dynamic>> getSettlementPreview({
    required String invoice,
    String? partyType,
    String? party,
  }) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.jarz_pos.api.invoices.get_invoice_settlement_preview',
      data: {
        'invoice_name': invoice,
        if (partyType != null) 'party_type': partyType,
        if (party != null) 'party': party,
      },
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected preview response');
  }
}
