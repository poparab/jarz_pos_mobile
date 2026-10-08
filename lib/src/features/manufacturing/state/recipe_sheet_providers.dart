import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/recipe_sheet.dart';
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

  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(recipeSheetDebounce);
  if (disposed) return null;

  return ref.read(manufacturingServiceProvider).getRecipeSheet(request.jars);
});
