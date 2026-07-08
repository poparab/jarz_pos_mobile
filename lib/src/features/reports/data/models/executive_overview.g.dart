// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'executive_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExecutiveOverviewImpl _$$ExecutiveOverviewImplFromJson(
  Map<String, dynamic> json,
) => _$ExecutiveOverviewImpl(
  period: json['period'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  kpis: json['kpis'] == null
      ? const ExecutiveKpis()
      : ExecutiveKpis.fromJson(json['kpis'] as Map<String, dynamic>),
  revenueTrend:
      (json['revenue_trend'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  productMix:
      (json['product_mix'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  segmentMix:
      (json['segment_mix'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  topTerritories:
      (json['top_territories'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$ExecutiveOverviewImplToJson(
  _$ExecutiveOverviewImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'kpis': instance.kpis,
  'revenue_trend': instance.revenueTrend,
  'product_mix': instance.productMix,
  'segment_mix': instance.segmentMix,
  'top_territories': instance.topTerritories,
  'alerts': instance.alerts,
};

_$ExecutiveKpisImpl _$$ExecutiveKpisImplFromJson(Map<String, dynamic> json) =>
    _$ExecutiveKpisImpl(
      revenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      orders: (json['total_orders'] as num?)?.toInt() ?? 0,
      grossProfit: (json['gross_profit'] as num?)?.toDouble() ?? 0,
      grossMarginPct: (json['gross_margin'] as num?)?.toDouble() ?? 0,
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
      netShippingPl: (json['net_shipping_pl'] as num?)?.toDouble() ?? 0,
      customers: (json['total_customers'] as num?)?.toInt() ?? 0,
      criticalStock: (json['critical_stock'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ExecutiveKpisImplToJson(_$ExecutiveKpisImpl instance) =>
    <String, dynamic>{
      'total_revenue': instance.revenue,
      'total_orders': instance.orders,
      'gross_profit': instance.grossProfit,
      'gross_margin': instance.grossMarginPct,
      'avg_order_value': instance.avgOrderValue,
      'net_shipping_pl': instance.netShippingPl,
      'total_customers': instance.customers,
      'critical_stock': instance.criticalStock,
    };
