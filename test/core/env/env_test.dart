import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/env/env.dart';

void main() {
  group('resolveEnvName', () {
    test('should prefer explicit env when provided', () {
      // Arrange
      const rawEnv = 'production';

      // Act
      final result = resolveEnvName(
        rawEnv: rawEnv,
        compiledBaseUrl: 'https://erpstg.orderjarz.com',
        currentHost: 'erpstg.orderjarz.com',
        isReleaseMode: true,
      );

      // Assert
      expect(result, 'production');
    });

    test('should resolve production when compile-time base url is production', () {
      // Arrange
      const compiledBaseUrl = 'https://erp.orderjarz.com';

      // Act
      final result = resolveEnvName(
        compiledBaseUrl: compiledBaseUrl,
        isReleaseMode: true,
      );

      // Assert
      expect(result, 'prod');
    });

    test('should resolve staging when current host is staging', () {
      // Arrange
      const currentHost = 'erpstg.orderjarz.com';

      // Act
      final result = resolveEnvName(
        currentHost: currentHost,
        isReleaseMode: true,
      );

      // Assert
      expect(result, 'staging');
    });

    test('should default to local for non-release builds without signals', () {
      // Act
      final result = resolveEnvName(isReleaseMode: false);

      // Assert
      expect(result, 'local');
    });
  });

  group('envFileFor', () {
    test('should map prod aliases to prod env file', () {
      // Act
      final result = envFileFor('production');

      // Assert
      expect(result, '.env.prod');
    });

    test('should map testing alias to staging env file', () {
      // Act
      final result = envFileFor('testing');

      // Assert
      expect(result, '.env.staging');
    });
  });
}