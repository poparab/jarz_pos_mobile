import '../data/stock_handover_models.dart';

/// Rounds to the 3 decimals the server compares at.
double round3(double v) => (v * 1000).round() / 1000;

/// Whether two quantities are equal at the server's 3-decimal precision.
bool sameQty(double a, double b) => round3(a) == round3(b);

/// How many things are waiting on this user, for the Handovers tab badge:
/// the 1:1 rows awaiting one of the user's OWN sides ([myWarehouses], from
/// `get_context.my_sides`), plus, for a manager, the receipts waiting on the
/// Transit board (`transit_to_match`). `can_respond` alone is not enough: it
/// is true on every side for a manager, so it would count every branch's own
/// row.
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
  return rows + lists.transitToMatch;
}
