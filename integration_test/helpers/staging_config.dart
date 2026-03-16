/// Staging environment configuration for E2E integration tests.
///
/// Test credentials are loaded from environment variables or `.env.test`
/// to avoid committing secrets. Set the following before running:
///
///   STAGING_USER=myuser
///   STAGING_PASSWORD=mypassword
///   STAGING_POS_PROFILE=MyProfile  (optional, resolved at runtime)
library;

import 'dart:io' show Platform;

abstract final class StagingConfig {
  /// Base URL of the staging ERPNext instance.
  static const baseUrl = 'https://erpstg.orderjarz.com';

  /// Frappe site header value used for multi-tenant routing.
  static const frappeSite = 'frontend';

  /// Default HTTP timeouts for test requests.
  static const connectTimeoutMs = 30000;
  static const receiveTimeoutMs = 30000;

  /// Test user credentials – sourced from env vars at runtime.
  static String get user {
    const fromDefine = String.fromEnvironment('STAGING_USER');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['STAGING_USER'] ?? _missingEnv('STAGING_USER');
  }

  static String get password {
    const fromDefine = String.fromEnvironment('STAGING_PASSWORD');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['STAGING_PASSWORD'] ??
        _missingEnv('STAGING_PASSWORD');
  }

  /// Optional: pre-set POS profile for tests that need one.
  /// If empty, the test will pick the first available profile.
  static String get posProfile {
    const fromDefine = String.fromEnvironment('STAGING_POS_PROFILE');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['STAGING_POS_PROFILE'] ?? '';
  }

  static String _missingEnv(String name) {
    throw StateError(
      'Missing environment variable $name. '
      'Run tests with: flutter test integration_test/ '
      '--dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y '
      'or set them as OS env vars.',
    );
  }
}
