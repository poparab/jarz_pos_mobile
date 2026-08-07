import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import '../../../core/constants/storage_keys.dart';

typedef OrderAlertPayloadHandler = void Function(Map<String, String> payload);

class AlarmSoundOption {
  final String title;
  final String uri;

  AlarmSoundOption({required this.title, required this.uri});
}

class OrderAlertNativeChannel {
  OrderAlertNativeChannel._();

  static const MethodChannel _channel = MethodChannel(MethodChannels.orderAlertNative);
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

  /// Starts the looping alarm for [invoiceId].
  ///
  /// The id matters: the native layer refuses to ring for an invoice the user
  /// has silenced. Passing null means "ring unless the device is globally
  /// muted", which is only correct for callers that have no invoice in hand.
  static Future<void> startAlarm({String? invoiceId}) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('startAlarm', {'invoiceId': invoiceId});
  }

  /// Mirrors the Dart mute state into the native layer.
  ///
  /// Android starts the alarm straight from the FCM service, with no Dart
  /// engine running and therefore no access to the controller's state. Without
  /// this, every push re-armed an alarm the user had already muted.
  static Future<void> setMuteState({
    required bool globalMute,
    required List<String> mutedInvoiceIds,
  }) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('setMuteState', {
      'globalMute': globalMute,
      'mutedInvoiceIds': mutedInvoiceIds,
    });
  }

  /// Tells the native layer whether this user is allowed to silence alarms.
  ///
  /// Drives the volume-key lock: someone who cannot mute must not be able to
  /// turn the volume down either, but locking the keys of someone who *can*
  /// mute just traps them.
  static Future<void> setCanMuteAlarm(bool canMute) {
    if (kIsWeb) return Future.value(); // No-op on web
    return _channel.invokeMethod('setCanMuteAlarm', {'canMute': canMute});
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

  static Future<String?> setAlarmSound(String? uri) async {
    if (kIsWeb) return uri; // No-op on web
    return _channel.invokeMethod<String?>('setAlarmSound', {'uri': uri});
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
