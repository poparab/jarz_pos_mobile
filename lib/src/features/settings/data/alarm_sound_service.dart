import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available alarm sounds for order notifications
enum AlarmSound {
  defaultAlarm('Default Alarm', 'default'),
  beep('Beep', 'beep'),
  chime('Chime', 'chime'),
  bell('Bell', 'bell'),
  siren('Siren', 'siren');

  final String displayName;
  final String value;

  const AlarmSound(this.displayName, this.value);

  static AlarmSound fromValue(String value) {
    return AlarmSound.values.firstWhere(
      (sound) => sound.value == value,
      orElse: () => AlarmSound.defaultAlarm,
    );
  }
}

class AlarmSoundService {
  static const String _alarmSoundKey = 'alarm_sound_preference';
  final SharedPreferences _prefs;

  AlarmSoundService(this._prefs);

  /// Get the currently selected alarm sound
  AlarmSound getSelectedSound() {
    final value = _prefs.getString(_alarmSoundKey);
    if (value == null) return AlarmSound.defaultAlarm;
    return AlarmSound.fromValue(value);
  }

  /// Set the alarm sound preference
  Future<void> setSelectedSound(AlarmSound sound) async {
    await _prefs.setString(_alarmSoundKey, sound.value);
  }
}

// Provider for the alarm sound service
final alarmSoundServiceProvider = Provider<AlarmSoundService>((ref) {
  throw UnimplementedError('alarmSoundServiceProvider must be overridden');
});

// Provider for the current alarm sound
final selectedAlarmSoundProvider = StateProvider<AlarmSound>((ref) {
  final service = ref.watch(alarmSoundServiceProvider);
  return service.getSelectedSound();
});
