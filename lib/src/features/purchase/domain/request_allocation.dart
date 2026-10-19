/// Splitting a purchased quantity back across the requests that asked for it.
///
/// ERPNext credits `received_qty` per `material_request_item`, so a cart line
/// bought against several requests has to become several invoice rows — one per
/// request line. Getting this wrong means the wrong request closes, so it lives
/// here as a pure function rather than inline in the widget.
library;

/// One request line a purchase can be credited against, and how much of it is
/// still outstanding.
class RequestAllocationTarget {
  final String materialRequest;
  final String materialRequestItem;
  final double outstandingQty;

  const RequestAllocationTarget({
    required this.materialRequest,
    required this.materialRequestItem,
    required this.outstandingQty,
  });
}

/// One resulting invoice row: a quantity, optionally linked to a request line.
class AllocatedRow {
  final double qty;
  final String? materialRequest;
  final String? materialRequestItem;

  const AllocatedRow({
    required this.qty,
    this.materialRequest,
    this.materialRequestItem,
  });

  bool get isLinked => materialRequestItem != null;
}

/// Tolerance for floating-point quantity comparisons. Quantities here come from
/// text fields and conversion factors, so exact equality is never safe.
const double _epsilon = 0.0001;

/// Distribute [purchasedQty] across [targets] in order, oldest-need first.
///
/// * Buying **less** than requested fills targets in order and simply leaves
///   later ones outstanding — they stay on the buying list.
/// * Buying **more** than requested fills every target, and the surplus becomes
///   a final unlinked row. Surplus must not be credited to any request, or a
///   request would close having received more than it asked for.
/// * With no targets the whole quantity is one unlinked row.
List<AllocatedRow> allocateAcrossRequests(
  double purchasedQty,
  List<RequestAllocationTarget> targets,
) {
  if (purchasedQty <= 0) return const [];
  if (targets.isEmpty) {
    return [AllocatedRow(qty: purchasedQty)];
  }

  final rows = <AllocatedRow>[];
  var remaining = purchasedQty;

  for (final target in targets) {
    if (remaining <= _epsilon) break;
    if (target.outstandingQty <= 0) continue;
    final take =
        remaining < target.outstandingQty ? remaining : target.outstandingQty;
    rows.add(AllocatedRow(
      qty: take,
      materialRequest: target.materialRequest,
      materialRequestItem: target.materialRequestItem,
    ));
    remaining -= take;
  }

  if (remaining > _epsilon) {
    rows.add(AllocatedRow(qty: remaining));
  }
  return rows;
}

/// [stockQty] expressed as a WHOLE number of units of [conversionFactor] stock
/// units, or null when it is not one.
///
/// Requests and their allocation are counted in stock units, while the buyer
/// may buy in boxes or cartons. A row goes out in the buyer's unit only when it
/// is a whole count of them — 9.6 Kg is 2 boxes of 4.8 — and otherwise in the
/// stock unit. Never 0.7 of a carton: ERPNext refuses a fraction of a unit
/// flagged "must be whole number", which would block the submit all over again.
double? qtyInUnit(double stockQty, double conversionFactor) {
  if (conversionFactor <= 0) return null;
  if ((conversionFactor - 1).abs() < _epsilon) return stockQty;
  final inUnit = stockQty / conversionFactor;
  final whole = inUnit.roundToDouble();
  if (whole <= 0) return null;
  if ((whole * conversionFactor - stockQty).abs() > _epsilon) return null;
  return whole;
}
