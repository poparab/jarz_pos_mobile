import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('WebSocketService (Mock)', () {
    late MockWebSocketService webSocketService;

    setUp(() {
      webSocketService = MockWebSocketService();
    });

    tearDown(() {
      webSocketService.dispose();
    });

    test('can emit kanban updates', () async {
      final updates = <Map<String, dynamic>>[];
      webSocketService.kanbanUpdates.listen(updates.add);

      webSocketService.emitKanbanUpdate({
        'action': 'update',
        'invoice_id': 'INV-001',
        'new_state': 'Processing',
      });

      await Future.delayed(const Duration(milliseconds: 10));

      expect(updates, hasLength(1));
      expect(updates.first['action'], equals('update'));
      expect(updates.first['invoice_id'], equals('INV-001'));
    });

    test('can emit invoice updates', () async {
      final updates = <Map<String, dynamic>>[];
      webSocketService.invoiceStream.listen(updates.add);

      webSocketService.emitInvoiceUpdate({
        'invoice_id': 'INV-002',
        'status': 'Submitted',
      });

      await Future.delayed(const Duration(milliseconds: 10));

      expect(updates, hasLength(1));
      expect(updates.first['invoice_id'], equals('INV-002'));
    });

    test('supports multiple listeners on kanban updates', () async {
      final listener1Updates = <Map<String, dynamic>>[];
      final listener2Updates = <Map<String, dynamic>>[];

      webSocketService.kanbanUpdates.listen(listener1Updates.add);
      webSocketService.kanbanUpdates.listen(listener2Updates.add);

      webSocketService.emitKanbanUpdate({'action': 'test'});

      await Future.delayed(const Duration(milliseconds: 10));

      expect(listener1Updates, hasLength(1));
      expect(listener2Updates, hasLength(1));
    });

    test('supports multiple listeners on invoice stream', () async {
      final listener1Updates = <Map<String, dynamic>>[];
      final listener2Updates = <Map<String, dynamic>>[];

      webSocketService.invoiceStream.listen(listener1Updates.add);
      webSocketService.invoiceStream.listen(listener2Updates.add);

      webSocketService.emitInvoiceUpdate({'invoice_id': 'INV-001'});

      await Future.delayed(const Duration(milliseconds: 10));

      expect(listener1Updates, hasLength(1));
      expect(listener2Updates, hasLength(1));
    });

    test('emits multiple updates in sequence', () async {
      final updates = <Map<String, dynamic>>[];
      webSocketService.kanbanUpdates.listen(updates.add);

      webSocketService.emitKanbanUpdate({'seq': 1});
      webSocketService.emitKanbanUpdate({'seq': 2});
      webSocketService.emitKanbanUpdate({'seq': 3});

      await Future.delayed(const Duration(milliseconds: 10));

      expect(updates, hasLength(3));
      expect(updates[0]['seq'], equals(1));
      expect(updates[1]['seq'], equals(2));
      expect(updates[2]['seq'], equals(3));
    });

    test('connect method is callable (no-op)', () {
      // Should not throw
      expect(() => webSocketService.connect(), returnsNormally);
    });

    test('streams work independently', () async {
      final kanbanUpdates = <Map<String, dynamic>>[];
      final invoiceUpdates = <Map<String, dynamic>>[];

      webSocketService.kanbanUpdates.listen(kanbanUpdates.add);
      webSocketService.invoiceStream.listen(invoiceUpdates.add);

      webSocketService.emitKanbanUpdate({'type': 'kanban'});
      webSocketService.emitInvoiceUpdate({'type': 'invoice'});

      await Future.delayed(const Duration(milliseconds: 10));

      expect(kanbanUpdates, hasLength(1));
      expect(kanbanUpdates.first['type'], equals('kanban'));
      
      expect(invoiceUpdates, hasLength(1));
      expect(invoiceUpdates.first['type'], equals('invoice'));
    });
  });
}
