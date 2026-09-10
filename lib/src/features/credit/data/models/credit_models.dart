// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/order_display_id.dart';

part 'credit_models.freezed.dart';
part 'credit_models.g.dart';

/// Wire models for `jarz_pos.api.credit.*`.
///
/// Credit is chosen PER ORDER, never per customer: the same coffee shop pays
/// cash at the door on one delivery and takes the next on account. Settlement
/// is rolling and informal — the shop typically pays invoice N when invoice
/// N+1 arrives — so the money shape that matters is a RUNNING BALANCE per
/// shop with its open invoices oldest-first, not a due-date alarm.
///
/// Every money field goes through [creditDouble] because Frappe sends money as
/// a `num` but a serialised Decimal reaches us as a `String`; a hard cast on
/// the second shape throws and takes a whole manager screen down.

/// The credit standing of one customer, from `get_customer_credit_profile`.
///
/// [availableCredit] is the server's own arithmetic, not
/// `creditLimit - currentBalance` recomputed here: a zero limit can mean
/// "unlimited" or "nothing", and only the backend knows which.
@freezed
class CustomerCreditProfile with _$CustomerCreditProfile {
  const CustomerCreditProfile._();

  const factory CustomerCreditProfile({
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,

    /// The gate for offering Credit at checkout. Defaults to false so a
    /// malformed or truncated payload can never silently open credit.
    @JsonKey(name: 'credit_allowed', fromJson: creditBool)
    @Default(false)
    bool creditAllowed,

    /// Payment terms in days. Zero means the backend reported no term, in
    /// which case the checkout selector shows no "Due in N days" line rather
    /// than claiming "Due in 0 days".
    @JsonKey(name: 'credit_days', fromJson: creditInt) @Default(0) int creditDays,
    @JsonKey(name: 'credit_limit', fromJson: creditDouble)
    @Default(0.0)
    double creditLimit,

    /// What the customer already owes, all-time.
    @JsonKey(name: 'current_balance', fromJson: creditDouble)
    @Default(0.0)
    double currentBalance,
    @JsonKey(name: 'available_credit', fromJson: creditDouble)
    @Default(0.0)
    double availableCredit,
    @Default('') String currency,
  }) = _CustomerCreditProfile;

  factory CustomerCreditProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerCreditProfileFromJson(json);

  /// A limit of zero carries no information (unlimited vs. nothing), so the
  /// checkout selector only prints a limit when one was actually configured.
  bool get hasLimit => creditLimit > 0;

  bool get hasTerms => creditDays > 0;

  /// The refusal a manager would recognise. Never used to BLOCK checkout —
  /// the server owns that decision and re-checks it on submit.
  bool get isOverLimit => hasLimit && availableCredit <= 0;
}

/// The filters the backend echoes back, so the UI can label what it listed.
@freezed
class CreditLedgerFilters with _$CreditLedgerFilters {
  const factory CreditLedgerFilters({
    @Default('') String customer,
    @JsonKey(name: 'pos_profile') @Default('') String posProfile,
    @JsonKey(name: 'from_date') @Default('') String fromDate,
    @JsonKey(name: 'to_date') @Default('') String toDate,
    @JsonKey(fromJson: creditInt) @Default(0) int limit,
  }) = _CreditLedgerFilters;

  factory CreditLedgerFilters.fromJson(Map<String, dynamic> json) =>
      _$CreditLedgerFiltersFromJson(json);
}

/// The headline numbers.
///
/// The date window and the money mean two different things, exactly as in the
/// employee ledger: the window scopes which INVOICES ARE LISTED, while
/// [totalOutstanding] is a balance over every open item of any age. Conflating
/// them is how a manager reads a partial figure as the whole debt, so
/// [outstandingIsAllTime] drives the label rather than an assumption.
@freezed
class CreditLedgerSummary with _$CreditLedgerSummary {
  const factory CreditLedgerSummary({
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    @Default(0.0)
    double totalOutstanding,

    /// Shops carrying a NON-ZERO balance. Can be smaller than
    /// `CreditLedger.customers.length`, because a shop with activity in the
    /// window but nothing owed is still listed, at zero.
    @JsonKey(name: 'customer_count', fromJson: creditInt)
    @Default(0)
    int customerCount,

    /// Invoices LISTED IN THE WINDOW, not the count behind the balance. Zero
    /// here is perfectly compatible with a non-zero outstanding amount: the
    /// debt is simply older than the selected period.
    @JsonKey(name: 'invoice_count', fromJson: creditInt)
    @Default(0)
    int invoiceCount,
    @Default('') String currency,

    /// Absent means an older backend that had not yet split balance from
    /// activity; defaults to true so the label never quietly under-claims.
    @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
    @Default(true)
    bool outstandingIsAllTime,
  }) = _CreditLedgerSummary;

  factory CreditLedgerSummary.fromJson(Map<String, dynamic> json) =>
      _$CreditLedgerSummaryFromJson(json);
}

/// One shop's rolled-up credit balance.
@freezed
class CreditCustomerRow with _$CreditCustomerRow {
  const CreditCustomerRow._();

  const factory CreditCustomerRow({
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,

    /// ALL-TIME, never bounded by the ledger's date window.
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    @Default(0.0)
    double totalOutstanding,

    /// Open invoices behind [totalOutstanding] — this one IS the count behind
    /// the balance, unlike `CreditLedgerSummary.invoiceCount`.
    @JsonKey(name: 'invoice_count', fromJson: creditInt)
    @Default(0)
    int invoiceCount,

    /// Posting date of the oldest still-open invoice, `YYYY-MM-DD`.
    @JsonKey(name: 'oldest_invoice_date') @Default('') String oldestInvoiceDate,
    @Default('') String currency,
  }) = _CreditCustomerRow;

  factory CreditCustomerRow.fromJson(Map<String, dynamic> json) =>
      _$CreditCustomerRowFromJson(json);

  /// Never blank: falls back to the customer id.
  String get displayName {
    final trimmed = customerName.trim();
    return trimmed.isNotEmpty ? trimmed : customer.trim();
  }

  /// Age of the oldest open invoice in whole days, or null when the backend
  /// sent no date. This is the ONLY ageing signal the UI shows — deliberately
  /// a neutral "45 days" and not an "OVERDUE" alarm, because rolling informal
  /// settlement means an old invoice is normal, not an incident.
  int? get oldestInvoiceAgeDays {
    final parsed = DateTime.tryParse(oldestInvoiceDate.trim());
    if (parsed == null) return null;
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(parsed.year, parsed.month, parsed.day))
        .inDays;
    return days < 0 ? 0 : days;
  }
}

/// One open credit invoice in the activity feed.
///
/// The id key is read tolerantly: the employee ledger calls it `invoice`, a
/// plain Frappe row calls it `name`. Accepting both keeps this list rendering
/// if the endpoint follows either idiom.
@freezed
class CreditInvoice with _$CreditInvoice {
  const CreditInvoice._();

  const factory CreditInvoice({
    @JsonKey(name: 'invoice', readValue: readInvoiceId)
    @Default('')
    String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'posting_date') @Default('') String postingDate,
    @JsonKey(name: 'due_date') @Default('') String dueDate,
    @JsonKey(name: 'grand_total', fromJson: creditDouble)
    @Default(0.0)
    double grandTotal,
    @JsonKey(name: 'outstanding_amount', fromJson: creditDouble)
    @Default(0.0)
    double outstandingAmount,
    @Default('') String status,
    @JsonKey(name: 'pos_profile') @Default('') String posProfile,
    @Default('') String branch,
    @Default('') String currency,
  }) = _CreditInvoice;

  factory CreditInvoice.fromJson(Map<String, dynamic> json) =>
      _$CreditInvoiceFromJson(json);

  /// What a human calls this order: the Woo number when there is one, else the
  /// invoice name with `ACC-SINV-` stripped. Staff quote this number on the
  /// phone; the raw name is an internal accounting key.
  String get displayId => orderDisplayId(invoice, wooOrderId: wooOrderId);

  /// Age in whole days since posting, or null when no date was sent.
  int? get ageDays {
    final parsed = DateTime.tryParse(postingDate.trim());
    if (parsed == null) return null;
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(parsed.year, parsed.month, parsed.day))
        .inDays;
    return days < 0 ? 0 : days;
  }
}

/// The customer analogue of the employee ledger.
@freezed
class CreditLedger with _$CreditLedger {
  const CreditLedger._();

  const factory CreditLedger({
    @Default(true) bool success,
    @Default(CreditLedgerFilters()) CreditLedgerFilters filters,
    @Default(CreditLedgerSummary()) CreditLedgerSummary summary,

    /// Sorted highest balance first by [CreditRepository.getCreditLedger], so
    /// the screen never depends on the server's ordering.
    @Default(<CreditCustomerRow>[]) List<CreditCustomerRow> customers,

    /// The activity feed. Bounded by the date window AND by `limit`, unlike
    /// the balances above it.
    @Default(<CreditInvoice>[]) List<CreditInvoice> invoices,
    @JsonKey(name: 'notice_code') String? noticeCode,
    String? notice,
  }) = _CreditLedger;

  factory CreditLedger.fromJson(Map<String, dynamic> json) =>
      _$CreditLedgerFromJson(json);

  bool get isEmpty => customers.isEmpty && invoices.isEmpty;

  bool get hasNotice =>
      (noticeCode ?? '').trim().isNotEmpty || (notice ?? '').trim().isNotEmpty;

  /// Only the shops that actually owe something, highest balance first. The
  /// list screen shows this; a zero-balance shop with window activity is not
  /// a "credit account" a manager needs to chase.
  List<CreditCustomerRow> get owing =>
      customers.where((row) => row.totalOutstanding != 0).toList();

  /// The open invoices for one shop, OLDEST FIRST — the order the backend
  /// allocates a payment in, so the detail list and the FIFO result agree.
  List<CreditInvoice> invoicesFor(String customer) {
    final rows = invoices.where((i) => i.customer == customer).toList();
    rows.sort((a, b) {
      final left = DateTime.tryParse(a.postingDate.trim());
      final right = DateTime.tryParse(b.postingDate.trim());
      if (left == null && right == null) return a.invoice.compareTo(b.invoice);
      if (left == null) return 1;
      if (right == null) return -1;
      final byDate = left.compareTo(right);
      return byDate != 0 ? byDate : a.invoice.compareTo(b.invoice);
    });
    return rows;
  }

  CreditCustomerRow? rowFor(String customer) {
    for (final row in customers) {
      if (row.customer == customer) return row;
    }
    return null;
  }
}

/// One invoice a payment was allocated against.
///
/// Key aliases are read tolerantly because FIFO allocation is reported as a
/// small ad-hoc structure rather than a DocType row: `invoice`/`sales_invoice`
/// /`name` and `allocated_amount`/`amount`/`allocated` all appear in the
/// codebase's neighbouring settlement payloads.
@freezed
class CreditPaymentAllocation with _$CreditPaymentAllocation {
  const CreditPaymentAllocation._();

  const factory CreditPaymentAllocation({
    @JsonKey(name: 'invoice', readValue: readInvoiceId)
    @Default('')
    String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    @JsonKey(name: 'allocated_amount', readValue: readAllocatedAmount, fromJson: creditDouble)
    @Default(0.0)
    double allocatedAmount,
    @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
    @Default(0.0)
    double outstandingBefore,
    @JsonKey(name: 'fully_settled') @Default(false) bool fullySettled,
    @JsonKey(name: 'posting_date') @Default('') String postingDate,
  }) = _CreditPaymentAllocation;

  factory CreditPaymentAllocation.fromJson(Map<String, dynamic> json) =>
      _$CreditPaymentAllocationFromJson(json);

  String get displayId => orderDisplayId(invoice, wooOrderId: wooOrderId);

  /// True when this invoice was fully settled by the allocation. A partial
  /// allocation on the oldest invoice is the normal FIFO tail, and the sheet
  /// must say so instead of implying the invoice is closed.
  ///
  /// Read straight off the server's `fully_settled`, never derived here. An
  /// earlier draft computed it from an `outstanding_after` field the backend
  /// does not send, so every row defaulted to 0 and read as fully cleared —
  /// the sheet would have told the user a part-paid invoice was closed.
  bool get fullyCleared => fullySettled;
}

/// What `record_credit_payment` actually did.
///
/// FIFO means the result is frequently NOT what the user expected: a round
/// number part-pays the oldest invoice, or over-pays and leaves an advance.
/// The sheet reads this back verbatim rather than echoing the input amount.
@freezed
class CreditPaymentResult with _$CreditPaymentResult {
  const CreditPaymentResult._();

  const factory CreditPaymentResult({
    @Default(true) bool success,
    @JsonKey(name: 'payment_entry') @Default('') String paymentEntry,
    @Default('') String customer,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'amount', fromJson: creditDouble) @Default(0.0) double amount,
    @JsonKey(
      name: 'total_allocated',
      readValue: readTotalAllocated,
      fromJson: creditDouble,
    )
    @Default(0.0)
    double totalAllocated,

    /// The excess left sitting as an unallocated advance on the customer.
    @JsonKey(
      name: 'unallocated_amount',
      readValue: readUnallocatedAmount,
      fromJson: creditDouble,
    )
    @Default(0.0)
    double unallocatedAmount,

    /// Remaining balance after the payment, when the backend reports it.
    @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
    double? remainingBalance,
    @JsonKey(name: 'allocations', readValue: readAllocations)
    @Default(<CreditPaymentAllocation>[])
    List<CreditPaymentAllocation> allocations,
    @Default('') String currency,
  }) = _CreditPaymentResult;

  factory CreditPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$CreditPaymentResultFromJson(json);

  /// Invoices this payment closed outright.
  List<CreditPaymentAllocation> get cleared =>
      allocations.where((a) => a.fullyCleared).toList();

  /// The at most one invoice a FIFO tail part-paid.
  List<CreditPaymentAllocation> get partial =>
      allocations.where((a) => !a.fullyCleared && a.allocatedAmount != 0).toList();

  bool get hasAdvance => unallocatedAmount.abs() >= 0.005;

  /// True when the money went nowhere — nothing open to allocate against, so
  /// the whole amount became an advance. Worth saying out loud.
  bool get isEntirelyAdvance => allocations.isEmpty && hasAdvance;
}

// ── Tolerant scalar readers ───────────────────────────────────────────────

/// Frappe sends money as a `num`, but a serialised Decimal reaches us as a
/// string, so both shapes are accepted before falling back to zero.
double creditDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

double? creditDoubleOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
  return null;
}

int creditInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

/// Frappe renders a Check as 0/1 and a JSON bool as true/false, so both are
/// accepted. Anything unrecognised is false: credit is never opened by a
/// payload the client could not read.
bool creditBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

/// Same shapes as [creditBool], but absent/blank means "not reported", which
/// defaults to all-time so the balance label never under-claims.
bool creditAllTimeFlag(Object? value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return normalized != 'false' && normalized != '0';
}

Object? _firstPresent(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) return value;
  }
  return null;
}

Object? readInvoiceId(Map<dynamic, dynamic> json, String key) =>
    _firstPresent(json, const ['invoice', 'sales_invoice', 'name']);

Object? readAllocatedAmount(Map<dynamic, dynamic> json, String key) =>
    _firstPresent(json, const ['allocated_amount', 'amount', 'allocated']);

Object? readTotalAllocated(Map<dynamic, dynamic> json, String key) =>
    _firstPresent(json, const [
      'total_allocated',
      'allocated_total',
      'allocated_amount',
    ]);

Object? readUnallocatedAmount(Map<dynamic, dynamic> json, String key) =>
    _firstPresent(json, const [
      'unallocated_amount',
      'unallocated',
      'advance_amount',
    ]);

Object? readAllocations(Map<dynamic, dynamic> json, String key) =>
    _firstPresent(json, const [
      'allocations',
      'allocated_invoices',
      'invoices',
    ]);
