// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_plan.freezed.dart';
part 'visit_plan.g.dart';

/// One day's field route for a rep.
///
/// The stop list's ORDER is the visiting order — there is no sequence field to
/// disagree with it. That is deliberate on both sides of the wire: the server's
/// child table works the same way, so a drag on this screen and a re-optimise
/// on the server can never end up describing two different days.
@freezed
class VisitPlan with _$VisitPlan {
  const VisitPlan._();

  const factory VisitPlan({
    required String name,
    @JsonKey(name: 'visit_date') String? visitDate,
    @Default('') String rep,
    @JsonKey(name: 'rep_name') @Default('') String repName,
    @Default('') String title,
    @Default('Draft') String status,
    @JsonKey(name: 'start_mode') @Default('Current Location') String startMode,
    @JsonKey(name: 'start_label') @Default('') String startLabel,
    @JsonKey(name: 'start_latitude') double? startLatitude,
    @JsonKey(name: 'start_longitude') double? startLongitude,
    @JsonKey(name: 'planned_start_time') String? plannedStartTime,
    @JsonKey(name: 'default_visit_minutes') @Default(20) int defaultVisitMinutes,
    @JsonKey(name: 'return_to_start', fromJson: _flag)
    @Default(false)
    bool returnToStart,
    @JsonKey(name: 'total_stops') @Default(0) int totalStops,
    @JsonKey(name: 'total_distance_km') @Default(0.0) double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') @Default(0) int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') @Default(0) int totalDurationMinutes,

    /// 'osrm' = real road distances, 'haversine' = straight-line estimate.
    /// Shown on the screen because it changes what the numbers mean.
    @JsonKey(name: 'route_engine') @Default('haversine') String routeEngine,
    @JsonKey(name: 'optimized_on') String? optimizedOn,
    @Default('') String notes,
    @JsonKey(name: 'can_edit', fromJson: _flagTrue) @Default(true) bool canEdit,
    @Default(<VisitStop>[]) List<VisitStop> stops,

    /// Road path through the stops, `[[lat, lng], ...]`. Null whenever OSRM is
    /// not in play; the map then draws straight legs between stops instead.
    @JsonKey(name: 'geometry') List<List<double>>? geometry,
  }) = _VisitPlan;

  factory VisitPlan.fromJson(Map<String, dynamic> json) =>
      _$VisitPlanFromJson(json);

  /// Whether the totals are road distances rather than estimates.
  bool get hasRoadDistances => routeEngine == 'osrm';

  /// Stops still to be driven.
  List<VisitStop> get pending =>
      stops.where((s) => s.status == 'Planned').toList();

  /// The next door to drive to — the first unresolved stop in route order.
  VisitStop? get nextStop {
    for (final stop in stops) {
      if (stop.status == 'Planned') return stop;
    }
    return null;
  }

  int get visitedCount => stops.where((s) => s.status == 'Visited').length;

  /// How far through the day the rep is, 0..1. A plan with no stops reads as
  /// 0 rather than dividing by zero into a NaN that paints an empty bar.
  double get progress {
    final total = stops.where((s) => s.status != 'Cancelled').length;
    if (total == 0) return 0;
    final done = stops
        .where((s) => s.status == 'Visited' || s.status == 'Skipped')
        .length;
    return done / total;
  }

  bool get isDone => status == 'Completed' || status == 'Cancelled';
}

/// One door on a route.
///
/// Coordinates live on the stop, copied at the time it was added rather than
/// read back through the lead — the catalog importer rewrites branch rows
/// wholesale, so a stop that resolved its pin later could move between the
/// evening it was planned and the morning it is driven.
@freezed
class VisitStop with _$VisitStop {
  const VisitStop._();

  const factory VisitStop({
    required String name,
    @Default(0) int idx,
    @JsonKey(name: 'reference_doctype') @Default('Lead') String referenceDoctype,
    @JsonKey(name: 'reference_name') @Default('') String referenceName,
    @Default('') String title,
    @JsonKey(name: 'branch_name') @Default('') String branchName,
    @Default('') String area,
    @Default('Planned') String status,
    double? latitude,
    double? longitude,
    @Default('') String address,
    @Default('') String phone,
    @JsonKey(name: 'maps_url') @Default('') String mapsUrl,
    @JsonKey(name: 'planned_time') String? plannedTime,
    @JsonKey(name: 'visit_minutes') @Default(0) int visitMinutes,

    /// Pinned to this position; the optimiser reorders around it. This is how
    /// a booked appointment is expressed.
    @JsonKey(fromJson: _flag) @Default(false) bool locked,
    @JsonKey(name: 'leg_km') @Default(0.0) double legKm,
    @JsonKey(name: 'leg_minutes') @Default(0) int legMinutes,
    @JsonKey(name: 'arrived_at') String? arrivedAt,
    @Default('') String outcome,
    @JsonKey(name: 'journey_note') String? journeyNote,
  }) = _VisitStop;

  factory VisitStop.fromJson(Map<String, dynamic> json) =>
      _$VisitStopFromJson(json);

  bool get hasLocation => latitude != null && longitude != null;
  bool get isResolved => status != 'Planned';
  bool get canCall => phone.trim().isNotEmpty;

  /// What to show as the stop's name: the brand, disambiguated by the branch
  /// when a chain has more than one door on the route.
  String get displayTitle {
    final brand = title.trim().isEmpty ? referenceName : title.trim();
    final branch = branchName.trim();
    if (branch.isEmpty || branch.toLowerCase() == brand.toLowerCase()) {
      return brand;
    }
    return '$brand — $branch';
  }

  /// The payload shape `set_visit_stops` expects. Carries `name` so the server
  /// keeps the row's identity — and with it the check-in, outcome and diary
  /// link — across a reorder.
  Map<String, dynamic> toPayload() => {
        'name': name,
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'title': title,
        'branch_name': branchName,
        'area': area,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'phone': phone,
        'maps_url': mapsUrl,
        'visit_minutes': visitMinutes,
        'locked': locked ? 1 : 0,
        'outcome': outcome,
      };
}

/// A door the planner considers worth visiting, with its reasoning.
///
/// [reasons] is not decoration. A rep who disagrees with a suggestion is
/// entitled to see why it was made — "overdue follow-up + not visited in 134
/// days" is an argument; a score is not.
@freezed
class VisitTarget with _$VisitTarget {
  const VisitTarget._();

  const factory VisitTarget({
    @JsonKey(name: 'reference_doctype') @Default('Lead') String referenceDoctype,
    @JsonKey(name: 'reference_name') @Default('') String referenceName,
    @Default('') String title,
    @JsonKey(name: 'branch_name') @Default('') String branchName,
    @Default('') String area,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default('') String address,
    @Default('') String phone,
    @JsonKey(name: 'maps_url') @Default('') String mapsUrl,
    @JsonKey(name: 'fit_score') @Default(0.0) double fitScore,
    @Default('') String stage,
    @Default('') String tier,
    @Default('') String category,
    @JsonKey(name: 'is_specialty', fromJson: _flag) @Default(false) bool isSpecialty,
    @JsonKey(name: 'last_visit_date') String? lastVisitDate,
    @JsonKey(name: 'days_since_visit') int? daysSinceVisit,
    @JsonKey(name: 'next_followup_date') String? nextFollowupDate,
    @JsonKey(name: 'followup_overdue', fromJson: _flag)
    @Default(false)
    bool followupOverdue,
    @Default(0.0) double priority,
    @Default(<String>[]) List<String> reasons,
  }) = _VisitTarget;

  factory VisitTarget.fromJson(Map<String, dynamic> json) =>
      _$VisitTargetFromJson(json);

  /// Stable identity for one door, matching the server's `VisitTarget.key`.
  String get key => '$referenceDoctype:$referenceName:$branchName';

  bool get neverVisited => lastVisitDate == null;

  String get displayTitle {
    final brand = title.trim().isEmpty ? referenceName : title.trim();
    final branch = branchName.trim();
    if (branch.isEmpty || branch.toLowerCase() == brand.toLowerCase()) {
      return brand;
    }
    return '$brand — $branch';
  }

  /// The payload shape the plan endpoints expect for a new stop.
  Map<String, dynamic> toStopPayload() => {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'title': title,
        'branch_name': branchName,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'phone': phone,
        'maps_url': mapsUrl,
      };
}

/// A proposed day, before anybody commits to it.
@freezed
class VisitSuggestion with _$VisitSuggestion {
  const VisitSuggestion._();

  const factory VisitSuggestion({
    @Default(<VisitTarget>[]) List<VisitTarget> targets,
    @Default('haversine') String engine,
    @JsonKey(name: 'engine_note') String? engineNote,
    @JsonKey(name: 'total_distance_km') @Default(0.0) double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') @Default(0) int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') @Default(0) int totalDurationMinutes,

    /// How many doors were weighed to produce this. Worth showing: "9 of 812
    /// considered" is what makes the suggestion feel like a decision rather
    /// than a coincidence.
    @Default(0) int considered,
    @JsonKey(name: 'dropped_for_time') @Default(0) int droppedForTime,
    @JsonKey(name: 'day_minutes') @Default(0) int dayMinutes,
    @JsonKey(name: 'visit_date') String? visitDate,
    String? note,
  }) = _VisitSuggestion;

  factory VisitSuggestion.fromJson(Map<String, dynamic> json) =>
      _$VisitSuggestionFromJson(json);

  bool get isEmpty => targets.isEmpty;
  bool get hasRoadDistances => engine == 'osrm';
}

/// Which routing engine is answering, and why.
@freezed
class RouteEngineStatus with _$RouteEngineStatus {
  const RouteEngineStatus._();

  const factory RouteEngineStatus({
    @JsonKey(fromJson: _flag) @Default(false) bool configured,
    @JsonKey(fromJson: _nullableFlag) bool? reachable,
    @Default('straight_line') String engine,
    String? reason,
    @JsonKey(name: 'road_factor') @Default(1.35) double roadFactor,
    @JsonKey(name: 'avg_speed_kmh') @Default(22.0) double avgSpeedKmh,
    @JsonKey(name: 'default_visit_minutes') @Default(20) int defaultVisitMinutes,
    @JsonKey(name: 'max_stops') @Default(12) int maxStops,
    @JsonKey(name: 'day_minutes') @Default(360) int dayMinutes,
    @JsonKey(name: 'visit_days') @Default(<String>[]) List<String> visitDays,
  }) = _RouteEngineStatus;

  factory RouteEngineStatus.fromJson(Map<String, dynamic> json) =>
      _$RouteEngineStatusFromJson(json);

  bool get usesRoadDistances => engine == 'osrm';

  /// A one-line explanation for the badge. Distinguishes "we have no routing
  /// server" from "the routing server is down", which look identical on screen
  /// and need completely different fixes.
  String get summary {
    if (usesRoadDistances) return 'Road distances';
    if (!configured) return 'Estimated distances';
    if (reachable == false) return 'Estimated — routing server unreachable';
    return 'Estimated distances';
  }
}

/// Decodes a Frappe Check field into a bool.
///
/// A Check is an INT column. Most of these endpoints map it to a real JSON
/// boolean on the way out, but not every path does — a value read straight off
/// a document, or an older server, sends `1`. A plain `bool` field throws
/// "type 'int' is not a subtype of type 'bool?'" on that, which takes down the
/// whole decode of a plan for one flag. Same guard the leads model puts on
/// `on_talabat`.
bool _flag(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
  return false;
}

/// [_flag] for a field whose absence means TRUE — permission flags default to
/// permitted, and the server denies the write anyway if it disagrees.
bool _flagTrue(dynamic value) => value == null ? true : _flag(value);

/// [_flag] for a genuinely three-state field. `null` means "not known", which
/// for reachability is different from "not reachable".
bool? _nullableFlag(dynamic value) => value == null ? null : _flag(value);
