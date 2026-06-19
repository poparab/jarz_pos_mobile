import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/b2b_models.dart';

final b2bRepositoryProvider = Provider<B2bRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return B2bRepository(dio);
});

/// HTTP repository for the B2B CRM (`jarz_pos.api.crm.*`). Every call requires
/// B2B access on the backend, which throws otherwise.
class B2bRepository {
  final Dio _dio;
  B2bRepository(this._dio);

  /// Unwraps Frappe's `{ "message": ... }` envelope.
  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'];
    }
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  Future<B2bPipeline> getPipeline() async {
    final response = await _dio.post(ApiEndpoints.getB2bPipeline, data: {});
    return B2bPipeline.fromJson(_asMap(_unwrap(response)));
  }

  Future<B2bAccount> getAccount({
    required String doctype,
    required String name,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getB2bAccount,
      data: {'doctype': doctype, 'name': name},
    );
    return B2bAccount.fromJson(_asMap(_unwrap(response)));
  }

  /// Advances a card to [stage]. Returns the server-confirmed
  /// `{doctype, name, stage}`.
  Future<B2bCard> advanceStage({
    required String doctype,
    required String name,
    required String stage,
    String? reason,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bAdvanceStage,
      data: {
        'doctype': doctype,
        'name': name,
        'stage': stage,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    final payload = _asMap(_unwrap(response));
    return B2bCard(
      doctype: (payload['doctype'] ?? doctype).toString(),
      name: (payload['name'] ?? name).toString(),
      title: (payload['title'] ?? name).toString(),
      stage: (payload['stage'] ?? stage).toString(),
    );
  }

  /// Creates a Lead. Returns its `name`.
  Future<String> createLead({
    required String leadName,
    String? companyName,
    String? mobileNo,
    String? emailId,
    String? source,
    String? territory,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bCreateLead,
      data: {
        'lead_name': leadName,
        if (companyName != null && companyName.trim().isNotEmpty)
          'company_name': companyName.trim(),
        if (mobileNo != null && mobileNo.trim().isNotEmpty)
          'mobile_no': mobileNo.trim(),
        if (emailId != null && emailId.trim().isNotEmpty)
          'email_id': emailId.trim(),
        if (source != null && source.trim().isNotEmpty) 'source': source.trim(),
        if (territory != null && territory.trim().isNotEmpty)
          'territory': territory.trim(),
      },
    );
    final payload = _asMap(_unwrap(response));
    return (payload['name'] ?? '').toString();
  }

  /// Logs an activity note against an account.
  Future<void> logActivity({
    required String doctype,
    required String name,
    required String note,
  }) async {
    await _dio.post(
      ApiEndpoints.b2bLogActivity,
      data: {'doctype': doctype, 'name': name, 'note': note},
    );
  }

  Future<B2bFollowups> getMyFollowups() async {
    final response = await _dio.post(ApiEndpoints.getB2bFollowups, data: {});
    return B2bFollowups.fromJson(_asMap(_unwrap(response)));
  }

  Future<List<ReorderDueItem>> getReorderDue() async {
    final response = await _dio.post(ApiEndpoints.getB2bReorderDue, data: {});
    final raw = _unwrap(response);
    final list = (raw as List? ?? const [])
        .whereType<Map>()
        .map((e) => ReorderDueItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  /// Requests a sample for a party. For a Lead with no linked Customer, the
  /// create-customer fields must be supplied.
  Future<OrderBinding> requestSample({
    required String partyDoctype,
    required String partyName,
    String? customerName,
    String? mobileNo,
    String? customerPrimaryAddress,
    String? territoryId,
    String? customerGroup,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bRequestSample,
      data: _bindingPayload(
        partyDoctype: partyDoctype,
        partyName: partyName,
        customerName: customerName,
        mobileNo: mobileNo,
        customerPrimaryAddress: customerPrimaryAddress,
        territoryId: territoryId,
        customerGroup: customerGroup,
      ),
    );
    return OrderBinding.fromJson(_asMap(_unwrap(response)));
  }

  /// Places a B2B supply order binding for a party. Same create-customer
  /// requirement as [requestSample] for Leads.
  Future<OrderBinding> placeB2bOrder({
    required String partyDoctype,
    required String partyName,
    String? customerName,
    String? mobileNo,
    String? customerPrimaryAddress,
    String? territoryId,
    String? customerGroup,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bPlaceOrder,
      data: _bindingPayload(
        partyDoctype: partyDoctype,
        partyName: partyName,
        customerName: customerName,
        mobileNo: mobileNo,
        customerPrimaryAddress: customerPrimaryAddress,
        territoryId: territoryId,
        customerGroup: customerGroup,
      ),
    );
    return OrderBinding.fromJson(_asMap(_unwrap(response)));
  }

  Map<String, dynamic> _bindingPayload({
    required String partyDoctype,
    required String partyName,
    String? customerName,
    String? mobileNo,
    String? customerPrimaryAddress,
    String? territoryId,
    String? customerGroup,
  }) {
    return {
      'party_doctype': partyDoctype,
      'party_name': partyName,
      if (customerName != null && customerName.trim().isNotEmpty)
        'customer_name': customerName.trim(),
      if (mobileNo != null && mobileNo.trim().isNotEmpty)
        'mobile_no': mobileNo.trim(),
      if (customerPrimaryAddress != null &&
          customerPrimaryAddress.trim().isNotEmpty)
        'customer_primary_address': customerPrimaryAddress.trim(),
      if (territoryId != null && territoryId.trim().isNotEmpty)
        'territory_id': territoryId.trim(),
      if (customerGroup != null && customerGroup.trim().isNotEmpty)
        'customer_group': customerGroup.trim(),
    };
  }

  /// Company-only customer search for B2B mode.
  Future<List<Map<String, dynamic>>> searchCompanyCustomers(
    String query,
  ) async {
    final isPhoneSearch = RegExp(r'^[0-9+\-\s()]+$').hasMatch(query.trim());
    final response = await _dio.post(
      ApiEndpoints.searchCustomers,
      data: {
        ...(isPhoneSearch ? {'phone': query} : {'name': query}),
        'customer_type': 'Company',
      },
    );
    final raw = _unwrap(response);
    return (raw as List? ?? const []).cast<Map<String, dynamic>>();
  }
}
