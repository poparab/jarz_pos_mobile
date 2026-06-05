import 'vapid_subscription_result.dart';

class VapidSubscriptionService {
  static Future<VapidSubscriptionResult> requestSubscription({
    required Object service,
  }) async {
    return const VapidSubscriptionResult(
      status: VapidSubscriptionStatus.unsupported,
      message: 'Web push subscriptions are only available in the web app.',
    );
  }

  static Future<VapidSubscriptionResult> subscribeIfPermissionGranted({
    required Object service,
  }) async {
    return const VapidSubscriptionResult(
      status: VapidSubscriptionStatus.unsupported,
      message: 'Web push subscriptions are only available in the web app.',
    );
  }
}
