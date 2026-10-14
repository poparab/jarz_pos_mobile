/// Reply of `jarz_courier.api.timeline.get_order_timeline(invoice_id)`.
///
/// Hand-written and tolerant like the other courier-launch models: a field the
/// server omits degrades to "not there" instead of throwing, and an event or
/// segment key the app does not know yet still renders from the server label.
class OrderTimeline {
  const OrderTimeline({
    required this.invoice,
    this.courierName,
    this.courierParty,
    this.events = const [],
    this.segments = const [],
    this.totalMinutes,
  });

  final String invoice;
  final String? courierName;
  final String? courierParty;
  final List<TimelineEvent> events;
  final List<TimelineSegment> segments;
  final int? totalMinutes;

  bool get isEmpty => events.isEmpty && segments.isEmpty;

  /// Events that carry a usable coordinate (for the small map).
  List<TimelineEvent> get locatedEvents =>
      events.where((e) => e.hasLocation).toList(growable: false);

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    final courier = json['courier'];
    String? courierName;
    String? courierParty;
    if (courier is Map) {
      courierName = _text(courier['name']);
      courierParty = _text(courier['party']);
    }
    return OrderTimeline(
      invoice: _text(json['invoice']) ?? '',
      courierName: courierName,
      courierParty: courierParty,
      events: _list(json['events'])
          .map(TimelineEvent.fromJson)
          .toList(growable: false),
      segments: _list(json['segments'])
          .map(TimelineSegment.fromJson)
          .toList(growable: false),
      totalMinutes: _int(json['total_minutes']),
    );
  }
}

/// Event keys the server sends today.
abstract final class TimelineEventKey {
  static const created = 'created';
  static const accepted = 'accepted';
  static const inProgress = 'in_progress';
  static const outForDelivery = 'out_for_delivery';
  static const leftBranch = 'left_branch';
  static const legStarted = 'leg_started';
  static const arrived = 'arrived';
  static const delivered = 'delivered';
  static const failed = 'failed';
  static const backAtBranch = 'back_at_branch';
}

/// Segment keys the server sends today.
abstract final class TimelineSegmentKey {
  static const prep = 'prep';
  static const dispatchWait = 'dispatch_wait';
  static const travel = 'travel';
  static const atDoor = 'at_door';
  static const returnTrip = 'return';
}

class TimelineEvent {
  const TimelineEvent({
    required this.key,
    required this.label,
    this.at,
    this.latitude,
    this.longitude,
    this.source,
  });

  final String key;

  /// The server's own label (English) — the fallback for an unknown [key].
  final String label;

  /// Parsed instant, null when the server sent nothing parseable.
  final DateTime? at;
  final double? latitude;
  final double? longitude;
  final String? source;

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      !(latitude == 0 && longitude == 0);

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final key = _text(json['key']) ?? '';
    return TimelineEvent(
      key: key,
      label: _text(json['label']) ?? key,
      at: _dateTime(json['at']),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      source: _text(json['source']),
    );
  }
}

class TimelineSegment {
  const TimelineSegment({
    required this.key,
    required this.label,
    this.from,
    this.to,
    this.minutes,
    this.targetMinutes,
    this.over = false,
  });

  final String key;
  final String label;
  final DateTime? from;
  final DateTime? to;
  final int? minutes;
  final int? targetMinutes;

  /// True when [minutes] exceeded [targetMinutes].
  final bool over;

  factory TimelineSegment.fromJson(Map<String, dynamic> json) {
    final key = _text(json['key']) ?? '';
    final over = json['over'];
    return TimelineSegment(
      key: key,
      label: _text(json['label']) ?? key,
      from: _dateTime(json['from']),
      to: _dateTime(json['to']),
      minutes: _int(json['minutes']),
      targetMinutes: _int(json['target_minutes']),
      over: over == true || over == 1 || over == '1' || over == 'true',
    );
  }
}

Iterable<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((m) => Map<String, dynamic>.from(m));
}

String? _text(Object? value) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty ? null : s;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value.trim()) ?? double.tryParse(value.trim())?.round();
  return null;
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Frappe sends `YYYY-MM-DD HH:MM:SS[.ffffff]` (site time, no zone); an ISO
/// string with a zone also parses. Kept as-is, never shifted: the clock time the
/// server printed is the clock time staff should read.
DateTime? _dateTime(Object? value) {
  final text = _text(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}
