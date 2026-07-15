import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jarz_pos/src/core/constants/storage_keys.dart';
import 'package:jarz_pos/src/features/settings/data/alarm_sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannels.orderAlertNative);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<AlarmSoundService> createService([
    Map<String, Object> initialValues = const <String, Object>{},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final prefs = await SharedPreferences.getInstance();
    return AlarmSoundService(prefs);
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('AlarmSoundService.setSelectedSound', () {
    test('should persist native-applied uri when native canonicalises selection', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        expect(call.arguments, {'uri': 'file:///storage/emulated/0/Download/custom.mp3'});
        return 'content://media/external/audio/media/42';
      });
      final sut = await createService();

      // Act
      final result = await sut.setSelectedSound(
        'file:///storage/emulated/0/Download/custom.mp3',
        'Custom tone',
      );

      // Assert
      expect(result.isApplied, isTrue);
      expect(result.status, AlarmSoundSelectionStatus.applied);
      expect(result.uri, 'content://media/external/audio/media/42');
      expect(sut.getSelectedSoundUri(), 'content://media/external/audio/media/42');
      expect(sut.getSelectedSoundTitle(), 'Custom tone');
    });

    test('should report fallback instead of throwing when native rejects the selected sound', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        return null;
      });
      final sut = await createService();

      // Act
      final result = await sut.setSelectedSound('file:///missing.mp3', 'Broken tone');

      // Assert
      expect(result.isApplied, isFalse);
      expect(result.status, AlarmSoundSelectionStatus.fallbackToDefault);
      expect(sut.getSelectedSoundUri(), isNull);
      expect(sut.getSelectedSoundTitle(), isNull);
    });

    test('should keep the previous working sound when native rejects a new selection', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        return null;
      });
      final sut = await createService({
        PrefKeys.alarmSoundUri: 'content://media/external/audio/media/7',
        PrefKeys.alarmSoundTitle: 'Working tone',
      });

      // Act
      final result = await sut.setSelectedSound('file:///missing.mp3', 'Broken tone');

      // Assert
      expect(result.isApplied, isFalse);
      expect(sut.getSelectedSoundUri(), 'content://media/external/audio/media/7');
      expect(sut.getSelectedSoundTitle(), 'Working tone');
    });

    test('should fall back to the default sound when the native channel throws', () async {
      // Arrange — a device that raises rather than returning null must not crash
      // the app or reach Sentry as a fatal error.
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        throw PlatformException(code: 'RINGTONE_UNAVAILABLE');
      });
      final sut = await createService();

      // Act
      final result = await sut.setSelectedSound('file:///missing.mp3', 'Broken tone');

      // Assert
      expect(result.isApplied, isFalse);
      expect(result.status, AlarmSoundSelectionStatus.fallbackToDefault);
      expect(sut.getSelectedSoundUri(), isNull);
    });
  });

  group('AlarmSoundService.restoreSelectedSoundOnNative', () {
    test('should refresh saved uri when native canonicalises stored selection', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        expect(call.arguments, {'uri': 'file:///storage/emulated/0/Download/custom.mp3'});
        return 'content://media/external/audio/media/84';
      });
      final sut = await createService({
        PrefKeys.alarmSoundUri: 'file:///storage/emulated/0/Download/custom.mp3',
        PrefKeys.alarmSoundTitle: 'Saved tone',
      });

      // Act
      await sut.restoreSelectedSoundOnNative();

      // Assert
      expect(sut.getSelectedSoundUri(), 'content://media/external/audio/media/84');
      expect(sut.getSelectedSoundTitle(), 'Saved tone');
    });

    test('should clear saved sound when native can no longer apply it', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        return null;
      });
      final sut = await createService({
        PrefKeys.alarmSoundUri: 'file:///storage/emulated/0/Download/missing.mp3',
        PrefKeys.alarmSoundTitle: 'Missing tone',
      });

      // Act
      await sut.restoreSelectedSoundOnNative();

      // Assert
      expect(sut.getSelectedSoundUri(), isNull);
      expect(sut.getSelectedSoundTitle(), isNull);
    });
  });

  group('AlarmSoundService.inMemory', () {
    test('should persist sound selection for the current session without shared preferences', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        return 'content://media/external/audio/media/99';
      });
      final sut = AlarmSoundService.inMemory();

      // Act
      final result = await sut.setSelectedSound('file:///tmp/custom.mp3', 'Session tone');

      // Assert
      expect(result.isApplied, isTrue);
      expect(sut.getSelectedSoundUri(), 'content://media/external/audio/media/99');
      expect(sut.getSelectedSoundTitle(), 'Session tone');
    });
  });
}