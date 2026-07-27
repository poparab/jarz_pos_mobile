import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/auth_repository.dart';
import '../../../core/router.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/user_service.dart';
import '../../manager/state/manager_providers.dart';
import '../../shift/state/shift_notifier.dart';
import '../../pos/state/pos_notifier.dart';
import '../../pos/data/repositories/draft_cart_repository.dart';

class LoginNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return false; // not logged in initially
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      final success = await repo.login(username, password);
      if (success) {
        ref.read(currentAuthStateProvider.notifier).state = true;
        // Do NOT invalidate authStateProvider here — it is watched by
        // currentAuthStateProvider whose build() returns false while loading,
        // which would immediately reset the auth state we just set above.
        //
        // Also reset every user-scoped provider/cache so nothing from a
        // previously logged-in user can leak into this session (belt-and-
        // suspenders: logout already does this, but a crash/kill between
        // sessions could skip it).
        _resetUserScopedState();
        state = AsyncData(true);
      } else {
        state = AsyncError('Invalid credentials', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(_mapLoginError(e), st);
    }
  }

  String _mapLoginError(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'Invalid credentials';
      }

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        final message = (error.message ?? '').toLowerCase();
        if (message.contains('no route to host') ||
            message.contains('failed host lookup') ||
            message.contains('socketexception')) {
          return 'Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.';
        }
        return 'Connection failed. Please verify network and server availability.';
      }
      return error.message ?? 'Login failed. Please try again.';
    }

    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception')) {
      return 'Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.';
    }

    return error.toString();
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(currentAuthStateProvider.notifier).state = false;
    ref.invalidate(authStateProvider);
    // Fully wipe every user-scoped provider and per-user Hive cache so no
    // state or permission from the previous user survives into the next login.
    _resetUserScopedState();
    state = AsyncData(false);
  }

  /// Reset all user-scoped Riverpod state and per-user Hive caches so that no
  /// previous-user data (POS profile/cart/customer/promos/amendment context,
  /// shift, roles + derived permissions, manager filters, draft carts, leads
  /// and inventory-count caches) leaks across a logout → login-as-another-user
  /// switch.
  ///
  /// Deliberately does NOT touch device-global state that must survive a user
  /// switch: locale/language (`app_settings`/preferred locale), printer prefs
  /// (`pos_printer_prefs`), the offline sync queue (`offline_queue`) and
  /// alarm-sound prefs. It also does NOT invalidate `authStateProvider` — the
  /// login path relies on it staying set; logout resets it explicitly. FCM/push
  /// token reset is owned by OrderAlertBridge, which reacts to the auth-state
  /// change.
  void _resetUserScopedState() {
    // POS: selected profile, cart, customer, promos, amendment context, drafts.
    ref.invalidate(posNotifierProvider);
    // Shift state.
    ref.invalidate(shiftNotifierProvider);
    ref.invalidate(activeShiftProvider);
    // Roles + every role-derived permission provider (avoids a transient
    // stale-permission window before userRolesFutureProvider refetches).
    ref.invalidate(userRolesFutureProvider);
    ref.invalidate(isJarzManagerProvider);
    ref.invalidate(isLineManagerProvider);
    ref.invalidate(isModeratorProvider);
    ref.invalidate(canAccessManagerDashboardRoleProvider);
    ref.invalidate(canAccessShiftMonitorProvider);
    ref.invalidate(canAccessB2bProvider);
    ref.invalidate(canMuteNotificationsProvider);
    ref.invalidate(requirePosShiftProvider);
    // Manager dashboard access + filter selections.
    ref.invalidate(managerAccessProvider);
    ref.invalidate(selectedBranchProvider);
    ref.invalidate(selectedStateProvider);
    // Per-user Hive caches (async; non-fatal on failure).
    unawaited(_clearUserScopedCaches());
  }

  /// Clear the per-user Hive caches. Guarded so a missing/closed box never
  /// throws, and so we never eagerly open a box just to clear it.
  Future<void> _clearUserScopedCaches() async {
    // Draft carts (owns its own box lifecycle).
    try {
      await ref.read(draftCartRepositoryProvider).clearAll();
    } catch (_) {
      // ignore: clearing caches on logout is best-effort.
    }
    // Leads + inventory-count caches: only clear if already open.
    for (final boxName in const [
      HiveBoxes.leadsCache,
      HiveBoxes.inventoryCount,
    ]) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      } catch (_) {
        // ignore: best-effort per-box clear.
      }
    }
  }
}

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);
