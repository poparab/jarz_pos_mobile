// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'report_json.dart';

part 'product_analytics.freezed.dart';
part 'product_analytics.g.dart';

/// Top-level payload of `get_product_analytics(date_from, date_to)`.
@freezed
class ProductAnalytics with _$ProductAnalytics {
  const factory ProductAnalytics({
    @Default(<String, dynamic>{}) JsonMap period,
    @Default(ProductAnalyticsSummary()) ProductAnalyticsSummary summary,
    @JsonKey(name: 'by_product_type')
    @Default(<JsonMap>[])
    List<JsonMap> byProductType,
    @JsonKey(name: 'top_products')
    @Default(<JsonMap>[])
    List<JsonMap> topProducts,
    @JsonKey(name: 'by_territory')
    @Default(<JsonMap>[])
    List<JsonMap> byTerritory,
    @Default(<JsonMap>[]) List<JsonMap> trend,
    @JsonKey(name: 'bundle_composition')
    @Default(<JsonMap>[])
    List<JsonMap> bundleComposition,
  }) = _ProductAnalytics;

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ProductAnalyticsFromJson(json);
}

@freezed
class ProductAnalyticsSummary with _$ProductAnalyticsSummary {
  const factory ProductAnalyticsSummary({
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'total_orders') @Default(0) int totalOrders,
    @JsonKey(name: 'total_gross_profit') @Default(0) double totalGrossProfit,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
    @JsonKey(name: 'best_selling_product')
    @Default('')
    String bestSellingProduct,
    @JsonKey(name: 'top_territory') @Default('') String topTerritory,
  }) = _ProductAnalyticsSummary;

  factory ProductAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductAnalyticsSummaryFromJson(json);
}
