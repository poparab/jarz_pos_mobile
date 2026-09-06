import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';

final partnerSettlementsServiceProvider =
    Provider<PartnerSettlementsService>((ref) {
  final dio = ref.watch(dioProvider);
  return PartnerSettlementsService(dio);
});

/// Two payables that today can only be cleared outside the app.
///
///  * Delivery Partner — a courier COMPANY whose per-trip fee accrues at
///    dispatch and is cleared by one weekly bank transfer. The partner's own
///    invoice does not always match ours, so settling takes an explicit list
///    of the trips the operator agrees with; anything left out stays
///    unbilled and reappears next week.
///  * Sales Partner — commission + VAT recognised in one batch journal entry
///    at settlement time (never at Out For Delivery).
class PartnerSettlementsService {
  final Dio _dio;
  PartnerSettlementsService(this._dio);

  // ── Delivery partners (weekly bank transfer) ──────────────────────────

  /// Unbilled fee total + trip count per Delivery Partner.
  Future<List<Map<String, dynamic>>> getDeliveryPartnerBalances() async {
    final resp =
        await _dio.post(ApiEndpoints.deliveryPartnerBalances, data: {});
    return _unwrapList(resp.data);
  }

  /// The individual unsettled trips making up one partner's balance — this is
  /// the list the operator checks against the partner's own invoice.
  Future<List<Map<String, dynamic>>> getDeliveryPartnerUnsettledDetails(
    String deliveryPartner,
  ) async {
    final resp = await _dio.post(
      ApiEndpoints.deliveryPartnerUnsettledDetails,
      data: {'delivery_partner': deliveryPartner},
    );
    return _unwrapList(resp.data);
  }

  /// Pays a Delivery Partner the selected trip fees plus any fixed charges.
  ///
  /// `courierTransactions` and `extraCharges` are sent JSON-encoded, matching
  /// the house pattern for list arguments to a Frappe whitelisted method
  /// (see `PosRepository.validatePromoCodes`'s `promo_codes` field): the
  /// backend's `_coerce_rows` explicitly accepts "a JSON string or a real
  /// list" because that is how Frappe receives list args over HTTP.
  Future<Map<String, dynamic>> settleDeliveryPartner({
    required String deliveryPartner,
    String? bankAccount,
    required List<String> courierTransactions,
    List<Map<String, dynamic>> extraCharges = const [],
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.deliveryPartnerSettle,
      data: {
        'delivery_partner': deliveryPartner,
        if (bankAccount != null && bankAccount.trim().isNotEmpty)
          'bank_account': bankAccount,
        'courier_transactions': jsonEncode(courierTransactions),
        'extra_charges': jsonEncode(extraCharges),
      },
    );
    return _unwrapMap(resp.data);
  }

  // ── Sales partners (commission + VAT) ─────────────────────────────────

  /// Unsettled commission totals per Sales Partner.
  Future<List<Map<String, dynamic>>> getSalesPartnerBalances() async {
    final resp = await _dio.post(ApiEndpoints.salesPartnerBalances, data: {});
    return _unwrapList(resp.data);
  }

  /// Posts the batch commission + VAT recognition journal entry for a Sales
  /// Partner, aggregating every `Unsettled` Sales Partner Transaction.
  Future<Map<String, dynamic>> settleSalesPartner({
    required String salesPartner,
    String? posProfile,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.salesPartnerSettle,
      data: {
        'sales_partner': salesPartner,
        if (posProfile != null && posProfile.trim().isNotEmpty)
          'pos_profile': posProfile,
      },
    );
    return _unwrapMap(resp.data);
  }

  // ── Envelope unwrapping ────────────────────────────────────────────────

  List<Map<String, dynamic>> _unwrapList(dynamic payload) {
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(dynamic payload) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    throw Exception('Unexpected partner settlement response');
  }
}
