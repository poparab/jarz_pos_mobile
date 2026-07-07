import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/shipping_analytics.dart';
import 'models/inventory_intelligence.dart';
import 'models/product_analytics.dart';
import 'models/customer_analytics.dart';
import 'models/executive_overview.dart';
import 'models/b2b_sales_clients.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepository(dio);
});

class ReportsRepository {
  final Dio _dio;
  ReportsRepository(this._dio);

  /// Unwraps Frappe's `{ "message": ... }` envelope down to a Map.
  Map<String, dynamic> _asMap(Response response) {
    final data = response.data;
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return const <String, dynamic>{};
  }

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

  // ── Analytics dashboards ────────────────────────────────────────────────

  /// Shipping Analytics. NOTE: this endpoint uses `from_date` / `to_date`
  /// (all other analytics endpoints use `date_from` / `date_to`).
  Future<ShippingAnalytics> fetchShippingAnalytics({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getShippingAnalytics,
      data: {'from_date': fromDate, 'to_date': toDate},
    );
    return ShippingAnalytics.fromJson(_asMap(response));
  }

  Future<InventoryIntelligence> fetchInventoryIntelligence({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getInventoryAnalytics,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );
    return InventoryIntelligence.fromJson(_asMap(response));
  }

  Future<ProductAnalytics> fetchProductAnalytics({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getProductAnalytics,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );
    return ProductAnalytics.fromJson(_asMap(response));
  }

  Future<CustomerAnalytics> fetchCustomerAnalytics({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getCustomerAnalytics,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );
    return CustomerAnalytics.fromJson(_asMap(response));
  }

  Future<ExecutiveOverview> fetchExecutiveOverview({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getExecutiveOverview,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );
    return ExecutiveOverview.fromJson(_asMap(response));
  }

  Future<B2bSalesAnalytics> fetchB2bSalesClients({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getB2bAnalytics,
      data: {'date_from': dateFrom, 'date_to': dateTo},
    );
    return B2bSalesAnalytics.fromJson(_asMap(response));
  }
}
