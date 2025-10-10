import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/src/core/connectivity/connectivity_service.dart';
import 'package:jarz_pos/src/core/offline/offline_queue.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_filter_options.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/services/kanban_service.dart';
import 'package:jarz_pos/src/features/kanban/services/notification_polling_service.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _FakeKanbanService extends KanbanService {
  _FakeKanbanService()
      : super(Dio(BaseOptions()));

  Map<String, dynamic>? lastFilters;
  String? lastUpdatedInvoice;
  String? lastUpdatedState;
  bool updateShouldSucceed = true;

  @override
  Future<List<KanbanColumn>> getKanbanColumns() async {
    return [
      KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
      KanbanColumn(id: 'processing', name: 'Processing', color: '#EEE'),
    ];
  }

  @override
  Future<Map<String, List<InvoiceCard>>> getKanbanInvoices({Map<String, dynamic>? filters}) async {
    lastFilters = filters == null ? null : Map<String, dynamic>.from(filters);
    final older = InvoiceCard.fromJson({
      'name': 'INV-OLD',
      'invoice_id_short': 'OLD',
      'customer_name': 'Alice',
      'customer': 'CUST-1',
      'territory': 'Metro',
      'status': 'Received',
      'posting_date': '2024-01-01',
      'grand_total': 100,
      'net_total': 90,
      'total_taxes_and_charges': 10,
      'full_address': '123 Test',
      'items': const [],
    });
    final newer = InvoiceCard.fromJson({
      'name': 'INV-NEW',
      'invoice_id_short': 'NEW',
      'customer_name': 'Bob',
      'customer': 'CUST-2',
      'territory': 'Metro',
      'status': 'Received',
      'posting_date': '2024-03-01',
      'grand_total': 150,
      'net_total': 140,
      'total_taxes_and_charges': 10,
      'full_address': '456 Test',
      'items': const [],
    });
    return {
      'received': [older, newer],
      'processing': const [],
    };
  }

  @override
  Future<KanbanFilterOptions> getKanbanFilters() async {
    return KanbanFilterOptions(
      customers: [FilterOption(value: 'CUST-1', label: 'Alice')],
      states: const [],
    );
  }

  @override
  Future<bool> updateInvoiceState(String invoiceId, String newState) async {
    lastUpdatedInvoice = invoiceId;
    lastUpdatedState = newState;
    return updateShouldSucceed;
  }
}

class _FakeWebSocketService extends WebSocketService {
  final _kanbanController = StreamController<Map<String, dynamic>>.broadcast();
  final _invoiceController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  void connect() {}

  @override
  Stream<Map<String, dynamic>> get kanbanUpdates => _kanbanController.stream;

  @override
  Stream<Map<String, dynamic>> get invoiceStream => _invoiceController.stream;

  @override
  void dispose() {
    _kanbanController.close();
    _invoiceController.close();
  }
}

class _FakeNotificationPollingService extends NotificationPollingService {
  _FakeNotificationPollingService() : super(Dio());

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get notificationStream => _controller.stream;

  @override
  void startPolling({int intervalSeconds = 30}) {}

  @override
  void stopPolling() {}

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeOfflineQueue extends OfflineQueue {
  final List<Map<String, dynamic>> _transactions = [];

  @override
  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    _transactions.add({
      'id': (_transactions.length + 1).toString(),
      'data': transaction,
      'status': 'pending',
      'endpoint': transaction['endpoint'],
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    return _transactions
        .where((tx) => tx['status'] == 'pending')
        .map((tx) => Map<String, dynamic>.from(tx))
        .toList();
  }

  @override
  Future<void> markAsProcessed(String id) async {
    for (final tx in _transactions) {
      if (tx['id'] == id) {
        tx['status'] = 'processed';
      }
    }
  }

  @override
  Future<void> markAsError(String id, String error) async {
    for (final tx in _transactions) {
      if (tx['id'] == id) {
        tx['status'] = 'error';
        tx['error'] = error;
      }
    }
  }

  @override
  Future<int> getPendingCount() async {
    return _transactions.where((tx) => tx['status'] == 'pending').length;
  }

  @override
  Future<void> clearAll() async {
    _transactions.clear();
  }
}

class _FakeConnectivityService extends ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _online = true;

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  @override
  void startMonitoring() {}

  @override
  Future<bool> hasConnection() async => _online;

  @override
  bool get isOnline => _online;

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    _controller.add(value);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _DummyPosRepository extends PosRepository {
  _DummyPosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async => const [];

  @override
  Future<List<Map<String, dynamic>>> getItems(String posProfile) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(String posProfile) async => const [];
}

class _PosNotifierStub extends PosNotifier {
  _PosNotifierStub() : super(_DummyPosRepository()) {
    state = state.copyWith(
      profiles: const [
        {'name': 'Main'},
        {'name': 'Branch-2'},
      ],
    );
  }
}

Future<void> _flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  group('KanbanNotifier', () {
    late ProviderContainer container;
    late _FakeKanbanService service;

    setUp(() {
      service = _FakeKanbanService();
      container = ProviderContainer(
        overrides: [
          kanbanServiceProvider.overrideWithValue(service),
          webSocketServiceProvider.overrideWithValue(_FakeWebSocketService()),
          notificationPollingServiceProvider
              .overrideWithValue(_FakeNotificationPollingService()),
          offlineQueueProvider.overrideWithValue(_FakeOfflineQueue()),
          connectivityServiceProvider.overrideWithValue(_FakeConnectivityService()),
          connectivityStatusProvider.overrideWith((ref) => Stream<bool>.value(true)),
          posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loadInvoices sorts Received column by posting date descending', () async {
      final notifier = container.read(kanbanProvider.notifier);

      await notifier.loadKanbanData();
      await _flushMicrotasks();

      final state = container.read(kanbanProvider);
      final received = state.invoices['received'];
      expect(received, isNotNull);
      expect(received, hasLength(2));
      expect(received!.first.id, 'INV-NEW');
      expect(received.last.id, 'INV-OLD');
    });

    test('updateFilters forwards filter payload to service', () async {
      final notifier = container.read(kanbanProvider.notifier);

      await notifier.loadKanbanData();
      await _flushMicrotasks();

      notifier.updateFilters(const KanbanFilters(searchTerm: 'bob'));
      await _flushMicrotasks();

      expect(service.lastFilters?['searchTerm'], 'bob');
    });

    test('branch selection injects branches filter', () async {
      final notifier = container.read(kanbanProvider.notifier);

      await notifier.loadKanbanData();
      await _flushMicrotasks();

      notifier.setSelectedBranches({'Main'});
      await _flushMicrotasks();
      expect(service.lastFilters?['branches'], equals(['Main']));

      notifier.toggleBranch('Branch-2');
      await _flushMicrotasks();
      final selected = container.read(kanbanProvider).selectedBranches;
      expect(selected, containsAll({'Main', 'Branch-2'}));
      expect(service.lastFilters?['branches'], containsAll(['Main', 'Branch-2']));
    });
  });
}
