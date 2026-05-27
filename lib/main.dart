import 'dart:async';
import 'dart:ui';

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
import 'src/core/debug/app_error_console.dart';
import 'src/core/debug/app_error_reporter.dart';
import 'src/core/firebase/firebase_runtime_config.dart';
import 'src/core/localization/locale_notifier.dart';
import 'src/core/monitoring/sentry_service.dart';
import 'src/core/widgets/orientation_policy_scope.dart';
import 'src/features/settings/data/alarm_sound_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadEnv();
  _installGlobalErrorHandling();

  final sentryConfig = SentryRuntimeConfig.fromEnvironment(
    appEnvironment: resolveEnvName(currentHost: Uri.base.host),
  );

  await runZonedGuarded<Future<void>>(
    () => SentryService.instance.initialize(
      config: sentryConfig,
      appRunner: _bootstrapAndRunApp,
    ),
    (error, stackTrace) {
      AppErrorReporter.instance.capture(
        source: 'Zone',
        error: error,
        stackTrace: stackTrace,
        summary: 'Unhandled asynchronous error',
        fatal: true,
      );
    },
  );
}

Future<void> _bootstrapAndRunApp() async {
  await _initializeFirebaseForCurrentPlatform();

  await Hive.initFlutter();
  await Hive.openBox(localeSettingsBoxName);

  final prefs = await SharedPreferences.getInstance();
  final alarmSoundService = AlarmSoundService(prefs);
  await alarmSoundService.restoreSelectedSoundOnNative();

  if (!kIsWeb) {
    await OrientationPolicyScope.applyDefaultNativePolicy();

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
      observers: [AppProviderObserver()],
      overrides: [
        alarmSoundServiceProvider.overrideWithValue(alarmSoundService),
      ],
      child: const JarzPosApp(),
    ),
  );
}

Future<void> _initializeFirebaseForCurrentPlatform() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  if (kIsWeb) {
    final options = FirebaseRuntimeConfig.webOptions;
    if (options == null) {
      if (FirebaseRuntimeConfig.webPushEnabled) {
        debugPrint('Firebase web push is enabled but Firebase web config is incomplete.');
      }
      return;
    }

    await Firebase.initializeApp(options: options);
    return;
  }

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

void _installGlobalErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppErrorReporter.instance.captureFlutterError(details);
  };

  ErrorWidget.builder = buildAppErrorWidget;

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppErrorReporter.instance.capture(
      source: 'PlatformDispatcher',
      error: error,
      stackTrace: stackTrace,
      summary: 'Unhandled platform error',
      fatal: true,
    );
    return true;
  };
}
