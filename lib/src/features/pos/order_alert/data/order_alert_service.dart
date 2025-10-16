import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../domain/invoice_alert.dart';

final orderAlertServiceProvider = Provider<OrderAlertService>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderAlertService(dio);
});

class OrderAlertService {
  OrderAlertService(this._dio);

  final Dio _dio;

  Future<void> registerDevice({
    required String token,
    String? platform,
    String? deviceName,
    String? appVersion,
    List<String>? posProfiles,
  }) async {
    final payload = <String, dynamic>{
      'token': token,
      if (platform != null) 'platform': platform,
      if (deviceName != null) 'device_name': deviceName,
      if (appVersion != null) 'app_version': appVersion,
      if (posProfiles != null && posProfiles.isNotEmpty)
        'pos_profiles': jsonEncode(posProfiles),
    };

    await _dio.post(
      '/api/method/jarz_pos.api.notifications.register_mobile_device',
      data: payload,
    );
  }

  Future<void> acknowledgeInvoice(String invoiceName) async {
    await _dio.post(
      '/api/method/jarz_pos.api.notifications.acknowledge_invoice',
      data: {'invoice_name': invoiceName},
    );
  }

  Future<List<InvoiceAlert>> getPendingAlerts() async {
    final response = await _dio.post(
      '/api/method/jarz_pos.api.notifications.get_pending_alerts',
      data: const {},
    );

    final message = _extractMessage(response);
    final alertsRaw = message['alerts'];
    if (alertsRaw is List) {
      final alerts = <InvoiceAlert>[];
      for (final entry in alertsRaw) {
        if (entry is Map<String, dynamic>) {
          alerts.add(InvoiceAlert.fromDynamic(entry));
        } else if (entry is Map) {
          alerts.add(InvoiceAlert.fromDynamic(Map<String, dynamic>.from(entry)));
        }
      }
      return alerts;
    }
    return const [];
  }

  Map<String, dynamic> _extractMessage(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is Map) {
        return Map<String, dynamic>.from(message);
      }
      return data;
    }
    return const {};
  }
}
