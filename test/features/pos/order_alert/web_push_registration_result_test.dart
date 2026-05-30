import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_registration_result.dart';

void main() {
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
}