// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BatchLine _$BatchLineFromJson(Map<String, dynamic> json) {
  return _BatchLine.fromJson(json);
}

/// @nodoc
mixin _$BatchLine {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bom_name')
  String get bomName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;

  /// Finished units produced by one run of this BOM.
  @JsonKey(name: 'bom_qty_yield')
  double get bomQtyYield => throw _privateConstructorUsedError;

  /// How many BOM runs to queue. Fractional is allowed — some BOMs are
  /// weight-based and half a batch is a real thing to make.
  double get batches => throw _privateConstructorUsedError;
  List<BomComponent> get components => throw _privateConstructorUsedError;

  /// Serializes this BatchLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchLineCopyWith<BatchLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchLineCopyWith<$Res> {
  factory $BatchLineCopyWith(BatchLine value, $Res Function(BatchLine) then) =
      _$BatchLineCopyWithImpl<$Res, BatchLine>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'bom_name') String bomName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'bom_qty_yield') double bomQtyYield,
    double batches,
    List<BomComponent> components,
  });
}

/// @nodoc
class _$BatchLineCopyWithImpl<$Res, $Val extends BatchLine>
    implements $BatchLineCopyWith<$Res> {
  _$BatchLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? bomName = null,
    Object? stockUom = null,
    Object? bomQtyYield = null,
    Object? batches = null,
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
            bomName: null == bomName
                ? _value.bomName
                : bomName // ignore: cast_nullable_to_non_nullable
                      as String,
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            bomQtyYield: null == bomQtyYield
                ? _value.bomQtyYield
                : bomQtyYield // ignore: cast_nullable_to_non_nullable
                      as double,
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BatchLineImplCopyWith<$Res>
    implements $BatchLineCopyWith<$Res> {
  factory _$$BatchLineImplCopyWith(
    _$BatchLineImpl value,
    $Res Function(_$BatchLineImpl) then,
  ) = __$$BatchLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'bom_name') String bomName,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'bom_qty_yield') double bomQtyYield,
    double batches,
    List<BomComponent> components,
  });
}

/// @nodoc
class __$$BatchLineImplCopyWithImpl<$Res>
    extends _$BatchLineCopyWithImpl<$Res, _$BatchLineImpl>
    implements _$$BatchLineImplCopyWith<$Res> {
  __$$BatchLineImplCopyWithImpl(
    _$BatchLineImpl _value,
    $Res Function(_$BatchLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? bomName = null,
    Object? stockUom = null,
    Object? bomQtyYield = null,
    Object? batches = null,
    Object? components = null,
  }) {
    return _then(
      _$BatchLineImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        bomName: null == bomName
            ? _value.bomName
            : bomName // ignore: cast_nullable_to_non_nullable
                  as String,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        bomQtyYield: null == bomQtyYield
            ? _value.bomQtyYield
            : bomQtyYield // ignore: cast_nullable_to_non_nullable
                  as double,
        batches: null == batches
            ? _value.batches
            : batches // ignore: cast_nullable_to_non_nullable
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
class _$BatchLineImpl extends _BatchLine {
  const _$BatchLineImpl({
    @JsonKey(name: 'item_code') required this.itemCode,
    @JsonKey(name: 'item_name') required this.itemName,
    @JsonKey(name: 'bom_name') required this.bomName,
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    @JsonKey(name: 'bom_qty_yield') this.bomQtyYield = 1.0,
    this.batches = 1.0,
    final List<BomComponent> components = const <BomComponent>[],
  }) : _components = components,
       super._();

  factory _$BatchLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchLineImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'bom_name')
  final String bomName;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;

  /// Finished units produced by one run of this BOM.
  @override
  @JsonKey(name: 'bom_qty_yield')
  final double bomQtyYield;

  /// How many BOM runs to queue. Fractional is allowed — some BOMs are
  /// weight-based and half a batch is a real thing to make.
  @override
  @JsonKey()
  final double batches;
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
    return 'BatchLine(itemCode: $itemCode, itemName: $itemName, bomName: $bomName, stockUom: $stockUom, bomQtyYield: $bomQtyYield, batches: $batches, components: $components)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchLineImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.bomName, bomName) || other.bomName == bomName) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.bomQtyYield, bomQtyYield) ||
                other.bomQtyYield == bomQtyYield) &&
            (identical(other.batches, batches) || other.batches == batches) &&
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
    bomName,
    stockUom,
    bomQtyYield,
    batches,
    const DeepCollectionEquality().hash(_components),
  );

  /// Create a copy of BatchLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchLineImplCopyWith<_$BatchLineImpl> get copyWith =>
      __$$BatchLineImplCopyWithImpl<_$BatchLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchLineImplToJson(this);
  }
}

abstract class _BatchLine extends BatchLine {
  const factory _BatchLine({
    @JsonKey(name: 'item_code') required final String itemCode,
    @JsonKey(name: 'item_name') required final String itemName,
    @JsonKey(name: 'bom_name') required final String bomName,
    @JsonKey(name: 'stock_uom') final String stockUom,
    @JsonKey(name: 'bom_qty_yield') final double bomQtyYield,
    final double batches,
    final List<BomComponent> components,
  }) = _$BatchLineImpl;
  const _BatchLine._() : super._();

  factory _BatchLine.fromJson(Map<String, dynamic> json) =
      _$BatchLineImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'bom_name')
  String get bomName;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;

  /// Finished units produced by one run of this BOM.
  @override
  @JsonKey(name: 'bom_qty_yield')
  double get bomQtyYield;

  /// How many BOM runs to queue. Fractional is allowed — some BOMs are
  /// weight-based and half a batch is a real thing to make.
  @override
  double get batches;
  @override
  List<BomComponent> get components;

  /// Create a copy of BatchLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchLineImplCopyWith<_$BatchLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductionBasket _$ProductionBasketFromJson(Map<String, dynamic> json) {
  return _ProductionBasket.fromJson(json);
}

/// @nodoc
mixin _$ProductionBasket {
  List<BatchLine> get lines => throw _privateConstructorUsedError;
  @JsonKey(name: 'posting_date')
  DateTime? get postingDate => throw _privateConstructorUsedError;

  /// Serializes this ProductionBasket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionBasket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionBasketCopyWith<ProductionBasket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionBasketCopyWith<$Res> {
  factory $ProductionBasketCopyWith(
    ProductionBasket value,
    $Res Function(ProductionBasket) then,
  ) = _$ProductionBasketCopyWithImpl<$Res, ProductionBasket>;
  @useResult
  $Res call({
    List<BatchLine> lines,
    @JsonKey(name: 'posting_date') DateTime? postingDate,
  });
}

/// @nodoc
class _$ProductionBasketCopyWithImpl<$Res, $Val extends ProductionBasket>
    implements $ProductionBasketCopyWith<$Res> {
  _$ProductionBasketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionBasket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lines = null, Object? postingDate = freezed}) {
    return _then(
      _value.copyWith(
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<BatchLine>,
            postingDate: freezed == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionBasketImplCopyWith<$Res>
    implements $ProductionBasketCopyWith<$Res> {
  factory _$$ProductionBasketImplCopyWith(
    _$ProductionBasketImpl value,
    $Res Function(_$ProductionBasketImpl) then,
  ) = __$$ProductionBasketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<BatchLine> lines,
    @JsonKey(name: 'posting_date') DateTime? postingDate,
  });
}

/// @nodoc
class __$$ProductionBasketImplCopyWithImpl<$Res>
    extends _$ProductionBasketCopyWithImpl<$Res, _$ProductionBasketImpl>
    implements _$$ProductionBasketImplCopyWith<$Res> {
  __$$ProductionBasketImplCopyWithImpl(
    _$ProductionBasketImpl _value,
    $Res Function(_$ProductionBasketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionBasket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lines = null, Object? postingDate = freezed}) {
    return _then(
      _$ProductionBasketImpl(
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<BatchLine>,
        postingDate: freezed == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionBasketImpl extends _ProductionBasket {
  const _$ProductionBasketImpl({
    final List<BatchLine> lines = const <BatchLine>[],
    @JsonKey(name: 'posting_date') this.postingDate,
  }) : _lines = lines,
       super._();

  factory _$ProductionBasketImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionBasketImplFromJson(json);

  final List<BatchLine> _lines;
  @override
  @JsonKey()
  List<BatchLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  @JsonKey(name: 'posting_date')
  final DateTime? postingDate;

  @override
  String toString() {
    return 'ProductionBasket(lines: $lines, postingDate: $postingDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionBasketImpl &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_lines),
    postingDate,
  );

  /// Create a copy of ProductionBasket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionBasketImplCopyWith<_$ProductionBasketImpl> get copyWith =>
      __$$ProductionBasketImplCopyWithImpl<_$ProductionBasketImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionBasketImplToJson(this);
  }
}

abstract class _ProductionBasket extends ProductionBasket {
  const factory _ProductionBasket({
    final List<BatchLine> lines,
    @JsonKey(name: 'posting_date') final DateTime? postingDate,
  }) = _$ProductionBasketImpl;
  const _ProductionBasket._() : super._();

  factory _ProductionBasket.fromJson(Map<String, dynamic> json) =
      _$ProductionBasketImpl.fromJson;

  @override
  List<BatchLine> get lines;
  @override
  @JsonKey(name: 'posting_date')
  DateTime? get postingDate;

  /// Create a copy of ProductionBasket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionBasketImplCopyWith<_$ProductionBasketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
