/// Typed payloads of `jarz_pos.api.employee_customers`.
///
/// Plain classes rather than Freezed, like the neighbouring manager ledger
/// models: Frappe renders a Check as 0/1 and may omit keys on older sites, so
/// every field is parsed leniently instead of through generated casts.
library;

String _string(dynamic value) => (value ?? '').toString().trim();

String? _optionalString(dynamic value) {
  final text = _string(value);
  return text.isEmpty ? null : text;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = _string(value).toLowerCase();
  return normalized == '1' || normalized == 'true' || normalized == 'yes';
}

List<Map<String, dynamic>> _maps(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList(growable: false);
}

/// One row of `list_staff_for_orders`: a person the order can be put on.
class StaffOrderEmployee {
  final String employee;
  final String employeeName;
  final String branch;
  final String designation;

  /// The linked Customer, or null when `ensure_staff_customer` will create one.
  final String? customer;
  final String? customerName;

  const StaffOrderEmployee({
    required this.employee,
    required this.employeeName,
    this.branch = '',
    this.designation = '',
    this.customer,
    this.customerName,
  });

  /// Never blank: falls back to the employee id.
  String get displayName => employeeName.isNotEmpty ? employeeName : employee;

  bool get hasCustomer => (customer ?? '').isNotEmpty;

  factory StaffOrderEmployee.fromJson(Map<String, dynamic> json) {
    return StaffOrderEmployee(
      employee: _string(json['employee']),
      employeeName: _string(json['employee_name']),
      branch: _string(json['branch']),
      designation: _string(json['designation']),
      customer: _optionalString(json['customer']),
      customerName: _optionalString(json['customer_name']),
    );
  }
}

/// The whole `list_staff_for_orders` response.
class StaffOrderEmployeeList {
  /// False when HRMS is not installed: there are no Employees to choose from,
  /// which is an explanation for the operator, not an error.
  final bool hrmsAvailable;
  final List<StaffOrderEmployee> employees;

  const StaffOrderEmployeeList({
    required this.hrmsAvailable,
    required this.employees,
  });

  factory StaffOrderEmployeeList.fromJson(Map<String, dynamic> json) {
    return StaffOrderEmployeeList(
      // Absent means an older payload that predates the flag; assume HRMS.
      hrmsAvailable: json.containsKey('hrms_available')
          ? _bool(json['hrms_available'])
          : true,
      employees: _maps(json['employees'])
          .map(StaffOrderEmployee.fromJson)
          .where((row) => row.employee.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// `ensure_staff_customer`: the Customer the order must be placed on.
class StaffCustomerEnsureResult {
  final bool created;

  /// `existing`, `adopted` or `created`.
  final String action;

  /// Same keys as a `search_customers` row, so it goes straight into
  /// `PosNotifier.selectCustomer`.
  final Map<String, dynamic> customer;

  const StaffCustomerEnsureResult({
    required this.created,
    required this.action,
    required this.customer,
  });

  String get customerId => _string(customer['name']);

  factory StaffCustomerEnsureResult.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'];
    final action = _string(json['action']);
    return StaffCustomerEnsureResult(
      created: _bool(json['created']) || action == 'created',
      action: action,
      customer: rawCustomer is Map
          ? Map<String, dynamic>.from(rawCustomer)
          : <String, dynamic>{},
    );
  }
}

/// One employee named in a `sync_staff_customers` bucket.
class StaffCustomerSyncEntry {
  final String employee;
  final String employeeName;
  final String customer;

  /// Only set for skipped rows.
  final String reason;

  /// Only set for conflicts: every Customer that matched this employee.
  final List<String> customers;

  const StaffCustomerSyncEntry({
    required this.employee,
    this.employeeName = '',
    this.customer = '',
    this.reason = '',
    this.customers = const [],
  });

  String get displayName => employeeName.isNotEmpty ? employeeName : employee;

  /// Bucket entries are maps, but a bare employee id is accepted as well.
  factory StaffCustomerSyncEntry.fromDynamic(dynamic raw) {
    if (raw is! Map) {
      return StaffCustomerSyncEntry(employee: _string(raw));
    }
    final json = Map<String, dynamic>.from(raw);
    final rawCustomers = json['customers'];
    return StaffCustomerSyncEntry(
      employee: _string(json['employee']),
      employeeName: _string(json['employee_name']),
      customer: _string(json['customer']),
      reason: _string(json['reason']),
      customers: rawCustomers is List
          ? rawCustomers
                .map(
                  (entry) => entry is Map
                      ? _string(entry['customer_name'] ?? entry['name'])
                      : _string(entry),
                )
                .where((name) => name.isNotEmpty)
                .toList(growable: false)
          : const [],
    );
  }
}

/// The `sync_staff_customers` report.
class StaffCustomerSyncResult {
  final List<StaffCustomerSyncEntry> created;
  final List<StaffCustomerSyncEntry> adopted;
  final List<StaffCustomerSyncEntry> existing;
  final List<StaffCustomerSyncEntry> skipped;
  final List<StaffCustomerSyncEntry> conflicts;

  const StaffCustomerSyncResult({
    this.created = const [],
    this.adopted = const [],
    this.existing = const [],
    this.skipped = const [],
    this.conflicts = const [],
  });

  static List<StaffCustomerSyncEntry> _entries(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map(StaffCustomerSyncEntry.fromDynamic)
        .where((entry) => entry.employee.isNotEmpty)
        .toList(growable: false);
  }

  factory StaffCustomerSyncResult.fromJson(Map<String, dynamic> json) {
    return StaffCustomerSyncResult(
      created: _entries(json['created']),
      adopted: _entries(json['adopted']),
      existing: _entries(json['existing']),
      skipped: _entries(json['skipped']),
      conflicts: _entries(json['conflicts']),
    );
  }
}
