import 'package:flutter/services.dart';

typedef OrderAlertPayloadHandler = void Function(Map<String, String> payload);

class OrderAlertNativeChannel {
  OrderAlertNativeChannel._();

  static const MethodChannel _channel = MethodChannel('order_alert_native');
  static OrderAlertPayloadHandler? _onPayload;
  static bool _isInitialised = false;

  static void setLaunchHandler(OrderAlertPayloadHandler? handler) {
    _onPayload = handler;
  }

  static Future<void> ensureInitialised() async {
    if (_isInitialised) return;
    _channel.setMethodCallHandler(_handleMethodCall);
    _isInitialised = true;
  }

  static Future<void> startAlarm() {
    return _channel.invokeMethod('startAlarm');
  }

  static Future<void> stopAlarm() {
    return _channel.invokeMethod('stopAlarm');
  }

  static Future<void> cancelNotification(String? invoiceId) {
    return _channel.invokeMethod('cancelNotification', {
      'invoiceId': invoiceId,
    });
  }

  static Future<void> showNotification(Map<String, String> data) {
    return _channel.invokeMethod('showNotification', {'data': data});
  }

  static Future<void> setVolumeLocked(bool locked) {
    return _channel.invokeMethod('setVolumeLocked', {'locked': locked});
  }

  static Future<Map<String, String>?> consumeLaunchPayload() async {
    final result = await _channel.invokeMethod<dynamic>('consumeLaunchPayload');
    if (result == null) return null;
    if (result is Map) {
      return result.map<String, String>(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return null;
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'launchPayload') {
      final payload = _coerceMap(call.arguments);
      if (payload != null) {
        _onPayload?.call(payload);
      }
    }
  }

  static Map<String, String>? _coerceMap(dynamic value) {
    if (value is Map) {
      return value.map<String, String>(
        (key, val) => MapEntry(key.toString(), val.toString()),
      );
    }
    return null;
  }
}
