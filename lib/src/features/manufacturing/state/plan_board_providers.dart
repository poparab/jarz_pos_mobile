import 'dart:async';

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
/// Display state only: an item here has NO queued quantity (the field reports
/// 0), so nothing can post a number the screen is not showing. It exists so
/// the red entry is still in the field after a scroll, a filter or a switch to
/// the Bases tab disposes the row, and so the action bar can hold Start
/// batches until every red field is fixed or cleared.
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
  ///
  /// A real number replaces any red entry on the row. "Fill the day", "Use 60"
  /// and "Use planned" write here while the row may be off-screen, where its
  /// own field cannot clear the entry, and a red "1.36" would stay over a 60
  /// both stores hold. Zero leaves it: that is what the row's own invalid path
  /// writes, right after reporting the text.
  void setQuantity(PlanRow row, int jars) {
    final qty = jars < 0 ? 0 : jars;
    if (qty > 0) setInvalidEntry(row.itemCode, null);
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
  ///
  /// Written to storage at once rather than after the queue's debounce: a
  /// posted line that is still in Hive when the app dies is restored into its
  /// field and can be posted again.
  void forgetStarted(Iterable<String> itemCodes) {
    final codes = itemCodes.toList(growable: false);
    unawaited(
      _ref.read(productionBasketProvider.notifier).removeItemsNow(codes),
    );
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
  ///
  /// An EMPTY jar list prunes nothing: it is a misconfigured or half-answered
  /// template far more often than a day with no jars, and pruning against it
  /// would wipe the whole persisted queue.
  bool dropUnlisted(PlanBoard board) {
    if (!board.hasJarList || board.isEmpty) return false;
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

  /// Whether the fields and the queue already describe the same quantities
  /// for every row on [board]. Pure, so the tab can ask on every build.
  bool isReconciled(PlanBoard board) => _mismatches(board).isEmpty;

  /// Lines the fields up with the queue, so that Start batches posts exactly
  /// what the fields show: nothing queued that no field shows, and nothing
  /// shown that is not queued. Returns whether anything changed.
  ///
  /// The two drift because the draft has writers that are not this tab — the
  /// Today screen types jars into it and empties them after a Make, and never
  /// touches the queue — while the queue alone survives a restart through
  /// Hive. Per item, whichever store actually holds the decision wins:
  ///
  /// * the draft, once it has taken a position on the jar this session (typed
  ///   anywhere, zeroed by a Make, cleared with the day). The queue follows,
  ///   so a jar Today just posted is not started again from here;
  /// * otherwise the queue, which after a restart is the only record of what
  ///   was typed. Its number goes back into the field.
  ///
  /// A saved plan never seeds anything: it is a target, not a quantity
  /// somebody has just typed, and pouring it into the fields would rebuild the
  /// queue behind it, so a run started this morning could be started a second
  /// time by re-opening the tab. The row shows the planned figure beside its
  /// field instead, one tap from being used.
  ///
  /// Items the board does not list are dropped from both stores (see
  /// [dropUnlisted]), and nothing is done until the jar list itself is in.
  /// Settling a row on a real number also clears a red entry left on it —
  /// otherwise a "1.36" typed here stays red over the 12 typed on Today — and
  /// several queued lines for one item collapse into one, since Start batches
  /// posts every line and the field can show only one number.
  bool reconcile(PlanBoard board) {
    final mismatches = _mismatches(board);
    if (mismatches.isEmpty) return false;

    final draft = _ref.read(dailyPlanDraftProvider.notifier);
    final basket = _ref.read(productionBasketProvider.notifier);
    final unlisted = <String>[];

    for (final m in mismatches) {
      final row = m.row;
      if (row == null) {
        unlisted.add(m.itemCode);
        continue;
      }
      if (m.clearsInvalidEntry) setInvalidEntry(m.itemCode, null);
      if (m.draftQty != m.target) draft.setQuantity(m.itemCode, m.target);
      if (m.basketOk) continue;
      if (m.duplicated) {
        final first = _ref
            .read(productionBasketProvider)
            .lines
            .firstWhere((l) => l.itemCode == m.itemCode);
        basket.removeItems([m.itemCode]);
        if (m.target > 0 && row.canQueue) basket.addOrRaise(first);
      }
      if (m.target > 0 && row.canQueue) {
        basket.setUnitsForItem(row.lineFor(m.target), m.target.toDouble());
      } else {
        // Nothing to post: a zero, or a row with no BOM to post it against —
        // which takes a plan quantity and is never queued.
        basket.removeItems([m.itemCode]);
      }
    }

    if (unlisted.isNotEmpty) forgetStarted(unlisted);
    return true;
  }

  List<_PlanMismatch> _mismatches(PlanBoard board) {
    // An empty jar list is treated as no answer — see [dropUnlisted].
    if (!board.hasJarList || board.isEmpty) return const <_PlanMismatch>[];

    final rows = {for (final row in board.rows) row.itemCode: row};
    final quantities = _ref.read(dailyPlanDraftProvider).quantities;
    final draft = _ref.read(dailyPlanDraftProvider.notifier);
    final lines = _ref.read(productionBasketProvider).lines;
    final invalid = _ref.read(planInvalidEntriesProvider);

    // What Start batches would post per item: EVERY positive line, not only
    // the first one `indexOfItem` finds.
    final queued = <String, double>{};
    final lineCount = <String, int>{};
    for (final line in lines) {
      final units = line.units > 0 ? line.units : 0.0;
      queued[line.itemCode] = (queued[line.itemCode] ?? 0) + units;
      lineCount[line.itemCode] = (lineCount[line.itemCode] ?? 0) + 1;
    }

    final mismatches = <_PlanMismatch>[];
    for (final code in {...quantities.keys, ...queued.keys}) {
      final row = rows[code];
      if (row == null) {
        mismatches.add(_PlanMismatch(itemCode: code));
        continue;
      }

      final draftQty = quantities[code] ?? 0;
      final units = queued[code] ?? 0;
      final target = draft.hasDecided(code)
          ? draftQty
          : (units > 0 ? units.round() : 0);

      final duplicated = (lineCount[code] ?? 0) > 1;
      // A zero-unit line posts nothing (`positiveLines`), so it can stay.
      final basketOk =
          !duplicated &&
          (target > 0 && row.canQueue
              ? (units - target).abs() < 1e-6
              : units <= 0);
      final clearsInvalidEntry = target > 0 && invalid.containsKey(code);

      if (draftQty != target || !basketOk || clearsInvalidEntry) {
        mismatches.add(
          _PlanMismatch(
            itemCode: code,
            row: row,
            draftQty: draftQty,
            target: target,
            basketOk: basketOk,
            duplicated: duplicated,
            clearsInvalidEntry: clearsInvalidEntry,
          ),
        );
      }
    }
    return mismatches;
  }
}

/// One item on which the fields and the queue disagree, and what to settle on.
@immutable
class _PlanMismatch {
  const _PlanMismatch({
    required this.itemCode,
    this.row,
    this.draftQty = 0,
    this.target = 0,
    this.basketOk = true,
    this.duplicated = false,
    this.clearsInvalidEntry = false,
  });

  final String itemCode;

  /// Null when the board does not list the item at all.
  final PlanRow? row;
  final int draftQty;
  final int target;
  final bool basketOk;

  /// The queue holds more than one line for the item.
  final bool duplicated;

  /// The row settles on a real number while a red entry is still recorded.
  final bool clearsInvalidEntry;
}
