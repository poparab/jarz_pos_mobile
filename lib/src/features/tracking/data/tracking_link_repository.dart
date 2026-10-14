import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'tracking_link.dart';

final trackingLinkRepositoryProvider = Provider<TrackingLinkRepository>((ref) {
  return TrackingLinkRepository(ref.watch(dioProvider));
});

/// `jarz_pos.api.tracking.get_tracking_link` — the customer's public tracking
/// link (and delivery code) for one invoice, for staff to send.
class TrackingLinkRepository {
  TrackingLinkRepository(this._dio);

  final Dio _dio;

  Future<TrackingLink> getTrackingLink(String invoiceId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getTrackingLink,
        data: {'invoice_id': invoiceId},
      );
      final data = response.data;
      final message = data is Map && data.containsKey('message')
          ? data['message']
          : data;
      if (message is! Map) {
        throw Exception('Failed to get the tracking link');
      }
      final link = TrackingLink.fromJson(Map<String, dynamic>.from(message));
      if (link.url.isEmpty) throw Exception('Failed to get the tracking link');
      return link;
    } on DioException catch (e) {
      throw mapFrappeError(e, fallback: 'Failed to get the tracking link');
    }
  }
}
