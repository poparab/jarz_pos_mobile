// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bom_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BomItemSummary _$BomItemSummaryFromJson(Map<String, dynamic> json) {
  return _BomItemSummary.fromJson(json);
}

/// @nodoc
mixin _$BomItemSummary {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String get defaultBom => throw _privateConstructorUsedError;
  @JsonKey(name: 'bom_qty')
  double get bomQty => throw _privateConstructorUsedError;

  /// Serializes this BomItemSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BomItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BomItemSummaryCopyWith<BomItemSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BomItemSummaryCopyWith<$Res> {
  factory $BomItemSummaryCopyWith(
    BomItemSummary value,
    $Res Function(BomItemSummary) then,
  ) = _$BomItemSummaryCopyWithImpl<$Res, BomItemSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
  });
}

/// @nodoc
class _$BomItemSummaryCopyWithImpl<$Res, $Val extends BomItemSummary>
    implements $BomItemSummaryCopyWith<$Res> {
  _$BomItemSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BomItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
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
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultBom: null == defaultBom
                ? _value.defaultBom
                : defaultBom // ignore: cast_nullable_to_non_nullable
                      as String,
            bomQty: null == bomQty
                ? _value.bomQty
                : bomQty // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BomItemSummaryImplCopyWith<$Res>
    implements $BomItemSummaryCopyWith<$Res> {
  factory _$$BomItemSummaryImplCopyWith(
    _$BomItemSummaryImpl value,
    $Res Function(_$BomItemSummaryImpl) then,
  ) = __$$BomItemSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
  });
}

/// @nodoc
class __$$BomItemSummaryImplCopyWithImpl<$Res>
    extends _$BomItemSummaryCopyWithImpl<$Res, _$BomItemSummaryImpl>
    implements _$$BomItemSummaryImplCopyWith<$Res> {
  __$$BomItemSummaryImplCopyWithImpl(
    _$BomItemSummaryImpl _value,
    $Res Function(_$BomItemSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BomItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
  }) {
    return _then(
      _$BomItemSummaryImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultBom: null == defaultBom
            ? _value.defaultBom
            : defaultBom // ignore: cast_nullable_to_non_nullable
                  as String,
        bomQty: null == bomQty
            ? _value.bomQty
            : bomQty // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BomItemSummaryImpl implements _BomItemSummary {
  const _$BomItemSummaryImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    @JsonKey(name: 'default_bom') this.defaultBom = '',
    @JsonKey(name: 'bom_qty') this.bomQty = 1.0,
  });

  factory _$BomItemSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BomItemSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  @override
  @JsonKey(name: 'default_bom')
  final String defaultBom;
  @override
  @JsonKey(name: 'bom_qty')
  final double bomQty;

  @override
  String toString() {
    return 'BomItemSummary(itemCode: $itemCode, itemName: $itemName, stockUom: $stockUom, defaultBom: $defaultBom, bomQty: $bomQty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BomItemSummaryImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.bomQty, bomQty) || other.bomQty == bomQty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    stockUom,
    defaultBom,
    bomQty,
  );

  /// Create a copy of BomItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BomItemSummaryImplCopyWith<_$BomItemSummaryImpl> get copyWith =>
      __$$BomItemSummaryImplCopyWithImpl<_$BomItemSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BomItemSummaryImplToJson(this);
  }
}

abstract class _BomItemSummary implements BomItemSummary {
  const factory _BomItemSummary({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'stock_uom') final String stockUom,
    @JsonKey(name: 'default_bom') final String defaultBom,
    @JsonKey(name: 'bom_qty') final double bomQty,
  }) = _$BomItemSummaryImpl;

  factory _BomItemSummary.fromJson(Map<String, dynamic> json) =
      _$BomItemSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  @JsonKey(name: 'default_bom')
  String get defaultBom;
  @override
  @JsonKey(name: 'bom_qty')
  double get bomQty;

  /// Create a copy of BomItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BomItemSummaryImplCopyWith<_$BomItemSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BomDetails _$BomDetailsFromJson(Map<String, dynamic> json) {
  return _BomDetails.fromJson(json);
}

/// @nodoc
mixin _$BomDetails {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String get defaultBom => throw _privateConstructorUsedError;

  /// Finished units produced by one run of this BOM.
  @JsonKey(name: 'bom_qty')
  double get bomQty => throw _privateConstructorUsedError;
  List<BomComponent> get components => throw _privateConstructorUsedError;

  /// Serializes this BomDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BomDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BomDetailsCopyWith<BomDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BomDetailsCopyWith<$Res> {
  factory $BomDetailsCopyWith(
    BomDetails value,
    $Res Function(BomDetails) then,
  ) = _$BomDetailsCopyWithImpl<$Res, BomDetails>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
    List<BomComponent> components,
  });
}

/// @nodoc
class _$BomDetailsCopyWithImpl<$Res, $Val extends BomDetails>
    implements $BomDetailsCopyWith<$Res> {
  _$BomDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BomDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
    Object? components = null,
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
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultBom: null == defaultBom
                ? _value.defaultBom
                : defaultBom // ignore: cast_nullable_to_non_nullable
                      as String,
            bomQty: null == bomQty
                ? _value.bomQty
                : bomQty // ignore: cast_nullable_to_non_nullable
                      as double,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<BomComponent>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BomDetailsImplCopyWith<$Res>
    implements $BomDetailsCopyWith<$Res> {
  factory _$$BomDetailsImplCopyWith(
    _$BomDetailsImpl value,
    $Res Function(_$BomDetailsImpl) then,
  ) = __$$BomDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
    List<BomComponent> components,
  });
}

/// @nodoc
class __$$BomDetailsImplCopyWithImpl<$Res>
    extends _$BomDetailsCopyWithImpl<$Res, _$BomDetailsImpl>
    implements _$$BomDetailsImplCopyWith<$Res> {
  __$$BomDetailsImplCopyWithImpl(
    _$BomDetailsImpl _value,
    $Res Function(_$BomDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BomDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
    Object? components = null,
  }) {
    return _then(
      _$BomDetailsImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultBom: null == defaultBom
            ? _value.defaultBom
            : defaultBom // ignore: cast_nullable_to_non_nullable
                  as String,
        bomQty: null == bomQty
            ? _value.bomQty
            : bomQty // ignore: cast_nullable_to_non_nullable
                  as double,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<BomComponent>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BomDetailsImpl implements _BomDetails {
  const _$BomDetailsImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    @JsonKey(name: 'default_bom') this.defaultBom = '',
    @JsonKey(name: 'bom_qty') this.bomQty = 1.0,
    final List<BomComponent> components = const <BomComponent>[],
  }) : _components = components;

  factory _$BomDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BomDetailsImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  @override
  @JsonKey(name: 'default_bom')
  final String defaultBom;

  /// Finished units produced by one run of this BOM.
  @override
  @JsonKey(name: 'bom_qty')
  final double bomQty;
  final List<BomComponent> _components;
  @override
  @JsonKey()
  List<BomComponent> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  @override
  String toString() {
    return 'BomDetails(itemCode: $itemCode, itemName: $itemName, stockUom: $stockUom, defaultBom: $defaultBom, bomQty: $bomQty, components: $components)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BomDetailsImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.bomQty, bomQty) || other.bomQty == bomQty) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    stockUom,
    defaultBom,
    bomQty,
    const DeepCollectionEquality().hash(_components),
  );

  /// Create a copy of BomDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BomDetailsImplCopyWith<_$BomDetailsImpl> get copyWith =>
      __$$BomDetailsImplCopyWithImpl<_$BomDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BomDetailsImplToJson(this);
  }
}

abstract class _BomDetails implements BomDetails {
  const factory _BomDetails({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'stock_uom') final String stockUom,
    @JsonKey(name: 'default_bom') final String defaultBom,
    @JsonKey(name: 'bom_qty') final double bomQty,
    final List<BomComponent> components,
  }) = _$BomDetailsImpl;

  factory _BomDetails.fromJson(Map<String, dynamic> json) =
      _$BomDetailsImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  @JsonKey(name: 'default_bom')
  String get defaultBom;

  /// Finished units produced by one run of this BOM.
  @override
  @JsonKey(name: 'bom_qty')
  double get bomQty;
  @override
  List<BomComponent> get components;

  /// Create a copy of BomDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BomDetailsImplCopyWith<_$BomDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BomComponent _$BomComponentFromJson(Map<String, dynamic> json) {
  return _BomComponent.fromJson(json);
}

/// @nodoc
mixin _$BomComponent {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;

  /// Quantity consumed by exactly one BOM run.
  @JsonKey(name: 'qty_per_bom')
  double get qtyPerBom => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double? get availableQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse => throw _privateConstructorUsedError;

  /// Serializes this BomComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BomComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BomComponentCopyWith<BomComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BomComponentCopyWith<$Res> {
  factory $BomComponentCopyWith(
    BomComponent value,
    $Res Function(BomComponent) then,
  ) = _$BomComponentCopyWithImpl<$Res, BomComponent>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'qty_per_bom') double qtyPerBom,
    @JsonKey(name: 'available_qty') double? availableQty,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
  });
}

/// @nodoc
class _$BomComponentCopyWithImpl<$Res, $Val extends BomComponent>
    implements $BomComponentCopyWith<$Res> {
  _$BomComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BomComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? qtyPerBom = null,
    Object? availableQty = freezed,
    Object? sourceWarehouse = freezed,
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
            uom: null == uom
                ? _value.uom
                : uom // ignore: cast_nullable_to_non_nullable
                      as String,
            qtyPerBom: null == qtyPerBom
                ? _value.qtyPerBom
                : qtyPerBom // ignore: cast_nullable_to_non_nullable
                      as double,
            availableQty: freezed == availableQty
                ? _value.availableQty
                : availableQty // ignore: cast_nullable_to_non_nullable
                      as double?,
            sourceWarehouse: freezed == sourceWarehouse
                ? _value.sourceWarehouse
                : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BomComponentImplCopyWith<$Res>
    implements $BomComponentCopyWith<$Res> {
  factory _$$BomComponentImplCopyWith(
    _$BomComponentImpl value,
    $Res Function(_$BomComponentImpl) then,
  ) = __$$BomComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'qty_per_bom') double qtyPerBom,
    @JsonKey(name: 'available_qty') double? availableQty,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
  });
}

/// @nodoc
class __$$BomComponentImplCopyWithImpl<$Res>
    extends _$BomComponentCopyWithImpl<$Res, _$BomComponentImpl>
    implements _$$BomComponentImplCopyWith<$Res> {
  __$$BomComponentImplCopyWithImpl(
    _$BomComponentImpl _value,
    $Res Function(_$BomComponentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BomComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? qtyPerBom = null,
    Object? availableQty = freezed,
    Object? sourceWarehouse = freezed,
  }) {
    return _then(
      _$BomComponentImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        uom: null == uom
            ? _value.uom
            : uom // ignore: cast_nullable_to_non_nullable
                  as String,
        qtyPerBom: null == qtyPerBom
            ? _value.qtyPerBom
            : qtyPerBom // ignore: cast_nullable_to_non_nullable
                  as double,
        availableQty: freezed == availableQty
            ? _value.availableQty
            : availableQty // ignore: cast_nullable_to_non_nullable
                  as double?,
        sourceWarehouse: freezed == sourceWarehouse
            ? _value.sourceWarehouse
            : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BomComponentImpl extends _BomComponent {
  const _$BomComponentImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.uom = '',
    @JsonKey(name: 'qty_per_bom') this.qtyPerBom = 0.0,
    @JsonKey(name: 'available_qty') this.availableQty,
    @JsonKey(name: 'source_warehouse') this.sourceWarehouse,
  }) : super._();

  factory _$BomComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$BomComponentImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey()
  final String uom;

  /// Quantity consumed by exactly one BOM run.
  @override
  @JsonKey(name: 'qty_per_bom')
  final double qtyPerBom;
  @override
  @JsonKey(name: 'available_qty')
  final double? availableQty;
  @override
  @JsonKey(name: 'source_warehouse')
  final String? sourceWarehouse;

  @override
  String toString() {
    return 'BomComponent(itemCode: $itemCode, itemName: $itemName, uom: $uom, qtyPerBom: $qtyPerBom, availableQty: $availableQty, sourceWarehouse: $sourceWarehouse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BomComponentImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.qtyPerBom, qtyPerBom) ||
                other.qtyPerBom == qtyPerBom) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty) &&
            (identical(other.sourceWarehouse, sourceWarehouse) ||
                other.sourceWarehouse == sourceWarehouse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    uom,
    qtyPerBom,
    availableQty,
    sourceWarehouse,
  );

  /// Create a copy of BomComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BomComponentImplCopyWith<_$BomComponentImpl> get copyWith =>
      __$$BomComponentImplCopyWithImpl<_$BomComponentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BomComponentImplToJson(this);
  }
}

abstract class _BomComponent extends BomComponent {
  const factory _BomComponent({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String uom,
    @JsonKey(name: 'qty_per_bom') final double qtyPerBom,
    @JsonKey(name: 'available_qty') final double? availableQty,
    @JsonKey(name: 'source_warehouse') final String? sourceWarehouse,
  }) = _$BomComponentImpl;
  const _BomComponent._() : super._();

  factory _BomComponent.fromJson(Map<String, dynamic> json) =
      _$BomComponentImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String get uom;

  /// Quantity consumed by exactly one BOM run.
  @override
  @JsonKey(name: 'qty_per_bom')
  double get qtyPerBom;
  @override
  @JsonKey(name: 'available_qty')
  double? get availableQty;
  @override
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse;

  /// Create a copy of BomComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BomComponentImplCopyWith<_$BomComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
