// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryPriceImpl _$$CategoryPriceImplFromJson(Map<String, dynamic> json) =>
    _$CategoryPriceImpl(
      itemGroup: json['item_group'] as String,
      rate: json['rate'] as num?,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CategoryPriceImplToJson(_$CategoryPriceImpl instance) =>
    <String, dynamic>{
      'item_group': instance.itemGroup,
      'rate': instance.rate,
      'item_count': instance.itemCount,
    };

_$ItemOverrideImpl _$$ItemOverrideImplFromJson(Map<String, dynamic> json) =>
    _$ItemOverrideImpl(
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String? ?? '',
      itemGroup: json['item_group'] as String? ?? '',
      rate: json['rate'] as num,
    );

Map<String, dynamic> _$$ItemOverrideImplToJson(_$ItemOverrideImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'item_group': instance.itemGroup,
      'rate': instance.rate,
    };

_$AssignedCustomerImpl _$$AssignedCustomerImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedCustomerImpl(
  customer: json['customer'] as String,
  customerName: json['customer_name'] as String? ?? '',
  assignment: json['assignment'] as String? ?? 'direct',
  customerGroup: json['customer_group'] as String? ?? '',
);

Map<String, dynamic> _$$AssignedCustomerImplToJson(
  _$AssignedCustomerImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'assignment': instance.assignment,
  'customer_group': instance.customerGroup,
};

_$PriceListSummaryImpl _$$PriceListSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$PriceListSummaryImpl(
  name: json['name'] as String,
  currency: json['currency'] as String? ?? 'EGP',
  enabled: json['enabled'] as bool? ?? true,
  isDefault: json['is_default'] as bool? ?? false,
  customerCount: (json['customer_count'] as num?)?.toInt() ?? 0,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryPrice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryPrice>[],
);

Map<String, dynamic> _$$PriceListSummaryImplToJson(
  _$PriceListSummaryImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'currency': instance.currency,
  'enabled': instance.enabled,
  'is_default': instance.isDefault,
  'customer_count': instance.customerCount,
  'categories': instance.categories,
};

_$PriceListDetailImpl _$$PriceListDetailImplFromJson(
  Map<String, dynamic> json,
) => _$PriceListDetailImpl(
  name: json['name'] as String,
  currency: json['currency'] as String? ?? 'EGP',
  enabled: json['enabled'] as bool? ?? true,
  isDefault: json['is_default'] as bool? ?? false,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryPrice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryPrice>[],
  itemOverrides:
      (json['item_overrides'] as List<dynamic>?)
          ?.map((e) => ItemOverride.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ItemOverride>[],
  customers:
      (json['customers'] as List<dynamic>?)
          ?.map((e) => AssignedCustomer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AssignedCustomer>[],
);

Map<String, dynamic> _$$PriceListDetailImplToJson(
  _$PriceListDetailImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'currency': instance.currency,
  'enabled': instance.enabled,
  'is_default': instance.isDefault,
  'categories': instance.categories,
  'item_overrides': instance.itemOverrides,
  'customers': instance.customers,
};

_$CustomerPriceImpl _$$CustomerPriceImplFromJson(Map<String, dynamic> json) =>
    _$CustomerPriceImpl(
      itemGroup: json['item_group'] as String? ?? '',
      itemCode: json['item_code'] as String?,
      itemName: json['item_name'] as String?,
      rate: json['rate'] as num,
      source: json['source'] as String? ?? 'none',
    );

Map<String, dynamic> _$$CustomerPriceImplToJson(_$CustomerPriceImpl instance) =>
    <String, dynamic>{
      'item_group': instance.itemGroup,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'rate': instance.rate,
      'source': instance.source,
    };

_$CustomerPricingImpl _$$CustomerPricingImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerPricingImpl(
  customer: json['customer'] as String,
  customerName: json['customer_name'] as String? ?? '',
  customerGroup: json['customer_group'] as String? ?? '',
  effectivePriceList: json['effective_price_list'] as String?,
  assignment: json['assignment'] as String? ?? 'none',
  prices:
      (json['prices'] as List<dynamic>?)
          ?.map((e) => CustomerPrice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CustomerPrice>[],
);

Map<String, dynamic> _$$CustomerPricingImplToJson(
  _$CustomerPricingImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'customer_group': instance.customerGroup,
  'effective_price_list': instance.effectivePriceList,
  'assignment': instance.assignment,
  'prices': instance.prices,
};

_$PricingCategoryImpl _$$PricingCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$PricingCategoryImpl(
  itemGroup: json['item_group'] as String,
  itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PricingCategoryImplToJson(
  _$PricingCategoryImpl instance,
) => <String, dynamic>{
  'item_group': instance.itemGroup,
  'item_count': instance.itemCount,
};

_$B2bCustomerResultImpl _$$B2bCustomerResultImplFromJson(
  Map<String, dynamic> json,
) => _$B2bCustomerResultImpl(
  customer: json['customer'] as String,
  customerName: json['customer_name'] as String? ?? '',
  customerGroup: json['customer_group'] as String? ?? '',
  defaultPriceList: json['default_price_list'] as String?,
);

Map<String, dynamic> _$$B2bCustomerResultImplToJson(
  _$B2bCustomerResultImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'customer_group': instance.customerGroup,
  'default_price_list': instance.defaultPriceList,
};
