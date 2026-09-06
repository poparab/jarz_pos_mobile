import 'report_json.dart';

/// Payload of `jarz_pos.api.forecasting.get_alert_summary` — four loosely
/// typed buckets of item rows, kept as [JsonMap] (not Freezed) to match the
/// row-level pattern already used by [InventoryIntelligence]'s alert lists;
/// each screen reads whichever keys it needs defensively.
///
/// Row shapes (from `services/demand_forecasting.build_alert_data`):
/// - `critical` / `watch_list`: item_code, item_name, item_group,
///   replenishment_type, daily_velocity, stock_on_hand, days_remaining
/// - `slow_movers`: item_code, item_name, item_group, replenishment_type,
///   stock_on_hand, trend
/// - `overstocked`: item_code, item_name, item_group, daily_velocity,
///   stock_on_hand, days_remaining, stock_value
class VelocityAlertSummary {
  final List<JsonMap> critical;
  final List<JsonMap> watchList;
  final List<JsonMap> slowMovers;
  final List<JsonMap> overstocked;

  const VelocityAlertSummary({
    this.critical = const <JsonMap>[],
    this.watchList = const <JsonMap>[],
    this.slowMovers = const <JsonMap>[],
    this.overstocked = const <JsonMap>[],
  });

  factory VelocityAlertSummary.fromJson(Map<String, dynamic> json) {
    return VelocityAlertSummary(
      critical: _rows(json['critical']),
      watchList: _rows(json['watch_list']),
      slowMovers: _rows(json['slow_movers']),
      overstocked: _rows(json['overstocked']),
    );
  }

  int get totalCount =>
      critical.length + watchList.length + slowMovers.length + overstocked.length;

  static List<JsonMap> _rows(dynamic value) {
    if (value is! List) return const <JsonMap>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}

/// Payload of `jarz_pos.api.forecasting.get_item_velocity` — a single item's
/// 30d/60d sales velocity, trend classification and current stock on hand.
class ItemVelocityDetail {
  final double velocity30d;
  final double velocity60d;
  final String trend;
  final double stockOnHand;

  const ItemVelocityDetail({
    required this.velocity30d,
    required this.velocity60d,
    required this.trend,
    required this.stockOnHand,
  });

  factory ItemVelocityDetail.fromJson(Map<String, dynamic> json) {
    return ItemVelocityDetail(
      velocity30d: _num(json['velocity_30d']),
      velocity60d: _num(json['velocity_60d']),
      trend: (json['trend'] ?? '').toString(),
      stockOnHand: _num(json['stock_on_hand']),
    );
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0;
    return 0;
  }
}
