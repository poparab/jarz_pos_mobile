// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_models.freezed.dart';
part 'pos_models.g.dart';

@freezed
class PosProfile with _$PosProfile {
  const factory PosProfile({
    required String name,
    required String title,
    @JsonKey(name: 'warehouse') required String warehouse,
    @JsonKey(name: 'cost_center') required String costCenter,
    @JsonKey(name: 'item_groups') required List<PosItemGroup> itemGroups,
    @JsonKey(name: 'customer_groups') required List<String> customerGroups,
    @JsonKey(name: 'price_list') required String priceList,
    @JsonKey(name: 'currency') required String currency,
  }) = _PosProfile;

  factory PosProfile.fromJson(Map<String, dynamic> json) =>
      _$PosProfileFromJson(json);
}

@freezed
class PosItemGroup with _$PosItemGroup {
  const factory PosItemGroup({
    @JsonKey(name: 'item_group') required String itemGroup,
  }) = _PosItemGroup;

  factory PosItemGroup.fromJson(Map<String, dynamic> json) =>
      _$PosItemGroupFromJson(json);
}

@freezed
class PosItem with _$PosItem {
  const factory PosItem({
    required String name,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'item_group') required String itemGroup,
    @JsonKey(name: 'stock_uom') required String stockUom,
    @JsonKey(name: 'rate') required double rate,
    @JsonKey(name: 'actual_qty') required double actualQty,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'description') String? description,
  }) = _PosItem;

  factory PosItem.fromJson(Map<String, dynamic> json) =>
      _$PosItemFromJson(json);
}

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String name,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_group') required String customerGroup,
    @JsonKey(name: 'customer_type') required String customerType,
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const CartItem._(); // Private constructor for getters

  const factory CartItem({
    required PosItem item,
    required double quantity,
    required double rate,
  }) = _CartItem;

  double get total => quantity * rate;
}

@freezed
class Cart with _$Cart {
  const Cart._(); // Private constructor for getters

  const factory Cart({@Default([]) List<CartItem> items, Customer? customer}) =
      _Cart;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity.toInt());
}
