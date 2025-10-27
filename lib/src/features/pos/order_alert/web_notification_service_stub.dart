/// Stub implementation for non-web platforms (Android, iOS, etc.)
class WebNotificationService {
  /// Request notification permission (no-op on non-web platforms)
  static Future<bool> requestPermission() async => false;

  /// Check if notifications are supported (always false on non-web)
  static bool get isSupported => false;

  /// Check if permission is granted (always false on non-web)
  static Future<bool> get hasPermission async => false;

  /// Show a browser notification (no-op on non-web platforms)
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    // No-op on non-web platforms
  }

  /// Show notification for new invoice alert (no-op on non-web platforms)
  static Future<void> showInvoiceAlert({
    required String invoiceId,
    required String customerName,
    required double total,
    String? posProfile,
  }) async {
    // No-op on non-web platforms
  }
}
