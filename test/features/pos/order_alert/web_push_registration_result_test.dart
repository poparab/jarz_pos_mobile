import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_enable_diagnostics.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_registration_result.dart';

void main() {
  group('WebPushRegistrationResult', () {
    test('should preserve diagnostics when marking token result as registered', () {
      // Arrange
      const diagnostics = WebPushEnableDiagnostics(
        currentPath: '/pos/',
        basePath: '/pos/',
        serviceWorkerScope: '/pos/',
        serviceWorkerUrl: '/pos/firebase-messaging-sw.js',
        webPushEnabled: true,
        firebaseOptionsReady: true,
        firebaseInitialized: true,
        failingStep: 'token_ready',
        tokenState: 'ready',
      );
      const result = WebPushRegistrationResult(
        status: WebPushRegistrationStatus.tokenReady,
        message: 'Web push token is ready for registration.',
        token: 'token-123',
        diagnostics: diagnostics,
      );

      // Act
      final registered = result.asRegistered();

      // Assert
      expect(registered.status, WebPushRegistrationStatus.registered);
      expect(registered.token, 'token-123');
      expect(registered.diagnostics, same(diagnostics));
    });

    test('should preserve diagnostics when converting a result to failure', () {
      // Arrange
      const diagnostics = WebPushEnableDiagnostics(
        currentPath: '/pos/',
        basePath: '/pos/',
        serviceWorkerScope: '/pos/',
        serviceWorkerUrl: '/pos/firebase-messaging-sw.js',
        webPushEnabled: true,
        firebaseOptionsReady: true,
        firebaseInitialized: true,
        failingStep: 'backend_registration',
      );
      const result = WebPushRegistrationResult(
        status: WebPushRegistrationStatus.tokenReady,
        message: 'Web push token is ready for registration.',
        token: 'token-123',
        diagnostics: diagnostics,
      );

      // Act
      final failed = result.asFailed(StateError('backend failed'));

      // Assert
      expect(failed.status, WebPushRegistrationStatus.failed);
      expect(failed.diagnostics, same(diagnostics));
    });
  });

  group('webPushPermissionNotGrantedResult', () {
    test('should explain denied permission with iPhone settings guidance', () {
      // Arrange

      // Act
      final result = webPushPermissionNotGrantedResult('denied');

      // Assert
      expect(result.status, WebPushRegistrationStatus.permissionDenied);
      expect(result.message, contains('iPhone Settings'));
    });

    test('should explain timeout with Home Screen reinstall guidance', () {
      // Arrange

      // Act
      final result = webPushPermissionNotGrantedResult('timeout');

      // Assert
      expect(result.status, WebPushRegistrationStatus.permissionDenied);
      expect(result.message, contains('Delete and re-add the Home Screen app'));
    });
  });

  group('webPushTimedOutResult', () {
    test('should mention retry steps in timeout message', () {
      // Arrange

      // Act
      final result = webPushTimedOutResult('Notification setup');

      // Assert
      expect(result.status, WebPushRegistrationStatus.failed);
      expect(result.message, contains('Notification setup timed out'));
      expect(result.message, contains('Enable Notifications'));
    });
  });

  group('webPushFailedFromException', () {
    test('should not expose raw null-check exception text', () {
      // Arrange

      // Act
      final result = webPushFailedFromException(
        StateError('Null check operator used on a null value'),
      );

      // Assert
      expect(result.status, WebPushRegistrationStatus.failed);
      expect(result.message, isNot(contains('Null check operator')));
      expect(result.message, contains('Home Screen app'));
    });
  });
}