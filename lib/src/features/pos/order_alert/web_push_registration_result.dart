import 'web_push_enable_diagnostics.dart';

enum WebPushRegistrationStatus {
  disabled,
  unsupported,
  missingConfig,
  permissionRequired,
  permissionDenied,
  noToken,
  tokenReady,
  registered,
  failed,
}

class WebPushRegistrationResult {
  const WebPushRegistrationResult({
    required this.status,
    required this.message,
    this.token,
    this.diagnostics,
  });

  final WebPushRegistrationStatus status;
  final String message;
  final String? token;
  final WebPushEnableDiagnostics? diagnostics;

  bool get hasToken => token?.isNotEmpty ?? false;
  bool get isSuccess => status == WebPushRegistrationStatus.registered;

  WebPushRegistrationResult asRegistered() {
    return WebPushRegistrationResult(
      status: WebPushRegistrationStatus.registered,
      message: 'Web push notifications are enabled for this device.',
      token: token,
      diagnostics: diagnostics,
    );
  }

  WebPushRegistrationResult asFailed(Object error) {
    return webPushFailedFromException(error, token: token, diagnostics: diagnostics);
  }
}

WebPushRegistrationResult webPushFailedFromException(
  Object error, {
  String? token,
  WebPushEnableDiagnostics? diagnostics,
}) {
  return WebPushRegistrationResult(
    status: WebPushRegistrationStatus.failed,
    message: webPushSafeErrorMessage(error),
    token: token,
    diagnostics: diagnostics,
  );
}

String webPushSafeErrorMessage(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();

  if (lower.contains('null check operator used on a null value')) {
    return 'iPhone could not complete notification setup in this installed app. Reopen the Home Screen app and try again; if it repeats, delete and re-add the Home Screen icon.';
  }

  if (lower.contains('firebase web messaging is unavailable') ||
      lower.contains('firebase_messaging') ||
      lower.contains('unsupported')) {
    return 'This browser context cannot create a web push token. Reopen the Home Screen app and try again.';
  }

  if (lower.contains('service worker')) {
    return 'Notification service worker is not ready yet. Reopen the Home Screen app and try Enable Notifications again.';
  }

  if (lower.contains('timeout')) {
    return 'Notification setup timed out. Check your connection, reopen the Home Screen app, and try again.';
  }

  return 'Failed to enable web push notifications. Reopen the Home Screen app and try again.';
}

WebPushRegistrationResult webPushPermissionNotGrantedResult(
  String status, {
  WebPushEnableDiagnostics? diagnostics,
}) {
  final normalizedStatus = status.trim().toLowerCase();

  final message = switch (normalizedStatus) {
    'denied' =>
      'Notification permission is blocked. Open iPhone Settings > Notifications > Jarz POS and allow notifications, then try again.',
    'timeout' =>
      'No notification prompt appeared in time. Delete and re-add the Home Screen app, then tap Enable Notifications again.',
    'error' =>
      'iPhone could not open the notification permission prompt. Reopen the Home Screen app and try again.',
    'unsupported' => 'Web push notifications are only available in the web app.',
    _ => 'Notification permission was not granted. Tap Enable Notifications again and choose Allow.',
  };

  return WebPushRegistrationResult(
    status: WebPushRegistrationStatus.permissionDenied,
    message: message,
    diagnostics: diagnostics,
  );
}

WebPushRegistrationResult webPushTimedOutResult(
  String operation, {
  WebPushEnableDiagnostics? diagnostics,
}) {
  return WebPushRegistrationResult(
    status: WebPushRegistrationStatus.failed,
    message:
        '$operation timed out. Check your connection, reopen the Home Screen app, and try Enable Notifications again.',
    diagnostics: diagnostics,
  );
}