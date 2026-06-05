import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_provider.dart';
import '../constants/api_endpoints.dart';
import '../constants/business_constants.dart';

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

  bool get isJarzManager => roles.contains(RoleNames.jarzManager);
  bool get isManager => isJarzManager;
  bool get isLineManager => roles.contains(RoleNames.jarzLineManager);
  bool get isAdminManager =>
      roles.contains(RoleNames.posManager) ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator);
  bool get canAccessManagerDashboard =>
      isJarzManager || isLineManager || isAdminManager;
  bool get canAccessShiftMonitor => isJarzManager || isAdminManager;
  bool get isModerator => roles.contains(RoleNames.moderator);
  bool get canMuteNotifications =>
      isJarzManager || isLineManager || isModerator;

  factory UserRoles.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final rolesList = rolesRaw is List
        ? rolesRaw.map((e) => e.toString()).toList()
        : <String>[];
    return UserRoles(
      user: (json['user'] ?? '').toString(),
      fullName: json['full_name']?.toString(),
      roles: rolesList,
      employee: json['employee']?.toString(),
      employeeName: json['employee_name']?.toString(),
      branch: json['branch']?.toString(),
      requirePosShift:
          json['require_pos_shift'] == true || json['require_pos_shift'] == 1,
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
    final resp = await _dio.post(ApiEndpoints.getCurrentUserRoles, data: {});
    final data = resp.data;
    if (data is Map && data['message'] is Map) {
      return UserRoles.fromJson(
        Map<String, dynamic>.from(data['message'] as Map),
      );
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

final canAccessManagerDashboardRoleProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessManagerDashboard,
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

final canAccessShiftMonitorProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessShiftMonitor,
    orElse: () => false,
  );
});

/// Login mode: when a Line Manager who requires a shift logs in,
/// they can choose to operate as 'line_manager' (skip shift) or
/// 'employee' (require shift). Defaults to 'employee'.
/// Reset on logout.
enum LoginMode { employee, lineManager }

final loginModeProvider = StateProvider<LoginMode>((ref) => LoginMode.employee);

/// Whether the user needs to open a POS shift.
/// Returns false if the user chose to log in as Line Manager.
final requirePosShiftProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  final loginMode = ref.watch(loginModeProvider);
  return rolesAsync.maybeWhen(
    data: (roles) {
      if (!roles.requirePosShift) return false;
      // Line managers who chose manager mode skip shift requirement
      if (roles.isLineManager && loginMode == LoginMode.lineManager) {
        return false;
      }
      return true;
    },
    orElse: () => false,
  );
});

/// Whether the current user should be shown the login mode choice
/// (is a line manager AND has shift requirement).
final shouldShowLoginModeChoiceProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.isLineManager && roles.requirePosShift,
    orElse: () => false,
  );
});
