import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/order_alert_controller.dart';
import '../order_alert_native_channel.dart';
import '../../../../core/network/user_service.dart';
import 'order_alert_dialog.dart';

/// Global overlay-based alert system that doesn't depend on Navigator context
class OrderAlertOverlay extends ConsumerStatefulWidget {
  const OrderAlertOverlay({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OrderAlertOverlay> createState() => _OrderAlertOverlayState();
}

class _OrderAlertOverlayState extends ConsumerState<OrderAlertOverlay> {
  OverlayEntry? _overlayEntry;
  String? _currentInvoiceId;
  Timer? _pollTimer;
  bool _isDisposed = false;
  bool _isShowingOverlay = false;

  @override
  void initState() {
    super.initState();
    OrderAlertNativeChannel.setVolumeLocked(false);
    
    // Start polling for pending alerts after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    
    // Safely remove overlay
    if (_overlayEntry != null && mounted) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        debugPrint('🔔 OVERLAY: Error removing overlay during dispose: $e');
      }
      _overlayEntry = null;
    }
    
    OrderAlertNativeChannel.setVolumeLocked(false);
    super.dispose();
  }

  void _startPolling() {
    // Poll every 2 seconds to check for pending alerts
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isDisposed && mounted) {
        _checkForAlerts();
      }
    });
    
    // Check immediately
    if (!_isDisposed && mounted) {
      _checkForAlerts();
    }
  }

  void _checkForAlerts() {
    if (_isDisposed || !mounted || _isShowingOverlay) {
      return;
    }

    try {
      final state = ref.read(orderAlertControllerProvider);
      final nextActive = state.active;
      
      debugPrint(
        '🔔 OVERLAY: Checking alerts - '
        'active=${nextActive?.invoiceId} '
        'current=$_currentInvoiceId '
        'overlayShowing=${_overlayEntry != null} '
        'queueLen=${state.queue.length}'
      );
      
      if (nextActive != null && nextActive.invoiceId != _currentInvoiceId) {
        debugPrint('🔔 OVERLAY: SHOWING for ${nextActive.invoiceId}');
        _showOverlay(nextActive.invoiceId);
      } else if (nextActive == null && _overlayEntry != null) {
        debugPrint('🔔 OVERLAY: REMOVING - no active alerts');
        _removeOverlay();
      }
    } catch (e, stack) {
      debugPrint('🔔 OVERLAY: Error in _checkForAlerts: $e\n$stack');
    }
  }

  void _showOverlay(String invoiceId) {
    if (_isDisposed || !mounted || _isShowingOverlay) {
      return;
    }

    _isShowingOverlay = true;
    
    // Remove any existing overlay first
    _removeOverlay();
    
    _currentInvoiceId = invoiceId;
    
    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => _OverlayContent(
          onDismiss: _removeOverlay,
        ),
      );
      
      // Use WidgetsBinding to ensure we have a valid overlay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && _overlayEntry != null) {
          try {
            final overlay = Overlay.of(context, rootOverlay: true);
            overlay.insert(_overlayEntry!);
            debugPrint('🔔 OVERLAY: Successfully inserted overlay for $invoiceId');
          } catch (e) {
            debugPrint('🔔 OVERLAY: Error inserting overlay: $e');
            _overlayEntry = null;
            _currentInvoiceId = null;
          }
        }
        _isShowingOverlay = false;
      });
    } catch (e) {
      debugPrint('🔔 OVERLAY: Error creating overlay: $e');
      _overlayEntry = null;
      _currentInvoiceId = null;
      _isShowingOverlay = false;
    }
  }

  void _removeOverlay() {
    if (_overlayEntry == null) {
      return;
    }

    try {
      debugPrint('🔔 OVERLAY: Removing overlay for $_currentInvoiceId');
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint('🔔 OVERLAY: Error removing overlay: $e');
    } finally {
      _overlayEntry = null;
      _currentInvoiceId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to trigger overlay updates
    ref.listen<dynamic>(
      orderAlertControllerProvider,
      (previous, next) {
        _checkForAlerts();
      },
    );

    return widget.child;
  }
}

class _OverlayContent extends ConsumerWidget {
  const _OverlayContent({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderAlertControllerProvider);
    final alert = state.active;
    final isManager = ref.watch(isJarzManagerProvider);

    if (alert == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.black54, // Semi-transparent background
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(24),
          child: OrderAlertDialog(
            onAccept: () async {
              await ref.read(orderAlertControllerProvider.notifier).acknowledgeActive();
            },
            onMute: isManager
                ? () async {
                    if (state.isMuted) {
                      await ref.read(orderAlertControllerProvider.notifier).unmuteAlerts();
                    } else {
                      await ref.read(orderAlertControllerProvider.notifier).muteActiveAlert();
                    }
                  }
                : null,
            isMuted: state.isMuted,
            isAcknowledging: state.isAcknowledging,
            error: state.error,
          ),
        ),
      ),
    );
  }
}
