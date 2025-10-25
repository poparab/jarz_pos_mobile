import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pos/order_alert/order_alert_native_channel.dart';

class AlarmSoundService {
  static const String _alarmSoundUriKey = 'alarm_sound_uri';
  static const String _alarmSoundTitleKey = 'alarm_sound_title';
  final SharedPreferences _prefs;

  AlarmSoundService(this._prefs);

  /// Get the currently selected alarm sound URI
  String? getSelectedSoundUri() {
    return _prefs.getString(_alarmSoundUriKey);
  }

  /// Get the currently selected alarm sound title
  String? getSelectedSoundTitle() {
    return _prefs.getString(_alarmSoundTitleKey);
  }

  /// Set the alarm sound preference
  Future<void> setSelectedSound(String uri, String title) async {
    await _prefs.setString(_alarmSoundUriKey, uri);
    await _prefs.setString(_alarmSoundTitleKey, title);
    // Update the native side
    await OrderAlertNativeChannel.setAlarmSound(uri);
  }

  /// Load available alarm sounds from the device
  Future<List<AlarmSoundOption>> getAvailableAlarmSounds() async {
    return await OrderAlertNativeChannel.getAvailableAlarmSounds();
  }

  /// Preview an alarm sound
  Future<void> previewSound(String uri) async {
    await OrderAlertNativeChannel.previewAlarmSound(uri);
  }

  /// Stop preview
  Future<void> stopPreview() async {
    await OrderAlertNativeChannel.stopPreview();
  }
}

// Provider for the alarm sound service
final alarmSoundServiceProvider = Provider<AlarmSoundService>((ref) {
  throw UnimplementedError('alarmSoundServiceProvider must be overridden');
});

// Provider for available alarm sounds (loads from device)
final availableAlarmSoundsProvider = FutureProvider<List<AlarmSoundOption>>((ref) async {
  final service = ref.watch(alarmSoundServiceProvider);
  return await service.getAvailableAlarmSounds();
});

// Provider for the currently selected alarm sound
final selectedAlarmSoundProvider = Provider<AlarmSoundOption?>((ref) {
  final service = ref.watch(alarmSoundServiceProvider);
  final uri = service.getSelectedSoundUri();
  final title = service.getSelectedSoundTitle();
  
  if (uri == null || title == null) return null;
  
  return AlarmSoundOption(title: title, uri: uri);
});
