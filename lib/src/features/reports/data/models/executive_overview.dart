// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'report_json.dart';

part 'executive_overview.freezed.dart';
part 'executive_overview.g.dart';

/// Top-level payload of `get_executive_overview(date_from, date_to)`.
@freezed
class ExecutiveOverview with _$ExecutiveOverview {
  const factory ExecutiveOverview({
    @Default(<String, dynamic>{}) JsonMap period,
    @Default(ExecutiveKpis()) ExecutiveKpis kpis,
    @JsonKey(name: 'revenue_trend')
    @Default(<JsonMap>[])
    List<JsonMap> revenueTrend,
    @JsonKey(name: 'product_mix')
    @Default(<JsonMap>[])
    List<JsonMap> productMix,
    @JsonKey(name: 'segment_mix')
    @Default(<JsonMap>[])
    List<JsonMap> segmentMix,
    @JsonKey(name: 'top_territories')
    @Default(<JsonMap>[])
    List<JsonMap> topTerritories,
    @Default(<JsonMap>[]) List<JsonMap> alerts,
  }) = _ExecutiveOverview;

  factory ExecutiveOverview.fromJson(Map<String, dynamic> json) =>
      _$ExecutiveOverviewFromJson(json);
}

@freezed
class ExecutiveKpis with _$ExecutiveKpis {
  const factory ExecutiveKpis({
    @Default(0) double revenue,
    @Default(0) int orders,
    @JsonKey(name: 'gross_profit') @Default(0) double grossProfit,
    @JsonKey(name: 'gross_margin_pct') @Default(0) double grossMarginPct,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
    @JsonKey(name: 'net_shipping_pl') @Default(0) double netShippingPl,
    @Default(0) int customers,
    @JsonKey(name: 'critical_stock') @Default(0) int criticalStock,
  }) = _ExecutiveKpis;

  factory ExecutiveKpis.fromJson(Map<String, dynamic> json) =>
      _$ExecutiveKpisFromJson(json);
}
