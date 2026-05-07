// ignore_for_file: avoid_print

/// Snapshot Updater — fetches live responses from staging and writes them
/// as JSON fixture files that the contract tests read.
///
/// Run with:
///   dart test/contracts/snapshot_updater.dart
///
/// Required environment variables (or --define flags):
///   STAGING_USER=your@email
///   STAGING_PASSWORD=yourpassword
///
/// The script will:
///   1. Log in to staging
///   2. Hit each API endpoint
///   3. Write the `message` payload to fixtures/*.json
///   4. Log out
///
/// Exit code 0 = all fixtures updated successfully.
/// Exit code 1 = one or more endpoints failed (partial update).
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

// ── Configuration ────────────────────────────────────────────────────────────

const String _baseUrl = 'https://erpstg.orderjarz.com';
const String _frappeSite = 'frontend';
const String _fixturesDir = 'test/contracts/fixtures';

// Prefer env vars; fall back to --define values injected at compile time.
String get _user {
  const fromDefine = String.fromEnvironment('STAGING_USER');
  if (fromDefine.isNotEmpty) return fromDefine;
  return Platform.environment['STAGING_USER'] ??
      (throw StateError('STAGING_USER not set'));
}

String get _password {
  const fromDefine = String.fromEnvironment('STAGING_PASSWORD');
  if (fromDefine.isNotEmpty) return fromDefine;
  return Platform.environment['STAGING_PASSWORD'] ??
      (throw StateError('STAGING_PASSWORD not set'));
}

// ── Endpoints to snapshot ────────────────────────────────────────────────────

/// Each entry: (filename, method, endpoint_path, optional_body)
final _snapshots = <(String, String, String, Map<String, dynamic>?)>[
  (
    'pos_profiles.json',
    'POST',
    '/api/method/jarz_pos.api.pos.get_pos_profiles',
    null,
  ),
  (
    'pos_items.json',
    'POST',
    '/api/method/jarz_pos.api.pos.get_profile_products',
    {'profile': 'Nasr city'},
  ),
  (
    'kanban_columns.json',
    'POST',
    '/api/method/jarz_pos.api.kanban.get_kanban_columns',
    null,
  ),
  (
    'active_shift.json',
    'POST',
    '/api/method/jarz_pos.api.shift.get_active_shift',
    null,
  ),
  (
    'customers.json',
    'POST',
    '/api/method/jarz_pos.api.customer.search_customers',
    // API takes 'name' (not 'query') for customer name search.
    {'name': 'test'},
  ),
  (
    'territories.json',
    'POST',
    '/api/method/jarz_pos.api.customer.get_territories',
    null,
  ),
];

// ── Main ─────────────────────────────────────────────────────────────────────

Future<void> main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Frappe-Site-Name': _frappeSite,
      },
    ),
  );

  // ── Login ─────────────────────────────────────────────────────────────

  print('[snapshot_updater] Logging in as $_user ...');
  String? sessionCookie;

  try {
    final loginResp = await dio.post(
      '/api/method/login',
      data: {'usr': _user, 'pwd': _password},
    );
    final setCookie = loginResp.headers['set-cookie'];
    if (setCookie != null) {
      for (final c in setCookie) {
        if (c.startsWith('sid=')) {
          sessionCookie = c.split(';')[0];
          dio.options.headers['Cookie'] = sessionCookie;
          break;
        }
      }
    }
    if (sessionCookie == null) {
      stderr.writeln('[snapshot_updater] ERROR: Login succeeded but no sid cookie found.');
      exit(1);
    }
    print('[snapshot_updater] Login OK.');
  } catch (e) {
    stderr.writeln('[snapshot_updater] ERROR: Login failed: $e');
    exit(1);
  }

  // ── Ensure fixtures directory exists ──────────────────────────────────

  final dir = Directory(_fixturesDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // ── Fetch and write each snapshot ─────────────────────────────────────

  int failed = 0;
  final encoder = const JsonEncoder.withIndent('  ');

  for (final (filename, method, path, body) in _snapshots) {
    try {
      Response resp;
      if (method == 'GET') {
        resp = await dio.get(path, queryParameters: body);
      } else {
        resp = await dio.post(path, data: body ?? {});
      }

      dynamic payload = resp.data;
      if (payload is Map && payload.containsKey('message')) {
        payload = payload['message'];
      }

      final outFile = File('$_fixturesDir/$filename');
      outFile.writeAsStringSync(encoder.convert(payload));
      print('[snapshot_updater] ✓  $filename');
    } catch (e) {
      stderr.writeln('[snapshot_updater] ✗  $filename — $e');
      failed++;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────

  try {
    await dio.post('/api/method/logout', data: {});
    print('[snapshot_updater] Logged out.');
  } catch (_) {
    // Non-fatal — session will expire on its own.
  }

  dio.close();

  if (failed > 0) {
    stderr.writeln('[snapshot_updater] $failed fixture(s) failed to update.');
    exit(1);
  } else {
    print('[snapshot_updater] All ${_snapshots.length} fixtures updated OK.');
  }
}
