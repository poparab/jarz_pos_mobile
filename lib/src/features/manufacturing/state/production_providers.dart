import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/basket_rollup.dart';
import '../data/models/bom_details.dart';
import '../data/models/production_suggestion.dart';
import 'production_basket_notifier.dart';

/// Which status buckets the Plan tab is showing.
class ProductionFilter {
  const ProductionFilter({this.statuses = const <String>{}});

  /// Empty means "everything".
  final Set<String> statuses;

  bool get isAll => statuses.isEmpty;

  bool matches(ProductionSuggestion item) =>
      isAll || statuses.contains(item.status);

  ProductionFilter toggle(String status) {
    final next = Set<String>.from(statuses);
    if (!next.remove(status)) next.add(status);
    return ProductionFilter(statuses: next);
  }

  @override
  bool operator ==(Object other) =>
      other is ProductionFilter &&
      other.statuses.length == statuses.length &&
      other.statuses.containsAll(statuses);

  @override
  int get hashCode => Object.hashAllUnordered(statuses);
}

final productionFilterProvider =
    StateProvider<ProductionFilter>((ref) => const ProductionFilter());

/// Whether to ask the backend for per-item capacity.
///
/// Capacity costs one BOM explosion per item server-side. Kept switchable so a
/// slow board can be made fast without a deploy.
final includeCapacityProvider = StateProvider<bool>((ref) => true);

/// The ranked board. Loads once and is refreshed explicitly.
final productionSuggestionsProvider = AsyncNotifierProvider<
    ProductionSuggestionsNotifier, ProductionSuggestionsPage>(
  ProductionSuggestionsNotifier.new,
);

class ProductionSuggestionsNotifier
    extends AsyncNotifier<ProductionSuggestionsPage> {
  ManufacturingService get _service => ref.read(manufacturingServiceProvider);

  @override
  Future<ProductionSuggestionsPage> build() {
    final includeCapacity = ref.watch(includeCapacityProvider);
    return _service.getProductionSuggestions(includeCapacity: includeCapacity);
  }

  /// Pull-to-refresh. Bypasses the server-side cache so the number on screen
  /// reflects stock as of now, not up to two minutes ago.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getProductionSuggestions(
        includeCapacity: ref.read(includeCapacityProvider),
        forceRefresh: true,
      ),
    );
  }

  /// Sets an item's cover-target override, then refreshes so its suggestion
  /// reflects the new target immediately.
  Future<void> setTargetDays(String itemCode, int? targetDays) async {
    await _service.setItemTargetDays(itemCode: itemCode, targetDays: targetDays);
    await refresh();
  }
}

/// The board after the status filter — derived, so filtering never refetches.
final visibleSuggestionsProvider = Provider<List<ProductionSuggestion>>((ref) {
  final page = ref.watch(productionSuggestionsProvider).valueOrNull;
  if (page == null) return const <ProductionSuggestion>[];

  final filter = ref.watch(productionFilterProvider);
  if (filter.isAll) return page.items;
  return page.items.where(filter.matches).toList(growable: false);
});

/// Search text for the manual BOM lookup, written debounced by the widget.
final bomSearchQueryProvider = StateProvider<String>((ref) => '');

/// Manual BOM search, cached per query for a minute.
///
/// Replaces the old `FutureBuilder(future: service.listDefaultBomItems(search))`
/// sitting inside `build()`, which re-issued the request on every keystroke and
/// on every unrelated `setState` — including each tap of a quantity stepper.
final bomSearchProvider = FutureProvider.autoDispose
    .family<List<BomItemSummary>, String>((ref, query) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 60), link.close);
  ref.onDispose(timer.cancel);

  return ref.read(manufacturingServiceProvider).searchBomItems(query);
});

/// One BOM's components, cached while the user is working with it.
final bomDetailsProvider =
    FutureProvider.autoDispose.family<BomDetails, String>((ref, itemCode) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  return ref.read(manufacturingServiceProvider).fetchBomDetails(itemCode);
});

/// Consolidated material check for the current basket.
///
/// Recomputed whenever the basket changes, so the pick list and the shortage
/// banner always describe what is actually queued. Returns null for an empty
/// basket rather than calling the API with nothing.
final basketRollupProvider =
    FutureProvider.autoDispose<BasketRollup?>((ref) async {
  final basket = ref.watch(productionBasketProvider);
  final lines = basket.toApiLines();
  if (lines.isEmpty) return null;

  return ref.read(manufacturingServiceProvider).getBasketMaterialRollup(lines);
});
