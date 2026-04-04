import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepository(dio);
});

class ReportsRepository {
  final Dio _dio;
  ReportsRepository(this._dio);

  Future<Map<String, dynamic>> fetchFinalProductsReport() async {
    final response = await _dio.post(
      ApiEndpoints.getFinalProductsReport,
      data: {},
    );
    final data = response.data;
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Unexpected response format');
  }

  Future<Map<String, dynamic>> fetchMaterialsReport() async {
    final response = await _dio.post(
      ApiEndpoints.getMaterialsReport,
      data: {},
    );
    final data = response.data;
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Unexpected response format');
  }
}
