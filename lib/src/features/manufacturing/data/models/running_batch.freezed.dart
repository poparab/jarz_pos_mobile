// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'running_batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RunningBatch _$RunningBatchFromJson(Map<String, dynamic> json) {
  return _RunningBatch.fromJson(json);
}

/// @nodoc
mixin _$RunningBatch {
  @JsonKey(name: 'name')
  String get workOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_item')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bom_no')
  String get bomName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  double get qty => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_qty')
  double get producedQty => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'jarz_started_by')
  String? get startedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'jarz_started_at')
  String? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'elapsed_minutes')
  int get elapsedMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'wip_warehouse')
  String? get wipWarehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg_warehouse')
  String? get fgWarehouse => throw _privateConstructorUsedError;

  /// Material transferred into WIP but not consumed by the finish. Surfaced
  /// so it cannot drift silently — that drift only ever shows up months later
  /// as an unexplainable variance.
  @JsonKey(name: 'wip_leftover_qty')
  double get wipLeftoverQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'jarz_sop_version')
  String? get sopVersion => throw _privateConstructorUsedError;

  /// Serializes this RunningBatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunningBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunningBatchCopyWith<RunningBatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunningBatchCopyWith<$Res> {
  factory $RunningBatchCopyWith(
    RunningBatch value,
    $Res Function(RunningBatch) then,
  ) = _$RunningBatchCopyWithImpl<$Res, RunningBatch>;
  @useResult
  $Res call({
    @JsonKey(name: 'name') String workOrder,
    @JsonKey(name: 'production_item') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'bom_no') String bomName,
    @JsonKey(name: 'stock_uom') String stockUom,
    double qty,
    @JsonKey(name: 'produced_qty') double producedQty,
    String status,
    @JsonKey(name: 'jarz_started_by') String? startedBy,
    @JsonKey(name: 'jarz_started_at') String? startedAt,
    @JsonKey(name: 'elapsed_minutes') int elapsedMinutes,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,
    @JsonKey(name: 'wip_leftover_qty') double wipLeftoverQty,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
  });
}

/// @nodoc
class _$RunningBatchCopyWithImpl<$Res, $Val extends RunningBatch>
    implements $RunningBatchCopyWith<$Res> {
  _$RunningBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunningBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? bomName = null,
    Object? stockUom = null,
    Object? qty = null,
    Object? producedQty = null,
    Object? status = null,
    Object? startedBy = freezed,
    Object? startedAt = freezed,
    Object? elapsedMinutes = null,
    Object? wipWarehouse = freezed,
    Object? fgWarehouse = freezed,
    Object? wipLeftoverQty = null,
    Object? sopVersion = freezed,
  }) {
    return _then(
      _value.copyWith(
            workOrder: null == workOrder
                ? _value.workOrder
                : workOrder // ignore: cast_nullable_to_non_nullable
                      as String,
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
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as double,
            producedQty: null == producedQty
                ? _value.producedQty
                : producedQty // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            startedBy: freezed == startedBy
                ? _value.startedBy
                : startedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            elapsedMinutes: null == elapsedMinutes
                ? _value.elapsedMinutes
                : elapsedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            wipWarehouse: freezed == wipWarehouse
                ? _value.wipWarehouse
                : wipWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            fgWarehouse: freezed == fgWarehouse
                ? _value.fgWarehouse
                : fgWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            wipLeftoverQty: null == wipLeftoverQty
                ? _value.wipLeftoverQty
                : wipLeftoverQty // ignore: cast_nullable_to_non_nullable
                      as double,
            sopVersion: freezed == sopVersion
                ? _value.sopVersion
                : sopVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RunningBatchImplCopyWith<$Res>
    implements $RunningBatchCopyWith<$Res> {
  factory _$$RunningBatchImplCopyWith(
    _$RunningBatchImpl value,
    $Res Function(_$RunningBatchImpl) then,
  ) = __$$RunningBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'name') String workOrder,
    @JsonKey(name: 'production_item') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'bom_no') String bomName,
    @JsonKey(name: 'stock_uom') String stockUom,
    double qty,
    @JsonKey(name: 'produced_qty') double producedQty,
    String status,
    @JsonKey(name: 'jarz_started_by') String? startedBy,
    @JsonKey(name: 'jarz_started_at') String? startedAt,
    @JsonKey(name: 'elapsed_minutes') int elapsedMinutes,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,
    @JsonKey(name: 'wip_leftover_qty') double wipLeftoverQty,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
  });
}

/// @nodoc
class __$$RunningBatchImplCopyWithImpl<$Res>
    extends _$RunningBatchCopyWithImpl<$Res, _$RunningBatchImpl>
    implements _$$RunningBatchImplCopyWith<$Res> {
  __$$RunningBatchImplCopyWithImpl(
    _$RunningBatchImpl _value,
    $Res Function(_$RunningBatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RunningBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? bomName = null,
    Object? stockUom = null,
    Object? qty = null,
    Object? producedQty = null,
    Object? status = null,
    Object? startedBy = freezed,
    Object? startedAt = freezed,
    Object? elapsedMinutes = null,
    Object? wipWarehouse = freezed,
    Object? fgWarehouse = freezed,
    Object? wipLeftoverQty = null,
    Object? sopVersion = freezed,
  }) {
    return _then(
      _$RunningBatchImpl(
        workOrder: null == workOrder
            ? _value.workOrder
            : workOrder // ignore: cast_nullable_to_non_nullable
                  as String,
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
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as double,
        producedQty: null == producedQty
            ? _value.producedQty
            : producedQty // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        startedBy: freezed == startedBy
            ? _value.startedBy
            : startedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        elapsedMinutes: null == elapsedMinutes
            ? _value.elapsedMinutes
            : elapsedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        wipWarehouse: freezed == wipWarehouse
            ? _value.wipWarehouse
            : wipWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        fgWarehouse: freezed == fgWarehouse
            ? _value.fgWarehouse
            : fgWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        wipLeftoverQty: null == wipLeftoverQty
            ? _value.wipLeftoverQty
            : wipLeftoverQty // ignore: cast_nullable_to_non_nullable
                  as double,
        sopVersion: freezed == sopVersion
            ? _value.sopVersion
            : sopVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RunningBatchImpl extends _RunningBatch {
  const _$RunningBatchImpl({
    @JsonKey(name: 'name') this.workOrder = '',
    @JsonKey(name: 'production_item') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'bom_no') this.bomName = '',
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    this.qty = 0.0,
    @JsonKey(name: 'produced_qty') this.producedQty = 0.0,
    this.status = '',
    @JsonKey(name: 'jarz_started_by') this.startedBy,
    @JsonKey(name: 'jarz_started_at') this.startedAt,
    @JsonKey(name: 'elapsed_minutes') this.elapsedMinutes = 0,
    @JsonKey(name: 'wip_warehouse') this.wipWarehouse,
    @JsonKey(name: 'fg_warehouse') this.fgWarehouse,
    @JsonKey(name: 'wip_leftover_qty') this.wipLeftoverQty = 0.0,
    @JsonKey(name: 'jarz_sop_version') this.sopVersion,
  }) : super._();

  factory _$RunningBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunningBatchImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String workOrder;
  @override
  @JsonKey(name: 'production_item')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'bom_no')
  final String bomName;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  @override
  @JsonKey()
  final double qty;
  @override
  @JsonKey(name: 'produced_qty')
  final double producedQty;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'jarz_started_by')
  final String? startedBy;
  @override
  @JsonKey(name: 'jarz_started_at')
  final String? startedAt;
  @override
  @JsonKey(name: 'elapsed_minutes')
  final int elapsedMinutes;
  @override
  @JsonKey(name: 'wip_warehouse')
  final String? wipWarehouse;
  @override
  @JsonKey(name: 'fg_warehouse')
  final String? fgWarehouse;

  /// Material transferred into WIP but not consumed by the finish. Surfaced
  /// so it cannot drift silently — that drift only ever shows up months later
  /// as an unexplainable variance.
  @override
  @JsonKey(name: 'wip_leftover_qty')
  final double wipLeftoverQty;
  @override
  @JsonKey(name: 'jarz_sop_version')
  final String? sopVersion;

  @override
  String toString() {
    return 'RunningBatch(workOrder: $workOrder, itemCode: $itemCode, itemName: $itemName, bomName: $bomName, stockUom: $stockUom, qty: $qty, producedQty: $producedQty, status: $status, startedBy: $startedBy, startedAt: $startedAt, elapsedMinutes: $elapsedMinutes, wipWarehouse: $wipWarehouse, fgWarehouse: $fgWarehouse, wipLeftoverQty: $wipLeftoverQty, sopVersion: $sopVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunningBatchImpl &&
            (identical(other.workOrder, workOrder) ||
                other.workOrder == workOrder) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.bomName, bomName) || other.bomName == bomName) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.producedQty, producedQty) ||
                other.producedQty == producedQty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedBy, startedBy) ||
                other.startedBy == startedBy) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.elapsedMinutes, elapsedMinutes) ||
                other.elapsedMinutes == elapsedMinutes) &&
            (identical(other.wipWarehouse, wipWarehouse) ||
                other.wipWarehouse == wipWarehouse) &&
            (identical(other.fgWarehouse, fgWarehouse) ||
                other.fgWarehouse == fgWarehouse) &&
            (identical(other.wipLeftoverQty, wipLeftoverQty) ||
                other.wipLeftoverQty == wipLeftoverQty) &&
            (identical(other.sopVersion, sopVersion) ||
                other.sopVersion == sopVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    workOrder,
    itemCode,
    itemName,
    bomName,
    stockUom,
    qty,
    producedQty,
    status,
    startedBy,
    startedAt,
    elapsedMinutes,
    wipWarehouse,
    fgWarehouse,
    wipLeftoverQty,
    sopVersion,
  );

  /// Create a copy of RunningBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunningBatchImplCopyWith<_$RunningBatchImpl> get copyWith =>
      __$$RunningBatchImplCopyWithImpl<_$RunningBatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunningBatchImplToJson(this);
  }
}

abstract class _RunningBatch extends RunningBatch {
  const factory _RunningBatch({
    @JsonKey(name: 'name') final String workOrder,
    @JsonKey(name: 'production_item') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'bom_no') final String bomName,
    @JsonKey(name: 'stock_uom') final String stockUom,
    final double qty,
    @JsonKey(name: 'produced_qty') final double producedQty,
    final String status,
    @JsonKey(name: 'jarz_started_by') final String? startedBy,
    @JsonKey(name: 'jarz_started_at') final String? startedAt,
    @JsonKey(name: 'elapsed_minutes') final int elapsedMinutes,
    @JsonKey(name: 'wip_warehouse') final String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') final String? fgWarehouse,
    @JsonKey(name: 'wip_leftover_qty') final double wipLeftoverQty,
    @JsonKey(name: 'jarz_sop_version') final String? sopVersion,
  }) = _$RunningBatchImpl;
  const _RunningBatch._() : super._();

  factory _RunningBatch.fromJson(Map<String, dynamic> json) =
      _$RunningBatchImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String get workOrder;
  @override
  @JsonKey(name: 'production_item')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'bom_no')
  String get bomName;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  double get qty;
  @override
  @JsonKey(name: 'produced_qty')
  double get producedQty;
  @override
  String get status;
  @override
  @JsonKey(name: 'jarz_started_by')
  String? get startedBy;
  @override
  @JsonKey(name: 'jarz_started_at')
  String? get startedAt;
  @override
  @JsonKey(name: 'elapsed_minutes')
  int get elapsedMinutes;
  @override
  @JsonKey(name: 'wip_warehouse')
  String? get wipWarehouse;
  @override
  @JsonKey(name: 'fg_warehouse')
  String? get fgWarehouse;

  /// Material transferred into WIP but not consumed by the finish. Surfaced
  /// so it cannot drift silently — that drift only ever shows up months later
  /// as an unexplainable variance.
  @override
  @JsonKey(name: 'wip_leftover_qty')
  double get wipLeftoverQty;
  @override
  @JsonKey(name: 'jarz_sop_version')
  String? get sopVersion;

  /// Create a copy of RunningBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunningBatchImplCopyWith<_$RunningBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchCost _$BatchCostFromJson(Map<String, dynamic> json) {
  return _BatchCost.fromJson(json);
}

/// @nodoc
mixin _$BatchCost {
  @JsonKey(name: 'work_order')
  String get workOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'material_cost')
  double get materialCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_qty')
  double get producedQty => throw _privateConstructorUsedError;

  /// Null when nothing has been produced yet — dividing by zero produces a
  /// number that looks real and is not.
  @JsonKey(name: 'cost_per_unit')
  double? get costPerUnit => throw _privateConstructorUsedError;

  /// Null when the BOM carries no cost, rather than a fake zero.
  @JsonKey(name: 'standard_per_unit')
  double? get standardPerUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'variance_amount')
  double? get varianceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'variance_pct')
  double? get variancePct => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this BatchCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchCostCopyWith<BatchCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchCostCopyWith<$Res> {
  factory $BatchCostCopyWith(BatchCost value, $Res Function(BatchCost) then) =
      _$BatchCostCopyWithImpl<$Res, BatchCost>;
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'material_cost') double materialCost,
    @JsonKey(name: 'produced_qty') double producedQty,
    @JsonKey(name: 'cost_per_unit') double? costPerUnit,
    @JsonKey(name: 'standard_per_unit') double? standardPerUnit,
    @JsonKey(name: 'variance_amount') double? varianceAmount,
    @JsonKey(name: 'variance_pct') double? variancePct,
    String currency,
  });
}

/// @nodoc
class _$BatchCostCopyWithImpl<$Res, $Val extends BatchCost>
    implements $BatchCostCopyWith<$Res> {
  _$BatchCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? materialCost = null,
    Object? producedQty = null,
    Object? costPerUnit = freezed,
    Object? standardPerUnit = freezed,
    Object? varianceAmount = freezed,
    Object? variancePct = freezed,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            workOrder: null == workOrder
                ? _value.workOrder
                : workOrder // ignore: cast_nullable_to_non_nullable
                      as String,
            materialCost: null == materialCost
                ? _value.materialCost
                : materialCost // ignore: cast_nullable_to_non_nullable
                      as double,
            producedQty: null == producedQty
                ? _value.producedQty
                : producedQty // ignore: cast_nullable_to_non_nullable
                      as double,
            costPerUnit: freezed == costPerUnit
                ? _value.costPerUnit
                : costPerUnit // ignore: cast_nullable_to_non_nullable
                      as double?,
            standardPerUnit: freezed == standardPerUnit
                ? _value.standardPerUnit
                : standardPerUnit // ignore: cast_nullable_to_non_nullable
                      as double?,
            varianceAmount: freezed == varianceAmount
                ? _value.varianceAmount
                : varianceAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            variancePct: freezed == variancePct
                ? _value.variancePct
                : variancePct // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$BatchCostImplCopyWith<$Res>
    implements $BatchCostCopyWith<$Res> {
  factory _$$BatchCostImplCopyWith(
    _$BatchCostImpl value,
    $Res Function(_$BatchCostImpl) then,
  ) = __$$BatchCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'material_cost') double materialCost,
    @JsonKey(name: 'produced_qty') double producedQty,
    @JsonKey(name: 'cost_per_unit') double? costPerUnit,
    @JsonKey(name: 'standard_per_unit') double? standardPerUnit,
    @JsonKey(name: 'variance_amount') double? varianceAmount,
    @JsonKey(name: 'variance_pct') double? variancePct,
    String currency,
  });
}

/// @nodoc
class __$$BatchCostImplCopyWithImpl<$Res>
    extends _$BatchCostCopyWithImpl<$Res, _$BatchCostImpl>
    implements _$$BatchCostImplCopyWith<$Res> {
  __$$BatchCostImplCopyWithImpl(
    _$BatchCostImpl _value,
    $Res Function(_$BatchCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? materialCost = null,
    Object? producedQty = null,
    Object? costPerUnit = freezed,
    Object? standardPerUnit = freezed,
    Object? varianceAmount = freezed,
    Object? variancePct = freezed,
    Object? currency = null,
  }) {
    return _then(
      _$BatchCostImpl(
        workOrder: null == workOrder
            ? _value.workOrder
            : workOrder // ignore: cast_nullable_to_non_nullable
                  as String,
        materialCost: null == materialCost
            ? _value.materialCost
            : materialCost // ignore: cast_nullable_to_non_nullable
                  as double,
        producedQty: null == producedQty
            ? _value.producedQty
            : producedQty // ignore: cast_nullable_to_non_nullable
                  as double,
        costPerUnit: freezed == costPerUnit
            ? _value.costPerUnit
            : costPerUnit // ignore: cast_nullable_to_non_nullable
                  as double?,
        standardPerUnit: freezed == standardPerUnit
            ? _value.standardPerUnit
            : standardPerUnit // ignore: cast_nullable_to_non_nullable
                  as double?,
        varianceAmount: freezed == varianceAmount
            ? _value.varianceAmount
            : varianceAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        variancePct: freezed == variancePct
            ? _value.variancePct
            : variancePct // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$BatchCostImpl extends _BatchCost {
  const _$BatchCostImpl({
    @JsonKey(name: 'work_order') this.workOrder = '',
    @JsonKey(name: 'material_cost') this.materialCost = 0.0,
    @JsonKey(name: 'produced_qty') this.producedQty = 0.0,
    @JsonKey(name: 'cost_per_unit') this.costPerUnit,
    @JsonKey(name: 'standard_per_unit') this.standardPerUnit,
    @JsonKey(name: 'variance_amount') this.varianceAmount,
    @JsonKey(name: 'variance_pct') this.variancePct,
    this.currency = '',
  }) : super._();

  factory _$BatchCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchCostImplFromJson(json);

  @override
  @JsonKey(name: 'work_order')
  final String workOrder;
  @override
  @JsonKey(name: 'material_cost')
  final double materialCost;
  @override
  @JsonKey(name: 'produced_qty')
  final double producedQty;

  /// Null when nothing has been produced yet — dividing by zero produces a
  /// number that looks real and is not.
  @override
  @JsonKey(name: 'cost_per_unit')
  final double? costPerUnit;

  /// Null when the BOM carries no cost, rather than a fake zero.
  @override
  @JsonKey(name: 'standard_per_unit')
  final double? standardPerUnit;
  @override
  @JsonKey(name: 'variance_amount')
  final double? varianceAmount;
  @override
  @JsonKey(name: 'variance_pct')
  final double? variancePct;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'BatchCost(workOrder: $workOrder, materialCost: $materialCost, producedQty: $producedQty, costPerUnit: $costPerUnit, standardPerUnit: $standardPerUnit, varianceAmount: $varianceAmount, variancePct: $variancePct, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchCostImpl &&
            (identical(other.workOrder, workOrder) ||
                other.workOrder == workOrder) &&
            (identical(other.materialCost, materialCost) ||
                other.materialCost == materialCost) &&
            (identical(other.producedQty, producedQty) ||
                other.producedQty == producedQty) &&
            (identical(other.costPerUnit, costPerUnit) ||
                other.costPerUnit == costPerUnit) &&
            (identical(other.standardPerUnit, standardPerUnit) ||
                other.standardPerUnit == standardPerUnit) &&
            (identical(other.varianceAmount, varianceAmount) ||
                other.varianceAmount == varianceAmount) &&
            (identical(other.variancePct, variancePct) ||
                other.variancePct == variancePct) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    workOrder,
    materialCost,
    producedQty,
    costPerUnit,
    standardPerUnit,
    varianceAmount,
    variancePct,
    currency,
  );

  /// Create a copy of BatchCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchCostImplCopyWith<_$BatchCostImpl> get copyWith =>
      __$$BatchCostImplCopyWithImpl<_$BatchCostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchCostImplToJson(this);
  }
}

abstract class _BatchCost extends BatchCost {
  const factory _BatchCost({
    @JsonKey(name: 'work_order') final String workOrder,
    @JsonKey(name: 'material_cost') final double materialCost,
    @JsonKey(name: 'produced_qty') final double producedQty,
    @JsonKey(name: 'cost_per_unit') final double? costPerUnit,
    @JsonKey(name: 'standard_per_unit') final double? standardPerUnit,
    @JsonKey(name: 'variance_amount') final double? varianceAmount,
    @JsonKey(name: 'variance_pct') final double? variancePct,
    final String currency,
  }) = _$BatchCostImpl;
  const _BatchCost._() : super._();

  factory _BatchCost.fromJson(Map<String, dynamic> json) =
      _$BatchCostImpl.fromJson;

  @override
  @JsonKey(name: 'work_order')
  String get workOrder;
  @override
  @JsonKey(name: 'material_cost')
  double get materialCost;
  @override
  @JsonKey(name: 'produced_qty')
  double get producedQty;

  /// Null when nothing has been produced yet — dividing by zero produces a
  /// number that looks real and is not.
  @override
  @JsonKey(name: 'cost_per_unit')
  double? get costPerUnit;

  /// Null when the BOM carries no cost, rather than a fake zero.
  @override
  @JsonKey(name: 'standard_per_unit')
  double? get standardPerUnit;
  @override
  @JsonKey(name: 'variance_amount')
  double? get varianceAmount;
  @override
  @JsonKey(name: 'variance_pct')
  double? get variancePct;
  @override
  String get currency;

  /// Create a copy of BatchCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchCostImplCopyWith<_$BatchCostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StartBatchResult _$StartBatchResultFromJson(Map<String, dynamic> json) {
  return _StartBatchResult.fromJson(json);
}

/// @nodoc
mixin _$StartBatchResult {
  @JsonKey(name: 'work_order')
  String get workOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'material_transfer')
  String get materialTransfer => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_qty')
  double get plannedQty => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;
  @JsonKey(name: 'wip_warehouse')
  String? get wipWarehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'fg_warehouse')
  String? get fgWarehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_material_cost')
  double? get estimatedMaterialCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'jarz_sop_version')
  String? get sopVersion => throw _privateConstructorUsedError;
  List<ComponentJson> get components => throw _privateConstructorUsedError;

  /// Serializes this StartBatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartBatchResultCopyWith<StartBatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartBatchResultCopyWith<$Res> {
  factory $StartBatchResultCopyWith(
    StartBatchResult value,
    $Res Function(StartBatchResult) then,
  ) = _$StartBatchResultCopyWithImpl<$Res, StartBatchResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'material_transfer') String materialTransfer,
    String status,
    @JsonKey(name: 'planned_qty') double plannedQty,
    String uom,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,
    @JsonKey(name: 'estimated_material_cost') double? estimatedMaterialCost,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
    List<ComponentJson> components,
  });
}

/// @nodoc
class _$StartBatchResultCopyWithImpl<$Res, $Val extends StartBatchResult>
    implements $StartBatchResultCopyWith<$Res> {
  _$StartBatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? materialTransfer = null,
    Object? status = null,
    Object? plannedQty = null,
    Object? uom = null,
    Object? wipWarehouse = freezed,
    Object? fgWarehouse = freezed,
    Object? estimatedMaterialCost = freezed,
    Object? sopVersion = freezed,
    Object? components = null,
  }) {
    return _then(
      _value.copyWith(
            workOrder: null == workOrder
                ? _value.workOrder
                : workOrder // ignore: cast_nullable_to_non_nullable
                      as String,
            materialTransfer: null == materialTransfer
                ? _value.materialTransfer
                : materialTransfer // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            plannedQty: null == plannedQty
                ? _value.plannedQty
                : plannedQty // ignore: cast_nullable_to_non_nullable
                      as double,
            uom: null == uom
                ? _value.uom
                : uom // ignore: cast_nullable_to_non_nullable
                      as String,
            wipWarehouse: freezed == wipWarehouse
                ? _value.wipWarehouse
                : wipWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            fgWarehouse: freezed == fgWarehouse
                ? _value.fgWarehouse
                : fgWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedMaterialCost: freezed == estimatedMaterialCost
                ? _value.estimatedMaterialCost
                : estimatedMaterialCost // ignore: cast_nullable_to_non_nullable
                      as double?,
            sopVersion: freezed == sopVersion
                ? _value.sopVersion
                : sopVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<ComponentJson>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StartBatchResultImplCopyWith<$Res>
    implements $StartBatchResultCopyWith<$Res> {
  factory _$$StartBatchResultImplCopyWith(
    _$StartBatchResultImpl value,
    $Res Function(_$StartBatchResultImpl) then,
  ) = __$$StartBatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'material_transfer') String materialTransfer,
    String status,
    @JsonKey(name: 'planned_qty') double plannedQty,
    String uom,
    @JsonKey(name: 'wip_warehouse') String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') String? fgWarehouse,
    @JsonKey(name: 'estimated_material_cost') double? estimatedMaterialCost,
    @JsonKey(name: 'jarz_sop_version') String? sopVersion,
    List<ComponentJson> components,
  });
}

/// @nodoc
class __$$StartBatchResultImplCopyWithImpl<$Res>
    extends _$StartBatchResultCopyWithImpl<$Res, _$StartBatchResultImpl>
    implements _$$StartBatchResultImplCopyWith<$Res> {
  __$$StartBatchResultImplCopyWithImpl(
    _$StartBatchResultImpl _value,
    $Res Function(_$StartBatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? materialTransfer = null,
    Object? status = null,
    Object? plannedQty = null,
    Object? uom = null,
    Object? wipWarehouse = freezed,
    Object? fgWarehouse = freezed,
    Object? estimatedMaterialCost = freezed,
    Object? sopVersion = freezed,
    Object? components = null,
  }) {
    return _then(
      _$StartBatchResultImpl(
        workOrder: null == workOrder
            ? _value.workOrder
            : workOrder // ignore: cast_nullable_to_non_nullable
                  as String,
        materialTransfer: null == materialTransfer
            ? _value.materialTransfer
            : materialTransfer // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        plannedQty: null == plannedQty
            ? _value.plannedQty
            : plannedQty // ignore: cast_nullable_to_non_nullable
                  as double,
        uom: null == uom
            ? _value.uom
            : uom // ignore: cast_nullable_to_non_nullable
                  as String,
        wipWarehouse: freezed == wipWarehouse
            ? _value.wipWarehouse
            : wipWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        fgWarehouse: freezed == fgWarehouse
            ? _value.fgWarehouse
            : fgWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedMaterialCost: freezed == estimatedMaterialCost
            ? _value.estimatedMaterialCost
            : estimatedMaterialCost // ignore: cast_nullable_to_non_nullable
                  as double?,
        sopVersion: freezed == sopVersion
            ? _value.sopVersion
            : sopVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<ComponentJson>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StartBatchResultImpl implements _StartBatchResult {
  const _$StartBatchResultImpl({
    @JsonKey(name: 'work_order') this.workOrder = '',
    @JsonKey(name: 'material_transfer') this.materialTransfer = '',
    this.status = '',
    @JsonKey(name: 'planned_qty') this.plannedQty = 0.0,
    this.uom = '',
    @JsonKey(name: 'wip_warehouse') this.wipWarehouse,
    @JsonKey(name: 'fg_warehouse') this.fgWarehouse,
    @JsonKey(name: 'estimated_material_cost') this.estimatedMaterialCost,
    @JsonKey(name: 'jarz_sop_version') this.sopVersion,
    final List<ComponentJson> components = const <ComponentJson>[],
  }) : _components = components;

  factory _$StartBatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartBatchResultImplFromJson(json);

  @override
  @JsonKey(name: 'work_order')
  final String workOrder;
  @override
  @JsonKey(name: 'material_transfer')
  final String materialTransfer;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'planned_qty')
  final double plannedQty;
  @override
  @JsonKey()
  final String uom;
  @override
  @JsonKey(name: 'wip_warehouse')
  final String? wipWarehouse;
  @override
  @JsonKey(name: 'fg_warehouse')
  final String? fgWarehouse;
  @override
  @JsonKey(name: 'estimated_material_cost')
  final double? estimatedMaterialCost;
  @override
  @JsonKey(name: 'jarz_sop_version')
  final String? sopVersion;
  final List<ComponentJson> _components;
  @override
  @JsonKey()
  List<ComponentJson> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  @override
  String toString() {
    return 'StartBatchResult(workOrder: $workOrder, materialTransfer: $materialTransfer, status: $status, plannedQty: $plannedQty, uom: $uom, wipWarehouse: $wipWarehouse, fgWarehouse: $fgWarehouse, estimatedMaterialCost: $estimatedMaterialCost, sopVersion: $sopVersion, components: $components)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartBatchResultImpl &&
            (identical(other.workOrder, workOrder) ||
                other.workOrder == workOrder) &&
            (identical(other.materialTransfer, materialTransfer) ||
                other.materialTransfer == materialTransfer) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.plannedQty, plannedQty) ||
                other.plannedQty == plannedQty) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.wipWarehouse, wipWarehouse) ||
                other.wipWarehouse == wipWarehouse) &&
            (identical(other.fgWarehouse, fgWarehouse) ||
                other.fgWarehouse == fgWarehouse) &&
            (identical(other.estimatedMaterialCost, estimatedMaterialCost) ||
                other.estimatedMaterialCost == estimatedMaterialCost) &&
            (identical(other.sopVersion, sopVersion) ||
                other.sopVersion == sopVersion) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    workOrder,
    materialTransfer,
    status,
    plannedQty,
    uom,
    wipWarehouse,
    fgWarehouse,
    estimatedMaterialCost,
    sopVersion,
    const DeepCollectionEquality().hash(_components),
  );

  /// Create a copy of StartBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartBatchResultImplCopyWith<_$StartBatchResultImpl> get copyWith =>
      __$$StartBatchResultImplCopyWithImpl<_$StartBatchResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StartBatchResultImplToJson(this);
  }
}

abstract class _StartBatchResult implements StartBatchResult {
  const factory _StartBatchResult({
    @JsonKey(name: 'work_order') final String workOrder,
    @JsonKey(name: 'material_transfer') final String materialTransfer,
    final String status,
    @JsonKey(name: 'planned_qty') final double plannedQty,
    final String uom,
    @JsonKey(name: 'wip_warehouse') final String? wipWarehouse,
    @JsonKey(name: 'fg_warehouse') final String? fgWarehouse,
    @JsonKey(name: 'estimated_material_cost')
    final double? estimatedMaterialCost,
    @JsonKey(name: 'jarz_sop_version') final String? sopVersion,
    final List<ComponentJson> components,
  }) = _$StartBatchResultImpl;

  factory _StartBatchResult.fromJson(Map<String, dynamic> json) =
      _$StartBatchResultImpl.fromJson;

  @override
  @JsonKey(name: 'work_order')
  String get workOrder;
  @override
  @JsonKey(name: 'material_transfer')
  String get materialTransfer;
  @override
  String get status;
  @override
  @JsonKey(name: 'planned_qty')
  double get plannedQty;
  @override
  String get uom;
  @override
  @JsonKey(name: 'wip_warehouse')
  String? get wipWarehouse;
  @override
  @JsonKey(name: 'fg_warehouse')
  String? get fgWarehouse;
  @override
  @JsonKey(name: 'estimated_material_cost')
  double? get estimatedMaterialCost;
  @override
  @JsonKey(name: 'jarz_sop_version')
  String? get sopVersion;
  @override
  List<ComponentJson> get components;

  /// Create a copy of StartBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartBatchResultImplCopyWith<_$StartBatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FinishBatchResult _$FinishBatchResultFromJson(Map<String, dynamic> json) {
  return _FinishBatchResult.fromJson(json);
}

/// @nodoc
mixin _$FinishBatchResult {
  @JsonKey(name: 'work_order')
  String get workOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'manufacture_entry')
  String get manufactureEntry => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_qty')
  double get actualQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'scrap_qty')
  double get scrapQty => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'wip_leftover_qty')
  double get wipLeftoverQty => throw _privateConstructorUsedError;
  BatchCost? get cost => throw _privateConstructorUsedError;

  /// Serializes this FinishBatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinishBatchResultCopyWith<FinishBatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinishBatchResultCopyWith<$Res> {
  factory $FinishBatchResultCopyWith(
    FinishBatchResult value,
    $Res Function(FinishBatchResult) then,
  ) = _$FinishBatchResultCopyWithImpl<$Res, FinishBatchResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'manufacture_entry') String manufactureEntry,
    @JsonKey(name: 'actual_qty') double actualQty,
    @JsonKey(name: 'scrap_qty') double scrapQty,
    String status,
    @JsonKey(name: 'wip_leftover_qty') double wipLeftoverQty,
    BatchCost? cost,
  });

  $BatchCostCopyWith<$Res>? get cost;
}

/// @nodoc
class _$FinishBatchResultCopyWithImpl<$Res, $Val extends FinishBatchResult>
    implements $FinishBatchResultCopyWith<$Res> {
  _$FinishBatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? manufactureEntry = null,
    Object? actualQty = null,
    Object? scrapQty = null,
    Object? status = null,
    Object? wipLeftoverQty = null,
    Object? cost = freezed,
  }) {
    return _then(
      _value.copyWith(
            workOrder: null == workOrder
                ? _value.workOrder
                : workOrder // ignore: cast_nullable_to_non_nullable
                      as String,
            manufactureEntry: null == manufactureEntry
                ? _value.manufactureEntry
                : manufactureEntry // ignore: cast_nullable_to_non_nullable
                      as String,
            actualQty: null == actualQty
                ? _value.actualQty
                : actualQty // ignore: cast_nullable_to_non_nullable
                      as double,
            scrapQty: null == scrapQty
                ? _value.scrapQty
                : scrapQty // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            wipLeftoverQty: null == wipLeftoverQty
                ? _value.wipLeftoverQty
                : wipLeftoverQty // ignore: cast_nullable_to_non_nullable
                      as double,
            cost: freezed == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as BatchCost?,
          )
          as $Val,
    );
  }

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchCostCopyWith<$Res>? get cost {
    if (_value.cost == null) {
      return null;
    }

    return $BatchCostCopyWith<$Res>(_value.cost!, (value) {
      return _then(_value.copyWith(cost: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FinishBatchResultImplCopyWith<$Res>
    implements $FinishBatchResultCopyWith<$Res> {
  factory _$$FinishBatchResultImplCopyWith(
    _$FinishBatchResultImpl value,
    $Res Function(_$FinishBatchResultImpl) then,
  ) = __$$FinishBatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'work_order') String workOrder,
    @JsonKey(name: 'manufacture_entry') String manufactureEntry,
    @JsonKey(name: 'actual_qty') double actualQty,
    @JsonKey(name: 'scrap_qty') double scrapQty,
    String status,
    @JsonKey(name: 'wip_leftover_qty') double wipLeftoverQty,
    BatchCost? cost,
  });

  @override
  $BatchCostCopyWith<$Res>? get cost;
}

/// @nodoc
class __$$FinishBatchResultImplCopyWithImpl<$Res>
    extends _$FinishBatchResultCopyWithImpl<$Res, _$FinishBatchResultImpl>
    implements _$$FinishBatchResultImplCopyWith<$Res> {
  __$$FinishBatchResultImplCopyWithImpl(
    _$FinishBatchResultImpl _value,
    $Res Function(_$FinishBatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workOrder = null,
    Object? manufactureEntry = null,
    Object? actualQty = null,
    Object? scrapQty = null,
    Object? status = null,
    Object? wipLeftoverQty = null,
    Object? cost = freezed,
  }) {
    return _then(
      _$FinishBatchResultImpl(
        workOrder: null == workOrder
            ? _value.workOrder
            : workOrder // ignore: cast_nullable_to_non_nullable
                  as String,
        manufactureEntry: null == manufactureEntry
            ? _value.manufactureEntry
            : manufactureEntry // ignore: cast_nullable_to_non_nullable
                  as String,
        actualQty: null == actualQty
            ? _value.actualQty
            : actualQty // ignore: cast_nullable_to_non_nullable
                  as double,
        scrapQty: null == scrapQty
            ? _value.scrapQty
            : scrapQty // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        wipLeftoverQty: null == wipLeftoverQty
            ? _value.wipLeftoverQty
            : wipLeftoverQty // ignore: cast_nullable_to_non_nullable
                  as double,
        cost: freezed == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as BatchCost?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinishBatchResultImpl extends _FinishBatchResult {
  const _$FinishBatchResultImpl({
    @JsonKey(name: 'work_order') this.workOrder = '',
    @JsonKey(name: 'manufacture_entry') this.manufactureEntry = '',
    @JsonKey(name: 'actual_qty') this.actualQty = 0.0,
    @JsonKey(name: 'scrap_qty') this.scrapQty = 0.0,
    this.status = '',
    @JsonKey(name: 'wip_leftover_qty') this.wipLeftoverQty = 0.0,
    this.cost,
  }) : super._();

  factory _$FinishBatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinishBatchResultImplFromJson(json);

  @override
  @JsonKey(name: 'work_order')
  final String workOrder;
  @override
  @JsonKey(name: 'manufacture_entry')
  final String manufactureEntry;
  @override
  @JsonKey(name: 'actual_qty')
  final double actualQty;
  @override
  @JsonKey(name: 'scrap_qty')
  final double scrapQty;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'wip_leftover_qty')
  final double wipLeftoverQty;
  @override
  final BatchCost? cost;

  @override
  String toString() {
    return 'FinishBatchResult(workOrder: $workOrder, manufactureEntry: $manufactureEntry, actualQty: $actualQty, scrapQty: $scrapQty, status: $status, wipLeftoverQty: $wipLeftoverQty, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinishBatchResultImpl &&
            (identical(other.workOrder, workOrder) ||
                other.workOrder == workOrder) &&
            (identical(other.manufactureEntry, manufactureEntry) ||
                other.manufactureEntry == manufactureEntry) &&
            (identical(other.actualQty, actualQty) ||
                other.actualQty == actualQty) &&
            (identical(other.scrapQty, scrapQty) ||
                other.scrapQty == scrapQty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.wipLeftoverQty, wipLeftoverQty) ||
                other.wipLeftoverQty == wipLeftoverQty) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    workOrder,
    manufactureEntry,
    actualQty,
    scrapQty,
    status,
    wipLeftoverQty,
    cost,
  );

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinishBatchResultImplCopyWith<_$FinishBatchResultImpl> get copyWith =>
      __$$FinishBatchResultImplCopyWithImpl<_$FinishBatchResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinishBatchResultImplToJson(this);
  }
}

abstract class _FinishBatchResult extends FinishBatchResult {
  const factory _FinishBatchResult({
    @JsonKey(name: 'work_order') final String workOrder,
    @JsonKey(name: 'manufacture_entry') final String manufactureEntry,
    @JsonKey(name: 'actual_qty') final double actualQty,
    @JsonKey(name: 'scrap_qty') final double scrapQty,
    final String status,
    @JsonKey(name: 'wip_leftover_qty') final double wipLeftoverQty,
    final BatchCost? cost,
  }) = _$FinishBatchResultImpl;
  const _FinishBatchResult._() : super._();

  factory _FinishBatchResult.fromJson(Map<String, dynamic> json) =
      _$FinishBatchResultImpl.fromJson;

  @override
  @JsonKey(name: 'work_order')
  String get workOrder;
  @override
  @JsonKey(name: 'manufacture_entry')
  String get manufactureEntry;
  @override
  @JsonKey(name: 'actual_qty')
  double get actualQty;
  @override
  @JsonKey(name: 'scrap_qty')
  double get scrapQty;
  @override
  String get status;
  @override
  @JsonKey(name: 'wip_leftover_qty')
  double get wipLeftoverQty;
  @override
  BatchCost? get cost;

  /// Create a copy of FinishBatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinishBatchResultImplCopyWith<_$FinishBatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
