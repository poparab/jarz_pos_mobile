import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/manager_providers.dart';
import '../data/manager_api.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final ordersAsync = ref.watch(managerOrdersProvider);
    final statesAsync = ref.watch(managerStatesProvider);
    final pendingCustomShippingAsync = ref.watch(pendingCustomShippingProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.managerMenuTooltip,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(l10n.managerDashboardTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(managerOrdersProvider);
          ref.invalidate(pendingCustomShippingProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(managerOrdersProvider.future),
            ref.read(pendingCustomShippingProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            summaryAsync.when(
              data: (summary) => _SummaryHeader(summary: summary),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )),
              error: (e, st) => _ErrorTile(error: e, onRetry: () {
                ref.invalidate(dashboardSummaryProvider);
              }),
            ),
            const SizedBox(height: 12),
            _BranchChips(),
            const SizedBox(height: 8),
            statesAsync.when(
              data: (states) => _StateFilter(states: states),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Text(l10n.managerPendingCustomShipping, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            pendingCustomShippingAsync.when(
              data: (items) => _PendingCustomShippingSection(items: items),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => _ErrorTile(error: e, onRetry: () {
                ref.invalidate(pendingCustomShippingProvider);
              }),
            ),
            const SizedBox(height: 12),
            Text(l10n.managerRecentOrders, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ordersAsync.when(
              data: (orders) => orders.isEmpty
                  ? Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(l10n.managerNoRecentOrders)),
                    )
                  : Column(
                      children: [for (final o in orders) _OrderTile(invoice: o)],
                    ),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )),
              error: (e, st) => _ErrorTile(error: e, onRetry: () {
                ref.invalidate(managerOrdersProvider);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final DashboardSummary summary;
  const _SummaryHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.managerBranchBalances, style: Theme.of(context).textTheme.titleMedium),
                // Simple hint button to guide switching in POS/Kanban headers
                TextButton.icon(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.managerSwitchProfileTip)),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.managerSwitchProfile),
                )
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in summary.branches)
                  Chip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(b.balance.toStringAsFixed(2), style: currencyStyle),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.managerTotalCash),
                Text(summary.totalBalance.toStringAsFixed(2), style: currencyStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(dashboardSummaryProvider).maybeWhen(
          data: (s) => s,
          orElse: () => null,
        );
    final selected = ref.watch(selectedBranchProvider);

    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          selected: selected == 'all',
          label: Text(l10n.managerAll),
          onSelected: (_) => ref.read(selectedBranchProvider.notifier).state = 'all',
        ),
        if (summary != null)
          for (final b in summary.branches)
            ChoiceChip(
              selected: selected == b.name,
              label: Text(b.title),
              onSelected: (_) => ref.read(selectedBranchProvider.notifier).state = b.name,
            ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  final ManagerInvoice invoice;
  const _OrderTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text('${invoice.name} • ${invoice.customerName}'),
        subtitle: Text('${invoice.postingDate} ${invoice.postingTime}  |  ${invoice.status}  |  ${invoice.branch}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(invoice.grandTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            _ChangeBranchButton(invoice: invoice),
          ],
        ),
      ),
    );
  }
}

class _PendingCustomShippingSection extends ConsumerWidget {
  final List<CustomShippingRequest> items;
  const _PendingCustomShippingSection({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(context.l10n.managerNoPendingRequests),
        ),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.invoice} • ${item.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '\$${item.originalAmount.toStringAsFixed(2)} → \$${item.requestedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(context.l10n.settlementTerritoryLabel(item.territoryNameAr ?? item.territory)),
                  const SizedBox(height: 4),
                  Text(context.l10n.managerReasonLabel(item.reason)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _reject(context, ref, item),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: Text(context.l10n.managerReject, style: const TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _approve(context, ref, item),
                        icon: const Icon(Icons.check),
                        label: Text(context.l10n.expensesApprove),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, CustomShippingRequest item) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(managerApiProvider).approveCustomShipping(item.name);
      ref.invalidate(pendingCustomShippingProvider);
      ref.invalidate(managerOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerCustomShippingApproved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerApproveFailed(e.toString()))));
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, CustomShippingRequest item) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.managerRejectCustomShippingTitle),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Optional rejection reason',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(reasonController.text.trim()), child: Text(context.l10n.managerReject)),
        ],
      ),
    );
    if (reason == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(managerApiProvider).rejectCustomShipping(item.name, reason: reason);
      ref.invalidate(pendingCustomShippingProvider);
      ref.invalidate(managerOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerCustomShippingRejected)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerRejectFailed(e.toString()))));
    }
  }
}

class _StateFilter extends ConsumerWidget {
  final List<String> states;
  const _StateFilter({required this.states});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(selectedStateProvider) ?? 'all';
    final items = ['all', ...states];
    return Row(
      children: [
        Text(l10n.managerFilterByState),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: items.contains(selected) ? selected : 'all',
          onChanged: (v) {
            ref.read(selectedStateProvider.notifier).state = v;
            ref.invalidate(managerOrdersProvider);
          },
          items: [
            for (final s in items)
              DropdownMenuItem<String>(
                value: s,
                child: Text(s == 'all' ? l10n.managerAll : s),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChangeBranchButton extends ConsumerWidget {
  final ManagerInvoice invoice;
  const _ChangeBranchButton({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.managerChangeBranch,
      icon: const Icon(Icons.swap_horiz),
      onPressed: () async {
        // Capture messenger before awaits to avoid using context across async gaps
        final messenger = ScaffoldMessenger.of(context);
        final summary = await ref.read(dashboardSummaryProvider.future);
        final branches = summary.branches;
        final current = invoice.branchName;
        String? selected = current;
        if (!context.mounted) return;
        final picked = await showDialog<String>(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (ctx, setState) => AlertDialog(
                title: Text(l10n.managerAssignToBranch),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final b in branches)
                        ListTile(
                          title: Text(b.title),
                          trailing: selected == b.name ? const Icon(Icons.check) : null,
                          onTap: () => setState(() {
                            selected = b.name;
                          }),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: Text(l10n.commonSubmit),
                  ),
                ],
              ),
            );
          },
        );
        if (!context.mounted) return;
        if (picked == null || picked == current) return;
        try {
          await ref.read(managerApiProvider).updateInvoiceBranch(invoiceId: invoice.name, newBranch: picked);
          final targetBranch = branches.firstWhere(
            (branch) => branch.name == picked,
            orElse: () => BranchBalance(
              name: picked,
              title: picked,
              cashAccount: null,
              balance: 0,
            ),
          );

          // Refresh the current manager list so the moved invoice leaves stale filters.
          ref.invalidate(managerOrdersProvider);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.invoiceTransferSuccess(targetBranch.title))),
          );
        } catch (e) {
          final errorMessage = extractFrappeErrorMessage(
            e,
            fallback: l10n.invoiceTransferFailed,
          );
          messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      },
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorTile({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(l10n.commonErrorWithDetails(error.toString())),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
