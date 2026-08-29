// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_alternative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockAlternativeImpl _$$StockAlternativeImplFromJson(
  Map<String, dynamic> json,
) => _$StockAlternativeImpl(
  warehouse: json['warehouse'] as String? ?? '',
  availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$StockAlternativeImplToJson(
  _$StockAlternativeImpl instance,
) => <String, dynamic>{
  'warehouse': instance.warehouse,
  'available_qty': instance.availableQty,
};
