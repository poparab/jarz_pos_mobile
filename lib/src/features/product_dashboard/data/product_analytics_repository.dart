import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'product_analytics_models.dart';

final productAnalyticsRepositoryProvider =
    Provider<ProductAnalyticsRepository>((ref) {
  return ProductAnalyticsRepository(ref.watch(dioProvider));
});

class ProductAnalyticsRepository {
  final Dio _dio;
  ProductAnalyticsRepository(this._dio);

  Future<ProductAnalyticsData> fetchAnalytics({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getProductAnalytics,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );

    final raw = response.data;
    final payload = raw is Map && raw['message'] is Map
        ? Map<String, dynamic>.from(raw['message'] as Map)
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};

    return ProductAnalyticsData.fromJson(payload);
  }
}
