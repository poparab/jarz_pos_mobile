// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PosProfile _$PosProfileFromJson(Map<String, dynamic> json) {
  return _PosProfile.fromJson(json);
}

/// @nodoc
mixin _$PosProfile {
  String get name => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'warehouse')
  String get warehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_center')
  String get costCenter => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_groups')
  List<PosItemGroup> get itemGroups => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_groups')
  List<String> get customerGroups => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_list')
  String get priceList => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency')
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this PosProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosProfileCopyWith<PosProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosProfileCopyWith<$Res> {
  factory $PosProfileCopyWith(
    PosProfile value,
    $Res Function(PosProfile) then,
  ) = _$PosProfileCopyWithImpl<$Res, PosProfile>;
  @useResult
  $Res call({
    String name,
    String title,
    @JsonKey(name: 'warehouse') String warehouse,
    @JsonKey(name: 'cost_center') String costCenter,
    @JsonKey(name: 'item_groups') List<PosItemGroup> itemGroups,
    @JsonKey(name: 'customer_groups') List<String> customerGroups,
    @JsonKey(name: 'price_list') String priceList,
    @JsonKey(name: 'currency') String currency,
  });
}

/// @nodoc
class _$PosProfileCopyWithImpl<$Res, $Val extends PosProfile>
    implements $PosProfileCopyWith<$Res> {
  _$PosProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? title = null,
    Object? warehouse = null,
    Object? costCenter = null,
    Object? itemGroups = null,
    Object? customerGroups = null,
    Object? priceList = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            warehouse: null == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as String,
            costCenter: null == costCenter
                ? _value.costCenter
                : costCenter // ignore: cast_nullable_to_non_nullable
                      as String,
            itemGroups: null == itemGroups
                ? _value.itemGroups
                : itemGroups // ignore: cast_nullable_to_non_nullable
                      as List<PosItemGroup>,
            customerGroups: null == customerGroups
                ? _value.customerGroups
                : customerGroups // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            priceList: null == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PosProfileImplCopyWith<$Res>
    implements $PosProfileCopyWith<$Res> {
  factory _$$PosProfileImplCopyWith(
    _$PosProfileImpl value,
    $Res Function(_$PosProfileImpl) then,
  ) = __$$PosProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String title,
    @JsonKey(name: 'warehouse') String warehouse,
    @JsonKey(name: 'cost_center') String costCenter,
    @JsonKey(name: 'item_groups') List<PosItemGroup> itemGroups,
    @JsonKey(name: 'customer_groups') List<String> customerGroups,
    @JsonKey(name: 'price_list') String priceList,
    @JsonKey(name: 'currency') String currency,
  });
}

/// @nodoc
class __$$PosProfileImplCopyWithImpl<$Res>
    extends _$PosProfileCopyWithImpl<$Res, _$PosProfileImpl>
    implements _$$PosProfileImplCopyWith<$Res> {
  __$$PosProfileImplCopyWithImpl(
    _$PosProfileImpl _value,
    $Res Function(_$PosProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? title = null,
    Object? warehouse = null,
    Object? costCenter = null,
    Object? itemGroups = null,
    Object? customerGroups = null,
    Object? priceList = null,
    Object? currency = null,
  }) {
    return _then(
      _$PosProfileImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        warehouse: null == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as String,
        costCenter: null == costCenter
            ? _value.costCenter
            : costCenter // ignore: cast_nullable_to_non_nullable
                  as String,
        itemGroups: null == itemGroups
            ? _value._itemGroups
            : itemGroups // ignore: cast_nullable_to_non_nullable
                  as List<PosItemGroup>,
        customerGroups: null == customerGroups
            ? _value._customerGroups
            : customerGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        priceList: null == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PosProfileImpl implements _PosProfile {
  const _$PosProfileImpl({
    required this.name,
    required this.title,
    @JsonKey(name: 'warehouse') required this.warehouse,
    @JsonKey(name: 'cost_center') required this.costCenter,
    @JsonKey(name: 'item_groups') required final List<PosItemGroup> itemGroups,
    @JsonKey(name: 'customer_groups')
    required final List<String> customerGroups,
    @JsonKey(name: 'price_list') required this.priceList,
    @JsonKey(name: 'currency') required this.currency,
  }) : _itemGroups = itemGroups,
       _customerGroups = customerGroups;

  factory _$PosProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosProfileImplFromJson(json);

  @override
  final String name;
  @override
  final String title;
  @override
  @JsonKey(name: 'warehouse')
  final String warehouse;
  @override
  @JsonKey(name: 'cost_center')
  final String costCenter;
  final List<PosItemGroup> _itemGroups;
  @override
  @JsonKey(name: 'item_groups')
  List<PosItemGroup> get itemGroups {
    if (_itemGroups is EqualUnmodifiableListView) return _itemGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemGroups);
  }

  final List<String> _customerGroups;
  @override
  @JsonKey(name: 'customer_groups')
  List<String> get customerGroups {
    if (_customerGroups is EqualUnmodifiableListView) return _customerGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customerGroups);
  }

  @override
  @JsonKey(name: 'price_list')
  final String priceList;
  @override
  @JsonKey(name: 'currency')
  final String currency;

  @override
  String toString() {
    return 'PosProfile(name: $name, title: $title, warehouse: $warehouse, costCenter: $costCenter, itemGroups: $itemGroups, customerGroups: $customerGroups, priceList: $priceList, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.costCenter, costCenter) ||
                other.costCenter == costCenter) &&
            const DeepCollectionEquality().equals(
              other._itemGroups,
              _itemGroups,
            ) &&
            const DeepCollectionEquality().equals(
              other._customerGroups,
              _customerGroups,
            ) &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    title,
    warehouse,
    costCenter,
    const DeepCollectionEquality().hash(_itemGroups),
    const DeepCollectionEquality().hash(_customerGroups),
    priceList,
    currency,
  );

  /// Create a copy of PosProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosProfileImplCopyWith<_$PosProfileImpl> get copyWith =>
      __$$PosProfileImplCopyWithImpl<_$PosProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosProfileImplToJson(this);
  }
}

abstract class _PosProfile implements PosProfile {
  const factory _PosProfile({
    required final String name,
    required final String title,
    @JsonKey(name: 'warehouse') required final String warehouse,
    @JsonKey(name: 'cost_center') required final String costCenter,
    @JsonKey(name: 'item_groups') required final List<PosItemGroup> itemGroups,
    @JsonKey(name: 'customer_groups')
    required final List<String> customerGroups,
    @JsonKey(name: 'price_list') required final String priceList,
    @JsonKey(name: 'currency') required final String currency,
  }) = _$PosProfileImpl;

  factory _PosProfile.fromJson(Map<String, dynamic> json) =
      _$PosProfileImpl.fromJson;

  @override
  String get name;
  @override
  String get title;
  @override
  @JsonKey(name: 'warehouse')
  String get warehouse;
  @override
  @JsonKey(name: 'cost_center')
  String get costCenter;
  @override
  @JsonKey(name: 'item_groups')
  List<PosItemGroup> get itemGroups;
  @override
  @JsonKey(name: 'customer_groups')
  List<String> get customerGroups;
  @override
  @JsonKey(name: 'price_list')
  String get priceList;
  @override
  @JsonKey(name: 'currency')
  String get currency;

  /// Create a copy of PosProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosProfileImplCopyWith<_$PosProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PosItemGroup _$PosItemGroupFromJson(Map<String, dynamic> json) {
  return _PosItemGroup.fromJson(json);
}

/// @nodoc
mixin _$PosItemGroup {
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;

  /// Serializes this PosItemGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosItemGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosItemGroupCopyWith<PosItemGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosItemGroupCopyWith<$Res> {
  factory $PosItemGroupCopyWith(
    PosItemGroup value,
    $Res Function(PosItemGroup) then,
  ) = _$PosItemGroupCopyWithImpl<$Res, PosItemGroup>;
  @useResult
  $Res call({@JsonKey(name: 'item_group') String itemGroup});
}

/// @nodoc
class _$PosItemGroupCopyWithImpl<$Res, $Val extends PosItemGroup>
    implements $PosItemGroupCopyWith<$Res> {
  _$PosItemGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosItemGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? itemGroup = null}) {
    return _then(
      _value.copyWith(
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PosItemGroupImplCopyWith<$Res>
    implements $PosItemGroupCopyWith<$Res> {
  factory _$$PosItemGroupImplCopyWith(
    _$PosItemGroupImpl value,
    $Res Function(_$PosItemGroupImpl) then,
  ) = __$$PosItemGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'item_group') String itemGroup});
}

/// @nodoc
class __$$PosItemGroupImplCopyWithImpl<$Res>
    extends _$PosItemGroupCopyWithImpl<$Res, _$PosItemGroupImpl>
    implements _$$PosItemGroupImplCopyWith<$Res> {
  __$$PosItemGroupImplCopyWithImpl(
    _$PosItemGroupImpl _value,
    $Res Function(_$PosItemGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosItemGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? itemGroup = null}) {
    return _then(
      _$PosItemGroupImpl(
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PosItemGroupImpl implements _PosItemGroup {
  const _$PosItemGroupImpl({
    @JsonKey(name: 'item_group') required this.itemGroup,
  });

  factory _$PosItemGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosItemGroupImplFromJson(json);

  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;

  @override
  String toString() {
    return 'PosItemGroup(itemGroup: $itemGroup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosItemGroupImpl &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemGroup);

  /// Create a copy of PosItemGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosItemGroupImplCopyWith<_$PosItemGroupImpl> get copyWith =>
      __$$PosItemGroupImplCopyWithImpl<_$PosItemGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosItemGroupImplToJson(this);
  }
}

abstract class _PosItemGroup implements PosItemGroup {
  const factory _PosItemGroup({
    @JsonKey(name: 'item_group') required final String itemGroup,
  }) = _$PosItemGroupImpl;

  factory _PosItemGroup.fromJson(Map<String, dynamic> json) =
      _$PosItemGroupImpl.fromJson;

  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;

  /// Create a copy of PosItemGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosItemGroupImplCopyWith<_$PosItemGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PosItem _$PosItemFromJson(Map<String, dynamic> json) {
  return _PosItem.fromJson(json);
}

/// @nodoc
mixin _$PosItem {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'rate')
  double get rate => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_qty')
  double get actualQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'image')
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this PosItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosItemCopyWith<PosItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosItemCopyWith<$Res> {
  factory $PosItemCopyWith(PosItem value, $Res Function(PosItem) then) =
      _$PosItemCopyWithImpl<$Res, PosItem>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'rate') double rate,
    @JsonKey(name: 'actual_qty') double actualQty,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'description') String? description,
  });
}

/// @nodoc
class _$PosItemCopyWithImpl<$Res, $Val extends PosItem>
    implements $PosItemCopyWith<$Res> {
  _$PosItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? stockUom = null,
    Object? rate = null,
    Object? actualQty = null,
    Object? image = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            actualQty: null == actualQty
                ? _value.actualQty
                : actualQty // ignore: cast_nullable_to_non_nullable
                      as double,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PosItemImplCopyWith<$Res> implements $PosItemCopyWith<$Res> {
  factory _$$PosItemImplCopyWith(
    _$PosItemImpl value,
    $Res Function(_$PosItemImpl) then,
  ) = __$$PosItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'rate') double rate,
    @JsonKey(name: 'actual_qty') double actualQty,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'description') String? description,
  });
}

/// @nodoc
class __$$PosItemImplCopyWithImpl<$Res>
    extends _$PosItemCopyWithImpl<$Res, _$PosItemImpl>
    implements _$$PosItemImplCopyWith<$Res> {
  __$$PosItemImplCopyWithImpl(
    _$PosItemImpl _value,
    $Res Function(_$PosItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? stockUom = null,
    Object? rate = null,
    Object? actualQty = null,
    Object? image = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _$PosItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        actualQty: null == actualQty
            ? _value.actualQty
            : actualQty // ignore: cast_nullable_to_non_nullable
                  as double,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PosItemImpl implements _PosItem {
  const _$PosItemImpl({
    required this.name,
    @JsonKey(name: 'item_name') required this.itemName,
    @JsonKey(name: 'item_group') required this.itemGroup,
    @JsonKey(name: 'stock_uom') required this.stockUom,
    @JsonKey(name: 'rate') required this.rate,
    @JsonKey(name: 'actual_qty') required this.actualQty,
    @JsonKey(name: 'image') this.image,
    @JsonKey(name: 'description') this.description,
  });

  factory _$PosItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  @override
  @JsonKey(name: 'rate')
  final double rate;
  @override
  @JsonKey(name: 'actual_qty')
  final double actualQty;
  @override
  @JsonKey(name: 'image')
  final String? image;
  @override
  @JsonKey(name: 'description')
  final String? description;

  @override
  String toString() {
    return 'PosItem(name: $name, itemName: $itemName, itemGroup: $itemGroup, stockUom: $stockUom, rate: $rate, actualQty: $actualQty, image: $image, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.actualQty, actualQty) ||
                other.actualQty == actualQty) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    itemName,
    itemGroup,
    stockUom,
    rate,
    actualQty,
    image,
    description,
  );

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosItemImplCopyWith<_$PosItemImpl> get copyWith =>
      __$$PosItemImplCopyWithImpl<_$PosItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosItemImplToJson(this);
  }
}

abstract class _PosItem implements PosItem {
  const factory _PosItem({
    required final String name,
    @JsonKey(name: 'item_name') required final String itemName,
    @JsonKey(name: 'item_group') required final String itemGroup,
    @JsonKey(name: 'stock_uom') required final String stockUom,
    @JsonKey(name: 'rate') required final double rate,
    @JsonKey(name: 'actual_qty') required final double actualQty,
    @JsonKey(name: 'image') final String? image,
    @JsonKey(name: 'description') final String? description,
  }) = _$PosItemImpl;

  factory _PosItem.fromJson(Map<String, dynamic> json) = _$PosItemImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  @JsonKey(name: 'rate')
  double get rate;
  @override
  @JsonKey(name: 'actual_qty')
  double get actualQty;
  @override
  @JsonKey(name: 'image')
  String? get image;
  @override
  @JsonKey(name: 'description')
  String? get description;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosItemImplCopyWith<_$PosItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_group')
  String get customerGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_type')
  String get customerType => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_no')
  String? get mobileNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_id')
  String? get emailId => throw _privateConstructorUsedError;

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'customer_type') String customerType,
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
  });
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? customerType = null,
    Object? mobileNo = freezed,
    Object? emailId = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerGroup: null == customerGroup
                ? _value.customerGroup
                : customerGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            customerType: null == customerType
                ? _value.customerType
                : customerType // ignore: cast_nullable_to_non_nullable
                      as String,
            mobileNo: freezed == mobileNo
                ? _value.mobileNo
                : mobileNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailId: freezed == emailId
                ? _value.emailId
                : emailId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
    _$CustomerImpl value,
    $Res Function(_$CustomerImpl) then,
  ) = __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'customer_type') String customerType,
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
  });
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
    _$CustomerImpl _value,
    $Res Function(_$CustomerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? customerType = null,
    Object? mobileNo = freezed,
    Object? emailId = freezed,
  }) {
    return _then(
      _$CustomerImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerGroup: null == customerGroup
            ? _value.customerGroup
            : customerGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        customerType: null == customerType
            ? _value.customerType
            : customerType // ignore: cast_nullable_to_non_nullable
                  as String,
        mobileNo: freezed == mobileNo
            ? _value.mobileNo
            : mobileNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailId: freezed == emailId
            ? _value.emailId
            : emailId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl({
    required this.name,
    @JsonKey(name: 'customer_name') required this.customerName,
    @JsonKey(name: 'customer_group') required this.customerGroup,
    @JsonKey(name: 'customer_type') required this.customerType,
    @JsonKey(name: 'mobile_no') this.mobileNo,
    @JsonKey(name: 'email_id') this.emailId,
  });

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'customer_group')
  final String customerGroup;
  @override
  @JsonKey(name: 'customer_type')
  final String customerType;
  @override
  @JsonKey(name: 'mobile_no')
  final String? mobileNo;
  @override
  @JsonKey(name: 'email_id')
  final String? emailId;

  @override
  String toString() {
    return 'Customer(name: $name, customerName: $customerName, customerGroup: $customerGroup, customerType: $customerType, mobileNo: $mobileNo, emailId: $emailId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerGroup, customerGroup) ||
                other.customerGroup == customerGroup) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.mobileNo, mobileNo) ||
                other.mobileNo == mobileNo) &&
            (identical(other.emailId, emailId) || other.emailId == emailId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    customerName,
    customerGroup,
    customerType,
    mobileNo,
    emailId,
  );

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(this);
  }
}

abstract class _Customer implements Customer {
  const factory _Customer({
    required final String name,
    @JsonKey(name: 'customer_name') required final String customerName,
    @JsonKey(name: 'customer_group') required final String customerGroup,
    @JsonKey(name: 'customer_type') required final String customerType,
    @JsonKey(name: 'mobile_no') final String? mobileNo,
    @JsonKey(name: 'email_id') final String? emailId,
  }) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'customer_group')
  String get customerGroup;
  @override
  @JsonKey(name: 'customer_type')
  String get customerType;
  @override
  @JsonKey(name: 'mobile_no')
  String? get mobileNo;
  @override
  @JsonKey(name: 'email_id')
  String? get emailId;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CartItem {
  PosItem get item => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call({PosItem item, double quantity, double rate});

  $PosItemCopyWith<$Res> get item;
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? quantity = null,
    Object? rate = null,
  }) {
    return _then(
      _value.copyWith(
            item: null == item
                ? _value.item
                : item // ignore: cast_nullable_to_non_nullable
                      as PosItem,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PosItemCopyWith<$Res> get item {
    return $PosItemCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
    _$CartItemImpl value,
    $Res Function(_$CartItemImpl) then,
  ) = __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PosItem item, double quantity, double rate});

  @override
  $PosItemCopyWith<$Res> get item;
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
    _$CartItemImpl _value,
    $Res Function(_$CartItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? quantity = null,
    Object? rate = null,
  }) {
    return _then(
      _$CartItemImpl(
        item: null == item
            ? _value.item
            : item // ignore: cast_nullable_to_non_nullable
                  as PosItem,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl({
    required this.item,
    required this.quantity,
    required this.rate,
  }) : super._();

  @override
  final PosItem item;
  @override
  final double quantity;
  @override
  final double rate;

  @override
  String toString() {
    return 'CartItem(item: $item, quantity: $quantity, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item, quantity, rate);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);
}

abstract class _CartItem extends CartItem {
  const factory _CartItem({
    required final PosItem item,
    required final double quantity,
    required final double rate,
  }) = _$CartItemImpl;
  const _CartItem._() : super._();

  @override
  PosItem get item;
  @override
  double get quantity;
  @override
  double get rate;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Cart {
  List<CartItem> get items => throw _privateConstructorUsedError;
  Customer? get customer => throw _privateConstructorUsedError;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartCopyWith<Cart> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartCopyWith<$Res> {
  factory $CartCopyWith(Cart value, $Res Function(Cart) then) =
      _$CartCopyWithImpl<$Res, Cart>;
  @useResult
  $Res call({List<CartItem> items, Customer? customer});

  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class _$CartCopyWithImpl<$Res, $Val extends Cart>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? customer = freezed}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CartItem>,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as Customer?,
          )
          as $Val,
    );
  }

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_value.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_value.customer!, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartImplCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$$CartImplCopyWith(
    _$CartImpl value,
    $Res Function(_$CartImpl) then,
  ) = __$$CartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CartItem> items, Customer? customer});

  @override
  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class __$$CartImplCopyWithImpl<$Res>
    extends _$CartCopyWithImpl<$Res, _$CartImpl>
    implements _$$CartImplCopyWith<$Res> {
  __$$CartImplCopyWithImpl(_$CartImpl _value, $Res Function(_$CartImpl) _then)
    : super(_value, _then);

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? customer = freezed}) {
    return _then(
      _$CartImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CartItem>,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as Customer?,
      ),
    );
  }
}

/// @nodoc

class _$CartImpl extends _Cart {
  const _$CartImpl({final List<CartItem> items = const [], this.customer})
    : _items = items,
      super._();

  final List<CartItem> _items;
  @override
  @JsonKey()
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final Customer? customer;

  @override
  String toString() {
    return 'Cart(items: $items, customer: $customer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.customer, customer) ||
                other.customer == customer));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    customer,
  );

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      __$$CartImplCopyWithImpl<_$CartImpl>(this, _$identity);
}

abstract class _Cart extends Cart {
  const factory _Cart({final List<CartItem> items, final Customer? customer}) =
      _$CartImpl;
  const _Cart._() : super._();

  @override
  List<CartItem> get items;
  @override
  Customer? get customer;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
