import 'report_json.dart';

/// One row of `jarz_pos.api.segmentation.get_segment_summary` — a segment name
/// (an RFM bucket) and how many active customers hold it.
///
/// The server also sends [pseudo] rows such as `{segment: "Regular", count,
/// pseudo: 1}`: an overlay (customers flagged regular, whatever their RFM
/// bucket), so their count overlaps the real segments and must not be added
/// into a total. `export_segment("Regular")` still lists them.
class SegmentSummaryRow {
  final String segment;
  final int count;
  final bool pseudo;

  const SegmentSummaryRow({
    required this.segment,
    required this.count,
    this.pseudo = false,
  });

  factory SegmentSummaryRow.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final rawPseudo = json['pseudo'];
    return SegmentSummaryRow(
      segment: (json['segment'] ?? '').toString(),
      count: rawCount is num
          ? rawCount.toInt()
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      pseudo: rawPseudo is bool
          ? rawPseudo
          : rawPseudo is num
              ? rawPseudo != 0
              : const {'1', 'true'}
                  .contains(rawPseudo?.toString().trim().toLowerCase()),
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
