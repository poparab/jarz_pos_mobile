// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

// Imported whole rather than with a `show`: the generated `copyWith` for the
// season and threshold blocks below reaches for their `$…CopyWith` mixins, and
// a show clause hides those.
import 'production_suggestion.dart';
import 'stock_alternative.dart';

part 'base_item.freezed.dart';
part 'base_item.g.dart';

/// Where the per-row `demand` block came from.
///
/// A base is never sold, so demand for it can only be derived from something
/// downstream: today's saved jar plan, or the ranked sales suggestions. `none`
/// means neither was available and the rows carry no demand at all — which is
/// a normal answer, not an error.
/// A run of this base is a whole or half batch: something in the recipe is
/// counted, not weighed, so the batch is a real physical unit.
const String kBaseEntryBatch = 'batch';

/// A run of this base is any quantity: every ingredient is weighed, so the
/// mixer imposes no grid and asking for "1.5 batches" of it is meaningless.
const String kBaseEntryQuantity = 'quantity';

abstract final class BaseDemandSource {
  static const plan = 'plan';
  static const suggestions = 'suggestions';
  static const none = 'none';
}

/// Payload of `subassembly.get_base_items`.
@freezed
class BaseItemsPage with _$BaseItemsPage {
  const factory BaseItemsPage({
    @Default('') String company,
    @JsonKey(name: 'generated_on') String? generatedOn,
    @JsonKey(name: 'demand_source')
    @Default(BaseDemandSource.none)
    String demandSource,
    @Default(<BaseItem>[]) List<BaseItem> items,
    @Default(BaseItemsSummary()) BaseItemsSummary summary,

    /// Whether this server worked out how fast the freezer empties.
    ///
    /// False on an older backend, and false when the roll-up was skipped: every
    /// per-item cover field is then absent rather than zero, and the card shows
    /// none of them instead of printing a confident nought.
    @JsonKey(name: 'cover_included') @Default(false) bool coverIncluded,

    /// The same season and thresholds the jar board applies, so a base and a
    /// jar are ranked by one rule rather than two.
    @Default(ProductionSeason()) ProductionSeason season,
    @JsonKey(name: 'default_target_days') @Default(7) int defaultTargetDays,
    @Default(ProductionThresholds()) ProductionThresholds thresholds,
  }) = _BaseItemsPage;

  factory BaseItemsPage.fromJson(Map<String, dynamic> json) =>
      _$BaseItemsPageFromJson(json);

  const BaseItemsPage._();

  bool get isEmpty => items.isEmpty;

  /// True when no row carries a demand block, so the hint line is pointless.
  bool get hasDemand => demandSource != BaseDemandSource.none;

  /// Bases the freezer will run out of first. Counted here rather than taken
  /// from [summary], which predates the cover figures and counts a different
  /// thing — what today's plan needs, not how long the freezer lasts.
  int get belowCoverCount => items.where((i) => i.isBelowCover).length;
}

@freezed
class BaseItemsSummary with _$BaseItemsSummary {
  const factory BaseItemsSummary({
    @Default(0) int total,
    @JsonKey(name: 'short_of_demand') @Default(0) int shortOfDemand,
    @JsonKey(name: 'blocked_by_materials') @Default(0) int blockedByMaterials,
  }) = _BaseItemsSummary;

  factory BaseItemsSummary.fromJson(Map<String, dynamic> json) =>
      _$BaseItemsSummaryFromJson(json);
}

/// One sub-assembly the floor can make a run of.
///
/// Everything on it is expressed in batches rather than jars: the mixer is the
/// unit of work, and `batch_yield` is the only bridge back to stock quantity.
@freezed
class BaseItem with _$BaseItem {
  const factory BaseItem({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @JsonKey(name: 'default_bom') @Default('') String defaultBom,

    /// What ONE batch produces, in [stockUom].
    @JsonKey(name: 'batch_yield') @Default(1.0) double batchYield,

    /// May be negative — a base with a negative Bin almost always means a run
    /// was consumed without ever being recorded as produced.
    @JsonKey(name: 'on_hand') @Default(0.0) double onHand,
    @JsonKey(name: 'stock_is_negative') @Default(false) bool stockIsNegative,
    @JsonKey(name: 'batches_on_hand') @Default(0.0) double batchesOnHand,

    /// Null when the server skipped the capacity check.
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component')
    BaseLimitingComponent? limitingComponent,

    /// The run sizes the mixer actually supports, when the backend publishes
    /// them. Advisory only: an off-grid figure warns, it never blocks.
    @JsonKey(name: 'run_sizes') List<double>? runSizes,

    /// How the floor actually measures a run of this base.
    ///
    /// `batch` — the recipe contains something countable (30 eggs), so a run
    /// is a whole or half batch and the quantity follows from it.
    /// `quantity` — every ingredient is weighed, so any amount is makeable and
    /// batches are a fiction the screen should not impose.
    ///
    /// Defaults to `batch` so a server that predates this field behaves exactly
    /// as it did: every base was a batch before the distinction existed.
    @JsonKey(name: 'entry_mode') @Default(kBaseEntryBatch) String entryMode,

    /// The countable ingredient one batch is measured by — eggs, for every
    /// cake in this catalogue.
    ///
    /// Null for anything weighed rather than counted, which is what makes
    /// [entryMode] `quantity`. The two always agree; [entryMode] is published
    /// separately so the client never has to re-derive the rule.
    @JsonKey(name: 'batch_unit') BaseBatchUnit? batchUnit,

    /// The jars whose own recipe draws on this base, with what each one takes.
    ///
    /// Empty — never null — when nothing consumes it. Sorted smallest-per-jar
    /// first by the server, which puts Medium before Large.
    @JsonKey(name: 'jar_consumers')
    @Default(<BaseJarConsumer>[])
    List<BaseJarConsumer> jarConsumers,
    @JsonKey(name: 'has_sop') @Default(false) bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,

    /// How much of this base the jars downstream actually eat per day, in
    /// [stockUom].
    ///
    /// **Null is NO SIGNAL** — nothing consumed it in the window, or the server
    /// did not look. Deliberately not `0.0`, which is a claim ("it never
    /// moves") and would make every cover figure derived from it infinite.
    @JsonKey(name: 'consumption_per_day') double? consumptionPerDay,

    /// Days the freezer lasts at [consumptionPerDay]. Null for the same reason.
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    @JsonKey(name: 'target_days') @Default(7) int targetDays,
    @JsonKey(name: 'target_days_source')
    @Default('default')
    String targetDaysSource,

    /// `critical|low|ok|overstocked|no_velocity`, the same vocabulary the jar
    /// board uses — so [ProductionStatusChip] can render a base and a jar
    /// identically.
    ///
    /// Null means this server does not compute cover for bases at all, which is
    /// distinct from `no_velocity` (it looked, and nothing consumes this base).
    String? status,
    @JsonKey(name: 'suggested_qty') @Default(0.0) double suggestedQty,
    @JsonKey(name: 'suggested_batches') @Default(0) int suggestedBatches,
  }) = _BaseItem;

  factory BaseItem.fromJson(Map<String, dynamic> json) =>
      _$BaseItemFromJson(json);

  const BaseItem._();

  /// Most bases are named by their code, so printing both renders one string
  /// twice.
  String get displayName => itemName.isEmpty ? itemCode : itemName;

  /// A zero or missing yield would collapse every batch↔quantity conversion to
  /// zero and submit an empty Work Order, so it is treated as one unit.
  double get safeBatchYield => batchYield > 0 ? batchYield : 1.0;

  /// Materials cannot cover even the smallest run the tab will submit.
  bool get isBlockedByMaterials =>
      canMakeNowBatches != null && canMakeNowBatches! <= 0;

  /// Made to any weight the floor asks for, with no batch grid.
  bool get isMadeByQuantity => entryMode == kBaseEntryQuantity;

  /// The jar counter is only offered where it is the natural way to ask: on a
  /// mix, "how many jars am I filling" IS the question. A cake is mixed by the
  /// egg and the jar arithmetic belongs to the plan, not to the mixer.
  bool get hasJarEntry => isMadeByQuantity && jarConsumers.isNotEmpty;

  /// What one batch is counted in on the floor — "30 eggs".
  ///
  /// Null wherever [isMadeByQuantity] is true, and the two never disagree: the
  /// server derives one from the other.
  BaseBatchUnit? get countedBatchUnit => isMadeByQuantity ? null : batchUnit;

  /// The server worked out a cover verdict for this base.
  bool get hasCoverSignal => status != null;

  /// Something actually consumes this base, so days-of-cover means something.
  ///
  /// The card must say "no signal" rather than print a zero when this is false:
  /// a base nothing has drawn on is not a base with nought days left.
  bool get hasConsumptionSignal => consumptionPerDay != null;

  /// The freezer runs out inside the target window.
  bool get isBelowCover =>
      status == ProductionStatus.critical || status == ProductionStatus.low;
}

/// The countable ingredient that defines one batch.
///
/// Derived from the recipe rather than configured: a Fudge Cake BOM lists 30
/// eggs and yields one batch, so "30 eggs" is what the floor is actually
/// counting when it mixes one. That makes the batch chips speak the kitchen's
/// language — 30 eggs, 45 eggs — instead of an abstract 1 and 1.5.
@freezed
class BaseBatchUnit with _$BaseBatchUnit {
  const factory BaseBatchUnit({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @Default('') String uom,

    /// How many of it one batch takes.
    @JsonKey(name: 'qty_per_batch') @Default(0.0) double qtyPerBatch,
  }) = _BaseBatchUnit;

  factory BaseBatchUnit.fromJson(Map<String, dynamic> json) =>
      _$BaseBatchUnitFromJson(json);

  const BaseBatchUnit._();

  String get displayName => itemName.isEmpty ? itemCode : itemName;

  /// A zero here would render every batch as "0 eggs" and make the chips
  /// meaningless, so the card checks before showing them.
  bool get isUsable => qtyPerBatch > 0 && displayName.isNotEmpty;

  /// What [batches] of this base is counted as — 1.5 batches of Fudge Cake is
  /// 45 eggs.
  double countFor(double batches) => batches * qtyPerBatch;
}

/// One jar that eats this base, and how much of it each jar takes.
///
/// This is the whole point of the mix half of the screen: the floor knows it is
/// filling 40 mediums and 20 larges, not that it needs 2.0 Kg.
@freezed
class BaseJarConsumer with _$BaseJarConsumer {
  const factory BaseJarConsumer({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,

    /// In the BASE's stock UOM, per one jar.
    @JsonKey(name: 'qty_per_jar') @Default(0.0) double qtyPerJar,
  }) = _BaseJarConsumer;

  factory BaseJarConsumer.fromJson(Map<String, dynamic> json) =>
      _$BaseJarConsumerFromJson(json);

  const BaseJarConsumer._();

  String get displayName => itemName.isEmpty ? itemCode : itemName;

  /// A zero rate cannot be divided by and cannot be multiplied into anything
  /// useful, so such a row is left off the counter entirely.
  bool get isUsable => qtyPerJar > 0 && itemCode.isNotEmpty;
}

/// What the jars downstream will draw off this base.
///
/// Purely a hint: the operator's typed batch count is always the control, and
/// nothing here is ever written into the stepper without a tap.
@freezed
class BaseDemand with _$BaseDemand {
  const factory BaseDemand({
    @JsonKey(name: 'qty_required') @Default(0.0) double qtyRequired,
    @JsonKey(name: 'batches_required') @Default(0.0) double batchesRequired,
    @JsonKey(name: 'shortfall_batches') @Default(0.0) double shortfallBatches,

    /// Free text naming what generated the demand ("today's plan", a plan name,
    /// "sales suggestions"). Rendered verbatim when present.
    @Default('') String driver,
  }) = _BaseDemand;

  factory BaseDemand.fromJson(Map<String, dynamic> json) =>
      _$BaseDemandFromJson(json);

  const BaseDemand._();

  /// Freezer stock does not cover what the jars will take.
  bool get isShort => shortfallBatches > 0;
}

/// The component that caps `can_make_now_batches`.
///
/// Deliberately NOT the `LimitingComponent` used by the sales board: that one
/// carries a `reason` string, this endpoint carries an `is_missing_warehouse`
/// flag, and reusing the model would silently read every warehouse gap as an
/// ordinary shortage.
@freezed
class BaseLimitingComponent with _$BaseLimitingComponent {
  const factory BaseLimitingComponent({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'available_qty') @Default(0.0) double availableQty,
    @JsonKey(name: 'required_qty') @Default(0.0) double requiredQty,
    @JsonKey(name: 'is_missing_warehouse')
    @Default(false)
    bool isMissingWarehouse,

    /// Where else this material is sitting, when the backend looked.
    ///
    /// Null means nobody looked — deliberately distinct from `0.0` with an
    /// empty [alternatives] list, which means the lookup ran and there is none
    /// of it anywhere in the company.
    @JsonKey(name: 'available_elsewhere') double? availableElsewhere,
    List<StockAlternative>? alternatives,
  }) = _BaseLimitingComponent;

  factory BaseLimitingComponent.fromJson(Map<String, dynamic> json) =>
      _$BaseLimitingComponentFromJson(json);

  const BaseLimitingComponent._();

  String get displayName => itemName.isEmpty ? itemCode : itemName;
}
