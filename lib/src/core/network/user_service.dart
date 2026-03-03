import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_provider.dart';

class UserRoles {
  final String user;
  final String? fullName;
  final List<String> roles;
  final String? employee;
  final String? employeeName;
  final String? branch;
  final bool requirePosShift;

  const UserRoles({
    required this.user,
    this.fullName,
    required this.roles,
    this.employee,
    this.employeeName,
    this.branch,
    this.requirePosShift = false,
  });

  bool get isJarzManager => roles.contains('JARZ Manager');
  bool get isManager => isJarzManager;
  bool get isLineManager => roles.contains('JARZ line manager');
  bool get isModerator => roles.contains('Moderator');
  bool get canMuteNotifications => isJarzManager || isLineManager || isModerator;

  factory UserRoles.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final rolesList = rolesRaw is List ? rolesRaw.map((e) => e.toString()).toList() : <String>[];
    return UserRoles(
      user: (json['user'] ?? '').toString(),
      fullName: json['full_name']?.toString(),
      roles: rolesList,
      employee: json['employee']?.toString(),
      employeeName: json['employee_name']?.toString(),
      branch: json['branch']?.toString(),
      requirePosShift: json['require_pos_shift'] == true || json['require_pos_shift'] == 1,
    );
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

class UserService {
  final Dio _dio;
  UserService(this._dio);

  Future<UserRoles> getCurrentUserRoles() async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.user.get_current_user_roles',
      data: {},
    );
    final data = resp.data;
    if (data is Map && data['message'] is Map) {
      return UserRoles.fromJson(Map<String, dynamic>.from(data['message'] as Map));
    }
    if (data is Map) {
      return UserRoles.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Unexpected roles response');
  }
}

// Riverpod providers for roles state
final userRolesFutureProvider = FutureProvider<UserRoles>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getCurrentUserRoles();
});

final isJarzManagerProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.isManager,
    orElse: () => false,
  );
});

final isLineManagerProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.isLineManager,
    orElse: () => false,
  );
});

final isModeratorProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.isModerator,
    orElse: () => false,
  );
});

final canMuteNotificationsProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canMuteNotifications,
    orElse: () => false,
  );
});

final requirePosShiftProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.requirePosShift,
    orElse: () => false,
  );
});
