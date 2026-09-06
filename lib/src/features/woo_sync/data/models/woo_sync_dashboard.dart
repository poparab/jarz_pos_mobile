import 'woo_sync_event.dart';

/// The outbound circuit-breaker state, from `sync_events._get_breaker_state`.
///
/// `isOpen` is the single most important bit on this whole console: while the
/// breaker is open, every outbound push is paused after a run of failures
/// against the live Woo store, and nothing will move until it clears (or an
/// operator clears it by hand).
class WooBreakerState {
  final int failureCount;
  final String? openUntil;
  final bool isOpen;

  const WooBreakerState({
    this.failureCount = 0,
    this.openUntil,
    this.isOpen = false,
  });

  factory WooBreakerState.fromJson(Map<String, dynamic> json) {
    return WooBreakerState(
      failureCount: (json['failure_count'] as num?)?.toInt() ?? 0,
      openUntil: json['open_until']?.toString(),
      isOpen: json['is_open'] == true,
    );
  }
}

/// Backlog depth summary from `get_dashboard`.
class WooSyncBacklog {
  final int pending;
  final int retryScheduled;
  final int processing;
  final int needsAttention;
  final int dueNow;
  final String? oldestDue;
  final int expiredProcessing;

  const WooSyncBacklog({
    this.pending = 0,
    this.retryScheduled = 0,
    this.processing = 0,
    this.needsAttention = 0,
    this.dueNow = 0,
    this.oldestDue,
    this.expiredProcessing = 0,
  });

  factory WooSyncBacklog.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => (v as num?)?.toInt() ?? 0;
    return WooSyncBacklog(
      pending: asInt(json['pending']),
      retryScheduled: asInt(json['retry_scheduled']),
      processing: asInt(json['processing']),
      needsAttention: asInt(json['needs_attention']),
      dueNow: asInt(json['due_now']),
      oldestDue: json['oldest_due']?.toString(),
      expiredProcessing: asInt(json['expired_processing']),
    );
  }
}

/// Full payload of `sync_events.get_dashboard`.
class WooSyncDashboard {
  final String? generatedAt;
  final int windowHours;
  final Map<String, dynamic> settings;
  final WooBreakerState breaker;
  final Map<String, dynamic> shadowFailures;
  final WooSyncBacklog backlog;
  final Map<String, int> statusCounts;
  final Map<String, int> reviewStateCounts;
  final Map<String, int> directionCounts;
  final Map<String, int> eventTypeCounts;
  final List<WooSyncEvent> attentionEvents;
  final List<WooSyncEvent> recentEvents;

  const WooSyncDashboard({
    this.generatedAt,
    this.windowHours = 24,
    this.settings = const {},
    this.breaker = const WooBreakerState(),
    this.shadowFailures = const {},
    this.backlog = const WooSyncBacklog(),
    this.statusCounts = const {},
    this.reviewStateCounts = const {},
    this.directionCounts = const {},
    this.eventTypeCounts = const {},
    this.attentionEvents = const [],
    this.recentEvents = const [],
  });

  factory WooSyncDashboard.fromJson(Map<String, dynamic> json) {
    Map<String, int> asCountMap(dynamic v) {
      if (v is! Map) return const {};
      return v.map((key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0));
    }

    List<WooSyncEvent> asEventList(dynamic v) {
      if (v is! List) return const [];
      return v
          .whereType<Map>()
          .map((e) => WooSyncEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return WooSyncDashboard(
      generatedAt: json['generated_at']?.toString(),
      windowHours: (json['window_hours'] as num?)?.toInt() ?? 24,
      settings: json['settings'] is Map ? Map<String, dynamic>.from(json['settings'] as Map) : const {},
      breaker: json['breaker'] is Map
          ? WooBreakerState.fromJson(Map<String, dynamic>.from(json['breaker'] as Map))
          : const WooBreakerState(),
      shadowFailures:
          json['shadow_failures'] is Map ? Map<String, dynamic>.from(json['shadow_failures'] as Map) : const {},
      backlog: json['backlog'] is Map
          ? WooSyncBacklog.fromJson(Map<String, dynamic>.from(json['backlog'] as Map))
          : const WooSyncBacklog(),
      statusCounts: asCountMap(json['status_counts']),
      reviewStateCounts: asCountMap(json['review_state_counts']),
      directionCounts: asCountMap(json['direction_counts']),
      eventTypeCounts: asCountMap(json['event_type_counts']),
      attentionEvents: asEventList(json['attention_events']),
      recentEvents: asEventList(json['recent_events']),
    );
  }
}
