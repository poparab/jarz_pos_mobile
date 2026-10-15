import 'report_json.dart';

// Models for `jarz_pos.api.ops_reports.*` (reports overhaul, spec A0–A3).
//
// Hand-written on purpose (no Freezed / json_serializable): every field is
// read through [ReportJson], so a missing key, a null or a number sent as a
// string falls back to a neutral value instead of throwing.

// ── A0 · get_report_branches ──────────────────────────────────────────────

/// A branch as the reports see it: a non-disabled POS Profile and the
/// warehouse that holds its stock.
class ReportBranch {
  final String name;
  final String warehouse;
  final String company;

  const ReportBranch({
    required this.name,
    this.warehouse = '',
    this.company = '',
  });

  factory ReportBranch.fromJson(JsonMap j) => ReportBranch(
    name: ReportJson.str(j['name']),
    warehouse: ReportJson.str(j['warehouse']),
    company: ReportJson.str(j['company']),
  );

  /// Parses `{"branches": [...]}` (or a bare list), dropping nameless rows.
  static List<ReportBranch> listFromPayload(Object? payload) {
    final raw = payload is Map ? payload['branches'] : payload;
    return ReportJson.listOf(raw, ReportBranch.fromJson)
        .where((b) => b.name.isNotEmpty)
        .toList(growable: false);
  }
}

// ── Shared row shapes ─────────────────────────────────────────────────────

/// Orders + net sales for one sales channel. [channel] is one of the backend
/// keys `pos`, `woo`, `talabat`, `b2b`, `staff` (unknown keys pass through).
class ChannelSales {
  final String channel;
  final int orders;
  final double netSales;

  const ChannelSales({
    required this.channel,
    this.orders = 0,
    this.netSales = 0,
  });

  factory ChannelSales.fromJson(JsonMap j) => ChannelSales(
    channel: ReportJson.str(j['channel']),
    orders: ReportJson.integer(j['orders']),
    netSales: ReportJson.dbl(j['net_sales']),
  );
}

/// Money collected through one Mode of Payment.
class PaymentModeAmount {
  final String mode;
  final double amount;

  const PaymentModeAmount({required this.mode, this.amount = 0});

  factory PaymentModeAmount.fromJson(JsonMap j) => PaymentModeAmount(
    mode: ReportJson.str(j['mode']),
    amount: ReportJson.dbl(j['amount']),
  );
}

// ── A1 · get_daily_close ──────────────────────────────────────────────────

class DailyClose {
  final JsonMap filters;
  final DailyCloseTotals totals;

  /// All branches combined.
  final List<ChannelSales> channels;
  final List<DailyCloseBranch> branches;
  final List<PaymentModeAmount> payments;
  final List<HourlySales> byHour;

  const DailyClose({
    this.filters = const {},
    this.totals = const DailyCloseTotals(),
    this.channels = const [],
    this.branches = const [],
    this.payments = const [],
    this.byHour = const [],
  });

  factory DailyClose.fromJson(JsonMap j) => DailyClose(
    filters: ReportJson.map(j['filters']),
    totals: DailyCloseTotals.fromJson(ReportJson.map(j['totals'])),
    channels: ReportJson.listOf(j['channels'], ChannelSales.fromJson),
    branches: ReportJson.listOf(j['branches'], DailyCloseBranch.fromJson),
    payments: ReportJson.listOf(j['payments'], PaymentModeAmount.fromJson),
    byHour: ReportJson.listOf(j['by_hour'], HourlySales.fromJson),
  );

  bool get isEmpty => totals.orders == 0 && branches.isEmpty;
}

class DailyCloseTotals {
  final int orders;
  final double netSales;
  final double grandTotal;
  final double shippingIncome;

  /// Returns as a positive amount (the backend negates the net return value).
  final double returns;
  final int cancelled;
  final double avgOrderValue;

  /// Extra keys (backend notes): sales before returns, number of return
  /// invoices, and money still owed (Talabat / courier JE settlements).
  final double grossSales;
  final int returnsCount;
  final double outstanding;

  const DailyCloseTotals({
    this.orders = 0,
    this.netSales = 0,
    this.grandTotal = 0,
    this.shippingIncome = 0,
    this.returns = 0,
    this.cancelled = 0,
    this.avgOrderValue = 0,
    this.grossSales = 0,
    this.returnsCount = 0,
    this.outstanding = 0,
  });

  factory DailyCloseTotals.fromJson(JsonMap j) => DailyCloseTotals(
    orders: ReportJson.integer(j['orders']),
    netSales: ReportJson.dbl(j['net_sales']),
    grandTotal: ReportJson.dbl(j['grand_total']),
    shippingIncome: ReportJson.dbl(j['shipping_income']),
    returns: ReportJson.dbl(j['returns']),
    cancelled: ReportJson.integer(j['cancelled']),
    avgOrderValue: ReportJson.dbl(j['avg_order_value']),
    grossSales: ReportJson.dbl(j['gross_sales']),
    returnsCount: ReportJson.integer(j['returns_count']),
    outstanding: ReportJson.dbl(j['outstanding']),
  );
}

class DailyCloseBranch {
  final String branch;
  final int orders;
  final double netSales;
  final double shippingIncome;
  final List<ChannelSales> channels;
  final List<PaymentModeAmount> payments;
  final int cancelled;

  const DailyCloseBranch({
    required this.branch,
    this.orders = 0,
    this.netSales = 0,
    this.shippingIncome = 0,
    this.cancelled = 0,
    this.channels = const [],
    this.payments = const [],
  });

  factory DailyCloseBranch.fromJson(JsonMap j) => DailyCloseBranch(
    branch: ReportJson.str(j['branch']),
    orders: ReportJson.integer(j['orders']),
    netSales: ReportJson.dbl(j['net_sales']),
    shippingIncome: ReportJson.dbl(j['shipping_income']),
    cancelled: ReportJson.integer(j['cancelled']),
    channels: ReportJson.listOf(j['channels'], ChannelSales.fromJson),
    payments: ReportJson.listOf(j['payments'], PaymentModeAmount.fromJson),
  );
}

class HourlySales {
  /// 0–23, server local time.
  final int hour;
  final int orders;
  final double netSales;

  const HourlySales({required this.hour, this.orders = 0, this.netSales = 0});

  factory HourlySales.fromJson(JsonMap j) => HourlySales(
    hour: ReportJson.integer(j['hour']),
    orders: ReportJson.integer(j['orders']),
    netSales: ReportJson.dbl(j['net_sales']),
  );
}

// ── A2 · get_cash_over_short ──────────────────────────────────────────────

/// Over / short figures share one shape at every level. `over` and `short`
/// are both positive amounts; `net` is signed (over − short).
class CashOverShort {
  final JsonMap filters;
  final CashOverShortTotals totals;
  final List<CashOverShortBranch> branches;
  final List<CashOverShortCashier> cashiers;

  /// Newest first, capped at 300 by the server.
  final List<CashOverShortShift> shifts;

  /// The Cash Over/Short account as booked (backend extra key); null when
  /// the server did not send it.
  final CashOverShortLedger? ledger;

  const CashOverShort({
    this.filters = const {},
    this.totals = const CashOverShortTotals(),
    this.branches = const [],
    this.cashiers = const [],
    this.shifts = const [],
    this.ledger,
  });

  factory CashOverShort.fromJson(JsonMap j) => CashOverShort(
    filters: ReportJson.map(j['filters']),
    totals: CashOverShortTotals.fromJson(ReportJson.map(j['totals'])),
    branches: ReportJson.listOf(j['branches'], CashOverShortBranch.fromJson),
    cashiers: ReportJson.listOf(j['cashiers'], CashOverShortCashier.fromJson),
    shifts: ReportJson.listOf(j['shifts'], CashOverShortShift.fromJson),
    ledger: j['ledger'] is Map
        ? CashOverShortLedger.fromJson(ReportJson.map(j['ledger']))
        : null,
  );

  bool get isEmpty => totals.shifts == 0 && shifts.isEmpty;
}

/// Cash Over/Short account movements in the range: booked at shift close,
/// at shift open (drawer write-offs), and not linked to any shift.
/// `over` / `short` positive, the `*Net` figures signed.
class CashOverShortLedger {
  final double atCloseNet;
  final double atOpenNet;
  final double unlinkedNet;
  final double over;
  final double short;
  final double net;

  const CashOverShortLedger({
    this.atCloseNet = 0,
    this.atOpenNet = 0,
    this.unlinkedNet = 0,
    this.over = 0,
    this.short = 0,
    this.net = 0,
  });

  factory CashOverShortLedger.fromJson(JsonMap j) => CashOverShortLedger(
    atCloseNet: ReportJson.dbl(j['at_close_net']),
    atOpenNet: ReportJson.dbl(j['at_open_net']),
    unlinkedNet: ReportJson.dbl(j['unlinked_net']),
    over: ReportJson.dbl(j['over']),
    short: ReportJson.dbl(j['short']),
    net: ReportJson.dbl(j['net']),
  );
}

class CashOverShortTotals {
  final int shifts;
  final double over;
  final double short;
  final double net;
  final int shiftsWithDiff;

  const CashOverShortTotals({
    this.shifts = 0,
    this.over = 0,
    this.short = 0,
    this.net = 0,
    this.shiftsWithDiff = 0,
  });

  factory CashOverShortTotals.fromJson(JsonMap j) => CashOverShortTotals(
    shifts: ReportJson.integer(j['shifts']),
    over: ReportJson.dbl(j['over']),
    short: ReportJson.dbl(j['short']),
    net: ReportJson.dbl(j['net']),
    shiftsWithDiff: ReportJson.integer(j['shifts_with_diff']),
  );
}

class CashOverShortBranch {
  final String branch;
  final int shifts;
  final double over;
  final double short;
  final double net;

  const CashOverShortBranch({
    required this.branch,
    this.shifts = 0,
    this.over = 0,
    this.short = 0,
    this.net = 0,
  });

  factory CashOverShortBranch.fromJson(JsonMap j) => CashOverShortBranch(
    branch: ReportJson.str(j['branch']),
    shifts: ReportJson.integer(j['shifts']),
    over: ReportJson.dbl(j['over']),
    short: ReportJson.dbl(j['short']),
    net: ReportJson.dbl(j['net']),
  );
}

class CashOverShortCashier {
  final String user;
  final String fullName;
  final int shifts;
  final double over;
  final double short;
  final double net;

  const CashOverShortCashier({
    required this.user,
    this.fullName = '',
    this.shifts = 0,
    this.over = 0,
    this.short = 0,
    this.net = 0,
  });

  /// [fullName], or the user id when the server had no name.
  String get displayName => fullName.isNotEmpty ? fullName : user;

  factory CashOverShortCashier.fromJson(JsonMap j) => CashOverShortCashier(
    user: ReportJson.str(j['user']),
    fullName: ReportJson.str(j['full_name']),
    shifts: ReportJson.integer(j['shifts']),
    over: ReportJson.dbl(j['over']),
    short: ReportJson.dbl(j['short']),
    net: ReportJson.dbl(j['net']),
  );
}

class CashOverShortShift {
  final String name;
  final String branch;
  final String user;
  final String fullName;
  final DateTime? opened;
  final DateTime? closed;
  final double expected;
  final double counted;

  /// counted − expected: positive = over, negative = short.
  final double difference;

  /// The opening entry of this shift and the difference found when the
  /// drawer was opened (backend extra keys).
  final String? openingEntry;
  final double openingDifference;

  const CashOverShortShift({
    required this.name,
    this.branch = '',
    this.user = '',
    this.fullName = '',
    this.opened,
    this.closed,
    this.expected = 0,
    this.counted = 0,
    this.difference = 0,
    this.openingEntry,
    this.openingDifference = 0,
  });

  String get displayName => fullName.isNotEmpty ? fullName : user;

  factory CashOverShortShift.fromJson(JsonMap j) => CashOverShortShift(
    name: ReportJson.str(j['name']),
    branch: ReportJson.str(j['branch']),
    user: ReportJson.str(j['user']),
    fullName: ReportJson.str(j['full_name']),
    opened: ReportJson.dateTimeOrNull(j['opened']),
    closed: ReportJson.dateTimeOrNull(j['closed']),
    expected: ReportJson.dbl(j['expected']),
    counted: ReportJson.dbl(j['counted']),
    difference: ReportJson.dbl(j['difference']),
    openingEntry: ReportJson.strOrNull(j['opening_entry']),
    openingDifference: ReportJson.dbl(j['opening_difference']),
  );
}

// ── A3 · get_fulfilment_sla ───────────────────────────────────────────────

/// Order → dispatch → delivered timings. "Late" = delivered after the
/// delivery slot end when a slot exists, else more than
/// [FulfilmentSlaTotals.lateThresholdMin] minutes after creation.
class FulfilmentSla {
  final JsonMap filters;
  final FulfilmentSlaTotals totals;
  final List<FulfilmentSlaBranch> branches;
  final List<FulfilmentSlaDay> byDay;

  /// Worst first, capped at 100 by the server.
  final List<LateOrder> late;
  final List<CancellationReason> cancellations;

  const FulfilmentSla({
    this.filters = const {},
    this.totals = const FulfilmentSlaTotals(),
    this.branches = const [],
    this.byDay = const [],
    this.late = const [],
    this.cancellations = const [],
  });

  factory FulfilmentSla.fromJson(JsonMap j) => FulfilmentSla(
    filters: ReportJson.map(j['filters']),
    totals: FulfilmentSlaTotals.fromJson(ReportJson.map(j['totals'])),
    branches: ReportJson.listOf(j['branches'], FulfilmentSlaBranch.fromJson),
    byDay: ReportJson.listOf(j['by_day'], FulfilmentSlaDay.fromJson),
    late: ReportJson.listOf(j['late'], LateOrder.fromJson),
    cancellations: ReportJson.listOf(
      j['cancellations'],
      CancellationReason.fromJson,
    ),
  );

  bool get isEmpty => totals.orders == 0;
}

class FulfilmentSlaTotals {
  final int orders;
  final int delivered;
  final int cancelled;
  final int returned;

  /// Minutes; null when no order in range reached that stage.
  final double? medianToDispatchMin;
  final double? medianToDeliverMin;
  final double? p90ToDeliverMin;
  final int lateOrders;
  final int lateThresholdMin;

  /// Backend extra keys: orders still undelivered and already past their
  /// deadline, and how many orders had a dispatch / delivery timestamp.
  final int openLateOrders;
  final int timedDispatch;
  final int timedDelivery;

  const FulfilmentSlaTotals({
    this.orders = 0,
    this.delivered = 0,
    this.cancelled = 0,
    this.returned = 0,
    this.medianToDispatchMin,
    this.medianToDeliverMin,
    this.p90ToDeliverMin,
    this.lateOrders = 0,
    this.lateThresholdMin = 90,
    this.openLateOrders = 0,
    this.timedDispatch = 0,
    this.timedDelivery = 0,
  });

  factory FulfilmentSlaTotals.fromJson(JsonMap j) => FulfilmentSlaTotals(
    orders: ReportJson.integer(j['orders']),
    delivered: ReportJson.integer(j['delivered']),
    cancelled: ReportJson.integer(j['cancelled']),
    returned: ReportJson.integer(j['returned']),
    medianToDispatchMin: ReportJson.dblOrNull(j['median_to_dispatch_min']),
    medianToDeliverMin: ReportJson.dblOrNull(j['median_to_deliver_min']),
    p90ToDeliverMin: ReportJson.dblOrNull(j['p90_to_deliver_min']),
    lateOrders: ReportJson.integer(j['late_orders']),
    lateThresholdMin: ReportJson.integer(j['late_threshold_min'], 90),
    openLateOrders: ReportJson.integer(j['open_late_orders']),
    timedDispatch: ReportJson.integer(j['timed_dispatch']),
    timedDelivery: ReportJson.integer(j['timed_delivery']),
  );
}

class FulfilmentSlaBranch {
  final String branch;
  final int orders;
  final double? medianToDispatchMin;
  final double? medianToDeliverMin;
  final int lateOrders;
  final int cancelled;
  final int returned;

  const FulfilmentSlaBranch({
    required this.branch,
    this.orders = 0,
    this.medianToDispatchMin,
    this.medianToDeliverMin,
    this.lateOrders = 0,
    this.cancelled = 0,
    this.returned = 0,
  });

  factory FulfilmentSlaBranch.fromJson(JsonMap j) => FulfilmentSlaBranch(
    branch: ReportJson.str(j['branch']),
    orders: ReportJson.integer(j['orders']),
    medianToDispatchMin: ReportJson.dblOrNull(j['median_to_dispatch_min']),
    medianToDeliverMin: ReportJson.dblOrNull(j['median_to_deliver_min']),
    lateOrders: ReportJson.integer(j['late_orders']),
    cancelled: ReportJson.integer(j['cancelled']),
    returned: ReportJson.integer(j['returned']),
  );
}

class FulfilmentSlaDay {
  /// `YYYY-MM-DD` as sent; [day] is the parsed form.
  final String date;
  final int orders;
  final double? medianToDeliverMin;
  final int lateOrders;

  const FulfilmentSlaDay({
    required this.date,
    this.orders = 0,
    this.medianToDeliverMin,
    this.lateOrders = 0,
  });

  DateTime? get day => ReportJson.dateTimeOrNull(date);

  factory FulfilmentSlaDay.fromJson(JsonMap j) => FulfilmentSlaDay(
    date: ReportJson.str(j['date']),
    orders: ReportJson.integer(j['orders']),
    medianToDeliverMin: ReportJson.dblOrNull(j['median_to_deliver_min']),
    lateOrders: ReportJson.integer(j['late_orders']),
  );
}

class LateOrder {
  final String invoice;
  final String branch;
  final String customer;
  final DateTime? created;
  final DateTime? delivered;
  final double minutes;

  /// The delivery slot label, when the order had one.
  final String? slot;

  /// Backend extra keys: the deadline the order was judged against, which
  /// rule set it (slot end vs threshold), the current kanban state, and the
  /// total minutes from creation to delivery. [minutes] is minutes PAST
  /// the deadline.
  final DateTime? deadline;
  final String? rule;
  final String? state;
  final double? toDeliverMin;

  const LateOrder({
    required this.invoice,
    this.branch = '',
    this.customer = '',
    this.created,
    this.delivered,
    this.minutes = 0,
    this.slot,
    this.deadline,
    this.rule,
    this.state,
    this.toDeliverMin,
  });

  factory LateOrder.fromJson(JsonMap j) => LateOrder(
    invoice: ReportJson.str(j['invoice']),
    branch: ReportJson.str(j['branch']),
    customer: ReportJson.str(j['customer']),
    created: ReportJson.dateTimeOrNull(j['created']),
    delivered: ReportJson.dateTimeOrNull(j['delivered']),
    minutes: ReportJson.dbl(j['minutes']),
    slot: ReportJson.strOrNull(j['slot']),
    deadline: ReportJson.dateTimeOrNull(j['deadline']),
    rule: ReportJson.strOrNull(j['rule']),
    state: ReportJson.strOrNull(j['state']),
    toDeliverMin: ReportJson.dblOrNull(j['to_deliver_min']),
  );
}

class CancellationReason {
  final String reason;
  final int count;

  const CancellationReason({required this.reason, this.count = 0});

  factory CancellationReason.fromJson(JsonMap j) => CancellationReason(
    reason: ReportJson.str(j['reason']),
    count: ReportJson.integer(j['count']),
  );
}
