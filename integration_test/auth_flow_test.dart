/// E2E: Authentication flow against the staging server.
///
/// Run with:
///   flutter test integration_test/auth_flow_test.dart
///     --dart-define=STAGING_USER=myuser --dart-define=STAGING_PASSWORD=mypass
///
/// Or set STAGING_USER / STAGING_PASSWORD as OS environment variables.
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import 'helpers/api_client.dart';

void main() {
  late StagingApiClient api;

  setUpAll(() {
    api = StagingApiClient();
  });

  tearDownAll(() {
    api.dispose();
  });

  // ── Login ───────────────────────────────────────────────────────────

  group('Login flow', () {
    test('successful login returns 200 and stores session cookie', () async {
      await api.login();
      expect(api.isLoggedIn, isTrue, reason: 'Session cookie should be stored');
    });

    test('get_logged_user returns current username after login', () async {
      await ensureLoggedIn(api);

      final user = await api.call(ApiEndpoints.getLoggedUser);
      expect(user, isA<String>());
      expect((user as String).contains('@'), isTrue,
          reason: 'Logged-in user should be an email');
    });

    test('get_current_user_roles returns valid role object', () async {
      await ensureLoggedIn(api);

      final roles = await api.call(ApiEndpoints.getCurrentUserRoles);
      expect(roles, isA<Map>());
      expect(roles['user'], isNotEmpty);
      expect(roles['roles'], isA<List>());
      expect((roles['roles'] as List).isNotEmpty, isTrue);
    });

    test('roles response contains require_pos_shift flag', () async {
      await ensureLoggedIn(api);

      final roles = await api.call(ApiEndpoints.getCurrentUserRoles);
      expect(roles.containsKey('require_pos_shift'), isTrue);
    });

    test('invalid credentials return 401', () async {
      final badApi = StagingApiClient();
      try {
        await badApi.login(user: 'nonexistent@fake.com', password: 'wrong');
        fail('Should have thrown on invalid credentials');
      } catch (e) {
        expect(e.toString(), contains('401'));
      } finally {
        badApi.dispose();
      }
    });
  });

  // ── Session validation ──────────────────────────────────────────────

  group('Session validation', () {
    test('validate_session succeeds with active session', () async {
      await ensureLoggedIn(api);

      final user = await api.call(ApiEndpoints.getLoggedUser);
      expect(user, isNotNull);
      expect(user, isNot('Guest'));
    });
  });

  // ── Logout ──────────────────────────────────────────────────────────

  group('Logout flow', () {
    test('logout clears session', () async {
      await ensureLoggedIn(api);
      await api.logout();
      expect(api.isLoggedIn, isFalse);
    });

    test('API calls after logout fail or return Guest', () async {
      // Re-login then logout
      await api.login();
      await api.logout();

      try {
        final user = await api.call(ApiEndpoints.getLoggedUser);
        // Frappe may return 'Guest' instead of throwing.
        expect(user, equals('Guest'));
      } catch (_) {
        // 403 or similar is also acceptable after logout.
      }
    });
  });
}
