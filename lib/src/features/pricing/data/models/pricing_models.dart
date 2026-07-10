// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing_models.freezed.dart';
part 'pricing_models.g.dart';

/// One category (Item Group) price row on a price list. [rate] is null when the
/// list has no item-group Item Price for that category yet.
@freezed
class CategoryPrice with _$CategoryPrice {
  const factory CategoryPrice({
    @JsonKey(name: 'item_group') required String itemGroup,
    num? rate,
    @JsonKey(name: 'item_count') @Default(0) int itemCount,
  }) = _CategoryPrice;

  factory CategoryPrice.fromJson(Map<String, dynamic> json) =>
      _$CategoryPriceFromJson(json);
}

/// A per-flavor (per-item) override on a price list. Beats the category rate.
@freezed
class ItemOverride with _$ItemOverride {
  const factory ItemOverride({
    @JsonKey(name: 'item_code') required String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'item_group') @Default('') String itemGroup,
    required num rate,
  }) = _ItemOverride;

  factory ItemOverride.fromJson(Map<String, dynamic> json) =>
      _$ItemOverrideFromJson(json);
}

/// A customer assigned to a price list, either directly (Customer.default_price_list)
/// or via their Customer Group's default.
@freezed
class AssignedCustomer with _$AssignedCustomer {
  const factory AssignedCustomer({
    required String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @Default('direct') String assignment,
    @JsonKey(name: 'customer_group') @Default('') String customerGroup,
  }) = _AssignedCustomer;

  factory AssignedCustomer.fromJson(Map<String, dynamic> json) =>
      _$AssignedCustomerFromJson(json);
}

/// A price list summary card as returned by `get_price_lists`.
@freezed
class PriceListSummary with _$PriceListSummary {
  const factory PriceListSummary({
    required String name,
    @Default('EGP') String currency,
    @Default(true) bool enabled,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'customer_count') @Default(0) int customerCount,
    @Default(<CategoryPrice>[]) List<CategoryPrice> categories,
  }) = _PriceListSummary;

  factory PriceListSummary.fromJson(Map<String, dynamic> json) =>
      _$PriceListSummaryFromJson(json);
}

/// The full detail for a price list as returned by `get_price_list_detail`.
@freezed
class PriceListDetail with _$PriceListDetail {
  const factory PriceListDetail({
    required String name,
    @Default('EGP') String currency,
    @Default(true) bool enabled,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @Default(<CategoryPrice>[]) List<CategoryPrice> categories,
    @JsonKey(name: 'item_overrides')
    @Default(<ItemOverride>[])
    List<ItemOverride> itemOverrides,
    @Default(<AssignedCustomer>[]) List<AssignedCustomer> customers,
  }) = _PriceListDetail;

  factory PriceListDetail.fromJson(Map<String, dynamic> json) =>
      _$PriceListDetailFromJson(json);
}

/// One effective price line in the reverse (customer → price) view. [source]
/// is "override", "category" or "none".
@freezed
class CustomerPrice with _$CustomerPrice {
  const factory CustomerPrice({
    @JsonKey(name: 'item_group') @Default('') String itemGroup,
    @JsonKey(name: 'item_code') String? itemCode,
    @JsonKey(name: 'item_name') String? itemName,
    required num rate,
    @Default('none') String source,
  }) = _CustomerPrice;

  factory CustomerPrice.fromJson(Map<String, dynamic> json) =>
      _$CustomerPriceFromJson(json);
}

/// The reverse / "double-entry" view for a customer, from `get_customer_pricing`.
@freezed
class CustomerPricing with _$CustomerPricing {
  const factory CustomerPricing({
    required String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'customer_group') @Default('') String customerGroup,
    @JsonKey(name: 'effective_price_list') String? effectivePriceList,
    @Default('none') String assignment,
    @Default(<CustomerPrice>[]) List<CustomerPrice> prices,
  }) = _CustomerPricing;

  factory CustomerPricing.fromJson(Map<String, dynamic> json) =>
      _$CustomerPricingFromJson(json);
}

/// A pricing category (Item Group with sellable items), from
/// `list_pricing_categories`.
@freezed
class PricingCategory with _$PricingCategory {
  const factory PricingCategory({
    @JsonKey(name: 'item_group') required String itemGroup,
    @JsonKey(name: 'item_count') @Default(0) int itemCount,
  }) = _PricingCategory;

  factory PricingCategory.fromJson(Map<String, dynamic> json) =>
      _$PricingCategoryFromJson(json);
}

/// A company customer search hit from `search_b2b_customers`.
@freezed
class B2bCustomerResult with _$B2bCustomerResult {
  const factory B2bCustomerResult({
    required String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'customer_group') @Default('') String customerGroup,
    @JsonKey(name: 'default_price_list') String? defaultPriceList,
  }) = _B2bCustomerResult;

  factory B2bCustomerResult.fromJson(Map<String, dynamic> json) =>
      _$B2bCustomerResultFromJson(json);
}
