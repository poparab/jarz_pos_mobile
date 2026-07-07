// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerAnalyticsImpl _$$CustomerAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerAnalyticsImpl(
  period: json['period'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  summary: json['summary'] == null
      ? const CustomerAnalyticsSummary()
      : CustomerAnalyticsSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  segmentDistribution:
      (json['segment_distribution'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  segmentTable:
      (json['segment_table'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  topCustomers:
      (json['top_customers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  atRiskCustomers:
      (json['at_risk_customers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  acquisitionTrend:
      (json['acquisition_trend'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$CustomerAnalyticsImplToJson(
  _$CustomerAnalyticsImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'summary': instance.summary,
  'segment_distribution': instance.segmentDistribution,
  'segment_table': instance.segmentTable,
  'top_customers': instance.topCustomers,
  'at_risk_customers': instance.atRiskCustomers,
  'acquisition_trend': instance.acquisitionTrend,
};

_$CustomerAnalyticsSummaryImpl _$$CustomerAnalyticsSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerAnalyticsSummaryImpl(
  totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
  activeInPeriod: (json['active_in_period'] as num?)?.toInt() ?? 0,
  newCustomers: (json['new_customers'] as num?)?.toInt() ?? 0,
  returningCustomers: (json['returning_customers'] as num?)?.toInt() ?? 0,
  repeatRate: (json['repeat_rate'] as num?)?.toDouble() ?? 0,
  champions: (json['champions'] as num?)?.toInt() ?? 0,
  atRisk: (json['at_risk'] as num?)?.toInt() ?? 0,
  lost: (json['lost'] as num?)?.toInt() ?? 0,
  periodRevenue: (json['period_revenue'] as num?)?.toDouble() ?? 0,
  periodOrders: (json['period_orders'] as num?)?.toInt() ?? 0,
  avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$CustomerAnalyticsSummaryImplToJson(
  _$CustomerAnalyticsSummaryImpl instance,
) => <String, dynamic>{
  'total_customers': instance.totalCustomers,
  'active_in_period': instance.activeInPeriod,
  'new_customers': instance.newCustomers,
  'returning_customers': instance.returningCustomers,
  'repeat_rate': instance.repeatRate,
  'champions': instance.champions,
  'at_risk': instance.atRisk,
  'lost': instance.lost,
  'period_revenue': instance.periodRevenue,
  'period_orders': instance.periodOrders,
  'avg_order_value': instance.avgOrderValue,
};
