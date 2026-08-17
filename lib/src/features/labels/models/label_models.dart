/// Models for B2B customer label stock, backed by `jarz_pos.api.labels.*`.
///
/// Every quantity here is computed server-side from the `Jarz Label Movement`
/// ledger — the app never adds up a balance itself, so the number on the phone
/// and the number in the daily alert cannot drift apart.
library;

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _toStr(dynamic value) => value?.toString() ?? '';

String? _toNullableStr(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

bool _toBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

DateTime? _toDate(dynamic value) {
  final text = _toNullableStr(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}

/// Where a label sits against its reorder point.
///
/// Mirrors `services/label_stock.py` exactly — the server decides, the app only
/// renders. Ordered most urgent first so `index` doubles as the sort key.
enum LabelStatus {
  outOfStock,
  reorderNow,
  reorderSoon,
  onOrder,
  ok,
  notTracked,
  unknown;

  static LabelStatus parse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'out of stock':
        return LabelStatus.outOfStock;
      case 'reorder now':
        return LabelStatus.reorderNow;
      case 'reorder soon':
        return LabelStatus.reorderSoon;
      case 'on order':
        return LabelStatus.onOrder;
      case 'ok':
        return LabelStatus.ok;
      case 'not tracked':
        return LabelStatus.notTracked;
      default:
        return LabelStatus.unknown;
    }
  }

  /// Whether this status belongs on the alert list / badge count.
  bool get needsAttention =>
      this == LabelStatus.outOfStock ||
      this == LabelStatus.reorderNow ||
      this == LabelStatus.reorderSoon;

  /// Whether a print batch is already on its way.
  bool get isOnOrder => this == LabelStatus.onOrder;

  bool get isTracked => this != LabelStatus.notTracked;
}

/// A print batch sent to the print house.
class LabelPrintOrder {
  final String name;
  final int qty;
  final String status;
  final DateTime? requestedOn;
  final DateTime? expectedReadyDate;
  final DateTime? receivedOn;
  final int receivedQty;
  final String? printerName;
  final String? notes;
  final String? requestedBy;

  const LabelPrintOrder({
    required this.name,
    required this.qty,
    required this.status,
    required this.requestedOn,
    required this.expectedReadyDate,
    required this.receivedOn,
    required this.receivedQty,
    required this.printerName,
    required this.notes,
    required this.requestedBy,
  });

  factory LabelPrintOrder.fromJson(Map<String, dynamic> json) => LabelPrintOrder(
        name: _toStr(json['name']),
        qty: _toInt(json['qty']),
        status: _toStr(json['status']),
        requestedOn: _toDate(json['requested_on']),
        expectedReadyDate: _toDate(json['expected_ready_date']),
        receivedOn: _toDate(json['received_on']),
        receivedQty: _toInt(json['received_qty']),
        printerName: _toNullableStr(json['printer_name']),
        notes: _toNullableStr(json['notes']),
        requestedBy: _toNullableStr(json['requested_by']),
      );

  bool get isOpen =>
      status == 'Requested' || status == 'Printing' || status == 'Ready';

  bool get isReceived => status == 'Received';

  /// Days until the batch is expected, negative once it is overdue.
  int? get daysUntilReady {
    final due = expectedReadyDate;
    if (due == null) return null;
    final now = DateTime.now();
    return DateTime(due.year, due.month, due.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  bool get isOverdue => isOpen && (daysUntilReady ?? 1) < 0;
}

/// One row of the label ledger.
class LabelMovement {
  final String name;
  final String movementType;

  /// Signed: positive added labels, negative used them.
  final int qty;
  final DateTime? postingDate;
  final String? remarks;
  final String? referenceDoctype;
  final String? referenceName;
  final String? printOrder;
  final String? owner;

  const LabelMovement({
    required this.name,
    required this.movementType,
    required this.qty,
    required this.postingDate,
    required this.remarks,
    required this.referenceDoctype,
    required this.referenceName,
    required this.printOrder,
    required this.owner,
  });

  factory LabelMovement.fromJson(Map<String, dynamic> json) => LabelMovement(
        name: _toStr(json['name']),
        movementType: _toStr(json['movement_type']),
        qty: _toInt(json['qty']),
        postingDate: _toDate(json['posting_date']),
        remarks: _toNullableStr(json['remarks']),
        referenceDoctype: _toNullableStr(json['reference_doctype']),
        referenceName: _toNullableStr(json['reference_name']),
        printOrder: _toNullableStr(json['print_order']),
        owner: _toNullableStr(json['owner']),
      );

  bool get isIncoming => qty > 0;

  /// True when the row was posted by the invoice hook rather than by a person.
  bool get isAutomatic => referenceDoctype == 'Sales Invoice';
}

/// One label design belonging to one B2B customer, with its computed position.
class CustomerLabel {
  final String name;
  final String customer;
  final String customerName;
  final String labelTitle;
  final bool enabled;

  /// False when the customer supplies their own labels — never counted, never
  /// alerted on. This is the flag that keeps the board down to the customers
  /// this feature is actually about.
  final bool wePrint;
  final bool tracked;
  final String? appliesToItemGroup;
  final double labelsPerUnit;

  final int onHandQty;
  final int minStockQty;
  final int reorderQty;
  final int suggestedPrintQty;

  final double avgDailyUsage;

  /// Null when there is no consumption history yet to divide by.
  final double? daysOfCover;
  final int consumedInWindow;
  final int usageWindowDays;

  final LabelStatus status;
  final bool needsAttention;

  final int leadDays;
  final int leadDaysMin;
  final int leadDaysMax;
  final String restDay;
  final DateTime? expectedReadyIfOrderedToday;
  final DateTime? runsOutOn;

  final List<LabelPrintOrder> openPrintOrders;
  final DateTime? lastMovementOn;
  final DateTime? lastCountedOn;
  final String? notes;

  /// Populated by `get_label_detail` only; empty on the dashboard list.
  final List<LabelMovement> movements;
  final List<LabelPrintOrder> printOrders;

  const CustomerLabel({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.labelTitle,
    required this.enabled,
    required this.wePrint,
    required this.tracked,
    required this.appliesToItemGroup,
    required this.labelsPerUnit,
    required this.onHandQty,
    required this.minStockQty,
    required this.reorderQty,
    required this.suggestedPrintQty,
    required this.avgDailyUsage,
    required this.daysOfCover,
    required this.consumedInWindow,
    required this.usageWindowDays,
    required this.status,
    required this.needsAttention,
    required this.leadDays,
    required this.leadDaysMin,
    required this.leadDaysMax,
    required this.restDay,
    required this.expectedReadyIfOrderedToday,
    required this.runsOutOn,
    required this.openPrintOrders,
    required this.lastMovementOn,
    required this.lastCountedOn,
    required this.notes,
    required this.movements,
    required this.printOrders,
  });

  factory CustomerLabel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) build) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => build(Map<String, dynamic>.from(e)))
          .toList();
    }

    return CustomerLabel(
      name: _toStr(json['name']),
      customer: _toStr(json['customer']),
      customerName: _toStr(json['customer_name']).isEmpty
          ? _toStr(json['customer'])
          : _toStr(json['customer_name']),
      labelTitle: _toStr(json['label_title']).isEmpty
          ? 'Default'
          : _toStr(json['label_title']),
      enabled: _toBool(json['enabled']),
      wePrint: _toBool(json['we_print']),
      tracked: _toBool(json['tracked']),
      appliesToItemGroup: _toNullableStr(json['applies_to_item_group']),
      labelsPerUnit: _toDouble(json['labels_per_unit']),
      onHandQty: _toInt(json['on_hand_qty']),
      minStockQty: _toInt(json['min_stock_qty']),
      reorderQty: _toInt(json['reorder_qty']),
      suggestedPrintQty: _toInt(json['suggested_print_qty']),
      avgDailyUsage: _toDouble(json['avg_daily_usage']),
      daysOfCover: _toNullableDouble(json['days_of_cover']),
      consumedInWindow: _toInt(json['consumed_in_window']),
      usageWindowDays: _toInt(json['usage_window_days']),
      status: LabelStatus.parse(_toStr(json['status'])),
      needsAttention: _toBool(json['needs_attention']),
      leadDays: _toInt(json['lead_days']),
      leadDaysMin: _toInt(json['lead_days_min']),
      leadDaysMax: _toInt(json['lead_days_max']),
      restDay: _toStr(json['rest_day']),
      expectedReadyIfOrderedToday:
          _toDate(json['expected_ready_if_ordered_today']),
      runsOutOn: _toDate(json['runs_out_on']),
      openPrintOrders:
          parseList(json['open_print_orders'], LabelPrintOrder.fromJson),
      lastMovementOn: _toDate(json['last_movement_on']),
      lastCountedOn: _toDate(json['last_counted_on']),
      notes: _toNullableStr(json['notes']),
      movements: parseList(json['movements'], LabelMovement.fromJson),
      printOrders: parseList(json['print_orders'], LabelPrintOrder.fromJson),
    );
  }

  String get displayTitle =>
      labelTitle == 'Default' ? customerName : '$customerName · $labelTitle';

  bool get hasOpenPrintOrder => openPrintOrders.isNotEmpty;

  /// The soonest batch already on its way, if any.
  LabelPrintOrder? get nextArrival =>
      openPrintOrders.isEmpty ? null : openPrintOrders.first;
}

/// Counts per status, for the dashboard header and the drawer badge.
class LabelSummary {
  final int total;
  final int tracked;
  final int outOfStock;
  final int reorderNow;
  final int reorderSoon;
  final int onOrder;
  final int ok;
  final int notTracked;
  final int needsAttention;

  const LabelSummary({
    required this.total,
    required this.tracked,
    required this.outOfStock,
    required this.reorderNow,
    required this.reorderSoon,
    required this.onOrder,
    required this.ok,
    required this.notTracked,
    required this.needsAttention,
  });

  const LabelSummary.empty()
      : total = 0,
        tracked = 0,
        outOfStock = 0,
        reorderNow = 0,
        reorderSoon = 0,
        onOrder = 0,
        ok = 0,
        notTracked = 0,
        needsAttention = 0;

  factory LabelSummary.fromJson(Map<String, dynamic> json) => LabelSummary(
        total: _toInt(json['total']),
        tracked: _toInt(json['tracked']),
        outOfStock: _toInt(json['out_of_stock']),
        reorderNow: _toInt(json['reorder_now']),
        reorderSoon: _toInt(json['reorder_soon']),
        onOrder: _toInt(json['on_order']),
        ok: _toInt(json['ok']),
        notTracked: _toInt(json['not_tracked']),
        needsAttention: _toInt(json['needs_attention']),
      );

  /// The count that must go to the print house today, not merely soon.
  int get urgent => outOfStock + reorderNow;
}

/// The printing lead time and alert configuration, as the server sees it.
class LabelSettings {
  final int leadDaysMin;
  final int leadDaysMax;
  final String restDay;
  final int bufferDays;
  final bool autoConsume;
  final bool alertsEnabled;
  final DateTime? expectedReadyIfOrderedToday;

  const LabelSettings({
    required this.leadDaysMin,
    required this.leadDaysMax,
    required this.restDay,
    required this.bufferDays,
    required this.autoConsume,
    required this.alertsEnabled,
    required this.expectedReadyIfOrderedToday,
  });

  const LabelSettings.fallback()
      : leadDaysMin = 2,
        leadDaysMax = 3,
        restDay = 'Friday',
        bufferDays = 3,
        autoConsume = true,
        alertsEnabled = true,
        expectedReadyIfOrderedToday = null;

  /// Missing fields fall back to the same defaults `services/label_stock.py`
  /// applies, so a partial payload renders "2–3 working days" rather than the
  /// nonsense "0–0 working days".
  factory LabelSettings.fromJson(Map<String, dynamic> json) {
    const fallback = LabelSettings.fallback();
    int intOr(String key, int alternative) {
      final value = _toInt(json[key]);
      return value > 0 ? value : alternative;
    }

    return LabelSettings(
      leadDaysMin: intOr('lead_days_min', fallback.leadDaysMin),
      leadDaysMax: intOr('lead_days_max', fallback.leadDaysMax),
      restDay: _toNullableStr(json['rest_day']) ?? fallback.restDay,
      // Zero buffer is a legitimate choice, so this one only falls back when
      // the key is absent entirely.
      bufferDays: json.containsKey('buffer_days')
          ? _toInt(json['buffer_days'])
          : fallback.bufferDays,
      autoConsume: json.containsKey('auto_consume')
          ? _toBool(json['auto_consume'])
          : fallback.autoConsume,
      alertsEnabled: json.containsKey('alerts_enabled')
          ? _toBool(json['alerts_enabled'])
          : fallback.alertsEnabled,
      expectedReadyIfOrderedToday:
          _toDate(json['expected_ready_if_ordered_today']),
    );
  }
}

/// Everything the labels board needs in one round trip.
class LabelDashboard {
  final LabelSummary summary;
  final List<CustomerLabel> labels;
  final LabelSettings settings;

  const LabelDashboard({
    required this.summary,
    required this.labels,
    required this.settings,
  });

  const LabelDashboard.empty()
      : summary = const LabelSummary.empty(),
        labels = const [],
        settings = const LabelSettings.fallback();

  factory LabelDashboard.fromJson(Map<String, dynamic> json) => LabelDashboard(
        summary: LabelSummary.fromJson(
          Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
        ),
        labels: (json['labels'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => CustomerLabel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        settings: LabelSettings.fromJson(
          Map<String, dynamic>.from((json['settings'] as Map?) ?? const {}),
        ),
      );
}

/// A customer the user may start tracking a label for.
class LabelCustomerOption {
  final String customer;
  final String customerName;
  final String? customerGroup;
  final int labelCount;

  const LabelCustomerOption({
    required this.customer,
    required this.customerName,
    required this.customerGroup,
    required this.labelCount,
  });

  factory LabelCustomerOption.fromJson(Map<String, dynamic> json) =>
      LabelCustomerOption(
        customer: _toStr(json['customer']),
        customerName: _toStr(json['customer_name']).isEmpty
            ? _toStr(json['customer'])
            : _toStr(json['customer_name']),
        customerGroup: _toNullableStr(json['customer_group']),
        labelCount: _toInt(json['label_count']),
      );
}
