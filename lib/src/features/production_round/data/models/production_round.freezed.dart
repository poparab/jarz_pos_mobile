// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductionRoundItemBranch _$ProductionRoundItemBranchFromJson(
  Map<String, dynamic> json,
) {
  return _ProductionRoundItemBranch.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundItemBranch {
  @JsonKey(fromJson: _readString)
  String get warehouse => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales => throw _privateConstructorUsedError;

  /// The branch's target holding: its weekly rate over the full cover.
  @JsonKey(fromJson: _readNum)
  double get par => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get fill => throw _privateConstructorUsedError;

  /// Null when the branch never sold the item — distinct from zero, which
  /// means "sells, and has run out".
  @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
  double? get daysOfCover => throw _privateConstructorUsedError;
  @JsonKey(name: 'below_backup', fromJson: _readFlag)
  bool get belowBackup => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
  bool get stockIsNegative => throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundItemBranch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundItemBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundItemBranchCopyWith<ProductionRoundItemBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundItemBranchCopyWith<$Res> {
  factory $ProductionRoundItemBranchCopyWith(
    ProductionRoundItemBranch value,
    $Res Function(ProductionRoundItemBranch) then,
  ) = _$ProductionRoundItemBranchCopyWithImpl<$Res, ProductionRoundItemBranch>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _readString) String warehouse,
    @JsonKey(fromJson: _readString) String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(fromJson: _readNum) double par,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(fromJson: _readNum) double fill,
    @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
    double? daysOfCover,
    @JsonKey(name: 'below_backup', fromJson: _readFlag) bool belowBackup,
    @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
    bool stockIsNegative,
  });
}

/// @nodoc
class _$ProductionRoundItemBranchCopyWithImpl<
  $Res,
  $Val extends ProductionRoundItemBranch
>
    implements $ProductionRoundItemBranchCopyWith<$Res> {
  _$ProductionRoundItemBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundItemBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouse = null,
    Object? label = null,
    Object? weeklySales = null,
    Object? par = null,
    Object? onHand = null,
    Object? fill = null,
    Object? daysOfCover = freezed,
    Object? belowBackup = null,
    Object? stockIsNegative = null,
  }) {
    return _then(
      _value.copyWith(
            warehouse: null == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            weeklySales: null == weeklySales
                ? _value.weeklySales
                : weeklySales // ignore: cast_nullable_to_non_nullable
                      as double,
            par: null == par
                ? _value.par
                : par // ignore: cast_nullable_to_non_nullable
                      as double,
            onHand: null == onHand
                ? _value.onHand
                : onHand // ignore: cast_nullable_to_non_nullable
                      as double,
            fill: null == fill
                ? _value.fill
                : fill // ignore: cast_nullable_to_non_nullable
                      as double,
            daysOfCover: freezed == daysOfCover
                ? _value.daysOfCover
                : daysOfCover // ignore: cast_nullable_to_non_nullable
                      as double?,
            belowBackup: null == belowBackup
                ? _value.belowBackup
                : belowBackup // ignore: cast_nullable_to_non_nullable
                      as bool,
            stockIsNegative: null == stockIsNegative
                ? _value.stockIsNegative
                : stockIsNegative // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundItemBranchImplCopyWith<$Res>
    implements $ProductionRoundItemBranchCopyWith<$Res> {
  factory _$$ProductionRoundItemBranchImplCopyWith(
    _$ProductionRoundItemBranchImpl value,
    $Res Function(_$ProductionRoundItemBranchImpl) then,
  ) = __$$ProductionRoundItemBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _readString) String warehouse,
    @JsonKey(fromJson: _readString) String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(fromJson: _readNum) double par,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(fromJson: _readNum) double fill,
    @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
    double? daysOfCover,
    @JsonKey(name: 'below_backup', fromJson: _readFlag) bool belowBackup,
    @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
    bool stockIsNegative,
  });
}

/// @nodoc
class __$$ProductionRoundItemBranchImplCopyWithImpl<$Res>
    extends
        _$ProductionRoundItemBranchCopyWithImpl<
          $Res,
          _$ProductionRoundItemBranchImpl
        >
    implements _$$ProductionRoundItemBranchImplCopyWith<$Res> {
  __$$ProductionRoundItemBranchImplCopyWithImpl(
    _$ProductionRoundItemBranchImpl _value,
    $Res Function(_$ProductionRoundItemBranchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundItemBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouse = null,
    Object? label = null,
    Object? weeklySales = null,
    Object? par = null,
    Object? onHand = null,
    Object? fill = null,
    Object? daysOfCover = freezed,
    Object? belowBackup = null,
    Object? stockIsNegative = null,
  }) {
    return _then(
      _$ProductionRoundItemBranchImpl(
        warehouse: null == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        weeklySales: null == weeklySales
            ? _value.weeklySales
            : weeklySales // ignore: cast_nullable_to_non_nullable
                  as double,
        par: null == par
            ? _value.par
            : par // ignore: cast_nullable_to_non_nullable
                  as double,
        onHand: null == onHand
            ? _value.onHand
            : onHand // ignore: cast_nullable_to_non_nullable
                  as double,
        fill: null == fill
            ? _value.fill
            : fill // ignore: cast_nullable_to_non_nullable
                  as double,
        daysOfCover: freezed == daysOfCover
            ? _value.daysOfCover
            : daysOfCover // ignore: cast_nullable_to_non_nullable
                  as double?,
        belowBackup: null == belowBackup
            ? _value.belowBackup
            : belowBackup // ignore: cast_nullable_to_non_nullable
                  as bool,
        stockIsNegative: null == stockIsNegative
            ? _value.stockIsNegative
            : stockIsNegative // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundItemBranchImpl extends _ProductionRoundItemBranch {
  const _$ProductionRoundItemBranchImpl({
    @JsonKey(fromJson: _readString) this.warehouse = '',
    @JsonKey(fromJson: _readString) this.label = '',
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) this.weeklySales = 0.0,
    @JsonKey(fromJson: _readNum) this.par = 0.0,
    @JsonKey(name: 'on_hand', fromJson: _readNum) this.onHand = 0.0,
    @JsonKey(fromJson: _readNum) this.fill = 0.0,
    @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull) this.daysOfCover,
    @JsonKey(name: 'below_backup', fromJson: _readFlag)
    this.belowBackup = false,
    @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
    this.stockIsNegative = false,
  }) : super._();

  factory _$ProductionRoundItemBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundItemBranchImplFromJson(json);

  @override
  @JsonKey(fromJson: _readString)
  final String warehouse;
  @override
  @JsonKey(fromJson: _readString)
  final String label;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  final double weeklySales;

  /// The branch's target holding: its weekly rate over the full cover.
  @override
  @JsonKey(fromJson: _readNum)
  final double par;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  final double onHand;
  @override
  @JsonKey(fromJson: _readNum)
  final double fill;

  /// Null when the branch never sold the item — distinct from zero, which
  /// means "sells, and has run out".
  @override
  @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
  final double? daysOfCover;
  @override
  @JsonKey(name: 'below_backup', fromJson: _readFlag)
  final bool belowBackup;
  @override
  @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
  final bool stockIsNegative;

  @override
  String toString() {
    return 'ProductionRoundItemBranch(warehouse: $warehouse, label: $label, weeklySales: $weeklySales, par: $par, onHand: $onHand, fill: $fill, daysOfCover: $daysOfCover, belowBackup: $belowBackup, stockIsNegative: $stockIsNegative)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundItemBranchImpl &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.weeklySales, weeklySales) ||
                other.weeklySales == weeklySales) &&
            (identical(other.par, par) || other.par == par) &&
            (identical(other.onHand, onHand) || other.onHand == onHand) &&
            (identical(other.fill, fill) || other.fill == fill) &&
            (identical(other.daysOfCover, daysOfCover) ||
                other.daysOfCover == daysOfCover) &&
            (identical(other.belowBackup, belowBackup) ||
                other.belowBackup == belowBackup) &&
            (identical(other.stockIsNegative, stockIsNegative) ||
                other.stockIsNegative == stockIsNegative));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    warehouse,
    label,
    weeklySales,
    par,
    onHand,
    fill,
    daysOfCover,
    belowBackup,
    stockIsNegative,
  );

  /// Create a copy of ProductionRoundItemBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundItemBranchImplCopyWith<_$ProductionRoundItemBranchImpl>
  get copyWith =>
      __$$ProductionRoundItemBranchImplCopyWithImpl<
        _$ProductionRoundItemBranchImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundItemBranchImplToJson(this);
  }
}

abstract class _ProductionRoundItemBranch extends ProductionRoundItemBranch {
  const factory _ProductionRoundItemBranch({
    @JsonKey(fromJson: _readString) final String warehouse,
    @JsonKey(fromJson: _readString) final String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) final double weeklySales,
    @JsonKey(fromJson: _readNum) final double par,
    @JsonKey(name: 'on_hand', fromJson: _readNum) final double onHand,
    @JsonKey(fromJson: _readNum) final double fill,
    @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
    final double? daysOfCover,
    @JsonKey(name: 'below_backup', fromJson: _readFlag) final bool belowBackup,
    @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
    final bool stockIsNegative,
  }) = _$ProductionRoundItemBranchImpl;
  const _ProductionRoundItemBranch._() : super._();

  factory _ProductionRoundItemBranch.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundItemBranchImpl.fromJson;

  @override
  @JsonKey(fromJson: _readString)
  String get warehouse;
  @override
  @JsonKey(fromJson: _readString)
  String get label;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales;

  /// The branch's target holding: its weekly rate over the full cover.
  @override
  @JsonKey(fromJson: _readNum)
  double get par;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand;
  @override
  @JsonKey(fromJson: _readNum)
  double get fill;

  /// Null when the branch never sold the item — distinct from zero, which
  /// means "sells, and has run out".
  @override
  @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
  double? get daysOfCover;
  @override
  @JsonKey(name: 'below_backup', fromJson: _readFlag)
  bool get belowBackup;
  @override
  @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
  bool get stockIsNegative;

  /// Create a copy of ProductionRoundItemBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundItemBranchImplCopyWith<_$ProductionRoundItemBranchImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionRoundItem _$ProductionRoundItemFromJson(Map<String, dynamic> json) {
  return _ProductionRoundItem.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundItem {
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get flavour => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_size', fromJson: _readNum)
  double get batchSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales => throw _privateConstructorUsedError;
  @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
  double get factoryOnHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_fill', fromJson: _readNum)
  double get totalFill => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_need', fromJson: _readNum)
  double get netNeed => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get batches => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get jars => throw _privateConstructorUsedError;
  @JsonKey(name: 'status', fromJson: _readString)
  String get rawStatus => throw _privateConstructorUsedError;

  /// Missing material item codes this jar consumes.
  @JsonKey(name: 'blocked_by', fromJson: _readStringList)
  List<String> get blockedBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readItemBranches)
  List<ProductionRoundItemBranch> get branches =>
      throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundItemCopyWith<ProductionRoundItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundItemCopyWith<$Res> {
  factory $ProductionRoundItemCopyWith(
    ProductionRoundItem value,
    $Res Function(ProductionRoundItem) then,
  ) = _$ProductionRoundItemCopyWithImpl<$Res, ProductionRoundItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(fromJson: _readString) String flavour,
    @JsonKey(fromJson: _readString) String size,
    @JsonKey(name: 'batch_size', fromJson: _readNum) double batchSize,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(name: 'factory_on_hand', fromJson: _readNum) double factoryOnHand,
    @JsonKey(name: 'total_fill', fromJson: _readNum) double totalFill,
    @JsonKey(name: 'net_need', fromJson: _readNum) double netNeed,
    @JsonKey(fromJson: _readNum) double batches,
    @JsonKey(fromJson: _readNum) double jars,
    @JsonKey(name: 'status', fromJson: _readString) String rawStatus,
    @JsonKey(name: 'blocked_by', fromJson: _readStringList)
    List<String> blockedBy,
    @JsonKey(fromJson: _readItemBranches)
    List<ProductionRoundItemBranch> branches,
  });
}

/// @nodoc
class _$ProductionRoundItemCopyWithImpl<$Res, $Val extends ProductionRoundItem>
    implements $ProductionRoundItemCopyWith<$Res> {
  _$ProductionRoundItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? flavour = null,
    Object? size = null,
    Object? batchSize = null,
    Object? weeklySales = null,
    Object? factoryOnHand = null,
    Object? totalFill = null,
    Object? netNeed = null,
    Object? batches = null,
    Object? jars = null,
    Object? rawStatus = null,
    Object? blockedBy = null,
    Object? branches = null,
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
            flavour: null == flavour
                ? _value.flavour
                : flavour // ignore: cast_nullable_to_non_nullable
                      as String,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String,
            batchSize: null == batchSize
                ? _value.batchSize
                : batchSize // ignore: cast_nullable_to_non_nullable
                      as double,
            weeklySales: null == weeklySales
                ? _value.weeklySales
                : weeklySales // ignore: cast_nullable_to_non_nullable
                      as double,
            factoryOnHand: null == factoryOnHand
                ? _value.factoryOnHand
                : factoryOnHand // ignore: cast_nullable_to_non_nullable
                      as double,
            totalFill: null == totalFill
                ? _value.totalFill
                : totalFill // ignore: cast_nullable_to_non_nullable
                      as double,
            netNeed: null == netNeed
                ? _value.netNeed
                : netNeed // ignore: cast_nullable_to_non_nullable
                      as double,
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
                      as double,
            jars: null == jars
                ? _value.jars
                : jars // ignore: cast_nullable_to_non_nullable
                      as double,
            rawStatus: null == rawStatus
                ? _value.rawStatus
                : rawStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            blockedBy: null == blockedBy
                ? _value.blockedBy
                : blockedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            branches: null == branches
                ? _value.branches
                : branches // ignore: cast_nullable_to_non_nullable
                      as List<ProductionRoundItemBranch>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundItemImplCopyWith<$Res>
    implements $ProductionRoundItemCopyWith<$Res> {
  factory _$$ProductionRoundItemImplCopyWith(
    _$ProductionRoundItemImpl value,
    $Res Function(_$ProductionRoundItemImpl) then,
  ) = __$$ProductionRoundItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(fromJson: _readString) String flavour,
    @JsonKey(fromJson: _readString) String size,
    @JsonKey(name: 'batch_size', fromJson: _readNum) double batchSize,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(name: 'factory_on_hand', fromJson: _readNum) double factoryOnHand,
    @JsonKey(name: 'total_fill', fromJson: _readNum) double totalFill,
    @JsonKey(name: 'net_need', fromJson: _readNum) double netNeed,
    @JsonKey(fromJson: _readNum) double batches,
    @JsonKey(fromJson: _readNum) double jars,
    @JsonKey(name: 'status', fromJson: _readString) String rawStatus,
    @JsonKey(name: 'blocked_by', fromJson: _readStringList)
    List<String> blockedBy,
    @JsonKey(fromJson: _readItemBranches)
    List<ProductionRoundItemBranch> branches,
  });
}

/// @nodoc
class __$$ProductionRoundItemImplCopyWithImpl<$Res>
    extends _$ProductionRoundItemCopyWithImpl<$Res, _$ProductionRoundItemImpl>
    implements _$$ProductionRoundItemImplCopyWith<$Res> {
  __$$ProductionRoundItemImplCopyWithImpl(
    _$ProductionRoundItemImpl _value,
    $Res Function(_$ProductionRoundItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? flavour = null,
    Object? size = null,
    Object? batchSize = null,
    Object? weeklySales = null,
    Object? factoryOnHand = null,
    Object? totalFill = null,
    Object? netNeed = null,
    Object? batches = null,
    Object? jars = null,
    Object? rawStatus = null,
    Object? blockedBy = null,
    Object? branches = null,
  }) {
    return _then(
      _$ProductionRoundItemImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        flavour: null == flavour
            ? _value.flavour
            : flavour // ignore: cast_nullable_to_non_nullable
                  as String,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String,
        batchSize: null == batchSize
            ? _value.batchSize
            : batchSize // ignore: cast_nullable_to_non_nullable
                  as double,
        weeklySales: null == weeklySales
            ? _value.weeklySales
            : weeklySales // ignore: cast_nullable_to_non_nullable
                  as double,
        factoryOnHand: null == factoryOnHand
            ? _value.factoryOnHand
            : factoryOnHand // ignore: cast_nullable_to_non_nullable
                  as double,
        totalFill: null == totalFill
            ? _value.totalFill
            : totalFill // ignore: cast_nullable_to_non_nullable
                  as double,
        netNeed: null == netNeed
            ? _value.netNeed
            : netNeed // ignore: cast_nullable_to_non_nullable
                  as double,
        batches: null == batches
            ? _value.batches
            : batches // ignore: cast_nullable_to_non_nullable
                  as double,
        jars: null == jars
            ? _value.jars
            : jars // ignore: cast_nullable_to_non_nullable
                  as double,
        rawStatus: null == rawStatus
            ? _value.rawStatus
            : rawStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        blockedBy: null == blockedBy
            ? _value._blockedBy
            : blockedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<ProductionRoundItemBranch>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundItemImpl extends _ProductionRoundItem {
  const _$ProductionRoundItemImpl({
    @JsonKey(name: 'item_code', fromJson: _readString) this.itemCode = '',
    @JsonKey(name: 'item_name', fromJson: _readString) this.itemName = '',
    @JsonKey(fromJson: _readString) this.flavour = '',
    @JsonKey(fromJson: _readString) this.size = '',
    @JsonKey(name: 'batch_size', fromJson: _readNum) this.batchSize = 0.0,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) this.weeklySales = 0.0,
    @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
    this.factoryOnHand = 0.0,
    @JsonKey(name: 'total_fill', fromJson: _readNum) this.totalFill = 0.0,
    @JsonKey(name: 'net_need', fromJson: _readNum) this.netNeed = 0.0,
    @JsonKey(fromJson: _readNum) this.batches = 0.0,
    @JsonKey(fromJson: _readNum) this.jars = 0.0,
    @JsonKey(name: 'status', fromJson: _readString) this.rawStatus = 'covered',
    @JsonKey(name: 'blocked_by', fromJson: _readStringList)
    final List<String> blockedBy = const <String>[],
    @JsonKey(fromJson: _readItemBranches)
    final List<ProductionRoundItemBranch> branches =
        const <ProductionRoundItemBranch>[],
  }) : _blockedBy = blockedBy,
       _branches = branches,
       super._();

  factory _$ProductionRoundItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundItemImplFromJson(json);

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  final String itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  final String itemName;
  @override
  @JsonKey(fromJson: _readString)
  final String flavour;
  @override
  @JsonKey(fromJson: _readString)
  final String size;
  @override
  @JsonKey(name: 'batch_size', fromJson: _readNum)
  final double batchSize;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  final double weeklySales;
  @override
  @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
  final double factoryOnHand;
  @override
  @JsonKey(name: 'total_fill', fromJson: _readNum)
  final double totalFill;
  @override
  @JsonKey(name: 'net_need', fromJson: _readNum)
  final double netNeed;
  @override
  @JsonKey(fromJson: _readNum)
  final double batches;
  @override
  @JsonKey(fromJson: _readNum)
  final double jars;
  @override
  @JsonKey(name: 'status', fromJson: _readString)
  final String rawStatus;

  /// Missing material item codes this jar consumes.
  final List<String> _blockedBy;

  /// Missing material item codes this jar consumes.
  @override
  @JsonKey(name: 'blocked_by', fromJson: _readStringList)
  List<String> get blockedBy {
    if (_blockedBy is EqualUnmodifiableListView) return _blockedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedBy);
  }

  final List<ProductionRoundItemBranch> _branches;
  @override
  @JsonKey(fromJson: _readItemBranches)
  List<ProductionRoundItemBranch> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  @override
  String toString() {
    return 'ProductionRoundItem(itemCode: $itemCode, itemName: $itemName, flavour: $flavour, size: $size, batchSize: $batchSize, weeklySales: $weeklySales, factoryOnHand: $factoryOnHand, totalFill: $totalFill, netNeed: $netNeed, batches: $batches, jars: $jars, rawStatus: $rawStatus, blockedBy: $blockedBy, branches: $branches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundItemImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.flavour, flavour) || other.flavour == flavour) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.weeklySales, weeklySales) ||
                other.weeklySales == weeklySales) &&
            (identical(other.factoryOnHand, factoryOnHand) ||
                other.factoryOnHand == factoryOnHand) &&
            (identical(other.totalFill, totalFill) ||
                other.totalFill == totalFill) &&
            (identical(other.netNeed, netNeed) || other.netNeed == netNeed) &&
            (identical(other.batches, batches) || other.batches == batches) &&
            (identical(other.jars, jars) || other.jars == jars) &&
            (identical(other.rawStatus, rawStatus) ||
                other.rawStatus == rawStatus) &&
            const DeepCollectionEquality().equals(
              other._blockedBy,
              _blockedBy,
            ) &&
            const DeepCollectionEquality().equals(other._branches, _branches));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    flavour,
    size,
    batchSize,
    weeklySales,
    factoryOnHand,
    totalFill,
    netNeed,
    batches,
    jars,
    rawStatus,
    const DeepCollectionEquality().hash(_blockedBy),
    const DeepCollectionEquality().hash(_branches),
  );

  /// Create a copy of ProductionRoundItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundItemImplCopyWith<_$ProductionRoundItemImpl> get copyWith =>
      __$$ProductionRoundItemImplCopyWithImpl<_$ProductionRoundItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundItemImplToJson(this);
  }
}

abstract class _ProductionRoundItem extends ProductionRoundItem {
  const factory _ProductionRoundItem({
    @JsonKey(name: 'item_code', fromJson: _readString) final String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) final String itemName,
    @JsonKey(fromJson: _readString) final String flavour,
    @JsonKey(fromJson: _readString) final String size,
    @JsonKey(name: 'batch_size', fromJson: _readNum) final double batchSize,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) final double weeklySales,
    @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
    final double factoryOnHand,
    @JsonKey(name: 'total_fill', fromJson: _readNum) final double totalFill,
    @JsonKey(name: 'net_need', fromJson: _readNum) final double netNeed,
    @JsonKey(fromJson: _readNum) final double batches,
    @JsonKey(fromJson: _readNum) final double jars,
    @JsonKey(name: 'status', fromJson: _readString) final String rawStatus,
    @JsonKey(name: 'blocked_by', fromJson: _readStringList)
    final List<String> blockedBy,
    @JsonKey(fromJson: _readItemBranches)
    final List<ProductionRoundItemBranch> branches,
  }) = _$ProductionRoundItemImpl;
  const _ProductionRoundItem._() : super._();

  factory _ProductionRoundItem.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundItemImpl.fromJson;

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName;
  @override
  @JsonKey(fromJson: _readString)
  String get flavour;
  @override
  @JsonKey(fromJson: _readString)
  String get size;
  @override
  @JsonKey(name: 'batch_size', fromJson: _readNum)
  double get batchSize;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales;
  @override
  @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
  double get factoryOnHand;
  @override
  @JsonKey(name: 'total_fill', fromJson: _readNum)
  double get totalFill;
  @override
  @JsonKey(name: 'net_need', fromJson: _readNum)
  double get netNeed;
  @override
  @JsonKey(fromJson: _readNum)
  double get batches;
  @override
  @JsonKey(fromJson: _readNum)
  double get jars;
  @override
  @JsonKey(name: 'status', fromJson: _readString)
  String get rawStatus;

  /// Missing material item codes this jar consumes.
  @override
  @JsonKey(name: 'blocked_by', fromJson: _readStringList)
  List<String> get blockedBy;
  @override
  @JsonKey(fromJson: _readItemBranches)
  List<ProductionRoundItemBranch> get branches;

  /// Create a copy of ProductionRoundItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundItemImplCopyWith<_$ProductionRoundItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductionRoundPrep _$ProductionRoundPrepFromJson(Map<String, dynamic> json) {
  return _ProductionRoundPrep.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundPrep {
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get uom => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get required => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_make', fromJson: _readNum)
  double get toMake => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_yield', fromJson: _readNum)
  double get batchYield => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get batches => throw _privateConstructorUsedError;

  /// A phantom mix: never stored, made fresh inside the jar batch.
  @JsonKey(name: 'made_fresh', fromJson: _readFlag)
  bool get madeFresh => throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundPrep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundPrep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundPrepCopyWith<ProductionRoundPrep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundPrepCopyWith<$Res> {
  factory $ProductionRoundPrepCopyWith(
    ProductionRoundPrep value,
    $Res Function(ProductionRoundPrep) then,
  ) = _$ProductionRoundPrepCopyWithImpl<$Res, ProductionRoundPrep>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(fromJson: _readString) String uom,
    @JsonKey(fromJson: _readNum) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(name: 'to_make', fromJson: _readNum) double toMake,
    @JsonKey(name: 'batch_yield', fromJson: _readNum) double batchYield,
    @JsonKey(fromJson: _readNum) double batches,
    @JsonKey(name: 'made_fresh', fromJson: _readFlag) bool madeFresh,
  });
}

/// @nodoc
class _$ProductionRoundPrepCopyWithImpl<$Res, $Val extends ProductionRoundPrep>
    implements $ProductionRoundPrepCopyWith<$Res> {
  _$ProductionRoundPrepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundPrep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? required = null,
    Object? onHand = null,
    Object? toMake = null,
    Object? batchYield = null,
    Object? batches = null,
    Object? madeFresh = null,
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
            required: null == required
                ? _value.required
                : required // ignore: cast_nullable_to_non_nullable
                      as double,
            onHand: null == onHand
                ? _value.onHand
                : onHand // ignore: cast_nullable_to_non_nullable
                      as double,
            toMake: null == toMake
                ? _value.toMake
                : toMake // ignore: cast_nullable_to_non_nullable
                      as double,
            batchYield: null == batchYield
                ? _value.batchYield
                : batchYield // ignore: cast_nullable_to_non_nullable
                      as double,
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
                      as double,
            madeFresh: null == madeFresh
                ? _value.madeFresh
                : madeFresh // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundPrepImplCopyWith<$Res>
    implements $ProductionRoundPrepCopyWith<$Res> {
  factory _$$ProductionRoundPrepImplCopyWith(
    _$ProductionRoundPrepImpl value,
    $Res Function(_$ProductionRoundPrepImpl) then,
  ) = __$$ProductionRoundPrepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(fromJson: _readString) String uom,
    @JsonKey(fromJson: _readNum) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(name: 'to_make', fromJson: _readNum) double toMake,
    @JsonKey(name: 'batch_yield', fromJson: _readNum) double batchYield,
    @JsonKey(fromJson: _readNum) double batches,
    @JsonKey(name: 'made_fresh', fromJson: _readFlag) bool madeFresh,
  });
}

/// @nodoc
class __$$ProductionRoundPrepImplCopyWithImpl<$Res>
    extends _$ProductionRoundPrepCopyWithImpl<$Res, _$ProductionRoundPrepImpl>
    implements _$$ProductionRoundPrepImplCopyWith<$Res> {
  __$$ProductionRoundPrepImplCopyWithImpl(
    _$ProductionRoundPrepImpl _value,
    $Res Function(_$ProductionRoundPrepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundPrep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? required = null,
    Object? onHand = null,
    Object? toMake = null,
    Object? batchYield = null,
    Object? batches = null,
    Object? madeFresh = null,
  }) {
    return _then(
      _$ProductionRoundPrepImpl(
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
        required: null == required
            ? _value.required
            : required // ignore: cast_nullable_to_non_nullable
                  as double,
        onHand: null == onHand
            ? _value.onHand
            : onHand // ignore: cast_nullable_to_non_nullable
                  as double,
        toMake: null == toMake
            ? _value.toMake
            : toMake // ignore: cast_nullable_to_non_nullable
                  as double,
        batchYield: null == batchYield
            ? _value.batchYield
            : batchYield // ignore: cast_nullable_to_non_nullable
                  as double,
        batches: null == batches
            ? _value.batches
            : batches // ignore: cast_nullable_to_non_nullable
                  as double,
        madeFresh: null == madeFresh
            ? _value.madeFresh
            : madeFresh // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundPrepImpl extends _ProductionRoundPrep {
  const _$ProductionRoundPrepImpl({
    @JsonKey(name: 'item_code', fromJson: _readString) this.itemCode = '',
    @JsonKey(name: 'item_name', fromJson: _readString) this.itemName = '',
    @JsonKey(fromJson: _readString) this.uom = '',
    @JsonKey(fromJson: _readNum) this.required = 0.0,
    @JsonKey(name: 'on_hand', fromJson: _readNum) this.onHand = 0.0,
    @JsonKey(name: 'to_make', fromJson: _readNum) this.toMake = 0.0,
    @JsonKey(name: 'batch_yield', fromJson: _readNum) this.batchYield = 0.0,
    @JsonKey(fromJson: _readNum) this.batches = 0.0,
    @JsonKey(name: 'made_fresh', fromJson: _readFlag) this.madeFresh = false,
  }) : super._();

  factory _$ProductionRoundPrepImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundPrepImplFromJson(json);

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  final String itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  final String itemName;
  @override
  @JsonKey(fromJson: _readString)
  final String uom;
  @override
  @JsonKey(fromJson: _readNum)
  final double required;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  final double onHand;
  @override
  @JsonKey(name: 'to_make', fromJson: _readNum)
  final double toMake;
  @override
  @JsonKey(name: 'batch_yield', fromJson: _readNum)
  final double batchYield;
  @override
  @JsonKey(fromJson: _readNum)
  final double batches;

  /// A phantom mix: never stored, made fresh inside the jar batch.
  @override
  @JsonKey(name: 'made_fresh', fromJson: _readFlag)
  final bool madeFresh;

  @override
  String toString() {
    return 'ProductionRoundPrep(itemCode: $itemCode, itemName: $itemName, uom: $uom, required: $required, onHand: $onHand, toMake: $toMake, batchYield: $batchYield, batches: $batches, madeFresh: $madeFresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundPrepImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.onHand, onHand) || other.onHand == onHand) &&
            (identical(other.toMake, toMake) || other.toMake == toMake) &&
            (identical(other.batchYield, batchYield) ||
                other.batchYield == batchYield) &&
            (identical(other.batches, batches) || other.batches == batches) &&
            (identical(other.madeFresh, madeFresh) ||
                other.madeFresh == madeFresh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    uom,
    required,
    onHand,
    toMake,
    batchYield,
    batches,
    madeFresh,
  );

  /// Create a copy of ProductionRoundPrep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundPrepImplCopyWith<_$ProductionRoundPrepImpl> get copyWith =>
      __$$ProductionRoundPrepImplCopyWithImpl<_$ProductionRoundPrepImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundPrepImplToJson(this);
  }
}

abstract class _ProductionRoundPrep extends ProductionRoundPrep {
  const factory _ProductionRoundPrep({
    @JsonKey(name: 'item_code', fromJson: _readString) final String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) final String itemName,
    @JsonKey(fromJson: _readString) final String uom,
    @JsonKey(fromJson: _readNum) final double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) final double onHand,
    @JsonKey(name: 'to_make', fromJson: _readNum) final double toMake,
    @JsonKey(name: 'batch_yield', fromJson: _readNum) final double batchYield,
    @JsonKey(fromJson: _readNum) final double batches,
    @JsonKey(name: 'made_fresh', fromJson: _readFlag) final bool madeFresh,
  }) = _$ProductionRoundPrepImpl;
  const _ProductionRoundPrep._() : super._();

  factory _ProductionRoundPrep.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundPrepImpl.fromJson;

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName;
  @override
  @JsonKey(fromJson: _readString)
  String get uom;
  @override
  @JsonKey(fromJson: _readNum)
  double get required;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand;
  @override
  @JsonKey(name: 'to_make', fromJson: _readNum)
  double get toMake;
  @override
  @JsonKey(name: 'batch_yield', fromJson: _readNum)
  double get batchYield;
  @override
  @JsonKey(fromJson: _readNum)
  double get batches;

  /// A phantom mix: never stored, made fresh inside the jar batch.
  @override
  @JsonKey(name: 'made_fresh', fromJson: _readFlag)
  bool get madeFresh;

  /// Create a copy of ProductionRoundPrep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundPrepImplCopyWith<_$ProductionRoundPrepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductionRoundMaterial _$ProductionRoundMaterialFromJson(
  Map<String, dynamic> json,
) {
  return _ProductionRoundMaterial.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundMaterial {
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group', fromJson: _readString)
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get uom => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get required => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
  double get alternativeOnHand => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNum)
  double get missing => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_by', fromJson: _readStringList)
  List<String> get usedBy => throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundMaterial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundMaterial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundMaterialCopyWith<ProductionRoundMaterial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundMaterialCopyWith<$Res> {
  factory $ProductionRoundMaterialCopyWith(
    ProductionRoundMaterial value,
    $Res Function(ProductionRoundMaterial) then,
  ) = _$ProductionRoundMaterialCopyWithImpl<$Res, ProductionRoundMaterial>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(name: 'item_group', fromJson: _readString) String itemGroup,
    @JsonKey(fromJson: _readString) String uom,
    @JsonKey(fromJson: _readNum) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
    double alternativeOnHand,
    @JsonKey(fromJson: _readNum) double missing,
    @JsonKey(name: 'used_by', fromJson: _readStringList) List<String> usedBy,
  });
}

/// @nodoc
class _$ProductionRoundMaterialCopyWithImpl<
  $Res,
  $Val extends ProductionRoundMaterial
>
    implements $ProductionRoundMaterialCopyWith<$Res> {
  _$ProductionRoundMaterialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundMaterial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? uom = null,
    Object? required = null,
    Object? onHand = null,
    Object? alternativeOnHand = null,
    Object? missing = null,
    Object? usedBy = null,
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
            uom: null == uom
                ? _value.uom
                : uom // ignore: cast_nullable_to_non_nullable
                      as String,
            required: null == required
                ? _value.required
                : required // ignore: cast_nullable_to_non_nullable
                      as double,
            onHand: null == onHand
                ? _value.onHand
                : onHand // ignore: cast_nullable_to_non_nullable
                      as double,
            alternativeOnHand: null == alternativeOnHand
                ? _value.alternativeOnHand
                : alternativeOnHand // ignore: cast_nullable_to_non_nullable
                      as double,
            missing: null == missing
                ? _value.missing
                : missing // ignore: cast_nullable_to_non_nullable
                      as double,
            usedBy: null == usedBy
                ? _value.usedBy
                : usedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundMaterialImplCopyWith<$Res>
    implements $ProductionRoundMaterialCopyWith<$Res> {
  factory _$$ProductionRoundMaterialImplCopyWith(
    _$ProductionRoundMaterialImpl value,
    $Res Function(_$ProductionRoundMaterialImpl) then,
  ) = __$$ProductionRoundMaterialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code', fromJson: _readString) String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) String itemName,
    @JsonKey(name: 'item_group', fromJson: _readString) String itemGroup,
    @JsonKey(fromJson: _readString) String uom,
    @JsonKey(fromJson: _readNum) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) double onHand,
    @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
    double alternativeOnHand,
    @JsonKey(fromJson: _readNum) double missing,
    @JsonKey(name: 'used_by', fromJson: _readStringList) List<String> usedBy,
  });
}

/// @nodoc
class __$$ProductionRoundMaterialImplCopyWithImpl<$Res>
    extends
        _$ProductionRoundMaterialCopyWithImpl<
          $Res,
          _$ProductionRoundMaterialImpl
        >
    implements _$$ProductionRoundMaterialImplCopyWith<$Res> {
  __$$ProductionRoundMaterialImplCopyWithImpl(
    _$ProductionRoundMaterialImpl _value,
    $Res Function(_$ProductionRoundMaterialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundMaterial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? uom = null,
    Object? required = null,
    Object? onHand = null,
    Object? alternativeOnHand = null,
    Object? missing = null,
    Object? usedBy = null,
  }) {
    return _then(
      _$ProductionRoundMaterialImpl(
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
        uom: null == uom
            ? _value.uom
            : uom // ignore: cast_nullable_to_non_nullable
                  as String,
        required: null == required
            ? _value.required
            : required // ignore: cast_nullable_to_non_nullable
                  as double,
        onHand: null == onHand
            ? _value.onHand
            : onHand // ignore: cast_nullable_to_non_nullable
                  as double,
        alternativeOnHand: null == alternativeOnHand
            ? _value.alternativeOnHand
            : alternativeOnHand // ignore: cast_nullable_to_non_nullable
                  as double,
        missing: null == missing
            ? _value.missing
            : missing // ignore: cast_nullable_to_non_nullable
                  as double,
        usedBy: null == usedBy
            ? _value._usedBy
            : usedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundMaterialImpl extends _ProductionRoundMaterial {
  const _$ProductionRoundMaterialImpl({
    @JsonKey(name: 'item_code', fromJson: _readString) this.itemCode = '',
    @JsonKey(name: 'item_name', fromJson: _readString) this.itemName = '',
    @JsonKey(name: 'item_group', fromJson: _readString) this.itemGroup = '',
    @JsonKey(fromJson: _readString) this.uom = '',
    @JsonKey(fromJson: _readNum) this.required = 0.0,
    @JsonKey(name: 'on_hand', fromJson: _readNum) this.onHand = 0.0,
    @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
    this.alternativeOnHand = 0.0,
    @JsonKey(fromJson: _readNum) this.missing = 0.0,
    @JsonKey(name: 'used_by', fromJson: _readStringList)
    final List<String> usedBy = const <String>[],
  }) : _usedBy = usedBy,
       super._();

  factory _$ProductionRoundMaterialImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundMaterialImplFromJson(json);

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  final String itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  final String itemName;
  @override
  @JsonKey(name: 'item_group', fromJson: _readString)
  final String itemGroup;
  @override
  @JsonKey(fromJson: _readString)
  final String uom;
  @override
  @JsonKey(fromJson: _readNum)
  final double required;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  final double onHand;
  @override
  @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
  final double alternativeOnHand;
  @override
  @JsonKey(fromJson: _readNum)
  final double missing;
  final List<String> _usedBy;
  @override
  @JsonKey(name: 'used_by', fromJson: _readStringList)
  List<String> get usedBy {
    if (_usedBy is EqualUnmodifiableListView) return _usedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usedBy);
  }

  @override
  String toString() {
    return 'ProductionRoundMaterial(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, uom: $uom, required: $required, onHand: $onHand, alternativeOnHand: $alternativeOnHand, missing: $missing, usedBy: $usedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundMaterialImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.onHand, onHand) || other.onHand == onHand) &&
            (identical(other.alternativeOnHand, alternativeOnHand) ||
                other.alternativeOnHand == alternativeOnHand) &&
            (identical(other.missing, missing) || other.missing == missing) &&
            const DeepCollectionEquality().equals(other._usedBy, _usedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    itemGroup,
    uom,
    required,
    onHand,
    alternativeOnHand,
    missing,
    const DeepCollectionEquality().hash(_usedBy),
  );

  /// Create a copy of ProductionRoundMaterial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundMaterialImplCopyWith<_$ProductionRoundMaterialImpl>
  get copyWith =>
      __$$ProductionRoundMaterialImplCopyWithImpl<
        _$ProductionRoundMaterialImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundMaterialImplToJson(this);
  }
}

abstract class _ProductionRoundMaterial extends ProductionRoundMaterial {
  const factory _ProductionRoundMaterial({
    @JsonKey(name: 'item_code', fromJson: _readString) final String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString) final String itemName,
    @JsonKey(name: 'item_group', fromJson: _readString) final String itemGroup,
    @JsonKey(fromJson: _readString) final String uom,
    @JsonKey(fromJson: _readNum) final double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) final double onHand,
    @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
    final double alternativeOnHand,
    @JsonKey(fromJson: _readNum) final double missing,
    @JsonKey(name: 'used_by', fromJson: _readStringList)
    final List<String> usedBy,
  }) = _$ProductionRoundMaterialImpl;
  const _ProductionRoundMaterial._() : super._();

  factory _ProductionRoundMaterial.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundMaterialImpl.fromJson;

  @override
  @JsonKey(name: 'item_code', fromJson: _readString)
  String get itemCode;
  @override
  @JsonKey(name: 'item_name', fromJson: _readString)
  String get itemName;
  @override
  @JsonKey(name: 'item_group', fromJson: _readString)
  String get itemGroup;
  @override
  @JsonKey(fromJson: _readString)
  String get uom;
  @override
  @JsonKey(fromJson: _readNum)
  double get required;
  @override
  @JsonKey(name: 'on_hand', fromJson: _readNum)
  double get onHand;
  @override
  @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
  double get alternativeOnHand;
  @override
  @JsonKey(fromJson: _readNum)
  double get missing;
  @override
  @JsonKey(name: 'used_by', fromJson: _readStringList)
  List<String> get usedBy;

  /// Create a copy of ProductionRoundMaterial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundMaterialImplCopyWith<_$ProductionRoundMaterialImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionRoundBranch _$ProductionRoundBranchFromJson(
  Map<String, dynamic> json,
) {
  return _ProductionRoundBranch.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundBranch {
  @JsonKey(fromJson: _readString)
  String get warehouse => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales => throw _privateConstructorUsedError;
  @JsonKey(name: 'par_total', fromJson: _readNum)
  double get parTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_hand_total', fromJson: _readNum)
  double get onHandTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'fill_total', fromJson: _readNum)
  double get fillTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'below_backup_count', fromJson: _readInt)
  int get belowBackupCount => throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundBranch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundBranchCopyWith<ProductionRoundBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundBranchCopyWith<$Res> {
  factory $ProductionRoundBranchCopyWith(
    ProductionRoundBranch value,
    $Res Function(ProductionRoundBranch) then,
  ) = _$ProductionRoundBranchCopyWithImpl<$Res, ProductionRoundBranch>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _readString) String warehouse,
    @JsonKey(fromJson: _readString) String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(name: 'par_total', fromJson: _readNum) double parTotal,
    @JsonKey(name: 'on_hand_total', fromJson: _readNum) double onHandTotal,
    @JsonKey(name: 'fill_total', fromJson: _readNum) double fillTotal,
    @JsonKey(name: 'below_backup_count', fromJson: _readInt)
    int belowBackupCount,
  });
}

/// @nodoc
class _$ProductionRoundBranchCopyWithImpl<
  $Res,
  $Val extends ProductionRoundBranch
>
    implements $ProductionRoundBranchCopyWith<$Res> {
  _$ProductionRoundBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouse = null,
    Object? label = null,
    Object? weeklySales = null,
    Object? parTotal = null,
    Object? onHandTotal = null,
    Object? fillTotal = null,
    Object? belowBackupCount = null,
  }) {
    return _then(
      _value.copyWith(
            warehouse: null == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            weeklySales: null == weeklySales
                ? _value.weeklySales
                : weeklySales // ignore: cast_nullable_to_non_nullable
                      as double,
            parTotal: null == parTotal
                ? _value.parTotal
                : parTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            onHandTotal: null == onHandTotal
                ? _value.onHandTotal
                : onHandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            fillTotal: null == fillTotal
                ? _value.fillTotal
                : fillTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            belowBackupCount: null == belowBackupCount
                ? _value.belowBackupCount
                : belowBackupCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundBranchImplCopyWith<$Res>
    implements $ProductionRoundBranchCopyWith<$Res> {
  factory _$$ProductionRoundBranchImplCopyWith(
    _$ProductionRoundBranchImpl value,
    $Res Function(_$ProductionRoundBranchImpl) then,
  ) = __$$ProductionRoundBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _readString) String warehouse,
    @JsonKey(fromJson: _readString) String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) double weeklySales,
    @JsonKey(name: 'par_total', fromJson: _readNum) double parTotal,
    @JsonKey(name: 'on_hand_total', fromJson: _readNum) double onHandTotal,
    @JsonKey(name: 'fill_total', fromJson: _readNum) double fillTotal,
    @JsonKey(name: 'below_backup_count', fromJson: _readInt)
    int belowBackupCount,
  });
}

/// @nodoc
class __$$ProductionRoundBranchImplCopyWithImpl<$Res>
    extends
        _$ProductionRoundBranchCopyWithImpl<$Res, _$ProductionRoundBranchImpl>
    implements _$$ProductionRoundBranchImplCopyWith<$Res> {
  __$$ProductionRoundBranchImplCopyWithImpl(
    _$ProductionRoundBranchImpl _value,
    $Res Function(_$ProductionRoundBranchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouse = null,
    Object? label = null,
    Object? weeklySales = null,
    Object? parTotal = null,
    Object? onHandTotal = null,
    Object? fillTotal = null,
    Object? belowBackupCount = null,
  }) {
    return _then(
      _$ProductionRoundBranchImpl(
        warehouse: null == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        weeklySales: null == weeklySales
            ? _value.weeklySales
            : weeklySales // ignore: cast_nullable_to_non_nullable
                  as double,
        parTotal: null == parTotal
            ? _value.parTotal
            : parTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        onHandTotal: null == onHandTotal
            ? _value.onHandTotal
            : onHandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        fillTotal: null == fillTotal
            ? _value.fillTotal
            : fillTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        belowBackupCount: null == belowBackupCount
            ? _value.belowBackupCount
            : belowBackupCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundBranchImpl extends _ProductionRoundBranch {
  const _$ProductionRoundBranchImpl({
    @JsonKey(fromJson: _readString) this.warehouse = '',
    @JsonKey(fromJson: _readString) this.label = '',
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) this.weeklySales = 0.0,
    @JsonKey(name: 'par_total', fromJson: _readNum) this.parTotal = 0.0,
    @JsonKey(name: 'on_hand_total', fromJson: _readNum) this.onHandTotal = 0.0,
    @JsonKey(name: 'fill_total', fromJson: _readNum) this.fillTotal = 0.0,
    @JsonKey(name: 'below_backup_count', fromJson: _readInt)
    this.belowBackupCount = 0,
  }) : super._();

  factory _$ProductionRoundBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundBranchImplFromJson(json);

  @override
  @JsonKey(fromJson: _readString)
  final String warehouse;
  @override
  @JsonKey(fromJson: _readString)
  final String label;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  final double weeklySales;
  @override
  @JsonKey(name: 'par_total', fromJson: _readNum)
  final double parTotal;
  @override
  @JsonKey(name: 'on_hand_total', fromJson: _readNum)
  final double onHandTotal;
  @override
  @JsonKey(name: 'fill_total', fromJson: _readNum)
  final double fillTotal;
  @override
  @JsonKey(name: 'below_backup_count', fromJson: _readInt)
  final int belowBackupCount;

  @override
  String toString() {
    return 'ProductionRoundBranch(warehouse: $warehouse, label: $label, weeklySales: $weeklySales, parTotal: $parTotal, onHandTotal: $onHandTotal, fillTotal: $fillTotal, belowBackupCount: $belowBackupCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundBranchImpl &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.weeklySales, weeklySales) ||
                other.weeklySales == weeklySales) &&
            (identical(other.parTotal, parTotal) ||
                other.parTotal == parTotal) &&
            (identical(other.onHandTotal, onHandTotal) ||
                other.onHandTotal == onHandTotal) &&
            (identical(other.fillTotal, fillTotal) ||
                other.fillTotal == fillTotal) &&
            (identical(other.belowBackupCount, belowBackupCount) ||
                other.belowBackupCount == belowBackupCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    warehouse,
    label,
    weeklySales,
    parTotal,
    onHandTotal,
    fillTotal,
    belowBackupCount,
  );

  /// Create a copy of ProductionRoundBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundBranchImplCopyWith<_$ProductionRoundBranchImpl>
  get copyWith =>
      __$$ProductionRoundBranchImplCopyWithImpl<_$ProductionRoundBranchImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundBranchImplToJson(this);
  }
}

abstract class _ProductionRoundBranch extends ProductionRoundBranch {
  const factory _ProductionRoundBranch({
    @JsonKey(fromJson: _readString) final String warehouse,
    @JsonKey(fromJson: _readString) final String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum) final double weeklySales,
    @JsonKey(name: 'par_total', fromJson: _readNum) final double parTotal,
    @JsonKey(name: 'on_hand_total', fromJson: _readNum)
    final double onHandTotal,
    @JsonKey(name: 'fill_total', fromJson: _readNum) final double fillTotal,
    @JsonKey(name: 'below_backup_count', fromJson: _readInt)
    final int belowBackupCount,
  }) = _$ProductionRoundBranchImpl;
  const _ProductionRoundBranch._() : super._();

  factory _ProductionRoundBranch.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundBranchImpl.fromJson;

  @override
  @JsonKey(fromJson: _readString)
  String get warehouse;
  @override
  @JsonKey(fromJson: _readString)
  String get label;
  @override
  @JsonKey(name: 'weekly_sales', fromJson: _readNum)
  double get weeklySales;
  @override
  @JsonKey(name: 'par_total', fromJson: _readNum)
  double get parTotal;
  @override
  @JsonKey(name: 'on_hand_total', fromJson: _readNum)
  double get onHandTotal;
  @override
  @JsonKey(name: 'fill_total', fromJson: _readNum)
  double get fillTotal;
  @override
  @JsonKey(name: 'below_backup_count', fromJson: _readInt)
  int get belowBackupCount;

  /// Create a copy of ProductionRoundBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundBranchImplCopyWith<_$ProductionRoundBranchImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionRoundSummary _$ProductionRoundSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _ProductionRoundSummary.fromJson(json);
}

/// @nodoc
mixin _$ProductionRoundSummary {
  /// Batches per size group (`Medium`, `Large`), multiples of 0.25.
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get batches => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get jars => throw _privateConstructorUsedError;
  @JsonKey(name: 'jars_total', fromJson: _readNum)
  double get jarsTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'items_to_make', fromJson: _readInt)
  int get itemsToMake => throw _privateConstructorUsedError;
  @JsonKey(name: 'needed_now_count', fromJson: _readInt)
  int get neededNowCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'missing_count', fromJson: _readInt)
  int get missingCount => throw _privateConstructorUsedError;

  /// Jar ITEMS (flavour × size) to make that use a missing material — a
  /// count of rows, not of jars.
  @JsonKey(name: 'blocked_count', fromJson: _readInt)
  int get blockedCount => throw _privateConstructorUsedError;

  /// Serializes this ProductionRoundSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundSummaryCopyWith<ProductionRoundSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundSummaryCopyWith<$Res> {
  factory $ProductionRoundSummaryCopyWith(
    ProductionRoundSummary value,
    $Res Function(ProductionRoundSummary) then,
  ) = _$ProductionRoundSummaryCopyWithImpl<$Res, ProductionRoundSummary>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _readNumMap) Map<String, double> batches,
    @JsonKey(fromJson: _readNumMap) Map<String, double> jars,
    @JsonKey(name: 'jars_total', fromJson: _readNum) double jarsTotal,
    @JsonKey(name: 'items_to_make', fromJson: _readInt) int itemsToMake,
    @JsonKey(name: 'needed_now_count', fromJson: _readInt) int neededNowCount,
    @JsonKey(name: 'missing_count', fromJson: _readInt) int missingCount,
    @JsonKey(name: 'blocked_count', fromJson: _readInt) int blockedCount,
  });
}

/// @nodoc
class _$ProductionRoundSummaryCopyWithImpl<
  $Res,
  $Val extends ProductionRoundSummary
>
    implements $ProductionRoundSummaryCopyWith<$Res> {
  _$ProductionRoundSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batches = null,
    Object? jars = null,
    Object? jarsTotal = null,
    Object? itemsToMake = null,
    Object? neededNowCount = null,
    Object? missingCount = null,
    Object? blockedCount = null,
  }) {
    return _then(
      _value.copyWith(
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            jars: null == jars
                ? _value.jars
                : jars // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            jarsTotal: null == jarsTotal
                ? _value.jarsTotal
                : jarsTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            itemsToMake: null == itemsToMake
                ? _value.itemsToMake
                : itemsToMake // ignore: cast_nullable_to_non_nullable
                      as int,
            neededNowCount: null == neededNowCount
                ? _value.neededNowCount
                : neededNowCount // ignore: cast_nullable_to_non_nullable
                      as int,
            missingCount: null == missingCount
                ? _value.missingCount
                : missingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            blockedCount: null == blockedCount
                ? _value.blockedCount
                : blockedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionRoundSummaryImplCopyWith<$Res>
    implements $ProductionRoundSummaryCopyWith<$Res> {
  factory _$$ProductionRoundSummaryImplCopyWith(
    _$ProductionRoundSummaryImpl value,
    $Res Function(_$ProductionRoundSummaryImpl) then,
  ) = __$$ProductionRoundSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _readNumMap) Map<String, double> batches,
    @JsonKey(fromJson: _readNumMap) Map<String, double> jars,
    @JsonKey(name: 'jars_total', fromJson: _readNum) double jarsTotal,
    @JsonKey(name: 'items_to_make', fromJson: _readInt) int itemsToMake,
    @JsonKey(name: 'needed_now_count', fromJson: _readInt) int neededNowCount,
    @JsonKey(name: 'missing_count', fromJson: _readInt) int missingCount,
    @JsonKey(name: 'blocked_count', fromJson: _readInt) int blockedCount,
  });
}

/// @nodoc
class __$$ProductionRoundSummaryImplCopyWithImpl<$Res>
    extends
        _$ProductionRoundSummaryCopyWithImpl<$Res, _$ProductionRoundSummaryImpl>
    implements _$$ProductionRoundSummaryImplCopyWith<$Res> {
  __$$ProductionRoundSummaryImplCopyWithImpl(
    _$ProductionRoundSummaryImpl _value,
    $Res Function(_$ProductionRoundSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batches = null,
    Object? jars = null,
    Object? jarsTotal = null,
    Object? itemsToMake = null,
    Object? neededNowCount = null,
    Object? missingCount = null,
    Object? blockedCount = null,
  }) {
    return _then(
      _$ProductionRoundSummaryImpl(
        batches: null == batches
            ? _value._batches
            : batches // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        jars: null == jars
            ? _value._jars
            : jars // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        jarsTotal: null == jarsTotal
            ? _value.jarsTotal
            : jarsTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        itemsToMake: null == itemsToMake
            ? _value.itemsToMake
            : itemsToMake // ignore: cast_nullable_to_non_nullable
                  as int,
        neededNowCount: null == neededNowCount
            ? _value.neededNowCount
            : neededNowCount // ignore: cast_nullable_to_non_nullable
                  as int,
        missingCount: null == missingCount
            ? _value.missingCount
            : missingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        blockedCount: null == blockedCount
            ? _value.blockedCount
            : blockedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundSummaryImpl implements _ProductionRoundSummary {
  const _$ProductionRoundSummaryImpl({
    @JsonKey(fromJson: _readNumMap)
    final Map<String, double> batches = const <String, double>{},
    @JsonKey(fromJson: _readNumMap)
    final Map<String, double> jars = const <String, double>{},
    @JsonKey(name: 'jars_total', fromJson: _readNum) this.jarsTotal = 0.0,
    @JsonKey(name: 'items_to_make', fromJson: _readInt) this.itemsToMake = 0,
    @JsonKey(name: 'needed_now_count', fromJson: _readInt)
    this.neededNowCount = 0,
    @JsonKey(name: 'missing_count', fromJson: _readInt) this.missingCount = 0,
    @JsonKey(name: 'blocked_count', fromJson: _readInt) this.blockedCount = 0,
  }) : _batches = batches,
       _jars = jars;

  factory _$ProductionRoundSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundSummaryImplFromJson(json);

  /// Batches per size group (`Medium`, `Large`), multiples of 0.25.
  final Map<String, double> _batches;

  /// Batches per size group (`Medium`, `Large`), multiples of 0.25.
  @override
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get batches {
    if (_batches is EqualUnmodifiableMapView) return _batches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_batches);
  }

  final Map<String, double> _jars;
  @override
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get jars {
    if (_jars is EqualUnmodifiableMapView) return _jars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_jars);
  }

  @override
  @JsonKey(name: 'jars_total', fromJson: _readNum)
  final double jarsTotal;
  @override
  @JsonKey(name: 'items_to_make', fromJson: _readInt)
  final int itemsToMake;
  @override
  @JsonKey(name: 'needed_now_count', fromJson: _readInt)
  final int neededNowCount;
  @override
  @JsonKey(name: 'missing_count', fromJson: _readInt)
  final int missingCount;

  /// Jar ITEMS (flavour × size) to make that use a missing material — a
  /// count of rows, not of jars.
  @override
  @JsonKey(name: 'blocked_count', fromJson: _readInt)
  final int blockedCount;

  @override
  String toString() {
    return 'ProductionRoundSummary(batches: $batches, jars: $jars, jarsTotal: $jarsTotal, itemsToMake: $itemsToMake, neededNowCount: $neededNowCount, missingCount: $missingCount, blockedCount: $blockedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundSummaryImpl &&
            const DeepCollectionEquality().equals(other._batches, _batches) &&
            const DeepCollectionEquality().equals(other._jars, _jars) &&
            (identical(other.jarsTotal, jarsTotal) ||
                other.jarsTotal == jarsTotal) &&
            (identical(other.itemsToMake, itemsToMake) ||
                other.itemsToMake == itemsToMake) &&
            (identical(other.neededNowCount, neededNowCount) ||
                other.neededNowCount == neededNowCount) &&
            (identical(other.missingCount, missingCount) ||
                other.missingCount == missingCount) &&
            (identical(other.blockedCount, blockedCount) ||
                other.blockedCount == blockedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_batches),
    const DeepCollectionEquality().hash(_jars),
    jarsTotal,
    itemsToMake,
    neededNowCount,
    missingCount,
    blockedCount,
  );

  /// Create a copy of ProductionRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundSummaryImplCopyWith<_$ProductionRoundSummaryImpl>
  get copyWith =>
      __$$ProductionRoundSummaryImplCopyWithImpl<_$ProductionRoundSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundSummaryImplToJson(this);
  }
}

abstract class _ProductionRoundSummary implements ProductionRoundSummary {
  const factory _ProductionRoundSummary({
    @JsonKey(fromJson: _readNumMap) final Map<String, double> batches,
    @JsonKey(fromJson: _readNumMap) final Map<String, double> jars,
    @JsonKey(name: 'jars_total', fromJson: _readNum) final double jarsTotal,
    @JsonKey(name: 'items_to_make', fromJson: _readInt) final int itemsToMake,
    @JsonKey(name: 'needed_now_count', fromJson: _readInt)
    final int neededNowCount,
    @JsonKey(name: 'missing_count', fromJson: _readInt) final int missingCount,
    @JsonKey(name: 'blocked_count', fromJson: _readInt) final int blockedCount,
  }) = _$ProductionRoundSummaryImpl;

  factory _ProductionRoundSummary.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundSummaryImpl.fromJson;

  /// Batches per size group (`Medium`, `Large`), multiples of 0.25.
  @override
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get batches;
  @override
  @JsonKey(fromJson: _readNumMap)
  Map<String, double> get jars;
  @override
  @JsonKey(name: 'jars_total', fromJson: _readNum)
  double get jarsTotal;
  @override
  @JsonKey(name: 'items_to_make', fromJson: _readInt)
  int get itemsToMake;
  @override
  @JsonKey(name: 'needed_now_count', fromJson: _readInt)
  int get neededNowCount;
  @override
  @JsonKey(name: 'missing_count', fromJson: _readInt)
  int get missingCount;

  /// Jar ITEMS (flavour × size) to make that use a missing material — a
  /// count of rows, not of jars.
  @override
  @JsonKey(name: 'blocked_count', fromJson: _readInt)
  int get blockedCount;

  /// Create a copy of ProductionRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundSummaryImplCopyWith<_$ProductionRoundSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionRound _$ProductionRoundFromJson(Map<String, dynamic> json) {
  return _ProductionRound.fromJson(json);
}

/// @nodoc
mixin _$ProductionRound {
  @JsonKey(name: 'generated_on', fromJson: _readString)
  String get generatedOn => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readString)
  String get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_warehouse', fromJson: _readString)
  String get sourceWarehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'cycle_days', fromJson: _readInt)
  int get cycleDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'backup_days', fromJson: _readInt)
  int get backupDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_days', fromJson: _readInt)
  int get coverDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'sales_weeks', fromJson: _readInt)
  int get salesWeeks => throw _privateConstructorUsedError;
  @JsonKey(name: 'sales_from', fromJson: _readString)
  String get salesFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'sales_to', fromJson: _readString)
  String get salesTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
  Map<String, double> get batchSizes => throw _privateConstructorUsedError;
  ProductionRoundSummary get summary => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readBranches)
  List<ProductionRoundBranch> get branches =>
      throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readItems)
  List<ProductionRoundItem> get items => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readPrep)
  List<ProductionRoundPrep> get prep => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readMaterials)
  List<ProductionRoundMaterial> get materials =>
      throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readStringList)
  List<String> get notices => throw _privateConstructorUsedError;

  /// Serializes this ProductionRound to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionRoundCopyWith<ProductionRound> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionRoundCopyWith<$Res> {
  factory $ProductionRoundCopyWith(
    ProductionRound value,
    $Res Function(ProductionRound) then,
  ) = _$ProductionRoundCopyWithImpl<$Res, ProductionRound>;
  @useResult
  $Res call({
    @JsonKey(name: 'generated_on', fromJson: _readString) String generatedOn,
    @JsonKey(fromJson: _readString) String company,
    @JsonKey(name: 'source_warehouse', fromJson: _readString)
    String sourceWarehouse,
    @JsonKey(name: 'cycle_days', fromJson: _readInt) int cycleDays,
    @JsonKey(name: 'backup_days', fromJson: _readInt) int backupDays,
    @JsonKey(name: 'cover_days', fromJson: _readInt) int coverDays,
    @JsonKey(name: 'sales_weeks', fromJson: _readInt) int salesWeeks,
    @JsonKey(name: 'sales_from', fromJson: _readString) String salesFrom,
    @JsonKey(name: 'sales_to', fromJson: _readString) String salesTo,
    @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
    Map<String, double> batchSizes,
    ProductionRoundSummary summary,
    @JsonKey(fromJson: _readBranches) List<ProductionRoundBranch> branches,
    @JsonKey(fromJson: _readItems) List<ProductionRoundItem> items,
    @JsonKey(fromJson: _readPrep) List<ProductionRoundPrep> prep,
    @JsonKey(fromJson: _readMaterials) List<ProductionRoundMaterial> materials,
    @JsonKey(fromJson: _readStringList) List<String> notices,
  });

  $ProductionRoundSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ProductionRoundCopyWithImpl<$Res, $Val extends ProductionRound>
    implements $ProductionRoundCopyWith<$Res> {
  _$ProductionRoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedOn = null,
    Object? company = null,
    Object? sourceWarehouse = null,
    Object? cycleDays = null,
    Object? backupDays = null,
    Object? coverDays = null,
    Object? salesWeeks = null,
    Object? salesFrom = null,
    Object? salesTo = null,
    Object? batchSizes = null,
    Object? summary = null,
    Object? branches = null,
    Object? items = null,
    Object? prep = null,
    Object? materials = null,
    Object? notices = null,
  }) {
    return _then(
      _value.copyWith(
            generatedOn: null == generatedOn
                ? _value.generatedOn
                : generatedOn // ignore: cast_nullable_to_non_nullable
                      as String,
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceWarehouse: null == sourceWarehouse
                ? _value.sourceWarehouse
                : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                      as String,
            cycleDays: null == cycleDays
                ? _value.cycleDays
                : cycleDays // ignore: cast_nullable_to_non_nullable
                      as int,
            backupDays: null == backupDays
                ? _value.backupDays
                : backupDays // ignore: cast_nullable_to_non_nullable
                      as int,
            coverDays: null == coverDays
                ? _value.coverDays
                : coverDays // ignore: cast_nullable_to_non_nullable
                      as int,
            salesWeeks: null == salesWeeks
                ? _value.salesWeeks
                : salesWeeks // ignore: cast_nullable_to_non_nullable
                      as int,
            salesFrom: null == salesFrom
                ? _value.salesFrom
                : salesFrom // ignore: cast_nullable_to_non_nullable
                      as String,
            salesTo: null == salesTo
                ? _value.salesTo
                : salesTo // ignore: cast_nullable_to_non_nullable
                      as String,
            batchSizes: null == batchSizes
                ? _value.batchSizes
                : batchSizes // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as ProductionRoundSummary,
            branches: null == branches
                ? _value.branches
                : branches // ignore: cast_nullable_to_non_nullable
                      as List<ProductionRoundBranch>,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ProductionRoundItem>,
            prep: null == prep
                ? _value.prep
                : prep // ignore: cast_nullable_to_non_nullable
                      as List<ProductionRoundPrep>,
            materials: null == materials
                ? _value.materials
                : materials // ignore: cast_nullable_to_non_nullable
                      as List<ProductionRoundMaterial>,
            notices: null == notices
                ? _value.notices
                : notices // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionRoundSummaryCopyWith<$Res> get summary {
    return $ProductionRoundSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductionRoundImplCopyWith<$Res>
    implements $ProductionRoundCopyWith<$Res> {
  factory _$$ProductionRoundImplCopyWith(
    _$ProductionRoundImpl value,
    $Res Function(_$ProductionRoundImpl) then,
  ) = __$$ProductionRoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'generated_on', fromJson: _readString) String generatedOn,
    @JsonKey(fromJson: _readString) String company,
    @JsonKey(name: 'source_warehouse', fromJson: _readString)
    String sourceWarehouse,
    @JsonKey(name: 'cycle_days', fromJson: _readInt) int cycleDays,
    @JsonKey(name: 'backup_days', fromJson: _readInt) int backupDays,
    @JsonKey(name: 'cover_days', fromJson: _readInt) int coverDays,
    @JsonKey(name: 'sales_weeks', fromJson: _readInt) int salesWeeks,
    @JsonKey(name: 'sales_from', fromJson: _readString) String salesFrom,
    @JsonKey(name: 'sales_to', fromJson: _readString) String salesTo,
    @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
    Map<String, double> batchSizes,
    ProductionRoundSummary summary,
    @JsonKey(fromJson: _readBranches) List<ProductionRoundBranch> branches,
    @JsonKey(fromJson: _readItems) List<ProductionRoundItem> items,
    @JsonKey(fromJson: _readPrep) List<ProductionRoundPrep> prep,
    @JsonKey(fromJson: _readMaterials) List<ProductionRoundMaterial> materials,
    @JsonKey(fromJson: _readStringList) List<String> notices,
  });

  @override
  $ProductionRoundSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ProductionRoundImplCopyWithImpl<$Res>
    extends _$ProductionRoundCopyWithImpl<$Res, _$ProductionRoundImpl>
    implements _$$ProductionRoundImplCopyWith<$Res> {
  __$$ProductionRoundImplCopyWithImpl(
    _$ProductionRoundImpl _value,
    $Res Function(_$ProductionRoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedOn = null,
    Object? company = null,
    Object? sourceWarehouse = null,
    Object? cycleDays = null,
    Object? backupDays = null,
    Object? coverDays = null,
    Object? salesWeeks = null,
    Object? salesFrom = null,
    Object? salesTo = null,
    Object? batchSizes = null,
    Object? summary = null,
    Object? branches = null,
    Object? items = null,
    Object? prep = null,
    Object? materials = null,
    Object? notices = null,
  }) {
    return _then(
      _$ProductionRoundImpl(
        generatedOn: null == generatedOn
            ? _value.generatedOn
            : generatedOn // ignore: cast_nullable_to_non_nullable
                  as String,
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceWarehouse: null == sourceWarehouse
            ? _value.sourceWarehouse
            : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                  as String,
        cycleDays: null == cycleDays
            ? _value.cycleDays
            : cycleDays // ignore: cast_nullable_to_non_nullable
                  as int,
        backupDays: null == backupDays
            ? _value.backupDays
            : backupDays // ignore: cast_nullable_to_non_nullable
                  as int,
        coverDays: null == coverDays
            ? _value.coverDays
            : coverDays // ignore: cast_nullable_to_non_nullable
                  as int,
        salesWeeks: null == salesWeeks
            ? _value.salesWeeks
            : salesWeeks // ignore: cast_nullable_to_non_nullable
                  as int,
        salesFrom: null == salesFrom
            ? _value.salesFrom
            : salesFrom // ignore: cast_nullable_to_non_nullable
                  as String,
        salesTo: null == salesTo
            ? _value.salesTo
            : salesTo // ignore: cast_nullable_to_non_nullable
                  as String,
        batchSizes: null == batchSizes
            ? _value._batchSizes
            : batchSizes // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as ProductionRoundSummary,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<ProductionRoundBranch>,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ProductionRoundItem>,
        prep: null == prep
            ? _value._prep
            : prep // ignore: cast_nullable_to_non_nullable
                  as List<ProductionRoundPrep>,
        materials: null == materials
            ? _value._materials
            : materials // ignore: cast_nullable_to_non_nullable
                  as List<ProductionRoundMaterial>,
        notices: null == notices
            ? _value._notices
            : notices // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionRoundImpl extends _ProductionRound {
  const _$ProductionRoundImpl({
    @JsonKey(name: 'generated_on', fromJson: _readString) this.generatedOn = '',
    @JsonKey(fromJson: _readString) this.company = '',
    @JsonKey(name: 'source_warehouse', fromJson: _readString)
    this.sourceWarehouse = '',
    @JsonKey(name: 'cycle_days', fromJson: _readInt) this.cycleDays = 0,
    @JsonKey(name: 'backup_days', fromJson: _readInt) this.backupDays = 0,
    @JsonKey(name: 'cover_days', fromJson: _readInt) this.coverDays = 0,
    @JsonKey(name: 'sales_weeks', fromJson: _readInt) this.salesWeeks = 0,
    @JsonKey(name: 'sales_from', fromJson: _readString) this.salesFrom = '',
    @JsonKey(name: 'sales_to', fromJson: _readString) this.salesTo = '',
    @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
    final Map<String, double> batchSizes = const <String, double>{},
    this.summary = const ProductionRoundSummary(),
    @JsonKey(fromJson: _readBranches)
    final List<ProductionRoundBranch> branches =
        const <ProductionRoundBranch>[],
    @JsonKey(fromJson: _readItems)
    final List<ProductionRoundItem> items = const <ProductionRoundItem>[],
    @JsonKey(fromJson: _readPrep)
    final List<ProductionRoundPrep> prep = const <ProductionRoundPrep>[],
    @JsonKey(fromJson: _readMaterials)
    final List<ProductionRoundMaterial> materials =
        const <ProductionRoundMaterial>[],
    @JsonKey(fromJson: _readStringList)
    final List<String> notices = const <String>[],
  }) : _batchSizes = batchSizes,
       _branches = branches,
       _items = items,
       _prep = prep,
       _materials = materials,
       _notices = notices,
       super._();

  factory _$ProductionRoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionRoundImplFromJson(json);

  @override
  @JsonKey(name: 'generated_on', fromJson: _readString)
  final String generatedOn;
  @override
  @JsonKey(fromJson: _readString)
  final String company;
  @override
  @JsonKey(name: 'source_warehouse', fromJson: _readString)
  final String sourceWarehouse;
  @override
  @JsonKey(name: 'cycle_days', fromJson: _readInt)
  final int cycleDays;
  @override
  @JsonKey(name: 'backup_days', fromJson: _readInt)
  final int backupDays;
  @override
  @JsonKey(name: 'cover_days', fromJson: _readInt)
  final int coverDays;
  @override
  @JsonKey(name: 'sales_weeks', fromJson: _readInt)
  final int salesWeeks;
  @override
  @JsonKey(name: 'sales_from', fromJson: _readString)
  final String salesFrom;
  @override
  @JsonKey(name: 'sales_to', fromJson: _readString)
  final String salesTo;
  final Map<String, double> _batchSizes;
  @override
  @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
  Map<String, double> get batchSizes {
    if (_batchSizes is EqualUnmodifiableMapView) return _batchSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_batchSizes);
  }

  @override
  @JsonKey()
  final ProductionRoundSummary summary;
  final List<ProductionRoundBranch> _branches;
  @override
  @JsonKey(fromJson: _readBranches)
  List<ProductionRoundBranch> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  final List<ProductionRoundItem> _items;
  @override
  @JsonKey(fromJson: _readItems)
  List<ProductionRoundItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<ProductionRoundPrep> _prep;
  @override
  @JsonKey(fromJson: _readPrep)
  List<ProductionRoundPrep> get prep {
    if (_prep is EqualUnmodifiableListView) return _prep;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prep);
  }

  final List<ProductionRoundMaterial> _materials;
  @override
  @JsonKey(fromJson: _readMaterials)
  List<ProductionRoundMaterial> get materials {
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_materials);
  }

  final List<String> _notices;
  @override
  @JsonKey(fromJson: _readStringList)
  List<String> get notices {
    if (_notices is EqualUnmodifiableListView) return _notices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notices);
  }

  @override
  String toString() {
    return 'ProductionRound(generatedOn: $generatedOn, company: $company, sourceWarehouse: $sourceWarehouse, cycleDays: $cycleDays, backupDays: $backupDays, coverDays: $coverDays, salesWeeks: $salesWeeks, salesFrom: $salesFrom, salesTo: $salesTo, batchSizes: $batchSizes, summary: $summary, branches: $branches, items: $items, prep: $prep, materials: $materials, notices: $notices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionRoundImpl &&
            (identical(other.generatedOn, generatedOn) ||
                other.generatedOn == generatedOn) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.sourceWarehouse, sourceWarehouse) ||
                other.sourceWarehouse == sourceWarehouse) &&
            (identical(other.cycleDays, cycleDays) ||
                other.cycleDays == cycleDays) &&
            (identical(other.backupDays, backupDays) ||
                other.backupDays == backupDays) &&
            (identical(other.coverDays, coverDays) ||
                other.coverDays == coverDays) &&
            (identical(other.salesWeeks, salesWeeks) ||
                other.salesWeeks == salesWeeks) &&
            (identical(other.salesFrom, salesFrom) ||
                other.salesFrom == salesFrom) &&
            (identical(other.salesTo, salesTo) || other.salesTo == salesTo) &&
            const DeepCollectionEquality().equals(
              other._batchSizes,
              _batchSizes,
            ) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._prep, _prep) &&
            const DeepCollectionEquality().equals(
              other._materials,
              _materials,
            ) &&
            const DeepCollectionEquality().equals(other._notices, _notices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    generatedOn,
    company,
    sourceWarehouse,
    cycleDays,
    backupDays,
    coverDays,
    salesWeeks,
    salesFrom,
    salesTo,
    const DeepCollectionEquality().hash(_batchSizes),
    summary,
    const DeepCollectionEquality().hash(_branches),
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_prep),
    const DeepCollectionEquality().hash(_materials),
    const DeepCollectionEquality().hash(_notices),
  );

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionRoundImplCopyWith<_$ProductionRoundImpl> get copyWith =>
      __$$ProductionRoundImplCopyWithImpl<_$ProductionRoundImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionRoundImplToJson(this);
  }
}

abstract class _ProductionRound extends ProductionRound {
  const factory _ProductionRound({
    @JsonKey(name: 'generated_on', fromJson: _readString)
    final String generatedOn,
    @JsonKey(fromJson: _readString) final String company,
    @JsonKey(name: 'source_warehouse', fromJson: _readString)
    final String sourceWarehouse,
    @JsonKey(name: 'cycle_days', fromJson: _readInt) final int cycleDays,
    @JsonKey(name: 'backup_days', fromJson: _readInt) final int backupDays,
    @JsonKey(name: 'cover_days', fromJson: _readInt) final int coverDays,
    @JsonKey(name: 'sales_weeks', fromJson: _readInt) final int salesWeeks,
    @JsonKey(name: 'sales_from', fromJson: _readString) final String salesFrom,
    @JsonKey(name: 'sales_to', fromJson: _readString) final String salesTo,
    @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
    final Map<String, double> batchSizes,
    final ProductionRoundSummary summary,
    @JsonKey(fromJson: _readBranches)
    final List<ProductionRoundBranch> branches,
    @JsonKey(fromJson: _readItems) final List<ProductionRoundItem> items,
    @JsonKey(fromJson: _readPrep) final List<ProductionRoundPrep> prep,
    @JsonKey(fromJson: _readMaterials)
    final List<ProductionRoundMaterial> materials,
    @JsonKey(fromJson: _readStringList) final List<String> notices,
  }) = _$ProductionRoundImpl;
  const _ProductionRound._() : super._();

  factory _ProductionRound.fromJson(Map<String, dynamic> json) =
      _$ProductionRoundImpl.fromJson;

  @override
  @JsonKey(name: 'generated_on', fromJson: _readString)
  String get generatedOn;
  @override
  @JsonKey(fromJson: _readString)
  String get company;
  @override
  @JsonKey(name: 'source_warehouse', fromJson: _readString)
  String get sourceWarehouse;
  @override
  @JsonKey(name: 'cycle_days', fromJson: _readInt)
  int get cycleDays;
  @override
  @JsonKey(name: 'backup_days', fromJson: _readInt)
  int get backupDays;
  @override
  @JsonKey(name: 'cover_days', fromJson: _readInt)
  int get coverDays;
  @override
  @JsonKey(name: 'sales_weeks', fromJson: _readInt)
  int get salesWeeks;
  @override
  @JsonKey(name: 'sales_from', fromJson: _readString)
  String get salesFrom;
  @override
  @JsonKey(name: 'sales_to', fromJson: _readString)
  String get salesTo;
  @override
  @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
  Map<String, double> get batchSizes;
  @override
  ProductionRoundSummary get summary;
  @override
  @JsonKey(fromJson: _readBranches)
  List<ProductionRoundBranch> get branches;
  @override
  @JsonKey(fromJson: _readItems)
  List<ProductionRoundItem> get items;
  @override
  @JsonKey(fromJson: _readPrep)
  List<ProductionRoundPrep> get prep;
  @override
  @JsonKey(fromJson: _readMaterials)
  List<ProductionRoundMaterial> get materials;
  @override
  @JsonKey(fromJson: _readStringList)
  List<String> get notices;

  /// Create a copy of ProductionRound
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionRoundImplCopyWith<_$ProductionRoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
