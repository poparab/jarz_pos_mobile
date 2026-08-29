// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_alternative.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockAlternative _$StockAlternativeFromJson(Map<String, dynamic> json) {
  return _StockAlternative.fromJson(json);
}

/// @nodoc
mixin _$StockAlternative {
  String get warehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double get availableQty => throw _privateConstructorUsedError;

  /// Serializes this StockAlternative to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockAlternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockAlternativeCopyWith<StockAlternative> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockAlternativeCopyWith<$Res> {
  factory $StockAlternativeCopyWith(
    StockAlternative value,
    $Res Function(StockAlternative) then,
  ) = _$StockAlternativeCopyWithImpl<$Res, StockAlternative>;
  @useResult
  $Res call({
    String warehouse,
    @JsonKey(name: 'available_qty') double availableQty,
  });
}

/// @nodoc
class _$StockAlternativeCopyWithImpl<$Res, $Val extends StockAlternative>
    implements $StockAlternativeCopyWith<$Res> {
  _$StockAlternativeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockAlternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? warehouse = null, Object? availableQty = null}) {
    return _then(
      _value.copyWith(
            warehouse: null == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as String,
            availableQty: null == availableQty
                ? _value.availableQty
                : availableQty // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockAlternativeImplCopyWith<$Res>
    implements $StockAlternativeCopyWith<$Res> {
  factory _$$StockAlternativeImplCopyWith(
    _$StockAlternativeImpl value,
    $Res Function(_$StockAlternativeImpl) then,
  ) = __$$StockAlternativeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String warehouse,
    @JsonKey(name: 'available_qty') double availableQty,
  });
}

/// @nodoc
class __$$StockAlternativeImplCopyWithImpl<$Res>
    extends _$StockAlternativeCopyWithImpl<$Res, _$StockAlternativeImpl>
    implements _$$StockAlternativeImplCopyWith<$Res> {
  __$$StockAlternativeImplCopyWithImpl(
    _$StockAlternativeImpl _value,
    $Res Function(_$StockAlternativeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockAlternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? warehouse = null, Object? availableQty = null}) {
    return _then(
      _$StockAlternativeImpl(
        warehouse: null == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as String,
        availableQty: null == availableQty
            ? _value.availableQty
            : availableQty // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockAlternativeImpl implements _StockAlternative {
  const _$StockAlternativeImpl({
    this.warehouse = '',
    @JsonKey(name: 'available_qty') this.availableQty = 0.0,
  });

  factory _$StockAlternativeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockAlternativeImplFromJson(json);

  @override
  @JsonKey()
  final String warehouse;
  @override
  @JsonKey(name: 'available_qty')
  final double availableQty;

  @override
  String toString() {
    return 'StockAlternative(warehouse: $warehouse, availableQty: $availableQty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockAlternativeImpl &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, warehouse, availableQty);

  /// Create a copy of StockAlternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockAlternativeImplCopyWith<_$StockAlternativeImpl> get copyWith =>
      __$$StockAlternativeImplCopyWithImpl<_$StockAlternativeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StockAlternativeImplToJson(this);
  }
}

abstract class _StockAlternative implements StockAlternative {
  const factory _StockAlternative({
    final String warehouse,
    @JsonKey(name: 'available_qty') final double availableQty,
  }) = _$StockAlternativeImpl;

  factory _StockAlternative.fromJson(Map<String, dynamic> json) =
      _$StockAlternativeImpl.fromJson;

  @override
  String get warehouse;
  @override
  @JsonKey(name: 'available_qty')
  double get availableQty;

  /// Create a copy of StockAlternative
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockAlternativeImplCopyWith<_$StockAlternativeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
