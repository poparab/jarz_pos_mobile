import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'credit_payment_token.dart';
import 'models/credit_models.dart';
import 'models/settlement_models.dart';

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

  /// Switches credit on/off for one shop and sets its terms. A null [days] or
  /// [limit] leaves that value as it is on the server; a limit of 0 means no
  /// limit. Returns the refreshed profile.
  Future<CustomerCreditProfile> updateCustomerCreditSettings({
    required String customer,
    required bool creditAllowed,
    int? days,
    double? limit,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updateCustomerCreditSettings,
        data: {
          'customer': customer,
          'credit_allowed': creditAllowed ? 1 : 0,
          if (days != null) 'credit_days': days,
          if (limit != null) 'credit_limit': limit,
        },
      );
      final map = _payload(response, 'Failed to save credit settings');
      return CustomerCreditProfile.fromJson({'customer': customer, ...map});
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to save credit settings');
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
        ..sort((a, b) => b.outstanding.compareTo(a.outstanding));
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
  ///
  /// [idempotencyToken] is the server's strongest double-submit guard: an
  /// exact `reference_no` match. Without it the backend falls back to a
  /// two-minute (customer, account, amount) heuristic that double-books a
  /// timed-out retry and swallows a second genuine handover of the same round
  /// figure. Callers mint it through [CreditPaymentIdempotency] so it stays
  /// stable across retries of ONE attempt. A replay comes back as
  /// `already_recorded`, not as an error — see [CreditPaymentResult.isReplay].
  ///
  /// Also note the scope asymmetry the UI has to be honest about: the ledger
  /// this amount was prefilled from is scoped to the caller's POS Profiles,
  /// while allocation here is FIFO across EVERY branch of the company.
  Future<CreditPaymentResult> recordCreditPayment({
    required String customer,
    required double amount,
    required String posProfile,
    String paymentMethod = 'Cash',
    String? postingDate,
    String? remarks,
    String? idempotencyToken,
    String? invoice,
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
          if (idempotencyToken != null && idempotencyToken.trim().isNotEmpty)
            'idempotency_token': idempotencyToken.trim(),
          // Paid first; the backend refuses rather than falls back to FIFO
          // when it is no longer an open credit invoice of this customer.
          if (invoice != null && invoice.trim().isNotEmpty)
            'invoice': invoice.trim(),
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

  // ── Settlement terms ───────────────────────────────────────────────────

  /// The one party argument the settlement endpoints accept: exactly one of
  /// [customer] / [lead], and only the one given travels.
  static SettlementParty settlementParty({String? customer, String? lead}) {
    final c = customer?.trim() ?? '';
    final l = lead?.trim() ?? '';
    if ((c.isEmpty) == (l.isEmpty)) {
      throw ArgumentError('Pass exactly one of customer or lead');
    }
    return l.isNotEmpty
        ? SettlementParty.lead(l)
        : SettlementParty.customer(c);
  }

  /// One party's payment schedule, its computed collection status, and
  /// whether the caller may edit it. `terms` is null for a party with none.
  ///
  /// Throws [SettlementTermsUnavailable] when the caller may not see terms
  /// or the server predates them (or predates `lead=`), so a screen that
  /// only offers terms as an extra can hide the card instead of erroring.
  Future<SettlementTermsResponse> getSettlementTerms({
    String? customer,
    String? lead,
  }) async {
    final party = settlementParty(customer: customer, lead: lead);
    try {
      final response = await _dio.get(
        ApiEndpoints.getSettlementTerms,
        queryParameters: party.queryParameters,
      );
      final map = _payload(response, 'Failed to load payment terms');
      return SettlementTermsResponse.fromJson({
        ..._partyDefaults(party),
        ...map,
      });
    } on DioException catch (error) {
      if (isSettlementTermsUnavailable(error, sentLead: party.isLead)) {
        throw SettlementTermsUnavailable(extractFrappeErrorMessage(error));
      }
      throw mapFrappeError(error, fallback: 'Failed to load payment terms');
    }
  }

  /// Upserts the schedule. The response has the same shape as
  /// [getSettlementTerms], so the caller can show the recomputed status
  /// without a second round-trip.
  Future<SettlementTermsResponse> saveSettlementTerms(
    SettlementTermsDraft draft,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.saveSettlementTerms,
        data: draft.toPayload(),
      );
      final map = _payload(response, 'Failed to save payment terms');
      return SettlementTermsResponse.fromJson({
        ..._partyDefaults(draft.party),
        ...map,
      });
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to save payment terms');
    }
  }

  /// Removes a party's terms record. Exactly one of [customer] / [lead].
  Future<void> deleteSettlementTerms({String? customer, String? lead}) async {
    final party = settlementParty(customer: customer, lead: lead);
    try {
      final response = await _dio.post(
        ApiEndpoints.deleteSettlementTerms,
        data: party.queryParameters,
      );
      _payload(response, 'Failed to delete payment terms');
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to delete payment terms');
    }
  }

  /// What an older server (no `party_type` / `party`) implied: the party the
  /// request was made for.
  static Map<String, dynamic> _partyDefaults(SettlementParty party) => {
        'customer': party.isLead ? null : party.name,
        'party_type': party.type,
        'party': party.name,
      };

  /// Shops to collect from: overdue → due today → due soon → unscheduled →
  /// on track. Shops owing nothing are excluded by the server.
  Future<CollectionsDue> getCollectionsDue({
    int daysAhead = 7,
    String? branch,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getCollectionsDue,
        queryParameters: {
          'days_ahead': daysAhead,
          if (branch != null && branch.isNotEmpty) 'branch': branch,
        },
      );
      return CollectionsDue.fromJson(
        _payload(response, 'Failed to load collections'),
      );
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load collections');
    }
  }
}

/// The caller may not read settlement terms, or the server does not know the
/// endpoint / the `lead` argument yet. Screens that show terms as an optional
/// extra hide the card on this rather than showing an error.
class SettlementTermsUnavailable implements Exception {
  final String message;
  const SettlementTermsUnavailable([this.message = '']);

  @override
  String toString() => 'SettlementTermsUnavailable: $message';
}

/// Whether a failed settlement-terms read means "not for this caller / not on
/// this server" — hide the card — rather than a real failure, which must keep
/// the retry line. Deliberately narrow; decided only from:
///
/// * HTTP 403 / 404;
/// * Frappe's `exc_type` being `PermissionError` or `DoesNotExistError`;
/// * the message saying the method is missing ("Failed to get method") or not
///   whitelisted ("is not whitelisted");
/// * a request sent with `lead=` answered 417 "customer is required": a
///   backend older than lead support (Frappe drops the unknown `lead` kwarg,
///   so the old endpoint sees no customer at all).
///
/// Never matched against the traceback: a real server bug mentioning, say,
/// an AttributeError must surface as an error, not as a missing card.
bool isSettlementTermsUnavailable(
  DioException error, {
  bool sentLead = false,
}) {
  final status = error.response?.statusCode;
  if (status == 403 || status == 404) return true;

  var data = error.response?.data;
  if (data is String) {
    try {
      data = json.decode(data);
    } catch (_) {
      // Not JSON; only the extracted message below applies.
    }
  }

  if (data is Map) {
    final excType = '${data['exc_type'] ?? ''}'.trim();
    if (excType == 'PermissionError' || excType == 'DoesNotExistError') {
      return true;
    }
  }

  final messages = <String>[
    extractFrappeErrorMessage(error, fallback: ''),
    if (data is Map) ...[
      '${data['exception'] ?? ''}',
      '${data['_server_messages'] ?? ''}',
      '${data['message'] ?? ''}',
    ],
  ];
  bool mentions(String needle) => messages.any(
        (m) => m.toLowerCase().contains(needle.toLowerCase()),
      );

  if (mentions('Failed to get method') || mentions('is not whitelisted')) {
    return true;
  }
  if (sentLead && status == 417 && mentions('customer is required')) {
    return true;
  }
  return false;
}
