import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/customer_segments.dart';
import 'models/report_json.dart';

final customerSegmentsRepositoryProvider =
    Provider<CustomerSegmentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerSegmentsRepository(dio);
});

/// Talks to the four `jarz_pos.api.segmentation` endpoints backing the
/// Customer Segments (RFM) dashboard. `get_segment_summary` and
/// `export_segment` both return a bare LIST (not a dict), so the envelope
/// unwrap here is list-shaped rather than the map-shaped one every other
/// reports repository uses — with the same bare-payload fallback.
class CustomerSegmentsRepository {
  final Dio _dio;
  CustomerSegmentsRepository(this._dio);

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

  List<JsonMap> _asList(Response response) {
    final data = response.data;
    if (data is Map && data['message'] is List) {
      return parseSegmentRows(data['message']);
    }
    if (data is List) {
      return parseSegmentRows(data);
    }
    return const <JsonMap>[];
  }

  /// `segmentation.get_segment_summary` — customer count per segment.
  Future<List<SegmentSummaryRow>> fetchSegmentSummary() async {
    final response = await _dio.post(ApiEndpoints.segmentSummary, data: {});
    return _asList(response)
        .map(SegmentSummaryRow.fromJson)
        .toList(growable: false);
  }

  /// `segmentation.export_segment` — every customer currently in [segment],
  /// for the in-app export view (this app never assumes a file download
  /// works, since it also runs on web).
  Future<List<SegmentCustomerRow>> exportSegment(String segment) async {
    final response = await _dio.post(
      ApiEndpoints.segmentExport,
      data: {'segment': segment},
    );
    return _asList(response);
  }

  /// `segmentation.run_segmentation_now` — manager-only, recalculates RFM
  /// segments for every customer (pinned customers are skipped). Returns the
  /// raw `{updated, skipped_override, total_customers}` payload.
  Future<Map<String, dynamic>> runSegmentationNow() async {
    final response = await _dio.post(ApiEndpoints.segmentRunNow, data: {});
    return _asMap(response);
  }

  /// `segmentation.set_segment_override` — pins or unpins a customer's
  /// segment. Pinning without [manualSegment] leaves `customer_segment`
  /// untouched (pins whatever it currently is); passing it also sets a new
  /// value in the same call.
  Future<void> setSegmentOverride({
    required String customer,
    required bool override,
    String? manualSegment,
  }) async {
    await _dio.post(
      ApiEndpoints.segmentSetOverride,
      data: {
        'customer': customer,
        'override': override ? 1 : 0,
        if (manualSegment != null) 'manual_segment': manualSegment,
      },
    );
  }
}
