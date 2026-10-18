/// Payload of `jarz_pos.api.crm.get_active_accounts`: the accounts at the
/// "Active" pipeline stage with the handful of numbers a rep wants at a glance.
///
/// Hand-written (no Freezed) on purpose: every number may arrive as an int or a
/// double, any of them may be null, and nothing here is round-tripped back to
/// the server, so tolerant parsing beats codegen.
library;

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v == null) return 0;
  return double.tryParse(v.toString()) ?? 0;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _toInt(dynamic v) {
  if (v is num) return v.round();
  if (v == null) return 0;
  return int.tryParse(v.toString()) ?? 0;
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}

/// Non-empty trimmed string, or null.
String? _toStrOrNull(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Reorder status values the backend sends.
abstract final class B2bReorderStatus {
  static const overdue = 'overdue';
  static const dueSoon = 'due_soon';
  static const ok = 'ok';
}

/// Alert codes carried in [B2bActiveAccount.alerts].
abstract final class B2bActiveAlert {
  static const reorderOverdue = 'reorder_overdue';
  static const oldUnpaid = 'old_unpaid';
  static const labels = 'labels';
  static const noCustomer = 'no_customer';
}

class B2bActiveSummary {
  final int accounts;
  final int periodOrders;
  final double periodBilled;
  final double prevPeriodBilled;

  /// Percent change of billed vs the previous period; null when there is
  /// nothing to compare against.
  final double? periodChangePct;
  final double outstanding;
  final int reorderDue;
  final int needsAttention;

  const B2bActiveSummary({
    this.accounts = 0,
    this.periodOrders = 0,
    this.periodBilled = 0,
    this.prevPeriodBilled = 0,
    this.periodChangePct,
    this.outstanding = 0,
    this.reorderDue = 0,
    this.needsAttention = 0,
  });

  factory B2bActiveSummary.fromJson(Map<String, dynamic> json) =>
      B2bActiveSummary(
        accounts: _toInt(json['accounts']),
        periodOrders: _toInt(json['period_orders']),
        periodBilled: _toDouble(json['period_billed']),
        prevPeriodBilled: _toDouble(json['prev_period_billed']),
        periodChangePct: _toDoubleOrNull(json['period_change_pct']),
        outstanding: _toDouble(json['outstanding']),
        reorderDue: _toInt(json['reorder_due']),
        needsAttention: _toInt(json['needs_attention']),
      );
}

class B2bActiveAccount {
  /// `Lead` or `Opportunity`.
  final String doctype;
  final String name;
  final String title;
  final String? customer;
  final String? customerName;
  final String? owner;
  final String? mobileNo;
  final String? territory;

  // Lifetime.
  final int orders;
  final double billed;
  final double avgOrderValue;

  // Selected period vs the one before it.
  final int periodOrders;
  final double periodBilled;
  final double prevPeriodBilled;
  final double? periodChangePct;

  // Ordering rhythm.
  final String? firstOrderDate;
  final String? lastOrderDate;
  final int? daysSinceLastOrder;
  final double? avgOrderCycleDays;
  final String? predictedNextOrder;

  /// `overdue` | `due_soon` | `ok` | null (not enough history).
  final String? reorderStatus;

  // Money owed.
  final double outstanding;
  final int? oldestUnpaidDays;

  /// Labels alert flag (printed-label stock needs attention). 0 = none.
  final int labelAlert;

  // Follow-up context.
  final String? lastJourneyDate;
  final String? lastJourneyNote;
  final String? nextActionDate;
  final String? nextAction;

  final List<String> alerts;

  const B2bActiveAccount({
    required this.doctype,
    required this.name,
    required this.title,
    this.customer,
    this.customerName,
    this.owner,
    this.mobileNo,
    this.territory,
    this.orders = 0,
    this.billed = 0,
    this.avgOrderValue = 0,
    this.periodOrders = 0,
    this.periodBilled = 0,
    this.prevPeriodBilled = 0,
    this.periodChangePct,
    this.firstOrderDate,
    this.lastOrderDate,
    this.daysSinceLastOrder,
    this.avgOrderCycleDays,
    this.predictedNextOrder,
    this.reorderStatus,
    this.outstanding = 0,
    this.oldestUnpaidDays,
    this.labelAlert = 0,
    this.lastJourneyDate,
    this.lastJourneyNote,
    this.nextActionDate,
    this.nextAction,
    this.alerts = const [],
  });

  factory B2bActiveAccount.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final rawAlerts = json['alerts'];
    return B2bActiveAccount(
      doctype: (json['doctype'] ?? 'Lead').toString(),
      name: name,
      title: _toStrOrNull(json['title']) ?? name,
      customer: _toStrOrNull(json['customer']),
      customerName: _toStrOrNull(json['customer_name']),
      owner: _toStrOrNull(json['owner']),
      mobileNo: _toStrOrNull(json['mobile_no']),
      territory: _toStrOrNull(json['territory']),
      orders: _toInt(json['orders']),
      billed: _toDouble(json['billed']),
      avgOrderValue: _toDouble(json['avg_order_value']),
      periodOrders: _toInt(json['period_orders']),
      periodBilled: _toDouble(json['period_billed']),
      prevPeriodBilled: _toDouble(json['prev_period_billed']),
      periodChangePct: _toDoubleOrNull(json['period_change_pct']),
      firstOrderDate: _toStrOrNull(json['first_order_date']),
      lastOrderDate: _toStrOrNull(json['last_order_date']),
      daysSinceLastOrder: _toIntOrNull(json['days_since_last_order']),
      avgOrderCycleDays: _toDoubleOrNull(json['avg_order_cycle_days']),
      predictedNextOrder: _toStrOrNull(json['predicted_next_order']),
      reorderStatus: _toStrOrNull(json['reorder_status']),
      outstanding: _toDouble(json['outstanding']),
      oldestUnpaidDays: _toIntOrNull(json['oldest_unpaid_days']),
      labelAlert: _toInt(json['label_alert']),
      lastJourneyDate: _toStrOrNull(json['last_journey_date']),
      lastJourneyNote: _toStrOrNull(json['last_journey_note']),
      nextActionDate: _toStrOrNull(json['next_action_date']),
      nextAction: _toStrOrNull(json['next_action']),
      alerts: rawAlerts is List
          ? [for (final a in rawAlerts) a.toString()]
          : const <String>[],
    );
  }

  bool hasAlert(String code) => alerts.contains(code);

  /// Anything that deserves the rep's eyes first.
  bool get needsAttention => alerts.isNotEmpty;

  bool get reorderDue =>
      reorderStatus == B2bReorderStatus.overdue ||
      reorderStatus == B2bReorderStatus.dueSoon;
}

class B2bActiveAccounts {
  final String? today;
  final int periodDays;
  final String? periodStart;
  final B2bActiveSummary summary;
  final List<B2bActiveAccount> accounts;

  const B2bActiveAccounts({
    this.today,
    this.periodDays = 30,
    this.periodStart,
    this.summary = const B2bActiveSummary(),
    this.accounts = const [],
  });

  factory B2bActiveAccounts.fromJson(Map<String, dynamic> json) {
    final rawAccounts = json['accounts'];
    final rawSummary = json['summary'];
    return B2bActiveAccounts(
      today: _toStrOrNull(json['today']),
      periodDays: _toIntOrNull(json['period_days']) ?? 30,
      periodStart: _toStrOrNull(json['period_start']),
      summary: rawSummary is Map
          ? B2bActiveSummary.fromJson(Map<String, dynamic>.from(rawSummary))
          : const B2bActiveSummary(),
      accounts: rawAccounts is List
          ? [
              for (final a in rawAccounts)
                if (a is Map)
                  B2bActiveAccount.fromJson(Map<String, dynamic>.from(a)),
            ]
          : const <B2bActiveAccount>[],
    );
  }
}
