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

  /// The one read of the saved basket into memory, shared by every caller (or
  /// a completed no-op once the day was cleared, which makes memory the whole
  /// truth). Until it completes storage can hold lines memory has never seen,
  /// and a removal written from memory alone would leave them there to come
  /// back after a restart. A Future rather than a flag, so two overlapping
  /// calls merge once instead of each merging what it read.
  Future<void>? _restoring;

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
  /// A restore arriving late never clobbers work the user has already started:
  /// a live line wins over the saved one for the same item, and the live
  /// posting date stands. Saved lines for items the live basket does not hold
  /// are added back rather than thrown away — the Hive load races the Plan
  /// tab, which queues jars typed on the Today screen the moment it opens, and
  /// dropping the saved basket whenever that won lost yesterday's queue
  /// without a trace. Whether each one belongs is the Plan tab's call
  /// (`PlanEntryController.reconcile`): back into its field, or dropped when
  /// the jar has been decided since.
  ///
  /// Once per app process: after the first read, storage only ever trails
  /// memory, and a second read would bring back a line removed inside the
  /// 400 ms before it was persisted.
  ///
  /// A failed read is not remembered, so the next call tries again.
  Future<void> restore() {
    return _restoring ??= _readSaved().catchError((
      Object error,
      StackTrace stack,
    ) {
      _restoring = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<void> _readSaved() async {
    final saved = await _repo.load();
    if (saved == null || saved.lines.isEmpty) return;
    if (state.lines.isEmpty) {
      state = saved;
      return;
    }
    final live = {for (final line in state.lines) line.itemCode};
    final missing = saved.lines
        .where((line) => !live.contains(line.itemCode))
        .toList(growable: false);
    if (missing.isEmpty) return;
    _update(state.copyWith(lines: [...state.lines, ...missing]));
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
    if (line.bomName != existing.bomName) {
      final batches = line.batches > existing.batches
          ? line.batches
          : existing.batches;
      _replaceAt(index, line.withBatches(batches));
      return;
    }
    if (line.batches <= existing.batches) return;
    _replaceAt(index, existing.withBatches(line.batches));
  }

  void addFromBom(BomDetails bom, {double batches = 1.0}) =>
      addOrRaise(BatchLine.fromBom(bom, batches: batches));

  /// Sets one item's queued quantity to exactly [units], adding or dropping the
  /// line as needed.
  ///
  /// The merged Plan tab types a jar count into a field, so it needs a setter
  /// and not [addOrRaise]: that one takes the LARGER of the two values, which
  /// is right for a row-by-row "Add" and wrong for a number somebody has just
  /// corrected downwards — 50 typed over 60 would have stayed 60.
  ///
  /// Zero removes the line rather than parking it at nought. A zeroed line is a
  /// leftover, and one sitting in the basket keeps the roll-up recomputing and
  /// the persisted basket growing for an item nobody is making.
  ///
  /// [prototype] carries the item's current BOM. When it names a different BOM
  /// than the queued line, the line is rebuilt from it: the material selections
  /// on the old line belong to a recipe that is no longer the default, and
  /// carrying them over would submit a substitution against the wrong BOM.
  void setUnitsForItem(BatchLine prototype, double units) {
    final index = state.indexOfItem(prototype.itemCode);
    if (units <= 0) {
      if (index >= 0) remove(index);
      return;
    }
    if (index < 0) {
      _update(state.copyWith(lines: [...state.lines, prototype.withUnits(units)]));
      return;
    }
    final existing = state.lines[index];
    if (existing.bomName != prototype.bomName ||
        existing.bomQtyYield != prototype.bomQtyYield) {
      _replaceAt(index, prototype.withUnits(units));
      return;
    }
    _replaceAt(index, existing.withUnits(units));
  }

  /// Drops the lines for [itemCodes] — what a successful start leaves behind.
  void removeItems(Iterable<String> itemCodes) {
    final drop = itemCodes.toSet();
    if (drop.isEmpty) return;
    final next = state.lines
        .where((l) => !drop.contains(l.itemCode))
        .toList(growable: false);
    if (next.length == state.lines.length) return;
    _update(state.copyWith(lines: next));
  }

  /// Drops [itemCodes] and writes that to storage NOW, not after the debounce.
  ///
  /// For lines that have just been posted. The queue survives a restart, so a
  /// posted line still in storage comes back into its field and can be posted
  /// a second time: the 400 ms debounce is a window in which killing the app
  /// does exactly that, and a Make on the Today screen used to leave the line
  /// in storage indefinitely. Memory changes synchronously; when storage has
  /// not been read yet this session it is read first, so its copy loses the
  /// lines too.
  Future<void> removeItemsNow(Iterable<String> itemCodes) async {
    final drop = itemCodes.toSet();
    if (drop.isEmpty) return;
    removeItems(drop);
    // Waits on the read already in flight rather than starting a second one,
    // then removes again from whatever it merged.
    await restore();
    removeItems(drop);
    _persistTimer?.cancel();
    await _repo.save(state);
  }

  void setBatches(int index, double batches) {
    if (index < 0 || index >= state.lines.length) return;
    _replaceAt(index, state.lines[index].withBatches(batches));
  }

  void setUnits(int index, double units) {
    if (index < 0 || index >= state.lines.length) return;
    _replaceAt(index, state.lines[index].withUnits(units));
  }

  void setMaterialSelection(
    int index,
    String originalItemCode,
    String selectedItemCode,
  ) {
    if (index < 0 || index >= state.lines.length) return;
    final line = state.lines[index];
    final selections = Map<String, String>.from(line.materialSelections);
    if (selectedItemCode == originalItemCode) {
      selections.remove(originalItemCode);
    } else {
      selections[originalItemCode] = selectedItemCode;
    }
    _replaceAt(index, line.copyWith(materialSelections: selections));
  }

  void remove(int index) {
    if (index < 0 || index >= state.lines.length) return;
    final next = [...state.lines]..removeAt(index);
    _update(state.copyWith(lines: next));
  }

  void clear() {
    _restoring ??= Future<void>.value();
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
