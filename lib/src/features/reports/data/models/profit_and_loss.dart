import 'report_json.dart';

/// The Profit & Loss report (`jarz_pos.api.financial_report.get_profit_and_loss`).
///
/// Every figure is read from the General Ledger on the server, and the payload
/// carries its own reconciliation, so the screen never recomputes money — it
/// only lays out what the backend already proved adds up.
class ProfitAndLoss {
  final String dateFrom;
  final String dateTo;

  /// `day`, `week` or `month` — the width of each [trend] bucket.
  final String granularity;
  final PnlSummary summary;
  final List<PnlChannel> channels;
  final PnlCostOfSales costOfSales;
  final PnlShipping shipping;
  final PnlRecurring recurring;
  final double otherExpensesTotal;
  final List<PnlAccountRow> otherExpenses;
  final List<PnlTrendPoint> trend;
  final PnlReconciliation reconciliation;
  final PnlDataQuality dataQuality;

  const ProfitAndLoss({
    this.dateFrom = '',
    this.dateTo = '',
    this.granularity = 'day',
    this.summary = const PnlSummary(),
    this.channels = const [],
    this.costOfSales = const PnlCostOfSales(),
    this.shipping = const PnlShipping(),
    this.recurring = const PnlRecurring(),
    this.otherExpensesTotal = 0,
    this.otherExpenses = const [],
    this.trend = const [],
    this.reconciliation = const PnlReconciliation(),
    this.dataQuality = const PnlDataQuality(),
  });

  factory ProfitAndLoss.fromJson(JsonMap json) {
    final period = _map(json['period']);
    final other = _map(json['other_expenses']);
    return ProfitAndLoss(
      dateFrom: _s(period['date_from']),
      dateTo: _s(period['date_to']),
      granularity: _s(period['granularity'], 'day'),
      summary: PnlSummary.fromJson(_map(json['summary'])),
      channels: _list(json['channels']).map(PnlChannel.fromJson).toList(),
      costOfSales: PnlCostOfSales.fromJson(_map(json['cost_of_sales'])),
      shipping: PnlShipping.fromJson(_map(json['shipping'])),
      recurring: PnlRecurring.fromJson(_map(json['recurring'])),
      otherExpensesTotal: _d(other['total']),
      otherExpenses: _list(other['rows']).map(PnlAccountRow.fromJson).toList(),
      trend: _list(json['trend']).map(PnlTrendPoint.fromJson).toList(),
      reconciliation: PnlReconciliation.fromJson(_map(json['reconciliation'])),
      dataQuality: PnlDataQuality.fromJson(_map(json['data_quality'])),
    );
  }

  PnlChannel channel(String key) => channels.firstWhere(
    (c) => c.channel == key,
    orElse: () => PnlChannel(channel: key),
  );
}

class PnlSummary {
  final double totalRevenue;
  final double sales;
  final double shippingIncome;
  final double b2bRevenue;
  final double b2cRevenue;
  final double costOfSales;
  final double grossProfit;
  final double grossMarginPct;
  final double shippingExpense;
  final double shippingNet;
  final double recurringExpenses;
  final double otherExpenses;
  final double operatingExpenses;
  final double totalExpenses;
  final double netProfit;
  final double netMarginPct;
  final int orders;

  const PnlSummary({
    this.totalRevenue = 0,
    this.sales = 0,
    this.shippingIncome = 0,
    this.b2bRevenue = 0,
    this.b2cRevenue = 0,
    this.costOfSales = 0,
    this.grossProfit = 0,
    this.grossMarginPct = 0,
    this.shippingExpense = 0,
    this.shippingNet = 0,
    this.recurringExpenses = 0,
    this.otherExpenses = 0,
    this.operatingExpenses = 0,
    this.totalExpenses = 0,
    this.netProfit = 0,
    this.netMarginPct = 0,
    this.orders = 0,
  });

  factory PnlSummary.fromJson(JsonMap j) => PnlSummary(
    totalRevenue: _d(j['total_revenue']),
    sales: _d(j['sales']),
    shippingIncome: _d(j['shipping_income']),
    b2bRevenue: _d(j['b2b_revenue']),
    b2cRevenue: _d(j['b2c_revenue']),
    costOfSales: _d(j['cost_of_sales']),
    grossProfit: _d(j['gross_profit']),
    grossMarginPct: _d(j['gross_margin_pct']),
    shippingExpense: _d(j['shipping_expense']),
    shippingNet: _d(j['shipping_net']),
    recurringExpenses: _d(j['recurring_expenses']),
    otherExpenses: _d(j['other_expenses']),
    operatingExpenses: _d(j['operating_expenses']),
    totalExpenses: _d(j['total_expenses']),
    netProfit: _d(j['net_profit']),
    netMarginPct: _d(j['net_margin_pct']),
    orders: _i(j['orders']),
  );
}

/// One sales channel: `b2c`, `b2b`, `staff`, `samples`, or `adjustments` (ledger
/// sales no invoice explains, e.g. a manual journal to Sales).
class PnlChannel {
  final String channel;
  final double sales;
  final double shippingIncome;
  final double revenue;
  final int orders;
  final int returns;
  final double returnsValue;
  final double sharePct;

  const PnlChannel({
    required this.channel,
    this.sales = 0,
    this.shippingIncome = 0,
    this.revenue = 0,
    this.orders = 0,
    this.returns = 0,
    this.returnsValue = 0,
    this.sharePct = 0,
  });

  factory PnlChannel.fromJson(JsonMap j) => PnlChannel(
    channel: _s(j['channel']),
    sales: _d(j['sales']),
    shippingIncome: _d(j['shipping_income']),
    revenue: _d(j['revenue']),
    orders: _i(j['orders']),
    returns: _i(j['returns']),
    returnsValue: _d(j['returns_value']),
    sharePct: _d(j['share_pct']),
  );
}

class PnlAccountRow {
  final String account;
  final String label;
  final double amount;

  const PnlAccountRow({this.account = '', this.label = '', this.amount = 0});

  factory PnlAccountRow.fromJson(JsonMap j) => PnlAccountRow(
    account: _s(j['account']),
    label: _s(j['label'], _s(j['account'])),
    amount: _d(j['amount']),
  );
}

class PnlCostOfSales {
  final double total;
  final double costOfGoods;
  final List<PnlAccountRow> rows;

  const PnlCostOfSales({
    this.total = 0,
    this.costOfGoods = 0,
    this.rows = const [],
  });

  factory PnlCostOfSales.fromJson(JsonMap j) => PnlCostOfSales(
    total: _d(j['total']),
    costOfGoods: _d(j['cost_of_goods']),
    rows: _list(j['rows']).map(PnlAccountRow.fromJson).toList(),
  );
}

class PnlShipping {
  final double income;
  final double expense;
  final double net;
  final double expenseOrderBasis;
  final double incomeInExpenseAccount;
  final int deliveryOrders;
  final int pickupOrders;
  final double incomePerDelivery;
  final double expensePerDelivery;

  const PnlShipping({
    this.income = 0,
    this.expense = 0,
    this.net = 0,
    this.expenseOrderBasis = 0,
    this.incomeInExpenseAccount = 0,
    this.deliveryOrders = 0,
    this.pickupOrders = 0,
    this.incomePerDelivery = 0,
    this.expensePerDelivery = 0,
  });

  factory PnlShipping.fromJson(JsonMap j) => PnlShipping(
    income: _d(j['income']),
    expense: _d(j['expense']),
    net: _d(j['net']),
    expenseOrderBasis: _d(j['expense_order_basis']),
    incomeInExpenseAccount: _d(j['income_in_expense_account']),
    deliveryOrders: _i(j['delivery_orders']),
    pickupOrders: _i(j['pickup_orders']),
    incomePerDelivery: _d(j['income_per_delivery']),
    expensePerDelivery: _d(j['expense_per_delivery']),
  );
}

class PnlRecurringRow {
  final String account;
  final String label;
  final String category;
  final double posted;
  final double due;
  final double remaining;

  const PnlRecurringRow({
    this.account = '',
    this.label = '',
    this.category = '',
    this.posted = 0,
    this.due = 0,
    this.remaining = 0,
  });

  factory PnlRecurringRow.fromJson(JsonMap j) => PnlRecurringRow(
    account: _s(j['account']),
    label: _s(j['label'], _s(j['account'])),
    category: _s(j['category']),
    posted: _d(j['posted']),
    due: _d(j['due']),
    remaining: _d(j['remaining']),
  );
}

class PnlRecurring {
  final double total;
  final double due;
  final List<PnlRecurringRow> rows;

  const PnlRecurring({this.total = 0, this.due = 0, this.rows = const []});

  factory PnlRecurring.fromJson(JsonMap j) => PnlRecurring(
    total: _d(j['total']),
    due: _d(j['due']),
    rows: _list(j['rows']).map(PnlRecurringRow.fromJson).toList(),
  );
}

class PnlTrendPoint {
  final String date;
  final double b2c;
  final double b2b;
  final double staff;
  final double samples;
  final double adjustments;
  final double shippingIncome;
  final double revenue;
  final double costOfSales;
  final double shippingExpense;
  final double recurring;
  final double otherExpenses;
  final double expenses;
  final double netProfit;

  const PnlTrendPoint({
    this.date = '',
    this.b2c = 0,
    this.b2b = 0,
    this.staff = 0,
    this.samples = 0,
    this.adjustments = 0,
    this.shippingIncome = 0,
    this.revenue = 0,
    this.costOfSales = 0,
    this.shippingExpense = 0,
    this.recurring = 0,
    this.otherExpenses = 0,
    this.expenses = 0,
    this.netProfit = 0,
  });

  /// Sales that are neither B2B nor B2C (staff, samples, ledger adjustments).
  double get otherSales => staff + samples + adjustments;

  factory PnlTrendPoint.fromJson(JsonMap j) => PnlTrendPoint(
    date: _s(j['date']),
    b2c: _d(j['b2c']),
    b2b: _d(j['b2b']),
    staff: _d(j['staff']),
    samples: _d(j['samples']),
    adjustments: _d(j['adjustments']),
    shippingIncome: _d(j['shipping_income']),
    revenue: _d(j['revenue']),
    costOfSales: _d(j['cost_of_sales']),
    shippingExpense: _d(j['shipping_expense']),
    recurring: _d(j['recurring']),
    otherExpenses: _d(j['other_expenses']),
    expenses: _d(j['expenses']),
    netProfit: _d(j['net_profit']),
  );
}

class PnlReconciliation {
  final double ledgerNetProfit;
  final double reportNetProfit;
  final double difference;
  final bool matches;
  final List<String> notes;

  const PnlReconciliation({
    this.ledgerNetProfit = 0,
    this.reportNetProfit = 0,
    this.difference = 0,
    this.matches = false,
    this.notes = const [],
  });

  factory PnlReconciliation.fromJson(JsonMap j) => PnlReconciliation(
    ledgerNetProfit: _d(j['ledger_net_profit']),
    reportNetProfit: _d(j['report_net_profit']),
    difference: _d(j['difference']),
    matches: j['matches'] == true,
    notes: _strings(j['notes']),
  );
}

/// How complete the books are for the period. The report can only be as right
/// as the ledger: a month whose stock or courier cost was never posted reads as
/// pure profit, so these are surfaced rather than hidden.
class PnlDataQuality {
  final int orders;
  final int stockPostedOrders;
  final double cogsCoveragePct;
  final double shippingExpenseCoveragePct;
  final List<String> warnings;

  const PnlDataQuality({
    this.orders = 0,
    this.stockPostedOrders = 0,
    this.cogsCoveragePct = 100,
    this.shippingExpenseCoveragePct = 100,
    this.warnings = const [],
  });

  factory PnlDataQuality.fromJson(JsonMap j) => PnlDataQuality(
    orders: _i(j['orders']),
    stockPostedOrders: _i(j['stock_posted_orders']),
    cogsCoveragePct: j.containsKey('cogs_coverage_pct')
        ? _d(j['cogs_coverage_pct'])
        : 100,
    shippingExpenseCoveragePct: j.containsKey('shipping_expense_coverage_pct')
        ? _d(j['shipping_expense_coverage_pct'])
        : 100,
    warnings: _strings(j['warnings']),
  );
}

// ── tolerant JSON readers ─────────────────────────────────────────────────

JsonMap _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

List<JsonMap> _list(Object? v) => v is List
    ? v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
    : const [];

List<String> _strings(Object? v) =>
    v is List ? v.map((e) => '$e').toList() : const [];

double _d(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int _i(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
  return 0;
}

String _s(Object? v, [String fallback = '']) {
  if (v == null) return fallback;
  final s = '$v';
  return s.trim().isEmpty ? fallback : s;
}
