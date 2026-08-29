import '../data/models/stock_alternative.dart';

/// What the backend found when it went looking for a short material in the
/// rest of the company.
enum StockElsewhereVerdict {
  /// It exists in at least one other warehouse, and [StockElsewhere.top] names
  /// the fullest one. The fix is a transfer, not a purchase order.
  found,

  /// The lookup ran and came back empty: there is none of it anywhere in the
  /// company. Worth saying out loud — it is what stops the operator hunting
  /// through the other branches before ordering.
  nowhere,
}

/// The "is this stock simply in the wrong store?" answer, resolved from the two
/// nullable fields the backend attaches to a shortage.
///
/// Three states, and collapsing any two of them destroys the answer:
///   * fields absent  → nobody looked. [resolve] returns null and the UI must
///                      render exactly what it rendered before the feature.
///   * `0.0` and `[]` → somebody looked and found none. [StockElsewhereVerdict.nowhere].
///   * populated      → [StockElsewhereVerdict.found], with a warehouse to name.
///
/// A zero is therefore a real, useful answer and must never be produced by a
/// missing field defaulting to zero — which is why every field feeding this is
/// modelled nullable.
class StockElsewhere {
  const StockElsewhere._(this.verdict, this.alternatives);

  final StockElsewhereVerdict verdict;

  /// Other warehouses holding the material, fullest first. Always empty for
  /// [StockElsewhereVerdict.nowhere].
  final List<StockAlternative> alternatives;

  /// Null means the backend said nothing at all — the caller renders nothing.
  ///
  /// Also null in the degenerate case of a positive quantity with no warehouse
  /// list: there is nothing to name, and reporting "none anywhere" against a
  /// positive total would be worse than staying quiet.
  static StockElsewhere? resolve({
    double? availableElsewhere,
    List<StockAlternative>? alternatives,
  }) {
    if (availableElsewhere == null && alternatives == null) return null;

    final named = <StockAlternative>[
      for (final alternative in alternatives ?? const <StockAlternative>[])
        if (alternative.availableQty > 0 && alternative.warehouse.isNotEmpty)
          alternative,
    ]..sort((a, b) => b.availableQty.compareTo(a.availableQty));

    if (named.isNotEmpty) {
      return StockElsewhere._(StockElsewhereVerdict.found, named);
    }
    // The lookup ran and named nowhere. Only a non-positive total can be
    // reported as "none in the company"; anything else is unexplained and
    // stays silent.
    if ((availableElsewhere ?? 0) > 0) return null;
    return const StockElsewhere._(
      StockElsewhereVerdict.nowhere,
      <StockAlternative>[],
    );
  }

  bool get isFound => verdict == StockElsewhereVerdict.found;

  /// The fullest other warehouse. Only read when [isFound].
  StockAlternative get top => alternatives.first;

  /// How many warehouses beyond [top] also hold some. Rendered as "and 2 more"
  /// rather than listed: these banners are already dense.
  int get otherCount => alternatives.isEmpty ? 0 : alternatives.length - 1;
}
