import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/kanban_provider.dart';
import '../models/kanban_models.dart';
import '../widgets/kanban_column_widget.dart';
import '../widgets/kanban_filters_widget.dart';
import '../../pos/state/pos_notifier.dart';
import '../../../core/router.dart';
import '../../pos/presentation/widgets/courier_balances_dialog.dart';
import '../../../core/network/courier_service.dart';
import '../widgets/settlement_preview_dialog.dart';
import '../../printing/pos_printer_provider.dart';
import '../../printing/printer_status.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/branch_filter_dialog.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const KanbanBoardScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> with RouteAware {
  bool _showFilters = false;
  bool _allowHScroll = true; // new state
  bool _posProfileDialogActive = false;
  ProviderSubscription<PosState>? _posStateSubscription;

  void _setScrollActive(bool active) {
    if (_allowHScroll == active) return;
    setState(() => _allowHScroll = active);
  }

  @override
  void initState() {
    super.initState();
    _posStateSubscription = ref.listenManual<PosState>(
      posNotifierProvider,
      (previous, next) {
        if (mounted) {
          _handlePosStateChange(next);
        }
      },
    );
    // On entering Kanban, refresh to fetch any new invoices created from POS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(kanbanProvider.notifier);
      notifier.loadInvoices();
      // Proactively load POS profiles so branch filter is available immediately
      final posState = ref.read(posNotifierProvider);
      if (!posState.isLoading && posState.profiles.isEmpty) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      }
      _handlePosStateChange(posState);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanState = ref.watch(kanbanProvider);
    // No POS profile guard here; Kanban should be usable with branch filter defaults

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: widget.showAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  tooltip: 'Menu',
                ),
              ),
              title: const Text('Sales Invoice Kanban'),
              actions: [
                // Branch filter control (compact dropdown with checkboxes)
                const _BranchFilterButton(),
                // Unified Printer Status Chip (same behavior/visuals as POS header)
                Consumer(
                  builder: (context, ref, _) {
                    final printer = ref.watch(posPrinterServiceProvider);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: InkWell(
                        onTap: () => context.push('/printers'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: () {
                              switch (printer.unifiedStatus) {
                                case PrinterUnifiedStatus.connectedBle:
                                case PrinterUnifiedStatus.connectedClassic:
                                  return Colors.green.withValues(alpha: 0.15);
                                case PrinterUnifiedStatus.connecting:
                                  return Colors.orange.withValues(alpha: 0.15);
                                case PrinterUnifiedStatus.error:
                                  return Colors.red.withValues(alpha: 0.18);
                                case PrinterUnifiedStatus.disconnected:
                                  return Colors.red.withValues(alpha: 0.15);
                              }
                            }(),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: () {
                                switch (printer.unifiedStatus) {
                                  case PrinterUnifiedStatus.connectedBle:
                                  case PrinterUnifiedStatus.connectedClassic:
                                    return Colors.green;
                                  case PrinterUnifiedStatus.connecting:
                                    return Colors.orange;
                                  case PrinterUnifiedStatus.error:
                                    return Colors.red;
                                  case PrinterUnifiedStatus.disconnected:
                                    return Colors.red;
                                }
                              }().withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.print,
                                size: 16,
                                color: () {
                                  switch (printer.unifiedStatus) {
                                    case PrinterUnifiedStatus.connectedBle:
                                    case PrinterUnifiedStatus.connectedClassic:
                                      return Colors.greenAccent;
                                    case PrinterUnifiedStatus.connecting:
                                      return Colors.orangeAccent;
                                    case PrinterUnifiedStatus.error:
                                      return Colors.redAccent;
                                    case PrinterUnifiedStatus.disconnected:
                                      return Colors.redAccent;
                                  }
                                }(),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                () {
                                  switch (printer.unifiedStatus) {
                                    case PrinterUnifiedStatus.connectedBle:
                                      return 'Printer: BLE';
                                    case PrinterUnifiedStatus.connectedClassic:
                                      return 'Printer: Classic';
                                    case PrinterUnifiedStatus.connecting:
                                      return 'Printer: Connecting…';
                                    case PrinterUnifiedStatus.error:
                                      return printer.lastErrorMessage ?? 'Printer Error';
                                    case PrinterUnifiedStatus.disconnected:
                                      return 'Printer: Not Connected';
                                  }
                                }(),
                                style: TextStyle(
                                  color: () {
                                    switch (printer.unifiedStatus) {
                                      case PrinterUnifiedStatus.connectedBle:
                                      case PrinterUnifiedStatus.connectedClassic:
                                        return Colors.green;
                                      case PrinterUnifiedStatus.connecting:
                                        return Colors.orange;
                                      case PrinterUnifiedStatus.error:
                                        return Colors.red;
                                      case PrinterUnifiedStatus.disconnected:
                                        return Colors.red;
                                    }
                                  }(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Courier Balances',
                  icon: const Icon(Icons.local_shipping),
                  onPressed: () => showCourierBalancesDialog(context),
                ),
                IconButton(
                  tooltip: 'Open POS',
                  icon: const Icon(Icons.point_of_sale),
                  onPressed: () => context.push('/pos'),
                ),
                IconButton(
                  tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
                  icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                )
              ],
            )
          : null,
      body: Column(
        children: [
          // Removed full-width branch chips to maximize kanban space; filter now in header
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: KanbanFiltersWidget(
                filters: kanbanState.filters,
                customers: kanbanState.customers,
                onFiltersChanged: (newFilters) {
                  ref.read(kanbanProvider.notifier).updateFilters(newFilters);
                },
              ),
            ),
          Expanded(child: _buildKanbanContent(kanbanState)),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route lifecycle
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute<dynamic>) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    _posStateSubscription?.close();
    // Unsubscribe
    try { routeObserver.unsubscribe(this); } catch (_) {}
    super.dispose();
  }

  // Called when coming back to this screen (e.g., from POS)
  @override
  void didPopNext() {
    // Refresh invoices and columns to pick up newly created orders
    final notifier = ref.read(kanbanProvider.notifier);
    notifier.loadInvoices();
    // Optionally refresh columns if backend added new states dynamically
    notifier.loadColumns();
  }

  Widget _buildKanbanContent(KanbanState kanbanState) {
    if (kanbanState.isLoading && kanbanState.columns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

  if (kanbanState.error != null && kanbanState.columns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading Kanban data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              kanbanState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(kanbanProvider.notifier).clearError();
                ref.read(kanbanProvider.notifier).loadInvoices();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (kanbanState.columns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'No Kanban columns configured',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please ensure the Sales Invoice State field is configured in ERPNext',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(kanbanProvider.notifier).loadKanbanData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: _allowHScroll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in kanbanState.columns) ...[
            Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              child: KanbanColumnWidget(
                column: column,
                invoices: kanbanState.invoices[column.id] ?? const [],
                onCardMoved: (invoiceId, newColumnId) => _handleCardMove(invoiceId, column.id, newColumnId),
                onCardPointerActive: (active) => _setScrollActive(!active),
              ),
            )
          ]
        ],
      ),
    );
  }

  void _handleCardMove(
    String invoiceId,
    String fromColumnId,
    String toColumnId,
  ) async {
  // Clear any previous error so it doesn't persist on the screen
  final messenger = ScaffoldMessenger.of(context);
  ref.read(kanbanProvider.notifier).clearError();
    final targetColumn = ref.read(kanbanProvider).columns.firstWhere(
      (col) => col.id == toColumnId,
      orElse: () => KanbanColumn(id: toColumnId, name: toColumnId, color: '#F5F5F5'),
    );

    String normId = toColumnId.trim().toLowerCase();
    String normName = targetColumn.name.trim().toLowerCase().replaceAll('  ', ' ');
    String collapsedName = normName.replaceAll(' ', '_');
    final movingToOut = (
      normId == 'out_for_delivery' ||
      collapsedName == 'out_for_delivery' ||
      (normName.contains('out') && normName.contains('delivery'))
    );
    if (movingToOut) {
      final inv = _findInvoice(invoiceId);
      final isPaid = (inv?.docStatus ?? '').toLowerCase() == 'paid' || (inv?.effectiveStatus.toLowerCase() == 'paid');
      final hasPartner = ((inv?.salesPartner ?? '').isNotEmpty);
      final isPickup = (inv?.isPickup ?? false);
      if (hasPartner) {
        // Fast-path for ANY Sales Partner invoice (paid or unpaid):
        // Provider logic distinguishes paid vs unpaid and will:
        //  - Paid: simple state update
        //  - Unpaid: create cash Payment Entry + auto OFD via backend endpoint
        await ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, 'Out For Delivery');
        return;
      }
    // Launch courier/mode dialog
      // Show "Settle Later" for non-partner, non-pickup only (per business rule)
      final showSettleLater = !hasPartner && !isPickup;
      final dialogResult = await _showCourierSettlementDialog(hideSettleLater: !showSettleLater);
      if (dialogResult == null) {
        // Revert visual move if user cancelled (pass label)
        final fromCol = ref.read(kanbanProvider).columns.firstWhere(
          (c) => c.id == fromColumnId,
          orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
        );
        ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
        return;
      }
  final courier = dialogResult['courier'] as String?; // may be 'UNKNOWN'
  final mode = dialogResult['mode'] as String; // pay_now
  final partyType = dialogResult['party_type'] as String?;
  final party = dialogResult['party'] as String?;
  final courierDisplay = dialogResult['display_name'] as String? ?? courier;
      final posProfile = _getPosProfile();
      if (posProfile == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
        // revert
        final fromCol = ref.read(kanbanProvider).columns.firstWhere(
          (c) => c.id == fromColumnId,
          orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
        );
        ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
        return;
      }
  // inv and isPaid already computed above

  // Only pay_now is supported per new business rule

      // New: Support 'later' when enabled (except Sales Partner and Pickup)
      if (mode == 'later') {
        try {
          final courierService = ref.read(courierServiceProvider);
          // Generate preview only to obtain a token; do not show any collect/pay dialogs
          final preview = await courierService.generateSettlementPreview(
            invoice: invoiceId,
            partyType: partyType,
            party: party,
            mode: 'later',
            recentPaymentSeconds: 30,
          );
          final previewPartyType = (preview['party_type'] ?? '').toString().trim();
          final previewParty = (preview['party'] ?? '').toString().trim();
          final resolvedPartyType = (partyType?.trim().isNotEmpty ?? false)
              ? partyType!.trim()
              : (previewPartyType.isNotEmpty ? previewPartyType : null);
          final resolvedParty = (party?.trim().isNotEmpty ?? false)
              ? party!.trim()
              : (previewParty.isNotEmpty ? previewParty : null);
          if (resolvedPartyType == null || resolvedParty == null) {
            messenger.showSnackBar(const SnackBar(content: Text('Settle Later failed: courier party missing. Assign courier and retry.')));
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
          final token = (preview['preview_token'] ?? preview['token'] ?? '').toString();
          if (token.isEmpty) {
            messenger.showSnackBar(const SnackBar(content: Text('Settle Later failed: preview expired.')));
            // revert
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }

          final res = await courierService.confirmSettlement(
            invoice: invoiceId,
            previewToken: token,
            mode: 'later',
            posProfile: posProfile,
            partyType: resolvedPartyType,
            party: resolvedParty,
            // No immediate collection; include courier label if present
            courier: courier ?? courierDisplay ?? 'UNKNOWN',
          );
          if (res['success'] != true) {
            messenger.showSnackBar(const SnackBar(content: Text('Settle Later failed')));
            // revert
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
          // Success: do not show collection/info popups for settle later
          messenger.showSnackBar(const SnackBar(content: Text('Marked to Settle Later')));
          return; // handled fully; backend already moved to OFD
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Settle Later error: $e')));
          // revert
          final fromCol = ref.read(kanbanProvider).columns.firstWhere(
            (c) => c.id == fromColumnId,
            orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
          );
          ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
          return;
        }
      }

      // If unpaid and choosing pay_now -> use two-step server-driven flow (preview -> confirm)
      if (!isPaid && mode == 'pay_now') {
        try {
          final courierService = ref.read(courierServiceProvider);
          final preview = await courierService.generateSettlementPreview(
            invoice: invoiceId,
            partyType: partyType,
            party: party,
            mode: mode,
            recentPaymentSeconds: 30,
          );
          final previewPartyType = (preview['party_type'] ?? '').toString().trim();
          final previewParty = (preview['party'] ?? '').toString().trim();
          final resolvedPartyType = (partyType?.trim().isNotEmpty ?? false)
              ? partyType!.trim()
              : (previewPartyType.isNotEmpty ? previewPartyType : null);
          final resolvedParty = (party?.trim().isNotEmpty ?? false)
              ? party!.trim()
              : (previewParty.isNotEmpty ? previewParty : null);
          if (resolvedPartyType == null || resolvedParty == null) {
            messenger.showSnackBar(const SnackBar(content: Text('Settlement failed: courier party missing. Assign courier and retry.')));
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
          if (!mounted) return;

          final confirmed = await showSettlementConfirmDialog(
            context,
            preview,
            invoice: invoiceId,
            territory: inv?.territory,
            orderFallback: inv?.grandTotal,
            shippingFallback: inv?.shippingExpenseDisplay,
          );
          if (confirmed != true) {
            // Revert visual move if user cancelled
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }

          final token = (preview['preview_token'] ?? preview['token'] ?? '').toString();
          if (token.isEmpty) {
            messenger.showSnackBar(const SnackBar(content: Text('Preview expired. Please retry.')));
            // revert
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }

          messenger.showSnackBar(const SnackBar(content: Text('Confirming settlement...')));
          final res = await courierService.confirmSettlement(
            invoice: invoiceId,
            previewToken: token,
            mode: mode,
            posProfile: posProfile,
            partyType: resolvedPartyType,
            party: resolvedParty,
            paymentMode: 'Cash',
            courier: courier ?? courierDisplay ?? 'UNKNOWN',
          );
          if (res['success'] != true) {
            messenger.showSnackBar(const SnackBar(content: Text('Settlement failed')));
            // revert
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
          messenger.showSnackBar(const SnackBar(content: Text('Settlement confirmed')));
          return; // handled: server already performed OFD
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Settlement error: $e')));
          // revert
          final fromCol = ref.read(kanbanProvider).columns.firstWhere(
            (c) => c.id == fromColumnId,
            orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
          );
          ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
          return;
        }
      }

      // Perform unified OFD transition
      ref.read(kanbanProvider.notifier)
          .outForDeliveryUnified(
            invoiceId: invoiceId,
            courier: courier ?? 'UNKNOWN',
            mode: mode,
            posProfile: posProfile,
            partyType: partyType,
            party: party,
            courierDisplay: courierDisplay,
          )
          .then((res) async {
        if (mode == 'pay_now') {
          // Fetch settlement preview to drive UI (signed net logic)
          try {
            final courierService = ref.read(courierServiceProvider);
            final preview = await courierService.getSettlementPreview(
              invoice: invoiceId,
              partyType: partyType,
              party: party,
            );
            if (!mounted) return;
            await _showSettlementResultDialog(preview, inv);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Preview failed: $e')),
            );
          }
        }
      });
      return; // do not fall through to normal state update
    }

    // Other states: normal state update
    ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, targetColumn.name);
  }

  InvoiceCard? _findInvoice(String id) {
    final s = ref.read(kanbanProvider);
    for (final entry in s.invoices.entries) {
      for (final c in entry.value) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  String? _getPosProfile() {
    final posState = ref.read(posNotifierProvider);
    return posState.selectedProfile?['name'];
  }

  void _handlePosStateChange(PosState state) {
    if (!mounted) return;
    final hasMultipleProfiles = state.profiles.length > 1;
    final noProfileSelected = state.selectedProfile == null;
    if (!_posProfileDialogActive && hasMultipleProfiles && noProfileSelected && !state.isLoading) {
      _posProfileDialogActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final selected = await _showPosProfileSelectionDialog(state.profiles);
        _posProfileDialogActive = false;
        if (selected != null && mounted) {
          await ref.read(posNotifierProvider.notifier).selectProfile(selected);
        }
      });
    }
  }

  Future<Map<String, dynamic>?> _showPosProfileSelectionDialog(List<Map<String, dynamic>> profiles) async {
    if (!mounted) return null;
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Select POS Profile'),
            content: SizedBox(
              width: 420,
              child: profiles.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No POS profiles available. Contact your administrator.'),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: profiles.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final profile = profiles[index];
                          final title = (profile['title'] ?? profile['name'] ?? '').toString();
                          final warehouse = (profile['warehouse'] ?? '').toString();
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: const Icon(Icons.store),
                              title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: warehouse.isNotEmpty ? Text('Warehouse: $warehouse') : null,
                              onTap: () => Navigator.of(ctx).pop(profile),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showCourierSettlementDialog({bool hideSettleLater = false}) async {
    String? courier;
    String mode = 'pay_now';
    bool loading = true;
    List<Map<String, String>> couriers = [];
    bool creating = false;
    String newPartyType = 'Supplier'; // Default to Supplier (Employee has validation issues on staging)
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    try {
      couriers = await ref.read(kanbanProvider.notifier).getCouriers();
      // Branch filter: keep only couriers whose branch matches selected POS profile name (if branch present)
      final posProfile = _getPosProfile();
      if (posProfile != null) {
        couriers = couriers.where((c) => (c['branch'] == null || c['branch']!.isEmpty) ? true : c['branch'] == posProfile).toList();
      }
    } catch (_) {}
    loading = false;
    if (!mounted) return null;
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Courier & Mode'),
            content: SizedBox(
              width: 640,
              child: loading
                  ? const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!creating) ...[
                            if (couriers.isEmpty) ...[
                              const Icon(Icons.local_shipping_outlined, size: 48, color: Colors.orange),
                              const SizedBox(height: 12),
                              Text('No couriers available', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                'Create a courier for tracking or continue without one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                            ] else ...[
                              // Grid/list of courier cards for selection
                              LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final isWide = constraints.maxWidth > 560;
                                  final crossAxisCount = isWide ? 3 : 2;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: couriers.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 2.8,
                                    ),
                                    itemBuilder: (ctx, i) {
                                      final c = couriers[i];
                                      final selected = courier == c['party'];
                                      return InkWell(
                                        onTap: () => setState(() => courier = c['party']),
                                        borderRadius: BorderRadius.circular(12),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected ? Colors.blue : Colors.grey[300]!,
                                              width: selected ? 2 : 1,
                                            ),
                                            color: selected ? Colors.blue.withValues(alpha: 0.06) : Colors.white,
                                            boxShadow: [
                                              if (selected)
                                                BoxShadow(
                                                  color: Colors.blue.withValues(alpha: 0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: selected ? Colors.blue : Colors.grey[200],
                                                child: Icon(Icons.person, color: selected ? Colors.white : Colors.grey[600]),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      c['display_name'] ?? c['party']!,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: selected ? Colors.blue[800] : Colors.black87,
                                                      ),
                                                    ),
                                                    if (c['party_type'] != null)
                                                      Text(
                                                        c['party_type']!,
                                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('New Courier'),
                                onPressed: () => setState(() => creating = true),
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: firstNameController,
                                    decoration: const InputDecoration(labelText: 'First Name'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: lastNameController,
                                    decoration: const InputDecoration(labelText: 'Last Name'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'Phone'),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: newPartyType,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: const [
                                DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                                DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                              ],
                              onChanged: (v) => setState(() => newPartyType = v ?? 'Employee'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: loading ? null : () => setState(() => creating = false),
                                  child: const Text('Back'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: loading
                                      ? null
                                      : () async {
                      final firstName = firstNameController.text.trim();
                      final lastName = lastNameController.text.trim();
                                          final phone = phoneController.text.trim();
                      if (firstName.isEmpty || lastName.isEmpty) return;
                                          setState(() => loading = true);
                                          try {
                                            final posProfile = _getPosProfile();
                                            final created = await ref.read(kanbanProvider.notifier).createDeliveryParty(
                                              partyType: newPartyType,
                        firstName: firstName,
                        lastName: lastName,
                                              phone: phone,
                                              posProfile: posProfile,
                                            );
                                            if (created != null) {
                                              couriers = [...couriers, created];
                                              courier = created['party'];
                                              creating = false;
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Create failed: $e')),
                                              );
                                            }
                                          } finally {
                                            setState(() => loading = false);
                                          }
                                        },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Save'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Mode', style: Theme.of(context).textTheme.titleSmall),
                          ),
                          // Offer Pay Now always; optionally show Settle Later per business rule
                          RadioGroup<String>(
                            groupValue: mode,
                            onChanged: (v) => setState(() => mode = v ?? mode),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const RadioListTile<String>(
                                  title: Text('Pay Now (Cash)'),
                                  value: 'pay_now',
                                  dense: true,
                                ),
                                if (!hideSettleLater)
                                  const RadioListTile<String>(
                                    title: Text('Settle Later (no immediate cash)'),
                                    subtitle: Text('Record courier outstanding; settle in batch later'),
                                    value: 'later',
                                    dense: true,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              if (!creating)
                if (couriers.isEmpty)
                  ElevatedButton(
                    onPressed: loading
                        ? null
                        : () => Navigator.pop(ctx, {
                              'courier': 'UNKNOWN',
                              'mode': mode,
                              'no_courier': true,
                            }),
                    child: const Text('Continue'),
                  )
                else
                  ElevatedButton(
                    onPressed: courier == null || loading
                        ? null
                        : () {
                              final selected = couriers.firstWhere((c) => c['party'] == courier, orElse: () => {});
                              Navigator.pop(ctx, {
                                'courier': courier,
                                'mode': mode,
                                'party_type': selected['party_type'],
                                'party': selected['party'],
                                'display_name': selected['display_name'],
                              });
                            },
                    child: const Text('Confirm'),
                  )
              else
                const SizedBox.shrink(),
            ],
          );
        });
      },
    );
  }

  Future<void> _showSettlementResultDialog(Map<String, dynamic> preview, InvoiceCard? inv) async {
    await showSettlementInfoDialog(
      context,
      preview,
      invoice: inv?.name,
      territory: inv?.territory,
      orderFallback: inv?.grandTotal,
      shippingFallback: inv?.shippingExpenseDisplay,
    );
  }
}


class _BranchFilterButton extends ConsumerWidget {
  const _BranchFilterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final posState = ref.watch(posNotifierProvider);
    final sel = ref.watch(kanbanProvider).selectedBranches;
    final profiles = posState.profiles;
    // Always render a placeholder chip so the UI is visible immediately
    final isLoading = posState.isLoading && profiles.isEmpty;

    final selectedCount = sel.length;
    final label = selectedCount == 0
        ? 'All Branches'
        : (selectedCount == 1 ? '1 Branch' : '$selectedCount Branches');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: () async {
          if (profiles.isEmpty) return; // ignore taps until loaded
          final current = Set<String>.from(sel);
          final result = await showDialog<Set<String>>(
            context: context,
            useRootNavigator: true,
            builder: (ctx) => BranchFilterDialog(
              profiles: profiles,
              initiallySelected: current,
              title: 'Filter by Branches',
            ),
          );
          if (result != null) {
            ref.read(kanbanProvider.notifier).setSelectedBranches(result);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt, size: 16, color: theme.colorScheme.onSurface),
              const SizedBox(width: 6),
              Text(
                isLoading ? 'Loading branches…' : label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 18, color: theme.colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
