// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunningBatchImpl _$$RunningBatchImplFromJson(Map<String, dynamic> json) =>
    _$RunningBatchImpl(
      workOrder: json['name'] as String? ?? '',
      itemCode: json['production_item'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      bomName: json['bom_no'] as String? ?? '',
      stockUom: json['stock_uom'] as String? ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      producedQty: (json['produced_qty'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      startedBy: json['jarz_started_by'] as String?,
      startedAt: json['jarz_started_at'] as String?,
      elapsedMinutes: (json['elapsed_minutes'] as num?)?.toInt() ?? 0,
      wipWarehouse: json['wip_warehouse'] as String?,
      fgWarehouse: json['fg_warehouse'] as String?,
      wipLeftoverQty: (json['wip_leftover_qty'] as num?)?.toDouble() ?? 0.0,
      sopVersion: json['jarz_sop_version'] as String?,
    );

Map<String, dynamic> _$$RunningBatchImplToJson(_$RunningBatchImpl instance) =>
    <String, dynamic>{
      'name': instance.workOrder,
      'production_item': instance.itemCode,
      'item_name': instance.itemName,
      'bom_no': instance.bomName,
      'stock_uom': instance.stockUom,
      'qty': instance.qty,
      'produced_qty': instance.producedQty,
      'status': instance.status,
      'jarz_started_by': instance.startedBy,
      'jarz_started_at': instance.startedAt,
      'elapsed_minutes': instance.elapsedMinutes,
      'wip_warehouse': instance.wipWarehouse,
      'fg_warehouse': instance.fgWarehouse,
      'wip_leftover_qty': instance.wipLeftoverQty,
      'jarz_sop_version': instance.sopVersion,
    };

_$BatchCostImpl _$$BatchCostImplFromJson(Map<String, dynamic> json) =>
    _$BatchCostImpl(
      workOrder: json['work_order'] as String? ?? '',
      materialCost: (json['material_cost'] as num?)?.toDouble() ?? 0.0,
      producedQty: (json['produced_qty'] as num?)?.toDouble() ?? 0.0,
      costPerUnit: (json['cost_per_unit'] as num?)?.toDouble(),
      standardPerUnit: (json['standard_per_unit'] as num?)?.toDouble(),
      varianceAmount: (json['variance_amount'] as num?)?.toDouble(),
      variancePct: (json['variance_pct'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? '',
    );

Map<String, dynamic> _$$BatchCostImplToJson(_$BatchCostImpl instance) =>
    <String, dynamic>{
      'work_order': instance.workOrder,
      'material_cost': instance.materialCost,
      'produced_qty': instance.producedQty,
      'cost_per_unit': instance.costPerUnit,
      'standard_per_unit': instance.standardPerUnit,
      'variance_amount': instance.varianceAmount,
      'variance_pct': instance.variancePct,
      'currency': instance.currency,
    };

_$StartBatchResultImpl _$$StartBatchResultImplFromJson(
  Map<String, dynamic> json,
) => _$StartBatchResultImpl(
  workOrder: json['work_order'] as String? ?? '',
  materialTransfer: json['material_transfer'] as String? ?? '',
  status: json['status'] as String? ?? '',
  plannedQty: (json['planned_qty'] as num?)?.toDouble() ?? 0.0,
  uom: json['uom'] as String? ?? '',
  wipWarehouse: json['wip_warehouse'] as String?,
  fgWarehouse: json['fg_warehouse'] as String?,
  estimatedMaterialCost: (json['estimated_material_cost'] as num?)?.toDouble(),
  sopVersion: json['jarz_sop_version'] as String?,
  components:
      (json['components'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <ComponentJson>[],
);

Map<String, dynamic> _$$StartBatchResultImplToJson(
  _$StartBatchResultImpl instance,
) => <String, dynamic>{
  'work_order': instance.workOrder,
  'material_transfer': instance.materialTransfer,
  'status': instance.status,
  'planned_qty': instance.plannedQty,
  'uom': instance.uom,
  'wip_warehouse': instance.wipWarehouse,
  'fg_warehouse': instance.fgWarehouse,
  'estimated_material_cost': instance.estimatedMaterialCost,
  'jarz_sop_version': instance.sopVersion,
  'components': instance.components,
};

_$FinishBatchResultImpl _$$FinishBatchResultImplFromJson(
  Map<String, dynamic> json,
) => _$FinishBatchResultImpl(
  workOrder: json['work_order'] as String? ?? '',
  manufactureEntry: json['manufacture_entry'] as String? ?? '',
  actualQty: (json['actual_qty'] as num?)?.toDouble() ?? 0.0,
  scrapQty: (json['scrap_qty'] as num?)?.toDouble() ?? 0.0,
  status: json['status'] as String? ?? '',
  wipLeftoverQty: (json['wip_leftover_qty'] as num?)?.toDouble() ?? 0.0,
  cost: json['cost'] == null
      ? null
      : BatchCost.fromJson(json['cost'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$FinishBatchResultImplToJson(
  _$FinishBatchResultImpl instance,
) => <String, dynamic>{
  'work_order': instance.workOrder,
  'manufacture_entry': instance.manufactureEntry,
  'actual_qty': instance.actualQty,
  'scrap_qty': instance.scrapQty,
  'status': instance.status,
  'wip_leftover_qty': instance.wipLeftoverQty,
  'cost': instance.cost,
};
