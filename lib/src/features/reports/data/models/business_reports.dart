import 'package:flutter/foundation.dart';

import 'report_json.dart';

// Models for `jarz_pos.api.business_reports.*` (reports overhaul, spec B1–B4).
//
// Hand-written on purpose (no Freezed / json_serializable): every field is
// read through [ReportJson], so a missing key, a null or a number sent as a
// string falls back to a neutral value instead of throwing.

// ── B1 · get_unit_economics ───────────────────────────────────────────────

/// The owner-supplied inputs to the unit-economics model. None of these are
/// booked in the ledger: ad spend and extra fixed cost are monthly estimates,
/// and the two percentages are the payment / marketplace fee rates.
///
/// Value-comparable so it can be part of a provider family key.
@immutable
class UnitEconomicsInputs {
  final double adSpend;
  final double kashierPct;
  final double talabatPct;
  final double extraFixed;

  const UnitEconomicsInputs({
    this.adSpend = 0,
    this.kashierPct = 3,
    this.talabatPct = 30,
    this.extraFixed = 0,
  });

  /// Request params, in the backend's names.
  ///
  /// Sent as strings: the whitelisted method annotates them as `str`.
  Map<String, dynamic> toParams() => {
    'ad_spend': _numParam(adSpend),
    'kashier_pct': _numParam(kashierPct),
    'talabat_pct': _numParam(talabatPct),
    'extra_fixed': _numParam(extraFixed),
  };

  static String _numParam(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  UnitEconomicsInputs copyWith({
    double? adSpend,
    double? kashierPct,
    double? talabatPct,
    double? extraFixed,
  }) => UnitEconomicsInputs(
    adSpend: adSpend ?? this.adSpend,
    kashierPct: kashierPct ?? this.kashierPct,
    talabatPct: talabatPct ?? this.talabatPct,
    extraFixed: extraFixed ?? this.extraFixed,
  );

  @override
  bool operator ==(Object other) =>
      other is UnitEconomicsInputs &&
      other.adSpend == adSpend &&
      other.kashierPct == kashierPct &&
      other.talabatPct == talabatPct &&
      other.extraFixed == extraFixed;

  @override
  int get hashCode => Object.hash(adSpend, kashierPct, talabatPct, extraFixed);
}

class UnitEconomics {
  /// Echo of the request, including the inputs used.
  final JsonMap filters;
  final double revenue;
  final int orders;
  final double avgOrderValue;
  final UnitEconomicsVariableCosts variableCosts;
  final double contribution;
  final double contributionMarginPct;
  final UnitEconomicsFixedCosts fixedCosts;
  final double netProfit;

  /// Null when the contribution margin is ≤ 0 (no break-even exists).
  final double? breakEvenRevenue;
  final int? breakEvenOrders;

  /// break-even revenue − revenue; ≤ 0 means already past break-even.
  final double? gapToBreakEven;
  final UnitEconomicsPerOrder perOrder;

  /// Server-written caveat CODES (which figures are estimates), e.g.
  /// `kashier_fees_estimated`. Localised by the screen.
  final List<String> notes;

  /// The raw figures the estimates were built from (`basis` block):
  /// kashier_receipts, talabat_sales, talabat_orders, shipping_income,
  /// shipping_expense, stock_adjustment, booked_partner_commission,
  /// booked_kashier_fees, recurring_due, cogs_coverage_pct, ledger_net_profit.
  final JsonMap basis;

  const UnitEconomics({
    this.filters = const {},
    this.revenue = 0,
    this.orders = 0,
    this.avgOrderValue = 0,
    this.variableCosts = const UnitEconomicsVariableCosts(),
    this.contribution = 0,
    this.contributionMarginPct = 0,
    this.fixedCosts = const UnitEconomicsFixedCosts(),
    this.netProfit = 0,
    this.breakEvenRevenue,
    this.breakEvenOrders,
    this.gapToBreakEven,
    this.perOrder = const UnitEconomicsPerOrder(),
    this.notes = const [],
    this.basis = const {},
  });

  /// A numeric `basis` value, or null when the server did not send it.
  double? basisValue(String key) => ReportJson.dblOrNull(basis[key]);

  bool get isEmpty => revenue == 0 && orders == 0 && variableCosts.total == 0 && fixedCosts.total == 0;

  factory UnitEconomics.fromJson(JsonMap j) => UnitEconomics(
    filters: ReportJson.map(j['filters']),
    revenue: ReportJson.dbl(j['revenue']),
    orders: ReportJson.integer(j['orders']),
    avgOrderValue: ReportJson.dbl(j['avg_order_value']),
    variableCosts: UnitEconomicsVariableCosts.fromJson(
      ReportJson.map(j['variable_costs']),
    ),
    contribution: ReportJson.dbl(j['contribution']),
    contributionMarginPct: ReportJson.dbl(j['contribution_margin_pct']),
    fixedCosts: UnitEconomicsFixedCosts.fromJson(
      ReportJson.map(j['fixed_costs']),
    ),
    netProfit: ReportJson.dbl(j['net_profit']),
    breakEvenRevenue: ReportJson.dblOrNull(j['break_even_revenue']),
    breakEvenOrders: ReportJson.intOrNull(j['break_even_orders']),
    gapToBreakEven: ReportJson.dblOrNull(j['gap_to_break_even']),
    perOrder: UnitEconomicsPerOrder.fromJson(ReportJson.map(j['per_order'])),
    notes: ReportJson.strings(j['notes']),
    basis: ReportJson.map(j['basis']),
  );
}

class UnitEconomicsVariableCosts {
  final double cogs;
  final double shippingNet;
  final double kashierFees;
  final double talabatCommission;
  final double total;

  const UnitEconomicsVariableCosts({
    this.cogs = 0,
    this.shippingNet = 0,
    this.kashierFees = 0,
    this.talabatCommission = 0,
    this.total = 0,
  });

  factory UnitEconomicsVariableCosts.fromJson(JsonMap j) =>
      UnitEconomicsVariableCosts(
        cogs: ReportJson.dbl(j['cogs']),
        shippingNet: ReportJson.dbl(j['shipping_net']),
        kashierFees: ReportJson.dbl(j['kashier_fees']),
        talabatCommission: ReportJson.dbl(j['talabat_commission']),
        total: ReportJson.dbl(j['total']),
      );
}

class UnitEconomicsFixedCosts {
  final double recurring;
  final double other;
  final double adSpend;
  final double extraFixed;
  final double total;

  const UnitEconomicsFixedCosts({
    this.recurring = 0,
    this.other = 0,
    this.adSpend = 0,
    this.extraFixed = 0,
    this.total = 0,
  });

  factory UnitEconomicsFixedCosts.fromJson(JsonMap j) =>
      UnitEconomicsFixedCosts(
        recurring: ReportJson.dbl(j['recurring']),
        other: ReportJson.dbl(j['other']),
        adSpend: ReportJson.dbl(j['ad_spend']),
        extraFixed: ReportJson.dbl(j['extra_fixed']),
        total: ReportJson.dbl(j['total']),
      );
}

class UnitEconomicsPerOrder {
  final double revenue;
  final double cogs;
  final double shipping;
  final double fees;
  final double contribution;

  const UnitEconomicsPerOrder({
    this.revenue = 0,
    this.cogs = 0,
    this.shipping = 0,
    this.fees = 0,
    this.contribution = 0,
  });

  factory UnitEconomicsPerOrder.fromJson(JsonMap j) => UnitEconomicsPerOrder(
    revenue: ReportJson.dbl(j['revenue']),
    cogs: ReportJson.dbl(j['cogs']),
    shipping: ReportJson.dbl(j['shipping']),
    fees: ReportJson.dbl(j['fees']),
    contribution: ReportJson.dbl(j['contribution']),
  );
}

// ── B2 · get_promo_performance ────────────────────────────────────────────

class PromoPerformance {
  final JsonMap filters;
  final PromoPerformanceTotals totals;
  final List<PromoCodeRow> codes;

  const PromoPerformance({
    this.filters = const {},
    this.totals = const PromoPerformanceTotals(),
    this.codes = const [],
  });

  factory PromoPerformance.fromJson(JsonMap j) => PromoPerformance(
    filters: ReportJson.map(j['filters']),
    totals: PromoPerformanceTotals.fromJson(ReportJson.map(j['totals'])),
    codes: ReportJson.listOf(j['codes'], PromoCodeRow.fromJson),
  );

  bool get isEmpty => totals.ordersWithPromo == 0 && codes.isEmpty;

  /// `filters.scope` (the backend sends `b2c`: consumer orders only).
  String get scope => ReportJson.str(filters['scope']);
}

class PromoPerformanceTotals {
  final int ordersWithPromo;
  final int ordersTotal;
  final double discountTotal;
  final double promoRevenue;
  final double promoAov;
  final double nonPromoAov;
  final int newCustomersViaPromo;

  const PromoPerformanceTotals({
    this.ordersWithPromo = 0,
    this.ordersTotal = 0,
    this.discountTotal = 0,
    this.promoRevenue = 0,
    this.promoAov = 0,
    this.nonPromoAov = 0,
    this.newCustomersViaPromo = 0,
  });

  /// Share of orders that used a code, 0–100; 0 when there were no orders.
  double get promoOrderSharePct =>
      ordersTotal == 0 ? 0 : ordersWithPromo * 100 / ordersTotal;

  factory PromoPerformanceTotals.fromJson(JsonMap j) => PromoPerformanceTotals(
    ordersWithPromo: ReportJson.integer(j['orders_with_promo']),
    ordersTotal: ReportJson.integer(j['orders_total']),
    discountTotal: ReportJson.dbl(j['discount_total']),
    promoRevenue: ReportJson.dbl(j['promo_revenue']),
    promoAov: ReportJson.dbl(j['promo_aov']),
    nonPromoAov: ReportJson.dbl(j['non_promo_aov']),
    newCustomersViaPromo: ReportJson.integer(j['new_customers_via_promo']),
  );
}

class PromoCodeRow {
  final String code;
  final int orders;
  final double discount;
  final double revenue;
  final double aov;
  final int newCustomers;

  /// Customers who ordered again later without a promo.
  final int repeatAfter;

  const PromoCodeRow({
    required this.code,
    this.orders = 0,
    this.discount = 0,
    this.revenue = 0,
    this.aov = 0,
    this.newCustomers = 0,
    this.repeatAfter = 0,
  });

  factory PromoCodeRow.fromJson(JsonMap j) => PromoCodeRow(
    code: ReportJson.str(j['code']),
    orders: ReportJson.integer(j['orders']),
    discount: ReportJson.dbl(j['discount']),
    revenue: ReportJson.dbl(j['revenue']),
    aov: ReportJson.dbl(j['aov']),
    newCustomers: ReportJson.integer(j['new_customers']),
    repeatAfter: ReportJson.integer(j['repeat_after']),
  );
}

// ── B3 · get_stock_adjustments ────────────────────────────────────────────

/// Waste and stock adjustments, valued at `stock_value_difference`. Losses
/// are reported as positive [StockAdjustmentsTotals.lossValue]; entry
/// `value`s are signed (negative = stock value lost).
class StockAdjustments {
  final JsonMap filters;
  final StockAdjustmentsTotals totals;
  final List<StockAdjustmentType> byType;
  final List<StockAdjustmentBranch> byBranch;

  /// Worst 50 items.
  final List<StockAdjustmentItem> byItem;

  /// Newest 200 entries.
  final List<StockAdjustmentEntry> entries;

  const StockAdjustments({
    this.filters = const {},
    this.totals = const StockAdjustmentsTotals(),
    this.byType = const [],
    this.byBranch = const [],
    this.byItem = const [],
    this.entries = const [],
  });

  factory StockAdjustments.fromJson(JsonMap j) => StockAdjustments(
    filters: ReportJson.map(j['filters']),
    totals: StockAdjustmentsTotals.fromJson(ReportJson.map(j['totals'])),
    byType: ReportJson.listOf(j['by_type'], StockAdjustmentType.fromJson),
    byBranch: ReportJson.listOf(j['by_branch'], StockAdjustmentBranch.fromJson),
    byItem: ReportJson.listOf(j['by_item'], StockAdjustmentItem.fromJson),
    entries: ReportJson.listOf(j['entries'], StockAdjustmentEntry.fromJson),
  );

  bool get isEmpty => totals.entries == 0 && entries.isEmpty;
}

class StockAdjustmentsTotals {
  final double lossValue;
  final double gainValue;
  final double netValue;
  final int entries;

  const StockAdjustmentsTotals({
    this.lossValue = 0,
    this.gainValue = 0,
    this.netValue = 0,
    this.entries = 0,
  });

  factory StockAdjustmentsTotals.fromJson(JsonMap j) => StockAdjustmentsTotals(
    lossValue: ReportJson.dbl(j['loss_value']),
    gainValue: ReportJson.dbl(j['gain_value']),
    netValue: ReportJson.dbl(j['net_value']),
    entries: ReportJson.integer(j['entries']),
  );
}

class StockAdjustmentType {
  /// e.g. `Stock Reconciliation`, `Material Issue` (backend text).
  final String type;
  final double value;
  final int entries;

  const StockAdjustmentType({required this.type, this.value = 0, this.entries = 0});

  factory StockAdjustmentType.fromJson(JsonMap j) => StockAdjustmentType(
    type: ReportJson.str(j['type']),
    value: ReportJson.dbl(j['value']),
    entries: ReportJson.integer(j['entries']),
  );
}

class StockAdjustmentBranch {
  final String branch;
  final String warehouse;
  final double lossValue;
  final double gainValue;
  final double netValue;

  const StockAdjustmentBranch({
    required this.branch,
    this.warehouse = '',
    this.lossValue = 0,
    this.gainValue = 0,
    this.netValue = 0,
  });

  /// Branch name, or the warehouse when the warehouse maps to no branch.
  String get displayName => branch.isNotEmpty ? branch : warehouse;

  factory StockAdjustmentBranch.fromJson(JsonMap j) => StockAdjustmentBranch(
    branch: ReportJson.str(j['branch']),
    warehouse: ReportJson.str(j['warehouse']),
    lossValue: ReportJson.dbl(j['loss_value']),
    gainValue: ReportJson.dbl(j['gain_value']),
    netValue: ReportJson.dbl(j['net_value']),
  );
}

class StockAdjustmentItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final String uom;
  final double value;

  const StockAdjustmentItem({
    required this.itemCode,
    this.itemName = '',
    this.qty = 0,
    this.uom = '',
    this.value = 0,
  });

  String get displayName => itemName.isNotEmpty ? itemName : itemCode;

  factory StockAdjustmentItem.fromJson(JsonMap j) => StockAdjustmentItem(
    itemCode: ReportJson.str(j['item_code']),
    itemName: ReportJson.str(j['item_name']),
    qty: ReportJson.dbl(j['qty']),
    uom: ReportJson.str(j['uom']),
    value: ReportJson.dbl(j['value']),
  );
}

class StockAdjustmentEntry {
  final String voucherType;
  final String voucherNo;

  /// `YYYY-MM-DD` as sent.
  final String postingDate;
  final String warehouse;
  final String itemCode;
  final double qty;
  final double value;
  final String remarks;

  const StockAdjustmentEntry({
    required this.voucherType,
    required this.voucherNo,
    this.postingDate = '',
    this.warehouse = '',
    this.itemCode = '',
    this.qty = 0,
    this.value = 0,
    this.remarks = '',
  });

  DateTime? get postingDay => ReportJson.dateTimeOrNull(postingDate);

  factory StockAdjustmentEntry.fromJson(JsonMap j) => StockAdjustmentEntry(
    voucherType: ReportJson.str(j['voucher_type']),
    voucherNo: ReportJson.str(j['voucher_no']),
    postingDate: ReportJson.str(j['posting_date']),
    warehouse: ReportJson.str(j['warehouse']),
    itemCode: ReportJson.str(j['item_code']),
    qty: ReportJson.dbl(j['qty']),
    value: ReportJson.dbl(j['value']),
    remarks: ReportJson.str(j['remarks']),
  );
}

// ── B4 · get_labour_cost ──────────────────────────────────────────────────

/// Where the labour cost figure came from — tells the screen how much to
/// trust it. Unknown values map to [estimate].
enum LabourCostBasis {
  salarySlips,
  recurringExpense,
  estimate;

  static LabourCostBasis parse(Object? v) =>
      switch (ReportJson.str(v).toLowerCase()) {
        'salary_slips' => LabourCostBasis.salarySlips,
        'recurring_expense' => LabourCostBasis.recurringExpense,
        _ => LabourCostBasis.estimate,
      };
}

class LabourCost {
  final JsonMap filters;
  final LabourCostTotals totals;
  final List<LabourCostBranch> branches;
  final List<LabourCostEmployee> employees;
  final LabourCostBasis costBasis;

  const LabourCost({
    this.filters = const {},
    this.totals = const LabourCostTotals(),
    this.branches = const [],
    this.employees = const [],
    this.costBasis = LabourCostBasis.estimate,
  });

  factory LabourCost.fromJson(JsonMap j) => LabourCost(
    filters: ReportJson.map(j['filters']),
    totals: LabourCostTotals.fromJson(ReportJson.map(j['totals'])),
    branches: ReportJson.listOf(j['branches'], LabourCostBranch.fromJson),
    employees: ReportJson.listOf(j['employees'], LabourCostEmployee.fromJson),
    costBasis: LabourCostBasis.parse(j['cost_basis']),
  );

  bool get isEmpty => totals.labourCost == 0 && totals.sales == 0 && employees.isEmpty;
}

class LabourCostTotals {
  final double labourCost;
  final double sales;

  /// labour ÷ sales × 100; null when there were no sales.
  final double? labourPct;
  final double hours;
  final double? salesPerHour;
  final int headcount;

  const LabourCostTotals({
    this.labourCost = 0,
    this.sales = 0,
    this.labourPct,
    this.hours = 0,
    this.salesPerHour,
    this.headcount = 0,
  });

  factory LabourCostTotals.fromJson(JsonMap j) => LabourCostTotals(
    labourCost: ReportJson.dbl(j['labour_cost']),
    sales: ReportJson.dbl(j['sales']),
    labourPct: ReportJson.dblOrNull(j['labour_pct']),
    hours: ReportJson.dbl(j['hours']),
    salesPerHour: ReportJson.dblOrNull(j['sales_per_hour']),
    headcount: ReportJson.integer(j['headcount']),
  );
}

class LabourCostBranch {
  final String branch;

  /// The attendance shift location; used as the label when [branch] is empty.
  final String shiftLocation;
  final double labourCost;
  final double sales;
  final double? labourPct;
  final double hours;
  final int headcount;

  const LabourCostBranch({
    required this.branch,
    this.shiftLocation = '',
    this.labourCost = 0,
    this.sales = 0,
    this.labourPct,
    this.hours = 0,
    this.headcount = 0,
  });

  /// Branch, else shift location, else null (the screen shows "Unassigned").
  String? get label => branch.isNotEmpty
      ? branch
      : (shiftLocation.isNotEmpty ? shiftLocation : null);

  factory LabourCostBranch.fromJson(JsonMap j) => LabourCostBranch(
    branch: ReportJson.str(j['branch']),
    shiftLocation: ReportJson.str(j['shift_location']),
    labourCost: ReportJson.dbl(j['labour_cost']),
    sales: ReportJson.dbl(j['sales']),
    labourPct: ReportJson.dblOrNull(j['labour_pct']),
    hours: ReportJson.dbl(j['hours']),
    headcount: ReportJson.integer(j['headcount']),
  );
}

class LabourCostEmployee {
  /// Employee id (e.g. `HR-EMP-0001`).
  final String employee;

  /// Display name (`name` in the payload).
  final String name;
  final String branch;

  /// The attendance shift location; used when [branch] is empty.
  final String shiftLocation;
  final double hours;
  final int days;
  final double cost;

  const LabourCostEmployee({
    required this.employee,
    this.name = '',
    this.branch = '',
    this.shiftLocation = '',
    this.hours = 0,
    this.days = 0,
    this.cost = 0,
  });

  String get displayName => name.isNotEmpty ? name : employee;

  /// Branch, else shift location, else null (the screen shows "Unassigned").
  String? get branchLabel => branch.isNotEmpty
      ? branch
      : (shiftLocation.isNotEmpty ? shiftLocation : null);

  factory LabourCostEmployee.fromJson(JsonMap j) => LabourCostEmployee(
    employee: ReportJson.str(j['employee']),
    name: ReportJson.str(j['name']),
    branch: ReportJson.str(j['branch']),
    shiftLocation: ReportJson.str(j['shift_location']),
    hours: ReportJson.dbl(j['hours']),
    days: ReportJson.integer(j['days']),
    cost: ReportJson.dbl(j['cost']),
  );
}
