import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../../../core/router.dart';

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
        // Invalidate auth state provider to refresh with new session
        ref.invalidate(authStateProvider);
        state = AsyncData(true);
      } else {
        state = AsyncError('Invalid credentials', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(currentAuthStateProvider.notifier).state = false;
    ref.invalidate(authStateProvider);
    state = AsyncData(false);
  }
}

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);
