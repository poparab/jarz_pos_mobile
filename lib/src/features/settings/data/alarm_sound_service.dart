import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Pick a custom alarm sound file from device storage
  Future<AlarmSoundOption?> pickCustomAlarmSound() async {
    try {
      // Request storage permission first
      if (kDebugMode) {
        debugPrint('Requesting storage permission...');
      }
      PermissionStatus status;
      
      // For Android 13+ (API 33+), request READ_MEDIA_AUDIO
      // For Android 12 and below, request READ_EXTERNAL_STORAGE
      if (await Permission.audio.isGranted) {
        status = PermissionStatus.granted;
        if (kDebugMode) {
          debugPrint('Audio permission already granted');
        }
      } else {
        status = await Permission.audio.request();
        if (kDebugMode) {
          debugPrint('Audio permission status: $status');
        }
        
        if (status.isDenied || status.isPermanentlyDenied) {
          // Try READ_EXTERNAL_STORAGE for older Android versions
          if (kDebugMode) {
            debugPrint('Trying READ_EXTERNAL_STORAGE permission...');
          }
          status = await Permission.storage.request();
          if (kDebugMode) {
            debugPrint('Storage permission status: $status');
          }
        }
      }
      
      if (!status.isGranted) {
        if (kDebugMode) {
          debugPrint('Storage permission not granted: $status');
        }
        throw Exception('Storage permission is required to browse audio files');
      }
      
      if (kDebugMode) {
        debugPrint('Opening file picker...');
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'],
        allowMultiple: false,
      );

      if (kDebugMode) {
        debugPrint('File picker result: ${result?.files.length ?? 0} files');
      }
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final fileName = file.name;
        
        if (kDebugMode) {
          debugPrint('Selected file: $fileName');
          debugPrint('File path: ${file.path}');
        }
        
        // For Android, we need to use the URI if available, otherwise use file path
        String uri;
        if (file.path != null) {
          uri = 'file://${file.path}';
          if (kDebugMode) {
            debugPrint('Using file URI: $uri');
          }
        } else {
          if (kDebugMode) {
            debugPrint('No file path available');
          }
          return null;
        }
        
        return AlarmSoundOption(
          title: fileName,
          uri: uri,
        );
      } else {
        if (kDebugMode) {
          debugPrint('No file selected');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error picking alarm sound: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
    return null;
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
