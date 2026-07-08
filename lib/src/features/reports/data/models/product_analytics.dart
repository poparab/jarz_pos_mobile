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
    // Backend emits an object `{item_name, total_qty}`; extract the name.
    @JsonKey(name: 'best_selling_product')
    @_BestSellingProductConverter()
    @Default('')
    String bestSellingProduct,
    // Backend emits an object `{territory, revenue}`; extract the territory.
    @JsonKey(name: 'top_territory')
    @_TopTerritoryConverter()
    @Default('')
    String topTerritory,
  }) = _ProductAnalyticsSummary;

  factory ProductAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductAnalyticsSummaryFromJson(json);
}

/// Reads a single string field out of a backend object value, tolerating a
/// plain string (returned as-is) or null/other (empty). Keeps the model field a
/// simple `String` so the UI stays unchanged. json_serializable does not allow
/// converters with constructor arguments, hence one small class per field.
String _stringField(Object? json, String field) {
  if (json is Map) {
    final v = json[field];
    return v == null ? '' : v.toString();
  }
  if (json is String) return json;
  return '';
}

class _BestSellingProductConverter implements JsonConverter<String, Object?> {
  const _BestSellingProductConverter();

  @override
  String fromJson(Object? json) => _stringField(json, 'item_name');

  @override
  Object? toJson(String value) => value;
}

class _TopTerritoryConverter implements JsonConverter<String, Object?> {
  const _TopTerritoryConverter();

  @override
  String fromJson(Object? json) => _stringField(json, 'territory');

  @override
  Object? toJson(String value) => value;
}
