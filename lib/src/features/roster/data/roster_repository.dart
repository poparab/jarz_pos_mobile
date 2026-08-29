import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/roster_models.dart';

final rosterRepositoryProvider = Provider<RosterRepository>((ref) {
  return RosterRepository(ref.watch(dioProvider));
});

/// HTTP repository for shift distribution (`jarz_pos.api.roster.*`).
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the visits, leads and journey
/// repositories.
class RosterRepository {
  RosterRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  // ── Reads ────────────────────────────────────────────────────────────

  /// Shift catalogue, branches and the caller's scope — one call so the
  /// calendar does not open on three separate spinners.
  Future<RosterBootstrap> getBootstrap() async {
    final response = await _dio.post(ApiEndpoints.rosterBootstrap, data: {});
    return RosterBootstrap.fromJson(_asMap(_unwrap(response)));
  }

  /// The month grid: one row per employee, one cell per day.
  ///
  /// [month] is `YYYY-MM`; omitting it asks the server for the current month,
  /// so the client never has to decide what "this month" means in the site's
  /// timezone.
  Future<RosterMonth> getMonth({String? month, String? shiftLocation}) async {
    final response = await _dio.post(
      ApiEndpoints.rosterMonth,
      data: {
        if (month != null) 'month': month,
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
    return RosterMonth.fromJson(_asMap(_unwrap(response)));
  }

  /// Hours and overtime for the month, as payroll reads it.
  Future<RosterHours> getMonthHours({
    String? month,
    String? shiftLocation,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.rosterMonthHours,
      data: {
        if (month != null) 'month': month,
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
    return RosterHours.fromJson(_asMap(_unwrap(response)));
  }

  // ── Writes ───────────────────────────────────────────────────────────

  /// Put one employee on one shift for one day.
  ///
  /// Passing [shiftLocation] moves them to another branch for the day, which
  /// also moves where their phone has to be to clock in.
  Future<void> assignShift({
    required String employee,
    required String date,
    required String shiftType,
    String? shiftLocation,
  }) async {
    await _dio.post(
      ApiEndpoints.rosterAssignShift,
      data: {
        'employee': employee,
        'date': date,
        'shift_type': shiftType,
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
  }

  /// Mark somebody off and, in the same request, name who covers the day.
  ///
  /// The pair is one call rather than two because a branch that loses one of
  /// its overlapping shifts is not covered by shortening the rota — sending
  /// them separately would leave a window where the branch is rostered
  /// half-open.
  Future<void> setDayOff({
    required String employee,
    required String date,
    required String offType,
    String? coveredBy,
    String? coverShiftType,
    String? notes,
  }) async {
    await _dio.post(
      ApiEndpoints.rosterSetDayOff,
      data: {
        'employee': employee,
        'date': date,
        'off_type': offType,
        if (coveredBy != null && coveredBy.isNotEmpty) 'covered_by': coveredBy,
        if (coverShiftType != null && coverShiftType.isNotEmpty)
          'cover_shift_type': coverShiftType,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// Undo a day off, restoring both the person and whoever covered them.
  Future<void> clearDayOff({
    required String employee,
    required String date,
  }) async {
    await _dio.post(
      ApiEndpoints.rosterClearDayOff,
      data: {'employee': employee, 'date': date},
    );
  }
}
