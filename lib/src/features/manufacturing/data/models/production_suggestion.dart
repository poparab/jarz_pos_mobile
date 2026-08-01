// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'production_suggestion.freezed.dart';
part 'production_suggestion.g.dart';

/// Status buckets returned by the backend, mirroring
/// `jarz_pos.services.production_planning`.
abstract final class ProductionStatus {
  static const critical = 'critical';
  static const low = 'low';
  static const ok = 'ok';
  static const overstocked = 'overstocked';
  static const noVelocity = 'no_velocity';

  /// The buckets "Fill the day" acts on.
  static const actionable = <String>{critical, low};
}

/// Payload of `get_production_suggestions`.
@freezed
class ProductionSuggestionsPage with _$ProductionSuggestionsPage {
  const factory ProductionSuggestionsPage({
    @JsonKey(name: 'generated_on') String? generatedOn,
    @Default('') String company,
    @Default(ProductionSeason()) ProductionSeason season,
    @JsonKey(name: 'default_target_days') @Default(7) int defaultTargetDays,
    @Default(ProductionThresholds()) ProductionThresholds thresholds,
    @JsonKey(name: 'velocity_updated_on') String? velocityUpdatedOn,
    @JsonKey(name: 'capacity_included') @Default(true) bool capacityIncluded,
    @Default(<ProductionSuggestion>[]) List<ProductionSuggestion> items,
    @Default(ProductionSummary()) ProductionSummary summary,
  }) = _ProductionSuggestionsPage;

  factory ProductionSuggestionsPage.fromJson(Map<String, dynamic> json) =>
      _$ProductionSuggestionsPageFromJson(json);
}

@freezed
class ProductionSeason with _$ProductionSeason {
  const factory ProductionSeason({
    String? name,
    @Default(1.0) double multiplier,
  }) = _ProductionSeason;

  factory ProductionSeason.fromJson(Map<String, dynamic> json) =>
      _$ProductionSeasonFromJson(json);
}

@freezed
class ProductionThresholds with _$ProductionThresholds {
  const factory ProductionThresholds({
    @JsonKey(name: 'critical_days') @Default(5) int criticalDays,
    @JsonKey(name: 'watch_days') @Default(14) int watchDays,
    @JsonKey(name: 'overstock_days') @Default(90) int overstockDays,
  }) = _ProductionThresholds;

  factory ProductionThresholds.fromJson(Map<String, dynamic> json) =>
      _$ProductionThresholdsFromJson(json);
}

@freezed
class ProductionSummary with _$ProductionSummary {
  const factory ProductionSummary({
    @Default(0) int critical,
    @Default(0) int low,
    @Default(0) int ok,
    @Default(0) int overstocked,
    @JsonKey(name: 'no_velocity') @Default(0) int noVelocity,
    @JsonKey(name: 'total_suggested_batches') @Default(0) int totalSuggestedBatches,
    @JsonKey(name: 'capped_by_materials') @Default(0) int cappedByMaterials,
  }) = _ProductionSummary;

  factory ProductionSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductionSummaryFromJson(json);

  const ProductionSummary._();

  /// Items the board wants somebody to act on.
  int get actionable => critical + low;
}

/// One producible item, with the arithmetic already done server-side.
@freezed
class ProductionSuggestion with _$ProductionSuggestion {
  const factory ProductionSuggestion({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @JsonKey(name: 'default_bom') @Default('') String defaultBom,
    @JsonKey(name: 'bom_qty') @Default(1.0) double bomQty,
    String? company,
    @JsonKey(name: 'on_hand') @Default(0.0) double onHand,
    @JsonKey(name: 'velocity_30d') @Default(0.0) double velocity30d,
    @JsonKey(name: 'velocity_60d') @Default(0.0) double velocity60d,
    @JsonKey(name: 'velocity_trend') String? velocityTrend,
    @JsonKey(name: 'season_multiplier') @Default(1.0) double seasonMultiplier,
    @JsonKey(name: 'effective_velocity') @Default(0.0) double effectiveVelocity,
    @JsonKey(name: 'target_days') @Default(7) int targetDays,
    @JsonKey(name: 'target_days_source') @Default('default') String targetDaysSource,

    /// Null means the item never sells — deliberately distinct from a large
    /// number, which the stored `jarz_days_of_stock` field cannot express.
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    @Default(ProductionStatus.ok) String status,

    /// Stock on hand is below zero. The suggestion deliberately ignores the
    /// hole — for a finished good a negative Bin almost always means unrecorded
    /// production or a count lag, not units owed to customers — so the row says
    /// so instead, and somebody counts the item.
    @JsonKey(name: 'stock_is_negative') @Default(false) bool stockIsNegative,
    @JsonKey(name: 'suggested_batches') @Default(0) int suggestedBatches,
    @JsonKey(name: 'suggested_units') @Default(0.0) double suggestedUnits,

    /// Null when capacity was not computed (`include_capacity=0`).
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component') LimitingComponent? limitingComponent,
  }) = _ProductionSuggestion;

  factory ProductionSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ProductionSuggestionFromJson(json);

  const ProductionSuggestion._();

  /// Whether materials cap the batch count below what demand asks for.
  bool get isCappedByMaterials =>
      canMakeNowBatches != null && suggestedBatches > canMakeNowBatches!;

  /// Batches actually worth queueing: what demand wants, capped by what the
  /// warehouse can cover. This is the number "Fill the day" adds.
  int get achievableBatches {
    final capacity = canMakeNowBatches;
    if (capacity == null) return suggestedBatches;
    return suggestedBatches < capacity ? suggestedBatches : capacity;
  }

  bool get isActionable =>
      ProductionStatus.actionable.contains(status) && suggestedBatches > 0;

  /// True when the item is on the board only for reference — no velocity data,
  /// so no suggestion can be made either way.
  bool get hasNoVelocity => status == ProductionStatus.noVelocity;
}

/// The component that caps `can_make_now_batches`.
@freezed
class LimitingComponent with _$LimitingComponent {
  const factory LimitingComponent({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @Default('') String uom,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
    @JsonKey(name: 'required_qty') @Default(0.0) double requiredQty,
    @JsonKey(name: 'available_qty') @Default(0.0) double availableQty,

    /// `insufficient_stock` or `missing_source_warehouse`.
    @Default('insufficient_stock') String reason,
  }) = _LimitingComponent;

  factory LimitingComponent.fromJson(Map<String, dynamic> json) =>
      _$LimitingComponentFromJson(json);

  const LimitingComponent._();

  bool get isMissingWarehouse => reason == 'missing_source_warehouse';
}
