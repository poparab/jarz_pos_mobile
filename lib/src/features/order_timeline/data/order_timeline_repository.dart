import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'order_timeline.dart';

final orderTimelineRepositoryProvider = Provider<OrderTimelineRepository>((
  ref,
) {
  return OrderTimelineRepository(ref.watch(dioProvider));
});

/// `jarz_courier.api.timeline.get_order_timeline` — the delivery timeline of
/// one invoice. Lives in the courier app, so a site without it (404) or a user
/// without the courier-map role (403) is a normal "nothing to show" answer, not
/// an error: [getTimeline] returns null for both.
class OrderTimelineRepository {
  OrderTimelineRepository(this._dio);

  final Dio _dio;

  Future<OrderTimeline?> getTimeline(String invoiceId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getOrderTimeline,
        data: {'invoice_id': invoiceId},
      );
      final data = response.data;
      final message = data is Map && data.containsKey('message')
          ? data['message']
          : data;
      if (message is! Map) return null;
      return OrderTimeline.fromJson(Map<String, dynamic>.from(message));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) return null;
      rethrow;
    }
  }
}
