// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:firebase_core/firebase_core.dart';

import '../../../core/firebase/firebase_runtime_config.dart';
import '../../../core/utils/logger.dart';
import 'web_push_enable_diagnostics.dart';
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
    var diagnostics = _newDiagnostics();
    if (!WebNotificationService.hasGrantedPermissionNow) {
      diagnostics = diagnostics.copyWith(
        failingStep: 'permission_check',
        permissionStatus: WebNotificationService.permissionStatus,
        failureReason: 'permission_not_granted',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.permissionRequired,
        message: 'Tap Enable Notifications to allow web push on this device.',
        diagnostics: diagnostics,
      );
    }

    diagnostics = diagnostics.copyWith(
      permissionStatus: WebNotificationService.permissionStatus,
    );
    return _getTokenDirectly(diagnostics: diagnostics);
  }

  static Future<WebPushRegistrationResult> requestToken() async {
    var diagnostics = _newDiagnostics();
    if (!FirebaseRuntimeConfig.webPushEnabled) {
      diagnostics = diagnostics.copyWith(
        failingStep: 'config',
        failureReason: 'web_push_disabled',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.disabled,
        message: 'Web push notifications are disabled for this environment.',
        diagnostics: diagnostics,
      );
    }

    if (FirebaseRuntimeConfig.webVapidKey.isEmpty || Firebase.apps.isEmpty) {
      diagnostics = diagnostics.copyWith(
        failingStep: 'firebase_ready',
        failureReason: 'firebase_missing_config_or_init',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.missingConfig,
        message: 'Web push notifications are not configured for this environment.',
        diagnostics: diagnostics,
      );
    }

    final permission = await WebNotificationService.requestPermissionStatus(
      timeout: _permissionTimeout,
    );
    diagnostics = diagnostics.copyWith(
      permissionStatus: permission,
    );
    if (permission != 'granted') {
      diagnostics = diagnostics.copyWith(
        failingStep: 'permission_prompt',
        failureReason: 'permission_not_granted',
      );
      return webPushPermissionNotGrantedResult(permission, diagnostics: diagnostics);
    }

    return _getTokenDirectly(diagnostics: diagnostics);
  }

  static Stream<String> tokenRefreshStream() {
    return const Stream.empty();
  }

  static Future<WebPushRegistrationResult> _getTokenDirectly({
    WebPushEnableDiagnostics? diagnostics,
  }) async {
    var state = diagnostics ?? _newDiagnostics();
    if (!FirebaseRuntimeConfig.webPushEnabled) {
      state = state.copyWith(
        failingStep: 'config',
        failureReason: 'web_push_disabled',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.disabled,
        message: 'Web push notifications are disabled for this environment.',
        diagnostics: state,
      );
    }

    if (FirebaseRuntimeConfig.webVapidKey.isEmpty || Firebase.apps.isEmpty) {
      state = state.copyWith(
        failingStep: 'firebase_ready',
        firebaseInitialized: Firebase.apps.isNotEmpty,
        firebaseOptionsReady: FirebaseRuntimeConfig.webOptions != null,
        failureReason: 'firebase_missing_config_or_init',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.missingConfig,
        message: 'Web push notifications are not configured for this environment.',
        diagnostics: state,
      );
    }

    try {
      if (!WebNotificationService.isSupported) {
        state = state.copyWith(
          failingStep: 'browser_support',
          notificationSupported: false,
          serviceWorkerSupported: _serviceWorkerContainer() != null,
          failureReason: 'notification_api_unsupported',
        );
        return WebPushRegistrationResult(
          status: WebPushRegistrationStatus.unsupported,
          message: 'This browser does not support notification permission prompts.',
          diagnostics: state,
        );
      }

      if (!WebNotificationService.hasGrantedPermissionNow) {
        state = state.copyWith(
          failingStep: 'permission_check',
          permissionStatus: WebNotificationService.permissionStatus,
          notificationSupported: true,
          serviceWorkerSupported: _serviceWorkerContainer() != null,
          failureReason: 'permission_not_granted',
        );
        return WebPushRegistrationResult(
          status: WebPushRegistrationStatus.permissionRequired,
          message: 'Tap Enable Notifications to allow web push on this device.',
          diagnostics: state,
        );
      }

      final registration = await _ensureServiceWorkerRegistration().timeout(
        _serviceWorkerTimeout,
      );
      state = state.copyWith(
        failingStep: 'service_worker',
        permissionStatus: WebNotificationService.permissionStatus,
        notificationSupported: true,
        serviceWorkerSupported: registration.registration != null,
        existingRegistrationScope: registration.existingRegistrationScope,
        readyRegistrationScope: registration.readyRegistrationScope,
      );
      if (registration.registration == null) {
        state = state.copyWith(
          failureReason: 'service_worker_unavailable',
          tokenState: 'unavailable',
        );
        return WebPushRegistrationResult(
          status: WebPushRegistrationStatus.unsupported,
          message:
              'Notification service worker is not available in this browser context. Reopen the Home Screen app and try again.',
          diagnostics: state,
        );
      }

      final tokenResolution = await _getTokenWithServiceWorker(
        registration.registration!,
      ).timeout(
        _tokenTimeout,
      );
      state = state.copyWith(
        failingStep: tokenResolution.token == null ? 'token_request' : 'token_ready',
        messagingLibraryAvailable: tokenResolution.messagingLibraryAvailable,
        messagingResolved: tokenResolution.messagingResolved,
        tokenState: tokenResolution.tokenState,
        failureReason: tokenResolution.failureReason,
        errorSummary: tokenResolution.errorSummary,
      );
      final token = tokenResolution.token;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          failureReason: state.failureReason ?? 'token_missing',
        );
        return WebPushRegistrationResult(
          status: WebPushRegistrationStatus.noToken,
          message: 'No web push token is available yet. Try again after reopening the app.',
          diagnostics: state,
        );
      }

      state = state.copyWith(
        failingStep: 'token_ready',
        tokenState: 'ready',
        clearFailureReason: true,
        clearErrorSummary: true,
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.tokenReady,
        message: 'Web push token is ready for registration.',
        token: token,
        diagnostics: state,
      );
    } on TimeoutException catch (error, stackTrace) {
      _logger.error('Web push registration timed out', error, stackTrace);
      final currentDiagnostics = state.copyWith(
        failingStep: state.failingStep ?? 'timeout',
        failureReason: 'timeout',
        errorSummary: error.toString(),
      );
      return webPushTimedOutResult(
        'Notification setup',
        diagnostics: currentDiagnostics,
      );
    } catch (error, stackTrace) {
      _logger.error('Failed to get web push token', error, stackTrace);
      final currentDiagnostics = state.copyWith(
        failingStep: state.failingStep ?? 'exception',
        failureReason: state.failureReason ?? 'unexpected_exception',
        errorSummary: error.toString(),
      );
      _logger.warning('Web push diagnostics: ${currentDiagnostics.toCompactSummary()}');
      return webPushFailedFromException(error, diagnostics: currentDiagnostics);
    }
  }

  static Future<_ServiceWorkerResolution> _ensureServiceWorkerRegistration() async {
    final container = _serviceWorkerContainer();
    if (container == null) {
      return const _ServiceWorkerResolution();
    }

    final existingRegistration = await _getExistingServiceWorkerRegistration(
      container,
    ).timeout(_serviceWorkerTimeout);
    if (existingRegistration != null) {
      final scope = _registrationScope(existingRegistration);
      return _ServiceWorkerResolution(
        registration: existingRegistration,
        existingRegistrationScope: scope,
        readyRegistrationScope: scope,
      );
    }

    final registration = await _registerServiceWorker(container).timeout(
      _serviceWorkerTimeout,
    );

    try {
      final readyRegistration = await _getReadyServiceWorkerRegistration(
        container,
      ).timeout(_serviceWorkerTimeout);
      return _ServiceWorkerResolution(
        registration: readyRegistration ?? registration,
        readyRegistrationScope: _registrationScope(readyRegistration ?? registration),
      );
    } on TimeoutException {
      return _ServiceWorkerResolution(
        registration: registration,
        readyRegistrationScope: _registrationScope(registration),
      );
    }
  }

  static Future<_TokenResolution> _getTokenWithServiceWorker(
    Object registration,
  ) async {
    final messagingResolution = _resolveWebMessaging();
    if (!messagingResolution.messagingLibraryAvailable) {
      return const _TokenResolution(
        messagingLibraryAvailable: false,
        messagingResolved: false,
        tokenState: 'messaging-unavailable',
        failureReason: 'messaging_library_unavailable',
      );
    }
    if (!messagingResolution.messagingResolved || messagingResolution.messaging == null) {
      return const _TokenResolution(
        messagingLibraryAvailable: true,
        messagingResolved: false,
        tokenState: 'messaging-unavailable',
        failureReason: 'messaging_instance_unavailable',
      );
    }

    try {
      final tokenValue = await _getWebPushToken(
        messagingResolution.messaging!,
        registration,
      ).timeout(_tokenTimeout);
      return _tokenResolutionFromValue(
        tokenValue,
        messagingLibraryAvailable: true,
        messagingResolved: true,
      );
    } catch (error) {
      if (!error.toString().toLowerCase().contains('no active service worker')) {
        return _TokenResolution(
          messagingLibraryAvailable: true,
          messagingResolved: true,
          tokenState: 'error',
          failureReason: 'token_request_failed',
          errorSummary: error.toString(),
        );
      }

      final container = _serviceWorkerContainer();
      final readyRegistration = container == null
          ? null
          : await _getReadyServiceWorkerRegistration(
              container,
            ).timeout(_serviceWorkerTimeout);
      if (readyRegistration == null) {
        return const _TokenResolution(
          messagingLibraryAvailable: true,
          messagingResolved: true,
          tokenState: 'service-worker-unready',
          failureReason: 'service_worker_ready_missing',
        );
      }

      try {
        final tokenValue = await _getWebPushToken(
          messagingResolution.messaging!,
          readyRegistration,
        ).timeout(_tokenTimeout);
        return _tokenResolutionFromValue(
          tokenValue,
          messagingLibraryAvailable: true,
          messagingResolved: true,
        );
      } catch (retryError) {
        return _TokenResolution(
          messagingLibraryAvailable: true,
          messagingResolved: true,
          tokenState: 'error',
          failureReason: 'token_request_retry_failed',
          errorSummary: retryError.toString(),
        );
      }
    }
  }

  static Object? _serviceWorkerContainer() {
    try {
      return js_util.getProperty<Object?>(html.window.navigator, 'serviceWorker');
    } catch (_) {
      return null;
    }
  }

  static WebPushEnableDiagnostics _newDiagnostics() {
    return WebPushEnableDiagnostics(
      currentPath: Uri.base.path,
      basePath: _webAppBasePath,
      serviceWorkerScope: _serviceWorkerScope,
      serviceWorkerUrl: _serviceWorkerUrl,
      webPushEnabled: FirebaseRuntimeConfig.webPushEnabled,
      firebaseOptionsReady: FirebaseRuntimeConfig.webOptions != null,
      firebaseInitialized: Firebase.apps.isNotEmpty,
      permissionStatus: WebNotificationService.permissionStatus,
      notificationSupported: WebNotificationService.isSupported,
      serviceWorkerSupported: _serviceWorkerContainer() != null,
    );
  }

  static String? _registrationScope(Object? registration) {
    if (registration == null) {
      return null;
    }

    try {
      return js_util.getProperty<Object?>(registration, 'scope')?.toString();
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

  static _MessagingResolution _resolveWebMessaging() {
    final firebaseMessaging = _firebaseMessagingLibrary();
    if (firebaseMessaging == null) {
      return const _MessagingResolution(
        messagingLibraryAvailable: false,
        messagingResolved: false,
      );
    }

    final messaging = js_util.callMethod<Object?>(
      firebaseMessaging,
      'getMessaging',
      const <Object?>[],
    );
    if (messaging == null) {
      return const _MessagingResolution(
        messagingLibraryAvailable: true,
        messagingResolved: false,
      );
    }

    return _MessagingResolution(
      messagingLibraryAvailable: true,
      messagingResolved: true,
      messaging: messaging,
    );
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

  static _TokenResolution _tokenResolutionFromValue(
    Object? value, {
    required bool messagingLibraryAvailable,
    required bool messagingResolved,
  }) {
    final dartifiedValue = _dartifyWebPushTokenValue(value);
    final token = normalizeWebPushTokenCandidate(dartifiedValue);
    if (token == null || token.isEmpty) {
      final rawValue = dartifiedValue?.toString();
      final failureReason = rawValue == null || rawValue.trim().isEmpty
          ? 'token_missing'
          : 'token_normalized_empty';
      return _TokenResolution(
        messagingLibraryAvailable: messagingLibraryAvailable,
        messagingResolved: messagingResolved,
        tokenState: 'missing',
        failureReason: failureReason,
        errorSummary: rawValue,
      );
    }

    return _TokenResolution(
      token: token,
      messagingLibraryAvailable: messagingLibraryAvailable,
      messagingResolved: messagingResolved,
      tokenState: 'ready',
    );
  }
}

class _ServiceWorkerResolution {
  const _ServiceWorkerResolution({
    this.registration,
    this.existingRegistrationScope,
    this.readyRegistrationScope,
  });

  final Object? registration;
  final String? existingRegistrationScope;
  final String? readyRegistrationScope;
}

class _MessagingResolution {
  const _MessagingResolution({
    required this.messagingLibraryAvailable,
    required this.messagingResolved,
    this.messaging,
  });

  final bool messagingLibraryAvailable;
  final bool messagingResolved;
  final Object? messaging;
}

class _TokenResolution {
  const _TokenResolution({
    this.token,
    required this.messagingLibraryAvailable,
    required this.messagingResolved,
    required this.tokenState,
    this.failureReason,
    this.errorSummary,
  });

  final String? token;
  final bool messagingLibraryAvailable;
  final bool messagingResolved;
  final String tokenState;
  final String? failureReason;
  final String? errorSummary;
}