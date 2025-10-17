import 'dart:async';

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
  String? _currentDialogInvoiceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OrderAlertNativeChannel.setVolumeLocked(false);
    
    // Post-frame callback to check for alerts after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDialog();
    });
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

  void _checkAndShowDialog() {
    if (!mounted) return;
    
    final state = ref.read(orderAlertControllerProvider);
    final nextActive = state.active;
    
    debugPrint(
      '🔔 _checkAndShowDialog: '
      'nextActive=${nextActive?.invoiceId} '
      'currentDialog=$_currentDialogInvoiceId '
      'dialogVisible=$_dialogVisible '
      'queueLen=${state.queue.length}'
    );
    
    // If there's an active alert but no dialog is showing, force show it
    if (nextActive != null) {
      if (_currentDialogInvoiceId == null || !_dialogVisible) {
        debugPrint('🔔 FORCE SHOWING dialog for ${nextActive.invoiceId} (was not showing)');
        _dialogVisible = false; // Reset state
        _currentDialogInvoiceId = null;
        _showDialog(nextActive.invoiceId);
      } else if (nextActive.invoiceId != _currentDialogInvoiceId) {
        debugPrint('🔔 SHOWING NEW dialog for ${nextActive.invoiceId} (different from current)');
        _showDialog(nextActive.invoiceId);
      } else {
        debugPrint('🔔 Dialog already showing for correct invoice ${nextActive.invoiceId}');
      }
    } else if (_dialogVisible) {
      debugPrint('🔔 CLOSING dialog - no active alerts');
      _closeDialog();
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
      'currentDialog=$_currentDialogInvoiceId '
      'dialogVisible=$_dialogVisible '
      'queueLen=${next.queue.length}'
    );

    // Always check if we need to show dialog when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDialog();
    });

    final shouldLockVolume = next.hasActive && !next.isMuted && !isManager;
    final previousLock =
        previous?.hasActive == true &&
        !(previous?.isMuted ?? false) &&
        !isManager;
    if (shouldLockVolume != previousLock) {
      OrderAlertNativeChannel.setVolumeLocked(shouldLockVolume);
    }
  }

  void _showDialog(String invoiceId) {
    if (!mounted) {
      debugPrint('🔔 ❌ Cannot show dialog - widget not mounted');
      return;
    }
    
    // If we're already showing a dialog for this invoice, don't show again
    if (_dialogVisible && _currentDialogInvoiceId == invoiceId) {
      debugPrint('🔔 Dialog already showing for $invoiceId, skipping');
      return;
    }
    
    // Close existing dialog if showing different invoice
    if (_dialogVisible && _currentDialogInvoiceId != invoiceId) {
      debugPrint('🔔 Closing old dialog for $_currentDialogInvoiceId to show new dialog for $invoiceId');
      _closeDialog();
      // Wait a frame before showing new dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog(invoiceId);
      });
      return;
    }
    
    _dialogVisible = true;
    _currentDialogInvoiceId = invoiceId;
    
    debugPrint('🔔 📱 ============================================');
    debugPrint('🔔 📱 ACTUALLY CALLING showDialog() for $invoiceId');
    debugPrint('🔔 📱 context.mounted: ${context.mounted}');
    debugPrint('🔔 📱 useRootNavigator: true');
    debugPrint('🔔 📱 barrierDismissible: false');
    debugPrint('🔔 📱 ============================================');
    
    unawaited(
      _showDialogAsync(invoiceId),
    );
  }
  
  Future<void> _showDialogAsync(String invoiceId) async {
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) {
          debugPrint('🔔 📱 Dialog builder called for $invoiceId');
          return const OrderAlertDialog();
        },
      );
      
      debugPrint('🔔 Dialog completed for $_currentDialogInvoiceId');
      _dialogVisible = false;
      _currentDialogInvoiceId = null;
      
      // Check if there's another alert waiting
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowDialog();
      });
    } catch (error) {
      debugPrint('🔔 ❌ Dialog ERROR for $_currentDialogInvoiceId: $error');
      _dialogVisible = false;
      _currentDialogInvoiceId = null;
    }
  }

  void _closeDialog() {
    if (!mounted || !_dialogVisible) return;
    debugPrint('🔔 Attempting to close dialog for $_currentDialogInvoiceId');
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _dialogVisible = false;
    _currentDialogInvoiceId = null;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes
    ref.listen<OrderAlertState>(
      orderAlertControllerProvider,
      (previous, next) => _handleStateChange(previous, next),
    );
    
    // ALSO check current state on every build to catch missed updates
    final currentState = ref.watch(orderAlertControllerProvider);
    
    // Use post-frame callback to show dialog if needed
    // This ensures we don't modify state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final nextActive = currentState.active;
        if (nextActive != null && nextActive.invoiceId != _currentDialogInvoiceId && !_dialogVisible) {
          debugPrint('🔔 Build detected unshown alert: ${nextActive.invoiceId}');
          _checkAndShowDialog();
        }
      }
    });

    return widget.child;
  }
}
