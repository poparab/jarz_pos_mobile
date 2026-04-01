import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/timing_config.dart';
import '../../../core/websocket/websocket_service.dart';
import 'courier_balances_provider.dart';

/// Listens to websocket events that impact courier balances and triggers reloads.
final courierWsBridgeProvider = Provider.autoDispose<void>((ref) {
  final keep = ref.keepAlive();
  final ws = ref.watch(webSocketServiceProvider);
  Timer? debounce;

  void trigger() {
    debounce?.cancel();
    debounce = Timer(UiDebounce.courierBridge, () {
      ref.read(courierBalancesProvider.notifier).load();
    });
  }

  // Only listen to courier-specific updates, not kanban updates
  final sub = ws.courierUpdates.listen((_) => trigger());
  ref.onDispose(() {
    sub.cancel();
    debounce?.cancel();
    keep.close();
  });
});
