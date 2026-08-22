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

  /// Both spellings of the line-manager Role exist as real records on staging
  /// and production, and the backend's `ROLES.LINE_MANAGER_TIER` carries both.
  /// Matching only the capitalised one left a line manager holding the other
  /// spelling looking like a plain POS user to every gate below.
  bool get isLineManager =>
      roles.contains(RoleNames.jarzLineManager) ||
      roles.contains(RoleNames.jarzLineManagerAlt);
  bool get isAdminManager =>
      roles.contains(RoleNames.posManager) ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator);

  /// Everything a JARZ line manager may do, the manager tier and the
  /// Administrator may do too — the line manager is a *narrower* manager, never
  /// the holder of an authority its own manager lacks. Mirrors the backend
  /// `ROLES.LINE_MANAGER_TIER`.
  ///
  /// Gate line-manager actions on this, NOT on [isLineManager]: cancel and
  /// return were gated on the bare role for months, so a JARZ Manager could not
  /// cancel or return an order on their own branch.
  bool get canActAsLineManager =>
      isLineManager || isJarzManager || isAdminManager;
  bool get canAccessManagerDashboard =>
      isJarzManager || isLineManager || isAdminManager;
  bool get isJarzPosStaff => roles.contains(RoleNames.jarzPosStaff);

  /// Lands on the Kanban board (instead of POS) only when the user is
  /// Jarz POS Staff AND not a manager — managers keep the POS home.
  bool get landsOnKanban => isJarzPosStaff && !canAccessManagerDashboard;
  bool get canAccessShiftMonitor =>
      isJarzManager || isAdminManager || isLineManager;
  bool get isModerator => roles.contains(RoleNames.moderator);
  /// The admin tier is included deliberately: ACCESS_MATRIX has always listed
  /// mute as a High Management capability, but the check omitted it, so a
  /// System-Manager-only account could not mute while a Moderator could.
  bool get canMuteNotifications =>
      isJarzManager || isLineManager || isModerator || isAdminManager;

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

  // ── Gates that mirror one backend role set each ──────────────────────
  //
  // Each of these mirrors the set its OWN API accepts, never the general
  // manager-dashboard gate. `canAccessManagerDashboard` is satisfied by any
  // line manager (the dashboard's own backend check accepts the line-manager
  // tier), but the APIs behind Cash Transfer, Stock Transfer, Inventory Count,
  // the Purchase Invoice and the analytics reports do not — so gating a drawer
  // entry on it shows a line manager a tile that answers "Not permitted" on
  // every call. Same class of bug as the old Manufacturing screen; see
  // [canAccessProductionBoard].
  //
  // `Administrator` is carried in every set because `frappe.get_roles` hands
  // that user every role, so the server always lets it through.

  /// Mirrors backend `ROLES.MANAGER` — Cash Transfer (`api/cash_transfer.py`)
  /// and Stock Transfer (`api/transfer.py`).
  bool get _isBackendManagerSet =>
      isJarzManager ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator) ||
      roles.contains(RoleNames.accountsManager) ||
      roles.contains(RoleNames.stockManager) ||
      roles.contains(RoleNames.manufacturingManager) ||
      roles.contains(RoleNames.purchaseManager);

  /// Whether this user may move cash between accounts.
  /// Mirrors `ROLES.MANAGER`, enforced by `cash_transfer._ensure_manager_access`.
  bool get canAccessCashTransfer => _isBackendManagerSet;

  /// Whether this user may move stock between warehouses.
  /// Mirrors `ROLES.MANAGER`, enforced by `transfer._ensure_manager_access`.
  /// Kept separate from [canAccessCashTransfer] even though the two sets are
  /// identical today, so tightening one server-side is a one-line change here.
  bool get canAccessStockTransfer => _isBackendManagerSet;

  /// Whether this user may run an inventory count.
  /// Mirrors `ROLES.STOCK`, enforced by
  /// `inventory_count._ensure_manager_access` — the same set as
  /// [canAccessCashTransfer] minus Purchase Manager.
  bool get canAccessInventoryCount =>
      isJarzManager ||
      roles.contains(RoleNames.systemManager) ||
      roles.contains(RoleNames.administrator) ||
      roles.contains(RoleNames.accountsManager) ||
      roles.contains(RoleNames.stockManager) ||
      roles.contains(RoleNames.manufacturingManager);

  /// Whether this user may raise a Purchase Invoice (buying against a request,
  /// which commits money — distinct from *asking* for stock, which
  /// `ROLES.PURCHASE_REQUEST` opens to everyone).
  /// Mirrors `ROLES.PURCHASE`, enforced by `purchase._ensure_manager_access`.
  bool get canAccessPurchaseInvoice => _isBackendManagerSet;

  /// Whether this user may open the analytics dashboards behind the Reports hub
  /// (shipping, inventory, product, customer, executive, B2B) and the Final
  /// Products stock report. Mirrors `_ensure_jarz_manager`, which every one of
  /// those endpoints calls: the JARZ Manager and the Administrator, nobody
  /// else. Note that System Manager and POS Manager are NOT in it.
  bool get canViewAllReports =>
      isJarzManager || roles.contains(RoleNames.administrator);

  /// Whether this user may open the Materials & Consumables report — the one
  /// report a line manager can actually read. Mirrors
  /// `reports._ensure_materials_report_access`, i.e. `ROLES.LINE_MANAGER_TIER`.
  bool get canViewMaterialsReport =>
      isLineManager ||
      isJarzManager ||
      roles.contains(RoleNames.administrator) ||
      roles.contains(RoleNames.systemManager);

  /// Whether the Reports hub has anything at all to show this user.
  ///
  /// The hub is kept rather than hidden for the line-manager tier because it
  /// still holds one readable report for them; the screen itself drops every
  /// tile whose API would refuse them, so the hub is never an empty page and
  /// never a dead link. A POS Manager, who is in neither set, loses the entry
  /// entirely — every tile on it would have 403'd.
  bool get canAccessReportsHub => canViewAllReports || canViewMaterialsReport;

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

/// Whether the user may take any line-manager action (cancel order, return
/// order, …). True for the line manager, the JARZ Manager and the admin tier.
final canActAsLineManagerProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canActAsLineManager,
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

/// Remembers the last answer [userRolesFutureProvider] gave for
/// [UserRoles.canMuteNotifications], for the duration of the session.
///
/// `maybeWhen(orElse: false)` answers "no" on every *reload* of the roles
/// future and on any transient failure. That is the wrong default here: it made
/// the mute button vanish from a ringing alarm — mid-alarm, with the volume keys
/// locked — every time roles were refetched or the network hiccuped, leaving a
/// manager with no way to silence the device. Cleared on logout by
/// [OrderAlertBridge] so it can never leak across users.
class CanMuteNotificationsCache extends StateNotifier<bool> {
  CanMuteNotificationsCache(this._ref) : super(false) {
    _ref.listen<AsyncValue<UserRoles>>(
      userRolesFutureProvider,
      (_, next) {
        final roles = next.valueOrNull;
        if (roles != null) {
          state = roles.canMuteNotifications;
        }
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;

  void clear() => state = false;
}

final canMuteNotificationsCacheProvider =
    StateNotifierProvider<CanMuteNotificationsCache, bool>(
  CanMuteNotificationsCache.new,
);

final canMuteNotificationsProvider = Provider<bool>((ref) {
  // Watched unconditionally: the cache only records while something keeps it
  // alive, and it has to be recording *before* the roles future starts
  // reloading, not after.
  final cached = ref.watch(canMuteNotificationsCacheProvider);
  final roles = ref.watch(userRolesFutureProvider).valueOrNull;
  return roles?.canMuteNotifications ?? cached;
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

/// Whether the current user may open Cash Transfer.
///
/// Mirrors backend `ROLES.MANAGER`, not the manager-dashboard gate: a line
/// manager passes the latter and is refused by `api/cash_transfer.py`.
final canAccessCashTransferProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessCashTransfer,
    orElse: () => false,
  );
});

/// Whether the current user may open Stock Transfer. Mirrors `ROLES.MANAGER`
/// as enforced by `api/transfer.py`.
final canAccessStockTransferProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessStockTransfer,
    orElse: () => false,
  );
});

/// Whether the current user may open Inventory Count. Mirrors `ROLES.STOCK`
/// as enforced by `api/inventory_count.py`.
final canAccessInventoryCountProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessInventoryCount,
    orElse: () => false,
  );
});

/// Whether the current user may open the Purchase Invoice screen. Mirrors
/// `ROLES.PURCHASE` as enforced by `api/purchase.py`. Note this is NOT the gate
/// for raising an item request — `ROLES.PURCHASE_REQUEST` is deliberately open
/// to everyone, so that drawer entry stays ungated.
final canAccessPurchaseInvoiceProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessPurchaseInvoice,
    orElse: () => false,
  );
});

/// Whether the Reports hub has at least one report this user may read.
///
/// True for the line-manager tier because the hub still shows them Materials &
/// Consumables; the hub itself hides the dashboards their role would be refused
/// on. See [UserRoles.canAccessReportsHub].
final canAccessReportsHubProvider = Provider<bool>((ref) {
  final rolesAsync = ref.watch(userRolesFutureProvider);
  return rolesAsync.maybeWhen(
    data: (roles) => roles.canAccessReportsHub,
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

