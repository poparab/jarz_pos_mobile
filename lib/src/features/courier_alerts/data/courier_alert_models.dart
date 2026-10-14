/// Models for `jarz_courier.api.alerts.*` (courier anomaly alerts).
///
/// Parsing is defensive: the endpoint ships from another app, so a missing or
/// oddly typed field degrades to a blank/zero rather than breaking the list.
library;

enum CourierAlertSeverity { low, medium, high }

enum CourierAlertStatus { open, reviewed, dismissed }

/// The anomaly types `jarz_courier.constants.ANOMALY_TYPE` can emit.
/// An unknown label from a newer server is shown as the raw string.
const knownCourierAnomalyTypes = <String>[
  'Detour',
  'Excessive Idle',
  'Speeding',
  'Delivered Far From Pin',
  'Ping Gap',
  'Mock GPS',
  'Unexpected Stop',
  'Stale Ping',
  'Tracker Mode Changed',
  'Tracking Lost',
  'Action Refused',
  'Delivery Code Failed',
];

class CourierAlert {
  const CourierAlert({
    required this.name,
    required this.anomalyType,
    required this.severity,
    required this.status,
    this.detectedOn,
    this.partyType,
    this.party,
    this.partyName,
    this.branch,
    this.invoice,
    this.run,
    this.details,
    this.reviewNote,
  });

  /// The Courier Anomaly document name.
  final String name;
  final String anomalyType;
  final CourierAlertSeverity severity;
  final CourierAlertStatus status;
  final DateTime? detectedOn;
  final String? partyType;
  final String? party;
  final String? partyName;
  final String? branch;
  final String? invoice;
  final String? run;
  final String? details;
  final String? reviewNote;

  bool get isOpen => status == CourierAlertStatus.open;

  /// Best label for the courier: the display name, else the party id.
  String? get courierLabel => partyName ?? party;

  factory CourierAlert.fromJson(Map<String, dynamic> json) => CourierAlert(
    name: (json['name'] ?? '').toString().trim(),
    anomalyType: (json['anomaly_type'] ?? '').toString().trim(),
    severity: parseCourierAlertSeverity(json['severity']),
    status: parseCourierAlertStatus(json['status']),
    detectedOn: _parseTime(json['detected_on']),
    partyType: _nullIfBlank(json['party_type']),
    party: _nullIfBlank(json['party']),
    partyName: _nullIfBlank(json['party_name']),
    branch: _nullIfBlank(json['branch']),
    invoice: _nullIfBlank(json['invoice']),
    run: _nullIfBlank(json['run']),
    details: _nullIfBlank(json['details']),
    reviewNote: _nullIfBlank(json['review_note'] ?? json['note']),
  );
}

CourierAlertSeverity parseCourierAlertSeverity(dynamic value) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'high':
      return CourierAlertSeverity.high;
    case 'medium':
      return CourierAlertSeverity.medium;
    default:
      return CourierAlertSeverity.low;
  }
}

CourierAlertStatus parseCourierAlertStatus(dynamic value) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'reviewed':
      return CourierAlertStatus.reviewed;
    case 'dismissed':
      return CourierAlertStatus.dismissed;
    default:
      return CourierAlertStatus.open;
  }
}

/// `{open_count, high_count}`: the drawer badge and the list header.
class CourierAlertCounts {
  const CourierAlertCounts({this.openCount = 0, this.highCount = 0});

  static const zero = CourierAlertCounts();

  final int openCount;
  final int highCount;

  factory CourierAlertCounts.fromJson(Map<String, dynamic> json) =>
      CourierAlertCounts(
        openCount: _toInt(json['open_count']) ?? 0,
        highCount: _toInt(json['high_count']) ?? 0,
      );
}

/// The `list_alerts` answer: the rows plus the open/high totals.
class CourierAlertsResult {
  const CourierAlertsResult({
    this.alerts = const [],
    this.openCount = 0,
    this.highCount = 0,
  });

  final List<CourierAlert> alerts;
  final int openCount;
  final int highCount;

  CourierAlertCounts get counts =>
      CourierAlertCounts(openCount: openCount, highCount: highCount);

  factory CourierAlertsResult.fromJson(Map<String, dynamic> json) {
    final raw = json['alerts'];
    final alerts = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => CourierAlert.fromJson(Map<String, dynamic>.from(e)))
              .where((a) => a.name.isNotEmpty)
              .toList()
        : <CourierAlert>[];
    return CourierAlertsResult(
      alerts: alerts,
      openCount: _toInt(json['open_count']) ?? 0,
      highCount: _toInt(json['high_count']) ?? 0,
    );
  }
}

DateTime? _parseTime(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : DateTime.tryParse(text);
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
