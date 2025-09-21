import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/websocket/websocket_service.dart';
import 'courier_balances_provider.dart';

/// Listens to websocket events that impact courier balances and triggers reloads.
final courierWsBridgeProvider = Provider.autoDispose<void>((ref) {
  final keep = ref.keepAlive();
  final ws = ref.watch(webSocketServiceProvider);
  Timer? debounce;

  void trigger() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(courierBalancesProvider.notifier).load();
    });
  }

  final sub1 = ws.kanbanUpdates.listen((_) => trigger());
  final sub2 = ws.courierUpdates.listen((_) => trigger());
  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    debounce?.cancel();
    keep.close();
  });
});
