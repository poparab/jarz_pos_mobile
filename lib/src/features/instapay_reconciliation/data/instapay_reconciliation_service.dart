import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/unconfirmed_online_order.dart';

final instapayReconciliationServiceProvider =
    Provider<InstapayReconciliationService>((ref) {
  final dio = ref.watch(dioProvider);
  return InstapayReconciliationService(dio);
});

/// Dio-backed client for the InstaPay-on-delivery payment assurance &
/// reconciliation endpoints. Mirrors the unwrap/error patterns of
/// [CourierService] so error surfacing stays consistent across the app.
class InstapayReconciliationService {
  final Dio _dio;
  InstapayReconciliationService(this._dio);

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
    if (success == false ||
        (error != null && error.toString().trim().isNotEmpty)) {
      throw Exception(
        extractFrappeErrorMessage(error ?? payload, fallback: fallback),
      );
    }
    return payload;
  }

  /// Move an UNPAID online order to Out for Delivery as "Awaiting Payment"
  /// without touching the courier-outstanding / settle-later path.
  Future<Map<String, dynamic>> deliverOnlineUnconfirmed({
    required String invoiceName,
    required String posProfile,
    String? partyType,
    String? party,
    bool shortageApproved = false,
    String? shortageReason,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.deliverOnlineUnconfirmed,
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          if (partyType != null && partyType.trim().isNotEmpty)
            'party_type': partyType.trim(),
          if (party != null && party.trim().isNotEmpty) 'party': party.trim(),
          if (shortageApproved) 'shortage_approved': 1,
          if (shortageReason != null && shortageReason.trim().isNotEmpty)
            'shortage_reason': shortageReason.trim(),
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to send order out for delivery',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to send order out for delivery',
      );
    }
  }

  /// List online orders that are out for delivery and awaiting a confirmed
  /// bank transfer, optionally scoped to a single POS profile.
  Future<List<UnconfirmedOnlineOrder>> fetchUnconfirmedOnlineOrders({
    String? posProfile,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.listUnconfirmedOnlineOrders,
        data: {
          if (posProfile != null && posProfile.trim().isNotEmpty)
            'pos_profile': posProfile.trim(),
        },
      );
      final payload = _parseMethodResponse(
        resp.data,
        fallback: 'Failed to load unconfirmed online orders',
      );
      final orders = payload['orders'];
      if (orders is List) {
        return orders
            .whereType<Map>()
            .map((e) =>
                UnconfirmedOnlineOrder.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load unconfirmed online orders',
      );
    }
  }

  /// Confirm the incoming bank transfer for an awaiting order, recording the
  /// reference number and the receipt screenshot record.
  Future<Map<String, dynamic>> confirmOnlinePayment({
    required String invoiceName,
    required String posProfile,
    required String referenceNo,
    required String receiptName,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.confirmOnlinePayment,
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'reference_no': referenceNo,
          'receipt_name': receiptName,
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to confirm online payment',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to confirm online payment',
      );
    }
  }

  /// Cash-at-the-door fallback: convert an awaiting online order into a
  /// cash-on-delivery settlement against the given courier party.
  Future<Map<String, dynamic>> convertToCod({
    required String invoiceName,
    required String posProfile,
    required String partyType,
    required String party,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.convertOnlineOrderToCod,
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': partyType,
          'party': party,
        },
      );
      return _parseMethodResponse(
        resp.data,
        fallback: 'Failed to convert order to cash',
      );
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to convert order to cash',
      );
    }
  }
}
