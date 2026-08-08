import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/lead.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LeadsRepository(dio);
});

/// HTTP repository for the Leads research feature (`jarz_pos.api.leads.*`).
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the B2B repository.
class LeadsRepository {
  final Dio _dio;
  LeadsRepository(this._dio);

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

  /// Fetches the lightweight lead catalog, optionally scoped by category/status.
  Future<List<Lead>> getLeads({String? category, String? status}) async {
    final response = await _dio.post(
      ApiEndpoints.getLeads,
      data: {
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    final payload = _asMap(_unwrap(response));
    final raw = (payload['leads'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Lead.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetches the full detail (branches + addresses + notes) for one lead.
  Future<Lead> getLead(String name) async {
    final response = await _dio.post(ApiEndpoints.getLead, data: {'name': name});
    return Lead.fromJson(_asMap(_unwrap(response)));
  }

  /// Creates or updates a lead. Pass [name] to update an existing one.
  /// Returns the server-assigned `name`.
  Future<String> saveLead(
    Map<String, dynamic> payload, {
    String? name,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.saveLead,
      data: {
        'payload': payload,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      },
    );
    final result = _asMap(_unwrap(response));
    return (result['name'] ?? '').toString();
  }

  /// Sets a lead's primary or shipping address. Returns the address `name`.
  Future<String> setLeadAddress({
    required String name,
    required String kind, // 'primary' | 'shipping'
    required LeadAddress address,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.setLeadAddress,
      data: {
        'name': name,
        'kind': kind,
        'address': address.toJson(),
      },
    );
    final result = _asMap(_unwrap(response));
    return (result['address'] ?? '').toString();
  }

  /// Fetches the canonical "why is this prospect not suitable" reasons. The
  /// backend owns the list (it reads the live Select options), so the app never
  /// hard-codes its own copy.
  Future<List<String>> getNotSuitableReasons() async {
    final response =
        await _dio.post(ApiEndpoints.getNotSuitableReasons, data: {});
    final payload = _asMap(_unwrap(response));
    final raw = (payload['reasons'] as List?) ?? const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  /// Marks a lead not suitable after manual inspection, or clears the verdict.
  ///
  /// [reason] is required when marking and must be one of
  /// [getNotSuitableReasons]. Returns the refreshed catalog row.
  Future<Lead> setLeadSuitability({
    required String name,
    required bool notSuitable,
    String? reason,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.setLeadSuitability,
      data: {
        'name': name,
        'not_suitable': notSuitable ? 1 : 0,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    final result = _asMap(_unwrap(response));
    return Lead.fromJson(Map<String, dynamic>.from(result['lead'] as Map));
  }

  /// Possible duplicates of [name]. With no [query] the backend suggests
  /// matches on brand name / phone / Instagram / website; with a [query] it is
  /// a plain name search for the duplicate the heuristics miss.
  Future<List<LeadMergeCandidate>> getMergeCandidates({
    required String name,
    String? query,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getMergeCandidates,
      data: {
        'name': name,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    final payload = _asMap(_unwrap(response));
    final raw = (payload['candidates'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => LeadMergeCandidate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Folds [sources] into [name] as duplicates of the same brand. Returns the
  /// refreshed surviving lead.
  Future<Lead> mergeLeads({
    required String name,
    required List<String> sources,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.mergeLeads,
      // Sent as a JSON string: Frappe delivers list args that way anyway, and
      // being explicit avoids Dio's form-encoding flattening it to `a,b`.
      data: {'target': name, 'sources': jsonEncode(sources)},
    );
    final result = _asMap(_unwrap(response));
    return Lead.fromJson(Map<String, dynamic>.from(result['lead'] as Map));
  }

  /// Fetches the list of lead categories.
  Future<List<LeadCategory>> getLeadCategories() async {
    final response =
        await _dio.post(ApiEndpoints.getLeadCategories, data: {});
    final payload = _asMap(_unwrap(response));
    final raw = (payload['categories'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => LeadCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Creates a new lead category. Returns the created `{name, categoryName}`.
  Future<LeadCategory> saveLeadCategory({
    required String categoryName,
    String? color,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.saveLeadCategory,
      data: {
        'category_name': categoryName,
        if (color != null && color.trim().isNotEmpty) 'color': color.trim(),
      },
    );
    final result = _asMap(_unwrap(response));
    return LeadCategory(
      name: (result['name'] ?? categoryName).toString(),
      categoryName: (result['category_name'] ?? categoryName).toString(),
      color: color,
    );
  }
}
