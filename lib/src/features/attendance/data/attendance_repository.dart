import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/attendance_models.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(dioProvider));
});

/// HTTP repository for attendance (`jarz_pos.api.attendance.*`).
///
/// Read-only for attendance itself: it is derived server-side from Employee
/// Checkin, Shift Assignment and Day Off rows, and nothing in this app may
/// write it. The ONE write is [approveDevice], which trusts a phone (device
/// state, not attendance); the server checks the caller may do it.
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the roster, visits and leads
/// repositories.
class AttendanceRepository {
  AttendanceRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  /// Branches, scope and the grace window — one call so the screen does not
  /// open on four separate spinners.
  Future<AttendanceBootstrap> getBootstrap() async {
    final response = await _dio.post(
      ApiEndpoints.attendanceBootstrap,
      data: {},
    );
    return AttendanceBootstrap.fromJson(_asMap(_unwrap(response)));
  }

  /// The month grid: one row per employee, one cell per day.
  ///
  /// [month] is `YYYY-MM`; omitting it asks the server for the current month,
  /// so the client never has to decide what "this month" means in the site's
  /// timezone.
  Future<AttendanceMonth> getMonth({
    String? month,
    String? shiftLocation,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.attendanceMonth,
      data: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
    return AttendanceMonth.fromJson(_asMap(_unwrap(response)));
  }

  /// One day, grouped by branch: who was rostered, who came, who was late.
  Future<AttendanceDay> getDay({String? date, String? shiftLocation}) async {
    final response = await _dio.post(
      ApiEndpoints.attendanceDay,
      data: {
        if (date != null && date.isNotEmpty) 'date': date,
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
    return AttendanceDay.fromJson(_asMap(_unwrap(response)));
  }

  /// One person over a date range, including their raw check-ins.
  Future<AttendanceEmployeeDetail> getEmployee({
    required String employee,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.attendanceEmployee,
      data: {
        'employee': employee,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      },
    );
    return AttendanceEmployeeDetail.fromJson(_asMap(_unwrap(response)));
  }

  /// Aggregates for a range, grouped by branch, employee or day.
  ///
  /// The grouping is sent as the contract's wire string rather than the enum's
  /// name so a Dart-side rename cannot quietly change the request.
  Future<AttendanceSummary> getSummary({
    String? fromDate,
    String? toDate,
    AttendanceGroupBy groupBy = AttendanceGroupBy.branch,
    String? shiftLocation,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.attendanceSummary,
      data: {
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        'group_by': attendanceGroupByToWire(groupBy),
        if (shiftLocation != null && shiftLocation.isNotEmpty)
          'shift_location': shiftLocation,
      },
    );
    return AttendanceSummary.fromJson(_asMap(_unwrap(response)));
  }

  /// Approve the phone [employee] checked in with on [date] (`YYYY-MM-DD`)
  /// as their own, clearing its "New Device" flag.
  ///
  /// A refusal (not allowed, nothing to approve) arrives as a Frappe
  /// exception, i.e. a [DioException]; the caller shows the server's words.
  Future<AttendanceDeviceApproval> approveDevice({
    required String employee,
    required String date,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.attendanceApproveDevice,
      data: {'employee': employee, 'date': date},
    );
    final body = _unwrap(response);
    return AttendanceDeviceApproval.fromJson(
      body is Map ? _asMap(body) : {'employee': employee},
    );
  }
}
