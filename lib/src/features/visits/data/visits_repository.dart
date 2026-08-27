import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/visit_plan.dart';

final visitsRepositoryProvider = Provider<VisitsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VisitsRepository(dio);
});

/// HTTP repository for the visit planner (`jarz_pos.api.visits.*`).
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the leads, journey and B2B
/// repositories.
///
/// Stop lists go out `jsonEncode`d. Frappe binds a list argument delivered as
/// form data into a JSON string anyway, and encoding it here means the server
/// sees one predictable shape instead of two — the same reason
/// `saveLeadContacts` and `mergeLeads` do it.
class VisitsRepository {
  final Dio _dio;
  VisitsRepository(this._dio);

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  // ── Reads ────────────────────────────────────────────────────────────

  /// Summary rows for a date range — the calendar and the plan list.
  ///
  /// Carries no stops by design: a month of routes with every door attached is
  /// a large payload for a screen that draws chips.
  Future<List<VisitPlan>> getPlans({
    required String fromDate,
    required String toDate,
    String scope = 'mine',
    String? status,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getVisitPlans,
      data: {
        'from_date': fromDate,
        'to_date': toDate,
        'scope': scope,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final payload = _asMap(_unwrap(response));
    return _asList(payload['plans']).map(VisitPlan.fromJson).toList();
  }

  /// One plan with its ordered stops.
  ///
  /// [withGeometry] asks the server for the drawn road path. It costs a second
  /// network hop on the server's side whose only job is to make the map
  /// prettier, so the caller opts in — the route, the order and the totals all
  /// arrive without it.
  Future<VisitPlan> getPlan(String name, {bool withGeometry = false}) async {
    final response = await _dio.post(
      ApiEndpoints.getVisitPlan,
      data: {'name': name, 'with_geometry': withGeometry ? 1 : 0},
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  Future<RouteEngineStatus> getEngineStatus() async {
    final response = await _dio.post(ApiEndpoints.getRouteEngineStatus);
    return RouteEngineStatus.fromJson(_asMap(_unwrap(response)));
  }

  /// Rankable doors matching a coarse filter, best first.
  Future<List<VisitTarget>> getTargets({
    String? category,
    String? tier,
    String? area,
    bool specialtyOnly = false,
    double minFitScore = 0,
    bool includeCustomers = true,
    int limit = 500,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getVisitTargets,
      data: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (tier != null && tier.isNotEmpty) 'tier': tier,
        if (area != null && area.isNotEmpty) 'area': area,
        'specialty_only': specialtyOnly ? 1 : 0,
        'min_fit_score': minFitScore,
        'include_customers': includeCustomers ? 1 : 0,
        'limit': limit,
      },
    );
    final payload = _asMap(_unwrap(response));
    return _asList(payload['targets']).map(VisitTarget.fromJson).toList();
  }

  /// Propose a day. Writes nothing — the rep commits it by creating a plan.
  Future<VisitSuggestion> suggest({
    required String visitDate,
    int? maxStops,
    double? startLatitude,
    double? startLongitude,
    double? radiusKm,
    String? category,
    String? tier,
    String? area,
    bool specialtyOnly = false,
    double minFitScore = 0,
    bool includeCustomers = true,
    int? dayMinutes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.suggestVisitPlan,
      data: {
        'visit_date': visitDate,
        if (maxStops != null) 'max_stops': maxStops,
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (category != null && category.isNotEmpty) 'category': category,
        if (tier != null && tier.isNotEmpty) 'tier': tier,
        if (area != null && area.isNotEmpty) 'area': area,
        'specialty_only': specialtyOnly ? 1 : 0,
        'min_fit_score': minFitScore,
        'include_customers': includeCustomers ? 1 : 0,
        if (dayMinutes != null) 'day_minutes': dayMinutes,
      },
    );
    return VisitSuggestion.fromJson(_asMap(_unwrap(response)));
  }

  /// The routable doors belonging to ONE record.
  ///
  /// Lets any screen offer "add to a visit" without knowing how doors are
  /// stored. An empty list means the record has no usable pin — a normal
  /// answer that the caller states plainly rather than offering a stop that
  /// leads nowhere.
  Future<List<VisitTarget>> getRecordTargets({
    required String referenceDoctype,
    required String referenceName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getRecordVisitTargets,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
      },
    );
    final payload = _asMap(_unwrap(response));
    return _asList(payload['targets']).map(VisitTarget.fromJson).toList();
  }

  /// Upcoming plans a stop can be added to, soonest first.
  ///
  /// Narrower than [getPlans] on purpose: this answers "where can I put this
  /// door", so finished and cancelled days are already excluded and the rep
  /// gets a short list they can hit with a thumb.
  Future<List<VisitPlan>> getAddablePlans({int daysAhead = 60}) async {
    final response = await _dio.post(
      ApiEndpoints.getAddableVisitPlans,
      data: {'days_ahead': daysAhead},
    );
    final payload = _asMap(_unwrap(response));
    return _asList(payload['plans']).map(VisitPlan.fromJson).toList();
  }

  /// Order and cost a stop list without saving it.
  ///
  /// Safe to call on every tick of a checkbox — it writes nothing.
  Future<RoutePreview> previewRoute({
    required List<Map<String, dynamic>> stops,
    double? startLatitude,
    double? startLongitude,
    bool returnToStart = false,
    int? defaultVisitMinutes,
    bool optimize = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.previewVisitRoute,
      data: {
        'stops': jsonEncode(stops),
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
        'return_to_start': returnToStart ? 1 : 0,
        if (defaultVisitMinutes != null)
          'default_visit_minutes': defaultVisitMinutes,
        'optimize': optimize ? 1 : 0,
      },
    );
    return RoutePreview.fromJson(_asMap(_unwrap(response)));
  }

  // ── Writes ───────────────────────────────────────────────────────────

  Future<VisitPlan> createPlan({
    required String visitDate,
    required List<Map<String, dynamic>> stops,
    String? title,
    String? rep,
    double? startLatitude,
    double? startLongitude,
    String? startLabel,
    String? startMode,
    String? plannedStartTime,
    int? defaultVisitMinutes,
    bool returnToStart = false,
    bool optimize = true,
    String? status,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createVisitPlan,
      data: {
        'visit_date': visitDate,
        'stops': jsonEncode(stops),
        if (title != null) 'title': title,
        if (rep != null && rep.isNotEmpty) 'rep': rep,
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
        if (startLabel != null) 'start_label': startLabel,
        if (startMode != null) 'start_mode': startMode,
        if (plannedStartTime != null) 'planned_start_time': plannedStartTime,
        if (defaultVisitMinutes != null)
          'default_visit_minutes': defaultVisitMinutes,
        'return_to_start': returnToStart ? 1 : 0,
        'optimize': optimize ? 1 : 0,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  Future<VisitPlan> updatePlan(
    String name, {
    String? visitDate,
    String? title,
    String? rep,
    String? status,
    String? notes,
    String? startMode,
    String? startLabel,
    double? startLatitude,
    double? startLongitude,
    String? plannedStartTime,
    int? defaultVisitMinutes,
    bool? returnToStart,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.updateVisitPlan,
      data: {
        'name': name,
        if (visitDate != null) 'visit_date': visitDate,
        if (title != null) 'title': title,
        if (rep != null) 'rep': rep,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
        if (startMode != null) 'start_mode': startMode,
        if (startLabel != null) 'start_label': startLabel,
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
        if (plannedStartTime != null) 'planned_start_time': plannedStartTime,
        if (defaultVisitMinutes != null)
          'default_visit_minutes': defaultVisitMinutes,
        if (returnToStart != null) 'return_to_start': returnToStart ? 1 : 0,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  /// Replace the whole stop list — add, remove and reorder in one write.
  ///
  /// Whole-list rather than per-stop because a drag reorders several rows at
  /// once: one atomic write beats five moves racing whoever else has the plan
  /// open. Rows keep their `name`, so a half-driven day survives a reorder
  /// with its check-ins intact.
  Future<VisitPlan> setStops(
    String name,
    List<Map<String, dynamic>> stops, {
    bool optimize = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.setVisitStops,
      data: {
        'name': name,
        'stops': jsonEncode(stops),
        'optimize': optimize ? 1 : 0,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  Future<VisitPlan> addStops(
    String name,
    List<Map<String, dynamic>> stops, {
    bool optimize = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.addVisitStops,
      data: {
        'name': name,
        'stops': jsonEncode(stops),
        'optimize': optimize ? 1 : 0,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  /// Reorder into the fastest sequence.
  ///
  /// The live position is passed per call rather than persisted: "start from
  /// where I am now" is the common case and it is a different point every
  /// morning.
  Future<VisitPlan> optimize(
    String name, {
    double? startLatitude,
    double? startLongitude,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.optimizeVisitPlan,
      data: {
        'name': name,
        if (startLatitude != null) 'start_latitude': startLatitude,
        if (startLongitude != null) 'start_longitude': startLongitude,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  /// Check in (or out of) one stop, optionally writing the diary entry.
  Future<VisitPlan> setStopStatus({
    required String plan,
    required String stop,
    required String status,
    String? outcome,
    bool logNote = false,
    String? noteText,
    String? nextAction,
    String? nextActionDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.setVisitStopStatus,
      data: {
        'name': plan,
        'stop': stop,
        'status': status,
        if (outcome != null) 'outcome': outcome,
        'log_note': logNote ? 1 : 0,
        if (noteText != null) 'note_text': noteText,
        if (nextAction != null) 'next_action': nextAction,
        if (nextActionDate != null) 'next_action_date': nextActionDate,
      },
    );
    return VisitPlan.fromJson(_asMap(_unwrap(response)));
  }

  Future<void> deletePlan(String name) async {
    await _dio.post(ApiEndpoints.deleteVisitPlan, data: {'name': name});
  }
}
