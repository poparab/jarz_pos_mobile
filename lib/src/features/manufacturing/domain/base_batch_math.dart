/// Batch arithmetic for the Bases tab.
///
/// Pure functions with no Flutter, no Riverpod and no models, so the numbers
/// the floor acts on are unit-testable on their own. The rule the whole tab is
/// built around: **the mixer is the unit of work**, and `batchYield` is the one
/// bridge back to a stock quantity.
library;

/// The mixer runs in halves, so every batch figure the tab produces lands on a
/// multiple of this.
const double kBatchStep = 0.5;

/// The smallest run the tab will submit. Below half a batch the mixer cannot
/// hold the mix against its blades.
const double kMinBatches = 0.5;

/// The largest run the stepper reaches. Not a business rule — a guard so a
/// fat-fingered long-press cannot queue 400 batches.
const double kMaxBatches = 40.0;

/// Tolerance for comparing batch figures.
///
/// Halves are exact in binary, but a figure that arrived over JSON, or came out
/// of a division, is not: 3.5 can present as 3.5000000000000004.
const double kBatchEpsilon = 1e-6;

/// Rounds to the nearest half batch.
double snapToHalf(double value) =>
    (value / kBatchStep).roundToDouble() * kBatchStep;

/// Rounds *up* to the next half batch — what a demand figure becomes when it is
/// offered as a run: 3.2 batches of demand needs 3.5 batches of mixing.
double snapUpToHalf(double value) =>
    (value / kBatchStep).ceilToDouble() * kBatchStep;

/// Rounds *down* to a half batch — what a capacity figure becomes: materials
/// covering 2.9 batches means 2.5 can actually be run.
double snapDownToHalf(double value) =>
    (value / kBatchStep).floorToDouble() * kBatchStep;

/// Holds a batch count inside what the tab will submit.
double clampBatches(double value) {
  if (value.isNaN) return kMinBatches;
  return value.clamp(kMinBatches, kMaxBatches).toDouble();
}

/// Moves the stepper by [delta] and lands the result back on the half-batch
/// grid, so repeated taps can never drift off it.
double stepBatches(double current, double delta) =>
    clampBatches(snapToHalf(current + delta));

/// What a run of [batches] produces, in the item's stock UOM.
///
/// This is the number that goes to `start_production_batch` as `item_qty` —
/// the backend takes a quantity, the operator thinks in batches, and this is
/// the only place the two are converted.
double itemQtyForBatches(double batches, double batchYield) =>
    batches * _safeYield(batchYield);

/// The inverse: how many batches a stock quantity is worth. Used to read
/// freezer stock back as "1.8 batches on hand".
double batchesForQty(double qty, double batchYield) =>
    qty / _safeYield(batchYield);

/// Whether [batches] sits on one of the mixer's published run sizes.
///
/// An empty or absent list means the backend published no grid, in which case
/// every figure is on-grid — the warning must not fire just because the server
/// declined to answer.
bool isRunSizeOk(double batches, List<double>? runSizes) {
  if (runSizes == null || runSizes.isEmpty) return true;
  return runSizes.any((size) => (size - batches).abs() <= kBatchEpsilon);
}

/// The published run size nearest to [batches], for the "did you mean" offer
/// beside an off-grid warning. Null when no grid was published.
double? nearestRunSize(double batches, List<double>? runSizes) {
  if (runSizes == null || runSizes.isEmpty) return null;

  double? best;
  var bestDistance = double.infinity;
  for (final size in runSizes) {
    final distance = (size - batches).abs();
    // Strictly less, so a tie between two equidistant sizes resolves to the
    // first one listed rather than depending on iteration order twice.
    if (distance < bestDistance) {
      bestDistance = distance;
      best = size;
    }
  }
  return best;
}

/// The largest half-batch run the warehouse can actually cover.
///
/// [components] are `(requiredQty, availableQty)` pairs taken from a preview
/// computed at [batches] — so the per-batch requirement has to be recovered by
/// dividing before the ratio means anything.
///
/// Returns 0 when nothing can be run, and [batches] itself when no component
/// constrains the run (a BOM whose lines are all zero-qty, which happens on
/// half-migrated BOMs).
double achievableBatchesFor(
  double batches,
  List<(double required, double available)> components,
) {
  if (batches <= 0) return 0;

  var limit = double.infinity;
  for (final (required, available) in components) {
    // A zero-qty line cannot constrain anything, and dividing by it would make
    // every run look impossible.
    if (required <= 0) continue;
    final perBatch = required / batches;
    final possible = available / perBatch;
    if (possible < limit) limit = possible;
  }

  if (limit == double.infinity) return batches;
  if (limit <= 0) return 0;

  // The ratio is a division of two doubles, so an exact 3.0 can present as
  // 2.9999999999999996 and snap down to 2.5 — a whole half batch lost to
  // floating point. Nudged by a relative epsilon before snapping.
  final nudged = limit + limit.abs() * kBatchEpsilon;
  final snapped = snapDownToHalf(nudged);
  return snapped < 0 ? 0 : snapped;
}

double _safeYield(double batchYield) => batchYield > 0 ? batchYield : 1.0;
