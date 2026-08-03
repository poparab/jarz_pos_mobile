/// Models for team item requests, backed by ERPNext `Material Request`.
///
/// Status values come straight from ERPNext's own status map, so they are not
/// re-invented here — see `jarz_pos/api/purchase_request.py` for the mapping
/// between business state and ERPNext status.
library;

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

String _toStr(dynamic value) => value?.toString() ?? '';

String? _toNullableStr(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _toDate(dynamic value) {
  final text = _toNullableStr(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}

/// Where a request sits in its life. Mirrors ERPNext's Material Request status.
enum RequestStatus {
  pending,
  partiallyOrdered,
  ordered,
  partiallyReceived,
  received,
  stopped,
  cancelled,
  unknown;

  static RequestStatus parse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'partially ordered':
        return RequestStatus.partiallyOrdered;
      case 'ordered':
        return RequestStatus.ordered;
      case 'partially received':
        return RequestStatus.partiallyReceived;
      case 'received':
        return RequestStatus.received;
      case 'stopped':
        return RequestStatus.stopped;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.unknown;
    }
  }

  /// Whether the request still wants stock.
  bool get isOpen => switch (this) {
        RequestStatus.pending ||
        RequestStatus.partiallyOrdered ||
        RequestStatus.ordered ||
        RequestStatus.partiallyReceived =>
          true,
        _ => false,
      };

  bool get isClosed => this == RequestStatus.received;
  bool get isRejected =>
      this == RequestStatus.stopped || this == RequestStatus.cancelled;
}

/// One item line inside a request.
class RequestLine {
  final String name;
  final String itemCode;
  final String itemName;
  final double qty;
  final String uom;
  final String stockUom;
  final double conversionFactor;
  final double stockQty;
  final double receivedQty;
  final double outstandingQty;
  final String? warehouse;
  final DateTime? scheduleDate;

  const RequestLine({
    required this.name,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.uom,
    required this.stockUom,
    required this.conversionFactor,
    required this.stockQty,
    required this.receivedQty,
    required this.outstandingQty,
    this.warehouse,
    this.scheduleDate,
  });

  bool get isFulfilled => outstandingQty <= 0.0001;

  /// 0..1 — how much of this line has actually arrived.
  double get progress {
    if (stockQty <= 0) return 0;
    return (receivedQty / stockQty).clamp(0.0, 1.0);
  }

  factory RequestLine.fromJson(Map<String, dynamic> json) {
    final stockQty = _toDouble(json['stock_qty']);
    final received = _toDouble(json['received_qty']);
    return RequestLine(
      name: _toStr(json['name']),
      itemCode: _toStr(json['item_code']),
      itemName: _toStr(json['item_name']).isEmpty
          ? _toStr(json['item_code'])
          : _toStr(json['item_name']),
      qty: _toDouble(json['qty']),
      uom: _toStr(json['uom']),
      stockUom: _toStr(json['stock_uom']),
      conversionFactor: _toDouble(json['conversion_factor']) == 0
          ? 1
          : _toDouble(json['conversion_factor']),
      stockQty: stockQty,
      receivedQty: received,
      outstandingQty: _toDouble(json['outstanding_qty']),
      warehouse: _toNullableStr(json['warehouse']),
      scheduleDate: _toDate(json['schedule_date']),
    );
  }
}

/// A team request as a whole.
class ItemRequest {
  final String name;
  final DateTime? transactionDate;
  final DateTime? scheduleDate;
  final RequestStatus status;
  final String rawStatus;
  final double perReceived;
  final String? posProfile;
  final String requestedBy;
  final String? requestedByUser;
  final String? note;
  final bool isMine;
  final List<RequestLine> items;

  const ItemRequest({
    required this.name,
    required this.transactionDate,
    required this.scheduleDate,
    required this.status,
    required this.rawStatus,
    required this.perReceived,
    required this.posProfile,
    required this.requestedBy,
    required this.requestedByUser,
    required this.note,
    required this.isMine,
    required this.items,
  });

  int get itemCount => items.length;

  /// True once the "needed by" date has passed and stock is still outstanding.
  bool get isOverdue {
    final due = scheduleDate;
    if (due == null || !status.isOpen) return false;
    final today = DateTime.now();
    return due.isBefore(DateTime(today.year, today.month, today.day));
  }

  factory ItemRequest.fromJson(Map<String, dynamic> json) {
    final rawStatus = _toStr(json['status']);
    return ItemRequest(
      name: _toStr(json['name']),
      transactionDate: _toDate(json['transaction_date']),
      scheduleDate: _toDate(json['schedule_date']),
      status: RequestStatus.parse(rawStatus),
      rawStatus: rawStatus,
      perReceived: _toDouble(json['per_received']),
      posProfile: _toNullableStr(json['pos_profile']),
      requestedBy: _toStr(json['requested_by']),
      requestedByUser: _toNullableStr(json['requested_by_user']),
      note: _toNullableStr(json['note']),
      isMine: json['is_mine'] == true,
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => RequestLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Which branch/requester contributed to a rolled-up buying line, and how much.
class RequestDemandSource {
  final String materialRequest;
  final String materialRequestItem;
  final String? posProfile;
  final String requestedBy;
  final String? note;
  final double outstandingQty;
  final String uom;
  final double conversionFactor;
  final String? warehouse;
  final DateTime? neededBy;

  const RequestDemandSource({
    required this.materialRequest,
    required this.materialRequestItem,
    required this.posProfile,
    required this.requestedBy,
    required this.note,
    required this.outstandingQty,
    required this.uom,
    required this.conversionFactor,
    required this.warehouse,
    required this.neededBy,
  });

  factory RequestDemandSource.fromJson(Map<String, dynamic> json) {
    return RequestDemandSource(
      materialRequest: _toStr(json['material_request']),
      materialRequestItem: _toStr(json['material_request_item']),
      posProfile: _toNullableStr(json['pos_profile']),
      requestedBy: _toStr(json['requested_by']),
      note: _toNullableStr(json['note']),
      outstandingQty: _toDouble(json['outstanding_qty']),
      uom: _toStr(json['uom']),
      conversionFactor: _toDouble(json['conversion_factor']) == 0
          ? 1
          : _toDouble(json['conversion_factor']),
      warehouse: _toNullableStr(json['warehouse']),
      neededBy: _toDate(json['needed_by']),
    );
  }
}

/// One row of the consolidated buying list: total outstanding demand for an
/// item across every open request, with the context a buyer needs to decide.
///
/// The roll-up is the point — buying request-by-request means three separate
/// orders for the same item, which is the default behaviour without it.
class RequestDemandLine {
  final String itemCode;
  final String itemName;
  final String stockUom;
  final double outstandingQty;
  final double requestedQty;
  final double receivedQty;
  final double onHandQty;
  final double lastPurchaseRate;
  final DateTime? earliestNeededBy;
  final List<RequestDemandSource> sources;

  const RequestDemandLine({
    required this.itemCode,
    required this.itemName,
    required this.stockUom,
    required this.outstandingQty,
    required this.requestedQty,
    required this.receivedQty,
    required this.onHandQty,
    required this.lastPurchaseRate,
    required this.earliestNeededBy,
    required this.sources,
  });

  /// Distinct branches waiting on this item.
  List<String> get branches {
    final seen = <String>{};
    for (final source in sources) {
      final profile = source.posProfile;
      if (profile != null && profile.isNotEmpty) seen.add(profile);
    }
    return seen.toList()..sort();
  }

  bool get isUrgent {
    final due = earliestNeededBy;
    if (due == null) return false;
    final today = DateTime.now();
    return !due.isAfter(DateTime(today.year, today.month, today.day));
  }

  factory RequestDemandLine.fromJson(Map<String, dynamic> json) {
    return RequestDemandLine(
      itemCode: _toStr(json['item_code']),
      itemName: _toStr(json['item_name']).isEmpty
          ? _toStr(json['item_code'])
          : _toStr(json['item_name']),
      stockUom: _toStr(json['stock_uom']),
      outstandingQty: _toDouble(json['outstanding_qty']),
      requestedQty: _toDouble(json['requested_qty']),
      receivedQty: _toDouble(json['received_qty']),
      onHandQty: _toDouble(json['on_hand_qty']),
      lastPurchaseRate: _toDouble(json['last_purchase_rate']),
      earliestNeededBy: _toDate(json['earliest_needed_by']),
      sources: ((json['sources'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => RequestDemandSource.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Paginated result of a request list query.
class ItemRequestPage {
  final List<ItemRequest> requests;
  final int total;
  final bool canReview;

  const ItemRequestPage({
    required this.requests,
    required this.total,
    required this.canReview,
  });

  factory ItemRequestPage.fromJson(Map<String, dynamic> json) {
    return ItemRequestPage(
      requests: ((json['requests'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ItemRequest.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (json['total'] is num) ? (json['total'] as num).toInt() : 0,
      canReview: json['can_review'] == true,
    );
  }
}

/// A line the user is about to request (pre-submit, client-side only).
class DraftRequestLine {
  final String itemCode;
  final String itemName;
  final String uom;
  final double qty;

  const DraftRequestLine({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.qty,
  });

  DraftRequestLine copyWith({double? qty, String? uom}) => DraftRequestLine(
        itemCode: itemCode,
        itemName: itemName,
        uom: uom ?? this.uom,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'item_code': itemCode,
        'qty': qty,
        'uom': uom,
      };
}
