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
    // Terminal Returned column, last on the board (backend order 6).
    KanbanColumn(id: 'returned', name: 'Returned', color: '#999'),
  ];

  CardMoveBlockReason? evaluate(
    String from,
    String to, {
    bool isPickup = false,
    bool isFullyReturned = false,
    List<KanbanColumn>? withColumns,
  }) {
    return evaluateCardMoveBlock(
      columns: withColumns ?? columns,
      fromColumnId: from,
      toColumnId: to,
      isPickupLookup: () => isPickup,
      isFullyReturnedLookup: () => isFullyReturned,
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

  group('isReturnedKanbanColumn', () {
    test('should match the Returned column on id or name', () {
      expect(
        isReturnedKanbanColumn(
            KanbanColumn(id: 'returned', name: 'Whatever', color: '#FFF')),
        isTrue,
      );
      expect(
        isReturnedKanbanColumn(
            KanbanColumn(id: 'x', name: 'RETURNED', color: '#FFF')),
        isTrue,
      );
    });

    test('should not match the unrelated "Returned to Sender" courier status', () {
      expect(
        isReturnedKanbanColumn(KanbanColumn(
            id: 'returned_to_sender', name: 'Returned to Sender', color: '#FFF')),
        isFalse,
      );
    });

    test('should not match ordinary columns', () {
      expect(
        isReturnedKanbanColumn(
            KanbanColumn(id: 'ready', name: 'Ready', color: '#FFF')),
        isFalse,
      );
    });
  });

  group('evaluateCardMoveBlock — Returned column is drag-proof', () {
    test('should block a forward move into Returned', () {
      expect(
        evaluate('courier_settlement', 'returned'),
        CardMoveBlockReason.returnViaMenuOnly,
      );
    });

    test('should block a backward move into Returned', () {
      final backwardBoard = [
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'returned', name: 'Returned', color: '#FFF'),
        KanbanColumn(id: 'ready', name: 'Ready', color: '#FFF'),
      ];
      expect(
        evaluate('ready', 'returned', withColumns: backwardBoard),
        CardMoveBlockReason.returnViaMenuOnly,
      );
    });

    test('should report return-via-menu, not "one stage at a time", for far drops', () {
      // Ordering guard: the Returned check must precede the distance check so
      // staff are told how to actually return an order.
      expect(
        evaluate('received', 'returned'),
        CardMoveBlockReason.returnViaMenuOnly,
      );
    });

    test('should resolve a blocking reason for every source column', () {
      for (final source in columns.where((c) => c.id != 'returned')) {
        expect(
          evaluate(source.id, 'returned'),
          CardMoveBlockReason.returnViaMenuOnly,
          reason: 'from ${source.id}',
        );
      }
    });
  });

  group('evaluateCardMoveBlock — a fully returned order is frozen', () {
    test('should block a move out of the Returned column', () {
      expect(
        evaluate('returned', 'ready', isFullyReturned: true),
        CardMoveBlockReason.fullyReturnedLocked,
      );
    });

    test('should block an otherwise legal single forward step', () {
      expect(evaluate('received', 'processing'), isNull);
      expect(
        evaluate('received', 'processing', isFullyReturned: true),
        CardMoveBlockReason.fullyReturnedLocked,
      );
    });

    test('should beat every target-specific guard', () {
      // Whatever the target, the reason must name the return — not pickup,
      // cancellation, direction or distance.
      for (final target in columns.where((c) => c.id != 'ready')) {
        expect(
          evaluate('ready', target.id, isFullyReturned: true, isPickup: true),
          CardMoveBlockReason.fullyReturnedLocked,
          reason: 'to ${target.id}',
        );
      }
    });

    test('should still no-op silently when dropped back on its own column', () {
      expect(
        evaluate('returned', 'returned', isFullyReturned: true),
        CardMoveBlockReason.sameColumn,
      );
    });

    test('should leave a partially returned order movable', () {
      // Partial returns keep the order in its active column and it must stay
      // draggable — only FULL returns are terminal.
      expect(evaluate('received', 'processing', isFullyReturned: false), isNull);
    });

    test('should default to movable when no return lookup is supplied', () {
      expect(
        evaluateCardMoveBlock(
          columns: columns,
          fromColumnId: 'received',
          toColumnId: 'processing',
          isPickupLookup: () => false,
        ),
        isNull,
      );
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

    test('should never offer Returned as a move target', () {
      for (final source in columns) {
        expect(
          targetsFor(source.id).where(isReturnedKanbanColumn),
          isEmpty,
          reason: 'from ${source.id}',
        );
      }
    });

    test('should offer nothing at all for a fully returned order', () {
      // The sheet short-circuits on this, but the filter must agree: a frozen
      // order has no legal target anywhere on the board.
      final targets = columns
          .where((column) => column.id != 'returned')
          .where((column) =>
              evaluate('returned', column.id, isFullyReturned: true) == null)
          .toList();
      expect(targets, isEmpty);
    });

    test('should still offer the legitimate next stage', () {
      expect(
        targetsFor('received').map((c) => c.id),
        contains('processing'),
      );
    });

    test('should offer In Progress as a target from Ready', () {
      expect(targetsFor('ready').map((c) => c.id), contains('processing'));
    });
  });

  group('evaluateCardMoveBlock — Ready can step back to In Progress', () {
    // Board where In Progress sits directly before Ready, as it does live.
    final liveColumns = [
      KanbanColumn(id: 'recieved', name: 'Recieved', color: '#FFF'),
      KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
      KanbanColumn(id: 'ready', name: 'Ready', color: '#DDD'),
      KanbanColumn(id: 'out_for_delivery', name: 'Out for Delivery', color: '#CCC'),
      KanbanColumn(id: 'delivered', name: 'Delivered', color: '#BBB'),
      KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#AAA'),
    ];

    test('should allow Ready -> In Progress on the live board', () {
      expect(
        evaluate('ready', 'in_progress', withColumns: liveColumns),
        isNull,
      );
    });

    test('should allow Ready -> In Progress by name too', () {
      expect(
        evaluate('Ready', 'In Progress', withColumns: liveColumns),
        isNull,
      );
    });

    test('should allow Ready -> Processing on a legacy-labelled board', () {
      // Non-adjacent on this board (Cancelled sits between them) — the carve-out
      // is about the two stages involved, not their distance.
      expect(evaluate('ready', 'processing'), isNull);
    });

    test('should still block every other backward move', () {
      expect(
        evaluate('ready', 'recieved', withColumns: liveColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
      expect(
        evaluate('out_for_delivery', 'ready', withColumns: liveColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
      expect(
        evaluate('delivered', 'in_progress', withColumns: liveColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
      expect(
        evaluate('in_progress', 'recieved', withColumns: liveColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });

    test('should keep the fully-returned freeze ahead of the carve-out', () {
      expect(
        evaluate('ready', 'in_progress',
            withColumns: liveColumns, isFullyReturned: true),
        CardMoveBlockReason.fullyReturnedLocked,
      );
    });
  });
}
