import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router.dart';
import '../order_alert_native_channel.dart';
import '../state/order_alert_controller.dart';
import '../state/order_alert_state.dart';
import '../../../../core/network/user_service.dart';
import 'order_alert_dialog.dart';

class OrderAlertListener extends ConsumerStatefulWidget {
  const OrderAlertListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OrderAlertListener> createState() => _OrderAlertListenerState();
}

class _OrderAlertListenerState extends ConsumerState<OrderAlertListener>
    with WidgetsBindingObserver {
  bool _dialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OrderAlertNativeChannel.setVolumeLocked(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OrderAlertNativeChannel.setVolumeLocked(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(currentAuthStateProvider)) {
      Future.microtask(
        () =>
            ref.read(orderAlertControllerProvider.notifier).syncPendingAlerts(),
      );
    }
  }

  void _handleStateChange(OrderAlertState? previous, OrderAlertState next) {
    final isManager = ref.read(isJarzManagerProvider);

    if (next.error != null && next.error != previous?.error) {
      final scaffold = ScaffoldMessenger.maybeOf(context);
      if (scaffold != null) {
        scaffold.showSnackBar(SnackBar(content: Text(next.error!)));
      }
    }

    final nextActive = next.active;
    final previousActive = previous?.active;

    debugPrint(
      '🔔 OrderAlertListener: State changed - '
      'nextActive=${nextActive?.invoiceId} '
      'previousActive=${previousActive?.invoiceId} '
      'dialogVisible=$_dialogVisible '
      'queueLen=${next.queue.length}'
    );

    if (nextActive != null &&
        (!_dialogVisible ||
            previousActive?.invoiceId != nextActive.invoiceId)) {
      debugPrint('🔔 SHOWING dialog for ${nextActive.invoiceId}');
      _showDialog();
    } else if (nextActive == null && _dialogVisible) {
      debugPrint('🔔 CLOSING dialog - no active alerts');
      _closeDialog();
    } else if (nextActive != null && _dialogVisible) {
      debugPrint('🔔 Dialog already visible for ${nextActive.invoiceId}');
    }

    final shouldLockVolume = next.hasActive && !next.isMuted && !isManager;
    final previousLock =
        previous?.hasActive == true &&
        !(previous?.isMuted ?? false) &&
        !isManager;
    if (shouldLockVolume != previousLock) {
      OrderAlertNativeChannel.setVolumeLocked(shouldLockVolume);
    }
  }

  void _showDialog() {
    if (!mounted) return;
    _dialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const OrderAlertDialog(),
    ).whenComplete(() {
      _dialogVisible = false;
    });
  }

  void _closeDialog() {
    if (!mounted || !_dialogVisible) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _dialogVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OrderAlertState>(
      orderAlertControllerProvider,
      (previous, next) => _handleStateChange(previous, next),
    );

    return widget.child;
  }
}
