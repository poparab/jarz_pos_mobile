import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_token_normalizer.dart';

void main() {
  group('normalizeWebPushTokenCandidate', () {
    test('should return null when candidate is null', () {
      // Arrange

      // Act
      final result = normalizeWebPushTokenCandidate(null);

      // Assert
      expect(result, isNull);
    });

    test('should return null when candidate is an empty string', () {
      // Arrange

      // Act
      final result = normalizeWebPushTokenCandidate('   ');

      // Assert
      expect(result, isNull);
    });

    test('should return null when candidate is the literal null string', () {
      // Arrange

      // Act
      final result = normalizeWebPushTokenCandidate('null');

      // Assert
      expect(result, isNull);
    });

    test('should return null when candidate is the literal undefined string', () {
      // Arrange

      // Act
      final result = normalizeWebPushTokenCandidate('undefined');

      // Assert
      expect(result, isNull);
    });

    test('should return trimmed token when candidate is a valid string', () {
      // Arrange

      // Act
      final result = normalizeWebPushTokenCandidate('  abc123  ');

      // Assert
      expect(result, 'abc123');
    });
  });
}