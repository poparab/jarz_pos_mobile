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
      '/api/method/jarz_pos.api.couriers.get_courier_balances',
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
      '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
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

  // New two-step APIs
  Future<Map<String, dynamic>> generateSettlementPreview({
    required String invoice,
    String? partyType,
    String? party,
    String mode = 'pay_now',
    int recentPaymentSeconds = 30,
  }) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.couriers.generate_settlement_preview',
      data: {
        'invoice': invoice,
        if (partyType != null) 'party_type': partyType,
        if (party != null) 'party': party,
        'mode': mode,
        'recent_payment_seconds': recentPaymentSeconds,
      },
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected generate preview response');
  }

  Future<Map<String, dynamic>> confirmSettlement({
    required String invoice,
    required String previewToken,
    required String mode,
    String? posProfile,
    String? partyType,
    String? party,
    String paymentMode = 'Cash',
  String? courier,
  }) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.couriers.confirm_settlement',
      data: {
        'invoice': invoice,
        'preview_token': previewToken,
        'mode': mode,
        if (posProfile != null) 'pos_profile': posProfile,
        if (partyType != null) 'party_type': partyType,
        if (party != null) 'party': party,
        'payment_mode': paymentMode,
    // Only send courier when non-empty; otherwise allow backend to derive from party
    if (courier != null && courier.trim().isNotEmpty) 'courier': courier,
      },
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected confirm settlement response');
  }

  Future<Map<String, dynamic>> settleAllForParty({
    required String posProfile,
    String? partyType,
    String? party,
    String? legacyCourier,
  }) async {
    // Prefer unified party endpoint; fallback to legacy courier label if needed
    final endpoint = (partyType != null && party != null && partyType.isNotEmpty && party.isNotEmpty)
        ? '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_delivery_party'
        : '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_courier';
    final data = <String, dynamic>{
      if (partyType != null && partyType.isNotEmpty) 'party_type': partyType,
      if (party != null && party.isNotEmpty) 'party': party,
      if (legacyCourier != null && legacyCourier.isNotEmpty) 'courier': legacyCourier,
      'pos_profile': posProfile,
    };
    final resp = await _dio.post(endpoint, data: data);
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected settle all response');
  }
}
