// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'stock_alternative.dart';

part 'base_item.freezed.dart';
part 'base_item.g.dart';

/// Where the per-row `demand` block came from.
///
/// A base is never sold, so demand for it can only be derived from something
/// downstream: today's saved jar plan, or the ranked sales suggestions. `none`
/// means neither was available and the rows carry no demand at all — which is
/// a normal answer, not an error.
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
  }) = _BaseItemsPage;

  factory BaseItemsPage.fromJson(Map<String, dynamic> json) =>
      _$BaseItemsPageFromJson(json);

  const BaseItemsPage._();

  bool get isEmpty => items.isEmpty;

  /// True when no row carries a demand block, so the hint line is pointless.
  bool get hasDemand => demandSource != BaseDemandSource.none;
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
    @JsonKey(name: 'has_sop') @Default(false) bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,
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
