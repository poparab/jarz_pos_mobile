import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/velocity_alerts_repository.dart';
import '../data/models/velocity_alerts.dart';

/// The current reorder/velocity alert summary. Hand-written `FutureProvider`
/// — this feature (like the rest of `reports/`) does not use `@riverpod`
/// codegen. Refresh via `ref.invalidate(velocityAlertSummaryProvider)`.
final velocityAlertSummaryProvider =
    FutureProvider.autoDispose<VelocityAlertSummary>((ref) async {
  final repo = ref.watch(velocityAlertsRepositoryProvider);
  return repo.fetchAlertSummary();
});

/// Velocity detail for a single item, keyed by item code.
final itemVelocityDetailProvider = FutureProvider.autoDispose
    .family<ItemVelocityDetail, String>((ref, itemCode) async {
  final repo = ref.watch(velocityAlertsRepositoryProvider);
  return repo.fetchItemVelocity(itemCode);
});
