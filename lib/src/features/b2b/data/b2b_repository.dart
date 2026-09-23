import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/b2b_account_labels.dart';
import 'models/b2b_models.dart';

final b2bRepositoryProvider = Provider<B2bRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return B2bRepository(dio);
});

/// Lead Source name strings for the lead-add Source dropdown.
final b2bLeadSourcesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(b2bRepositoryProvider).getLeadSources();
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

  Future<B2bAccountDetail> getAccount({
    required String doctype,
    required String name,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getB2bAccount,
      data: {'doctype': doctype, 'name': name},
    );
    final payload = _asMap(_unwrap(response));
    // `labels` is parsed OFF the Freezed model on purpose: it is nullable,
    // absent on older backends, and hand-coerced — see b2b_account_labels.dart.
    return B2bAccountDetail(
      account: B2bAccount.fromJson(payload),
      labels: B2bAccountLabels.tryParse(payload['labels']),
    );
  }

  /// Advances a card to [stage]. Returns the server-confirmed
  /// `{doctype, name, stage}`.
  Future<B2bCard> advanceStage({
    required String doctype,
    required String name,
    required String stage,
    String? reason,
    String? followUpDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bAdvanceStage,
      data: {
        'doctype': doctype,
        'name': name,
        'stage': stage,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (followUpDate != null && followUpDate.trim().isNotEmpty)
          'follow_up_date': followUpDate.trim(),
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

  /// Returns the list of Lead Source name strings for the source dropdown.
  Future<List<String>> getLeadSources() async {
    final response = await _dio.post(ApiEndpoints.getLeadSources, data: {});
    final raw = _unwrap(response);
    return (raw as List? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Marks a follow-up as done: closes the reminder loop so it stops being
  /// regenerated daily. [doctype]/[name] come from the ToDo's reference.
  Future<void> completeFollowup({
    required String doctype,
    required String name,
  }) async {
    await _dio.post(
      ApiEndpoints.completeFollowup,
      data: {'doctype': doctype, 'name': name},
    );
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
    String? shippingAddressName,
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
        shippingAddressName: shippingAddressName,
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
    String? shippingAddressName,
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
        shippingAddressName: shippingAddressName,
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
    String? shippingAddressName,
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
      if (shippingAddressName != null && shippingAddressName.trim().isNotEmpty)
        'shipping_address_name': shippingAddressName.trim(),
    };
  }

  /// The `branch` filter value selecting invoices that match no branch.
  static const unassignedBranch = '__unassigned__';

  /// An account's invoices, all order purposes included. [branch] is a
  /// branch's `address_name`, [unassignedBranch], or null for every invoice.
  Future<B2bAccountInvoices> getAccountInvoices({
    required String doctype,
    required String name,
    String? branch,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.getB2bAccountInvoices,
      queryParameters: {
        'doctype': doctype,
        'name': name,
        if (branch != null && branch.trim().isNotEmpty) 'branch': branch.trim(),
        'limit': limit,
      },
    );
    return B2bAccountInvoices.fromJson(_asMap(_unwrap(response)));
  }

  /// Accounts [name] could be merged with as a branch (Leads and Customers).
  Future<List<B2bMergeCandidate>> searchMergeTargets({
    required String doctype,
    required String name,
    String? query,
    int limit = 20,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bSearchMergeTargets,
      data: {
        'doctype': doctype,
        'name': name,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        'limit': limit,
      },
    );
    final raw = _unwrap(response);
    final list = raw is Map ? raw['candidates'] : raw;
    return (list as List? ?? const [])
        .whereType<Map>()
        .map((e) => B2bMergeCandidate.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  /// Dry run of [mergeAsBranch]: what would move, and whether this user may.
  Future<B2bMergePreview> previewMergeAsBranch({
    required String sourceDoctype,
    required String sourceName,
    required String targetDoctype,
    required String targetName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bPreviewMergeAsBranch,
      data: {
        'source_doctype': sourceDoctype,
        'source_name': sourceName,
        'target_doctype': targetDoctype,
        'target_name': targetName,
      },
    );
    return B2bMergePreview.fromJson(_asMap(_unwrap(response)));
  }

  /// Folds the source account into the target as one of its branches.
  /// A Customer-into-Customer merge is irreversible and manager-only.
  Future<B2bMergeResult> mergeAsBranch({
    required String sourceDoctype,
    required String sourceName,
    required String targetDoctype,
    required String targetName,
    String? branchName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bMergeAsBranch,
      data: {
        'source_doctype': sourceDoctype,
        'source_name': sourceName,
        'target_doctype': targetDoctype,
        'target_name': targetName,
        if (branchName != null && branchName.trim().isNotEmpty)
          'branch_name': branchName.trim(),
      },
    );
    final raw = _unwrap(response);
    return B2bMergeResult.fromJson(
      raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
      fallbackDoctype: targetDoctype,
      fallbackName: targetName,
    );
  }

  /// Pairs the Google Maps branch [mapsRow] of the account's Lead with the
  /// delivery branch [addressName]. A null / blank [addressName] unlinks the
  /// row, which also stops the server auto-matching it. Returns the account's
  /// unified branch list after the change.
  Future<B2bBranchLinkResult> linkBranch({
    required String doctype,
    required String name,
    required String mapsRow,
    String? addressName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bLinkBranch,
      data: {
        'doctype': doctype,
        'name': name,
        'maps_row': mapsRow,
        if (addressName != null && addressName.trim().isNotEmpty)
          'address_name': addressName.trim(),
      },
    );
    final raw = _unwrap(response);
    return B2bBranchLinkResult.fromJson(
      raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );
  }

  /// Searches every enabled Customer type/group that may legitimately back a
  /// B2B account. Linking never mutates the Customer classification.
  Future<List<Map<String, dynamic>>> searchLinkableCustomers(
    String query, {
    int limit = 20,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bSearchLinkableCustomers,
      data: {'query': query.trim(), 'limit': limit},
    );
    final raw = _unwrap(response);
    return (raw as List? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> linkExistingCustomer({
    required String partyDoctype,
    required String partyName,
    required String customer,
    String? expectedCustomer,
    bool allowRelink = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.b2bLinkExistingCustomer,
      data: {
        'party_doctype': partyDoctype,
        'party_name': partyName,
        'customer': customer,
        if (expectedCustomer != null && expectedCustomer.trim().isNotEmpty)
          'expected_customer': expectedCustomer.trim(),
        'allow_relink': allowRelink ? 1 : 0,
      },
    );
    return _asMap(_unwrap(response));
  }
}
