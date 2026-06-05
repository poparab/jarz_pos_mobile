// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import '../../../core/utils/logger.dart';
import 'data/order_alert_service.dart';
import 'vapid_subscription_result.dart';

class VapidSubscriptionService {
  static final Logger _logger = Logger('VapidSubscriptionService');

  /// Requests a new VAPID web push subscription.
  ///
  /// Must be called from a user gesture (e.g. button tap) if notification
  /// permission has not been granted yet. Once granted, it can be called
  /// silently on subsequent app loads via [subscribeIfPermissionGranted].
  static Future<VapidSubscriptionResult> requestSubscription({
    required OrderAlertService service,
  }) async {
    return _doSubscribe(service: service);
  }

  /// Silently re-registers a VAPID subscription if permission is already granted.
  /// No-op if permission is "default" or "denied".
  static Future<VapidSubscriptionResult> subscribeIfPermissionGranted({
    required OrderAlertService service,
  }) async {
    try {
      final permission = js_util.getProperty<Object?>(
        js_util.getProperty<Object>(html.window, 'Notification') as Object,
        'permission',
      )?.toString();
      if (permission != 'granted') {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.permissionDenied,
          message: 'Notification permission not yet granted.',
        );
      }
    } catch (_) {
      return const VapidSubscriptionResult(
        status: VapidSubscriptionStatus.unsupported,
        message: 'Notification API not available.',
      );
    }
    return _doSubscribe(service: service);
  }

  static Future<VapidSubscriptionResult> _doSubscribe({
    required OrderAlertService service,
  }) async {
    // 1. Verify Push API support
    final swContainer = _serviceWorkerContainer();
    if (swContainer == null) {
      return const VapidSubscriptionResult(
        status: VapidSubscriptionStatus.unsupported,
        message: 'Service Worker API not available — upgrade to a modern browser.',
      );
    }

    try {
      // 2. Fetch VAPID public key from backend
      final publicKey = await service.fetchVapidPublicKey()
          .timeout(const Duration(seconds: 10));

      // 3. Await the service worker becoming active
      final readyPromise = js_util.getProperty<Object?>(swContainer, 'ready');
      if (readyPromise == null) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.unsupported,
          message: 'Service worker ready state unavailable.',
        );
      }
      final registration = await js_util
          .promiseToFuture<Object>(readyPromise)
          .timeout(const Duration(seconds: 15));

      // 4. Get PushManager
      final pushManager = js_util.getProperty<Object?>(registration, 'pushManager');
      if (pushManager == null) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.unsupported,
          message: 'Push API not supported in this browser. On iOS, install the app to the Home Screen first.',
        );
      }

      // 5. Convert VAPID public key (base64url) to JS Uint8Array
      final keyBytes = _base64UrlDecode(publicKey);
      final keyArray = _toJsUint8Array(keyBytes);

      // 6. Build subscribe options
      final options = js_util.newObject<Object>();
      js_util.setProperty(options, 'userVisibleOnly', true);
      js_util.setProperty(options, 'applicationServerKey', keyArray);

      // 7. Subscribe — on iOS this shows the system notification prompt if not already granted
      final subscribePromise = js_util.callMethod<Object>(
        pushManager as Object,
        'subscribe',
        [options],
      );
      final subscription = await js_util
          .promiseToFuture<Object>(subscribePromise)
          .timeout(const Duration(seconds: 30));

      // 8. Serialize to JSON string
      final jsonObj = js_util.callMethod<Object>(subscription, 'toJSON', []);
      final jsonStr = js_util.callMethod<String>(
        js_util.getProperty<Object>(html.window, 'JSON') as Object,
        'stringify',
        [jsonObj],
      );

      _logger.info('VAPID subscription obtained');
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.subscribed,
        message: 'Web push subscription created.',
        subscriptionJson: jsonStr,
        browser: _detectBrowserHint(),
      );
    } on TimeoutException catch (e) {
      _logger.warning('VAPID subscription timed out: $e');
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.failed,
        message: 'Push subscription timed out. Check your connection and try again.',
      );
    } catch (error) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('notallowed') ||
          errorStr.contains('permission denied') ||
          errorStr.contains('permission_denied')) {
        return const VapidSubscriptionResult(
          status: VapidSubscriptionStatus.permissionDenied,
          message: 'Notification permission was denied.',
        );
      }
      _logger.error('VAPID subscription failed', error, StackTrace.current);
      return VapidSubscriptionResult(
        status: VapidSubscriptionStatus.failed,
        message: 'Failed to create web push subscription: ${_sanitizeError(error)}',
      );
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static Object? _serviceWorkerContainer() {
    try {
      return js_util.getProperty<Object?>(html.window.navigator, 'serviceWorker');
    } catch (_) {
      return null;
    }
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

  /// Creates a JS Uint8Array from a Dart Uint8List.
  static Object _toJsUint8Array(Uint8List bytes) {
    final jsBytes = js_util.jsify(bytes.toList());
    final uint8ArrayCtor = js_util.getProperty<Object>(html.window, 'Uint8Array');
    return js_util.callMethod<Object>(uint8ArrayCtor as Object, 'from', [jsBytes]);
  }

  static String _detectBrowserHint() {
    try {
      final ua = js_util
          .getProperty<String>(
            js_util.getProperty<Object>(html.window, 'navigator') as Object,
            'userAgent',
          )
          .toLowerCase();
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
