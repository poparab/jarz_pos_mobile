// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosProfileImpl _$$PosProfileImplFromJson(Map<String, dynamic> json) =>
    _$PosProfileImpl(
      name: json['name'] as String,
      title: json['title'] as String,
      warehouse: json['warehouse'] as String,
      costCenter: json['cost_center'] as String,
      itemGroups: (json['item_groups'] as List<dynamic>)
          .map((e) => PosItemGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerGroups: (json['customer_groups'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      priceList: json['price_list'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$$PosProfileImplToJson(_$PosProfileImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'warehouse': instance.warehouse,
      'cost_center': instance.costCenter,
      'item_groups': instance.itemGroups,
      'customer_groups': instance.customerGroups,
      'price_list': instance.priceList,
      'currency': instance.currency,
    };

_$PosItemGroupImpl _$$PosItemGroupImplFromJson(Map<String, dynamic> json) =>
    _$PosItemGroupImpl(itemGroup: json['item_group'] as String);

Map<String, dynamic> _$$PosItemGroupImplToJson(_$PosItemGroupImpl instance) =>
    <String, dynamic>{'item_group': instance.itemGroup};

_$PosItemImpl _$$PosItemImplFromJson(Map<String, dynamic> json) =>
    _$PosItemImpl(
      name: json['name'] as String,
      itemName: json['item_name'] as String,
      itemGroup: json['item_group'] as String,
      stockUom: json['stock_uom'] as String,
      rate: (json['rate'] as num).toDouble(),
      actualQty: (json['actual_qty'] as num).toDouble(),
      image: json['image'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$PosItemImplToJson(_$PosItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'item_name': instance.itemName,
      'item_group': instance.itemGroup,
      'stock_uom': instance.stockUom,
      'rate': instance.rate,
      'actual_qty': instance.actualQty,
      'image': instance.image,
      'description': instance.description,
    };

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      name: json['name'] as String,
      customerName: json['customer_name'] as String,
      customerGroup: json['customer_group'] as String,
      customerType: json['customer_type'] as String,
      mobileNo: json['mobile_no'] as String?,
      emailId: json['email_id'] as String?,
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'customer_name': instance.customerName,
      'customer_group': instance.customerGroup,
      'customer_type': instance.customerType,
      'mobile_no': instance.mobileNo,
      'email_id': instance.emailId,
    };
