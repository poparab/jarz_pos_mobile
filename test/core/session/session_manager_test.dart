import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('SessionManager', () {
    late MockSessionManager sessionManager;

    setUp(() {
      sessionManager = MockSessionManager();
    });

    test('initially has no session', () async {
      final sessionId = await sessionManager.getSessionId();
      expect(sessionId, isNull);
    });

    test('hasValidSession returns false when no session exists', () async {
      final hasSession = await sessionManager.hasValidSession();
      expect(hasSession, isFalse);
    });

    test('can save and retrieve session ID', () async {
      const testSessionId = 'test-session-123';
      
      await sessionManager.saveSessionId(testSessionId);
      final retrievedId = await sessionManager.getSessionId();
      
      expect(retrievedId, equals(testSessionId));
    });

    test('hasValidSession returns true when session exists', () async {
      await sessionManager.saveSessionId('valid-session');
      
      final hasSession = await sessionManager.hasValidSession();
      expect(hasSession, isTrue);
    });

    test('clearSession removes session ID', () async {
      await sessionManager.saveSessionId('session-to-clear');
      await sessionManager.clearSession();
      
      final sessionId = await sessionManager.getSessionId();
      expect(sessionId, isNull);
    });

    test('hasValidSession returns false for empty session ID', () async {
      await sessionManager.saveSessionId('');
      
      final hasSession = await sessionManager.hasValidSession();
      expect(hasSession, isFalse);
    });

    test('can overwrite existing session', () async {
      await sessionManager.saveSessionId('old-session');
      await sessionManager.saveSessionId('new-session');
      
      final sessionId = await sessionManager.getSessionId();
      expect(sessionId, equals('new-session'));
    });
  });
}
