import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/screens/kanban_board_screen.dart';

void main() {
  // Mirrors the live board since the Ready stage was removed (2026-10-13):
  // Received -> In Progress -> Out for Delivery, then settlement, with the
  // terminal Cancelled and Returned columns at the end.
  final columns = [
    KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
    KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
    KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#DDD'),
    KanbanColumn(id: 'courier_settlement', name: 'Courier Settlement', color: '#CCC'),
    KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#BBB'),
    // Terminal Returned column, last on the board.
    KanbanColumn(id: 'returned', name: 'Returned', color: '#AAA'),
  ];

  // Cancelled sitting mid-board, so a move into it can be backward too.
  final cancelMidBoard = [
    KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
    KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
    KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#DDD'),
    KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#CCC'),
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
            KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#FFF')),
        isFalse,
      );
    });
  });

  group('evaluateCardMoveBlock — Cancelled column is drag-proof', () {
    test('should block a forward move into Cancelled', () {
      expect(
        evaluate('in_progress', 'cancelled', withColumns: cancelMidBoard),
        CardMoveBlockReason.cancelViaMenuOnly,
      );
    });

    test('should block a backward move into Cancelled', () {
      expect(
        evaluate('out_for_delivery', 'cancelled', withColumns: cancelMidBoard),
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
      final reason =
          evaluate('out_for_delivery', 'cancelled', withColumns: cancelMidBoard);
      expect(reason, isNot(CardMoveBlockReason.cannotMoveBackward));
      expect(reason, CardMoveBlockReason.cancelViaMenuOnly);
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
            KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#FFF')),
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
        KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#FFF'),
      ];
      expect(
        evaluate('in_progress', 'returned', withColumns: backwardBoard),
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
        evaluate('returned', 'in_progress', isFullyReturned: true),
        CardMoveBlockReason.fullyReturnedLocked,
      );
    });

    test('should block an otherwise legal single forward step', () {
      expect(evaluate('received', 'in_progress'), isNull);
      expect(
        evaluate('received', 'in_progress', isFullyReturned: true),
        CardMoveBlockReason.fullyReturnedLocked,
      );
    });

    test('should beat every target-specific guard', () {
      // Whatever the target, the reason must name the return — not pickup,
      // cancellation, direction or distance.
      for (final target in columns.where((c) => c.id != 'in_progress')) {
        expect(
          evaluate('in_progress', target.id, isFullyReturned: true, isPickup: true),
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
      expect(evaluate('received', 'in_progress', isFullyReturned: false), isNull);
    });

    test('should default to movable when no return lookup is supplied', () {
      expect(
        evaluateCardMoveBlock(
          columns: columns,
          fromColumnId: 'received',
          toColumnId: 'in_progress',
          isPickupLookup: () => false,
        ),
        isNull,
      );
    });
  });

  group('evaluateCardMoveBlock — three-step flow without Ready', () {
    test('should allow Received -> In Progress', () {
      expect(evaluate('received', 'in_progress'), isNull);
    });

    test('should allow In Progress -> Out for Delivery with 3-column board', () {
      final threeColumns = [
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
        KanbanColumn(id: 'out_for_delivery', name: 'Out for Delivery', color: '#DDD'),
      ];
      expect(
        evaluate('in_progress', 'out_for_delivery', withColumns: threeColumns),
        isNull,
      );
      expect(evaluate('in_progress', 'out_for_delivery'), isNull);
    });

    test('should block Out for Delivery -> In Progress', () {
      expect(
        evaluate('out_for_delivery', 'in_progress'),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });

    test('should block In Progress -> Received', () {
      expect(
        evaluate('in_progress', 'received'),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });

    test('should block Received -> Out for Delivery (skipping In Progress)', () {
      expect(
        evaluate('received', 'out_for_delivery'),
        CardMoveBlockReason.moveOneStage,
      );
    });
  });

  group('evaluateCardMoveBlock — no backward move at all', () {
    test('should block every backward move between ordinary columns', () {
      final ordinary = columns
          .where((c) => !isCancelledKanbanColumn(c) && !isReturnedKanbanColumn(c))
          .toList();
      for (var from = 0; from < ordinary.length; from++) {
        for (var to = 0; to < from; to++) {
          expect(
            evaluate(ordinary[from].id, ordinary[to].id),
            CardMoveBlockReason.cannotMoveBackward,
            reason: '${ordinary[from].id} -> ${ordinary[to].id}',
          );
        }
      }
    });

    test('should block the old Ready -> In Progress correction on a legacy board', () {
      // An older backend may still send Ready during the rollout; the
      // kitchen-correction carve-out is gone there too.
      final legacyColumns = [
        KanbanColumn(id: 'recieved', name: 'Recieved', color: '#FFF'),
        KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
        KanbanColumn(id: 'ready', name: 'Ready', color: '#DDD'),
        KanbanColumn(id: 'out_for_delivery', name: 'Out for Delivery', color: '#CCC'),
      ];
      expect(
        evaluate('ready', 'in_progress', withColumns: legacyColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
      expect(
        evaluate('Ready', 'In Progress', withColumns: legacyColumns),
        CardMoveBlockReason.cannotMoveBackward,
      );
      // The forward path through Ready still works on that board.
      expect(evaluate('in_progress', 'ready', withColumns: legacyColumns), isNull);
      expect(evaluate('ready', 'out_for_delivery', withColumns: legacyColumns), isNull);
    });

    test('should block a backward move to the legacy Processing label too', () {
      final legacyLabels = [
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'processing', name: 'Processing', color: '#EEE'),
        KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#DDD'),
      ];
      expect(
        evaluate('out_for_delivery', 'processing', withColumns: legacyLabels),
        CardMoveBlockReason.cannotMoveBackward,
      );
    });
  });

  group('evaluateCardMoveBlock — existing guards still hold', () {
    test('should block a multi-stage forward jump to a non-Cancelled column', () {
      expect(
        evaluate('in_progress', 'courier_settlement'),
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
      expect(evaluate('in_progress', 'in_progress'), CardMoveBlockReason.sameColumn);
    });

    test('should not block when a column cannot be resolved', () {
      expect(evaluate('received', 'who-knows'), isNull);
      expect(evaluate('who-knows', 'received'), isNull);
      expect(evaluate('received', 'cancelled', withColumns: const []), isNull);
    });

    test('should resolve columns by name as well as id', () {
      expect(evaluate('Received', 'In Progress'), isNull);
      expect(evaluate('In Progress', 'Out For Delivery'), isNull);
      expect(
        evaluate('Out For Delivery', 'In Progress'),
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

    test('should offer only the next stage from each active column', () {
      expect(targetsFor('received').map((c) => c.id), ['in_progress']);
      expect(targetsFor('in_progress').map((c) => c.id), ['out_for_delivery']);
      expect(
        targetsFor('out_for_delivery').map((c) => c.id),
        ['courier_settlement'],
      );
    });
  });

  group('tripStagingKanbanColumn', () {
    test('should pick In Progress when the board has no Ready column', () {
      expect(tripStagingKanbanColumn(columns)?.id, 'in_progress');
    });

    test('should accept the legacy Processing label', () {
      final legacyLabels = [
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'processing', name: 'Processing', color: '#EEE'),
        KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#DDD'),
      ];
      expect(tripStagingKanbanColumn(legacyLabels)?.id, 'processing');
    });

    test('should keep Ready as the trip column while an old server still sends it', () {
      final legacyColumns = [
        KanbanColumn(id: 'recieved', name: 'Recieved', color: '#FFF'),
        KanbanColumn(id: 'in_progress', name: 'In Progress', color: '#EEE'),
        KanbanColumn(id: 'ready', name: 'Ready', color: '#DDD'),
        KanbanColumn(id: 'out_for_delivery', name: 'Out for Delivery', color: '#CCC'),
      ];
      expect(tripStagingKanbanColumn(legacyColumns)?.id, 'ready');
    });

    test('should return null when neither column exists', () {
      expect(tripStagingKanbanColumn(const []), isNull);
      expect(
        tripStagingKanbanColumn([
          KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
          KanbanColumn(id: 'out_for_delivery', name: 'Out For Delivery', color: '#DDD'),
        ]),
        isNull,
      );
    });
  });
}
