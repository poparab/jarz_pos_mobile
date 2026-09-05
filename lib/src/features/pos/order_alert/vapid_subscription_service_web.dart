import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../../core/utils/logger.dart';
import 'data/order_alert_service.dart';
import 'vapid_subscription_result.dart';
import 'web_push_paths.dart';

class VapidSubscriptionService {
  static final Logger _logger = Logger('VapidSubscriptionService');

  /// The application server key is a stable per-site value, so it is fetched
  /// once per session. On iOS this also keeps a retry from spending another
  /// network round-trip between the tap and `subscribe()`.
  static String? _cachedPublicKey;

  /// Requests a new VAPID web push subscription.
  ///
  /// Notification permission must ALREADY be granted. iOS Safari does not
  /// prompt from `pushManager.subscribe()` the way Chrome does — with
  /// permission still `default` the subscribe promise never settles, which at
  /// the call site is indistinguishable from a network stall. The caller
  /// (`OrderAlertBridge.enableWebPushNotifications`) is responsible for calling
  /// `Notification.requestPermission()` first, inside the tap gesture.
  static Future<VapidSubscriptionResult> requestSubscription({
    required OrderAlertService service,
  }) async {
    return _doSubscribe(service: service, forceResubscribe: true);
  }

  /// Silently re-registers a VAPID subscription if permission is already granted.
  /// No-op if permission is "default" or "denied".
  static Future<VapidSubscriptionResult> subscribeIfPermissionGranted({
    required OrderAlertService service,
  }) async {
    final permission = _permissionStatus();
    if (permission == 'unsupported') {
      return const VapidSubscriptionResult(
        status: VapidSubscriptionStatus.unsupported,
        message: 'Notification API not available.',
        failingStep: 'permission',
      );
    }
    if (permission != 'granted') {
      return const VapidSubscriptionResult(
        status: VapidSubscriptionStatus.permissionDenied,
        message: 'Notification permission not yet granted.',
        failingStep: 'permission',
      );
    }
    return _doSubscribe(service: service);
  }

  static Future<VapidSubscriptionResult> _doSubscribe({
    required OrderAlertService service,
    bool forceResubscribe = false,
  }) async {
    // 1. Verify Push API support
    final swContainer = _serviceWorkerContainer();
    if (swContainer == null) {
      return const VapidSubscriptionResult(
        status: VapidSubscriptionStatus.unsupported,
        message: 'Service Worker API not available — upgrade to a modern browser.',
        failingStep: 'service_worker_support',
      );
    }

    // 2. Refuse to subscribe without permission.
    //
    // This guard is the difference between a clear message and a 30-second
    // hang. WebKit does not surface the permission prompt from inside
    // `pushManager.subscribe()`, and with permission at `default` it leaves the
    // returned promise pending rather than rejecting — so the only symptom the
    // user ever saw was "Push subscription timed out", which points at the
    // network instead of at the missing permission.
    final permission = _permissionStatus();
    if (permission != 'granted') {
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.permissionDenied,
        message: permission == 'denied'
            ? 'Notifications are blocked for this app. Delete and re-add the Home Screen app, then choose Allow.'
            : 'Notification permission was not granted. Tap Enable Notifications again and choose Allow.',
        failingStep: 'permission',
      );
    }

    var step = 'key_fetch';
    try {
      // 3. Fetch VAPID public key from backend (cached after the first call)
      final publicKey = _cachedPublicKey ??
          await service.fetchVapidPublicKey().timeout(const Duration(seconds: 10));
      _cachedPublicKey = publicKey;

      // 4. Get the dedicated Firebase messaging service worker registration.
      // The VAPID subscription MUST belong to firebase-messaging-sw.js — the only
      // worker with a `push` handler that calls showNotification. Flutter's own
      // flutter_service_worker.js controls the app scope and has no push handler,
      // so a subscription created against `navigator.serviceWorker.ready`
      // (Flutter's worker) is delivered there and silently dropped — the push
      // service returns 201 but nothing appears. Registering the Firebase worker
      // at a dedicated sub-scope makes it its own registration that is never
      // clobbered by Flutter's root worker and still receives pushes regardless
      // of which worker controls the page.
      step = 'service_worker';
      final registration = await _ensurePushRegistration(swContainer)
          .timeout(const Duration(seconds: 15));
      if (registration == null) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.unsupported,
          message: 'Notification service worker is unavailable. On iOS, reopen the Home Screen app and try again.',
          failingStep: 'service_worker',
        );
      }

      // 5. Get PushManager
      // Read dynamically: package:web types `pushManager` as non-null, but
      // Safari outside a Home Screen install simply does not have it.
      final pushManagerValue = registration['pushManager'];
      final pushManager = pushManagerValue.isUndefinedOrNull
          ? null
          : pushManagerValue as web.PushManager;
      if (pushManager == null) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.unsupported,
          message: 'Push API not supported in this browser. On iOS, install the app to the Home Screen first.',
          failingStep: 'push_manager',
        );
      }

      // 6. On an explicit user re-enable, drop any existing subscription first
      // so we always bind to the CURRENT VAPID application server key. A
      // subscription created against a previous key (e.g. after a server re-key
      // or AMI clone) is rejected by the push service with VapidPkHashMismatch,
      // and subscribe() cannot overwrite a subscription bound to a different
      // key — it must be unsubscribed first. Silent re-registration keeps the
      // existing subscription (forceResubscribe = false) to avoid endpoint churn.
      //
      // Both calls are individually bounded: they reach the platform push
      // daemon, and an unbounded await here would wedge the whole enable flow
      // with no timeout to escape through and no message to show.
      step = 'clear_existing';
      if (forceResubscribe) {
        try {
          final existing = await pushManager
              .getSubscription()
              .toDart
              .timeout(const Duration(seconds: 10));
          if (existing != null) {
            await existing
                .unsubscribe()
                .toDart
                .timeout(const Duration(seconds: 10));
            _logger.info('Cleared existing push subscription before re-subscribing');
          }
        } catch (error) {
          // Non-fatal: proceed to subscribe. A leftover stale subscription will
          // be auto-disabled by the backend when the push service returns 410.
          _logger.warning('Failed clearing stale push subscription: $error');
        }
      }

      // 7. Convert VAPID public key (base64url) to JS Uint8Array
      final keyBytes = _base64UrlDecode(publicKey);
      final keyArray = keyBytes.toJS;

      // 8. Subscribe — permission is already granted, so this is a straight
      // round-trip to the push service with no prompt in the way.
      step = 'subscribe';
      final subscription = await pushManager
          .subscribe(
            web.PushSubscriptionOptionsInit(
              userVisibleOnly: true,
              applicationServerKey: keyArray,
            ),
          )
          .toDart
          .timeout(const Duration(seconds: 30));

      // 9. Serialize to JSON string
      final jsonStr = _jsonStringify(subscription.toJSON());

      _logger.info('VAPID subscription obtained');
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.subscribed,
        message: 'Web push subscription created.',
        subscriptionJson: jsonStr,
        browser: _detectBrowserHint(),
      );
    } on TimeoutException catch (e) {
      // A stalled key fetch is worth retrying from scratch.
      if (step == 'key_fetch') _cachedPublicKey = null;
      _logger.warning('VAPID subscription timed out at $step: $e');
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.failed,
        message: 'Push subscription timed out at "$step". Check your connection and try again.',
        failingStep: step,
      );
    } catch (error) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('notallowed') ||
          errorStr.contains('permission denied') ||
          errorStr.contains('permission_denied')) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.permissionDenied,
          message: 'Notification permission was denied.',
          failingStep: 'permission',
        );
      }
      if (step == 'key_fetch') _cachedPublicKey = null;
      _logger.error('VAPID subscription failed at $step', error, StackTrace.current);
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.failed,
        message: 'Failed to create web push subscription at "$step": ${_sanitizeError(error)}',
        failingStep: step,
      );
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// `Notification.permission`, or `unsupported` when the API is missing.
  static String _permissionStatus() {
    try {
      if (!globalContext.has('Notification')) return 'unsupported';
      return web.Notification.permission;
    } catch (_) {
      return 'unsupported';
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

  /// Dedicated sub-scope for the Firebase push worker so it never collides with
  /// Flutter's root service worker at the app base path. Kept in sync with the
  /// `push/` suffix that `firebase-messaging-sw.js` strips when resolving the
  /// app base path for notification icons and click URLs.
  static const _pushScopeSuffix = 'push/';
  static const _pushServiceWorkerFile = 'firebase-messaging-sw.js';

  static String get _basePath {
    try {
      return normalizeWebAppBasePath(Uri.base.path);
    } catch (_) {
      return '/';
    }
  }

  /// Registers (or reuses) firebase-messaging-sw.js at the dedicated push scope
  /// and returns the registration once it has an active worker. Returns null on
  /// failure. `register()` is idempotent for the same script+scope, so calling
  /// this on every subscribe is safe.
  static Future<web.ServiceWorkerRegistration?> _ensurePushRegistration(
    web.ServiceWorkerContainer swContainer,
  ) async {
    final base = _basePath;
    final swUrl = buildWebAppAssetUrl(base, _pushServiceWorkerFile);
    final scope = base == '/' ? '/$_pushScopeSuffix' : '$base$_pushScopeSuffix';

    final web.ServiceWorkerRegistration registration;
    try {
      registration = await swContainer
          .register(swUrl.toJS, web.RegistrationOptions(scope: scope))
          .toDart;
    } catch (error) {
      _logger.error('Failed registering push service worker at $scope', error, StackTrace.current);
      return null;
    }

    // A fresh sub-scope has no existing controller, so the worker activates
    // without waiting. Poll briefly until `active` is populated.
    for (var i = 0; i < 50; i++) {
      if (registration.active != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return registration;
  }

  /// The browser's `JSON.stringify`, not `jsonEncode`: the backend stores this
  /// string and the push service is keyed on it, so it must be the exact bytes
  /// the browser produces for its own subscription object.
  static String _jsonStringify(JSAny? value) {
    final json = globalContext.getProperty<JSObject>('JSON'.toJS);
    return json.callMethod<JSString>('stringify'.toJS, value).toDart;
  }

  /// Decodes a base64url string (with or without padding) to bytes.
  static Uint8List _base64UrlDecode(String base64UrlStr) {
    // Normalize base64url characters to standard base64
    String padded = base64UrlStr.replaceAll('-', '+').replaceAll('_', '/');
    // Restore padding
    final remainder = padded.length % 4;
    if (remainder == 2) {
      padded += '==';
    } else if (remainder == 3) {
      padded += '=';
    }
    return base64Decode(padded);
  }

  static String _detectBrowserHint() {
    try {
      final ua = web.window.navigator.userAgent.toLowerCase();
      if (ua.contains('iphone') || ua.contains('ipad')) return 'Safari/iOS';
      if (ua.contains('chrome')) return 'Chrome/Web';
      if (ua.contains('firefox')) return 'Firefox/Web';
      if (ua.contains('safari')) return 'Safari/macOS';
      return 'Web';
    } catch (_) {
      return 'Web';
    }
  }

  static String _sanitizeError(Object error) {
    final raw = error.toString();
    if (raw.length > 120) return '${raw.substring(0, 120)}…';
    return raw;
  }
}
