import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/pos/presentation/screens/pos_profile_selection_screen.dart';
import '../features/kanban/screens/kanban_board_screen.dart';
import 'session/session_manager.dart';
import '../features/pos/state/pos_notifier.dart';
import '../features/pos/presentation/screens/courier_balances_screen.dart';

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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentAuthStateProvider);
  // Watch only the selected profile to avoid router recreation on unrelated POS state changes (like cart updates)
  final selectedProfile = ref.watch(posNotifierProvider.select((s) => s.selectedProfile));
  final isAuthenticated = authState;
  final needProfileSelection = isAuthenticated && selectedProfile == null; // require a profile for any POS-dependent route

  // Expose a RouteObserver so screens can respond to navigation lifecycle (e.g., refresh on return)
  // Keep a single observer instance; safe to reuse across router rebuilds
  // Note: exported below for screen imports
  // (Declared outside function in actual file scope)
  
  return GoRouter(
    initialLocation: isAuthenticated
  ? (needProfileSelection ? '/pos-profile-selection' : '/kanban')
        : '/login',
    redirect: (context, state) {
      final isOnLogin = state.matchedLocation == '/login';
      final isOnSelection = state.matchedLocation == '/pos-profile-selection';
      final isKanban = state.matchedLocation == '/kanban';
      final isPos = state.matchedLocation == '/pos';
      final needSelection = needProfileSelection;

      // Not authenticated -> force login
      if (!isAuthenticated && !isOnLogin) return '/login';

      // Authenticated on login -> send to appropriate start
      if (isAuthenticated && isOnLogin) {
  return needSelection ? '/pos-profile-selection' : '/kanban';
      }

      // Need to pick profile but not on selection page
      if (isAuthenticated && needSelection && !isOnSelection) {
        return '/pos-profile-selection';
      }

      // Already selected profile but still on selection page -> forward to Kanban
      if (isAuthenticated && !needSelection && isOnSelection) {
        return '/kanban';
      }

      // Block kanban if profile not selected
      if (isAuthenticated && needSelection && (isKanban || isPos)) {
        return '/pos-profile-selection';
      }

      return null; // no change
    },
  observers: [routeObserver],
  routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/pos-profile-selection',
        builder: (context, state) => const PosProfileSelectionScreen(),
      ),
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const PosScreen(),
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
  GoRoute(path: '/', redirect: (context, state) => '/kanban'),
    ],
  );
});

