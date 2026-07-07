// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'executive_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExecutiveOverview _$ExecutiveOverviewFromJson(Map<String, dynamic> json) {
  return _ExecutiveOverview.fromJson(json);
}

/// @nodoc
mixin _$ExecutiveOverview {
  Map<String, dynamic> get period => throw _privateConstructorUsedError;
  ExecutiveKpis get kpis => throw _privateConstructorUsedError;
  @JsonKey(name: 'revenue_trend')
  List<JsonMap> get revenueTrend => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_mix')
  List<JsonMap> get productMix => throw _privateConstructorUsedError;
  @JsonKey(name: 'segment_mix')
  List<JsonMap> get segmentMix => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_territories')
  List<JsonMap> get topTerritories => throw _privateConstructorUsedError;
  List<JsonMap> get alerts => throw _privateConstructorUsedError;

  /// Serializes this ExecutiveOverview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExecutiveOverviewCopyWith<ExecutiveOverview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExecutiveOverviewCopyWith<$Res> {
  factory $ExecutiveOverviewCopyWith(
    ExecutiveOverview value,
    $Res Function(ExecutiveOverview) then,
  ) = _$ExecutiveOverviewCopyWithImpl<$Res, ExecutiveOverview>;
  @useResult
  $Res call({
    Map<String, dynamic> period,
    ExecutiveKpis kpis,
    @JsonKey(name: 'revenue_trend') List<JsonMap> revenueTrend,
    @JsonKey(name: 'product_mix') List<JsonMap> productMix,
    @JsonKey(name: 'segment_mix') List<JsonMap> segmentMix,
    @JsonKey(name: 'top_territories') List<JsonMap> topTerritories,
    List<JsonMap> alerts,
  });

  $ExecutiveKpisCopyWith<$Res> get kpis;
}

/// @nodoc
class _$ExecutiveOverviewCopyWithImpl<$Res, $Val extends ExecutiveOverview>
    implements $ExecutiveOverviewCopyWith<$Res> {
  _$ExecutiveOverviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? kpis = null,
    Object? revenueTrend = null,
    Object? productMix = null,
    Object? segmentMix = null,
    Object? topTerritories = null,
    Object? alerts = null,
  }) {
    return _then(
      _value.copyWith(
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            kpis: null == kpis
                ? _value.kpis
                : kpis // ignore: cast_nullable_to_non_nullable
                      as ExecutiveKpis,
            revenueTrend: null == revenueTrend
                ? _value.revenueTrend
                : revenueTrend // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            productMix: null == productMix
                ? _value.productMix
                : productMix // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            segmentMix: null == segmentMix
                ? _value.segmentMix
                : segmentMix // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            topTerritories: null == topTerritories
                ? _value.topTerritories
                : topTerritories // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            alerts: null == alerts
                ? _value.alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExecutiveKpisCopyWith<$Res> get kpis {
    return $ExecutiveKpisCopyWith<$Res>(_value.kpis, (value) {
      return _then(_value.copyWith(kpis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExecutiveOverviewImplCopyWith<$Res>
    implements $ExecutiveOverviewCopyWith<$Res> {
  factory _$$ExecutiveOverviewImplCopyWith(
    _$ExecutiveOverviewImpl value,
    $Res Function(_$ExecutiveOverviewImpl) then,
  ) = __$$ExecutiveOverviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic> period,
    ExecutiveKpis kpis,
    @JsonKey(name: 'revenue_trend') List<JsonMap> revenueTrend,
    @JsonKey(name: 'product_mix') List<JsonMap> productMix,
    @JsonKey(name: 'segment_mix') List<JsonMap> segmentMix,
    @JsonKey(name: 'top_territories') List<JsonMap> topTerritories,
    List<JsonMap> alerts,
  });

  @override
  $ExecutiveKpisCopyWith<$Res> get kpis;
}

/// @nodoc
class __$$ExecutiveOverviewImplCopyWithImpl<$Res>
    extends _$ExecutiveOverviewCopyWithImpl<$Res, _$ExecutiveOverviewImpl>
    implements _$$ExecutiveOverviewImplCopyWith<$Res> {
  __$$ExecutiveOverviewImplCopyWithImpl(
    _$ExecutiveOverviewImpl _value,
    $Res Function(_$ExecutiveOverviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? kpis = null,
    Object? revenueTrend = null,
    Object? productMix = null,
    Object? segmentMix = null,
    Object? topTerritories = null,
    Object? alerts = null,
  }) {
    return _then(
      _$ExecutiveOverviewImpl(
        period: null == period
            ? _value._period
            : period // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        kpis: null == kpis
            ? _value.kpis
            : kpis // ignore: cast_nullable_to_non_nullable
                  as ExecutiveKpis,
        revenueTrend: null == revenueTrend
            ? _value._revenueTrend
            : revenueTrend // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        productMix: null == productMix
            ? _value._productMix
            : productMix // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        segmentMix: null == segmentMix
            ? _value._segmentMix
            : segmentMix // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        topTerritories: null == topTerritories
            ? _value._topTerritories
            : topTerritories // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        alerts: null == alerts
            ? _value._alerts
            : alerts // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExecutiveOverviewImpl implements _ExecutiveOverview {
  const _$ExecutiveOverviewImpl({
    final Map<String, dynamic> period = const <String, dynamic>{},
    this.kpis = const ExecutiveKpis(),
    @JsonKey(name: 'revenue_trend')
    final List<JsonMap> revenueTrend = const <JsonMap>[],
    @JsonKey(name: 'product_mix')
    final List<JsonMap> productMix = const <JsonMap>[],
    @JsonKey(name: 'segment_mix')
    final List<JsonMap> segmentMix = const <JsonMap>[],
    @JsonKey(name: 'top_territories')
    final List<JsonMap> topTerritories = const <JsonMap>[],
    final List<JsonMap> alerts = const <JsonMap>[],
  }) : _period = period,
       _revenueTrend = revenueTrend,
       _productMix = productMix,
       _segmentMix = segmentMix,
       _topTerritories = topTerritories,
       _alerts = alerts;

  factory _$ExecutiveOverviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExecutiveOverviewImplFromJson(json);

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
  final ExecutiveKpis kpis;
  final List<JsonMap> _revenueTrend;
  @override
  @JsonKey(name: 'revenue_trend')
  List<JsonMap> get revenueTrend {
    if (_revenueTrend is EqualUnmodifiableListView) return _revenueTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueTrend);
  }

  final List<JsonMap> _productMix;
  @override
  @JsonKey(name: 'product_mix')
  List<JsonMap> get productMix {
    if (_productMix is EqualUnmodifiableListView) return _productMix;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_productMix);
  }

  final List<JsonMap> _segmentMix;
  @override
  @JsonKey(name: 'segment_mix')
  List<JsonMap> get segmentMix {
    if (_segmentMix is EqualUnmodifiableListView) return _segmentMix;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segmentMix);
  }

  final List<JsonMap> _topTerritories;
  @override
  @JsonKey(name: 'top_territories')
  List<JsonMap> get topTerritories {
    if (_topTerritories is EqualUnmodifiableListView) return _topTerritories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topTerritories);
  }

  final List<JsonMap> _alerts;
  @override
  @JsonKey()
  List<JsonMap> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  String toString() {
    return 'ExecutiveOverview(period: $period, kpis: $kpis, revenueTrend: $revenueTrend, productMix: $productMix, segmentMix: $segmentMix, topTerritories: $topTerritories, alerts: $alerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExecutiveOverviewImpl &&
            const DeepCollectionEquality().equals(other._period, _period) &&
            (identical(other.kpis, kpis) || other.kpis == kpis) &&
            const DeepCollectionEquality().equals(
              other._revenueTrend,
              _revenueTrend,
            ) &&
            const DeepCollectionEquality().equals(
              other._productMix,
              _productMix,
            ) &&
            const DeepCollectionEquality().equals(
              other._segmentMix,
              _segmentMix,
            ) &&
            const DeepCollectionEquality().equals(
              other._topTerritories,
              _topTerritories,
            ) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_period),
    kpis,
    const DeepCollectionEquality().hash(_revenueTrend),
    const DeepCollectionEquality().hash(_productMix),
    const DeepCollectionEquality().hash(_segmentMix),
    const DeepCollectionEquality().hash(_topTerritories),
    const DeepCollectionEquality().hash(_alerts),
  );

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExecutiveOverviewImplCopyWith<_$ExecutiveOverviewImpl> get copyWith =>
      __$$ExecutiveOverviewImplCopyWithImpl<_$ExecutiveOverviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExecutiveOverviewImplToJson(this);
  }
}

abstract class _ExecutiveOverview implements ExecutiveOverview {
  const factory _ExecutiveOverview({
    final Map<String, dynamic> period,
    final ExecutiveKpis kpis,
    @JsonKey(name: 'revenue_trend') final List<JsonMap> revenueTrend,
    @JsonKey(name: 'product_mix') final List<JsonMap> productMix,
    @JsonKey(name: 'segment_mix') final List<JsonMap> segmentMix,
    @JsonKey(name: 'top_territories') final List<JsonMap> topTerritories,
    final List<JsonMap> alerts,
  }) = _$ExecutiveOverviewImpl;

  factory _ExecutiveOverview.fromJson(Map<String, dynamic> json) =
      _$ExecutiveOverviewImpl.fromJson;

  @override
  Map<String, dynamic> get period;
  @override
  ExecutiveKpis get kpis;
  @override
  @JsonKey(name: 'revenue_trend')
  List<JsonMap> get revenueTrend;
  @override
  @JsonKey(name: 'product_mix')
  List<JsonMap> get productMix;
  @override
  @JsonKey(name: 'segment_mix')
  List<JsonMap> get segmentMix;
  @override
  @JsonKey(name: 'top_territories')
  List<JsonMap> get topTerritories;
  @override
  List<JsonMap> get alerts;

  /// Create a copy of ExecutiveOverview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExecutiveOverviewImplCopyWith<_$ExecutiveOverviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExecutiveKpis _$ExecutiveKpisFromJson(Map<String, dynamic> json) {
  return _ExecutiveKpis.fromJson(json);
}

/// @nodoc
mixin _$ExecutiveKpis {
  double get revenue => throw _privateConstructorUsedError;
  int get orders => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_profit')
  double get grossProfit => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_margin_pct')
  double get grossMarginPct => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_shipping_pl')
  double get netShippingPl => throw _privateConstructorUsedError;
  int get customers => throw _privateConstructorUsedError;
  @JsonKey(name: 'critical_stock')
  int get criticalStock => throw _privateConstructorUsedError;

  /// Serializes this ExecutiveKpis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExecutiveKpis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExecutiveKpisCopyWith<ExecutiveKpis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExecutiveKpisCopyWith<$Res> {
  factory $ExecutiveKpisCopyWith(
    ExecutiveKpis value,
    $Res Function(ExecutiveKpis) then,
  ) = _$ExecutiveKpisCopyWithImpl<$Res, ExecutiveKpis>;
  @useResult
  $Res call({
    double revenue,
    int orders,
    @JsonKey(name: 'gross_profit') double grossProfit,
    @JsonKey(name: 'gross_margin_pct') double grossMarginPct,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'net_shipping_pl') double netShippingPl,
    int customers,
    @JsonKey(name: 'critical_stock') int criticalStock,
  });
}

/// @nodoc
class _$ExecutiveKpisCopyWithImpl<$Res, $Val extends ExecutiveKpis>
    implements $ExecutiveKpisCopyWith<$Res> {
  _$ExecutiveKpisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExecutiveKpis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? revenue = null,
    Object? orders = null,
    Object? grossProfit = null,
    Object? grossMarginPct = null,
    Object? avgOrderValue = null,
    Object? netShippingPl = null,
    Object? customers = null,
    Object? criticalStock = null,
  }) {
    return _then(
      _value.copyWith(
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as int,
            grossProfit: null == grossProfit
                ? _value.grossProfit
                : grossProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            grossMarginPct: null == grossMarginPct
                ? _value.grossMarginPct
                : grossMarginPct // ignore: cast_nullable_to_non_nullable
                      as double,
            avgOrderValue: null == avgOrderValue
                ? _value.avgOrderValue
                : avgOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
            netShippingPl: null == netShippingPl
                ? _value.netShippingPl
                : netShippingPl // ignore: cast_nullable_to_non_nullable
                      as double,
            customers: null == customers
                ? _value.customers
                : customers // ignore: cast_nullable_to_non_nullable
                      as int,
            criticalStock: null == criticalStock
                ? _value.criticalStock
                : criticalStock // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExecutiveKpisImplCopyWith<$Res>
    implements $ExecutiveKpisCopyWith<$Res> {
  factory _$$ExecutiveKpisImplCopyWith(
    _$ExecutiveKpisImpl value,
    $Res Function(_$ExecutiveKpisImpl) then,
  ) = __$$ExecutiveKpisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double revenue,
    int orders,
    @JsonKey(name: 'gross_profit') double grossProfit,
    @JsonKey(name: 'gross_margin_pct') double grossMarginPct,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'net_shipping_pl') double netShippingPl,
    int customers,
    @JsonKey(name: 'critical_stock') int criticalStock,
  });
}

/// @nodoc
class __$$ExecutiveKpisImplCopyWithImpl<$Res>
    extends _$ExecutiveKpisCopyWithImpl<$Res, _$ExecutiveKpisImpl>
    implements _$$ExecutiveKpisImplCopyWith<$Res> {
  __$$ExecutiveKpisImplCopyWithImpl(
    _$ExecutiveKpisImpl _value,
    $Res Function(_$ExecutiveKpisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExecutiveKpis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? revenue = null,
    Object? orders = null,
    Object? grossProfit = null,
    Object? grossMarginPct = null,
    Object? avgOrderValue = null,
    Object? netShippingPl = null,
    Object? customers = null,
    Object? criticalStock = null,
  }) {
    return _then(
      _$ExecutiveKpisImpl(
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        orders: null == orders
            ? _value.orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as int,
        grossProfit: null == grossProfit
            ? _value.grossProfit
            : grossProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        grossMarginPct: null == grossMarginPct
            ? _value.grossMarginPct
            : grossMarginPct // ignore: cast_nullable_to_non_nullable
                  as double,
        avgOrderValue: null == avgOrderValue
            ? _value.avgOrderValue
            : avgOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
        netShippingPl: null == netShippingPl
            ? _value.netShippingPl
            : netShippingPl // ignore: cast_nullable_to_non_nullable
                  as double,
        customers: null == customers
            ? _value.customers
            : customers // ignore: cast_nullable_to_non_nullable
                  as int,
        criticalStock: null == criticalStock
            ? _value.criticalStock
            : criticalStock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExecutiveKpisImpl implements _ExecutiveKpis {
  const _$ExecutiveKpisImpl({
    this.revenue = 0,
    this.orders = 0,
    @JsonKey(name: 'gross_profit') this.grossProfit = 0,
    @JsonKey(name: 'gross_margin_pct') this.grossMarginPct = 0,
    @JsonKey(name: 'avg_order_value') this.avgOrderValue = 0,
    @JsonKey(name: 'net_shipping_pl') this.netShippingPl = 0,
    this.customers = 0,
    @JsonKey(name: 'critical_stock') this.criticalStock = 0,
  });

  factory _$ExecutiveKpisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExecutiveKpisImplFromJson(json);

  @override
  @JsonKey()
  final double revenue;
  @override
  @JsonKey()
  final int orders;
  @override
  @JsonKey(name: 'gross_profit')
  final double grossProfit;
  @override
  @JsonKey(name: 'gross_margin_pct')
  final double grossMarginPct;
  @override
  @JsonKey(name: 'avg_order_value')
  final double avgOrderValue;
  @override
  @JsonKey(name: 'net_shipping_pl')
  final double netShippingPl;
  @override
  @JsonKey()
  final int customers;
  @override
  @JsonKey(name: 'critical_stock')
  final int criticalStock;

  @override
  String toString() {
    return 'ExecutiveKpis(revenue: $revenue, orders: $orders, grossProfit: $grossProfit, grossMarginPct: $grossMarginPct, avgOrderValue: $avgOrderValue, netShippingPl: $netShippingPl, customers: $customers, criticalStock: $criticalStock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExecutiveKpisImpl &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.orders, orders) || other.orders == orders) &&
            (identical(other.grossProfit, grossProfit) ||
                other.grossProfit == grossProfit) &&
            (identical(other.grossMarginPct, grossMarginPct) ||
                other.grossMarginPct == grossMarginPct) &&
            (identical(other.avgOrderValue, avgOrderValue) ||
                other.avgOrderValue == avgOrderValue) &&
            (identical(other.netShippingPl, netShippingPl) ||
                other.netShippingPl == netShippingPl) &&
            (identical(other.customers, customers) ||
                other.customers == customers) &&
            (identical(other.criticalStock, criticalStock) ||
                other.criticalStock == criticalStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    revenue,
    orders,
    grossProfit,
    grossMarginPct,
    avgOrderValue,
    netShippingPl,
    customers,
    criticalStock,
  );

  /// Create a copy of ExecutiveKpis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExecutiveKpisImplCopyWith<_$ExecutiveKpisImpl> get copyWith =>
      __$$ExecutiveKpisImplCopyWithImpl<_$ExecutiveKpisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExecutiveKpisImplToJson(this);
  }
}

abstract class _ExecutiveKpis implements ExecutiveKpis {
  const factory _ExecutiveKpis({
    final double revenue,
    final int orders,
    @JsonKey(name: 'gross_profit') final double grossProfit,
    @JsonKey(name: 'gross_margin_pct') final double grossMarginPct,
    @JsonKey(name: 'avg_order_value') final double avgOrderValue,
    @JsonKey(name: 'net_shipping_pl') final double netShippingPl,
    final int customers,
    @JsonKey(name: 'critical_stock') final int criticalStock,
  }) = _$ExecutiveKpisImpl;

  factory _ExecutiveKpis.fromJson(Map<String, dynamic> json) =
      _$ExecutiveKpisImpl.fromJson;

  @override
  double get revenue;
  @override
  int get orders;
  @override
  @JsonKey(name: 'gross_profit')
  double get grossProfit;
  @override
  @JsonKey(name: 'gross_margin_pct')
  double get grossMarginPct;
  @override
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue;
  @override
  @JsonKey(name: 'net_shipping_pl')
  double get netShippingPl;
  @override
  int get customers;
  @override
  @JsonKey(name: 'critical_stock')
  int get criticalStock;

  /// Create a copy of ExecutiveKpis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExecutiveKpisImplCopyWith<_$ExecutiveKpisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
