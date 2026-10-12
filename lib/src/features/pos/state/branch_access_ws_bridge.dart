import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../../../core/websocket/websocket_service.dart';
import 'pos_notifier.dart';

/// Quiet window that folds a burst of branch-access events (a branch move
/// sends an add and a remove back to back) into one refresh.
const branchAccessRefreshDebounce = Duration(milliseconds: 600);

/// Re-reads this user's branches when the server says their access changed.
///
/// Without it a person given a new branch would only see it after restarting
/// the app: the POS branch list is otherwise loaded once, when the POS,
/// branch-selection or Kanban screen first mounts. Roles are re-read too, so
/// branch- and role-dependent menus follow.
final branchAccessWsBridgeProvider = Provider.autoDispose<void>((ref) {
  final keep = ref.keepAlive();
  final ws = ref.watch(webSocketServiceProvider);
  Timer? debounce;

  void trigger() {
    debounce?.cancel();
    debounce = Timer(branchAccessRefreshDebounce, () {
      ref.invalidate(userRolesFutureProvider);
      ref.read(posNotifierProvider.notifier).refreshProfileList();
    });
  }

  final sub = ws.branchAccessUpdates.listen((_) => trigger());
  ref.onDispose(() {
    sub.cancel();
    debounce?.cancel();
    keep.close();
  });
});
