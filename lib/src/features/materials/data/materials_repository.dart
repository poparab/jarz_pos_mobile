import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/sales_material.dart';

final materialsRepositoryProvider = Provider<MaterialsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MaterialsRepository(dio);
});

/// HTTP repository for sales-material sharing (`jarz_pos.api.materials.*`).
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the leads and journey repositories.
class MaterialsRepository {
  final Dio _dio;
  MaterialsRepository(this._dio);

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'];
    }
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  /// The library plus the message template, in one round trip.
  Future<MaterialLibrary> getLibrary() async {
    final response = await _dio.post(ApiEndpoints.getSalesMaterials, data: {});
    return MaterialLibrary.fromJson(_asMap(_unwrap(response)));
  }

  /// Mints one share link and the WhatsApp deep link that carries it.
  ///
  /// [message] is the rep's edited text and should still contain the library's
  /// link placeholder; the server substitutes it after the row (and therefore
  /// the URL) exists. A message that lost the placeholder gets the URL
  /// appended server-side rather than being sent without one.
  Future<MaterialShare> createShare({
    required String referenceName,
    required List<String> materials,
    String referenceDoctype = 'Lead',
    String? contactName,
    String? contactPhone,
    String? message,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createMaterialShare,
      // Sent as a JSON string for the same reason as mergeLeads: Dio would
      // otherwise form-encode the list into repeated keys, which Frappe
      // flattens to the LAST value only — so a five-material pack would
      // silently become one.
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'materials': jsonEncode(materials),
        if (contactName != null && contactName.trim().isNotEmpty)
          'contact_name': contactName.trim(),
        if (contactPhone != null && contactPhone.trim().isNotEmpty)
          'contact_phone': contactPhone.trim(),
        if (message != null && message.trim().isNotEmpty) 'message': message,
      },
    );
    return MaterialShare.fromJson(_asMap(_unwrap(response)));
  }

  /// What has already been sent to this record, newest first.
  Future<List<MaterialShareSummary>> getShares({
    required String referenceName,
    String referenceDoctype = 'Lead',
    int limit = 20,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getMaterialShares,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'limit': limit,
      },
    );
    final payload = _asMap(_unwrap(response));
    final raw = (payload['shares'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => MaterialShareSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
