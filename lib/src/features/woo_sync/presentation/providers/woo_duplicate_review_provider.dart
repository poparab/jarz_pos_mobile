import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/woo_duplicate_group.dart';
import '../../data/repositories/woo_sync_repository.dart';

/// Read-only: the duplicate-phone groups the dedupe autopilot refused to
/// auto-merge. `autoDispose` so a stale triage list is never shown after the
/// screen is reopened — an administrator may have merged a group elsewhere
/// between visits.
final wooDuplicateReviewProvider =
    FutureProvider.autoDispose<List<WooDuplicateGroup>>((ref) {
  final repo = ref.watch(wooSyncRepositoryProvider);
  return repo.getDuplicateReview();
});
