/// How a run of a base is entered, in the unit the floor actually uses.
///
/// [base_batch_math] converts between batches and stock quantity and assumes
/// the mixer is always the unit of work. It is not: a cake is counted in eggs
/// and a mix is weighed, and this library holds the arithmetic for both. Pure
/// functions with no Flutter, no Riverpod and no models, so the numbers the
/// floor acts on are testable on their own.
library;

/// Quantities are carried to the gram. Three decimals is what the mix recipes
/// need (a jar takes 0.030 Kg) and one more than the server renders, so a
/// rounding here can never disagree with the preview it is checked against.
const int kQtyDecimals = 3;

/// Below a gram is float noise, not a quantity anybody can weigh out.
const double kQtyEpsilon = 5e-4;

/// The smallest run this screen will submit, in stock UOM.
///
/// A gram of blueberry mix is not a batch, it is a typo. Deliberately far below
/// anything real so it never refuses a genuine small top-up.
const double kMinQty = 0.001;

/// Rounds a quantity to the gram.
///
/// Every quantity that reaches a field, a chip or a submit goes through here:
/// `40 * 0.03 + 20 * 0.04` lands on `2.0000000000000004`, and a field that
/// renders those extra digits reads as a broken calculator.
double roundQty(double value) {
  if (value.isNaN || value.isInfinite) return 0;
  final factor = _pow10(kQtyDecimals);
  return (value * factor).roundToDouble() / factor;
}

/// Rounds a quantity **up** to the next [step].
///
/// What a requirement becomes when it is offered as a run: needing 1.42 Kg of
/// mix and offering "make 1.42" sends somebody to weigh out a figure nobody
/// would choose. Offering 1.5 matches how a tub is actually filled.
double roundQtyUpTo(double value, double step) {
  if (step <= 0) return roundQty(value);
  if (value <= 0) return 0;
  // The nudge matters for the same reason it does in `achievableBatchesFor`:
  // an exact 2.0 arriving as 2.0000000000000004 would otherwise round up to
  // 2.5 and ask for half a tub nobody needs.
  final nudged = value - value.abs() * 1e-9;
  return roundQty((nudged / step).ceilToDouble() * step);
}

/// What a set of jar counts takes out of the freezer, in the base's stock UOM.
///
/// [counts] is `{jar item code: how many jars}` and [perJar] is
/// `{jar item code: how much of this base one jar takes}`. Only jars present in
/// [perJar] contribute: a count for something nobody lists is ignored rather
/// than guessed at, the same rule the server applies when deriving demand.
///
/// Negative counts contribute nothing. A jar whose count somebody cleared to
/// `-3` must never subtract the mix another jar genuinely needs.
double qtyForJarCounts(Map<String, int> counts, Map<String, double> perJar) {
  var total = 0.0;
  for (final entry in counts.entries) {
    final rate = perJar[entry.key];
    if (rate == null || rate <= 0) continue;
    if (entry.value <= 0) continue;
    total += entry.value * rate;
  }
  return roundQty(total);
}

/// Whole jars a quantity of base fills.
///
/// Floors, because a jar is either filled or it is not. The nudge is the same
/// guard `cover_suggested_batches` uses server-side: `0.06 / 0.03` can land on
/// `1.9999999999999998`, and flooring that loses a real jar.
int jarsFromQty(double qty, double perJar) {
  if (perJar <= 0 || qty <= 0) return 0;
  final ratio = qty / perJar;
  return (ratio + ratio.abs() * 1e-9).floor();
}

/// What is still to be made: the requirement less what is already in the store.
///
/// Freezer stock is floored at zero first. A negative `Bin` is a counting lag,
/// and letting it through would add a phantom hole on top of a real
/// requirement — the error that put 81 invented batches on the jar board.
double qtyStillNeeded({required double required, required double onHand}) {
  final have = onHand > 0 ? onHand : 0.0;
  final gap = required - have;
  return gap <= kQtyEpsilon ? 0 : roundQty(gap);
}

/// Holds a typed quantity inside what the screen will submit.
///
/// [max] is the largest run its materials could cover, when that is known; a
/// null or non-positive [max] means nobody worked one out, which is not the
/// same as "nothing is possible" and must not clamp to zero.
double clampQty(double value, {double? max}) {
  if (value.isNaN) return 0;
  var next = value < 0 ? 0.0 : value;
  if (max != null && max > 0 && next > max) next = max;
  return roundQty(next);
}

/// Nice round steps a weighed quantity is nudged by, largest last.
const List<double> kQtyStepLadder = <double>[0.05, 0.1, 0.25, 0.5, 1.0];

/// The step the +/- buttons move a weighed base by.
///
/// Derived from the recipe rather than fixed: a quarter of what the recipe makes
/// is about the smallest amount worth walking to the mixer for, and it lands on
/// a figure somebody would actually say out loud. Blueberry mix makes 2 Kg, so
/// it steps by 0.5; ganache makes 5.9 and steps by 1.
double niceQtyStep(double batchYield) {
  final quarter = batchYield > 0 ? batchYield / 4 : 0.0;
  var chosen = kQtyStepLadder.first;
  for (final step in kQtyStepLadder) {
    if (step <= quarter + kQtyEpsilon) chosen = step;
  }
  return chosen;
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
