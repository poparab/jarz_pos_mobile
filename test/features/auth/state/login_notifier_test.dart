import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:jarz_pos/src/core/constants/storage_keys.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';
import 'package:jarz_pos/src/core/router.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/mock_services.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository(super.dio, super.sessionManager);
  
  bool shouldSucceed = true;
  String? lastUsername;
  String? lastPassword;
  bool logoutCalled = false;
  
  // Allow dynamic login behavior
  Future<bool> Function(String username, String password)? loginCallback;

  @override
  Future<bool> login(String username, String password) async {
    lastUsername = username;
    lastPassword = password;
    if (loginCallback != null) {
      return loginCallback!(username, password);
    }
    return shouldSucceed;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  // LoginNotifier wipes the per-user Hive caches on both login and logout, so
  // the boxes it touches have to exist on disk somewhere for this suite.
  setUpAll(() => setUpTestHive(prefix: 'login-notifier-test'));
  tearDownAll(tearDownTestHive);

  group('LoginNotifier', () {
    late ProviderContainer container;
    late FakeAuthRepository fakeAuthRepo;

    setUp(() {
      fakeAuthRepo = FakeAuthRepository(createMockDio(), MockSessionManager());
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
          currentAuthStateProvider.overrideWith((ref) => false),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      // The cache wipe is fire-and-forget; let it land before resetting the
      // boxes so no draft/lead state leaks into the next test.
      await flushMicrotasks();
      await clearOpenTestHiveBoxes(const [
        HiveBoxes.draftCarts,
        HiveBoxes.leadsCache,
        HiveBoxes.inventoryCount,
        HiveBoxes.productionBasket,
      ]);
    });

    test('initial state is not logged in', () async {
      final notifier = container.read(loginNotifierProvider.notifier);
      final initialState = await notifier.future;
      
      expect(initialState, isFalse);
    });

    test('successful login updates state to logged in', () async {
      fakeAuthRepo.shouldSucceed = true;
      final notifier = container.read(loginNotifierProvider.notifier);

      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      final state = await notifier.future;
      expect(state, isTrue);
      expect(fakeAuthRepo.lastUsername, equals('testuser'));
      expect(fakeAuthRepo.lastPassword, equals('testpass'));
    });

    test('failed login sets error state', () async {
      fakeAuthRepo.shouldSucceed = false;
      final notifier = container.read(loginNotifierProvider.notifier);

      await notifier.login('wrong', 'credentials');
      await flushMicrotasks();

      final state = container.read(loginNotifierProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Invalid credentials'));
    });

    test('login sets loading state during execution', () async {
      fakeAuthRepo.shouldSucceed = true;
      final notifier = container.read(loginNotifierProvider.notifier);

      // Start login but don't await
      final loginFuture = notifier.login('testuser', 'testpass');
      
      // Check state immediately
      final state = container.read(loginNotifierProvider);
      expect(state.isLoading, isTrue);

      // Complete the login
      await loginFuture;
    });

    test('logout clears authentication state', () async {
      fakeAuthRepo.shouldSucceed = true;
      final notifier = container.read(loginNotifierProvider.notifier);

      // First login
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();
      
      expect(await notifier.future, isTrue);

      // Then logout
      await notifier.logout();
      await flushMicrotasks();

      expect(fakeAuthRepo.logoutCalled, isTrue);
      final state = await notifier.future;
      expect(state, isFalse);
    });

    test('logout wipes the per-user Hive caches', () async {
      final notifier = container.read(loginNotifierProvider.notifier);

      // No login first: login runs the same cache wipe asynchronously, which
      // would race the seeding below. logout() is independent of it.
      // Seed the caches a previous user would have left behind.
      final drafts = await Hive.openBox(HiveBoxes.draftCarts);
      await drafts.put('draft-1', {'id': 'draft-1'});
      final leads = await Hive.openBox(HiveBoxes.leadsCache);
      await leads.put('lead-1', {'name': 'LEAD-0001'});
      expect(drafts.isNotEmpty, isTrue);
      expect(leads.isNotEmpty, isTrue);

      await notifier.logout();
      // LoginNotifier clears the caches fire-and-forget, so poll (bounded)
      // rather than assuming a single event-loop turn covers the disk writes.
      await pumpUntil(() => drafts.isEmpty && leads.isEmpty);

      expect(drafts.isEmpty, isTrue,
          reason: 'logout must clear the draft-cart cache');
      expect(leads.isEmpty, isTrue,
          reason: 'logout must clear the leads cache');
    });

    test('successful login updates currentAuthStateProvider', () async {
      fakeAuthRepo.shouldSucceed = true;
      final notifier = container.read(loginNotifierProvider.notifier);

      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      final authState = container.read(currentAuthStateProvider);
      expect(authState, isTrue);
    });

    test('logout updates currentAuthStateProvider to false', () async {
      fakeAuthRepo.shouldSucceed = true;
      final notifier = container.read(loginNotifierProvider.notifier);

      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();
      
      await notifier.logout();
      await flushMicrotasks();

      final authState = container.read(currentAuthStateProvider);
      expect(authState, isFalse);
    });

    test('handles exceptions during login', () async {
      final errorRepo = FakeAuthRepository(createMockDio(), MockSessionManager());
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(errorRepo),
        ],
      );

      // Override login to throw
      errorRepo.loginCallback = (username, password) => throw Exception('Network error');

      final notifier = container.read(loginNotifierProvider.notifier);
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      final state = container.read(loginNotifierProvider);
      expect(state.hasError, isTrue);
    });
  });
}
