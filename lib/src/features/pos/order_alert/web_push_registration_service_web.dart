import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/firebase/firebase_runtime_config.dart';
import '../../../core/utils/logger.dart';
import 'web_push_registration_result.dart';

class WebPushRegistrationService {
  static final Logger _logger = Logger('WebPushRegistrationService');

  static Future<WebPushRegistrationResult> getTokenIfPermissionGranted() {
    return _getToken(requestPermission: false);
  }

  static Future<WebPushRegistrationResult> requestToken() {
    return _getToken(requestPermission: true);
  }

  static Stream<String> tokenRefreshStream() {
    if (!FirebaseRuntimeConfig.webPushEnabled || Firebase.apps.isEmpty) {
      return const Stream.empty();
    }

    try {
      return FirebaseMessaging.instance.onTokenRefresh;
    } catch (error, stackTrace) {
      _logger.error('Unable to subscribe to web FCM token refresh', error, stackTrace);
      return const Stream.empty();
    }
  }

  static Future<WebPushRegistrationResult> _getToken({
    required bool requestPermission,
  }) async {
    if (!FirebaseRuntimeConfig.webPushEnabled) {
      return const WebPushRegistrationResult(
        status: WebPushRegistrationStatus.disabled,
        message: 'Web push notifications are disabled for this environment.',
      );
    }

    if (FirebaseRuntimeConfig.webVapidKey.isEmpty || Firebase.apps.isEmpty) {
      return const WebPushRegistrationResult(
        status: WebPushRegistrationStatus.missingConfig,
        message: 'Web push notifications are not configured for this environment.',
      );
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final supported = await messaging.isSupported();
      if (!supported) {
        return const WebPushRegistrationResult(
          status: WebPushRegistrationStatus.unsupported,
          message: 'This browser does not support web push notifications.',
        );
      }

      final settings = requestPermission
          ? await messaging.requestPermission()
          : await messaging.getNotificationSettings();
      final status = settings.authorizationStatus;
      if (!_isAuthorized(status)) {
        return WebPushRegistrationResult(
          status: requestPermission
              ? WebPushRegistrationStatus.permissionDenied
              : WebPushRegistrationStatus.permissionRequired,
          message: requestPermission
              ? 'Notification permission was not granted.'
              : 'Tap Enable Notifications to allow web push on this device.',
        );
      }

      final token = await messaging.getToken(
        vapidKey: FirebaseRuntimeConfig.webVapidKey,
      );
      if (token == null || token.isEmpty) {
        return const WebPushRegistrationResult(
          status: WebPushRegistrationStatus.noToken,
          message: 'No web push token is available yet. Try again after reopening the app.',
        );
      }

      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.tokenReady,
        message: 'Web push token is ready for registration.',
        token: token,
      );
    } catch (error, stackTrace) {
      _logger.error('Failed to get web push token', error, stackTrace);
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.failed,
        message: 'Failed to prepare web push notifications: $error',
      );
    }
  }

  static bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }
}