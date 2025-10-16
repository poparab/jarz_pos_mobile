import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';
import '../data/order_alert_service.dart';
import '../domain/invoice_alert.dart';
import '../order_alert_native_channel.dart';
import 'order_alert_state.dart';

final orderAlertControllerProvider = StateNotifierProvider<OrderAlertController, OrderAlertState>((ref) {
  final service = ref.watch(orderAlertServiceProvider);
  return OrderAlertController(service);
});

class OrderAlertController extends StateNotifier<OrderAlertState> {
  OrderAlertController(this._service) : super(const OrderAlertState());

  static const _prefKeyToken = 'order_alert_last_token';
  static const _prefKeyUser = 'order_alert_last_user';

  final OrderAlertService _service;
  final Logger _logger = Logger('OrderAlertController');

  SharedPreferences? _prefs;
  bool _loadingPending = false;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> enqueueAlert(InvoiceAlert alert, {bool fromNotification = false}) async {
    if (!alert.requiresAcceptance) {
      return;
    }
    await OrderAlertNativeChannel.ensureInitialised();
    final currentQueue = List<InvoiceAlert>.from(state.queue);
    final existingIndex = currentQueue.indexWhere((item) => item.invoiceId == alert.invoiceId);
    if (existingIndex >= 0) {
      currentQueue[existingIndex] = alert;
      final isActive = state.active?.invoiceId == alert.invoiceId;
      state = state.copyWith(queue: currentQueue, active: isActive ? alert : state.active, clearError: true);
      return;
    }

    currentQueue.add(alert);
    final hasActive = state.hasActive;
    final newActive = hasActive ? state.active : alert;
    final reorderedQueue = _ensureActiveFirst(currentQueue, newActive);

    state = state.copyWith(queue: reorderedQueue, active: newActive, clearError: true);

    if (!hasActive) {
      _logger.info('Starting alarm for invoice ${alert.invoiceId}');
      await OrderAlertNativeChannel.startAlarm();
      if (!fromNotification) {
        await OrderAlertNativeChannel.showNotification(_buildNotificationData(alert));
      }
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
      if (next != null) {
        _logger.info('Continuing alarm with next invoice ${next.invoiceId}');
        await OrderAlertNativeChannel.startAlarm();
      }
    } catch (error, stackTrace) {
      _logger.error('Failed to acknowledge invoice ${current.invoiceId}', error, stackTrace);
      state = state.copyWith(isAcknowledging: false, error: error.toString());
    }
  }

  Future<void> syncPendingAlerts() async {
    if (_loadingPending) {
      return;
    }
    _loadingPending = true;
    try {
    final alerts = await _service.getPendingAlerts();
    final now = DateTime.now();
      if (alerts.isEmpty) {
        if (state.hasActive) {
          await OrderAlertNativeChannel.stopAlarm();
        }
        state = state.copyWith(queue: const [], active: null, lastSynced: now, clearError: true, isAcknowledging: false);
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
      state = state.copyWith(queue: reordered, active: newActive, lastSynced: now, clearError: true, isAcknowledging: false);

      if (existingActiveId != null && (newActive == null || newActive.invoiceId != existingActiveId)) {
        await OrderAlertNativeChannel.stopAlarm();
      }
      if (newActive != null) {
        _logger.info('Sync ensures alarm for invoice ${newActive.invoiceId}');
        await OrderAlertNativeChannel.startAlarm();
      }
    } catch (error, stackTrace) {
      _logger.error('Failed to sync pending alerts', error, stackTrace);
      state = state.copyWith(error: error.toString(), lastSynced: DateTime.now());
    } finally {
      _loadingPending = false;
    }
  }

  Future<void> handleInvoiceAccepted(String invoiceId) async {
    final wasActive = state.active?.invoiceId == invoiceId;
    final removed = _removeInvoice(invoiceId);
    if (!removed) {
      return;
    }

    if (wasActive) {
      await OrderAlertNativeChannel.stopAlarm();
      await OrderAlertNativeChannel.cancelNotification(invoiceId);
      final next = state.active;
      if (next != null) {
        _logger.info('Switching alarm to invoice ${next.invoiceId}');
        await OrderAlertNativeChannel.startAlarm();
      }
    } else {
      await OrderAlertNativeChannel.cancelNotification(invoiceId);
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
    state = state.copyWith(queue: currentQueue, active: nextActive, isAcknowledging: false, clearError: true);
    return true;
  }

  List<InvoiceAlert> _ensureActiveFirst(List<InvoiceAlert> queue, InvoiceAlert? active) {
    if (queue.isEmpty || active == null) {
      return List<InvoiceAlert>.from(queue);
    }
    final reordered = List<InvoiceAlert>.from(queue);
    final index = reordered.indexWhere((alert) => alert.invoiceId == active.invoiceId);
    if (index > 0) {
      final entry = reordered.removeAt(index);
      reordered.insert(0, entry);
    } else if (index == -1) {
      reordered.insert(0, active);
    }
    return reordered;
  }
}
