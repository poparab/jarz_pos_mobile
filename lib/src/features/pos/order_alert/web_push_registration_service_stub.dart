import 'web_push_enable_diagnostics.dart';
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

  static WebPushEnableDiagnostics captureEmergencyDiagnostics({
    String failingStep = 'unsupported_platform',
    String? failureReason,
    Object? error,
  }) {
    return WebPushEnableDiagnostics(
      currentPath: '/',
      basePath: '/',
      serviceWorkerScope: '/',
      serviceWorkerUrl: 'firebase-messaging-sw.js',
      webPushEnabled: false,
      firebaseOptionsReady: false,
      firebaseInitialized: false,
      failingStep: failingStep,
      failureReason: failureReason ?? 'unsupported_platform',
      errorSummary: error?.toString(),
    );
  }

  static Stream<String> tokenRefreshStream() => const Stream.empty();
}