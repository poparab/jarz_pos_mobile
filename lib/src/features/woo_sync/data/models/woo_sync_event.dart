/// A single `WooCommerce Sync Event` row, as returned by
/// `sync_events.get_events` / embedded in `sync_events.get_dashboard`.
///
/// Field names mirror `EVENT_LIST_FIELDS` in
/// `jarz_woocommerce_integration/api/sync_events.py` exactly (snake_case on
/// the wire, camelCase here). Kept as a plain class (no Freezed/build_runner)
/// to match the hand-rolled-model style already used by `cash_transfer`.
class WooSyncEvent {
  final String name;
  final String direction;
  final String eventType;
  final String status;
  final String priority;
  final String? firstSeenOn;
  final String? nextAttemptAt;
  final int attemptCount;
  final int maxAttempts;
  final String? objectType;
  final String? sourceId;
  final int? wooOrderId;
  final String? wooCustomerId;
  final String? localDoctype;
  final String? localDocname;
  final String? reviewState;
  final bool isRetentionExempt;
  final String? retainUntil;
  final String? lastOperation;
  final String? lastOperationOn;
  final String? manualReviewReason;
  final String? lastError;
  final String? modified;

  const WooSyncEvent({
    required this.name,
    required this.direction,
    required this.eventType,
    required this.status,
    required this.priority,
    this.firstSeenOn,
    this.nextAttemptAt,
    this.attemptCount = 0,
    this.maxAttempts = 0,
    this.objectType,
    this.sourceId,
    this.wooOrderId,
    this.wooCustomerId,
    this.localDoctype,
    this.localDocname,
    this.reviewState,
    this.isRetentionExempt = false,
    this.retainUntil,
    this.lastOperation,
    this.lastOperationOn,
    this.manualReviewReason,
    this.lastError,
    this.modified,
  });

  /// Statuses that need an operator's eyes right now: failed outright, kicked
  /// to manual review, or fell out of the retry ladder entirely.
  static const attentionStatuses = {'Failed', 'NeedsReview', 'DeadLetter'};

  /// Statuses that can still be pushed through the retry ladder — mirrors
  /// `RETRYABLE_STATUSES` server-side; `retry_event` rejects anything else.
  static const retryableStatuses = {
    'Pending',
    'RetryScheduled',
    'Failed',
    'NeedsReview',
    'DeadLetter',
  };

  /// Mirrors `REVIEW_STATES` server-side, in the order an operator triages.
  static const reviewStates = ['Open', 'Investigating', 'Resolved', 'Ignored'];

  bool get needsAttention => attentionStatuses.contains(status);
  bool get isRetryable => retryableStatuses.contains(status);
  bool get hasLocalInvoice =>
      localDoctype == 'Sales Invoice' &&
      (localDocname != null && localDocname!.isNotEmpty);

  factory WooSyncEvent.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v == null ? null : (v is int ? v : int.tryParse(v.toString()));
    return WooSyncEvent(
      name: (json['name'] ?? '').toString(),
      direction: (json['direction'] ?? '').toString(),
      eventType: (json['event_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      firstSeenOn: json['first_seen_on']?.toString(),
      nextAttemptAt: json['next_attempt_at']?.toString(),
      attemptCount: asInt(json['attempt_count']) ?? 0,
      maxAttempts: asInt(json['max_attempts']) ?? 0,
      objectType: json['object_type']?.toString(),
      sourceId: json['source_id']?.toString(),
      wooOrderId: asInt(json['woo_order_id']),
      wooCustomerId: json['woo_customer_id']?.toString(),
      localDoctype: json['local_doctype']?.toString(),
      localDocname: json['local_docname']?.toString(),
      reviewState: json['review_state']?.toString(),
      isRetentionExempt: json['is_retention_exempt'] == 1 || json['is_retention_exempt'] == true,
      retainUntil: json['retain_until']?.toString(),
      lastOperation: json['last_operation']?.toString(),
      lastOperationOn: json['last_operation_on']?.toString(),
      manualReviewReason: json['manual_review_reason']?.toString(),
      lastError: json['last_error']?.toString(),
      modified: json['modified']?.toString(),
    );
  }
}
