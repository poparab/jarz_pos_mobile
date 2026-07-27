class ShiftMonitorResponse {
  const ShiftMonitorResponse({
    required this.summary,
    required this.filters,
    required this.profiles,
    required this.shifts,
  });

  final ShiftMonitorSummary summary;
  final ShiftMonitorFilters filters;
  final List<ShiftMonitorProfileOption> profiles;
  final List<ShiftMonitorShift> shifts;

  factory ShiftMonitorResponse.fromJson(Map<String, dynamic> json) {
    return ShiftMonitorResponse(
      summary: ShiftMonitorSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? const {}),
      ),
      filters: ShiftMonitorFilters.fromJson(
        Map<String, dynamic>.from(json['filters'] as Map? ?? const {}),
      ),
      profiles: (json['profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => ShiftMonitorProfileOption.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(),
      shifts: (json['shifts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (entry) =>
                ShiftMonitorShift.fromJson(Map<String, dynamic>.from(entry)),
          )
          .toList(),
    );
  }
}

class ShiftMonitorSummary {
  const ShiftMonitorSummary({
    required this.openCount,
    required this.closedCount,
    required this.discrepancyCount,
    required this.discrepancyTotal,
  });

  final int openCount;
  final int closedCount;
  final int discrepancyCount;
  final double discrepancyTotal;

  factory ShiftMonitorSummary.fromJson(Map<String, dynamic> json) {
    return ShiftMonitorSummary(
      openCount: (json['open_count'] as num?)?.toInt() ?? 0,
      closedCount: (json['closed_count'] as num?)?.toInt() ?? 0,
      discrepancyCount: (json['discrepancy_count'] as num?)?.toInt() ?? 0,
      discrepancyTotal: (json['discrepancy_total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ShiftMonitorFilters {
  const ShiftMonitorFilters({
    this.fromDate,
    this.toDate,
    this.status,
    this.posProfile,
  });

  final String? fromDate;
  final String? toDate;
  final String? status;
  final String? posProfile;

  factory ShiftMonitorFilters.fromJson(Map<String, dynamic> json) {
    return ShiftMonitorFilters(
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      status: json['status']?.toString(),
      posProfile: json['pos_profile']?.toString(),
    );
  }
}

class ShiftMonitorProfileOption {
  const ShiftMonitorProfileOption({required this.name, required this.title});

  final String name;
  final String title;

  factory ShiftMonitorProfileOption.fromJson(Map<String, dynamic> json) {
    return ShiftMonitorProfileOption(
      name: (json['name'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
    );
  }
}

class ShiftMonitorShift {
  const ShiftMonitorShift({
    required this.posProfile,
    required this.company,
    required this.shiftStatus,
    required this.openingEntry,
    required this.closingEntry,
    required this.openedAt,
    required this.openedByUser,
    required this.openedByFullName,
    required this.openedByEmployee,
    required this.openedByEmployeeName,
    required this.closedAt,
    required this.closedByUser,
    required this.closedByFullName,
    required this.closedByEmployee,
    required this.closedByEmployeeName,
    required this.cashAccount,
    required this.openingAmount,
    required this.expectedClosingAmount,
    required this.actualClosingAmount,
    required this.differenceAmount,
    required this.differenceKind,
    required this.journalEntry,
  });

  final String posProfile;
  final String? company;
  final String shiftStatus;
  final String openingEntry;
  final String? closingEntry;
  final DateTime? openedAt;
  final String? openedByUser;
  final String? openedByFullName;
  final String? openedByEmployee;
  final String? openedByEmployeeName;
  final DateTime? closedAt;
  final String? closedByUser;
  final String? closedByFullName;
  final String? closedByEmployee;
  final String? closedByEmployeeName;
  final String? cashAccount;
  final double openingAmount;
  final double? expectedClosingAmount;
  final double? actualClosingAmount;
  final double? differenceAmount;
  final String differenceKind;
  final String? journalEntry;

  bool get isOpen => shiftStatus == 'open';
  bool get isClosed => shiftStatus == 'closed';
  bool get hasDiscrepancy => (differenceAmount ?? 0) != 0;

  String get openerLabel =>
      openedByEmployeeName ?? openedByFullName ?? openedByUser ?? '';

  String get closerLabel =>
      closedByEmployeeName ?? closedByFullName ?? closedByUser ?? '';

  factory ShiftMonitorShift.fromJson(Map<String, dynamic> json) {
    return ShiftMonitorShift(
      posProfile: (json['pos_profile'] ?? '').toString(),
      company: json['company']?.toString(),
      shiftStatus: (json['shift_status'] ?? 'open').toString(),
      openingEntry: (json['opening_entry'] ?? '').toString(),
      closingEntry: json['closing_entry']?.toString(),
      openedAt: _parseDateTime(json['opened_at']),
      openedByUser: json['opened_by_user']?.toString(),
      openedByFullName: json['opened_by_full_name']?.toString(),
      openedByEmployee: json['opened_by_employee']?.toString(),
      openedByEmployeeName: json['opened_by_employee_name']?.toString(),
      closedAt: _parseDateTime(json['closed_at']),
      closedByUser: json['closed_by_user']?.toString(),
      closedByFullName: json['closed_by_full_name']?.toString(),
      closedByEmployee: json['closed_by_employee']?.toString(),
      closedByEmployeeName: json['closed_by_employee_name']?.toString(),
      cashAccount: json['cash_account']?.toString(),
      openingAmount: (json['opening_amount'] as num?)?.toDouble() ?? 0,
      expectedClosingAmount: (json['expected_closing_amount'] as num?)
          ?.toDouble(),
      actualClosingAmount: (json['actual_closing_amount'] as num?)?.toDouble(),
      differenceAmount: (json['difference_amount'] as num?)?.toDouble(),
      differenceKind: (json['difference_kind'] ?? 'none').toString(),
      journalEntry: json['journal_entry']?.toString(),
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

/// What a manager needs to know before closing somebody else's shift: whose it
/// is, which payment modes need a count, and whether courier balances are still
/// outstanding on that branch.
class ForceClosePreview {
  const ForceClosePreview({
    required this.openingEntry,
    required this.posProfile,
    required this.user,
    required this.userFullName,
    required this.isCurrentUser,
    required this.modesOfPayment,
    required this.expectedAmount,
    required this.courierBlocked,
    required this.courierTransactionCount,
    required this.courierInvoiceCount,
  });

  final String openingEntry;
  final String posProfile;
  final String user;
  final String userFullName;
  final bool isCurrentUser;
  final List<String> modesOfPayment;
  final double expectedAmount;
  final bool courierBlocked;
  final int courierTransactionCount;
  final int courierInvoiceCount;

  factory ForceClosePreview.fromJson(Map<String, dynamic> json) {
    final courier = Map<String, dynamic>.from(
      json['courier_block'] as Map? ?? const {},
    );
    final modes = (json['modes_of_payment'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    return ForceClosePreview(
      openingEntry: (json['opening_entry'] ?? '').toString(),
      posProfile: (json['pos_profile'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      userFullName: (json['user_full_name'] ?? json['user'] ?? '').toString(),
      isCurrentUser: json['is_current_user'] == true || json['is_current_user'] == 1,
      // A profile with no configured modes still needs one cash count row.
      modesOfPayment: modes.isEmpty ? const ['Cash'] : modes,
      expectedAmount: (json['expected_amount'] as num?)?.toDouble() ?? 0,
      courierBlocked: courier['blocked'] == true || courier['blocked'] == 1,
      courierTransactionCount:
          (courier['transaction_count'] as num?)?.toInt() ?? 0,
      courierInvoiceCount: (courier['invoice_count'] as num?)?.toInt() ?? 0,
    );
  }
}
