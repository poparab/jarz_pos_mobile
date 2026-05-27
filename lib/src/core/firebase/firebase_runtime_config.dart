import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class FirebaseRuntimeConfig {
  static bool get webPushEnabled => _envBool('WEB_PUSH_ENABLED');

  static String get webVapidKey => _env('FIREBASE_WEB_VAPID_KEY');

  static FirebaseOptions? get webOptions {
    final apiKey = _env('FIREBASE_WEB_API_KEY');
    final appId = _env('FIREBASE_WEB_APP_ID');
    final messagingSenderId = _env('FIREBASE_WEB_MESSAGING_SENDER_ID');
    final projectId = _env('FIREBASE_WEB_PROJECT_ID');

    if ([apiKey, appId, messagingSenderId, projectId].any((value) => value.isEmpty)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: _envOrNull('FIREBASE_WEB_AUTH_DOMAIN'),
      storageBucket: _envOrNull('FIREBASE_WEB_STORAGE_BUCKET'),
      measurementId: _envOrNull('FIREBASE_WEB_MEASUREMENT_ID'),
    );
  }

  static String _env(String key) => dotenv.env[key]?.trim() ?? '';

  static String? _envOrNull(String key) {
    final value = _env(key);
    return value.isEmpty ? null : value;
  }

  static bool _envBool(String key) {
    final value = _env(key).toLowerCase();
    return value == '1' || value == 'true' || value == 'yes' || value == 'on';
  }
}