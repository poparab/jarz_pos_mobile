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

  bool get hasToken => token != null && token!.isNotEmpty;
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