// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_plan.freezed.dart';
part 'daily_plan.g.dart';

/// How well a given mixer run size actually mixes.
///
/// Not cosmetic: the server optimises the day's split against this, so the
/// screen has to show it or the plan looks arbitrary. 1.5 is what the recipe is
/// built around, 2 stretches the machine, 1 leaves too little in the bowl.
enum RunQuality {
  @JsonValue('preferred')
  preferred,
  @JsonValue('acceptable')
  acceptable,
  @JsonValue('poor')
  poor,
}

/// One fillable item on the morning screen, with what the BOM says it costs
/// in mix.
@freezed
class DailyPlanItem with _$DailyPlanItem {
  const factory DailyPlanItem({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'item_group') @Default('') String itemGroup,
    @JsonKey(name: 'default_bom') String? defaultBom,

    /// Mix consumed by one jar, in the mix item's stock UOM.
    @JsonKey(name: 'mix_qty_per_unit') @Default(0.0) double mixQtyPerUnit,

    /// Jars one full batch yields — the 120-or-77 the floor already knows.
    /// Null when the flavour uses no mix at all.
    @JsonKey(name: 'jars_per_batch') double? jarsPerBatch,
    @JsonKey(name: 'uses_mix') @Default(false) bool usesMix,
  }) = _DailyPlanItem;

  factory DailyPlanItem.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanItemFromJson(json);
}

/// The mix sub-assembly and what one batch of it is.
@freezed
class DailyPlanMix with _$DailyPlanMix {
  const factory DailyPlanMix({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'default_bom') String? defaultBom,
    @JsonKey(name: 'batch_qty') @Default(0.0) double batchQty,
    @Default('') String uom,
  }) = _DailyPlanMix;

  factory DailyPlanMix.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanMixFromJson(json);
}

/// One scheduled mixer run.
@freezed
class MixerRun with _$MixerRun {
  const factory MixerRun({
    @Default(0.0) double size,
    @Default(RunQuality.acceptable) RunQuality quality,
  }) = _MixerRun;

  factory MixerRun.fromJson(Map<String, dynamic> json) =>
      _$MixerRunFromJson(json);
}

/// Server response for `preview_plan` — the live answer while somebody types.
@freezed
class DailyPlanPreview with _$DailyPlanPreview {
  const factory DailyPlanPreview({
    @Default(DailyPlanMix()) DailyPlanMix mix,
    @JsonKey(name: 'total_mix_qty') @Default(0.0) double totalMixQty,
    @JsonKey(name: 'required_batches') @Default(0.0) double requiredBatches,
    @JsonKey(name: 'planned_batches') @Default(0.0) double plannedBatches,
    @JsonKey(name: 'run_detail') @Default(<MixerRun>[]) List<MixerRun> runs,
    @JsonKey(name: 'run_count') @Default(0) int runCount,
    @JsonKey(name: 'overproduction_batches')
    @Default(0.0)
    double overproductionBatches,

    /// True when the mixer is not configured or the day exceeds what the
    /// planner will schedule — the split shown is not a usable answer.
    @Default(false) bool capped,
    @Default(<DailyPlanBreakdown>[]) List<DailyPlanBreakdown> breakdown,
    DailyPlanMaterials? materials,
  }) = _DailyPlanPreview;

  factory DailyPlanPreview.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanPreviewFromJson(json);
}

@freezed
class DailyPlanBreakdown with _$DailyPlanBreakdown {
  const factory DailyPlanBreakdown({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'planned_qty') @Default(0.0) double plannedQty,
    @JsonKey(name: 'mix_qty') @Default(0.0) double mixQty,
  }) = _DailyPlanBreakdown;

  factory DailyPlanBreakdown.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanBreakdownFromJson(json);
}

/// Raw-material coverage for the whole day, measured against one stock snapshot.
@freezed
class DailyPlanMaterials with _$DailyPlanMaterials {
  const factory DailyPlanMaterials({
    @Default(true) bool ok,
    @Default(<MaterialShortage>[]) List<MaterialShortage> shortages,

    /// Set when the roll-up could not be computed, so an empty shortage list
    /// reads as "not checked" rather than "all clear".
    @Default(false) bool unavailable,
  }) = _DailyPlanMaterials;

  factory DailyPlanMaterials.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanMaterialsFromJson(json);
}

@freezed
class MaterialShortage with _$MaterialShortage {
  const factory MaterialShortage({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @Default('') String uom,
    @JsonKey(name: 'required_qty') @Default(0.0) double requiredQty,
    @JsonKey(name: 'available_qty') @Default(0.0) double availableQty,
    @JsonKey(name: 'missing_qty') @Default(0.0) double missingQty,
    @Default('') String reason,
  }) = _MaterialShortage;

  factory MaterialShortage.fromJson(Map<String, dynamic> json) =>
      _$MaterialShortageFromJson(json);
}

/// A saved plan document.
@freezed
class DailyPlan with _$DailyPlan {
  const factory DailyPlan({
    @Default('') String name,
    @JsonKey(name: 'plan_date') @Default('') String planDate,
    @Default('Draft') String status,
    @JsonKey(name: 'mix_item') @Default('') String mixItem,
    @JsonKey(name: 'mix_batch_qty') @Default(0.0) double mixBatchQty,
    @JsonKey(name: 'mix_uom') @Default('') String mixUom,
    @JsonKey(name: 'total_mix_qty') @Default(0.0) double totalMixQty,
    @JsonKey(name: 'required_batches') @Default(0.0) double requiredBatches,
    @JsonKey(name: 'planned_batches') @Default(0.0) double plannedBatches,
    @JsonKey(name: 'mixer_runs') @Default('') String mixerRuns,
    @JsonKey(name: 'run_count') @Default(0) int runCount,
    @JsonKey(name: 'overproduction_batches')
    @Default(0.0)
    double overproductionBatches,
    @JsonKey(name: 'overproduction_note') String? overproductionNote,
    @JsonKey(name: 'actual_batches_run') @Default(0.0) double actualBatchesRun,
    @JsonKey(name: 'total_planned_units') @Default(0) int totalPlannedUnits,
    @JsonKey(name: 'total_actual_units') @Default(0) int totalActualUnits,
    @JsonKey(name: 'realised_units_per_batch')
    @Default(0.0)
    double realisedUnitsPerBatch,
    String? notes,
    @Default(<DailyPlanLine>[]) List<DailyPlanLine> lines,
  }) = _DailyPlan;

  factory DailyPlan.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanFromJson(json);

  const DailyPlan._();

  bool get isClosed => status == 'Closed';
  bool get isCancelled => status == 'Cancelled';
}

@freezed
class DailyPlanLine with _$DailyPlanLine {
  const factory DailyPlanLine({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'item_group') @Default('') String itemGroup,
    @JsonKey(name: 'planned_qty') @Default(0) int plannedQty,

    /// Null means not counted yet — deliberately distinct from a counted zero,
    /// all the way from the DocType to this screen.
    @JsonKey(name: 'actual_qty') int? actualQty,
    @JsonKey(name: 'variance_qty') @Default(0) int varianceQty,
    @JsonKey(name: 'mix_qty') @Default(0.0) double mixQty,
    @JsonKey(name: 'jars_per_batch') @Default(0.0) double jarsPerBatch,
    String? notes,
  }) = _DailyPlanLine;

  factory DailyPlanLine.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanLineFromJson(json);
}

/// Whether the BOMs can answer the batch question yet.
@freezed
class BomReadiness with _$BomReadiness {
  const factory BomReadiness({
    @Default(false) bool ok,
    @JsonKey(name: 'mix_item') @Default('') String mixItem,
    @JsonKey(name: 'ready_items') @Default(0) int readyItems,
    @JsonKey(name: 'issue_count') @Default(0) int issueCount,
    @Default(<BomReadinessIssue>[]) List<BomReadinessIssue> issues,
  }) = _BomReadiness;

  factory BomReadiness.fromJson(Map<String, dynamic> json) =>
      _$BomReadinessFromJson(json);
}

@freezed
class BomReadinessIssue with _$BomReadinessIssue {
  const factory BomReadinessIssue({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @Default('') String severity,
    @Default('') String reason,
    @Default('') String detail,
  }) = _BomReadinessIssue;

  factory BomReadinessIssue.fromJson(Map<String, dynamic> json) =>
      _$BomReadinessIssueFromJson(json);
}

/// Payload of `get_plan_template`.
@freezed
class DailyPlanTemplate with _$DailyPlanTemplate {
  const factory DailyPlanTemplate({
    @JsonKey(name: 'plan_date') @Default('') String planDate,
    @Default(DailyPlanMix()) DailyPlanMix mix,
    @Default(<DailyPlanItem>[]) List<DailyPlanItem> items,
    @JsonKey(name: 'existing_plan') String? existingPlan,
  }) = _DailyPlanTemplate;

  factory DailyPlanTemplate.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanTemplateFromJson(json);
}
