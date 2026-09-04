import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/constants/storage_keys.dart';
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
  OrderAlertController(this._service, this._posRepository)
      : super(const OrderAlertState()) {
    _muteRestored = _restoreMuteState();
  }

  static const _prefKeyToken = PrefKeys.orderAlertLastToken;
  static const _prefKeyUser = PrefKeys.orderAlertLastUser;
  static const _prefKeyProfiles = PrefKeys.orderAlertLastProfiles;
  static const _prefKeyGlobalMute = PrefKeys.orderAlertGlobalMute;
  static const _prefKeyMutedInvoices = PrefKeys.orderAlertMutedInvoices;

  /// How long a POS-profile timetable answer is reused.
  ///
  /// This probe is an HTTP round trip and used to run on every poll tick (every
  /// 2–10s per device). Beyond the traffic, the await was the window in which a
  /// mute could be overtaken by an alarm start that had already passed its
  /// checks — caching all but closes it.
  static const _profileOpenTtl = Duration(minutes: 2);

  final OrderAlertService _service;
  final PosRepository _posRepository;
  final Logger _logger = Logger('OrderAlertController');

  SharedPreferences? _prefs;
  bool _loadingPending = false;

  /// How many `syncPendingAlerts` runs in a row have failed, reset by the
  /// first server answer.
  ///
  /// Two jobs. It keeps a permanent failure - a dead session used to be the
  /// worst one - from being reported once every 10s forever, and the alert
  /// poller reads it to widen its interval instead of hammering a server that
  /// is plainly not answering.
  int _consecutiveSyncFailures = 0;

  int get consecutiveSyncFailures => _consecutiveSyncFailures;
  late final Future<void> _muteRestored;

  /// Bumped on every change to the mute state. An alarm start that began before
  /// the bump is abandoned, so "mute" can never lose a race to a start decision
  /// that was made microseconds earlier.
  int _muteGeneration = 0;

  final Map<String, _ProfileOpenResult> _profileOpenCache = {};

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _restoreMuteState() async {
    try {
      final prefs = await _preferences();
      final globalMute = prefs.getBool(_prefKeyGlobalMute) ?? false;
      final muted =
          (prefs.getStringList(_prefKeyMutedInvoices) ?? const <String>[]).toSet();
      if (!mounted) return;
      if (globalMute || muted.isNotEmpty) {
        _logger.info(
          'Restored mute state: globalMute=$globalMute muted=${muted.length}',
        );
      }
      state = state.copyWith(globalMute: globalMute, mutedInvoiceIds: muted);
      await _pushMuteStateToNative();
    } catch (error, stackTrace) {
      _logger.error('Failed to restore mute state', error, stackTrace);
    }
  }

  /// Mirrors the mute state into the native layer.
  ///
  /// The Android FCM service starts the alarm from a background isolate with no
  /// Dart state to consult, so the native side has to own the final say —
  /// otherwise every push re-armed an alarm the user had already silenced.
  Future<void> _pushMuteStateToNative() async {
    await OrderAlertNativeChannel.setMuteState(
      globalMute: state.globalMute,
      mutedInvoiceIds: state.mutedInvoiceIds.toList(),
    );
  }

  Future<void> _updateMuteState({
    Set<String>? mutedInvoiceIds,
    bool? globalMute,
  }) async {
    if (!mounted) return;

    // Only a *new* silence has to abort in-flight alarm starts. Bumping on
    // removals too (the pruning pass runs on every sync) would cancel healthy
    // keep-alive starts for no reason.
    final gainedSilence = (globalMute == true && !state.globalMute) ||
        (mutedInvoiceIds != null &&
            mutedInvoiceIds.difference(state.mutedInvoiceIds).isNotEmpty);
    if (gainedSilence) {
      _muteGeneration++;
    }

    state = state.copyWith(
      mutedInvoiceIds: mutedInvoiceIds,
      globalMute: globalMute,
      clearError: true,
    );

    try {
      final prefs = await _preferences();
      await prefs.setBool(_prefKeyGlobalMute, state.globalMute);
      await prefs.setStringList(
        _prefKeyMutedInvoices,
        state.mutedInvoiceIds.toList(),
      );
    } catch (error, stackTrace) {
      _logger.error('Failed to persist mute state', error, stackTrace);
    }

    await _pushMuteStateToNative();
  }

  /// The single place that is allowed to start the alarm.
  ///
  /// Every check is repeated after every await: the timetable probe and the
  /// method-channel hop both yield, and a mute that lands inside either of those
  /// windows must still win.
  Future<void> _startAlarmIfAllowed(
    InvoiceAlert alert, {
    required String reason,
  }) async {
    final generation = _muteGeneration;

    if (state.isInvoiceMuted(alert.invoiceId)) {
      _logger.info(
        'Not starting alarm for ${alert.invoiceId} ($reason): muted '
        '(global=${state.globalMute})',
      );
      return;
    }

    if (!await _shouldTriggerAlarm(alert.posProfile)) {
      _logger.info(
        'Not starting alarm for ${alert.invoiceId} ($reason): POS profile closed',
      );
      return;
    }

    if (_muteGeneration != generation || state.isInvoiceMuted(alert.invoiceId)) {
      _logger.info(
        'Abandoning alarm start for ${alert.invoiceId} ($reason): '
        'muted while checking the timetable',
      );
      return;
    }

    _logger.info('Starting alarm for ${alert.invoiceId} ($reason)');
    await OrderAlertNativeChannel.startAlarm(invoiceId: alert.invoiceId);

    if (_muteGeneration != generation || state.isInvoiceMuted(alert.invoiceId)) {
      _logger.info(
        'Muted while the alarm was starting for ${alert.invoiceId} — stopping again',
      );
      await OrderAlertNativeChannel.stopAlarm();
    }
  }

  /// Re-evaluates the alarm for whatever is currently active.
  Future<void> _refreshAlarmForActive({required String reason}) async {
    final active = state.active;
    if (active == null) {
      return;
    }
    await _startAlarmIfAllowed(active, reason: reason);
  }

  Future<void> enqueueAlert(
    InvoiceAlert alert, {
    bool fromNotification = false,
    bool triggerNativeEffects = true,
  }) async {
    await _muteRestored;

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

    // Skip cancelled invoices (kanban column or ERPNext status)
    final invoiceState = alert.salesInvoiceState?.toLowerCase() ?? '';
    if (invoiceState == 'cancelled') {
      _logger.warning(
        "Alert for ${alert.invoiceId} is Cancelled (state: ${alert.salesInvoiceState}). Skipping enqueue."
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

    // A silenced alert must not keep the active slot: mute means "this order is
    // handled", not "stop telling me about new orders". Handing the slot to the
    // newcomer is what lets the next order actually ring.
    final currentActive = state.active;
    final activeIsSilenced =
        currentActive != null && state.isInvoiceMuted(currentActive.invoiceId);
    final newActive =
        (currentActive == null || activeIsSilenced) ? alert : currentActive;
    final promoted = newActive.invoiceId == alert.invoiceId;
    final reorderedQueue = _ensureActiveFirst(currentQueue, newActive);

    _logger.info(
      "Setting state: queueLen=${reorderedQueue.length} "
      "activeInvoice=${newActive.invoiceId} "
      "promoted=$promoted "
      "isMuted=${state.isMuted}"
    );

    state = state.copyWith(
      queue: reorderedQueue,
      active: newActive,
      clearError: true,
    );

    if (!triggerNativeEffects) {
      return;
    }

    if (promoted) {
      await _startAlarmIfAllowed(alert, reason: 'new alert');
    } else {
      _logger.info(
        'NOT starting alarm for ${alert.invoiceId}: '
        '${currentActive?.invoiceId} is already ringing',
      );
    }

    if (fromNotification || promoted) {
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
      await _forgetMute(current.invoiceId);
      _removeInvoice(current.invoiceId);

      // Force sync to check if there are any remaining alerts on server
      // This ensures we don't keep ringing if all alerts were accepted
      _logger.info('Forcing sync after acknowledging ${current.invoiceId}');
      await syncPendingAlerts();

      // Check if we still have alerts after sync
      if (!state.hasActive) {
        _logger.info('No more active alerts after sync - ensuring alarm is stopped');
        await OrderAlertNativeChannel.stopAlarm();
        state = state.copyWith(isAcknowledging: false, clearError: true);
        return;
      }

      state = state.copyWith(isAcknowledging: false, clearError: true);
      await _refreshAlarmForActive(reason: 'next queued alert');
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
      await _muteRestored;
      final rawAlerts = await _service.getPendingAlerts();
      // The server answered; whatever run of failures preceded this is over.
      _consecutiveSyncFailures = 0;
      // Filter out cancelled invoices client-side as a safety net
      final alerts = rawAlerts.where((a) {
        final st = a.salesInvoiceState?.toLowerCase() ?? '';
        return st != 'cancelled';
      }).toList();
      final now = DateTime.now();
      _logger.info("syncPendingAlerts fetched ${rawAlerts.length} alerts, ${alerts.length} after filtering cancelled");

      if (alerts.isEmpty) {
        _logger.info("No pending alerts from server, clearing local queue and stopping alarm");
        if (state.hasActive || state.queue.isNotEmpty) {
          await OrderAlertNativeChannel.stopAlarm();
          _logger.info("Stopped alarm - no pending alerts on server");
        }
        state = state.copyWith(
          queue: const [],
          active: null,
          lastSynced: now,
          clearError: true,
          isAcknowledging: false,
        );
        // Per-invoice mutes die with their invoice; the device-wide mute is a
        // setting and survives.
        if (state.mutedInvoiceIds.isNotEmpty) {
          await _updateMuteState(mutedInvoiceIds: const <String>{});
        }
        _loadingPending = false;
        return;
      }

      // Drop mutes for invoices the server no longer considers pending, so the
      // set cannot grow forever and a recycled id cannot arrive pre-silenced.
      final pendingIds = alerts.map((alert) => alert.invoiceId).toSet();
      final prunedMutes = state.mutedInvoiceIds.intersection(pendingIds);
      if (prunedMutes.length != state.mutedInvoiceIds.length) {
        await _updateMuteState(mutedInvoiceIds: prunedMutes);
      }

      final existingActiveId = state.active?.invoiceId;
      final existingActive = existingActiveId == null
          ? null
          : alerts.firstWhereOrNull(
              (alert) => alert.invoiceId == existingActiveId,
            );
      final candidateActive = (existingActive != null &&
              !state.isInvoiceMuted(existingActive.invoiceId))
          ? existingActive
          // Prefer something the user has NOT silenced, so a muted order at the
          // head of the queue cannot swallow the alarm for everything behind it.
          : (alerts.firstWhereOrNull(
                  (alert) => !state.isInvoiceMuted(alert.invoiceId),
                ) ??
              existingActive ??
              alerts.first);
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

      if (newActive != null) {
        await _startAlarmIfAllowed(newActive, reason: 'sync');
      }
    } catch (error, stackTrace) {
      // This runs on a poll loop, so an offline device would otherwise report
      // the same "Failed host lookup" thousands of times per session and bury
      // real issues. Expected connectivity failures are logged and retried on
      // the next tick; anything else is still reported.
      _consecutiveSyncFailures++;
      if (_isExpectedOfflineFailure(error)) {
        _logger.debug('Skipping alert sync while offline: $error');
      } else if (_consecutiveSyncFailures == 1) {
        _logger.error('Failed to sync pending alerts', error, stackTrace);
      } else {
        // Same fault, still there, on a 10s loop. The first one is already in
        // Sentry with the same stack; repeating it only buys 360 events an
        // hour. Deliberately done here and not by widening
        // AppErrorReporter's global dedup window, which would also hide
        // genuinely distinct repeating faults everywhere else in the app.
        _logger.debug(
          'Alert sync still failing (attempt $_consecutiveSyncFailures), '
          'already reported: $error',
        );
      }
      state = state.copyWith(
        error: error.toString(),
        lastSynced: DateTime.now(),
      );
    } finally {
      _loadingPending = false;
    }
  }

  /// True when [error] means "the device could not reach the server", which is
  /// a normal condition for a mobile POS rather than a bug worth reporting.
  bool _isExpectedOfflineFailure(Object error) {
    if (error is DioException) {
      // A real server response (any 4xx/5xx) is still worth reporting.
      if (error.type == DioExceptionType.badResponse) {
        return false;
      }
      const transportFailures = <DioExceptionType>{
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (transportFailures.contains(error.type)) {
        return true;
      }
    }

    final text = error.toString().toLowerCase();
    return text.contains('failed host lookup') ||
        text.contains('socketexception') ||
        text.contains('xmlhttprequest error') ||
        text.contains('cannot reach server');
  }

  Future<void> handleInvoiceAccepted(String invoiceId) async {
    _logger.info("handleInvoiceAccepted invoice=$invoiceId - stopping alarm and removing from queue");

    // ALWAYS stop the alarm when we receive an acceptance notification
    // This ensures that if another device accepted, this device stops ringing
    await OrderAlertNativeChannel.stopAlarm();
    await OrderAlertNativeChannel.cancelNotification(invoiceId);
    await _forgetMute(invoiceId);

    final wasActive = state.active?.invoiceId == invoiceId;
    final removed = _removeInvoice(invoiceId);
    _logger.info("handleInvoiceAccepted invoice=$invoiceId removed=$removed wasActive=$wasActive hasActive=${state.hasActive}");

    if (!removed) {
      // Even if we don't have this invoice locally, ensure alarm is stopped
      _logger.info("Invoice $invoiceId not in local queue but stopping alarm anyway");
      return;
    }

    // If there are no more active alerts, ensure alarm is completely stopped
    if (!state.hasActive) {
      _logger.info('No more pending invoices after accepting $invoiceId - stopping alarm completely');
      await OrderAlertNativeChannel.stopAlarm();
      return;
    }

    if (wasActive) {
      await _refreshAlarmForActive(reason: 'previous alert accepted');
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<bool> shouldRegisterToken(String token, String user, List<String> posProfiles) async {
    final prefs = await _preferences();
    final lastToken = prefs.getString(_prefKeyToken);
    final lastUser = prefs.getString(_prefKeyUser);
    final lastProfiles = prefs.getStringList(_prefKeyProfiles) ?? const <String>[];

    final normalizedProfiles = [...posProfiles]..sort();
    final normalizedLast = [...lastProfiles]..sort();

    final listEquals = const ListEquality<String>().equals;

    return lastToken != token ||
        lastUser != user ||
        !listEquals(normalizedProfiles, normalizedLast);
  }

  Future<void> markTokenRegistered(String token, String user, List<String> posProfiles) async {
    final prefs = await _preferences();
    await prefs.setString(_prefKeyToken, token);
    await prefs.setString(_prefKeyUser, user);
    await prefs.setStringList(_prefKeyProfiles, List.unmodifiable(posProfiles));
  }

  Future<void> resetTokenCache() async {
    final prefs = await _preferences();
    await prefs.remove(_prefKeyToken);
    await prefs.remove(_prefKeyUser);
    await prefs.remove(_prefKeyProfiles);
  }

  Future<bool> getGlobalMuteState() async {
    final prefs = await _preferences();
    return prefs.getBool(_prefKeyGlobalMute) ?? false;
  }

  Future<void> setGlobalMuteState(bool muted) async {
    _logger.info('Global notification mute state set to: $muted');
    await _updateMuteState(globalMute: muted);

    if (muted) {
      await OrderAlertNativeChannel.stopAlarm();
    } else {
      // Resuming is an explicit user action: re-probe the timetable rather than
      // resuming on a cached answer that may be minutes old.
      _profileOpenCache.clear();
      await _refreshAlarmForActive(reason: 'global unmute');
    }
  }

  Future<void> clearAll() async {
    await OrderAlertNativeChannel.stopAlarm();
    // Keep the device-wide setting; only the per-invoice mutes belong to the
    // session that just ended.
    final globalMute = state.globalMute;
    state = OrderAlertState(globalMute: globalMute);
    await _updateMuteState(mutedInvoiceIds: const <String>{});
    _profileOpenCache.clear();
  }

  Future<void> muteActiveAlert() async {
    final active = state.active;
    if (active == null || state.isMuted) {
      return;
    }
    _logger.info('Muting alarm for invoice ${active.invoiceId}');
    // Record the mute BEFORE stopping: this bumps the generation and tells the
    // native layer, so an alarm start already in flight (poll tick, FCM push)
    // is refused instead of restarting what the user just silenced.
    await _updateMuteState(
      mutedInvoiceIds: {...state.mutedInvoiceIds, active.invoiceId},
    );
    await OrderAlertNativeChannel.stopAlarm();
  }

  Future<void> unmuteAlerts() async {
    if (!state.isMuted) {
      return;
    }
    _logger.info('Unmuting alarm');
    final active = state.active;
    final remaining = {...state.mutedInvoiceIds};
    if (active != null) {
      remaining.remove(active.invoiceId);
    }
    // The button on a ringing alert reads "Unmute", so it has to undo the
    // device-wide mute too — otherwise it claims to restore sound and doesn't.
    await _updateMuteState(mutedInvoiceIds: remaining, globalMute: false);
    _profileOpenCache.clear();
    await _refreshAlarmForActive(reason: 'unmute');
  }

  Future<void> _forgetMute(String invoiceId) async {
    if (!state.mutedInvoiceIds.contains(invoiceId)) {
      return;
    }
    final remaining = {...state.mutedInvoiceIds}..remove(invoiceId);
    await _updateMuteState(mutedInvoiceIds: remaining);
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
    final cached = _profileOpenCache[posProfile];
    if (cached != null && !cached.isStale(_profileOpenTtl)) {
      return cached.isOpen;
    }

    try {
      final result = await _posRepository.isPosProfileOpen(posProfile);
      final isOpen = result['is_open'] as bool? ?? true;

      if (!isOpen) {
        _logger.info(
          'POS Profile $posProfile is closed: ${result['message']}. '
          'Alarm will not be triggered.'
        );
      }

      _profileOpenCache[posProfile] =
          _ProfileOpenResult(isOpen: isOpen, checkedAt: DateTime.now());
      return isOpen;
    } catch (e) {
      _logger.error('Error checking POS profile timetable: $e. Defaulting to trigger alarm.');
      // If there's an error checking the timetable, default to triggering the alarm
      // to avoid missing important alerts. Deliberately not cached — a transient
      // failure must not pin the answer for the next two minutes.
      return true;
    }
  }
}

class _ProfileOpenResult {
  const _ProfileOpenResult({required this.isOpen, required this.checkedAt});

  final bool isOpen;
  final DateTime checkedAt;

  bool isStale(Duration ttl) => DateTime.now().difference(checkedAt) > ttl;
}
