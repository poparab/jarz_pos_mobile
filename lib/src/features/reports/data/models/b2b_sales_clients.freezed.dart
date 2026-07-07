// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'b2b_sales_clients.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

B2bSalesAnalytics _$B2bSalesAnalyticsFromJson(Map<String, dynamic> json) {
  return _B2bSalesAnalytics.fromJson(json);
}

/// @nodoc
mixin _$B2bSalesAnalytics {
  B2bSalesPeriod get period => throw _privateConstructorUsedError;
  B2bSalesSummary get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'pipeline_by_stage')
  List<B2bPipelineStage> get pipelineByStage =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'revenue_trend')
  List<B2bSalesRevenueTrendPoint> get revenueTrend =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'top_clients')
  List<B2bTopClient> get topClients => throw _privateConstructorUsedError;
  @JsonKey(name: 'revenue_by_policy')
  List<B2bRevenueByPolicy> get revenueByPolicy =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'revenue_by_territory')
  List<B2bRevenueByTerritory> get revenueByTerritory =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'clients_by_group')
  List<B2bClientsByGroup> get clientsByGroup =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'reorder_due')
  List<B2bReorderDueClient> get reorderDue =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'at_risk_clients')
  List<B2bAtRiskClient> get atRiskClients => throw _privateConstructorUsedError;
  B2bConversion get conversion => throw _privateConstructorUsedError;
  List<B2bSalesAlert> get alerts => throw _privateConstructorUsedError;

  /// Serializes this B2bSalesAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bSalesAnalyticsCopyWith<B2bSalesAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bSalesAnalyticsCopyWith<$Res> {
  factory $B2bSalesAnalyticsCopyWith(
    B2bSalesAnalytics value,
    $Res Function(B2bSalesAnalytics) then,
  ) = _$B2bSalesAnalyticsCopyWithImpl<$Res, B2bSalesAnalytics>;
  @useResult
  $Res call({
    B2bSalesPeriod period,
    B2bSalesSummary summary,
    @JsonKey(name: 'pipeline_by_stage') List<B2bPipelineStage> pipelineByStage,
    @JsonKey(name: 'revenue_trend')
    List<B2bSalesRevenueTrendPoint> revenueTrend,
    @JsonKey(name: 'top_clients') List<B2bTopClient> topClients,
    @JsonKey(name: 'revenue_by_policy')
    List<B2bRevenueByPolicy> revenueByPolicy,
    @JsonKey(name: 'revenue_by_territory')
    List<B2bRevenueByTerritory> revenueByTerritory,
    @JsonKey(name: 'clients_by_group') List<B2bClientsByGroup> clientsByGroup,
    @JsonKey(name: 'reorder_due') List<B2bReorderDueClient> reorderDue,
    @JsonKey(name: 'at_risk_clients') List<B2bAtRiskClient> atRiskClients,
    B2bConversion conversion,
    List<B2bSalesAlert> alerts,
  });

  $B2bSalesPeriodCopyWith<$Res> get period;
  $B2bSalesSummaryCopyWith<$Res> get summary;
  $B2bConversionCopyWith<$Res> get conversion;
}

/// @nodoc
class _$B2bSalesAnalyticsCopyWithImpl<$Res, $Val extends B2bSalesAnalytics>
    implements $B2bSalesAnalyticsCopyWith<$Res> {
  _$B2bSalesAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? pipelineByStage = null,
    Object? revenueTrend = null,
    Object? topClients = null,
    Object? revenueByPolicy = null,
    Object? revenueByTerritory = null,
    Object? clientsByGroup = null,
    Object? reorderDue = null,
    Object? atRiskClients = null,
    Object? conversion = null,
    Object? alerts = null,
  }) {
    return _then(
      _value.copyWith(
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as B2bSalesPeriod,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as B2bSalesSummary,
            pipelineByStage: null == pipelineByStage
                ? _value.pipelineByStage
                : pipelineByStage // ignore: cast_nullable_to_non_nullable
                      as List<B2bPipelineStage>,
            revenueTrend: null == revenueTrend
                ? _value.revenueTrend
                : revenueTrend // ignore: cast_nullable_to_non_nullable
                      as List<B2bSalesRevenueTrendPoint>,
            topClients: null == topClients
                ? _value.topClients
                : topClients // ignore: cast_nullable_to_non_nullable
                      as List<B2bTopClient>,
            revenueByPolicy: null == revenueByPolicy
                ? _value.revenueByPolicy
                : revenueByPolicy // ignore: cast_nullable_to_non_nullable
                      as List<B2bRevenueByPolicy>,
            revenueByTerritory: null == revenueByTerritory
                ? _value.revenueByTerritory
                : revenueByTerritory // ignore: cast_nullable_to_non_nullable
                      as List<B2bRevenueByTerritory>,
            clientsByGroup: null == clientsByGroup
                ? _value.clientsByGroup
                : clientsByGroup // ignore: cast_nullable_to_non_nullable
                      as List<B2bClientsByGroup>,
            reorderDue: null == reorderDue
                ? _value.reorderDue
                : reorderDue // ignore: cast_nullable_to_non_nullable
                      as List<B2bReorderDueClient>,
            atRiskClients: null == atRiskClients
                ? _value.atRiskClients
                : atRiskClients // ignore: cast_nullable_to_non_nullable
                      as List<B2bAtRiskClient>,
            conversion: null == conversion
                ? _value.conversion
                : conversion // ignore: cast_nullable_to_non_nullable
                      as B2bConversion,
            alerts: null == alerts
                ? _value.alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                      as List<B2bSalesAlert>,
          )
          as $Val,
    );
  }

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bSalesPeriodCopyWith<$Res> get period {
    return $B2bSalesPeriodCopyWith<$Res>(_value.period, (value) {
      return _then(_value.copyWith(period: value) as $Val);
    });
  }

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bSalesSummaryCopyWith<$Res> get summary {
    return $B2bSalesSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bConversionCopyWith<$Res> get conversion {
    return $B2bConversionCopyWith<$Res>(_value.conversion, (value) {
      return _then(_value.copyWith(conversion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$B2bSalesAnalyticsImplCopyWith<$Res>
    implements $B2bSalesAnalyticsCopyWith<$Res> {
  factory _$$B2bSalesAnalyticsImplCopyWith(
    _$B2bSalesAnalyticsImpl value,
    $Res Function(_$B2bSalesAnalyticsImpl) then,
  ) = __$$B2bSalesAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    B2bSalesPeriod period,
    B2bSalesSummary summary,
    @JsonKey(name: 'pipeline_by_stage') List<B2bPipelineStage> pipelineByStage,
    @JsonKey(name: 'revenue_trend')
    List<B2bSalesRevenueTrendPoint> revenueTrend,
    @JsonKey(name: 'top_clients') List<B2bTopClient> topClients,
    @JsonKey(name: 'revenue_by_policy')
    List<B2bRevenueByPolicy> revenueByPolicy,
    @JsonKey(name: 'revenue_by_territory')
    List<B2bRevenueByTerritory> revenueByTerritory,
    @JsonKey(name: 'clients_by_group') List<B2bClientsByGroup> clientsByGroup,
    @JsonKey(name: 'reorder_due') List<B2bReorderDueClient> reorderDue,
    @JsonKey(name: 'at_risk_clients') List<B2bAtRiskClient> atRiskClients,
    B2bConversion conversion,
    List<B2bSalesAlert> alerts,
  });

  @override
  $B2bSalesPeriodCopyWith<$Res> get period;
  @override
  $B2bSalesSummaryCopyWith<$Res> get summary;
  @override
  $B2bConversionCopyWith<$Res> get conversion;
}

/// @nodoc
class __$$B2bSalesAnalyticsImplCopyWithImpl<$Res>
    extends _$B2bSalesAnalyticsCopyWithImpl<$Res, _$B2bSalesAnalyticsImpl>
    implements _$$B2bSalesAnalyticsImplCopyWith<$Res> {
  __$$B2bSalesAnalyticsImplCopyWithImpl(
    _$B2bSalesAnalyticsImpl _value,
    $Res Function(_$B2bSalesAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? pipelineByStage = null,
    Object? revenueTrend = null,
    Object? topClients = null,
    Object? revenueByPolicy = null,
    Object? revenueByTerritory = null,
    Object? clientsByGroup = null,
    Object? reorderDue = null,
    Object? atRiskClients = null,
    Object? conversion = null,
    Object? alerts = null,
  }) {
    return _then(
      _$B2bSalesAnalyticsImpl(
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as B2bSalesPeriod,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as B2bSalesSummary,
        pipelineByStage: null == pipelineByStage
            ? _value._pipelineByStage
            : pipelineByStage // ignore: cast_nullable_to_non_nullable
                  as List<B2bPipelineStage>,
        revenueTrend: null == revenueTrend
            ? _value._revenueTrend
            : revenueTrend // ignore: cast_nullable_to_non_nullable
                  as List<B2bSalesRevenueTrendPoint>,
        topClients: null == topClients
            ? _value._topClients
            : topClients // ignore: cast_nullable_to_non_nullable
                  as List<B2bTopClient>,
        revenueByPolicy: null == revenueByPolicy
            ? _value._revenueByPolicy
            : revenueByPolicy // ignore: cast_nullable_to_non_nullable
                  as List<B2bRevenueByPolicy>,
        revenueByTerritory: null == revenueByTerritory
            ? _value._revenueByTerritory
            : revenueByTerritory // ignore: cast_nullable_to_non_nullable
                  as List<B2bRevenueByTerritory>,
        clientsByGroup: null == clientsByGroup
            ? _value._clientsByGroup
            : clientsByGroup // ignore: cast_nullable_to_non_nullable
                  as List<B2bClientsByGroup>,
        reorderDue: null == reorderDue
            ? _value._reorderDue
            : reorderDue // ignore: cast_nullable_to_non_nullable
                  as List<B2bReorderDueClient>,
        atRiskClients: null == atRiskClients
            ? _value._atRiskClients
            : atRiskClients // ignore: cast_nullable_to_non_nullable
                  as List<B2bAtRiskClient>,
        conversion: null == conversion
            ? _value.conversion
            : conversion // ignore: cast_nullable_to_non_nullable
                  as B2bConversion,
        alerts: null == alerts
            ? _value._alerts
            : alerts // ignore: cast_nullable_to_non_nullable
                  as List<B2bSalesAlert>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bSalesAnalyticsImpl implements _B2bSalesAnalytics {
  const _$B2bSalesAnalyticsImpl({
    this.period = const B2bSalesPeriod(),
    this.summary = const B2bSalesSummary(),
    @JsonKey(name: 'pipeline_by_stage')
    final List<B2bPipelineStage> pipelineByStage = const <B2bPipelineStage>[],
    @JsonKey(name: 'revenue_trend')
    final List<B2bSalesRevenueTrendPoint> revenueTrend =
        const <B2bSalesRevenueTrendPoint>[],
    @JsonKey(name: 'top_clients')
    final List<B2bTopClient> topClients = const <B2bTopClient>[],
    @JsonKey(name: 'revenue_by_policy')
    final List<B2bRevenueByPolicy> revenueByPolicy =
        const <B2bRevenueByPolicy>[],
    @JsonKey(name: 'revenue_by_territory')
    final List<B2bRevenueByTerritory> revenueByTerritory =
        const <B2bRevenueByTerritory>[],
    @JsonKey(name: 'clients_by_group')
    final List<B2bClientsByGroup> clientsByGroup = const <B2bClientsByGroup>[],
    @JsonKey(name: 'reorder_due')
    final List<B2bReorderDueClient> reorderDue = const <B2bReorderDueClient>[],
    @JsonKey(name: 'at_risk_clients')
    final List<B2bAtRiskClient> atRiskClients = const <B2bAtRiskClient>[],
    this.conversion = const B2bConversion(),
    final List<B2bSalesAlert> alerts = const <B2bSalesAlert>[],
  }) : _pipelineByStage = pipelineByStage,
       _revenueTrend = revenueTrend,
       _topClients = topClients,
       _revenueByPolicy = revenueByPolicy,
       _revenueByTerritory = revenueByTerritory,
       _clientsByGroup = clientsByGroup,
       _reorderDue = reorderDue,
       _atRiskClients = atRiskClients,
       _alerts = alerts;

  factory _$B2bSalesAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bSalesAnalyticsImplFromJson(json);

  @override
  @JsonKey()
  final B2bSalesPeriod period;
  @override
  @JsonKey()
  final B2bSalesSummary summary;
  final List<B2bPipelineStage> _pipelineByStage;
  @override
  @JsonKey(name: 'pipeline_by_stage')
  List<B2bPipelineStage> get pipelineByStage {
    if (_pipelineByStage is EqualUnmodifiableListView) return _pipelineByStage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pipelineByStage);
  }

  final List<B2bSalesRevenueTrendPoint> _revenueTrend;
  @override
  @JsonKey(name: 'revenue_trend')
  List<B2bSalesRevenueTrendPoint> get revenueTrend {
    if (_revenueTrend is EqualUnmodifiableListView) return _revenueTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueTrend);
  }

  final List<B2bTopClient> _topClients;
  @override
  @JsonKey(name: 'top_clients')
  List<B2bTopClient> get topClients {
    if (_topClients is EqualUnmodifiableListView) return _topClients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topClients);
  }

  final List<B2bRevenueByPolicy> _revenueByPolicy;
  @override
  @JsonKey(name: 'revenue_by_policy')
  List<B2bRevenueByPolicy> get revenueByPolicy {
    if (_revenueByPolicy is EqualUnmodifiableListView) return _revenueByPolicy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueByPolicy);
  }

  final List<B2bRevenueByTerritory> _revenueByTerritory;
  @override
  @JsonKey(name: 'revenue_by_territory')
  List<B2bRevenueByTerritory> get revenueByTerritory {
    if (_revenueByTerritory is EqualUnmodifiableListView)
      return _revenueByTerritory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueByTerritory);
  }

  final List<B2bClientsByGroup> _clientsByGroup;
  @override
  @JsonKey(name: 'clients_by_group')
  List<B2bClientsByGroup> get clientsByGroup {
    if (_clientsByGroup is EqualUnmodifiableListView) return _clientsByGroup;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_clientsByGroup);
  }

  final List<B2bReorderDueClient> _reorderDue;
  @override
  @JsonKey(name: 'reorder_due')
  List<B2bReorderDueClient> get reorderDue {
    if (_reorderDue is EqualUnmodifiableListView) return _reorderDue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reorderDue);
  }

  final List<B2bAtRiskClient> _atRiskClients;
  @override
  @JsonKey(name: 'at_risk_clients')
  List<B2bAtRiskClient> get atRiskClients {
    if (_atRiskClients is EqualUnmodifiableListView) return _atRiskClients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_atRiskClients);
  }

  @override
  @JsonKey()
  final B2bConversion conversion;
  final List<B2bSalesAlert> _alerts;
  @override
  @JsonKey()
  List<B2bSalesAlert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  String toString() {
    return 'B2bSalesAnalytics(period: $period, summary: $summary, pipelineByStage: $pipelineByStage, revenueTrend: $revenueTrend, topClients: $topClients, revenueByPolicy: $revenueByPolicy, revenueByTerritory: $revenueByTerritory, clientsByGroup: $clientsByGroup, reorderDue: $reorderDue, atRiskClients: $atRiskClients, conversion: $conversion, alerts: $alerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bSalesAnalyticsImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._pipelineByStage,
              _pipelineByStage,
            ) &&
            const DeepCollectionEquality().equals(
              other._revenueTrend,
              _revenueTrend,
            ) &&
            const DeepCollectionEquality().equals(
              other._topClients,
              _topClients,
            ) &&
            const DeepCollectionEquality().equals(
              other._revenueByPolicy,
              _revenueByPolicy,
            ) &&
            const DeepCollectionEquality().equals(
              other._revenueByTerritory,
              _revenueByTerritory,
            ) &&
            const DeepCollectionEquality().equals(
              other._clientsByGroup,
              _clientsByGroup,
            ) &&
            const DeepCollectionEquality().equals(
              other._reorderDue,
              _reorderDue,
            ) &&
            const DeepCollectionEquality().equals(
              other._atRiskClients,
              _atRiskClients,
            ) &&
            (identical(other.conversion, conversion) ||
                other.conversion == conversion) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    period,
    summary,
    const DeepCollectionEquality().hash(_pipelineByStage),
    const DeepCollectionEquality().hash(_revenueTrend),
    const DeepCollectionEquality().hash(_topClients),
    const DeepCollectionEquality().hash(_revenueByPolicy),
    const DeepCollectionEquality().hash(_revenueByTerritory),
    const DeepCollectionEquality().hash(_clientsByGroup),
    const DeepCollectionEquality().hash(_reorderDue),
    const DeepCollectionEquality().hash(_atRiskClients),
    conversion,
    const DeepCollectionEquality().hash(_alerts),
  );

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bSalesAnalyticsImplCopyWith<_$B2bSalesAnalyticsImpl> get copyWith =>
      __$$B2bSalesAnalyticsImplCopyWithImpl<_$B2bSalesAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bSalesAnalyticsImplToJson(this);
  }
}

abstract class _B2bSalesAnalytics implements B2bSalesAnalytics {
  const factory _B2bSalesAnalytics({
    final B2bSalesPeriod period,
    final B2bSalesSummary summary,
    @JsonKey(name: 'pipeline_by_stage')
    final List<B2bPipelineStage> pipelineByStage,
    @JsonKey(name: 'revenue_trend')
    final List<B2bSalesRevenueTrendPoint> revenueTrend,
    @JsonKey(name: 'top_clients') final List<B2bTopClient> topClients,
    @JsonKey(name: 'revenue_by_policy')
    final List<B2bRevenueByPolicy> revenueByPolicy,
    @JsonKey(name: 'revenue_by_territory')
    final List<B2bRevenueByTerritory> revenueByTerritory,
    @JsonKey(name: 'clients_by_group')
    final List<B2bClientsByGroup> clientsByGroup,
    @JsonKey(name: 'reorder_due') final List<B2bReorderDueClient> reorderDue,
    @JsonKey(name: 'at_risk_clients') final List<B2bAtRiskClient> atRiskClients,
    final B2bConversion conversion,
    final List<B2bSalesAlert> alerts,
  }) = _$B2bSalesAnalyticsImpl;

  factory _B2bSalesAnalytics.fromJson(Map<String, dynamic> json) =
      _$B2bSalesAnalyticsImpl.fromJson;

  @override
  B2bSalesPeriod get period;
  @override
  B2bSalesSummary get summary;
  @override
  @JsonKey(name: 'pipeline_by_stage')
  List<B2bPipelineStage> get pipelineByStage;
  @override
  @JsonKey(name: 'revenue_trend')
  List<B2bSalesRevenueTrendPoint> get revenueTrend;
  @override
  @JsonKey(name: 'top_clients')
  List<B2bTopClient> get topClients;
  @override
  @JsonKey(name: 'revenue_by_policy')
  List<B2bRevenueByPolicy> get revenueByPolicy;
  @override
  @JsonKey(name: 'revenue_by_territory')
  List<B2bRevenueByTerritory> get revenueByTerritory;
  @override
  @JsonKey(name: 'clients_by_group')
  List<B2bClientsByGroup> get clientsByGroup;
  @override
  @JsonKey(name: 'reorder_due')
  List<B2bReorderDueClient> get reorderDue;
  @override
  @JsonKey(name: 'at_risk_clients')
  List<B2bAtRiskClient> get atRiskClients;
  @override
  B2bConversion get conversion;
  @override
  List<B2bSalesAlert> get alerts;

  /// Create a copy of B2bSalesAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bSalesAnalyticsImplCopyWith<_$B2bSalesAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bSalesPeriod _$B2bSalesPeriodFromJson(Map<String, dynamic> json) {
  return _B2bSalesPeriod.fromJson(json);
}

/// @nodoc
mixin _$B2bSalesPeriod {
  @JsonKey(name: 'date_from')
  String get dateFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_to')
  String get dateTo => throw _privateConstructorUsedError;

  /// Serializes this B2bSalesPeriod to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bSalesPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bSalesPeriodCopyWith<B2bSalesPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bSalesPeriodCopyWith<$Res> {
  factory $B2bSalesPeriodCopyWith(
    B2bSalesPeriod value,
    $Res Function(B2bSalesPeriod) then,
  ) = _$B2bSalesPeriodCopyWithImpl<$Res, B2bSalesPeriod>;
  @useResult
  $Res call({
    @JsonKey(name: 'date_from') String dateFrom,
    @JsonKey(name: 'date_to') String dateTo,
  });
}

/// @nodoc
class _$B2bSalesPeriodCopyWithImpl<$Res, $Val extends B2bSalesPeriod>
    implements $B2bSalesPeriodCopyWith<$Res> {
  _$B2bSalesPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bSalesPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dateFrom = null, Object? dateTo = null}) {
    return _then(
      _value.copyWith(
            dateFrom: null == dateFrom
                ? _value.dateFrom
                : dateFrom // ignore: cast_nullable_to_non_nullable
                      as String,
            dateTo: null == dateTo
                ? _value.dateTo
                : dateTo // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bSalesPeriodImplCopyWith<$Res>
    implements $B2bSalesPeriodCopyWith<$Res> {
  factory _$$B2bSalesPeriodImplCopyWith(
    _$B2bSalesPeriodImpl value,
    $Res Function(_$B2bSalesPeriodImpl) then,
  ) = __$$B2bSalesPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'date_from') String dateFrom,
    @JsonKey(name: 'date_to') String dateTo,
  });
}

/// @nodoc
class __$$B2bSalesPeriodImplCopyWithImpl<$Res>
    extends _$B2bSalesPeriodCopyWithImpl<$Res, _$B2bSalesPeriodImpl>
    implements _$$B2bSalesPeriodImplCopyWith<$Res> {
  __$$B2bSalesPeriodImplCopyWithImpl(
    _$B2bSalesPeriodImpl _value,
    $Res Function(_$B2bSalesPeriodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bSalesPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dateFrom = null, Object? dateTo = null}) {
    return _then(
      _$B2bSalesPeriodImpl(
        dateFrom: null == dateFrom
            ? _value.dateFrom
            : dateFrom // ignore: cast_nullable_to_non_nullable
                  as String,
        dateTo: null == dateTo
            ? _value.dateTo
            : dateTo // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bSalesPeriodImpl implements _B2bSalesPeriod {
  const _$B2bSalesPeriodImpl({
    @JsonKey(name: 'date_from') this.dateFrom = '',
    @JsonKey(name: 'date_to') this.dateTo = '',
  });

  factory _$B2bSalesPeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bSalesPeriodImplFromJson(json);

  @override
  @JsonKey(name: 'date_from')
  final String dateFrom;
  @override
  @JsonKey(name: 'date_to')
  final String dateTo;

  @override
  String toString() {
    return 'B2bSalesPeriod(dateFrom: $dateFrom, dateTo: $dateTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bSalesPeriodImpl &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dateFrom, dateTo);

  /// Create a copy of B2bSalesPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bSalesPeriodImplCopyWith<_$B2bSalesPeriodImpl> get copyWith =>
      __$$B2bSalesPeriodImplCopyWithImpl<_$B2bSalesPeriodImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bSalesPeriodImplToJson(this);
  }
}

abstract class _B2bSalesPeriod implements B2bSalesPeriod {
  const factory _B2bSalesPeriod({
    @JsonKey(name: 'date_from') final String dateFrom,
    @JsonKey(name: 'date_to') final String dateTo,
  }) = _$B2bSalesPeriodImpl;

  factory _B2bSalesPeriod.fromJson(Map<String, dynamic> json) =
      _$B2bSalesPeriodImpl.fromJson;

  @override
  @JsonKey(name: 'date_from')
  String get dateFrom;
  @override
  @JsonKey(name: 'date_to')
  String get dateTo;

  /// Create a copy of B2bSalesPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bSalesPeriodImplCopyWith<_$B2bSalesPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bSalesSummary _$B2bSalesSummaryFromJson(Map<String, dynamic> json) {
  return _B2bSalesSummary.fromJson(json);
}

/// @nodoc
mixin _$B2bSalesSummary {
  @JsonKey(name: 'b2b_revenue')
  double get b2bRevenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'b2b_orders')
  int get b2bOrders => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_clients')
  int get activeClients => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_clients')
  int get newClients => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_profit')
  double get grossProfit => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_margin_pct')
  double get grossMarginPct => throw _privateConstructorUsedError;
  @JsonKey(name: 'reorder_due_count')
  int get reorderDueCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'at_risk_count')
  int get atRiskCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_b2b_clients')
  int get totalB2bClients => throw _privateConstructorUsedError;
  @JsonKey(name: 'pipeline_open_value')
  double get pipelineOpenValue => throw _privateConstructorUsedError;

  /// Serializes this B2bSalesSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bSalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bSalesSummaryCopyWith<B2bSalesSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bSalesSummaryCopyWith<$Res> {
  factory $B2bSalesSummaryCopyWith(
    B2bSalesSummary value,
    $Res Function(B2bSalesSummary) then,
  ) = _$B2bSalesSummaryCopyWithImpl<$Res, B2bSalesSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'b2b_revenue') double b2bRevenue,
    @JsonKey(name: 'b2b_orders') int b2bOrders,
    @JsonKey(name: 'active_clients') int activeClients,
    @JsonKey(name: 'new_clients') int newClients,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'gross_profit') double grossProfit,
    @JsonKey(name: 'gross_margin_pct') double grossMarginPct,
    @JsonKey(name: 'reorder_due_count') int reorderDueCount,
    @JsonKey(name: 'at_risk_count') int atRiskCount,
    @JsonKey(name: 'total_b2b_clients') int totalB2bClients,
    @JsonKey(name: 'pipeline_open_value') double pipelineOpenValue,
  });
}

/// @nodoc
class _$B2bSalesSummaryCopyWithImpl<$Res, $Val extends B2bSalesSummary>
    implements $B2bSalesSummaryCopyWith<$Res> {
  _$B2bSalesSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bSalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b2bRevenue = null,
    Object? b2bOrders = null,
    Object? activeClients = null,
    Object? newClients = null,
    Object? avgOrderValue = null,
    Object? grossProfit = null,
    Object? grossMarginPct = null,
    Object? reorderDueCount = null,
    Object? atRiskCount = null,
    Object? totalB2bClients = null,
    Object? pipelineOpenValue = null,
  }) {
    return _then(
      _value.copyWith(
            b2bRevenue: null == b2bRevenue
                ? _value.b2bRevenue
                : b2bRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            b2bOrders: null == b2bOrders
                ? _value.b2bOrders
                : b2bOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            activeClients: null == activeClients
                ? _value.activeClients
                : activeClients // ignore: cast_nullable_to_non_nullable
                      as int,
            newClients: null == newClients
                ? _value.newClients
                : newClients // ignore: cast_nullable_to_non_nullable
                      as int,
            avgOrderValue: null == avgOrderValue
                ? _value.avgOrderValue
                : avgOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
            grossProfit: null == grossProfit
                ? _value.grossProfit
                : grossProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            grossMarginPct: null == grossMarginPct
                ? _value.grossMarginPct
                : grossMarginPct // ignore: cast_nullable_to_non_nullable
                      as double,
            reorderDueCount: null == reorderDueCount
                ? _value.reorderDueCount
                : reorderDueCount // ignore: cast_nullable_to_non_nullable
                      as int,
            atRiskCount: null == atRiskCount
                ? _value.atRiskCount
                : atRiskCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalB2bClients: null == totalB2bClients
                ? _value.totalB2bClients
                : totalB2bClients // ignore: cast_nullable_to_non_nullable
                      as int,
            pipelineOpenValue: null == pipelineOpenValue
                ? _value.pipelineOpenValue
                : pipelineOpenValue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bSalesSummaryImplCopyWith<$Res>
    implements $B2bSalesSummaryCopyWith<$Res> {
  factory _$$B2bSalesSummaryImplCopyWith(
    _$B2bSalesSummaryImpl value,
    $Res Function(_$B2bSalesSummaryImpl) then,
  ) = __$$B2bSalesSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'b2b_revenue') double b2bRevenue,
    @JsonKey(name: 'b2b_orders') int b2bOrders,
    @JsonKey(name: 'active_clients') int activeClients,
    @JsonKey(name: 'new_clients') int newClients,
    @JsonKey(name: 'avg_order_value') double avgOrderValue,
    @JsonKey(name: 'gross_profit') double grossProfit,
    @JsonKey(name: 'gross_margin_pct') double grossMarginPct,
    @JsonKey(name: 'reorder_due_count') int reorderDueCount,
    @JsonKey(name: 'at_risk_count') int atRiskCount,
    @JsonKey(name: 'total_b2b_clients') int totalB2bClients,
    @JsonKey(name: 'pipeline_open_value') double pipelineOpenValue,
  });
}

/// @nodoc
class __$$B2bSalesSummaryImplCopyWithImpl<$Res>
    extends _$B2bSalesSummaryCopyWithImpl<$Res, _$B2bSalesSummaryImpl>
    implements _$$B2bSalesSummaryImplCopyWith<$Res> {
  __$$B2bSalesSummaryImplCopyWithImpl(
    _$B2bSalesSummaryImpl _value,
    $Res Function(_$B2bSalesSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bSalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b2bRevenue = null,
    Object? b2bOrders = null,
    Object? activeClients = null,
    Object? newClients = null,
    Object? avgOrderValue = null,
    Object? grossProfit = null,
    Object? grossMarginPct = null,
    Object? reorderDueCount = null,
    Object? atRiskCount = null,
    Object? totalB2bClients = null,
    Object? pipelineOpenValue = null,
  }) {
    return _then(
      _$B2bSalesSummaryImpl(
        b2bRevenue: null == b2bRevenue
            ? _value.b2bRevenue
            : b2bRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        b2bOrders: null == b2bOrders
            ? _value.b2bOrders
            : b2bOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        activeClients: null == activeClients
            ? _value.activeClients
            : activeClients // ignore: cast_nullable_to_non_nullable
                  as int,
        newClients: null == newClients
            ? _value.newClients
            : newClients // ignore: cast_nullable_to_non_nullable
                  as int,
        avgOrderValue: null == avgOrderValue
            ? _value.avgOrderValue
            : avgOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
        grossProfit: null == grossProfit
            ? _value.grossProfit
            : grossProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        grossMarginPct: null == grossMarginPct
            ? _value.grossMarginPct
            : grossMarginPct // ignore: cast_nullable_to_non_nullable
                  as double,
        reorderDueCount: null == reorderDueCount
            ? _value.reorderDueCount
            : reorderDueCount // ignore: cast_nullable_to_non_nullable
                  as int,
        atRiskCount: null == atRiskCount
            ? _value.atRiskCount
            : atRiskCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalB2bClients: null == totalB2bClients
            ? _value.totalB2bClients
            : totalB2bClients // ignore: cast_nullable_to_non_nullable
                  as int,
        pipelineOpenValue: null == pipelineOpenValue
            ? _value.pipelineOpenValue
            : pipelineOpenValue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bSalesSummaryImpl implements _B2bSalesSummary {
  const _$B2bSalesSummaryImpl({
    @JsonKey(name: 'b2b_revenue') this.b2bRevenue = 0,
    @JsonKey(name: 'b2b_orders') this.b2bOrders = 0,
    @JsonKey(name: 'active_clients') this.activeClients = 0,
    @JsonKey(name: 'new_clients') this.newClients = 0,
    @JsonKey(name: 'avg_order_value') this.avgOrderValue = 0,
    @JsonKey(name: 'gross_profit') this.grossProfit = 0,
    @JsonKey(name: 'gross_margin_pct') this.grossMarginPct = 0,
    @JsonKey(name: 'reorder_due_count') this.reorderDueCount = 0,
    @JsonKey(name: 'at_risk_count') this.atRiskCount = 0,
    @JsonKey(name: 'total_b2b_clients') this.totalB2bClients = 0,
    @JsonKey(name: 'pipeline_open_value') this.pipelineOpenValue = 0,
  });

  factory _$B2bSalesSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bSalesSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'b2b_revenue')
  final double b2bRevenue;
  @override
  @JsonKey(name: 'b2b_orders')
  final int b2bOrders;
  @override
  @JsonKey(name: 'active_clients')
  final int activeClients;
  @override
  @JsonKey(name: 'new_clients')
  final int newClients;
  @override
  @JsonKey(name: 'avg_order_value')
  final double avgOrderValue;
  @override
  @JsonKey(name: 'gross_profit')
  final double grossProfit;
  @override
  @JsonKey(name: 'gross_margin_pct')
  final double grossMarginPct;
  @override
  @JsonKey(name: 'reorder_due_count')
  final int reorderDueCount;
  @override
  @JsonKey(name: 'at_risk_count')
  final int atRiskCount;
  @override
  @JsonKey(name: 'total_b2b_clients')
  final int totalB2bClients;
  @override
  @JsonKey(name: 'pipeline_open_value')
  final double pipelineOpenValue;

  @override
  String toString() {
    return 'B2bSalesSummary(b2bRevenue: $b2bRevenue, b2bOrders: $b2bOrders, activeClients: $activeClients, newClients: $newClients, avgOrderValue: $avgOrderValue, grossProfit: $grossProfit, grossMarginPct: $grossMarginPct, reorderDueCount: $reorderDueCount, atRiskCount: $atRiskCount, totalB2bClients: $totalB2bClients, pipelineOpenValue: $pipelineOpenValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bSalesSummaryImpl &&
            (identical(other.b2bRevenue, b2bRevenue) ||
                other.b2bRevenue == b2bRevenue) &&
            (identical(other.b2bOrders, b2bOrders) ||
                other.b2bOrders == b2bOrders) &&
            (identical(other.activeClients, activeClients) ||
                other.activeClients == activeClients) &&
            (identical(other.newClients, newClients) ||
                other.newClients == newClients) &&
            (identical(other.avgOrderValue, avgOrderValue) ||
                other.avgOrderValue == avgOrderValue) &&
            (identical(other.grossProfit, grossProfit) ||
                other.grossProfit == grossProfit) &&
            (identical(other.grossMarginPct, grossMarginPct) ||
                other.grossMarginPct == grossMarginPct) &&
            (identical(other.reorderDueCount, reorderDueCount) ||
                other.reorderDueCount == reorderDueCount) &&
            (identical(other.atRiskCount, atRiskCount) ||
                other.atRiskCount == atRiskCount) &&
            (identical(other.totalB2bClients, totalB2bClients) ||
                other.totalB2bClients == totalB2bClients) &&
            (identical(other.pipelineOpenValue, pipelineOpenValue) ||
                other.pipelineOpenValue == pipelineOpenValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    b2bRevenue,
    b2bOrders,
    activeClients,
    newClients,
    avgOrderValue,
    grossProfit,
    grossMarginPct,
    reorderDueCount,
    atRiskCount,
    totalB2bClients,
    pipelineOpenValue,
  );

  /// Create a copy of B2bSalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bSalesSummaryImplCopyWith<_$B2bSalesSummaryImpl> get copyWith =>
      __$$B2bSalesSummaryImplCopyWithImpl<_$B2bSalesSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bSalesSummaryImplToJson(this);
  }
}

abstract class _B2bSalesSummary implements B2bSalesSummary {
  const factory _B2bSalesSummary({
    @JsonKey(name: 'b2b_revenue') final double b2bRevenue,
    @JsonKey(name: 'b2b_orders') final int b2bOrders,
    @JsonKey(name: 'active_clients') final int activeClients,
    @JsonKey(name: 'new_clients') final int newClients,
    @JsonKey(name: 'avg_order_value') final double avgOrderValue,
    @JsonKey(name: 'gross_profit') final double grossProfit,
    @JsonKey(name: 'gross_margin_pct') final double grossMarginPct,
    @JsonKey(name: 'reorder_due_count') final int reorderDueCount,
    @JsonKey(name: 'at_risk_count') final int atRiskCount,
    @JsonKey(name: 'total_b2b_clients') final int totalB2bClients,
    @JsonKey(name: 'pipeline_open_value') final double pipelineOpenValue,
  }) = _$B2bSalesSummaryImpl;

  factory _B2bSalesSummary.fromJson(Map<String, dynamic> json) =
      _$B2bSalesSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'b2b_revenue')
  double get b2bRevenue;
  @override
  @JsonKey(name: 'b2b_orders')
  int get b2bOrders;
  @override
  @JsonKey(name: 'active_clients')
  int get activeClients;
  @override
  @JsonKey(name: 'new_clients')
  int get newClients;
  @override
  @JsonKey(name: 'avg_order_value')
  double get avgOrderValue;
  @override
  @JsonKey(name: 'gross_profit')
  double get grossProfit;
  @override
  @JsonKey(name: 'gross_margin_pct')
  double get grossMarginPct;
  @override
  @JsonKey(name: 'reorder_due_count')
  int get reorderDueCount;
  @override
  @JsonKey(name: 'at_risk_count')
  int get atRiskCount;
  @override
  @JsonKey(name: 'total_b2b_clients')
  int get totalB2bClients;
  @override
  @JsonKey(name: 'pipeline_open_value')
  double get pipelineOpenValue;

  /// Create a copy of B2bSalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bSalesSummaryImplCopyWith<_$B2bSalesSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bPipelineStage _$B2bPipelineStageFromJson(Map<String, dynamic> json) {
  return _B2bPipelineStage.fromJson(json);
}

/// @nodoc
mixin _$B2bPipelineStage {
  String get stage => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;

  /// Serializes this B2bPipelineStage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bPipelineStage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bPipelineStageCopyWith<B2bPipelineStage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bPipelineStageCopyWith<$Res> {
  factory $B2bPipelineStageCopyWith(
    B2bPipelineStage value,
    $Res Function(B2bPipelineStage) then,
  ) = _$B2bPipelineStageCopyWithImpl<$Res, B2bPipelineStage>;
  @useResult
  $Res call({String stage, int count, double value});
}

/// @nodoc
class _$B2bPipelineStageCopyWithImpl<$Res, $Val extends B2bPipelineStage>
    implements $B2bPipelineStageCopyWith<$Res> {
  _$B2bPipelineStageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bPipelineStage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? count = null,
    Object? value = null,
  }) {
    return _then(
      _value.copyWith(
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bPipelineStageImplCopyWith<$Res>
    implements $B2bPipelineStageCopyWith<$Res> {
  factory _$$B2bPipelineStageImplCopyWith(
    _$B2bPipelineStageImpl value,
    $Res Function(_$B2bPipelineStageImpl) then,
  ) = __$$B2bPipelineStageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String stage, int count, double value});
}

/// @nodoc
class __$$B2bPipelineStageImplCopyWithImpl<$Res>
    extends _$B2bPipelineStageCopyWithImpl<$Res, _$B2bPipelineStageImpl>
    implements _$$B2bPipelineStageImplCopyWith<$Res> {
  __$$B2bPipelineStageImplCopyWithImpl(
    _$B2bPipelineStageImpl _value,
    $Res Function(_$B2bPipelineStageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bPipelineStage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? count = null,
    Object? value = null,
  }) {
    return _then(
      _$B2bPipelineStageImpl(
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bPipelineStageImpl implements _B2bPipelineStage {
  const _$B2bPipelineStageImpl({
    this.stage = '',
    this.count = 0,
    this.value = 0,
  });

  factory _$B2bPipelineStageImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bPipelineStageImplFromJson(json);

  @override
  @JsonKey()
  final String stage;
  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final double value;

  @override
  String toString() {
    return 'B2bPipelineStage(stage: $stage, count: $count, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bPipelineStageImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stage, count, value);

  /// Create a copy of B2bPipelineStage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bPipelineStageImplCopyWith<_$B2bPipelineStageImpl> get copyWith =>
      __$$B2bPipelineStageImplCopyWithImpl<_$B2bPipelineStageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bPipelineStageImplToJson(this);
  }
}

abstract class _B2bPipelineStage implements B2bPipelineStage {
  const factory _B2bPipelineStage({
    final String stage,
    final int count,
    final double value,
  }) = _$B2bPipelineStageImpl;

  factory _B2bPipelineStage.fromJson(Map<String, dynamic> json) =
      _$B2bPipelineStageImpl.fromJson;

  @override
  String get stage;
  @override
  int get count;
  @override
  double get value;

  /// Create a copy of B2bPipelineStage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bPipelineStageImplCopyWith<_$B2bPipelineStageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bSalesRevenueTrendPoint _$B2bSalesRevenueTrendPointFromJson(
  Map<String, dynamic> json,
) {
  return _B2bSalesRevenueTrendPoint.fromJson(json);
}

/// @nodoc
mixin _$B2bSalesRevenueTrendPoint {
  @JsonKey(name: 'posting_date')
  String get postingDate => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  int get orders => throw _privateConstructorUsedError;

  /// Serializes this B2bSalesRevenueTrendPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bSalesRevenueTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bSalesRevenueTrendPointCopyWith<B2bSalesRevenueTrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bSalesRevenueTrendPointCopyWith<$Res> {
  factory $B2bSalesRevenueTrendPointCopyWith(
    B2bSalesRevenueTrendPoint value,
    $Res Function(B2bSalesRevenueTrendPoint) then,
  ) = _$B2bSalesRevenueTrendPointCopyWithImpl<$Res, B2bSalesRevenueTrendPoint>;
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    double revenue,
    int orders,
  });
}

/// @nodoc
class _$B2bSalesRevenueTrendPointCopyWithImpl<
  $Res,
  $Val extends B2bSalesRevenueTrendPoint
>
    implements $B2bSalesRevenueTrendPointCopyWith<$Res> {
  _$B2bSalesRevenueTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bSalesRevenueTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? revenue = null,
    Object? orders = null,
  }) {
    return _then(
      _value.copyWith(
            postingDate: null == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bSalesRevenueTrendPointImplCopyWith<$Res>
    implements $B2bSalesRevenueTrendPointCopyWith<$Res> {
  factory _$$B2bSalesRevenueTrendPointImplCopyWith(
    _$B2bSalesRevenueTrendPointImpl value,
    $Res Function(_$B2bSalesRevenueTrendPointImpl) then,
  ) = __$$B2bSalesRevenueTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'posting_date') String postingDate,
    double revenue,
    int orders,
  });
}

/// @nodoc
class __$$B2bSalesRevenueTrendPointImplCopyWithImpl<$Res>
    extends
        _$B2bSalesRevenueTrendPointCopyWithImpl<
          $Res,
          _$B2bSalesRevenueTrendPointImpl
        >
    implements _$$B2bSalesRevenueTrendPointImplCopyWith<$Res> {
  __$$B2bSalesRevenueTrendPointImplCopyWithImpl(
    _$B2bSalesRevenueTrendPointImpl _value,
    $Res Function(_$B2bSalesRevenueTrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bSalesRevenueTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postingDate = null,
    Object? revenue = null,
    Object? orders = null,
  }) {
    return _then(
      _$B2bSalesRevenueTrendPointImpl(
        postingDate: null == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        orders: null == orders
            ? _value.orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bSalesRevenueTrendPointImpl implements _B2bSalesRevenueTrendPoint {
  const _$B2bSalesRevenueTrendPointImpl({
    @JsonKey(name: 'posting_date') this.postingDate = '',
    this.revenue = 0,
    this.orders = 0,
  });

  factory _$B2bSalesRevenueTrendPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bSalesRevenueTrendPointImplFromJson(json);

  @override
  @JsonKey(name: 'posting_date')
  final String postingDate;
  @override
  @JsonKey()
  final double revenue;
  @override
  @JsonKey()
  final int orders;

  @override
  String toString() {
    return 'B2bSalesRevenueTrendPoint(postingDate: $postingDate, revenue: $revenue, orders: $orders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bSalesRevenueTrendPointImpl &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.orders, orders) || other.orders == orders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, postingDate, revenue, orders);

  /// Create a copy of B2bSalesRevenueTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bSalesRevenueTrendPointImplCopyWith<_$B2bSalesRevenueTrendPointImpl>
  get copyWith =>
      __$$B2bSalesRevenueTrendPointImplCopyWithImpl<
        _$B2bSalesRevenueTrendPointImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bSalesRevenueTrendPointImplToJson(this);
  }
}

abstract class _B2bSalesRevenueTrendPoint implements B2bSalesRevenueTrendPoint {
  const factory _B2bSalesRevenueTrendPoint({
    @JsonKey(name: 'posting_date') final String postingDate,
    final double revenue,
    final int orders,
  }) = _$B2bSalesRevenueTrendPointImpl;

  factory _B2bSalesRevenueTrendPoint.fromJson(Map<String, dynamic> json) =
      _$B2bSalesRevenueTrendPointImpl.fromJson;

  @override
  @JsonKey(name: 'posting_date')
  String get postingDate;
  @override
  double get revenue;
  @override
  int get orders;

  /// Create a copy of B2bSalesRevenueTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bSalesRevenueTrendPointImplCopyWith<_$B2bSalesRevenueTrendPointImpl>
  get copyWith => throw _privateConstructorUsedError;
}

B2bTopClient _$B2bTopClientFromJson(Map<String, dynamic> json) {
  return _B2bTopClient.fromJson(json);
}

/// @nodoc
mixin _$B2bTopClient {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  int get orders => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_order_date')
  String get lastOrderDate => throw _privateConstructorUsedError;
  String get segment => throw _privateConstructorUsedError;

  /// Serializes this B2bTopClient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bTopClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bTopClientCopyWith<B2bTopClient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bTopClientCopyWith<$Res> {
  factory $B2bTopClientCopyWith(
    B2bTopClient value,
    $Res Function(B2bTopClient) then,
  ) = _$B2bTopClientCopyWithImpl<$Res, B2bTopClient>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    double revenue,
    int orders,
    @JsonKey(name: 'last_order_date') String lastOrderDate,
    String segment,
  });
}

/// @nodoc
class _$B2bTopClientCopyWithImpl<$Res, $Val extends B2bTopClient>
    implements $B2bTopClientCopyWith<$Res> {
  _$B2bTopClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bTopClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? revenue = null,
    Object? orders = null,
    Object? lastOrderDate = null,
    Object? segment = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as int,
            lastOrderDate: null == lastOrderDate
                ? _value.lastOrderDate
                : lastOrderDate // ignore: cast_nullable_to_non_nullable
                      as String,
            segment: null == segment
                ? _value.segment
                : segment // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bTopClientImplCopyWith<$Res>
    implements $B2bTopClientCopyWith<$Res> {
  factory _$$B2bTopClientImplCopyWith(
    _$B2bTopClientImpl value,
    $Res Function(_$B2bTopClientImpl) then,
  ) = __$$B2bTopClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    double revenue,
    int orders,
    @JsonKey(name: 'last_order_date') String lastOrderDate,
    String segment,
  });
}

/// @nodoc
class __$$B2bTopClientImplCopyWithImpl<$Res>
    extends _$B2bTopClientCopyWithImpl<$Res, _$B2bTopClientImpl>
    implements _$$B2bTopClientImplCopyWith<$Res> {
  __$$B2bTopClientImplCopyWithImpl(
    _$B2bTopClientImpl _value,
    $Res Function(_$B2bTopClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bTopClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? revenue = null,
    Object? orders = null,
    Object? lastOrderDate = null,
    Object? segment = null,
  }) {
    return _then(
      _$B2bTopClientImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        orders: null == orders
            ? _value.orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as int,
        lastOrderDate: null == lastOrderDate
            ? _value.lastOrderDate
            : lastOrderDate // ignore: cast_nullable_to_non_nullable
                  as String,
        segment: null == segment
            ? _value.segment
            : segment // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bTopClientImpl implements _B2bTopClient {
  const _$B2bTopClientImpl({
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    this.revenue = 0,
    this.orders = 0,
    @JsonKey(name: 'last_order_date') this.lastOrderDate = '',
    this.segment = '',
  });

  factory _$B2bTopClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bTopClientImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey()
  final double revenue;
  @override
  @JsonKey()
  final int orders;
  @override
  @JsonKey(name: 'last_order_date')
  final String lastOrderDate;
  @override
  @JsonKey()
  final String segment;

  @override
  String toString() {
    return 'B2bTopClient(customer: $customer, customerName: $customerName, revenue: $revenue, orders: $orders, lastOrderDate: $lastOrderDate, segment: $segment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bTopClientImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.orders, orders) || other.orders == orders) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate) &&
            (identical(other.segment, segment) || other.segment == segment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    revenue,
    orders,
    lastOrderDate,
    segment,
  );

  /// Create a copy of B2bTopClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bTopClientImplCopyWith<_$B2bTopClientImpl> get copyWith =>
      __$$B2bTopClientImplCopyWithImpl<_$B2bTopClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bTopClientImplToJson(this);
  }
}

abstract class _B2bTopClient implements B2bTopClient {
  const factory _B2bTopClient({
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    final double revenue,
    final int orders,
    @JsonKey(name: 'last_order_date') final String lastOrderDate,
    final String segment,
  }) = _$B2bTopClientImpl;

  factory _B2bTopClient.fromJson(Map<String, dynamic> json) =
      _$B2bTopClientImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  double get revenue;
  @override
  int get orders;
  @override
  @JsonKey(name: 'last_order_date')
  String get lastOrderDate;
  @override
  String get segment;

  /// Create a copy of B2bTopClient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bTopClientImplCopyWith<_$B2bTopClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bRevenueByPolicy _$B2bRevenueByPolicyFromJson(Map<String, dynamic> json) {
  return _B2bRevenueByPolicy.fromJson(json);
}

/// @nodoc
mixin _$B2bRevenueByPolicy {
  String get policy => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_count')
  int get orderCount => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this B2bRevenueByPolicy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bRevenueByPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bRevenueByPolicyCopyWith<B2bRevenueByPolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bRevenueByPolicyCopyWith<$Res> {
  factory $B2bRevenueByPolicyCopyWith(
    B2bRevenueByPolicy value,
    $Res Function(B2bRevenueByPolicy) then,
  ) = _$B2bRevenueByPolicyCopyWithImpl<$Res, B2bRevenueByPolicy>;
  @useResult
  $Res call({
    String policy,
    @JsonKey(name: 'order_count') int orderCount,
    double revenue,
  });
}

/// @nodoc
class _$B2bRevenueByPolicyCopyWithImpl<$Res, $Val extends B2bRevenueByPolicy>
    implements $B2bRevenueByPolicyCopyWith<$Res> {
  _$B2bRevenueByPolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bRevenueByPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policy = null,
    Object? orderCount = null,
    Object? revenue = null,
  }) {
    return _then(
      _value.copyWith(
            policy: null == policy
                ? _value.policy
                : policy // ignore: cast_nullable_to_non_nullable
                      as String,
            orderCount: null == orderCount
                ? _value.orderCount
                : orderCount // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bRevenueByPolicyImplCopyWith<$Res>
    implements $B2bRevenueByPolicyCopyWith<$Res> {
  factory _$$B2bRevenueByPolicyImplCopyWith(
    _$B2bRevenueByPolicyImpl value,
    $Res Function(_$B2bRevenueByPolicyImpl) then,
  ) = __$$B2bRevenueByPolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String policy,
    @JsonKey(name: 'order_count') int orderCount,
    double revenue,
  });
}

/// @nodoc
class __$$B2bRevenueByPolicyImplCopyWithImpl<$Res>
    extends _$B2bRevenueByPolicyCopyWithImpl<$Res, _$B2bRevenueByPolicyImpl>
    implements _$$B2bRevenueByPolicyImplCopyWith<$Res> {
  __$$B2bRevenueByPolicyImplCopyWithImpl(
    _$B2bRevenueByPolicyImpl _value,
    $Res Function(_$B2bRevenueByPolicyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bRevenueByPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policy = null,
    Object? orderCount = null,
    Object? revenue = null,
  }) {
    return _then(
      _$B2bRevenueByPolicyImpl(
        policy: null == policy
            ? _value.policy
            : policy // ignore: cast_nullable_to_non_nullable
                  as String,
        orderCount: null == orderCount
            ? _value.orderCount
            : orderCount // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bRevenueByPolicyImpl implements _B2bRevenueByPolicy {
  const _$B2bRevenueByPolicyImpl({
    this.policy = '',
    @JsonKey(name: 'order_count') this.orderCount = 0,
    this.revenue = 0,
  });

  factory _$B2bRevenueByPolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bRevenueByPolicyImplFromJson(json);

  @override
  @JsonKey()
  final String policy;
  @override
  @JsonKey(name: 'order_count')
  final int orderCount;
  @override
  @JsonKey()
  final double revenue;

  @override
  String toString() {
    return 'B2bRevenueByPolicy(policy: $policy, orderCount: $orderCount, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bRevenueByPolicyImpl &&
            (identical(other.policy, policy) || other.policy == policy) &&
            (identical(other.orderCount, orderCount) ||
                other.orderCount == orderCount) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, policy, orderCount, revenue);

  /// Create a copy of B2bRevenueByPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bRevenueByPolicyImplCopyWith<_$B2bRevenueByPolicyImpl> get copyWith =>
      __$$B2bRevenueByPolicyImplCopyWithImpl<_$B2bRevenueByPolicyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bRevenueByPolicyImplToJson(this);
  }
}

abstract class _B2bRevenueByPolicy implements B2bRevenueByPolicy {
  const factory _B2bRevenueByPolicy({
    final String policy,
    @JsonKey(name: 'order_count') final int orderCount,
    final double revenue,
  }) = _$B2bRevenueByPolicyImpl;

  factory _B2bRevenueByPolicy.fromJson(Map<String, dynamic> json) =
      _$B2bRevenueByPolicyImpl.fromJson;

  @override
  String get policy;
  @override
  @JsonKey(name: 'order_count')
  int get orderCount;
  @override
  double get revenue;

  /// Create a copy of B2bRevenueByPolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bRevenueByPolicyImplCopyWith<_$B2bRevenueByPolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bRevenueByTerritory _$B2bRevenueByTerritoryFromJson(
  Map<String, dynamic> json,
) {
  return _B2bRevenueByTerritory.fromJson(json);
}

/// @nodoc
mixin _$B2bRevenueByTerritory {
  String get territory => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  int get orders => throw _privateConstructorUsedError;

  /// Serializes this B2bRevenueByTerritory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bRevenueByTerritory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bRevenueByTerritoryCopyWith<B2bRevenueByTerritory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bRevenueByTerritoryCopyWith<$Res> {
  factory $B2bRevenueByTerritoryCopyWith(
    B2bRevenueByTerritory value,
    $Res Function(B2bRevenueByTerritory) then,
  ) = _$B2bRevenueByTerritoryCopyWithImpl<$Res, B2bRevenueByTerritory>;
  @useResult
  $Res call({String territory, double revenue, int orders});
}

/// @nodoc
class _$B2bRevenueByTerritoryCopyWithImpl<
  $Res,
  $Val extends B2bRevenueByTerritory
>
    implements $B2bRevenueByTerritoryCopyWith<$Res> {
  _$B2bRevenueByTerritoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bRevenueByTerritory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? territory = null,
    Object? revenue = null,
    Object? orders = null,
  }) {
    return _then(
      _value.copyWith(
            territory: null == territory
                ? _value.territory
                : territory // ignore: cast_nullable_to_non_nullable
                      as String,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bRevenueByTerritoryImplCopyWith<$Res>
    implements $B2bRevenueByTerritoryCopyWith<$Res> {
  factory _$$B2bRevenueByTerritoryImplCopyWith(
    _$B2bRevenueByTerritoryImpl value,
    $Res Function(_$B2bRevenueByTerritoryImpl) then,
  ) = __$$B2bRevenueByTerritoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String territory, double revenue, int orders});
}

/// @nodoc
class __$$B2bRevenueByTerritoryImplCopyWithImpl<$Res>
    extends
        _$B2bRevenueByTerritoryCopyWithImpl<$Res, _$B2bRevenueByTerritoryImpl>
    implements _$$B2bRevenueByTerritoryImplCopyWith<$Res> {
  __$$B2bRevenueByTerritoryImplCopyWithImpl(
    _$B2bRevenueByTerritoryImpl _value,
    $Res Function(_$B2bRevenueByTerritoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bRevenueByTerritory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? territory = null,
    Object? revenue = null,
    Object? orders = null,
  }) {
    return _then(
      _$B2bRevenueByTerritoryImpl(
        territory: null == territory
            ? _value.territory
            : territory // ignore: cast_nullable_to_non_nullable
                  as String,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        orders: null == orders
            ? _value.orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bRevenueByTerritoryImpl implements _B2bRevenueByTerritory {
  const _$B2bRevenueByTerritoryImpl({
    this.territory = '',
    this.revenue = 0,
    this.orders = 0,
  });

  factory _$B2bRevenueByTerritoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bRevenueByTerritoryImplFromJson(json);

  @override
  @JsonKey()
  final String territory;
  @override
  @JsonKey()
  final double revenue;
  @override
  @JsonKey()
  final int orders;

  @override
  String toString() {
    return 'B2bRevenueByTerritory(territory: $territory, revenue: $revenue, orders: $orders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bRevenueByTerritoryImpl &&
            (identical(other.territory, territory) ||
                other.territory == territory) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.orders, orders) || other.orders == orders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, territory, revenue, orders);

  /// Create a copy of B2bRevenueByTerritory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bRevenueByTerritoryImplCopyWith<_$B2bRevenueByTerritoryImpl>
  get copyWith =>
      __$$B2bRevenueByTerritoryImplCopyWithImpl<_$B2bRevenueByTerritoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bRevenueByTerritoryImplToJson(this);
  }
}

abstract class _B2bRevenueByTerritory implements B2bRevenueByTerritory {
  const factory _B2bRevenueByTerritory({
    final String territory,
    final double revenue,
    final int orders,
  }) = _$B2bRevenueByTerritoryImpl;

  factory _B2bRevenueByTerritory.fromJson(Map<String, dynamic> json) =
      _$B2bRevenueByTerritoryImpl.fromJson;

  @override
  String get territory;
  @override
  double get revenue;
  @override
  int get orders;

  /// Create a copy of B2bRevenueByTerritory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bRevenueByTerritoryImplCopyWith<_$B2bRevenueByTerritoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

B2bClientsByGroup _$B2bClientsByGroupFromJson(Map<String, dynamic> json) {
  return _B2bClientsByGroup.fromJson(json);
}

/// @nodoc
mixin _$B2bClientsByGroup {
  @JsonKey(name: 'customer_group')
  String get customerGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_count')
  int get clientCount => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this B2bClientsByGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bClientsByGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bClientsByGroupCopyWith<B2bClientsByGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bClientsByGroupCopyWith<$Res> {
  factory $B2bClientsByGroupCopyWith(
    B2bClientsByGroup value,
    $Res Function(B2bClientsByGroup) then,
  ) = _$B2bClientsByGroupCopyWithImpl<$Res, B2bClientsByGroup>;
  @useResult
  $Res call({
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'client_count') int clientCount,
    double revenue,
  });
}

/// @nodoc
class _$B2bClientsByGroupCopyWithImpl<$Res, $Val extends B2bClientsByGroup>
    implements $B2bClientsByGroupCopyWith<$Res> {
  _$B2bClientsByGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bClientsByGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerGroup = null,
    Object? clientCount = null,
    Object? revenue = null,
  }) {
    return _then(
      _value.copyWith(
            customerGroup: null == customerGroup
                ? _value.customerGroup
                : customerGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            clientCount: null == clientCount
                ? _value.clientCount
                : clientCount // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bClientsByGroupImplCopyWith<$Res>
    implements $B2bClientsByGroupCopyWith<$Res> {
  factory _$$B2bClientsByGroupImplCopyWith(
    _$B2bClientsByGroupImpl value,
    $Res Function(_$B2bClientsByGroupImpl) then,
  ) = __$$B2bClientsByGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'customer_group') String customerGroup,
    @JsonKey(name: 'client_count') int clientCount,
    double revenue,
  });
}

/// @nodoc
class __$$B2bClientsByGroupImplCopyWithImpl<$Res>
    extends _$B2bClientsByGroupCopyWithImpl<$Res, _$B2bClientsByGroupImpl>
    implements _$$B2bClientsByGroupImplCopyWith<$Res> {
  __$$B2bClientsByGroupImplCopyWithImpl(
    _$B2bClientsByGroupImpl _value,
    $Res Function(_$B2bClientsByGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bClientsByGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerGroup = null,
    Object? clientCount = null,
    Object? revenue = null,
  }) {
    return _then(
      _$B2bClientsByGroupImpl(
        customerGroup: null == customerGroup
            ? _value.customerGroup
            : customerGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        clientCount: null == clientCount
            ? _value.clientCount
            : clientCount // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bClientsByGroupImpl implements _B2bClientsByGroup {
  const _$B2bClientsByGroupImpl({
    @JsonKey(name: 'customer_group') this.customerGroup = '',
    @JsonKey(name: 'client_count') this.clientCount = 0,
    this.revenue = 0,
  });

  factory _$B2bClientsByGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bClientsByGroupImplFromJson(json);

  @override
  @JsonKey(name: 'customer_group')
  final String customerGroup;
  @override
  @JsonKey(name: 'client_count')
  final int clientCount;
  @override
  @JsonKey()
  final double revenue;

  @override
  String toString() {
    return 'B2bClientsByGroup(customerGroup: $customerGroup, clientCount: $clientCount, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bClientsByGroupImpl &&
            (identical(other.customerGroup, customerGroup) ||
                other.customerGroup == customerGroup) &&
            (identical(other.clientCount, clientCount) ||
                other.clientCount == clientCount) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customerGroup, clientCount, revenue);

  /// Create a copy of B2bClientsByGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bClientsByGroupImplCopyWith<_$B2bClientsByGroupImpl> get copyWith =>
      __$$B2bClientsByGroupImplCopyWithImpl<_$B2bClientsByGroupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bClientsByGroupImplToJson(this);
  }
}

abstract class _B2bClientsByGroup implements B2bClientsByGroup {
  const factory _B2bClientsByGroup({
    @JsonKey(name: 'customer_group') final String customerGroup,
    @JsonKey(name: 'client_count') final int clientCount,
    final double revenue,
  }) = _$B2bClientsByGroupImpl;

  factory _B2bClientsByGroup.fromJson(Map<String, dynamic> json) =
      _$B2bClientsByGroupImpl.fromJson;

  @override
  @JsonKey(name: 'customer_group')
  String get customerGroup;
  @override
  @JsonKey(name: 'client_count')
  int get clientCount;
  @override
  double get revenue;

  /// Create a copy of B2bClientsByGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bClientsByGroupImplCopyWith<_$B2bClientsByGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bReorderDueClient _$B2bReorderDueClientFromJson(Map<String, dynamic> json) {
  return _B2bReorderDueClient.fromJson(json);
}

/// @nodoc
mixin _$B2bReorderDueClient {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_order_date')
  String get lastOrderDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_since')
  int get daysSince => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_reorder_date')
  String get expectedReorderDate => throw _privateConstructorUsedError;

  /// Serializes this B2bReorderDueClient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bReorderDueClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bReorderDueClientCopyWith<B2bReorderDueClient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bReorderDueClientCopyWith<$Res> {
  factory $B2bReorderDueClientCopyWith(
    B2bReorderDueClient value,
    $Res Function(B2bReorderDueClient) then,
  ) = _$B2bReorderDueClientCopyWithImpl<$Res, B2bReorderDueClient>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'last_order_date') String lastOrderDate,
    @JsonKey(name: 'days_since') int daysSince,
    @JsonKey(name: 'expected_reorder_date') String expectedReorderDate,
  });
}

/// @nodoc
class _$B2bReorderDueClientCopyWithImpl<$Res, $Val extends B2bReorderDueClient>
    implements $B2bReorderDueClientCopyWith<$Res> {
  _$B2bReorderDueClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bReorderDueClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? lastOrderDate = null,
    Object? daysSince = null,
    Object? expectedReorderDate = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastOrderDate: null == lastOrderDate
                ? _value.lastOrderDate
                : lastOrderDate // ignore: cast_nullable_to_non_nullable
                      as String,
            daysSince: null == daysSince
                ? _value.daysSince
                : daysSince // ignore: cast_nullable_to_non_nullable
                      as int,
            expectedReorderDate: null == expectedReorderDate
                ? _value.expectedReorderDate
                : expectedReorderDate // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bReorderDueClientImplCopyWith<$Res>
    implements $B2bReorderDueClientCopyWith<$Res> {
  factory _$$B2bReorderDueClientImplCopyWith(
    _$B2bReorderDueClientImpl value,
    $Res Function(_$B2bReorderDueClientImpl) then,
  ) = __$$B2bReorderDueClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'last_order_date') String lastOrderDate,
    @JsonKey(name: 'days_since') int daysSince,
    @JsonKey(name: 'expected_reorder_date') String expectedReorderDate,
  });
}

/// @nodoc
class __$$B2bReorderDueClientImplCopyWithImpl<$Res>
    extends _$B2bReorderDueClientCopyWithImpl<$Res, _$B2bReorderDueClientImpl>
    implements _$$B2bReorderDueClientImplCopyWith<$Res> {
  __$$B2bReorderDueClientImplCopyWithImpl(
    _$B2bReorderDueClientImpl _value,
    $Res Function(_$B2bReorderDueClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bReorderDueClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? lastOrderDate = null,
    Object? daysSince = null,
    Object? expectedReorderDate = null,
  }) {
    return _then(
      _$B2bReorderDueClientImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastOrderDate: null == lastOrderDate
            ? _value.lastOrderDate
            : lastOrderDate // ignore: cast_nullable_to_non_nullable
                  as String,
        daysSince: null == daysSince
            ? _value.daysSince
            : daysSince // ignore: cast_nullable_to_non_nullable
                  as int,
        expectedReorderDate: null == expectedReorderDate
            ? _value.expectedReorderDate
            : expectedReorderDate // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bReorderDueClientImpl implements _B2bReorderDueClient {
  const _$B2bReorderDueClientImpl({
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'last_order_date') this.lastOrderDate = '',
    @JsonKey(name: 'days_since') this.daysSince = 0,
    @JsonKey(name: 'expected_reorder_date') this.expectedReorderDate = '',
  });

  factory _$B2bReorderDueClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bReorderDueClientImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'last_order_date')
  final String lastOrderDate;
  @override
  @JsonKey(name: 'days_since')
  final int daysSince;
  @override
  @JsonKey(name: 'expected_reorder_date')
  final String expectedReorderDate;

  @override
  String toString() {
    return 'B2bReorderDueClient(customer: $customer, customerName: $customerName, lastOrderDate: $lastOrderDate, daysSince: $daysSince, expectedReorderDate: $expectedReorderDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bReorderDueClientImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate) &&
            (identical(other.daysSince, daysSince) ||
                other.daysSince == daysSince) &&
            (identical(other.expectedReorderDate, expectedReorderDate) ||
                other.expectedReorderDate == expectedReorderDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    lastOrderDate,
    daysSince,
    expectedReorderDate,
  );

  /// Create a copy of B2bReorderDueClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bReorderDueClientImplCopyWith<_$B2bReorderDueClientImpl> get copyWith =>
      __$$B2bReorderDueClientImplCopyWithImpl<_$B2bReorderDueClientImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bReorderDueClientImplToJson(this);
  }
}

abstract class _B2bReorderDueClient implements B2bReorderDueClient {
  const factory _B2bReorderDueClient({
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'last_order_date') final String lastOrderDate,
    @JsonKey(name: 'days_since') final int daysSince,
    @JsonKey(name: 'expected_reorder_date') final String expectedReorderDate,
  }) = _$B2bReorderDueClientImpl;

  factory _B2bReorderDueClient.fromJson(Map<String, dynamic> json) =
      _$B2bReorderDueClientImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'last_order_date')
  String get lastOrderDate;
  @override
  @JsonKey(name: 'days_since')
  int get daysSince;
  @override
  @JsonKey(name: 'expected_reorder_date')
  String get expectedReorderDate;

  /// Create a copy of B2bReorderDueClient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bReorderDueClientImplCopyWith<_$B2bReorderDueClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bAtRiskClient _$B2bAtRiskClientFromJson(Map<String, dynamic> json) {
  return _B2bAtRiskClient.fromJson(json);
}

/// @nodoc
mixin _$B2bAtRiskClient {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  String get segment => throw _privateConstructorUsedError;
  @JsonKey(name: 'recency_days')
  int get recencyDays => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this B2bAtRiskClient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bAtRiskClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bAtRiskClientCopyWith<B2bAtRiskClient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bAtRiskClientCopyWith<$Res> {
  factory $B2bAtRiskClientCopyWith(
    B2bAtRiskClient value,
    $Res Function(B2bAtRiskClient) then,
  ) = _$B2bAtRiskClientCopyWithImpl<$Res, B2bAtRiskClient>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    String segment,
    @JsonKey(name: 'recency_days') int recencyDays,
    double revenue,
  });
}

/// @nodoc
class _$B2bAtRiskClientCopyWithImpl<$Res, $Val extends B2bAtRiskClient>
    implements $B2bAtRiskClientCopyWith<$Res> {
  _$B2bAtRiskClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bAtRiskClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? segment = null,
    Object? recencyDays = null,
    Object? revenue = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            segment: null == segment
                ? _value.segment
                : segment // ignore: cast_nullable_to_non_nullable
                      as String,
            recencyDays: null == recencyDays
                ? _value.recencyDays
                : recencyDays // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bAtRiskClientImplCopyWith<$Res>
    implements $B2bAtRiskClientCopyWith<$Res> {
  factory _$$B2bAtRiskClientImplCopyWith(
    _$B2bAtRiskClientImpl value,
    $Res Function(_$B2bAtRiskClientImpl) then,
  ) = __$$B2bAtRiskClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    String segment,
    @JsonKey(name: 'recency_days') int recencyDays,
    double revenue,
  });
}

/// @nodoc
class __$$B2bAtRiskClientImplCopyWithImpl<$Res>
    extends _$B2bAtRiskClientCopyWithImpl<$Res, _$B2bAtRiskClientImpl>
    implements _$$B2bAtRiskClientImplCopyWith<$Res> {
  __$$B2bAtRiskClientImplCopyWithImpl(
    _$B2bAtRiskClientImpl _value,
    $Res Function(_$B2bAtRiskClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bAtRiskClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? segment = null,
    Object? recencyDays = null,
    Object? revenue = null,
  }) {
    return _then(
      _$B2bAtRiskClientImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        segment: null == segment
            ? _value.segment
            : segment // ignore: cast_nullable_to_non_nullable
                  as String,
        recencyDays: null == recencyDays
            ? _value.recencyDays
            : recencyDays // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bAtRiskClientImpl implements _B2bAtRiskClient {
  const _$B2bAtRiskClientImpl({
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    this.segment = '',
    @JsonKey(name: 'recency_days') this.recencyDays = 0,
    this.revenue = 0,
  });

  factory _$B2bAtRiskClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bAtRiskClientImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey()
  final String segment;
  @override
  @JsonKey(name: 'recency_days')
  final int recencyDays;
  @override
  @JsonKey()
  final double revenue;

  @override
  String toString() {
    return 'B2bAtRiskClient(customer: $customer, customerName: $customerName, segment: $segment, recencyDays: $recencyDays, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bAtRiskClientImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.segment, segment) || other.segment == segment) &&
            (identical(other.recencyDays, recencyDays) ||
                other.recencyDays == recencyDays) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    segment,
    recencyDays,
    revenue,
  );

  /// Create a copy of B2bAtRiskClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bAtRiskClientImplCopyWith<_$B2bAtRiskClientImpl> get copyWith =>
      __$$B2bAtRiskClientImplCopyWithImpl<_$B2bAtRiskClientImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bAtRiskClientImplToJson(this);
  }
}

abstract class _B2bAtRiskClient implements B2bAtRiskClient {
  const factory _B2bAtRiskClient({
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    final String segment,
    @JsonKey(name: 'recency_days') final int recencyDays,
    final double revenue,
  }) = _$B2bAtRiskClientImpl;

  factory _B2bAtRiskClient.fromJson(Map<String, dynamic> json) =
      _$B2bAtRiskClientImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  String get segment;
  @override
  @JsonKey(name: 'recency_days')
  int get recencyDays;
  @override
  double get revenue;

  /// Create a copy of B2bAtRiskClient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bAtRiskClientImplCopyWith<_$B2bAtRiskClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bConversion _$B2bConversionFromJson(Map<String, dynamic> json) {
  return _B2bConversion.fromJson(json);
}

/// @nodoc
mixin _$B2bConversion {
  int get opportunities => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  @JsonKey(name: 'conversion_rate')
  double get conversionRate => throw _privateConstructorUsedError;

  /// Serializes this B2bConversion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bConversion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bConversionCopyWith<B2bConversion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bConversionCopyWith<$Res> {
  factory $B2bConversionCopyWith(
    B2bConversion value,
    $Res Function(B2bConversion) then,
  ) = _$B2bConversionCopyWithImpl<$Res, B2bConversion>;
  @useResult
  $Res call({
    int opportunities,
    int won,
    @JsonKey(name: 'conversion_rate') double conversionRate,
  });
}

/// @nodoc
class _$B2bConversionCopyWithImpl<$Res, $Val extends B2bConversion>
    implements $B2bConversionCopyWith<$Res> {
  _$B2bConversionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bConversion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opportunities = null,
    Object? won = null,
    Object? conversionRate = null,
  }) {
    return _then(
      _value.copyWith(
            opportunities: null == opportunities
                ? _value.opportunities
                : opportunities // ignore: cast_nullable_to_non_nullable
                      as int,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as int,
            conversionRate: null == conversionRate
                ? _value.conversionRate
                : conversionRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bConversionImplCopyWith<$Res>
    implements $B2bConversionCopyWith<$Res> {
  factory _$$B2bConversionImplCopyWith(
    _$B2bConversionImpl value,
    $Res Function(_$B2bConversionImpl) then,
  ) = __$$B2bConversionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int opportunities,
    int won,
    @JsonKey(name: 'conversion_rate') double conversionRate,
  });
}

/// @nodoc
class __$$B2bConversionImplCopyWithImpl<$Res>
    extends _$B2bConversionCopyWithImpl<$Res, _$B2bConversionImpl>
    implements _$$B2bConversionImplCopyWith<$Res> {
  __$$B2bConversionImplCopyWithImpl(
    _$B2bConversionImpl _value,
    $Res Function(_$B2bConversionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bConversion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opportunities = null,
    Object? won = null,
    Object? conversionRate = null,
  }) {
    return _then(
      _$B2bConversionImpl(
        opportunities: null == opportunities
            ? _value.opportunities
            : opportunities // ignore: cast_nullable_to_non_nullable
                  as int,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as int,
        conversionRate: null == conversionRate
            ? _value.conversionRate
            : conversionRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bConversionImpl implements _B2bConversion {
  const _$B2bConversionImpl({
    this.opportunities = 0,
    this.won = 0,
    @JsonKey(name: 'conversion_rate') this.conversionRate = 0,
  });

  factory _$B2bConversionImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bConversionImplFromJson(json);

  @override
  @JsonKey()
  final int opportunities;
  @override
  @JsonKey()
  final int won;
  @override
  @JsonKey(name: 'conversion_rate')
  final double conversionRate;

  @override
  String toString() {
    return 'B2bConversion(opportunities: $opportunities, won: $won, conversionRate: $conversionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bConversionImpl &&
            (identical(other.opportunities, opportunities) ||
                other.opportunities == opportunities) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, opportunities, won, conversionRate);

  /// Create a copy of B2bConversion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bConversionImplCopyWith<_$B2bConversionImpl> get copyWith =>
      __$$B2bConversionImplCopyWithImpl<_$B2bConversionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bConversionImplToJson(this);
  }
}

abstract class _B2bConversion implements B2bConversion {
  const factory _B2bConversion({
    final int opportunities,
    final int won,
    @JsonKey(name: 'conversion_rate') final double conversionRate,
  }) = _$B2bConversionImpl;

  factory _B2bConversion.fromJson(Map<String, dynamic> json) =
      _$B2bConversionImpl.fromJson;

  @override
  int get opportunities;
  @override
  int get won;
  @override
  @JsonKey(name: 'conversion_rate')
  double get conversionRate;

  /// Create a copy of B2bConversion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bConversionImplCopyWith<_$B2bConversionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bSalesAlert _$B2bSalesAlertFromJson(Map<String, dynamic> json) {
  return _B2bSalesAlert.fromJson(json);
}

/// @nodoc
mixin _$B2bSalesAlert {
  String get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this B2bSalesAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bSalesAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bSalesAlertCopyWith<B2bSalesAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bSalesAlertCopyWith<$Res> {
  factory $B2bSalesAlertCopyWith(
    B2bSalesAlert value,
    $Res Function(B2bSalesAlert) then,
  ) = _$B2bSalesAlertCopyWithImpl<$Res, B2bSalesAlert>;
  @useResult
  $Res call({String type, String message});
}

/// @nodoc
class _$B2bSalesAlertCopyWithImpl<$Res, $Val extends B2bSalesAlert>
    implements $B2bSalesAlertCopyWith<$Res> {
  _$B2bSalesAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bSalesAlert
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
abstract class _$$B2bSalesAlertImplCopyWith<$Res>
    implements $B2bSalesAlertCopyWith<$Res> {
  factory _$$B2bSalesAlertImplCopyWith(
    _$B2bSalesAlertImpl value,
    $Res Function(_$B2bSalesAlertImpl) then,
  ) = __$$B2bSalesAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String message});
}

/// @nodoc
class __$$B2bSalesAlertImplCopyWithImpl<$Res>
    extends _$B2bSalesAlertCopyWithImpl<$Res, _$B2bSalesAlertImpl>
    implements _$$B2bSalesAlertImplCopyWith<$Res> {
  __$$B2bSalesAlertImplCopyWithImpl(
    _$B2bSalesAlertImpl _value,
    $Res Function(_$B2bSalesAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bSalesAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? message = null}) {
    return _then(
      _$B2bSalesAlertImpl(
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
class _$B2bSalesAlertImpl implements _B2bSalesAlert {
  const _$B2bSalesAlertImpl({this.type = 'info', this.message = ''});

  factory _$B2bSalesAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bSalesAlertImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'B2bSalesAlert(type: $type, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bSalesAlertImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, message);

  /// Create a copy of B2bSalesAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bSalesAlertImplCopyWith<_$B2bSalesAlertImpl> get copyWith =>
      __$$B2bSalesAlertImplCopyWithImpl<_$B2bSalesAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bSalesAlertImplToJson(this);
  }
}

abstract class _B2bSalesAlert implements B2bSalesAlert {
  const factory _B2bSalesAlert({final String type, final String message}) =
      _$B2bSalesAlertImpl;

  factory _B2bSalesAlert.fromJson(Map<String, dynamic> json) =
      _$B2bSalesAlertImpl.fromJson;

  @override
  String get type;
  @override
  String get message;

  /// Create a copy of B2bSalesAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bSalesAlertImplCopyWith<_$B2bSalesAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
