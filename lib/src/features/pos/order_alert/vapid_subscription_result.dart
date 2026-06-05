enum VapidSubscriptionStatus {
  unsupported,
  permissionDenied,
  failed,
  subscribed,
}

class VapidSubscriptionResult {
  const VapidSubscriptionResult({
    required this.status,
    required this.message,
    this.subscriptionJson,
    this.browser,
  });

  final VapidSubscriptionStatus status;
  final String message;
  final String? subscriptionJson;
  final String? browser;

  bool get isSuccess => status == VapidSubscriptionStatus.subscribed;
}
