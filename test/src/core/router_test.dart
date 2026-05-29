import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/router.dart';

void main() {
  group('resolveInitialAuthState', () {
    test('validates browser cookie on web even without stored session', () async {
      var hasStoredSessionCalled = false;
      var validateSessionCalled = false;

      final result = await resolveInitialAuthState(
        isWeb: true,
        hasStoredSession: () async {
          hasStoredSessionCalled = true;
          return false;
        },
        validateSession: () async {
          validateSessionCalled = true;
          return true;
        },
      );

      expect(result, isTrue);
      expect(hasStoredSessionCalled, isFalse);
      expect(validateSessionCalled, isTrue);
    });

    test('does not validate native session when no local session exists', () async {
      var validateSessionCalled = false;

      final result = await resolveInitialAuthState(
        isWeb: false,
        hasStoredSession: () async => false,
        validateSession: () async {
          validateSessionCalled = true;
          return true;
        },
      );

      expect(result, isFalse);
      expect(validateSessionCalled, isFalse);
    });

    test('validates native session when local session exists', () async {
      final result = await resolveInitialAuthState(
        isWeb: false,
        hasStoredSession: () async => true,
        validateSession: () async => true,
      );

      expect(result, isTrue);
    });

    test('returns false when web session validation throws', () async {
      final result = await resolveInitialAuthState(
        isWeb: true,
        hasStoredSession: () async => true,
        validateSession: () async => throw Exception('validation failed'),
      );

      expect(result, isFalse);
    });
  });
}