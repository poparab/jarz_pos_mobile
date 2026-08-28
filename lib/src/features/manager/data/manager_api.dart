import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/order_display_id.dart';

final managerApiProvider = Provider<ManagerApi>((ref) {
  final dio = ref.read(dioProvider);
  return ManagerApi(dio);
});

class ManagerApi {
  final Dio _dio;
  ManagerApi(this._dio);

  Future<DashboardSummary> getSummary({String? company}) async {
    final resp = await _dio.get(
      ApiEndpoints.getManagerDashboardSummary,
      queryParameters: {if (company != null) 'company': company},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    return DashboardSummary.fromJson(data['message'] ?? data);
  }

  Future<List<TransferTargetBranch>> getTransferTargetBranches() async {
    try {
      final resp = await _dio.get(ApiEndpoints.getManagerTransferTargetBranches);
      final data = resp.data is String ? json.decode(resp.data) : resp.data;
      final payload = data is Map<String, dynamic> ? (data['message'] ?? data) : data;

      if (payload is Map<String, dynamic> && payload['success'] == false) {
        throw Exception(
          extractFrappeErrorMessage(
            payload,
            fallback: 'Failed to load transfer branches',
          ),
        );
      }

      final rawBranches = payload is List<dynamic>
          ? payload
          : payload is Map<String, dynamic>
              ? ((payload['branches'] ?? payload['data']) as List<dynamic>? ??
                  const <dynamic>[])
              : const <dynamic>[];

      return rawBranches
          .whereType<Map>()
          .map(
            (entry) => TransferTargetBranch.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .where((branch) => branch.name.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load transfer branches',
      );
    }
  }

  Future<List<ManagerInvoice>> getOrders({String? branch, String? state, int limit = 200}) async {
    final resp = await _dio.get(
      ApiEndpoints.getManagerOrders,
      queryParameters: {
        if (branch != null) 'branch': branch,
        if (state != null) 'state': state,
        'limit': limit,
      },
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final list = (data['message'] ?? data)['invoices'] as List<dynamic>? ?? const [];
    return list.map((j) => ManagerInvoice.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getStates() async {
    final resp = await _dio.get(
      ApiEndpoints.getManagerStates,
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final list = (data['message'] ?? data)['states'] as List<dynamic>? ?? const [];
    return list.map((e) => e.toString()).toList();
  }

  Future<void> updateInvoiceBranch({required String invoiceId, required String newBranch}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.updateInvoiceBranch,
        data: {'invoice_id': invoiceId, 'new_branch': newBranch},
      );
      final data = resp.data is String ? json.decode(resp.data) : resp.data;
      final message = data is Map<String, dynamic> ? (data['message'] ?? data) : data;
      if (!((message is Map<String, dynamic>) && message['success'] == true)) {
        throw Exception(
          extractFrappeErrorMessage(
            message,
            fallback: 'Failed to transfer branch',
          ),
        );
      }
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to transfer branch');
    }
  }

  /// What every employee currently owes the company.
  ///
  /// Two independent debts roll into one balance per person: HRMS cash advances
  /// that were paid out but not yet claimed or returned, and Employee-purpose
  /// POS orders settled on the employee account that are still an unpaid
  /// receivable. The backend defaults to a 90-day window ending today when the
  /// dates are omitted, and treats "all" (any case) as the no-filter branch.
  Future<EmployeeLedger> getEmployeeLedger({
    String? fromDate,
    String? toDate,
    String? branch,
    String? employee,
    int limit = 200,
  }) async {
    try {
      final resp = await _dio.get(
        ApiEndpoints.getEmployeeLedger,
        queryParameters: {
          if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
          if (branch != null && branch.isNotEmpty) 'branch': branch,
          if (employee != null && employee.isNotEmpty) 'employee': employee,
          'limit': limit,
        },
      );
      final data = resp.data is String ? json.decode(resp.data) : resp.data;
      final payload =
          data is Map<String, dynamic> ? (data['message'] ?? data) : data;

      if (payload is! Map) {
        throw Exception('Failed to load employee ledger');
      }

      final map = Map<String, dynamic>.from(payload);
      if (map['success'] == false) {
        throw Exception(
          extractFrappeErrorMessage(
            map,
            fallback: 'Failed to load employee ledger',
          ),
        );
      }

      return EmployeeLedger.fromJson(map);
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load employee ledger');
    }
  }

  Future<List<CustomShippingRequest>> getPendingCustomShippingRequests() async {
    final resp = await _dio.get(ApiEndpoints.getPendingCustomShippingRequests);
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    final ok = (msg is Map<String, dynamic>) ? (msg['success'] == true) : false;
    if (!ok) {
      throw Exception('Failed to fetch pending custom shipping requests');
    }
    final list = (msg['data'] as List<dynamic>? ?? const []);
    return list
        .map((j) => CustomShippingRequest.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveCustomShipping(String requestName) async {
    final resp = await _dio.post(
      ApiEndpoints.approveCustomShipping,
      data: {'request_name': requestName},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    if (!((msg is Map<String, dynamic>) && msg['success'] == true)) {
      throw Exception((msg is Map<String, dynamic>) ? (msg['message'] ?? 'Failed to approve') : 'Failed to approve');
    }
  }

  Future<void> rejectCustomShipping(String requestName, {String reason = ''}) async {
    final resp = await _dio.post(
      ApiEndpoints.rejectCustomShipping,
      data: {'request_name': requestName, 'rejection_reason': reason},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    if (!((msg is Map<String, dynamic>) && msg['success'] == true)) {
      throw Exception((msg is Map<String, dynamic>) ? (msg['message'] ?? 'Failed to reject') : 'Failed to reject');
    }
  }
}

class DashboardSummary {
  final List<BranchBalance> branches;
  final double totalBalance;
  DashboardSummary({required this.branches, required this.totalBalance});
  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        branches: (json['branches'] as List<dynamic>? ?? const [])
            .map((e) => BranchBalance.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      );
}

class TransferTargetBranch {
  final String name;
  final String title;

  const TransferTargetBranch({required this.name, required this.title});

  factory TransferTargetBranch.fromJson(Map<String, dynamic> json) =>
      TransferTargetBranch(
        name: (json['name'] ?? '').toString(),
        title: (json['title'] ?? json['name'] ?? '').toString(),
      );
}

class BranchBalance {
  final String name;
  final String title;
  final String? cashAccount;
  final double balance;
  BranchBalance({required this.name, required this.title, required this.cashAccount, required this.balance});
  factory BranchBalance.fromJson(Map<String, dynamic> json) => BranchBalance(
        name: json['name'] as String,
        title: (json['title'] as String?) ?? json['name'] as String,
        cashAccount: json['cash_account'] as String?,
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      );
}

class ManagerInvoice {
  final String name;
  final int? wooOrderId;
  final String customer;
  final String customerName;
  final String postingDate;
  final String postingTime;
  final double grandTotal;
  final double netTotal;
  final String status;
  final String branch;
  // convenience for UI
  String get branchName => branch;
  /// What the dashboard labels this order with.
  String get displayId => orderDisplayId(name, wooOrderId: wooOrderId);
  ManagerInvoice({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.postingDate,
    required this.postingTime,
    required this.grandTotal,
    required this.netTotal,
    required this.status,
    required this.branch,
    this.wooOrderId,
  });
  factory ManagerInvoice.fromJson(Map<String, dynamic> json) => ManagerInvoice(
        name: json['name'] as String,
        wooOrderId: normalizeWooOrderId(json['woo_order_id']),
        customer: json['customer'] as String,
        customerName: (json['customer_name'] as String?) ?? (json['customer'] as String),
        postingDate: json['posting_date'] as String,
        postingTime: json['posting_time'] as String,
        grandTotal: (json['grand_total'] as num).toDouble(),
        netTotal: (json['net_total'] as num).toDouble(),
        status: json['status'] as String,
        branch: json['branch'] as String,
      );
}

class CustomShippingRequest {
  final String name;
  final String invoice;
  final String customerName;
  final String territory;
  final String? territoryNameAr;
  final double originalAmount;
  final double requestedAmount;
  final String reason;
  final String requestedBy;
  final String requestedOn;

  CustomShippingRequest({
    required this.name,
    required this.invoice,
    required this.customerName,
    required this.territory,
    this.territoryNameAr,
    required this.originalAmount,
    required this.requestedAmount,
    required this.reason,
    required this.requestedBy,
    required this.requestedOn,
  });

  factory CustomShippingRequest.fromJson(Map<String, dynamic> json) {
    return CustomShippingRequest(
      name: (json['name'] ?? '').toString(),
      invoice: (json['invoice'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      territory: (json['territory'] ?? '').toString(),
      territoryNameAr: json['territory_name_ar']?.toString(),
      originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0,
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] ?? '').toString(),
      requestedBy: (json['requested_by'] ?? '').toString(),
      requestedOn: (json['requested_on'] ?? '').toString(),
    );
  }
}

/// The per-employee outstanding view returned by
/// `manager.get_employee_ledger`: HRMS cash advances plus unpaid
/// Employee-purpose POS orders, rolled into one balance per person.
class EmployeeLedger {
  /// False when HRMS is not installed. The advances half is then legitimately
  /// empty and only the orders half carries money — never treat it as an error.
  final bool hrmsAvailable;
  final String fromDate;
  final String toDate;
  final String branch;
  final String employee;
  final EmployeeLedgerSummary summary;

  /// Already sorted by [EmployeeLedgerRow.totalOutstanding] descending.
  final List<EmployeeLedgerRow> employees;
  final List<EmployeeLedgerAdvance> advances;
  final List<EmployeeLedgerOrder> orders;

  /// One of `no_branch_assigned`, `branch_not_permitted`, `hrms_unavailable`,
  /// `results_truncated`. Informational — never an error.
  final String? noticeCode;
  final String? notice;

  const EmployeeLedger({
    required this.hrmsAvailable,
    required this.fromDate,
    required this.toDate,
    required this.branch,
    required this.employee,
    required this.summary,
    required this.employees,
    required this.advances,
    required this.orders,
    this.noticeCode,
    this.notice,
  });

  bool get isEmpty => employees.isEmpty && advances.isEmpty && orders.isEmpty;

  bool get hasNotice =>
      (noticeCode ?? '').isNotEmpty || (notice ?? '').isNotEmpty;

  /// The advances belonging to one rollup row. An empty [employeeId] is the
  /// bucket for orders whose customer resolved to no employee.
  List<EmployeeLedgerAdvance> advancesFor(String employeeId) =>
      advances.where((a) => a.employee == employeeId).toList();

  List<EmployeeLedgerOrder> ordersFor(String employeeId) =>
      orders.where((o) => o.employee == employeeId).toList();

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) build,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => build(Map<String, dynamic>.from(e)))
        .toList();
  }

  factory EmployeeLedger.fromJson(Map<String, dynamic> json) {
    final rawFilters = json['filters'];
    final filters = rawFilters is Map
        ? Map<String, dynamic>.from(rawFilters)
        : const <String, dynamic>{};
    final rawSummary = json['summary'];

    final noticeCode = (json['notice_code'] ?? '').toString().trim();
    final notice = (json['notice'] ?? '').toString().trim();

    return EmployeeLedger(
      hrmsAvailable: json['hrms_available'] == true,
      fromDate: (filters['from_date'] ?? '').toString(),
      toDate: (filters['to_date'] ?? '').toString(),
      branch: (filters['branch'] ?? '').toString(),
      employee: (filters['employee'] ?? '').toString(),
      summary: EmployeeLedgerSummary.fromJson(
        rawSummary is Map
            ? Map<String, dynamic>.from(rawSummary)
            : const <String, dynamic>{},
      ),
      employees: _parseList(json['employees'], EmployeeLedgerRow.fromJson),
      advances: _parseList(json['advances'], EmployeeLedgerAdvance.fromJson),
      orders: _parseList(json['orders'], EmployeeLedgerOrder.fromJson),
      noticeCode: noticeCode.isEmpty ? null : noticeCode,
      notice: notice.isEmpty ? null : notice,
    );
  }
}

/// The headline numbers.
///
/// The date window and the money mean two different things here: the window
/// scopes which rows are LISTED, while the outstanding amounts are a balance
/// over every open item. Conflating them is how a manager reads a partial
/// figure as the whole debt, so [outstandingIsAllTime] drives the label.
class EmployeeLedgerSummary {
  /// All-time when [outstandingIsAllTime], covering open items of any age.
  final double advanceOutstanding;
  final double orderOutstanding;
  final double totalOutstanding;

  /// Rows LISTED IN THE WINDOW, not the balance. Zero here is perfectly
  /// compatible with a non-zero outstanding amount: the debt is simply older
  /// than the selected period.
  final int advanceCount;
  final int orderCount;

  /// People carrying a NON-ZERO balance. Can be smaller than
  /// [EmployeeLedger.employees] length, because somebody with activity in the
  /// window but nothing owed is still listed, at zero.
  final int employeeCount;
  final String currency;

  /// Whether the outstanding amounts ignore the date window. Absent means an
  /// older backend that had not yet split balance from activity; it defaults
  /// to true so the label never quietly under-claims what the number covers.
  final bool outstandingIsAllTime;

  const EmployeeLedgerSummary({
    required this.advanceOutstanding,
    required this.orderOutstanding,
    required this.totalOutstanding,
    required this.advanceCount,
    required this.orderCount,
    required this.employeeCount,
    required this.currency,
    this.outstandingIsAllTime = true,
  });

  factory EmployeeLedgerSummary.fromJson(Map<String, dynamic> json) =>
      EmployeeLedgerSummary(
        advanceOutstanding: _toLedgerDouble(json['advance_outstanding']),
        orderOutstanding: _toLedgerDouble(json['order_outstanding']),
        totalOutstanding: _toLedgerDouble(json['total_outstanding']),
        advanceCount: _toLedgerInt(json['advance_count']),
        orderCount: _toLedgerInt(json['order_count']),
        employeeCount: _toLedgerInt(json['employee_count']),
        currency: (json['currency'] ?? '').toString(),
        outstandingIsAllTime:
            _toLedgerAllTimeFlag(json['outstanding_is_all_time']),
      );
}

/// One person's rolled-up balance. [employee] is empty for orders whose
/// customer resolved to no employee — that money is still real, so the row is
/// rendered like any other with the customer name standing in for the person.
class EmployeeLedgerRow {
  final String employee;
  final String employeeName;
  final String user;
  final String branch;
  final String customer;
  final double advanceOutstanding;
  final double orderOutstanding;
  final double totalOutstanding;
  final int advanceCount;
  final int orderCount;

  const EmployeeLedgerRow({
    required this.employee,
    required this.employeeName,
    required this.user,
    required this.branch,
    required this.customer,
    required this.advanceOutstanding,
    required this.orderOutstanding,
    required this.totalOutstanding,
    required this.advanceCount,
    required this.orderCount,
  });

  /// Never blank: falls back through the employee id, then the customer.
  String get displayName {
    for (final candidate in [employeeName, employee, customer]) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  /// True when no HRMS Employee backs this row (unattributed employee orders).
  bool get isUnmatched => employee.trim().isEmpty;

  factory EmployeeLedgerRow.fromJson(Map<String, dynamic> json) {
    final employee = (json['employee'] ?? '').toString();
    final customer = (json['customer'] ?? '').toString();
    final name = (json['employee_name'] ?? '').toString();
    return EmployeeLedgerRow(
      employee: employee,
      employeeName: name.isNotEmpty
          ? name
          : (employee.isNotEmpty ? employee : customer),
      user: (json['user'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      customer: customer,
      advanceOutstanding: _toLedgerDouble(json['advance_outstanding']),
      orderOutstanding: _toLedgerDouble(json['order_outstanding']),
      totalOutstanding: _toLedgerDouble(json['total_outstanding']),
      advanceCount: _toLedgerInt(json['advance_count']),
      orderCount: _toLedgerInt(json['order_count']),
    );
  }
}

/// A single HRMS Employee Advance line. [balance] is what is still owed.
class EmployeeLedgerAdvance {
  final String name;
  final String employee;
  final String employeeName;
  final String postingDate;
  final double amount;
  final double paidAmount;
  final double claimedAmount;
  final double returnAmount;
  final double balance;
  final String status;
  final String purpose;
  final String branch;
  final String payingAccount;
  final String currency;

  const EmployeeLedgerAdvance({
    required this.name,
    required this.employee,
    required this.employeeName,
    required this.postingDate,
    required this.amount,
    required this.paidAmount,
    required this.claimedAmount,
    required this.returnAmount,
    required this.balance,
    required this.status,
    required this.purpose,
    required this.branch,
    required this.payingAccount,
    required this.currency,
  });

  factory EmployeeLedgerAdvance.fromJson(Map<String, dynamic> json) {
    final employee = (json['employee'] ?? '').toString();
    final name = (json['employee_name'] ?? '').toString();
    return EmployeeLedgerAdvance(
      name: (json['name'] ?? '').toString(),
      employee: employee,
      employeeName: name.isNotEmpty ? name : employee,
      postingDate: (json['posting_date'] ?? '').toString(),
      amount: _toLedgerDouble(json['amount']),
      paidAmount: _toLedgerDouble(json['paid_amount']),
      claimedAmount: _toLedgerDouble(json['claimed_amount']),
      returnAmount: _toLedgerDouble(json['return_amount']),
      balance: _toLedgerDouble(json['balance']),
      status: (json['status'] ?? '').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      payingAccount: (json['paying_account'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
    );
  }
}

/// An Employee-purpose POS order still carrying an outstanding receivable.
class EmployeeLedgerOrder {
  final String invoice;
  final String employee;
  final String employeeName;
  final String customer;
  final String customerName;
  final String branch;
  final String postingDate;
  final double grandTotal;
  final double outstandingAmount;
  final String status;
  final String state;
  final String deliveryNote;

  const EmployeeLedgerOrder({
    required this.invoice,
    required this.employee,
    required this.employeeName,
    required this.customer,
    required this.customerName,
    required this.branch,
    required this.postingDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.status,
    required this.state,
    required this.deliveryNote,
  });

  /// What a human calls this order. The ledger payload carries no
  /// `woo_order_id`, so this is the invoice name with `ACC-SINV-` stripped.
  String get displayId => orderDisplayId(invoice);

  factory EmployeeLedgerOrder.fromJson(Map<String, dynamic> json) {
    final employee = (json['employee'] ?? '').toString();
    final customer = (json['customer'] ?? '').toString();
    final customerName = (json['customer_name'] ?? '').toString();
    final name = (json['employee_name'] ?? '').toString();
    return EmployeeLedgerOrder(
      invoice: (json['invoice'] ?? '').toString(),
      employee: employee,
      employeeName: name.isNotEmpty
          ? name
          : (customerName.isNotEmpty ? customerName : customer),
      customer: customer,
      customerName: customerName.isNotEmpty ? customerName : customer,
      branch: (json['branch'] ?? '').toString(),
      postingDate: (json['posting_date'] ?? '').toString(),
      grandTotal: _toLedgerDouble(json['grand_total']),
      outstandingAmount: _toLedgerDouble(json['outstanding_amount']),
      status: (json['status'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      deliveryNote: (json['delivery_note'] ?? '').toString(),
    );
  }
}

/// Frappe sends money as a `num`, but a serialised Decimal reaches us as a
/// string, so both shapes are accepted before falling back to zero.
double _toLedgerDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _toLedgerInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

/// Frappe renders a Check as 0/1 and a JSON bool as true/false, so both are
/// accepted. Absent or blank means "not reported", which defaults to all-time.
bool _toLedgerAllTimeFlag(dynamic value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return normalized != 'false' && normalized != '0';
}
