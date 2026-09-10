import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/replenishment/data/models/branch_replenishment.dart';
import 'package:jarz_pos/src/features/replenishment/domain/replenishment_draft.dart';

ReplenishmentBranch _branch({
  required String warehouse,
  required String name,
  required int belowCover,
  double sendNow = 0,
  List<ReplenishmentItem> items = const [],
}) {
  return ReplenishmentBranch(
    warehouse: warehouse,
    branch: name,
    items: items,
    summary: ReplenishmentSummary(
      itemsBelowCover: belowCover,
      totalSendNow: sendNow,
    ),
  );
}

void main() {
  group('defaultBranchWarehouse', () {
    test('opens on the branch with the most items below cover', () {
      final plan = ReplenishmentPlan(
        branches: [
          _branch(warehouse: 'Dokki - J', name: 'Dokki', belowCover: 3),
          _branch(warehouse: 'Nasr - J', name: 'Nasr City', belowCover: 9),
          _branch(warehouse: 'Oct - J', name: '6th of October', belowCover: 5),
        ],
      );

      expect(defaultBranchWarehouse(plan), 'Nasr - J');
    });

    test('breaks a tie on the size of the load, then deterministically', () {
      final plan = ReplenishmentPlan(
        branches: [
          _branch(
            warehouse: 'Dokki - J',
            name: 'Dokki',
            belowCover: 4,
            sendNow: 12,
          ),
          _branch(
            warehouse: 'Nasr - J',
            name: 'Nasr City',
            belowCover: 4,
            sendNow: 80,
          ),
        ],
      );

      expect(defaultBranchWarehouse(plan), 'Nasr - J');
    });

    test('is null when the run produced no branches at all', () {
      expect(defaultBranchWarehouse(const ReplenishmentPlan()), isNull);
    });
  });

  group('sendLines', () {
    final branch = _branch(
      warehouse: 'Nasr - J',
      name: 'Nasr City',
      belowCover: 2,
      items: const [
        ReplenishmentItem(itemCode: 'JAR-A', sendNow: 10),
        ReplenishmentItem(itemCode: 'JAR-B', sendNow: 4),
        ReplenishmentItem(itemCode: 'JAR-C', sendNow: 0),
      ],
    );

    test('carries only the positive lines, in the branch row order', () {
      final lines = sendLines(branch, {'JAR-A': 7, 'JAR-B': 0, 'JAR-C': 3});

      expect(lines, [
        {'item_code': 'JAR-A', 'qty': 7.0},
        {'item_code': 'JAR-C', 'qty': 3.0},
      ]);
    });

    test('totals count lines, not rows', () {
      final totals = totalsFor(branch, {'JAR-A': 7, 'JAR-B': 0, 'JAR-C': 3});

      expect(totals.lineCount, 2);
      expect(totals.totalQty, 10);
      expect(totals.isEmpty, isFalse);
    });

    test('an all-zero draft is empty, so the Send button stays off', () {
      final totals = totalsFor(branch, {'JAR-A': 0, 'JAR-B': 0, 'JAR-C': 0});

      expect(totals.isEmpty, isTrue);
      expect(sendLines(branch, {'JAR-A': 0}), isEmpty);
    });
  });

  group('seedQuantities', () {
    test('pre-fills from the capped send_now, never from suggested_qty', () {
      final branch = _branch(
        warehouse: 'Nasr - J',
        name: 'Nasr City',
        belowCover: 1,
        items: const [
          ReplenishmentItem(
            itemCode: 'JAR-A',
            suggestedQty: 40,
            sendNow: 12,
            shortBy: 28,
          ),
        ],
      );

      expect(seedQuantities(branch), {'JAR-A': 12.0});
    });
  });

  group('failedItemFromError', () {
    final branch = _branch(
      warehouse: 'Nasr - J',
      name: 'Nasr City',
      belowCover: 2,
      items: const [
        ReplenishmentItem(itemCode: 'JAR-LOTUS', itemName: 'Lotus Jar'),
        ReplenishmentItem(itemCode: 'JAR-MANGO', itemName: 'Mango Jar'),
      ],
    );

    test('matches the item code the server named', () {
      final item = failedItemFromError(
        'Negative stock error for item JAR-MANGO in warehouse Finished Goods - J',
        branch,
      );

      expect(item?.itemCode, 'JAR-MANGO');
    });

    test('falls back to the item name when only the label is in the text', () {
      final item = failedItemFromError('Not enough Lotus Jar to move', branch);

      expect(item?.itemCode, 'JAR-LOTUS');
    });

    test('names nothing rather than guessing', () {
      expect(failedItemFromError('Insufficient permission', branch), isNull);
      expect(failedItemFromError(null, branch), isNull);
    });
  });
}
