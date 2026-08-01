// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bom_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BomItemSummaryImpl _$$BomItemSummaryImplFromJson(Map<String, dynamic> json) =>
    _$BomItemSummaryImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      stockUom: json['stock_uom'] as String? ?? '',
      defaultBom: json['default_bom'] as String? ?? '',
      bomQty: (json['bom_qty'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$BomItemSummaryImplToJson(
  _$BomItemSummaryImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'stock_uom': instance.stockUom,
  'default_bom': instance.defaultBom,
  'bom_qty': instance.bomQty,
};

_$BomDetailsImpl _$$BomDetailsImplFromJson(Map<String, dynamic> json) =>
    _$BomDetailsImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      stockUom: json['stock_uom'] as String? ?? '',
      defaultBom: json['default_bom'] as String? ?? '',
      bomQty: (json['bom_qty'] as num?)?.toDouble() ?? 1.0,
      components:
          (json['components'] as List<dynamic>?)
              ?.map((e) => BomComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BomComponent>[],
    );

Map<String, dynamic> _$$BomDetailsImplToJson(_$BomDetailsImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'stock_uom': instance.stockUom,
      'default_bom': instance.defaultBom,
      'bom_qty': instance.bomQty,
      'components': instance.components,
    };

_$BomComponentImpl _$$BomComponentImplFromJson(Map<String, dynamic> json) =>
    _$BomComponentImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      uom: json['uom'] as String? ?? '',
      qtyPerBom: (json['qty_per_bom'] as num?)?.toDouble() ?? 0.0,
      availableQty: (json['available_qty'] as num?)?.toDouble(),
      sourceWarehouse: json['source_warehouse'] as String?,
    );

Map<String, dynamic> _$$BomComponentImplToJson(_$BomComponentImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'uom': instance.uom,
      'qty_per_bom': instance.qtyPerBom,
      'available_qty': instance.availableQty,
      'source_warehouse': instance.sourceWarehouse,
    };
