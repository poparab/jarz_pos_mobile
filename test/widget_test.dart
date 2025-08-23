// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:jarz_pos/src/core/app.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/core/session/session_manager.dart';
import 'package:jarz_pos/src/core/sync/offline_sync_service.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:jarz_pos/src/core/offline/offline_queue.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/features/pos/state/courier_ws_bridge.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/core/router.dart';

// --- Fakes (top-level) ---
class FakeSessionManager extends SessionManager {
  @override
  Future<String?> getSessionId() async => null;
  @override
  Future<void> saveSessionId(String sessionId) async {}
  @override
  Future<void> clearSession() async {}
  @override
  Future<bool> hasValidSession() async => false;
}

class FakeWebSocketService extends WebSocketService {
  @override
  void connect() {}
  @override
  void dispose() {}
}

class FakeOfflineSyncService extends OfflineSyncService {
  FakeOfflineSyncService() : super(FakeOfflineQueue(), Dio());
  @override
  void startPeriodicSync() {}
  @override
  Future<void> syncPendingTransactions() async {}
  @override
  void dispose() {}
}

class FakeOfflineQueue extends OfflineQueue {
  // Use super methods; no storage interaction required in test (Hive already in memory).
}

class FakeCourierService extends CourierService {
  FakeCourierService() : super(Dio());
  @override
  Future<List<dynamic>> getBalances() async => [];
}

class FakeCourierRepository extends CourierRepository {
  FakeCourierRepository() : super(FakeCourierService());
  @override
  Future<List<CourierBalance>> getBalances() async => [];
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository()
      : super(Dio(BaseOptions()), SessionManager());
  @override
  Future<bool> login(String u, String p) async => false;
  @override
  Future<bool> validateSession() async => false;
  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('App builds inside ProviderScope with minimal init', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    final fakeDio = Dio(BaseOptions(baseUrl: 'http://localhost'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionManagerProvider.overrideWithValue(FakeSessionManager()),
          webSocketServiceProvider.overrideWithValue(FakeWebSocketService()),
          offlineSyncServiceProvider.overrideWithValue(FakeOfflineSyncService()),
          dioProvider.overrideWithValue(fakeDio),
          courierServiceProvider.overrideWithValue(FakeCourierService()),
          courierRepositoryProvider.overrideWithValue(FakeCourierRepository()),
          courierWsBridgeProvider.overrideWithValue(null),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          authStateProvider.overrideWith((ref) async => false),
        ],
        child: const JarzPosApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(JarzPosApp), findsOneWidget);
  });
}
