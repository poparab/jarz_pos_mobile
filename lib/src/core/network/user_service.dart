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
  final bool isB2bSalesRep;
  final bool canAccessB2b;

  const UserRoles({
    required this.user,
    this.fullName,
    required this.roles,
    this.employee,
    this.employeeName,
    this.branch,
    this.requirePosShift = false,
    this.isB2bSalesRep = false,
    this.canAccessB2b = false,
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
  bool get isJarzPosStaff => roles.contains(RoleNames.jarzPosStaff);

  /// Lands on the Kanban board (instead of POS) only when the user is
  /// Jarz POS Staff AND not a manager — managers keep the POS home.
  bool get landsOnKanban => isJarzPosStaff && !canAccessManagerDashboard;
  bool get canAccessShiftMonitor =>
      isJarzManager || isAdminManager || isLineManager;
  bool get isModerator => roles.contains(RoleNames.moderator);
  bool get canMuteNotifications =>
      isJarzManager || isLineManager || isModerator;

  /// Whether this user is a dedicated B2B sales rep (lands in B2B mode and is
  /// blocked from the B2C POS/Kanban flows). Falls back to the role name when
  /// the backend flag is absent.
  bool get isB2bRep =>
      isB2bSalesRep || roles.contains(RoleNames.b2bSalesRep);

  /// Whether this user can use B2B mode at all (sales reps + managers).
  bool get canUseB2b => canAccessB2b || isB2bRep;

  /// Whether this user may EDIT prices (create lists, set category/flavor
  /// prices, assign customers to lists). The backend
  /// `_ensure_full_manager_pricing_access` requires manager-pricing access AND
  /// B2B access, which nets out to the JARZ Manager (Administrator holds that
  /// role implicitly). Line managers lack B2B and B2B reps lack pricing, so both
  /// get the read-only pricing view.
  bool get canEditPricing => isJarzManager;

  /// A B2B rep who is NOT a manager lands in B2B mode and cannot reach the
  /// B2C POS/Kanban flows. Managers keep their normal landing but get a switch.
  bool get landsOnB2b => isB2bRep && !canAccessManagerDashboard;

  /// Holds one of the stock/manufacturing roles the backend accepts.
  bool get isProductionRole =>
      roles.contains(RoleNames.manufacturingManager) ||
      roles.contains(RoleNames.stockManager) ||
      roles.contains(RoleNames.purchaseManager);

  bool get isProductionOperator =>
      roles.contains(RoleNames.productionOperator);

  /// May start and finish batches. Mirrors backend `ROLES.PRODUCTION_EXECUTE`.
  bool get canExecuteProduction =>
      isProductionOperator || canAccessProductionBoard;

  /// May post production on a past date. Mirrors `ROLES.PRODUCTION_BACKDATE` —
  /// deliberately EXCLUDES the operator role. The server enforces this against
  /// its own clock; this only decides whether the date picker is tappable, so a
  /// client that got it wrong would still be refused.
  bool get canBackDateProduction =>
      isJarzManager ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator) ||
      isProductionRole;

  /// May return stranded WIP material to its source warehouse.
  ///
  /// Deliberately NOT [canAccessProductionBoard]: that mirrors the backend's
  /// PRODUCTION_VIEW set, which *includes* Production Operator — gating on it
  /// would show the action to exactly the role it must be hidden from. Manager
  /// tier only, matching what the backend requires for `return_wip_to_store`.
  bool get canManageProductionWip => canBackDateProduction;

  /// Whether this user may open the Production Board.
  ///
  /// Mirrors the backend `ROLES.PRODUCTION_VIEW` set exactly — deliberately
  /// NOT `canAccessManagerDashboard`, which admits POS Manager and line
  /// managers that the production API rejects. Gating on a wider set than the
  /// server accepts is how the old Manufacturing screen ended up showing a
  /// tile that failed on every call.
  bool get canAccessProductionBoard =>
      isJarzManager ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator) ||
      isProductionRole ||
      roles.contains(RoleNames.productionOperator);

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
      isB2bSalesRep:
          json['is_b2b_sales_rep'] == true || json['is_b2b_sales_rep'] == 1,
      canAccessB2b:
          json['can_access_b2b'] == true || json['can_access_b2b'] == 1,
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

/// Whether the current user can open the Production Board.
///
/// Role-derived and synchronous — no server probe. The Manufacturing screen
/// used to gate on `managerAccessProvider`, which fires a manager-dashboard
/// request on every open and admits roles the production API rejects.
final canAccessProductionBoardProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessProductionBoard,
    orElse: () => false,
  );
});

/// Whether the current user may start and finish production batches.
final canExecuteProductionProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canExecuteProduction,
    orElse: () => false,
  );
});

/// Whether the current user may post production on a past date.
final canBackDateProductionProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canBackDateProduction,
    orElse: () => false,
  );
});

/// Whether the current user may return stranded WIP material to store.
final canManageProductionWipProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canManageProductionWip,
    orElse: () => false,
  );
});

/// Whether the current user can access B2B mode (sales reps + managers).
final canAccessB2bProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canUseB2b,
    orElse: () => false,
  );
});

/// Whether the current user can VIEW the Pricing (Price Lists) page.
/// Managers get full edit access; B2B sales reps get a read-only view.
final canViewPricingProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessManagerDashboard || roles.canUseB2b,
    orElse: () => false,
  );
});

/// Whether the current user can EDIT pricing (create lists, set category prices,
/// set/remove overrides, assign customers). Managers only; B2B reps are
/// read-only.
final canEditPricingProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canEditPricing,
    orElse: () => false,
  );
});

/// Whether the user needs to open a POS shift.
///
/// Driven solely by `User.custom_require_pos_shift`, which is the same flag the
/// backend enforces. The old line-manager "manager mode" escape hatch is gone:
/// it lived only on the client, so a line manager could take cash with no shift
/// open and leave the money unattributed at close. A line manager who genuinely
/// should not need a shift is configured by clearing the flag on their User.
final requirePosShiftProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  // `valueOrNull` keeps the last successful roles across a refresh failure.
  // `maybeWhen(orElse: false)` used to report "no shift needed" whenever the
  // roles call errored, silently switching the gate off on a network blip.
  final roles = rolesAsync.valueOrNull;
  if (roles == null) return false;
  return roles.requirePosShift;
});

