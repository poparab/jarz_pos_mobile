import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import '../../../core/firebase/firebase_runtime_config.dart';
import '../../../core/utils/logger.dart';
import 'web_push_paths.dart';
import 'web_push_registration_result.dart';

@JS('firebase_messaging.getMessaging')
external _WebMessagingJsImpl _getWebMessaging();

@JS('firebase_messaging.getToken')
external JSPromise<JSString> _getWebPushToken(
  _WebMessagingJsImpl messaging,
  _WebGetTokenOptions options,
);

@JS()
@staticInterop
class _WebMessagingJsImpl {}

@JS()
@staticInterop
@anonymous
class _WebGetTokenOptions {
  external factory _WebGetTokenOptions({
    JSString? vapidKey,
    web.ServiceWorkerRegistration? serviceWorkerRegistration,
  });
}

class WebPushRegistrationService {
  static final Logger _logger = Logger('WebPushRegistrationService');

  static String get _webAppBasePath => normalizeWebAppBasePath(Uri.base.path);

  static String get _serviceWorkerUrl =>
      buildWebAppAssetUrl(_webAppBasePath, 'firebase-messaging-sw.js');

  static String get _serviceWorkerScope => _webAppBasePath;

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

      final registration = await _ensureServiceWorkerRegistration();
      final token = await _getTokenWithServiceWorker(registration);
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

  static Future<web.ServiceWorkerRegistration> _ensureServiceWorkerRegistration() async {
    final container = web.window.navigator.serviceWorker;
    final existingRegistration = await container
        .getRegistration(_serviceWorkerScope)
        .toDart;
    if (existingRegistration != null) {
      return existingRegistration;
    }

    final registration = await container
        .register(
          _serviceWorkerUrl.toJS,
          web.RegistrationOptions(scope: _serviceWorkerScope),
        )
        .toDart;

    try {
      return await container.ready.toDart;
    } catch (_) {
      return registration;
    }
  }

  static Future<String?> _getTokenWithServiceWorker(
    web.ServiceWorkerRegistration registration,
  ) async {
    try {
      final token = await _getWebPushToken(
        _getWebMessaging(),
        _WebGetTokenOptions(
          vapidKey: FirebaseRuntimeConfig.webVapidKey.toJS,
          serviceWorkerRegistration: registration,
        ),
      ).toDart;
      return token.toDart;
    } catch (error) {
      if (!error.toString().toLowerCase().contains('no active service worker')) {
        rethrow;
      }

      final readyRegistration = await web.window.navigator.serviceWorker.ready.toDart;
      final token = await _getWebPushToken(
        _getWebMessaging(),
        _WebGetTokenOptions(
          vapidKey: FirebaseRuntimeConfig.webVapidKey.toJS,
          serviceWorkerRegistration: readyRegistration,
        ),
      ).toDart;
      return token.toDart;
    }
  }
}