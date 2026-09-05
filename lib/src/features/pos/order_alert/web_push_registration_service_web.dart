import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:web/web.dart' as web;

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

  // Register the Firebase messaging worker at a dedicated sub-scope so it is its
  // own registration and never competes with Flutter's root service worker at
  // the app base path. A push subscription is delivered to the worker that owns
  // it regardless of which worker controls the page, so a narrower scope is fine
  // and keeps Flutter's offline worker intact. Kept in sync with
  // VapidSubscriptionService and the `push/` suffix firebase-messaging-sw.js strips.
  static String get _serviceWorkerScope {
    final base = _webAppBasePath;
    return base == '/' ? '/push/' : '${base}push/';
  }

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

    if (!WebNotificationService.isSupported) {
      diagnostics = diagnostics.copyWith(
        failingStep: 'browser_support',
        notificationSupported: false,
        serviceWorkerSupported: _serviceWorkerContainer() != null,
        failureReason: 'notification_api_unsupported',
      );
      return WebPushRegistrationResult(
        status: WebPushRegistrationStatus.unsupported,
        message: 'This browser does not support notification permission prompts.',
        diagnostics: diagnostics,
      );
    }

    // iOS requires Notification.requestPermission() to be the very first async
    // call triggered by a user tap. All Firebase checks come AFTER to preserve
    // the browser's gesture-activation context.
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

  // Safely ensures Firebase is initialized, attempting init if needed.
  // Never throws — returns false if Firebase cannot be made ready.
  static Future<bool> _ensureFirebaseReady() async {
    try {
      if (Firebase.apps.isNotEmpty) return true;
      final options = FirebaseRuntimeConfig.webOptions;
      if (options == null) return false;
      await Firebase.initializeApp(options: options);
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Registers the Firebase messaging service worker at app startup so it is
  // already in "active" state before the user taps Enable Notifications.
  // Non-fatal: errors are swallowed and registration is retried later.
  static Future<void> initServiceWorker() async {
    if (!FirebaseRuntimeConfig.webPushEnabled) return;
    try {
      await _ensureServiceWorkerRegistration().timeout(
        const Duration(seconds: 10),
      );
    } catch (_) {
      // Non-fatal: service worker will be re-registered when the user taps
      // Enable Notifications inside _getTokenDirectly().
    }
  }

  static WebPushEnableDiagnostics captureEmergencyDiagnostics({
    String failingStep = 'request_token_exception',
    String? failureReason,
    Object? error,
  }) {
    return _newDiagnostics().copyWith(
      failingStep: failingStep,
      failureReason: failureReason ?? 'request_token_exception',
      errorSummary: error?.toString(),
    );
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

    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady || FirebaseRuntimeConfig.webVapidKey.isEmpty) {
      state = state.copyWith(
        failingStep: 'firebase_ready',
        firebaseInitialized: _safeFirebaseInitialized(),
        firebaseOptionsReady: FirebaseRuntimeConfig.webOptions != null,
        failureReason: !firebaseReady ? 'firebase_missing_config_or_init' : 'vapid_key_missing',
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
    web.ServiceWorkerRegistration registration,
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

  /// `navigator.serviceWorker` is undefined in insecure contexts and some
  /// embedded browsers. package:web types it non-null, so read it dynamically.
  static web.ServiceWorkerContainer? _serviceWorkerContainer() {
    try {
      final value = web.window.navigator['serviceWorker'];
      if (value.isUndefinedOrNull) return null;
      return value as web.ServiceWorkerContainer;
    } catch (_) {
      return null;
    }
  }

  static WebPushEnableDiagnostics _newDiagnostics() {
    return WebPushEnableDiagnostics(
      currentPath: _safeCurrentPath(),
      basePath: _safeWebAppBasePath(),
      serviceWorkerScope: _safeServiceWorkerScope(),
      serviceWorkerUrl: _safeServiceWorkerUrl(),
      webPushEnabled: FirebaseRuntimeConfig.webPushEnabled,
      firebaseOptionsReady: FirebaseRuntimeConfig.webOptions != null,
      firebaseInitialized: _safeFirebaseInitialized(),
      permissionStatus: _safePermissionStatus(),
      notificationSupported: _safeNotificationSupported(),
      serviceWorkerSupported: _safeServiceWorkerSupported(),
    );
  }

  static String _safeCurrentPath() {
    try {
      return Uri.base.path;
    } catch (_) {
      return '/unknown';
    }
  }

  static String _safeWebAppBasePath() {
    try {
      return normalizeWebAppBasePath(_safeCurrentPath());
    } catch (_) {
      return '/';
    }
  }

  static String _safeServiceWorkerScope() {
    return _safeWebAppBasePath();
  }

  static String _safeServiceWorkerUrl() {
    try {
      return buildWebAppAssetUrl(_safeWebAppBasePath(), 'firebase-messaging-sw.js');
    } catch (_) {
      return 'firebase-messaging-sw.js';
    }
  }

  static bool _safeFirebaseInitialized() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static String _safePermissionStatus() {
    try {
      return WebNotificationService.permissionStatus;
    } catch (_) {
      return 'unknown';
    }
  }

  static bool? _safeNotificationSupported() {
    try {
      return WebNotificationService.isSupported;
    } catch (_) {
      return null;
    }
  }

  static bool? _safeServiceWorkerSupported() {
    try {
      return _serviceWorkerContainer() != null;
    } catch (_) {
      return null;
    }
  }

  static String? _registrationScope(web.ServiceWorkerRegistration? registration) {
    if (registration == null) {
      return null;
    }

    try {
      return registration.scope;
    } catch (_) {
      return null;
    }
  }

  static Future<web.ServiceWorkerRegistration?> _getExistingServiceWorkerRegistration(
    web.ServiceWorkerContainer container,
  ) async {
    try {
      return await container.getRegistration(_serviceWorkerScope).toDart;
    } catch (_) {
      return null;
    }
  }

  static Future<web.ServiceWorkerRegistration?> _registerServiceWorker(
    web.ServiceWorkerContainer container,
  ) async {
    try {
      return await container
          .register(
            _serviceWorkerUrl.toJS,
            web.RegistrationOptions(scope: _serviceWorkerScope),
          )
          .toDart;
    } catch (error) {
      throw StateError('Notification service worker registration failed: $error');
    }
  }

  static Future<web.ServiceWorkerRegistration?> _getReadyServiceWorkerRegistration(
    web.ServiceWorkerContainer container,
  ) async {
    try {
      return await container.ready.toDart;
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

    final messaging = firebaseMessaging.callMethod<JSObject?>('getMessaging'.toJS);
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

  /// The Firebase compat bundle that build_release.sh ships next to the app
  /// exposes itself as `window.firebase_messaging`.
  static JSObject? _firebaseMessagingLibrary() {
    try {
      final value = globalContext['firebase_messaging'];
      if (value.isUndefinedOrNull) return null;
      return value as JSObject;
    } catch (_) {
      return null;
    }
  }

  static Future<JSAny?> _getWebPushToken(
    JSObject messaging,
    web.ServiceWorkerRegistration registration,
  ) async {
    final firebaseMessaging = _firebaseMessagingLibrary();
    if (firebaseMessaging == null) {
      throw UnsupportedError('Firebase web messaging is unavailable in this browser context.');
    }

    final options = JSObject()
      ..setProperty('vapidKey'.toJS, FirebaseRuntimeConfig.webVapidKey.toJS)
      ..setProperty('serviceWorkerRegistration'.toJS, registration);

    final tokenPromise = firebaseMessaging.callMethod<JSPromise<JSAny?>?>(
      'getToken'.toJS,
      messaging,
      options,
    );
    if (tokenPromise == null) {
      return null;
    }

    return tokenPromise.toDart;
  }

  static Object? _dartifyWebPushTokenValue(JSAny? value) {
    if (value == null) {
      return null;
    }

    return value.dartify();
  }

  static _TokenResolution _tokenResolutionFromValue(
    JSAny? value, {
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

  /// Test seam: drives the `window.firebase_messaging` bridge exactly as
  /// [_getTokenWithServiceWorker] does - resolve the library, call
  /// `getMessaging`, call `getToken` with the options object, dartify and
  /// normalise the result - minus the Firebase-init and permission gates a
  /// browser test cannot satisfy. The registration is passed through untouched.
  @visibleForTesting
  static Future<({bool libraryAvailable, bool resolved, String? token})>
      resolveTokenThroughMessagingBridge(
    web.ServiceWorkerRegistration registration,
  ) async {
    final messaging = _resolveWebMessaging();
    if (!messaging.messagingResolved || messaging.messaging == null) {
      return (
        libraryAvailable: messaging.messagingLibraryAvailable,
        resolved: false,
        token: null,
      );
    }

    final value = await _getWebPushToken(messaging.messaging!, registration);
    final resolution = _tokenResolutionFromValue(
      value,
      messagingLibraryAvailable: true,
      messagingResolved: true,
    );
    return (libraryAvailable: true, resolved: true, token: resolution.token);
  }
}

class _ServiceWorkerResolution {
  const _ServiceWorkerResolution({
    this.registration,
    this.existingRegistrationScope,
    this.readyRegistrationScope,
  });

  final web.ServiceWorkerRegistration? registration;
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
  final JSObject? messaging;
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