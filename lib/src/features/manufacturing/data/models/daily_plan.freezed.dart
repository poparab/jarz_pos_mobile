// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyPlanItem _$DailyPlanItemFromJson(Map<String, dynamic> json) {
  return _DailyPlanItem.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanItem {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String? get defaultBom => throw _privateConstructorUsedError;

  /// Mix consumed by one jar, in the mix item's stock UOM.
  @JsonKey(name: 'mix_qty_per_unit')
  double get mixQtyPerUnit => throw _privateConstructorUsedError;

  /// Jars one full batch yields — the 120-or-77 the floor already knows.
  /// Null when the flavour uses no mix at all.
  @JsonKey(name: 'jars_per_batch')
  double? get jarsPerBatch => throw _privateConstructorUsedError;
  @JsonKey(name: 'uses_mix')
  bool get usesMix => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanItemCopyWith<DailyPlanItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanItemCopyWith<$Res> {
  factory $DailyPlanItemCopyWith(
    DailyPlanItem value,
    $Res Function(DailyPlanItem) then,
  ) = _$DailyPlanItemCopyWithImpl<$Res, DailyPlanItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'default_bom') String? defaultBom,
    @JsonKey(name: 'mix_qty_per_unit') double mixQtyPerUnit,
    @JsonKey(name: 'jars_per_batch') double? jarsPerBatch,
    @JsonKey(name: 'uses_mix') bool usesMix,
  });
}

/// @nodoc
class _$DailyPlanItemCopyWithImpl<$Res, $Val extends DailyPlanItem>
    implements $DailyPlanItemCopyWith<$Res> {
  _$DailyPlanItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? defaultBom = freezed,
    Object? mixQtyPerUnit = null,
    Object? jarsPerBatch = freezed,
    Object? usesMix = null,
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
            defaultBom: freezed == defaultBom
                ? _value.defaultBom
                : defaultBom // ignore: cast_nullable_to_non_nullable
                      as String?,
            mixQtyPerUnit: null == mixQtyPerUnit
                ? _value.mixQtyPerUnit
                : mixQtyPerUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            jarsPerBatch: freezed == jarsPerBatch
                ? _value.jarsPerBatch
                : jarsPerBatch // ignore: cast_nullable_to_non_nullable
                      as double?,
            usesMix: null == usesMix
                ? _value.usesMix
                : usesMix // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanItemImplCopyWith<$Res>
    implements $DailyPlanItemCopyWith<$Res> {
  factory _$$DailyPlanItemImplCopyWith(
    _$DailyPlanItemImpl value,
    $Res Function(_$DailyPlanItemImpl) then,
  ) = __$$DailyPlanItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'default_bom') String? defaultBom,
    @JsonKey(name: 'mix_qty_per_unit') double mixQtyPerUnit,
    @JsonKey(name: 'jars_per_batch') double? jarsPerBatch,
    @JsonKey(name: 'uses_mix') bool usesMix,
  });
}

/// @nodoc
class __$$DailyPlanItemImplCopyWithImpl<$Res>
    extends _$DailyPlanItemCopyWithImpl<$Res, _$DailyPlanItemImpl>
    implements _$$DailyPlanItemImplCopyWith<$Res> {
  __$$DailyPlanItemImplCopyWithImpl(
    _$DailyPlanItemImpl _value,
    $Res Function(_$DailyPlanItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? defaultBom = freezed,
    Object? mixQtyPerUnit = null,
    Object? jarsPerBatch = freezed,
    Object? usesMix = null,
  }) {
    return _then(
      _$DailyPlanItemImpl(
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
        defaultBom: freezed == defaultBom
            ? _value.defaultBom
            : defaultBom // ignore: cast_nullable_to_non_nullable
                  as String?,
        mixQtyPerUnit: null == mixQtyPerUnit
            ? _value.mixQtyPerUnit
            : mixQtyPerUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        jarsPerBatch: freezed == jarsPerBatch
            ? _value.jarsPerBatch
            : jarsPerBatch // ignore: cast_nullable_to_non_nullable
                  as double?,
        usesMix: null == usesMix
            ? _value.usesMix
            : usesMix // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanItemImpl implements _DailyPlanItem {
  const _$DailyPlanItemImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'item_group') this.itemGroup = '',
    @JsonKey(name: 'default_bom') this.defaultBom,
    @JsonKey(name: 'mix_qty_per_unit') this.mixQtyPerUnit = 0.0,
    @JsonKey(name: 'jars_per_batch') this.jarsPerBatch,
    @JsonKey(name: 'uses_mix') this.usesMix = false,
  });

  factory _$DailyPlanItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanItemImplFromJson(json);

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
  @JsonKey(name: 'default_bom')
  final String? defaultBom;

  /// Mix consumed by one jar, in the mix item's stock UOM.
  @override
  @JsonKey(name: 'mix_qty_per_unit')
  final double mixQtyPerUnit;

  /// Jars one full batch yields — the 120-or-77 the floor already knows.
  /// Null when the flavour uses no mix at all.
  @override
  @JsonKey(name: 'jars_per_batch')
  final double? jarsPerBatch;
  @override
  @JsonKey(name: 'uses_mix')
  final bool usesMix;

  @override
  String toString() {
    return 'DailyPlanItem(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, defaultBom: $defaultBom, mixQtyPerUnit: $mixQtyPerUnit, jarsPerBatch: $jarsPerBatch, usesMix: $usesMix)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanItemImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.mixQtyPerUnit, mixQtyPerUnit) ||
                other.mixQtyPerUnit == mixQtyPerUnit) &&
            (identical(other.jarsPerBatch, jarsPerBatch) ||
                other.jarsPerBatch == jarsPerBatch) &&
            (identical(other.usesMix, usesMix) || other.usesMix == usesMix));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    itemGroup,
    defaultBom,
    mixQtyPerUnit,
    jarsPerBatch,
    usesMix,
  );

  /// Create a copy of DailyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanItemImplCopyWith<_$DailyPlanItemImpl> get copyWith =>
      __$$DailyPlanItemImplCopyWithImpl<_$DailyPlanItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanItemImplToJson(this);
  }
}

abstract class _DailyPlanItem implements DailyPlanItem {
  const factory _DailyPlanItem({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'item_group') final String itemGroup,
    @JsonKey(name: 'default_bom') final String? defaultBom,
    @JsonKey(name: 'mix_qty_per_unit') final double mixQtyPerUnit,
    @JsonKey(name: 'jars_per_batch') final double? jarsPerBatch,
    @JsonKey(name: 'uses_mix') final bool usesMix,
  }) = _$DailyPlanItemImpl;

  factory _DailyPlanItem.fromJson(Map<String, dynamic> json) =
      _$DailyPlanItemImpl.fromJson;

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
  @JsonKey(name: 'default_bom')
  String? get defaultBom;

  /// Mix consumed by one jar, in the mix item's stock UOM.
  @override
  @JsonKey(name: 'mix_qty_per_unit')
  double get mixQtyPerUnit;

  /// Jars one full batch yields — the 120-or-77 the floor already knows.
  /// Null when the flavour uses no mix at all.
  @override
  @JsonKey(name: 'jars_per_batch')
  double? get jarsPerBatch;
  @override
  @JsonKey(name: 'uses_mix')
  bool get usesMix;

  /// Create a copy of DailyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanItemImplCopyWith<_$DailyPlanItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanMix _$DailyPlanMixFromJson(Map<String, dynamic> json) {
  return _DailyPlanMix.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanMix {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String? get defaultBom => throw _privateConstructorUsedError;
  @JsonKey(name: 'batch_qty')
  double get batchQty => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanMix to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanMix
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanMixCopyWith<DailyPlanMix> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanMixCopyWith<$Res> {
  factory $DailyPlanMixCopyWith(
    DailyPlanMix value,
    $Res Function(DailyPlanMix) then,
  ) = _$DailyPlanMixCopyWithImpl<$Res, DailyPlanMix>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'default_bom') String? defaultBom,
    @JsonKey(name: 'batch_qty') double batchQty,
    String uom,
  });
}

/// @nodoc
class _$DailyPlanMixCopyWithImpl<$Res, $Val extends DailyPlanMix>
    implements $DailyPlanMixCopyWith<$Res> {
  _$DailyPlanMixCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanMix
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? defaultBom = freezed,
    Object? batchQty = null,
    Object? uom = null,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultBom: freezed == defaultBom
                ? _value.defaultBom
                : defaultBom // ignore: cast_nullable_to_non_nullable
                      as String?,
            batchQty: null == batchQty
                ? _value.batchQty
                : batchQty // ignore: cast_nullable_to_non_nullable
                      as double,
            uom: null == uom
                ? _value.uom
                : uom // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanMixImplCopyWith<$Res>
    implements $DailyPlanMixCopyWith<$Res> {
  factory _$$DailyPlanMixImplCopyWith(
    _$DailyPlanMixImpl value,
    $Res Function(_$DailyPlanMixImpl) then,
  ) = __$$DailyPlanMixImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'default_bom') String? defaultBom,
    @JsonKey(name: 'batch_qty') double batchQty,
    String uom,
  });
}

/// @nodoc
class __$$DailyPlanMixImplCopyWithImpl<$Res>
    extends _$DailyPlanMixCopyWithImpl<$Res, _$DailyPlanMixImpl>
    implements _$$DailyPlanMixImplCopyWith<$Res> {
  __$$DailyPlanMixImplCopyWithImpl(
    _$DailyPlanMixImpl _value,
    $Res Function(_$DailyPlanMixImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanMix
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? defaultBom = freezed,
    Object? batchQty = null,
    Object? uom = null,
  }) {
    return _then(
      _$DailyPlanMixImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultBom: freezed == defaultBom
            ? _value.defaultBom
            : defaultBom // ignore: cast_nullable_to_non_nullable
                  as String?,
        batchQty: null == batchQty
            ? _value.batchQty
            : batchQty // ignore: cast_nullable_to_non_nullable
                  as double,
        uom: null == uom
            ? _value.uom
            : uom // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanMixImpl implements _DailyPlanMix {
  const _$DailyPlanMixImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'default_bom') this.defaultBom,
    @JsonKey(name: 'batch_qty') this.batchQty = 0.0,
    this.uom = '',
  });

  factory _$DailyPlanMixImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanMixImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'default_bom')
  final String? defaultBom;
  @override
  @JsonKey(name: 'batch_qty')
  final double batchQty;
  @override
  @JsonKey()
  final String uom;

  @override
  String toString() {
    return 'DailyPlanMix(itemCode: $itemCode, defaultBom: $defaultBom, batchQty: $batchQty, uom: $uom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanMixImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.batchQty, batchQty) ||
                other.batchQty == batchQty) &&
            (identical(other.uom, uom) || other.uom == uom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemCode, defaultBom, batchQty, uom);

  /// Create a copy of DailyPlanMix
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanMixImplCopyWith<_$DailyPlanMixImpl> get copyWith =>
      __$$DailyPlanMixImplCopyWithImpl<_$DailyPlanMixImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanMixImplToJson(this);
  }
}

abstract class _DailyPlanMix implements DailyPlanMix {
  const factory _DailyPlanMix({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'default_bom') final String? defaultBom,
    @JsonKey(name: 'batch_qty') final double batchQty,
    final String uom,
  }) = _$DailyPlanMixImpl;

  factory _DailyPlanMix.fromJson(Map<String, dynamic> json) =
      _$DailyPlanMixImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'default_bom')
  String? get defaultBom;
  @override
  @JsonKey(name: 'batch_qty')
  double get batchQty;
  @override
  String get uom;

  /// Create a copy of DailyPlanMix
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanMixImplCopyWith<_$DailyPlanMixImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MixerRun _$MixerRunFromJson(Map<String, dynamic> json) {
  return _MixerRun.fromJson(json);
}

/// @nodoc
mixin _$MixerRun {
  double get size => throw _privateConstructorUsedError;
  RunQuality get quality => throw _privateConstructorUsedError;

  /// Serializes this MixerRun to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MixerRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MixerRunCopyWith<MixerRun> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MixerRunCopyWith<$Res> {
  factory $MixerRunCopyWith(MixerRun value, $Res Function(MixerRun) then) =
      _$MixerRunCopyWithImpl<$Res, MixerRun>;
  @useResult
  $Res call({double size, RunQuality quality});
}

/// @nodoc
class _$MixerRunCopyWithImpl<$Res, $Val extends MixerRun>
    implements $MixerRunCopyWith<$Res> {
  _$MixerRunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MixerRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? size = null, Object? quality = null}) {
    return _then(
      _value.copyWith(
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as double,
            quality: null == quality
                ? _value.quality
                : quality // ignore: cast_nullable_to_non_nullable
                      as RunQuality,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MixerRunImplCopyWith<$Res>
    implements $MixerRunCopyWith<$Res> {
  factory _$$MixerRunImplCopyWith(
    _$MixerRunImpl value,
    $Res Function(_$MixerRunImpl) then,
  ) = __$$MixerRunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double size, RunQuality quality});
}

/// @nodoc
class __$$MixerRunImplCopyWithImpl<$Res>
    extends _$MixerRunCopyWithImpl<$Res, _$MixerRunImpl>
    implements _$$MixerRunImplCopyWith<$Res> {
  __$$MixerRunImplCopyWithImpl(
    _$MixerRunImpl _value,
    $Res Function(_$MixerRunImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MixerRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? size = null, Object? quality = null}) {
    return _then(
      _$MixerRunImpl(
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as double,
        quality: null == quality
            ? _value.quality
            : quality // ignore: cast_nullable_to_non_nullable
                  as RunQuality,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MixerRunImpl implements _MixerRun {
  const _$MixerRunImpl({this.size = 0.0, this.quality = RunQuality.acceptable});

  factory _$MixerRunImpl.fromJson(Map<String, dynamic> json) =>
      _$$MixerRunImplFromJson(json);

  @override
  @JsonKey()
  final double size;
  @override
  @JsonKey()
  final RunQuality quality;

  @override
  String toString() {
    return 'MixerRun(size: $size, quality: $quality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MixerRunImpl &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.quality, quality) || other.quality == quality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, size, quality);

  /// Create a copy of MixerRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MixerRunImplCopyWith<_$MixerRunImpl> get copyWith =>
      __$$MixerRunImplCopyWithImpl<_$MixerRunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MixerRunImplToJson(this);
  }
}

abstract class _MixerRun implements MixerRun {
  const factory _MixerRun({final double size, final RunQuality quality}) =
      _$MixerRunImpl;

  factory _MixerRun.fromJson(Map<String, dynamic> json) =
      _$MixerRunImpl.fromJson;

  @override
  double get size;
  @override
  RunQuality get quality;

  /// Create a copy of MixerRun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MixerRunImplCopyWith<_$MixerRunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanPreview _$DailyPlanPreviewFromJson(Map<String, dynamic> json) {
  return _DailyPlanPreview.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanPreview {
  DailyPlanMix get mix => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_mix_qty')
  double get totalMixQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_batches')
  double get requiredBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_batches')
  double get plannedBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'run_detail')
  List<MixerRun> get runs => throw _privateConstructorUsedError;
  @JsonKey(name: 'run_count')
  int get runCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overproduction_batches')
  double get overproductionBatches => throw _privateConstructorUsedError;

  /// True when the mixer is not configured or the day exceeds what the
  /// planner will schedule — the split shown is not a usable answer.
  bool get capped => throw _privateConstructorUsedError;
  List<DailyPlanBreakdown> get breakdown => throw _privateConstructorUsedError;
  DailyPlanMaterials? get materials => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanPreview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanPreviewCopyWith<DailyPlanPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanPreviewCopyWith<$Res> {
  factory $DailyPlanPreviewCopyWith(
    DailyPlanPreview value,
    $Res Function(DailyPlanPreview) then,
  ) = _$DailyPlanPreviewCopyWithImpl<$Res, DailyPlanPreview>;
  @useResult
  $Res call({
    DailyPlanMix mix,
    @JsonKey(name: 'total_mix_qty') double totalMixQty,
    @JsonKey(name: 'required_batches') double requiredBatches,
    @JsonKey(name: 'planned_batches') double plannedBatches,
    @JsonKey(name: 'run_detail') List<MixerRun> runs,
    @JsonKey(name: 'run_count') int runCount,
    @JsonKey(name: 'overproduction_batches') double overproductionBatches,
    bool capped,
    List<DailyPlanBreakdown> breakdown,
    DailyPlanMaterials? materials,
  });

  $DailyPlanMixCopyWith<$Res> get mix;
  $DailyPlanMaterialsCopyWith<$Res>? get materials;
}

/// @nodoc
class _$DailyPlanPreviewCopyWithImpl<$Res, $Val extends DailyPlanPreview>
    implements $DailyPlanPreviewCopyWith<$Res> {
  _$DailyPlanPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mix = null,
    Object? totalMixQty = null,
    Object? requiredBatches = null,
    Object? plannedBatches = null,
    Object? runs = null,
    Object? runCount = null,
    Object? overproductionBatches = null,
    Object? capped = null,
    Object? breakdown = null,
    Object? materials = freezed,
  }) {
    return _then(
      _value.copyWith(
            mix: null == mix
                ? _value.mix
                : mix // ignore: cast_nullable_to_non_nullable
                      as DailyPlanMix,
            totalMixQty: null == totalMixQty
                ? _value.totalMixQty
                : totalMixQty // ignore: cast_nullable_to_non_nullable
                      as double,
            requiredBatches: null == requiredBatches
                ? _value.requiredBatches
                : requiredBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            plannedBatches: null == plannedBatches
                ? _value.plannedBatches
                : plannedBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            runs: null == runs
                ? _value.runs
                : runs // ignore: cast_nullable_to_non_nullable
                      as List<MixerRun>,
            runCount: null == runCount
                ? _value.runCount
                : runCount // ignore: cast_nullable_to_non_nullable
                      as int,
            overproductionBatches: null == overproductionBatches
                ? _value.overproductionBatches
                : overproductionBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            capped: null == capped
                ? _value.capped
                : capped // ignore: cast_nullable_to_non_nullable
                      as bool,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as List<DailyPlanBreakdown>,
            materials: freezed == materials
                ? _value.materials
                : materials // ignore: cast_nullable_to_non_nullable
                      as DailyPlanMaterials?,
          )
          as $Val,
    );
  }

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyPlanMixCopyWith<$Res> get mix {
    return $DailyPlanMixCopyWith<$Res>(_value.mix, (value) {
      return _then(_value.copyWith(mix: value) as $Val);
    });
  }

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyPlanMaterialsCopyWith<$Res>? get materials {
    if (_value.materials == null) {
      return null;
    }

    return $DailyPlanMaterialsCopyWith<$Res>(_value.materials!, (value) {
      return _then(_value.copyWith(materials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyPlanPreviewImplCopyWith<$Res>
    implements $DailyPlanPreviewCopyWith<$Res> {
  factory _$$DailyPlanPreviewImplCopyWith(
    _$DailyPlanPreviewImpl value,
    $Res Function(_$DailyPlanPreviewImpl) then,
  ) = __$$DailyPlanPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DailyPlanMix mix,
    @JsonKey(name: 'total_mix_qty') double totalMixQty,
    @JsonKey(name: 'required_batches') double requiredBatches,
    @JsonKey(name: 'planned_batches') double plannedBatches,
    @JsonKey(name: 'run_detail') List<MixerRun> runs,
    @JsonKey(name: 'run_count') int runCount,
    @JsonKey(name: 'overproduction_batches') double overproductionBatches,
    bool capped,
    List<DailyPlanBreakdown> breakdown,
    DailyPlanMaterials? materials,
  });

  @override
  $DailyPlanMixCopyWith<$Res> get mix;
  @override
  $DailyPlanMaterialsCopyWith<$Res>? get materials;
}

/// @nodoc
class __$$DailyPlanPreviewImplCopyWithImpl<$Res>
    extends _$DailyPlanPreviewCopyWithImpl<$Res, _$DailyPlanPreviewImpl>
    implements _$$DailyPlanPreviewImplCopyWith<$Res> {
  __$$DailyPlanPreviewImplCopyWithImpl(
    _$DailyPlanPreviewImpl _value,
    $Res Function(_$DailyPlanPreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mix = null,
    Object? totalMixQty = null,
    Object? requiredBatches = null,
    Object? plannedBatches = null,
    Object? runs = null,
    Object? runCount = null,
    Object? overproductionBatches = null,
    Object? capped = null,
    Object? breakdown = null,
    Object? materials = freezed,
  }) {
    return _then(
      _$DailyPlanPreviewImpl(
        mix: null == mix
            ? _value.mix
            : mix // ignore: cast_nullable_to_non_nullable
                  as DailyPlanMix,
        totalMixQty: null == totalMixQty
            ? _value.totalMixQty
            : totalMixQty // ignore: cast_nullable_to_non_nullable
                  as double,
        requiredBatches: null == requiredBatches
            ? _value.requiredBatches
            : requiredBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        plannedBatches: null == plannedBatches
            ? _value.plannedBatches
            : plannedBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        runs: null == runs
            ? _value._runs
            : runs // ignore: cast_nullable_to_non_nullable
                  as List<MixerRun>,
        runCount: null == runCount
            ? _value.runCount
            : runCount // ignore: cast_nullable_to_non_nullable
                  as int,
        overproductionBatches: null == overproductionBatches
            ? _value.overproductionBatches
            : overproductionBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        capped: null == capped
            ? _value.capped
            : capped // ignore: cast_nullable_to_non_nullable
                  as bool,
        breakdown: null == breakdown
            ? _value._breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as List<DailyPlanBreakdown>,
        materials: freezed == materials
            ? _value.materials
            : materials // ignore: cast_nullable_to_non_nullable
                  as DailyPlanMaterials?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanPreviewImpl implements _DailyPlanPreview {
  const _$DailyPlanPreviewImpl({
    this.mix = const DailyPlanMix(),
    @JsonKey(name: 'total_mix_qty') this.totalMixQty = 0.0,
    @JsonKey(name: 'required_batches') this.requiredBatches = 0.0,
    @JsonKey(name: 'planned_batches') this.plannedBatches = 0.0,
    @JsonKey(name: 'run_detail') final List<MixerRun> runs = const <MixerRun>[],
    @JsonKey(name: 'run_count') this.runCount = 0,
    @JsonKey(name: 'overproduction_batches') this.overproductionBatches = 0.0,
    this.capped = false,
    final List<DailyPlanBreakdown> breakdown = const <DailyPlanBreakdown>[],
    this.materials,
  }) : _runs = runs,
       _breakdown = breakdown;

  factory _$DailyPlanPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanPreviewImplFromJson(json);

  @override
  @JsonKey()
  final DailyPlanMix mix;
  @override
  @JsonKey(name: 'total_mix_qty')
  final double totalMixQty;
  @override
  @JsonKey(name: 'required_batches')
  final double requiredBatches;
  @override
  @JsonKey(name: 'planned_batches')
  final double plannedBatches;
  final List<MixerRun> _runs;
  @override
  @JsonKey(name: 'run_detail')
  List<MixerRun> get runs {
    if (_runs is EqualUnmodifiableListView) return _runs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_runs);
  }

  @override
  @JsonKey(name: 'run_count')
  final int runCount;
  @override
  @JsonKey(name: 'overproduction_batches')
  final double overproductionBatches;

  /// True when the mixer is not configured or the day exceeds what the
  /// planner will schedule — the split shown is not a usable answer.
  @override
  @JsonKey()
  final bool capped;
  final List<DailyPlanBreakdown> _breakdown;
  @override
  @JsonKey()
  List<DailyPlanBreakdown> get breakdown {
    if (_breakdown is EqualUnmodifiableListView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakdown);
  }

  @override
  final DailyPlanMaterials? materials;

  @override
  String toString() {
    return 'DailyPlanPreview(mix: $mix, totalMixQty: $totalMixQty, requiredBatches: $requiredBatches, plannedBatches: $plannedBatches, runs: $runs, runCount: $runCount, overproductionBatches: $overproductionBatches, capped: $capped, breakdown: $breakdown, materials: $materials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanPreviewImpl &&
            (identical(other.mix, mix) || other.mix == mix) &&
            (identical(other.totalMixQty, totalMixQty) ||
                other.totalMixQty == totalMixQty) &&
            (identical(other.requiredBatches, requiredBatches) ||
                other.requiredBatches == requiredBatches) &&
            (identical(other.plannedBatches, plannedBatches) ||
                other.plannedBatches == plannedBatches) &&
            const DeepCollectionEquality().equals(other._runs, _runs) &&
            (identical(other.runCount, runCount) ||
                other.runCount == runCount) &&
            (identical(other.overproductionBatches, overproductionBatches) ||
                other.overproductionBatches == overproductionBatches) &&
            (identical(other.capped, capped) || other.capped == capped) &&
            const DeepCollectionEquality().equals(
              other._breakdown,
              _breakdown,
            ) &&
            (identical(other.materials, materials) ||
                other.materials == materials));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mix,
    totalMixQty,
    requiredBatches,
    plannedBatches,
    const DeepCollectionEquality().hash(_runs),
    runCount,
    overproductionBatches,
    capped,
    const DeepCollectionEquality().hash(_breakdown),
    materials,
  );

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanPreviewImplCopyWith<_$DailyPlanPreviewImpl> get copyWith =>
      __$$DailyPlanPreviewImplCopyWithImpl<_$DailyPlanPreviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanPreviewImplToJson(this);
  }
}

abstract class _DailyPlanPreview implements DailyPlanPreview {
  const factory _DailyPlanPreview({
    final DailyPlanMix mix,
    @JsonKey(name: 'total_mix_qty') final double totalMixQty,
    @JsonKey(name: 'required_batches') final double requiredBatches,
    @JsonKey(name: 'planned_batches') final double plannedBatches,
    @JsonKey(name: 'run_detail') final List<MixerRun> runs,
    @JsonKey(name: 'run_count') final int runCount,
    @JsonKey(name: 'overproduction_batches') final double overproductionBatches,
    final bool capped,
    final List<DailyPlanBreakdown> breakdown,
    final DailyPlanMaterials? materials,
  }) = _$DailyPlanPreviewImpl;

  factory _DailyPlanPreview.fromJson(Map<String, dynamic> json) =
      _$DailyPlanPreviewImpl.fromJson;

  @override
  DailyPlanMix get mix;
  @override
  @JsonKey(name: 'total_mix_qty')
  double get totalMixQty;
  @override
  @JsonKey(name: 'required_batches')
  double get requiredBatches;
  @override
  @JsonKey(name: 'planned_batches')
  double get plannedBatches;
  @override
  @JsonKey(name: 'run_detail')
  List<MixerRun> get runs;
  @override
  @JsonKey(name: 'run_count')
  int get runCount;
  @override
  @JsonKey(name: 'overproduction_batches')
  double get overproductionBatches;

  /// True when the mixer is not configured or the day exceeds what the
  /// planner will schedule — the split shown is not a usable answer.
  @override
  bool get capped;
  @override
  List<DailyPlanBreakdown> get breakdown;
  @override
  DailyPlanMaterials? get materials;

  /// Create a copy of DailyPlanPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanPreviewImplCopyWith<_$DailyPlanPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanBreakdown _$DailyPlanBreakdownFromJson(Map<String, dynamic> json) {
  return _DailyPlanBreakdown.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanBreakdown {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_qty')
  double get plannedQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_qty')
  double get mixQty => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanBreakdownCopyWith<DailyPlanBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanBreakdownCopyWith<$Res> {
  factory $DailyPlanBreakdownCopyWith(
    DailyPlanBreakdown value,
    $Res Function(DailyPlanBreakdown) then,
  ) = _$DailyPlanBreakdownCopyWithImpl<$Res, DailyPlanBreakdown>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'planned_qty') double plannedQty,
    @JsonKey(name: 'mix_qty') double mixQty,
  });
}

/// @nodoc
class _$DailyPlanBreakdownCopyWithImpl<$Res, $Val extends DailyPlanBreakdown>
    implements $DailyPlanBreakdownCopyWith<$Res> {
  _$DailyPlanBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? plannedQty = null,
    Object? mixQty = null,
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
            plannedQty: null == plannedQty
                ? _value.plannedQty
                : plannedQty // ignore: cast_nullable_to_non_nullable
                      as double,
            mixQty: null == mixQty
                ? _value.mixQty
                : mixQty // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanBreakdownImplCopyWith<$Res>
    implements $DailyPlanBreakdownCopyWith<$Res> {
  factory _$$DailyPlanBreakdownImplCopyWith(
    _$DailyPlanBreakdownImpl value,
    $Res Function(_$DailyPlanBreakdownImpl) then,
  ) = __$$DailyPlanBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'planned_qty') double plannedQty,
    @JsonKey(name: 'mix_qty') double mixQty,
  });
}

/// @nodoc
class __$$DailyPlanBreakdownImplCopyWithImpl<$Res>
    extends _$DailyPlanBreakdownCopyWithImpl<$Res, _$DailyPlanBreakdownImpl>
    implements _$$DailyPlanBreakdownImplCopyWith<$Res> {
  __$$DailyPlanBreakdownImplCopyWithImpl(
    _$DailyPlanBreakdownImpl _value,
    $Res Function(_$DailyPlanBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? plannedQty = null,
    Object? mixQty = null,
  }) {
    return _then(
      _$DailyPlanBreakdownImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        plannedQty: null == plannedQty
            ? _value.plannedQty
            : plannedQty // ignore: cast_nullable_to_non_nullable
                  as double,
        mixQty: null == mixQty
            ? _value.mixQty
            : mixQty // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanBreakdownImpl implements _DailyPlanBreakdown {
  const _$DailyPlanBreakdownImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'planned_qty') this.plannedQty = 0.0,
    @JsonKey(name: 'mix_qty') this.mixQty = 0.0,
  });

  factory _$DailyPlanBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanBreakdownImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'planned_qty')
  final double plannedQty;
  @override
  @JsonKey(name: 'mix_qty')
  final double mixQty;

  @override
  String toString() {
    return 'DailyPlanBreakdown(itemCode: $itemCode, itemName: $itemName, plannedQty: $plannedQty, mixQty: $mixQty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanBreakdownImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.plannedQty, plannedQty) ||
                other.plannedQty == plannedQty) &&
            (identical(other.mixQty, mixQty) || other.mixQty == mixQty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemCode, itemName, plannedQty, mixQty);

  /// Create a copy of DailyPlanBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanBreakdownImplCopyWith<_$DailyPlanBreakdownImpl> get copyWith =>
      __$$DailyPlanBreakdownImplCopyWithImpl<_$DailyPlanBreakdownImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanBreakdownImplToJson(this);
  }
}

abstract class _DailyPlanBreakdown implements DailyPlanBreakdown {
  const factory _DailyPlanBreakdown({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'planned_qty') final double plannedQty,
    @JsonKey(name: 'mix_qty') final double mixQty,
  }) = _$DailyPlanBreakdownImpl;

  factory _DailyPlanBreakdown.fromJson(Map<String, dynamic> json) =
      _$DailyPlanBreakdownImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'planned_qty')
  double get plannedQty;
  @override
  @JsonKey(name: 'mix_qty')
  double get mixQty;

  /// Create a copy of DailyPlanBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanBreakdownImplCopyWith<_$DailyPlanBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanMaterials _$DailyPlanMaterialsFromJson(Map<String, dynamic> json) {
  return _DailyPlanMaterials.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanMaterials {
  bool get ok => throw _privateConstructorUsedError;
  List<MaterialShortage> get shortages => throw _privateConstructorUsedError;

  /// Set when the roll-up could not be computed, so an empty shortage list
  /// reads as "not checked" rather than "all clear".
  bool get unavailable => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanMaterials to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanMaterials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanMaterialsCopyWith<DailyPlanMaterials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanMaterialsCopyWith<$Res> {
  factory $DailyPlanMaterialsCopyWith(
    DailyPlanMaterials value,
    $Res Function(DailyPlanMaterials) then,
  ) = _$DailyPlanMaterialsCopyWithImpl<$Res, DailyPlanMaterials>;
  @useResult
  $Res call({bool ok, List<MaterialShortage> shortages, bool unavailable});
}

/// @nodoc
class _$DailyPlanMaterialsCopyWithImpl<$Res, $Val extends DailyPlanMaterials>
    implements $DailyPlanMaterialsCopyWith<$Res> {
  _$DailyPlanMaterialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanMaterials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ok = null,
    Object? shortages = null,
    Object? unavailable = null,
  }) {
    return _then(
      _value.copyWith(
            ok: null == ok
                ? _value.ok
                : ok // ignore: cast_nullable_to_non_nullable
                      as bool,
            shortages: null == shortages
                ? _value.shortages
                : shortages // ignore: cast_nullable_to_non_nullable
                      as List<MaterialShortage>,
            unavailable: null == unavailable
                ? _value.unavailable
                : unavailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanMaterialsImplCopyWith<$Res>
    implements $DailyPlanMaterialsCopyWith<$Res> {
  factory _$$DailyPlanMaterialsImplCopyWith(
    _$DailyPlanMaterialsImpl value,
    $Res Function(_$DailyPlanMaterialsImpl) then,
  ) = __$$DailyPlanMaterialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool ok, List<MaterialShortage> shortages, bool unavailable});
}

/// @nodoc
class __$$DailyPlanMaterialsImplCopyWithImpl<$Res>
    extends _$DailyPlanMaterialsCopyWithImpl<$Res, _$DailyPlanMaterialsImpl>
    implements _$$DailyPlanMaterialsImplCopyWith<$Res> {
  __$$DailyPlanMaterialsImplCopyWithImpl(
    _$DailyPlanMaterialsImpl _value,
    $Res Function(_$DailyPlanMaterialsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanMaterials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ok = null,
    Object? shortages = null,
    Object? unavailable = null,
  }) {
    return _then(
      _$DailyPlanMaterialsImpl(
        ok: null == ok
            ? _value.ok
            : ok // ignore: cast_nullable_to_non_nullable
                  as bool,
        shortages: null == shortages
            ? _value._shortages
            : shortages // ignore: cast_nullable_to_non_nullable
                  as List<MaterialShortage>,
        unavailable: null == unavailable
            ? _value.unavailable
            : unavailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanMaterialsImpl implements _DailyPlanMaterials {
  const _$DailyPlanMaterialsImpl({
    this.ok = true,
    final List<MaterialShortage> shortages = const <MaterialShortage>[],
    this.unavailable = false,
  }) : _shortages = shortages;

  factory _$DailyPlanMaterialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanMaterialsImplFromJson(json);

  @override
  @JsonKey()
  final bool ok;
  final List<MaterialShortage> _shortages;
  @override
  @JsonKey()
  List<MaterialShortage> get shortages {
    if (_shortages is EqualUnmodifiableListView) return _shortages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shortages);
  }

  /// Set when the roll-up could not be computed, so an empty shortage list
  /// reads as "not checked" rather than "all clear".
  @override
  @JsonKey()
  final bool unavailable;

  @override
  String toString() {
    return 'DailyPlanMaterials(ok: $ok, shortages: $shortages, unavailable: $unavailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanMaterialsImpl &&
            (identical(other.ok, ok) || other.ok == ok) &&
            const DeepCollectionEquality().equals(
              other._shortages,
              _shortages,
            ) &&
            (identical(other.unavailable, unavailable) ||
                other.unavailable == unavailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ok,
    const DeepCollectionEquality().hash(_shortages),
    unavailable,
  );

  /// Create a copy of DailyPlanMaterials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanMaterialsImplCopyWith<_$DailyPlanMaterialsImpl> get copyWith =>
      __$$DailyPlanMaterialsImplCopyWithImpl<_$DailyPlanMaterialsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanMaterialsImplToJson(this);
  }
}

abstract class _DailyPlanMaterials implements DailyPlanMaterials {
  const factory _DailyPlanMaterials({
    final bool ok,
    final List<MaterialShortage> shortages,
    final bool unavailable,
  }) = _$DailyPlanMaterialsImpl;

  factory _DailyPlanMaterials.fromJson(Map<String, dynamic> json) =
      _$DailyPlanMaterialsImpl.fromJson;

  @override
  bool get ok;
  @override
  List<MaterialShortage> get shortages;

  /// Set when the roll-up could not be computed, so an empty shortage list
  /// reads as "not checked" rather than "all clear".
  @override
  bool get unavailable;

  /// Create a copy of DailyPlanMaterials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanMaterialsImplCopyWith<_$DailyPlanMaterialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MaterialShortage _$MaterialShortageFromJson(Map<String, dynamic> json) {
  return _MaterialShortage.fromJson(json);
}

/// @nodoc
mixin _$MaterialShortage {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_qty')
  double get requiredQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double get availableQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'missing_qty')
  double get missingQty => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this MaterialShortage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaterialShortage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaterialShortageCopyWith<MaterialShortage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaterialShortageCopyWith<$Res> {
  factory $MaterialShortageCopyWith(
    MaterialShortage value,
    $Res Function(MaterialShortage) then,
  ) = _$MaterialShortageCopyWithImpl<$Res, MaterialShortage>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    @JsonKey(name: 'missing_qty') double missingQty,
    String reason,
  });
}

/// @nodoc
class _$MaterialShortageCopyWithImpl<$Res, $Val extends MaterialShortage>
    implements $MaterialShortageCopyWith<$Res> {
  _$MaterialShortageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaterialShortage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? requiredQty = null,
    Object? availableQty = null,
    Object? missingQty = null,
    Object? reason = null,
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
            missingQty: null == missingQty
                ? _value.missingQty
                : missingQty // ignore: cast_nullable_to_non_nullable
                      as double,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaterialShortageImplCopyWith<$Res>
    implements $MaterialShortageCopyWith<$Res> {
  factory _$$MaterialShortageImplCopyWith(
    _$MaterialShortageImpl value,
    $Res Function(_$MaterialShortageImpl) then,
  ) = __$$MaterialShortageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    @JsonKey(name: 'missing_qty') double missingQty,
    String reason,
  });
}

/// @nodoc
class __$$MaterialShortageImplCopyWithImpl<$Res>
    extends _$MaterialShortageCopyWithImpl<$Res, _$MaterialShortageImpl>
    implements _$$MaterialShortageImplCopyWith<$Res> {
  __$$MaterialShortageImplCopyWithImpl(
    _$MaterialShortageImpl _value,
    $Res Function(_$MaterialShortageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaterialShortage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? requiredQty = null,
    Object? availableQty = null,
    Object? missingQty = null,
    Object? reason = null,
  }) {
    return _then(
      _$MaterialShortageImpl(
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
        missingQty: null == missingQty
            ? _value.missingQty
            : missingQty // ignore: cast_nullable_to_non_nullable
                  as double,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaterialShortageImpl implements _MaterialShortage {
  const _$MaterialShortageImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.uom = '',
    @JsonKey(name: 'required_qty') this.requiredQty = 0.0,
    @JsonKey(name: 'available_qty') this.availableQty = 0.0,
    @JsonKey(name: 'missing_qty') this.missingQty = 0.0,
    this.reason = '',
  });

  factory _$MaterialShortageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialShortageImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey()
  final String uom;
  @override
  @JsonKey(name: 'required_qty')
  final double requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  final double availableQty;
  @override
  @JsonKey(name: 'missing_qty')
  final double missingQty;
  @override
  @JsonKey()
  final String reason;

  @override
  String toString() {
    return 'MaterialShortage(itemCode: $itemCode, itemName: $itemName, uom: $uom, requiredQty: $requiredQty, availableQty: $availableQty, missingQty: $missingQty, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialShortageImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.requiredQty, requiredQty) ||
                other.requiredQty == requiredQty) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty) &&
            (identical(other.missingQty, missingQty) ||
                other.missingQty == missingQty) &&
            (identical(other.reason, reason) || other.reason == reason));
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
    missingQty,
    reason,
  );

  /// Create a copy of MaterialShortage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialShortageImplCopyWith<_$MaterialShortageImpl> get copyWith =>
      __$$MaterialShortageImplCopyWithImpl<_$MaterialShortageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaterialShortageImplToJson(this);
  }
}

abstract class _MaterialShortage implements MaterialShortage {
  const factory _MaterialShortage({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String uom,
    @JsonKey(name: 'required_qty') final double requiredQty,
    @JsonKey(name: 'available_qty') final double availableQty,
    @JsonKey(name: 'missing_qty') final double missingQty,
    final String reason,
  }) = _$MaterialShortageImpl;

  factory _MaterialShortage.fromJson(Map<String, dynamic> json) =
      _$MaterialShortageImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String get uom;
  @override
  @JsonKey(name: 'required_qty')
  double get requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  double get availableQty;
  @override
  @JsonKey(name: 'missing_qty')
  double get missingQty;
  @override
  String get reason;

  /// Create a copy of MaterialShortage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialShortageImplCopyWith<_$MaterialShortageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlan _$DailyPlanFromJson(Map<String, dynamic> json) {
  return _DailyPlan.fromJson(json);
}

/// @nodoc
mixin _$DailyPlan {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_date')
  String get planDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_item')
  String get mixItem => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_batch_qty')
  double get mixBatchQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_uom')
  String get mixUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_mix_qty')
  double get totalMixQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_batches')
  double get requiredBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_batches')
  double get plannedBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'mixer_runs')
  String get mixerRuns => throw _privateConstructorUsedError;
  @JsonKey(name: 'run_count')
  int get runCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overproduction_batches')
  double get overproductionBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'overproduction_note')
  String? get overproductionNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_batches_run')
  double get actualBatchesRun => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_planned_units')
  int get totalPlannedUnits => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_actual_units')
  int get totalActualUnits => throw _privateConstructorUsedError;
  @JsonKey(name: 'realised_units_per_batch')
  double get realisedUnitsPerBatch => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<DailyPlanLine> get lines => throw _privateConstructorUsedError;

  /// Serializes this DailyPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanCopyWith<DailyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanCopyWith<$Res> {
  factory $DailyPlanCopyWith(DailyPlan value, $Res Function(DailyPlan) then) =
      _$DailyPlanCopyWithImpl<$Res, DailyPlan>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'plan_date') String planDate,
    String status,
    @JsonKey(name: 'mix_item') String mixItem,
    @JsonKey(name: 'mix_batch_qty') double mixBatchQty,
    @JsonKey(name: 'mix_uom') String mixUom,
    @JsonKey(name: 'total_mix_qty') double totalMixQty,
    @JsonKey(name: 'required_batches') double requiredBatches,
    @JsonKey(name: 'planned_batches') double plannedBatches,
    @JsonKey(name: 'mixer_runs') String mixerRuns,
    @JsonKey(name: 'run_count') int runCount,
    @JsonKey(name: 'overproduction_batches') double overproductionBatches,
    @JsonKey(name: 'overproduction_note') String? overproductionNote,
    @JsonKey(name: 'actual_batches_run') double actualBatchesRun,
    @JsonKey(name: 'total_planned_units') int totalPlannedUnits,
    @JsonKey(name: 'total_actual_units') int totalActualUnits,
    @JsonKey(name: 'realised_units_per_batch') double realisedUnitsPerBatch,
    String? notes,
    List<DailyPlanLine> lines,
  });
}

/// @nodoc
class _$DailyPlanCopyWithImpl<$Res, $Val extends DailyPlan>
    implements $DailyPlanCopyWith<$Res> {
  _$DailyPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? planDate = null,
    Object? status = null,
    Object? mixItem = null,
    Object? mixBatchQty = null,
    Object? mixUom = null,
    Object? totalMixQty = null,
    Object? requiredBatches = null,
    Object? plannedBatches = null,
    Object? mixerRuns = null,
    Object? runCount = null,
    Object? overproductionBatches = null,
    Object? overproductionNote = freezed,
    Object? actualBatchesRun = null,
    Object? totalPlannedUnits = null,
    Object? totalActualUnits = null,
    Object? realisedUnitsPerBatch = null,
    Object? notes = freezed,
    Object? lines = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            mixItem: null == mixItem
                ? _value.mixItem
                : mixItem // ignore: cast_nullable_to_non_nullable
                      as String,
            mixBatchQty: null == mixBatchQty
                ? _value.mixBatchQty
                : mixBatchQty // ignore: cast_nullable_to_non_nullable
                      as double,
            mixUom: null == mixUom
                ? _value.mixUom
                : mixUom // ignore: cast_nullable_to_non_nullable
                      as String,
            totalMixQty: null == totalMixQty
                ? _value.totalMixQty
                : totalMixQty // ignore: cast_nullable_to_non_nullable
                      as double,
            requiredBatches: null == requiredBatches
                ? _value.requiredBatches
                : requiredBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            plannedBatches: null == plannedBatches
                ? _value.plannedBatches
                : plannedBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            mixerRuns: null == mixerRuns
                ? _value.mixerRuns
                : mixerRuns // ignore: cast_nullable_to_non_nullable
                      as String,
            runCount: null == runCount
                ? _value.runCount
                : runCount // ignore: cast_nullable_to_non_nullable
                      as int,
            overproductionBatches: null == overproductionBatches
                ? _value.overproductionBatches
                : overproductionBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            overproductionNote: freezed == overproductionNote
                ? _value.overproductionNote
                : overproductionNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            actualBatchesRun: null == actualBatchesRun
                ? _value.actualBatchesRun
                : actualBatchesRun // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPlannedUnits: null == totalPlannedUnits
                ? _value.totalPlannedUnits
                : totalPlannedUnits // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActualUnits: null == totalActualUnits
                ? _value.totalActualUnits
                : totalActualUnits // ignore: cast_nullable_to_non_nullable
                      as int,
            realisedUnitsPerBatch: null == realisedUnitsPerBatch
                ? _value.realisedUnitsPerBatch
                : realisedUnitsPerBatch // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<DailyPlanLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanImplCopyWith<$Res>
    implements $DailyPlanCopyWith<$Res> {
  factory _$$DailyPlanImplCopyWith(
    _$DailyPlanImpl value,
    $Res Function(_$DailyPlanImpl) then,
  ) = __$$DailyPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'plan_date') String planDate,
    String status,
    @JsonKey(name: 'mix_item') String mixItem,
    @JsonKey(name: 'mix_batch_qty') double mixBatchQty,
    @JsonKey(name: 'mix_uom') String mixUom,
    @JsonKey(name: 'total_mix_qty') double totalMixQty,
    @JsonKey(name: 'required_batches') double requiredBatches,
    @JsonKey(name: 'planned_batches') double plannedBatches,
    @JsonKey(name: 'mixer_runs') String mixerRuns,
    @JsonKey(name: 'run_count') int runCount,
    @JsonKey(name: 'overproduction_batches') double overproductionBatches,
    @JsonKey(name: 'overproduction_note') String? overproductionNote,
    @JsonKey(name: 'actual_batches_run') double actualBatchesRun,
    @JsonKey(name: 'total_planned_units') int totalPlannedUnits,
    @JsonKey(name: 'total_actual_units') int totalActualUnits,
    @JsonKey(name: 'realised_units_per_batch') double realisedUnitsPerBatch,
    String? notes,
    List<DailyPlanLine> lines,
  });
}

/// @nodoc
class __$$DailyPlanImplCopyWithImpl<$Res>
    extends _$DailyPlanCopyWithImpl<$Res, _$DailyPlanImpl>
    implements _$$DailyPlanImplCopyWith<$Res> {
  __$$DailyPlanImplCopyWithImpl(
    _$DailyPlanImpl _value,
    $Res Function(_$DailyPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? planDate = null,
    Object? status = null,
    Object? mixItem = null,
    Object? mixBatchQty = null,
    Object? mixUom = null,
    Object? totalMixQty = null,
    Object? requiredBatches = null,
    Object? plannedBatches = null,
    Object? mixerRuns = null,
    Object? runCount = null,
    Object? overproductionBatches = null,
    Object? overproductionNote = freezed,
    Object? actualBatchesRun = null,
    Object? totalPlannedUnits = null,
    Object? totalActualUnits = null,
    Object? realisedUnitsPerBatch = null,
    Object? notes = freezed,
    Object? lines = null,
  }) {
    return _then(
      _$DailyPlanImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        mixItem: null == mixItem
            ? _value.mixItem
            : mixItem // ignore: cast_nullable_to_non_nullable
                  as String,
        mixBatchQty: null == mixBatchQty
            ? _value.mixBatchQty
            : mixBatchQty // ignore: cast_nullable_to_non_nullable
                  as double,
        mixUom: null == mixUom
            ? _value.mixUom
            : mixUom // ignore: cast_nullable_to_non_nullable
                  as String,
        totalMixQty: null == totalMixQty
            ? _value.totalMixQty
            : totalMixQty // ignore: cast_nullable_to_non_nullable
                  as double,
        requiredBatches: null == requiredBatches
            ? _value.requiredBatches
            : requiredBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        plannedBatches: null == plannedBatches
            ? _value.plannedBatches
            : plannedBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        mixerRuns: null == mixerRuns
            ? _value.mixerRuns
            : mixerRuns // ignore: cast_nullable_to_non_nullable
                  as String,
        runCount: null == runCount
            ? _value.runCount
            : runCount // ignore: cast_nullable_to_non_nullable
                  as int,
        overproductionBatches: null == overproductionBatches
            ? _value.overproductionBatches
            : overproductionBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        overproductionNote: freezed == overproductionNote
            ? _value.overproductionNote
            : overproductionNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        actualBatchesRun: null == actualBatchesRun
            ? _value.actualBatchesRun
            : actualBatchesRun // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPlannedUnits: null == totalPlannedUnits
            ? _value.totalPlannedUnits
            : totalPlannedUnits // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActualUnits: null == totalActualUnits
            ? _value.totalActualUnits
            : totalActualUnits // ignore: cast_nullable_to_non_nullable
                  as int,
        realisedUnitsPerBatch: null == realisedUnitsPerBatch
            ? _value.realisedUnitsPerBatch
            : realisedUnitsPerBatch // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<DailyPlanLine>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanImpl extends _DailyPlan {
  const _$DailyPlanImpl({
    this.name = '',
    @JsonKey(name: 'plan_date') this.planDate = '',
    this.status = 'Draft',
    @JsonKey(name: 'mix_item') this.mixItem = '',
    @JsonKey(name: 'mix_batch_qty') this.mixBatchQty = 0.0,
    @JsonKey(name: 'mix_uom') this.mixUom = '',
    @JsonKey(name: 'total_mix_qty') this.totalMixQty = 0.0,
    @JsonKey(name: 'required_batches') this.requiredBatches = 0.0,
    @JsonKey(name: 'planned_batches') this.plannedBatches = 0.0,
    @JsonKey(name: 'mixer_runs') this.mixerRuns = '',
    @JsonKey(name: 'run_count') this.runCount = 0,
    @JsonKey(name: 'overproduction_batches') this.overproductionBatches = 0.0,
    @JsonKey(name: 'overproduction_note') this.overproductionNote,
    @JsonKey(name: 'actual_batches_run') this.actualBatchesRun = 0.0,
    @JsonKey(name: 'total_planned_units') this.totalPlannedUnits = 0,
    @JsonKey(name: 'total_actual_units') this.totalActualUnits = 0,
    @JsonKey(name: 'realised_units_per_batch') this.realisedUnitsPerBatch = 0.0,
    this.notes,
    final List<DailyPlanLine> lines = const <DailyPlanLine>[],
  }) : _lines = lines,
       super._();

  factory _$DailyPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey(name: 'plan_date')
  final String planDate;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'mix_item')
  final String mixItem;
  @override
  @JsonKey(name: 'mix_batch_qty')
  final double mixBatchQty;
  @override
  @JsonKey(name: 'mix_uom')
  final String mixUom;
  @override
  @JsonKey(name: 'total_mix_qty')
  final double totalMixQty;
  @override
  @JsonKey(name: 'required_batches')
  final double requiredBatches;
  @override
  @JsonKey(name: 'planned_batches')
  final double plannedBatches;
  @override
  @JsonKey(name: 'mixer_runs')
  final String mixerRuns;
  @override
  @JsonKey(name: 'run_count')
  final int runCount;
  @override
  @JsonKey(name: 'overproduction_batches')
  final double overproductionBatches;
  @override
  @JsonKey(name: 'overproduction_note')
  final String? overproductionNote;
  @override
  @JsonKey(name: 'actual_batches_run')
  final double actualBatchesRun;
  @override
  @JsonKey(name: 'total_planned_units')
  final int totalPlannedUnits;
  @override
  @JsonKey(name: 'total_actual_units')
  final int totalActualUnits;
  @override
  @JsonKey(name: 'realised_units_per_batch')
  final double realisedUnitsPerBatch;
  @override
  final String? notes;
  final List<DailyPlanLine> _lines;
  @override
  @JsonKey()
  List<DailyPlanLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'DailyPlan(name: $name, planDate: $planDate, status: $status, mixItem: $mixItem, mixBatchQty: $mixBatchQty, mixUom: $mixUom, totalMixQty: $totalMixQty, requiredBatches: $requiredBatches, plannedBatches: $plannedBatches, mixerRuns: $mixerRuns, runCount: $runCount, overproductionBatches: $overproductionBatches, overproductionNote: $overproductionNote, actualBatchesRun: $actualBatchesRun, totalPlannedUnits: $totalPlannedUnits, totalActualUnits: $totalActualUnits, realisedUnitsPerBatch: $realisedUnitsPerBatch, notes: $notes, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mixItem, mixItem) || other.mixItem == mixItem) &&
            (identical(other.mixBatchQty, mixBatchQty) ||
                other.mixBatchQty == mixBatchQty) &&
            (identical(other.mixUom, mixUom) || other.mixUom == mixUom) &&
            (identical(other.totalMixQty, totalMixQty) ||
                other.totalMixQty == totalMixQty) &&
            (identical(other.requiredBatches, requiredBatches) ||
                other.requiredBatches == requiredBatches) &&
            (identical(other.plannedBatches, plannedBatches) ||
                other.plannedBatches == plannedBatches) &&
            (identical(other.mixerRuns, mixerRuns) ||
                other.mixerRuns == mixerRuns) &&
            (identical(other.runCount, runCount) ||
                other.runCount == runCount) &&
            (identical(other.overproductionBatches, overproductionBatches) ||
                other.overproductionBatches == overproductionBatches) &&
            (identical(other.overproductionNote, overproductionNote) ||
                other.overproductionNote == overproductionNote) &&
            (identical(other.actualBatchesRun, actualBatchesRun) ||
                other.actualBatchesRun == actualBatchesRun) &&
            (identical(other.totalPlannedUnits, totalPlannedUnits) ||
                other.totalPlannedUnits == totalPlannedUnits) &&
            (identical(other.totalActualUnits, totalActualUnits) ||
                other.totalActualUnits == totalActualUnits) &&
            (identical(other.realisedUnitsPerBatch, realisedUnitsPerBatch) ||
                other.realisedUnitsPerBatch == realisedUnitsPerBatch) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    planDate,
    status,
    mixItem,
    mixBatchQty,
    mixUom,
    totalMixQty,
    requiredBatches,
    plannedBatches,
    mixerRuns,
    runCount,
    overproductionBatches,
    overproductionNote,
    actualBatchesRun,
    totalPlannedUnits,
    totalActualUnits,
    realisedUnitsPerBatch,
    notes,
    const DeepCollectionEquality().hash(_lines),
  ]);

  /// Create a copy of DailyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanImplCopyWith<_$DailyPlanImpl> get copyWith =>
      __$$DailyPlanImplCopyWithImpl<_$DailyPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanImplToJson(this);
  }
}

abstract class _DailyPlan extends DailyPlan {
  const factory _DailyPlan({
    final String name,
    @JsonKey(name: 'plan_date') final String planDate,
    final String status,
    @JsonKey(name: 'mix_item') final String mixItem,
    @JsonKey(name: 'mix_batch_qty') final double mixBatchQty,
    @JsonKey(name: 'mix_uom') final String mixUom,
    @JsonKey(name: 'total_mix_qty') final double totalMixQty,
    @JsonKey(name: 'required_batches') final double requiredBatches,
    @JsonKey(name: 'planned_batches') final double plannedBatches,
    @JsonKey(name: 'mixer_runs') final String mixerRuns,
    @JsonKey(name: 'run_count') final int runCount,
    @JsonKey(name: 'overproduction_batches') final double overproductionBatches,
    @JsonKey(name: 'overproduction_note') final String? overproductionNote,
    @JsonKey(name: 'actual_batches_run') final double actualBatchesRun,
    @JsonKey(name: 'total_planned_units') final int totalPlannedUnits,
    @JsonKey(name: 'total_actual_units') final int totalActualUnits,
    @JsonKey(name: 'realised_units_per_batch')
    final double realisedUnitsPerBatch,
    final String? notes,
    final List<DailyPlanLine> lines,
  }) = _$DailyPlanImpl;
  const _DailyPlan._() : super._();

  factory _DailyPlan.fromJson(Map<String, dynamic> json) =
      _$DailyPlanImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'plan_date')
  String get planDate;
  @override
  String get status;
  @override
  @JsonKey(name: 'mix_item')
  String get mixItem;
  @override
  @JsonKey(name: 'mix_batch_qty')
  double get mixBatchQty;
  @override
  @JsonKey(name: 'mix_uom')
  String get mixUom;
  @override
  @JsonKey(name: 'total_mix_qty')
  double get totalMixQty;
  @override
  @JsonKey(name: 'required_batches')
  double get requiredBatches;
  @override
  @JsonKey(name: 'planned_batches')
  double get plannedBatches;
  @override
  @JsonKey(name: 'mixer_runs')
  String get mixerRuns;
  @override
  @JsonKey(name: 'run_count')
  int get runCount;
  @override
  @JsonKey(name: 'overproduction_batches')
  double get overproductionBatches;
  @override
  @JsonKey(name: 'overproduction_note')
  String? get overproductionNote;
  @override
  @JsonKey(name: 'actual_batches_run')
  double get actualBatchesRun;
  @override
  @JsonKey(name: 'total_planned_units')
  int get totalPlannedUnits;
  @override
  @JsonKey(name: 'total_actual_units')
  int get totalActualUnits;
  @override
  @JsonKey(name: 'realised_units_per_batch')
  double get realisedUnitsPerBatch;
  @override
  String? get notes;
  @override
  List<DailyPlanLine> get lines;

  /// Create a copy of DailyPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanImplCopyWith<_$DailyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanLine _$DailyPlanLineFromJson(Map<String, dynamic> json) {
  return _DailyPlanLine.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanLine {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_qty')
  int get plannedQty => throw _privateConstructorUsedError;

  /// Null means not counted yet — deliberately distinct from a counted zero,
  /// all the way from the DocType to this screen.
  @JsonKey(name: 'actual_qty')
  int? get actualQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'variance_qty')
  int get varianceQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_qty')
  double get mixQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'jars_per_batch')
  double get jarsPerBatch => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanLineCopyWith<DailyPlanLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanLineCopyWith<$Res> {
  factory $DailyPlanLineCopyWith(
    DailyPlanLine value,
    $Res Function(DailyPlanLine) then,
  ) = _$DailyPlanLineCopyWithImpl<$Res, DailyPlanLine>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'planned_qty') int plannedQty,
    @JsonKey(name: 'actual_qty') int? actualQty,
    @JsonKey(name: 'variance_qty') int varianceQty,
    @JsonKey(name: 'mix_qty') double mixQty,
    @JsonKey(name: 'jars_per_batch') double jarsPerBatch,
    String? notes,
  });
}

/// @nodoc
class _$DailyPlanLineCopyWithImpl<$Res, $Val extends DailyPlanLine>
    implements $DailyPlanLineCopyWith<$Res> {
  _$DailyPlanLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? plannedQty = null,
    Object? actualQty = freezed,
    Object? varianceQty = null,
    Object? mixQty = null,
    Object? jarsPerBatch = null,
    Object? notes = freezed,
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
            plannedQty: null == plannedQty
                ? _value.plannedQty
                : plannedQty // ignore: cast_nullable_to_non_nullable
                      as int,
            actualQty: freezed == actualQty
                ? _value.actualQty
                : actualQty // ignore: cast_nullable_to_non_nullable
                      as int?,
            varianceQty: null == varianceQty
                ? _value.varianceQty
                : varianceQty // ignore: cast_nullable_to_non_nullable
                      as int,
            mixQty: null == mixQty
                ? _value.mixQty
                : mixQty // ignore: cast_nullable_to_non_nullable
                      as double,
            jarsPerBatch: null == jarsPerBatch
                ? _value.jarsPerBatch
                : jarsPerBatch // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanLineImplCopyWith<$Res>
    implements $DailyPlanLineCopyWith<$Res> {
  factory _$$DailyPlanLineImplCopyWith(
    _$DailyPlanLineImpl value,
    $Res Function(_$DailyPlanLineImpl) then,
  ) = __$$DailyPlanLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String itemGroup,
    @JsonKey(name: 'planned_qty') int plannedQty,
    @JsonKey(name: 'actual_qty') int? actualQty,
    @JsonKey(name: 'variance_qty') int varianceQty,
    @JsonKey(name: 'mix_qty') double mixQty,
    @JsonKey(name: 'jars_per_batch') double jarsPerBatch,
    String? notes,
  });
}

/// @nodoc
class __$$DailyPlanLineImplCopyWithImpl<$Res>
    extends _$DailyPlanLineCopyWithImpl<$Res, _$DailyPlanLineImpl>
    implements _$$DailyPlanLineImplCopyWith<$Res> {
  __$$DailyPlanLineImplCopyWithImpl(
    _$DailyPlanLineImpl _value,
    $Res Function(_$DailyPlanLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = null,
    Object? plannedQty = null,
    Object? actualQty = freezed,
    Object? varianceQty = null,
    Object? mixQty = null,
    Object? jarsPerBatch = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$DailyPlanLineImpl(
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
        plannedQty: null == plannedQty
            ? _value.plannedQty
            : plannedQty // ignore: cast_nullable_to_non_nullable
                  as int,
        actualQty: freezed == actualQty
            ? _value.actualQty
            : actualQty // ignore: cast_nullable_to_non_nullable
                  as int?,
        varianceQty: null == varianceQty
            ? _value.varianceQty
            : varianceQty // ignore: cast_nullable_to_non_nullable
                  as int,
        mixQty: null == mixQty
            ? _value.mixQty
            : mixQty // ignore: cast_nullable_to_non_nullable
                  as double,
        jarsPerBatch: null == jarsPerBatch
            ? _value.jarsPerBatch
            : jarsPerBatch // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanLineImpl implements _DailyPlanLine {
  const _$DailyPlanLineImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'item_group') this.itemGroup = '',
    @JsonKey(name: 'planned_qty') this.plannedQty = 0,
    @JsonKey(name: 'actual_qty') this.actualQty,
    @JsonKey(name: 'variance_qty') this.varianceQty = 0,
    @JsonKey(name: 'mix_qty') this.mixQty = 0.0,
    @JsonKey(name: 'jars_per_batch') this.jarsPerBatch = 0.0,
    this.notes,
  });

  factory _$DailyPlanLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanLineImplFromJson(json);

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
  @JsonKey(name: 'planned_qty')
  final int plannedQty;

  /// Null means not counted yet — deliberately distinct from a counted zero,
  /// all the way from the DocType to this screen.
  @override
  @JsonKey(name: 'actual_qty')
  final int? actualQty;
  @override
  @JsonKey(name: 'variance_qty')
  final int varianceQty;
  @override
  @JsonKey(name: 'mix_qty')
  final double mixQty;
  @override
  @JsonKey(name: 'jars_per_batch')
  final double jarsPerBatch;
  @override
  final String? notes;

  @override
  String toString() {
    return 'DailyPlanLine(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, plannedQty: $plannedQty, actualQty: $actualQty, varianceQty: $varianceQty, mixQty: $mixQty, jarsPerBatch: $jarsPerBatch, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanLineImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.plannedQty, plannedQty) ||
                other.plannedQty == plannedQty) &&
            (identical(other.actualQty, actualQty) ||
                other.actualQty == actualQty) &&
            (identical(other.varianceQty, varianceQty) ||
                other.varianceQty == varianceQty) &&
            (identical(other.mixQty, mixQty) || other.mixQty == mixQty) &&
            (identical(other.jarsPerBatch, jarsPerBatch) ||
                other.jarsPerBatch == jarsPerBatch) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    itemGroup,
    plannedQty,
    actualQty,
    varianceQty,
    mixQty,
    jarsPerBatch,
    notes,
  );

  /// Create a copy of DailyPlanLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanLineImplCopyWith<_$DailyPlanLineImpl> get copyWith =>
      __$$DailyPlanLineImplCopyWithImpl<_$DailyPlanLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanLineImplToJson(this);
  }
}

abstract class _DailyPlanLine implements DailyPlanLine {
  const factory _DailyPlanLine({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'item_group') final String itemGroup,
    @JsonKey(name: 'planned_qty') final int plannedQty,
    @JsonKey(name: 'actual_qty') final int? actualQty,
    @JsonKey(name: 'variance_qty') final int varianceQty,
    @JsonKey(name: 'mix_qty') final double mixQty,
    @JsonKey(name: 'jars_per_batch') final double jarsPerBatch,
    final String? notes,
  }) = _$DailyPlanLineImpl;

  factory _DailyPlanLine.fromJson(Map<String, dynamic> json) =
      _$DailyPlanLineImpl.fromJson;

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
  @JsonKey(name: 'planned_qty')
  int get plannedQty;

  /// Null means not counted yet — deliberately distinct from a counted zero,
  /// all the way from the DocType to this screen.
  @override
  @JsonKey(name: 'actual_qty')
  int? get actualQty;
  @override
  @JsonKey(name: 'variance_qty')
  int get varianceQty;
  @override
  @JsonKey(name: 'mix_qty')
  double get mixQty;
  @override
  @JsonKey(name: 'jars_per_batch')
  double get jarsPerBatch;
  @override
  String? get notes;

  /// Create a copy of DailyPlanLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanLineImplCopyWith<_$DailyPlanLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BomReadiness _$BomReadinessFromJson(Map<String, dynamic> json) {
  return _BomReadiness.fromJson(json);
}

/// @nodoc
mixin _$BomReadiness {
  bool get ok => throw _privateConstructorUsedError;
  @JsonKey(name: 'mix_item')
  String get mixItem => throw _privateConstructorUsedError;
  @JsonKey(name: 'ready_items')
  int get readyItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'issue_count')
  int get issueCount => throw _privateConstructorUsedError;
  List<BomReadinessIssue> get issues => throw _privateConstructorUsedError;

  /// Serializes this BomReadiness to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BomReadiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BomReadinessCopyWith<BomReadiness> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BomReadinessCopyWith<$Res> {
  factory $BomReadinessCopyWith(
    BomReadiness value,
    $Res Function(BomReadiness) then,
  ) = _$BomReadinessCopyWithImpl<$Res, BomReadiness>;
  @useResult
  $Res call({
    bool ok,
    @JsonKey(name: 'mix_item') String mixItem,
    @JsonKey(name: 'ready_items') int readyItems,
    @JsonKey(name: 'issue_count') int issueCount,
    List<BomReadinessIssue> issues,
  });
}

/// @nodoc
class _$BomReadinessCopyWithImpl<$Res, $Val extends BomReadiness>
    implements $BomReadinessCopyWith<$Res> {
  _$BomReadinessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BomReadiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ok = null,
    Object? mixItem = null,
    Object? readyItems = null,
    Object? issueCount = null,
    Object? issues = null,
  }) {
    return _then(
      _value.copyWith(
            ok: null == ok
                ? _value.ok
                : ok // ignore: cast_nullable_to_non_nullable
                      as bool,
            mixItem: null == mixItem
                ? _value.mixItem
                : mixItem // ignore: cast_nullable_to_non_nullable
                      as String,
            readyItems: null == readyItems
                ? _value.readyItems
                : readyItems // ignore: cast_nullable_to_non_nullable
                      as int,
            issueCount: null == issueCount
                ? _value.issueCount
                : issueCount // ignore: cast_nullable_to_non_nullable
                      as int,
            issues: null == issues
                ? _value.issues
                : issues // ignore: cast_nullable_to_non_nullable
                      as List<BomReadinessIssue>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BomReadinessImplCopyWith<$Res>
    implements $BomReadinessCopyWith<$Res> {
  factory _$$BomReadinessImplCopyWith(
    _$BomReadinessImpl value,
    $Res Function(_$BomReadinessImpl) then,
  ) = __$$BomReadinessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool ok,
    @JsonKey(name: 'mix_item') String mixItem,
    @JsonKey(name: 'ready_items') int readyItems,
    @JsonKey(name: 'issue_count') int issueCount,
    List<BomReadinessIssue> issues,
  });
}

/// @nodoc
class __$$BomReadinessImplCopyWithImpl<$Res>
    extends _$BomReadinessCopyWithImpl<$Res, _$BomReadinessImpl>
    implements _$$BomReadinessImplCopyWith<$Res> {
  __$$BomReadinessImplCopyWithImpl(
    _$BomReadinessImpl _value,
    $Res Function(_$BomReadinessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BomReadiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ok = null,
    Object? mixItem = null,
    Object? readyItems = null,
    Object? issueCount = null,
    Object? issues = null,
  }) {
    return _then(
      _$BomReadinessImpl(
        ok: null == ok
            ? _value.ok
            : ok // ignore: cast_nullable_to_non_nullable
                  as bool,
        mixItem: null == mixItem
            ? _value.mixItem
            : mixItem // ignore: cast_nullable_to_non_nullable
                  as String,
        readyItems: null == readyItems
            ? _value.readyItems
            : readyItems // ignore: cast_nullable_to_non_nullable
                  as int,
        issueCount: null == issueCount
            ? _value.issueCount
            : issueCount // ignore: cast_nullable_to_non_nullable
                  as int,
        issues: null == issues
            ? _value._issues
            : issues // ignore: cast_nullable_to_non_nullable
                  as List<BomReadinessIssue>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BomReadinessImpl implements _BomReadiness {
  const _$BomReadinessImpl({
    this.ok = false,
    @JsonKey(name: 'mix_item') this.mixItem = '',
    @JsonKey(name: 'ready_items') this.readyItems = 0,
    @JsonKey(name: 'issue_count') this.issueCount = 0,
    final List<BomReadinessIssue> issues = const <BomReadinessIssue>[],
  }) : _issues = issues;

  factory _$BomReadinessImpl.fromJson(Map<String, dynamic> json) =>
      _$$BomReadinessImplFromJson(json);

  @override
  @JsonKey()
  final bool ok;
  @override
  @JsonKey(name: 'mix_item')
  final String mixItem;
  @override
  @JsonKey(name: 'ready_items')
  final int readyItems;
  @override
  @JsonKey(name: 'issue_count')
  final int issueCount;
  final List<BomReadinessIssue> _issues;
  @override
  @JsonKey()
  List<BomReadinessIssue> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  @override
  String toString() {
    return 'BomReadiness(ok: $ok, mixItem: $mixItem, readyItems: $readyItems, issueCount: $issueCount, issues: $issues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BomReadinessImpl &&
            (identical(other.ok, ok) || other.ok == ok) &&
            (identical(other.mixItem, mixItem) || other.mixItem == mixItem) &&
            (identical(other.readyItems, readyItems) ||
                other.readyItems == readyItems) &&
            (identical(other.issueCount, issueCount) ||
                other.issueCount == issueCount) &&
            const DeepCollectionEquality().equals(other._issues, _issues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ok,
    mixItem,
    readyItems,
    issueCount,
    const DeepCollectionEquality().hash(_issues),
  );

  /// Create a copy of BomReadiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BomReadinessImplCopyWith<_$BomReadinessImpl> get copyWith =>
      __$$BomReadinessImplCopyWithImpl<_$BomReadinessImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BomReadinessImplToJson(this);
  }
}

abstract class _BomReadiness implements BomReadiness {
  const factory _BomReadiness({
    final bool ok,
    @JsonKey(name: 'mix_item') final String mixItem,
    @JsonKey(name: 'ready_items') final int readyItems,
    @JsonKey(name: 'issue_count') final int issueCount,
    final List<BomReadinessIssue> issues,
  }) = _$BomReadinessImpl;

  factory _BomReadiness.fromJson(Map<String, dynamic> json) =
      _$BomReadinessImpl.fromJson;

  @override
  bool get ok;
  @override
  @JsonKey(name: 'mix_item')
  String get mixItem;
  @override
  @JsonKey(name: 'ready_items')
  int get readyItems;
  @override
  @JsonKey(name: 'issue_count')
  int get issueCount;
  @override
  List<BomReadinessIssue> get issues;

  /// Create a copy of BomReadiness
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BomReadinessImplCopyWith<_$BomReadinessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BomReadinessIssue _$BomReadinessIssueFromJson(Map<String, dynamic> json) {
  return _BomReadinessIssue.fromJson(json);
}

/// @nodoc
mixin _$BomReadinessIssue {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;

  /// Serializes this BomReadinessIssue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BomReadinessIssue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BomReadinessIssueCopyWith<BomReadinessIssue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BomReadinessIssueCopyWith<$Res> {
  factory $BomReadinessIssueCopyWith(
    BomReadinessIssue value,
    $Res Function(BomReadinessIssue) then,
  ) = _$BomReadinessIssueCopyWithImpl<$Res, BomReadinessIssue>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    String severity,
    String reason,
    String detail,
  });
}

/// @nodoc
class _$BomReadinessIssueCopyWithImpl<$Res, $Val extends BomReadinessIssue>
    implements $BomReadinessIssueCopyWith<$Res> {
  _$BomReadinessIssueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BomReadinessIssue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? severity = null,
    Object? reason = null,
    Object? detail = null,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            detail: null == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BomReadinessIssueImplCopyWith<$Res>
    implements $BomReadinessIssueCopyWith<$Res> {
  factory _$$BomReadinessIssueImplCopyWith(
    _$BomReadinessIssueImpl value,
    $Res Function(_$BomReadinessIssueImpl) then,
  ) = __$$BomReadinessIssueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    String severity,
    String reason,
    String detail,
  });
}

/// @nodoc
class __$$BomReadinessIssueImplCopyWithImpl<$Res>
    extends _$BomReadinessIssueCopyWithImpl<$Res, _$BomReadinessIssueImpl>
    implements _$$BomReadinessIssueImplCopyWith<$Res> {
  __$$BomReadinessIssueImplCopyWithImpl(
    _$BomReadinessIssueImpl _value,
    $Res Function(_$BomReadinessIssueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BomReadinessIssue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? severity = null,
    Object? reason = null,
    Object? detail = null,
  }) {
    return _then(
      _$BomReadinessIssueImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        detail: null == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BomReadinessIssueImpl implements _BomReadinessIssue {
  const _$BomReadinessIssueImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    this.severity = '',
    this.reason = '',
    this.detail = '',
  });

  factory _$BomReadinessIssueImpl.fromJson(Map<String, dynamic> json) =>
      _$$BomReadinessIssueImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey()
  final String severity;
  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final String detail;

  @override
  String toString() {
    return 'BomReadinessIssue(itemCode: $itemCode, severity: $severity, reason: $reason, detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BomReadinessIssueImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemCode, severity, reason, detail);

  /// Create a copy of BomReadinessIssue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BomReadinessIssueImplCopyWith<_$BomReadinessIssueImpl> get copyWith =>
      __$$BomReadinessIssueImplCopyWithImpl<_$BomReadinessIssueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BomReadinessIssueImplToJson(this);
  }
}

abstract class _BomReadinessIssue implements BomReadinessIssue {
  const factory _BomReadinessIssue({
    @JsonKey(name: 'item_code') final String itemCode,
    final String severity,
    final String reason,
    final String detail,
  }) = _$BomReadinessIssueImpl;

  factory _BomReadinessIssue.fromJson(Map<String, dynamic> json) =
      _$BomReadinessIssueImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  String get severity;
  @override
  String get reason;
  @override
  String get detail;

  /// Create a copy of BomReadinessIssue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BomReadinessIssueImplCopyWith<_$BomReadinessIssueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanTemplate _$DailyPlanTemplateFromJson(Map<String, dynamic> json) {
  return _DailyPlanTemplate.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanTemplate {
  @JsonKey(name: 'plan_date')
  String get planDate => throw _privateConstructorUsedError;
  DailyPlanMix get mix => throw _privateConstructorUsedError;
  List<DailyPlanItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'existing_plan')
  String? get existingPlan => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanTemplateCopyWith<DailyPlanTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanTemplateCopyWith<$Res> {
  factory $DailyPlanTemplateCopyWith(
    DailyPlanTemplate value,
    $Res Function(DailyPlanTemplate) then,
  ) = _$DailyPlanTemplateCopyWithImpl<$Res, DailyPlanTemplate>;
  @useResult
  $Res call({
    @JsonKey(name: 'plan_date') String planDate,
    DailyPlanMix mix,
    List<DailyPlanItem> items,
    @JsonKey(name: 'existing_plan') String? existingPlan,
  });

  $DailyPlanMixCopyWith<$Res> get mix;
}

/// @nodoc
class _$DailyPlanTemplateCopyWithImpl<$Res, $Val extends DailyPlanTemplate>
    implements $DailyPlanTemplateCopyWith<$Res> {
  _$DailyPlanTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planDate = null,
    Object? mix = null,
    Object? items = null,
    Object? existingPlan = freezed,
  }) {
    return _then(
      _value.copyWith(
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as String,
            mix: null == mix
                ? _value.mix
                : mix // ignore: cast_nullable_to_non_nullable
                      as DailyPlanMix,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<DailyPlanItem>,
            existingPlan: freezed == existingPlan
                ? _value.existingPlan
                : existingPlan // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyPlanMixCopyWith<$Res> get mix {
    return $DailyPlanMixCopyWith<$Res>(_value.mix, (value) {
      return _then(_value.copyWith(mix: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyPlanTemplateImplCopyWith<$Res>
    implements $DailyPlanTemplateCopyWith<$Res> {
  factory _$$DailyPlanTemplateImplCopyWith(
    _$DailyPlanTemplateImpl value,
    $Res Function(_$DailyPlanTemplateImpl) then,
  ) = __$$DailyPlanTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'plan_date') String planDate,
    DailyPlanMix mix,
    List<DailyPlanItem> items,
    @JsonKey(name: 'existing_plan') String? existingPlan,
  });

  @override
  $DailyPlanMixCopyWith<$Res> get mix;
}

/// @nodoc
class __$$DailyPlanTemplateImplCopyWithImpl<$Res>
    extends _$DailyPlanTemplateCopyWithImpl<$Res, _$DailyPlanTemplateImpl>
    implements _$$DailyPlanTemplateImplCopyWith<$Res> {
  __$$DailyPlanTemplateImplCopyWithImpl(
    _$DailyPlanTemplateImpl _value,
    $Res Function(_$DailyPlanTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planDate = null,
    Object? mix = null,
    Object? items = null,
    Object? existingPlan = freezed,
  }) {
    return _then(
      _$DailyPlanTemplateImpl(
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as String,
        mix: null == mix
            ? _value.mix
            : mix // ignore: cast_nullable_to_non_nullable
                  as DailyPlanMix,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<DailyPlanItem>,
        existingPlan: freezed == existingPlan
            ? _value.existingPlan
            : existingPlan // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanTemplateImpl implements _DailyPlanTemplate {
  const _$DailyPlanTemplateImpl({
    @JsonKey(name: 'plan_date') this.planDate = '',
    this.mix = const DailyPlanMix(),
    final List<DailyPlanItem> items = const <DailyPlanItem>[],
    @JsonKey(name: 'existing_plan') this.existingPlan,
  }) : _items = items;

  factory _$DailyPlanTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanTemplateImplFromJson(json);

  @override
  @JsonKey(name: 'plan_date')
  final String planDate;
  @override
  @JsonKey()
  final DailyPlanMix mix;
  final List<DailyPlanItem> _items;
  @override
  @JsonKey()
  List<DailyPlanItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'existing_plan')
  final String? existingPlan;

  @override
  String toString() {
    return 'DailyPlanTemplate(planDate: $planDate, mix: $mix, items: $items, existingPlan: $existingPlan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanTemplateImpl &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.mix, mix) || other.mix == mix) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.existingPlan, existingPlan) ||
                other.existingPlan == existingPlan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    planDate,
    mix,
    const DeepCollectionEquality().hash(_items),
    existingPlan,
  );

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanTemplateImplCopyWith<_$DailyPlanTemplateImpl> get copyWith =>
      __$$DailyPlanTemplateImplCopyWithImpl<_$DailyPlanTemplateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanTemplateImplToJson(this);
  }
}

abstract class _DailyPlanTemplate implements DailyPlanTemplate {
  const factory _DailyPlanTemplate({
    @JsonKey(name: 'plan_date') final String planDate,
    final DailyPlanMix mix,
    final List<DailyPlanItem> items,
    @JsonKey(name: 'existing_plan') final String? existingPlan,
  }) = _$DailyPlanTemplateImpl;

  factory _DailyPlanTemplate.fromJson(Map<String, dynamic> json) =
      _$DailyPlanTemplateImpl.fromJson;

  @override
  @JsonKey(name: 'plan_date')
  String get planDate;
  @override
  DailyPlanMix get mix;
  @override
  List<DailyPlanItem> get items;
  @override
  @JsonKey(name: 'existing_plan')
  String? get existingPlan;

  /// Create a copy of DailyPlanTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanTemplateImplCopyWith<_$DailyPlanTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
