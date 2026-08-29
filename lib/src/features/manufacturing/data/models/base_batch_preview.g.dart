// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_batch_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaseBatchPreviewImpl _$$BaseBatchPreviewImplFromJson(
  Map<String, dynamic> json,
) => _$BaseBatchPreviewImpl(
  itemCode: json['item_code'] as String? ?? '',
  bomName: json['bom_name'] as String? ?? '',
  company: json['company'] as String? ?? '',
  batches: (json['batches'] as num?)?.toDouble() ?? 0.0,
  batchYield: (json['batch_yield'] as num?)?.toDouble() ?? 1.0,
  itemQty: (json['item_qty'] as num?)?.toDouble() ?? 0.0,
  stockUom: json['stock_uom'] as String? ?? '',
  components:
      (json['components'] as List<dynamic>?)
          ?.map((e) => BasePreviewComponent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BasePreviewComponent>[],
  hasShortage: json['has_shortage'] as bool? ?? false,
  estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
  runSizeOk: json['run_size_ok'] as bool? ?? true,
  runSizes: (json['run_sizes'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  hasSop: json['has_sop'] as bool? ?? false,
);

Map<String, dynamic> _$$BaseBatchPreviewImplToJson(
  _$BaseBatchPreviewImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'bom_name': instance.bomName,
  'company': instance.company,
  'batches': instance.batches,
  'batch_yield': instance.batchYield,
  'item_qty': instance.itemQty,
  'stock_uom': instance.stockUom,
  'components': instance.components,
  'has_shortage': instance.hasShortage,
  'estimated_cost': instance.estimatedCost,
  'run_size_ok': instance.runSizeOk,
  'run_sizes': instance.runSizes,
  'has_sop': instance.hasSop,
};

_$BasePreviewComponentImpl _$$BasePreviewComponentImplFromJson(
  Map<String, dynamic> json,
) => _$BasePreviewComponentImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  uom: json['uom'] as String? ?? '',
  requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0.0,
  availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0.0,
  shortfall: (json['shortfall'] as num?)?.toDouble() ?? 0.0,
  sourceWarehouse: json['source_warehouse'] as String?,
  availableElsewhere: (json['available_elsewhere'] as num?)?.toDouble(),
  alternatives: (json['alternatives'] as List<dynamic>?)
      ?.map((e) => StockAlternative.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$BasePreviewComponentImplToJson(
  _$BasePreviewComponentImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'uom': instance.uom,
  'required_qty': instance.requiredQty,
  'available_qty': instance.availableQty,
  'shortfall': instance.shortfall,
  'source_warehouse': instance.sourceWarehouse,
  'available_elsewhere': instance.availableElsewhere,
  'alternatives': instance.alternatives,
};
