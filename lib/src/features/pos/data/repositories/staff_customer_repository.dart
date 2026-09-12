import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../models/staff_customer_models.dart';

/// HTTP client for `jarz_pos.api.employee_customers`.
///
/// A staff order is only deducted from payroll when its Customer is linked to
/// an Employee. The POS therefore never lets the operator pick that customer by
/// hand: it picks a person, and [ensureStaffCustomer] returns the linked
/// customer, creating or adopting one when needed.
class StaffCustomerRepository {
  StaffCustomerRepository(this._dio);

  final Dio _dio;

  static const listFailedMessage = 'Failed to load staff members';
  static const ensureFailedMessage = 'Failed to prepare the staff customer';
  static const syncFailedMessage = 'Failed to create staff customers';

  /// Unwraps Frappe's `message` envelope and raises a `success: false` body.
  Map<String, dynamic> _payload(Response<dynamic> response, String fallback) {
    final raw = response.data is String
        ? json.decode(response.data as String)
        : response.data;
    final message = raw is Map ? (raw['message'] ?? raw) : raw;
    if (message is! Map) {
      throw Exception(fallback);
    }
    final map = Map<String, dynamic>.from(message);
    if (map['success'] == false) {
      throw Exception(extractFrappeErrorMessage(map, fallback: fallback));
    }
    return map;
  }

  Future<StaffOrderEmployeeList> listStaffForOrders({String? search}) async {
    final query = search?.trim() ?? '';
    try {
      final response = await _dio.get(
        ApiEndpoints.listStaffForOrders,
        queryParameters: {if (query.isNotEmpty) 'search': query},
      );
      return StaffOrderEmployeeList.fromJson(
        _payload(response, listFailedMessage),
      );
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: listFailedMessage);
    }
  }

  Future<StaffCustomerEnsureResult> ensureStaffCustomer(String employee) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.ensureStaffCustomer,
        data: {'employee': employee},
      );
      final result = StaffCustomerEnsureResult.fromJson(
        _payload(response, ensureFailedMessage),
      );
      // Selecting a customer without a name would put the order on
      // "Walking Customer" — exactly the unattributed debt this prevents.
      if (result.customerId.isEmpty) {
        throw Exception(ensureFailedMessage);
      }
      return result;
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: ensureFailedMessage);
    }
  }

  Future<StaffCustomerSyncResult> syncStaffCustomers() async {
    try {
      final response = await _dio.post(ApiEndpoints.syncStaffCustomers);
      return StaffCustomerSyncResult.fromJson(
        _payload(response, syncFailedMessage),
      );
    } on DioException catch (error) {
      throw mapFrappeError(error, fallback: syncFailedMessage);
    }
  }
}

final staffCustomerRepositoryProvider = Provider<StaffCustomerRepository>((
  ref,
) {
  return StaffCustomerRepository(ref.watch(dioProvider));
});
