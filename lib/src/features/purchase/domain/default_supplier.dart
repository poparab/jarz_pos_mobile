/// Which supplier a purchase bought from requests should start on.
///
/// Buying from requests filled the cart but never chose a supplier, and the
/// submit button stays disabled without one — so the buyer was left with a
/// full cart they could not submit. Starting on whoever last billed these
/// items is what the buyer would pick by hand almost every time.
library;

/// The supplier most of [lastSuppliers] were last bought from; on a tie, the
/// one that appears first. Blank entries (items never bought) are ignored.
/// Returns null when none of the items has been bought before.
String? defaultSupplierFor(Iterable<String?> lastSuppliers) {
  final counts = <String, int>{};
  for (final raw in lastSuppliers) {
    final name = raw?.trim() ?? '';
    if (name.isEmpty) continue;
    counts[name] = (counts[name] ?? 0) + 1;
  }
  String? best;
  var bestCount = 0;
  // Map iteration keeps insertion order, so a strict ">" keeps the first on a tie.
  counts.forEach((name, count) {
    if (count > bestCount) {
      best = name;
      bestCount = count;
    }
  });
  return best;
}
