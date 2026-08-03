// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/order_display_id.dart';
import 'report_json.dart';

part 'shipping_analytics.freezed.dart';
part 'shipping_analytics.g.dart';

/// Top-level payload of `get_shipping_analytics(from_date, to_date)`.
@freezed
class ShippingAnalytics with _$ShippingAnalytics {
  const factory ShippingAnalytics({
    @JsonKey(name: 'summary_kpis')
    @Default(ShippingSummaryKpis())
    ShippingSummaryKpis summaryKpis,
    @Default(<ShippingAlert>[]) List<ShippingAlert> alerts,
    @JsonKey(name: 'cost_by_territory')
    @Default(<ShippingTerritoryCost>[])
    List<ShippingTerritoryCost> costByTerritory,
    @JsonKey(name: 'cost_by_sub_territory')
    @Default(<ShippingSubTerritoryCost>[])
    List<ShippingSubTerritoryCost> costBySubTerritory,
    @JsonKey(name: 'cost_by_pos_profile')
    @Default(<ShippingPosProfileCost>[])
    List<ShippingPosProfileCost> costByPosProfile,
    @JsonKey(name: 'cost_by_courier')
    @Default(<ShippingCourierCost>[])
    List<ShippingCourierCost> costByCourier,
    @JsonKey(name: 'custom_shipping_breakdown')
    @Default(ShippingCustomBreakdown())
    ShippingCustomBreakdown customShippingBreakdown,
    @JsonKey(name: 'double_shipping_impact')
    @Default(ShippingDoubleImpact())
    ShippingDoubleImpact doubleShippingImpact,
    @JsonKey(name: 'daily_trend')
    @Default(<ShippingDailyTrendPoint>[])
    List<ShippingDailyTrendPoint> dailyTrend,
    @JsonKey(name: 'pickup_vs_delivery_split')
    @Default(ShippingPickupDeliverySplit())
    ShippingPickupDeliverySplit pickupVsDeliverySplit,
    @JsonKey(name: 'unsettled_courier_balances')
    @Default(<ShippingUnsettledCourierBalance>[])
    List<ShippingUnsettledCourierBalance> unsettledCourierBalances,
    @JsonKey(name: 'pickup_delivery_trend')
    @Default(<ShippingPickupDeliveryTrendPoint>[])
    List<ShippingPickupDeliveryTrendPoint> pickupDeliveryTrend,
  }) = _ShippingAnalytics;

  factory ShippingAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ShippingAnalyticsFromJson(json);
}

@freezed
class ShippingSummaryKpis with _$ShippingSummaryKpis {
  const factory ShippingSummaryKpis({
    @JsonKey(name: 'total_orders') @Default(0) int totalOrders,
    @JsonKey(name: 'delivery_orders') @Default(0) int deliveryOrders,
    @JsonKey(name: 'pickup_orders') @Default(0) int pickupOrders,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
    @JsonKey(name: 'total_income') @Default(0) double totalIncome,
    @JsonKey(name: 'net_pl') @Default(0) double netPl,
    @JsonKey(name: 'avg_cost_per_order') @Default(0) double avgCostPerOrder,
    @JsonKey(name: 'pending_csr_count') @Default(0) int pendingCsrCount,
    @JsonKey(name: 'unsettled_courier_total')
    @Default(0)
    double unsettledCourierTotal,
  }) = _ShippingSummaryKpis;

  factory ShippingSummaryKpis.fromJson(Map<String, dynamic> json) =>
      _$ShippingSummaryKpisFromJson(json);
}

@freezed
class ShippingAlert with _$ShippingAlert {
  const factory ShippingAlert({
    @Default('info') String type,
    @Default('') String message,
  }) = _ShippingAlert;

  factory ShippingAlert.fromJson(Map<String, dynamic> json) =>
      _$ShippingAlertFromJson(json);
}

@freezed
class ShippingTerritoryCost with _$ShippingTerritoryCost {
  const factory ShippingTerritoryCost({
    @Default('') String territory,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
    @JsonKey(name: 'total_income') @Default(0) double totalIncome,
    @JsonKey(name: 'net_pl') @Default(0) double netPl,
    @JsonKey(name: 'avg_cost') @Default(0) double avgCost,
  }) = _ShippingTerritoryCost;

  factory ShippingTerritoryCost.fromJson(Map<String, dynamic> json) =>
      _$ShippingTerritoryCostFromJson(json);
}

@freezed
class ShippingSubTerritoryCost with _$ShippingSubTerritoryCost {
  const factory ShippingSubTerritoryCost({
    @JsonKey(name: 'sub_territory') @Default('') String subTerritory,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
  }) = _ShippingSubTerritoryCost;

  factory ShippingSubTerritoryCost.fromJson(Map<String, dynamic> json) =>
      _$ShippingSubTerritoryCostFromJson(json);
}

@freezed
class ShippingPosProfileCost with _$ShippingPosProfileCost {
  const factory ShippingPosProfileCost({
    @Default('') String branch,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
    @JsonKey(name: 'total_income') @Default(0) double totalIncome,
    @JsonKey(name: 'avg_cost') @Default(0) double avgCost,
  }) = _ShippingPosProfileCost;

  factory ShippingPosProfileCost.fromJson(Map<String, dynamic> json) =>
      _$ShippingPosProfileCostFromJson(json);
}

@freezed
class ShippingCourierCost with _$ShippingCourierCost {
  const factory ShippingCourierCost({
    @Default('') String party,
    @Default(0) double settled,
    @Default(0) double unsettled,
  }) = _ShippingCourierCost;

  factory ShippingCourierCost.fromJson(Map<String, dynamic> json) =>
      _$ShippingCourierCostFromJson(json);
}

@freezed
class ShippingCustomBreakdown with _$ShippingCustomBreakdown {
  const factory ShippingCustomBreakdown({
    @Default(ShippingCustomBreakdownSummary())
    ShippingCustomBreakdownSummary summary,
    @Default(<ShippingCustomBreakdownRow>[])
    List<ShippingCustomBreakdownRow> rows,
  }) = _ShippingCustomBreakdown;

  factory ShippingCustomBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ShippingCustomBreakdownFromJson(json);
}

@freezed
class ShippingCustomBreakdownSummary with _$ShippingCustomBreakdownSummary {
  const factory ShippingCustomBreakdownSummary({
    @Default(0) int total,
    @Default(0) int approved,
    @Default(0) int rejected,
    @Default(0) int pending,
    @JsonKey(name: 'approval_rate') @Default(0) double approvalRate,
  }) = _ShippingCustomBreakdownSummary;

  factory ShippingCustomBreakdownSummary.fromJson(Map<String, dynamic> json) =>
      _$ShippingCustomBreakdownSummaryFromJson(json);
}

@freezed
class ShippingCustomBreakdownRow with _$ShippingCustomBreakdownRow {
  const ShippingCustomBreakdownRow._();

  const factory ShippingCustomBreakdownRow({
    @Default('') String invoice,
    @JsonKey(name: 'woo_order_id') int? wooOrderId,
    @Default('') String territory,
    @JsonKey(name: 'original_amount') @Default(0) double originalAmount,
    @JsonKey(name: 'requested_amount') @Default(0) double requestedAmount,
    @Default(0) double delta,
    @JsonKey(name: 'is_large_override') @Default(false) bool isLargeOverride,
    @Default('') String status,
  }) = _ShippingCustomBreakdownRow;

  /// What the report labels this row with.
  String get displayId => orderDisplayId(invoice, wooOrderId: wooOrderId);

  factory ShippingCustomBreakdownRow.fromJson(Map<String, dynamic> json) =>
      _$ShippingCustomBreakdownRowFromJson(json);
}

@freezed
class ShippingDoubleImpact with _$ShippingDoubleImpact {
  const factory ShippingDoubleImpact({
    @JsonKey(name: 'total_double_trips') @Default(0) int totalDoubleTrips,
    @JsonKey(name: 'total_extra_cost') @Default(0) double totalExtraCost,
    @Default(<JsonMap>[]) List<JsonMap> trips,
  }) = _ShippingDoubleImpact;

  factory ShippingDoubleImpact.fromJson(Map<String, dynamic> json) =>
      _$ShippingDoubleImpactFromJson(json);
}

@freezed
class ShippingDailyTrendPoint with _$ShippingDailyTrendPoint {
  const factory ShippingDailyTrendPoint({
    @JsonKey(name: 'posting_date') @Default('') String postingDate,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
    @JsonKey(name: 'total_income') @Default(0) double totalIncome,
  }) = _ShippingDailyTrendPoint;

  factory ShippingDailyTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$ShippingDailyTrendPointFromJson(json);
}

@freezed
class ShippingPickupDeliverySplit with _$ShippingPickupDeliverySplit {
  const factory ShippingPickupDeliverySplit({
    @Default(0) int pickup,
    @Default(0) int delivery,
  }) = _ShippingPickupDeliverySplit;

  factory ShippingPickupDeliverySplit.fromJson(Map<String, dynamic> json) =>
      _$ShippingPickupDeliverySplitFromJson(json);
}

@freezed
class ShippingUnsettledCourierBalance with _$ShippingUnsettledCourierBalance {
  const factory ShippingUnsettledCourierBalance({
    @Default('') String party,
    @JsonKey(name: 'party_type') @Default('') String partyType,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @JsonKey(name: 'total_owed') @Default(0) double totalOwed,
    @JsonKey(name: 'oldest_date') @Default('') String oldestDate,
    @JsonKey(name: 'days_aged') @Default(0) int daysAged,
  }) = _ShippingUnsettledCourierBalance;

  factory ShippingUnsettledCourierBalance.fromJson(Map<String, dynamic> json) =>
      _$ShippingUnsettledCourierBalanceFromJson(json);
}

@freezed
class ShippingPickupDeliveryTrendPoint
    with _$ShippingPickupDeliveryTrendPoint {
  const factory ShippingPickupDeliveryTrendPoint({
    @JsonKey(name: 'posting_date') @Default('') String postingDate,
    @Default(0) int pickup,
    @Default(0) int delivery,
  }) = _ShippingPickupDeliveryTrendPoint;

  factory ShippingPickupDeliveryTrendPoint.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ShippingPickupDeliveryTrendPointFromJson(json);
}
