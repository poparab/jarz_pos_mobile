// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductionSuggestionsPage _$ProductionSuggestionsPageFromJson(
  Map<String, dynamic> json,
) {
  return _ProductionSuggestionsPage.fromJson(json);
}

/// @nodoc
mixin _$ProductionSuggestionsPage {
  @JsonKey(name: 'generated_on')
  String? get generatedOn => throw _privateConstructorUsedError;
  String get company => throw _privateConstructorUsedError;
  ProductionSeason get season => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_target_days')
  int get defaultTargetDays => throw _privateConstructorUsedError;
  ProductionThresholds get thresholds => throw _privateConstructorUsedError;
  @JsonKey(name: 'velocity_updated_on')
  String? get velocityUpdatedOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'capacity_included')
  bool get capacityIncluded => throw _privateConstructorUsedError;
  List<ProductionSuggestion> get items => throw _privateConstructorUsedError;
  ProductionSummary get summary => throw _privateConstructorUsedError;

  /// Serializes this ProductionSuggestionsPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionSuggestionsPageCopyWith<ProductionSuggestionsPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionSuggestionsPageCopyWith<$Res> {
  factory $ProductionSuggestionsPageCopyWith(
    ProductionSuggestionsPage value,
    $Res Function(ProductionSuggestionsPage) then,
  ) = _$ProductionSuggestionsPageCopyWithImpl<$Res, ProductionSuggestionsPage>;
  @useResult
  $Res call({
    @JsonKey(name: 'generated_on') String? generatedOn,
    String company,
    ProductionSeason season,
    @JsonKey(name: 'default_target_days') int defaultTargetDays,
    ProductionThresholds thresholds,
    @JsonKey(name: 'velocity_updated_on') String? velocityUpdatedOn,
    @JsonKey(name: 'capacity_included') bool capacityIncluded,
    List<ProductionSuggestion> items,
    ProductionSummary summary,
  });

  $ProductionSeasonCopyWith<$Res> get season;
  $ProductionThresholdsCopyWith<$Res> get thresholds;
  $ProductionSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ProductionSuggestionsPageCopyWithImpl<
  $Res,
  $Val extends ProductionSuggestionsPage
>
    implements $ProductionSuggestionsPageCopyWith<$Res> {
  _$ProductionSuggestionsPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedOn = freezed,
    Object? company = null,
    Object? season = null,
    Object? defaultTargetDays = null,
    Object? thresholds = null,
    Object? velocityUpdatedOn = freezed,
    Object? capacityIncluded = null,
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(
      _value.copyWith(
            generatedOn: freezed == generatedOn
                ? _value.generatedOn
                : generatedOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            season: null == season
                ? _value.season
                : season // ignore: cast_nullable_to_non_nullable
                      as ProductionSeason,
            defaultTargetDays: null == defaultTargetDays
                ? _value.defaultTargetDays
                : defaultTargetDays // ignore: cast_nullable_to_non_nullable
                      as int,
            thresholds: null == thresholds
                ? _value.thresholds
                : thresholds // ignore: cast_nullable_to_non_nullable
                      as ProductionThresholds,
            velocityUpdatedOn: freezed == velocityUpdatedOn
                ? _value.velocityUpdatedOn
                : velocityUpdatedOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            capacityIncluded: null == capacityIncluded
                ? _value.capacityIncluded
                : capacityIncluded // ignore: cast_nullable_to_non_nullable
                      as bool,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ProductionSuggestion>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as ProductionSummary,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionSeasonCopyWith<$Res> get season {
    return $ProductionSeasonCopyWith<$Res>(_value.season, (value) {
      return _then(_value.copyWith(season: value) as $Val);
    });
  }

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionThresholdsCopyWith<$Res> get thresholds {
    return $ProductionThresholdsCopyWith<$Res>(_value.thresholds, (value) {
      return _then(_value.copyWith(thresholds: value) as $Val);
    });
  }

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionSummaryCopyWith<$Res> get summary {
    return $ProductionSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductionSuggestionsPageImplCopyWith<$Res>
    implements $ProductionSuggestionsPageCopyWith<$Res> {
  factory _$$ProductionSuggestionsPageImplCopyWith(
    _$ProductionSuggestionsPageImpl value,
    $Res Function(_$ProductionSuggestionsPageImpl) then,
  ) = __$$ProductionSuggestionsPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'generated_on') String? generatedOn,
    String company,
    ProductionSeason season,
    @JsonKey(name: 'default_target_days') int defaultTargetDays,
    ProductionThresholds thresholds,
    @JsonKey(name: 'velocity_updated_on') String? velocityUpdatedOn,
    @JsonKey(name: 'capacity_included') bool capacityIncluded,
    List<ProductionSuggestion> items,
    ProductionSummary summary,
  });

  @override
  $ProductionSeasonCopyWith<$Res> get season;
  @override
  $ProductionThresholdsCopyWith<$Res> get thresholds;
  @override
  $ProductionSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ProductionSuggestionsPageImplCopyWithImpl<$Res>
    extends
        _$ProductionSuggestionsPageCopyWithImpl<
          $Res,
          _$ProductionSuggestionsPageImpl
        >
    implements _$$ProductionSuggestionsPageImplCopyWith<$Res> {
  __$$ProductionSuggestionsPageImplCopyWithImpl(
    _$ProductionSuggestionsPageImpl _value,
    $Res Function(_$ProductionSuggestionsPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedOn = freezed,
    Object? company = null,
    Object? season = null,
    Object? defaultTargetDays = null,
    Object? thresholds = null,
    Object? velocityUpdatedOn = freezed,
    Object? capacityIncluded = null,
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(
      _$ProductionSuggestionsPageImpl(
        generatedOn: freezed == generatedOn
            ? _value.generatedOn
            : generatedOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        season: null == season
            ? _value.season
            : season // ignore: cast_nullable_to_non_nullable
                  as ProductionSeason,
        defaultTargetDays: null == defaultTargetDays
            ? _value.defaultTargetDays
            : defaultTargetDays // ignore: cast_nullable_to_non_nullable
                  as int,
        thresholds: null == thresholds
            ? _value.thresholds
            : thresholds // ignore: cast_nullable_to_non_nullable
                  as ProductionThresholds,
        velocityUpdatedOn: freezed == velocityUpdatedOn
            ? _value.velocityUpdatedOn
            : velocityUpdatedOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        capacityIncluded: null == capacityIncluded
            ? _value.capacityIncluded
            : capacityIncluded // ignore: cast_nullable_to_non_nullable
                  as bool,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ProductionSuggestion>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as ProductionSummary,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionSuggestionsPageImpl implements _ProductionSuggestionsPage {
  const _$ProductionSuggestionsPageImpl({
    @JsonKey(name: 'generated_on') this.generatedOn,
    this.company = '',
    this.season = const ProductionSeason(),
    @JsonKey(name: 'default_target_days') this.defaultTargetDays = 7,
    this.thresholds = const ProductionThresholds(),
    @JsonKey(name: 'velocity_updated_on') this.velocityUpdatedOn,
    @JsonKey(name: 'capacity_included') this.capacityIncluded = true,
    final List<ProductionSuggestion> items = const <ProductionSuggestion>[],
    this.summary = const ProductionSummary(),
  }) : _items = items;

  factory _$ProductionSuggestionsPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionSuggestionsPageImplFromJson(json);

  @override
  @JsonKey(name: 'generated_on')
  final String? generatedOn;
  @override
  @JsonKey()
  final String company;
  @override
  @JsonKey()
  final ProductionSeason season;
  @override
  @JsonKey(name: 'default_target_days')
  final int defaultTargetDays;
  @override
  @JsonKey()
  final ProductionThresholds thresholds;
  @override
  @JsonKey(name: 'velocity_updated_on')
  final String? velocityUpdatedOn;
  @override
  @JsonKey(name: 'capacity_included')
  final bool capacityIncluded;
  final List<ProductionSuggestion> _items;
  @override
  @JsonKey()
  List<ProductionSuggestion> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final ProductionSummary summary;

  @override
  String toString() {
    return 'ProductionSuggestionsPage(generatedOn: $generatedOn, company: $company, season: $season, defaultTargetDays: $defaultTargetDays, thresholds: $thresholds, velocityUpdatedOn: $velocityUpdatedOn, capacityIncluded: $capacityIncluded, items: $items, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionSuggestionsPageImpl &&
            (identical(other.generatedOn, generatedOn) ||
                other.generatedOn == generatedOn) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.defaultTargetDays, defaultTargetDays) ||
                other.defaultTargetDays == defaultTargetDays) &&
            (identical(other.thresholds, thresholds) ||
                other.thresholds == thresholds) &&
            (identical(other.velocityUpdatedOn, velocityUpdatedOn) ||
                other.velocityUpdatedOn == velocityUpdatedOn) &&
            (identical(other.capacityIncluded, capacityIncluded) ||
                other.capacityIncluded == capacityIncluded) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    generatedOn,
    company,
    season,
    defaultTargetDays,
    thresholds,
    velocityUpdatedOn,
    capacityIncluded,
    const DeepCollectionEquality().hash(_items),
    summary,
  );

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionSuggestionsPageImplCopyWith<_$ProductionSuggestionsPageImpl>
  get copyWith =>
      __$$ProductionSuggestionsPageImplCopyWithImpl<
        _$ProductionSuggestionsPageImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionSuggestionsPageImplToJson(this);
  }
}

abstract class _ProductionSuggestionsPage implements ProductionSuggestionsPage {
  const factory _ProductionSuggestionsPage({
    @JsonKey(name: 'generated_on') final String? generatedOn,
    final String company,
    final ProductionSeason season,
    @JsonKey(name: 'default_target_days') final int defaultTargetDays,
    final ProductionThresholds thresholds,
    @JsonKey(name: 'velocity_updated_on') final String? velocityUpdatedOn,
    @JsonKey(name: 'capacity_included') final bool capacityIncluded,
    final List<ProductionSuggestion> items,
    final ProductionSummary summary,
  }) = _$ProductionSuggestionsPageImpl;

  factory _ProductionSuggestionsPage.fromJson(Map<String, dynamic> json) =
      _$ProductionSuggestionsPageImpl.fromJson;

  @override
  @JsonKey(name: 'generated_on')
  String? get generatedOn;
  @override
  String get company;
  @override
  ProductionSeason get season;
  @override
  @JsonKey(name: 'default_target_days')
  int get defaultTargetDays;
  @override
  ProductionThresholds get thresholds;
  @override
  @JsonKey(name: 'velocity_updated_on')
  String? get velocityUpdatedOn;
  @override
  @JsonKey(name: 'capacity_included')
  bool get capacityIncluded;
  @override
  List<ProductionSuggestion> get items;
  @override
  ProductionSummary get summary;

  /// Create a copy of ProductionSuggestionsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionSuggestionsPageImplCopyWith<_$ProductionSuggestionsPageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionSeason _$ProductionSeasonFromJson(Map<String, dynamic> json) {
  return _ProductionSeason.fromJson(json);
}

/// @nodoc
mixin _$ProductionSeason {
  String? get name => throw _privateConstructorUsedError;
  double get multiplier => throw _privateConstructorUsedError;

  /// Serializes this ProductionSeason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionSeason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionSeasonCopyWith<ProductionSeason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionSeasonCopyWith<$Res> {
  factory $ProductionSeasonCopyWith(
    ProductionSeason value,
    $Res Function(ProductionSeason) then,
  ) = _$ProductionSeasonCopyWithImpl<$Res, ProductionSeason>;
  @useResult
  $Res call({String? name, double multiplier});
}

/// @nodoc
class _$ProductionSeasonCopyWithImpl<$Res, $Val extends ProductionSeason>
    implements $ProductionSeasonCopyWith<$Res> {
  _$ProductionSeasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionSeason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? multiplier = null}) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            multiplier: null == multiplier
                ? _value.multiplier
                : multiplier // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionSeasonImplCopyWith<$Res>
    implements $ProductionSeasonCopyWith<$Res> {
  factory _$$ProductionSeasonImplCopyWith(
    _$ProductionSeasonImpl value,
    $Res Function(_$ProductionSeasonImpl) then,
  ) = __$$ProductionSeasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, double multiplier});
}

/// @nodoc
class __$$ProductionSeasonImplCopyWithImpl<$Res>
    extends _$ProductionSeasonCopyWithImpl<$Res, _$ProductionSeasonImpl>
    implements _$$ProductionSeasonImplCopyWith<$Res> {
  __$$ProductionSeasonImplCopyWithImpl(
    _$ProductionSeasonImpl _value,
    $Res Function(_$ProductionSeasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionSeason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? multiplier = null}) {
    return _then(
      _$ProductionSeasonImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        multiplier: null == multiplier
            ? _value.multiplier
            : multiplier // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionSeasonImpl implements _ProductionSeason {
  const _$ProductionSeasonImpl({this.name, this.multiplier = 1.0});

  factory _$ProductionSeasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionSeasonImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey()
  final double multiplier;

  @override
  String toString() {
    return 'ProductionSeason(name: $name, multiplier: $multiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionSeasonImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, multiplier);

  /// Create a copy of ProductionSeason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionSeasonImplCopyWith<_$ProductionSeasonImpl> get copyWith =>
      __$$ProductionSeasonImplCopyWithImpl<_$ProductionSeasonImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionSeasonImplToJson(this);
  }
}

abstract class _ProductionSeason implements ProductionSeason {
  const factory _ProductionSeason({
    final String? name,
    final double multiplier,
  }) = _$ProductionSeasonImpl;

  factory _ProductionSeason.fromJson(Map<String, dynamic> json) =
      _$ProductionSeasonImpl.fromJson;

  @override
  String? get name;
  @override
  double get multiplier;

  /// Create a copy of ProductionSeason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionSeasonImplCopyWith<_$ProductionSeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductionThresholds _$ProductionThresholdsFromJson(Map<String, dynamic> json) {
  return _ProductionThresholds.fromJson(json);
}

/// @nodoc
mixin _$ProductionThresholds {
  @JsonKey(name: 'critical_days')
  int get criticalDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'watch_days')
  int get watchDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'overstock_days')
  int get overstockDays => throw _privateConstructorUsedError;

  /// Serializes this ProductionThresholds to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionThresholds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionThresholdsCopyWith<ProductionThresholds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionThresholdsCopyWith<$Res> {
  factory $ProductionThresholdsCopyWith(
    ProductionThresholds value,
    $Res Function(ProductionThresholds) then,
  ) = _$ProductionThresholdsCopyWithImpl<$Res, ProductionThresholds>;
  @useResult
  $Res call({
    @JsonKey(name: 'critical_days') int criticalDays,
    @JsonKey(name: 'watch_days') int watchDays,
    @JsonKey(name: 'overstock_days') int overstockDays,
  });
}

/// @nodoc
class _$ProductionThresholdsCopyWithImpl<
  $Res,
  $Val extends ProductionThresholds
>
    implements $ProductionThresholdsCopyWith<$Res> {
  _$ProductionThresholdsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionThresholds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? criticalDays = null,
    Object? watchDays = null,
    Object? overstockDays = null,
  }) {
    return _then(
      _value.copyWith(
            criticalDays: null == criticalDays
                ? _value.criticalDays
                : criticalDays // ignore: cast_nullable_to_non_nullable
                      as int,
            watchDays: null == watchDays
                ? _value.watchDays
                : watchDays // ignore: cast_nullable_to_non_nullable
                      as int,
            overstockDays: null == overstockDays
                ? _value.overstockDays
                : overstockDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionThresholdsImplCopyWith<$Res>
    implements $ProductionThresholdsCopyWith<$Res> {
  factory _$$ProductionThresholdsImplCopyWith(
    _$ProductionThresholdsImpl value,
    $Res Function(_$ProductionThresholdsImpl) then,
  ) = __$$ProductionThresholdsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'critical_days') int criticalDays,
    @JsonKey(name: 'watch_days') int watchDays,
    @JsonKey(name: 'overstock_days') int overstockDays,
  });
}

/// @nodoc
class __$$ProductionThresholdsImplCopyWithImpl<$Res>
    extends _$ProductionThresholdsCopyWithImpl<$Res, _$ProductionThresholdsImpl>
    implements _$$ProductionThresholdsImplCopyWith<$Res> {
  __$$ProductionThresholdsImplCopyWithImpl(
    _$ProductionThresholdsImpl _value,
    $Res Function(_$ProductionThresholdsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionThresholds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? criticalDays = null,
    Object? watchDays = null,
    Object? overstockDays = null,
  }) {
    return _then(
      _$ProductionThresholdsImpl(
        criticalDays: null == criticalDays
            ? _value.criticalDays
            : criticalDays // ignore: cast_nullable_to_non_nullable
                  as int,
        watchDays: null == watchDays
            ? _value.watchDays
            : watchDays // ignore: cast_nullable_to_non_nullable
                  as int,
        overstockDays: null == overstockDays
            ? _value.overstockDays
            : overstockDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionThresholdsImpl implements _ProductionThresholds {
  const _$ProductionThresholdsImpl({
    @JsonKey(name: 'critical_days') this.criticalDays = 5,
    @JsonKey(name: 'watch_days') this.watchDays = 14,
    @JsonKey(name: 'overstock_days') this.overstockDays = 90,
  });

  factory _$ProductionThresholdsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionThresholdsImplFromJson(json);

  @override
  @JsonKey(name: 'critical_days')
  final int criticalDays;
  @override
  @JsonKey(name: 'watch_days')
  final int watchDays;
  @override
  @JsonKey(name: 'overstock_days')
  final int overstockDays;

  @override
  String toString() {
    return 'ProductionThresholds(criticalDays: $criticalDays, watchDays: $watchDays, overstockDays: $overstockDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionThresholdsImpl &&
            (identical(other.criticalDays, criticalDays) ||
                other.criticalDays == criticalDays) &&
            (identical(other.watchDays, watchDays) ||
                other.watchDays == watchDays) &&
            (identical(other.overstockDays, overstockDays) ||
                other.overstockDays == overstockDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, criticalDays, watchDays, overstockDays);

  /// Create a copy of ProductionThresholds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionThresholdsImplCopyWith<_$ProductionThresholdsImpl>
  get copyWith =>
      __$$ProductionThresholdsImplCopyWithImpl<_$ProductionThresholdsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionThresholdsImplToJson(this);
  }
}

abstract class _ProductionThresholds implements ProductionThresholds {
  const factory _ProductionThresholds({
    @JsonKey(name: 'critical_days') final int criticalDays,
    @JsonKey(name: 'watch_days') final int watchDays,
    @JsonKey(name: 'overstock_days') final int overstockDays,
  }) = _$ProductionThresholdsImpl;

  factory _ProductionThresholds.fromJson(Map<String, dynamic> json) =
      _$ProductionThresholdsImpl.fromJson;

  @override
  @JsonKey(name: 'critical_days')
  int get criticalDays;
  @override
  @JsonKey(name: 'watch_days')
  int get watchDays;
  @override
  @JsonKey(name: 'overstock_days')
  int get overstockDays;

  /// Create a copy of ProductionThresholds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionThresholdsImplCopyWith<_$ProductionThresholdsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProductionSummary _$ProductionSummaryFromJson(Map<String, dynamic> json) {
  return _ProductionSummary.fromJson(json);
}

/// @nodoc
mixin _$ProductionSummary {
  int get critical => throw _privateConstructorUsedError;
  int get low => throw _privateConstructorUsedError;
  int get ok => throw _privateConstructorUsedError;
  int get overstocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'no_velocity')
  int get noVelocity => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_suggested_batches')
  int get totalSuggestedBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'capped_by_materials')
  int get cappedByMaterials => throw _privateConstructorUsedError;

  /// Serializes this ProductionSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionSummaryCopyWith<ProductionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionSummaryCopyWith<$Res> {
  factory $ProductionSummaryCopyWith(
    ProductionSummary value,
    $Res Function(ProductionSummary) then,
  ) = _$ProductionSummaryCopyWithImpl<$Res, ProductionSummary>;
  @useResult
  $Res call({
    int critical,
    int low,
    int ok,
    int overstocked,
    @JsonKey(name: 'no_velocity') int noVelocity,
    @JsonKey(name: 'total_suggested_batches') int totalSuggestedBatches,
    @JsonKey(name: 'capped_by_materials') int cappedByMaterials,
  });
}

/// @nodoc
class _$ProductionSummaryCopyWithImpl<$Res, $Val extends ProductionSummary>
    implements $ProductionSummaryCopyWith<$Res> {
  _$ProductionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? critical = null,
    Object? low = null,
    Object? ok = null,
    Object? overstocked = null,
    Object? noVelocity = null,
    Object? totalSuggestedBatches = null,
    Object? cappedByMaterials = null,
  }) {
    return _then(
      _value.copyWith(
            critical: null == critical
                ? _value.critical
                : critical // ignore: cast_nullable_to_non_nullable
                      as int,
            low: null == low
                ? _value.low
                : low // ignore: cast_nullable_to_non_nullable
                      as int,
            ok: null == ok
                ? _value.ok
                : ok // ignore: cast_nullable_to_non_nullable
                      as int,
            overstocked: null == overstocked
                ? _value.overstocked
                : overstocked // ignore: cast_nullable_to_non_nullable
                      as int,
            noVelocity: null == noVelocity
                ? _value.noVelocity
                : noVelocity // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSuggestedBatches: null == totalSuggestedBatches
                ? _value.totalSuggestedBatches
                : totalSuggestedBatches // ignore: cast_nullable_to_non_nullable
                      as int,
            cappedByMaterials: null == cappedByMaterials
                ? _value.cappedByMaterials
                : cappedByMaterials // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductionSummaryImplCopyWith<$Res>
    implements $ProductionSummaryCopyWith<$Res> {
  factory _$$ProductionSummaryImplCopyWith(
    _$ProductionSummaryImpl value,
    $Res Function(_$ProductionSummaryImpl) then,
  ) = __$$ProductionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int critical,
    int low,
    int ok,
    int overstocked,
    @JsonKey(name: 'no_velocity') int noVelocity,
    @JsonKey(name: 'total_suggested_batches') int totalSuggestedBatches,
    @JsonKey(name: 'capped_by_materials') int cappedByMaterials,
  });
}

/// @nodoc
class __$$ProductionSummaryImplCopyWithImpl<$Res>
    extends _$ProductionSummaryCopyWithImpl<$Res, _$ProductionSummaryImpl>
    implements _$$ProductionSummaryImplCopyWith<$Res> {
  __$$ProductionSummaryImplCopyWithImpl(
    _$ProductionSummaryImpl _value,
    $Res Function(_$ProductionSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? critical = null,
    Object? low = null,
    Object? ok = null,
    Object? overstocked = null,
    Object? noVelocity = null,
    Object? totalSuggestedBatches = null,
    Object? cappedByMaterials = null,
  }) {
    return _then(
      _$ProductionSummaryImpl(
        critical: null == critical
            ? _value.critical
            : critical // ignore: cast_nullable_to_non_nullable
                  as int,
        low: null == low
            ? _value.low
            : low // ignore: cast_nullable_to_non_nullable
                  as int,
        ok: null == ok
            ? _value.ok
            : ok // ignore: cast_nullable_to_non_nullable
                  as int,
        overstocked: null == overstocked
            ? _value.overstocked
            : overstocked // ignore: cast_nullable_to_non_nullable
                  as int,
        noVelocity: null == noVelocity
            ? _value.noVelocity
            : noVelocity // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSuggestedBatches: null == totalSuggestedBatches
            ? _value.totalSuggestedBatches
            : totalSuggestedBatches // ignore: cast_nullable_to_non_nullable
                  as int,
        cappedByMaterials: null == cappedByMaterials
            ? _value.cappedByMaterials
            : cappedByMaterials // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionSummaryImpl extends _ProductionSummary {
  const _$ProductionSummaryImpl({
    this.critical = 0,
    this.low = 0,
    this.ok = 0,
    this.overstocked = 0,
    @JsonKey(name: 'no_velocity') this.noVelocity = 0,
    @JsonKey(name: 'total_suggested_batches') this.totalSuggestedBatches = 0,
    @JsonKey(name: 'capped_by_materials') this.cappedByMaterials = 0,
  }) : super._();

  factory _$ProductionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int critical;
  @override
  @JsonKey()
  final int low;
  @override
  @JsonKey()
  final int ok;
  @override
  @JsonKey()
  final int overstocked;
  @override
  @JsonKey(name: 'no_velocity')
  final int noVelocity;
  @override
  @JsonKey(name: 'total_suggested_batches')
  final int totalSuggestedBatches;
  @override
  @JsonKey(name: 'capped_by_materials')
  final int cappedByMaterials;

  @override
  String toString() {
    return 'ProductionSummary(critical: $critical, low: $low, ok: $ok, overstocked: $overstocked, noVelocity: $noVelocity, totalSuggestedBatches: $totalSuggestedBatches, cappedByMaterials: $cappedByMaterials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionSummaryImpl &&
            (identical(other.critical, critical) ||
                other.critical == critical) &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.ok, ok) || other.ok == ok) &&
            (identical(other.overstocked, overstocked) ||
                other.overstocked == overstocked) &&
            (identical(other.noVelocity, noVelocity) ||
                other.noVelocity == noVelocity) &&
            (identical(other.totalSuggestedBatches, totalSuggestedBatches) ||
                other.totalSuggestedBatches == totalSuggestedBatches) &&
            (identical(other.cappedByMaterials, cappedByMaterials) ||
                other.cappedByMaterials == cappedByMaterials));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    critical,
    low,
    ok,
    overstocked,
    noVelocity,
    totalSuggestedBatches,
    cappedByMaterials,
  );

  /// Create a copy of ProductionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionSummaryImplCopyWith<_$ProductionSummaryImpl> get copyWith =>
      __$$ProductionSummaryImplCopyWithImpl<_$ProductionSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionSummaryImplToJson(this);
  }
}

abstract class _ProductionSummary extends ProductionSummary {
  const factory _ProductionSummary({
    final int critical,
    final int low,
    final int ok,
    final int overstocked,
    @JsonKey(name: 'no_velocity') final int noVelocity,
    @JsonKey(name: 'total_suggested_batches') final int totalSuggestedBatches,
    @JsonKey(name: 'capped_by_materials') final int cappedByMaterials,
  }) = _$ProductionSummaryImpl;
  const _ProductionSummary._() : super._();

  factory _ProductionSummary.fromJson(Map<String, dynamic> json) =
      _$ProductionSummaryImpl.fromJson;

  @override
  int get critical;
  @override
  int get low;
  @override
  int get ok;
  @override
  int get overstocked;
  @override
  @JsonKey(name: 'no_velocity')
  int get noVelocity;
  @override
  @JsonKey(name: 'total_suggested_batches')
  int get totalSuggestedBatches;
  @override
  @JsonKey(name: 'capped_by_materials')
  int get cappedByMaterials;

  /// Create a copy of ProductionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionSummaryImplCopyWith<_$ProductionSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductionSuggestion _$ProductionSuggestionFromJson(Map<String, dynamic> json) {
  return _ProductionSuggestion.fromJson(json);
}

/// @nodoc
mixin _$ProductionSuggestion {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String? get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String get defaultBom => throw _privateConstructorUsedError;
  @JsonKey(name: 'bom_qty')
  double get bomQty => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_hand')
  double get onHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'velocity_30d')
  double get velocity30d => throw _privateConstructorUsedError;
  @JsonKey(name: 'velocity_60d')
  double get velocity60d => throw _privateConstructorUsedError;
  @JsonKey(name: 'velocity_trend')
  String? get velocityTrend => throw _privateConstructorUsedError;
  @JsonKey(name: 'season_multiplier')
  double get seasonMultiplier => throw _privateConstructorUsedError;
  @JsonKey(name: 'effective_velocity')
  double get effectiveVelocity => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_days')
  int get targetDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_days_source')
  String get targetDaysSource => throw _privateConstructorUsedError;

  /// Null means the item never sells — deliberately distinct from a large
  /// number, which the stored `jarz_days_of_stock` field cannot express.
  @JsonKey(name: 'days_of_cover')
  double? get daysOfCover => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Stock on hand is below zero. The suggestion deliberately ignores the
  /// hole — for a finished good a negative Bin almost always means unrecorded
  /// production or a count lag, not units owed to customers — so the row says
  /// so instead, and somebody counts the item.
  @JsonKey(name: 'stock_is_negative')
  bool get stockIsNegative => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_batches')
  int get suggestedBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_units')
  double get suggestedUnits => throw _privateConstructorUsedError;

  /// Null when capacity was not computed (`include_capacity=0`).
  @JsonKey(name: 'can_make_now_batches')
  int? get canMakeNowBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'limiting_component')
  LimitingComponent? get limitingComponent =>
      throw _privateConstructorUsedError;

  /// Serializes this ProductionSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductionSuggestionCopyWith<ProductionSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductionSuggestionCopyWith<$Res> {
  factory $ProductionSuggestionCopyWith(
    ProductionSuggestion value,
    $Res Function(ProductionSuggestion) then,
  ) = _$ProductionSuggestionCopyWithImpl<$Res, ProductionSuggestion>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
    String? company,
    @JsonKey(name: 'on_hand') double onHand,
    @JsonKey(name: 'velocity_30d') double velocity30d,
    @JsonKey(name: 'velocity_60d') double velocity60d,
    @JsonKey(name: 'velocity_trend') String? velocityTrend,
    @JsonKey(name: 'season_multiplier') double seasonMultiplier,
    @JsonKey(name: 'effective_velocity') double effectiveVelocity,
    @JsonKey(name: 'target_days') int targetDays,
    @JsonKey(name: 'target_days_source') String targetDaysSource,
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    String status,
    @JsonKey(name: 'stock_is_negative') bool stockIsNegative,
    @JsonKey(name: 'suggested_batches') int suggestedBatches,
    @JsonKey(name: 'suggested_units') double suggestedUnits,
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component') LimitingComponent? limitingComponent,
  });

  $LimitingComponentCopyWith<$Res>? get limitingComponent;
}

/// @nodoc
class _$ProductionSuggestionCopyWithImpl<
  $Res,
  $Val extends ProductionSuggestion
>
    implements $ProductionSuggestionCopyWith<$Res> {
  _$ProductionSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = freezed,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
    Object? company = freezed,
    Object? onHand = null,
    Object? velocity30d = null,
    Object? velocity60d = null,
    Object? velocityTrend = freezed,
    Object? seasonMultiplier = null,
    Object? effectiveVelocity = null,
    Object? targetDays = null,
    Object? targetDaysSource = null,
    Object? daysOfCover = freezed,
    Object? status = null,
    Object? stockIsNegative = null,
    Object? suggestedBatches = null,
    Object? suggestedUnits = null,
    Object? canMakeNowBatches = freezed,
    Object? limitingComponent = freezed,
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
            itemGroup: freezed == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            company: freezed == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String?,
            onHand: null == onHand
                ? _value.onHand
                : onHand // ignore: cast_nullable_to_non_nullable
                      as double,
            velocity30d: null == velocity30d
                ? _value.velocity30d
                : velocity30d // ignore: cast_nullable_to_non_nullable
                      as double,
            velocity60d: null == velocity60d
                ? _value.velocity60d
                : velocity60d // ignore: cast_nullable_to_non_nullable
                      as double,
            velocityTrend: freezed == velocityTrend
                ? _value.velocityTrend
                : velocityTrend // ignore: cast_nullable_to_non_nullable
                      as String?,
            seasonMultiplier: null == seasonMultiplier
                ? _value.seasonMultiplier
                : seasonMultiplier // ignore: cast_nullable_to_non_nullable
                      as double,
            effectiveVelocity: null == effectiveVelocity
                ? _value.effectiveVelocity
                : effectiveVelocity // ignore: cast_nullable_to_non_nullable
                      as double,
            targetDays: null == targetDays
                ? _value.targetDays
                : targetDays // ignore: cast_nullable_to_non_nullable
                      as int,
            targetDaysSource: null == targetDaysSource
                ? _value.targetDaysSource
                : targetDaysSource // ignore: cast_nullable_to_non_nullable
                      as String,
            daysOfCover: freezed == daysOfCover
                ? _value.daysOfCover
                : daysOfCover // ignore: cast_nullable_to_non_nullable
                      as double?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            stockIsNegative: null == stockIsNegative
                ? _value.stockIsNegative
                : stockIsNegative // ignore: cast_nullable_to_non_nullable
                      as bool,
            suggestedBatches: null == suggestedBatches
                ? _value.suggestedBatches
                : suggestedBatches // ignore: cast_nullable_to_non_nullable
                      as int,
            suggestedUnits: null == suggestedUnits
                ? _value.suggestedUnits
                : suggestedUnits // ignore: cast_nullable_to_non_nullable
                      as double,
            canMakeNowBatches: freezed == canMakeNowBatches
                ? _value.canMakeNowBatches
                : canMakeNowBatches // ignore: cast_nullable_to_non_nullable
                      as int?,
            limitingComponent: freezed == limitingComponent
                ? _value.limitingComponent
                : limitingComponent // ignore: cast_nullable_to_non_nullable
                      as LimitingComponent?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LimitingComponentCopyWith<$Res>? get limitingComponent {
    if (_value.limitingComponent == null) {
      return null;
    }

    return $LimitingComponentCopyWith<$Res>(_value.limitingComponent!, (value) {
      return _then(_value.copyWith(limitingComponent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductionSuggestionImplCopyWith<$Res>
    implements $ProductionSuggestionCopyWith<$Res> {
  factory _$$ProductionSuggestionImplCopyWith(
    _$ProductionSuggestionImpl value,
    $Res Function(_$ProductionSuggestionImpl) then,
  ) = __$$ProductionSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'bom_qty') double bomQty,
    String? company,
    @JsonKey(name: 'on_hand') double onHand,
    @JsonKey(name: 'velocity_30d') double velocity30d,
    @JsonKey(name: 'velocity_60d') double velocity60d,
    @JsonKey(name: 'velocity_trend') String? velocityTrend,
    @JsonKey(name: 'season_multiplier') double seasonMultiplier,
    @JsonKey(name: 'effective_velocity') double effectiveVelocity,
    @JsonKey(name: 'target_days') int targetDays,
    @JsonKey(name: 'target_days_source') String targetDaysSource,
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    String status,
    @JsonKey(name: 'stock_is_negative') bool stockIsNegative,
    @JsonKey(name: 'suggested_batches') int suggestedBatches,
    @JsonKey(name: 'suggested_units') double suggestedUnits,
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component') LimitingComponent? limitingComponent,
  });

  @override
  $LimitingComponentCopyWith<$Res>? get limitingComponent;
}

/// @nodoc
class __$$ProductionSuggestionImplCopyWithImpl<$Res>
    extends _$ProductionSuggestionCopyWithImpl<$Res, _$ProductionSuggestionImpl>
    implements _$$ProductionSuggestionImplCopyWith<$Res> {
  __$$ProductionSuggestionImplCopyWithImpl(
    _$ProductionSuggestionImpl _value,
    $Res Function(_$ProductionSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = freezed,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? bomQty = null,
    Object? company = freezed,
    Object? onHand = null,
    Object? velocity30d = null,
    Object? velocity60d = null,
    Object? velocityTrend = freezed,
    Object? seasonMultiplier = null,
    Object? effectiveVelocity = null,
    Object? targetDays = null,
    Object? targetDaysSource = null,
    Object? daysOfCover = freezed,
    Object? status = null,
    Object? stockIsNegative = null,
    Object? suggestedBatches = null,
    Object? suggestedUnits = null,
    Object? canMakeNowBatches = freezed,
    Object? limitingComponent = freezed,
  }) {
    return _then(
      _$ProductionSuggestionImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        itemGroup: freezed == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        company: freezed == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String?,
        onHand: null == onHand
            ? _value.onHand
            : onHand // ignore: cast_nullable_to_non_nullable
                  as double,
        velocity30d: null == velocity30d
            ? _value.velocity30d
            : velocity30d // ignore: cast_nullable_to_non_nullable
                  as double,
        velocity60d: null == velocity60d
            ? _value.velocity60d
            : velocity60d // ignore: cast_nullable_to_non_nullable
                  as double,
        velocityTrend: freezed == velocityTrend
            ? _value.velocityTrend
            : velocityTrend // ignore: cast_nullable_to_non_nullable
                  as String?,
        seasonMultiplier: null == seasonMultiplier
            ? _value.seasonMultiplier
            : seasonMultiplier // ignore: cast_nullable_to_non_nullable
                  as double,
        effectiveVelocity: null == effectiveVelocity
            ? _value.effectiveVelocity
            : effectiveVelocity // ignore: cast_nullable_to_non_nullable
                  as double,
        targetDays: null == targetDays
            ? _value.targetDays
            : targetDays // ignore: cast_nullable_to_non_nullable
                  as int,
        targetDaysSource: null == targetDaysSource
            ? _value.targetDaysSource
            : targetDaysSource // ignore: cast_nullable_to_non_nullable
                  as String,
        daysOfCover: freezed == daysOfCover
            ? _value.daysOfCover
            : daysOfCover // ignore: cast_nullable_to_non_nullable
                  as double?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        stockIsNegative: null == stockIsNegative
            ? _value.stockIsNegative
            : stockIsNegative // ignore: cast_nullable_to_non_nullable
                  as bool,
        suggestedBatches: null == suggestedBatches
            ? _value.suggestedBatches
            : suggestedBatches // ignore: cast_nullable_to_non_nullable
                  as int,
        suggestedUnits: null == suggestedUnits
            ? _value.suggestedUnits
            : suggestedUnits // ignore: cast_nullable_to_non_nullable
                  as double,
        canMakeNowBatches: freezed == canMakeNowBatches
            ? _value.canMakeNowBatches
            : canMakeNowBatches // ignore: cast_nullable_to_non_nullable
                  as int?,
        limitingComponent: freezed == limitingComponent
            ? _value.limitingComponent
            : limitingComponent // ignore: cast_nullable_to_non_nullable
                  as LimitingComponent?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductionSuggestionImpl extends _ProductionSuggestion {
  const _$ProductionSuggestionImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'item_group') this.itemGroup,
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    @JsonKey(name: 'default_bom') this.defaultBom = '',
    @JsonKey(name: 'bom_qty') this.bomQty = 1.0,
    this.company,
    @JsonKey(name: 'on_hand') this.onHand = 0.0,
    @JsonKey(name: 'velocity_30d') this.velocity30d = 0.0,
    @JsonKey(name: 'velocity_60d') this.velocity60d = 0.0,
    @JsonKey(name: 'velocity_trend') this.velocityTrend,
    @JsonKey(name: 'season_multiplier') this.seasonMultiplier = 1.0,
    @JsonKey(name: 'effective_velocity') this.effectiveVelocity = 0.0,
    @JsonKey(name: 'target_days') this.targetDays = 7,
    @JsonKey(name: 'target_days_source') this.targetDaysSource = 'default',
    @JsonKey(name: 'days_of_cover') this.daysOfCover,
    this.status = ProductionStatus.ok,
    @JsonKey(name: 'stock_is_negative') this.stockIsNegative = false,
    @JsonKey(name: 'suggested_batches') this.suggestedBatches = 0,
    @JsonKey(name: 'suggested_units') this.suggestedUnits = 0.0,
    @JsonKey(name: 'can_make_now_batches') this.canMakeNowBatches,
    @JsonKey(name: 'limiting_component') this.limitingComponent,
  }) : super._();

  factory _$ProductionSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductionSuggestionImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_group')
  final String? itemGroup;
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
  final String? company;
  @override
  @JsonKey(name: 'on_hand')
  final double onHand;
  @override
  @JsonKey(name: 'velocity_30d')
  final double velocity30d;
  @override
  @JsonKey(name: 'velocity_60d')
  final double velocity60d;
  @override
  @JsonKey(name: 'velocity_trend')
  final String? velocityTrend;
  @override
  @JsonKey(name: 'season_multiplier')
  final double seasonMultiplier;
  @override
  @JsonKey(name: 'effective_velocity')
  final double effectiveVelocity;
  @override
  @JsonKey(name: 'target_days')
  final int targetDays;
  @override
  @JsonKey(name: 'target_days_source')
  final String targetDaysSource;

  /// Null means the item never sells — deliberately distinct from a large
  /// number, which the stored `jarz_days_of_stock` field cannot express.
  @override
  @JsonKey(name: 'days_of_cover')
  final double? daysOfCover;
  @override
  @JsonKey()
  final String status;

  /// Stock on hand is below zero. The suggestion deliberately ignores the
  /// hole — for a finished good a negative Bin almost always means unrecorded
  /// production or a count lag, not units owed to customers — so the row says
  /// so instead, and somebody counts the item.
  @override
  @JsonKey(name: 'stock_is_negative')
  final bool stockIsNegative;
  @override
  @JsonKey(name: 'suggested_batches')
  final int suggestedBatches;
  @override
  @JsonKey(name: 'suggested_units')
  final double suggestedUnits;

  /// Null when capacity was not computed (`include_capacity=0`).
  @override
  @JsonKey(name: 'can_make_now_batches')
  final int? canMakeNowBatches;
  @override
  @JsonKey(name: 'limiting_component')
  final LimitingComponent? limitingComponent;

  @override
  String toString() {
    return 'ProductionSuggestion(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, stockUom: $stockUom, defaultBom: $defaultBom, bomQty: $bomQty, company: $company, onHand: $onHand, velocity30d: $velocity30d, velocity60d: $velocity60d, velocityTrend: $velocityTrend, seasonMultiplier: $seasonMultiplier, effectiveVelocity: $effectiveVelocity, targetDays: $targetDays, targetDaysSource: $targetDaysSource, daysOfCover: $daysOfCover, status: $status, stockIsNegative: $stockIsNegative, suggestedBatches: $suggestedBatches, suggestedUnits: $suggestedUnits, canMakeNowBatches: $canMakeNowBatches, limitingComponent: $limitingComponent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductionSuggestionImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.bomQty, bomQty) || other.bomQty == bomQty) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.onHand, onHand) || other.onHand == onHand) &&
            (identical(other.velocity30d, velocity30d) ||
                other.velocity30d == velocity30d) &&
            (identical(other.velocity60d, velocity60d) ||
                other.velocity60d == velocity60d) &&
            (identical(other.velocityTrend, velocityTrend) ||
                other.velocityTrend == velocityTrend) &&
            (identical(other.seasonMultiplier, seasonMultiplier) ||
                other.seasonMultiplier == seasonMultiplier) &&
            (identical(other.effectiveVelocity, effectiveVelocity) ||
                other.effectiveVelocity == effectiveVelocity) &&
            (identical(other.targetDays, targetDays) ||
                other.targetDays == targetDays) &&
            (identical(other.targetDaysSource, targetDaysSource) ||
                other.targetDaysSource == targetDaysSource) &&
            (identical(other.daysOfCover, daysOfCover) ||
                other.daysOfCover == daysOfCover) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stockIsNegative, stockIsNegative) ||
                other.stockIsNegative == stockIsNegative) &&
            (identical(other.suggestedBatches, suggestedBatches) ||
                other.suggestedBatches == suggestedBatches) &&
            (identical(other.suggestedUnits, suggestedUnits) ||
                other.suggestedUnits == suggestedUnits) &&
            (identical(other.canMakeNowBatches, canMakeNowBatches) ||
                other.canMakeNowBatches == canMakeNowBatches) &&
            (identical(other.limitingComponent, limitingComponent) ||
                other.limitingComponent == limitingComponent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    itemCode,
    itemName,
    itemGroup,
    stockUom,
    defaultBom,
    bomQty,
    company,
    onHand,
    velocity30d,
    velocity60d,
    velocityTrend,
    seasonMultiplier,
    effectiveVelocity,
    targetDays,
    targetDaysSource,
    daysOfCover,
    status,
    stockIsNegative,
    suggestedBatches,
    suggestedUnits,
    canMakeNowBatches,
    limitingComponent,
  ]);

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductionSuggestionImplCopyWith<_$ProductionSuggestionImpl>
  get copyWith =>
      __$$ProductionSuggestionImplCopyWithImpl<_$ProductionSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductionSuggestionImplToJson(this);
  }
}

abstract class _ProductionSuggestion extends ProductionSuggestion {
  const factory _ProductionSuggestion({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'item_group') final String? itemGroup,
    @JsonKey(name: 'stock_uom') final String stockUom,
    @JsonKey(name: 'default_bom') final String defaultBom,
    @JsonKey(name: 'bom_qty') final double bomQty,
    final String? company,
    @JsonKey(name: 'on_hand') final double onHand,
    @JsonKey(name: 'velocity_30d') final double velocity30d,
    @JsonKey(name: 'velocity_60d') final double velocity60d,
    @JsonKey(name: 'velocity_trend') final String? velocityTrend,
    @JsonKey(name: 'season_multiplier') final double seasonMultiplier,
    @JsonKey(name: 'effective_velocity') final double effectiveVelocity,
    @JsonKey(name: 'target_days') final int targetDays,
    @JsonKey(name: 'target_days_source') final String targetDaysSource,
    @JsonKey(name: 'days_of_cover') final double? daysOfCover,
    final String status,
    @JsonKey(name: 'stock_is_negative') final bool stockIsNegative,
    @JsonKey(name: 'suggested_batches') final int suggestedBatches,
    @JsonKey(name: 'suggested_units') final double suggestedUnits,
    @JsonKey(name: 'can_make_now_batches') final int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component')
    final LimitingComponent? limitingComponent,
  }) = _$ProductionSuggestionImpl;
  const _ProductionSuggestion._() : super._();

  factory _ProductionSuggestion.fromJson(Map<String, dynamic> json) =
      _$ProductionSuggestionImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_group')
  String? get itemGroup;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  @JsonKey(name: 'default_bom')
  String get defaultBom;
  @override
  @JsonKey(name: 'bom_qty')
  double get bomQty;
  @override
  String? get company;
  @override
  @JsonKey(name: 'on_hand')
  double get onHand;
  @override
  @JsonKey(name: 'velocity_30d')
  double get velocity30d;
  @override
  @JsonKey(name: 'velocity_60d')
  double get velocity60d;
  @override
  @JsonKey(name: 'velocity_trend')
  String? get velocityTrend;
  @override
  @JsonKey(name: 'season_multiplier')
  double get seasonMultiplier;
  @override
  @JsonKey(name: 'effective_velocity')
  double get effectiveVelocity;
  @override
  @JsonKey(name: 'target_days')
  int get targetDays;
  @override
  @JsonKey(name: 'target_days_source')
  String get targetDaysSource;

  /// Null means the item never sells — deliberately distinct from a large
  /// number, which the stored `jarz_days_of_stock` field cannot express.
  @override
  @JsonKey(name: 'days_of_cover')
  double? get daysOfCover;
  @override
  String get status;

  /// Stock on hand is below zero. The suggestion deliberately ignores the
  /// hole — for a finished good a negative Bin almost always means unrecorded
  /// production or a count lag, not units owed to customers — so the row says
  /// so instead, and somebody counts the item.
  @override
  @JsonKey(name: 'stock_is_negative')
  bool get stockIsNegative;
  @override
  @JsonKey(name: 'suggested_batches')
  int get suggestedBatches;
  @override
  @JsonKey(name: 'suggested_units')
  double get suggestedUnits;

  /// Null when capacity was not computed (`include_capacity=0`).
  @override
  @JsonKey(name: 'can_make_now_batches')
  int? get canMakeNowBatches;
  @override
  @JsonKey(name: 'limiting_component')
  LimitingComponent? get limitingComponent;

  /// Create a copy of ProductionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductionSuggestionImplCopyWith<_$ProductionSuggestionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LimitingComponent _$LimitingComponentFromJson(Map<String, dynamic> json) {
  return _LimitingComponent.fromJson(json);
}

/// @nodoc
mixin _$LimitingComponent {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_qty')
  double get requiredQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double get availableQty => throw _privateConstructorUsedError;

  /// `insufficient_stock` or `missing_source_warehouse`.
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this LimitingComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LimitingComponentCopyWith<LimitingComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LimitingComponentCopyWith<$Res> {
  factory $LimitingComponentCopyWith(
    LimitingComponent value,
    $Res Function(LimitingComponent) then,
  ) = _$LimitingComponentCopyWithImpl<$Res, LimitingComponent>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    String reason,
  });
}

/// @nodoc
class _$LimitingComponentCopyWithImpl<$Res, $Val extends LimitingComponent>
    implements $LimitingComponentCopyWith<$Res> {
  _$LimitingComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? sourceWarehouse = freezed,
    Object? requiredQty = null,
    Object? availableQty = null,
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
            sourceWarehouse: freezed == sourceWarehouse
                ? _value.sourceWarehouse
                : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            requiredQty: null == requiredQty
                ? _value.requiredQty
                : requiredQty // ignore: cast_nullable_to_non_nullable
                      as double,
            availableQty: null == availableQty
                ? _value.availableQty
                : availableQty // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LimitingComponentImplCopyWith<$Res>
    implements $LimitingComponentCopyWith<$Res> {
  factory _$$LimitingComponentImplCopyWith(
    _$LimitingComponentImpl value,
    $Res Function(_$LimitingComponentImpl) then,
  ) = __$$LimitingComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'available_qty') double availableQty,
    String reason,
  });
}

/// @nodoc
class __$$LimitingComponentImplCopyWithImpl<$Res>
    extends _$LimitingComponentCopyWithImpl<$Res, _$LimitingComponentImpl>
    implements _$$LimitingComponentImplCopyWith<$Res> {
  __$$LimitingComponentImplCopyWithImpl(
    _$LimitingComponentImpl _value,
    $Res Function(_$LimitingComponentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? sourceWarehouse = freezed,
    Object? requiredQty = null,
    Object? availableQty = null,
    Object? reason = null,
  }) {
    return _then(
      _$LimitingComponentImpl(
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
        sourceWarehouse: freezed == sourceWarehouse
            ? _value.sourceWarehouse
            : sourceWarehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        requiredQty: null == requiredQty
            ? _value.requiredQty
            : requiredQty // ignore: cast_nullable_to_non_nullable
                  as double,
        availableQty: null == availableQty
            ? _value.availableQty
            : availableQty // ignore: cast_nullable_to_non_nullable
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
class _$LimitingComponentImpl extends _LimitingComponent {
  const _$LimitingComponentImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.uom = '',
    @JsonKey(name: 'source_warehouse') this.sourceWarehouse,
    @JsonKey(name: 'required_qty') this.requiredQty = 0.0,
    @JsonKey(name: 'available_qty') this.availableQty = 0.0,
    this.reason = 'insufficient_stock',
  }) : super._();

  factory _$LimitingComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$LimitingComponentImplFromJson(json);

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
  @JsonKey(name: 'source_warehouse')
  final String? sourceWarehouse;
  @override
  @JsonKey(name: 'required_qty')
  final double requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  final double availableQty;

  /// `insufficient_stock` or `missing_source_warehouse`.
  @override
  @JsonKey()
  final String reason;

  @override
  String toString() {
    return 'LimitingComponent(itemCode: $itemCode, itemName: $itemName, uom: $uom, sourceWarehouse: $sourceWarehouse, requiredQty: $requiredQty, availableQty: $availableQty, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LimitingComponentImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.sourceWarehouse, sourceWarehouse) ||
                other.sourceWarehouse == sourceWarehouse) &&
            (identical(other.requiredQty, requiredQty) ||
                other.requiredQty == requiredQty) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    uom,
    sourceWarehouse,
    requiredQty,
    availableQty,
    reason,
  );

  /// Create a copy of LimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LimitingComponentImplCopyWith<_$LimitingComponentImpl> get copyWith =>
      __$$LimitingComponentImplCopyWithImpl<_$LimitingComponentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LimitingComponentImplToJson(this);
  }
}

abstract class _LimitingComponent extends LimitingComponent {
  const factory _LimitingComponent({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String uom,
    @JsonKey(name: 'source_warehouse') final String? sourceWarehouse,
    @JsonKey(name: 'required_qty') final double requiredQty,
    @JsonKey(name: 'available_qty') final double availableQty,
    final String reason,
  }) = _$LimitingComponentImpl;
  const _LimitingComponent._() : super._();

  factory _LimitingComponent.fromJson(Map<String, dynamic> json) =
      _$LimitingComponentImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String get uom;
  @override
  @JsonKey(name: 'source_warehouse')
  String? get sourceWarehouse;
  @override
  @JsonKey(name: 'required_qty')
  double get requiredQty;
  @override
  @JsonKey(name: 'available_qty')
  double get availableQty;

  /// `insufficient_stock` or `missing_source_warehouse`.
  @override
  String get reason;

  /// Create a copy of LimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LimitingComponentImplCopyWith<_$LimitingComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
