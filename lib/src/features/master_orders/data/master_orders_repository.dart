import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final masterOrdersRepositoryProvider = Provider<MasterOrdersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MasterOrdersRepository(dio);
});

class MasterOrdersRepository {
  final Dio _dio;
  MasterOrdersRepository(this._dio);

  Future<Map<String, dynamic>> fetchOrders({
    String? search,
    String? status,
    String? branch,
    String? fromDate,
    String? toDate,
    String? paymentStatus,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getMasterOrders,
      data: {
        'search': search,
        'status': status,
        'branch': branch,
        'from_date': fromDate,
        'to_date': toDate,
        'payment_status': paymentStatus,
        'page': page,
        'page_size': pageSize,
      },
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
