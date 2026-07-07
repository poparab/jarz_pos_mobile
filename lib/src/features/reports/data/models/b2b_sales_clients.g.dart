// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b2b_sales_clients.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$B2bSalesAnalyticsImpl _$$B2bSalesAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$B2bSalesAnalyticsImpl(
  period: json['period'] == null
      ? const B2bSalesPeriod()
      : B2bSalesPeriod.fromJson(json['period'] as Map<String, dynamic>),
  summary: json['summary'] == null
      ? const B2bSalesSummary()
      : B2bSalesSummary.fromJson(json['summary'] as Map<String, dynamic>),
  pipelineByStage:
      (json['pipeline_by_stage'] as List<dynamic>?)
          ?.map((e) => B2bPipelineStage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bPipelineStage>[],
  revenueTrend:
      (json['revenue_trend'] as List<dynamic>?)
          ?.map(
            (e) =>
                B2bSalesRevenueTrendPoint.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <B2bSalesRevenueTrendPoint>[],
  topClients:
      (json['top_clients'] as List<dynamic>?)
          ?.map((e) => B2bTopClient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bTopClient>[],
  revenueByPolicy:
      (json['revenue_by_policy'] as List<dynamic>?)
          ?.map((e) => B2bRevenueByPolicy.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bRevenueByPolicy>[],
  revenueByTerritory:
      (json['revenue_by_territory'] as List<dynamic>?)
          ?.map(
            (e) => B2bRevenueByTerritory.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <B2bRevenueByTerritory>[],
  clientsByGroup:
      (json['clients_by_group'] as List<dynamic>?)
          ?.map((e) => B2bClientsByGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bClientsByGroup>[],
  reorderDue:
      (json['reorder_due'] as List<dynamic>?)
          ?.map((e) => B2bReorderDueClient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bReorderDueClient>[],
  atRiskClients:
      (json['at_risk_clients'] as List<dynamic>?)
          ?.map((e) => B2bAtRiskClient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bAtRiskClient>[],
  conversion: json['conversion'] == null
      ? const B2bConversion()
      : B2bConversion.fromJson(json['conversion'] as Map<String, dynamic>),
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => B2bSalesAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bSalesAlert>[],
);

Map<String, dynamic> _$$B2bSalesAnalyticsImplToJson(
  _$B2bSalesAnalyticsImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'summary': instance.summary,
  'pipeline_by_stage': instance.pipelineByStage,
  'revenue_trend': instance.revenueTrend,
  'top_clients': instance.topClients,
  'revenue_by_policy': instance.revenueByPolicy,
  'revenue_by_territory': instance.revenueByTerritory,
  'clients_by_group': instance.clientsByGroup,
  'reorder_due': instance.reorderDue,
  'at_risk_clients': instance.atRiskClients,
  'conversion': instance.conversion,
  'alerts': instance.alerts,
};

_$B2bSalesPeriodImpl _$$B2bSalesPeriodImplFromJson(Map<String, dynamic> json) =>
    _$B2bSalesPeriodImpl(
      dateFrom: json['date_from'] as String? ?? '',
      dateTo: json['date_to'] as String? ?? '',
    );

Map<String, dynamic> _$$B2bSalesPeriodImplToJson(
  _$B2bSalesPeriodImpl instance,
) => <String, dynamic>{
  'date_from': instance.dateFrom,
  'date_to': instance.dateTo,
};

_$B2bSalesSummaryImpl _$$B2bSalesSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$B2bSalesSummaryImpl(
  b2bRevenue: (json['b2b_revenue'] as num?)?.toDouble() ?? 0,
  b2bOrders: (json['b2b_orders'] as num?)?.toInt() ?? 0,
  activeClients: (json['active_clients'] as num?)?.toInt() ?? 0,
  newClients: (json['new_clients'] as num?)?.toInt() ?? 0,
  avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
  grossProfit: (json['gross_profit'] as num?)?.toDouble() ?? 0,
  grossMarginPct: (json['gross_margin_pct'] as num?)?.toDouble() ?? 0,
  reorderDueCount: (json['reorder_due_count'] as num?)?.toInt() ?? 0,
  atRiskCount: (json['at_risk_count'] as num?)?.toInt() ?? 0,
  totalB2bClients: (json['total_b2b_clients'] as num?)?.toInt() ?? 0,
  pipelineOpenValue: (json['pipeline_open_value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$B2bSalesSummaryImplToJson(
  _$B2bSalesSummaryImpl instance,
) => <String, dynamic>{
  'b2b_revenue': instance.b2bRevenue,
  'b2b_orders': instance.b2bOrders,
  'active_clients': instance.activeClients,
  'new_clients': instance.newClients,
  'avg_order_value': instance.avgOrderValue,
  'gross_profit': instance.grossProfit,
  'gross_margin_pct': instance.grossMarginPct,
  'reorder_due_count': instance.reorderDueCount,
  'at_risk_count': instance.atRiskCount,
  'total_b2b_clients': instance.totalB2bClients,
  'pipeline_open_value': instance.pipelineOpenValue,
};

_$B2bPipelineStageImpl _$$B2bPipelineStageImplFromJson(
  Map<String, dynamic> json,
) => _$B2bPipelineStageImpl(
  stage: json['stage'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
  value: (json['value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$B2bPipelineStageImplToJson(
  _$B2bPipelineStageImpl instance,
) => <String, dynamic>{
  'stage': instance.stage,
  'count': instance.count,
  'value': instance.value,
};

_$B2bSalesRevenueTrendPointImpl _$$B2bSalesRevenueTrendPointImplFromJson(
  Map<String, dynamic> json,
) => _$B2bSalesRevenueTrendPointImpl(
  postingDate: json['posting_date'] as String? ?? '',
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
  orders: (json['orders'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$B2bSalesRevenueTrendPointImplToJson(
  _$B2bSalesRevenueTrendPointImpl instance,
) => <String, dynamic>{
  'posting_date': instance.postingDate,
  'revenue': instance.revenue,
  'orders': instance.orders,
};

_$B2bTopClientImpl _$$B2bTopClientImplFromJson(Map<String, dynamic> json) =>
    _$B2bTopClientImpl(
      customer: json['customer'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      lastOrderDate: json['last_order_date'] as String? ?? '',
      segment: json['segment'] as String? ?? '',
    );

Map<String, dynamic> _$$B2bTopClientImplToJson(_$B2bTopClientImpl instance) =>
    <String, dynamic>{
      'customer': instance.customer,
      'customer_name': instance.customerName,
      'revenue': instance.revenue,
      'orders': instance.orders,
      'last_order_date': instance.lastOrderDate,
      'segment': instance.segment,
    };

_$B2bRevenueByPolicyImpl _$$B2bRevenueByPolicyImplFromJson(
  Map<String, dynamic> json,
) => _$B2bRevenueByPolicyImpl(
  policy: json['policy'] as String? ?? '',
  orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$B2bRevenueByPolicyImplToJson(
  _$B2bRevenueByPolicyImpl instance,
) => <String, dynamic>{
  'policy': instance.policy,
  'order_count': instance.orderCount,
  'revenue': instance.revenue,
};

_$B2bRevenueByTerritoryImpl _$$B2bRevenueByTerritoryImplFromJson(
  Map<String, dynamic> json,
) => _$B2bRevenueByTerritoryImpl(
  territory: json['territory'] as String? ?? '',
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
  orders: (json['orders'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$B2bRevenueByTerritoryImplToJson(
  _$B2bRevenueByTerritoryImpl instance,
) => <String, dynamic>{
  'territory': instance.territory,
  'revenue': instance.revenue,
  'orders': instance.orders,
};

_$B2bClientsByGroupImpl _$$B2bClientsByGroupImplFromJson(
  Map<String, dynamic> json,
) => _$B2bClientsByGroupImpl(
  customerGroup: json['customer_group'] as String? ?? '',
  clientCount: (json['client_count'] as num?)?.toInt() ?? 0,
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$B2bClientsByGroupImplToJson(
  _$B2bClientsByGroupImpl instance,
) => <String, dynamic>{
  'customer_group': instance.customerGroup,
  'client_count': instance.clientCount,
  'revenue': instance.revenue,
};

_$B2bReorderDueClientImpl _$$B2bReorderDueClientImplFromJson(
  Map<String, dynamic> json,
) => _$B2bReorderDueClientImpl(
  customer: json['customer'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
  lastOrderDate: json['last_order_date'] as String? ?? '',
  daysSince: (json['days_since'] as num?)?.toInt() ?? 0,
  expectedReorderDate: json['expected_reorder_date'] as String? ?? '',
);

Map<String, dynamic> _$$B2bReorderDueClientImplToJson(
  _$B2bReorderDueClientImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'last_order_date': instance.lastOrderDate,
  'days_since': instance.daysSince,
  'expected_reorder_date': instance.expectedReorderDate,
};

_$B2bAtRiskClientImpl _$$B2bAtRiskClientImplFromJson(
  Map<String, dynamic> json,
) => _$B2bAtRiskClientImpl(
  customer: json['customer'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
  segment: json['segment'] as String? ?? '',
  recencyDays: (json['recency_days'] as num?)?.toInt() ?? 0,
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$B2bAtRiskClientImplToJson(
  _$B2bAtRiskClientImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'segment': instance.segment,
  'recency_days': instance.recencyDays,
  'revenue': instance.revenue,
};

_$B2bConversionImpl _$$B2bConversionImplFromJson(Map<String, dynamic> json) =>
    _$B2bConversionImpl(
      opportunities: (json['opportunities'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$B2bConversionImplToJson(_$B2bConversionImpl instance) =>
    <String, dynamic>{
      'opportunities': instance.opportunities,
      'won': instance.won,
      'conversion_rate': instance.conversionRate,
    };

_$B2bSalesAlertImpl _$$B2bSalesAlertImplFromJson(Map<String, dynamic> json) =>
    _$B2bSalesAlertImpl(
      type: json['type'] as String? ?? 'info',
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$$B2bSalesAlertImplToJson(_$B2bSalesAlertImpl instance) =>
    <String, dynamic>{'type': instance.type, 'message': instance.message};
