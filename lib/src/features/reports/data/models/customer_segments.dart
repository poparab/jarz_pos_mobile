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

/// Pseudo (overlay) segments the summary adds on top of the RFM buckets.
/// Their membership overlaps real segments, so they are never a valid
/// `manual_segment` for a pin.
const kPseudoSegmentNames = {'regular', 'regulars'};

/// True when [segment] is an overlay rather than a real RFM bucket: listed
/// in [kPseudoSegmentNames] or flagged `pseudo` by the server in
/// [pseudoSegments].
bool isPseudoSegment(
  String? segment, {
  Iterable<String> pseudoSegments = const [],
}) {
  final key = segment?.trim().toLowerCase() ?? '';
  if (key.isEmpty) return false;
  if (kPseudoSegmentNames.contains(key)) return true;
  return pseudoSegments.any((p) => p.trim().toLowerCase() == key);
}

/// The `manual_segment` to send when pinning a customer whose current RFM
/// segment is [currentSegment], or null to let the server pin whatever
/// segment the customer holds now. Never returns a blank or pseudo segment
/// (the server rejects "Regular" as a manual segment).
String? manualSegmentForPin(
  String? currentSegment, {
  Iterable<String> pseudoSegments = const [],
}) {
  final s = currentSegment?.trim() ?? '';
  if (s.isEmpty) return null;
  if (isPseudoSegment(s, pseudoSegments: pseudoSegments)) return null;
  return s;
}
