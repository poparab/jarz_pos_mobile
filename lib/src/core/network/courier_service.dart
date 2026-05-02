import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';
import 'frappe_error_message.dart';
import '../constants/api_endpoints.dart';
import '../constants/business_constants.dart';

final courierServiceProvider = Provider<CourierService>((ref) {
  final dio = ref.watch(dioProvider);
  return CourierService(dio);
});

class CourierService {
  final Dio _dio;
  CourierService(this._dio);

  Map<String, dynamic> _parseMethodResponse(
    dynamic payload, {
    required String fallback,
  }) {
    if (payload is Map && payload['message'] is Map) {
      return _unwrapPayloadMap(
        Map<String, dynamic>.from(payload['message'] as Map),
        fallback: fallback,
      );
    }
    if (payload is Map) {
      return _unwrapPayloadMap(
        Map<String, dynamic>.from(payload),
        fallback: fallback,
      );
    }
    throw Exception(fallback);
  }

  Map<String, dynamic> _unwrapPayloadMap(
    Map<String, dynamic> payload, {
    required String fallback,
  }) {
    final success = payload['success'];
    final error = payload['error'];
    if (success == false || (error != null && error.toString().trim().isNotEmpty)) {
      throw Exception(
        extractFrappeErrorMessage(error ?? payload, fallback: fallback),
      );
    }
    return payload;
  }

  Future<List<dynamic>> getBalances() async {
    final resp = await _dio.post(
      ApiEndpoints.getCourierBalances,
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
    try {
      final resp = await _dio.post(
        ApiEndpoints.getInvoiceSettlementPreview,
        data: {
          'invoice_name': invoice,
          if (partyType != null) 'party_type': partyType,
          if (party != null) 'party': party,
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to load settlement preview',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load settlement preview',
      );
    }
  }

  // New two-step APIs
  Future<Map<String, dynamic>> generateSettlementPreview({
    required String invoice,
    String? partyType,
    String? party,
    String mode = 'pay_now',
    int recentPaymentSeconds = 30,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.generateSettlementPreview,
        data: {
          'invoice': invoice,
          if (partyType != null) 'party_type': partyType,
          if (party != null) 'party': party,
          'mode': mode,
          'recent_payment_seconds': recentPaymentSeconds,
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to load settlement preview',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load settlement preview',
      );
    }
  }

  Future<Map<String, dynamic>> confirmSettlement({
    required String invoice,
    required String previewToken,
    required String mode,
    String? posProfile,
    String? partyType,
    String? party,
    String paymentMode = PaymentModes.cash,
    String? courier,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.confirmSettlement,
        data: {
          'invoice': invoice,
          'preview_token': previewToken,
          'mode': mode,
          if (posProfile != null) 'pos_profile': posProfile,
          if (partyType != null) 'party_type': partyType,
          if (party != null) 'party': party,
          'payment_mode': paymentMode,
          if (courier != null && courier.trim().isNotEmpty) 'courier': courier,
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to confirm settlement',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to confirm settlement',
      );
    }
  }

  Future<Map<String, dynamic>> settleAllForParty({
    required String posProfile,
    String? partyType,
    String? party,
    String? legacyCourier,
  }) async {
    // Prefer unified party endpoint; fallback to legacy courier label if needed
    final endpoint = (partyType != null && party != null && partyType.isNotEmpty && party.isNotEmpty)
        ? ApiEndpoints.settleDeliveryParty
        : ApiEndpoints.settleCourier;
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
