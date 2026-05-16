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
      await sut.setSelectedSound(
        'file:///storage/emulated/0/Download/custom.mp3',
        'Custom tone',
      );

      // Assert
      expect(sut.getSelectedSoundUri(), 'content://media/external/audio/media/42');
      expect(sut.getSelectedSoundTitle(), 'Custom tone');
    });

    test('should leave prefs untouched when native rejects the selected sound', () async {
      // Arrange
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.method, 'setAlarmSound');
        return null;
      });
      final sut = await createService();

      // Act
      final future = sut.setSelectedSound('file:///missing.mp3', 'Broken tone');

      // Assert
      await expectLater(future, throwsStateError);
      expect(sut.getSelectedSoundUri(), isNull);
      expect(sut.getSelectedSoundTitle(), isNull);
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
}