// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductAnalyticsImpl _$$ProductAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ProductAnalyticsImpl(
  period: json['period'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  summary: json['summary'] == null
      ? const ProductAnalyticsSummary()
      : ProductAnalyticsSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  byProductType:
      (json['by_product_type'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  topProducts:
      (json['top_products'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  byTerritory:
      (json['by_territory'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  trend:
      (json['trend'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
  bundleComposition:
      (json['bundle_composition'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$ProductAnalyticsImplToJson(
  _$ProductAnalyticsImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'summary': instance.summary,
  'by_product_type': instance.byProductType,
  'top_products': instance.topProducts,
  'by_territory': instance.byTerritory,
  'trend': instance.trend,
  'bundle_composition': instance.bundleComposition,
};

_$ProductAnalyticsSummaryImpl _$$ProductAnalyticsSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ProductAnalyticsSummaryImpl(
  totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
  totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
  totalGrossProfit: (json['total_gross_profit'] as num?)?.toDouble() ?? 0,
  avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
  bestSellingProduct: json['best_selling_product'] == null
      ? ''
      : const _BestSellingProductConverter().fromJson(
          json['best_selling_product'],
        ),
  topTerritory: json['top_territory'] == null
      ? ''
      : const _TopTerritoryConverter().fromJson(json['top_territory']),
);

Map<String, dynamic> _$$ProductAnalyticsSummaryImplToJson(
  _$ProductAnalyticsSummaryImpl instance,
) => <String, dynamic>{
  'total_revenue': instance.totalRevenue,
  'total_orders': instance.totalOrders,
  'total_gross_profit': instance.totalGrossProfit,
  'avg_order_value': instance.avgOrderValue,
  'best_selling_product': const _BestSellingProductConverter().toJson(
    instance.bestSellingProduct,
  ),
  'top_territory': const _TopTerritoryConverter().toJson(instance.topTerritory),
};
