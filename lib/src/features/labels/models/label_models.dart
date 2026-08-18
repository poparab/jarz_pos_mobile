/// Models for B2B customer label stock, backed by `jarz_pos.api.labels.*`.
///
/// Every quantity here is computed server-side from the `Jarz Label Movement`
/// ledger — the app never adds up a balance itself, so the number on the phone
/// and the number in the daily alert cannot drift apart.
///
/// v2: one label per (customer, flavour item). Ordering happens in SHEETS
/// (21 Medium / 18 Large per sheet), each label has a home storage location,
/// and print batches carry real money (supplier, net cost, purchase invoice).
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

List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) build) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => build(Map<String, dynamic>.from(e)))
      .toList();
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

/// A print batch sent to the print house. Ordered in sheets; counted in labels.
class LabelPrintOrder {
  final String name;

  /// Label quantity (computed server-side from sheets × labels per sheet).
  final int qty;

  /// What was actually ordered: whole sheets, because that is what the print
  /// house sells.
  final int qtySheets;
  final String status;
  final DateTime? requestedOn;
  final DateTime? expectedReadyDate;
  final DateTime? receivedOn;
  final int receivedQty;
  final String? printerName;
  final String? supplier;

  /// The supplier Purchase Invoice, set once the batch is billed.
  final String? purchaseInvoice;

  /// Net cost of the batch (what the printer charged, before VAT).
  final double totalCost;
  final double costPerLabel;

  /// "Unbilled" until `bill_print_order` books the supplier invoice.
  final String billingStatus;
  final String? notes;
  final String? requestedBy;

  const LabelPrintOrder({
    required this.name,
    required this.qty,
    required this.qtySheets,
    required this.status,
    required this.requestedOn,
    required this.expectedReadyDate,
    required this.receivedOn,
    required this.receivedQty,
    required this.printerName,
    required this.supplier,
    required this.purchaseInvoice,
    required this.totalCost,
    required this.costPerLabel,
    required this.billingStatus,
    required this.notes,
    required this.requestedBy,
  });

  factory LabelPrintOrder.fromJson(Map<String, dynamic> json) =>
      LabelPrintOrder(
        name: _toStr(json['name']),
        qty: _toInt(json['qty']),
        qtySheets: _toInt(json['qty_sheets']),
        status: _toStr(json['status']),
        requestedOn: _toDate(json['requested_on']),
        expectedReadyDate: _toDate(json['expected_ready_date']),
        receivedOn: _toDate(json['received_on']),
        receivedQty: _toInt(json['received_qty']),
        printerName: _toNullableStr(json['printer_name']),
        supplier: _toNullableStr(json['supplier']),
        purchaseInvoice: _toNullableStr(json['purchase_invoice']),
        totalCost: _toDouble(json['total_cost']),
        costPerLabel: _toDouble(json['cost_per_label']),
        billingStatus: _toNullableStr(json['billing_status']) ?? 'Unbilled',
        notes: _toNullableStr(json['notes']),
        requestedBy: _toNullableStr(json['requested_by']),
      );

  bool get isOpen =>
      status == 'Requested' || status == 'Printing' || status == 'Ready';

  bool get isReceived => status == 'Received';

  bool get isBilled => billingStatus == 'Billed';

  /// Received but the printer's bill was never booked — real money still
  /// missing from the ledger.
  bool get awaitsBill => isReceived && !isBilled;

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

  /// What each label in this row was valued at.
  final double unitCost;

  /// Signed money: what this row added to or drained from Labels Inventory.
  final double value;
  final DateTime? postingDate;
  final String? remarks;
  final String? referenceDoctype;
  final String? referenceName;
  final String? printOrder;

  /// The COGS Journal Entry mirroring this row's value, when one was posted.
  final String? journalEntry;
  final String? owner;

  const LabelMovement({
    required this.name,
    required this.movementType,
    required this.qty,
    required this.unitCost,
    required this.value,
    required this.postingDate,
    required this.remarks,
    required this.referenceDoctype,
    required this.referenceName,
    required this.printOrder,
    required this.journalEntry,
    required this.owner,
  });

  factory LabelMovement.fromJson(Map<String, dynamic> json) => LabelMovement(
        name: _toStr(json['name']),
        movementType: _toStr(json['movement_type']),
        qty: _toInt(json['qty']),
        unitCost: _toDouble(json['unit_cost']),
        value: _toDouble(json['value']),
        postingDate: _toDate(json['posting_date']),
        remarks: _toNullableStr(json['remarks']),
        referenceDoctype: _toNullableStr(json['reference_doctype']),
        referenceName: _toNullableStr(json['reference_name']),
        printOrder: _toNullableStr(json['print_order']),
        journalEntry: _toNullableStr(json['journal_entry']),
        owner: _toNullableStr(json['owner']),
      );

  bool get isIncoming => qty > 0;

  /// True when the row was posted by the invoice hook rather than by a person.
  bool get isAutomatic => referenceDoctype == 'Sales Invoice';
}

/// One flavour's label for one B2B customer, with its computed position.
class CustomerLabel {
  final String name;
  final String customer;
  final String customerName;
  final String labelTitle;

  /// The flavour Item this label belongs to. Every flavour has its own artwork.
  final String? item;

  /// The jar size (Item Group: Medium/Large) — it decides the sheet layout.
  final String? size;

  /// The warehouse (branch or factory) where this label physically lives.
  final String? storageLocation;
  final bool enabled;

  /// False when the customer supplies their own labels — never counted, never
  /// alerted on. This is the flag that keeps the board down to the customers
  /// this feature is actually about.
  final bool wePrint;
  final bool tracked;
  final double labelsPerUnit;

  /// Labels on one printed sheet for this design (size default or override).
  final int labelsPerSheet;

  /// The usual batch, in sheets.
  final int defaultPrintSheets;

  final int onHandQty;
  final int minStockQty;

  /// What the labels on the shelf are worth (sum of ledger value).
  final double stockValue;

  /// Weighted-average cost of what is left; zero until a batch is billed.
  final double avgCostPerLabel;

  /// Sheets to order now, per the server's cover maths.
  final int suggestedPrintSheets;

  /// The same suggestion expressed in labels.
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
    required this.item,
    required this.size,
    required this.storageLocation,
    required this.enabled,
    required this.wePrint,
    required this.tracked,
    required this.labelsPerUnit,
    required this.labelsPerSheet,
    required this.defaultPrintSheets,
    required this.onHandQty,
    required this.minStockQty,
    required this.stockValue,
    required this.avgCostPerLabel,
    required this.suggestedPrintSheets,
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
    return CustomerLabel(
      name: _toStr(json['name']),
      customer: _toStr(json['customer']),
      customerName: _toStr(json['customer_name']).isEmpty
          ? _toStr(json['customer'])
          : _toStr(json['customer_name']),
      labelTitle: _toStr(json['label_title']).isEmpty
          ? 'Default'
          : _toStr(json['label_title']),
      item: _toNullableStr(json['item']),
      size: _toNullableStr(json['size']),
      storageLocation: _toNullableStr(json['storage_location']),
      enabled: _toBool(json['enabled']),
      wePrint: _toBool(json['we_print']),
      tracked: _toBool(json['tracked']),
      labelsPerUnit: _toDouble(json['labels_per_unit']),
      labelsPerSheet: _toInt(json['labels_per_sheet']),
      defaultPrintSheets: _toInt(json['default_print_sheets']),
      onHandQty: _toInt(json['on_hand_qty']),
      minStockQty: _toInt(json['min_stock_qty']),
      stockValue: _toDouble(json['stock_value']),
      avgCostPerLabel: _toDouble(json['avg_cost_per_label']),
      suggestedPrintSheets: _toInt(json['suggested_print_sheets']),
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
          _parseList(json['open_print_orders'], LabelPrintOrder.fromJson),
      lastMovementOn: _toDate(json['last_movement_on']),
      lastCountedOn: _toDate(json['last_counted_on']),
      notes: _toNullableStr(json['notes']),
      movements: _parseList(json['movements'], LabelMovement.fromJson),
      printOrders: _parseList(json['print_orders'], LabelPrintOrder.fromJson),
    );
  }

  String get displayTitle =>
      labelTitle == 'Default' ? customerName : '$customerName · $labelTitle';

  bool get hasOpenPrintOrder => openPrintOrders.isNotEmpty;

  /// The soonest batch already on its way, if any.
  LabelPrintOrder? get nextArrival =>
      openPrintOrders.isEmpty ? null : openPrintOrders.first;

  /// Sheet-to-label equivalence for this design: what [sheets] sheets yield.
  ///
  /// The one place the "N sheets = M labels" line is computed, so the order
  /// sheet and the confirmation snackbar can never disagree.
  int labelsForSheets(int sheets) {
    if (sheets <= 0 || labelsPerSheet <= 0) return 0;
    return sheets * labelsPerSheet;
  }
}

/// One customer's slice of the board: their flavour labels, most urgent first.
class LabelCustomerGroup {
  final String customer;
  final String customerName;
  final List<CustomerLabel> labels;

  const LabelCustomerGroup({
    required this.customer,
    required this.customerName,
    required this.labels,
  });

  /// The most urgent status among this customer's flavours — what the header
  /// stripe shows, so a customer with one dead flavour reads as urgent even
  /// when the rest are fine.
  LabelStatus get worstStatus {
    var worst = LabelStatus.unknown;
    var worstIndex = 999;
    for (final label in labels) {
      if (label.status == LabelStatus.unknown) continue;
      if (label.status.index < worstIndex) {
        worstIndex = label.status.index;
        worst = label.status;
      }
    }
    return worst;
  }

  int get needsAttentionCount =>
      labels.where((l) => l.needsAttention).length;
}

/// Groups board rows by customer, preserving the incoming order.
///
/// The server sorts labels most urgent first; the first time a customer
/// appears fixes their position, so the customer with the most urgent flavour
/// still tops the board.
List<LabelCustomerGroup> groupLabelsByCustomer(List<CustomerLabel> labels) {
  final order = <String>[];
  final byCustomer = <String, List<CustomerLabel>>{};
  for (final label in labels) {
    final key = label.customer.isEmpty ? label.customerName : label.customer;
    if (!byCustomer.containsKey(key)) {
      order.add(key);
      byCustomer[key] = [];
    }
    byCustomer[key]!.add(label);
  }
  return [
    for (final key in order)
      LabelCustomerGroup(
        customer: key,
        customerName: byCustomer[key]!.first.customerName,
        labels: byCustomer[key]!,
      ),
  ];
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

/// The printing lead time, sheet geometry and alert configuration, as the
/// server sees it.
class LabelSettings {
  final int leadDaysMin;
  final int leadDaysMax;
  final String restDay;
  final int bufferDays;
  final bool autoConsume;
  final bool alertsEnabled;

  /// Labels on one Medium sheet / one Large sheet at the print house.
  final int sheetMedium;
  final int sheetLarge;

  /// The site-wide usual batch, in sheets, when a label has no override.
  final int defaultPrintSheets;

  /// Whether consumption value is mirrored into COGS journals.
  final bool postCogs;

  /// True once both GL accounts are configured; false means count-only mode.
  final bool accountingReady;
  final DateTime? expectedReadyIfOrderedToday;

  const LabelSettings({
    required this.leadDaysMin,
    required this.leadDaysMax,
    required this.restDay,
    required this.bufferDays,
    required this.autoConsume,
    required this.alertsEnabled,
    required this.sheetMedium,
    required this.sheetLarge,
    required this.defaultPrintSheets,
    required this.postCogs,
    required this.accountingReady,
    required this.expectedReadyIfOrderedToday,
  });

  const LabelSettings.fallback()
      : leadDaysMin = 2,
        leadDaysMax = 3,
        restDay = 'Friday',
        bufferDays = 3,
        autoConsume = true,
        alertsEnabled = true,
        sheetMedium = 21,
        sheetLarge = 18,
        defaultPrintSheets = 2,
        postCogs = true,
        accountingReady = false,
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
      // Zero labels on a sheet is nonsense, so these fall back like lead time.
      sheetMedium: intOr('sheet_medium', fallback.sheetMedium),
      sheetLarge: intOr('sheet_large', fallback.sheetLarge),
      defaultPrintSheets:
          intOr('default_print_sheets', fallback.defaultPrintSheets),
      postCogs: json.containsKey('post_cogs')
          ? _toBool(json['post_cogs'])
          : fallback.postCogs,
      accountingReady: _toBool(json['accounting_ready']),
      expectedReadyIfOrderedToday:
          _toDate(json['expected_ready_if_ordered_today']),
    );
  }
}

/// Everything the labels board needs in one round trip.
class LabelDashboard {
  final LabelSummary summary;
  final List<CustomerLabel> labels;

  /// Distinct storage locations in use, for the board's location filter.
  final List<String> locations;
  final LabelSettings settings;

  const LabelDashboard({
    required this.summary,
    required this.labels,
    required this.locations,
    required this.settings,
  });

  const LabelDashboard.empty()
      : summary = const LabelSummary.empty(),
        labels = const [],
        locations = const [],
        settings = const LabelSettings.fallback();

  factory LabelDashboard.fromJson(Map<String, dynamic> json) => LabelDashboard(
        summary: LabelSummary.fromJson(
          Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
        ),
        labels: (json['labels'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => CustomerLabel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        locations: (json['locations'] as List? ?? const [])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        settings: LabelSettings.fromJson(
          Map<String, dynamic>.from((json['settings'] as Map?) ?? const {}),
        ),
      );
}

/// A customer the user may set up labels for.
class LabelCustomerOption {
  final String customer;
  final String customerName;
  final String? customerGroup;
  final String? defaultPriceList;
  final int labelCount;

  const LabelCustomerOption({
    required this.customer,
    required this.customerName,
    required this.customerGroup,
    required this.defaultPriceList,
    required this.labelCount,
  });

  factory LabelCustomerOption.fromJson(Map<String, dynamic> json) =>
      LabelCustomerOption(
        customer: _toStr(json['customer']),
        customerName: _toStr(json['customer_name']).isEmpty
            ? _toStr(json['customer'])
            : _toStr(json['customer_name']),
        customerGroup: _toNullableStr(json['customer_group']),
        defaultPriceList: _toNullableStr(json['default_price_list']),
        labelCount: _toInt(json['label_count']),
      );
}

/// One flavour the setup wizard can offer: where it came from and whether a
/// label already tracks it.
class LabelFlavourOption {
  final String itemCode;
  final String itemName;

  /// Jar size (Item Group) — the wizard groups the checklist by this.
  final String size;

  /// Provenance flags: "price_list", "history", "label".
  final List<String> sources;
  final bool hasLabel;

  /// The existing label's name when [hasLabel] is true.
  final String? label;

  const LabelFlavourOption({
    required this.itemCode,
    required this.itemName,
    required this.size,
    required this.sources,
    required this.hasLabel,
    required this.label,
  });

  factory LabelFlavourOption.fromJson(Map<String, dynamic> json) =>
      LabelFlavourOption(
        itemCode: _toStr(json['item_code']),
        itemName: _toStr(json['item_name']).isEmpty
            ? _toStr(json['item_code'])
            : _toStr(json['item_name']),
        size: _toStr(json['size']),
        sources: (json['sources'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        hasLabel: _toBool(json['has_label']),
        label: _toNullableStr(json['label']),
      );

  bool get onPriceList => sources.contains('price_list');
  bool get orderedBefore => sources.contains('history');
}

/// The flavours a customer deals in, for the setup wizard's checklist.
class LabelFlavourOptions {
  final String customer;
  final String? priceList;
  final List<LabelFlavourOption> flavours;

  const LabelFlavourOptions({
    required this.customer,
    required this.priceList,
    required this.flavours,
  });

  factory LabelFlavourOptions.fromJson(Map<String, dynamic> json) =>
      LabelFlavourOptions(
        customer: _toStr(json['customer']),
        priceList: _toNullableStr(json['price_list']),
        flavours: _parseList(json['flavours'], LabelFlavourOption.fromJson),
      );
}

/// A warehouse a label can live in (branch or factory).
class LabelStorageLocation {
  final String name;
  final String label;

  const LabelStorageLocation({required this.name, required this.label});

  factory LabelStorageLocation.fromJson(Map<String, dynamic> json) =>
      LabelStorageLocation(
        name: _toStr(json['name']),
        label: _toStr(json['label']).isEmpty
            ? _toStr(json['name'])
            : _toStr(json['label']),
      );
}

/// A supplier option for the print house picker.
class LabelSupplierOption {
  final String name;
  final String supplierName;

  const LabelSupplierOption({required this.name, required this.supplierName});

  factory LabelSupplierOption.fromJson(Map<String, dynamic> json) =>
      LabelSupplierOption(
        name: _toStr(json['name']),
        supplierName: _toStr(json['supplier_name']).isEmpty
            ? _toStr(json['name'])
            : _toStr(json['supplier_name']),
      );
}

/// What `setup_customer_labels` reports back: which flavours were created and
/// which were already tracked (re-running the wizard is additive, never
/// destructive).
class LabelSetupResult {
  final List<String> created;
  final List<String> skippedItems;
  final String? priceList;
  final LabelSummary summary;

  const LabelSetupResult({
    required this.created,
    required this.skippedItems,
    required this.priceList,
    required this.summary,
  });

  factory LabelSetupResult.fromJson(Map<String, dynamic> json) =>
      LabelSetupResult(
        created: (json['created'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        skippedItems: (json['skipped'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => _toStr(e['item_code']))
            .where((e) => e.isNotEmpty)
            .toList(),
        priceList: _toNullableStr(json['price_list']),
        summary: LabelSummary.fromJson(
          Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
        ),
      );

  int get createdCount => created.length;
  int get skippedCount => skippedItems.length;
}

/// One flavour row the wizard sends to `setup_customer_labels`.
class LabelSetupFlavour {
  final String itemCode;
  final int openingQty;
  final int minStockQty;

  const LabelSetupFlavour({
    required this.itemCode,
    this.openingQty = 0,
    this.minStockQty = 0,
  });

  Map<String, dynamic> toJson() => {
        'item_code': itemCode,
        if (openingQty != 0) 'opening_qty': openingQty,
        if (minStockQty != 0) 'min_stock_qty': minStockQty,
      };
}
