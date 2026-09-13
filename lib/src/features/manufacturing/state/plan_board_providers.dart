import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/batch_line.dart';
import '../data/models/daily_plan.dart';
import '../data/models/production_suggestion.dart';
import 'daily_plan_providers.dart';
import 'production_basket_notifier.dart';
import 'production_providers.dart';

/// One jar on the merged Plan tab.
///
/// Two endpoints answer two halves of the same question — the plan template
/// knows which flavours are fillable and what a mixer batch of each yields, the
/// suggestions board knows what is running low — and the floor was reading them
/// on two different tabs with no way to act on both at once. This is the joined
/// row: the flavour, its cover figures when the board has any, and the one
/// quantity that drives the plan, the mixer split and the batches.
@immutable
class PlanRow {
  const PlanRow({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    this.stockUom = '',
    this.bomName = '',
    this.bomQty = 1.0,
    this.jarsPerBatch,
    this.usesMix = false,
    this.inTemplate = false,
    this.suggestion,
  });

  final String itemCode;
  final String itemName;

  /// Empty for a row the plan template does not carry — the widget renders
  /// those under one heading rather than inventing a group name here, where
  /// there is no `l10n`.
  final String itemGroup;
  final String stockUom;

  /// The jar's own default BOM. Empty means nothing can be queued for it: the
  /// row still takes a quantity, because a flavour with no BOM is still part of
  /// the day's target, but Start batches has nothing to submit for it.
  final String bomName;

  /// Finished jars one run of [bomName] yields.
  final double bomQty;

  /// Jars one full MIXER batch yields — a different number from [bomQty], and
  /// the one the floor knows by heart.
  final double? jarsPerBatch;
  final bool usesMix;

  /// The plan template lists this flavour. False for a row the ranked board
  /// asked for and the template does not carry — the mixer knows nothing about
  /// it, so the row must not claim "no cheesecake mix" either way.
  final bool inTemplate;

  /// Null when the ranked board does not carry this item: no cover, no status,
  /// no suggestion. The row is then plan-entry only, which is exactly what the
  /// old Daily tab was.
  final ProductionSuggestion? suggestion;

  String get displayName => itemName.isEmpty ? itemCode : itemName;

  /// A line can be built for this row.
  bool get canQueue => bomName.trim().isNotEmpty && bomQty > 0;

  String get status => suggestion?.status ?? ProductionStatus.noVelocity;

  /// Jars the warehouse can actually cover right now, or 0.
  ///
  /// This is what a bulk fill uses: adding a number materials cannot cover
  /// moves the refusal from the board to the submit, where it costs three more
  /// taps to discover.
  int get achievableJars {
    final item = suggestion;
    if (item == null || !canQueue) return 0;
    final batches = item.achievableBatches;
    if (batches <= 0) return 0;
    return (batches * item.bomQty).round();
  }

  /// The jar count the row's own one-tap fill offers, or 0 when there is
  /// nothing to offer.
  ///
  /// Falls back to the FULL suggestion for a row materials block outright, the
  /// way the old Add button did: the operator can still plan it, pick a
  /// stocked alternative or move stock in, and the consolidated check before
  /// Start batches is what actually refuses. A row with no source warehouse
  /// configured offers nothing — there is no shortfall to fix from here.
  int get suggestedJars {
    final item = suggestion;
    if (item == null || !canQueue) return 0;
    if (item.limitingComponent?.isMissingWarehouse ?? false) return 0;
    final achievable = achievableJars;
    if (achievable > 0) return achievable;
    return (item.suggestedBatches * item.bomQty).round();
  }

  /// The queue entry for this row at [jars] jars.
  BatchLine lineFor(int jars) => BatchLine(
    itemCode: itemCode,
    itemName: displayName,
    bomName: bomName,
    stockUom: stockUom,
    bomQtyYield: bomQty,
    batches: bomQty > 0 ? jars / bomQty : 0,
  );
}

/// A run of rows under one item-group heading.
@immutable
class PlanGroup {
  const PlanGroup({required this.name, required this.rows});

  /// Empty for the rows the plan template does not carry.
  final String name;
  final List<PlanRow> rows;
}

/// Everything the merged Plan tab needs, from both endpoints at once.
///
/// The plan template is the list of rows: it is the server's own answer to
/// "which items are jars" (`FINISHED_GOODS_GROUPS`), the same list the Today
/// screen fills jars from. The ranked board only decorates those rows with
/// cover figures, so a board that fails still leaves a usable plan form.
///
/// The reverse does not hold, and that is deliberate. The ranked board also
/// ranks the BASES — strawberry mix, sponge cake — because they own a BOM too,
/// and this tab once listed them under "Other items" with a whole-jar field.
/// Typing the 1.36 Kg a mix needed there lost the decimal point and queued
/// 1360 Kg against a two-kilo recipe. Bases are entered on the Bases tab, in
/// their own unit, so without the template this tab cannot tell a jar from a
/// base and says so instead of guessing.
@immutable
class PlanBoard {
  const PlanBoard({
    this.groups = const <PlanGroup>[],
    this.page,
    this.mix = const DailyPlanMix(),
    this.existingPlan,
    this.isLoading = false,
    this.error,
    this.hasJarList = false,
  });

  final List<PlanGroup> groups;

  /// The plan template has answered, so [groups] is the whole jar list rather
  /// than an empty placeholder. Anything that prunes against the rows must
  /// wait for this: pruning against a board still loading would empty the
  /// queue.
  final bool hasJarList;

  /// The ranked board's own header data (season, velocity freshness, summary).
  /// Null when that call failed or has not landed.
  final ProductionSuggestionsPage? page;

  /// The mix item and what one batch of it is — the mixer summary's units.
  final DailyPlanMix mix;

  /// The plan document already filed for this day, if any.
  final String? existingPlan;

  final bool isLoading;

  /// Set when the jar list itself could not be read.
  final Object? error;

  bool get isEmpty => groups.every((g) => g.rows.isEmpty);

  Iterable<PlanRow> get rows => groups.expand((g) => g.rows);
}

/// The joined board.
final planBoardProvider = Provider<PlanBoard>((ref) {
  final suggestions = ref.watch(productionSuggestionsProvider);
  final template = ref.watch(dailyPlanTemplateProvider);

  final page = suggestions.valueOrNull;
  final plan = template.valueOrNull;

  if (plan == null) {
    if (template.hasError) return PlanBoard(error: template.error);
    return const PlanBoard(isLoading: true);
  }

  final byCode = <String, ProductionSuggestion>{
    for (final item in page?.items ?? const <ProductionSuggestion>[])
      item.itemCode: item,
  };

  final grouped = <String, List<PlanRow>>{};

  for (final item in plan.items) {
    final suggestion = byCode[item.itemCode];
    grouped
        .putIfAbsent(item.itemGroup, () => <PlanRow>[])
        .add(
          PlanRow(
            itemCode: item.itemCode,
            itemName: item.itemName,
            itemGroup: item.itemGroup,
            stockUom: suggestion?.stockUom ?? '',
            // The template's BOM is the fallback: it names the recipe but not its
            // yield, so a row known only to the template queues jar-for-jar. That
            // is the right `item_qty` either way — only the batch COUNT in the
            // totals is then a jar count.
            bomName: suggestion?.defaultBom ?? item.defaultBom ?? '',
            bomQty: suggestion?.bomQty ?? 1.0,
            jarsPerBatch: item.jarsPerBatch,
            usesMix: item.usesMix,
            inTemplate: true,
            suggestion: suggestion,
          ),
        );
  }

  // Named groups in alphabetical order, the way the morning list has always
  // read; an unnamed group last.
  final names = grouped.keys.where((k) => k.isNotEmpty).toList()..sort();
  if (grouped.containsKey('')) names.add('');

  return PlanBoard(
    groups: [
      for (final name in names) PlanGroup(name: name, rows: grouped[name]!),
    ],
    page: page,
    mix: plan.mix,
    existingPlan: plan.existingPlan,
    isLoading: suggestions.isLoading || template.isLoading,
    hasJarList: true,
  );
});

/// The board after the status filter — derived, so filtering never refetches.
///
/// A row the ranked board says nothing about carries no status, so a filter
/// narrower than "all" hides it: it cannot be shown to match a bucket it was
/// never sorted into.
final visiblePlanBoardProvider = Provider<List<PlanGroup>>((ref) {
  final board = ref.watch(planBoardProvider);
  final filter = ref.watch(productionFilterProvider);
  if (filter.isAll) return board.groups;

  final groups = <PlanGroup>[];
  for (final group in board.groups) {
    final rows = group.rows
        .where((r) => r.suggestion != null && filter.matches(r.suggestion!))
        .toList(growable: false);
    if (rows.isNotEmpty) groups.add(PlanGroup(name: group.name, rows: rows));
  }
  return groups;
});

/// What a "Fill the day" did, so the bar can say what it skipped instead of
/// silently planning less than the board asked for.
@immutable
class PlanFillResult {
  const PlanFillResult({
    required this.itemsFilled,
    required this.jarsFilled,
    required this.skippedNoMaterials,
  });

  final int itemsFilled;
  final int jarsFilled;

  /// Actionable rows the warehouse cannot start at all.
  final int skippedNoMaterials;

  bool get filledNothing => itemsFilled == 0;
}

/// `{item code: raw text}` for every jar field holding something that is not a
/// whole jar count.
///
/// While an item is here its queue line keeps the last valid number (a stray
/// "." must not drop the line and the material choices on it), so nothing may
/// be submitted until the field is fixed — otherwise a red "1.360" still posts
/// 1. Root-scoped on purpose, beside the draft and the queue it qualifies: the
/// row is disposed by a scroll or a filter and the whole tab by switching to
/// Bases, and either one used to rebuild the field as a plain, valid-looking
/// "1" with Start batches enabled.
final planInvalidEntriesProvider = StateProvider<Map<String, String>>(
  (ref) => const <String, String>{},
);

/// The ONE write path for a jar quantity.
///
/// The number in a row's field has to be three things at once: the day's target
/// on the saved plan, the input to the mixer split, and the quantity Start
/// batches posts. Two stores would drift the moment one of them was written
/// without the other — which is precisely what having three tabs cost — so
/// every edit goes through here and lands in both.
///
/// The draft is the display truth and the basket is its Hive-backed shadow:
/// what the fields show is what Start batches submits, with nothing queued that
/// is not on screen and nothing on screen that is not queued.
final planEntryProvider = Provider<PlanEntryController>(
  PlanEntryController.new,
);

class PlanEntryController {
  PlanEntryController(this._ref);

  final Ref _ref;

  /// Sets [row] to [jars]. Zero clears the row from both stores.
  void setQuantity(PlanRow row, int jars) {
    final qty = jars < 0 ? 0 : jars;
    _ref.read(dailyPlanDraftProvider.notifier).setQuantity(row.itemCode, qty);
    if (!row.canQueue) return;
    _ref
        .read(productionBasketProvider.notifier)
        .setUnitsForItem(row.lineFor(qty), qty.toDouble());
  }

  /// The one-tap offer on a row. Returns what it filled in.
  ///
  /// Deliberately a tap and not a default: a suggestion pre-typed into the
  /// field is a number nobody entered, and this feature has already paid for
  /// that once — 50 planned, 42 made, one un-edited tap booking 50.
  int fillSuggestion(PlanRow row) {
    final jars = row.suggestedJars;
    if (jars > 0) setQuantity(row, jars);
    return jars;
  }

  /// Fills every row the board calls urgent, in one tap.
  ///
  /// Only critical and low, and only what materials allow — the same rule the
  /// old "Fill the day" applied, moved from the basket to the fields so the
  /// operator can see and correct every number before anything is posted.
  PlanFillResult fillTheDay(Iterable<PlanRow> rows) {
    var items = 0;
    var jars = 0;
    var skipped = 0;

    for (final row in rows) {
      final suggestion = row.suggestion;
      if (suggestion == null || !suggestion.isActionable) continue;
      final offer = row.achievableJars;
      if (offer <= 0) {
        skipped++;
        continue;
      }
      final current =
          _ref.read(dailyPlanDraftProvider).quantities[row.itemCode] ?? 0;
      // Never downwards: the operator's own larger number outranks the board's.
      if (offer <= current) continue;
      setQuantity(row, offer);
      items++;
      jars += offer - current;
    }

    return PlanFillResult(
      itemsFilled: items,
      jarsFilled: jars,
      skippedNoMaterials: skipped,
    );
  }

  /// Records what a field holds when it is not a whole jar count, or clears
  /// that record with null.
  void setInvalidEntry(String itemCode, String? text) {
    final notifier = _ref.read(planInvalidEntriesProvider.notifier);
    final current = notifier.state;
    if (current[itemCode] == text) return;
    final next = Map<String, String>.from(current);
    if (text == null) {
      next.remove(itemCode);
    } else {
      next[itemCode] = text;
    }
    notifier.state = next;
  }

  /// Empties the day — every store, so nothing survives in one of them.
  void clear() {
    _ref.read(productionBasketProvider.notifier).clear();
    _ref.read(dailyPlanDraftProvider.notifier).clear();
    _ref.read(planInvalidEntriesProvider.notifier).state =
        const <String, String>{};
  }

  /// Drops what has just been started. The jars are on the floor now, and a
  /// number left in the field invites the same run to be started twice; what
  /// was planned survives on the saved plan document.
  void forgetStarted(Iterable<String> itemCodes) {
    final codes = itemCodes.toList(growable: false);
    _ref.read(productionBasketProvider.notifier).removeItems(codes);
    _ref.read(dailyPlanDraftProvider.notifier).forget(codes);
    for (final code in codes) {
      setInvalidEntry(code, null);
    }
  }

  /// Drops every queued quantity for an item that is not a row on [board].
  ///
  /// The queue is persisted, so a tablet can carry a line from before a row
  /// left this tab — a base typed in as jars is the live case. Left alone it
  /// would be invisible and still submitted by Start batches, and still
  /// counted in the tab's badge. Returns whether anything was dropped.
  bool dropUnlisted(PlanBoard board) {
    if (!board.hasJarList) return false;
    final listed = {for (final row in board.rows) row.itemCode};
    final stale = <String>{
      for (final line in _ref.read(productionBasketProvider).lines)
        if (!listed.contains(line.itemCode)) line.itemCode,
      for (final code in _ref.read(dailyPlanDraftProvider).quantities.keys)
        if (!listed.contains(code)) code,
    };
    if (stale.isEmpty) return false;
    forgetStarted(stale);
    return true;
  }

  /// Re-hydrates the fields after a restart, WITHOUT writing anything back.
  ///
  /// The queue is the half that survives the app being killed, so it is the
  /// only thing that seeds the fields. A plan already filed for the day
  /// deliberately does NOT: it is a target, not a quantity somebody has just
  /// typed, and pouring it back into the fields would rebuild the queue behind
  /// it — so a run started this morning could be started a second time by
  /// re-opening the tab and tapping Start. The row shows the planned figure
  /// beside its field instead, one tap from being used.
  void hydrate() {
    final draft = _ref.read(dailyPlanDraftProvider);
    if (draft.quantities.isNotEmpty) return;

    final basket = _ref.read(productionBasketProvider);
    if (basket.positiveLines.isEmpty) return;

    _ref.read(dailyPlanDraftProvider.notifier).seedQuantities({
      for (final line in basket.positiveLines)
        line.itemCode: line.units.round(),
    });
  }
}
