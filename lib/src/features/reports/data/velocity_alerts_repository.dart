import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/velocity_alerts.dart';

final velocityAlertsRepositoryProvider = Provider<VelocityAlertsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VelocityAlertsRepository(dio);
});

/// Talks to the three `jarz_pos.api.forecasting` endpoints backing the
/// Reorder & Velocity Alerts dashboard. Mirrors [ReportsRepository]'s Frappe
/// envelope handling: every whitelisted method's return value arrives wrapped
/// as `{"message": ...}`, with a bare-payload fallback kept defensively.
class VelocityAlertsRepository {
  final Dio _dio;
  VelocityAlertsRepository(this._dio);

  Map<String, dynamic> _asMap(Response response) {
    final data = response.data;
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return const <String, dynamic>{};
  }

  /// `forecasting.get_alert_summary` — current critical/watch/slow/overstock
  /// buckets, read off `Item.jarz_velocity_*` (recalculated by the weekly job).
  Future<VelocityAlertSummary> fetchAlertSummary() async {
    final response = await _dio.post(
      ApiEndpoints.forecastAlertSummary,
      data: {},
    );
    return VelocityAlertSummary.fromJson(_asMap(response));
  }

  /// `forecasting.get_item_velocity` — 30d/60d velocity, trend and current
  /// stock for a single item.
  Future<ItemVelocityDetail> fetchItemVelocity(String itemCode) async {
    final response = await _dio.post(
      ApiEndpoints.forecastItemVelocity,
      data: {'item_code': itemCode},
    );
    return ItemVelocityDetail.fromJson(_asMap(response));
  }

  /// `forecasting.run_velocity_update_now` — manager-only, synchronously
  /// recalculates velocity for every active stock item (heavy job; the
  /// weekly scheduled job normally does this). Returns the item count updated.
  Future<int> runVelocityUpdateNow() async {
    final response = await _dio.post(
      ApiEndpoints.forecastRunVelocityNow,
      data: {},
    );
    final updated = _asMap(response)['updated'];
    return updated is num ? updated.toInt() : 0;
  }
}
