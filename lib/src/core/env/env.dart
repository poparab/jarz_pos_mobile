import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads the appropriate .env file based on a compile-time define `ENV`.
/// Usage:
///   flutter run --dart-define=ENV=local|staging|prod
/// Defaults to local when not provided.
Future<void> loadEnv() async {
  const env = String.fromEnvironment('ENV', defaultValue: 'local');
  // Map ENV -> file name
  final file = switch (env.toLowerCase()) {
    'local' => '.env.local',
    // Treat testing as an alias of staging so CI builds and manual `--dart-define=ENV=testing`
    // load the staging endpoints instead of falling back to .env (local).
    'staging' || 'testing' || 'test' => '.env.staging',
    'prod' || 'production' => '.env.prod',
    _ => '.env', // final fallback to legacy single-file setup
  };

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
