import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_handover_models.dart';
import 'package:jarz_pos/src/features/stock_transfer/state/match_plan.dart';

MatchItem _item(String code, double sent, Map<String, double> claims) =>
    MatchItem(
      itemCode: code,
      itemName: code,
      sent: sent,
      claims: [
        for (final e in claims.entries)
          MatchClaim(warehouse: e.key, qty: e.value),
      ],
    );

MatchGroup _group({
  List<MatchItem>? items,
  bool canConfirm = true,
  bool balanced = false,
}) =>
    MatchGroup(
      sourceWarehouse: 'Dokki - J',
      sourceLabel: 'Dokki',
      dispatches: const ['HND-1'],
      receipts: const ['HND-2'],
      destinations: const [
        MatchDestination(warehouse: 'Nasr - J', label: 'Nasr'),
        MatchDestination(warehouse: 'Maadi - J', label: 'Maadi'),
      ],
      items: items ??
          [
            _item('A', 20, {'Nasr - J': 12, 'Maadi - J': 8}),
          ],
      canConfirm: canConfirm,
      balanced: balanced,
    );

StockHandover _row({
  bool canRespond = true,
  String side = 'To',
  String from = 'A',
  String to = 'B',
}) =>
    StockHandover(
      name: 'H',
      status: 'Pending',
      fromWarehouse: from,
      fromLabel: from,
      toWarehouse: to,
      toLabel: to,
      canRespond: canRespond,
      awaitingSide: side,
    );

void main() {
  group('MatchPlan balance', () {
    test('starts from the claims, so a matching group is balanced', () {
      final plan = MatchPlan.fromGroup(_group());

      expect(plan.items.single.remaining, 0);
      expect(plan.balanced, isTrue);
      expect(plan.canConfirm, isTrue);
    });

    test('an unclaimed remainder blocks confirm', () {
      final plan = MatchPlan.fromGroup(_group(items: [
        _item('A', 20, {'Nasr - J': 12}),
      ]));

      expect(plan.items.single.remaining, 8);
      expect(plan.balanced, isFalse);
      expect(plan.canConfirm, isFalse);
      expect(plan.unmatchedUnits, 8);
    });

    test('adding a branch and filling the gap balances it', () {
      final plan = MatchPlan.fromGroup(_group(items: [
        _item('A', 20, {'Nasr - J': 12}),
      ]));

      plan.addDestination(0, 'Giza - J', 'Giza');
      plan.addDestination(0, 'Giza - J', 'Giza');
      expect(plan.items.single.splits, hasLength(3),
          reason: 'adding the same branch twice is a no-op');
      plan.items.single.splits.last.qty = 8;

      expect(plan.items.single.remaining, 0);
      expect(plan.canConfirm, isTrue);
    });

    test('over-claiming gives a negative remaining and blocks confirm', () {
      final plan = MatchPlan.fromGroup(_group());
      plan.items.single.splits.first.qty = 13;

      expect(plan.items.single.remaining, -1);
      expect(plan.canConfirm, isFalse);
    });

    test('changing sent re-balances against the splits', () {
      final plan = MatchPlan.fromGroup(_group());
      plan.items.single.sent = 18;

      expect(plan.items.single.remaining, -2);
      expect(plan.items.single.sentChanged, isTrue);
      expect(plan.sentChanges, hasLength(1));
      plan.items.single.splits.first.qty = 10;
      expect(plan.items.single.remaining, 0);
    });

    test('3 dp rounding absorbs floating point noise', () {
      final plan = MatchPlan.fromGroup(_group(items: [
        _item('A', 0.3, {'Nasr - J': 0.1, 'Maadi - J': 0.2}),
      ]));

      expect(plan.items.single.remaining, 0);
      expect(plan.balanced, isTrue);
    });

    test('the server forbidding confirm wins over a balanced plan', () {
      final plan = MatchPlan.fromGroup(_group(canConfirm: false));

      expect(plan.balanced, isTrue);
      expect(plan.canConfirm, isFalse);
    });

    test('nothing moving is not a balanced plan', () {
      final plan = MatchPlan.fromGroup(_group(items: [
        _item('A', 0, {}),
      ]));

      expect(plan.items.single.remaining, 0);
      expect(plan.balanced, isFalse);
    });
  });

  group('MatchPlan output', () {
    test('review lists only nonzero splits and flags manager changes', () {
      final plan = MatchPlan.fromGroup(_group());
      plan.items.single.splits.first.qty = 10;
      plan.items.single.splits.last.qty = 0;
      plan.addDestination(0, 'Giza - J', 'Giza');
      plan.items.single.splits.last.qty = 10;

      final lines = plan.reviewLines();

      expect(lines.map((l) => l.toLabel), ['Nasr', 'Giza']);
      expect(lines.first.changed, isTrue);
      expect(lines.last.claimed, 0);
      expect(plan.droppedClaims().single.toLabel, 'Maadi');
    });

    test('an untouched plan reviews as unchanged', () {
      final lines = MatchPlan.fromGroup(_group()).reviewLines();

      expect(lines, hasLength(2));
      expect(lines.every((l) => !l.changed), isTrue);
    });

    test('toLines rounds and keeps zero splits for the service to drop', () {
      final plan = MatchPlan.fromGroup(_group());
      plan.items.single.splits.last.qty = 0;

      final lines = plan.toLines();

      expect(lines.single['item_code'], 'A');
      expect(lines.single['sent'], 20.0);
      expect(lines.single['splits'] as List, hasLength(2));
    });
  });

  group('handoverBadgeCount', () {
    test('counts only rows awaiting one of my sides plus balanced groups', () {
      final lists = StockHandoverLists(
        waitingForMe: [
          _row(), // awaits B, which is mine
          _row(canRespond: false),
          _row(side: 'Manager'),
          _row(from: 'X', to: 'Y'), // another branch's own row
          _row(side: 'From', from: 'A', to: 'Z'), // awaits A, mine
        ],
        toMatch: [
          _group(balanced: true),
          _group(balanced: false),
          _group(balanced: true, canConfirm: false),
        ],
      );

      expect(handoverBadgeCount(lists, myWarehouses: ['A', 'B']), 3);
      expect(handoverBadgeCount(lists), 1,
          reason: 'with no sides of my own only the groups count');
    });

    test('no lists means no badge', () {
      expect(handoverBadgeCount(null), 0);
    });
  });
}
