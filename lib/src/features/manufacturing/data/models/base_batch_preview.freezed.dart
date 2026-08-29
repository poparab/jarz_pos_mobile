// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_batch_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BaseBatchPreview _$BaseBatchPreviewFromJson(Map<String, dynamic> json) {
  return _BaseBatchPreview.fromJson(json);
}

/// @nodoc
mixin _$BaseBatchPreview {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'bom_name')
  String get bomName => throw _privateConstructorUsedError;
  String get company => throw _privateConstructorUsedError;
  double get batches => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_yield')
  double get batchYield => throw _privateConstructorUsedError;

  /// `batches * batch_yield`, computed server-side. This is what goes to
  /// `start_production_batch` — the client only recomputes it when a preview
  /// could not be fetched at all.
  @JsonKey(name: 'item_qty')
  double get itemQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  List<BasePreviewComponent> get components =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'has_shortage')
  bool get hasShortage => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_cost')
  double? get estimatedCost => throw _privateConstructorUsedError;

  /// False when the chosen figure is off the mixer's published run grid.
  /// A warning, never a block.
  @JsonKey(name: 'run_size_ok')
  bool get runSizeOk => throw _privateConstructorUsedError;
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_sop')
  bool get hasSop => throw _privateConstructorUsedError;

  /// Serializes this BaseBatchPreview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseBatchPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseBatchPreviewCopyWith<BaseBatchPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseBatchPreviewCopyWith<$Res> {
  factory $BaseBatchPreviewCopyWith(
    BaseBatchPreview value,
    $Res Function(BaseBatchPreview) then,
  ) = _$BaseBatchPreviewCopyWithImpl<$Res, BaseBatchPreview>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'bom_name') String bomName,
    String company,
    double batches,
    @JsonKey(name: 'batch_yield') double batchYield,
    @JsonKey(name: 'item_qty') double itemQty,
    @JsonKey(name: 'stock_uom') String stockUom,
    List<BasePreviewComponent> components,
    @JsonKey(name: 'has_shortage') bool hasShortage,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,
    @JsonKey(name: 'run_size_ok') bool runSizeOk,
    @JsonKey(name: 'run_sizes') List<double>? runSizes,
    @JsonKey(name: 'has_sop') bool hasSop,
  });
}

/// @nodoc
class _$BaseBatchPreviewCopyWithImpl<$Res, $Val extends BaseBatchPreview>
    implements $BaseBatchPreviewCopyWith<$Res> {
  _$BaseBatchPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseBatchPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? bomName = null,
    Object? company = null,
    Object? batches = null,
    Object? batchYield = null,
    Object? itemQty = null,
    Object? stockUom = null,
    Object? components = null,
    Object? hasShortage = null,
    Object? estimatedCost = freezed,
    Object? runSizeOk = null,
    Object? runSizes = freezed,
    Object? hasSop = null,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            bomName: null == bomName
                ? _value.bomName
                : bomName // ignore: cast_nullable_to_non_nullable
                      as String,
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
                      as double,
            batchYield: null == batchYield
                ? _value.batchYield
                : batchYield // ignore: cast_nullable_to_non_nullable
                      as double,
            itemQty: null == itemQty
                ? _value.itemQty
                : itemQty // ignore: cast_nullable_to_non_nullable
                      as double,
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<BasePreviewComponent>,
            hasShortage: null == hasShortage
                ? _value.hasShortage
                : hasShortage // ignore: cast_nullable_to_non_nullable
                      as bool,
            estimatedCost: freezed == estimatedCost
                ? _value.estimatedCost
                : estimatedCost // ignore: cast_nullable_to_non_nullable
                      as double?,
            runSizeOk: null == runSizeOk
                ? _value.runSizeOk
                : runSizeOk // ignore: cast_nullable_to_non_nullable
                      as bool,
            runSizes: freezed == runSizes
                ? _value.runSizes
                : runSizes // ignore: cast_nullable_to_non_nullable
                      as List<double>?,
            hasSop: null == hasSop
                ? _value.hasSop
                : hasSop // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseBatchPreviewImplCopyWith<$Res>
    implements $BaseBatchPreviewCopyWith<$Res> {
  factory _$$BaseBatchPreviewImplCopyWith(
    _$BaseBatchPreviewImpl value,
    $Res Function(_$BaseBatchPreviewImpl) then,
  ) = __$$BaseBatchPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'bom_name') String bomName,
    String company,
    double batches,
    @JsonKey(name: 'batch_yield') double batchYield,
    @JsonKey(name: 'item_qty') double itemQty,
    @JsonKey(name: 'stock_uom') String stockUom,
    List<BasePreviewComponent> components,
    @JsonKey(name: 'has_shortage') bool hasShortage,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,
    @JsonKey(name: 'run_size_ok') bool runSizeOk,
    @JsonKey(name: 'run_sizes') List<double>? runSizes,
    @JsonKey(name: 'has_sop') bool hasSop,
  });
}

/// @nodoc
class __$$BaseBatchPreviewImplCopyWithImpl<$Res>
    extends _$BaseBatchPreviewCopyWithImpl<$Res, _$BaseBatchPreviewImpl>
    implements _$$BaseBatchPreviewImplCopyWith<$Res> {
  __$$BaseBatchPreviewImplCopyWithImpl(
    _$BaseBatchPreviewImpl _value,
    $Res Function(_$BaseBatchPreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseBatchPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? bomName = null,
    Object? company = null,
    Object? batches = null,
    Object? batchYield = null,
    Object? itemQty = null,
    Object? stockUom = null,
    Object? components = null,
    Object? hasShortage = null,
    Object? estimatedCost = freezed,
    Object? runSizeOk = null,
    Object? runSizes = freezed,
    Object? hasSop = null,
  }) {
    return _then(
      _$BaseBatchPreviewImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        bomName: null == bomName
            ? _value.bomName
            : bomName // ignore: cast_nullable_to_non_nullable
                  as String,
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        batches: null == batches
            ? _value.batches
            : batches // ignore: cast_nullable_to_non_nullable
                  as double,
        batchYield: null == batchYield
            ? _value.batchYield
            : batchYield // ignore: cast_nullable_to_non_nullable
                  as double,
        itemQty: null == itemQty
            ? _value.itemQty
            : itemQty // ignore: cast_nullable_to_non_nullable
                  as double,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<BasePreviewComponent>,
        hasShortage: null == hasShortage
            ? _value.hasShortage
            : hasShortage // ignore: cast_nullable_to_non_nullable
                  as bool,
        estimatedCost: freezed == estimatedCost
            ? _value.estimatedCost
            : estimatedCost // ignore: cast_nullable_to_non_nullable
                  as double?,
        runSizeOk: null == runSizeOk
            ? _value.runSizeOk
            : runSizeOk // ignore: cast_nullable_to_non_nullable
                  as bool,
        runSizes: freezed == runSizes
            ? _value._runSizes
            : runSizes // ignore: cast_nullable_to_non_nullable
                  as List<double>?,
        hasSop: null == hasSop
            ? _value.hasSop
            : hasSop // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseBatchPreviewImpl extends _BaseBatchPreview {
  const _$BaseBatchPreviewImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'bom_name') this.bomName = '',
    this.company = '',
    this.batches = 0.0,
    @JsonKey(name: 'batch_yield') this.batchYield = 1.0,
    @JsonKey(name: 'item_qty') this.itemQty = 0.0,
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    final List<BasePreviewComponent> components =
        const <BasePreviewComponent>[],
    @JsonKey(name: 'has_shortage') this.hasShortage = false,
    @JsonKey(name: 'estimated_cost') this.estimatedCost,
    @JsonKey(name: 'run_size_ok') this.runSizeOk = true,
    @JsonKey(name: 'run_sizes') final List<double>? runSizes,
    @JsonKey(name: 'has_sop') this.hasSop = false,
  }) : _components = components,
       _runSizes = runSizes,
       super._();

  factory _$BaseBatchPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseBatchPreviewImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'bom_name')
  final String bomName;
  @override
  @JsonKey()
  final String company;
  @override
  @JsonKey()
  final double batches;
  @override
  @JsonKey(name: 'batch_yield')
  final double batchYield;

  /// `batches * batch_yield`, computed server-side. This is what goes to
  /// `start_production_batch` — the client only recomputes it when a preview
  /// could not be fetched at all.
  @override
  @JsonKey(name: 'item_qty')
  final double itemQty;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  final List<BasePreviewComponent> _components;
  @override
  @JsonKey()
  List<BasePreviewComponent> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  @override
  @JsonKey(name: 'has_shortage')
  final bool hasShortage;
  @override
  @JsonKey(name: 'estimated_cost')
  final double? estimatedCost;

  /// False when the chosen figure is off the mixer's published run grid.
  /// A warning, never a block.
  @override
  @JsonKey(name: 'run_size_ok')
  final bool runSizeOk;
  final List<double>? _runSizes;
  @override
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes {
    final value = _runSizes;
    if (value == null) return null;
    if (_runSizes is EqualUnmodifiableListView) return _runSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'has_sop')
  final bool hasSop;

  @override
  String toString() {
    return 'BaseBatchPreview(itemCode: $itemCode, bomName: $bomName, company: $company, batches: $batches, batchYield: $batchYield, itemQty: $itemQty, stockUom: $stockUom, components: $components, hasShortage: $hasShortage, estimatedCost: $estimatedCost, runSizeOk: $runSizeOk, runSizes: $runSizes, hasSop: $hasSop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseBatchPreviewImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.bomName, bomName) || other.bomName == bomName) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.batches, batches) || other.batches == batches) &&
            (identical(other.batchYield, batchYield) ||
                other.batchYield == batchYield) &&
            (identical(other.itemQty, itemQty) || other.itemQty == itemQty) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ) &&
            (identical(other.hasShortage, hasShortage) ||
                other.hasShortage == hasShortage) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.runSizeOk, runSizeOk) ||
                other.runSizeOk == runSizeOk) &&
            const DeepCollectionEquality().equals(other._runSizes, _runSizes) &&
            (identical(other.hasSop, hasSop) || other.hasSop == hasSop));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    bomName,
    company,
    batches,
    batchYield,
    itemQty,
    stockUom,
    const DeepCollectionEquality().hash(_components),
    hasShortage,
    estimatedCost,
    runSizeOk,
    const DeepCollectionEquality().hash(_runSizes),
    hasSop,
  );

  /// Create a copy of BaseBatchPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseBatchPreviewImplCopyWith<_$BaseBatchPreviewImpl> get copyWith =>
      __$$BaseBatchPreviewImplCopyWithImpl<_$BaseBatchPreviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseBatchPreviewImplToJson(this);
  }
}

abstract class _BaseBatchPreview extends BaseBatchPreview {
  const factory _BaseBatchPreview({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'bom_name') final String bomName,
    final String company,
    final double batches,
    @JsonKey(name: 'batch_yield') final double batchYield,
    @JsonKey(name: 'item_qty') final double itemQty,
    @JsonKey(name: 'stock_uom') final String stockUom,
    final List<BasePreviewComponent> components,
    @JsonKey(name: 'has_shortage') final bool hasShortage,
    @JsonKey(name: 'estimated_cost') final double? estimatedCost,
    @JsonKey(name: 'run_size_ok') final bool runSizeOk,
    @JsonKey(name: 'run_sizes') final List<double>? runSizes,
    @JsonKey(name: 'has_sop') final bool hasSop,
  }) = _$BaseBatchPreviewImpl;
  const _BaseBatchPreview._() : super._();

  factory _BaseBatchPreview.fromJson(Map<String, dynamic> json) =
      _$BaseBatchPreviewImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'bom_name')
  String get bomName;
  @override
  String get company;
  @override
  double get batches;
  @override
  @JsonKey(name: 'batch_yield')
  double get batchYield;

  /// `batches * batch_yield`, computed server-side. This is what goes to
  /// `start_production_batch` — the client only recomputes it when a preview
  /// could not be fetched at all.
  @override
  @JsonKey(name: 'item_qty')
  double get itemQty;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  List<BasePreviewComponent> get components;
  @override
  @JsonKey(name: 'has_shortage')
  bool get hasShortage;
  @override
  @JsonKey(name: 'estimated_cost')
  double? get estimatedCost;

  /// False when the chosen figure is off the mixer's published run grid.
  /// A warning, never a block.
  @override
  @JsonKey(name: 'run_size_ok')
  bool get runSizeOk;
  @override
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes;
  @override
  @JsonKey(name: 'has_sop')
  bool get hasSop;

  /// Create a copy of BaseBatchPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseBatchPreviewImplCopyWith<_$BaseBatchPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BasePreviewComponent _$BasePreviewComponentFromJson(Map<String, dynamic> json) {
  return _BasePreviewComponent.fromJson(json);
}

/// @nodoc
mixin _$BasePreviewComponent {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;

  /// For the whole run, not per batch.
  @JsonKey(name: 'required_qty')
  double get requiredQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double get availableQty => throw _privateConstructorUsedError;
  double get shortfall => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse => throw _privateConstructorUsedError;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @JsonKey(name: 'available_elsewhere')
  double? get availableElsewhere => throw _privateConstructorUsedError;
  List<StockAlternative>? get alternatives =>
      throw _privateConstructorUsedError;

  /// Serializes this BasePreviewComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BasePreviewComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BasePreviewComponentCopyWith<BasePreviewComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BasePreviewComponentCopyWith<$Res> {
  factory $BasePreviewComponentCopyWith(
    BasePreviewComponent value,
    $Res Function(BasePreviewComponent) then,
  ) = _$BasePreviewComponentCopyWithImpl<$Res, BasePreviewComponent>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    double shortfall,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
    @JsonKey(name: 'available_elsewhere') double? availableElsewhere,
    List<StockAlternative>? alternatives,
  });
}

/// @nodoc
class _$BasePreviewComponentCopyWithImpl<
  $Res,
  $Val extends BasePreviewComponent
>
    implements $BasePreviewComponentCopyWith<$Res> {
  _$BasePreviewComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BasePreviewComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? requiredQty = null,
    Object? availableQty = null,
    Object? shortfall = null,
    Object? sourceWarehouse = freezed,
    Object? availableElsewhere = freezed,
    Object? alternatives = freezed,
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
            requiredQty: null == requiredQty
                ? _value.requiredQty
                : requiredQty // ignore: cast_nullable_to_non_nullable
                      as double,
            availableQty: null == availableQty
                ? _value.availableQty
                : availableQty // ignore: cast_nullable_to_non_nullable
                      as double,
            shortfall: null == shortfall
                ? _value.shortfall
                : shortfall // ignore: cast_nullable_to_non_nullable
                      as double,
            sourceWarehouse: freezed == sourceWarehouse
                ? _value.sourceWarehouse
                : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            availableElsewhere: freezed == availableElsewhere
                ? _value.availableElsewhere
                : availableElsewhere // ignore: cast_nullable_to_non_nullable
                      as double?,
            alternatives: freezed == alternatives
                ? _value.alternatives
                : alternatives // ignore: cast_nullable_to_non_nullable
                      as List<StockAlternative>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BasePreviewComponentImplCopyWith<$Res>
    implements $BasePreviewComponentCopyWith<$Res> {
  factory _$$BasePreviewComponentImplCopyWith(
    _$BasePreviewComponentImpl value,
    $Res Function(_$BasePreviewComponentImpl) then,
  ) = __$$BasePreviewComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    double shortfall,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
    @JsonKey(name: 'available_elsewhere') double? availableElsewhere,
    List<StockAlternative>? alternatives,
  });
}

/// @nodoc
class __$$BasePreviewComponentImplCopyWithImpl<$Res>
    extends _$BasePreviewComponentCopyWithImpl<$Res, _$BasePreviewComponentImpl>
    implements _$$BasePreviewComponentImplCopyWith<$Res> {
  __$$BasePreviewComponentImplCopyWithImpl(
    _$BasePreviewComponentImpl _value,
    $Res Function(_$BasePreviewComponentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BasePreviewComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? requiredQty = null,
    Object? availableQty = null,
    Object? shortfall = null,
    Object? sourceWarehouse = freezed,
    Object? availableElsewhere = freezed,
    Object? alternatives = freezed,
  }) {
    return _then(
      _$BasePreviewComponentImpl(
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
        requiredQty: null == requiredQty
            ? _value.requiredQty
            : requiredQty // ignore: cast_nullable_to_non_nullable
                  as double,
        availableQty: null == availableQty
            ? _value.availableQty
            : availableQty // ignore: cast_nullable_to_non_nullable
                  as double,
        shortfall: null == shortfall
            ? _value.shortfall
            : shortfall // ignore: cast_nullable_to_non_nullable
                  as double,
        sourceWarehouse: freezed == sourceWarehouse
            ? _value.sourceWarehouse
            : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        availableElsewhere: freezed == availableElsewhere
            ? _value.availableElsewhere
            : availableElsewhere // ignore: cast_nullable_to_non_nullable
                  as double?,
        alternatives: freezed == alternatives
            ? _value._alternatives
            : alternatives // ignore: cast_nullable_to_non_nullable
                  as List<StockAlternative>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BasePreviewComponentImpl extends _BasePreviewComponent {
  const _$BasePreviewComponentImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.uom = '',
    @JsonKey(name: 'required_qty') this.requiredQty = 0.0,
    @JsonKey(name: 'available_qty') this.availableQty = 0.0,
    this.shortfall = 0.0,
    @JsonKey(name: 'source_warehouse') this.sourceWarehouse,
    @JsonKey(name: 'available_elsewhere') this.availableElsewhere,
    final List<StockAlternative>? alternatives,
  }) : _alternatives = alternatives,
       super._();

  factory _$BasePreviewComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$BasePreviewComponentImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey()
  final String uom;

  /// For the whole run, not per batch.
  @override
  @JsonKey(name: 'required_qty')
  final double requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  final double availableQty;
  @override
  @JsonKey()
  final double shortfall;
  @override
  @JsonKey(name: 'source_warehouse')
  final String? sourceWarehouse;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @override
  @JsonKey(name: 'available_elsewhere')
  final double? availableElsewhere;
  final List<StockAlternative>? _alternatives;
  @override
  List<StockAlternative>? get alternatives {
    final value = _alternatives;
    if (value == null) return null;
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'BasePreviewComponent(itemCode: $itemCode, itemName: $itemName, uom: $uom, requiredQty: $requiredQty, availableQty: $availableQty, shortfall: $shortfall, sourceWarehouse: $sourceWarehouse, availableElsewhere: $availableElsewhere, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BasePreviewComponentImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.requiredQty, requiredQty) ||
                other.requiredQty == requiredQty) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty) &&
            (identical(other.shortfall, shortfall) ||
                other.shortfall == shortfall) &&
            (identical(other.sourceWarehouse, sourceWarehouse) ||
                other.sourceWarehouse == sourceWarehouse) &&
            (identical(other.availableElsewhere, availableElsewhere) ||
                other.availableElsewhere == availableElsewhere) &&
            const DeepCollectionEquality().equals(
              other._alternatives,
              _alternatives,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    uom,
    requiredQty,
    availableQty,
    shortfall,
    sourceWarehouse,
    availableElsewhere,
    const DeepCollectionEquality().hash(_alternatives),
  );

  /// Create a copy of BasePreviewComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BasePreviewComponentImplCopyWith<_$BasePreviewComponentImpl>
  get copyWith =>
      __$$BasePreviewComponentImplCopyWithImpl<_$BasePreviewComponentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BasePreviewComponentImplToJson(this);
  }
}

abstract class _BasePreviewComponent extends BasePreviewComponent {
  const factory _BasePreviewComponent({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String uom,
    @JsonKey(name: 'required_qty') final double requiredQty,
    @JsonKey(name: 'available_qty') final double availableQty,
    final double shortfall,
    @JsonKey(name: 'source_warehouse') final String? sourceWarehouse,
    @JsonKey(name: 'available_elsewhere') final double? availableElsewhere,
    final List<StockAlternative>? alternatives,
  }) = _$BasePreviewComponentImpl;
  const _BasePreviewComponent._() : super._();

  factory _BasePreviewComponent.fromJson(Map<String, dynamic> json) =
      _$BasePreviewComponentImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String get uom;

  /// For the whole run, not per batch.
  @override
  @JsonKey(name: 'required_qty')
  double get requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  double get availableQty;
  @override
  double get shortfall;
  @override
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @override
  @JsonKey(name: 'available_elsewhere')
  double? get availableElsewhere;
  @override
  List<StockAlternative>? get alternatives;

  /// Create a copy of BasePreviewComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BasePreviewComponentImplCopyWith<_$BasePreviewComponentImpl>
  get copyWith => throw _privateConstructorUsedError;
}
