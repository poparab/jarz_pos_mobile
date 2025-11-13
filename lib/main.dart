import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/env/env.dart';

import 'src/core/app.dart';
import 'src/core/localization/locale_notifier.dart';
import 'src/features/settings/data/alarm_sound_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (supports --dart-define=ENV=local|staging|prod)
  await loadEnv();

  // Initialize Firebase only on mobile platforms (not web)
  // Web requires explicit FirebaseOptions which we don't have configured
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox(localeSettingsBoxName);

  // Initialize SharedPreferences for alarm sound settings
  final prefs = await SharedPreferences.getInstance();

  // Set landscape orientation for POS system (web will ignore this)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        alarmSoundServiceProvider.overrideWithValue(AlarmSoundService(prefs)),
      ],
      child: const JarzPosApp(),
    ),
  );
}
