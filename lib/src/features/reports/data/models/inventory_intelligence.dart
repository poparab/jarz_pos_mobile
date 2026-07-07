// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'report_json.dart';

part 'inventory_intelligence.freezed.dart';
part 'inventory_intelligence.g.dart';

/// Top-level payload of `get_inventory_analytics(date_from, date_to)`.
@freezed
class InventoryIntelligence with _$InventoryIntelligence {
  const factory InventoryIntelligence({
    @Default(<String, dynamic>{}) JsonMap period,
    @Default(InventorySummary()) InventorySummary summary,
    @Default(InventoryAlerts()) InventoryAlerts alerts,
    @JsonKey(name: 'velocity_distribution')
    @Default(<JsonMap>[])
    List<JsonMap> velocityDistribution,
    @JsonKey(name: 'top_movers')
    @Default(<JsonMap>[])
    List<JsonMap> topMovers,
    @JsonKey(name: 'top_sold_in_range')
    @Default(<JsonMap>[])
    List<JsonMap> topSoldInRange,
  }) = _InventoryIntelligence;

  factory InventoryIntelligence.fromJson(Map<String, dynamic> json) =>
      _$InventoryIntelligenceFromJson(json);
}

@freezed
class InventorySummary with _$InventorySummary {
  const factory InventorySummary({
    @JsonKey(name: 'total_stock_items') @Default(0) int totalStockItems,
    @JsonKey(name: 'critical_count') @Default(0) int criticalCount,
    @JsonKey(name: 'watch_count') @Default(0) int watchCount,
    @JsonKey(name: 'slow_count') @Default(0) int slowCount,
    @JsonKey(name: 'overstock_count') @Default(0) int overstockCount,
    @JsonKey(name: 'total_stock_value') @Default(0) double totalStockValue,
  }) = _InventorySummary;

  factory InventorySummary.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryFromJson(json);
}

@freezed
class InventoryAlerts with _$InventoryAlerts {
  const factory InventoryAlerts({
    @Default(<JsonMap>[]) List<JsonMap> critical,
    @JsonKey(name: 'watch_list')
    @Default(<JsonMap>[])
    List<JsonMap> watchList,
    @JsonKey(name: 'slow_movers')
    @Default(<JsonMap>[])
    List<JsonMap> slowMovers,
    @Default(<JsonMap>[]) List<JsonMap> overstocked,
  }) = _InventoryAlerts;

  factory InventoryAlerts.fromJson(Map<String, dynamic> json) =>
      _$InventoryAlertsFromJson(json);
}
