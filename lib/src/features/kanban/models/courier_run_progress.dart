/// How far along a courier's run is — "7/12 delivered" — derived entirely from
/// the Kanban board the dispatcher is already looking at.
///
/// **Why this is computed client-side rather than fetched.** Every stop on a run
/// is a Sales Invoice the board has already loaded, carrying its own courier
/// party and delivery outcome. Grouping them needs no round trip, works on the
/// existing `jarz_pos` Kanban endpoint, and cannot disagree with the cards
/// on screen. A dedicated endpoint would be a second source of truth that drifts
/// from the board, which is precisely the confusion this is meant to remove.
///
/// **What it deliberately does not do.** It never computes money and never
/// reconciles anything. It counts stops.
library;

import 'kanban_models.dart';

/// One courier's progress through their run.
class CourierRunProgress {
  const CourierRunProgress({
    required this.courierKey,
    required this.courierLabel,
    required this.total,
    required this.delivered,
    required this.failed,
  });

  /// `custom_courier_party` (or the display name, when no party is on the
  /// payload) that these stops are grouped by.
  final String courierKey;

  /// Human label for the courier, for tooltips.
  final String courierLabel;

  /// Stops on the run that are visible on the board.
  final int total;

  /// Stops that have been delivered.
  final int delivered;

  /// Stops attempted, missed, and still owed a delivery. Not a subset of
  /// [delivered] — the two are mutually exclusive by construction.
  final int failed;

  /// Stops neither delivered nor failed: still to be attempted.
  int get pending {
    final remaining = total - delivered - failed;
    return remaining < 0 ? 0 : remaining;
  }

  /// Every stop on the run is delivered.
  bool get isComplete => total > 0 && delivered == total;

  /// At least one stop was attempted and missed — the dispatcher's cue to act.
  bool get hasFailures => failed > 0;

  /// Progress as a 0..1 fraction. 0 for an empty run rather than NaN.
  double get fraction => total <= 0 ? 0 : delivered / total;

  @override
  String toString() =>
      'CourierRunProgress($courierKey, $delivered/$total, failed: $failed)';
}

/// Run progress for every courier on the board, keyed by [CourierRunProgress.courierKey].
///
/// Built once per board change and shared by every card, so a board of N cards
/// costs one O(N) pass rather than N passes.
class CourierRunProgressIndex {
  const CourierRunProgressIndex(this._byCourier);

  const CourierRunProgressIndex.empty() : _byCourier = const {};

  final Map<String, CourierRunProgress> _byCourier;

  /// Group every stop on the board by its courier.
  ///
  /// Invoices that are not run stops (pickups, unassigned, cancelled, still in
  /// preparation) are skipped, so the denominator only ever counts work that was
  /// actually handed to a courier.
  factory CourierRunProgressIndex.fromInvoices(
    Iterable<InvoiceCard> invoices,
  ) {
    final totals = <String, int>{};
    final delivered = <String, int>{};
    final failed = <String, int>{};
    final labels = <String, String>{};
    // One card can appear in more than one place if a caller passes overlapping
    // column lists; dedupe on invoice id so a stop is never counted twice.
    final seen = <String>{};

    for (final invoice in invoices) {
      if (!invoice.isCourierRunStop) continue;
      final key = invoice.courierRunKey;
      if (key == null) continue;
      if (!seen.add(invoice.id)) continue;

      totals[key] = (totals[key] ?? 0) + 1;
      labels[key] ??= invoice.courierRunLabel ?? key;
      if (invoice.isDeliveredStop) {
        delivered[key] = (delivered[key] ?? 0) + 1;
      } else if (invoice.hasOpenDeliveryFailure) {
        failed[key] = (failed[key] ?? 0) + 1;
      }
    }

    final result = <String, CourierRunProgress>{};
    for (final entry in totals.entries) {
      final key = entry.key;
      result[key] = CourierRunProgress(
        courierKey: key,
        courierLabel: labels[key] ?? key,
        total: entry.value,
        delivered: delivered[key] ?? 0,
        failed: failed[key] ?? 0,
      );
    }
    return CourierRunProgressIndex(result);
  }

  /// Progress for one courier, or null when they have no stops on the board.
  CourierRunProgress? forCourier(String? courierKey) {
    if (courierKey == null || courierKey.isEmpty) return null;
    return _byCourier[courierKey];
  }

  /// Progress for the run the given invoice belongs to, or null when the invoice
  /// is not a stop on anyone's run.
  CourierRunProgress? forInvoice(InvoiceCard invoice) =>
      forCourier(invoice.courierRunKey);

  /// Every run on the board, ordered by courier label for a stable UI.
  List<CourierRunProgress> get runs {
    final all = _byCourier.values.toList();
    all.sort((a, b) => a.courierLabel.compareTo(b.courierLabel));
    return all;
  }

  bool get isEmpty => _byCourier.isEmpty;
}
