// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_intelligence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InventoryIntelligence _$InventoryIntelligenceFromJson(
  Map<String, dynamic> json,
) {
  return _InventoryIntelligence.fromJson(json);
}

/// @nodoc
mixin _$InventoryIntelligence {
  Map<String, dynamic> get period => throw _privateConstructorUsedError;
  InventorySummary get summary => throw _privateConstructorUsedError;
  InventoryAlerts get alerts => throw _privateConstructorUsedError;
  @JsonKey(name: 'velocity_distribution')
  List<JsonMap> get velocityDistribution => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_movers')
  List<JsonMap> get topMovers => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_sold_in_range')
  List<JsonMap> get topSoldInRange => throw _privateConstructorUsedError;

  /// Serializes this InventoryIntelligence to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryIntelligenceCopyWith<InventoryIntelligence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryIntelligenceCopyWith<$Res> {
  factory $InventoryIntelligenceCopyWith(
    InventoryIntelligence value,
    $Res Function(InventoryIntelligence) then,
  ) = _$InventoryIntelligenceCopyWithImpl<$Res, InventoryIntelligence>;
  @useResult
  $Res call({
    Map<String, dynamic> period,
    InventorySummary summary,
    InventoryAlerts alerts,
    @JsonKey(name: 'velocity_distribution') List<JsonMap> velocityDistribution,
    @JsonKey(name: 'top_movers') List<JsonMap> topMovers,
    @JsonKey(name: 'top_sold_in_range') List<JsonMap> topSoldInRange,
  });

  $InventorySummaryCopyWith<$Res> get summary;
  $InventoryAlertsCopyWith<$Res> get alerts;
}

/// @nodoc
class _$InventoryIntelligenceCopyWithImpl<
  $Res,
  $Val extends InventoryIntelligence
>
    implements $InventoryIntelligenceCopyWith<$Res> {
  _$InventoryIntelligenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? alerts = null,
    Object? velocityDistribution = null,
    Object? topMovers = null,
    Object? topSoldInRange = null,
  }) {
    return _then(
      _value.copyWith(
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as InventorySummary,
            alerts: null == alerts
                ? _value.alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                      as InventoryAlerts,
            velocityDistribution: null == velocityDistribution
                ? _value.velocityDistribution
                : velocityDistribution // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            topMovers: null == topMovers
                ? _value.topMovers
                : topMovers // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            topSoldInRange: null == topSoldInRange
                ? _value.topSoldInRange
                : topSoldInRange // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InventorySummaryCopyWith<$Res> get summary {
    return $InventorySummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InventoryAlertsCopyWith<$Res> get alerts {
    return $InventoryAlertsCopyWith<$Res>(_value.alerts, (value) {
      return _then(_value.copyWith(alerts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InventoryIntelligenceImplCopyWith<$Res>
    implements $InventoryIntelligenceCopyWith<$Res> {
  factory _$$InventoryIntelligenceImplCopyWith(
    _$InventoryIntelligenceImpl value,
    $Res Function(_$InventoryIntelligenceImpl) then,
  ) = __$$InventoryIntelligenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic> period,
    InventorySummary summary,
    InventoryAlerts alerts,
    @JsonKey(name: 'velocity_distribution') List<JsonMap> velocityDistribution,
    @JsonKey(name: 'top_movers') List<JsonMap> topMovers,
    @JsonKey(name: 'top_sold_in_range') List<JsonMap> topSoldInRange,
  });

  @override
  $InventorySummaryCopyWith<$Res> get summary;
  @override
  $InventoryAlertsCopyWith<$Res> get alerts;
}

/// @nodoc
class __$$InventoryIntelligenceImplCopyWithImpl<$Res>
    extends
        _$InventoryIntelligenceCopyWithImpl<$Res, _$InventoryIntelligenceImpl>
    implements _$$InventoryIntelligenceImplCopyWith<$Res> {
  __$$InventoryIntelligenceImplCopyWithImpl(
    _$InventoryIntelligenceImpl _value,
    $Res Function(_$InventoryIntelligenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? alerts = null,
    Object? velocityDistribution = null,
    Object? topMovers = null,
    Object? topSoldInRange = null,
  }) {
    return _then(
      _$InventoryIntelligenceImpl(
        period: null == period
            ? _value._period
            : period // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as InventorySummary,
        alerts: null == alerts
            ? _value.alerts
            : alerts // ignore: cast_nullable_to_non_nullable
                  as InventoryAlerts,
        velocityDistribution: null == velocityDistribution
            ? _value._velocityDistribution
            : velocityDistribution // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        topMovers: null == topMovers
            ? _value._topMovers
            : topMovers // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        topSoldInRange: null == topSoldInRange
            ? _value._topSoldInRange
            : topSoldInRange // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryIntelligenceImpl implements _InventoryIntelligence {
  const _$InventoryIntelligenceImpl({
    final Map<String, dynamic> period = const <String, dynamic>{},
    this.summary = const InventorySummary(),
    this.alerts = const InventoryAlerts(),
    @JsonKey(name: 'velocity_distribution')
    final List<JsonMap> velocityDistribution = const <JsonMap>[],
    @JsonKey(name: 'top_movers')
    final List<JsonMap> topMovers = const <JsonMap>[],
    @JsonKey(name: 'top_sold_in_range')
    final List<JsonMap> topSoldInRange = const <JsonMap>[],
  }) : _period = period,
       _velocityDistribution = velocityDistribution,
       _topMovers = topMovers,
       _topSoldInRange = topSoldInRange;

  factory _$InventoryIntelligenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryIntelligenceImplFromJson(json);

  final Map<String, dynamic> _period;
  @override
  @JsonKey()
  Map<String, dynamic> get period {
    if (_period is EqualUnmodifiableMapView) return _period;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_period);
  }

  @override
  @JsonKey()
  final InventorySummary summary;
  @override
  @JsonKey()
  final InventoryAlerts alerts;
  final List<JsonMap> _velocityDistribution;
  @override
  @JsonKey(name: 'velocity_distribution')
  List<JsonMap> get velocityDistribution {
    if (_velocityDistribution is EqualUnmodifiableListView)
      return _velocityDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_velocityDistribution);
  }

  final List<JsonMap> _topMovers;
  @override
  @JsonKey(name: 'top_movers')
  List<JsonMap> get topMovers {
    if (_topMovers is EqualUnmodifiableListView) return _topMovers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topMovers);
  }

  final List<JsonMap> _topSoldInRange;
  @override
  @JsonKey(name: 'top_sold_in_range')
  List<JsonMap> get topSoldInRange {
    if (_topSoldInRange is EqualUnmodifiableListView) return _topSoldInRange;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topSoldInRange);
  }

  @override
  String toString() {
    return 'InventoryIntelligence(period: $period, summary: $summary, alerts: $alerts, velocityDistribution: $velocityDistribution, topMovers: $topMovers, topSoldInRange: $topSoldInRange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryIntelligenceImpl &&
            const DeepCollectionEquality().equals(other._period, _period) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.alerts, alerts) || other.alerts == alerts) &&
            const DeepCollectionEquality().equals(
              other._velocityDistribution,
              _velocityDistribution,
            ) &&
            const DeepCollectionEquality().equals(
              other._topMovers,
              _topMovers,
            ) &&
            const DeepCollectionEquality().equals(
              other._topSoldInRange,
              _topSoldInRange,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_period),
    summary,
    alerts,
    const DeepCollectionEquality().hash(_velocityDistribution),
    const DeepCollectionEquality().hash(_topMovers),
    const DeepCollectionEquality().hash(_topSoldInRange),
  );

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryIntelligenceImplCopyWith<_$InventoryIntelligenceImpl>
  get copyWith =>
      __$$InventoryIntelligenceImplCopyWithImpl<_$InventoryIntelligenceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryIntelligenceImplToJson(this);
  }
}

abstract class _InventoryIntelligence implements InventoryIntelligence {
  const factory _InventoryIntelligence({
    final Map<String, dynamic> period,
    final InventorySummary summary,
    final InventoryAlerts alerts,
    @JsonKey(name: 'velocity_distribution')
    final List<JsonMap> velocityDistribution,
    @JsonKey(name: 'top_movers') final List<JsonMap> topMovers,
    @JsonKey(name: 'top_sold_in_range') final List<JsonMap> topSoldInRange,
  }) = _$InventoryIntelligenceImpl;

  factory _InventoryIntelligence.fromJson(Map<String, dynamic> json) =
      _$InventoryIntelligenceImpl.fromJson;

  @override
  Map<String, dynamic> get period;
  @override
  InventorySummary get summary;
  @override
  InventoryAlerts get alerts;
  @override
  @JsonKey(name: 'velocity_distribution')
  List<JsonMap> get velocityDistribution;
  @override
  @JsonKey(name: 'top_movers')
  List<JsonMap> get topMovers;
  @override
  @JsonKey(name: 'top_sold_in_range')
  List<JsonMap> get topSoldInRange;

  /// Create a copy of InventoryIntelligence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryIntelligenceImplCopyWith<_$InventoryIntelligenceImpl>
  get copyWith => throw _privateConstructorUsedError;
}

InventorySummary _$InventorySummaryFromJson(Map<String, dynamic> json) {
  return _InventorySummary.fromJson(json);
}

/// @nodoc
mixin _$InventorySummary {
  @JsonKey(name: 'total_stock_items')
  int get totalStockItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'critical_count')
  int get criticalCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'watch_count')
  int get watchCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'slow_count')
  int get slowCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overstock_count')
  int get overstockCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_stock_value')
  double get totalStockValue => throw _privateConstructorUsedError;

  /// Serializes this InventorySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventorySummaryCopyWith<InventorySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventorySummaryCopyWith<$Res> {
  factory $InventorySummaryCopyWith(
    InventorySummary value,
    $Res Function(InventorySummary) then,
  ) = _$InventorySummaryCopyWithImpl<$Res, InventorySummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_stock_items') int totalStockItems,
    @JsonKey(name: 'critical_count') int criticalCount,
    @JsonKey(name: 'watch_count') int watchCount,
    @JsonKey(name: 'slow_count') int slowCount,
    @JsonKey(name: 'overstock_count') int overstockCount,
    @JsonKey(name: 'total_stock_value') double totalStockValue,
  });
}

/// @nodoc
class _$InventorySummaryCopyWithImpl<$Res, $Val extends InventorySummary>
    implements $InventorySummaryCopyWith<$Res> {
  _$InventorySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalStockItems = null,
    Object? criticalCount = null,
    Object? watchCount = null,
    Object? slowCount = null,
    Object? overstockCount = null,
    Object? totalStockValue = null,
  }) {
    return _then(
      _value.copyWith(
            totalStockItems: null == totalStockItems
                ? _value.totalStockItems
                : totalStockItems // ignore: cast_nullable_to_non_nullable
                      as int,
            criticalCount: null == criticalCount
                ? _value.criticalCount
                : criticalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            watchCount: null == watchCount
                ? _value.watchCount
                : watchCount // ignore: cast_nullable_to_non_nullable
                      as int,
            slowCount: null == slowCount
                ? _value.slowCount
                : slowCount // ignore: cast_nullable_to_non_nullable
                      as int,
            overstockCount: null == overstockCount
                ? _value.overstockCount
                : overstockCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStockValue: null == totalStockValue
                ? _value.totalStockValue
                : totalStockValue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventorySummaryImplCopyWith<$Res>
    implements $InventorySummaryCopyWith<$Res> {
  factory _$$InventorySummaryImplCopyWith(
    _$InventorySummaryImpl value,
    $Res Function(_$InventorySummaryImpl) then,
  ) = __$$InventorySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_stock_items') int totalStockItems,
    @JsonKey(name: 'critical_count') int criticalCount,
    @JsonKey(name: 'watch_count') int watchCount,
    @JsonKey(name: 'slow_count') int slowCount,
    @JsonKey(name: 'overstock_count') int overstockCount,
    @JsonKey(name: 'total_stock_value') double totalStockValue,
  });
}

/// @nodoc
class __$$InventorySummaryImplCopyWithImpl<$Res>
    extends _$InventorySummaryCopyWithImpl<$Res, _$InventorySummaryImpl>
    implements _$$InventorySummaryImplCopyWith<$Res> {
  __$$InventorySummaryImplCopyWithImpl(
    _$InventorySummaryImpl _value,
    $Res Function(_$InventorySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalStockItems = null,
    Object? criticalCount = null,
    Object? watchCount = null,
    Object? slowCount = null,
    Object? overstockCount = null,
    Object? totalStockValue = null,
  }) {
    return _then(
      _$InventorySummaryImpl(
        totalStockItems: null == totalStockItems
            ? _value.totalStockItems
            : totalStockItems // ignore: cast_nullable_to_non_nullable
                  as int,
        criticalCount: null == criticalCount
            ? _value.criticalCount
            : criticalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        watchCount: null == watchCount
            ? _value.watchCount
            : watchCount // ignore: cast_nullable_to_non_nullable
                  as int,
        slowCount: null == slowCount
            ? _value.slowCount
            : slowCount // ignore: cast_nullable_to_non_nullable
                  as int,
        overstockCount: null == overstockCount
            ? _value.overstockCount
            : overstockCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStockValue: null == totalStockValue
            ? _value.totalStockValue
            : totalStockValue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventorySummaryImpl implements _InventorySummary {
  const _$InventorySummaryImpl({
    @JsonKey(name: 'total_stock_items') this.totalStockItems = 0,
    @JsonKey(name: 'critical_count') this.criticalCount = 0,
    @JsonKey(name: 'watch_count') this.watchCount = 0,
    @JsonKey(name: 'slow_count') this.slowCount = 0,
    @JsonKey(name: 'overstock_count') this.overstockCount = 0,
    @JsonKey(name: 'total_stock_value') this.totalStockValue = 0,
  });

  factory _$InventorySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventorySummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_stock_items')
  final int totalStockItems;
  @override
  @JsonKey(name: 'critical_count')
  final int criticalCount;
  @override
  @JsonKey(name: 'watch_count')
  final int watchCount;
  @override
  @JsonKey(name: 'slow_count')
  final int slowCount;
  @override
  @JsonKey(name: 'overstock_count')
  final int overstockCount;
  @override
  @JsonKey(name: 'total_stock_value')
  final double totalStockValue;

  @override
  String toString() {
    return 'InventorySummary(totalStockItems: $totalStockItems, criticalCount: $criticalCount, watchCount: $watchCount, slowCount: $slowCount, overstockCount: $overstockCount, totalStockValue: $totalStockValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventorySummaryImpl &&
            (identical(other.totalStockItems, totalStockItems) ||
                other.totalStockItems == totalStockItems) &&
            (identical(other.criticalCount, criticalCount) ||
                other.criticalCount == criticalCount) &&
            (identical(other.watchCount, watchCount) ||
                other.watchCount == watchCount) &&
            (identical(other.slowCount, slowCount) ||
                other.slowCount == slowCount) &&
            (identical(other.overstockCount, overstockCount) ||
                other.overstockCount == overstockCount) &&
            (identical(other.totalStockValue, totalStockValue) ||
                other.totalStockValue == totalStockValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalStockItems,
    criticalCount,
    watchCount,
    slowCount,
    overstockCount,
    totalStockValue,
  );

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventorySummaryImplCopyWith<_$InventorySummaryImpl> get copyWith =>
      __$$InventorySummaryImplCopyWithImpl<_$InventorySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventorySummaryImplToJson(this);
  }
}

abstract class _InventorySummary implements InventorySummary {
  const factory _InventorySummary({
    @JsonKey(name: 'total_stock_items') final int totalStockItems,
    @JsonKey(name: 'critical_count') final int criticalCount,
    @JsonKey(name: 'watch_count') final int watchCount,
    @JsonKey(name: 'slow_count') final int slowCount,
    @JsonKey(name: 'overstock_count') final int overstockCount,
    @JsonKey(name: 'total_stock_value') final double totalStockValue,
  }) = _$InventorySummaryImpl;

  factory _InventorySummary.fromJson(Map<String, dynamic> json) =
      _$InventorySummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_stock_items')
  int get totalStockItems;
  @override
  @JsonKey(name: 'critical_count')
  int get criticalCount;
  @override
  @JsonKey(name: 'watch_count')
  int get watchCount;
  @override
  @JsonKey(name: 'slow_count')
  int get slowCount;
  @override
  @JsonKey(name: 'overstock_count')
  int get overstockCount;
  @override
  @JsonKey(name: 'total_stock_value')
  double get totalStockValue;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventorySummaryImplCopyWith<_$InventorySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryAlerts _$InventoryAlertsFromJson(Map<String, dynamic> json) {
  return _InventoryAlerts.fromJson(json);
}

/// @nodoc
mixin _$InventoryAlerts {
  List<JsonMap> get critical => throw _privateConstructorUsedError;
  @JsonKey(name: 'watch_list')
  List<JsonMap> get watchList => throw _privateConstructorUsedError;
  @JsonKey(name: 'slow_movers')
  List<JsonMap> get slowMovers => throw _privateConstructorUsedError;
  List<JsonMap> get overstocked => throw _privateConstructorUsedError;

  /// Serializes this InventoryAlerts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryAlerts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryAlertsCopyWith<InventoryAlerts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryAlertsCopyWith<$Res> {
  factory $InventoryAlertsCopyWith(
    InventoryAlerts value,
    $Res Function(InventoryAlerts) then,
  ) = _$InventoryAlertsCopyWithImpl<$Res, InventoryAlerts>;
  @useResult
  $Res call({
    List<JsonMap> critical,
    @JsonKey(name: 'watch_list') List<JsonMap> watchList,
    @JsonKey(name: 'slow_movers') List<JsonMap> slowMovers,
    List<JsonMap> overstocked,
  });
}

/// @nodoc
class _$InventoryAlertsCopyWithImpl<$Res, $Val extends InventoryAlerts>
    implements $InventoryAlertsCopyWith<$Res> {
  _$InventoryAlertsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryAlerts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? critical = null,
    Object? watchList = null,
    Object? slowMovers = null,
    Object? overstocked = null,
  }) {
    return _then(
      _value.copyWith(
            critical: null == critical
                ? _value.critical
                : critical // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            watchList: null == watchList
                ? _value.watchList
                : watchList // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            slowMovers: null == slowMovers
                ? _value.slowMovers
                : slowMovers // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            overstocked: null == overstocked
                ? _value.overstocked
                : overstocked // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryAlertsImplCopyWith<$Res>
    implements $InventoryAlertsCopyWith<$Res> {
  factory _$$InventoryAlertsImplCopyWith(
    _$InventoryAlertsImpl value,
    $Res Function(_$InventoryAlertsImpl) then,
  ) = __$$InventoryAlertsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<JsonMap> critical,
    @JsonKey(name: 'watch_list') List<JsonMap> watchList,
    @JsonKey(name: 'slow_movers') List<JsonMap> slowMovers,
    List<JsonMap> overstocked,
  });
}

/// @nodoc
class __$$InventoryAlertsImplCopyWithImpl<$Res>
    extends _$InventoryAlertsCopyWithImpl<$Res, _$InventoryAlertsImpl>
    implements _$$InventoryAlertsImplCopyWith<$Res> {
  __$$InventoryAlertsImplCopyWithImpl(
    _$InventoryAlertsImpl _value,
    $Res Function(_$InventoryAlertsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryAlerts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? critical = null,
    Object? watchList = null,
    Object? slowMovers = null,
    Object? overstocked = null,
  }) {
    return _then(
      _$InventoryAlertsImpl(
        critical: null == critical
            ? _value._critical
            : critical // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        watchList: null == watchList
            ? _value._watchList
            : watchList // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        slowMovers: null == slowMovers
            ? _value._slowMovers
            : slowMovers // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        overstocked: null == overstocked
            ? _value._overstocked
            : overstocked // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryAlertsImpl implements _InventoryAlerts {
  const _$InventoryAlertsImpl({
    final List<JsonMap> critical = const <JsonMap>[],
    @JsonKey(name: 'watch_list')
    final List<JsonMap> watchList = const <JsonMap>[],
    @JsonKey(name: 'slow_movers')
    final List<JsonMap> slowMovers = const <JsonMap>[],
    final List<JsonMap> overstocked = const <JsonMap>[],
  }) : _critical = critical,
       _watchList = watchList,
       _slowMovers = slowMovers,
       _overstocked = overstocked;

  factory _$InventoryAlertsImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryAlertsImplFromJson(json);

  final List<JsonMap> _critical;
  @override
  @JsonKey()
  List<JsonMap> get critical {
    if (_critical is EqualUnmodifiableListView) return _critical;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_critical);
  }

  final List<JsonMap> _watchList;
  @override
  @JsonKey(name: 'watch_list')
  List<JsonMap> get watchList {
    if (_watchList is EqualUnmodifiableListView) return _watchList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_watchList);
  }

  final List<JsonMap> _slowMovers;
  @override
  @JsonKey(name: 'slow_movers')
  List<JsonMap> get slowMovers {
    if (_slowMovers is EqualUnmodifiableListView) return _slowMovers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slowMovers);
  }

  final List<JsonMap> _overstocked;
  @override
  @JsonKey()
  List<JsonMap> get overstocked {
    if (_overstocked is EqualUnmodifiableListView) return _overstocked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_overstocked);
  }

  @override
  String toString() {
    return 'InventoryAlerts(critical: $critical, watchList: $watchList, slowMovers: $slowMovers, overstocked: $overstocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryAlertsImpl &&
            const DeepCollectionEquality().equals(other._critical, _critical) &&
            const DeepCollectionEquality().equals(
              other._watchList,
              _watchList,
            ) &&
            const DeepCollectionEquality().equals(
              other._slowMovers,
              _slowMovers,
            ) &&
            const DeepCollectionEquality().equals(
              other._overstocked,
              _overstocked,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_critical),
    const DeepCollectionEquality().hash(_watchList),
    const DeepCollectionEquality().hash(_slowMovers),
    const DeepCollectionEquality().hash(_overstocked),
  );

  /// Create a copy of InventoryAlerts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryAlertsImplCopyWith<_$InventoryAlertsImpl> get copyWith =>
      __$$InventoryAlertsImplCopyWithImpl<_$InventoryAlertsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryAlertsImplToJson(this);
  }
}

abstract class _InventoryAlerts implements InventoryAlerts {
  const factory _InventoryAlerts({
    final List<JsonMap> critical,
    @JsonKey(name: 'watch_list') final List<JsonMap> watchList,
    @JsonKey(name: 'slow_movers') final List<JsonMap> slowMovers,
    final List<JsonMap> overstocked,
  }) = _$InventoryAlertsImpl;

  factory _InventoryAlerts.fromJson(Map<String, dynamic> json) =
      _$InventoryAlertsImpl.fromJson;

  @override
  List<JsonMap> get critical;
  @override
  @JsonKey(name: 'watch_list')
  List<JsonMap> get watchList;
  @override
  @JsonKey(name: 'slow_movers')
  List<JsonMap> get slowMovers;
  @override
  List<JsonMap> get overstocked;

  /// Create a copy of InventoryAlerts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryAlertsImplCopyWith<_$InventoryAlertsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
