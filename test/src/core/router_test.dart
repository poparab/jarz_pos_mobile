import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';

void main() {
  group('resolveInitialAuthState', () {
    test(
      'validates browser cookie on web even without stored session',
      () async {
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
      },
    );

    test(
      'does not validate native session when no local session exists',
      () async {
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
      },
    );

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

  group('resolveRouterRedirect', () {
    test(
      'should not read authenticated providers when unauthenticated on login',
      () {
        var readAuthenticatedProvider = false;

        final result = resolveRouterRedirect(
          isAuthenticated: false,
          location: AppRoutes.login,
          readRequirePosShift: () {
            readAuthenticatedProvider = true;
            throw StateError('requirePosShiftProvider was read');
          },
          readActiveShift: () {
            readAuthenticatedProvider = true;
            throw StateError('activeShiftProvider was read');
          },
          readSelectedProfile: () {
            readAuthenticatedProvider = true;
            throw StateError('posNotifierProvider was read');
          },
        );

        expect(result, isNull);
        expect(readAuthenticatedProvider, isFalse);
      },
    );

    test('should redirect unauthenticated protected routes to login', () {
      final result = resolveRouterRedirect(
        isAuthenticated: false,
        location: AppRoutes.pos,
        readRequirePosShift: () => throw StateError('unexpected read'),
        readActiveShift: () => throw StateError('unexpected read'),
        readSelectedProfile: () => throw StateError('unexpected read'),
      );

      expect(result, AppRoutes.login);
    });

    test(
      'should redirect authenticated login to the root gate before reading shift state',
      () {
        var readAuthenticatedProvider = false;

        final result = resolveRouterRedirect(
          isAuthenticated: true,
          location: AppRoutes.login,
          readRequirePosShift: () {
            readAuthenticatedProvider = true;
            throw StateError('requirePosShiftProvider was read');
          },
          readActiveShift: () {
            readAuthenticatedProvider = true;
            throw StateError('activeShiftProvider was read');
          },
          readSelectedProfile: () {
            readAuthenticatedProvider = true;
            throw StateError('posNotifierProvider was read');
          },
        );

        expect(result, AppRoutes.root);
        expect(readAuthenticatedProvider, isFalse);
      },
    );

    test(
      'should redirect to shift start when selected profile requires a shift',
      () {
        final result = resolveRouterRedirect(
          isAuthenticated: true,
          location: AppRoutes.pos,
          readRequirePosShift: () => true,
          readActiveShift: () => const AsyncValue<ShiftEntry?>.data(null),
          readSelectedProfile: () => const {'name': 'Dokki'},
        );

        expect(result, AppRoutes.shiftStart);
      },
    );
  });

  group('home route resolution', () {
    UserRoles rolesWith(List<String> roles) =>
        UserRoles(user: 'u@x.com', roles: roles);

    test('staff without a manager role lands on Kanban', () {
      final roles = rolesWith([RoleNames.jarzPosStaff]);
      expect(roles.landsOnKanban, isTrue);
      expect(homeRouteFor(roles), AppRoutes.kanban);
    });

    test('staff who is also a manager keeps POS (manager wins)', () {
      final roles = rolesWith([RoleNames.jarzPosStaff, RoleNames.jarzManager]);
      expect(roles.landsOnKanban, isFalse);
      expect(homeRouteFor(roles), AppRoutes.pos);
    });

    test('non-staff lands on POS', () {
      final roles = rolesWith([RoleNames.posManager]);
      expect(roles.landsOnKanban, isFalse);
      expect(homeRouteFor(roles), AppRoutes.pos);
    });
  });
}
