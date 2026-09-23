/// Queue keys — the wire contract with `jarz_pos.api.approvals`. A key this
/// build does not know is dropped rather than rendered, so a queue added on the
/// server later never shows up here as a nameless row that goes nowhere.
class PendingApprovalKeys {
  static const expenses = 'expenses';
  static const employeeAdvances = 'employee_advances';
  static const itemRequests = 'item_requests';
  static const paymentReceipts = 'payment_receipts';
  static const customShipping = 'custom_shipping';

  /// Task Board: my open cards and open subtasks, and In Review cards I may
  /// approve. Not approvals in the money sense, but work waiting on this user.
  static const tasksAssigned = 'tasks_assigned';
  static const tasksReview = 'tasks_review';

  static const known = {
    expenses,
    employeeAdvances,
    itemRequests,
    paymentReceipts,
    customShipping,
    tasksAssigned,
    tasksReview,
  };
}

/// One approval queue the caller may act on.
class PendingApprovalQueue {
  final String key;
  final int count;

  /// `YYYY-MM` of the oldest waiting item, for the month-paged screens
  /// (Expenses, Advances) that otherwise open on the current month and would
  /// not show a request filed last month.
  final String? oldestMonth;

  const PendingApprovalQueue({
    required this.key,
    required this.count,
    this.oldestMonth,
  });

  factory PendingApprovalQueue.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final month = json['oldest_month']?.toString().trim() ?? '';
    return PendingApprovalQueue(
      key: json['key']?.toString() ?? '',
      count: asInt(json['count']),
      oldestMonth: month.isEmpty ? null : month,
    );
  }
}

/// Everything awaiting the signed-in user's decision.
class PendingApprovals {
  /// False when the user may act on no queue at all; polling stops then.
  final bool eligible;
  final List<PendingApprovalQueue> queues;
  final DateTime fetchedAt;

  const PendingApprovals({
    required this.eligible,
    required this.queues,
    required this.fetchedAt,
  });

  /// Only the queues with something in them — what the menu shows.
  List<PendingApprovalQueue> get waiting =>
      queues.where((q) => q.count > 0).toList(growable: false);

  /// Summed on the client from the rows it can render, so the badge on the
  /// menu button always equals the rows under it.
  int get total => waiting.fold(0, (sum, q) => sum + q.count);

  factory PendingApprovals.fromJson(Map<String, dynamic> json) {
    final raw = json['queues'];
    final queues = (raw is List ? raw : const [])
        .whereType<Map>()
        .map((e) => PendingApprovalQueue.fromJson(Map<String, dynamic>.from(e)))
        .where((q) => PendingApprovalKeys.known.contains(q.key))
        .toList(growable: false);
    return PendingApprovals(
      eligible: json['eligible'] == true,
      queues: queues,
      fetchedAt: DateTime.now(),
    );
  }
}
