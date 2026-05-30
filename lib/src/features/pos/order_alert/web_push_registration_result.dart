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
  });

  final WebPushRegistrationStatus status;
  final String message;
  final String? token;

  bool get hasToken => token?.isNotEmpty ?? false;
  bool get isSuccess => status == WebPushRegistrationStatus.registered;

  WebPushRegistrationResult asRegistered() {
    return WebPushRegistrationResult(
      status: WebPushRegistrationStatus.registered,
      message: 'Web push notifications are enabled for this device.',
      token: token,
    );
  }

  WebPushRegistrationResult asFailed(Object error) {
    return WebPushRegistrationResult(
      status: WebPushRegistrationStatus.failed,
      message: 'Failed to enable web push notifications: $error',
      token: token,
    );
  }
}

WebPushRegistrationResult webPushPermissionNotGrantedResult(String status) {
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
  );
}

WebPushRegistrationResult webPushTimedOutResult(String operation) {
  return WebPushRegistrationResult(
    status: WebPushRegistrationStatus.failed,
    message:
        '$operation timed out. Check your connection, reopen the Home Screen app, and try Enable Notifications again.',
  );
}