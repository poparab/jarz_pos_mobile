import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/shift/data/shift_repository.dart';
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

  group('shift gate while the lookup is unsettled', () {
    ShiftEntry shiftFor(
      String profile, {
      bool isCurrentUser = true,
    }) => ShiftEntry(
      name: 'POS-OPEN-1',
      posProfile: profile,
      status: 'Open',
      isCurrentUser: isCurrentUser,
    );

    // The reported bug: the user reached POS while get_active_shift was still
    // in flight, and only got bounced to Start Shift when a later action
    // happened to re-run the redirect.
    test('blocks POS while the shift lookup has not resolved yet', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.pos,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue<ShiftEntry?>.loading(),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, AppRoutes.shiftStart);
    });

    // A profile switch re-runs the provider, and Riverpod carries the previous
    // profile's value forward on the loading state. That stale value must not
    // satisfy the gate for the newly selected profile.
    test('blocks POS when a refresh still holds the previous profile', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.pos,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue<ShiftEntry?>.loading()
            .copyWithPrevious(AsyncValue.data(shiftFor('Zamalek'))),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, AppRoutes.shiftStart);
    });

    test('blocks POS when the shift lookup failed', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.pos,
        readRequirePosShift: () => true,
        readActiveShift: () =>
            AsyncValue<ShiftEntry?>.error(Exception('boom'), StackTrace.empty),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, AppRoutes.shiftStart);
    });

    test('blocks POS when the profile shift belongs to another user', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.pos,
        readRequirePosShift: () => true,
        readActiveShift: () =>
            AsyncValue.data(shiftFor('Dokki', isCurrentUser: false)),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, AppRoutes.shiftStart);
    });

    test('lets the owner of a matching shift onto POS', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.pos,
        readRequirePosShift: () => true,
        readActiveShift: () => AsyncValue.data(shiftFor('Dokki')),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, isNull);
    });

    // A background revalidation of a shift the user already holds must not
    // yank them off the screen they are working on.
    test('keeps a held shift valid across a background refresh', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.kanban,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue<ShiftEntry?>.loading()
            .copyWithPrevious(AsyncValue.data(shiftFor('Dokki'))),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, isNull);
    });

    test('sends the owner of a matching shift off the Start Shift screen', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.shiftStart,
        readRequirePosShift: () => true,
        readActiveShift: () => AsyncValue.data(shiftFor('Dokki')),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, AppRoutes.pos);
    });

    // The reported bug: closing a shift made the active shift disappear, the
    // gate fired on the End Shift screen and bounced the user to Start Shift —
    // past the closing summary and the Logout button on it — so ending a shift
    // silently left the operator signed in.
    test('keeps the closing summary up once the shift is gone', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.shiftEnd,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue<ShiftEntry?>.data(null),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, isNull);
    });

    test('does not bounce End Shift when the shift lookup failed', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.shiftEnd,
        readRequirePosShift: () => true,
        readActiveShift: () =>
            AsyncValue<ShiftEntry?>.error(Exception('boom'), StackTrace.empty),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, isNull);
    });

    test('still sends an unauthenticated user off End Shift to login', () {
      final result = resolveRouterRedirect(
        isAuthenticated: false,
        location: AppRoutes.shiftEnd,
        readRequirePosShift: () => throw StateError('unexpected read'),
        readActiveShift: () => throw StateError('unexpected read'),
        readSelectedProfile: () => throw StateError('unexpected read'),
      );

      expect(result, AppRoutes.login);
    });

    test('holds an unsettled lookup on Start Shift without bouncing', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.shiftStart,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue<ShiftEntry?>.loading(),
        readSelectedProfile: () => const {'name': 'Dokki'},
      );

      expect(result, isNull);
    });
  });

  group('shift gate without a selected profile', () {
    // A Jarz POS Staff user lands straight on the Kanban board and never passes
    // through profile selection. The gate used to require a selected profile,
    // so those users skipped it entirely while still collecting cash and
    // dispatching orders.
    test('sends a shift-required user with no profile to profile selection', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.kanban,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue.data(null),
        readSelectedProfile: () => null,
      );

      expect(result, AppRoutes.selectProfile);
    });

    test('does not bounce a user already on profile selection', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.selectProfile,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue.data(null),
        readSelectedProfile: () => null,
      );

      expect(result, isNull);
    });

    test('does not bounce a user already on shift start', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.shiftStart,
        readRequirePosShift: () => true,
        readActiveShift: () => const AsyncValue.data(null),
        readSelectedProfile: () => null,
      );

      expect(result, isNull);
    });

    test('leaves users without a shift requirement alone', () {
      final result = resolveRouterRedirect(
        isAuthenticated: true,
        location: AppRoutes.kanban,
        readRequirePosShift: () => false,
        readActiveShift: () => const AsyncValue.data(null),
        readSelectedProfile: () => null,
      );

      expect(result, isNull);
    });
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

  // Guards the half of the bug `resolveRouterRedirect` cannot see. The gate
  // reads `activeShiftProvider`, but GoRouter only re-evaluates `redirect` on
  // navigation or when `refreshListenable` fires — and the shift lookup was
  // never wired into that listenable. So a user who reached POS while
  // get_active_shift was still in flight stayed there, with no shift open,
  // until some unrelated navigation happened to re-trigger the gate.
  group('routerProvider shift-gate wiring', () {
    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    ProviderContainer containerFor({
      required bool isAuthenticated,
      required ShiftRepository shiftRepository,
    }) {
      final container = ProviderContainer(
        overrides: [
          currentAuthStateProvider.overrideWith((ref) => isAuthenticated),
          userRolesFutureProvider.overrideWith(
            (ref) async => const UserRoles(
              user: 'u@x.com',
              roles: [],
              requirePosShift: true,
            ),
          ),
          shiftRepositoryProvider.overrideWithValue(shiftRepository),
          posNotifierProvider.overrideWith(
            (ref) => _PosNotifierStub(
              PosState(selectedProfile: const {'name': 'Dokki'}),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('subscribes the redirect gate to the shift lookup', () async {
      final repository = _RecordingShiftRepository();
      final container = containerFor(
        isAuthenticated: true,
        shiftRepository: repository,
      );

      container.read(routerProvider);
      await pumpEventQueue();

      // Building the router alone must establish the subscription — that is
      // what makes the gate re-run once the lookup resolves.
      expect(repository.getActiveShiftCalls, greaterThan(0));
    });

    test('does not look up a shift for an unauthenticated session', () async {
      final repository = _RecordingShiftRepository();
      final container = containerFor(
        isAuthenticated: false,
        shiftRepository: repository,
      );

      container.read(routerProvider);
      await pumpEventQueue();

      // The login screen must never call get_active_shift.
      expect(repository.getActiveShiftCalls, 0);
    });
  });

  // Mirror of the group above for the *roles* lookup. `ref.listen` initialises
  // the provider it listens to, and `routerProvider` is watched unconditionally
  // by `JarzPosApp.build`, so an ungated listen fired `get_current_user_roles`
  // with no session while the user sat on /login — 403, 149 production events.
  // The same listen re-fired straight after `LoginNotifier.logout()`
  // invalidates the provider, i.e. against a session that had just been killed.
  group('routerProvider roles-gate wiring', () {
    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    ProviderContainer containerFor({
      required bool isAuthenticated,
      required UserService userService,
    }) {
      final container = ProviderContainer(
        overrides: [
          currentAuthStateProvider.overrideWith((ref) => isAuthenticated),
          // Deliberately NOT overriding `userRolesFutureProvider` here: the
          // point of these tests is whether that provider gets initialised at
          // all, so the real one has to run and reach this recording service.
          userServiceProvider.overrideWithValue(userService),
          shiftRepositoryProvider.overrideWithValue(
            _RecordingShiftRepository(),
          ),
          posNotifierProvider.overrideWith(
            (ref) => _PosNotifierStub(
              PosState(selectedProfile: const {'name': 'Dokki'}),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('does not fetch roles for an unauthenticated session', () async {
      final service = _RecordingUserService();
      final container = containerFor(
        isAuthenticated: false,
        userService: service,
      );

      container.read(routerProvider);
      await pumpEventQueue();

      // The login screen has no session, so get_current_user_roles can only
      // ever answer 403 there.
      expect(service.getCurrentUserRolesCalls, 0);
    });

    test('subscribes the gate to the roles lookup once authenticated', () async {
      final service = _RecordingUserService();
      final container = containerFor(
        isAuthenticated: true,
        userService: service,
      );

      container.read(routerProvider);
      await pumpEventQueue();

      // Regression guard on the fix: building the router while authenticated
      // must still establish the subscription. Without it the landing gate at
      // `router.dart` never re-runs when roles land, and a cold-start user is
      // stranded on the spinner.
      expect(service.getCurrentUserRolesCalls, greaterThan(0));
    });
  });
}

class _RecordingUserService extends UserService {
  _RecordingUserService() : super(Dio());

  int getCurrentUserRolesCalls = 0;

  @override
  Future<UserRoles> getCurrentUserRoles() async {
    getCurrentUserRolesCalls++;
    return const UserRoles(user: 'u@x.com', roles: [], requirePosShift: true);
  }
}

class _RecordingShiftRepository extends ShiftRepository {
  _RecordingShiftRepository() : super(Dio());

  int getActiveShiftCalls = 0;

  @override
  Future<ShiftEntry?> getActiveShift({String? posProfile}) async {
    getActiveShiftCalls++;
    return null;
  }
}

class _DummyPosRepository extends PosRepository {
  _DummyPosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async => const [];

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(String posProfile) async =>
      const [];
}

class _DummyDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];

  @override
  Future<void> upsert(draft) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _PosNotifierStub extends PosNotifier {
  _PosNotifierStub(PosState initialState)
    : super(_DummyPosRepository(), _DummyDraftCartRepository()) {
    state = initialState;
  }
}
