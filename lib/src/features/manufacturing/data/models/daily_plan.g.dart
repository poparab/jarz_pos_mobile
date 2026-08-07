// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyPlanItemImpl _$$DailyPlanItemImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanItemImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      itemGroup: json['item_group'] as String? ?? '',
      defaultBom: json['default_bom'] as String?,
      mixQtyPerUnit: (json['mix_qty_per_unit'] as num?)?.toDouble() ?? 0.0,
      jarsPerBatch: (json['jars_per_batch'] as num?)?.toDouble(),
      usesMix: json['uses_mix'] as bool? ?? false,
    );

Map<String, dynamic> _$$DailyPlanItemImplToJson(_$DailyPlanItemImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'item_group': instance.itemGroup,
      'default_bom': instance.defaultBom,
      'mix_qty_per_unit': instance.mixQtyPerUnit,
      'jars_per_batch': instance.jarsPerBatch,
      'uses_mix': instance.usesMix,
    };

_$DailyPlanMixImpl _$$DailyPlanMixImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanMixImpl(
      itemCode: json['item_code'] as String? ?? '',
      defaultBom: json['default_bom'] as String?,
      batchQty: (json['batch_qty'] as num?)?.toDouble() ?? 0.0,
      uom: json['uom'] as String? ?? '',
    );

Map<String, dynamic> _$$DailyPlanMixImplToJson(_$DailyPlanMixImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'default_bom': instance.defaultBom,
      'batch_qty': instance.batchQty,
      'uom': instance.uom,
    };

_$MixerRunImpl _$$MixerRunImplFromJson(Map<String, dynamic> json) =>
    _$MixerRunImpl(
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      quality:
          $enumDecodeNullable(_$RunQualityEnumMap, json['quality']) ??
          RunQuality.acceptable,
    );

Map<String, dynamic> _$$MixerRunImplToJson(_$MixerRunImpl instance) =>
    <String, dynamic>{
      'size': instance.size,
      'quality': _$RunQualityEnumMap[instance.quality]!,
    };

const _$RunQualityEnumMap = {
  RunQuality.preferred: 'preferred',
  RunQuality.acceptable: 'acceptable',
  RunQuality.poor: 'poor',
};

_$DailyPlanPreviewImpl _$$DailyPlanPreviewImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPlanPreviewImpl(
  mix: json['mix'] == null
      ? const DailyPlanMix()
      : DailyPlanMix.fromJson(json['mix'] as Map<String, dynamic>),
  totalMixQty: (json['total_mix_qty'] as num?)?.toDouble() ?? 0.0,
  requiredBatches: (json['required_batches'] as num?)?.toDouble() ?? 0.0,
  plannedBatches: (json['planned_batches'] as num?)?.toDouble() ?? 0.0,
  runs:
      (json['run_detail'] as List<dynamic>?)
          ?.map((e) => MixerRun.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MixerRun>[],
  runCount: (json['run_count'] as num?)?.toInt() ?? 0,
  overproductionBatches:
      (json['overproduction_batches'] as num?)?.toDouble() ?? 0.0,
  capped: json['capped'] as bool? ?? false,
  breakdown:
      (json['breakdown'] as List<dynamic>?)
          ?.map((e) => DailyPlanBreakdown.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DailyPlanBreakdown>[],
  materials: json['materials'] == null
      ? null
      : DailyPlanMaterials.fromJson(json['materials'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$DailyPlanPreviewImplToJson(
  _$DailyPlanPreviewImpl instance,
) => <String, dynamic>{
  'mix': instance.mix,
  'total_mix_qty': instance.totalMixQty,
  'required_batches': instance.requiredBatches,
  'planned_batches': instance.plannedBatches,
  'run_detail': instance.runs,
  'run_count': instance.runCount,
  'overproduction_batches': instance.overproductionBatches,
  'capped': instance.capped,
  'breakdown': instance.breakdown,
  'materials': instance.materials,
};

_$DailyPlanBreakdownImpl _$$DailyPlanBreakdownImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPlanBreakdownImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  plannedQty: (json['planned_qty'] as num?)?.toDouble() ?? 0.0,
  mixQty: (json['mix_qty'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$DailyPlanBreakdownImplToJson(
  _$DailyPlanBreakdownImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'planned_qty': instance.plannedQty,
  'mix_qty': instance.mixQty,
};

_$DailyPlanMaterialsImpl _$$DailyPlanMaterialsImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPlanMaterialsImpl(
  ok: json['ok'] as bool? ?? true,
  shortages:
      (json['shortages'] as List<dynamic>?)
          ?.map((e) => MaterialShortage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MaterialShortage>[],
  unavailable: json['unavailable'] as bool? ?? false,
);

Map<String, dynamic> _$$DailyPlanMaterialsImplToJson(
  _$DailyPlanMaterialsImpl instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'shortages': instance.shortages,
  'unavailable': instance.unavailable,
};

_$MaterialShortageImpl _$$MaterialShortageImplFromJson(
  Map<String, dynamic> json,
) => _$MaterialShortageImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  uom: json['uom'] as String? ?? '',
  requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0.0,
  availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0.0,
  missingQty: (json['missing_qty'] as num?)?.toDouble() ?? 0.0,
  reason: json['reason'] as String? ?? '',
);

Map<String, dynamic> _$$MaterialShortageImplToJson(
  _$MaterialShortageImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'uom': instance.uom,
  'required_qty': instance.requiredQty,
  'available_qty': instance.availableQty,
  'missing_qty': instance.missingQty,
  'reason': instance.reason,
};

_$DailyPlanImpl _$$DailyPlanImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanImpl(
      name: json['name'] as String? ?? '',
      planDate: json['plan_date'] as String? ?? '',
      status: json['status'] as String? ?? 'Draft',
      mixItem: json['mix_item'] as String? ?? '',
      mixBatchQty: (json['mix_batch_qty'] as num?)?.toDouble() ?? 0.0,
      mixUom: json['mix_uom'] as String? ?? '',
      totalMixQty: (json['total_mix_qty'] as num?)?.toDouble() ?? 0.0,
      requiredBatches: (json['required_batches'] as num?)?.toDouble() ?? 0.0,
      plannedBatches: (json['planned_batches'] as num?)?.toDouble() ?? 0.0,
      mixerRuns: json['mixer_runs'] as String? ?? '',
      runCount: (json['run_count'] as num?)?.toInt() ?? 0,
      overproductionBatches:
          (json['overproduction_batches'] as num?)?.toDouble() ?? 0.0,
      overproductionNote: json['overproduction_note'] as String?,
      actualBatchesRun: (json['actual_batches_run'] as num?)?.toDouble() ?? 0.0,
      totalPlannedUnits: (json['total_planned_units'] as num?)?.toInt() ?? 0,
      totalActualUnits: (json['total_actual_units'] as num?)?.toInt() ?? 0,
      realisedUnitsPerBatch:
          (json['realised_units_per_batch'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => DailyPlanLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DailyPlanLine>[],
    );

Map<String, dynamic> _$$DailyPlanImplToJson(_$DailyPlanImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'plan_date': instance.planDate,
      'status': instance.status,
      'mix_item': instance.mixItem,
      'mix_batch_qty': instance.mixBatchQty,
      'mix_uom': instance.mixUom,
      'total_mix_qty': instance.totalMixQty,
      'required_batches': instance.requiredBatches,
      'planned_batches': instance.plannedBatches,
      'mixer_runs': instance.mixerRuns,
      'run_count': instance.runCount,
      'overproduction_batches': instance.overproductionBatches,
      'overproduction_note': instance.overproductionNote,
      'actual_batches_run': instance.actualBatchesRun,
      'total_planned_units': instance.totalPlannedUnits,
      'total_actual_units': instance.totalActualUnits,
      'realised_units_per_batch': instance.realisedUnitsPerBatch,
      'notes': instance.notes,
      'lines': instance.lines,
    };

_$DailyPlanLineImpl _$$DailyPlanLineImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanLineImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      itemGroup: json['item_group'] as String? ?? '',
      plannedQty: (json['planned_qty'] as num?)?.toInt() ?? 0,
      actualQty: (json['actual_qty'] as num?)?.toInt(),
      varianceQty: (json['variance_qty'] as num?)?.toInt() ?? 0,
      mixQty: (json['mix_qty'] as num?)?.toDouble() ?? 0.0,
      jarsPerBatch: (json['jars_per_batch'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$DailyPlanLineImplToJson(_$DailyPlanLineImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'item_group': instance.itemGroup,
      'planned_qty': instance.plannedQty,
      'actual_qty': instance.actualQty,
      'variance_qty': instance.varianceQty,
      'mix_qty': instance.mixQty,
      'jars_per_batch': instance.jarsPerBatch,
      'notes': instance.notes,
    };

_$BomReadinessImpl _$$BomReadinessImplFromJson(Map<String, dynamic> json) =>
    _$BomReadinessImpl(
      ok: json['ok'] as bool? ?? false,
      mixItem: json['mix_item'] as String? ?? '',
      readyItems: (json['ready_items'] as num?)?.toInt() ?? 0,
      issueCount: (json['issue_count'] as num?)?.toInt() ?? 0,
      issues:
          (json['issues'] as List<dynamic>?)
              ?.map(
                (e) => BomReadinessIssue.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <BomReadinessIssue>[],
    );

Map<String, dynamic> _$$BomReadinessImplToJson(_$BomReadinessImpl instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'mix_item': instance.mixItem,
      'ready_items': instance.readyItems,
      'issue_count': instance.issueCount,
      'issues': instance.issues,
    };

_$BomReadinessIssueImpl _$$BomReadinessIssueImplFromJson(
  Map<String, dynamic> json,
) => _$BomReadinessIssueImpl(
  itemCode: json['item_code'] as String? ?? '',
  severity: json['severity'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  detail: json['detail'] as String? ?? '',
);

Map<String, dynamic> _$$BomReadinessIssueImplToJson(
  _$BomReadinessIssueImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'severity': instance.severity,
  'reason': instance.reason,
  'detail': instance.detail,
};

_$DailyPlanTemplateImpl _$$DailyPlanTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPlanTemplateImpl(
  planDate: json['plan_date'] as String? ?? '',
  mix: json['mix'] == null
      ? const DailyPlanMix()
      : DailyPlanMix.fromJson(json['mix'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => DailyPlanItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DailyPlanItem>[],
  existingPlan: json['existing_plan'] as String?,
);

Map<String, dynamic> _$$DailyPlanTemplateImplToJson(
  _$DailyPlanTemplateImpl instance,
) => <String, dynamic>{
  'plan_date': instance.planDate,
  'mix': instance.mix,
  'items': instance.items,
  'existing_plan': instance.existingPlan,
};
