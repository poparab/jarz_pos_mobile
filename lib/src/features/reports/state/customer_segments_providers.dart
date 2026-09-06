import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/customer_segments_repository.dart';
import '../data/models/customer_segments.dart';
import '../data/models/report_json.dart';

/// Customer counts per RFM segment. Hand-written `FutureProvider` — no
/// `@riverpod` codegen in this feature. Refresh via
/// `ref.invalidate(segmentSummaryProvider)`.
final segmentSummaryProvider =
    FutureProvider.autoDispose<List<SegmentSummaryRow>>((ref) async {
  final repo = ref.watch(customerSegmentsRepositoryProvider);
  return repo.fetchSegmentSummary();
});

/// Every customer currently in one segment, keyed by segment name.
final segmentCustomersProvider = FutureProvider.autoDispose
    .family<List<SegmentCustomerRow>, String>((ref, segment) async {
  final repo = ref.watch(customerSegmentsRepositoryProvider);
  return repo.exportSegment(segment);
});

/// Re-exported so screens only need this one import for row typing.
typedef SegmentRow = JsonMap;
