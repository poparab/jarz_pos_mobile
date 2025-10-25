import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/pos/presentation/screens/pos_profile_selection_screen.dart';
import '../features/kanban/screens/kanban_board_screen.dart';
import 'session/session_manager.dart';
import '../features/pos/presentation/screens/courier_balances_screen.dart';
import '../features/printing/printer_selection_screen.dart';
import '../features/manager/presentation/manager_dashboard_screen.dart';
import '../features/purchase/presentation/purchase_screen.dart';
import '../features/manufacturing/presentation/manufacturing_screen.dart';
import '../features/stock_transfer/presentation/stock_transfer_screen.dart';
import '../features/cash_transfer/presentation/cash_transfer_screen.dart';
import '../features/inventory_count/presentation/inventory_count_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/settings/presentation/user_profile_screen.dart';

// Global RouteObserver for navigation lifecycle (used by Kanban to refresh on return)
final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

// Auth state provider that checks stored session on startup
final authStateProvider = FutureProvider<bool>((ref) async {
  final sessionManager = ref.watch(sessionManagerProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  // Check if we have a stored session
  final hasSession = await sessionManager.hasValidSession();
  if (!hasSession) return false;

  // Validate the session with the server
  return await authRepo.validateSession();
});

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
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) => rootNavigatorKey);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentAuthStateProvider);
  final isAuthenticated = authState;

  // Expose a RouteObserver so screens can respond to navigation lifecycle (e.g., refresh on return)
  // Keep a single observer instance; safe to reuse across router rebuilds
  // Note: exported below for screen imports
  // (Declared outside function in actual file scope)
  
  return GoRouter(
    // On startup: if authenticated, land on Kanban without forcing POS profile selection
    initialLocation: isAuthenticated ? '/kanban' : '/login',
    redirect: (context, state) {
      final isOnLogin = state.matchedLocation == '/login';
      // Not authenticated -> force login
      if (!isAuthenticated && !isOnLogin) return '/login';
      // Authenticated on login -> go to Kanban
      if (isAuthenticated && isOnLogin) return '/kanban';
      return null; // no change
    },
  observers: [routeObserver],
  routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: '/pos/select-profile',
        name: 'pos-select-profile',
        builder: (context, state) => const PosProfileSelectionScreen(),
      ),
      GoRoute(
        path: '/kanban',
        name: 'kanban',
        builder: (context, state) => const KanbanBoardScreen(),
      ),
      GoRoute(
        path: '/courier-balances',
        name: 'courier-balances',
        builder: (context, state) => const CourierBalancesScreen(),
      ),
      GoRoute(
        path: '/printers',
        name: 'printers',
        builder: (context, state) => const PrinterSelectionScreen(),
      ),
      GoRoute(
        path: '/manager',
        name: 'manager',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/purchase',
        name: 'purchase',
        builder: (context, state) => const PurchaseScreen(),
      ),
      GoRoute(
        path: '/manufacturing',
        name: 'manufacturing',
        builder: (context, state) => const ManufacturingScreen(),
      ),
      GoRoute(
        path: '/stock-transfer',
        name: 'stock-transfer',
        builder: (context, state) => const StockTransferScreen(),
      ),
      GoRoute(
        path: '/cash-transfer',
        name: 'cash-transfer',
        builder: (context, state) => const CashTransferScreen(),
      ),
      GoRoute(
        path: '/inventory-count',
        name: 'inventory-count',
        builder: (context, state) => const InventoryCountScreen(),
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
  GoRoute(path: '/', redirect: (context, state) => '/kanban'),
    ],
  navigatorKey: rootNavigatorKey,
  );
});

