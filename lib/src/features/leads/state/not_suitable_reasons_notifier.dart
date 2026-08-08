import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leads_repository.dart';

/// Fallback reasons used when the backend list cannot be fetched (offline, or a
/// site that has not migrated the `custom_not_suitable_reason` field yet).
/// Mirrors `NOT_SUITABLE_REASONS` in `jarz_pos/api/leads.py`; the server list
/// always wins when it is reachable.
const kFallbackNotSuitableReasons = <String>[
  'Out of Business',
  'Wrong Category',
  'Too Small',
  'No Contact Info',
  'Unreachable',
  'Already Supplied',
  'Price Mismatch',
  'Outside Delivery Area',
  'Duplicate',
  'Not Interested',
  'Other',
];

/// The canonical not-suitable reasons for the disqualify dialog. Never fails:
/// a network error degrades to [kFallbackNotSuitableReasons] so a rep can still
/// record a verdict, and the server rejects anything it does not recognise.
final notSuitableReasonsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final reasons = await ref.read(leadsRepositoryProvider).getNotSuitableReasons();
    if (reasons.isNotEmpty) return reasons;
  } catch (_) {
    // Fall through to the bundled list.
  }
  return kFallbackNotSuitableReasons;
});
