import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/base_batch_preview.dart';
import '../data/models/base_item.dart';
import '../data/models/basket_rollup.dart';
import '../domain/base_entry_math.dart';
import 'production_today_providers.dart'
    show ProduceLineOutcome, parseBasketShortages, parseProduceResults;

/// Whether to ask the backend to roll up jar demand for each base.
///
/// Demand costs a plan lookup plus a BOM explosion per base server-side. Kept
/// switchable for the same reason `includeCapacityProvider` is: a slow list can
/// be made fast without a deploy.
final includeBaseDemandProvider = StateProvider<bool>((ref) => true);

/// The list of bases. Loads once and is refreshed explicitly.
final baseItemsProvider =
    AsyncNotifierProvider<BaseItemsNotifier, BaseItemsPage>(
      BaseItemsNotifier.new,
    );

class BaseItemsNotifier extends AsyncNotifier<BaseItemsPage> {
  ManufacturingService get _service => ref.read(manufacturingServiceProvider);

  @override
  Future<BaseItemsPage> build() {
    final includeDemand = ref.watch(includeBaseDemandProvider);
    return _service.getBaseItems(includeDemand: includeDemand);
  }

  /// Pull-to-refresh, and the single way the list comes back in sync after a
  /// run is started.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getBaseItems(
        includeDemand: ref.read(includeBaseDemandProvider),
      ),
    );
  }
}

// ── One base's draft ────────────────────────────────────────────────────

/// The run one base is set up to make, in the unit its recipe is measured in.
///
/// [qty] is canonical throughout — the endpoint takes a quantity, and both ways
/// of arriving at one (jar counts on a mix, egg-count chips on a cake) resolve
/// to it here so there is exactly one number that can be submitted.
@immutable
class BaseRunDraft {
  const BaseRunDraft({
    this.qty = 0,
    this.jarCounts = const <String, int>{},
    this.qtyIsCustom = false,
    this.touched = false,
    this.preview,
    this.loading = false,
    this.error,
    this.materialSelections = const <String, String>{},
  });

  /// In the base's stock UOM. Zero means nothing has been asked for yet, which
  /// is why the Make button ignores this row until it is set.
  final double qty;

  /// `{jar item code: how many jars}` — the mix half's input. Kept even after
  /// [qty] is nudged by hand, so the screen can show that the two diverged
  /// instead of silently discarding what somebody typed.
  final Map<String, int> jarCounts;

  /// [qty] was typed or nudged directly and no longer follows [jarCounts].
  ///
  /// Touching any jar count clears this and re-syncs: a calculator that keeps
  /// recomputing over a figure you deliberately rounded up is a calculator
  /// nobody trusts, and one that never recomputes again is worse.
  final bool qtyIsCustom;

  /// Somebody has set a quantity on this row. Distinct from `qty > 0` because
  /// clearing a field back to zero is an answer, and re-seeding it with the
  /// recipe's default would put a number back that was deliberately removed.
  final bool touched;

  final BaseBatchPreview? preview;

  /// A preview is in flight or queued behind the debounce.
  final bool loading;

  /// The raw error object, not a message: the string has to be built with the
  /// widget's `l10n` and this class has no `BuildContext`.
  final Object? error;
  final Map<String, String> materialSelections;

  bool get hasPreview => preview != null;

  /// Something is actually asked for here.
  bool get isRunnable => qty >= kMinQty;

  /// The preview describes the quantity currently on screen.
  ///
  /// While the field is ahead of the last answer, the old component list is
  /// still worth showing — it just must not be read as current.
  bool get previewIsCurrent =>
      preview != null && (preview!.itemQty - qty).abs() <= kQtyEpsilon;

  BaseRunDraft copyWith({
    double? qty,
    Map<String, int>? jarCounts,
    bool? qtyIsCustom,
    bool? touched,
    BaseBatchPreview? preview,
    bool? loading,
    Object? error,
    bool clearPreview = false,
    bool clearError = false,
    Map<String, String>? materialSelections,
  }) {
    return BaseRunDraft(
      qty: qty ?? this.qty,
      jarCounts: jarCounts ?? this.jarCounts,
      qtyIsCustom: qtyIsCustom ?? this.qtyIsCustom,
      touched: touched ?? this.touched,
      preview: clearPreview ? null : (preview ?? this.preview),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      materialSelections: materialSelections ?? this.materialSelections,
    );
  }
}

/// Per-base draft, keyed by item code.
///
/// Deliberately NOT auto-disposed: a row scrolled off screen and back must
/// still hold what was dialled in. The family is bounded by the number of bases
/// (a handful), so nothing accumulates.
final baseRunDraftProvider =
    NotifierProvider.family<BaseRunDraftNotifier, BaseRunDraft, String>(
      BaseRunDraftNotifier.new,
    );

class BaseRunDraftNotifier extends FamilyNotifier<BaseRunDraft, String> {
  Timer? _debounce;

  /// Long enough that typing "45" costs one request, short enough that the
  /// consumption panel feels attached to the number above it.
  static const _debounceDelay = Duration(milliseconds: 400);

  @override
  BaseRunDraft build(String arg) {
    ref.onDispose(() => _debounce?.cancel());
    // Nothing is fetched here on purpose: a provider's build() must not start
    // network work, and the row asks for its first preview once it is opened.
    return const BaseRunDraft();
  }

  /// Puts the recipe's own batch on the row the first time it is opened, and
  /// never again.
  ///
  /// One batch is the right opening offer for both kinds: it is a whole oven
  /// tray for a cake, and for a mix it is the round amount the recipe is written
  /// in (1 Kg fruit + 1 Kg jelly = 2 Kg). [touched] is what keeps a re-open from
  /// overwriting a figure somebody set — including a deliberate zero.
  void seed(double qty) {
    if (state.touched) {
      // A row that was set up earlier still wants a current preview: the store
      // has moved since, and an old answer must not gate a Make.
      ensurePreview();
      return;
    }
    state = state.copyWith(
      qty: clampQty(qty),
      touched: true,
      clearError: true,
    );
    _schedulePreview();
  }

  /// Sets the quantity directly — a typed figure or a nudge chip.
  void setQty(double value) {
    final next = clampQty(value);
    if ((next - state.qty).abs() <= kQtyEpsilon && state.hasPreview) return;
    state = state.copyWith(
      qty: next,
      qtyIsCustom: true,
      touched: true,
      clearError: true,
    );
    _schedulePreview();
  }

  /// Sets how many of one jar are being filled, and re-derives the quantity.
  ///
  /// [perJar] is the whole base's rate table, not just this jar's: the quantity
  /// is the sum over every jar on the row, so recomputing it needs all of them.
  void setJarCount(
    String jarItemCode,
    int count, {
    required Map<String, double> perJar,
  }) {
    final counts = Map<String, int>.from(state.jarCounts);
    if (count <= 0) {
      counts.remove(jarItemCode);
    } else {
      counts[jarItemCode] = count;
    }

    final derived = qtyForJarCounts(counts, perJar);
    state = state.copyWith(
      jarCounts: counts,
      qty: clampQty(derived),
      // Re-synced: touching a jar count is a statement about what is being
      // filled, and it takes precedence over an earlier nudge to the total.
      qtyIsCustom: false,
      touched: true,
      clearError: true,
    );
    _schedulePreview();
  }

  /// Empties the jar counter without touching the quantity.
  void clearJarCounts() {
    if (state.jarCounts.isEmpty) return;
    state = state.copyWith(
      jarCounts: const <String, int>{},
      qtyIsCustom: true,
      clearError: true,
    );
  }

  void setMaterialSelection(String originalItemCode, String selectedItemCode) {
    final selections = Map<String, String>.from(state.materialSelections);
    if (selectedItemCode == originalItemCode) {
      selections.remove(originalItemCode);
    } else {
      selections[originalItemCode] = selectedItemCode;
    }
    state = state.copyWith(materialSelections: selections, clearError: true);
    _schedulePreview();
  }

  void resetMaterialSelections() {
    if (state.materialSelections.isEmpty) return;
    state = state.copyWith(
      materialSelections: const <String, String>{},
      clearPreview: true,
      clearError: true,
    );
    _schedulePreview();
  }

  /// Fetches the first preview for a row that has just been opened. Idempotent,
  /// so a rebuild does not re-request.
  void ensurePreview() {
    if (state.hasPreview || state.loading) return;
    if (!state.isRunnable) return;
    _schedulePreview();
  }

  /// Drops the cached preview and re-asks. Used after a run is posted, when the
  /// stock the last preview was computed against has physically moved.
  void invalidatePreview() {
    state = state.copyWith(clearPreview: true, clearError: true);
    _schedulePreview();
  }

  /// Everything this row was set up to make is now in the ledger.
  ///
  /// Reset rather than left standing: a row that keeps its numbers after a
  /// successful post is how a second Make silently re-posts a run that already
  /// happened.
  void clearAfterSuccess() {
    _debounce?.cancel();
    state = const BaseRunDraft();
  }

  void _schedulePreview() {
    _debounce?.cancel();
    if (!state.isRunnable) {
      // Nothing to cost. Clearing the stale answer matters: a panel describing
      // 2 Kg above an empty field reads as though 2 Kg were still queued.
      state = state.copyWith(
        loading: false,
        clearPreview: true,
        clearError: true,
      );
      return;
    }
    state = state.copyWith(loading: true);
    _debounce = Timer(_debounceDelay, refreshPreview);
  }

  /// Fetches now, skipping the debounce.
  Future<void> refreshPreview() async {
    final item = _item();
    if (item == null) {
      // The list has not loaded yet (or this base fell off it). Not an error
      // worth showing — the row re-asks once the list arrives.
      state = state.copyWith(loading: false);
      return;
    }
    if (!state.isRunnable) {
      state = state.copyWith(loading: false);
      return;
    }

    final requested = state.qty;
    final requestedSelections = Map<String, String>.from(
      state.materialSelections,
    );
    try {
      final preview = await ref
          .read(manufacturingServiceProvider)
          .previewBaseBatch(
            itemCode: item.itemCode,
            // Always the quantity, for both kinds of base. The chips on a cake
            // have already converted eggs into Kg, and sending a batch count
            // instead would make the server divide it back out — two
            // conversions where the contract promises one.
            qty: requested,
            bomName: item.defaultBom,
            materialSelections: requestedSelections,
          );
      // A slower earlier request must not overwrite a newer entry.
      if (!_stillWanted(requested, requestedSelections)) return;
      state = state.copyWith(
        preview: preview,
        loading: false,
        clearError: true,
      );
    } catch (error) {
      if (!_stillWanted(requested, requestedSelections)) return;
      // The stale component list is dropped with the failure: leaving numbers
      // on screen that describe a different quantity is worse than an honest
      // blank.
      state = state.copyWith(loading: false, error: error, clearPreview: true);
    }
  }

  bool _stillWanted(double requested, Map<String, String> requestedSelections) =>
      (state.qty - requested).abs() <= kQtyEpsilon &&
      _sameSelections(state.materialSelections, requestedSelections);

  bool _sameSelections(Map<String, String> left, Map<String, String> right) {
    if (left.length != right.length) return false;
    return left.entries.every((entry) => right[entry.key] == entry.value);
  }

  BaseItem? _item() {
    final page = ref.read(baseItemsProvider).valueOrNull;
    if (page == null) return null;
    for (final item in page.items) {
      if (item.itemCode == arg) return item;
    }
    return null;
  }
}

// ── Which rows are in this run ──────────────────────────────────────────

/// The bases the Make button will act on.
///
/// Explicit rather than inferred from "has a quantity typed in it": several
/// mixes going on at once is the normal case on this screen, and a set the
/// operator can see and untick is the only way that stays predictable.
final baseSelectionProvider =
    NotifierProvider<BaseSelectionNotifier, Set<String>>(
      BaseSelectionNotifier.new,
    );

class BaseSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  bool isSelected(String itemCode) => state.contains(itemCode);

  void toggle(String itemCode) {
    final next = Set<String>.from(state);
    if (!next.remove(itemCode)) next.add(itemCode);
    state = next;
  }

  void select(String itemCode) {
    if (state.contains(itemCode)) return;
    state = {...state, itemCode};
  }

  void remove(Iterable<String> itemCodes) {
    if (itemCodes.isEmpty) return;
    final next = Set<String>.from(state)..removeAll(itemCodes);
    if (next.length == state.length) return;
    state = next;
  }

  void clear() {
    if (state.isEmpty) return;
    state = const <String>{};
  }
}

// ── Making them ─────────────────────────────────────────────────────────

/// What one Make attempt did, split by what the two kinds of base actually do.
///
/// A mix is booked outright — material out, mix in, nothing to come back to. A
/// cake only has its material moved into WIP and is finished on the Running tab
/// once it comes out of the oven. Reporting them as one count would tell
/// somebody a cake is made when it is still baking.
@immutable
class BaseMakeReport {
  const BaseMakeReport({
    this.mixOutcomes = const <ProduceLineOutcome>[],
    this.cakeOutcomes = const <ProduceLineOutcome>[],
    this.shortages = const <RollupComponent>[],
    this.attempted = 0,
    this.mixError,
    this.cakeError,
    this.unresolved = const <String>[],
    this.nothingToDo = false,
  });

  /// Mixes booked as made.
  final List<ProduceLineOutcome> mixOutcomes;

  /// Cakes whose material is now in WIP, waiting to be finished.
  final List<ProduceLineOutcome> cakeOutcomes;

  /// `basket_shortages` from either stage, in the model the pick list renders.
  final List<RollupComponent> shortages;

  /// How many lines were sent, across both stages.
  final int attempted;

  /// Transport-level failure of a whole stage, kept raw so the screen can run
  /// it through `userErrorMessage`.
  final Object? mixError;
  final Object? cakeError;

  /// Selected rows whose item could not be found in the loaded catalogue, so
  /// NOTHING was sent at all.
  ///
  /// The catalogue can be absent for reasons unrelated to what is on screen —
  /// the provider errored, or is refetching. Dropping those lines silently would
  /// post a smaller run than was asked for and report it as a complete one.
  final List<String> unresolved;

  /// Nothing was set up. The button is disabled in that state, so this only
  /// guards a race.
  final bool nothingToDo;

  List<ProduceLineOutcome> get outcomes => [...mixOutcomes, ...cakeOutcomes];

  List<ProduceLineOutcome> get failures =>
      outcomes.where((o) => !o.ok).toList(growable: false);

  int get madeCount => mixOutcomes.where((o) => o.ok).length;
  int get startedCount => cakeOutcomes.where((o) => o.ok).length;
  int get okCount => madeCount + startedCount;

  /// Nothing at all reached the ledger — the screen then leads with the failure
  /// rather than with a count.
  bool get postedNothing => okCount == 0;

  /// A cake is now in WIP, so the Running tab is where the day continues.
  bool get hasRunningWork => startedCount > 0;

  Set<String> get succeededItemCodes => {
    for (final outcome in outcomes)
      if (outcome.ok && outcome.itemCode.isNotEmpty) outcome.itemCode,
  };

  BaseMakeReport copyWith({
    List<ProduceLineOutcome>? mixOutcomes,
    List<ProduceLineOutcome>? cakeOutcomes,
    List<RollupComponent>? shortages,
    int? attempted,
    Object? mixError,
    Object? cakeError,
    List<String>? unresolved,
    bool? nothingToDo,
  }) {
    return BaseMakeReport(
      mixOutcomes: mixOutcomes ?? this.mixOutcomes,
      cakeOutcomes: cakeOutcomes ?? this.cakeOutcomes,
      shortages: shortages ?? this.shortages,
      attempted: attempted ?? this.attempted,
      mixError: mixError ?? this.mixError,
      cakeError: cakeError ?? this.cakeError,
      unresolved: unresolved ?? this.unresolved,
      nothingToDo: nothingToDo ?? this.nothingToDo,
    );
  }
}

/// Posts the selected rows. One notifier for the whole screen, because the
/// button is one button and two of them running at once would race the store.
final baseMakeProvider = NotifierProvider<BaseMakeNotifier, bool>(
  BaseMakeNotifier.new,
);

class BaseMakeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// True while a Make is in flight.
  bool get submitting => state;

  /// Makes every selected row.
  ///
  /// Two calls, never one, because the two kinds of base do different things to
  /// stock: the mixes go through `produce_now` (booked outright) and the cakes
  /// through `start_production_batches` (material into WIP, finished later). Each
  /// call carries its own basket-wide material check, and the mixes go first so
  /// the cakes' check measures what is actually left after they commit.
  Future<BaseMakeReport> make({required String scheduledAt}) async {
    if (state) return const BaseMakeReport(nothingToDo: true);

    final selected = ref.read(baseSelectionProvider);
    if (selected.isEmpty) return const BaseMakeReport(nothingToDo: true);

    final page = ref.read(baseItemsProvider).valueOrNull;
    final byCode = <String, BaseItem>{
      for (final item in page?.items ?? const <BaseItem>[]) item.itemCode: item,
    };

    final mixLines = <Map<String, dynamic>>[];
    final cakeLines = <Map<String, dynamic>>[];
    final unresolved = <String>[];

    for (final code in selected) {
      final draft = ref.read(baseRunDraftProvider(code));
      if (!draft.isRunnable) continue;

      final item = byCode[code];
      if (item == null) {
        unresolved.add(code);
        continue;
      }

      final line = <String, dynamic>{
        'item_code': item.itemCode,
        if (item.defaultBom.isNotEmpty) 'bom_name': item.defaultBom,
        'item_qty': draft.qty,
        'scheduled_at': scheduledAt,
        if (draft.materialSelections.isNotEmpty)
          'material_selections': draft.materialSelections,
      };
      (item.isMadeByQuantity ? mixLines : cakeLines).add(line);
    }

    // An unnameable row aborts the whole Make rather than shrinking it. A
    // partial run reported as "3 of 3 done" is the failure mode worth being
    // strict about; every number stays where it was typed.
    if (unresolved.isNotEmpty) {
      return BaseMakeReport(unresolved: unresolved);
    }
    if (mixLines.isEmpty && cakeLines.isEmpty) {
      return const BaseMakeReport(nothingToDo: true);
    }

    state = true;
    final service = ref.read(manufacturingServiceProvider);
    var report = BaseMakeReport(attempted: mixLines.length + cakeLines.length);

    try {
      if (mixLines.isNotEmpty) {
        try {
          final response = await service.produceNow(
            mixLines,
            strictBasket: true,
          );
          report = report.copyWith(
            mixOutcomes: parseProduceResults(response),
            shortages: [...report.shortages, ...parseBasketShortages(response)],
          );
        } catch (error) {
          report = report.copyWith(mixError: error);
        }
      }

      // The cakes are attempted even when a mix failed: they draw on different
      // material (eggs and flour, not fruit and jelly), so refusing them over
      // somebody else's shortage would cost the floor an oven slot for nothing.
      if (cakeLines.isNotEmpty) {
        try {
          final response = await service.startProductionBatches(
            cakeLines,
            strictBasket: true,
          );
          report = report.copyWith(
            cakeOutcomes: parseProduceResults(response),
            shortages: [...report.shortages, ...parseBasketShortages(response)],
          );
        } catch (error) {
          report = report.copyWith(cakeError: error);
        }
      }

      return report;
    } finally {
      // On every exit path, including the early returns above: a row that
      // posted has to leave the screen with its selection, or the next Make
      // re-posts a run already in the ledger.
      final succeeded = report.succeededItemCodes;
      for (final code in succeeded) {
        ref.read(baseRunDraftProvider(code).notifier).clearAfterSuccess();
      }
      ref.read(baseSelectionProvider.notifier).remove(succeeded);
      state = false;
    }
  }
}
