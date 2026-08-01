// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BatchLineImpl _$$BatchLineImplFromJson(Map<String, dynamic> json) =>
    _$BatchLineImpl(
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String,
      bomName: json['bom_name'] as String,
      stockUom: json['stock_uom'] as String? ?? '',
      bomQtyYield: (json['bom_qty_yield'] as num?)?.toDouble() ?? 1.0,
      batches: (json['batches'] as num?)?.toDouble() ?? 1.0,
      components:
          (json['components'] as List<dynamic>?)
              ?.map((e) => BomComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BomComponent>[],
    );

Map<String, dynamic> _$$BatchLineImplToJson(_$BatchLineImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'bom_name': instance.bomName,
      'stock_uom': instance.stockUom,
      'bom_qty_yield': instance.bomQtyYield,
      'batches': instance.batches,
      'components': instance.components,
    };

_$ProductionBasketImpl _$$ProductionBasketImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionBasketImpl(
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => BatchLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BatchLine>[],
  postingDate: json['posting_date'] == null
      ? null
      : DateTime.parse(json['posting_date'] as String),
);

Map<String, dynamic> _$$ProductionBasketImplToJson(
  _$ProductionBasketImpl instance,
) => <String, dynamic>{
  'lines': instance.lines,
  'posting_date': instance.postingDate?.toIso8601String(),
};
