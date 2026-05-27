import 'web_push_registration_result.dart';

class WebPushRegistrationService {
  static Future<WebPushRegistrationResult> getTokenIfPermissionGranted() async {
    return const WebPushRegistrationResult(
      status: WebPushRegistrationStatus.unsupported,
      message: 'Web push notifications are only available in the web app.',
    );
  }

  static Future<WebPushRegistrationResult> requestToken() async {
    return const WebPushRegistrationResult(
      status: WebPushRegistrationStatus.unsupported,
      message: 'Web push notifications are only available in the web app.',
    );
  }

  static Stream<String> tokenRefreshStream() => const Stream.empty();
}