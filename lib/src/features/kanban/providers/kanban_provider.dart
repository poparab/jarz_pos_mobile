import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/kanban_models.dart';
import '../services/kanban_service.dart';
import '../services/notification_polling_service.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../core/offline/offline_queue.dart';
import '../../../core/connectivity/connectivity_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

// Provider for KanbanService
final kanbanServiceProvider = Provider<KanbanService>((ref) {
  final dio = ref.watch(dioProvider); // use shared Dio with cookies
  return KanbanService(dio);
});

// State class for Kanban data
class KanbanState {
  final List<KanbanColumn> columns;
  final Map<String, List<InvoiceCard>> invoices;
  final bool isLoading;
  final String? error;
  final KanbanFilters filters;
  final List<CustomerOption> customers;
  final Set<String> transitioningInvoices; // Phase 7

  KanbanState({
    this.columns = const [],
    this.invoices = const {},
    this.isLoading = false,
    this.error,
    this.filters = const KanbanFilters(),
    this.customers = const [],
    this.transitioningInvoices = const {},
  });

  KanbanState copyWith({
    List<KanbanColumn>? columns,
    Map<String, List<InvoiceCard>>? invoices,
    bool? isLoading,
    String? error,
    KanbanFilters? filters,
    List<CustomerOption>? customers,
    Set<String>? transitioningInvoices,
  }) {
    return KanbanState(
      columns: columns ?? this.columns,
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      customers: customers ?? this.customers,
      transitioningInvoices: transitioningInvoices ?? this.transitioningInvoices,
    );
  }
}

// Kanban state notifier
class KanbanNotifier extends StateNotifier<KanbanState> {
  final KanbanService _kanbanService;
  WebSocketService? _wsService;
  StreamSubscription<Map<String, dynamic>>? _kanbanSub;
  StreamSubscription<Map<String, dynamic>>? _pollingSub;
  final Ref _ref; // store ref for offline queue & connectivity

  KanbanNotifier(this._kanbanService, Ref ref) : _ref = ref, super(KanbanState()) {
    _wsService = ref.read(webSocketServiceProvider);
    _initializeKanban();
    _attachRealtime();
    _attachNotificationPolling();
    _listenConnectivity();
  }

  Future<void> _initializeKanban() async {
    await loadColumns();
    await loadInvoices();
    await loadFilters();
  }

  Future<void> loadKanbanData() async {
    await _initializeKanban();
  }

  void _attachRealtime() {
    try {
      // Listen for kanban state change updates
      _kanbanSub = _wsService?.kanbanUpdates.listen((event) {
        final invoiceId = event['invoice'] as String? ?? event['invoice_id'] as String?;
        // If it's a new invoice broadcast (no old state), just refresh invoices
        if ((event['old_state_key'] == null || (event['old_state_key'] as String?)?.isEmpty == true) &&
            event['new_state_key'] != null) {
          // New cards created from other devices/sources
          loadInvoices();
          return;
        }
        if (event['event'] == 'jarz_pos_out_for_delivery_transition' || event.containsKey('courier_transaction')) {
          if (invoiceId != null) {
            _patchInvoiceOutForDelivery(invoiceId, event);
          }
          return; // skip generic move handler
        }
        final oldKey = event['old_state_key'] as String?;
        final newKey = event['new_state_key'] as String?;
        if (invoiceId != null && newKey != null) {
            _applyRealtimeMove(invoiceId, oldKey, newKey);
        }
      });
  // Also listen for new POS invoices and refresh the Received column
      _wsService?.invoiceStream.listen((inv) async {
        // Basic guard: ensure Kanban is initialized
        if (state.columns.isEmpty) return;
        // Simple strategy: reload invoices to pick up the new card
        await loadInvoices();
      });
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint('Kanban realtime attach failed: $e');
        }
      }
    }
  }

  void _attachNotificationPolling() {
    try {
      // Start the notification polling service
      final pollingService = _ref.read(notificationPollingServiceProvider);
      pollingService.startPolling(intervalSeconds: 30);
      
      // Listen for polling notifications
      _pollingSub = pollingService.notificationStream.listen((event) {
        if (kDebugMode) {
          if (kDebugMode) {
            debugPrint('📊 KANBAN: Received polling notification: ${event['type']}');
          }
        }
        
        final eventType = event['type'] as String?;
        switch (eventType) {
          case 'new_invoice':
            final invoiceData = event['data'] as Map<String, dynamic>?;
            if (invoiceData != null) {
              if (kDebugMode) {
                if (kDebugMode) {
                  debugPrint('📊 KANBAN: New invoice from polling: ${invoiceData['name']}');
                }
              }
              // Refresh invoices to show the new one
              loadInvoices();
            }
            break;
          case 'invoice_updated':
            final invoiceData = event['data'] as Map<String, dynamic>?;
            if (invoiceData != null) {
              if (kDebugMode) {
                if (kDebugMode) {
                  debugPrint('📊 KANBAN: Updated invoice from polling: ${invoiceData['name']}');
                }
              }
              // Refresh invoices to show updates
              loadInvoices();
            }
            break;
          case 'updates_available':
            final totalUpdates = event['total_updates'] as int?;
            if (totalUpdates != null && totalUpdates > 0) {
              if (kDebugMode) {
                if (kDebugMode) {
                  debugPrint('📊 KANBAN: $totalUpdates updates available from polling');
                }
              }
              // Refresh invoices to show all updates
              loadInvoices();
            }
            break;
        }
      });
      
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint('📊 KANBAN: Notification polling service attached');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint('❌ KANBAN: Failed to attach notification polling: $e');
        }
      }
    }
  }

  void _patchInvoiceOutForDelivery(String invoiceId, Map<String, dynamic> payload) {
    final current = Map<String, List<InvoiceCard>>.from(state.invoices);
  InvoiceCard? card; // find source column and remove from there
    for (final e in current.entries) {
      final idx = e.value.indexWhere((c) => c.id == invoiceId);
      if (idx >= 0) { card = e.value[idx]; break; }
    }
    if (card == null) return;
    final outKey = _stateKey('Out For Delivery');
    final shippingAmt = (payload['shipping_amount'] ?? card.shippingExpense);
    final updated = card.copyWith(
      status: 'Out For Delivery',
      docStatus: 'Paid',
      shippingExpense: (shippingAmt is num ? shippingAmt.toDouble() : card.shippingExpense),
      courier: payload['display_name'] ?? payload['courier'] ?? card.courier,
      settlementMode: payload['mode'] ?? payload['settlement'] ?? card.settlementMode,
    );
    // Remove from whichever column contains it
    for (final key in current.keys) {
      final list = List<InvoiceCard>.from(current[key] ?? []);
  final before = list.length;
  list.removeWhere((c) => c.id == invoiceId);
  if (list.length != before) {
        current[key] = list;
        break;
      }
    }
    final dest = List<InvoiceCard>.from(current[outKey] ?? []);
    dest.removeWhere((c) => c.id == invoiceId);
    dest.add(updated);
    current[outKey] = dest;
    final ti = Set<String>.from(state.transitioningInvoices)..remove(invoiceId);
    state = state.copyWith(invoices: current, transitioningInvoices: ti);
  }

  void _applyRealtimeMove(String invoiceId, String? oldStateKey, String newStateKey) {
    final current = Map<String, List<InvoiceCard>>.from(state.invoices);
    InvoiceCard? card;
    // oldStateKey/newStateKey are keys (already normalized) from backend payload
    if (oldStateKey != null && current.containsKey(oldStateKey)) {
      final list = List<InvoiceCard>.from(current[oldStateKey]!);
      final idx = list.indexWhere((c) => c.id == invoiceId);
      if (idx >= 0) { card = list.removeAt(idx); current[oldStateKey] = list; }
    } else {
      for (final entry in current.entries) {
        final idx = entry.value.indexWhere((c) => c.id == invoiceId);
        if (idx >= 0) { final list = List<InvoiceCard>.from(entry.value); card = list.removeAt(idx); current[entry.key] = list; break; }
      }
    }
    if (card != null) {
      final displayName = state.columns.firstWhere(
        (c) => c.id == newStateKey,
        orElse: () => KanbanColumn(id: newStateKey, name: newStateKey.replaceAll('_', ' '), color: '#F5F5F5'),
      ).name;
      final updatedCard = card.copyWith(status: displayName);
      final dest = List<InvoiceCard>.from(current[newStateKey] ?? []);
      dest.removeWhere((c) => c.id == invoiceId);
      dest.add(updatedCard);
      current[newStateKey] = dest;
      state = state.copyWith(invoices: current);
    }
  }

  // Removed unused _getStateDisplayName helper (was only used for display mapping; realtime path now resolves directly)

  Future<void> loadColumns() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final columns = await _kanbanService.getKanbanColumns();
      state = state.copyWith(columns: columns, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load columns: $e',
      );
    }
  }

  Future<void> loadInvoices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final filterMap = state.filters.hasFilters ? state.filters.toJson() : null;
      final invoices = await _kanbanService.getKanbanInvoices(filters: filterMap);

      // Sort the "Received" column by posting date (newest first)
      final receivedKey = _stateKey('Received');
      final sorted = Map<String, List<InvoiceCard>>.from(invoices);
      if (sorted.containsKey(receivedKey)) {
        final list = List<InvoiceCard>.from(sorted[receivedKey] ?? const []);
        DateTime parseDate(String s) => DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
        list.sort((a, b) => parseDate(b.postingDate).compareTo(parseDate(a.postingDate)));
        sorted[receivedKey] = list;
      }

      state = state.copyWith(invoices: sorted, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load invoices: $e',
      );
    }
  }

  Future<void> loadFilters() async {
    try {
      final filtersData = await _kanbanService.getKanbanFilters();
      // Convert FilterOptions to CustomerOptions
      final customers = filtersData.customers
          .map((option) => CustomerOption(
                customer: option.value,
                customerName: option.label,
              ))
          .toList();
      state = state.copyWith(customers: customers);
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint('Failed to load filters: $e');
        }
      }
      // Set empty list on error
      state = state.copyWith(customers: <CustomerOption>[]);
    }
  }

  Future<void> updateInvoiceState(String invoiceId, String newState) async {
    // Resolve to canonical state LABEL from either label or id/key
    String canonical;
    final cols = state.columns;
    // 1) Match by label (case-insensitive)
    final byLabel = cols.cast<KanbanColumn?>().firstWhere(
      (c) => c != null && c.name.toLowerCase() == newState.toLowerCase(),
      orElse: () => null,
    );
    if (byLabel != null) {
      canonical = byLabel.name;
    } else {
      // 2) Match by id/key (received like 'out_for_delivery')
      final key = _stateKey(newState);
      final byId = cols.cast<KanbanColumn?>().firstWhere(
        (c) => c != null && c.id.toLowerCase() == key,
        orElse: () => null,
      );
      canonical = byId?.name ?? newState;
    }

    // Guard: prevent direct drag into OFD without unified flow (we expect drag handler to intercept)
    if (canonical.toLowerCase() == 'out for delivery') {
      final all = state.invoices.values.expand((e) => e).toList();
      final card = all.firstWhere((c) => c.id == invoiceId, orElse: () => InvoiceCard.fromJson({'name': invoiceId}));
      final isPaid = (card.docStatus ?? '').toLowerCase() == 'paid' || (card.effectiveStatus.toLowerCase() == 'paid');
      if (!isPaid) {
        state = state.copyWith(error: 'Invoice must be paid before Out for Delivery');
        return;
      }
      // If paid, we still prefer the unified OFD function (adds courier + Journal Entry).
      // So block here to avoid state-only move.
      state = state.copyWith(error: 'Use Out For Delivery flow (courier required)');
      return;
    }

    final prevState = state;
    try {
      _optimisticMove(invoiceId, canonical);
      final success = await _kanbanService.updateInvoiceState(invoiceId, canonical);
      if (!success) {
        state = prevState.copyWith(error: 'Update failed (no success flag)');
      } else {
        // Safety: ensure card present in target column (in case optimistic move failed)
        final targetKey = _stateKey(canonical);
        final placed = state.invoices[targetKey]?.any((c) => c.id == invoiceId) ?? false;
        if (!placed) {
          _optimisticMove(invoiceId, canonical); // force-place
        }
        // Force reload from backend to reconcile with authoritative data (dual-field write)
        await loadInvoices();
        // Fallback: if target column absent (edge case), insert column key and force-place card
        if (!state.invoices.containsKey(targetKey)) {
          final refreshed = Map<String, List<InvoiceCard>>.from(state.invoices);
            refreshed[targetKey] = [];
          state = state.copyWith(invoices: refreshed);
          _optimisticMove(invoiceId, canonical);
        }
      }
    } catch (e) {
      state = prevState.copyWith(error: 'Error updating invoice: $e');
    }
  }

  void _optimisticMove(String invoiceId, String targetStateDisplay) {
    final targetKey = _stateKey(targetStateDisplay);
  final current = Map<String, List<InvoiceCard>>.from(state.invoices);
  InvoiceCard? card;
    for (final entry in current.entries) {
      final idx = entry.value.indexWhere((c) => c.id == invoiceId);
      if (idx >= 0) { final list = List<InvoiceCard>.from(entry.value); card = list.removeAt(idx); current[entry.key] = list; break; }
    }
    if (card == null) return;
    final updated = card.copyWith(status: targetStateDisplay);
    final dest = List<InvoiceCard>.from(current[targetKey] ?? []);
    dest.removeWhere((c) => c.id == invoiceId);
    dest.add(updated);
    current[targetKey] = dest;
    state = state.copyWith(invoices: current);
  }

  void updateFilters(KanbanFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    loadInvoices(); // Reload with new filters
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _stateKey(String label) => label.toLowerCase().replaceAll(' ', '_');

  @override
  void dispose() {
    _kanbanSub?.cancel();
    _pollingSub?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> payInvoice({
    required String invoiceId,
    required String paymentMode,
    String? posProfile,
  }) async {
    try {
      final result = await _kanbanService.payInvoice(
        invoiceName: invoiceId,
        paymentMode: paymentMode,
        posProfile: posProfile,
      );
      // Refresh invoice details & list after payment
      await loadInvoices();
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Payment failed: $e');
      return null;
    }
  }
  
    Future<Map<String, dynamic>?> settleSingleInvoicePaid({
      required String invoiceId,
      required String posProfile,
      required String partyType,
      required String party,
    }) async {
      try {
        final res = await _kanbanService.settleSingleInvoicePaid(
          invoiceName: invoiceId,
          posProfile: posProfile,
          partyType: partyType,
          party: party,
        );
        return res;
      } catch (e) {
        return null;
      }
    }

    Future<Map<String, dynamic>?> settleCourierCollectedPayment({
      required String invoiceId,
      required String posProfile,
      required String partyType,
      required String party,
    }) async {
      try {
        final res = await _kanbanService.settleCourierCollectedPayment(
          invoiceName: invoiceId,
          posProfile: posProfile,
          partyType: partyType,
          party: party,
        );
        return res;
      } catch (e) {
        return null;
      }
    }

  Future<Map<String, dynamic>?> outForDeliveryPaid({
    required String invoiceId,
    required String courier,
    required String settlement,
    required String posProfile,
    String? partyType,
    String? party,
  }) async {
    // Legacy shim -> unified function
    return outForDeliveryUnified(
      invoiceId: invoiceId,
      courier: courier,
      mode: settlement == 'cash_now' ? 'pay_now' : 'settle_later',
      posProfile: posProfile,
      partyType: partyType,
      party: party,
    );
  }

  /// For UNPAID invoices when staff selects "settle now":
  /// - Creates Payment Entry moving receivable to Courier Outstanding
  /// - Creates Courier Transaction with amount = invoice outstanding, shipping_amount = city expense
  /// - Sets state to Out For Delivery via backend and emits realtime event consumed by _patchInvoiceOutForDelivery
  Future<Map<String, dynamic>?> markCourierOutstanding({
    required String invoiceId,
    required String courier,
  String? partyType,
  String? party,
  String? courierDisplay,
  }) async {
    final prevState = state;
    // Clear any stale error that might render a full-screen panel
    state = state.copyWith(error: null);
    final ti = Set<String>.from(state.transitioningInvoices)..add(invoiceId);
    state = state.copyWith(transitioningInvoices: ti);
    try {
      final res = await _kanbanService.markCourierOutstanding(
        invoiceName: invoiceId,
        courier: courier,
  partyType: partyType,
  party: party,
      );
      // Preserve friendly courier label if backend doesn't include it
      if (courierDisplay != null) {
        res.putIfAbsent('display_name', () => courierDisplay);
      }
      // Move card immediately to Out For Delivery (optimistic), then reconcile.
      // Prefer backend-provided payload for accurate fields (shipping_amount/mode/courier).
      try {
        _patchInvoiceOutForDelivery(invoiceId, res);
      } catch (_) {
  _optimisticOutForDelivery(invoiceId, courier: courierDisplay ?? courier, mode: 'settle_later');
      }
      // Backend also publishes realtime; still reload to reconcile authoritative data.
      await loadInvoices();
      final ti2 = Set<String>.from(state.transitioningInvoices)..remove(invoiceId);
      state = state.copyWith(transitioningInvoices: ti2);
      return res;
    } catch (e) {
      // Keep board visible but surface the error for UX; don't revert the optimistic move here
      state = prevState.copyWith(
        error: 'Mark courier outstanding failed: $e',
        transitioningInvoices: Set<String>.from(prevState.transitioningInvoices)..remove(invoiceId),
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> outForDeliveryUnified({
    required String invoiceId,
    required String courier,
    required String mode, // pay_now | settle_later
    required String posProfile,
  String? partyType,
  String? party,
  String? courierDisplay,
  }) async {
    final token = const Uuid().v4();
    final prevState = state;
    final ti = Set<String>.from(state.transitioningInvoices)..add(invoiceId);
    state = state.copyWith(transitioningInvoices: ti);
  _optimisticOutForDelivery(invoiceId, courier: courierDisplay ?? courier, mode: mode);

    final connectivity = _ref.read(connectivityServiceProvider);
    final offlineQueue = _ref.read(offlineQueueProvider);

    if (!connectivity.isOnline) {
      await offlineQueue.addTransaction({
        'endpoint': 'ofd_transition',
        'method': 'POST',
        'data': {
          'invoice_id': invoiceId,
          'courier': courier,
          'mode': mode,
          'pos_profile': posProfile,
          'idempotency_token': token,
          if (partyType != null) 'party_type': partyType,
          if (party != null) 'party': party,
        },
      });
      final ti2 = Set<String>.from(state.transitioningInvoices)..remove(invoiceId);
      state = state.copyWith(transitioningInvoices: ti2);
      return {
        'success': true,
        'offline_queued': true,
        'invoice': invoiceId,
        'courier': courier,
        'mode': mode,
        'idempotency_token': token,
  if (partyType != null) 'party_type': partyType,
  if (party != null) 'party': party,
      };
    }

    try {
      final res = await _kanbanService.handleOutForDeliveryTransition(
        invoiceName: invoiceId,
        courier: courier,
        mode: mode,
        posProfile: posProfile,
        idempotencyToken: token,
  partyType: partyType,
  party: party,
      );
      // Preserve friendly courier label if backend doesn't include it
      if (courierDisplay != null) {
        res.putIfAbsent('display_name', () => courierDisplay);
      }
      _patchInvoiceOutForDelivery(invoiceId, res);
      // Fallback reconcile: ensure card ended up in OFD column; otherwise force reload
      final ofdKey = _stateKey('Out For Delivery');
      final placed = state.invoices[ofdKey]?.any((c) => c.id == invoiceId) ?? false;
      if (!placed) {
        await loadInvoices();
      }
      return res;
    } catch (e) {
      state = prevState.copyWith(
        error: 'Out For Delivery failed: $e',
        transitioningInvoices: Set<String>.from(prevState.transitioningInvoices)..remove(invoiceId),
      );
      return null;
    }
  }

  void _optimisticOutForDelivery(String invoiceId, {String? courier, String? mode}) {
  final targetKey = _stateKey('Out For Delivery'); // keep label
    if (state.invoices[targetKey]?.any((c) => c.id == invoiceId) == true) return;
    final current = Map<String, List<InvoiceCard>>.from(state.invoices);
    InvoiceCard? card;
    for (final e in current.entries) {
      final idx = e.value.indexWhere((c) => c.id == invoiceId);
      if (idx >= 0) { final list = List<InvoiceCard>.from(e.value); card = list.removeAt(idx); current[e.key] = list; break; }
    }
    if (card == null) return;
    final updated = card.copyWith(
      status: 'Out For Delivery',
      docStatus: card.docStatus ?? 'Paid',
      courier: courier ?? card.courier,
      settlementMode: mode ?? card.settlementMode,
    );
    final dest = List<InvoiceCard>.from(current[targetKey] ?? []);
    dest.removeWhere((c) => c.id == invoiceId);
    dest.add(updated);
    current[targetKey] = dest;
    state = state.copyWith(invoices: current);
  }

  Future<List<Map<String, String>>> getCouriers() async {
    try {
      return await _kanbanService.fetchCouriers();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, String>?> createDeliveryParty({
    required String partyType,
    String? name,
    String? firstName,
    String? lastName,
    required String phone,
    String? posProfile,
  }) async {
    try {
      final res = await _kanbanService.createDeliveryParty(
        partyType: partyType,
        name: name,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        posProfile: posProfile,
      );
      return res;
    } catch (e) {
      state = state.copyWith(error: 'Create courier failed: $e');
      return null;
    }
  }

  void _listenConnectivity() {
    // Listen to connectivity status (AsyncValue<bool>) and replay queue when back online
    _ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (prev, next) {
      final online = next.value;
      if (online == true) {
        _replayOfflineQueue();
      }
    });
  }

  Future<void> _replayOfflineQueue() async {
    final queue = _ref.read(offlineQueueProvider);
    final pending = await queue.getPendingTransactions();
    if (pending.isEmpty) return;
    for (final tx in pending) {
      final data = tx['data'] as Map<String, dynamic>?;
      if (data == null) continue;
      if (tx['endpoint'] == 'ofd_transition') {
        final invoiceId = data['invoice_id'] as String;
        final courier = data['courier'] as String;
        final mode = data['mode'] as String;
        final posProfile = data['pos_profile'] as String;
        final token = data['idempotency_token'] as String;
    final partyType = data['party_type'] as String?;
    final party = data['party'] as String?;
        try {
          final res = await _kanbanService.handleOutForDeliveryTransition(
            invoiceName: invoiceId,
            courier: courier,
            mode: mode,
            posProfile: posProfile,
      idempotencyToken: token,
      partyType: partyType,
      party: party,
          );
          _patchInvoiceOutForDelivery(invoiceId, res);
          await queue.markAsProcessed(tx['id']);
        } catch (e) {
          await queue.markAsError(tx['id'], e.toString());
        }
      }
    }
  }
}

// Provider for Kanban state
final kanbanProvider = StateNotifierProvider<KanbanNotifier, KanbanState>((ref) {
  final svc = ref.watch(kanbanServiceProvider);
  return KanbanNotifier(svc, ref);
});

// Provider for specific invoice details
final invoiceDetailsProvider = FutureProvider.family<InvoiceCard?, String>((
  ref,
  invoiceId,
) async {
  final kanbanService = ref.watch(kanbanServiceProvider);
  try {
    final invoice = await kanbanService.getInvoiceDetails(invoiceId);
    return invoice;
  } catch (e) {
    return null;
  }
});
