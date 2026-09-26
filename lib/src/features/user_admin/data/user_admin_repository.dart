import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/user_admin_models.dart';

final userAdminRepositoryProvider = Provider<UserAdminRepository>((ref) {
  return UserAdminRepository(ref.watch(dioProvider));
});

/// HTTP repository for user management (`jarz_pos.api.user_admin.*`).
///
/// Reads are GET, changes are POST; every answer comes in Frappe's
/// `{ "message": ... }` envelope. Refusals (not a manager, a System Manager
/// account, a user still linked to records) arrive as HTTP errors and are
/// left to propagate, so the screen can show the server's own sentence.
class UserAdminRepository {
  UserAdminRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  List<Map<String, dynamic>> _asList(dynamic value) => value is List
      ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : const [];

  UserAdminUser _user(Response response) =>
      UserAdminUser.fromJson(_asMap(_unwrap(response)));

  /// What the caller may do, and the role profiles the form offers.
  Future<UserAdminContext> getContext() async {
    final response = await _dio.get(ApiEndpoints.userAdminContext);
    return UserAdminContext.fromJson(_asMap(_unwrap(response)));
  }

  Future<List<UserAdminUser>> listUsers({
    String? search,
    bool includeDisabled = true,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.userAdminListUsers,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'include_disabled': includeDisabled ? 1 : 0,
      },
    );
    return _asList(
      _unwrap(response),
    ).map(UserAdminUser.fromJson).where((u) => u.name.isNotEmpty).toList();
  }

  Future<UserAdminUser> getUser(String user) async {
    final response = await _dio.get(
      ApiEndpoints.userAdminGetUser,
      queryParameters: {'user': user},
    );
    return _user(response);
  }

  /// Active employees (the server caps it at 50).
  Future<List<UserAdminEmployee>> listEmployees({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.userAdminListEmployees,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asList(
      _unwrap(response),
    ).map(UserAdminEmployee.fromJson).where((e) => e.name.isNotEmpty).toList();
  }

  Future<UserAdminUser> createUser({
    required String email,
    required String firstName,
    required String password,
    required List<String> roleProfiles,
    String? lastName,
    String? mobileNo,
    bool? requirePosShift,
    String? employee,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.userAdminCreateUser,
      data: {
        'email': email.trim(),
        'first_name': firstName.trim(),
        'password': password,
        'role_profiles': jsonEncode(roleProfiles),
        if (lastName != null && lastName.trim().isNotEmpty)
          'last_name': lastName.trim(),
        if (mobileNo != null && mobileNo.trim().isNotEmpty)
          'mobile_no': mobileNo.trim(),
        if (requirePosShift != null)
          'require_pos_shift': requirePosShift ? 1 : 0,
        if (employee != null && employee.isNotEmpty) 'employee': employee,
      },
    );
    return _user(response);
  }

  /// Sends only what is given; an omitted field stays as it is on the server.
  /// [lastName] / [mobileNo] may be `''` to clear them.
  Future<UserAdminUser> updateUser({
    required String user,
    String? firstName,
    String? lastName,
    String? mobileNo,
    List<String>? roleProfiles,
    bool? requirePosShift,
    String? employee,
    bool clearEmployee = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.userAdminUpdateUser,
      data: {
        'user': user,
        if (firstName != null) 'first_name': firstName.trim(),
        if (lastName != null) 'last_name': lastName.trim(),
        if (mobileNo != null) 'mobile_no': mobileNo.trim(),
        if (roleProfiles != null) 'role_profiles': jsonEncode(roleProfiles),
        if (requirePosShift != null)
          'require_pos_shift': requirePosShift ? 1 : 0,
        if (employee != null && employee.isNotEmpty) 'employee': employee,
        if (clearEmployee) 'clear_employee': 1,
      },
    );
    return _user(response);
  }

  /// Disabling signs the user out of every device.
  Future<UserAdminUser> setEnabled({
    required String user,
    required bool enabled,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.userAdminSetEnabled,
      data: {'user': user, 'enabled': enabled ? 1 : 0},
    );
    return _user(response);
  }

  Future<UserAdminAck> resetPassword({
    required String user,
    required String newPassword,
    bool signOut = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.userAdminResetPassword,
      data: {
        'user': user,
        'new_password': newPassword,
        'sign_out': signOut ? 1 : 0,
      },
    );
    return UserAdminAck.fromJson(_asMap(_unwrap(response)));
  }

  /// Refused by the server while the user is linked to any record.
  Future<UserAdminAck> deleteUser(String user) async {
    final response = await _dio.post(
      ApiEndpoints.userAdminDeleteUser,
      data: {'user': user},
    );
    return UserAdminAck.fromJson(_asMap(_unwrap(response)));
  }
}
