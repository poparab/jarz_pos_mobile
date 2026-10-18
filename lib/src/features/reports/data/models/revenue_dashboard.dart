import 'report_json.dart';

// Model for `jarz_pos.api.revenue_dashboard.get_revenue_dashboard`
// (Feature: revenue-dashboard).
//
// Hand-written on purpose (no Freezed / json_serializable): every field is
// read through [ReportJson] under the exact key the backend contract names,
// so a missing key, a null or a number sent as a string falls back to a
// neutral value instead of throwing. Values the contract allows to be null
// (AOV with no orders, a change % with nothing to compare against, shares of
// zero) stay nullable here so the screen can show "—" rather than a fake 0.

/// The whole dashboard payload (`message`).
class RevenueDashboard {
  /// `YYYY-MM-DD HH:MM:SS` on the server; empty on an older backend.
  final String generatedAt;

  /// The server's today (site timezone), `YYYY-MM-DD`.
  final String today;
  final RevenueFilters filters;

  /// Today / yesterday / last 7 days / month to date. Independent of the
  /// selected dates; follows the branch.
  final RevenueSnapshot snapshot;

  /// Figures for the selected range.
  final RevenueSummary summary;

  /// `day`, `week` or `month`: the width of each [trend] bucket.
  final String granularity;
  final List<RevenueTrendPoint> trend;
  final List<RevenueSourceRow> bySource;
  final List<RevenuePaymentRow> byPayment;
  final List<RevenueBranchRow> byBranch;
  final List<RevenueHourRow> byHour;
  final RevenueFulfilment fulfilment;
  final List<RevenueProductRow> topProducts;
  final List<RevenueB2bCustomerRow> topB2bCustomers;

  /// True when the payload carried no keys at all.
  final bool isEmpty;

  const RevenueDashboard({
    this.generatedAt = '',
    this.today = '',
    this.filters = const RevenueFilters(),
    this.snapshot = const RevenueSnapshot(),
    this.summary = const RevenueSummary(),
    this.granularity = 'day',
    this.trend = const [],
    this.bySource = const [],
    this.byPayment = const [],
    this.byBranch = const [],
    this.byHour = const [],
    this.fulfilment = const RevenueFulfilment(),
    this.topProducts = const [],
    this.topB2bCustomers = const [],
    this.isEmpty = false,
  });

  factory RevenueDashboard.fromJson(JsonMap j) => RevenueDashboard(
    generatedAt: ReportJson.str(j['generated_at']),
    today: ReportJson.str(j['today']),
    filters: RevenueFilters.fromJson(ReportJson.map(j['filters'])),
    snapshot: RevenueSnapshot.fromJson(ReportJson.map(j['snapshot'])),
    summary: RevenueSummary.fromJson(ReportJson.map(j['summary'])),
    granularity: ReportJson.str(j['granularity'], 'day'),
    trend: ReportJson.listOf(j['trend'], RevenueTrendPoint.fromJson),
    bySource: ReportJson.listOf(j['by_source'], RevenueSourceRow.fromJson),
    byPayment: ReportJson.listOf(j['by_payment'], RevenuePaymentRow.fromJson),
    byBranch: ReportJson.listOf(j['by_branch'], RevenueBranchRow.fromJson),
    byHour: ReportJson.listOf(j['by_hour'], RevenueHourRow.fromJson),
    fulfilment: RevenueFulfilment.fromJson(ReportJson.map(j['fulfilment'])),
    topProducts: ReportJson.listOf(
      j['top_products'],
      RevenueProductRow.fromJson,
    ),
    topB2bCustomers: ReportJson.listOf(
      j['top_b2b_customers'],
      RevenueB2bCustomerRow.fromJson,
    ),
    isEmpty: j.isEmpty,
  );

  /// Exactly 24 rows, hour 0..23, whatever the payload held: missing hours
  /// read as zero, out-of-range hours are dropped, a repeated hour is summed.
  List<RevenueHourRow> get hourly {
    final orders = List<int>.filled(24, 0);
    final net = List<double>.filled(24, 0);
    for (final r in byHour) {
      if (r.hour < 0 || r.hour > 23) continue;
      orders[r.hour] += r.orders;
      net[r.hour] += r.netSales;
    }
    return [
      for (var h = 0; h < 24; h++)
        RevenueHourRow(hour: h, orders: orders[h], netSales: net[h]),
    ];
  }
}

class RevenueFilters {
  final String dateFrom;
  final String dateTo;

  /// POS Profile name, or null for all branches.
  final String? branch;

  const RevenueFilters({this.dateFrom = '', this.dateTo = '', this.branch});

  factory RevenueFilters.fromJson(JsonMap j) => RevenueFilters(
    dateFrom: ReportJson.str(j['date_from']),
    dateTo: ReportJson.str(j['date_to']),
    branch: ReportJson.strOrNull(j['branch']),
  );
}

// ── Snapshot ──────────────────────────────────────────────────────────────

class RevenueSnapshot {
  /// Compared with the same weekday last week (today - 7), not yesterday.
  final RevenueSnapshotPeriod today;

  /// Compared with yesterday - 7.
  final RevenueSnapshotPeriod yesterday;

  /// today-6 .. today, compared with today-13 .. today-7.
  final RevenueSnapshotPeriod last7Days;

  /// 1st of the month .. today, compared with the same days last month.
  final RevenueSnapshotPeriod monthToDate;

  const RevenueSnapshot({
    this.today = const RevenueSnapshotPeriod(),
    this.yesterday = const RevenueSnapshotPeriod(),
    this.last7Days = const RevenueSnapshotPeriod(),
    this.monthToDate = const RevenueSnapshotPeriod(),
  });

  factory RevenueSnapshot.fromJson(JsonMap j) => RevenueSnapshot(
    today: RevenueSnapshotPeriod.fromJson(ReportJson.map(j['today'])),
    yesterday: RevenueSnapshotPeriod.fromJson(ReportJson.map(j['yesterday'])),
    last7Days: RevenueSnapshotPeriod.fromJson(
      ReportJson.map(j['last_7_days']),
    ),
    monthToDate: RevenueSnapshotPeriod.fromJson(
      ReportJson.map(j['month_to_date']),
    ),
  );
}

/// One snapshot card.
class RevenueSnapshotPeriod {
  final String labelFrom;
  final String labelTo;
  final double netSales;
  final double b2c;
  final double b2b;

  /// Staff + samples.
  final double other;
  final int orders;
  final int b2cOrders;
  final int b2bOrders;

  /// Null with no orders.
  final double? aov;
  final double compareNetSales;
  final int compareOrders;

  /// Net sales vs the comparison window; null when that window was zero.
  final double? changePct;
  final String compareFrom;
  final String compareTo;

  const RevenueSnapshotPeriod({
    this.labelFrom = '',
    this.labelTo = '',
    this.netSales = 0,
    this.b2c = 0,
    this.b2b = 0,
    this.other = 0,
    this.orders = 0,
    this.b2cOrders = 0,
    this.b2bOrders = 0,
    this.aov,
    this.compareNetSales = 0,
    this.compareOrders = 0,
    this.changePct,
    this.compareFrom = '',
    this.compareTo = '',
  });

  factory RevenueSnapshotPeriod.fromJson(JsonMap j) => RevenueSnapshotPeriod(
    labelFrom: ReportJson.str(j['label_from']),
    labelTo: ReportJson.str(j['label_to']),
    netSales: ReportJson.dbl(j['net_sales']),
    b2c: ReportJson.dbl(j['b2c']),
    b2b: ReportJson.dbl(j['b2b']),
    other: ReportJson.dbl(j['other']),
    orders: ReportJson.integer(j['orders']),
    b2cOrders: ReportJson.integer(j['b2c_orders']),
    b2bOrders: ReportJson.integer(j['b2b_orders']),
    aov: ReportJson.dblOrNull(j['aov']),
    compareNetSales: ReportJson.dbl(j['compare_net_sales']),
    compareOrders: ReportJson.integer(j['compare_orders']),
    changePct: ReportJson.dblOrNull(j['change_pct']),
    compareFrom: ReportJson.str(j['compare_from']),
    compareTo: ReportJson.str(j['compare_to']),
  );
}

// ── Summary of the selected range ─────────────────────────────────────────

class RevenueSummary {
  /// SUM(base_net_total): after discounts, before tax and delivery fees.
  final double netSales;
  final double b2c;
  final double b2b;
  final double staff;
  final double samples;

  /// Delivery fees charged to customers.
  final double shippingIncome;

  /// [netSales] + [shippingIncome].
  final double totalRevenue;
  final int orders;
  final int b2cOrders;
  final int b2bOrders;
  final int otherOrders;
  final double? aov;
  final double? b2cAov;
  final double? b2bAov;

  /// b2b / net_sales * 100; null when there were no sales.
  final double? b2bSharePct;

  /// Count of return invoices.
  final int returns;

  /// Positive value of the returns.
  final double returnsValue;
  final int cancelled;
  final double cancelledValue;
  final double discountTotal;
  final int customers;
  final int newCustomers;
  final int days;
  final double dailyAverage;
  final RevenueDay? bestDay;
  final RevenueDay? worstDay;
  final RevenuePrevious previous;

  const RevenueSummary({
    this.netSales = 0,
    this.b2c = 0,
    this.b2b = 0,
    this.staff = 0,
    this.samples = 0,
    this.shippingIncome = 0,
    this.totalRevenue = 0,
    this.orders = 0,
    this.b2cOrders = 0,
    this.b2bOrders = 0,
    this.otherOrders = 0,
    this.aov,
    this.b2cAov,
    this.b2bAov,
    this.b2bSharePct,
    this.returns = 0,
    this.returnsValue = 0,
    this.cancelled = 0,
    this.cancelledValue = 0,
    this.discountTotal = 0,
    this.customers = 0,
    this.newCustomers = 0,
    this.days = 1,
    this.dailyAverage = 0,
    this.bestDay,
    this.worstDay,
    this.previous = const RevenuePrevious(),
  });

  /// Staff + samples, the slice that is neither B2B nor B2C.
  double get other => staff + samples;

  /// Nothing happened in the range at all.
  bool get hasNoActivity =>
      orders == 0 &&
      returns == 0 &&
      cancelled == 0 &&
      netSales == 0 &&
      shippingIncome == 0;

  factory RevenueSummary.fromJson(JsonMap j) => RevenueSummary(
    netSales: ReportJson.dbl(j['net_sales']),
    b2c: ReportJson.dbl(j['b2c']),
    b2b: ReportJson.dbl(j['b2b']),
    staff: ReportJson.dbl(j['staff']),
    samples: ReportJson.dbl(j['samples']),
    shippingIncome: ReportJson.dbl(j['shipping_income']),
    totalRevenue: ReportJson.dbl(j['total_revenue']),
    orders: ReportJson.integer(j['orders']),
    b2cOrders: ReportJson.integer(j['b2c_orders']),
    b2bOrders: ReportJson.integer(j['b2b_orders']),
    otherOrders: ReportJson.integer(j['other_orders']),
    aov: ReportJson.dblOrNull(j['aov']),
    b2cAov: ReportJson.dblOrNull(j['b2c_aov']),
    b2bAov: ReportJson.dblOrNull(j['b2b_aov']),
    b2bSharePct: ReportJson.dblOrNull(j['b2b_share_pct']),
    returns: ReportJson.integer(j['returns']),
    returnsValue: ReportJson.dbl(j['returns_value']),
    cancelled: ReportJson.integer(j['cancelled']),
    cancelledValue: ReportJson.dbl(j['cancelled_value']),
    discountTotal: ReportJson.dbl(j['discount_total']),
    customers: ReportJson.integer(j['customers']),
    newCustomers: ReportJson.integer(j['new_customers']),
    days: ReportJson.integer(j['days'], 1),
    dailyAverage: ReportJson.dbl(j['daily_average']),
    bestDay: RevenueDay.fromJsonOrNull(j['best_day']),
    worstDay: RevenueDay.fromJsonOrNull(j['worst_day']),
    previous: RevenuePrevious.fromJson(ReportJson.map(j['previous'])),
  );
}

/// `best_day` / `worst_day`.
class RevenueDay {
  final String date;
  final double netSales;

  const RevenueDay({this.date = '', this.netSales = 0});

  /// Null for a null / non-map value or a dateless row.
  static RevenueDay? fromJsonOrNull(Object? v) {
    if (v is! Map) return null;
    final j = ReportJson.map(v);
    final date = ReportJson.str(j['date']);
    if (date.isEmpty) return null;
    return RevenueDay(date: date, netSales: ReportJson.dbl(j['net_sales']));
  }
}

/// The same-length window ending the day before `date_from`.
class RevenuePrevious {
  final String dateFrom;
  final String dateTo;
  final double netSales;
  final double b2c;
  final double b2b;
  final int orders;
  final double? changePct;
  final double? b2cChangePct;
  final double? b2bChangePct;
  final double? ordersChangePct;

  const RevenuePrevious({
    this.dateFrom = '',
    this.dateTo = '',
    this.netSales = 0,
    this.b2c = 0,
    this.b2b = 0,
    this.orders = 0,
    this.changePct,
    this.b2cChangePct,
    this.b2bChangePct,
    this.ordersChangePct,
  });

  factory RevenuePrevious.fromJson(JsonMap j) => RevenuePrevious(
    dateFrom: ReportJson.str(j['date_from']),
    dateTo: ReportJson.str(j['date_to']),
    netSales: ReportJson.dbl(j['net_sales']),
    b2c: ReportJson.dbl(j['b2c']),
    b2b: ReportJson.dbl(j['b2b']),
    orders: ReportJson.integer(j['orders']),
    changePct: ReportJson.dblOrNull(j['change_pct']),
    b2cChangePct: ReportJson.dblOrNull(j['b2c_change_pct']),
    b2bChangePct: ReportJson.dblOrNull(j['b2b_change_pct']),
    ordersChangePct: ReportJson.dblOrNull(j['orders_change_pct']),
  );
}

// ── Breakdowns ────────────────────────────────────────────────────────────

/// One bucket of `trend` (day, week start, or month start).
class RevenueTrendPoint {
  final String date;
  final double b2c;
  final double b2b;

  /// Staff + samples.
  final double other;
  final double netSales;
  final int orders;

  const RevenueTrendPoint({
    this.date = '',
    this.b2c = 0,
    this.b2b = 0,
    this.other = 0,
    this.netSales = 0,
    this.orders = 0,
  });

  factory RevenueTrendPoint.fromJson(JsonMap j) => RevenueTrendPoint(
    date: ReportJson.str(j['date']),
    b2c: ReportJson.dbl(j['b2c']),
    b2b: ReportJson.dbl(j['b2b']),
    other: ReportJson.dbl(j['other']),
    netSales: ReportJson.dbl(j['net_sales']),
    orders: ReportJson.integer(j['orders']),
  );
}

/// `by_source`: [source] is `pos`, `woo`, `talabat`, `partner`, `b2b`,
/// `staff` or `samples` (unknown keys pass through).
class RevenueSourceRow {
  final String source;
  final double netSales;
  final int orders;
  final double? sharePct;

  const RevenueSourceRow({
    required this.source,
    this.netSales = 0,
    this.orders = 0,
    this.sharePct,
  });

  factory RevenueSourceRow.fromJson(JsonMap j) => RevenueSourceRow(
    source: ReportJson.str(j['source']),
    netSales: ReportJson.dbl(j['net_sales']),
    orders: ReportJson.integer(j['orders']),
    sharePct: ReportJson.dblOrNull(j['share_pct']),
  );
}

/// `by_payment`: [method] is the raw `custom_payment_method` ("Cash",
/// "Instapay", ... or "Unspecified").
class RevenuePaymentRow {
  final String method;
  final double netSales;
  final int orders;
  final double? sharePct;

  const RevenuePaymentRow({
    required this.method,
    this.netSales = 0,
    this.orders = 0,
    this.sharePct,
  });

  factory RevenuePaymentRow.fromJson(JsonMap j) => RevenuePaymentRow(
    method: ReportJson.str(j['method']),
    netSales: ReportJson.dbl(j['net_sales']),
    orders: ReportJson.integer(j['orders']),
    sharePct: ReportJson.dblOrNull(j['share_pct']),
  );
}

/// `by_branch`: [branch] is the POS Profile, or "(No Profile)".
class RevenueBranchRow {
  final String branch;
  final double netSales;
  final double b2c;
  final double b2b;
  final int orders;
  final double? sharePct;

  const RevenueBranchRow({
    required this.branch,
    this.netSales = 0,
    this.b2c = 0,
    this.b2b = 0,
    this.orders = 0,
    this.sharePct,
  });

  factory RevenueBranchRow.fromJson(JsonMap j) => RevenueBranchRow(
    branch: ReportJson.str(j['branch']),
    netSales: ReportJson.dbl(j['net_sales']),
    b2c: ReportJson.dbl(j['b2c']),
    b2b: ReportJson.dbl(j['b2b']),
    orders: ReportJson.integer(j['orders']),
    sharePct: ReportJson.dblOrNull(j['share_pct']),
  );
}

/// `by_hour`: HOUR(posting_time) of non-return invoices.
class RevenueHourRow {
  final int hour;
  final int orders;
  final double netSales;

  const RevenueHourRow({required this.hour, this.orders = 0, this.netSales = 0});

  factory RevenueHourRow.fromJson(JsonMap j) => RevenueHourRow(
    hour: ReportJson.integer(j['hour'], -1),
    orders: ReportJson.integer(j['orders']),
    netSales: ReportJson.dbl(j['net_sales']),
  );
}

class RevenueFulfilment {
  final int deliveryOrders;
  final int pickupOrders;

  const RevenueFulfilment({this.deliveryOrders = 0, this.pickupOrders = 0});

  int get total => deliveryOrders + pickupOrders;

  factory RevenueFulfilment.fromJson(JsonMap j) => RevenueFulfilment(
    deliveryOrders: ReportJson.integer(j['delivery_orders']),
    pickupOrders: ReportJson.integer(j['pickup_orders']),
  );
}

class RevenueProductRow {
  final String itemCode;
  final String itemName;
  final double qty;
  final double netSales;

  const RevenueProductRow({
    this.itemCode = '',
    this.itemName = '',
    this.qty = 0,
    this.netSales = 0,
  });

  String get displayName => itemName.isNotEmpty ? itemName : itemCode;

  factory RevenueProductRow.fromJson(JsonMap j) => RevenueProductRow(
    itemCode: ReportJson.str(j['item_code']),
    itemName: ReportJson.str(j['item_name']),
    qty: ReportJson.dbl(j['qty']),
    netSales: ReportJson.dbl(j['net_sales']),
  );
}

class RevenueB2bCustomerRow {
  final String customer;
  final String customerName;
  final double netSales;
  final int orders;

  const RevenueB2bCustomerRow({
    this.customer = '',
    this.customerName = '',
    this.netSales = 0,
    this.orders = 0,
  });

  String get displayName => customerName.isNotEmpty ? customerName : customer;

  factory RevenueB2bCustomerRow.fromJson(JsonMap j) => RevenueB2bCustomerRow(
    customer: ReportJson.str(j['customer']),
    customerName: ReportJson.str(j['customer_name']),
    netSales: ReportJson.dbl(j['net_sales']),
    orders: ReportJson.integer(j['orders']),
  );
}
