import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/batch_line.dart';
import '../data/models/bom_details.dart';
import '../data/models/production_suggestion.dart';
import '../data/repositories/production_basket_repository.dart';

/// How far back production may be posted from the app.
///
/// The old picker allowed anything from last year to two years out, and that
/// date became the stock entry's posting date. Forward-dating is removed
/// outright: a future-dated stock entry for work already done is meaningless.
const int kProductionBackDateDays = 3;

final productionBasketProvider =
    NotifierProvider<ProductionBasketNotifier, ProductionBasket>(
  ProductionBasketNotifier.new,
);

class ProductionBasketNotifier extends Notifier<ProductionBasket> {
  Timer? _persistTimer;

  ProductionBasketRepository get _repo =>
      ref.read(productionBasketRepositoryProvider);

  @override
  ProductionBasket build() {
    ref.onDispose(() => _persistTimer?.cancel());
    // Starts empty and is hydrated by restore(); Hive opens asynchronously and
    // a Notifier's build() cannot await.
    return const ProductionBasket();
  }

  /// Loads any basket left over from a previous session.
  ///
  /// Only applied when the in-memory basket is still untouched, so a restore
  /// arriving late can never clobber work the user has already started.
  Future<void> restore() async {
    final saved = await _repo.load();
    if (saved == null || saved.lines.isEmpty) return;
    if (state.lines.isNotEmpty) return;
    state = saved;
  }

  /// Adds a line, or raises an existing one to [batches].
  ///
  /// Takes the larger value rather than summing: tapping "Add" twice on a row
  /// suggesting 5 batches means 5, not 10.
  void addOrRaise(BatchLine line) {
    final index = state.indexOfItem(line.itemCode);
    if (index < 0) {
      _update(state.copyWith(lines: [...state.lines, line]));
      return;
    }

    final existing = state.lines[index];
    if (line.batches <= existing.batches) return;
    _replaceAt(index, existing.withBatches(line.batches));
  }

  void addFromBom(BomDetails bom, {double batches = 1.0}) =>
      addOrRaise(BatchLine.fromBom(bom, batches: batches));

  void setBatches(int index, double batches) {
    if (index < 0 || index >= state.lines.length) return;
    _replaceAt(index, state.lines[index].withBatches(batches));
  }

  void setUnits(int index, double units) {
    if (index < 0 || index >= state.lines.length) return;
    _replaceAt(index, state.lines[index].withUnits(units));
  }

  void remove(int index) {
    if (index < 0 || index >= state.lines.length) return;
    final next = [...state.lines]..removeAt(index);
    _update(state.copyWith(lines: next));
  }

  void clear() {
    _update(state.copyWith(lines: const []));
    unawaited(_repo.clear());
  }

  void setPostingDate(DateTime date) =>
      _update(state.copyWith(postingDate: date));

  /// Queues everything the board says is urgent, in one tap.
  ///
  /// When [capByCapacity] is on (the default) each line is capped at what
  /// materials actually allow, so the basket that comes out is one the
  /// warehouse can start today rather than one that fails at submit.
  FillTheDayResult fillTheDay(
    List<ProductionSuggestion> suggestions, {
    bool capByCapacity = true,
  }) {
    var added = 0;
    var batchesAdded = 0.0;
    var skipped = 0;
    var capped = 0;

    final lines = [...state.lines];

    for (final suggestion in suggestions) {
      if (!suggestion.isActionable) continue;

      final target = capByCapacity
          ? suggestion.achievableBatches
          : suggestion.suggestedBatches;

      if (target <= 0) {
        // Actionable but the warehouse cannot start it at all — reported
        // rather than silently dropped.
        skipped++;
        continue;
      }
      if (capByCapacity && suggestion.isCappedByMaterials) capped++;

      final line = BatchLine(
        itemCode: suggestion.itemCode,
        itemName: suggestion.itemName,
        bomName: suggestion.defaultBom,
        stockUom: suggestion.stockUom,
        bomQtyYield: suggestion.bomQty,
        batches: target.toDouble(),
      );

      final index = lines.indexWhere((l) => l.itemCode == suggestion.itemCode);
      if (index < 0) {
        lines.add(line);
        added++;
        batchesAdded += target;
      } else if (target > lines[index].batches) {
        batchesAdded += target - lines[index].batches;
        lines[index] = lines[index].withBatches(target.toDouble());
        added++;
      }
    }

    if (added > 0) _update(state.copyWith(lines: lines));

    return FillTheDayResult(
      itemsAdded: added,
      batchesAdded: batchesAdded,
      skippedNoMaterials: skipped,
      cappedByMaterials: capped,
    );
  }

  /// Fills in the components of a line once its BOM has been fetched.
  ///
  /// "Fill the day" builds lines from suggestion rows, which carry no component
  /// detail — this backfills it so the batch tab can show the pick list.
  void attachComponents(String itemCode, BomDetails bom) {
    final index = state.indexOfItem(itemCode);
    if (index < 0) return;
    if (state.lines[index].components.isNotEmpty) return;
    _replaceAt(index, state.lines[index].copyWith(components: bom.components));
  }

  void _replaceAt(int index, BatchLine line) {
    final next = [...state.lines]..[index] = line;
    _update(state.copyWith(lines: next));
  }

  void _update(ProductionBasket basket) {
    state = basket;
    _schedulePersist();
  }

  /// Debounced so dragging a stepper does not hit storage on every frame.
  void _schedulePersist() {
    _persistTimer?.cancel();
    final snapshot = state;
    _persistTimer = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(_repo.save(snapshot)),
    );
  }
}
