/// Plain models for the Stock Handover API (`jarz_pos.api.stock_handover`).
///
/// A handover is one side saying "this stock moved" and the OTHER side
/// confirming it; only the confirmation posts a Stock Entry. Every parser here
/// is lenient on purpose: a missing field reads as empty rather than throwing,
/// so one odd row can never blank the whole screen.
library;

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

String _toStr(Object? value) => value == null ? '' : value.toString();

String? _toOptStr(Object? value) {
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

bool _toBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// Unwraps Frappe's `{"message": ...}` envelope when present.
Object? unwrapFrappeMessage(Object? payload) {
  if (payload is Map && payload.containsKey('message')) {
    return payload['message'];
  }
  return payload;
}

Map<String, dynamic> unwrapFrappeMap(Object? payload) {
  final inner = unwrapFrappeMessage(payload);
  if (inner is Map) return Map<String, dynamic>.from(inner);
  return <String, dynamic>{};
}

/// A warehouse the user can act for, or a warehouse they hand stock to/from.
class HandoverSide {
  const HandoverSide({
    required this.warehouse,
    required this.label,
    required this.kind,
    this.posProfile,
  });

  final String warehouse;
  final String label;

  /// `branch` or `factory`.
  final String kind;

  /// Set for a branch side the user acts for through an open shift.
  final String? posProfile;

  bool get isFactory => kind == 'factory';
  bool get isBranch => kind == 'branch';

  factory HandoverSide.fromJson(Map<String, dynamic> json) {
    final warehouse = _toStr(json['warehouse']);
    final label = _toStr(json['label']);
    return HandoverSide(
      warehouse: warehouse,
      label: label.isEmpty ? warehouse : label,
      kind: _toStr(json['kind']),
      posProfile: _toOptStr(json['pos_profile']),
    );
  }
}

/// Who the user is for handovers (`get_context`).
class HandoverContext {
  const HandoverContext({
    this.mySides = const [],
    this.counterparts = const [],
    this.canManage = false,
  });

  final List<HandoverSide> mySides;
  final List<HandoverSide> counterparts;

  /// `ROLES.STOCK_TRANSFER`: the full manager transfer screen applies too.
  final bool canManage;

  bool get canDeclare => mySides.isNotEmpty;

  /// Everyone this [side] can hand stock to/from: never itself, factory first,
  /// then the branches in the server's order.
  List<HandoverSide> counterpartsFor(HandoverSide side) {
    final others = counterparts
        .where((c) => c.warehouse != side.warehouse)
        .toList();
    final factory = others.where((c) => c.isFactory);
    final rest = others.where((c) => !c.isFactory);
    return [...factory, ...rest];
  }

  factory HandoverContext.fromJson(Map<String, dynamic> json) {
    return HandoverContext(
      mySides: _maps(json['my_sides']).map(HandoverSide.fromJson).toList(),
      counterparts:
          _maps(json['counterparts']).map(HandoverSide.fromJson).toList(),
      canManage: _toBool(json['can_manage']),
    );
  }
}

/// One item that may be declared (`list_items`). Deliberately no stock
/// figures: the declaration is blind.
class HandoverItemOption {
  const HandoverItemOption({
    required this.itemCode,
    required this.itemName,
    this.itemGroup = '',
    this.stockUom = '',
  });

  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;

  factory HandoverItemOption.fromJson(Map<String, dynamic> json) {
    final code = _toStr(json['item_code']);
    final name = _toStr(json['item_name']);
    return HandoverItemOption(
      itemCode: code,
      itemName: name.isEmpty ? code : name,
      itemGroup: _toStr(json['item_group']),
      stockUom: _toStr(json['stock_uom']),
    );
  }
}

class StockHandoverLine {
  const StockHandoverLine({
    required this.itemCode,
    required this.itemName,
    this.stockUom = '',
    this.qty = 0,
    this.declaredQty = 0,
  });

  final String itemCode;
  final String itemName;
  final String stockUom;

  /// The quantity currently proposed.
  final double qty;

  /// What the first declaration said; differs from [qty] after a change.
  final double declaredQty;

  bool get isChanged => (qty - declaredQty).abs() > 1e-9;

  factory StockHandoverLine.fromJson(Map<String, dynamic> json) {
    final code = _toStr(json['item_code']);
    final name = _toStr(json['item_name']);
    final qty = _toDouble(json['qty']);
    return StockHandoverLine(
      itemCode: code,
      itemName: name.isEmpty ? code : name,
      stockUom: _toStr(json['stock_uom']),
      qty: qty,
      declaredQty:
          json.containsKey('declared_qty') ? _toDouble(json['declared_qty']) : qty,
    );
  }
}

class StockHandover {
  const StockHandover({
    required this.name,
    required this.status,
    required this.fromWarehouse,
    required this.fromLabel,
    required this.toWarehouse,
    required this.toLabel,
    this.awaitingSide = '',
    this.awaitingLabel = '',
    this.declaredByName = '',
    this.declaredAt,
    this.lastProposedByName = '',
    this.lastProposedAt,
    this.changed = false,
    this.canRespond = false,
    this.canCancel = false,
    this.stockEntry,
    this.rejectReason,
    this.items = const [],
  });

  final String name;

  /// Pending | Confirmed | Rejected | Cancelled
  final String status;
  final String fromWarehouse;
  final String fromLabel;
  final String toWarehouse;
  final String toLabel;

  /// `From` or `To`.
  final String awaitingSide;
  final String awaitingLabel;
  final String declaredByName;
  final DateTime? declaredAt;
  final String lastProposedByName;
  final DateTime? lastProposedAt;
  final bool changed;
  final bool canRespond;
  final bool canCancel;
  final String? stockEntry;
  final String? rejectReason;
  final List<StockHandoverLine> items;

  bool get isPending => status == 'Pending';
  bool get isConfirmed => status == 'Confirmed';
  bool get isRejected => status == 'Rejected';
  bool get isCancelled => status == 'Cancelled';

  /// The warehouse whose turn it is (the one that would confirm / change).
  String get awaitingWarehouse =>
      awaitingSide == 'From' ? fromWarehouse : toWarehouse;

  /// The other side of [awaitingWarehouse].
  String get proposingWarehouse =>
      awaitingSide == 'From' ? toWarehouse : fromWarehouse;

  double get totalQty => items.fold(0, (sum, l) => sum + l.qty);

  factory StockHandover.fromJson(Map<String, dynamic> json) {
    final fromWh = _toStr(json['from_warehouse']);
    final toWh = _toStr(json['to_warehouse']);
    final fromLabel = _toStr(json['from_label']);
    final toLabel = _toStr(json['to_label']);
    return StockHandover(
      name: _toStr(json['name']),
      status: _toStr(json['status']),
      fromWarehouse: fromWh,
      fromLabel: fromLabel.isEmpty ? fromWh : fromLabel,
      toWarehouse: toWh,
      toLabel: toLabel.isEmpty ? toWh : toLabel,
      awaitingSide: _toStr(json['awaiting_side']),
      awaitingLabel: _toStr(json['awaiting_label']),
      declaredByName: _toStr(json['declared_by_name']),
      declaredAt: DateTime.tryParse(_toStr(json['declared_at'])),
      lastProposedByName: _toStr(json['last_proposed_by_name']),
      lastProposedAt: DateTime.tryParse(_toStr(json['last_proposed_at'])),
      changed: _toBool(json['changed']),
      canRespond: _toBool(json['can_respond']),
      canCancel: _toBool(json['can_cancel']),
      stockEntry: _toOptStr(json['stock_entry']),
      rejectReason: _toOptStr(json['reject_reason']),
      items: _maps(json['items']).map(StockHandoverLine.fromJson).toList(),
    );
  }
}

class StockHandoverLists {
  const StockHandoverLists({
    this.waitingForMe = const [],
    this.waitingForThem = const [],
    this.recent = const [],
  });

  final List<StockHandover> waitingForMe;
  final List<StockHandover> waitingForThem;
  final List<StockHandover> recent;

  bool get isEmpty =>
      waitingForMe.isEmpty && waitingForThem.isEmpty && recent.isEmpty;

  factory StockHandoverLists.fromJson(Map<String, dynamic> json) {
    List<StockHandover> parse(Object? v) =>
        _maps(v).map(StockHandover.fromJson).toList();
    return StockHandoverLists(
      waitingForMe: parse(json['waiting_for_me']),
      waitingForThem: parse(json['waiting_for_them']),
      recent: parse(json['recent']),
    );
  }
}

/// What `transfer.submit_transfer` answered.
///
/// Two shapes are valid: the old `{"ok": true, "stock_entry": "MAT-STE-…"}`
/// (posted now), and, for a transfer touching a branch,
/// `{"ok": true, "stock_entry": null, "handover": "HND-…", "pending": true}`
/// — nothing has moved yet; the other side must confirm.
class TransferSubmitOutcome {
  const TransferSubmitOutcome({
    this.stockEntry,
    this.handover,
    this.pending = false,
  });

  final String? stockEntry;
  final String? handover;
  final bool pending;

  factory TransferSubmitOutcome.fromJson(Map<String, dynamic> json) {
    final handover = _toOptStr(json['handover']);
    return TransferSubmitOutcome(
      stockEntry: _toOptStr(json['stock_entry']),
      handover: handover,
      // A handover name alone also means "not posted yet", whatever the flag.
      pending: _toBool(json['pending']) || handover != null,
    );
  }
}
