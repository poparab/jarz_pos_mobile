import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/screens/kanban_board_screen.dart';

void main() {
  // Mirrors the real board ordering: Cancelled sits mid-board, so moves into it
  // can be forward, backward or adjacent depending on the source column.
  final columns = [
    KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
    KanbanColumn(id: 'processing', name: 'Processing', color: '#EEE'),
    KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#DDD'),
    KanbanColumn(id: 'ready', name: 'Ready', color: '#CCC'),
    KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#BBB'),
    KanbanColumn(id: 'courier_settlement', name: 'Courier Settlement', color: '#AAA'),
  ];

  CardMoveBlockReason? evaluate(
    String from,
    String to, {
    bool isPickup = false,
    List<KanbanColumn>? withColumns,
  }) {
    return evaluateCardMoveBlock(
      columns: withColumns ?? columns,
      fromColumnId: from,
      toColumnId: to,
      isPickupLookup: () => isPickup,
    );
  }

  group('isCancelledKanbanColumn', () {
    test('should match on id or name, case insensitively', () {
      expect(
        isCancelledKanbanColumn(
            KanbanColumn(id: 'cancelled', name: 'Whatever', color: '#FFF')),
        isTrue,
      );
      expect(
        isCancelledKanbanColumn(
            KanbanColumn(id: 'x', name: 'CANCELLED', color: '#FFF')),
        isTrue,
      );
      expect(
        isCancelledKanbanColumn(
            KanbanColumn(id: 'ready', name: 'Ready', color: '#FFF')),
        isFalse,
      );
    });
  });

  group('evaluateCardMoveBlock — Cancelled column is drag-proof', () {
    test('should block a forward move into Cancelled', () {
      expect(
        evaluate('processing', 'cancelled'),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should block a backward move into Cancelled', () {
      // Backward from Out For Delivery. Before the fix this was deliberately
      // PERMITTED and fell through to a reason-less updateInvoiceState.
      expect(
        evaluate('out_for_delivery', 'cancelled'),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should block a multi-stage forward jump into Cancelled', () {
      expect(
        evaluate('received', 'cancelled'),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should report cancel-via-menu, not "cannot move backward", for backward drops', () {
      // Ordering guard: the Cancelled check must precede the backward check so
      // staff are told how to actually cancel instead of a dead-end message.
      expect(
        evaluate('ready', 'cancelled'),
        isNot(CardMoveBlockReason.cannotMoveBackward),
      );
      expect(
        evaluate('ready', 'cancelled'),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should block by column name when the id is not literally "cancelled"', () {
      final named = [
        KanbanColumn(id: 'col-a', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'col-b', name: 'Cancelled', color: '#FFF'),
      ];
      expect(
        evaluate('col-a', 'col-b', withColumns: named),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should resolve a blocking reason for every source column', () {
      for (final source in columns.where((c) => c.id != 'cancelled')) {
        expect(
          evaluate(source.id, 'cancelled'),
          CardMoveBlockReason.cancelViaMenuOnly,
          reason: 'from ${source.id}',
        );
      }
    });
  });

  group('evaluateCardMoveBlock — existing guards still hold', () {
    test('should allow a single forward step', () {
      expect(evaluate('received', 'processing'), isNull);
      expect(evaluate('ready', 'out_for_delivery'), isNull);
    });

    test('should block a backward move to a non-Cancelled column', () {
      expect(
        evaluate('out_for_delivery', 'ready'),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });

    test('should block a multi-stage forward jump to a non-Cancelled column', () {
      expect(
        evaluate('ready', 'courier_settlement'),
        CardMoveBlockReason.moveOneStage,
      );
    });

    test('should block pickup orders from reaching Courier Settlement', () {
      expect(
        evaluate('out_for_delivery', 'courier_settlement', isPickup: true),
        CardMoveBlockReason.pickupNoSettlement,
      );
    });

    test('should allow non-pickup orders into Courier Settlement', () {
      expect(evaluate('out_for_delivery', 'courier_settlement'), isNull);
    });

    test('should silently no-op a drop onto the source column', () {
      expect(evaluate('ready', 'ready'), CardMoveBlockReason.sameColumn);
    });

    test('should not block when a column cannot be resolved', () {
      expect(evaluate('received', 'who-knows'), isNull);
      expect(evaluate('who-knows', 'received'), isNull);
      expect(evaluate('received', 'cancelled', withColumns: const []), isNull);
    });

    test('should resolve columns by name as well as id', () {
      expect(evaluate('Received', 'Processing'), isNull);
      expect(
        evaluate('Out For Delivery', 'Ready'),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });
  });

  group('evaluateCardMoveBlock — mobile Move sheet target filtering', () {
    // The phone "Move" sheet builds its target list by keeping only columns
    // where evaluateCardMoveBlock returns null, so Cancelled must never survive
    // the filter (it would otherwise hit the same reason-less updateInvoiceState).
    List<KanbanColumn> targetsFor(String fromColumnId) {
      return columns
          .where((column) => column.id != fromColumnId)
          .where((column) =>
              evaluate(fromColumnId, column.id) == null)
          .toList();
    }

    test('should never offer Cancelled as a move target', () {
      for (final source in columns) {
        expect(
          targetsFor(source.id).where(isCancelledKanbanColumn),
          isEmpty,
          reason: 'from ${source.id}',
        );
      }
    });

    test('should still offer the legitimate next stage', () {
      expect(
        targetsFor('received').map((c) => c.id),
        contains('processing'),
      );
    });
  });
}
