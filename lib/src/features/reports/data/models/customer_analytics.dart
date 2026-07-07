// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'report_json.dart';

part 'customer_analytics.freezed.dart';
part 'customer_analytics.g.dart';

/// Top-level payload of `get_customer_analytics(date_from, date_to)`.
@freezed
class CustomerAnalytics with _$CustomerAnalytics {
  const factory CustomerAnalytics({
    @Default(<String, dynamic>{}) JsonMap period,
    @Default(CustomerAnalyticsSummary()) CustomerAnalyticsSummary summary,
    @JsonKey(name: 'segment_distribution')
    @Default(<JsonMap>[])
    List<JsonMap> segmentDistribution,
    @JsonKey(name: 'segment_table')
    @Default(<JsonMap>[])
    List<JsonMap> segmentTable,
    @JsonKey(name: 'top_customers')
    @Default(<JsonMap>[])
    List<JsonMap> topCustomers,
    @JsonKey(name: 'at_risk_customers')
    @Default(<JsonMap>[])
    List<JsonMap> atRiskCustomers,
    @JsonKey(name: 'acquisition_trend')
    @Default(<JsonMap>[])
    List<JsonMap> acquisitionTrend,
  }) = _CustomerAnalytics;

  factory CustomerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$CustomerAnalyticsFromJson(json);
}

@freezed
class CustomerAnalyticsSummary with _$CustomerAnalyticsSummary {
  const factory CustomerAnalyticsSummary({
    @JsonKey(name: 'total_customers') @Default(0) int totalCustomers,
    @JsonKey(name: 'active_in_period') @Default(0) int activeInPeriod,
    @JsonKey(name: 'new_customers') @Default(0) int newCustomers,
    @JsonKey(name: 'returning_customers') @Default(0) int returningCustomers,
    @JsonKey(name: 'repeat_rate') @Default(0) double repeatRate,
    @Default(0) int champions,
    @JsonKey(name: 'at_risk') @Default(0) int atRisk,
    @Default(0) int lost,
    @JsonKey(name: 'period_revenue') @Default(0) double periodRevenue,
    @JsonKey(name: 'period_orders') @Default(0) int periodOrders,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
  }) = _CustomerAnalyticsSummary;

  factory CustomerAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$CustomerAnalyticsSummaryFromJson(json);
}
