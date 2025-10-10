import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';
import 'package:jarz_pos/src/core/router.dart';
import '../../../helpers/test_helpers.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository(super.dio, super.sessionManager);
  
  bool shouldSucceed = true;
  String? lastUsername;
  String? lastPassword;
  bool logoutCalled = false;

  @override
  Future<bool> login(String username, String password) async {
    lastUsername = username;
    lastPassword = password;
    return shouldSucceed;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  group('LoginNotifier', () {
    late ProviderContainer container;
    late FakeAuthRepository fakeAuthRepo;

    setUp(() {
      fakeAuthRepo = FakeAuthRepository(createMockDio(), null as dynamic);
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
          currentAuthStateProvider.overrideWith((ref) => false),
        ],
      );
    });

    tearDown(() {
      container.dispose();
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
      final errorRepo = FakeAuthRepository(createMockDio(), null as dynamic);
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(errorRepo),
        ],
      );

      // Override login to throw
      errorRepo.login = (username, password) => throw Exception('Network error');

      final notifier = container.read(loginNotifierProvider.notifier);
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      final state = container.read(loginNotifierProvider);
      expect(state.hasError, isTrue);
    });
  });
}
