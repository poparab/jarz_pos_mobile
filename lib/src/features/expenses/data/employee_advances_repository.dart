import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/employee_advance_models.dart';

final employeeAdvancesRepositoryProvider =
    Provider<EmployeeAdvancesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return EmployeeAdvancesRepository(dio);
});

/// One approved advance plus the Payment Entry the approval posted.
///
/// The Payment Entry name is surfaced (not swallowed) because approval moves
/// real cash out of the branch account — the card shows it so an approver can
/// trace the money without leaving the app.
class EmployeeAdvanceApproval {
  final EmployeeAdvance advance;
  final String? paymentEntry;

  const EmployeeAdvanceApproval({required this.advance, this.paymentEntry});
}

class EmployeeAdvancesRepository {
  final Dio _dio;
  EmployeeAdvancesRepository(this._dio);

  /// Unwraps the Frappe `{"message": ...}` envelope exactly as
  /// `ExpensesRepository` does — some proxies hand the payload back bare.
  Map<String, dynamic> _payload(Response<dynamic> response) {
    final data = response.data is Map
        ? response.data['message'] ?? response.data
        : response.data;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Guards the MUTATION endpoints only.
  ///
  /// Dio throws on a non-2xx or a Frappe exception, so this covers the one case
  /// it cannot: an HTTP 200 carrying `success: false`. Deliberately NOT applied
  /// to the bootstrap — `hrms_available: false` is a normal answer there and
  /// must never become an error tile.
  void _ensureSuccess(Map<String, dynamic> payload) {
    if (payload['success'] == false || payload['success'] == 0) {
      final message = payload['message'] ?? payload['error'] ?? payload['notice'];
      throw Exception(
        message?.toString().trim().isNotEmpty == true
            ? message.toString().trim()
            : 'Request failed',
      );
    }
  }

  /// `filters` is a JSON-ENCODED STRING, the same idiom
  /// `get_expense_bootstrap` uses — not a nested JSON object.
  Future<EmployeeAdvanceBootstrap> fetchAdvances({
    String? month,
    String? status,
    String? employee,
    String? branch,
  }) async {
    final filters = <String, dynamic>{};
    if (month != null && month.isNotEmpty) filters['month'] = month;
    if (status != null && status.isNotEmpty) filters['status'] = status;
    if (employee != null && employee.isNotEmpty) filters['employee'] = employee;
    if (branch != null && branch.isNotEmpty) filters['branch'] = branch;

    final response = await _dio.post(
      ApiEndpoints.getEmployeeAdvanceBootstrap,
      data: {'filters': jsonEncode(filters)},
    );
    return EmployeeAdvanceBootstrap.fromJson(_payload(response));
  }

  Future<EmployeeAdvance> createRequest({
    required String employee,
    required double amount,
    required String purpose,
    required String payingAccount,
    String? posProfile,
    String? postingDate,
  }) async {
    final body = <String, dynamic>{
      'employee': employee,
      'amount': amount,
      'purpose': purpose.trim(),
      'paying_account': payingAccount,
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
      if (postingDate != null && postingDate.isNotEmpty)
        'posting_date': postingDate,
    };

    final response = await _dio.post(
      ApiEndpoints.createEmployeeAdvanceRequest,
      data: body,
    );
    final data = _payload(response);
    _ensureSuccess(data);
    return EmployeeAdvance.fromJson(
      Map<String, dynamic>.from(data['advance'] as Map),
    );
  }

  /// Submits the HRMS Employee Advance AND posts the Payment Entry server-side.
  /// There is no separate "pay" call — cash leaves the account on this request.
  Future<EmployeeAdvanceApproval> approve(String name) async {
    final response = await _dio.post(
      ApiEndpoints.approveEmployeeAdvance,
      data: {'name': name},
    );
    final data = _payload(response);
    _ensureSuccess(data);
    return EmployeeAdvanceApproval(
      advance: EmployeeAdvance.fromJson(
        Map<String, dynamic>.from(data['advance'] as Map),
      ),
      paymentEntry: data['payment_entry']?.toString(),
    );
  }

  /// Returns nothing but `{success}` — the caller reloads to pick up the
  /// cancelled row rather than patching state from a response body that has no
  /// advance in it.
  Future<void> reject(String name, String reason) async {
    final response = await _dio.post(
      ApiEndpoints.rejectEmployeeAdvance,
      data: {'name': name, 'reason': reason.trim()},
    );
    // `{success}` is the WHOLE body here, so an HTTP 200 carrying
    // `success: false` would otherwise read as a rejection that never happened.
    _ensureSuccess(_payload(response));
  }
}
