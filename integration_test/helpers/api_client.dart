/// Authenticated Dio client for staging E2E tests.
///
/// Logs in once per test file and keeps the session cookie alive for all
/// subsequent requests. Provides convenience methods for the Frappe API
/// envelope pattern (`{ "message": <data> }`).
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import 'staging_config.dart';

/// A thin wrapper around [Dio] that handles staging auth automatically.
class StagingApiClient {
  StagingApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: StagingConfig.baseUrl,
            connectTimeout:
                Duration(milliseconds: StagingConfig.connectTimeoutMs),
            receiveTimeout:
                Duration(milliseconds: StagingConfig.receiveTimeoutMs),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Frappe-Site-Name': StagingConfig.frappeSite,
            },
          ),
        );

  final Dio _dio;

  /// Whether [login] has been called successfully at least once.
  bool get isLoggedIn => _sessionCookie != null;

  String? _sessionCookie;

  // ── Auth ──────────────────────────────────────────────────────────────

  /// Authenticate against the staging backend.
  /// Stores the `sid` cookie for subsequent calls.
  Future<void> login({String? user, String? password}) async {
    final resp = await _dio.post(
      ApiEndpoints.login,
      data: {
        'usr': user ?? StagingConfig.user,
        'pwd': password ?? StagingConfig.password,
      },
    );

    // Extract sid cookie from set-cookie header.
    final setCookie = resp.headers['set-cookie'];
    if (setCookie != null) {
      for (final c in setCookie) {
        if (c.startsWith('sid=')) {
          _sessionCookie = c.split(';')[0]; // "sid=<value>"
          _dio.options.headers['Cookie'] = _sessionCookie;
          break;
        }
      }
    }

    expect(resp.statusCode, 200,
        reason: 'Login should succeed with status 200');
  }

  /// Destroy the remote session and clear local cookie.
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout, data: {});
    _sessionCookie = null;
    _dio.options.headers.remove('Cookie');
  }

  // ── Generic helpers ───────────────────────────────────────────────────

  /// POST and unwrap Frappe `{ "message": <data> }` envelope.
  /// Returns the inner `message` value (may be `null`).
  Future<dynamic> call(String endpoint, {Map<String, dynamic>? data}) async {
    final resp = await _dio.post(endpoint, data: data ?? {});
    final body = resp.data;
    if (body is Map && body.containsKey('message')) return body['message'];
    return body;
  }

  /// GET and unwrap Frappe envelope.
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    final resp =
        await _dio.get(endpoint, queryParameters: queryParameters);
    final body = resp.data;
    if (body is Map && body.containsKey('message')) return body['message'];
    return body;
  }

  /// Raw [Dio] POST – use when you need full [Response] access.
  Future<Response> rawPost(String endpoint,
          {Object? data, Options? options}) =>
      _dio.post(endpoint, data: data, options: options);

  /// Expose the Dio instance for edge-case tests that need direct access.
  Dio get dio => _dio;

  /// Clean up – call in `tearDownAll`.
  void dispose() {
    _dio.close();
  }
}

/// Convenience: ensure [StagingApiClient] is authenticated.
/// Use in `setUpAll`:
/// ```dart
/// late StagingApiClient api;
/// setUpAll(() async {
///   api = StagingApiClient();
///   await ensureLoggedIn(api);
/// });
/// ```
Future<void> ensureLoggedIn(StagingApiClient api) async {
  if (!api.isLoggedIn) await api.login();
}
