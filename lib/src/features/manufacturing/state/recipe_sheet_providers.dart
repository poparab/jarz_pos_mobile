import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/recipe_sheet.dart';
import 'base_production_providers.dart';
import 'daily_plan_providers.dart';
import 'sop_providers.dart';

/// The jars a recipe sheet is asked for: only items with an active SOP, only
/// counts above zero, in item-code order.
///
/// Value-equal, so the sheet below refetches only when THIS set changes —
/// typing a jar that has no recipe changes the draft but not this.
@immutable
class RecipeSheetJars {
  RecipeSheetJars(Map<String, int> jars)
    : jars = Map<String, int>.unmodifiable(
        Map.fromEntries(
          jars.entries.where((e) => e.value > 0).toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        ),
      );

  /// Filters [quantities] down to [sopItems].
  factory RecipeSheetJars.from(
    Map<String, int> quantities,
    Set<String> sopItems,
  ) => RecipeSheetJars({
    for (final entry in quantities.entries)
      if (entry.value > 0 && sopItems.contains(entry.key))
        entry.key: entry.value,
  });

  final Map<String, int> jars;

  bool get isEmpty => jars.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is RecipeSheetJars && mapEquals(other.jars, jars);

  @override
  int get hashCode =>
      Object.hashAll(jars.entries.map((e) => Object.hash(e.key, e.value)));

  @override
  String toString() => 'RecipeSheetJars($jars)';
}

/// What the recipe sheet would be asked for right now.
///
/// Empty while the SOP list is loading or failed (that provider never errors,
/// it answers an empty set), so no sheet is requested for items the server has
/// not confirmed carry a recipe.
final recipeSheetJarsProvider = Provider.autoDispose<RecipeSheetJars>((ref) {
  final sopItems =
      ref.watch(sopItemCodesProvider).valueOrNull ?? const <String>{};
  if (sopItems.isEmpty) return RecipeSheetJars(const {});
  final quantities = ref.watch(
    dailyPlanDraftProvider.select((draft) => draft.quantities),
  );
  return RecipeSheetJars.from(quantities, sopItems);
});

/// How long typing must pause before the sheet is fetched: long enough to
/// swallow a multi-digit entry.
const recipeSheetDebounce = Duration(milliseconds: 400);

/// One combined recipe sheet for every SOP jar typed into the day's draft —
/// the draft both the Today screen and the Plan tab type into.
///
/// Null when nothing with a recipe is typed (no call is made). Debounced: each
/// change to [recipeSheetJarsProvider] rebuilds this provider, which disposes
/// the pending build, so a burst of keystrokes ends in one request. Riverpod
/// keeps the previous value on the loading state, so the card does not blink
/// while a new count settles.
final recipeSheetProvider = FutureProvider.autoDispose<RecipeSheetResponse?>((
  ref,
) async {
  final request = ref.watch(recipeSheetJarsProvider);
  if (request.isEmpty) return null;
  return _debouncedSheet(ref, request.jars);
});

/// Waits out [recipeSheetDebounce], then asks for the sheet — unless the
/// provider was rebuilt (or dropped) in the meantime, which is how a burst of
/// keystrokes ends in one request.
Future<RecipeSheetResponse?> _debouncedSheet(
  Ref ref,
  Map<String, num> lines,
) async {
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(recipeSheetDebounce);
  if (disposed) return null;

  return ref.read(manufacturingServiceProvider).getRecipeSheet(lines);
}

// ── The Bases tab ──────────────────────────────────────────────────────────

/// The bases a recipe sheet is asked for on the Bases tab: ticked, runnable,
/// with an active SOP, keyed by item code to the amount in the base's stock
/// UOM (Kg for every base today). Amounts stay fractional — 12.5 Kg is not 12.
///
/// Value-equal for the same reason [RecipeSheetJars] is: the sheet refetches
/// only when THIS set changes, not when a preview lands on a row or a base
/// without a recipe is retyped.
@immutable
class BaseRecipeSheetLines {
  BaseRecipeSheetLines(Map<String, double> amounts)
    : amounts = Map<String, double>.unmodifiable(
        Map.fromEntries(
          amounts.entries.where((e) => e.value > 0).toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        ),
      );

  final Map<String, double> amounts;

  bool get isEmpty => amounts.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is BaseRecipeSheetLines && mapEquals(other.amounts, amounts);

  @override
  int get hashCode =>
      Object.hashAll(amounts.entries.map((e) => Object.hash(e.key, e.value)));

  @override
  String toString() => 'BaseRecipeSheetLines($amounts)';
}

/// What the Bases tab's recipe sheet would be asked for right now.
///
/// Only a ticked base that has an SOP is watched at all, and only through its
/// runnable amount, so a row's preview arriving or loading does not rebuild
/// this. Empty while the SOP list is loading or failed, like the jar version.
final baseRecipeSheetLinesProvider = Provider.autoDispose<BaseRecipeSheetLines>(
  (ref) {
    final sopItems =
        ref.watch(sopItemCodesProvider).valueOrNull ?? const <String>{};
    if (sopItems.isEmpty) return BaseRecipeSheetLines(const {});
    final selected = ref.watch(baseSelectionProvider);
    return BaseRecipeSheetLines({
      for (final code in selected)
        if (sopItems.contains(code))
          code: ref.watch(
            baseRunDraftProvider(
              code,
            ).select((draft) => draft.isRunnable ? draft.qty : 0.0),
          ),
    });
  },
);

/// One recipe sheet per ticked base with a recipe — the steps differ between
/// bases, so the server answers each as its own sheet.
///
/// Null when nothing qualifies (no call is made). Debounced exactly like
/// [recipeSheetProvider].
final baseRecipeSheetProvider =
    FutureProvider.autoDispose<RecipeSheetResponse?>((ref) async {
      final request = ref.watch(baseRecipeSheetLinesProvider);
      if (request.isEmpty) return null;
      return _debouncedSheet(ref, request.amounts);
    });
