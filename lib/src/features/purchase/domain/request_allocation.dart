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
