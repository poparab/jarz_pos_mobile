// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipping_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShippingAnalytics _$ShippingAnalyticsFromJson(Map<String, dynamic> json) {
  return _ShippingAnalytics.fromJson(json);
}

/// @nodoc
mixin _$ShippingAnalytics {
  @JsonKey(name: 'summary_kpis')
  ShippingSummaryKpis get summaryKpis => throw _privateConstructorUsedError;
  List<ShippingAlert> get alerts => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_by_territory')
  List<ShippingTerritoryCost> get costByTerritory =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_by_sub_territory')
  List<ShippingSubTerritoryCost> get costBySubTerritory =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_by_pos_profile')
  List<ShippingPosProfileCost> get costByPosProfile =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_by_courier')
  List<ShippingCourierCost> get costByCourier =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_shipping_breakdown')
  ShippingCustomBreakdown get customShippingBreakdown =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'double_shipping_impact')
  ShippingDoubleImpact get doubleShippingImpact =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_trend')
  List<ShippingDailyTrendPoint> get dailyTrend =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_vs_delivery_split')
  ShippingPickupDeliverySplit get pickupVsDeliverySplit =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'unsettled_courier_balances')
  List<ShippingUnsettledCourierBalance> get unsettledCourierBalances =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_delivery_trend')
  List<ShippingPickupDeliveryTrendPoint> get pickupDeliveryTrend =>
      throw _privateConstructorUsedError;

  /// Serializes this ShippingAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingAnalyticsCopyWith<ShippingAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingAnalyticsCopyWith<$Res> {
  factory $ShippingAnalyticsCopyWith(
    ShippingAnalytics value,
    $Res Function(ShippingAnalytics) then,
  ) = _$ShippingAnalyticsCopyWithImpl<$Res, ShippingAnalytics>;
  @useResult
  $Res call({
    @JsonKey(name: 'summary_kpis') ShippingSummaryKpis summaryKpis,
    List<ShippingAlert> alerts,
    @JsonKey(name: 'cost_by_territory')
    List<ShippingTerritoryCost> costByTerritory,
    @JsonKey(name: 'cost_by_sub_territory')
    List<ShippingSubTerritoryCost> costBySubTerritory,
    @JsonKey(name: 'cost_by_pos_profile')
    List<ShippingPosProfileCost> costByPosProfile,
    @JsonKey(name: 'cost_by_courier') List<ShippingCourierCost> costByCourier,
    @JsonKey(name: 'custom_shipping_breakdown')
    ShippingCustomBreakdown customShippingBreakdown,
    @JsonKey(name: 'double_shipping_impact')
    ShippingDoubleImpact doubleShippingImpact,
    @JsonKey(name: 'daily_trend') List<ShippingDailyTrendPoint> dailyTrend,
    @JsonKey(name: 'pickup_vs_delivery_split')
    ShippingPickupDeliverySplit pickupVsDeliverySplit,
    @JsonKey(name: 'unsettled_courier_balances')
    List<ShippingUnsettledCourierBalance> unsettledCourierBalances,
    @JsonKey(name: 'pickup_delivery_trend')
    List<ShippingPickupDeliveryTrendPoint> pickupDeliveryTrend,
  });

  $ShippingSummaryKpisCopyWith<$Res> get summaryKpis;
  $ShippingCustomBreakdownCopyWith<$Res> get customShippingBreakdown;
  $ShippingDoubleImpactCopyWith<$Res> get doubleShippingImpact;
  $ShippingPickupDeliverySplitCopyWith<$Res> get pickupVsDeliverySplit;
}

/// @nodoc
class _$ShippingAnalyticsCopyWithImpl<$Res, $Val extends ShippingAnalytics>
    implements $ShippingAnalyticsCopyWith<$Res> {
  _$ShippingAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summaryKpis = null,
    Object? alerts = null,
    Object? costByTerritory = null,
    Object? costBySubTerritory = null,
    Object? costByPosProfile = null,
    Object? costByCourier = null,
    Object? customShippingBreakdown = null,
    Object? doubleShippingImpact = null,
    Object? dailyTrend = null,
    Object? pickupVsDeliverySplit = null,
    Object? unsettledCourierBalances = null,
    Object? pickupDeliveryTrend = null,
  }) {
    return _then(
      _value.copyWith(
            summaryKpis: null == summaryKpis
                ? _value.summaryKpis
                : summaryKpis // ignore: cast_nullable_to_non_nullable
                      as ShippingSummaryKpis,
            alerts: null == alerts
                ? _value.alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                      as List<ShippingAlert>,
            costByTerritory: null == costByTerritory
                ? _value.costByTerritory
                : costByTerritory // ignore: cast_nullable_to_non_nullable
                      as List<ShippingTerritoryCost>,
            costBySubTerritory: null == costBySubTerritory
                ? _value.costBySubTerritory
                : costBySubTerritory // ignore: cast_nullable_to_non_nullable
                      as List<ShippingSubTerritoryCost>,
            costByPosProfile: null == costByPosProfile
                ? _value.costByPosProfile
                : costByPosProfile // ignore: cast_nullable_to_non_nullable
                      as List<ShippingPosProfileCost>,
            costByCourier: null == costByCourier
                ? _value.costByCourier
                : costByCourier // ignore: cast_nullable_to_non_nullable
                      as List<ShippingCourierCost>,
            customShippingBreakdown: null == customShippingBreakdown
                ? _value.customShippingBreakdown
                : customShippingBreakdown // ignore: cast_nullable_to_non_nullable
                      as ShippingCustomBreakdown,
            doubleShippingImpact: null == doubleShippingImpact
                ? _value.doubleShippingImpact
                : doubleShippingImpact // ignore: cast_nullable_to_non_nullable
                      as ShippingDoubleImpact,
            dailyTrend: null == dailyTrend
                ? _value.dailyTrend
                : dailyTrend // ignore: cast_nullable_to_non_nullable
                      as List<ShippingDailyTrendPoint>,
            pickupVsDeliverySplit: null == pickupVsDeliverySplit
                ? _value.pickupVsDeliverySplit
                : pickupVsDeliverySplit // ignore: cast_nullable_to_non_nullable
                      as ShippingPickupDeliverySplit,
            unsettledCourierBalances: null == unsettledCourierBalances
                ? _value.unsettledCourierBalances
                : unsettledCourierBalances // ignore: cast_nullable_to_non_nullable
                      as List<ShippingUnsettledCourierBalance>,
            pickupDeliveryTrend: null == pickupDeliveryTrend
                ? _value.pickupDeliveryTrend
                : pickupDeliveryTrend // ignore: cast_nullable_to_non_nullable
                      as List<ShippingPickupDeliveryTrendPoint>,
          )
          as $Val,
    );
  }

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingSummaryKpisCopyWith<$Res> get summaryKpis {
    return $ShippingSummaryKpisCopyWith<$Res>(_value.summaryKpis, (value) {
      return _then(_value.copyWith(summaryKpis: value) as $Val);
    });
  }

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingCustomBreakdownCopyWith<$Res> get customShippingBreakdown {
    return $ShippingCustomBreakdownCopyWith<$Res>(
      _value.customShippingBreakdown,
      (value) {
        return _then(_value.copyWith(customShippingBreakdown: value) as $Val);
      },
    );
  }

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingDoubleImpactCopyWith<$Res> get doubleShippingImpact {
    return $ShippingDoubleImpactCopyWith<$Res>(_value.doubleShippingImpact, (
      value,
    ) {
      return _then(_value.copyWith(doubleShippingImpact: value) as $Val);
    });
  }

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingPickupDeliverySplitCopyWith<$Res> get pickupVsDeliverySplit {
    return $ShippingPickupDeliverySplitCopyWith<$Res>(
      _value.pickupVsDeliverySplit,
      (value) {
        return _then(_value.copyWith(pickupVsDeliverySplit: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$ShippingAnalyticsImplCopyWith<$Res>
    implements $ShippingAnalyticsCopyWith<$Res> {
  factory _$$ShippingAnalyticsImplCopyWith(
    _$ShippingAnalyticsImpl value,
    $Res Function(_$ShippingAnalyticsImpl) then,
  ) = __$$ShippingAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'summary_kpis') ShippingSummaryKpis summaryKpis,
    List<ShippingAlert> alerts,
    @JsonKey(name: 'cost_by_territory')
    List<ShippingTerritoryCost> costByTerritory,
    @JsonKey(name: 'cost_by_sub_territory')
    List<ShippingSubTerritoryCost> costBySubTerritory,
    @JsonKey(name: 'cost_by_pos_profile')
    List<ShippingPosProfileCost> costByPosProfile,
    @JsonKey(name: 'cost_by_courier') List<ShippingCourierCost> costByCourier,
    @JsonKey(name: 'custom_shipping_breakdown')
    ShippingCustomBreakdown customShippingBreakdown,
    @JsonKey(name: 'double_shipping_impact')
    ShippingDoubleImpact doubleShippingImpact,
    @JsonKey(name: 'daily_trend') List<ShippingDailyTrendPoint> dailyTrend,
    @JsonKey(name: 'pickup_vs_delivery_split')
    ShippingPickupDeliverySplit pickupVsDeliverySplit,
    @JsonKey(name: 'unsettled_courier_balances')
    List<ShippingUnsettledCourierBalance> unsettledCourierBalances,
    @JsonKey(name: 'pickup_delivery_trend')
    List<ShippingPickupDeliveryTrendPoint> pickupDeliveryTrend,
  });

  @override
  $ShippingSummaryKpisCopyWith<$Res> get summaryKpis;
  @override
  $ShippingCustomBreakdownCopyWith<$Res> get customShippingBreakdown;
  @override
  $ShippingDoubleImpactCopyWith<$Res> get doubleShippingImpact;
  @override
  $ShippingPickupDeliverySplitCopyWith<$Res> get pickupVsDeliverySplit;
}

/// @nodoc
class __$$ShippingAnalyticsImplCopyWithImpl<$Res>
    extends _$ShippingAnalyticsCopyWithImpl<$Res, _$ShippingAnalyticsImpl>
    implements _$$ShippingAnalyticsImplCopyWith<$Res> {
  __$$ShippingAnalyticsImplCopyWithImpl(
    _$ShippingAnalyticsImpl _value,
    $Res Function(_$ShippingAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summaryKpis = null,
    Object? alerts = null,
    Object? costByTerritory = null,
    Object? costBySubTerritory = null,
    Object? costByPosProfile = null,
    Object? costByCourier = null,
    Object? customShippingBreakdown = null,
    Object? doubleShippingImpact = null,
    Object? dailyTrend = null,
    Object? pickupVsDeliverySplit = null,
    Object? unsettledCourierBalances = null,
    Object? pickupDeliveryTrend = null,
  }) {
    return _then(
      _$ShippingAnalyticsImpl(
        summaryKpis: null == summaryKpis
            ? _value.summaryKpis
            : summaryKpis // ignore: cast_nullable_to_non_nullable
                  as ShippingSummaryKpis,
        alerts: null == alerts
            ? _value._alerts
            : alerts // ignore: cast_nullable_to_non_nullable
                  as List<ShippingAlert>,
        costByTerritory: null == costByTerritory
            ? _value._costByTerritory
            : costByTerritory // ignore: cast_nullable_to_non_nullable
                  as List<ShippingTerritoryCost>,
        costBySubTerritory: null == costBySubTerritory
            ? _value._costBySubTerritory
            : costBySubTerritory // ignore: cast_nullable_to_non_nullable
                  as List<ShippingSubTerritoryCost>,
        costByPosProfile: null == costByPosProfile
            ? _value._costByPosProfile
            : costByPosProfile // ignore: cast_nullable_to_non_nullable
                  as List<ShippingPosProfileCost>,
        costByCourier: null == costByCourier
            ? _value._costByCourier
            : costByCourier // ignore: cast_nullable_to_non_nullable
                  as List<ShippingCourierCost>,
        customShippingBreakdown: null == customShippingBreakdown
            ? _value.customShippingBreakdown
            : customShippingBreakdown // ignore: cast_nullable_to_non_nullable
                  as ShippingCustomBreakdown,
        doubleShippingImpact: null == doubleShippingImpact
            ? _value.doubleShippingImpact
            : doubleShippingImpact // ignore: cast_nullable_to_non_nullable
                  as ShippingDoubleImpact,
        dailyTrend: null == dailyTrend
            ? _value._dailyTrend
            : dailyTrend // ignore: cast_nullable_to_non_nullable
                  as List<ShippingDailyTrendPoint>,
        pickupVsDeliverySplit: null == pickupVsDeliverySplit
            ? _value.pickupVsDeliverySplit
            : pickupVsDeliverySplit // ignore: cast_nullable_to_non_nullable
                  as ShippingPickupDeliverySplit,
        unsettledCourierBalances: null == unsettledCourierBalances
            ? _value._unsettledCourierBalances
            : unsettledCourierBalances // ignore: cast_nullable_to_non_nullable
                  as List<ShippingUnsettledCourierBalance>,
        pickupDeliveryTrend: null == pickupDeliveryTrend
            ? _value._pickupDeliveryTrend
            : pickupDeliveryTrend // ignore: cast_nullable_to_non_nullable
                  as List<ShippingPickupDeliveryTrendPoint>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingAnalyticsImpl implements _ShippingAnalytics {
  const _$ShippingAnalyticsImpl({
    @JsonKey(name: 'summary_kpis')
    this.summaryKpis = const ShippingSummaryKpis(),
    final List<ShippingAlert> alerts = const <ShippingAlert>[],
    @JsonKey(name: 'cost_by_territory')
    final List<ShippingTerritoryCost> costByTerritory =
        const <ShippingTerritoryCost>[],
    @JsonKey(name: 'cost_by_sub_territory')
    final List<ShippingSubTerritoryCost> costBySubTerritory =
        const <ShippingSubTerritoryCost>[],
    @JsonKey(name: 'cost_by_pos_profile')
    final List<ShippingPosProfileCost> costByPosProfile =
        const <ShippingPosProfileCost>[],
    @JsonKey(name: 'cost_by_courier')
    final List<ShippingCourierCost> costByCourier =
        const <ShippingCourierCost>[],
    @JsonKey(name: 'custom_shipping_breakdown')
    this.customShippingBreakdown = const ShippingCustomBreakdown(),
    @JsonKey(name: 'double_shipping_impact')
    this.doubleShippingImpact = const ShippingDoubleImpact(),
    @JsonKey(name: 'daily_trend')
    final List<ShippingDailyTrendPoint> dailyTrend =
        const <ShippingDailyTrendPoint>[],
    @JsonKey(name: 'pickup_vs_delivery_split')
    this.pickupVsDeliverySplit = const ShippingPickupDeliverySplit(),
    @JsonKey(name: 'unsettled_courier_balances')
    final List<ShippingUnsettledCourierBalance> unsettledCourierBalances =
        const <ShippingUnsettledCourierBalance>[],
    @JsonKey(name: 'pickup_delivery_trend')
    final List<ShippingPickupDeliveryTrendPoint> pickupDeliveryTrend =
        const <ShippingPickupDeliveryTrendPoint>[],
  }) : _alerts = alerts,
       _costByTerritory = costByTerritory,
       _costBySubTerritory = costBySubTerritory,
       _costByPosProfile = costByPosProfile,
       _costByCourier = costByCourier,
       _dailyTrend = dailyTrend,
       _unsettledCourierBalances = unsettledCourierBalances,
       _pickupDeliveryTrend = pickupDeliveryTrend;

  factory _$ShippingAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingAnalyticsImplFromJson(json);

  @override
  @JsonKey(name: 'summary_kpis')
  final ShippingSummaryKpis summaryKpis;
  final List<ShippingAlert> _alerts;
  @override
  @JsonKey()
  List<ShippingAlert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  final List<ShippingTerritoryCost> _costByTerritory;
  @override
  @JsonKey(name: 'cost_by_territory')
  List<ShippingTerritoryCost> get costByTerritory {
    if (_costByTerritory is EqualUnmodifiableListView) return _costByTerritory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_costByTerritory);
  }

  final List<ShippingSubTerritoryCost> _costBySubTerritory;
  @override
  @JsonKey(name: 'cost_by_sub_territory')
  List<ShippingSubTerritoryCost> get costBySubTerritory {
    if (_costBySubTerritory is EqualUnmodifiableListView)
      return _costBySubTerritory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_costBySubTerritory);
  }

  final List<ShippingPosProfileCost> _costByPosProfile;
  @override
  @JsonKey(name: 'cost_by_pos_profile')
  List<ShippingPosProfileCost> get costByPosProfile {
    if (_costByPosProfile is EqualUnmodifiableListView)
      return _costByPosProfile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_costByPosProfile);
  }

  final List<ShippingCourierCost> _costByCourier;
  @override
  @JsonKey(name: 'cost_by_courier')
  List<ShippingCourierCost> get costByCourier {
    if (_costByCourier is EqualUnmodifiableListView) return _costByCourier;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_costByCourier);
  }

  @override
  @JsonKey(name: 'custom_shipping_breakdown')
  final ShippingCustomBreakdown customShippingBreakdown;
  @override
  @JsonKey(name: 'double_shipping_impact')
  final ShippingDoubleImpact doubleShippingImpact;
  final List<ShippingDailyTrendPoint> _dailyTrend;
  @override
  @JsonKey(name: 'daily_trend')
  List<ShippingDailyTrendPoint> get dailyTrend {
    if (_dailyTrend is EqualUnmodifiableListView) return _dailyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyTrend);
  }

  @override
  @JsonKey(name: 'pickup_vs_delivery_split')
  final ShippingPickupDeliverySplit pickupVsDeliverySplit;
  final List<ShippingUnsettledCourierBalance> _unsettledCourierBalances;
  @override
  @JsonKey(name: 'unsettled_courier_balances')
  List<ShippingUnsettledCourierBalance> get unsettledCourierBalances {
    if (_unsettledCourierBalances is EqualUnmodifiableListView)
      return _unsettledCourierBalances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unsettledCourierBalances);
  }

  final List<ShippingPickupDeliveryTrendPoint> _pickupDeliveryTrend;
  @override
  @JsonKey(name: 'pickup_delivery_trend')
  List<ShippingPickupDeliveryTrendPoint> get pickupDeliveryTrend {
    if (_pickupDeliveryTrend is EqualUnmodifiableListView)
      return _pickupDeliveryTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pickupDeliveryTrend);
  }

  @override
  String toString() {
    return 'ShippingAnalytics(summaryKpis: $summaryKpis, alerts: $alerts, costByTerritory: $costByTerritory, costBySubTerritory: $costBySubTerritory, costByPosProfile: $costByPosProfile, costByCourier: $costByCourier, customShippingBreakdown: $customShippingBreakdown, doubleShippingImpact: $doubleShippingImpact, dailyTrend: $dailyTrend, pickupVsDeliverySplit: $pickupVsDeliverySplit, unsettledCourierBalances: $unsettledCourierBalances, pickupDeliveryTrend: $pickupDeliveryTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingAnalyticsImpl &&
            (identical(other.summaryKpis, summaryKpis) ||
                other.summaryKpis == summaryKpis) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            const DeepCollectionEquality().equals(
              other._costByTerritory,
              _costByTerritory,
            ) &&
            const DeepCollectionEquality().equals(
              other._costBySubTerritory,
              _costBySubTerritory,
            ) &&
            const DeepCollectionEquality().equals(
              other._costByPosProfile,
              _costByPosProfile,
            ) &&
            const DeepCollectionEquality().equals(
              other._costByCourier,
              _costByCourier,
            ) &&
            (identical(
                  other.customShippingBreakdown,
                  customShippingBreakdown,
                ) ||
                other.customShippingBreakdown == customShippingBreakdown) &&
            (identical(other.doubleShippingImpact, doubleShippingImpact) ||
                other.doubleShippingImpact == doubleShippingImpact) &&
            const DeepCollectionEquality().equals(
              other._dailyTrend,
              _dailyTrend,
            ) &&
            (identical(other.pickupVsDeliverySplit, pickupVsDeliverySplit) ||
                other.pickupVsDeliverySplit == pickupVsDeliverySplit) &&
            const DeepCollectionEquality().equals(
              other._unsettledCourierBalances,
              _unsettledCourierBalances,
            ) &&
            const DeepCollectionEquality().equals(
              other._pickupDeliveryTrend,
              _pickupDeliveryTrend,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    summaryKpis,
    const DeepCollectionEquality().hash(_alerts),
    const DeepCollectionEquality().hash(_costByTerritory),
    const DeepCollectionEquality().hash(_costBySubTerritory),
    const DeepCollectionEquality().hash(_costByPosProfile),
    const DeepCollectionEquality().hash(_costByCourier),
    customShippingBreakdown,
    doubleShippingImpact,
    const DeepCollectionEquality().hash(_dailyTrend),
    pickupVsDeliverySplit,
    const DeepCollectionEquality().hash(_unsettledCourierBalances),
    const DeepCollectionEquality().hash(_pickupDeliveryTrend),
  );

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingAnalyticsImplCopyWith<_$ShippingAnalyticsImpl> get copyWith =>
      __$$ShippingAnalyticsImplCopyWithImpl<_$ShippingAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingAnalyticsImplToJson(this);
  }
}

abstract class _ShippingAnalytics implements ShippingAnalytics {
  const factory _ShippingAnalytics({
    @JsonKey(name: 'summary_kpis') final ShippingSummaryKpis summaryKpis,
    final List<ShippingAlert> alerts,
    @JsonKey(name: 'cost_by_territory')
    final List<ShippingTerritoryCost> costByTerritory,
    @JsonKey(name: 'cost_by_sub_territory')
    final List<ShippingSubTerritoryCost> costBySubTerritory,
    @JsonKey(name: 'cost_by_pos_profile')
    final List<ShippingPosProfileCost> costByPosProfile,
    @JsonKey(name: 'cost_by_courier')
    final List<ShippingCourierCost> costByCourier,
    @JsonKey(name: 'custom_shipping_breakdown')
    final ShippingCustomBreakdown customShippingBreakdown,
    @JsonKey(name: 'double_shipping_impact')
    final ShippingDoubleImpact doubleShippingImpact,
    @JsonKey(name: 'daily_trend')
    final List<ShippingDailyTrendPoint> dailyTrend,
    @JsonKey(name: 'pickup_vs_delivery_split')
    final ShippingPickupDeliverySplit pickupVsDeliverySplit,
    @JsonKey(name: 'unsettled_courier_balances')
    final List<ShippingUnsettledCourierBalance> unsettledCourierBalances,
    @JsonKey(name: 'pickup_delivery_trend')
    final List<ShippingPickupDeliveryTrendPoint> pickupDeliveryTrend,
  }) = _$ShippingAnalyticsImpl;

  factory _ShippingAnalytics.fromJson(Map<String, dynamic> json) =
      _$ShippingAnalyticsImpl.fromJson;

  @override
  @JsonKey(name: 'summary_kpis')
  ShippingSummaryKpis get summaryKpis;
  @override
  List<ShippingAlert> get alerts;
  @override
  @JsonKey(name: 'cost_by_territory')
  List<ShippingTerritoryCost> get costByTerritory;
  @override
  @JsonKey(name: 'cost_by_sub_territory')
  List<ShippingSubTerritoryCost> get costBySubTerritory;
  @override
  @JsonKey(name: 'cost_by_pos_profile')
  List<ShippingPosProfileCost> get costByPosProfile;
  @override
  @JsonKey(name: 'cost_by_courier')
  List<ShippingCourierCost> get costByCourier;
  @override
  @JsonKey(name: 'custom_shipping_breakdown')
  ShippingCustomBreakdown get customShippingBreakdown;
  @override
  @JsonKey(name: 'double_shipping_impact')
  ShippingDoubleImpact get doubleShippingImpact;
  @override
  @JsonKey(name: 'daily_trend')
  List<ShippingDailyTrendPoint> get dailyTrend;
  @override
  @JsonKey(name: 'pickup_vs_delivery_split')
  ShippingPickupDeliverySplit get pickupVsDeliverySplit;
  @override
  @JsonKey(name: 'unsettled_courier_balances')
  List<ShippingUnsettledCourierBalance> get unsettledCourierBalances;
  @override
  @JsonKey(name: 'pickup_delivery_trend')
  List<ShippingPickupDeliveryTrendPoint> get pickupDeliveryTrend;

  /// Create a copy of ShippingAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingAnalyticsImplCopyWith<_$ShippingAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShippingSummaryKpis _$ShippingSummaryKpisFromJson(Map<String, dynamic> json) {
  return _ShippingSummaryKpis.fromJson(json);
}

/// @nodoc
mixin _$ShippingSummaryKpis {
  @JsonKey(name: 'total_orders')
  int get totalOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_orders')
  int get deliveryOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_orders')
  int get pickupOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_income')
  double get totalIncome => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_pl')
  double get netPl => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_cost_per_order')
  double get avgCostPerOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_csr_count')
  int get pendingCsrCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'unsettled_courier_total')
  double get unsettledCourierTotal => throw _privateConstructorUsedError;

  /// Serializes this ShippingSummaryKpis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingSummaryKpis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingSummaryKpisCopyWith<ShippingSummaryKpis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingSummaryKpisCopyWith<$Res> {
  factory $ShippingSummaryKpisCopyWith(
    ShippingSummaryKpis value,
    $Res Function(ShippingSummaryKpis) then,
  ) = _$ShippingSummaryKpisCopyWithImpl<$Res, ShippingSummaryKpis>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_orders') int totalOrders,
    @JsonKey(name: 'delivery_orders') int deliveryOrders,
    @JsonKey(name: 'pickup_orders') int pickupOrders,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'net_pl') double netPl,
    @JsonKey(name: 'avg_cost_per_order') double avgCostPerOrder,
    @JsonKey(name: 'pending_csr_count') int pendingCsrCount,
    @JsonKey(name: 'unsettled_courier_total') double unsettledCourierTotal,
  });
}

/// @nodoc
class _$ShippingSummaryKpisCopyWithImpl<$Res, $Val extends ShippingSummaryKpis>
    implements $ShippingSummaryKpisCopyWith<$Res> {
  _$ShippingSummaryKpisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingSummaryKpis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOrders = null,
    Object? deliveryOrders = null,
    Object? pickupOrders = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? netPl = null,
    Object? avgCostPerOrder = null,
    Object? pendingCsrCount = null,
    Object? unsettledCourierTotal = null,
  }) {
    return _then(
      _value.copyWith(
            totalOrders: null == totalOrders
                ? _value.totalOrders
                : totalOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveryOrders: null == deliveryOrders
                ? _value.deliveryOrders
                : deliveryOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            pickupOrders: null == pickupOrders
                ? _value.pickupOrders
                : pickupOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            netPl: null == netPl
                ? _value.netPl
                : netPl // ignore: cast_nullable_to_non_nullable
                      as double,
            avgCostPerOrder: null == avgCostPerOrder
                ? _value.avgCostPerOrder
                : avgCostPerOrder // ignore: cast_nullable_to_non_nullable
                      as double,
            pendingCsrCount: null == pendingCsrCount
                ? _value.pendingCsrCount
                : pendingCsrCount // ignore: cast_nullable_to_non_nullable
                      as int,
            unsettledCourierTotal: null == unsettledCourierTotal
                ? _value.unsettledCourierTotal
                : unsettledCourierTotal // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingSummaryKpisImplCopyWith<$Res>
    implements $ShippingSummaryKpisCopyWith<$Res> {
  factory _$$ShippingSummaryKpisImplCopyWith(
    _$ShippingSummaryKpisImpl value,
    $Res Function(_$ShippingSummaryKpisImpl) then,
  ) = __$$ShippingSummaryKpisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_orders') int totalOrders,
    @JsonKey(name: 'delivery_orders') int deliveryOrders,
    @JsonKey(name: 'pickup_orders') int pickupOrders,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'net_pl') double netPl,
    @JsonKey(name: 'avg_cost_per_order') double avgCostPerOrder,
    @JsonKey(name: 'pending_csr_count') int pendingCsrCount,
    @JsonKey(name: 'unsettled_courier_total') double unsettledCourierTotal,
  });
}

/// @nodoc
class __$$ShippingSummaryKpisImplCopyWithImpl<$Res>
    extends _$ShippingSummaryKpisCopyWithImpl<$Res, _$ShippingSummaryKpisImpl>
    implements _$$ShippingSummaryKpisImplCopyWith<$Res> {
  __$$ShippingSummaryKpisImplCopyWithImpl(
    _$ShippingSummaryKpisImpl _value,
    $Res Function(_$ShippingSummaryKpisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingSummaryKpis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOrders = null,
    Object? deliveryOrders = null,
    Object? pickupOrders = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? netPl = null,
    Object? avgCostPerOrder = null,
    Object? pendingCsrCount = null,
    Object? unsettledCourierTotal = null,
  }) {
    return _then(
      _$ShippingSummaryKpisImpl(
        totalOrders: null == totalOrders
            ? _value.totalOrders
            : totalOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveryOrders: null == deliveryOrders
            ? _value.deliveryOrders
            : deliveryOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        pickupOrders: null == pickupOrders
            ? _value.pickupOrders
            : pickupOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        netPl: null == netPl
            ? _value.netPl
            : netPl // ignore: cast_nullable_to_non_nullable
                  as double,
        avgCostPerOrder: null == avgCostPerOrder
            ? _value.avgCostPerOrder
            : avgCostPerOrder // ignore: cast_nullable_to_non_nullable
                  as double,
        pendingCsrCount: null == pendingCsrCount
            ? _value.pendingCsrCount
            : pendingCsrCount // ignore: cast_nullable_to_non_nullable
                  as int,
        unsettledCourierTotal: null == unsettledCourierTotal
            ? _value.unsettledCourierTotal
            : unsettledCourierTotal // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingSummaryKpisImpl implements _ShippingSummaryKpis {
  const _$ShippingSummaryKpisImpl({
    @JsonKey(name: 'total_orders') this.totalOrders = 0,
    @JsonKey(name: 'delivery_orders') this.deliveryOrders = 0,
    @JsonKey(name: 'pickup_orders') this.pickupOrders = 0,
    @JsonKey(name: 'total_expense') this.totalExpense = 0,
    @JsonKey(name: 'total_income') this.totalIncome = 0,
    @JsonKey(name: 'net_pl') this.netPl = 0,
    @JsonKey(name: 'avg_cost_per_order') this.avgCostPerOrder = 0,
    @JsonKey(name: 'pending_csr_count') this.pendingCsrCount = 0,
    @JsonKey(name: 'unsettled_courier_total') this.unsettledCourierTotal = 0,
  });

  factory _$ShippingSummaryKpisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingSummaryKpisImplFromJson(json);

  @override
  @JsonKey(name: 'total_orders')
  final int totalOrders;
  @override
  @JsonKey(name: 'delivery_orders')
  final int deliveryOrders;
  @override
  @JsonKey(name: 'pickup_orders')
  final int pickupOrders;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @override
  @JsonKey(name: 'total_income')
  final double totalIncome;
  @override
  @JsonKey(name: 'net_pl')
  final double netPl;
  @override
  @JsonKey(name: 'avg_cost_per_order')
  final double avgCostPerOrder;
  @override
  @JsonKey(name: 'pending_csr_count')
  final int pendingCsrCount;
  @override
  @JsonKey(name: 'unsettled_courier_total')
  final double unsettledCourierTotal;

  @override
  String toString() {
    return 'ShippingSummaryKpis(totalOrders: $totalOrders, deliveryOrders: $deliveryOrders, pickupOrders: $pickupOrders, totalExpense: $totalExpense, totalIncome: $totalIncome, netPl: $netPl, avgCostPerOrder: $avgCostPerOrder, pendingCsrCount: $pendingCsrCount, unsettledCourierTotal: $unsettledCourierTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingSummaryKpisImpl &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.deliveryOrders, deliveryOrders) ||
                other.deliveryOrders == deliveryOrders) &&
            (identical(other.pickupOrders, pickupOrders) ||
                other.pickupOrders == pickupOrders) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.netPl, netPl) || other.netPl == netPl) &&
            (identical(other.avgCostPerOrder, avgCostPerOrder) ||
                other.avgCostPerOrder == avgCostPerOrder) &&
            (identical(other.pendingCsrCount, pendingCsrCount) ||
                other.pendingCsrCount == pendingCsrCount) &&
            (identical(other.unsettledCourierTotal, unsettledCourierTotal) ||
                other.unsettledCourierTotal == unsettledCourierTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalOrders,
    deliveryOrders,
    pickupOrders,
    totalExpense,
    totalIncome,
    netPl,
    avgCostPerOrder,
    pendingCsrCount,
    unsettledCourierTotal,
  );

  /// Create a copy of ShippingSummaryKpis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingSummaryKpisImplCopyWith<_$ShippingSummaryKpisImpl> get copyWith =>
      __$$ShippingSummaryKpisImplCopyWithImpl<_$ShippingSummaryKpisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingSummaryKpisImplToJson(this);
  }
}

abstract class _ShippingSummaryKpis implements ShippingSummaryKpis {
  const factory _ShippingSummaryKpis({
    @JsonKey(name: 'total_orders') final int totalOrders,
    @JsonKey(name: 'delivery_orders') final int deliveryOrders,
    @JsonKey(name: 'pickup_orders') final int pickupOrders,
    @JsonKey(name: 'total_expense') final double totalExpense,
    @JsonKey(name: 'total_income') final double totalIncome,
    @JsonKey(name: 'net_pl') final double netPl,
    @JsonKey(name: 'avg_cost_per_order') final double avgCostPerOrder,
    @JsonKey(name: 'pending_csr_count') final int pendingCsrCount,
    @JsonKey(name: 'unsettled_courier_total')
    final double unsettledCourierTotal,
  }) = _$ShippingSummaryKpisImpl;

  factory _ShippingSummaryKpis.fromJson(Map<String, dynamic> json) =
      _$ShippingSummaryKpisImpl.fromJson;

  @override
  @JsonKey(name: 'total_orders')
  int get totalOrders;
  @override
  @JsonKey(name: 'delivery_orders')
  int get deliveryOrders;
  @override
  @JsonKey(name: 'pickup_orders')
  int get pickupOrders;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;
  @override
  @JsonKey(name: 'total_income')
  double get totalIncome;
  @override
  @JsonKey(name: 'net_pl')
  double get netPl;
  @override
  @JsonKey(name: 'avg_cost_per_order')
  double get avgCostPerOrder;
  @override
  @JsonKey(name: 'pending_csr_count')
  int get pendingCsrCount;
  @override
  @JsonKey(name: 'unsettled_courier_total')
  double get unsettledCourierTotal;

  /// Create a copy of ShippingSummaryKpis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingSummaryKpisImplCopyWith<_$ShippingSummaryKpisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShippingAlert _$ShippingAlertFromJson(Map<String, dynamic> json) {
  return _ShippingAlert.fromJson(json);
}

/// @nodoc
mixin _$ShippingAlert {
  String get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this ShippingAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingAlertCopyWith<ShippingAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingAlertCopyWith<$Res> {
  factory $ShippingAlertCopyWith(
    ShippingAlert value,
    $Res Function(ShippingAlert) then,
  ) = _$ShippingAlertCopyWithImpl<$Res, ShippingAlert>;
  @useResult
  $Res call({String type, String message});
}

/// @nodoc
class _$ShippingAlertCopyWithImpl<$Res, $Val extends ShippingAlert>
    implements $ShippingAlertCopyWith<$Res> {
  _$ShippingAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingAlertImplCopyWith<$Res>
    implements $ShippingAlertCopyWith<$Res> {
  factory _$$ShippingAlertImplCopyWith(
    _$ShippingAlertImpl value,
    $Res Function(_$ShippingAlertImpl) then,
  ) = __$$ShippingAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String message});
}

/// @nodoc
class __$$ShippingAlertImplCopyWithImpl<$Res>
    extends _$ShippingAlertCopyWithImpl<$Res, _$ShippingAlertImpl>
    implements _$$ShippingAlertImplCopyWith<$Res> {
  __$$ShippingAlertImplCopyWithImpl(
    _$ShippingAlertImpl _value,
    $Res Function(_$ShippingAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? message = null}) {
    return _then(
      _$ShippingAlertImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingAlertImpl implements _ShippingAlert {
  const _$ShippingAlertImpl({this.type = 'info', this.message = ''});

  factory _$ShippingAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingAlertImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ShippingAlert(type: $type, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingAlertImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, message);

  /// Create a copy of ShippingAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingAlertImplCopyWith<_$ShippingAlertImpl> get copyWith =>
      __$$ShippingAlertImplCopyWithImpl<_$ShippingAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingAlertImplToJson(this);
  }
}

abstract class _ShippingAlert implements ShippingAlert {
  const factory _ShippingAlert({final String type, final String message}) =
      _$ShippingAlertImpl;

  factory _ShippingAlert.fromJson(Map<String, dynamic> json) =
      _$ShippingAlertImpl.fromJson;

  @override
  String get type;
  @override
  String get message;

  /// Create a copy of ShippingAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingAlertImplCopyWith<_$ShippingAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShippingTerritoryCost _$ShippingTerritoryCostFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingTerritoryCost.fromJson(json);
}

/// @nodoc
mixin _$ShippingTerritoryCost {
  String get territory => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_count')
  int get orderCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_income')
  double get totalIncome => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_pl')
  double get netPl => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_cost')
  double get avgCost => throw _privateConstructorUsedError;

  /// Serializes this ShippingTerritoryCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingTerritoryCostCopyWith<ShippingTerritoryCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingTerritoryCostCopyWith<$Res> {
  factory $ShippingTerritoryCostCopyWith(
    ShippingTerritoryCost value,
    $Res Function(ShippingTerritoryCost) then,
  ) = _$ShippingTerritoryCostCopyWithImpl<$Res, ShippingTerritoryCost>;
  @useResult
  $Res call({
    String territory,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'net_pl') double netPl,
    @JsonKey(name: 'avg_cost') double avgCost,
  });
}

/// @nodoc
class _$ShippingTerritoryCostCopyWithImpl<
  $Res,
  $Val extends ShippingTerritoryCost
>
    implements $ShippingTerritoryCostCopyWith<$Res> {
  _$ShippingTerritoryCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? territory = null,
    Object? orderCount = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? netPl = null,
    Object? avgCost = null,
  }) {
    return _then(
      _value.copyWith(
            territory: null == territory
                ? _value.territory
                : territory // ignore: cast_nullable_to_non_nullable
                      as String,
            orderCount: null == orderCount
                ? _value.orderCount
                : orderCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            netPl: null == netPl
                ? _value.netPl
                : netPl // ignore: cast_nullable_to_non_nullable
                      as double,
            avgCost: null == avgCost
                ? _value.avgCost
                : avgCost // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingTerritoryCostImplCopyWith<$Res>
    implements $ShippingTerritoryCostCopyWith<$Res> {
  factory _$$ShippingTerritoryCostImplCopyWith(
    _$ShippingTerritoryCostImpl value,
    $Res Function(_$ShippingTerritoryCostImpl) then,
  ) = __$$ShippingTerritoryCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String territory,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'net_pl') double netPl,
    @JsonKey(name: 'avg_cost') double avgCost,
  });
}

/// @nodoc
class __$$ShippingTerritoryCostImplCopyWithImpl<$Res>
    extends
        _$ShippingTerritoryCostCopyWithImpl<$Res, _$ShippingTerritoryCostImpl>
    implements _$$ShippingTerritoryCostImplCopyWith<$Res> {
  __$$ShippingTerritoryCostImplCopyWithImpl(
    _$ShippingTerritoryCostImpl _value,
    $Res Function(_$ShippingTerritoryCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? territory = null,
    Object? orderCount = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? netPl = null,
    Object? avgCost = null,
  }) {
    return _then(
      _$ShippingTerritoryCostImpl(
        territory: null == territory
            ? _value.territory
            : territory // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCount: null == orderCount
            ? _value.orderCount
            : orderCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        netPl: null == netPl
            ? _value.netPl
            : netPl // ignore: cast_nullable_to_non_nullable
                  as double,
        avgCost: null == avgCost
            ? _value.avgCost
            : avgCost // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingTerritoryCostImpl implements _ShippingTerritoryCost {
  const _$ShippingTerritoryCostImpl({
    this.territory = '',
    @JsonKey(name: 'order_count') this.orderCount = 0,
    @JsonKey(name: 'total_expense') this.totalExpense = 0,
    @JsonKey(name: 'total_income') this.totalIncome = 0,
    @JsonKey(name: 'net_pl') this.netPl = 0,
    @JsonKey(name: 'avg_cost') this.avgCost = 0,
  });

  factory _$ShippingTerritoryCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingTerritoryCostImplFromJson(json);

  @override
  @JsonKey()
  final String territory;
  @override
  @JsonKey(name: 'order_count')
  final int orderCount;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @override
  @JsonKey(name: 'total_income')
  final double totalIncome;
  @override
  @JsonKey(name: 'net_pl')
  final double netPl;
  @override
  @JsonKey(name: 'avg_cost')
  final double avgCost;

  @override
  String toString() {
    return 'ShippingTerritoryCost(territory: $territory, orderCount: $orderCount, totalExpense: $totalExpense, totalIncome: $totalIncome, netPl: $netPl, avgCost: $avgCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingTerritoryCostImpl &&
            (identical(other.territory, territory) ||
                other.territory == territory) &&
            (identical(other.orderCount, orderCount) ||
                other.orderCount == orderCount) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.netPl, netPl) || other.netPl == netPl) &&
            (identical(other.avgCost, avgCost) || other.avgCost == avgCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    territory,
    orderCount,
    totalExpense,
    totalIncome,
    netPl,
    avgCost,
  );

  /// Create a copy of ShippingTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingTerritoryCostImplCopyWith<_$ShippingTerritoryCostImpl>
  get copyWith =>
      __$$ShippingTerritoryCostImplCopyWithImpl<_$ShippingTerritoryCostImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingTerritoryCostImplToJson(this);
  }
}

abstract class _ShippingTerritoryCost implements ShippingTerritoryCost {
  const factory _ShippingTerritoryCost({
    final String territory,
    @JsonKey(name: 'order_count') final int orderCount,
    @JsonKey(name: 'total_expense') final double totalExpense,
    @JsonKey(name: 'total_income') final double totalIncome,
    @JsonKey(name: 'net_pl') final double netPl,
    @JsonKey(name: 'avg_cost') final double avgCost,
  }) = _$ShippingTerritoryCostImpl;

  factory _ShippingTerritoryCost.fromJson(Map<String, dynamic> json) =
      _$ShippingTerritoryCostImpl.fromJson;

  @override
  String get territory;
  @override
  @JsonKey(name: 'order_count')
  int get orderCount;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;
  @override
  @JsonKey(name: 'total_income')
  double get totalIncome;
  @override
  @JsonKey(name: 'net_pl')
  double get netPl;
  @override
  @JsonKey(name: 'avg_cost')
  double get avgCost;

  /// Create a copy of ShippingTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingTerritoryCostImplCopyWith<_$ShippingTerritoryCostImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingSubTerritoryCost _$ShippingSubTerritoryCostFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingSubTerritoryCost.fromJson(json);
}

/// @nodoc
mixin _$ShippingSubTerritoryCost {
  @JsonKey(name: 'sub_territory')
  String get subTerritory => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;

  /// Serializes this ShippingSubTerritoryCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingSubTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingSubTerritoryCostCopyWith<ShippingSubTerritoryCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingSubTerritoryCostCopyWith<$Res> {
  factory $ShippingSubTerritoryCostCopyWith(
    ShippingSubTerritoryCost value,
    $Res Function(ShippingSubTerritoryCost) then,
  ) = _$ShippingSubTerritoryCostCopyWithImpl<$Res, ShippingSubTerritoryCost>;
  @useResult
  $Res call({
    @JsonKey(name: 'sub_territory') String subTerritory,
    @JsonKey(name: 'total_expense') double totalExpense,
  });
}

/// @nodoc
class _$ShippingSubTerritoryCostCopyWithImpl<
  $Res,
  $Val extends ShippingSubTerritoryCost
>
    implements $ShippingSubTerritoryCostCopyWith<$Res> {
  _$ShippingSubTerritoryCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingSubTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? subTerritory = null, Object? totalExpense = null}) {
    return _then(
      _value.copyWith(
            subTerritory: null == subTerritory
                ? _value.subTerritory
                : subTerritory // ignore: cast_nullable_to_non_nullable
                      as String,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingSubTerritoryCostImplCopyWith<$Res>
    implements $ShippingSubTerritoryCostCopyWith<$Res> {
  factory _$$ShippingSubTerritoryCostImplCopyWith(
    _$ShippingSubTerritoryCostImpl value,
    $Res Function(_$ShippingSubTerritoryCostImpl) then,
  ) = __$$ShippingSubTerritoryCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'sub_territory') String subTerritory,
    @JsonKey(name: 'total_expense') double totalExpense,
  });
}

/// @nodoc
class __$$ShippingSubTerritoryCostImplCopyWithImpl<$Res>
    extends
        _$ShippingSubTerritoryCostCopyWithImpl<
          $Res,
          _$ShippingSubTerritoryCostImpl
        >
    implements _$$ShippingSubTerritoryCostImplCopyWith<$Res> {
  __$$ShippingSubTerritoryCostImplCopyWithImpl(
    _$ShippingSubTerritoryCostImpl _value,
    $Res Function(_$ShippingSubTerritoryCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingSubTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? subTerritory = null, Object? totalExpense = null}) {
    return _then(
      _$ShippingSubTerritoryCostImpl(
        subTerritory: null == subTerritory
            ? _value.subTerritory
            : subTerritory // ignore: cast_nullable_to_non_nullable
                  as String,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingSubTerritoryCostImpl implements _ShippingSubTerritoryCost {
  const _$ShippingSubTerritoryCostImpl({
    @JsonKey(name: 'sub_territory') this.subTerritory = '',
    @JsonKey(name: 'total_expense') this.totalExpense = 0,
  });

  factory _$ShippingSubTerritoryCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingSubTerritoryCostImplFromJson(json);

  @override
  @JsonKey(name: 'sub_territory')
  final String subTerritory;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;

  @override
  String toString() {
    return 'ShippingSubTerritoryCost(subTerritory: $subTerritory, totalExpense: $totalExpense)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingSubTerritoryCostImpl &&
            (identical(other.subTerritory, subTerritory) ||
                other.subTerritory == subTerritory) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subTerritory, totalExpense);

  /// Create a copy of ShippingSubTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingSubTerritoryCostImplCopyWith<_$ShippingSubTerritoryCostImpl>
  get copyWith =>
      __$$ShippingSubTerritoryCostImplCopyWithImpl<
        _$ShippingSubTerritoryCostImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingSubTerritoryCostImplToJson(this);
  }
}

abstract class _ShippingSubTerritoryCost implements ShippingSubTerritoryCost {
  const factory _ShippingSubTerritoryCost({
    @JsonKey(name: 'sub_territory') final String subTerritory,
    @JsonKey(name: 'total_expense') final double totalExpense,
  }) = _$ShippingSubTerritoryCostImpl;

  factory _ShippingSubTerritoryCost.fromJson(Map<String, dynamic> json) =
      _$ShippingSubTerritoryCostImpl.fromJson;

  @override
  @JsonKey(name: 'sub_territory')
  String get subTerritory;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;

  /// Create a copy of ShippingSubTerritoryCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingSubTerritoryCostImplCopyWith<_$ShippingSubTerritoryCostImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingPosProfileCost _$ShippingPosProfileCostFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingPosProfileCost.fromJson(json);
}

/// @nodoc
mixin _$ShippingPosProfileCost {
  String get branch => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_income')
  double get totalIncome => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_cost')
  double get avgCost => throw _privateConstructorUsedError;

  /// Serializes this ShippingPosProfileCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingPosProfileCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingPosProfileCostCopyWith<ShippingPosProfileCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingPosProfileCostCopyWith<$Res> {
  factory $ShippingPosProfileCostCopyWith(
    ShippingPosProfileCost value,
    $Res Function(ShippingPosProfileCost) then,
  ) = _$ShippingPosProfileCostCopyWithImpl<$Res, ShippingPosProfileCost>;
  @useResult
  $Res call({
    String branch,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'avg_cost') double avgCost,
  });
}

/// @nodoc
class _$ShippingPosProfileCostCopyWithImpl<
  $Res,
  $Val extends ShippingPosProfileCost
>
    implements $ShippingPosProfileCostCopyWith<$Res> {
  _$ShippingPosProfileCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingPosProfileCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branch = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? avgCost = null,
  }) {
    return _then(
      _value.copyWith(
            branch: null == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as String,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            avgCost: null == avgCost
                ? _value.avgCost
                : avgCost // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingPosProfileCostImplCopyWith<$Res>
    implements $ShippingPosProfileCostCopyWith<$Res> {
  factory _$$ShippingPosProfileCostImplCopyWith(
    _$ShippingPosProfileCostImpl value,
    $Res Function(_$ShippingPosProfileCostImpl) then,
  ) = __$$ShippingPosProfileCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String branch,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
    @JsonKey(name: 'avg_cost') double avgCost,
  });
}

/// @nodoc
class __$$ShippingPosProfileCostImplCopyWithImpl<$Res>
    extends
        _$ShippingPosProfileCostCopyWithImpl<$Res, _$ShippingPosProfileCostImpl>
    implements _$$ShippingPosProfileCostImplCopyWith<$Res> {
  __$$ShippingPosProfileCostImplCopyWithImpl(
    _$ShippingPosProfileCostImpl _value,
    $Res Function(_$ShippingPosProfileCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingPosProfileCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branch = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
    Object? avgCost = null,
  }) {
    return _then(
      _$ShippingPosProfileCostImpl(
        branch: null == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as String,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        avgCost: null == avgCost
            ? _value.avgCost
            : avgCost // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingPosProfileCostImpl implements _ShippingPosProfileCost {
  const _$ShippingPosProfileCostImpl({
    this.branch = '',
    @JsonKey(name: 'total_expense') this.totalExpense = 0,
    @JsonKey(name: 'total_income') this.totalIncome = 0,
    @JsonKey(name: 'avg_cost') this.avgCost = 0,
  });

  factory _$ShippingPosProfileCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingPosProfileCostImplFromJson(json);

  @override
  @JsonKey()
  final String branch;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @override
  @JsonKey(name: 'total_income')
  final double totalIncome;
  @override
  @JsonKey(name: 'avg_cost')
  final double avgCost;

  @override
  String toString() {
    return 'ShippingPosProfileCost(branch: $branch, totalExpense: $totalExpense, totalIncome: $totalIncome, avgCost: $avgCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingPosProfileCostImpl &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.avgCost, avgCost) || other.avgCost == avgCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, branch, totalExpense, totalIncome, avgCost);

  /// Create a copy of ShippingPosProfileCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingPosProfileCostImplCopyWith<_$ShippingPosProfileCostImpl>
  get copyWith =>
      __$$ShippingPosProfileCostImplCopyWithImpl<_$ShippingPosProfileCostImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingPosProfileCostImplToJson(this);
  }
}

abstract class _ShippingPosProfileCost implements ShippingPosProfileCost {
  const factory _ShippingPosProfileCost({
    final String branch,
    @JsonKey(name: 'total_expense') final double totalExpense,
    @JsonKey(name: 'total_income') final double totalIncome,
    @JsonKey(name: 'avg_cost') final double avgCost,
  }) = _$ShippingPosProfileCostImpl;

  factory _ShippingPosProfileCost.fromJson(Map<String, dynamic> json) =
      _$ShippingPosProfileCostImpl.fromJson;

  @override
  String get branch;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;
  @override
  @JsonKey(name: 'total_income')
  double get totalIncome;
  @override
  @JsonKey(name: 'avg_cost')
  double get avgCost;

  /// Create a copy of ShippingPosProfileCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingPosProfileCostImplCopyWith<_$ShippingPosProfileCostImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingCourierCost _$ShippingCourierCostFromJson(Map<String, dynamic> json) {
  return _ShippingCourierCost.fromJson(json);
}

/// @nodoc
mixin _$ShippingCourierCost {
  String get party => throw _privateConstructorUsedError;
  double get settled => throw _privateConstructorUsedError;
  double get unsettled => throw _privateConstructorUsedError;

  /// Serializes this ShippingCourierCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingCourierCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingCourierCostCopyWith<ShippingCourierCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingCourierCostCopyWith<$Res> {
  factory $ShippingCourierCostCopyWith(
    ShippingCourierCost value,
    $Res Function(ShippingCourierCost) then,
  ) = _$ShippingCourierCostCopyWithImpl<$Res, ShippingCourierCost>;
  @useResult
  $Res call({String party, double settled, double unsettled});
}

/// @nodoc
class _$ShippingCourierCostCopyWithImpl<$Res, $Val extends ShippingCourierCost>
    implements $ShippingCourierCostCopyWith<$Res> {
  _$ShippingCourierCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingCourierCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? party = null,
    Object? settled = null,
    Object? unsettled = null,
  }) {
    return _then(
      _value.copyWith(
            party: null == party
                ? _value.party
                : party // ignore: cast_nullable_to_non_nullable
                      as String,
            settled: null == settled
                ? _value.settled
                : settled // ignore: cast_nullable_to_non_nullable
                      as double,
            unsettled: null == unsettled
                ? _value.unsettled
                : unsettled // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingCourierCostImplCopyWith<$Res>
    implements $ShippingCourierCostCopyWith<$Res> {
  factory _$$ShippingCourierCostImplCopyWith(
    _$ShippingCourierCostImpl value,
    $Res Function(_$ShippingCourierCostImpl) then,
  ) = __$$ShippingCourierCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String party, double settled, double unsettled});
}

/// @nodoc
class __$$ShippingCourierCostImplCopyWithImpl<$Res>
    extends _$ShippingCourierCostCopyWithImpl<$Res, _$ShippingCourierCostImpl>
    implements _$$ShippingCourierCostImplCopyWith<$Res> {
  __$$ShippingCourierCostImplCopyWithImpl(
    _$ShippingCourierCostImpl _value,
    $Res Function(_$ShippingCourierCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingCourierCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? party = null,
    Object? settled = null,
    Object? unsettled = null,
  }) {
    return _then(
      _$ShippingCourierCostImpl(
        party: null == party
            ? _value.party
            : party // ignore: cast_nullable_to_non_nullable
                  as String,
        settled: null == settled
            ? _value.settled
            : settled // ignore: cast_nullable_to_non_nullable
                  as double,
        unsettled: null == unsettled
            ? _value.unsettled
            : unsettled // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingCourierCostImpl implements _ShippingCourierCost {
  const _$ShippingCourierCostImpl({
    this.party = '',
    this.settled = 0,
    this.unsettled = 0,
  });

  factory _$ShippingCourierCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingCourierCostImplFromJson(json);

  @override
  @JsonKey()
  final String party;
  @override
  @JsonKey()
  final double settled;
  @override
  @JsonKey()
  final double unsettled;

  @override
  String toString() {
    return 'ShippingCourierCost(party: $party, settled: $settled, unsettled: $unsettled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingCourierCostImpl &&
            (identical(other.party, party) || other.party == party) &&
            (identical(other.settled, settled) || other.settled == settled) &&
            (identical(other.unsettled, unsettled) ||
                other.unsettled == unsettled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, party, settled, unsettled);

  /// Create a copy of ShippingCourierCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingCourierCostImplCopyWith<_$ShippingCourierCostImpl> get copyWith =>
      __$$ShippingCourierCostImplCopyWithImpl<_$ShippingCourierCostImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingCourierCostImplToJson(this);
  }
}

abstract class _ShippingCourierCost implements ShippingCourierCost {
  const factory _ShippingCourierCost({
    final String party,
    final double settled,
    final double unsettled,
  }) = _$ShippingCourierCostImpl;

  factory _ShippingCourierCost.fromJson(Map<String, dynamic> json) =
      _$ShippingCourierCostImpl.fromJson;

  @override
  String get party;
  @override
  double get settled;
  @override
  double get unsettled;

  /// Create a copy of ShippingCourierCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingCourierCostImplCopyWith<_$ShippingCourierCostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShippingCustomBreakdown _$ShippingCustomBreakdownFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingCustomBreakdown.fromJson(json);
}

/// @nodoc
mixin _$ShippingCustomBreakdown {
  ShippingCustomBreakdownSummary get summary =>
      throw _privateConstructorUsedError;
  List<ShippingCustomBreakdownRow> get rows =>
      throw _privateConstructorUsedError;

  /// Serializes this ShippingCustomBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingCustomBreakdownCopyWith<ShippingCustomBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingCustomBreakdownCopyWith<$Res> {
  factory $ShippingCustomBreakdownCopyWith(
    ShippingCustomBreakdown value,
    $Res Function(ShippingCustomBreakdown) then,
  ) = _$ShippingCustomBreakdownCopyWithImpl<$Res, ShippingCustomBreakdown>;
  @useResult
  $Res call({
    ShippingCustomBreakdownSummary summary,
    List<ShippingCustomBreakdownRow> rows,
  });

  $ShippingCustomBreakdownSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ShippingCustomBreakdownCopyWithImpl<
  $Res,
  $Val extends ShippingCustomBreakdown
>
    implements $ShippingCustomBreakdownCopyWith<$Res> {
  _$ShippingCustomBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? rows = null}) {
    return _then(
      _value.copyWith(
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as ShippingCustomBreakdownSummary,
            rows: null == rows
                ? _value.rows
                : rows // ignore: cast_nullable_to_non_nullable
                      as List<ShippingCustomBreakdownRow>,
          )
          as $Val,
    );
  }

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingCustomBreakdownSummaryCopyWith<$Res> get summary {
    return $ShippingCustomBreakdownSummaryCopyWith<$Res>(_value.summary, (
      value,
    ) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShippingCustomBreakdownImplCopyWith<$Res>
    implements $ShippingCustomBreakdownCopyWith<$Res> {
  factory _$$ShippingCustomBreakdownImplCopyWith(
    _$ShippingCustomBreakdownImpl value,
    $Res Function(_$ShippingCustomBreakdownImpl) then,
  ) = __$$ShippingCustomBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ShippingCustomBreakdownSummary summary,
    List<ShippingCustomBreakdownRow> rows,
  });

  @override
  $ShippingCustomBreakdownSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ShippingCustomBreakdownImplCopyWithImpl<$Res>
    extends
        _$ShippingCustomBreakdownCopyWithImpl<
          $Res,
          _$ShippingCustomBreakdownImpl
        >
    implements _$$ShippingCustomBreakdownImplCopyWith<$Res> {
  __$$ShippingCustomBreakdownImplCopyWithImpl(
    _$ShippingCustomBreakdownImpl _value,
    $Res Function(_$ShippingCustomBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? rows = null}) {
    return _then(
      _$ShippingCustomBreakdownImpl(
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as ShippingCustomBreakdownSummary,
        rows: null == rows
            ? _value._rows
            : rows // ignore: cast_nullable_to_non_nullable
                  as List<ShippingCustomBreakdownRow>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingCustomBreakdownImpl implements _ShippingCustomBreakdown {
  const _$ShippingCustomBreakdownImpl({
    this.summary = const ShippingCustomBreakdownSummary(),
    final List<ShippingCustomBreakdownRow> rows =
        const <ShippingCustomBreakdownRow>[],
  }) : _rows = rows;

  factory _$ShippingCustomBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingCustomBreakdownImplFromJson(json);

  @override
  @JsonKey()
  final ShippingCustomBreakdownSummary summary;
  final List<ShippingCustomBreakdownRow> _rows;
  @override
  @JsonKey()
  List<ShippingCustomBreakdownRow> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  String toString() {
    return 'ShippingCustomBreakdown(summary: $summary, rows: $rows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingCustomBreakdownImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._rows, _rows));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    summary,
    const DeepCollectionEquality().hash(_rows),
  );

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingCustomBreakdownImplCopyWith<_$ShippingCustomBreakdownImpl>
  get copyWith =>
      __$$ShippingCustomBreakdownImplCopyWithImpl<
        _$ShippingCustomBreakdownImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingCustomBreakdownImplToJson(this);
  }
}

abstract class _ShippingCustomBreakdown implements ShippingCustomBreakdown {
  const factory _ShippingCustomBreakdown({
    final ShippingCustomBreakdownSummary summary,
    final List<ShippingCustomBreakdownRow> rows,
  }) = _$ShippingCustomBreakdownImpl;

  factory _ShippingCustomBreakdown.fromJson(Map<String, dynamic> json) =
      _$ShippingCustomBreakdownImpl.fromJson;

  @override
  ShippingCustomBreakdownSummary get summary;
  @override
  List<ShippingCustomBreakdownRow> get rows;

  /// Create a copy of ShippingCustomBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingCustomBreakdownImplCopyWith<_$ShippingCustomBreakdownImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingCustomBreakdownSummary _$ShippingCustomBreakdownSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingCustomBreakdownSummary.fromJson(json);
}

/// @nodoc
mixin _$ShippingCustomBreakdownSummary {
  int get total => throw _privateConstructorUsedError;
  int get approved => throw _privateConstructorUsedError;
  int get rejected => throw _privateConstructorUsedError;
  int get pending => throw _privateConstructorUsedError;
  @JsonKey(name: 'approval_rate')
  double get approvalRate => throw _privateConstructorUsedError;

  /// Serializes this ShippingCustomBreakdownSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingCustomBreakdownSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingCustomBreakdownSummaryCopyWith<ShippingCustomBreakdownSummary>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingCustomBreakdownSummaryCopyWith<$Res> {
  factory $ShippingCustomBreakdownSummaryCopyWith(
    ShippingCustomBreakdownSummary value,
    $Res Function(ShippingCustomBreakdownSummary) then,
  ) =
      _$ShippingCustomBreakdownSummaryCopyWithImpl<
        $Res,
        ShippingCustomBreakdownSummary
      >;
  @useResult
  $Res call({
    int total,
    int approved,
    int rejected,
    int pending,
    @JsonKey(name: 'approval_rate') double approvalRate,
  });
}

/// @nodoc
class _$ShippingCustomBreakdownSummaryCopyWithImpl<
  $Res,
  $Val extends ShippingCustomBreakdownSummary
>
    implements $ShippingCustomBreakdownSummaryCopyWith<$Res> {
  _$ShippingCustomBreakdownSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingCustomBreakdownSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? approved = null,
    Object? rejected = null,
    Object? pending = null,
    Object? approvalRate = null,
  }) {
    return _then(
      _value.copyWith(
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            approved: null == approved
                ? _value.approved
                : approved // ignore: cast_nullable_to_non_nullable
                      as int,
            rejected: null == rejected
                ? _value.rejected
                : rejected // ignore: cast_nullable_to_non_nullable
                      as int,
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int,
            approvalRate: null == approvalRate
                ? _value.approvalRate
                : approvalRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingCustomBreakdownSummaryImplCopyWith<$Res>
    implements $ShippingCustomBreakdownSummaryCopyWith<$Res> {
  factory _$$ShippingCustomBreakdownSummaryImplCopyWith(
    _$ShippingCustomBreakdownSummaryImpl value,
    $Res Function(_$ShippingCustomBreakdownSummaryImpl) then,
  ) = __$$ShippingCustomBreakdownSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int total,
    int approved,
    int rejected,
    int pending,
    @JsonKey(name: 'approval_rate') double approvalRate,
  });
}

/// @nodoc
class __$$ShippingCustomBreakdownSummaryImplCopyWithImpl<$Res>
    extends
        _$ShippingCustomBreakdownSummaryCopyWithImpl<
          $Res,
          _$ShippingCustomBreakdownSummaryImpl
        >
    implements _$$ShippingCustomBreakdownSummaryImplCopyWith<$Res> {
  __$$ShippingCustomBreakdownSummaryImplCopyWithImpl(
    _$ShippingCustomBreakdownSummaryImpl _value,
    $Res Function(_$ShippingCustomBreakdownSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingCustomBreakdownSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? approved = null,
    Object? rejected = null,
    Object? pending = null,
    Object? approvalRate = null,
  }) {
    return _then(
      _$ShippingCustomBreakdownSummaryImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        approved: null == approved
            ? _value.approved
            : approved // ignore: cast_nullable_to_non_nullable
                  as int,
        rejected: null == rejected
            ? _value.rejected
            : rejected // ignore: cast_nullable_to_non_nullable
                  as int,
        pending: null == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int,
        approvalRate: null == approvalRate
            ? _value.approvalRate
            : approvalRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingCustomBreakdownSummaryImpl
    implements _ShippingCustomBreakdownSummary {
  const _$ShippingCustomBreakdownSummaryImpl({
    this.total = 0,
    this.approved = 0,
    this.rejected = 0,
    this.pending = 0,
    @JsonKey(name: 'approval_rate') this.approvalRate = 0,
  });

  factory _$ShippingCustomBreakdownSummaryImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ShippingCustomBreakdownSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int approved;
  @override
  @JsonKey()
  final int rejected;
  @override
  @JsonKey()
  final int pending;
  @override
  @JsonKey(name: 'approval_rate')
  final double approvalRate;

  @override
  String toString() {
    return 'ShippingCustomBreakdownSummary(total: $total, approved: $approved, rejected: $rejected, pending: $pending, approvalRate: $approvalRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingCustomBreakdownSummaryImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.approved, approved) ||
                other.approved == approved) &&
            (identical(other.rejected, rejected) ||
                other.rejected == rejected) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.approvalRate, approvalRate) ||
                other.approvalRate == approvalRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    total,
    approved,
    rejected,
    pending,
    approvalRate,
  );

  /// Create a copy of ShippingCustomBreakdownSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingCustomBreakdownSummaryImplCopyWith<
    _$ShippingCustomBreakdownSummaryImpl
  >
  get copyWith =>
      __$$ShippingCustomBreakdownSummaryImplCopyWithImpl<
        _$ShippingCustomBreakdownSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingCustomBreakdownSummaryImplToJson(this);
  }
}

abstract class _ShippingCustomBreakdownSummary
    implements ShippingCustomBreakdownSummary {
  const factory _ShippingCustomBreakdownSummary({
    final int total,
    final int approved,
    final int rejected,
    final int pending,
    @JsonKey(name: 'approval_rate') final double approvalRate,
  }) = _$ShippingCustomBreakdownSummaryImpl;

  factory _ShippingCustomBreakdownSummary.fromJson(Map<String, dynamic> json) =
      _$ShippingCustomBreakdownSummaryImpl.fromJson;

  @override
  int get total;
  @override
  int get approved;
  @override
  int get rejected;
  @override
  int get pending;
  @override
  @JsonKey(name: 'approval_rate')
  double get approvalRate;

  /// Create a copy of ShippingCustomBreakdownSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingCustomBreakdownSummaryImplCopyWith<
    _$ShippingCustomBreakdownSummaryImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ShippingCustomBreakdownRow _$ShippingCustomBreakdownRowFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingCustomBreakdownRow.fromJson(json);
}

/// @nodoc
mixin _$ShippingCustomBreakdownRow {
  String get invoice => throw _privateConstructorUsedError;
  String get territory => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_amount')
  double get originalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_amount')
  double get requestedAmount => throw _privateConstructorUsedError;
  double get delta => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_large_override')
  bool get isLargeOverride => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ShippingCustomBreakdownRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingCustomBreakdownRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingCustomBreakdownRowCopyWith<ShippingCustomBreakdownRow>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingCustomBreakdownRowCopyWith<$Res> {
  factory $ShippingCustomBreakdownRowCopyWith(
    ShippingCustomBreakdownRow value,
    $Res Function(ShippingCustomBreakdownRow) then,
  ) =
      _$ShippingCustomBreakdownRowCopyWithImpl<
        $Res,
        ShippingCustomBreakdownRow
      >;
  @useResult
  $Res call({
    String invoice,
    String territory,
    @JsonKey(name: 'original_amount') double originalAmount,
    @JsonKey(name: 'requested_amount') double requestedAmount,
    double delta,
    @JsonKey(name: 'is_large_override') bool isLargeOverride,
    String status,
  });
}

/// @nodoc
class _$ShippingCustomBreakdownRowCopyWithImpl<
  $Res,
  $Val extends ShippingCustomBreakdownRow
>
    implements $ShippingCustomBreakdownRowCopyWith<$Res> {
  _$ShippingCustomBreakdownRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingCustomBreakdownRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? territory = null,
    Object? originalAmount = null,
    Object? requestedAmount = null,
    Object? delta = null,
    Object? isLargeOverride = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            invoice: null == invoice
                ? _value.invoice
                : invoice // ignore: cast_nullable_to_non_nullable
                      as String,
            territory: null == territory
                ? _value.territory
                : territory // ignore: cast_nullable_to_non_nullable
                      as String,
            originalAmount: null == originalAmount
                ? _value.originalAmount
                : originalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            requestedAmount: null == requestedAmount
                ? _value.requestedAmount
                : requestedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            delta: null == delta
                ? _value.delta
                : delta // ignore: cast_nullable_to_non_nullable
                      as double,
            isLargeOverride: null == isLargeOverride
                ? _value.isLargeOverride
                : isLargeOverride // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingCustomBreakdownRowImplCopyWith<$Res>
    implements $ShippingCustomBreakdownRowCopyWith<$Res> {
  factory _$$ShippingCustomBreakdownRowImplCopyWith(
    _$ShippingCustomBreakdownRowImpl value,
    $Res Function(_$ShippingCustomBreakdownRowImpl) then,
  ) = __$$ShippingCustomBreakdownRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String invoice,
    String territory,
    @JsonKey(name: 'original_amount') double originalAmount,
    @JsonKey(name: 'requested_amount') double requestedAmount,
    double delta,
    @JsonKey(name: 'is_large_override') bool isLargeOverride,
    String status,
  });
}

/// @nodoc
class __$$ShippingCustomBreakdownRowImplCopyWithImpl<$Res>
    extends
        _$ShippingCustomBreakdownRowCopyWithImpl<
          $Res,
          _$ShippingCustomBreakdownRowImpl
        >
    implements _$$ShippingCustomBreakdownRowImplCopyWith<$Res> {
  __$$ShippingCustomBreakdownRowImplCopyWithImpl(
    _$ShippingCustomBreakdownRowImpl _value,
    $Res Function(_$ShippingCustomBreakdownRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingCustomBreakdownRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? territory = null,
    Object? originalAmount = null,
    Object? requestedAmount = null,
    Object? delta = null,
    Object? isLargeOverride = null,
    Object? status = null,
  }) {
    return _then(
      _$ShippingCustomBreakdownRowImpl(
        invoice: null == invoice
            ? _value.invoice
            : invoice // ignore: cast_nullable_to_non_nullable
                  as String,
        territory: null == territory
            ? _value.territory
            : territory // ignore: cast_nullable_to_non_nullable
                  as String,
        originalAmount: null == originalAmount
            ? _value.originalAmount
            : originalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        requestedAmount: null == requestedAmount
            ? _value.requestedAmount
            : requestedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        delta: null == delta
            ? _value.delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as double,
        isLargeOverride: null == isLargeOverride
            ? _value.isLargeOverride
            : isLargeOverride // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingCustomBreakdownRowImpl implements _ShippingCustomBreakdownRow {
  const _$ShippingCustomBreakdownRowImpl({
    this.invoice = '',
    this.territory = '',
    @JsonKey(name: 'original_amount') this.originalAmount = 0,
    @JsonKey(name: 'requested_amount') this.requestedAmount = 0,
    this.delta = 0,
    @JsonKey(name: 'is_large_override') this.isLargeOverride = false,
    this.status = '',
  });

  factory _$ShippingCustomBreakdownRowImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ShippingCustomBreakdownRowImplFromJson(json);

  @override
  @JsonKey()
  final String invoice;
  @override
  @JsonKey()
  final String territory;
  @override
  @JsonKey(name: 'original_amount')
  final double originalAmount;
  @override
  @JsonKey(name: 'requested_amount')
  final double requestedAmount;
  @override
  @JsonKey()
  final double delta;
  @override
  @JsonKey(name: 'is_large_override')
  final bool isLargeOverride;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'ShippingCustomBreakdownRow(invoice: $invoice, territory: $territory, originalAmount: $originalAmount, requestedAmount: $requestedAmount, delta: $delta, isLargeOverride: $isLargeOverride, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingCustomBreakdownRowImpl &&
            (identical(other.invoice, invoice) || other.invoice == invoice) &&
            (identical(other.territory, territory) ||
                other.territory == territory) &&
            (identical(other.originalAmount, originalAmount) ||
                other.originalAmount == originalAmount) &&
            (identical(other.requestedAmount, requestedAmount) ||
                other.requestedAmount == requestedAmount) &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.isLargeOverride, isLargeOverride) ||
                other.isLargeOverride == isLargeOverride) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    invoice,
    territory,
    originalAmount,
    requestedAmount,
    delta,
    isLargeOverride,
    status,
  );

  /// Create a copy of ShippingCustomBreakdownRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingCustomBreakdownRowImplCopyWith<_$ShippingCustomBreakdownRowImpl>
  get copyWith =>
      __$$ShippingCustomBreakdownRowImplCopyWithImpl<
        _$ShippingCustomBreakdownRowImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingCustomBreakdownRowImplToJson(this);
  }
}

abstract class _ShippingCustomBreakdownRow
    implements ShippingCustomBreakdownRow {
  const factory _ShippingCustomBreakdownRow({
    final String invoice,
    final String territory,
    @JsonKey(name: 'original_amount') final double originalAmount,
    @JsonKey(name: 'requested_amount') final double requestedAmount,
    final double delta,
    @JsonKey(name: 'is_large_override') final bool isLargeOverride,
    final String status,
  }) = _$ShippingCustomBreakdownRowImpl;

  factory _ShippingCustomBreakdownRow.fromJson(Map<String, dynamic> json) =
      _$ShippingCustomBreakdownRowImpl.fromJson;

  @override
  String get invoice;
  @override
  String get territory;
  @override
  @JsonKey(name: 'original_amount')
  double get originalAmount;
  @override
  @JsonKey(name: 'requested_amount')
  double get requestedAmount;
  @override
  double get delta;
  @override
  @JsonKey(name: 'is_large_override')
  bool get isLargeOverride;
  @override
  String get status;

  /// Create a copy of ShippingCustomBreakdownRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingCustomBreakdownRowImplCopyWith<_$ShippingCustomBreakdownRowImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingDoubleImpact _$ShippingDoubleImpactFromJson(Map<String, dynamic> json) {
  return _ShippingDoubleImpact.fromJson(json);
}

/// @nodoc
mixin _$ShippingDoubleImpact {
  @JsonKey(name: 'total_double_trips')
  int get totalDoubleTrips => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_extra_cost')
  double get totalExtraCost => throw _privateConstructorUsedError;
  List<JsonMap> get trips => throw _privateConstructorUsedError;

  /// Serializes this ShippingDoubleImpact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingDoubleImpact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingDoubleImpactCopyWith<ShippingDoubleImpact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingDoubleImpactCopyWith<$Res> {
  factory $ShippingDoubleImpactCopyWith(
    ShippingDoubleImpact value,
    $Res Function(ShippingDoubleImpact) then,
  ) = _$ShippingDoubleImpactCopyWithImpl<$Res, ShippingDoubleImpact>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_double_trips') int totalDoubleTrips,
    @JsonKey(name: 'total_extra_cost') double totalExtraCost,
    List<JsonMap> trips,
  });
}

/// @nodoc
class _$ShippingDoubleImpactCopyWithImpl<
  $Res,
  $Val extends ShippingDoubleImpact
>
    implements $ShippingDoubleImpactCopyWith<$Res> {
  _$ShippingDoubleImpactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingDoubleImpact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDoubleTrips = null,
    Object? totalExtraCost = null,
    Object? trips = null,
  }) {
    return _then(
      _value.copyWith(
            totalDoubleTrips: null == totalDoubleTrips
                ? _value.totalDoubleTrips
                : totalDoubleTrips // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExtraCost: null == totalExtraCost
                ? _value.totalExtraCost
                : totalExtraCost // ignore: cast_nullable_to_non_nullable
                      as double,
            trips: null == trips
                ? _value.trips
                : trips // ignore: cast_nullable_to_non_nullable
                      as List<JsonMap>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingDoubleImpactImplCopyWith<$Res>
    implements $ShippingDoubleImpactCopyWith<$Res> {
  factory _$$ShippingDoubleImpactImplCopyWith(
    _$ShippingDoubleImpactImpl value,
    $Res Function(_$ShippingDoubleImpactImpl) then,
  ) = __$$ShippingDoubleImpactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_double_trips') int totalDoubleTrips,
    @JsonKey(name: 'total_extra_cost') double totalExtraCost,
    List<JsonMap> trips,
  });
}

/// @nodoc
class __$$ShippingDoubleImpactImplCopyWithImpl<$Res>
    extends _$ShippingDoubleImpactCopyWithImpl<$Res, _$ShippingDoubleImpactImpl>
    implements _$$ShippingDoubleImpactImplCopyWith<$Res> {
  __$$ShippingDoubleImpactImplCopyWithImpl(
    _$ShippingDoubleImpactImpl _value,
    $Res Function(_$ShippingDoubleImpactImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingDoubleImpact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDoubleTrips = null,
    Object? totalExtraCost = null,
    Object? trips = null,
  }) {
    return _then(
      _$ShippingDoubleImpactImpl(
        totalDoubleTrips: null == totalDoubleTrips
            ? _value.totalDoubleTrips
            : totalDoubleTrips // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExtraCost: null == totalExtraCost
            ? _value.totalExtraCost
            : totalExtraCost // ignore: cast_nullable_to_non_nullable
                  as double,
        trips: null == trips
            ? _value._trips
            : trips // ignore: cast_nullable_to_non_nullable
                  as List<JsonMap>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingDoubleImpactImpl implements _ShippingDoubleImpact {
  const _$ShippingDoubleImpactImpl({
    @JsonKey(name: 'total_double_trips') this.totalDoubleTrips = 0,
    @JsonKey(name: 'total_extra_cost') this.totalExtraCost = 0,
    final List<JsonMap> trips = const <JsonMap>[],
  }) : _trips = trips;

  factory _$ShippingDoubleImpactImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingDoubleImpactImplFromJson(json);

  @override
  @JsonKey(name: 'total_double_trips')
  final int totalDoubleTrips;
  @override
  @JsonKey(name: 'total_extra_cost')
  final double totalExtraCost;
  final List<JsonMap> _trips;
  @override
  @JsonKey()
  List<JsonMap> get trips {
    if (_trips is EqualUnmodifiableListView) return _trips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trips);
  }

  @override
  String toString() {
    return 'ShippingDoubleImpact(totalDoubleTrips: $totalDoubleTrips, totalExtraCost: $totalExtraCost, trips: $trips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingDoubleImpactImpl &&
            (identical(other.totalDoubleTrips, totalDoubleTrips) ||
                other.totalDoubleTrips == totalDoubleTrips) &&
            (identical(other.totalExtraCost, totalExtraCost) ||
                other.totalExtraCost == totalExtraCost) &&
            const DeepCollectionEquality().equals(other._trips, _trips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalDoubleTrips,
    totalExtraCost,
    const DeepCollectionEquality().hash(_trips),
  );

  /// Create a copy of ShippingDoubleImpact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingDoubleImpactImplCopyWith<_$ShippingDoubleImpactImpl>
  get copyWith =>
      __$$ShippingDoubleImpactImplCopyWithImpl<_$ShippingDoubleImpactImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingDoubleImpactImplToJson(this);
  }
}

abstract class _ShippingDoubleImpact implements ShippingDoubleImpact {
  const factory _ShippingDoubleImpact({
    @JsonKey(name: 'total_double_trips') final int totalDoubleTrips,
    @JsonKey(name: 'total_extra_cost') final double totalExtraCost,
    final List<JsonMap> trips,
  }) = _$ShippingDoubleImpactImpl;

  factory _ShippingDoubleImpact.fromJson(Map<String, dynamic> json) =
      _$ShippingDoubleImpactImpl.fromJson;

  @override
  @JsonKey(name: 'total_double_trips')
  int get totalDoubleTrips;
  @override
  @JsonKey(name: 'total_extra_cost')
  double get totalExtraCost;
  @override
  List<JsonMap> get trips;

  /// Create a copy of ShippingDoubleImpact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingDoubleImpactImplCopyWith<_$ShippingDoubleImpactImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingDailyTrendPoint _$ShippingDailyTrendPointFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingDailyTrendPoint.fromJson(json);
}

/// @nodoc
mixin _$ShippingDailyTrendPoint {
  @JsonKey(name: 'posting_date')
  String get postingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_count')
  int get orderCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_income')
  double get totalIncome => throw _privateConstructorUsedError;

  /// Serializes this ShippingDailyTrendPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingDailyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingDailyTrendPointCopyWith<ShippingDailyTrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingDailyTrendPointCopyWith<$Res> {
  factory $ShippingDailyTrendPointCopyWith(
    ShippingDailyTrendPoint value,
    $Res Function(ShippingDailyTrendPoint) then,
  ) = _$ShippingDailyTrendPointCopyWithImpl<$Res, ShippingDailyTrendPoint>;
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
  });
}

/// @nodoc
class _$ShippingDailyTrendPointCopyWithImpl<
  $Res,
  $Val extends ShippingDailyTrendPoint
>
    implements $ShippingDailyTrendPointCopyWith<$Res> {
  _$ShippingDailyTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingDailyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? orderCount = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
  }) {
    return _then(
      _value.copyWith(
            postingDate: null == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String,
            orderCount: null == orderCount
                ? _value.orderCount
                : orderCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingDailyTrendPointImplCopyWith<$Res>
    implements $ShippingDailyTrendPointCopyWith<$Res> {
  factory _$$ShippingDailyTrendPointImplCopyWith(
    _$ShippingDailyTrendPointImpl value,
    $Res Function(_$ShippingDailyTrendPointImpl) then,
  ) = __$$ShippingDailyTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_expense') double totalExpense,
    @JsonKey(name: 'total_income') double totalIncome,
  });
}

/// @nodoc
class __$$ShippingDailyTrendPointImplCopyWithImpl<$Res>
    extends
        _$ShippingDailyTrendPointCopyWithImpl<
          $Res,
          _$ShippingDailyTrendPointImpl
        >
    implements _$$ShippingDailyTrendPointImplCopyWith<$Res> {
  __$$ShippingDailyTrendPointImplCopyWithImpl(
    _$ShippingDailyTrendPointImpl _value,
    $Res Function(_$ShippingDailyTrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingDailyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? orderCount = null,
    Object? totalExpense = null,
    Object? totalIncome = null,
  }) {
    return _then(
      _$ShippingDailyTrendPointImpl(
        postingDate: null == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCount: null == orderCount
            ? _value.orderCount
            : orderCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingDailyTrendPointImpl implements _ShippingDailyTrendPoint {
  const _$ShippingDailyTrendPointImpl({
    @JsonKey(name: 'posting_date') this.postingDate = '',
    @JsonKey(name: 'order_count') this.orderCount = 0,
    @JsonKey(name: 'total_expense') this.totalExpense = 0,
    @JsonKey(name: 'total_income') this.totalIncome = 0,
  });

  factory _$ShippingDailyTrendPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingDailyTrendPointImplFromJson(json);

  @override
  @JsonKey(name: 'posting_date')
  final String postingDate;
  @override
  @JsonKey(name: 'order_count')
  final int orderCount;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @override
  @JsonKey(name: 'total_income')
  final double totalIncome;

  @override
  String toString() {
    return 'ShippingDailyTrendPoint(postingDate: $postingDate, orderCount: $orderCount, totalExpense: $totalExpense, totalIncome: $totalIncome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingDailyTrendPointImpl &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.orderCount, orderCount) ||
                other.orderCount == orderCount) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    postingDate,
    orderCount,
    totalExpense,
    totalIncome,
  );

  /// Create a copy of ShippingDailyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingDailyTrendPointImplCopyWith<_$ShippingDailyTrendPointImpl>
  get copyWith =>
      __$$ShippingDailyTrendPointImplCopyWithImpl<
        _$ShippingDailyTrendPointImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingDailyTrendPointImplToJson(this);
  }
}

abstract class _ShippingDailyTrendPoint implements ShippingDailyTrendPoint {
  const factory _ShippingDailyTrendPoint({
    @JsonKey(name: 'posting_date') final String postingDate,
    @JsonKey(name: 'order_count') final int orderCount,
    @JsonKey(name: 'total_expense') final double totalExpense,
    @JsonKey(name: 'total_income') final double totalIncome,
  }) = _$ShippingDailyTrendPointImpl;

  factory _ShippingDailyTrendPoint.fromJson(Map<String, dynamic> json) =
      _$ShippingDailyTrendPointImpl.fromJson;

  @override
  @JsonKey(name: 'posting_date')
  String get postingDate;
  @override
  @JsonKey(name: 'order_count')
  int get orderCount;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;
  @override
  @JsonKey(name: 'total_income')
  double get totalIncome;

  /// Create a copy of ShippingDailyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingDailyTrendPointImplCopyWith<_$ShippingDailyTrendPointImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingPickupDeliverySplit _$ShippingPickupDeliverySplitFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingPickupDeliverySplit.fromJson(json);
}

/// @nodoc
mixin _$ShippingPickupDeliverySplit {
  int get pickup => throw _privateConstructorUsedError;
  int get delivery => throw _privateConstructorUsedError;

  /// Serializes this ShippingPickupDeliverySplit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingPickupDeliverySplit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingPickupDeliverySplitCopyWith<ShippingPickupDeliverySplit>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingPickupDeliverySplitCopyWith<$Res> {
  factory $ShippingPickupDeliverySplitCopyWith(
    ShippingPickupDeliverySplit value,
    $Res Function(ShippingPickupDeliverySplit) then,
  ) =
      _$ShippingPickupDeliverySplitCopyWithImpl<
        $Res,
        ShippingPickupDeliverySplit
      >;
  @useResult
  $Res call({int pickup, int delivery});
}

/// @nodoc
class _$ShippingPickupDeliverySplitCopyWithImpl<
  $Res,
  $Val extends ShippingPickupDeliverySplit
>
    implements $ShippingPickupDeliverySplitCopyWith<$Res> {
  _$ShippingPickupDeliverySplitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingPickupDeliverySplit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pickup = null, Object? delivery = null}) {
    return _then(
      _value.copyWith(
            pickup: null == pickup
                ? _value.pickup
                : pickup // ignore: cast_nullable_to_non_nullable
                      as int,
            delivery: null == delivery
                ? _value.delivery
                : delivery // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingPickupDeliverySplitImplCopyWith<$Res>
    implements $ShippingPickupDeliverySplitCopyWith<$Res> {
  factory _$$ShippingPickupDeliverySplitImplCopyWith(
    _$ShippingPickupDeliverySplitImpl value,
    $Res Function(_$ShippingPickupDeliverySplitImpl) then,
  ) = __$$ShippingPickupDeliverySplitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pickup, int delivery});
}

/// @nodoc
class __$$ShippingPickupDeliverySplitImplCopyWithImpl<$Res>
    extends
        _$ShippingPickupDeliverySplitCopyWithImpl<
          $Res,
          _$ShippingPickupDeliverySplitImpl
        >
    implements _$$ShippingPickupDeliverySplitImplCopyWith<$Res> {
  __$$ShippingPickupDeliverySplitImplCopyWithImpl(
    _$ShippingPickupDeliverySplitImpl _value,
    $Res Function(_$ShippingPickupDeliverySplitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingPickupDeliverySplit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pickup = null, Object? delivery = null}) {
    return _then(
      _$ShippingPickupDeliverySplitImpl(
        pickup: null == pickup
            ? _value.pickup
            : pickup // ignore: cast_nullable_to_non_nullable
                  as int,
        delivery: null == delivery
            ? _value.delivery
            : delivery // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingPickupDeliverySplitImpl
    implements _ShippingPickupDeliverySplit {
  const _$ShippingPickupDeliverySplitImpl({this.pickup = 0, this.delivery = 0});

  factory _$ShippingPickupDeliverySplitImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ShippingPickupDeliverySplitImplFromJson(json);

  @override
  @JsonKey()
  final int pickup;
  @override
  @JsonKey()
  final int delivery;

  @override
  String toString() {
    return 'ShippingPickupDeliverySplit(pickup: $pickup, delivery: $delivery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingPickupDeliverySplitImpl &&
            (identical(other.pickup, pickup) || other.pickup == pickup) &&
            (identical(other.delivery, delivery) ||
                other.delivery == delivery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pickup, delivery);

  /// Create a copy of ShippingPickupDeliverySplit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingPickupDeliverySplitImplCopyWith<_$ShippingPickupDeliverySplitImpl>
  get copyWith =>
      __$$ShippingPickupDeliverySplitImplCopyWithImpl<
        _$ShippingPickupDeliverySplitImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingPickupDeliverySplitImplToJson(this);
  }
}

abstract class _ShippingPickupDeliverySplit
    implements ShippingPickupDeliverySplit {
  const factory _ShippingPickupDeliverySplit({
    final int pickup,
    final int delivery,
  }) = _$ShippingPickupDeliverySplitImpl;

  factory _ShippingPickupDeliverySplit.fromJson(Map<String, dynamic> json) =
      _$ShippingPickupDeliverySplitImpl.fromJson;

  @override
  int get pickup;
  @override
  int get delivery;

  /// Create a copy of ShippingPickupDeliverySplit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingPickupDeliverySplitImplCopyWith<_$ShippingPickupDeliverySplitImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ShippingUnsettledCourierBalance _$ShippingUnsettledCourierBalanceFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingUnsettledCourierBalance.fromJson(json);
}

/// @nodoc
mixin _$ShippingUnsettledCourierBalance {
  String get party => throw _privateConstructorUsedError;
  @JsonKey(name: 'party_type')
  String get partyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_count')
  int get orderCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_owed')
  double get totalOwed => throw _privateConstructorUsedError;
  @JsonKey(name: 'oldest_date')
  String get oldestDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_aged')
  int get daysAged => throw _privateConstructorUsedError;

  /// Serializes this ShippingUnsettledCourierBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingUnsettledCourierBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingUnsettledCourierBalanceCopyWith<ShippingUnsettledCourierBalance>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingUnsettledCourierBalanceCopyWith<$Res> {
  factory $ShippingUnsettledCourierBalanceCopyWith(
    ShippingUnsettledCourierBalance value,
    $Res Function(ShippingUnsettledCourierBalance) then,
  ) =
      _$ShippingUnsettledCourierBalanceCopyWithImpl<
        $Res,
        ShippingUnsettledCourierBalance
      >;
  @useResult
  $Res call({
    String party,
    @JsonKey(name: 'party_type') String partyType,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_owed') double totalOwed,
    @JsonKey(name: 'oldest_date') String oldestDate,
    @JsonKey(name: 'days_aged') int daysAged,
  });
}

/// @nodoc
class _$ShippingUnsettledCourierBalanceCopyWithImpl<
  $Res,
  $Val extends ShippingUnsettledCourierBalance
>
    implements $ShippingUnsettledCourierBalanceCopyWith<$Res> {
  _$ShippingUnsettledCourierBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingUnsettledCourierBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? party = null,
    Object? partyType = null,
    Object? orderCount = null,
    Object? totalOwed = null,
    Object? oldestDate = null,
    Object? daysAged = null,
  }) {
    return _then(
      _value.copyWith(
            party: null == party
                ? _value.party
                : party // ignore: cast_nullable_to_non_nullable
                      as String,
            partyType: null == partyType
                ? _value.partyType
                : partyType // ignore: cast_nullable_to_non_nullable
                      as String,
            orderCount: null == orderCount
                ? _value.orderCount
                : orderCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOwed: null == totalOwed
                ? _value.totalOwed
                : totalOwed // ignore: cast_nullable_to_non_nullable
                      as double,
            oldestDate: null == oldestDate
                ? _value.oldestDate
                : oldestDate // ignore: cast_nullable_to_non_nullable
                      as String,
            daysAged: null == daysAged
                ? _value.daysAged
                : daysAged // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingUnsettledCourierBalanceImplCopyWith<$Res>
    implements $ShippingUnsettledCourierBalanceCopyWith<$Res> {
  factory _$$ShippingUnsettledCourierBalanceImplCopyWith(
    _$ShippingUnsettledCourierBalanceImpl value,
    $Res Function(_$ShippingUnsettledCourierBalanceImpl) then,
  ) = __$$ShippingUnsettledCourierBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String party,
    @JsonKey(name: 'party_type') String partyType,
    @JsonKey(name: 'order_count') int orderCount,
    @JsonKey(name: 'total_owed') double totalOwed,
    @JsonKey(name: 'oldest_date') String oldestDate,
    @JsonKey(name: 'days_aged') int daysAged,
  });
}

/// @nodoc
class __$$ShippingUnsettledCourierBalanceImplCopyWithImpl<$Res>
    extends
        _$ShippingUnsettledCourierBalanceCopyWithImpl<
          $Res,
          _$ShippingUnsettledCourierBalanceImpl
        >
    implements _$$ShippingUnsettledCourierBalanceImplCopyWith<$Res> {
  __$$ShippingUnsettledCourierBalanceImplCopyWithImpl(
    _$ShippingUnsettledCourierBalanceImpl _value,
    $Res Function(_$ShippingUnsettledCourierBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingUnsettledCourierBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? party = null,
    Object? partyType = null,
    Object? orderCount = null,
    Object? totalOwed = null,
    Object? oldestDate = null,
    Object? daysAged = null,
  }) {
    return _then(
      _$ShippingUnsettledCourierBalanceImpl(
        party: null == party
            ? _value.party
            : party // ignore: cast_nullable_to_non_nullable
                  as String,
        partyType: null == partyType
            ? _value.partyType
            : partyType // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCount: null == orderCount
            ? _value.orderCount
            : orderCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOwed: null == totalOwed
            ? _value.totalOwed
            : totalOwed // ignore: cast_nullable_to_non_nullable
                  as double,
        oldestDate: null == oldestDate
            ? _value.oldestDate
            : oldestDate // ignore: cast_nullable_to_non_nullable
                  as String,
        daysAged: null == daysAged
            ? _value.daysAged
            : daysAged // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingUnsettledCourierBalanceImpl
    implements _ShippingUnsettledCourierBalance {
  const _$ShippingUnsettledCourierBalanceImpl({
    this.party = '',
    @JsonKey(name: 'party_type') this.partyType = '',
    @JsonKey(name: 'order_count') this.orderCount = 0,
    @JsonKey(name: 'total_owed') this.totalOwed = 0,
    @JsonKey(name: 'oldest_date') this.oldestDate = '',
    @JsonKey(name: 'days_aged') this.daysAged = 0,
  });

  factory _$ShippingUnsettledCourierBalanceImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ShippingUnsettledCourierBalanceImplFromJson(json);

  @override
  @JsonKey()
  final String party;
  @override
  @JsonKey(name: 'party_type')
  final String partyType;
  @override
  @JsonKey(name: 'order_count')
  final int orderCount;
  @override
  @JsonKey(name: 'total_owed')
  final double totalOwed;
  @override
  @JsonKey(name: 'oldest_date')
  final String oldestDate;
  @override
  @JsonKey(name: 'days_aged')
  final int daysAged;

  @override
  String toString() {
    return 'ShippingUnsettledCourierBalance(party: $party, partyType: $partyType, orderCount: $orderCount, totalOwed: $totalOwed, oldestDate: $oldestDate, daysAged: $daysAged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingUnsettledCourierBalanceImpl &&
            (identical(other.party, party) || other.party == party) &&
            (identical(other.partyType, partyType) ||
                other.partyType == partyType) &&
            (identical(other.orderCount, orderCount) ||
                other.orderCount == orderCount) &&
            (identical(other.totalOwed, totalOwed) ||
                other.totalOwed == totalOwed) &&
            (identical(other.oldestDate, oldestDate) ||
                other.oldestDate == oldestDate) &&
            (identical(other.daysAged, daysAged) ||
                other.daysAged == daysAged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    party,
    partyType,
    orderCount,
    totalOwed,
    oldestDate,
    daysAged,
  );

  /// Create a copy of ShippingUnsettledCourierBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingUnsettledCourierBalanceImplCopyWith<
    _$ShippingUnsettledCourierBalanceImpl
  >
  get copyWith =>
      __$$ShippingUnsettledCourierBalanceImplCopyWithImpl<
        _$ShippingUnsettledCourierBalanceImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingUnsettledCourierBalanceImplToJson(this);
  }
}

abstract class _ShippingUnsettledCourierBalance
    implements ShippingUnsettledCourierBalance {
  const factory _ShippingUnsettledCourierBalance({
    final String party,
    @JsonKey(name: 'party_type') final String partyType,
    @JsonKey(name: 'order_count') final int orderCount,
    @JsonKey(name: 'total_owed') final double totalOwed,
    @JsonKey(name: 'oldest_date') final String oldestDate,
    @JsonKey(name: 'days_aged') final int daysAged,
  }) = _$ShippingUnsettledCourierBalanceImpl;

  factory _ShippingUnsettledCourierBalance.fromJson(Map<String, dynamic> json) =
      _$ShippingUnsettledCourierBalanceImpl.fromJson;

  @override
  String get party;
  @override
  @JsonKey(name: 'party_type')
  String get partyType;
  @override
  @JsonKey(name: 'order_count')
  int get orderCount;
  @override
  @JsonKey(name: 'total_owed')
  double get totalOwed;
  @override
  @JsonKey(name: 'oldest_date')
  String get oldestDate;
  @override
  @JsonKey(name: 'days_aged')
  int get daysAged;

  /// Create a copy of ShippingUnsettledCourierBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingUnsettledCourierBalanceImplCopyWith<
    _$ShippingUnsettledCourierBalanceImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ShippingPickupDeliveryTrendPoint _$ShippingPickupDeliveryTrendPointFromJson(
  Map<String, dynamic> json,
) {
  return _ShippingPickupDeliveryTrendPoint.fromJson(json);
}

/// @nodoc
mixin _$ShippingPickupDeliveryTrendPoint {
  @JsonKey(name: 'posting_date')
  String get postingDate => throw _privateConstructorUsedError;
  int get pickup => throw _privateConstructorUsedError;
  int get delivery => throw _privateConstructorUsedError;

  /// Serializes this ShippingPickupDeliveryTrendPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingPickupDeliveryTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingPickupDeliveryTrendPointCopyWith<ShippingPickupDeliveryTrendPoint>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingPickupDeliveryTrendPointCopyWith<$Res> {
  factory $ShippingPickupDeliveryTrendPointCopyWith(
    ShippingPickupDeliveryTrendPoint value,
    $Res Function(ShippingPickupDeliveryTrendPoint) then,
  ) =
      _$ShippingPickupDeliveryTrendPointCopyWithImpl<
        $Res,
        ShippingPickupDeliveryTrendPoint
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    int pickup,
    int delivery,
  });
}

/// @nodoc
class _$ShippingPickupDeliveryTrendPointCopyWithImpl<
  $Res,
  $Val extends ShippingPickupDeliveryTrendPoint
>
    implements $ShippingPickupDeliveryTrendPointCopyWith<$Res> {
  _$ShippingPickupDeliveryTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingPickupDeliveryTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? pickup = null,
    Object? delivery = null,
  }) {
    return _then(
      _value.copyWith(
            postingDate: null == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String,
            pickup: null == pickup
                ? _value.pickup
                : pickup // ignore: cast_nullable_to_non_nullable
                      as int,
            delivery: null == delivery
                ? _value.delivery
                : delivery // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShippingPickupDeliveryTrendPointImplCopyWith<$Res>
    implements $ShippingPickupDeliveryTrendPointCopyWith<$Res> {
  factory _$$ShippingPickupDeliveryTrendPointImplCopyWith(
    _$ShippingPickupDeliveryTrendPointImpl value,
    $Res Function(_$ShippingPickupDeliveryTrendPointImpl) then,
  ) = __$$ShippingPickupDeliveryTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    int pickup,
    int delivery,
  });
}

/// @nodoc
class __$$ShippingPickupDeliveryTrendPointImplCopyWithImpl<$Res>
    extends
        _$ShippingPickupDeliveryTrendPointCopyWithImpl<
          $Res,
          _$ShippingPickupDeliveryTrendPointImpl
        >
    implements _$$ShippingPickupDeliveryTrendPointImplCopyWith<$Res> {
  __$$ShippingPickupDeliveryTrendPointImplCopyWithImpl(
    _$ShippingPickupDeliveryTrendPointImpl _value,
    $Res Function(_$ShippingPickupDeliveryTrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingPickupDeliveryTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? pickup = null,
    Object? delivery = null,
  }) {
    return _then(
      _$ShippingPickupDeliveryTrendPointImpl(
        postingDate: null == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String,
        pickup: null == pickup
            ? _value.pickup
            : pickup // ignore: cast_nullable_to_non_nullable
                  as int,
        delivery: null == delivery
            ? _value.delivery
            : delivery // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingPickupDeliveryTrendPointImpl
    implements _ShippingPickupDeliveryTrendPoint {
  const _$ShippingPickupDeliveryTrendPointImpl({
    @JsonKey(name: 'posting_date') this.postingDate = '',
    this.pickup = 0,
    this.delivery = 0,
  });

  factory _$ShippingPickupDeliveryTrendPointImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ShippingPickupDeliveryTrendPointImplFromJson(json);

  @override
  @JsonKey(name: 'posting_date')
  final String postingDate;
  @override
  @JsonKey()
  final int pickup;
  @override
  @JsonKey()
  final int delivery;

  @override
  String toString() {
    return 'ShippingPickupDeliveryTrendPoint(postingDate: $postingDate, pickup: $pickup, delivery: $delivery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingPickupDeliveryTrendPointImpl &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.pickup, pickup) || other.pickup == pickup) &&
            (identical(other.delivery, delivery) ||
                other.delivery == delivery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, postingDate, pickup, delivery);

  /// Create a copy of ShippingPickupDeliveryTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingPickupDeliveryTrendPointImplCopyWith<
    _$ShippingPickupDeliveryTrendPointImpl
  >
  get copyWith =>
      __$$ShippingPickupDeliveryTrendPointImplCopyWithImpl<
        _$ShippingPickupDeliveryTrendPointImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingPickupDeliveryTrendPointImplToJson(this);
  }
}

abstract class _ShippingPickupDeliveryTrendPoint
    implements ShippingPickupDeliveryTrendPoint {
  const factory _ShippingPickupDeliveryTrendPoint({
    @JsonKey(name: 'posting_date') final String postingDate,
    final int pickup,
    final int delivery,
  }) = _$ShippingPickupDeliveryTrendPointImpl;

  factory _ShippingPickupDeliveryTrendPoint.fromJson(
    Map<String, dynamic> json,
  ) = _$ShippingPickupDeliveryTrendPointImpl.fromJson;

  @override
  @JsonKey(name: 'posting_date')
  String get postingDate;
  @override
  int get pickup;
  @override
  int get delivery;

  /// Create a copy of ShippingPickupDeliveryTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingPickupDeliveryTrendPointImplCopyWith<
    _$ShippingPickupDeliveryTrendPointImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
