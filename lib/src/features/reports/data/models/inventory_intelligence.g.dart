// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_intelligence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryIntelligenceImpl _$$InventoryIntelligenceImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryIntelligenceImpl(
  period: json['period'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  summary: json['summary'] == null
      ? const InventorySummary()
      : InventorySummary.fromJson(json['summary'] as Map<String, dynamic>),
  alerts: json['alerts'] == null
      ? const InventoryAlerts()
      : InventoryAlerts.fromJson(json['alerts'] as Map<String, dynamic>),
  velocityDistribution:
      (json['velocity_distribution'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  topMovers:
      (json['top_movers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  topSoldInRange:
      (json['top_sold_in_range'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$InventoryIntelligenceImplToJson(
  _$InventoryIntelligenceImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'summary': instance.summary,
  'alerts': instance.alerts,
  'velocity_distribution': instance.velocityDistribution,
  'top_movers': instance.topMovers,
  'top_sold_in_range': instance.topSoldInRange,
};

_$InventorySummaryImpl _$$InventorySummaryImplFromJson(
  Map<String, dynamic> json,
) => _$InventorySummaryImpl(
  totalStockItems: (json['total_stock_items'] as num?)?.toInt() ?? 0,
  criticalCount: (json['critical_count'] as num?)?.toInt() ?? 0,
  watchCount: (json['watch_count'] as num?)?.toInt() ?? 0,
  slowCount: (json['slow_count'] as num?)?.toInt() ?? 0,
  overstockCount: (json['overstock_count'] as num?)?.toInt() ?? 0,
  totalStockValue: (json['total_stock_value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$InventorySummaryImplToJson(
  _$InventorySummaryImpl instance,
) => <String, dynamic>{
  'total_stock_items': instance.totalStockItems,
  'critical_count': instance.criticalCount,
  'watch_count': instance.watchCount,
  'slow_count': instance.slowCount,
  'overstock_count': instance.overstockCount,
  'total_stock_value': instance.totalStockValue,
};

_$InventoryAlertsImpl _$$InventoryAlertsImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryAlertsImpl(
  critical:
      (json['critical'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  watchList:
      (json['watch_list'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  slowMovers:
      (json['slow_movers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  overstocked:
      (json['overstocked'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$InventoryAlertsImplToJson(
  _$InventoryAlertsImpl instance,
) => <String, dynamic>{
  'critical': instance.critical,
  'watch_list': instance.watchList,
  'slow_movers': instance.slowMovers,
  'overstocked': instance.overstocked,
};
