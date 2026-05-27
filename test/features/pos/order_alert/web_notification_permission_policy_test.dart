import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_notification_permission_policy.dart';

void main() {
  group('shouldAutoPromptBrowserNotifications', () {
    test('should preserve legacy auto prompt when web push is disabled', () {
      // Arrange

      // Act
      final result = shouldAutoPromptBrowserNotifications(webPushEnabled: false);

      // Assert
      expect(result, isTrue);
    });

    test('should require explicit user action when web push is enabled', () {
      // Arrange

      // Act
      final result = shouldAutoPromptBrowserNotifications(webPushEnabled: true);

      // Assert
      expect(result, isFalse);
    });
  });
}