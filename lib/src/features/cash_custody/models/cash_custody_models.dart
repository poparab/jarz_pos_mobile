import '../../expenses/models/expense_models.dart' show localizedExpenseLabel;

/// Wire parsing shared by every custody model.
///
/// The backend is Frappe: a Check field arrives as `0`/`1`, a Currency as a
/// float or (through some query paths) a string, and a missing value as
/// `null`. Each model tolerates all three rather than trusting one shape.
double custodyParseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? 0;
}

bool custodyParseBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return fallback;
  return text == '1' || text == 'true' || text == 'yes';
}

String? custodyParseNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> _asMapList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

/// Balances are compared with a half-piaster tolerance: the server rounds to
/// two decimals, and a float sum on the client can land a hair above it.
const double custodyBalanceEpsilon = 0.005;

/// An employee who may hold company cash, with what they hold right now.
class CustodyHolder {
  final String name;
  final String employee;
  final String employeeName;
  final String? user;
  final String? company;
  final String account;
  final String? labelEn;
  final String? labelAr;
  final double balance;
  final bool enabled;
  final String? lastMovement;

  const CustodyHolder({
    required this.name,
    required this.employee,
    required this.employeeName,
    required this.account,
    required this.balance,
    required this.enabled,
    this.user,
    this.company,
    this.labelEn,
    this.labelAr,
    this.lastMovement,
  });

  bool get hasBalance => balance.abs() > custodyBalanceEpsilon;

  /// The person's name in the reader's language, falling back to the
  /// employee name and then the record id.
  String localizedName(String languageCode) {
    final fallback = employeeName.isNotEmpty ? employeeName : name;
    return localizedExpenseLabel(
      languageCode: languageCode,
      fallbackLabel: fallback,
      englishLabel: labelEn,
      arabicLabel: labelAr,
    );
  }

  factory CustodyHolder.fromJson(Map<String, dynamic> json) {
    return CustodyHolder(
      name: (json['name'] ?? '').toString(),
      employee: (json['employee'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      user: custodyParseNullableString(json['user']),
      company: custodyParseNullableString(json['company']),
      account: (json['account'] ?? '').toString(),
      labelEn: custodyParseNullableString(json['label_en']),
      labelAr: custodyParseNullableString(json['label_ar']),
      balance: custodyParseDouble(json['balance']),
      // A holder row without the flag is a live one: the server only omits it
      // on shapes that predate the switch.
      enabled: custodyParseBool(json['enabled'], fallback: true),
      lastMovement: custodyParseNullableString(json['last_movement']),
    );
  }
}

/// A ledger account money can come from (issue) or go back to (return).
class CustodyAccountOption {
  final String account;
  final String label;
  final String? labelEn;
  final String? labelAr;
  final String category;
  final double balance;
  final String? posProfile;

  const CustodyAccountOption({
    required this.account,
    required this.label,
    required this.category,
    required this.balance,
    this.labelEn,
    this.labelAr,
    this.posProfile,
  });

  String localizedLabel(String languageCode) => localizedExpenseLabel(
        languageCode: languageCode,
        fallbackLabel: label.isNotEmpty ? label : account,
        englishLabel: labelEn,
        arabicLabel: labelAr,
      );

  factory CustodyAccountOption.fromJson(Map<String, dynamic> json) {
    return CustodyAccountOption(
      account: (json['account'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      labelEn: custodyParseNullableString(json['label_en']),
      labelAr: custodyParseNullableString(json['label_ar']),
      category: (json['category'] ?? 'other').toString(),
      balance: custodyParseDouble(json['balance']),
      posProfile: custodyParseNullableString(json['pos_profile']),
    );
  }
}

/// `get_custody_overview`: who the caller is to this feature, and what exists.
class CustodyOverview {
  final String? company;
  final bool canManage;
  final bool canManageHolders;
  final CustodyHolder? myHolder;
  final List<CustodyHolder> holders;
  final List<CustodyAccountOption> sourceAccounts;
  final List<CustodyAccountOption> returnAccounts;

  const CustodyOverview({
    required this.canManage,
    required this.canManageHolders,
    required this.holders,
    required this.sourceAccounts,
    required this.returnAccounts,
    this.company,
    this.myHolder,
  });

  static const empty = CustodyOverview(
    canManage: false,
    canManageHolders: false,
    holders: [],
    sourceAccounts: [],
    returnAccounts: [],
  );

  /// Whether the Cash Custody screen has anything to show this user.
  bool get hasAccess => canManage || myHolder != null;

  double get totalHeld =>
      holders.fold<double>(0, (sum, holder) => sum + holder.balance);

  /// The freshest copy of a holder: the manager list first, then the caller's
  /// own row (a non-manager's `holders` may be empty).
  CustodyHolder? holderNamed(String name) {
    for (final holder in holders) {
      if (holder.name == name) return holder;
    }
    if (myHolder?.name == name) return myHolder;
    return null;
  }

  /// Custodies this caller may spend from when paying a purchase: every
  /// enabled holder for a manager, otherwise only their own (if enabled).
  List<CustodyHolder> get payableHolders {
    if (canManage) {
      final list = holders.where((h) => h.enabled).toList();
      final mine = myHolder;
      if (mine != null && mine.enabled && !list.any((h) => h.name == mine.name)) {
        list.insert(0, mine);
      }
      return list;
    }
    final mine = myHolder;
    return mine != null && mine.enabled ? [mine] : const [];
  }

  factory CustodyOverview.fromJson(Map<String, dynamic> json) {
    final mine = json['my_holder'];
    return CustodyOverview(
      company: custodyParseNullableString(json['company']),
      canManage: custodyParseBool(json['can_manage']),
      canManageHolders: custodyParseBool(json['can_manage_holders']),
      myHolder: mine is Map ? CustodyHolder.fromJson(_asMap(mine)) : null,
      holders: _asMapList(json['holders']).map(CustodyHolder.fromJson).toList(),
      sourceAccounts: _asMapList(json['source_accounts'])
          .map(CustodyAccountOption.fromJson)
          .toList(),
      returnAccounts: _asMapList(json['return_accounts'])
          .map(CustodyAccountOption.fromJson)
          .toList(),
    );
  }
}

/// An employee who can be made a holder (`list_custody_candidates`).
class CustodyCandidate {
  final String employee;
  final String employeeName;
  final String? user;

  const CustodyCandidate({
    required this.employee,
    required this.employeeName,
    this.user,
  });

  String get displayName => employeeName.isNotEmpty ? employeeName : employee;

  factory CustodyCandidate.fromJson(Map<String, dynamic> json) {
    return CustodyCandidate(
      employee: (json['employee'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      user: custodyParseNullableString(json['user']),
    );
  }
}

/// What kind of movement a statement line is.
enum CustodyEntryKind {
  issue,
  returned,
  expense,
  purchase,
  transferIn,
  transferOut,
  other;

  static CustodyEntryKind parse(dynamic value) {
    switch ((value ?? '').toString().trim().toLowerCase()) {
      case 'issue':
        return CustodyEntryKind.issue;
      case 'return':
        return CustodyEntryKind.returned;
      case 'expense':
        return CustodyEntryKind.expense;
      case 'purchase':
        return CustodyEntryKind.purchase;
      case 'transfer_in':
        return CustodyEntryKind.transferIn;
      case 'transfer_out':
        return CustodyEntryKind.transferOut;
      default:
        return CustodyEntryKind.other;
    }
  }
}

class CustodyStatementEntry {
  final String? postingDate;
  final String? voucherType;
  final String? voucherNo;
  final CustodyEntryKind kind;
  final double debit;
  final double credit;
  final double balance;
  final String? remark;
  final String? counterAccount;
  final String? counterLabel;

  const CustodyStatementEntry({
    required this.kind,
    required this.debit,
    required this.credit,
    required this.balance,
    this.postingDate,
    this.voucherType,
    this.voucherNo,
    this.remark,
    this.counterAccount,
    this.counterLabel,
  });

  /// Positive for money into the custody, negative for money out.
  double get net => debit - credit;

  factory CustodyStatementEntry.fromJson(Map<String, dynamic> json) {
    return CustodyStatementEntry(
      postingDate: custodyParseNullableString(json['posting_date']),
      voucherType: custodyParseNullableString(json['voucher_type']),
      voucherNo: custodyParseNullableString(json['voucher_no']),
      kind: CustodyEntryKind.parse(json['kind']),
      debit: custodyParseDouble(json['debit']),
      credit: custodyParseDouble(json['credit']),
      balance: custodyParseDouble(json['balance']),
      remark: custodyParseNullableString(json['remark']),
      counterAccount: custodyParseNullableString(json['counter_account']),
      counterLabel: custodyParseNullableString(json['counter_label']),
    );
  }
}

class CustodyStatement {
  final CustodyHolder? holder;
  final String? fromDate;
  final String? toDate;
  final double openingBalance;
  final double closingBalance;
  final List<CustodyStatementEntry> entries;

  const CustodyStatement({
    required this.openingBalance,
    required this.closingBalance,
    required this.entries,
    this.holder,
    this.fromDate,
    this.toDate,
  });

  factory CustodyStatement.fromJson(Map<String, dynamic> json) {
    final holder = json['holder'];
    return CustodyStatement(
      holder: holder is Map ? CustodyHolder.fromJson(_asMap(holder)) : null,
      fromDate: custodyParseNullableString(json['from_date']),
      toDate: custodyParseNullableString(json['to_date']),
      openingBalance: custodyParseDouble(json['opening_balance']),
      closingBalance: custodyParseDouble(json['closing_balance']),
      entries: _asMapList(json['entries'])
          .map(CustodyStatementEntry.fromJson)
          .toList(),
    );
  }
}

/// `issue_custody` / `return_custody`: the posted entry and the holder after it.
class CustodyMovementResult {
  final String? journalEntry;
  final CustodyHolder? holder;

  const CustodyMovementResult({this.journalEntry, this.holder});

  factory CustodyMovementResult.fromJson(Map<String, dynamic> json) {
    final holder = json['holder'];
    return CustodyMovementResult(
      journalEntry: custodyParseNullableString(json['journal_entry']),
      holder: holder is Map ? CustodyHolder.fromJson(_asMap(holder)) : null,
    );
  }
}

/// The payment option string `create_purchase_invoice` / `pay_purchase_invoice`
/// accept for paying from a holder's custody.
String custodyPurchasePaymentOption(String holderName) => 'custody:$holderName';
