import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:jarz_pos/src/core/network/session_expired_signal.dart';

import '../../helpers/mock_services.dart';

/// The exact shape Frappe returns when the request ran as Guest because the
/// session is gone: `_server_messages` is a JSON string holding JSON strings.
Map<String, dynamic> _guestBody() => <String, dynamic>{
  'exc_type': 'PermissionError',
  '_server_messages': jsonEncode([
    jsonEncode({
      'message':
          'You are not permitted to access this resource. Login to access',
      'title': 'Message',
    }),
    jsonEncode({
      'message':
          'Function jarz_pos.api.notifications.get_pending_alerts is not '
          'whitelisted.',
      'title': 'Message',
    }),
  ]),
};

void main() {
  group('clearStoredSessionAfterUnauthorized', () {
    test('should skip local cleanup when running on web', () async {
      final sessionManager = MockSessionManager();
      var cookiesCleared = false;

      await sessionManager.saveSessionId('session-123');

      await clearStoredSessionAfterUnauthorized(
        isWeb: true,
        sessionManager: sessionManager,
        clearCookies: () async {
          cookiesCleared = true;
        },
      );

      expect(await sessionManager.getSessionId(), 'session-123');
      expect(cookiesCleared, isFalse);
    });

    test('should clear session and cookies when running natively', () async {
      final sessionManager = MockSessionManager();
      var cookiesCleared = false;

      await sessionManager.saveSessionId('session-123');

      await clearStoredSessionAfterUnauthorized(
        isWeb: false,
        sessionManager: sessionManager,
        clearCookies: () async {
          cookiesCleared = true;
        },
      );

      expect(await sessionManager.getSessionId(), isNull);
      expect(cookiesCleared, isTrue);
    });
  });

  // The discriminator that decides whether a 403 ends the session. Getting it
  // wrong in the permissive direction logs a supervisor-less user out of a
  // live till mid-shift; getting it wrong the other way leaves the poll flood
  // in place. Both directions are asserted here.
  group('looksLikeDeadSession', () {
    test('is true for the Guest 403 the alert poll actually receives', () {
      expect(looksLikeDeadSession(403, _guestBody()), isTrue);
    });

    test('is false for a plain role-denial 403', () {
      // THE regression guard: fleet_repository maps 403 to
      // FleetPermissionDeniedException and manager_providers uses it to hide
      // the manager menu. Neither may sign the operator out.
      final body = <String, dynamic>{
        'exc_type': 'PermissionError',
        '_server_messages': jsonEncode([
          jsonEncode({
            'message': 'Not permitted to view Fleet Vehicle',
            'title': 'Message',
          }),
        ]),
      };

      expect(looksLikeDeadSession(403, body), isFalse);
    });

    test('is false for a 403 with no body at all', () {
      expect(looksLikeDeadSession(403, null), isFalse);
      expect(looksLikeDeadSession(403, const <String, dynamic>{}), isFalse);
    });

    test('is false for a bare "not whitelisted" without the Guest sentence', () {
      // An authenticated call to a genuinely un-whitelisted method is a client
      // bug, not a dead session. Signing out on it would loop:
      // sign in -> poll -> sign out.
      final body = <String, dynamic>{
        'exc_type': 'PermissionError',
        '_server_messages': jsonEncode([
          jsonEncode({
            'message': 'Function jarz_pos.api.x.y is not whitelisted.',
            'title': 'Message',
          }),
        ]),
      };

      expect(looksLikeDeadSession(403, body), isFalse);
    });

    test('is true for an explicit session-expired exc_type', () {
      expect(
        looksLikeDeadSession(403, const {'exc_type': 'SessionExpired'}),
        isTrue,
      );
    });

    test('is true for 401 regardless of body', () {
      expect(looksLikeDeadSession(401, null), isTrue);
    });

    test('is false for every other status', () {
      for (final status in [200, 400, 404, 417, 426, 500, 502, null]) {
        expect(
          looksLikeDeadSession(status, _guestBody()),
          isFalse,
          reason: 'status $status must not end the session',
        );
      }
    });

    test('survives a non-Map body from an upstream proxy', () {
      expect(
        looksLikeDeadSession(403, '<html><body>Login to access</body></html>'),
        isTrue,
      );
      expect(looksLikeDeadSession(403, '<html>403 Forbidden</html>'), isFalse);
    });
  });

  // The wiring, not just the predicate: the interceptor is what actually
  // raises the gate, and it sits on the single Dio serving the whole app.
  group('SessionInterceptor reports a dead session', () {
    setUp(SessionExpiredSignal.instance.clear);
    tearDown(SessionExpiredSignal.instance.clear);

    Future<void> feedError({int? status, Object? body}) async {
      final interceptor = SessionInterceptor(
        MockSessionManager(),
        MockOfflineQueue(),
        '',
        isWebOverride: true,
      );
      final options = RequestOptions(
        path: '/api/method/jarz_pos.api.notifications.get_pending_alerts',
      );
      final completer = Completer<void>();
      interceptor.onError(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: body,
          ),
        ),
        _CapturingErrorHandler(completer),
      );
      await completer.future;
    }

    test('latches the signal on the Guest 403 from the alert poll', () async {
      await feedError(status: 403, body: _guestBody());

      expect(SessionExpiredSignal.instance.expired.value, isTrue);
    });

    test('leaves the signal alone for a role-denial 403', () async {
      await feedError(
        status: 403,
        body: const {'message': 'Not permitted to view Fleet Vehicle'},
      );

      expect(SessionExpiredSignal.instance.expired.value, isFalse);
    });

    test('leaves the signal alone for a 500', () async {
      await feedError(status: 500, body: const {'message': 'boom'});

      expect(SessionExpiredSignal.instance.expired.value, isFalse);
    });
  });

  group('SessionExpiredSignal', () {
    setUp(SessionExpiredSignal.instance.clear);
    tearDown(SessionExpiredSignal.instance.clear);

    test('stays latched until cleared', () {
      SessionExpiredSignal.instance.report();
      SessionExpiredSignal.instance.report();
      expect(SessionExpiredSignal.instance.expired.value, isTrue);

      SessionExpiredSignal.instance.clear();
      expect(SessionExpiredSignal.instance.expired.value, isFalse);
    });

    test('clear() also lifts a deferred client flip', () {
      SessionExpiredSignal.instance.deferClientFlip();
      expect(SessionExpiredSignal.instance.clientFlipDeferred, isTrue);

      SessionExpiredSignal.instance.clear();
      expect(SessionExpiredSignal.instance.clientFlipDeferred, isFalse);
    });
  });
}

/// Lets the test await the interceptor's async `onError` without a real Dio.
class _CapturingErrorHandler extends ErrorInterceptorHandler {
  _CapturingErrorHandler(this._completer);

  final Completer<void> _completer;

  void _finish() {
    if (!_completer.isCompleted) _completer.complete();
  }

  @override
  void next(DioException err) => _finish();

  @override
  void reject(DioException error) => _finish();

  @override
  void resolve(Response<dynamic> response) => _finish();
}
