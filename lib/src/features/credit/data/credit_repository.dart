import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/credit_models.dart';

final creditRepositoryProvider = Provider<CreditRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CreditRepository(dio);
});

/// HTTP repository for `jarz_pos.api.credit.*`.
///
/// Every call unwraps Frappe's `{"message": ...}` envelope and re-raises
/// through [extractFrappeErrorMessage], so a server refusal — "credit limit
/// exceeded", "not approved for credit" — reaches the UI as the sentence the
/// backend wrote rather than as a bare 417.
class CreditRepository {
  final Dio _dio;
  CreditRepository(this._dio);

  /// Unwraps `{"message": ...}` and tolerates a string body (some proxies
  /// hand Dio the raw JSON text).
  Map<String, dynamic> _payload(Response<dynamic> response, String fallback) {
    final data = response.data is String
        ? json.decode(response.data as String)
        : response.data;
    final unwrapped = data is Map<String, dynamic> ? (data['message'] ?? data) : data;
    if (unwrapped is! Map) {
      throw Exception(fallback);
    }
    final map = Map<String, dynamic>.from(unwrapped);
    if (map['success'] == false) {
      throw Exception(extractFrappeErrorMessage(map, fallback: fallback));
    }
    return map;
  }

  /// The customer's credit standing, used to gate and annotate the checkout
  /// payment selector. Read-only; the server re-checks the limit on submit,
  /// so a stale profile can never let an over-limit order through.
  Future<CustomerCreditProfile> getCustomerCreditProfile(String customer) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getCustomerCreditProfile,
        queryParameters: {'customer': customer},
      );
      final map = _payload(response, 'Failed to load credit profile');
      return CustomerCreditProfile.fromJson({'customer': customer, ...map});
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load credit profile');
    }
  }

  /// Per-shop credit balances plus the window-scoped invoice feed.
  ///
  /// The date window scopes the `invoices` list ONLY. Each customer's
  /// outstanding total is all-time by contract, which is why the window
  /// arguments are not applied to it here either.
  ///
  /// The returned customers are re-sorted highest balance first so the screen
  /// never inherits whatever order the server happened to produce.
  Future<CreditLedger> getCreditLedger({
    String? customer,
    String? posProfile,
    String? fromDate,
    String? toDate,
    int limit = 200,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getCreditLedger,
        queryParameters: {
          if (customer != null && customer.isNotEmpty) 'customer': customer,
          if (posProfile != null && posProfile.isNotEmpty)
            'pos_profile': posProfile,
          if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
          'limit': limit,
        },
      );
      final ledger = CreditLedger.fromJson(
        _payload(response, 'Failed to load credit accounts'),
      );
      final sorted = [...ledger.customers]
        ..sort((a, b) => b.totalOutstanding.compareTo(a.totalOutstanding));
      return ledger.copyWith(customers: sorted);
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load credit accounts');
    }
  }

  /// Records a payment against a shop's credit account.
  ///
  /// The backend allocates FIFO across the open invoices, oldest first: a
  /// partial payment part-allocates the oldest, and any excess is left as an
  /// unallocated advance. The response — not the amount that was typed — is
  /// what the caller must show back to the user.
  Future<CreditPaymentResult> recordCreditPayment({
    required String customer,
    required double amount,
    required String posProfile,
    String paymentMethod = 'Cash',
    String? postingDate,
    String? remarks,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.recordCreditPayment,
        data: {
          'customer': customer,
          'amount': amount,
          'pos_profile': posProfile,
          'payment_method': paymentMethod,
          if (postingDate != null && postingDate.isNotEmpty)
            'posting_date': postingDate,
          if (remarks != null && remarks.trim().isNotEmpty)
            'remarks': remarks.trim(),
        },
      );
      final map = _payload(response, 'Failed to record payment');
      return CreditPaymentResult.fromJson({
        'customer': customer,
        'amount': amount,
        ...map,
      });
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to record payment');
    }
  }
}
