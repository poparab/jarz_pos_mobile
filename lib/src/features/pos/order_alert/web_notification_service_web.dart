// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import '../../../core/firebase/firebase_runtime_config.dart';
import '../../../core/utils/logger.dart';
import 'web_notification_permission_policy.dart';
import 'web_push_paths.dart';

/// Service for managing browser notifications on web platform
class WebNotificationService {
  static final Logger _logger = Logger('WebNotificationService');
  static bool _permissionRequested = false;
  static String _permissionStatus = 'default';

  static String get _notificationIconPath => buildWebAppAssetUrl(
    normalizeWebAppBasePath(Uri.base.path),
    'icons/Icon-192.png',
  );

  /// Request notification permission from the browser
  static Future<bool> requestPermission() async {
    _permissionStatus = _currentPermissionStatus();

    if (_permissionRequested) return _permissionStatus == 'granted';

    try {
      final permission = await html.Notification.requestPermission();
      _permissionStatus = permission;
      _permissionRequested = true;
      
      _logger.info('🔔 Browser notification permission: $permission');
      return permission == 'granted';
    } catch (e) {
      _logger.error('Failed to request notification permission', e);
      return false;
    }
  }

  /// Check if notifications are supported and permitted
  static bool get isSupported {
    return html.Notification.supported;
  }

  /// Check if permission is granted
  static Future<bool> get hasPermission async {
    _permissionStatus = _currentPermissionStatus();
    if (_permissionStatus != 'default') {
      return _permissionStatus == 'granted';
    }

    if (!_permissionRequested && shouldAutoPromptBrowserNotifications(
      webPushEnabled: FirebaseRuntimeConfig.webPushEnabled,
    )) {
      await requestPermission();
    }

    return _permissionStatus == 'granted';
  }

  static String _currentPermissionStatus() {
    try {
      return html.Notification.permission ?? _permissionStatus;
    } catch (_) {
      return _permissionStatus;
    }
  }

  /// Show a browser notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    if (!isSupported) {
      _logger.warning('Browser notifications not supported');
      return;
    }

    if (!await hasPermission) {
      _logger.warning('Notification permission not granted');
      return;
    }

    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? _notificationIconPath,
        tag: tag,
      );

      // Handle notification click - bring window to front
      notification.onClick.listen((_) {
        _logger.info('Notification clicked');
        // Note: window.focus() is not available in dart:html
        // The click itself will typically bring the browser tab to focus
        notification.close();
      });

      // Auto-close after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        try {
          notification.close();
        } catch (e) {
          // Ignore if already closed
        }
      });

      _logger.info('✅ Browser notification shown: $title');
    } catch (e) {
      _logger.error('Failed to show browser notification', e);
    }
  }

  /// Show notification for new invoice alert
  static Future<void> showInvoiceAlert({
    required String invoiceId,
    required String customerName,
    required double total,
    String? posProfile,
  }) async {
    await showNotification(
      title: '🔔 New Order Alert',
      body: 'Invoice: $invoiceId\nCustomer: $customerName\nTotal: \$$total',
      tag: 'invoice_$invoiceId',
      data: {
        'type': 'invoice_alert',
        'invoice_id': invoiceId,
        'customer_name': customerName,
        'total': total,
        'pos_profile': posProfile,
      },
    );
  }

  /// Show notification for shift events
  static Future<void> showShiftNotification({
    required String title,
    required String body,
    String? posProfile,
  }) async {
    await showNotification(
      title: title,
      body: body,
      tag: 'shift_${posProfile ?? 'unknown'}',
    );
  }
}
