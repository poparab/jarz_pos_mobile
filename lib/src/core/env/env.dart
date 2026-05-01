import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String resolveEnvName({
  String rawEnv = const String.fromEnvironment('ENV', defaultValue: ''),
  String compiledBaseUrl = const String.fromEnvironment('ERP_BASE_URL', defaultValue: ''),
  String currentHost = '',
  bool isReleaseMode = kReleaseMode,
}) {
  final explicitEnv = rawEnv.trim();
  if (explicitEnv.isNotEmpty) {
    return explicitEnv;
  }

  final normalizedBaseUrl = compiledBaseUrl.trim().toLowerCase();
  if (normalizedBaseUrl.contains('erp.orderjarz.com')) {
    return 'prod';
  }
  if (normalizedBaseUrl.contains('erpstg.orderjarz.com') ||
      normalizedBaseUrl.contains('demo.orderjarz.com')) {
    return 'staging';
  }

  final normalizedHost = currentHost.trim().toLowerCase();
  if (normalizedHost == 'erp.orderjarz.com') {
    return 'prod';
  }
  if (normalizedHost == 'erpstg.orderjarz.com' || normalizedHost == 'demo.orderjarz.com') {
    return 'staging';
  }

  return isReleaseMode ? 'staging' : 'local';
}

String envFileFor(String env) {
  return switch (env.toLowerCase()) {
    'local' => '.env.local',
    // Treat testing as an alias of staging so CI builds and manual `--dart-define=ENV=testing`
    // load the staging endpoints instead of falling back to .env (local).
    'staging' || 'testing' || 'test' => '.env.staging',
    'prod' || 'production' => '.env.prod',
    _ => '.env',
  };
}

/// Loads the appropriate .env file based on a compile-time define `ENV`.
/// If `ENV` is absent, prefer the compile-time base URL emitted by
/// `--dart-define-from-file`, then the current web host, before falling back.
Future<void> loadEnv() async {
  final env = resolveEnvName(currentHost: Uri.base.host);
  final file = envFileFor(env);

  if (kDebugMode) {
    // Helpful at startup to confirm which env loaded
    // ignore: avoid_print
    print('🔧 Loading environment: $env -> $file');
  }

  // Load chosen file; if it fails (e.g., missing), fallback to legacy .env
  try {
    await dotenv.load(fileName: file);
  } catch (_) {
    await dotenv.load(fileName: '.env');
  }
}
