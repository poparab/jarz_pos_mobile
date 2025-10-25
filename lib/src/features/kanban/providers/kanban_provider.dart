import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/kanban_models.dart';
import '../services/kanban_service.dart';
import '../services/notification_polling_service.dart';
import '../../../core/network/dio_provider.dart'; // shared Dio instance
import '../../../core/websocket/websocket_service.dart';
import '../../../core/offline/offline_queue.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/router.dart';
import '../../pos/state/pos_notifier.dart';
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
  final Set<String> selectedBranches; // POS profile names filter

  KanbanState({
    this.columns = const [],
    this.invoices = const {},
    this.isLoading = false,
    this.error,
    this.filters = const KanbanFilters(),
    this.customers = const [],
    this.transitioningInvoices = const {},
    this.selectedBranches = const {},
  });

  KanbanState copyWith({
    List<KanbanColumn>? columns,
    Map<String, List<InvoiceCard>>? invoices,
    bool? isLoading,
    String? error,
    KanbanFilters? filters,
    List<CustomerOption>? customers,
    Set<String>? transitioningInvoices,
    Set<String>? selectedBranches,
  }) {
    return KanbanState(
      columns: columns ?? this.columns,
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      customers: customers ?? this.customers,
      transitioningInvoices: transitioningInvoices ?? this.transitioningInvoices,
      selectedBranches: selectedBranches ?? this.selectedBranches,
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
  bool _autoBranchesInitialized = false; // ensure we don't override user choice

  KanbanNotifier(this._kanbanService, Ref ref) : _ref = ref, super(KanbanState()) {
    _wsService = ref.read(webSocketServiceProvider);
    _initializeKanban();
    _attachRealtime();
    _attachNotificationPolling();
    _listenConnectivity();
    _autoSelectAllBranchesIfNeeded();
    // React to POS profile list becoming available later (after async load)
    _ref.listen(posNotifierProvider, (prev, next) {
      // If user already made a branch selection, do nothing
      if (_autoBranchesInitialized || state.selectedBranches.isNotEmpty) return;
      // When multiple profiles exist, preselect all to reflect multi-branch view
      if ((next.profiles.length) > 1) {
        final all = next.profiles
            .map((p) => (p['name'] ?? p['title'])?.toString())
            .whereType<String>()
            .toSet();
        if (all.isNotEmpty) {
          state = state.copyWith(selectedBranches: all);
          _autoBranchesInitialized = true;
          // Reload invoices with branch filter applied
          loadInvoices();
        }
      }
    });
  }

  // Lightweight passthrough helpers (some widgets expect these names)
  Future<Map<String, List<InvoiceCard>>> fetchInvoices() async {
    return _kanbanService.getKanbanInvoices(filters: state.filters.toJson());
  }

  void _autoSelectAllBranchesIfNeeded() {
    if (_autoBranchesInitialized || state.selectedBranches.isNotEmpty) return;
    final posState = _ref.read(posNotifierProvider);
    final profiles = posState.profiles;
    if (profiles.length > 1) {
      final all = profiles
          .map((p) => (p['name'] ?? p['title'])?.toString())
          .whereType<String>()
          .toSet();
      if (all.isNotEmpty) {
        state = state.copyWith(selectedBranches: all);
        _autoBranchesInitialized = true;
      }
    }
  }

  Future<dynamic> rawPost(String path, Map<String, dynamic> data) async {
    return _kanbanService.rawPost(path, data);
  }

  Future<dynamic> callBackend(String path, {Map<String, dynamic>? data}) async {
    // Use underlying KanbanService dio instance (exposed via method) or create lightweight post
    try {
      return await _kanbanService.rawPost(path, data ?? {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshSingle(String invoiceId) async {
    try {
  final data = await fetchInvoices();
      // Find updated invoice card in result set, then patch existing state without full reload
      InvoiceCard? updated;
      for (final list in data.values) {
        final idx = list.indexWhere((c) => c.id == invoiceId || c.name == invoiceId);
        if (idx >= 0) { updated = list[idx]; break; }
      }
      if (updated == null) return; // not found; skip
      final current = Map<String, List<InvoiceCard>>.from(state.invoices);
      // Remove from any column
      for (final key in current.keys) {
        final list = List<InvoiceCard>.from(current[key] ?? []);
        final before = list.length;
        list.removeWhere((c) => c.id == invoiceId || c.name == invoiceId);
        if (before != list.length) current[key] = list;
      }
      final destKey = _stateKey(updated.status);
      final dest = List<InvoiceCard>.from(current[destKey] ?? []);
      dest.removeWhere((c) => c.id == updated!.id);
      dest.add(updated);
      current[destKey] = dest;
      state = state.copyWith(invoices: current);
    } catch (_) {}
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
        // Pre-payment collect prompt for Sales Partner unpaid flow
        try {
          final mode = (event['mode'] ?? '').toString();
          if (invoiceId != null && mode == 'sales_partner_collect_prompt') {
            final amt = (event['outstanding'] ?? event['amount'] ?? '').toString();
            _showCollectCashDialog(amount: amt, invoiceId: invoiceId);
            // don't return; allow subsequent handlers to patch board if needed
          }
        } catch (_) {}
        // Detect Sales Partner unpaid Out For Delivery fast-path realtime event
        // Backend event: jarz_pos_sales_partner_unpaid_ofd (mode == sales_partner_unpaid_cash)
        try {
          final mode = (event['mode'] ?? '').toString();
          final paymentEntry = event['payment_entry'];
          final amt = (event['amount'] ?? '').toString();
          final hasPartner = (event['sales_partner'] ?? event['salesPartner'] ?? '').toString().isNotEmpty;
          if (invoiceId != null && hasPartner && mode == 'sales_partner_unpaid_cash' && paymentEntry != null) {
            // Ensure card patched to Out For Delivery
            _patchInvoiceOutForDelivery(invoiceId, event);
            // Show collect cash dialog informing staff (idempotent UI attempt)
            _showCollectCashDialog(amount: amt, invoiceId: invoiceId);
            return; // handled
          }
        } catch (_) {}
        // If it's a new invoice broadcast (no old state), just refresh invoices
        final oldKeyForNew = event['old_state_key'] as String?;
        if ((oldKeyForNew == null || oldKeyForNew.isEmpty) && event['new_state_key'] != null) {
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
            // POPUP TRIGGER: Sales Partner + Cash on Out For Delivery
            try {
              final becameOFD = (newKey == 'out_for_delivery');
              if (becameOFD) {
                final hadPartner = (((event['sales_partner'] ?? event['salesPartner'])?.toString()) ?? '').isNotEmpty;
                // Backend now includes cash_payment_entry when cash PE was created on OFD transition
                final cashPE = event['cash_payment_entry'] ?? event['cashPaymentEntry'];
                final amt = (event['amount'] ?? '').toString();
                if (hadPartner && cashPE != null) {
                  _showCollectCashDialog(amount: amt, invoiceId: invoiceId);
                }
              }
            } catch (_) {}
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

  // UI helper: show collect cash dialog; requires root navigator context.
  void _showCollectCashDialog({required String amount, String? invoiceId}) {
    try {
      // Prefer global navigator key context so dialog is shown even if focus is elsewhere
      final navKey = _ref.read(navigatorKeyProvider);
      BuildContext? ctx = navKey.currentContext;
      ctx ??= WidgetsBinding.instance.rootElement;
      ctx ??= WidgetsBinding.instance.focusManager.primaryFocus?.context;
      if (ctx == null) return; // no context available to anchor dialog
      // Parse amount to a nicely formatted value
      String amountLabel;
      try {
        final v = double.parse(amount.toString());
        amountLabel = v.toStringAsFixed(2);
      } catch (_) {
        amountLabel = amount.toString();
      }
      showDialog(
        context: ctx,
        builder: (c) => AlertDialog(
          title: const Text('Collect Cash'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emphasize amount
              Text(
                amountLabel,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Collect the full order amount now from the Sales Partner courier.'),
              if (invoiceId != null && invoiceId.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Invoice: $invoiceId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {}
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
      Map<String, dynamic> filterMap = state.filters.hasFilters ? state.filters.toJson() : {};
      // Inject branch filter if any selected (subset of allowed profiles)
      if (state.selectedBranches.isNotEmpty) {
        // Send as list of names under 'branches' key
        filterMap['branches'] = state.selectedBranches.toList();
      }
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

    // Guard: Out For Delivery handling
    if (canonical.toLowerCase() == 'out for delivery') {
      final all = state.invoices.values.expand((e) => e).toList();
      final card = all.firstWhere((c) => c.id == invoiceId, orElse: () => InvoiceCard.fromJson({'name': invoiceId}));
      final isPaid = (card.docStatus ?? '').toLowerCase() == 'paid' || (card.effectiveStatus.toLowerCase() == 'paid');
  final hasPartner = (card.salesPartner ?? '').isNotEmpty;
      if (hasPartner) {
        // Branch: Sales Partner invoice
        if (!isPaid) {
          // UNPAID + Sales Partner -> invoke fast-path backend (auto cash PE & OFD)
          try {
            // Need POS Profile for branch cash account; attempt to resolve from POS notifier
            final posProfile = _ref.read(posNotifierProvider).selectedProfile?['name'];
            if (posProfile == null) {
              state = state.copyWith(error: 'Select POS Profile before dispatching unpaid Sales Partner invoice');
              return;
            }
            final res = await _kanbanService.salesPartnerUnpaidOutForDelivery(
              invoiceName: invoiceId,
              posProfile: posProfile,
            );
            // Patch board optimistically
            _patchInvoiceOutForDelivery(invoiceId, {
              'invoice': invoiceId,
              'mode': 'sales_partner_unpaid_cash',
              'payment_entry': res['payment_entry'],
              'sales_partner': card.salesPartner,
              'shipping_amount': 0, // backend event will correct later if needed
            });
            // Show collect prompt immediately (in addition to realtime listener) for reliability
            final amt = (res['amount'] ?? '').toString();
            if (amt.isNotEmpty) {
              _showCollectCashDialog(amount: amt, invoiceId: invoiceId);
            }
            // Refresh authoritative data
            await loadInvoices();
            return;
          } catch (e) {
            state = state.copyWith(error: 'Sales Partner unpaid dispatch failed: $e');
            return;
          }
        } else {
          // Already paid + Sales Partner -> call dedicated backend endpoint to ensure DN & realtime
          try {
            final res = await _kanbanService.salesPartnerPaidOutForDelivery(invoiceId: invoiceId);
            if (res['success'] != true) {
              state = state.copyWith(error: 'Sales Partner paid dispatch failed');
              return;
            }
            // Optimistically move, then reload authoritative data
            _optimisticMove(invoiceId, canonical);
            await loadInvoices();
          } catch (e) {
            state = state.copyWith(error: 'Sales Partner paid dispatch error: $e');
          }
          return;
        }
      } else {
        // Non-partner invoices must use courier flow – block drag direct change
        state = state.copyWith(error: 'Use Out For Delivery flow (courier required)');
        return;
      }
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

  // Branch multi-select helpers
  void setSelectedBranches(Set<String> branches) {
    // If empty set, treat as ALL (i.e., clear filter)
    final newSet = Set<String>.from(branches);
    state = state.copyWith(selectedBranches: newSet);
    loadInvoices();
  }

  void toggleBranch(String branchName) {
    final s = Set<String>.from(state.selectedBranches);
    if (s.contains(branchName)) {
      s.remove(branchName);
    } else {
      s.add(branchName);
    }
    state = state.copyWith(selectedBranches: s);
    loadInvoices();
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
    if ((state.invoices[targetKey]?.any((c) => c.id == invoiceId)) ?? false) return;
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

  /// Update customer address and make it the default
  Future<bool> updateCustomerAddress({
    required String customer,
    required String address,
    required String phone,
  }) async {
    try {
      final response = await _kanbanService.updateCustomerAddress(
        customer: customer,
        address: address,
        phone: phone,
      );
      
      return response['success'] == true || response['message'] == 'success';
    } catch (e) {
      debugPrint('Error updating customer address: $e');
      rethrow;
    }
  }

  /// Transfer invoice to a different POS profile
  Future<bool> transferInvoice({
    required String invoiceId,
    required String newBranch,
  }) async {
    try {
      await _kanbanService.transferInvoice(
        invoiceId: invoiceId,
        newBranch: newBranch,
      );
      return true;
    } catch (e) {
      debugPrint('Transfer invoice error: $e');
      return false;
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
