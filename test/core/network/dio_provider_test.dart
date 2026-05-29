import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';

import '../../helpers/mock_services.dart';

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
}