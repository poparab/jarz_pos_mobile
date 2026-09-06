/// The filter dimensions `sync_events.get_events` accepts, plus the free-text
/// `search` it also matches against `name`/`source_id`/`local_docname`/
/// `manual_review_reason` (and `woo_order_id` when the search is numeric).
class WooSyncFilters {
  final String? status;
  final String? direction;
  final String? eventType;
  final String? reviewState;
  final String search;

  /// When true, the event list is restricted to the attention statuses
  /// (`Failed`, `NeedsReview`, `DeadLetter`) regardless of [status] — the
  /// console's default view, so the backlog is the first thing an operator
  /// sees rather than a firehose of healthy events.
  final bool attentionOnly;

  const WooSyncFilters({
    this.status,
    this.direction,
    this.eventType,
    this.reviewState,
    this.search = '',
    this.attentionOnly = true,
  });

  bool get isEmpty =>
      status == null &&
      direction == null &&
      eventType == null &&
      reviewState == null &&
      search.isEmpty &&
      !attentionOnly;

  WooSyncFilters copyWith({
    String? status,
    bool clearStatus = false,
    String? direction,
    bool clearDirection = false,
    String? eventType,
    bool clearEventType = false,
    String? reviewState,
    bool clearReviewState = false,
    String? search,
    bool? attentionOnly,
  }) {
    return WooSyncFilters(
      status: clearStatus ? null : (status ?? this.status),
      direction: clearDirection ? null : (direction ?? this.direction),
      eventType: clearEventType ? null : (eventType ?? this.eventType),
      reviewState: clearReviewState ? null : (reviewState ?? this.reviewState),
      search: search ?? this.search,
      attentionOnly: attentionOnly ?? this.attentionOnly,
    );
  }
}
