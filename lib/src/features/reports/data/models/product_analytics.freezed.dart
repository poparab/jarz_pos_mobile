// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductAnalytics _$ProductAnalyticsFromJson(Map<String, dynamic> json) {
  return _ProductAnalytics.fromJson(json);
}

/// @nodoc
mixin _$ProductAnalytics {
  Map<String, dynamic> get period => throw _privateConstructorUsedError;
  ProductAnalyticsSummary get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'by_product_type')
  List<JsonMap> get byProductType => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_products')
  List<JsonMap> get topProducts => throw _privateConstructorUsedError;
  @JsonKey(name: 'by_territory')
  List<JsonMap> get byTerritory => throw _privateConstructorUsedError;
  List<JsonMap> get trend => throw _privateConstructorUsedError;
  @JsonKey(name: 'bundle_composition')
  List<JsonMap> get bundleComposition => throw _privateConstructorUsedError;

  /// Serializes this ProductAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductAnalyticsCopyWith<ProductAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductAnalyticsCopyWith<$Res> {
  factory $ProductAnalyticsCopyWith(
    ProductAnalytics value,
    $Res Function(ProductAnalytics) then,
  ) = _$ProductAnalyticsCopyWithImpl<$Res, ProductAnalytics>;
  @useResult
  $Res call({
    Map<String, dynamic> period,
    ProductAnalyticsSummary summary,
    @JsonKey(name: 'by_product_type') List<JsonMap> byProductType,
    @JsonKey(name: 'top_products') List<JsonMap> topProducts,
    @JsonKey(name: 'by_territory') List<JsonMap> byTerritory,
    List<JsonMap> trend,
    @JsonKey(name: 'bundle_composition') List<JsonMap> bundleComposition,
  });

  $ProductAnalyticsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ProductAnalyticsCopyWithImpl<$Res, $Val extends ProductAnalytics>
    implements $ProductAnalyticsCopyWith<$Res> {
  _$ProductAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? byProductType = null,
    Object? topProducts = null,
    Object? byTerritory = null,
    Object? trend = null,
    Object? bundleComposition = null,
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
                      as ProductAnalyticsSummary,
            byProductType: null == byProductType
                ? _value.byProductType
                : byProductType // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            topProducts: null == topProducts
                ? _value.topProducts
                : topProducts // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            byTerritory: null == byTerritory
                ? _value.byTerritory
                : byTerritory // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
            bundleComposition: null == bundleComposition
                ? _value.bundleComposition
                : bundleComposition // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductAnalyticsSummaryCopyWith<$Res> get summary {
    return $ProductAnalyticsSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductAnalyticsImplCopyWith<$Res>
    implements $ProductAnalyticsCopyWith<$Res> {
  factory _$$ProductAnalyticsImplCopyWith(
    _$ProductAnalyticsImpl value,
    $Res Function(_$ProductAnalyticsImpl) then,
  ) = __$$ProductAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic> period,
    ProductAnalyticsSummary summary,
    @JsonKey(name: 'by_product_type') List<JsonMap> byProductType,
    @JsonKey(name: 'top_products') List<JsonMap> topProducts,
    @JsonKey(name: 'by_territory') List<JsonMap> byTerritory,
    List<JsonMap> trend,
    @JsonKey(name: 'bundle_composition') List<JsonMap> bundleComposition,
  });

  @override
  $ProductAnalyticsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ProductAnalyticsImplCopyWithImpl<$Res>
    extends _$ProductAnalyticsCopyWithImpl<$Res, _$ProductAnalyticsImpl>
    implements _$$ProductAnalyticsImplCopyWith<$Res> {
  __$$ProductAnalyticsImplCopyWithImpl(
    _$ProductAnalyticsImpl _value,
    $Res Function(_$ProductAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? byProductType = null,
    Object? topProducts = null,
    Object? byTerritory = null,
    Object? trend = null,
    Object? bundleComposition = null,
  }) {
    return _then(
      _$ProductAnalyticsImpl(
        period: null == period
            ? _value._period
            : period // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as ProductAnalyticsSummary,
        byProductType: null == byProductType
            ? _value._byProductType
            : byProductType // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        topProducts: null == topProducts
            ? _value._topProducts
            : topProducts // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        byTerritory: null == byTerritory
            ? _value._byTerritory
            : byTerritory // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        trend: null == trend
            ? _value._trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
        bundleComposition: null == bundleComposition
            ? _value._bundleComposition
            : bundleComposition // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductAnalyticsImpl implements _ProductAnalytics {
  const _$ProductAnalyticsImpl({
    final Map<String, dynamic> period = const <String, dynamic>{},
    this.summary = const ProductAnalyticsSummary(),
    @JsonKey(name: 'by_product_type')
    final List<JsonMap> byProductType = const <JsonMap>[],
    @JsonKey(name: 'top_products')
    final List<JsonMap> topProducts = const <JsonMap>[],
    @JsonKey(name: 'by_territory')
    final List<JsonMap> byTerritory = const <JsonMap>[],
    final List<JsonMap> trend = const <JsonMap>[],
    @JsonKey(name: 'bundle_composition')
    final List<JsonMap> bundleComposition = const <JsonMap>[],
  }) : _period = period,
       _byProductType = byProductType,
       _topProducts = topProducts,
       _byTerritory = byTerritory,
       _trend = trend,
       _bundleComposition = bundleComposition;

  factory _$ProductAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductAnalyticsImplFromJson(json);

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
  final ProductAnalyticsSummary summary;
  final List<JsonMap> _byProductType;
  @override
  @JsonKey(name: 'by_product_type')
  List<JsonMap> get byProductType {
    if (_byProductType is EqualUnmodifiableListView) return _byProductType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byProductType);
  }

  final List<JsonMap> _topProducts;
  @override
  @JsonKey(name: 'top_products')
  List<JsonMap> get topProducts {
    if (_topProducts is EqualUnmodifiableListView) return _topProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topProducts);
  }

  final List<JsonMap> _byTerritory;
  @override
  @JsonKey(name: 'by_territory')
  List<JsonMap> get byTerritory {
    if (_byTerritory is EqualUnmodifiableListView) return _byTerritory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byTerritory);
  }

  final List<JsonMap> _trend;
  @override
  @JsonKey()
  List<JsonMap> get trend {
    if (_trend is EqualUnmodifiableListView) return _trend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trend);
  }

  final List<JsonMap> _bundleComposition;
  @override
  @JsonKey(name: 'bundle_composition')
  List<JsonMap> get bundleComposition {
    if (_bundleComposition is EqualUnmodifiableListView)
      return _bundleComposition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bundleComposition);
  }

  @override
  String toString() {
    return 'ProductAnalytics(period: $period, summary: $summary, byProductType: $byProductType, topProducts: $topProducts, byTerritory: $byTerritory, trend: $trend, bundleComposition: $bundleComposition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductAnalyticsImpl &&
            const DeepCollectionEquality().equals(other._period, _period) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._byProductType,
              _byProductType,
            ) &&
            const DeepCollectionEquality().equals(
              other._topProducts,
              _topProducts,
            ) &&
            const DeepCollectionEquality().equals(
              other._byTerritory,
              _byTerritory,
            ) &&
            const DeepCollectionEquality().equals(other._trend, _trend) &&
            const DeepCollectionEquality().equals(
              other._bundleComposition,
              _bundleComposition,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_period),
    summary,
    const DeepCollectionEquality().hash(_byProductType),
    const DeepCollectionEquality().hash(_topProducts),
    const DeepCollectionEquality().hash(_byTerritory),
    const DeepCollectionEquality().hash(_trend),
    const DeepCollectionEquality().hash(_bundleComposition),
  );

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductAnalyticsImplCopyWith<_$ProductAnalyticsImpl> get copyWith =>
      __$$ProductAnalyticsImplCopyWithImpl<_$ProductAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductAnalyticsImplToJson(this);
  }
}

abstract class _ProductAnalytics implements ProductAnalytics {
  const factory _ProductAnalytics({
    final Map<String, dynamic> period,
    final ProductAnalyticsSummary summary,
    @JsonKey(name: 'by_product_type') final List<JsonMap> byProductType,
    @JsonKey(name: 'top_products') final List<JsonMap> topProducts,
    @JsonKey(name: 'by_territory') final List<JsonMap> byTerritory,
    final List<JsonMap> trend,
    @JsonKey(name: 'bundle_composition') final List<JsonMap> bundleComposition,
  }) = _$ProductAnalyticsImpl;

  factory _ProductAnalytics.fromJson(Map<String, dynamic> json) =
      _$ProductAnalyticsImpl.fromJson;

  @override
  Map<String, dynamic> get period;
  @override
  ProductAnalyticsSummary get summary;
  @override
  @JsonKey(name: 'by_product_type')
  List<JsonMap> get byProductType;
  @override
  @JsonKey(name: 'top_products')
  List<JsonMap> get topProducts;
  @override
  @JsonKey(name: 'by_territory')
  List<JsonMap> get byTerritory;
  @override
  List<JsonMap> get trend;
  @override
  @JsonKey(name: 'bundle_composition')
  List<JsonMap> get bundleComposition;

  /// Create a copy of ProductAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductAnalyticsImplCopyWith<_$ProductAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductAnalyticsSummary _$ProductAnalyticsSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _ProductAnalyticsSummary.fromJson(json);
}

/// @nodoc
mixin _$ProductAnalyticsSummary {
  @JsonKey(name: 'total_revenue')
  double get totalRevenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_orders')
  int get totalOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_gross_profit')
  double get totalGrossProfit => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue => throw _privateConstructorUsedError; // Backend emits an object `{item_name, total_qty}`; extract the name.
  @JsonKey(name: 'best_selling_product')
  @_BestSellingProductConverter()
  String get bestSellingProduct => throw _privateConstructorUsedError; // Backend emits an object `{territory, revenue}`; extract the territory.
  @JsonKey(name: 'top_territory')
  @_TopTerritoryConverter()
  String get topTerritory => throw _privateConstructorUsedError;

  /// Serializes this ProductAnalyticsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductAnalyticsSummaryCopyWith<ProductAnalyticsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductAnalyticsSummaryCopyWith<$Res> {
  factory $ProductAnalyticsSummaryCopyWith(
    ProductAnalyticsSummary value,
    $Res Function(ProductAnalyticsSummary) then,
  ) = _$ProductAnalyticsSummaryCopyWithImpl<$Res, ProductAnalyticsSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_revenue') double totalRevenue,
    @JsonKey(name: 'total_orders') int totalOrders,
    @JsonKey(name: 'total_gross_profit') double totalGrossProfit,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'best_selling_product')
    @_BestSellingProductConverter()
    String bestSellingProduct,
    @JsonKey(name: 'top_territory')
    @_TopTerritoryConverter()
    String topTerritory,
  });
}

/// @nodoc
class _$ProductAnalyticsSummaryCopyWithImpl<
  $Res,
  $Val extends ProductAnalyticsSummary
>
    implements $ProductAnalyticsSummaryCopyWith<$Res> {
  _$ProductAnalyticsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalOrders = null,
    Object? totalGrossProfit = null,
    Object? avgOrderValue = null,
    Object? bestSellingProduct = null,
    Object? topTerritory = null,
  }) {
    return _then(
      _value.copyWith(
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            totalOrders: null == totalOrders
                ? _value.totalOrders
                : totalOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            totalGrossProfit: null == totalGrossProfit
                ? _value.totalGrossProfit
                : totalGrossProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            avgOrderValue: null == avgOrderValue
                ? _value.avgOrderValue
                : avgOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
            bestSellingProduct: null == bestSellingProduct
                ? _value.bestSellingProduct
                : bestSellingProduct // ignore: cast_nullable_to_non_nullable
                      as String,
            topTerritory: null == topTerritory
                ? _value.topTerritory
                : topTerritory // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductAnalyticsSummaryImplCopyWith<$Res>
    implements $ProductAnalyticsSummaryCopyWith<$Res> {
  factory _$$ProductAnalyticsSummaryImplCopyWith(
    _$ProductAnalyticsSummaryImpl value,
    $Res Function(_$ProductAnalyticsSummaryImpl) then,
  ) = __$$ProductAnalyticsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_revenue') double totalRevenue,
    @JsonKey(name: 'total_orders') int totalOrders,
    @JsonKey(name: 'total_gross_profit') double totalGrossProfit,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'best_selling_product')
    @_BestSellingProductConverter()
    String bestSellingProduct,
    @JsonKey(name: 'top_territory')
    @_TopTerritoryConverter()
    String topTerritory,
  });
}

/// @nodoc
class __$$ProductAnalyticsSummaryImplCopyWithImpl<$Res>
    extends
        _$ProductAnalyticsSummaryCopyWithImpl<
          $Res,
          _$ProductAnalyticsSummaryImpl
        >
    implements _$$ProductAnalyticsSummaryImplCopyWith<$Res> {
  __$$ProductAnalyticsSummaryImplCopyWithImpl(
    _$ProductAnalyticsSummaryImpl _value,
    $Res Function(_$ProductAnalyticsSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalOrders = null,
    Object? totalGrossProfit = null,
    Object? avgOrderValue = null,
    Object? bestSellingProduct = null,
    Object? topTerritory = null,
  }) {
    return _then(
      _$ProductAnalyticsSummaryImpl(
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        totalOrders: null == totalOrders
            ? _value.totalOrders
            : totalOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        totalGrossProfit: null == totalGrossProfit
            ? _value.totalGrossProfit
            : totalGrossProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        avgOrderValue: null == avgOrderValue
            ? _value.avgOrderValue
            : avgOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
        bestSellingProduct: null == bestSellingProduct
            ? _value.bestSellingProduct
            : bestSellingProduct // ignore: cast_nullable_to_non_nullable
                  as String,
        topTerritory: null == topTerritory
            ? _value.topTerritory
            : topTerritory // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductAnalyticsSummaryImpl implements _ProductAnalyticsSummary {
  const _$ProductAnalyticsSummaryImpl({
    @JsonKey(name: 'total_revenue') this.totalRevenue = 0,
    @JsonKey(name: 'total_orders') this.totalOrders = 0,
    @JsonKey(name: 'total_gross_profit') this.totalGrossProfit = 0,
    @JsonKey(name: 'avg_order_value') this.avgOrderValue = 0,
    @JsonKey(name: 'best_selling_product')
    @_BestSellingProductConverter()
    this.bestSellingProduct = '',
    @JsonKey(name: 'top_territory')
    @_TopTerritoryConverter()
    this.topTerritory = '',
  });

  factory _$ProductAnalyticsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductAnalyticsSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_revenue')
  final double totalRevenue;
  @override
  @JsonKey(name: 'total_orders')
  final int totalOrders;
  @override
  @JsonKey(name: 'total_gross_profit')
  final double totalGrossProfit;
  @override
  @JsonKey(name: 'avg_order_value')
  final double avgOrderValue;
  // Backend emits an object `{item_name, total_qty}`; extract the name.
  @override
  @JsonKey(name: 'best_selling_product')
  @_BestSellingProductConverter()
  final String bestSellingProduct;
  // Backend emits an object `{territory, revenue}`; extract the territory.
  @override
  @JsonKey(name: 'top_territory')
  @_TopTerritoryConverter()
  final String topTerritory;

  @override
  String toString() {
    return 'ProductAnalyticsSummary(totalRevenue: $totalRevenue, totalOrders: $totalOrders, totalGrossProfit: $totalGrossProfit, avgOrderValue: $avgOrderValue, bestSellingProduct: $bestSellingProduct, topTerritory: $topTerritory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductAnalyticsSummaryImpl &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.totalGrossProfit, totalGrossProfit) ||
                other.totalGrossProfit == totalGrossProfit) &&
            (identical(other.avgOrderValue, avgOrderValue) ||
                other.avgOrderValue == avgOrderValue) &&
            (identical(other.bestSellingProduct, bestSellingProduct) ||
                other.bestSellingProduct == bestSellingProduct) &&
            (identical(other.topTerritory, topTerritory) ||
                other.topTerritory == topTerritory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalRevenue,
    totalOrders,
    totalGrossProfit,
    avgOrderValue,
    bestSellingProduct,
    topTerritory,
  );

  /// Create a copy of ProductAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductAnalyticsSummaryImplCopyWith<_$ProductAnalyticsSummaryImpl>
  get copyWith =>
      __$$ProductAnalyticsSummaryImplCopyWithImpl<
        _$ProductAnalyticsSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductAnalyticsSummaryImplToJson(this);
  }
}

abstract class _ProductAnalyticsSummary implements ProductAnalyticsSummary {
  const factory _ProductAnalyticsSummary({
    @JsonKey(name: 'total_revenue') final double totalRevenue,
    @JsonKey(name: 'total_orders') final int totalOrders,
    @JsonKey(name: 'total_gross_profit') final double totalGrossProfit,
    @JsonKey(name: 'avg_order_value') final double avgOrderValue,
    @JsonKey(name: 'best_selling_product')
    @_BestSellingProductConverter()
    final String bestSellingProduct,
    @JsonKey(name: 'top_territory')
    @_TopTerritoryConverter()
    final String topTerritory,
  }) = _$ProductAnalyticsSummaryImpl;

  factory _ProductAnalyticsSummary.fromJson(Map<String, dynamic> json) =
      _$ProductAnalyticsSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_revenue')
  double get totalRevenue;
  @override
  @JsonKey(name: 'total_orders')
  int get totalOrders;
  @override
  @JsonKey(name: 'total_gross_profit')
  double get totalGrossProfit;
  @override
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue; // Backend emits an object `{item_name, total_qty}`; extract the name.
  @override
  @JsonKey(name: 'best_selling_product')
  @_BestSellingProductConverter()
  String get bestSellingProduct; // Backend emits an object `{territory, revenue}`; extract the territory.
  @override
  @JsonKey(name: 'top_territory')
  @_TopTerritoryConverter()
  String get topTerritory;

  /// Create a copy of ProductAnalyticsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductAnalyticsSummaryImplCopyWith<_$ProductAnalyticsSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
