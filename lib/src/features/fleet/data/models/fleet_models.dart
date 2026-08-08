import 'package:latlong2/latlong.dart';

/// Fallback TTL used when the payload carries none (or a nonsense one).
///
/// Matches the backend default for `get_live_positions`. A position lives in
/// Redis for this long; past it there is nothing left to read.
const Duration kFleetDefaultTtl = Duration(seconds: 900);

/// How much of a position's TTL has burned off.
///
/// This is the single most important thing this screen communicates: a fix
/// approaching its TTL is nearly worthless, and a dispatcher who treats a
/// 14-minute-old dot as live will send a courier to the wrong place.
enum FleetFreshness {
  /// Under a third of the TTL — safe to act on.
  fresh,

  /// Between a third and two thirds of the TTL — the courier has moved since.
  ageing,

  /// Past two thirds of the TTL (or beyond it entirely) — do not rely on it.
  stale,
}

/// Buckets [age] against [ttl] using thirds.
///
/// With the backend's 900 s default that reads as: fresh under 5 min, ageing
/// 5–10 min, stale past 10 min.
FleetFreshness fleetFreshnessFor(Duration age, Duration ttl) {
  final effectiveTtl = ttl.inSeconds > 0 ? ttl : kFleetDefaultTtl;
  if (age < effectiveTtl * (1 / 3)) return FleetFreshness.fresh;
  if (age < effectiveTtl * (2 / 3)) return FleetFreshness.ageing;
  return FleetFreshness.stale;
}

/// The lower bound (inclusive) of a freshness bucket, for the legend.
Duration fleetFreshnessThreshold(FleetFreshness freshness, Duration ttl) {
  final effectiveTtl = ttl.inSeconds > 0 ? ttl : kFleetDefaultTtl;
  return switch (freshness) {
    FleetFreshness.fresh => Duration.zero,
    FleetFreshness.ageing => effectiveTtl * (1 / 3),
    FleetFreshness.stale => effectiveTtl * (2 / 3),
  };
}

/// One courier as the tracking API reports them right now.
///
/// A courier can appear here **without** a usable fix: the backend accepts
/// several spellings and an older app build in the wild still posts the old
/// one, so anything unparseable lands as [point] `null` rather than blowing up
/// the whole response. That distinction is load-bearing — "on shift with no
/// position" and "not on shift at all" are different problems for a dispatcher.
class CourierPosition {
  const CourierPosition({
    required this.id,
    required this.displayName,
    required this.branch,
    required this.point,
    required this.timestamp,
    required this.accuracyMeters,
    required this.branchAsOf,
    required this.ttl,
    required this.fetchedAt,
  });

  /// Stable identity used to keep the detail sheet pinned to the same courier
  /// across polls. Never shown to the user on its own.
  final String id;

  /// Courier name, falling back to [id] when the payload carries no name.
  final String displayName;

  /// Branch the position was grouped under; empty when the payload had none.
  final String branch;

  /// Null when the courier reported no parseable coordinates.
  final LatLng? point;

  /// When the fix was taken, per the server clock.
  final DateTime? timestamp;

  /// Reported GPS accuracy radius in metres, when the device sent one.
  final double? accuracyMeters;

  /// The server's own clock at response time, copied down from the branch
  /// group. Used to age the fix without trusting the device clock.
  final DateTime? branchAsOf;

  /// TTL in force for this position.
  final Duration ttl;

  /// Device clock at the moment the response landed.
  final DateTime fetchedAt;

  /// Whether this courier can be drawn on the map at all.
  bool get hasFix => point != null;

  /// How old the fix is at [now].
  ///
  /// Prefers `as_of - ts`, which is a difference between two *server*
  /// timestamps and therefore survives a device whose clock is wrong — shared
  /// shop hardware routinely is. Only the elapsed time since the response
  /// landed comes from the local clock, and that part cannot drift far.
  Duration? ageAt(DateTime now) {
    final ts = timestamp;
    if (ts == null) return null;

    final asOf = branchAsOf;
    final age = asOf != null
        ? asOf.difference(ts) + _sinceFetch(now)
        : now.difference(ts);
    return age.isNegative ? Duration.zero : age;
  }

  /// Freshness bucket at [now]; null when the fix carried no timestamp.
  FleetFreshness? freshnessAt(DateTime now) {
    final age = ageAt(now);
    if (age == null) return null;
    return fleetFreshnessFor(age, ttl);
  }

  Duration _sinceFetch(DateTime now) {
    final elapsed = now.difference(fetchedAt);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  factory CourierPosition.fromJson(
    Map<String, dynamic> json, {
    required String branch,
    required DateTime? branchAsOf,
    required Duration ttl,
    required DateTime fetchedAt,
  }) {
    // Both spellings are accepted on the way in by the backend itself, so both
    // can come back out depending on which app build posted the fix.
    final lat = _asDouble(json['lat'] ?? json['latitude']);
    final lng = _asDouble(json['lng'] ?? json['longitude']);

    final id = _firstString(json, const [
      'courier',
      'party',
      'party_name',
      'name',
      'user',
      'employee',
    ]);
    final name = _firstString(json, const [
      'courier_name',
      'party_display_name',
      'full_name',
      'employee_name',
      'name',
    ]);

    return CourierPosition(
      id: id.isNotEmpty ? id : name,
      displayName: name.isNotEmpty ? name : id,
      branch: _firstString(json, const ['branch']).ifEmpty(branch),
      point: _asPoint(lat, lng),
      timestamp: _asDateTime(json['ts'] ?? json['timestamp']),
      accuracyMeters: _asDouble(json['accuracy_m'] ?? json['accuracy']),
      branchAsOf: branchAsOf,
      ttl: ttl,
      fetchedAt: fetchedAt,
    );
  }
}

/// One branch's slice of the response.
class FleetBranchGroup {
  const FleetBranchGroup({
    required this.branch,
    required this.asOf,
    required this.ttl,
    required this.couriers,
  });

  final String branch;
  final DateTime? asOf;
  final Duration ttl;
  final List<CourierPosition> couriers;

  factory FleetBranchGroup.fromJson(
    Map<String, dynamic> json, {
    required Duration fallbackTtl,
    required DateTime fetchedAt,
  }) {
    final branch = _firstString(json, const ['branch']);
    final asOf = _asDateTime(json['as_of']);
    final ttl = _asTtl(json['ttl_seconds']) ?? fallbackTtl;

    return FleetBranchGroup(
      branch: branch,
      asOf: asOf,
      ttl: ttl,
      couriers: (json['couriers'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => CourierPosition.fromJson(
              Map<String, dynamic>.from(entry),
              branch: branch,
              branchAsOf: asOf,
              ttl: ttl,
              fetchedAt: fetchedAt,
            ),
          )
          .toList(),
    );
  }
}

/// Why the map has nothing to draw.
///
/// The two cases have different causes and different fixes, so the screen must
/// never collapse them into one "no data" message.
enum FleetEmptyReason {
  /// The tracking service reports no courier at all in the caller's scope.
  noCouriers,

  /// Couriers are reporting, but not one of them has a usable position yet.
  noPositions,
}

/// A whole `get_live_positions` response, parsed.
class FleetSnapshot {
  const FleetSnapshot({
    required this.branches,
    required this.ttl,
    required this.fetchedAt,
  });

  final List<FleetBranchGroup> branches;

  /// Top-level TTL; per-branch groups may narrow it.
  final Duration ttl;

  /// Device clock when the response landed. Drives "updated N min ago".
  final DateTime fetchedAt;

  /// Every courier the response mentioned, located or not.
  List<CourierPosition> get couriers => [
    for (final group in branches) ...group.couriers,
  ];

  /// Couriers that can actually be drawn.
  List<CourierPosition> get located =>
      couriers.where((courier) => courier.hasFix).toList();

  /// Couriers the service knows about but cannot place.
  List<CourierPosition> get unlocated =>
      couriers.where((courier) => !courier.hasFix).toList();

  /// The most-stale bucket currently on the map, for the header warning.
  FleetFreshness? worstFreshnessAt(DateTime now) {
    FleetFreshness? worst;
    for (final courier in located) {
      final freshness = courier.freshnessAt(now);
      if (freshness == null) continue;
      if (worst == null || freshness.index > worst.index) worst = freshness;
    }
    return worst;
  }

  /// Null when there is something to draw.
  FleetEmptyReason? get emptyReason {
    if (couriers.isEmpty) return FleetEmptyReason.noCouriers;
    if (located.isEmpty) return FleetEmptyReason.noPositions;
    return null;
  }

  /// Parses the documented envelope, tolerating a flat `couriers` list in place
  /// of `branches` so a contract drift degrades to "ungrouped" instead of
  /// "empty map, no explanation".
  factory FleetSnapshot.fromJson(
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final ttl = _asTtl(json['ttl_seconds']) ?? kFleetDefaultTtl;

    final rawBranches = (json['branches'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => FleetBranchGroup.fromJson(
            Map<String, dynamic>.from(entry),
            fallbackTtl: ttl,
            fetchedAt: fetchedAt,
          ),
        )
        .toList();

    if (rawBranches.isEmpty && json['couriers'] is List) {
      final asOf = _asDateTime(json['as_of']);
      rawBranches.add(
        FleetBranchGroup(
          branch: '',
          asOf: asOf,
          ttl: ttl,
          couriers: (json['couriers'] as List<dynamic>)
              .whereType<Map>()
              .map(
                (entry) => CourierPosition.fromJson(
                  Map<String, dynamic>.from(entry),
                  branch: '',
                  branchAsOf: asOf,
                  ttl: ttl,
                  fetchedAt: fetchedAt,
                ),
              )
              .toList(),
        ),
      );
    }

    return FleetSnapshot(
      branches: rawBranches,
      ttl: ttl,
      fetchedAt: fetchedAt,
    );
  }
}

// ── tolerant parsing helpers ────────────────────────────────────────────────

double? _asDouble(dynamic value) {
  if (value is num) {
    final result = value.toDouble();
    return result.isFinite ? result : null;
  }
  if (value is String) {
    final parsed = double.tryParse(value.trim());
    return (parsed != null && parsed.isFinite) ? parsed : null;
  }
  return null;
}

/// Frappe hands back naive `YYYY-MM-DD HH:MM:SS` strings on the site clock,
/// which `DateTime.parse` reads as local time — the same zone the device is in
/// for every branch this app runs in.
DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is! String) return null;
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

Duration? _asTtl(dynamic value) {
  final seconds = _asDouble(value);
  if (seconds == null || seconds <= 0) return null;
  return Duration(seconds: seconds.round());
}

/// Rejects anything that cannot be a real fix.
///
/// Exact 0/0 is the classic "no fix" sentinel a GPS stack emits when it has
/// nothing; drawing a courier in the Gulf of Guinea is worse than admitting we
/// do not know where they are.
LatLng? _asPoint(double? lat, double? lng) {
  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90) return null;
  if (lng < -180 || lng > 180) return null;
  if (lat == 0 && lng == 0) return null;
  return LatLng(lat, lng);
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

extension _StringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
