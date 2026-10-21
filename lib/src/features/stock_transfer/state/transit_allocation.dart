import '../data/stock_handover_models.dart';
import 'handover_badge.dart';

// The manager's working copy of one receipt on the Transit board: for every
// line, how much actually arrived and which sends (or undeclared senders) it
// came from. Pure data and arithmetic, so the rules behind the Approve
// button are testable without a widget. Prefilled from the engine's
// suggestions; ReceiptAllocation builds exactly what `approve_receipt` takes.

/// One open send that holds this line's item.
class TransitSendOption {
  const TransitSendOption({
    required this.dispatch,
    required this.sourceWarehouse,
    required this.sourceLabel,
    this.declaredAt,
    this.declaredByName = '',
    required this.remaining,
    this.reservedElsewhere = 0,
    this.overdue = false,
  });

  final String dispatch;
  final String sourceWarehouse;
  final String sourceLabel;
  final DateTime? declaredAt;
  final String declaredByName;

  /// What is left of the item on this send, for every receipt together.
  final double remaining;

  /// How much of [remaining] the engine suggested for OTHER receipts: taking
  /// it here is allowed, but the other receipt will then come up short.
  final double reservedElsewhere;
  final bool overdue;
}

/// "The sender didn't declare it": stock taken straight from [sourceWarehouse].
class DirectAllocation {
  DirectAllocation({
    required this.sourceWarehouse,
    required this.sourceLabel,
    this.qty = 0,
  });

  final String sourceWarehouse;
  final String sourceLabel;
  double qty;
}

/// Key of one allocation, shared by suggestions and the manager's numbers:
/// the send name, or `direct:<warehouse>`.
String _keyOf(String? dispatch, String sourceWarehouse) =>
    dispatch ?? 'direct:$sourceWarehouse';

class LineAllocation {
  LineAllocation._({
    required this.line,
    required this.targetWarehouse,
    required this.options,
  }) : received = line.qty;

  final TransitReceiptLine line;
  final String targetWarehouse;

  /// Every open send holding the item: suggested ones first, then the oldest.
  final List<TransitSendOption> options;

  /// The manager's correction of what arrived; starts at the declared qty.
  double received;

  /// Send name → quantity taken from it.
  final Map<String, double> sendQty = {};

  /// Undeclared senders, at most one row per warehouse.
  final List<DirectAllocation> direct = [];

  String get itemCode => line.itemCode;

  List<TransitSuggestion> get suggestions => line.suggestions;

  bool get receivedChanged => !sameQty(received, line.qty);

  double get assigned {
    var sum = 0.0;
    for (final q in sendQty.values) {
      sum += q;
    }
    for (final d in direct) {
      sum += d.qty;
    }
    return round3(sum);
  }

  /// `received - assigned`: 0 = fully placed, negative = too much assigned.
  double get leftToAssign => round3(received - assigned);

  TransitSendOption? optionFor(String dispatch) {
    for (final o in options) {
      if (o.dispatch == dispatch) return o;
    }
    return null;
  }

  double qtyFor(String dispatch) => sendQty[dispatch] ?? 0;

  /// More is taken from [dispatch] than it has left.
  bool overRemaining(String dispatch) {
    final o = optionFor(dispatch);
    if (o == null) return false;
    return round3(qtyFor(dispatch)) > round3(o.remaining);
  }

  bool get anyOverRemaining => sendQty.keys.any(overRemaining);

  /// Every unit placed, nothing over a send's remaining, and every number
  /// sane. This is what the line needs for Approve.
  bool get fullyAssigned =>
      received >= 0 &&
      leftToAssign == 0 &&
      !anyOverRemaining &&
      sendQty.values.every((q) => q >= 0 && q.isFinite) &&
      direct.every((d) =>
          d.qty >= 0 &&
          d.qty.isFinite &&
          d.sourceWarehouse.isNotEmpty &&
          d.sourceWarehouse != targetWarehouse);

  /// The nonzero allocations right now, keyed like [_suggestedMap].
  Map<String, double> get _currentMap {
    final out = <String, double>{};
    for (final e in sendQty.entries) {
      if (round3(e.value) > 0) out[e.key] = round3(e.value);
    }
    for (final d in direct) {
      if (round3(d.qty) > 0) {
        final k = _keyOf(null, d.sourceWarehouse);
        out[k] = round3((out[k] ?? 0) + d.qty);
      }
    }
    return out;
  }

  Map<String, double> get _suggestedMap {
    final out = <String, double>{};
    for (final s in suggestions) {
      if (round3(s.qty) <= 0) continue;
      final k = _keyOf(s.dispatch, s.sourceWarehouse);
      out[k] = round3((out[k] ?? 0) + s.qty);
    }
    return out;
  }

  /// The manager left the engine's suggestion for this line as it was.
  bool get keptSuggestion {
    final a = _currentMap;
    final b = _suggestedMap;
    if (b.isEmpty || a.length != b.length) return false;
    for (final e in b.entries) {
      final v = a[e.key];
      if (v == null || !sameQty(v, e.value)) return false;
    }
    return true;
  }

  /// The engine's confidence for the allocation [key], or none.
  TransitConfidence _confidenceFor(String key) {
    for (final s in suggestions) {
      if (_keyOf(s.dispatch, s.sourceWarehouse) == key) return s.confidence;
    }
    return TransitConfidence.none;
  }

  /// Every suggestion is `high`, nothing is left unresolved, and the
  /// suggestions cover what arrived.
  bool get allHigh =>
      suggestions.isNotEmpty &&
      round3(line.unresolvedQty) <= 0 &&
      suggestions.every((s) => s.confidence == TransitConfidence.high);

  // ── Edits ────────────────────────────────────────────────────────────────

  void setSendQty(String dispatch, double qty) {
    if (!qty.isFinite || qty <= 0) {
      sendQty.remove(dispatch);
    } else {
      sendQty[dispatch] = qty;
    }
  }

  void setDirectQty(String sourceWarehouse, double qty) {
    for (final d in direct) {
      if (d.sourceWarehouse == sourceWarehouse) {
        d.qty = (!qty.isFinite || qty < 0) ? 0 : qty;
        return;
      }
    }
  }

  /// Adds an undeclared sender (no-op for the receiver itself, or one
  /// already listed). Prefills it with whatever is still unplaced.
  void addDirect(String sourceWarehouse, String sourceLabel) {
    if (sourceWarehouse.isEmpty || sourceWarehouse == targetWarehouse) return;
    if (direct.any((d) => d.sourceWarehouse == sourceWarehouse)) return;
    final left = leftToAssign;
    direct.add(DirectAllocation(
      sourceWarehouse: sourceWarehouse,
      sourceLabel: sourceLabel,
      qty: left > 0 ? left : 0,
    ));
  }

  void removeDirect(String sourceWarehouse) =>
      direct.removeWhere((d) => d.sourceWarehouse == sourceWarehouse);

  /// Puts everything still unplaced on [dispatch], up to its remaining.
  void fillRestFrom(String dispatch) {
    final o = optionFor(dispatch);
    if (o == null) return;
    final left = leftToAssign;
    if (left <= 0) return;
    final room = round3(o.remaining - qtyFor(dispatch));
    if (room <= 0) return;
    setSendQty(dispatch, round3(qtyFor(dispatch) + (left < room ? left : room)));
  }

  /// Back to the engine's suggestion and the declared quantity.
  void resetToSuggestion() {
    received = line.qty;
    sendQty.clear();
    direct.clear();
    for (final s in suggestions) {
      if (round3(s.qty) <= 0) continue;
      final d = s.dispatch;
      if (d != null) {
        sendQty[d] = round3((sendQty[d] ?? 0) + s.qty);
      } else if (s.sourceWarehouse.isNotEmpty &&
          s.sourceWarehouse != targetWarehouse) {
        final existing = direct
            .where((x) => x.sourceWarehouse == s.sourceWarehouse)
            .toList();
        if (existing.isEmpty) {
          direct.add(DirectAllocation(
            sourceWarehouse: s.sourceWarehouse,
            sourceLabel: s.sourceLabel,
            qty: round3(s.qty),
          ));
        } else {
          existing.first.qty = round3(existing.first.qty + s.qty);
        }
      }
    }
  }

  /// One row per nonzero allocation of this line, `approve_receipt` shape.
  List<Map<String, dynamic>> toAllocations() {
    final kept = keptSuggestion;
    final out = <Map<String, dynamic>>[];
    for (final o in options) {
      final q = round3(qtyFor(o.dispatch));
      if (q <= 0) continue;
      out.add({
        'item_code': itemCode,
        'dispatch': o.dispatch,
        'source_warehouse': o.sourceWarehouse,
        'qty': q,
        'was_recommended': kept ? 1 : 0,
        'confidence': _confidenceFor(o.dispatch).wire,
      });
    }
    for (final d in direct) {
      final q = round3(d.qty);
      if (q <= 0) continue;
      out.add({
        'item_code': itemCode,
        'dispatch': null,
        'source_warehouse': d.sourceWarehouse,
        'qty': q,
        'was_recommended': kept ? 1 : 0,
        'confidence': _confidenceFor(_keyOf(null, d.sourceWarehouse)).wire,
      });
    }
    return out;
  }
}

class ReceiptAllocation {
  ReceiptAllocation._(this.receipt, this.lines, this.version);

  /// Builds the editor for [receipt] from the whole [board]: the candidate
  /// sends for each line, what other receipts were suggested from them, and
  /// the prefill from the engine's suggestions.
  factory ReceiptAllocation.fromBoard(
    TransitBoard board,
    TransitReceipt receipt,
  ) {
    // What the engine suggested for every OTHER receipt, per (send, item).
    final reserved = <String, double>{};
    for (final r in board.receipts) {
      if (r.name == receipt.name) continue;
      for (final l in r.lines) {
        for (final s in l.suggestions) {
          final d = s.dispatch;
          if (d == null) continue;
          final k = '$d|${l.itemCode}';
          reserved[k] = (reserved[k] ?? 0) + s.qty;
        }
      }
    }

    final lines = <LineAllocation>[];
    for (final line in receipt.lines) {
      final suggestedOrder = <String>[
        for (final s in line.suggestions)
          if (s.dispatch != null) s.dispatch!,
      ];
      final options = <TransitSendOption>[];
      for (final send in board.sends) {
        if (send.sourceWarehouse == receipt.targetWarehouse) continue;
        final remaining = send.remainingFor(line.itemCode);
        final isSuggested = suggestedOrder.contains(send.name);
        if (remaining <= 0 && !isSuggested) continue;
        options.add(TransitSendOption(
          dispatch: send.name,
          sourceWarehouse: send.sourceWarehouse,
          sourceLabel: send.sourceLabel,
          declaredAt: send.declaredAt,
          declaredByName: send.declaredByName,
          remaining: round3(remaining),
          reservedElsewhere:
              round3(reserved['${send.name}|${line.itemCode}'] ?? 0),
          overdue: send.overdue,
        ));
      }
      // A suggested send the board did not list (should not happen): keep
      // it so the suggestion is not silently lost; its remaining is unknown,
      // so trust the suggested quantity.
      for (final s in line.suggestions) {
        final d = s.dispatch;
        if (d == null || options.any((o) => o.dispatch == d)) continue;
        options.add(TransitSendOption(
          dispatch: d,
          sourceWarehouse: s.sourceWarehouse,
          sourceLabel: s.sourceLabel,
          remaining: round3(s.qty),
        ));
      }
      int rank(TransitSendOption o) {
        final i = suggestedOrder.indexOf(o.dispatch);
        if (i >= 0) return i;
        if (receipt.namedSource != null &&
            o.sourceWarehouse == receipt.namedSource) {
          return 1000;
        }
        return 2000;
      }

      final indexed = options.asMap().entries.toList()
        ..sort((a, b) {
          final r = rank(a.value).compareTo(rank(b.value));
          // Board order is oldest first: keep it as the tiebreak.
          return r != 0 ? r : a.key.compareTo(b.key);
        });
      final la = LineAllocation._(
        line: line,
        targetWarehouse: receipt.targetWarehouse,
        options: [for (final e in indexed) e.value],
      )..resetToSuggestion();
      lines.add(la);
    }
    return ReceiptAllocation._(receipt, lines, board.version);
  }

  final TransitReceipt receipt;
  final List<LineAllocation> lines;

  /// The board's drift token, sent back with the approval.
  final String version;

  LineAllocation? lineFor(String itemCode) {
    for (final l in lines) {
      if (l.itemCode == itemCode) return l;
    }
    return null;
  }

  double get totalReceived => lines.fold(0.0, (s, l) => s + l.received);

  bool get fullyAssigned => lines.every((l) => l.fullyAssigned);

  /// Lines that still need the manager.
  int get openLines => lines.where((l) => !l.fullyAssigned).length;

  /// Approve is allowed: this manager may approve it, every line adds up,
  /// and something actually arrived (an all-zero receipt is rejected, not
  /// approved).
  bool get canApprove =>
      receipt.canApprove && fullyAssigned && round3(totalReceived) > 0;

  /// Safe for "Approve all confident": every suggestion `high`, nothing
  /// unresolved, untouched, and it adds up.
  bool get isConfident =>
      canApprove &&
      lines.every((l) => l.allHigh && l.keptSuggestion && !l.receivedChanged);

  bool get anyReceivedChanged => lines.any((l) => l.receivedChanged);

  /// `received` for `approve_receipt`: null when nothing was corrected, else
  /// every item's quantity (unchanged ones included), so the server never has
  /// to guess what a missing item means.
  Map<String, double>? receivedPayload() {
    if (!anyReceivedChanged) return null;
    return {for (final l in lines) l.itemCode: round3(l.received)};
  }

  List<Map<String, dynamic>> allocationsPayload() =>
      [for (final l in lines) ...l.toAllocations()];
}

/// The receipts "Approve all confident" would approve, in board order.
List<ReceiptAllocation> confidentReceipts(TransitBoard board) => [
      for (final r in board.receipts) ReceiptAllocation.fromBoard(board, r),
    ].where((a) => a.isConfident).toList();

/// The server's drift refusal (`_DRIFT_MESSAGE`, "Something changed in this
/// batch. Reload and check again."): what is on screen is stale.
bool isTransitDrift(String message) =>
    message.toLowerCase().contains('something changed');
