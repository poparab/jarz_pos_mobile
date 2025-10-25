import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';
import '../data/order_alert_service.dart';
import '../domain/invoice_alert.dart';
import '../order_alert_native_channel.dart';
import 'order_alert_state.dart';
import '../../data/repositories/pos_repository.dart';

final orderAlertControllerProvider =
    StateNotifierProvider<OrderAlertController, OrderAlertState>((ref) {
      final service = ref.watch(orderAlertServiceProvider);
      final posRepo = ref.watch(posRepositoryProvider);
      return OrderAlertController(service, posRepo);
    });

class OrderAlertController extends StateNotifier<OrderAlertState> {
  OrderAlertController(this._service, this._posRepository) : super(const OrderAlertState());

  static const _prefKeyToken = 'order_alert_last_token';
  static const _prefKeyUser = 'order_alert_last_user';

  final OrderAlertService _service;
  final PosRepository _posRepository;
  final Logger _logger = Logger('OrderAlertController');

  SharedPreferences? _prefs;
  bool _loadingPending = false;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> enqueueAlert(
    InvoiceAlert alert, {
    bool fromNotification = false,
  }) async {
    _logger.info(
      "enqueueAlert CALLED: invoice=${alert.invoiceId} "
      "requiresAcceptance=${alert.requiresAcceptance} "
      "acceptanceStatus=${alert.acceptanceStatus} "
      "source=${fromNotification ? 'push' : 'realtime'} "
      "currentQueueLen=${state.queue.length}"
    );
    
    if (!alert.requiresAcceptance) {
      _logger.warning(
        "Alert for ${alert.invoiceId} does NOT require acceptance. "
        "Status: ${alert.acceptanceStatus}. Skipping enqueue."
      );
      return;
    }
    
    await OrderAlertNativeChannel.ensureInitialised();
    final currentQueue = List<InvoiceAlert>.from(state.queue);
    final existingIndex = currentQueue.indexWhere(
      (item) => item.invoiceId == alert.invoiceId,
    );
    if (existingIndex >= 0) {
      _logger.info("Updating existing alert for ${alert.invoiceId} at index $existingIndex");
      currentQueue[existingIndex] = alert;
      final isActive = state.active?.invoiceId == alert.invoiceId;
      state = state.copyWith(
        queue: currentQueue,
        active: isActive ? alert : state.active,
        clearError: true,
      );
      return;
    }

    _logger.info("Adding NEW alert for ${alert.invoiceId} to queue");
    currentQueue.add(alert);
    final hasActive = state.hasActive;
    final newActive = hasActive ? state.active : alert;
    final reorderedQueue = _ensureActiveFirst(currentQueue, newActive);

    _logger.info(
      "Setting state: queueLen=${reorderedQueue.length} "
      "activeInvoice=${newActive?.invoiceId} "
      "hasActive=$hasActive "
      "isMuted=${state.isMuted}"
    );

    state = state.copyWith(
      queue: reorderedQueue,
      active: newActive,
      clearError: true,
    );

    if (!hasActive && !state.isMuted) {
      // Check if POS Profile is open before triggering alarm
      final shouldTrigger = await _shouldTriggerAlarm(alert.posProfile);
      if (shouldTrigger) {
        _logger.info('POS Profile is open. Starting alarm for invoice ${alert.invoiceId}');
        await OrderAlertNativeChannel.startAlarm();
      } else {
        _logger.info('POS Profile is closed. Skipping alarm for invoice ${alert.invoiceId}');
      }
    } else {
      _logger.info(
        'NOT starting alarm: hasActive=$hasActive, isMuted=${state.isMuted}'
      );
    }

    if (fromNotification || (!hasActive && !state.isMuted)) {
      _logger.info('Showing notification for ${alert.invoiceId}');
      await OrderAlertNativeChannel.showNotification(
        _buildNotificationData(alert),
      );
    }
  }

  bool hasInvoice(String invoiceId) {
    return state.queue.any((item) => item.invoiceId == invoiceId);
  }

  Future<void> acknowledgeActive() async {
    final current = state.active;
    if (current == null) {
      _logger.debug('acknowledgeActive called with no active alert');
      return;
    }

    state = state.copyWith(isAcknowledging: true, clearError: true);
    try {
      await _service.acknowledgeInvoice(current.invoiceId);
      await OrderAlertNativeChannel.stopAlarm();
      await OrderAlertNativeChannel.cancelNotification(current.invoiceId);
      _removeInvoice(current.invoiceId);
      final next = state.active;
      if (next != null && !state.isMuted) {
        // Check if POS Profile is open before continuing alarm
        final shouldTrigger = await _shouldTriggerAlarm(next.posProfile);
        if (shouldTrigger) {
          _logger.info('POS Profile is open. Continuing alarm with next invoice ${next.invoiceId}');
          await OrderAlertNativeChannel.startAlarm();
        } else {
          _logger.info('POS Profile is closed. Skipping alarm for next invoice ${next.invoiceId}');
        }
      }
      if (!state.hasActive) {
        state = state.copyWith(
          isMuted: false,
          isAcknowledging: false,
          clearError: true,
        );
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to acknowledge invoice ${current.invoiceId}',
        error,
        stackTrace,
      );
      state = state.copyWith(isAcknowledging: false, error: error.toString());
    }
  }

  Future<void> syncPendingAlerts() async {
    _logger.debug("syncPendingAlerts invoked loading=$_loadingPending");
    if (_loadingPending) {
      return;
    }
    _loadingPending = true;
    try {
      final alerts = await _service.getPendingAlerts();
      final now = DateTime.now();
      _logger.info("syncPendingAlerts fetched ${alerts.length} alerts from server");
      
      // If we have local alerts but server returns empty, DON'T clear them immediately
      // This handles the race condition where notification arrives before server API updates
      if (alerts.isEmpty && state.queue.isNotEmpty) {
        _logger.warning(
          "Server returned 0 alerts but we have ${state.queue.length} local alerts. "
          "Keeping local alerts to avoid race condition."
        );
        state = state.copyWith(lastSynced: now);
        _loadingPending = false;
        return;
      }
      
      if (alerts.isEmpty) {
        _logger.info("No pending alerts from server, clearing local queue");
        if (state.hasActive) {
          await OrderAlertNativeChannel.stopAlarm();
        }
        state = state.copyWith(
          queue: const [],
          active: null,
          lastSynced: now,
          clearError: true,
          isAcknowledging: false,
          isMuted: false,
        );
        _loadingPending = false;
        return;
      }

      final existingActiveId = state.active?.invoiceId;
      final candidateActive = existingActiveId != null
          ? alerts.firstWhere(
              (alert) => alert.invoiceId == existingActiveId,
              orElse: () => alerts.first,
            )
          : alerts.first;
      final reordered = _ensureActiveFirst(alerts, candidateActive);

      final newActive = reordered.isNotEmpty ? reordered.first : null;
      state = state.copyWith(
        queue: reordered,
        active: newActive,
        lastSynced: now,
        clearError: true,
        isAcknowledging: false,
      );

      if (existingActiveId != null &&
          (newActive == null || newActive.invoiceId != existingActiveId)) {
        await OrderAlertNativeChannel.stopAlarm();
      }
      if (newActive != null && !state.isMuted) {
        // Check if POS Profile is open before starting alarm
        final shouldTrigger = await _shouldTriggerAlarm(newActive.posProfile);
        if (shouldTrigger) {
          _logger.info('POS Profile is open. Sync ensures alarm for invoice ${newActive.invoiceId}');
          await OrderAlertNativeChannel.startAlarm();
        } else {
          _logger.info('POS Profile is closed. Skipping alarm during sync for invoice ${newActive.invoiceId}');
        }
      }
      if (newActive == null) {
        state = state.copyWith(isMuted: false, clearError: true);
      }
    } catch (error, stackTrace) {
      _logger.error('Failed to sync pending alerts', error, stackTrace);
      state = state.copyWith(
        error: error.toString(),
        lastSynced: DateTime.now(),
      );
    } finally {
      _loadingPending = false;
    }
  }

  Future<void> handleInvoiceAccepted(String invoiceId) async {
    _logger.info("handleInvoiceAccepted invoice=$invoiceId - stopping alarm and removing from queue");
    
    // ALWAYS stop the alarm when we receive an acceptance notification
    // This ensures that if another device accepted, this device stops ringing
    await OrderAlertNativeChannel.stopAlarm();
    await OrderAlertNativeChannel.cancelNotification(invoiceId);
    
    final wasActive = state.active?.invoiceId == invoiceId;
    final removed = _removeInvoice(invoiceId);
    _logger.info("handleInvoiceAccepted invoice=$invoiceId removed=$removed wasActive=$wasActive");
    
    if (!removed) {
      // Even if we don't have this invoice locally, ensure alarm is stopped
      _logger.info("Invoice $invoiceId not in local queue but stopping alarm anyway");
      return;
    }

    if (wasActive) {
      final next = state.active;
      if (next != null && !state.isMuted) {
        // Check if POS Profile is open before starting alarm for next invoice
        final shouldTrigger = await _shouldTriggerAlarm(next.posProfile);
        if (shouldTrigger) {
          _logger.info('POS Profile is open. Switching alarm to next invoice ${next.invoiceId}');
          await OrderAlertNativeChannel.startAlarm();
        } else {
          _logger.info('POS Profile is closed. Skipping alarm for next invoice ${next.invoiceId}');
        }
      } else {
        // No more pending invoices - ensure alarm is completely stopped
        _logger.info('No more pending invoices - stopping alarm completely');
        await OrderAlertNativeChannel.stopAlarm();
      }
      if (!state.hasActive) {
        state = state.copyWith(isMuted: false, clearError: true);
      }
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<bool> shouldRegisterToken(String token, String user) async {
    final prefs = await _preferences();
    final lastToken = prefs.getString(_prefKeyToken);
    final lastUser = prefs.getString(_prefKeyUser);
    return lastToken != token || lastUser != user;
  }

  Future<void> markTokenRegistered(String token, String user) async {
    final prefs = await _preferences();
    await prefs.setString(_prefKeyToken, token);
    await prefs.setString(_prefKeyUser, user);
  }

  Future<void> resetTokenCache() async {
    final prefs = await _preferences();
    await prefs.remove(_prefKeyToken);
    await prefs.remove(_prefKeyUser);
  }

  Future<void> clearAll() async {
    await OrderAlertNativeChannel.stopAlarm();
    state = const OrderAlertState();
  }

  Future<void> muteActiveAlert() async {
    if (!state.hasActive || state.isMuted) {
      return;
    }
    _logger.info('Muting alarm for invoice ${state.active?.invoiceId}');
    await OrderAlertNativeChannel.stopAlarm();
    state = state.copyWith(isMuted: true, clearError: true);
  }

  Future<void> unmuteAlerts() async {
    if (!state.isMuted) {
      return;
    }
    _logger.info('Unmuting alarm');
    state = state.copyWith(isMuted: false, clearError: true);
    if (state.hasActive) {
      // Check if POS Profile is open before starting alarm when unmuting
      final shouldTrigger = await _shouldTriggerAlarm(state.active!.posProfile);
      if (shouldTrigger) {
        _logger.info('POS Profile is open. Starting alarm after unmute');
        await OrderAlertNativeChannel.startAlarm();
      } else {
        _logger.info('POS Profile is closed. Skipping alarm after unmute');
      }
    }
  }

  Map<String, String> _buildNotificationData(InvoiceAlert alert) {
    final data = <String, String>{
      'type': 'new_invoice',
      'invoice_id': alert.invoiceId,
      'customer_name': alert.customerName ?? '',
      'pos_profile': alert.posProfile,
      'grand_total': alert.grandTotal.toString(),
      'sales_invoice_state': alert.salesInvoiceState ?? '',
      'timestamp': (alert.timestamp ?? DateTime.now()).toIso8601String(),
      'requires_acceptance': alert.requiresAcceptance ? '1' : '0',
    };
    if (alert.itemSummary != null) {
      data['item_summary'] = alert.itemSummary!;
    }
    return data;
  }

  bool _removeInvoice(String invoiceId) {
    final currentQueue = List<InvoiceAlert>.from(state.queue);
    InvoiceAlert? removed;
    currentQueue.removeWhere((alert) {
      final match = alert.invoiceId == invoiceId;
      if (match) {
        removed = alert;
      }
      return match;
    });
    if (removed == null) {
      return false;
    }

    final nextActive = currentQueue.isNotEmpty ? currentQueue.first : null;
    state = state.copyWith(
      queue: currentQueue,
      active: nextActive,
      isAcknowledging: false,
      clearError: true,
      isMuted: nextActive == null ? false : state.isMuted,
    );
    return true;
  }

  List<InvoiceAlert> _ensureActiveFirst(
    List<InvoiceAlert> queue,
    InvoiceAlert? active,
  ) {
    if (queue.isEmpty || active == null) {
      return List<InvoiceAlert>.from(queue);
    }
    final reordered = List<InvoiceAlert>.from(queue);
    final index = reordered.indexWhere(
      (alert) => alert.invoiceId == active.invoiceId,
    );
    if (index > 0) {
      final entry = reordered.removeAt(index);
      reordered.insert(0, entry);
    } else if (index == -1) {
      reordered.insert(0, active);
    }
    return reordered;
  }

  /// Check if the POS Profile is currently open based on its timetable
  Future<bool> _shouldTriggerAlarm(String posProfile) async {
    try {
      final result = await _posRepository.isPosProfileOpen(posProfile);
      final isOpen = result['is_open'] as bool? ?? true;
      
      if (!isOpen) {
        _logger.info(
          'POS Profile $posProfile is closed: ${result['message']}. '
          'Alarm will not be triggered.'
        );
      }
      
      return isOpen;
    } catch (e) {
      _logger.error('Error checking POS profile timetable: $e. Defaulting to trigger alarm.');
      // If there's an error checking the timetable, default to triggering the alarm
      // to avoid missing important alerts
      return true;
    }
  }
}
