import '../../expenses/models/expense_models.dart' show localizedExpenseLabel;

/// Models for `jarz_pos.api.monthly_expenses.get_monthly_expenses`.
///
/// Hand-written `fromJson`, exactly like `expenses/models/expense_models.dart`:
/// this module deliberately does NOT introduce freezed/json_serializable, so
/// the two finance features stay one style and one review surface.
///
/// Every parser is defensive on purpose. The payload is assembled from a
/// registry, the GL and HRMS, and a field that is absent for one row is normal
/// (a recurring expense with no supplier, an employee with no department), not
/// an error worth failing the whole screen over.

double _num(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _int(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

bool _bool(dynamic value) {
  return value == true || value == 1 || value == '1' || value == 'true';
}

String _str(dynamic value) => (value ?? '').toString();

String? _strOrNull(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

/// The five states the backend reports for a recurring item or a salary row.
///
/// Kept as raw server strings rather than an enum: an unrecognised status still
/// has to render (as itself) instead of crashing the month, and the server owns
/// the vocabulary. [localizedMonthlyExpenseStatus] does the display mapping.
class MonthlyExpenseStatus {
  static const paid = 'Paid';
  static const partial = 'Partial';
  static const unpaid = 'Unpaid';
  static const notDue = 'Not Due';
  static const overpaid = 'Overpaid';

  const MonthlyExpenseStatus._();
}

/// Registry lifecycle status of a `Jarz Recurring Expense`.
class RecurringExpenseLifecycle {
  static const active = 'Active';
  static const paused = 'Paused';
  static const ended = 'Ended';

  const RecurringExpenseLifecycle._();
}

/// One entry of `available_months`.
///
/// The contract froze the *ordering* ("12 months back plus current, newest
/// last") but not the element shape, so both shapes the backend could
/// reasonably send are accepted: a bare `"2026-09"` string, or an object
/// carrying its own label. When only the id arrives the screen formats the
/// label itself from the locale.
class MonthlyExpenseMonthOption {
  final String id;
  final String? label;

  const MonthlyExpenseMonthOption({required this.id, this.label});

  factory MonthlyExpenseMonthOption.fromDynamic(dynamic value) {
    if (value is Map) {
      final json = Map<String, dynamic>.from(value);
      return MonthlyExpenseMonthOption(
        id: _str(json['month'] ?? json['id'] ?? json['value']),
        label: _strOrNull(json['month_label'] ?? json['label']),
      );
    }
    return MonthlyExpenseMonthOption(id: _str(value));
  }

  static List<MonthlyExpenseMonthOption> listFrom(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(MonthlyExpenseMonthOption.fromDynamic)
        .where((m) => m.id.isNotEmpty)
        .toList();
  }
}

/// The month's headline figures. `remaining` is the number the screen leads
/// with — everything else on the header exists to explain it.
class MonthlyExpenseSummary {
  final double runRate;
  final double due;
  final double paid;
  final double remaining;
  final double overpaid;
  final int itemsTotal;
  final int itemsPaid;
  final int itemsPartial;
  final int itemsUnpaid;

  const MonthlyExpenseSummary({
    this.runRate = 0,
    this.due = 0,
    this.paid = 0,
    this.remaining = 0,
    this.overpaid = 0,
    this.itemsTotal = 0,
    this.itemsPaid = 0,
    this.itemsPartial = 0,
    this.itemsUnpaid = 0,
  });

  factory MonthlyExpenseSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MonthlyExpenseSummary();
    return MonthlyExpenseSummary(
      runRate: _num(json['run_rate']),
      due: _num(json['due']),
      paid: _num(json['paid']),
      remaining: _num(json['remaining']),
      overpaid: _num(json['overpaid']),
      itemsTotal: _int(json['items_total']),
      itemsPaid: _int(json['items_paid']),
      itemsPartial: _int(json['items_partial']),
      itemsUnpaid: _int(json['items_unpaid']),
    );
  }
}

/// A `by_category` row. `source` says where the numbers came from (the registry
/// or payroll), which is why the salaries block can appear as a category total
/// without being a registry item.
class MonthlyExpenseCategoryTotal {
  final String category;
  final double due;
  final double paid;
  final double remaining;
  final int count;
  final String source;

  const MonthlyExpenseCategoryTotal({
    required this.category,
    required this.due,
    required this.paid,
    required this.remaining,
    required this.count,
    required this.source,
  });

  factory MonthlyExpenseCategoryTotal.fromJson(Map<String, dynamic> json) {
    return MonthlyExpenseCategoryTotal(
      category: _str(json['category']),
      due: _num(json['due']),
      paid: _num(json['paid']),
      remaining: _num(json['remaining']),
      count: _int(json['count']),
      source: _str(json['source']),
    );
  }
}

/// One submitted `Jarz Expense Request` that paid part or all of a period.
class MonthlyExpensePayment {
  final String name;
  final double amount;
  final DateTime? date;
  final String payingAccount;
  final String payingLabel;
  final String? journalEntry;
  final String? remarks;
  final String? by;

  const MonthlyExpensePayment({
    required this.name,
    required this.amount,
    this.date,
    this.payingAccount = '',
    this.payingLabel = '',
    this.journalEntry,
    this.remarks,
    this.by,
  });

  /// What to show as the source of the money: the server's label when it sent
  /// one, otherwise the raw account, which is never empty for a posted payment.
  String get sourceLabel =>
      payingLabel.trim().isNotEmpty ? payingLabel.trim() : payingAccount;

  factory MonthlyExpensePayment.fromJson(Map<String, dynamic> json) {
    return MonthlyExpensePayment(
      name: _str(json['name']),
      amount: _num(json['amount']),
      date: _date(json['date']),
      payingAccount: _str(json['paying_account']),
      payingLabel: _str(json['paying_label']),
      journalEntry: _strOrNull(json['journal_entry']),
      remarks: _strOrNull(json['remarks']),
      by: _strOrNull(json['by']),
    );
  }

  static List<MonthlyExpensePayment> listFrom(dynamic value) =>
      _maps(value).map(MonthlyExpensePayment.fromJson).toList();
}

/// A single registry item resolved against the selected month.
class RecurringExpenseItem {
  final String name;
  final String expenseName;
  final String category;
  final String status;
  final double amount;
  final String frequency;
  final double monthlyEquivalent;
  final int? dayOfMonth;
  final DateTime? dueDate;
  final String expenseAccount;
  final String expenseAccountLabel;
  final String? costCenter;
  final String? supplier;
  final String? defaultPayingAccount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  final bool dueThisMonth;
  final double dueAmount;
  final double paidAmount;
  final double paidLinked;
  final double paidUnlinked;
  final double remaining;
  final String paymentStatus;

  /// Several items due this month post to the SAME expense account, so ledger
  /// money that did not come through the app cannot be attributed to one of
  /// them. The card says so instead of guessing.
  final bool sharedAccount;

  /// `paid_amount` includes money read out of the GL rather than a payment made
  /// in this app. Surfaced on the card because "paid" then means "the ledger
  /// says so", which is a materially weaker claim than "we paid it here".
  final bool inferred;

  final bool canPay;
  final List<MonthlyExpensePayment> payments;

  const RecurringExpenseItem({
    required this.name,
    required this.expenseName,
    required this.category,
    required this.status,
    required this.amount,
    required this.frequency,
    required this.monthlyEquivalent,
    this.dayOfMonth,
    this.dueDate,
    required this.expenseAccount,
    required this.expenseAccountLabel,
    this.costCenter,
    this.supplier,
    this.defaultPayingAccount,
    this.startDate,
    this.endDate,
    this.notes,
    required this.dueThisMonth,
    required this.dueAmount,
    required this.paidAmount,
    required this.paidLinked,
    required this.paidUnlinked,
    required this.remaining,
    required this.paymentStatus,
    required this.sharedAccount,
    required this.inferred,
    required this.canPay,
    required this.payments,
  });

  bool get isActive => status == RecurringExpenseLifecycle.active;
  bool get isPaused => status == RecurringExpenseLifecycle.paused;
  bool get isEnded => status == RecurringExpenseLifecycle.ended;

  /// The label to put on the card. Falls back to the doc name so a row with a
  /// blank `expense_name` is still identifiable rather than a blank line.
  String get displayName =>
      expenseName.trim().isNotEmpty ? expenseName.trim() : name;

  String get accountDisplayLabel => expenseAccountLabel.trim().isNotEmpty
      ? expenseAccountLabel.trim()
      : expenseAccount;

  factory RecurringExpenseItem.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseItem(
      name: _str(json['name']),
      expenseName: _str(json['expense_name']),
      category: _str(json['category']),
      status: _str(json['status']),
      amount: _num(json['amount']),
      frequency: _str(json['frequency']),
      monthlyEquivalent: _num(json['monthly_equivalent']),
      dayOfMonth: json['day_of_month'] == null
          ? null
          : _int(json['day_of_month']),
      dueDate: _date(json['due_date']),
      expenseAccount: _str(json['expense_account']),
      expenseAccountLabel: _str(json['expense_account_label']),
      costCenter: _strOrNull(json['cost_center']),
      supplier: _strOrNull(json['supplier']),
      defaultPayingAccount: _strOrNull(json['default_paying_account']),
      startDate: _date(json['start_date']),
      endDate: _date(json['end_date']),
      notes: _strOrNull(json['notes']),
      dueThisMonth: _bool(json['due_this_month']),
      dueAmount: _num(json['due_amount']),
      paidAmount: _num(json['paid_amount']),
      paidLinked: _num(json['paid_linked']),
      paidUnlinked: _num(json['paid_unlinked']),
      remaining: _num(json['remaining']),
      paymentStatus: _str(json['payment_status']),
      sharedAccount: _bool(json['shared_account']),
      inferred: _bool(json['inferred']),
      canPay: _bool(json['can_pay']),
      payments: MonthlyExpensePayment.listFrom(json['payments']),
    );
  }

  static List<RecurringExpenseItem> listFrom(dynamic value) =>
      _maps(value).map(RecurringExpenseItem.fromJson).toList();
}

/// One employee's salary for the month.
class SalaryRow {
  final String employee;
  final String employeeName;
  final String? designation;
  final String? department;
  final double base;
  final double variable;
  final double dueAmount;
  final double paidAmount;
  final double remaining;
  final String paymentStatus;

  /// A submitted Salary Slip already exists for this period, so paying here
  /// would double-post. The backend refuses it; the card hides the button.
  final bool hasSalarySlip;

  final bool canPay;
  final List<MonthlyExpensePayment> payments;

  const SalaryRow({
    required this.employee,
    required this.employeeName,
    this.designation,
    this.department,
    required this.base,
    required this.variable,
    required this.dueAmount,
    required this.paidAmount,
    required this.remaining,
    required this.paymentStatus,
    required this.hasSalarySlip,
    required this.canPay,
    required this.payments,
  });

  String get displayName =>
      employeeName.trim().isNotEmpty ? employeeName.trim() : employee;

  factory SalaryRow.fromJson(Map<String, dynamic> json) {
    return SalaryRow(
      employee: _str(json['employee']),
      employeeName: _str(json['employee_name']),
      designation: _strOrNull(json['designation']),
      department: _strOrNull(json['department']),
      base: _num(json['base']),
      variable: _num(json['variable']),
      dueAmount: _num(json['due_amount']),
      paidAmount: _num(json['paid_amount']),
      remaining: _num(json['remaining']),
      paymentStatus: _str(json['payment_status']),
      hasSalarySlip: _bool(json['has_salary_slip']),
      canPay: _bool(json['can_pay']),
      payments: MonthlyExpensePayment.listFrom(json['payments']),
    );
  }
}

/// An employee with no submitted Salary Structure Assignment. Reported as a
/// caveat beside the salaries list, never as a row with a zero in it: a zero
/// would read as "nothing owed", when the truth is "we do not know".
class SalaryGapEmployee {
  final String employee;
  final String employeeName;
  final String? designation;
  final String? department;

  const SalaryGapEmployee({
    required this.employee,
    required this.employeeName,
    this.designation,
    this.department,
  });

  String get displayName =>
      employeeName.trim().isNotEmpty ? employeeName.trim() : employee;

  factory SalaryGapEmployee.fromJson(Map<String, dynamic> json) {
    return SalaryGapEmployee(
      employee: _str(json['employee']),
      employeeName: _str(json['employee_name']),
      designation: _strOrNull(json['designation']),
      department: _strOrNull(json['department']),
    );
  }
}

class PayrollBlock {
  final bool configured;
  final int employeesTotal;
  final int employeesWithStructure;
  final int employeesWithoutStructure;
  final String? salaryAccount;
  final double due;
  final double paid;
  final double remaining;

  /// Salary GL that no row can claim. Salary posts to one account for the whole
  /// company, so it cannot be split per employee — it is reported once, here,
  /// and never folded into a row.
  final double unattributedGl;

  final List<SalaryRow> rows;
  final List<SalaryGapEmployee> missing;

  const PayrollBlock({
    this.configured = false,
    this.employeesTotal = 0,
    this.employeesWithStructure = 0,
    this.employeesWithoutStructure = 0,
    this.salaryAccount,
    this.due = 0,
    this.paid = 0,
    this.remaining = 0,
    this.unattributedGl = 0,
    this.rows = const [],
    this.missing = const [],
  });

  factory PayrollBlock.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PayrollBlock();
    return PayrollBlock(
      configured: _bool(json['configured']),
      employeesTotal: _int(json['employees_total']),
      employeesWithStructure: _int(json['employees_with_structure']),
      employeesWithoutStructure: _int(json['employees_without_structure']),
      salaryAccount: _strOrNull(json['salary_account']),
      due: _num(json['due']),
      paid: _num(json['paid']),
      remaining: _num(json['remaining']),
      unattributedGl: _num(json['unattributed_gl']),
      rows: _maps(json['rows']).map(SalaryRow.fromJson).toList(),
      missing: _maps(json['missing']).map(SalaryGapEmployee.fromJson).toList(),
    );
  }
}

/// A cash-or-bank account the payment can come out of.
///
/// The contract says the backend reuses `expenses._serialize_payment_sources`
/// so the picker matches the ad-hoc expense screen, but declares the field as
/// `type` while that serializer emits `category`. Both are read, so whichever
/// the server actually sends lands in the same place — the alternative is a
/// picker whose every entry says "account".
class MonthlyExpensePaymentSource {
  final String id;
  final String account;
  final String label;
  final String? labelEn;
  final String? labelAr;
  final String type;
  final double balance;
  final String? posProfile;

  const MonthlyExpensePaymentSource({
    required this.id,
    required this.account,
    required this.label,
    this.labelEn,
    this.labelAr,
    this.type = 'account',
    this.balance = 0,
    this.posProfile,
  });

  String localizedLabel(String languageCode) => localizedExpenseLabel(
        languageCode: languageCode,
        fallbackLabel: label.isNotEmpty ? label : account,
        englishLabel: labelEn,
        arabicLabel: labelAr,
      );

  factory MonthlyExpensePaymentSource.fromJson(Map<String, dynamic> json) {
    return MonthlyExpensePaymentSource(
      id: _str(json['id'] ?? json['account']),
      account: _str(json['account']),
      label: _str(json['label']),
      labelEn: _strOrNull(json['label_en']),
      labelAr: _strOrNull(json['label_ar']),
      type: _str(json['type'] ?? json['category']).isEmpty
          ? 'account'
          : _str(json['type'] ?? json['category']),
      balance: _num(json['balance']),
      posProfile: _strOrNull(json['pos_profile']),
    );
  }

  static List<MonthlyExpensePaymentSource> listFrom(dynamic value) =>
      _maps(value).map(MonthlyExpensePaymentSource.fromJson).toList();
}

/// An `expense_accounts` option for the manage form.
class ExpenseAccountOption {
  final String account;
  final String label;

  const ExpenseAccountOption({required this.account, required this.label});

  String get displayLabel => label.trim().isNotEmpty ? label.trim() : account;

  factory ExpenseAccountOption.fromJson(Map<String, dynamic> json) {
    return ExpenseAccountOption(
      account: _str(json['account']),
      label: _str(json['label']),
    );
  }

  static List<ExpenseAccountOption> listFrom(dynamic value) => _maps(value)
      .map(ExpenseAccountOption.fromJson)
      .where((o) => o.account.isNotEmpty)
      .toList();
}

/// A `cost_centers` option for the manage form.
class CostCenterOption {
  final String name;
  final String label;

  const CostCenterOption({required this.name, required this.label});

  String get displayLabel => label.trim().isNotEmpty ? label.trim() : name;

  factory CostCenterOption.fromJson(Map<String, dynamic> json) {
    return CostCenterOption(
      name: _str(json['name']),
      label: _str(json['label']),
    );
  }

  static List<CostCenterOption> listFrom(dynamic value) => _maps(value)
      .map(CostCenterOption.fromJson)
      .where((o) => o.name.isNotEmpty)
      .toList();
}

/// Something the server wants the manager to know before trusting the numbers:
/// a missing salary structure, an overpaid item, unattributable salary GL, an
/// empty registry. Rendered at the top of the screen, above the money.
class MonthlyExpenseGap {
  final String severity;
  final String message;

  const MonthlyExpenseGap({required this.severity, required this.message});

  bool get isCritical {
    final s = severity.toLowerCase();
    return s == 'critical' || s == 'error' || s == 'danger';
  }

  factory MonthlyExpenseGap.fromJson(Map<String, dynamic> json) {
    return MonthlyExpenseGap(
      severity: _str(json['severity']),
      message: _str(json['message']),
    );
  }

  static List<MonthlyExpenseGap> listFrom(dynamic value) => _maps(value)
      .map(MonthlyExpenseGap.fromJson)
      .where((g) => g.message.isNotEmpty)
      .toList();
}

/// The whole `get_monthly_expenses` response.
class MonthlyExpensesPayload {
  final String month;
  final String monthLabel;
  final DateTime? monthStart;
  final DateTime? monthEnd;
  final String company;
  final String currency;
  final List<MonthlyExpenseMonthOption> availableMonths;
  final MonthlyExpenseSummary summary;
  final List<MonthlyExpenseCategoryTotal> byCategory;
  final List<RecurringExpenseItem> recurring;
  final PayrollBlock payroll;
  final List<MonthlyExpensePaymentSource> paymentSources;
  final List<ExpenseAccountOption> expenseAccounts;
  final List<CostCenterOption> costCenters;
  final List<String> categories;
  final List<String> frequencies;
  final List<MonthlyExpenseGap> gaps;
  final bool canManage;

  /// Whether this user may reverse a posted payment.
  ///
  /// Deliberately separate from [canManage]: cancelling reverses a Journal
  /// Entry, and the server gates that on a NARROWER role set (JARZ Manager and
  /// the admin tier) than the one that may read this screen (which also admits
  /// Accounts Manager). Reusing [canManage] would show an Accounts Manager a
  /// Cancel button that always fails.
  final bool canCancelPayments;

  const MonthlyExpensesPayload({
    this.month = '',
    this.monthLabel = '',
    this.monthStart,
    this.monthEnd,
    this.company = '',
    this.currency = '',
    this.availableMonths = const [],
    this.summary = const MonthlyExpenseSummary(),
    this.byCategory = const [],
    this.recurring = const [],
    this.payroll = const PayrollBlock(),
    this.paymentSources = const [],
    this.expenseAccounts = const [],
    this.costCenters = const [],
    this.categories = const [],
    this.frequencies = const [],
    this.gaps = const [],
    this.canManage = false,
    this.canCancelPayments = false,
  });

  /// Registry items keyed by category, categories in the order `by_category`
  /// gives them so the sections match the totals the header shows. Categories
  /// the server did not rank are appended alphabetically rather than dropped.
  Map<String, List<RecurringExpenseItem>> get recurringByCategory {
    final grouped = <String, List<RecurringExpenseItem>>{};
    for (final item in recurring) {
      final key = item.category.trim().isEmpty ? '' : item.category.trim();
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final ordered = <String, List<RecurringExpenseItem>>{};
    for (final total in byCategory) {
      final key = total.category.trim();
      final items = grouped.remove(key);
      if (items != null && items.isNotEmpty) ordered[key] = items;
    }
    final leftovers = grouped.keys.toList()..sort();
    for (final key in leftovers) {
      ordered[key] = grouped[key]!;
    }
    return ordered;
  }

  MonthlyExpenseCategoryTotal? categoryTotal(String category) {
    for (final total in byCategory) {
      if (total.category.trim() == category.trim()) return total;
    }
    return null;
  }

  factory MonthlyExpensesPayload.fromJson(Map<String, dynamic> json) {
    return MonthlyExpensesPayload(
      month: _str(json['month']),
      monthLabel: _str(json['month_label']),
      monthStart: _date(json['month_start']),
      monthEnd: _date(json['month_end']),
      company: _str(json['company']),
      currency: _str(json['currency']),
      availableMonths:
          MonthlyExpenseMonthOption.listFrom(json['available_months']),
      summary: MonthlyExpenseSummary.fromJson(
        json['summary'] is Map
            ? Map<String, dynamic>.from(json['summary'] as Map)
            : null,
      ),
      byCategory: _maps(json['by_category'])
          .map(MonthlyExpenseCategoryTotal.fromJson)
          .toList(),
      recurring: RecurringExpenseItem.listFrom(json['recurring']),
      payroll: PayrollBlock.fromJson(
        json['payroll'] is Map
            ? Map<String, dynamic>.from(json['payroll'] as Map)
            : null,
      ),
      paymentSources:
          MonthlyExpensePaymentSource.listFrom(json['payment_sources']),
      expenseAccounts: ExpenseAccountOption.listFrom(json['expense_accounts']),
      costCenters: CostCenterOption.listFrom(json['cost_centers']),
      categories: _stringList(json['categories']),
      frequencies: _stringList(json['frequencies']),
      gaps: MonthlyExpenseGap.listFrom(json['gaps']),
      canManage: _bool(json['can_manage']),
      canCancelPayments: _bool(json['can_cancel_payments']),
    );
  }
}

/// `categories` / `frequencies` are declared as bare lists in the contract but
/// the Desk-side helpers they come from return `{"value","label"}` rows for
/// some Selects, so both are flattened to the value the API expects back.
List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  final out = <String>[];
  for (final item in value) {
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final text = _str(map['value'] ?? map['name'] ?? map['label']);
      if (text.isNotEmpty) out.add(text);
    } else {
      final text = _str(item).trim();
      if (text.isNotEmpty) out.add(text);
    }
  }
  return out;
}

/// The payload a manage save sends back to `save_recurring_expense`.
///
/// A class rather than a loose map so the field names are written once: the
/// form, the repository and the test all read the same definition, and a typo
/// in one of them is a compile error instead of a field the server silently
/// ignores.
class RecurringExpenseDraft {
  /// Absent for a create, present for an update.
  final String? name;
  final String expenseName;
  final String category;
  final double amount;
  final String frequency;
  final String expenseAccount;
  final int? dayOfMonth;
  final String? costCenter;
  final String? supplier;
  final String? defaultPayingAccount;
  final String? startDate;
  final String? endDate;
  final String? notes;

  const RecurringExpenseDraft({
    this.name,
    required this.expenseName,
    required this.category,
    required this.amount,
    required this.frequency,
    required this.expenseAccount,
    this.dayOfMonth,
    this.costCenter,
    this.supplier,
    this.defaultPayingAccount,
    this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        'expense_name': expenseName,
        'category': category,
        'amount': amount,
        'frequency': frequency,
        'expense_account': expenseAccount,
        if (dayOfMonth != null) 'day_of_month': dayOfMonth,
        if (costCenter != null && costCenter!.isNotEmpty)
          'cost_center': costCenter,
        if (supplier != null && supplier!.isNotEmpty) 'supplier': supplier,
        if (defaultPayingAccount != null && defaultPayingAccount!.isNotEmpty)
          'default_paying_account': defaultPayingAccount,
        if (startDate != null && startDate!.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}
