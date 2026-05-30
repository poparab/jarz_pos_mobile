// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:firebase_core/firebase_core.dart';

import '../../../core/firebase/firebase_runtime_config.dart';
import '../../../core/utils/logger.dart';
import 'web_notification_service_web.dart';
import 'web_push_paths.dart';
import 'web_push_registration_result.dart';
import 'web_push_token_normalizer.dart';

class WebPushRegistrationService {
  static final Logger _logger = Logger('WebPushRegistrationService');
  static const _permissionTimeout = Duration(seconds: 5);
  static const _serviceWorkerTimeout = Duration(seconds: 7);
  static const _tokenTimeout = Duration(seconds: 10);

  static String get _webAppBasePath => normalizeWebAppBasePath(Uri.base.path);

  static String get _serviceWorkerUrl =>
      buildWebAppAssetUrl(_webAppBasePath, 'firebase-messaging-sw.js');

  static String get _serviceWorkerScope => _webAppBasePath;

  static Future<WebPushRegistrationResult> getTokenIfPermissionGranted() async {
    if (!WebNotificationService.hasGrantedPermissionNow) {
      return const WebPushRegistrationResult(
        status: WebPushRegistrationStatus.permissionRequired,
        message: 'Tap Enable Notifications to allow web push on this device.',
      );
    }

    return _getTokenDirectly();
  }

  static Future<WebPushRegistrationResult> requestToken() async {
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

    final permission = await WebNotificationService.requestPermissionStatus(
      timeout: _permissionTimeout,
    );
    if (permission != 'granted') {
      return webPushPermissionNotGrantedResult(permission);
    }

    return _getTokenDirectly();
  }

  static Stream<String> tokenRefreshStream() {
    return const Stream.empty();
  }

  static Future<WebPushRegistrationResult> _getTokenDirectly() async {
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
      if (!WebNotificationService.isSupported) {
        return const WebPushRegistrationResult(
          status: WebPushRegistrationStatus.unsupported,
          message: 'This browser does not support notification permission prompts.',
        );
      }

      if (!WebNotificationService.hasGrantedPermissionNow) {
        return const WebPushRegistrationResult(
          status: WebPushRegistrationStatus.permissionRequired,
          message: 'Tap Enable Notifications to allow web push on this device.',
        );
      }

      final registration = await _ensureServiceWorkerRegistration().timeout(
        _serviceWorkerTimeout,
      );
      if (registration == null) {
        return const WebPushRegistrationResult(
          status: WebPushRegistrationStatus.unsupported,
          message:
              'Notification service worker is not available in this browser context. Reopen the Home Screen app and try again.',
        );
      }

      final token = await _getTokenWithServiceWorker(registration).timeout(
        _tokenTimeout,
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
    } on TimeoutException catch (error, stackTrace) {
      _logger.error('Web push registration timed out', error, stackTrace);
      return webPushTimedOutResult('Notification setup');
    } catch (error, stackTrace) {
      _logger.error('Failed to get web push token', error, stackTrace);
      return webPushFailedFromException(error);
    }
  }

  static Future<Object?> _ensureServiceWorkerRegistration() async {
    final container = _serviceWorkerContainer();
    if (container == null) {
      return null;
    }

    final existingRegistration = await _getExistingServiceWorkerRegistration(
      container,
    ).timeout(_serviceWorkerTimeout);
    if (existingRegistration != null) {
      return existingRegistration;
    }

    final registration = await _registerServiceWorker(container).timeout(
      _serviceWorkerTimeout,
    );

    try {
      final readyRegistration = await _getReadyServiceWorkerRegistration(
        container,
      ).timeout(_serviceWorkerTimeout);
      return readyRegistration ?? registration;
    } on TimeoutException {
      return registration;
    }
  }

  static Future<String?> _getTokenWithServiceWorker(
    Object registration,
  ) async {
    final messaging = _requireWebMessaging();

    try {
      final tokenValue = await _getWebPushToken(
        messaging,
        registration,
      ).timeout(_tokenTimeout);
      return normalizeWebPushTokenCandidate(_dartifyWebPushTokenValue(tokenValue));
    } catch (error) {
      if (!error.toString().toLowerCase().contains('no active service worker')) {
        rethrow;
      }

      final container = _serviceWorkerContainer();
      final readyRegistration = container == null
          ? null
          : await _getReadyServiceWorkerRegistration(
              container,
            ).timeout(_serviceWorkerTimeout);
      if (readyRegistration == null) {
        return null;
      }

      final tokenValue = await _getWebPushToken(
        _requireWebMessaging(),
        readyRegistration,
      ).timeout(_tokenTimeout);
      return normalizeWebPushTokenCandidate(_dartifyWebPushTokenValue(tokenValue));
    }
  }

  static Object? _serviceWorkerContainer() {
    try {
      return js_util.getProperty<Object?>(html.window.navigator, 'serviceWorker');
    } catch (_) {
      return null;
    }
  }

  static Future<Object?> _getExistingServiceWorkerRegistration(
    Object container,
  ) async {
    try {
      final registrationPromise = js_util.callMethod<Object?>(
        container,
        'getRegistration',
        <Object?>[_serviceWorkerScope],
      );
      if (registrationPromise == null) {
        return null;
      }

      return await js_util.promiseToFuture<Object?>(registrationPromise);
    } catch (_) {
      return null;
    }
  }

  static Future<Object?> _registerServiceWorker(Object container) async {
    try {
      final options = js_util.newObject<Object>();
      js_util.setProperty(options, 'scope', _serviceWorkerScope);

      final registrationPromise = js_util.callMethod<Object?>(
        container,
        'register',
        <Object?>[_serviceWorkerUrl, options],
      );
      if (registrationPromise == null) {
        return null;
      }

      return await js_util.promiseToFuture<Object?>(registrationPromise);
    } catch (error) {
      throw StateError('Notification service worker registration failed: $error');
    }
  }

  static Future<Object?> _getReadyServiceWorkerRegistration(Object container) async {
    try {
      final readyPromise = js_util.getProperty<Object?>(container, 'ready');
      if (readyPromise == null) {
        return null;
      }

      return await js_util.promiseToFuture<Object?>(readyPromise);
    } catch (error) {
      throw StateError('Notification service worker readiness check failed: $error');
    }
  }

  static Object _requireWebMessaging() {
    final firebaseMessaging = _firebaseMessagingLibrary();
    if (firebaseMessaging == null) {
      throw UnsupportedError('Firebase web messaging is unavailable in this browser context.');
    }

    final messaging = js_util.callMethod<Object?>(
      firebaseMessaging,
      'getMessaging',
      const <Object?>[],
    );
    if (messaging == null) {
      throw StateError('Firebase web messaging is unavailable in this browser context.');
    }

    return messaging;
  }

  static Object? _firebaseMessagingLibrary() {
    try {
      return js_util.getProperty<Object?>(html.window, 'firebase_messaging');
    } catch (_) {
      return null;
    }
  }

  static Future<Object?> _getWebPushToken(
    Object messaging,
    Object registration,
  ) async {
    final firebaseMessaging = _firebaseMessagingLibrary();
    if (firebaseMessaging == null) {
      throw UnsupportedError('Firebase web messaging is unavailable in this browser context.');
    }

    final options = js_util.newObject<Object>();
    js_util.setProperty(options, 'vapidKey', FirebaseRuntimeConfig.webVapidKey);
    js_util.setProperty(options, 'serviceWorkerRegistration', registration);

    final tokenPromise = js_util.callMethod<Object?>(
      firebaseMessaging,
      'getToken',
      <Object?>[messaging, options],
    );
    if (tokenPromise == null) {
      return null;
    }

    return js_util.promiseToFuture<Object?>(tokenPromise);
  }

  static Object? _dartifyWebPushTokenValue(Object? value) {
    if (value == null) {
      return null;
    }

    return js_util.dartify(value);
  }
}