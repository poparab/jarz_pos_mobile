import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'constants/app_routes.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/pos/presentation/screens/pos_profile_selection_screen.dart';
import '../features/kanban/screens/kanban_board_screen.dart';
import 'session/session_manager.dart';
import '../features/pos/presentation/screens/courier_balances_screen.dart';
import '../features/printing/printer_selection_screen.dart'
    if (dart.library.html) '../features/printing/printer_selection_screen_web.dart';
import '../features/manager/presentation/manager_dashboard_screen.dart';
import '../features/shift_monitor/presentation/shift_monitor_screen.dart';
import '../features/purchase/presentation/purchase_screen.dart';
import '../features/manufacturing/presentation/manufacturing_screen.dart';
import '../features/stock_transfer/presentation/stock_transfer_screen.dart';
import '../features/cash_transfer/presentation/cash_transfer_screen.dart';
import '../features/inventory_count/presentation/inventory_count_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/settings/presentation/user_profile_screen.dart';
import '../features/shift/presentation/shift_start_screen.dart';
import '../features/shift/presentation/shift_end_screen.dart';
import '../features/trips/screens/trips_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/master_orders/presentation/master_orders_screen.dart';
import 'network/user_service.dart';
import '../features/about/presentation/screens/about_screen.dart';

import '../features/shift/state/shift_notifier.dart';
import '../features/shift/models/shift_models.dart';
import '../features/pos/state/pos_notifier.dart';
import 'widgets/global_orientation_enforcer.dart';

// Global RouteObserver for navigation lifecycle (used by Kanban to refresh on return)
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

// Auth state provider that checks stored session on startup
final authStateProvider = FutureProvider<bool>((ref) async {
  final sessionManager = ref.watch(sessionManagerProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  return resolveInitialAuthState(
    isWeb: kIsWeb,
    hasStoredSession: sessionManager.hasValidSession,
    validateSession: authRepo.validateSession,
  );
});

@visibleForTesting
Future<bool> resolveInitialAuthState({
  required bool isWeb,
  required Future<bool> Function() hasStoredSession,
  required Future<bool> Function() validateSession,
}) async {
  try {
    if (!isWeb) {
      final hasSession = await hasStoredSession();
      if (!hasSession) return false;
    }

    return await validateSession();
  } catch (_) {
    return false;
  }
}

// Current auth state for UI
final currentAuthStateProvider = StateProvider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (isAuthenticated) => isAuthenticated,
    orElse: () => false,
  );
});

// Global navigator key so logic outside widgets (e.g., websocket handlers) can show dialogs
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Expose as provider for consumers needing context
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => rootNavigatorKey,
);

@visibleForTesting
String? resolveRouterRedirect({
  required bool isAuthenticated,
  required String location,
  required bool Function() readRequirePosShift,
  required AsyncValue<ShiftEntry?> Function() readActiveShift,
  required Map<String, dynamic>? Function() readSelectedProfile,
}) {
  final isOnLogin = location == AppRoutes.login;
  final isOnShiftStart = location == AppRoutes.shiftStart;
  final isOnProfileSelection = location == AppRoutes.selectProfile;

  if (!isAuthenticated && !isOnLogin) return AppRoutes.login;
  // Send freshly-authenticated users to the root landing gate, which resolves
  // the correct home (Kanban for Jarz POS Staff, POS otherwise) once roles load.
  if (isAuthenticated && isOnLogin) return AppRoutes.root;

  if (!isAuthenticated) return null;

  final requirePosShift = readRequirePosShift();
  final activeShiftAsync = readActiveShift();
  final selectedProfile = readSelectedProfile();

  // Track whether a profile has been selected (used for subsequent checks).
  final hasSelectedProfile = selectedProfile != null;

  // If profile is selected, no need to keep user on profile selection screen.
  if (hasSelectedProfile && isOnProfileSelection) {
    return AppRoutes.pos;
  }

  // Global shift gating: only after POS profile is selected.
  // Each POS profile is independent – shifts on other profiles are irrelevant.
  if (hasSelectedProfile && requirePosShift) {
    final activeShift = activeShiftAsync.valueOrNull;
    final selectedProfileName = (selectedProfile['name'] ?? '').toString();
    final isActiveShiftKnown = !activeShiftAsync.isLoading;

    // While shift data is loading/refreshing, don't redirect.
    if (!isActiveShiftKnown) return null;

    final hasShiftForProfile =
        activeShift != null && activeShift.posProfile == selectedProfileName;

    if (!hasShiftForProfile) {
      // No shift on this profile → force Start Shift.
      if (!isOnShiftStart) return AppRoutes.shiftStart;
    } else if (activeShift.isCurrentUser) {
      // Same user + same profile → go to POS.
      if (isOnShiftStart) return AppRoutes.pos;
    } else {
      // Different user + same profile → block on Start Shift.
      if (!isOnShiftStart) return AppRoutes.shiftStart;
    }
  }

  return null;
}

/// The home route for a user based on their roles: Kanban for Jarz POS Staff
/// (who are not managers), POS for everyone else.
String homeRouteFor(UserRoles roles) =>
    roles.landsOnKanban ? AppRoutes.kanban : AppRoutes.pos;

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentAuthStateProvider);
  final isAuthenticated = authState;

  // Re-run redirects when the user's roles finish loading (e.g. on cold start
  // with a saved session) so the landing gate can resolve the correct home.
  final rolesRefresh = ValueNotifier<int>(0);
  ref.listen(userRolesFutureProvider, (_, _) => rolesRefresh.value++);
  ref.onDispose(rolesRefresh.dispose);

  // Expose a RouteObserver so screens can respond to navigation lifecycle (e.g., refresh on return)
  // Keep a single observer instance; safe to reuse across router rebuilds
  // Note: exported below for screen imports
  // (Declared outside function in actual file scope)

  return GoRouter(
    // On startup: if authenticated, land on the root gate which resolves the
    // correct home (Kanban for Jarz POS Staff, POS otherwise) once roles load.
    initialLocation: isAuthenticated ? AppRoutes.root : AppRoutes.login,
    refreshListenable: rolesRefresh,
    redirect: (context, state) {
      // NOTE: We do NOT redirect non-POS/shift screens when no profile is selected.
      // Kanban, Trips, Expenses, and Courier screens can operate across all accessible
      // profiles without requiring a single selection. Profile selection is only mandatory
      // for POS order creation and authenticated shift management.
      return resolveRouterRedirect(
        isAuthenticated: isAuthenticated,
        location: state.matchedLocation,
        readRequirePosShift: () => ref.read(requirePosShiftProvider),
        readActiveShift: () => ref.read(activeShiftProvider),
        readSelectedProfile: () =>
            ref.read(posNotifierProvider.select((s) => s.selectedProfile)),
      );
    },
    observers: [routeObserver],
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        builder: (context, state) {
          final extra = state.extra;
          final launchData = extra is Map
              ? Map<String, dynamic>.from(extra)
              : null;
          return PosScreen(launchData: launchData);
        },
      ),
      GoRoute(
        path: AppRoutes.selectProfile,
        name: 'pos-select-profile',
        builder: (context, state) => const PosProfileSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.kanban,
        name: 'kanban',
        builder: (context, state) => const KanbanBoardScreen(),
      ),
      GoRoute(
        path: AppRoutes.courierBalances,
        name: 'courier-balances',
        builder: (context, state) => const CourierBalancesScreen(),
      ),
      GoRoute(
        path: AppRoutes.printers,
        name: 'printers',
        builder: (context, state) => const PrinterSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.manager,
        name: 'manager',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.shiftMonitor,
        name: 'shift-monitor',
        builder: (context, state) => const ShiftMonitorScreen(),
      ),
      GoRoute(
        path: AppRoutes.purchase,
        name: 'purchase',
        builder: (context, state) => const PurchaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.manufacturing,
        name: 'manufacturing',
        builder: (context, state) => const ManufacturingScreen(),
      ),
      GoRoute(
        path: AppRoutes.stockTransfer,
        name: 'stock-transfer',
        builder: (context, state) => const StockTransferScreen(),
      ),
      GoRoute(
        path: AppRoutes.cashTransfer,
        name: 'cash-transfer',
        builder: (context, state) => const CashTransferScreen(),
      ),
      GoRoute(
        path: AppRoutes.inventoryCount,
        name: 'inventory-count',
        builder: (context, state) => const InventoryCountScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.trips,
        name: 'trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) =>
            const PhoneLandscapeScope(child: ReportsScreen()),
      ),
      GoRoute(
        path: AppRoutes.masterOrders,
        name: 'master-orders',
        builder: (context, state) => const MasterOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.shiftStart,
        name: 'shift-start',
        builder: (context, state) => const ShiftStartScreen(),
      ),
      GoRoute(
        path: AppRoutes.shiftEnd,
        name: 'shift-end',
        builder: (context, state) => const ShiftEndScreen(),
      ),
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const _LandingGateScreen(),
        redirect: (context, state) {
          if (!ref.read(currentAuthStateProvider)) return AppRoutes.login;
          final rolesAsync = ref.read(userRolesFutureProvider);
          // Stay on the gate (spinner) until roles are known.
          if (!rolesAsync.hasValue) return null;
          return homeRouteFor(rolesAsync.requireValue);
        },
      ),
    ],
    navigatorKey: rootNavigatorKey,
  );
});

/// Minimal splash shown while the landing gate resolves the user's home route.
class _LandingGateScreen extends StatelessWidget {
  const _LandingGateScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
