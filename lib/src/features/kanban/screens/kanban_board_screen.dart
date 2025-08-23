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

class KanbanBoardScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const KanbanBoardScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> with RouteAware {
  bool _showFilters = false;
  bool _allowHScroll = true; // new state

  void _setScrollActive(bool active) {
    if (_allowHScroll == active) return;
    setState(() => _allowHScroll = active);
  }

  @override
  void initState() {
    super.initState();
    // On entering Kanban, refresh to fetch any new invoices created from POS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(kanbanProvider.notifier);
      notifier.loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanState = ref.watch(kanbanProvider);
    final posState = ref.watch(posNotifierProvider);

    // If no POS profile chosen yet show helper screen
    if (posState.selectedProfile == null) {
      return Scaffold(
        appBar: widget.showAppBar ? AppBar(title: const Text('Sales Invoice Kanban')) : null,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.store_mall_directory, size: 72, color: Colors.orangeAccent),
              const SizedBox(height: 16),
              const Text('Select a POS Profile to continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => context.push('/pos-profile-selection'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Choose Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Sales Invoice Kanban'),
              actions: [
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
      // Launch courier/mode dialog
  final dialogResult = await _showCourierSettlementDialog();
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
  final mode = dialogResult['mode'] as String; // pay_now | settle_later
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
      final inv = _findInvoice(invoiceId);
      final isPaid = (inv?.docStatus ?? '').toLowerCase() == 'paid' || (inv?.effectiveStatus.toLowerCase() == 'paid');

    // New: Unpaid + settle_later -> backend handles Payment Entry + Courier Transaction + state change
    // UX: No collect-now popup for settle_later
    if (!isPaid && mode == 'settle_later') {
        try {
          final res = await ref.read(kanbanProvider.notifier).markCourierOutstanding(
            invoiceId: invoiceId,
            courier: (courier ?? 'UNKNOWN'),
            partyType: partyType,
            party: party,
            courierDisplay: courierDisplay,
          );
          if (res == null || (res['success'] != true && res['status'] != 'success')) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Failed to mark courier outstanding')),
            );
            // revert visual move
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
      // No popup in settle_later case.
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
          // revert
          final fromCol = ref.read(kanbanProvider).columns.firstWhere(
            (c) => c.id == fromColumnId,
            orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
          );
          ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
        }
        return; // handled
      }

      // If unpaid and choosing pay_now, perform a cash payment first
      if (!isPaid && mode == 'pay_now') {
        try {
          final payRes = await ref.read(kanbanProvider.notifier).payInvoice(
            invoiceId: invoiceId,
            paymentMode: 'Cash',
            posProfile: posProfile,
          );
          if (payRes == null || payRes['success'] != true) {
            messenger.showSnackBar(const SnackBar(content: Text('Payment failed; aborting move')));
            final fromCol = ref.read(kanbanProvider).columns.firstWhere(
              (c) => c.id == fromColumnId,
              orElse: () => KanbanColumn(id: fromColumnId, name: fromColumnId.replaceAll('_', ' '), color: '#F5F5F5'),
            );
            ref.read(kanbanProvider.notifier).updateInvoiceState(invoiceId, fromCol.name);
            return;
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Payment error: $e')));
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
          final rawAmt = res != null
              ? (res['shipping_amount'] ?? res['shipping_expense'] ?? res['shippingExpense'] ?? res['shipping'])
              : null;
          double? shippingAmt;
          if (rawAmt is num) {
            shippingAmt = rawAmt.toDouble();
          } else if (rawAmt is String) {
            shippingAmt = double.tryParse(rawAmt);
          }
          shippingAmt ??= inv?.shippingExpense; // fallback to card value
          final shippingLabel = (shippingAmt != null) ? '\$${shippingAmt.toStringAsFixed(2)}' : null;

          if (!isPaid) {
            // Unpaid before: we created a payment entry. Instruct staff to collect net from courier.
            final orderTotal = inv?.grandTotal ?? 0;
            final net = (shippingAmt != null) ? (orderTotal - shippingAmt) : null;
            final orderLabel = '\$${orderTotal.toStringAsFixed(2)}';
            final netLabel = (net != null) ? '\$${net.toStringAsFixed(2)}' : null;
            if (!mounted) return; // ensure context is valid before showing dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Collect From Courier'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (netLabel != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet, size: 20, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text('Net to Collect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          netLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.indigo),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if ((inv?.territory ?? '').isNotEmpty) ...[
                      Row(children: [
                        const Icon(Icons.map, size: 18, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Text('Territory: ${inv!.territory}', style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 8),
                    ],
                    Row(children: [
                      const Icon(Icons.receipt_long, size: 20, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text('Order Total: $orderLabel', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.local_shipping, size: 20, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text('Shipping: ${shippingLabel ?? '-'}'),
                    ]),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Done')),
                ],
              ),
            );
          } else {
            // Paid before: prompt to pay courier shipping expense now
            if (!mounted) return; // ensure context is valid before showing dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Pay Courier Shipping'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pay the courier the shipping expense amount now:', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    if (shippingLabel != null)
                      Row(children: [
                        const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          shippingLabel,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ])
                    else
                      const Text('Amount not returned by server. Please verify in system.',
                          style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Done')),
                ],
              ),
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

  Future<Map<String, dynamic>?> _showCourierSettlementDialog() async {
    String? courier;
    String mode = 'pay_now';
    bool loading = true;
    List<Map<String, String>> couriers = [];
    bool creating = false;
    String newPartyType = 'Employee';
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
                          RadioGroup<String>(
                            groupValue: mode,
                            onChanged: (v) => setState(() => mode = v!),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                RadioListTile<String>(
                                  title: Text('Pay Now (Cash)'),
                                  value: 'pay_now',
                                  dense: true,
                                ),
                                RadioListTile<String>(
                                  title: Text('Settle Later'),
                                  value: 'settle_later',
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
}
