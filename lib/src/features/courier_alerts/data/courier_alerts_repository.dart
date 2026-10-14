import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'courier_alert_models.dart';

final courierAlertsRepositoryProvider = Provider<CourierAlertsRepository>((
  ref,
) {
  return CourierAlertsRepository(ref.watch(dioProvider));
});

/// HTTP repository for `jarz_courier.api.alerts.*`.
///
/// Every answer arrives in Frappe's `{ "message": ... }` envelope. Failures
/// (403 for a non-supervisor, 404 when jarz_courier is not installed) are left
/// to propagate so the screen can show the server's own sentence.
class CourierAlertsRepository {
  CourierAlertsRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  Future<CourierAlertsResult> _listByStatus(String status, int limit) async {
    final response = await _dio.post(
      ApiEndpoints.courierListAlerts,
      data: {'status': status, 'limit': limit},
    );
    return CourierAlertsResult.fromJson(_asMap(_unwrap(response)));
  }

  /// [openOnly] true asks for Open alerts. False merges Open, Reviewed and
  /// Dismissed, newest first: the contract documents `status` as one of those
  /// three values, so "all" is built here instead of relying on a fourth.
  Future<CourierAlertsResult> listAlerts({
    bool openOnly = true,
    int limit = 50,
  }) async {
    if (openOnly) return _listByStatus('Open', limit);
    final parts = await Future.wait([
      _listByStatus('Open', limit),
      _listByStatus('Reviewed', limit),
      _listByStatus('Dismissed', limit),
    ]);
    final merged = <CourierAlert>[for (final p in parts) ...p.alerts]
      ..sort((a, b) {
        final at = a.detectedOn, bt = b.detectedOn;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    return CourierAlertsResult(
      alerts: merged.take(limit).toList(),
      openCount: parts.first.openCount,
      highCount: parts.first.highCount,
    );
  }

  /// Marks an alert Reviewed or Dismissed. Returns the updated alert.
  Future<CourierAlert> acknowledge({
    required String name,
    required CourierAlertStatus status,
    String? note,
  }) async {
    assert(status != CourierAlertStatus.open);
    final trimmed = note?.trim() ?? '';
    final response = await _dio.post(
      ApiEndpoints.courierAcknowledgeAlert,
      data: {
        'name': name,
        'status': status == CourierAlertStatus.dismissed
            ? 'Dismissed'
            : 'Reviewed',
        if (trimmed.isNotEmpty) 'note': trimmed,
      },
    );
    return CourierAlert.fromJson(_asMap(_unwrap(response)));
  }

  Future<CourierAlertCounts> getCounts() async {
    final response = await _dio.post(ApiEndpoints.courierAlertCounts, data: {});
    return CourierAlertCounts.fromJson(_asMap(_unwrap(response)));
  }
}
