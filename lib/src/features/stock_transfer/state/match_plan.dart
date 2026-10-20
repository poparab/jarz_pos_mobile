import '../data/stock_handover_models.dart';

/// Rounds to the 3 decimals the server compares at.
double round3(double v) => (v * 1000).round() / 1000;

/// Whether two quantities are equal at the server's 3-decimal precision.
bool sameQty(double a, double b) => round3(a) == round3(b);

/// How many things are waiting on this manager, for the Handovers tab badge:
/// the 1:1 rows awaiting one of the manager's OWN sides ([myWarehouses], from
/// `get_context.my_sides`), plus the match groups that already add up and that
/// this user may confirm (a group still short of its claims is not actionable
/// yet, so it does not count). `can_respond` alone is not enough: it is true
/// on every side for a manager, so it would count every branch's own row.
int handoverBadgeCount(
  StockHandoverLists? lists, {
  Iterable<String> myWarehouses = const [],
}) {
  if (lists == null) return 0;
  final mine = myWarehouses.toSet();
  final rows = lists.waitingForMe
      .where((h) =>
          h.canRespond &&
          !h.awaitsManager &&
          mine.contains(h.awaitingWarehouse))
      .length;
  final groups =
      lists.toMatch.where((g) => g.balanced && g.canConfirm).length;
  return rows + groups;
}

/// One destination row of one item in the Match screen.
class MatchSplit {
  MatchSplit({
    required this.warehouse,
    required this.label,
    required this.qty,
    required this.claimed,
  });

  final String warehouse;
  final String label;

  /// The manager's current number.
  double qty;

  /// What the receiver claimed (0 for a destination the manager added).
  final double claimed;

  bool get changed => !sameQty(qty, claimed);
}

/// One item of the Match screen: what was sent and where it goes.
class MatchItemPlan {
  MatchItemPlan({
    required this.item,
    required this.sent,
    required this.splits,
  }) : originalSent = item.sent;

  final MatchItem item;
  final double originalSent;
  double sent;
  final List<MatchSplit> splits;

  double get placed => splits.fold(0.0, (sum, s) => sum + s.qty);

  /// `sent - placed`, rounded: 0 means the item is fully matched. Negative
  /// means more is claimed than left.
  double get remaining => round3(sent - placed);

  bool get balanced => remaining == 0;

  bool get sentChanged => !sameQty(sent, originalSent);

  bool hasSplitFor(String warehouse) =>
      splits.any((s) => s.warehouse == warehouse);
}

/// One line of the review sheet: a nonzero split.
class MatchReviewLine {
  const MatchReviewLine({
    required this.itemName,
    required this.fromLabel,
    required this.toLabel,
    required this.qty,
    required this.claimed,
    required this.changed,
  });

  final String itemName;
  final String fromLabel;
  final String toLabel;
  final double qty;
  final double claimed;

  /// Differs from what the receiver claimed.
  final bool changed;
}

/// The manager's working copy of one [MatchGroup]. Pure data and arithmetic,
/// so the balance rules can be tested without a widget.
class MatchPlan {
  MatchPlan.fromGroup(this.group)
      : items = [
          for (final item in group.items)
            MatchItemPlan(
              item: item,
              sent: item.sent,
              splits: [
                for (final d in group.destinations)
                  MatchSplit(
                    warehouse: d.warehouse,
                    label: d.label,
                    qty: item.claimFor(d.warehouse),
                    claimed: item.claimFor(d.warehouse),
                  ),
              ],
            ),
        ];

  final MatchGroup group;
  final List<MatchItemPlan> items;

  /// Every item adds up, and something actually moves.
  bool get balanced =>
      items.every((i) => i.balanced) &&
      items.any((i) => i.sent > 0 && i.placed > 0);

  /// Confirm is allowed: balanced and the server says this user may confirm.
  bool get canConfirm => group.canConfirm && balanced;

  /// Units still unplaced across the items (absolute), for a summary chip.
  double get unmatchedUnits =>
      items.fold(0.0, (sum, i) => sum + i.remaining.abs());

  /// Adds a destination row to item [index] (no-op when it already has one).
  void addDestination(int index, String warehouse, String label) {
    final plan = items[index];
    if (plan.hasSplitFor(warehouse)) return;
    plan.splits.add(
      MatchSplit(warehouse: warehouse, label: label, qty: 0, claimed: 0),
    );
  }

  /// The `lines` payload for `confirm_match`.
  List<Map<String, dynamic>> toLines() => [
        for (final i in items)
          {
            'item_code': i.item.itemCode,
            'sent': round3(i.sent),
            'splits': [
              for (final s in i.splits)
                {'warehouse': s.warehouse, 'qty': round3(s.qty)},
            ],
          },
      ];

  /// Only the nonzero splits, flagged when they differ from the claim.
  List<MatchReviewLine> reviewLines() => [
        for (final i in items)
          for (final s in i.splits)
            if (round3(s.qty) > 0)
              MatchReviewLine(
                itemName: i.item.itemName,
                fromLabel: group.sourceLabel,
                toLabel: s.label,
                qty: round3(s.qty),
                claimed: s.claimed,
                changed: s.changed,
              ),
      ];

  /// Items whose "sent" the manager changed (X miscounted).
  List<MatchItemPlan> get sentChanges =>
      items.where((i) => i.sentChanged).toList();

  /// Receivers whose claim the manager set to zero: they get nothing, and the
  /// review should say so rather than let it disappear.
  List<MatchReviewLine> droppedClaims() => [
        for (final i in items)
          for (final s in i.splits)
            if (round3(s.qty) <= 0 && round3(s.claimed) > 0)
              MatchReviewLine(
                itemName: i.item.itemName,
                fromLabel: group.sourceLabel,
                toLabel: s.label,
                qty: 0,
                claimed: s.claimed,
                changed: true,
              ),
      ];
}
