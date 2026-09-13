import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:jarz_pos/src/core/constants/storage_keys.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/plan_board_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_today_providers.dart';
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

/// The Production Board's persisted jar queue, observable without Hive.
class _FakeBasketRepository implements ProductionBasketRepository {
  _FakeBasketRepository();
  ProductionBasket? stored;

  @override
  Future<ProductionBasket?> load() async => stored;
  @override
  Future<void> save(ProductionBasket basket) async =>
      stored = basket.lines.isEmpty ? null : basket;
  @override
  Future<void> clear() async => stored = null;
}

const _previousUsersJar = BatchLine(
  itemCode: 'JAR-LOTUS',
  itemName: 'Lotus Jar',
  bomName: 'BOM-JAR-LOTUS-001',
  bomQtyYield: 1,
  batches: 60,
);

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

    group('Production Board state', () {
      late _FakeBasketRepository basketRepo;

      setUp(() {
        basketRepo = _FakeBasketRepository();
        container.dispose();
        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
            currentAuthStateProvider.overrideWith((ref) => false),
            productionBasketRepositoryProvider.overrideWithValue(basketRepo),
          ],
        );
      });

      /// What user A leaves typed and queued on a shared floor tablet.
      void typeAsPreviousUser() {
        container.read(productionBasketProvider.notifier).addOrRaise(
          _previousUsersJar,
        );
        container
            .read(dailyPlanDraftProvider.notifier)
            .setQuantity('JAR-LOTUS', 60);
        container.read(planInvalidEntriesProvider.notifier).state = {
          'JAR-BERRY': '1.36',
        };
        container
            .read(productionTodayProvider.notifier)
            .setBaseBatches('BASE-FUDGE', 2);
        container.read(baseSelectionProvider.notifier).select('BASE-FUDGE');
        container.read(baseProductionDateProvider.notifier).state =
            DateTime(2026, 9, 12);
      }

      void expectNothingTyped() {
        expect(container.read(productionBasketProvider).lines, isEmpty);
        expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
        expect(container.read(planInvalidEntriesProvider), isEmpty);
        expect(container.read(productionTodayProvider).baseBatches, isEmpty);
        expect(container.read(baseSelectionProvider), isEmpty);
        expect(container.read(baseProductionDateProvider), isNull);
      }

      test('logout leaves none of the typed or queued jars behind', () async {
        // The next user on the tablet saw them in their own fields, and
        // Start batches would have posted them under that user's name.
        typeAsPreviousUser();

        await container.read(loginNotifierProvider.notifier).logout();
        await flushMicrotasks();

        expectNothingTyped();
      });

      test('logout clears a saved queue the board never opened', () async {
        // Only an already-open Hive box was cleared. A queue saved in an
        // earlier app process sat in a closed box, survived the logout, and
        // came back into the next user's fields when the board opened.
        basketRepo.stored = const ProductionBasket(lines: [_previousUsersJar]);

        await container.read(loginNotifierProvider.notifier).logout();
        await flushMicrotasks();
        expect(basketRepo.stored, isNull);

        // And a board opened straight after cannot read it back in a race.
        basketRepo.stored = const ProductionBasket(lines: [_previousUsersJar]);
        await container.read(productionBasketProvider.notifier).restore();
        expect(container.read(productionBasketProvider).lines, isEmpty);
      });

      test('logging in as the next user starts from an empty board', () async {
        // A crash between sessions skips logout; login is the second chance.
        typeAsPreviousUser();
        basketRepo.stored = const ProductionBasket(lines: [_previousUsersJar]);

        await container
            .read(loginNotifierProvider.notifier)
            .login('next-user', 'secret');
        await flushMicrotasks();

        expectNothingTyped();
        expect(basketRepo.stored, isNull);
      });
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
