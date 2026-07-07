// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'b2b_sales_clients.freezed.dart';
part 'b2b_sales_clients.g.dart';

/// Top-level payload of `get_b2b_analytics(date_from, date_to)`.
@freezed
class B2bSalesAnalytics with _$B2bSalesAnalytics {
  const factory B2bSalesAnalytics({
    @Default(B2bSalesPeriod()) B2bSalesPeriod period,
    @Default(B2bSalesSummary()) B2bSalesSummary summary,
    @JsonKey(name: 'pipeline_by_stage')
    @Default(<B2bPipelineStage>[])
    List<B2bPipelineStage> pipelineByStage,
    @JsonKey(name: 'revenue_trend')
    @Default(<B2bSalesRevenueTrendPoint>[])
    List<B2bSalesRevenueTrendPoint> revenueTrend,
    @JsonKey(name: 'top_clients')
    @Default(<B2bTopClient>[])
    List<B2bTopClient> topClients,
    @JsonKey(name: 'revenue_by_policy')
    @Default(<B2bRevenueByPolicy>[])
    List<B2bRevenueByPolicy> revenueByPolicy,
    @JsonKey(name: 'revenue_by_territory')
    @Default(<B2bRevenueByTerritory>[])
    List<B2bRevenueByTerritory> revenueByTerritory,
    @JsonKey(name: 'clients_by_group')
    @Default(<B2bClientsByGroup>[])
    List<B2bClientsByGroup> clientsByGroup,
    @JsonKey(name: 'reorder_due')
    @Default(<B2bReorderDueClient>[])
    List<B2bReorderDueClient> reorderDue,
    @JsonKey(name: 'at_risk_clients')
    @Default(<B2bAtRiskClient>[])
    List<B2bAtRiskClient> atRiskClients,
    @Default(B2bConversion()) B2bConversion conversion,
    @Default(<B2bSalesAlert>[]) List<B2bSalesAlert> alerts,
  }) = _B2bSalesAnalytics;

  factory B2bSalesAnalytics.fromJson(Map<String, dynamic> json) =>
      _$B2bSalesAnalyticsFromJson(json);
}

@freezed
class B2bSalesPeriod with _$B2bSalesPeriod {
  const factory B2bSalesPeriod({
    @JsonKey(name: 'date_from') @Default('') String dateFrom,
    @JsonKey(name: 'date_to') @Default('') String dateTo,
  }) = _B2bSalesPeriod;

  factory B2bSalesPeriod.fromJson(Map<String, dynamic> json) =>
      _$B2bSalesPeriodFromJson(json);
}

@freezed
class B2bSalesSummary with _$B2bSalesSummary {
  const factory B2bSalesSummary({
    @JsonKey(name: 'b2b_revenue') @Default(0) double b2bRevenue,
    @JsonKey(name: 'b2b_orders') @Default(0) int b2bOrders,
    @JsonKey(name: 'active_clients') @Default(0) int activeClients,
    @JsonKey(name: 'new_clients') @Default(0) int newClients,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
    @JsonKey(name: 'gross_profit') @Default(0) double grossProfit,
    @JsonKey(name: 'gross_margin_pct') @Default(0) double grossMarginPct,
    @JsonKey(name: 'reorder_due_count') @Default(0) int reorderDueCount,
    @JsonKey(name: 'at_risk_count') @Default(0) int atRiskCount,
    @JsonKey(name: 'total_b2b_clients') @Default(0) int totalB2bClients,
    @JsonKey(name: 'pipeline_open_value') @Default(0) double pipelineOpenValue,
  }) = _B2bSalesSummary;

  factory B2bSalesSummary.fromJson(Map<String, dynamic> json) =>
      _$B2bSalesSummaryFromJson(json);
}

@freezed
class B2bPipelineStage with _$B2bPipelineStage {
  const factory B2bPipelineStage({
    @Default('') String stage,
    @Default(0) int count,
    @Default(0) double value,
  }) = _B2bPipelineStage;

  factory B2bPipelineStage.fromJson(Map<String, dynamic> json) =>
      _$B2bPipelineStageFromJson(json);
}

@freezed
class B2bSalesRevenueTrendPoint with _$B2bSalesRevenueTrendPoint {
  const factory B2bSalesRevenueTrendPoint({
    @JsonKey(name: 'posting_date') @Default('') String postingDate,
    @Default(0) double revenue,
    @Default(0) int orders,
  }) = _B2bSalesRevenueTrendPoint;

  factory B2bSalesRevenueTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$B2bSalesRevenueTrendPointFromJson(json);
}

@freezed
class B2bTopClient with _$B2bTopClient {
  const factory B2bTopClient({
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @Default(0) double revenue,
    @Default(0) int orders,
    @JsonKey(name: 'last_order_date') @Default('') String lastOrderDate,
    @Default('') String segment,
  }) = _B2bTopClient;

  factory B2bTopClient.fromJson(Map<String, dynamic> json) =>
      _$B2bTopClientFromJson(json);
}

@freezed
class B2bRevenueByPolicy with _$B2bRevenueByPolicy {
  const factory B2bRevenueByPolicy({
    @Default('') String policy,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @Default(0) double revenue,
  }) = _B2bRevenueByPolicy;

  factory B2bRevenueByPolicy.fromJson(Map<String, dynamic> json) =>
      _$B2bRevenueByPolicyFromJson(json);
}

@freezed
class B2bRevenueByTerritory with _$B2bRevenueByTerritory {
  const factory B2bRevenueByTerritory({
    @Default('') String territory,
    @Default(0) double revenue,
    @Default(0) int orders,
  }) = _B2bRevenueByTerritory;

  factory B2bRevenueByTerritory.fromJson(Map<String, dynamic> json) =>
      _$B2bRevenueByTerritoryFromJson(json);
}

@freezed
class B2bClientsByGroup with _$B2bClientsByGroup {
  const factory B2bClientsByGroup({
    @JsonKey(name: 'customer_group') @Default('') String customerGroup,
    @JsonKey(name: 'client_count') @Default(0) int clientCount,
    @Default(0) double revenue,
  }) = _B2bClientsByGroup;

  factory B2bClientsByGroup.fromJson(Map<String, dynamic> json) =>
      _$B2bClientsByGroupFromJson(json);
}

@freezed
class B2bReorderDueClient with _$B2bReorderDueClient {
  const factory B2bReorderDueClient({
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'last_order_date') @Default('') String lastOrderDate,
    @JsonKey(name: 'days_since') @Default(0) int daysSince,
    @JsonKey(name: 'expected_reorder_date')
    @Default('')
    String expectedReorderDate,
  }) = _B2bReorderDueClient;

  factory B2bReorderDueClient.fromJson(Map<String, dynamic> json) =>
      _$B2bReorderDueClientFromJson(json);
}

@freezed
class B2bAtRiskClient with _$B2bAtRiskClient {
  const factory B2bAtRiskClient({
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @Default('') String segment,
    @JsonKey(name: 'recency_days') @Default(0) int recencyDays,
    @Default(0) double revenue,
  }) = _B2bAtRiskClient;

  factory B2bAtRiskClient.fromJson(Map<String, dynamic> json) =>
      _$B2bAtRiskClientFromJson(json);
}

@freezed
class B2bConversion with _$B2bConversion {
  const factory B2bConversion({
    @Default(0) int opportunities,
    @Default(0) int won,
    @JsonKey(name: 'conversion_rate') @Default(0) double conversionRate,
  }) = _B2bConversion;

  factory B2bConversion.fromJson(Map<String, dynamic> json) =>
      _$B2bConversionFromJson(json);
}

@freezed
class B2bSalesAlert with _$B2bSalesAlert {
  const factory B2bSalesAlert({
    @Default('info') String type,
    @Default('') String message,
  }) = _B2bSalesAlert;

  factory B2bSalesAlert.fromJson(Map<String, dynamic> json) =>
      _$B2bSalesAlertFromJson(json);
}
