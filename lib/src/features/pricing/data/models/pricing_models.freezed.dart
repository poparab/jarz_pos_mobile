// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CategoryPrice _$CategoryPriceFromJson(Map<String, dynamic> json) {
  return _CategoryPrice.fromJson(json);
}

/// @nodoc
mixin _$CategoryPrice {
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  num? get rate => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_count')
  int get itemCount => throw _privateConstructorUsedError;

  /// Serializes this CategoryPrice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryPriceCopyWith<CategoryPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryPriceCopyWith<$Res> {
  factory $CategoryPriceCopyWith(
    CategoryPrice value,
    $Res Function(CategoryPrice) then,
  ) = _$CategoryPriceCopyWithImpl<$Res, CategoryPrice>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    num? rate,
    @JsonKey(name: 'item_count') int itemCount,
  });
}

/// @nodoc
class _$CategoryPriceCopyWithImpl<$Res, $Val extends CategoryPrice>
    implements $CategoryPriceCopyWith<$Res> {
  _$CategoryPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemGroup = null,
    Object? rate = freezed,
    Object? itemCount = null,
  }) {
    return _then(
      _value.copyWith(
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            rate: freezed == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as num?,
            itemCount: null == itemCount
                ? _value.itemCount
                : itemCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryPriceImplCopyWith<$Res>
    implements $CategoryPriceCopyWith<$Res> {
  factory _$$CategoryPriceImplCopyWith(
    _$CategoryPriceImpl value,
    $Res Function(_$CategoryPriceImpl) then,
  ) = __$$CategoryPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    num? rate,
    @JsonKey(name: 'item_count') int itemCount,
  });
}

/// @nodoc
class __$$CategoryPriceImplCopyWithImpl<$Res>
    extends _$CategoryPriceCopyWithImpl<$Res, _$CategoryPriceImpl>
    implements _$$CategoryPriceImplCopyWith<$Res> {
  __$$CategoryPriceImplCopyWithImpl(
    _$CategoryPriceImpl _value,
    $Res Function(_$CategoryPriceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemGroup = null,
    Object? rate = freezed,
    Object? itemCount = null,
  }) {
    return _then(
      _$CategoryPriceImpl(
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        rate: freezed == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as num?,
        itemCount: null == itemCount
            ? _value.itemCount
            : itemCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryPriceImpl implements _CategoryPrice {
  const _$CategoryPriceImpl({
    @JsonKey(name: 'item_group') required this.itemGroup,
    this.rate,
    @JsonKey(name: 'item_count') this.itemCount = 0,
  });

  factory _$CategoryPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryPriceImplFromJson(json);

  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;
  @override
  final num? rate;
  @override
  @JsonKey(name: 'item_count')
  final int itemCount;

  @override
  String toString() {
    return 'CategoryPrice(itemGroup: $itemGroup, rate: $rate, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryPriceImpl &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemGroup, rate, itemCount);

  /// Create a copy of CategoryPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryPriceImplCopyWith<_$CategoryPriceImpl> get copyWith =>
      __$$CategoryPriceImplCopyWithImpl<_$CategoryPriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryPriceImplToJson(this);
  }
}

abstract class _CategoryPrice implements CategoryPrice {
  const factory _CategoryPrice({
    @JsonKey(name: 'item_group') required final String itemGroup,
    final num? rate,
    @JsonKey(name: 'item_count') final int itemCount,
  }) = _$CategoryPriceImpl;

  factory _CategoryPrice.fromJson(Map<String, dynamic> json) =
      _$CategoryPriceImpl.fromJson;

  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;
  @override
  num? get rate;
  @override
  @JsonKey(name: 'item_count')
  int get itemCount;

  /// Create a copy of CategoryPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryPriceImplCopyWith<_$CategoryPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemOverride _$ItemOverrideFromJson(Map<String, dynamic> json) {
  return _ItemOverride.fromJson(json);
}

/// @nodoc
mixin _$ItemOverride {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  num get rate => throw _privateConstructorUsedError;

  /// Serializes this ItemOverride to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemOverride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemOverrideCopyWith<ItemOverride> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemOverrideCopyWith<$Res> {
  factory $ItemOverrideCopyWith(
    ItemOverride value,
    $Res Function(ItemOverride) then,
  ) = _$ItemOverrideCopyWithImpl<$Res, ItemOverride>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    num rate,
  });
}

/// @nodoc
class _$ItemOverrideCopyWithImpl<$Res, $Val extends ItemOverride>
    implements $ItemOverrideCopyWith<$Res> {
  _$ItemOverrideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemOverride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? rate = null,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as num,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ItemOverrideImplCopyWith<$Res>
    implements $ItemOverrideCopyWith<$Res> {
  factory _$$ItemOverrideImplCopyWith(
    _$ItemOverrideImpl value,
    $Res Function(_$ItemOverrideImpl) then,
  ) = __$$ItemOverrideImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    num rate,
  });
}

/// @nodoc
class __$$ItemOverrideImplCopyWithImpl<$Res>
    extends _$ItemOverrideCopyWithImpl<$Res, _$ItemOverrideImpl>
    implements _$$ItemOverrideImplCopyWith<$Res> {
  __$$ItemOverrideImplCopyWithImpl(
    _$ItemOverrideImpl _value,
    $Res Function(_$ItemOverrideImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItemOverride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? rate = null,
  }) {
    return _then(
      _$ItemOverrideImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as num,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemOverrideImpl implements _ItemOverride {
  const _$ItemOverrideImpl({
    @JsonKey(name: 'item_code') required this.itemCode,
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'item_group') this.itemGroup = '',
    required this.rate,
  });

  factory _$ItemOverrideImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemOverrideImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;
  @override
  final num rate;

  @override
  String toString() {
    return 'ItemOverride(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemOverrideImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemCode, itemName, itemGroup, rate);

  /// Create a copy of ItemOverride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemOverrideImplCopyWith<_$ItemOverrideImpl> get copyWith =>
      __$$ItemOverrideImplCopyWithImpl<_$ItemOverrideImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemOverrideImplToJson(this);
  }
}

abstract class _ItemOverride implements ItemOverride {
  const factory _ItemOverride({
    @JsonKey(name: 'item_code') required final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'item_group') final String itemGroup,
    required final num rate,
  }) = _$ItemOverrideImpl;

  factory _ItemOverride.fromJson(Map<String, dynamic> json) =
      _$ItemOverrideImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;
  @override
  num get rate;

  /// Create a copy of ItemOverride
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemOverrideImplCopyWith<_$ItemOverrideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssignedCustomer _$AssignedCustomerFromJson(Map<String, dynamic> json) {
  return _AssignedCustomer.fromJson(json);
}

/// @nodoc
mixin _$AssignedCustomer {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  String get assignment => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_group')
  String get customerGroup => throw _privateConstructorUsedError;

  /// Serializes this AssignedCustomer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignedCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignedCustomerCopyWith<AssignedCustomer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignedCustomerCopyWith<$Res> {
  factory $AssignedCustomerCopyWith(
    AssignedCustomer value,
    $Res Function(AssignedCustomer) then,
  ) = _$AssignedCustomerCopyWithImpl<$Res, AssignedCustomer>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    String assignment,
    @JsonKey(name: 'customer_group') String customerGroup,
  });
}

/// @nodoc
class _$AssignedCustomerCopyWithImpl<$Res, $Val extends AssignedCustomer>
    implements $AssignedCustomerCopyWith<$Res> {
  _$AssignedCustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignedCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? assignment = null,
    Object? customerGroup = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            assignment: null == assignment
                ? _value.assignment
                : assignment // ignore: cast_nullable_to_non_nullable
                      as String,
            customerGroup: null == customerGroup
                ? _value.customerGroup
                : customerGroup // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignedCustomerImplCopyWith<$Res>
    implements $AssignedCustomerCopyWith<$Res> {
  factory _$$AssignedCustomerImplCopyWith(
    _$AssignedCustomerImpl value,
    $Res Function(_$AssignedCustomerImpl) then,
  ) = __$$AssignedCustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    String assignment,
    @JsonKey(name: 'customer_group') String customerGroup,
  });
}

/// @nodoc
class __$$AssignedCustomerImplCopyWithImpl<$Res>
    extends _$AssignedCustomerCopyWithImpl<$Res, _$AssignedCustomerImpl>
    implements _$$AssignedCustomerImplCopyWith<$Res> {
  __$$AssignedCustomerImplCopyWithImpl(
    _$AssignedCustomerImpl _value,
    $Res Function(_$AssignedCustomerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? assignment = null,
    Object? customerGroup = null,
  }) {
    return _then(
      _$AssignedCustomerImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        assignment: null == assignment
            ? _value.assignment
            : assignment // ignore: cast_nullable_to_non_nullable
                  as String,
        customerGroup: null == customerGroup
            ? _value.customerGroup
            : customerGroup // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedCustomerImpl implements _AssignedCustomer {
  const _$AssignedCustomerImpl({
    required this.customer,
    @JsonKey(name: 'customer_name') this.customerName = '',
    this.assignment = 'direct',
    @JsonKey(name: 'customer_group') this.customerGroup = '',
  });

  factory _$AssignedCustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedCustomerImplFromJson(json);

  @override
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey()
  final String assignment;
  @override
  @JsonKey(name: 'customer_group')
  final String customerGroup;

  @override
  String toString() {
    return 'AssignedCustomer(customer: $customer, customerName: $customerName, assignment: $assignment, customerGroup: $customerGroup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedCustomerImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment) &&
            (identical(other.customerGroup, customerGroup) ||
                other.customerGroup == customerGroup));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    assignment,
    customerGroup,
  );

  /// Create a copy of AssignedCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedCustomerImplCopyWith<_$AssignedCustomerImpl> get copyWith =>
      __$$AssignedCustomerImplCopyWithImpl<_$AssignedCustomerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedCustomerImplToJson(this);
  }
}

abstract class _AssignedCustomer implements AssignedCustomer {
  const factory _AssignedCustomer({
    required final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    final String assignment,
    @JsonKey(name: 'customer_group') final String customerGroup,
  }) = _$AssignedCustomerImpl;

  factory _AssignedCustomer.fromJson(Map<String, dynamic> json) =
      _$AssignedCustomerImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  String get assignment;
  @override
  @JsonKey(name: 'customer_group')
  String get customerGroup;

  /// Create a copy of AssignedCustomer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedCustomerImplCopyWith<_$AssignedCustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceListSummary _$PriceListSummaryFromJson(Map<String, dynamic> json) {
  return _PriceListSummary.fromJson(json);
}

/// @nodoc
mixin _$PriceListSummary {
  String get name => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_count')
  int get customerCount => throw _privateConstructorUsedError;
  List<CategoryPrice> get categories => throw _privateConstructorUsedError;

  /// Serializes this PriceListSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceListSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceListSummaryCopyWith<PriceListSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceListSummaryCopyWith<$Res> {
  factory $PriceListSummaryCopyWith(
    PriceListSummary value,
    $Res Function(PriceListSummary) then,
  ) = _$PriceListSummaryCopyWithImpl<$Res, PriceListSummary>;
  @useResult
  $Res call({
    String name,
    String currency,
    bool enabled,
    @JsonKey(name: 'is_default') bool isDefault,
    @JsonKey(name: 'customer_count') int customerCount,
    List<CategoryPrice> categories,
  });
}

/// @nodoc
class _$PriceListSummaryCopyWithImpl<$Res, $Val extends PriceListSummary>
    implements $PriceListSummaryCopyWith<$Res> {
  _$PriceListSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceListSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? enabled = null,
    Object? isDefault = null,
    Object? customerCount = null,
    Object? categories = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            customerCount: null == customerCount
                ? _value.customerCount
                : customerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<CategoryPrice>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceListSummaryImplCopyWith<$Res>
    implements $PriceListSummaryCopyWith<$Res> {
  factory _$$PriceListSummaryImplCopyWith(
    _$PriceListSummaryImpl value,
    $Res Function(_$PriceListSummaryImpl) then,
  ) = __$$PriceListSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String currency,
    bool enabled,
    @JsonKey(name: 'is_default') bool isDefault,
    @JsonKey(name: 'customer_count') int customerCount,
    List<CategoryPrice> categories,
  });
}

/// @nodoc
class __$$PriceListSummaryImplCopyWithImpl<$Res>
    extends _$PriceListSummaryCopyWithImpl<$Res, _$PriceListSummaryImpl>
    implements _$$PriceListSummaryImplCopyWith<$Res> {
  __$$PriceListSummaryImplCopyWithImpl(
    _$PriceListSummaryImpl _value,
    $Res Function(_$PriceListSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceListSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? enabled = null,
    Object? isDefault = null,
    Object? customerCount = null,
    Object? categories = null,
  }) {
    return _then(
      _$PriceListSummaryImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        customerCount: null == customerCount
            ? _value.customerCount
            : customerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<CategoryPrice>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceListSummaryImpl implements _PriceListSummary {
  const _$PriceListSummaryImpl({
    required this.name,
    this.currency = 'EGP',
    this.enabled = true,
    @JsonKey(name: 'is_default') this.isDefault = false,
    @JsonKey(name: 'customer_count') this.customerCount = 0,
    final List<CategoryPrice> categories = const <CategoryPrice>[],
  }) : _categories = categories;

  factory _$PriceListSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceListSummaryImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @override
  @JsonKey(name: 'customer_count')
  final int customerCount;
  final List<CategoryPrice> _categories;
  @override
  @JsonKey()
  List<CategoryPrice> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'PriceListSummary(name: $name, currency: $currency, enabled: $enabled, isDefault: $isDefault, customerCount: $customerCount, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceListSummaryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.customerCount, customerCount) ||
                other.customerCount == customerCount) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    currency,
    enabled,
    isDefault,
    customerCount,
    const DeepCollectionEquality().hash(_categories),
  );

  /// Create a copy of PriceListSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceListSummaryImplCopyWith<_$PriceListSummaryImpl> get copyWith =>
      __$$PriceListSummaryImplCopyWithImpl<_$PriceListSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceListSummaryImplToJson(this);
  }
}

abstract class _PriceListSummary implements PriceListSummary {
  const factory _PriceListSummary({
    required final String name,
    final String currency,
    final bool enabled,
    @JsonKey(name: 'is_default') final bool isDefault,
    @JsonKey(name: 'customer_count') final int customerCount,
    final List<CategoryPrice> categories,
  }) = _$PriceListSummaryImpl;

  factory _PriceListSummary.fromJson(Map<String, dynamic> json) =
      _$PriceListSummaryImpl.fromJson;

  @override
  String get name;
  @override
  String get currency;
  @override
  bool get enabled;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  @JsonKey(name: 'customer_count')
  int get customerCount;
  @override
  List<CategoryPrice> get categories;

  /// Create a copy of PriceListSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceListSummaryImplCopyWith<_$PriceListSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceListDetail _$PriceListDetailFromJson(Map<String, dynamic> json) {
  return _PriceListDetail.fromJson(json);
}

/// @nodoc
mixin _$PriceListDetail {
  String get name => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;
  List<CategoryPrice> get categories => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_overrides')
  List<ItemOverride> get itemOverrides => throw _privateConstructorUsedError;
  List<AssignedCustomer> get customers => throw _privateConstructorUsedError;

  /// Serializes this PriceListDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceListDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceListDetailCopyWith<PriceListDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceListDetailCopyWith<$Res> {
  factory $PriceListDetailCopyWith(
    PriceListDetail value,
    $Res Function(PriceListDetail) then,
  ) = _$PriceListDetailCopyWithImpl<$Res, PriceListDetail>;
  @useResult
  $Res call({
    String name,
    String currency,
    bool enabled,
    @JsonKey(name: 'is_default') bool isDefault,
    List<CategoryPrice> categories,
    @JsonKey(name: 'item_overrides') List<ItemOverride> itemOverrides,
    List<AssignedCustomer> customers,
  });
}

/// @nodoc
class _$PriceListDetailCopyWithImpl<$Res, $Val extends PriceListDetail>
    implements $PriceListDetailCopyWith<$Res> {
  _$PriceListDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceListDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? enabled = null,
    Object? isDefault = null,
    Object? categories = null,
    Object? itemOverrides = null,
    Object? customers = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<CategoryPrice>,
            itemOverrides: null == itemOverrides
                ? _value.itemOverrides
                : itemOverrides // ignore: cast_nullable_to_non_nullable
                      as List<ItemOverride>,
            customers: null == customers
                ? _value.customers
                : customers // ignore: cast_nullable_to_non_nullable
                      as List<AssignedCustomer>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceListDetailImplCopyWith<$Res>
    implements $PriceListDetailCopyWith<$Res> {
  factory _$$PriceListDetailImplCopyWith(
    _$PriceListDetailImpl value,
    $Res Function(_$PriceListDetailImpl) then,
  ) = __$$PriceListDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String currency,
    bool enabled,
    @JsonKey(name: 'is_default') bool isDefault,
    List<CategoryPrice> categories,
    @JsonKey(name: 'item_overrides') List<ItemOverride> itemOverrides,
    List<AssignedCustomer> customers,
  });
}

/// @nodoc
class __$$PriceListDetailImplCopyWithImpl<$Res>
    extends _$PriceListDetailCopyWithImpl<$Res, _$PriceListDetailImpl>
    implements _$$PriceListDetailImplCopyWith<$Res> {
  __$$PriceListDetailImplCopyWithImpl(
    _$PriceListDetailImpl _value,
    $Res Function(_$PriceListDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceListDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? currency = null,
    Object? enabled = null,
    Object? isDefault = null,
    Object? categories = null,
    Object? itemOverrides = null,
    Object? customers = null,
  }) {
    return _then(
      _$PriceListDetailImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<CategoryPrice>,
        itemOverrides: null == itemOverrides
            ? _value._itemOverrides
            : itemOverrides // ignore: cast_nullable_to_non_nullable
                  as List<ItemOverride>,
        customers: null == customers
            ? _value._customers
            : customers // ignore: cast_nullable_to_non_nullable
                  as List<AssignedCustomer>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceListDetailImpl implements _PriceListDetail {
  const _$PriceListDetailImpl({
    required this.name,
    this.currency = 'EGP',
    this.enabled = true,
    @JsonKey(name: 'is_default') this.isDefault = false,
    final List<CategoryPrice> categories = const <CategoryPrice>[],
    @JsonKey(name: 'item_overrides')
    final List<ItemOverride> itemOverrides = const <ItemOverride>[],
    final List<AssignedCustomer> customers = const <AssignedCustomer>[],
  }) : _categories = categories,
       _itemOverrides = itemOverrides,
       _customers = customers;

  factory _$PriceListDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceListDetailImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  final List<CategoryPrice> _categories;
  @override
  @JsonKey()
  List<CategoryPrice> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<ItemOverride> _itemOverrides;
  @override
  @JsonKey(name: 'item_overrides')
  List<ItemOverride> get itemOverrides {
    if (_itemOverrides is EqualUnmodifiableListView) return _itemOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemOverrides);
  }

  final List<AssignedCustomer> _customers;
  @override
  @JsonKey()
  List<AssignedCustomer> get customers {
    if (_customers is EqualUnmodifiableListView) return _customers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customers);
  }

  @override
  String toString() {
    return 'PriceListDetail(name: $name, currency: $currency, enabled: $enabled, isDefault: $isDefault, categories: $categories, itemOverrides: $itemOverrides, customers: $customers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceListDetailImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(
              other._itemOverrides,
              _itemOverrides,
            ) &&
            const DeepCollectionEquality().equals(
              other._customers,
              _customers,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    currency,
    enabled,
    isDefault,
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_itemOverrides),
    const DeepCollectionEquality().hash(_customers),
  );

  /// Create a copy of PriceListDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceListDetailImplCopyWith<_$PriceListDetailImpl> get copyWith =>
      __$$PriceListDetailImplCopyWithImpl<_$PriceListDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceListDetailImplToJson(this);
  }
}

abstract class _PriceListDetail implements PriceListDetail {
  const factory _PriceListDetail({
    required final String name,
    final String currency,
    final bool enabled,
    @JsonKey(name: 'is_default') final bool isDefault,
    final List<CategoryPrice> categories,
    @JsonKey(name: 'item_overrides') final List<ItemOverride> itemOverrides,
    final List<AssignedCustomer> customers,
  }) = _$PriceListDetailImpl;

  factory _PriceListDetail.fromJson(Map<String, dynamic> json) =
      _$PriceListDetailImpl.fromJson;

  @override
  String get name;
  @override
  String get currency;
  @override
  bool get enabled;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  List<CategoryPrice> get categories;
  @override
  @JsonKey(name: 'item_overrides')
  List<ItemOverride> get itemOverrides;
  @override
  List<AssignedCustomer> get customers;

  /// Create a copy of PriceListDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceListDetailImplCopyWith<_$PriceListDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerPrice _$CustomerPriceFromJson(Map<String, dynamic> json) {
  return _CustomerPrice.fromJson(json);
}

/// @nodoc
mixin _$CustomerPrice {
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_code')
  String? get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String? get itemName => throw _privateConstructorUsedError;
  num get rate => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;

  /// Serializes this CustomerPrice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerPriceCopyWith<CustomerPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerPriceCopyWith<$Res> {
  factory $CustomerPriceCopyWith(
    CustomerPrice value,
    $Res Function(CustomerPrice) then,
  ) = _$CustomerPriceCopyWithImpl<$Res, CustomerPrice>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'item_code') String? itemCode,
    @JsonKey(name: 'item_name') String? itemName,
    num rate,
    String source,
  });
}

/// @nodoc
class _$CustomerPriceCopyWithImpl<$Res, $Val extends CustomerPrice>
    implements $CustomerPriceCopyWith<$Res> {
  _$CustomerPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemGroup = null,
    Object? itemCode = freezed,
    Object? itemName = freezed,
    Object? rate = null,
    Object? source = null,
  }) {
    return _then(
      _value.copyWith(
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            itemCode: freezed == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemName: freezed == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String?,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as num,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerPriceImplCopyWith<$Res>
    implements $CustomerPriceCopyWith<$Res> {
  factory _$$CustomerPriceImplCopyWith(
    _$CustomerPriceImpl value,
    $Res Function(_$CustomerPriceImpl) then,
  ) = __$$CustomerPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'item_code') String? itemCode,
    @JsonKey(name: 'item_name') String? itemName,
    num rate,
    String source,
  });
}

/// @nodoc
class __$$CustomerPriceImplCopyWithImpl<$Res>
    extends _$CustomerPriceCopyWithImpl<$Res, _$CustomerPriceImpl>
    implements _$$CustomerPriceImplCopyWith<$Res> {
  __$$CustomerPriceImplCopyWithImpl(
    _$CustomerPriceImpl _value,
    $Res Function(_$CustomerPriceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemGroup = null,
    Object? itemCode = freezed,
    Object? itemName = freezed,
    Object? rate = null,
    Object? source = null,
  }) {
    return _then(
      _$CustomerPriceImpl(
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        itemCode: freezed == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemName: freezed == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String?,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as num,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerPriceImpl implements _CustomerPrice {
  const _$CustomerPriceImpl({
    @JsonKey(name: 'item_group') this.itemGroup = '',
    @JsonKey(name: 'item_code') this.itemCode,
    @JsonKey(name: 'item_name') this.itemName,
    required this.rate,
    this.source = 'none',
  });

  factory _$CustomerPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerPriceImplFromJson(json);

  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;
  @override
  @JsonKey(name: 'item_code')
  final String? itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String? itemName;
  @override
  final num rate;
  @override
  @JsonKey()
  final String source;

  @override
  String toString() {
    return 'CustomerPrice(itemGroup: $itemGroup, itemCode: $itemCode, itemName: $itemName, rate: $rate, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerPriceImpl &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemGroup, itemCode, itemName, rate, source);

  /// Create a copy of CustomerPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerPriceImplCopyWith<_$CustomerPriceImpl> get copyWith =>
      __$$CustomerPriceImplCopyWithImpl<_$CustomerPriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerPriceImplToJson(this);
  }
}

abstract class _CustomerPrice implements CustomerPrice {
  const factory _CustomerPrice({
    @JsonKey(name: 'item_group') final String itemGroup,
    @JsonKey(name: 'item_code') final String? itemCode,
    @JsonKey(name: 'item_name') final String? itemName,
    required final num rate,
    final String source,
  }) = _$CustomerPriceImpl;

  factory _CustomerPrice.fromJson(Map<String, dynamic> json) =
      _$CustomerPriceImpl.fromJson;

  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;
  @override
  @JsonKey(name: 'item_code')
  String? get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String? get itemName;
  @override
  num get rate;
  @override
  String get source;

  /// Create a copy of CustomerPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerPriceImplCopyWith<_$CustomerPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerPricing _$CustomerPricingFromJson(Map<String, dynamic> json) {
  return _CustomerPricing.fromJson(json);
}

/// @nodoc
mixin _$CustomerPricing {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_group')
  String get customerGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'effective_price_list')
  String? get effectivePriceList => throw _privateConstructorUsedError;
  String get assignment => throw _privateConstructorUsedError;
  List<CustomerPrice> get prices => throw _privateConstructorUsedError;

  /// Serializes this CustomerPricing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerPricingCopyWith<CustomerPricing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerPricingCopyWith<$Res> {
  factory $CustomerPricingCopyWith(
    CustomerPricing value,
    $Res Function(CustomerPricing) then,
  ) = _$CustomerPricingCopyWithImpl<$Res, CustomerPricing>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'effective_price_list') String? effectivePriceList,
    String assignment,
    List<CustomerPrice> prices,
  });
}

/// @nodoc
class _$CustomerPricingCopyWithImpl<$Res, $Val extends CustomerPricing>
    implements $CustomerPricingCopyWith<$Res> {
  _$CustomerPricingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? effectivePriceList = freezed,
    Object? assignment = null,
    Object? prices = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerGroup: null == customerGroup
                ? _value.customerGroup
                : customerGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            effectivePriceList: freezed == effectivePriceList
                ? _value.effectivePriceList
                : effectivePriceList // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignment: null == assignment
                ? _value.assignment
                : assignment // ignore: cast_nullable_to_non_nullable
                      as String,
            prices: null == prices
                ? _value.prices
                : prices // ignore: cast_nullable_to_non_nullable
                      as List<CustomerPrice>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerPricingImplCopyWith<$Res>
    implements $CustomerPricingCopyWith<$Res> {
  factory _$$CustomerPricingImplCopyWith(
    _$CustomerPricingImpl value,
    $Res Function(_$CustomerPricingImpl) then,
  ) = __$$CustomerPricingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'effective_price_list') String? effectivePriceList,
    String assignment,
    List<CustomerPrice> prices,
  });
}

/// @nodoc
class __$$CustomerPricingImplCopyWithImpl<$Res>
    extends _$CustomerPricingCopyWithImpl<$Res, _$CustomerPricingImpl>
    implements _$$CustomerPricingImplCopyWith<$Res> {
  __$$CustomerPricingImplCopyWithImpl(
    _$CustomerPricingImpl _value,
    $Res Function(_$CustomerPricingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? effectivePriceList = freezed,
    Object? assignment = null,
    Object? prices = null,
  }) {
    return _then(
      _$CustomerPricingImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerGroup: null == customerGroup
            ? _value.customerGroup
            : customerGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        effectivePriceList: freezed == effectivePriceList
            ? _value.effectivePriceList
            : effectivePriceList // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignment: null == assignment
            ? _value.assignment
            : assignment // ignore: cast_nullable_to_non_nullable
                  as String,
        prices: null == prices
            ? _value._prices
            : prices // ignore: cast_nullable_to_non_nullable
                  as List<CustomerPrice>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerPricingImpl implements _CustomerPricing {
  const _$CustomerPricingImpl({
    required this.customer,
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'customer_group') this.customerGroup = '',
    @JsonKey(name: 'effective_price_list') this.effectivePriceList,
    this.assignment = 'none',
    final List<CustomerPrice> prices = const <CustomerPrice>[],
  }) : _prices = prices;

  factory _$CustomerPricingImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerPricingImplFromJson(json);

  @override
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'customer_group')
  final String customerGroup;
  @override
  @JsonKey(name: 'effective_price_list')
  final String? effectivePriceList;
  @override
  @JsonKey()
  final String assignment;
  final List<CustomerPrice> _prices;
  @override
  @JsonKey()
  List<CustomerPrice> get prices {
    if (_prices is EqualUnmodifiableListView) return _prices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prices);
  }

  @override
  String toString() {
    return 'CustomerPricing(customer: $customer, customerName: $customerName, customerGroup: $customerGroup, effectivePriceList: $effectivePriceList, assignment: $assignment, prices: $prices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerPricingImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerGroup, customerGroup) ||
                other.customerGroup == customerGroup) &&
            (identical(other.effectivePriceList, effectivePriceList) ||
                other.effectivePriceList == effectivePriceList) &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment) &&
            const DeepCollectionEquality().equals(other._prices, _prices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    customerGroup,
    effectivePriceList,
    assignment,
    const DeepCollectionEquality().hash(_prices),
  );

  /// Create a copy of CustomerPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerPricingImplCopyWith<_$CustomerPricingImpl> get copyWith =>
      __$$CustomerPricingImplCopyWithImpl<_$CustomerPricingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerPricingImplToJson(this);
  }
}

abstract class _CustomerPricing implements CustomerPricing {
  const factory _CustomerPricing({
    required final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'customer_group') final String customerGroup,
    @JsonKey(name: 'effective_price_list') final String? effectivePriceList,
    final String assignment,
    final List<CustomerPrice> prices,
  }) = _$CustomerPricingImpl;

  factory _CustomerPricing.fromJson(Map<String, dynamic> json) =
      _$CustomerPricingImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'customer_group')
  String get customerGroup;
  @override
  @JsonKey(name: 'effective_price_list')
  String? get effectivePriceList;
  @override
  String get assignment;
  @override
  List<CustomerPrice> get prices;

  /// Create a copy of CustomerPricing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerPricingImplCopyWith<_$CustomerPricingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PricingCategory _$PricingCategoryFromJson(Map<String, dynamic> json) {
  return _PricingCategory.fromJson(json);
}

/// @nodoc
mixin _$PricingCategory {
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_count')
  int get itemCount => throw _privateConstructorUsedError;

  /// Serializes this PricingCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricingCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingCategoryCopyWith<PricingCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingCategoryCopyWith<$Res> {
  factory $PricingCategoryCopyWith(
    PricingCategory value,
    $Res Function(PricingCategory) then,
  ) = _$PricingCategoryCopyWithImpl<$Res, PricingCategory>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'item_count') int itemCount,
  });
}

/// @nodoc
class _$PricingCategoryCopyWithImpl<$Res, $Val extends PricingCategory>
    implements $PricingCategoryCopyWith<$Res> {
  _$PricingCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? itemGroup = null, Object? itemCount = null}) {
    return _then(
      _value.copyWith(
            itemGroup: null == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            itemCount: null == itemCount
                ? _value.itemCount
                : itemCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PricingCategoryImplCopyWith<$Res>
    implements $PricingCategoryCopyWith<$Res> {
  factory _$$PricingCategoryImplCopyWith(
    _$PricingCategoryImpl value,
    $Res Function(_$PricingCategoryImpl) then,
  ) = __$$PricingCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'item_count') int itemCount,
  });
}

/// @nodoc
class __$$PricingCategoryImplCopyWithImpl<$Res>
    extends _$PricingCategoryCopyWithImpl<$Res, _$PricingCategoryImpl>
    implements _$$PricingCategoryImplCopyWith<$Res> {
  __$$PricingCategoryImplCopyWithImpl(
    _$PricingCategoryImpl _value,
    $Res Function(_$PricingCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? itemGroup = null, Object? itemCount = null}) {
    return _then(
      _$PricingCategoryImpl(
        itemGroup: null == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        itemCount: null == itemCount
            ? _value.itemCount
            : itemCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PricingCategoryImpl implements _PricingCategory {
  const _$PricingCategoryImpl({
    @JsonKey(name: 'item_group') required this.itemGroup,
    @JsonKey(name: 'item_count') this.itemCount = 0,
  });

  factory _$PricingCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricingCategoryImplFromJson(json);

  @override
  @JsonKey(name: 'item_group')
  final String itemGroup;
  @override
  @JsonKey(name: 'item_count')
  final int itemCount;

  @override
  String toString() {
    return 'PricingCategory(itemGroup: $itemGroup, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingCategoryImpl &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemGroup, itemCount);

  /// Create a copy of PricingCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingCategoryImplCopyWith<_$PricingCategoryImpl> get copyWith =>
      __$$PricingCategoryImplCopyWithImpl<_$PricingCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PricingCategoryImplToJson(this);
  }
}

abstract class _PricingCategory implements PricingCategory {
  const factory _PricingCategory({
    @JsonKey(name: 'item_group') required final String itemGroup,
    @JsonKey(name: 'item_count') final int itemCount,
  }) = _$PricingCategoryImpl;

  factory _PricingCategory.fromJson(Map<String, dynamic> json) =
      _$PricingCategoryImpl.fromJson;

  @override
  @JsonKey(name: 'item_group')
  String get itemGroup;
  @override
  @JsonKey(name: 'item_count')
  int get itemCount;

  /// Create a copy of PricingCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingCategoryImplCopyWith<_$PricingCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bCustomerResult _$B2bCustomerResultFromJson(Map<String, dynamic> json) {
  return _B2bCustomerResult.fromJson(json);
}

/// @nodoc
mixin _$B2bCustomerResult {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_group')
  String get customerGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_price_list')
  String? get defaultPriceList => throw _privateConstructorUsedError;

  /// Serializes this B2bCustomerResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bCustomerResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bCustomerResultCopyWith<B2bCustomerResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bCustomerResultCopyWith<$Res> {
  factory $B2bCustomerResultCopyWith(
    B2bCustomerResult value,
    $Res Function(B2bCustomerResult) then,
  ) = _$B2bCustomerResultCopyWithImpl<$Res, B2bCustomerResult>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'default_price_list') String? defaultPriceList,
  });
}

/// @nodoc
class _$B2bCustomerResultCopyWithImpl<$Res, $Val extends B2bCustomerResult>
    implements $B2bCustomerResultCopyWith<$Res> {
  _$B2bCustomerResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bCustomerResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? defaultPriceList = freezed,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerGroup: null == customerGroup
                ? _value.customerGroup
                : customerGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultPriceList: freezed == defaultPriceList
                ? _value.defaultPriceList
                : defaultPriceList // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bCustomerResultImplCopyWith<$Res>
    implements $B2bCustomerResultCopyWith<$Res> {
  factory _$$B2bCustomerResultImplCopyWith(
    _$B2bCustomerResultImpl value,
    $Res Function(_$B2bCustomerResultImpl) then,
  ) = __$$B2bCustomerResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'default_price_list') String? defaultPriceList,
  });
}

/// @nodoc
class __$$B2bCustomerResultImplCopyWithImpl<$Res>
    extends _$B2bCustomerResultCopyWithImpl<$Res, _$B2bCustomerResultImpl>
    implements _$$B2bCustomerResultImplCopyWith<$Res> {
  __$$B2bCustomerResultImplCopyWithImpl(
    _$B2bCustomerResultImpl _value,
    $Res Function(_$B2bCustomerResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bCustomerResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? customerGroup = null,
    Object? defaultPriceList = freezed,
  }) {
    return _then(
      _$B2bCustomerResultImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerGroup: null == customerGroup
            ? _value.customerGroup
            : customerGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultPriceList: freezed == defaultPriceList
            ? _value.defaultPriceList
            : defaultPriceList // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bCustomerResultImpl implements _B2bCustomerResult {
  const _$B2bCustomerResultImpl({
    required this.customer,
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'customer_group') this.customerGroup = '',
    @JsonKey(name: 'default_price_list') this.defaultPriceList,
  });

  factory _$B2bCustomerResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bCustomerResultImplFromJson(json);

  @override
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'customer_group')
  final String customerGroup;
  @override
  @JsonKey(name: 'default_price_list')
  final String? defaultPriceList;

  @override
  String toString() {
    return 'B2bCustomerResult(customer: $customer, customerName: $customerName, customerGroup: $customerGroup, defaultPriceList: $defaultPriceList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bCustomerResultImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerGroup, customerGroup) ||
                other.customerGroup == customerGroup) &&
            (identical(other.defaultPriceList, defaultPriceList) ||
                other.defaultPriceList == defaultPriceList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    customerGroup,
    defaultPriceList,
  );

  /// Create a copy of B2bCustomerResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bCustomerResultImplCopyWith<_$B2bCustomerResultImpl> get copyWith =>
      __$$B2bCustomerResultImplCopyWithImpl<_$B2bCustomerResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bCustomerResultImplToJson(this);
  }
}

abstract class _B2bCustomerResult implements B2bCustomerResult {
  const factory _B2bCustomerResult({
    required final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'customer_group') final String customerGroup,
    @JsonKey(name: 'default_price_list') final String? defaultPriceList,
  }) = _$B2bCustomerResultImpl;

  factory _B2bCustomerResult.fromJson(Map<String, dynamic> json) =
      _$B2bCustomerResultImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'customer_group')
  String get customerGroup;
  @override
  @JsonKey(name: 'default_price_list')
  String? get defaultPriceList;

  /// Create a copy of B2bCustomerResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bCustomerResultImplCopyWith<_$B2bCustomerResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
