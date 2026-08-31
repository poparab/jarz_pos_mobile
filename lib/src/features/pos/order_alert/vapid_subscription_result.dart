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
    this.failingStep,
  });

  final VapidSubscriptionStatus status;
  final String message;
  final String? subscriptionJson;
  final String? browser;

  /// Which stage of the subscribe pipeline produced this result — `key_fetch`,
  /// `service_worker`, `clear_existing`, `subscribe`, `permission`. A bare
  /// "timed out" message is undiagnosable after the fact: four awaits share one
  /// catch, so the step is the only thing that says which one hung.
  final String? failingStep;

  bool get isSuccess => status == VapidSubscriptionStatus.subscribed;
}
