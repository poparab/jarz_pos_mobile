import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_enable_diagnostics.dart';

void main() {
  group('WebPushEnableDiagnostics', () {
    test('should include failing step and reason in compact summary', () {
      // Arrange
      const diagnostics = WebPushEnableDiagnostics(
        currentPath: '/pos/',
        basePath: '/pos/',
        serviceWorkerScope: '/pos/',
        serviceWorkerUrl: '/pos/firebase-messaging-sw.js',
        webPushEnabled: true,
        firebaseOptionsReady: true,
        firebaseInitialized: true,
        failingStep: 'token_request',
        permissionStatus: 'granted',
        notificationSupported: true,
        serviceWorkerSupported: true,
        existingRegistrationScope: '/pos/',
        readyRegistrationScope: '/pos/',
        messagingLibraryAvailable: true,
        messagingResolved: true,
        tokenState: 'missing',
        failureReason: 'token_missing',
      );

      // Act
      final summary = diagnostics.toCompactSummary();

      // Assert
      expect(summary, contains('step token_request'));
      expect(summary, contains('reason token_missing'));
      expect(summary, contains('msg yes/yes'));
    });

    test('should truncate long error details in compact summary', () {
      // Arrange
      const diagnostics = WebPushEnableDiagnostics(
        currentPath: '/pos/',
        basePath: '/pos/',
        serviceWorkerScope: '/pos/',
        serviceWorkerUrl: '/pos/firebase-messaging-sw.js',
        webPushEnabled: true,
        firebaseOptionsReady: true,
        firebaseInitialized: true,
        errorSummary:
            'This is a very long error summary that should be trimmed down before it is shown in compact diagnostics output for user-facing debugging.',
      );

      // Act
      final summary = diagnostics.toCompactSummary();

      // Assert
      expect(summary, contains('error This is a very long error summary'));
      expect(summary, contains('...'));
    });
  });
}