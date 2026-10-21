import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_handover_models.dart';
import 'package:jarz_pos/src/features/stock_transfer/state/handover_badge.dart';

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
  group('handoverBadgeCount', () {
    test('counts rows awaiting one of my sides plus transit receipts', () {
      final lists = StockHandoverLists(
        waitingForMe: [
          _row(), // awaits B, which is mine
          _row(canRespond: false),
          _row(side: 'Manager'),
          _row(from: 'X', to: 'Y'), // another branch's own row
          _row(side: 'From', from: 'A', to: 'Z'), // awaits A, mine
        ],
        transitToMatch: 3,
      );

      expect(handoverBadgeCount(lists, myWarehouses: ['A', 'B']), 5);
      expect(handoverBadgeCount(lists), 3,
          reason: 'with no sides of my own only the transit receipts count');
    });

    test('no lists means no badge', () {
      expect(handoverBadgeCount(null), 0);
    });
  });

  group('qty helpers', () {
    test('round3 and sameQty compare at 3 decimals', () {
      expect(round3(1.23456), 1.235);
      expect(sameQty(1.0001, 1.0), isTrue);
      expect(sameQty(1.002, 1.0), isFalse);
    });
  });
}
