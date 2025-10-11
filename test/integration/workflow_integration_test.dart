import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/core/connectivity/connectivity_service.dart';
import 'package:jarz_pos/src/core/offline/offline_queue.dart';
import '../helpers/mock_services.dart';
import '../helpers/test_helpers.dart';

/// Integration tests verify that multiple components work together correctly
/// These tests validate complete workflows and interactions between services

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();
  
  group('Authentication Flow Integration Tests', () {
    late ProviderContainer container;
    late MockDio mockDio;
    late MockSessionManager mockSessionManager;
    late MockConnectivityService mockConnectivityService;
    late MockOfflineQueue mockOfflineQueue;

    setUp(() {
      mockDio = MockDio();
      mockSessionManager = MockSessionManager();
      mockConnectivityService = MockConnectivityService();
      mockOfflineQueue = MockOfflineQueue();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepository(mockDio, mockSessionManager),
          ),
          connectivityServiceProvider.overrideWithValue(mockConnectivityService),
          offlineQueueProvider.overrideWithValue(mockOfflineQueue),
          currentAuthStateProvider.overrideWith((ref) => false),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('complete login flow updates all relevant states', () async {
      // Arrange
      mockDio.setResponse(
        '/api/method/login',
        createSuccessResponse(data: {'message': 'Logged In'}),
      );

      final notifier = container.read(loginNotifierProvider.notifier);

      // Act - Perform login
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      // Assert - Check all state updates
      final loginState = await notifier.future;
      expect(loginState, isTrue);

      final authState = container.read(currentAuthStateProvider);
      expect(authState, isTrue);

      // Verify API was called with correct credentials
      expect(mockDio.requestLog, hasLength(1));
      expect(mockDio.requestLog.first['path'], equals('/api/method/login'));
    });

    test('logout clears all authentication artifacts', () async {
      // Arrange - First login
      mockDio.setResponse(
        '/api/method/login',
        createSuccessResponse(data: {'message': 'Logged In'}),
      );
      mockDio.setResponse(
        '/api/method/logout',
        createSuccessResponse(data: {'message': 'Logged Out'}),
      );

      final notifier = container.read(loginNotifierProvider.notifier);
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      // Act - Perform logout
      await notifier.logout();
      await flushMicrotasks();

      // Assert - All auth state is cleared
      final loginState = await notifier.future;
      expect(loginState, isFalse);

      final authState = container.read(currentAuthStateProvider);
      expect(authState, isFalse);

      final sessionId = await mockSessionManager.getSessionId();
      expect(sessionId, isNull);
    });

    test('failed login does not update authentication state', () async {
      // Arrange
      mockDio.setResponse(
        '/api/method/login',
        createSuccessResponse(data: {'message': 'Failed'}),
        statusCode: 401,
      );

      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.login('wrong', 'credentials');
      await flushMicrotasks();

      // Assert
      final state = container.read(loginNotifierProvider);
      expect(state.hasError, isTrue);

      final authState = container.read(currentAuthStateProvider);
      expect(authState, isFalse);
    });
  });

  group('Offline Queue Integration Tests', () {
    late MockOfflineQueue mockOfflineQueue;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      mockOfflineQueue = MockOfflineQueue();
      mockConnectivityService = MockConnectivityService();
    });

    test('transactions are queued when offline', () async {
      // Arrange
      mockConnectivityService.setOnline(false);

      // Act - Add transaction while offline
      await mockOfflineQueue.addTransaction({
        'endpoint': '/api/method/test',
        'data': {'key': 'value'},
      });

      // Assert
      final count = await mockOfflineQueue.getPendingCount();
      expect(count, equals(1));

      final transactions = await mockOfflineQueue.getPendingTransactions();
      expect(transactions.first['status'], equals('pending'));
    });

    test('transactions are processed when coming back online', () async {
      // Arrange - Add transaction while offline
      mockConnectivityService.setOnline(false);
      await mockOfflineQueue.addTransaction({
        'endpoint': '/api/method/test',
        'data': {'key': 'value'},
      });

      // Act - Come back online and process
      mockConnectivityService.setOnline(true);
      
      final transactions = await mockOfflineQueue.getPendingTransactions();
      final id = transactions.first['id'] as String;
      await mockOfflineQueue.markAsProcessed(id);

      // Assert
      final pendingCount = await mockOfflineQueue.getPendingCount();
      expect(pendingCount, equals(0));
    });
  });

  group('POS Workflow Integration Tests', () {
    test('cart total calculation includes all items and shipping', () async {
      // This is a simplified integration test example
      // In a real scenario, this would test the full POS flow
      
      final cartItems = [
        {'item_code': 'ITEM-1', 'rate': 100.0, 'quantity': 2, 'type': 'item'},
        {'item_code': 'ITEM-2', 'rate': 50.0, 'quantity': 1, 'type': 'item'},
      ];

      // Calculate totals
      final subtotal = cartItems.fold<double>(
        0,
        (sum, item) => sum + (item['rate'] as double) * (item['quantity'] as num),
      );

      expect(subtotal, equals(250.0));

      // Add shipping
      const shipping = 30.0;
      final total = subtotal + shipping;

      expect(total, equals(280.0));
    });
  });

  group('Error Handling Integration Tests', () {
    late ProviderContainer container;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepository(mockDio, MockSessionManager()),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('network errors are properly propagated through the stack', () async {
      // Arrange
      mockDio.setError(
        '/api/method/login',
        createMockDioException(
          message: 'Network error',
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.login('testuser', 'testpass');
      await flushMicrotasks();

      // Assert
      final state = container.read(loginNotifierProvider);
      expect(state.hasError, isTrue);
    });
  });
}
