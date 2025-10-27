import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

typedef OrderAlertPayloadHandler = void Function(Map<String, String> payload);

class AlarmSoundOption {
  final String title;
  final String uri;

  AlarmSoundOption({required this.title, required this.uri});
}

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
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('startAlarm');
  }

  static Future<void> stopAlarm() {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('stopAlarm');
  }

  static Future<void> cancelNotification(String? invoiceId) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('cancelNotification', {
      'invoiceId': invoiceId,
    });
  }

  static Future<void> showNotification(Map<String, String> data) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('showNotification', {'data': data});
  }

  static Future<void> setVolumeLocked(bool locked) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('setVolumeLocked', {'locked': locked});
  }

  static Future<List<AlarmSoundOption>> getAvailableAlarmSounds() async {
    if (kIsWeb) return []; // No alarm sounds on web
    final result = await _channel.invokeMethod<List<dynamic>>('getAvailableAlarmSounds');
    if (result == null) return [];
    
    return result.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return AlarmSoundOption(
        title: map['title']?.toString() ?? 'Unknown',
        uri: map['uri']?.toString() ?? '',
      );
    }).toList();
  }

  static Future<void> setAlarmSound(String? uri) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('setAlarmSound', {'uri': uri});
  }

  static Future<void> previewAlarmSound(String uri) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('previewAlarmSound', {'uri': uri});
  }

  static Future<void> stopPreview() {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('stopPreview');
  }

  static Future<Map<String, String>?> consumeLaunchPayload() async {
    if (kIsWeb) return null; // No launch payload on web
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
