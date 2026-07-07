// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerAnalytics _$CustomerAnalyticsFromJson(Map<String, dynamic> json) {
  return _CustomerAnalytics.fromJson(json);
}

/// @nodoc
mixin _$CustomerAnalytics {
  Map<String, dynamic> get period => throw _privateConstructorUsedError;
  CustomerAnalyticsSummary get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'segment_distribution')
  List<JsonMap> get segmentDistribution => throw _privateConstructorUsedError;
  @JsonKey(name: 'segment_table')
  List<JsonMap> get segmentTable => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_customers')
  List<JsonMap> get topCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'at_risk_customers')
  List<JsonMap> get atRiskCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'acquisition_trend')
  List<JsonMap> get acquisitionTrend => throw _privateConstructorUsedError;

  /// Serializes this CustomerAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerAnalyticsCopyWith<CustomerAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerAnalyticsCopyWith<$Res> {
  factory $CustomerAnalyticsCopyWith(
    CustomerAnalytics value,
    $Res Function(CustomerAnalytics) then,
  ) = _$CustomerAnalyticsCopyWithImpl<$Res, CustomerAnalytics>;
  @useResult
  $Res call({
    Map<String, dynamic> period,
    CustomerAnalyticsSummary summary,
    @JsonKey(name: 'segment_distribution') List<JsonMap> segmentDistribution,
    @JsonKey(name: 'segment_table') List<JsonMap> segmentTable,
    @JsonKey(name: 'top_customers') List<JsonMap> topCustomers,
    @JsonKey(name: 'at_risk_customers') List<JsonMap> atRiskCustomers,
    @JsonKey(name: 'acquisition_trend') List<JsonMap> acquisitionTrend,
  });

  $CustomerAnalyticsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$CustomerAnalyticsCopyWithImpl<$Res, $Val extends CustomerAnalytics>
    implements $CustomerAnalyticsCopyWith<$Res> {
  _$CustomerAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? segmentDistribution = null,
    Object? segmentTable = null,
    Object? topCustomers = null,
    Object? atRiskCustomers = null,
    Object? acquisitionTrend = null,
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
                      as CustomerAnalyticsSummary,
            segmentDistribution: null == segmentDistribution
                ? _value.segmentDistribution
                : segmentDistribution // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            segmentTable: null == segmentTable
                ? _value.segmentTable
                : segmentTable // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            topCustomers: null == topCustomers
                ? _value.topCustomers
                : topCustomers // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            atRiskCustomers: null == atRiskCustomers
                ? _value.atRiskCustomers
                : atRiskCustomers // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            acquisitionTrend: null == acquisitionTrend
                ? _value.acquisitionTrend
                : acquisitionTrend // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerAnalyticsSummaryCopyWith<$Res> get summary {
    return $CustomerAnalyticsSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerAnalyticsImplCopyWith<$Res>
    implements $CustomerAnalyticsCopyWith<$Res> {
  factory _$$CustomerAnalyticsImplCopyWith(
    _$CustomerAnalyticsImpl value,
    $Res Function(_$CustomerAnalyticsImpl) then,
  ) = __$$CustomerAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic> period,
    CustomerAnalyticsSummary summary,
    @JsonKey(name: 'segment_distribution') List<JsonMap> segmentDistribution,
    @JsonKey(name: 'segment_table') List<JsonMap> segmentTable,
    @JsonKey(name: 'top_customers') List<JsonMap> topCustomers,
    @JsonKey(name: 'at_risk_customers') List<JsonMap> atRiskCustomers,
    @JsonKey(name: 'acquisition_trend') List<JsonMap> acquisitionTrend,
  });

  @override
  $CustomerAnalyticsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$CustomerAnalyticsImplCopyWithImpl<$Res>
    extends _$CustomerAnalyticsCopyWithImpl<$Res, _$CustomerAnalyticsImpl>
    implements _$$CustomerAnalyticsImplCopyWith<$Res> {
  __$$CustomerAnalyticsImplCopyWithImpl(
    _$CustomerAnalyticsImpl _value,
    $Res Function(_$CustomerAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? segmentDistribution = null,
    Object? segmentTable = null,
    Object? topCustomers = null,
    Object? atRiskCustomers = null,
    Object? acquisitionTrend = null,
  }) {
    return _then(
      _$CustomerAnalyticsImpl(
        period: null == period
            ? _value._period
            : period // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as CustomerAnalyticsSummary,
        segmentDistribution: null == segmentDistribution
            ? _value._segmentDistribution
            : segmentDistribution // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        segmentTable: null == segmentTable
            ? _value._segmentTable
            : segmentTable // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        topCustomers: null == topCustomers
            ? _value._topCustomers
            : topCustomers // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        atRiskCustomers: null == atRiskCustomers
            ? _value._atRiskCustomers
            : atRiskCustomers // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        acquisitionTrend: null == acquisitionTrend
            ? _value._acquisitionTrend
            : acquisitionTrend // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerAnalyticsImpl implements _CustomerAnalytics {
  const _$CustomerAnalyticsImpl({
    final Map<String, dynamic> period = const <String, dynamic>{},
    this.summary = const CustomerAnalyticsSummary(),
    @JsonKey(name: 'segment_distribution')
    final List<JsonMap> segmentDistribution = const <JsonMap>[],
    @JsonKey(name: 'segment_table')
    final List<JsonMap> segmentTable = const <JsonMap>[],
    @JsonKey(name: 'top_customers')
    final List<JsonMap> topCustomers = const <JsonMap>[],
    @JsonKey(name: 'at_risk_customers')
    final List<JsonMap> atRiskCustomers = const <JsonMap>[],
    @JsonKey(name: 'acquisition_trend')
    final List<JsonMap> acquisitionTrend = const <JsonMap>[],
  }) : _period = period,
       _segmentDistribution = segmentDistribution,
       _segmentTable = segmentTable,
       _topCustomers = topCustomers,
       _atRiskCustomers = atRiskCustomers,
       _acquisitionTrend = acquisitionTrend;

  factory _$CustomerAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerAnalyticsImplFromJson(json);

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
  final CustomerAnalyticsSummary summary;
  final List<JsonMap> _segmentDistribution;
  @override
  @JsonKey(name: 'segment_distribution')
  List<JsonMap> get segmentDistribution {
    if (_segmentDistribution is EqualUnmodifiableListView)
      return _segmentDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segmentDistribution);
  }

  final List<JsonMap> _segmentTable;
  @override
  @JsonKey(name: 'segment_table')
  List<JsonMap> get segmentTable {
    if (_segmentTable is EqualUnmodifiableListView) return _segmentTable;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segmentTable);
  }

  final List<JsonMap> _topCustomers;
  @override
  @JsonKey(name: 'top_customers')
  List<JsonMap> get topCustomers {
    if (_topCustomers is EqualUnmodifiableListView) return _topCustomers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topCustomers);
  }

  final List<JsonMap> _atRiskCustomers;
  @override
  @JsonKey(name: 'at_risk_customers')
  List<JsonMap> get atRiskCustomers {
    if (_atRiskCustomers is EqualUnmodifiableListView) return _atRiskCustomers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_atRiskCustomers);
  }

  final List<JsonMap> _acquisitionTrend;
  @override
  @JsonKey(name: 'acquisition_trend')
  List<JsonMap> get acquisitionTrend {
    if (_acquisitionTrend is EqualUnmodifiableListView)
      return _acquisitionTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acquisitionTrend);
  }

  @override
  String toString() {
    return 'CustomerAnalytics(period: $period, summary: $summary, segmentDistribution: $segmentDistribution, segmentTable: $segmentTable, topCustomers: $topCustomers, atRiskCustomers: $atRiskCustomers, acquisitionTrend: $acquisitionTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerAnalyticsImpl &&
            const DeepCollectionEquality().equals(other._period, _period) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._segmentDistribution,
              _segmentDistribution,
            ) &&
            const DeepCollectionEquality().equals(
              other._segmentTable,
              _segmentTable,
            ) &&
            const DeepCollectionEquality().equals(
              other._topCustomers,
              _topCustomers,
            ) &&
            const DeepCollectionEquality().equals(
              other._atRiskCustomers,
              _atRiskCustomers,
            ) &&
            const DeepCollectionEquality().equals(
              other._acquisitionTrend,
              _acquisitionTrend,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_period),
    summary,
    const DeepCollectionEquality().hash(_segmentDistribution),
    const DeepCollectionEquality().hash(_segmentTable),
    const DeepCollectionEquality().hash(_topCustomers),
    const DeepCollectionEquality().hash(_atRiskCustomers),
    const DeepCollectionEquality().hash(_acquisitionTrend),
  );

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerAnalyticsImplCopyWith<_$CustomerAnalyticsImpl> get copyWith =>
      __$$CustomerAnalyticsImplCopyWithImpl<_$CustomerAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerAnalyticsImplToJson(this);
  }
}

abstract class _CustomerAnalytics implements CustomerAnalytics {
  const factory _CustomerAnalytics({
    final Map<String, dynamic> period,
    final CustomerAnalyticsSummary summary,
    @JsonKey(name: 'segment_distribution')
    final List<JsonMap> segmentDistribution,
    @JsonKey(name: 'segment_table') final List<JsonMap> segmentTable,
    @JsonKey(name: 'top_customers') final List<JsonMap> topCustomers,
    @JsonKey(name: 'at_risk_customers') final List<JsonMap> atRiskCustomers,
    @JsonKey(name: 'acquisition_trend') final List<JsonMap> acquisitionTrend,
  }) = _$CustomerAnalyticsImpl;

  factory _CustomerAnalytics.fromJson(Map<String, dynamic> json) =
      _$CustomerAnalyticsImpl.fromJson;

  @override
  Map<String, dynamic> get period;
  @override
  CustomerAnalyticsSummary get summary;
  @override
  @JsonKey(name: 'segment_distribution')
  List<JsonMap> get segmentDistribution;
  @override
  @JsonKey(name: 'segment_table')
  List<JsonMap> get segmentTable;
  @override
  @JsonKey(name: 'top_customers')
  List<JsonMap> get topCustomers;
  @override
  @JsonKey(name: 'at_risk_customers')
  List<JsonMap> get atRiskCustomers;
  @override
  @JsonKey(name: 'acquisition_trend')
  List<JsonMap> get acquisitionTrend;

  /// Create a copy of CustomerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerAnalyticsImplCopyWith<_$CustomerAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerAnalyticsSummary _$CustomerAnalyticsSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerAnalyticsSummary.fromJson(json);
}

/// @nodoc
mixin _$CustomerAnalyticsSummary {
  @JsonKey(name: 'total_customers')
  int get totalCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_in_period')
  int get activeInPeriod => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_customers')
  int get newCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'returning_customers')
  int get returningCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'repeat_rate')
  double get repeatRate => throw _privateConstructorUsedError;
  int get champions => throw _privateConstructorUsedError;
  @JsonKey(name: 'at_risk')
  int get atRisk => throw _privateConstructorUsedError;
  int get lost => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_revenue')
  double get periodRevenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_orders')
  int get periodOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue => throw _privateConstructorUsedError;

  /// Serializes this CustomerAnalyticsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerAnalyticsSummaryCopyWith<CustomerAnalyticsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerAnalyticsSummaryCopyWith<$Res> {
  factory $CustomerAnalyticsSummaryCopyWith(
    CustomerAnalyticsSummary value,
    $Res Function(CustomerAnalyticsSummary) then,
  ) = _$CustomerAnalyticsSummaryCopyWithImpl<$Res, CustomerAnalyticsSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_customers') int totalCustomers,
    @JsonKey(name: 'active_in_period') int activeInPeriod,
    @JsonKey(name: 'new_customers') int newCustomers,
    @JsonKey(name: 'returning_customers') int returningCustomers,
    @JsonKey(name: 'repeat_rate') double repeatRate,
    int champions,
    @JsonKey(name: 'at_risk') int atRisk,
    int lost,
    @JsonKey(name: 'period_revenue') double periodRevenue,
    @JsonKey(name: 'period_orders') int periodOrders,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
  });
}

/// @nodoc
class _$CustomerAnalyticsSummaryCopyWithImpl<
  $Res,
  $Val extends CustomerAnalyticsSummary
>
    implements $CustomerAnalyticsSummaryCopyWith<$Res> {
  _$CustomerAnalyticsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCustomers = null,
    Object? activeInPeriod = null,
    Object? newCustomers = null,
    Object? returningCustomers = null,
    Object? repeatRate = null,
    Object? champions = null,
    Object? atRisk = null,
    Object? lost = null,
    Object? periodRevenue = null,
    Object? periodOrders = null,
    Object? avgOrderValue = null,
  }) {
    return _then(
      _value.copyWith(
            totalCustomers: null == totalCustomers
                ? _value.totalCustomers
                : totalCustomers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeInPeriod: null == activeInPeriod
                ? _value.activeInPeriod
                : activeInPeriod // ignore: cast_nullable_to_non_nullable
                      as int,
            newCustomers: null == newCustomers
                ? _value.newCustomers
                : newCustomers // ignore: cast_nullable_to_non_nullable
                      as int,
            returningCustomers: null == returningCustomers
                ? _value.returningCustomers
                : returningCustomers // ignore: cast_nullable_to_non_nullable
                      as int,
            repeatRate: null == repeatRate
                ? _value.repeatRate
                : repeatRate // ignore: cast_nullable_to_non_nullable
                      as double,
            champions: null == champions
                ? _value.champions
                : champions // ignore: cast_nullable_to_non_nullable
                      as int,
            atRisk: null == atRisk
                ? _value.atRisk
                : atRisk // ignore: cast_nullable_to_non_nullable
                      as int,
            lost: null == lost
                ? _value.lost
                : lost // ignore: cast_nullable_to_non_nullable
                      as int,
            periodRevenue: null == periodRevenue
                ? _value.periodRevenue
                : periodRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            periodOrders: null == periodOrders
                ? _value.periodOrders
                : periodOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            avgOrderValue: null == avgOrderValue
                ? _value.avgOrderValue
                : avgOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerAnalyticsSummaryImplCopyWith<$Res>
    implements $CustomerAnalyticsSummaryCopyWith<$Res> {
  factory _$$CustomerAnalyticsSummaryImplCopyWith(
    _$CustomerAnalyticsSummaryImpl value,
    $Res Function(_$CustomerAnalyticsSummaryImpl) then,
  ) = __$$CustomerAnalyticsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_customers') int totalCustomers,
    @JsonKey(name: 'active_in_period') int activeInPeriod,
    @JsonKey(name: 'new_customers') int newCustomers,
    @JsonKey(name: 'returning_customers') int returningCustomers,
    @JsonKey(name: 'repeat_rate') double repeatRate,
    int champions,
    @JsonKey(name: 'at_risk') int atRisk,
    int lost,
    @JsonKey(name: 'period_revenue') double periodRevenue,
    @JsonKey(name: 'period_orders') int periodOrders,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
  });
}

/// @nodoc
class __$$CustomerAnalyticsSummaryImplCopyWithImpl<$Res>
    extends
        _$CustomerAnalyticsSummaryCopyWithImpl<
          $Res,
          _$CustomerAnalyticsSummaryImpl
        >
    implements _$$CustomerAnalyticsSummaryImplCopyWith<$Res> {
  __$$CustomerAnalyticsSummaryImplCopyWithImpl(
    _$CustomerAnalyticsSummaryImpl _value,
    $Res Function(_$CustomerAnalyticsSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCustomers = null,
    Object? activeInPeriod = null,
    Object? newCustomers = null,
    Object? returningCustomers = null,
    Object? repeatRate = null,
    Object? champions = null,
    Object? atRisk = null,
    Object? lost = null,
    Object? periodRevenue = null,
    Object? periodOrders = null,
    Object? avgOrderValue = null,
  }) {
    return _then(
      _$CustomerAnalyticsSummaryImpl(
        totalCustomers: null == totalCustomers
            ? _value.totalCustomers
            : totalCustomers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeInPeriod: null == activeInPeriod
            ? _value.activeInPeriod
            : activeInPeriod // ignore: cast_nullable_to_non_nullable
                  as int,
        newCustomers: null == newCustomers
            ? _value.newCustomers
            : newCustomers // ignore: cast_nullable_to_non_nullable
                  as int,
        returningCustomers: null == returningCustomers
            ? _value.returningCustomers
            : returningCustomers // ignore: cast_nullable_to_non_nullable
                  as int,
        repeatRate: null == repeatRate
            ? _value.repeatRate
            : repeatRate // ignore: cast_nullable_to_non_nullable
                  as double,
        champions: null == champions
            ? _value.champions
            : champions // ignore: cast_nullable_to_non_nullable
                  as int,
        atRisk: null == atRisk
            ? _value.atRisk
            : atRisk // ignore: cast_nullable_to_non_nullable
                  as int,
        lost: null == lost
            ? _value.lost
            : lost // ignore: cast_nullable_to_non_nullable
                  as int,
        periodRevenue: null == periodRevenue
            ? _value.periodRevenue
            : periodRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        periodOrders: null == periodOrders
            ? _value.periodOrders
            : periodOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        avgOrderValue: null == avgOrderValue
            ? _value.avgOrderValue
            : avgOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerAnalyticsSummaryImpl implements _CustomerAnalyticsSummary {
  const _$CustomerAnalyticsSummaryImpl({
    @JsonKey(name: 'total_customers') this.totalCustomers = 0,
    @JsonKey(name: 'active_in_period') this.activeInPeriod = 0,
    @JsonKey(name: 'new_customers') this.newCustomers = 0,
    @JsonKey(name: 'returning_customers') this.returningCustomers = 0,
    @JsonKey(name: 'repeat_rate') this.repeatRate = 0,
    this.champions = 0,
    @JsonKey(name: 'at_risk') this.atRisk = 0,
    this.lost = 0,
    @JsonKey(name: 'period_revenue') this.periodRevenue = 0,
    @JsonKey(name: 'period_orders') this.periodOrders = 0,
    @JsonKey(name: 'avg_order_value') this.avgOrderValue = 0,
  });

  factory _$CustomerAnalyticsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerAnalyticsSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_customers')
  final int totalCustomers;
  @override
  @JsonKey(name: 'active_in_period')
  final int activeInPeriod;
  @override
  @JsonKey(name: 'new_customers')
  final int newCustomers;
  @override
  @JsonKey(name: 'returning_customers')
  final int returningCustomers;
  @override
  @JsonKey(name: 'repeat_rate')
  final double repeatRate;
  @override
  @JsonKey()
  final int champions;
  @override
  @JsonKey(name: 'at_risk')
  final int atRisk;
  @override
  @JsonKey()
  final int lost;
  @override
  @JsonKey(name: 'period_revenue')
  final double periodRevenue;
  @override
  @JsonKey(name: 'period_orders')
  final int periodOrders;
  @override
  @JsonKey(name: 'avg_order_value')
  final double avgOrderValue;

  @override
  String toString() {
    return 'CustomerAnalyticsSummary(totalCustomers: $totalCustomers, activeInPeriod: $activeInPeriod, newCustomers: $newCustomers, returningCustomers: $returningCustomers, repeatRate: $repeatRate, champions: $champions, atRisk: $atRisk, lost: $lost, periodRevenue: $periodRevenue, periodOrders: $periodOrders, avgOrderValue: $avgOrderValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerAnalyticsSummaryImpl &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.activeInPeriod, activeInPeriod) ||
                other.activeInPeriod == activeInPeriod) &&
            (identical(other.newCustomers, newCustomers) ||
                other.newCustomers == newCustomers) &&
            (identical(other.returningCustomers, returningCustomers) ||
                other.returningCustomers == returningCustomers) &&
            (identical(other.repeatRate, repeatRate) ||
                other.repeatRate == repeatRate) &&
            (identical(other.champions, champions) ||
                other.champions == champions) &&
            (identical(other.atRisk, atRisk) || other.atRisk == atRisk) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.periodRevenue, periodRevenue) ||
                other.periodRevenue == periodRevenue) &&
            (identical(other.periodOrders, periodOrders) ||
                other.periodOrders == periodOrders) &&
            (identical(other.avgOrderValue, avgOrderValue) ||
                other.avgOrderValue == avgOrderValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalCustomers,
    activeInPeriod,
    newCustomers,
    returningCustomers,
    repeatRate,
    champions,
    atRisk,
    lost,
    periodRevenue,
    periodOrders,
    avgOrderValue,
  );

  /// Create a copy of CustomerAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerAnalyticsSummaryImplCopyWith<_$CustomerAnalyticsSummaryImpl>
  get copyWith =>
      __$$CustomerAnalyticsSummaryImplCopyWithImpl<
        _$CustomerAnalyticsSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerAnalyticsSummaryImplToJson(this);
  }
}

abstract class _CustomerAnalyticsSummary implements CustomerAnalyticsSummary {
  const factory _CustomerAnalyticsSummary({
    @JsonKey(name: 'total_customers') final int totalCustomers,
    @JsonKey(name: 'active_in_period') final int activeInPeriod,
    @JsonKey(name: 'new_customers') final int newCustomers,
    @JsonKey(name: 'returning_customers') final int returningCustomers,
    @JsonKey(name: 'repeat_rate') final double repeatRate,
    final int champions,
    @JsonKey(name: 'at_risk') final int atRisk,
    final int lost,
    @JsonKey(name: 'period_revenue') final double periodRevenue,
    @JsonKey(name: 'period_orders') final int periodOrders,
    @JsonKey(name: 'avg_order_value') final double avgOrderValue,
  }) = _$CustomerAnalyticsSummaryImpl;

  factory _CustomerAnalyticsSummary.fromJson(Map<String, dynamic> json) =
      _$CustomerAnalyticsSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_customers')
  int get totalCustomers;
  @override
  @JsonKey(name: 'active_in_period')
  int get activeInPeriod;
  @override
  @JsonKey(name: 'new_customers')
  int get newCustomers;
  @override
  @JsonKey(name: 'returning_customers')
  int get returningCustomers;
  @override
  @JsonKey(name: 'repeat_rate')
  double get repeatRate;
  @override
  int get champions;
  @override
  @JsonKey(name: 'at_risk')
  int get atRisk;
  @override
  int get lost;
  @override
  @JsonKey(name: 'period_revenue')
  double get periodRevenue;
  @override
  @JsonKey(name: 'period_orders')
  int get periodOrders;
  @override
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue;

  /// Create a copy of CustomerAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerAnalyticsSummaryImplCopyWith<_$CustomerAnalyticsSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
