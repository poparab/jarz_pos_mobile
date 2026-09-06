import 'report_json.dart';

/// One row of `jarz_pos.api.segmentation.get_segment_summary` — a segment name
/// (RFM bucket, or "Unclassified") and how many active customers hold it.
class SegmentSummaryRow {
  final String segment;
  final int count;

  const SegmentSummaryRow({required this.segment, required this.count});

  factory SegmentSummaryRow.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    return SegmentSummaryRow(
      segment: (json['segment'] ?? '').toString(),
      count: rawCount is num
          ? rawCount.toInt()
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
    );
  }
}

/// A row of `jarz_pos.api.segmentation.export_segment(segment)`. Kept as a
/// [JsonMap] (not a dedicated class) to match the loosely-typed row pattern
/// used across the reports feature — its shape is read defensively wherever
/// it is rendered.
///
/// Fields (from `services/rfm_segmentation.export_segment_csv`): customer_id,
/// customer_name, mobile_no, territory, customer_segment, rfm_recency_days,
/// rfm_frequency_count, rfm_avg_order_value, segment_updated_on.
typedef SegmentCustomerRow = JsonMap;

List<JsonMap> parseSegmentRows(dynamic value) {
  if (value is! List) return const <JsonMap>[];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}
