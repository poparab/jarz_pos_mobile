import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../../../core/router.dart';
import '../../../core/network/user_service.dart';
import '../../manager/state/manager_providers.dart';
import '../../shift/state/shift_notifier.dart';

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
        ref.invalidate(activeShiftProvider);
        ref.invalidate(userRolesFutureProvider);
        ref.invalidate(isJarzManagerProvider);
        ref.invalidate(managerAccessProvider);
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
    ref.invalidate(activeShiftProvider);
    ref.invalidate(userRolesFutureProvider);
    ref.invalidate(isJarzManagerProvider);
    ref.invalidate(managerAccessProvider);
    state = AsyncData(false);
  }
}

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);
