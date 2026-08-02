// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'running_batch.freezed.dart';
part 'running_batch.g.dart';

/// Freezed's source parser splits on `>`, so a nested generic written inline in
/// an `@Default(...)` literal breaks codegen. The alias keeps it single-level.
typedef ComponentJson = Map<String, dynamic>;

/// A batch that has been started but not finished.
///
/// Exists only because production is now two moments instead of one. The old
/// flow filed the material transfer and the manufacture entry back to back, so
/// there was never an in-progress state to show — or to attach an SOP to.
@freezed
class RunningBatch with _$RunningBatch {
  const factory RunningBatch({
    @JsonKey(name: 'name') @Default('') String workOrder,
    @JsonKey(name: 'production_item') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'bom_no') @Default('') String bomName,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @Default(0.0) double qty,
    @JsonKey(name: 'produced_qty') @Default(0.0) double producedQty,
    @Default('') String status,
    @JsonKey(name: 'jarz_started_by') String? startedBy,
    @JsonKey(name: 'jarz_started_at') String? startedAt,
    @JsonKey(name: 'elapsed_minutes') @Default(0) int elapsedMinutes,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,

    /// Material transferred into WIP but not consumed by the finish. Surfaced
    /// so it cannot drift silently — that drift only ever shows up months later
    /// as an unexplainable variance.
    @JsonKey(name: 'wip_leftover_qty') @Default(0.0) double wipLeftoverQty,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
  }) = _RunningBatch;

  factory RunningBatch.fromJson(Map<String, dynamic> json) =>
      _$RunningBatchFromJson(json);

  const RunningBatch._();

  bool get hasSop => (sopVersion ?? '').isNotEmpty;
  bool get hasWipLeftover => wipLeftoverQty > 0;

  /// Remaining planned quantity, never negative.
  double get outstandingQty {
    final remaining = qty - producedQty;
    return remaining > 0 ? remaining : 0;
  }
}

/// Payload of `get_batch_cost`.
@freezed
class BatchCost with _$BatchCost {
  const factory BatchCost({
    @JsonKey(name: 'work_order') @Default('') String workOrder,
    @JsonKey(name: 'material_cost') @Default(0.0) double materialCost,
    @JsonKey(name: 'produced_qty') @Default(0.0) double producedQty,

    /// Null when nothing has been produced yet — dividing by zero produces a
    /// number that looks real and is not.
    @JsonKey(name: 'cost_per_unit') double? costPerUnit,

    /// Null when the BOM carries no cost, rather than a fake zero.
    @JsonKey(name: 'standard_per_unit') double? standardPerUnit,
    @JsonKey(name: 'variance_amount') double? varianceAmount,
    @JsonKey(name: 'variance_pct') double? variancePct,
    @Default('') String currency,
  }) = _BatchCost;

  factory BatchCost.fromJson(Map<String, dynamic> json) =>
      _$BatchCostFromJson(json);

  const BatchCost._();

  bool get hasStandard => standardPerUnit != null && standardPerUnit! > 0;
  bool get isOverStandard => (varianceAmount ?? 0) > 0;
  bool get isComparable => costPerUnit != null && hasStandard;
}

/// Result of `start_production_batch`.
@freezed
class StartBatchResult with _$StartBatchResult {
  const factory StartBatchResult({
    @JsonKey(name: 'work_order') @Default('') String workOrder,
    @JsonKey(name: 'material_transfer') @Default('') String materialTransfer,
    @Default('') String status,
    @JsonKey(name: 'planned_qty') @Default(0.0) double plannedQty,
    @Default('') String uom,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,
    @JsonKey(name: 'estimated_material_cost') double? estimatedMaterialCost,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
    @Default(<ComponentJson>[]) List<ComponentJson> components,
  }) = _StartBatchResult;

  factory StartBatchResult.fromJson(Map<String, dynamic> json) =>
      _$StartBatchResultFromJson(json);
}

/// Result of `finish_production_batch`.
@freezed
class FinishBatchResult with _$FinishBatchResult {
  const factory FinishBatchResult({
    @JsonKey(name: 'work_order') @Default('') String workOrder,
    @JsonKey(name: 'manufacture_entry') @Default('') String manufactureEntry,
    @JsonKey(name: 'actual_qty') @Default(0.0) double actualQty,
    @JsonKey(name: 'scrap_qty') @Default(0.0) double scrapQty,
    @Default('') String status,
    @JsonKey(name: 'wip_leftover_qty') @Default(0.0) double wipLeftoverQty,
    BatchCost? cost,
  }) = _FinishBatchResult;

  factory FinishBatchResult.fromJson(Map<String, dynamic> json) =>
      _$FinishBatchResultFromJson(json);

  const FinishBatchResult._();

  bool get hasWipLeftover => wipLeftoverQty > 0;
}
