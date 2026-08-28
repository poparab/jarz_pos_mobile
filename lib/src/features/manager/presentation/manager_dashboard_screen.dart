import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/manager_providers.dart';
import '../data/manager_api.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/utils/territory_label.dart';

String _normalizedManagerError(Object error) {
  final extracted = extractFrappeErrorMessage(error, fallback: '').trim();
  final message = extracted.isNotEmpty ? extracted : error.toString().trim();
  return message.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
}

String _localizedManagerErrorDetail(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = _normalizedManagerError(error);

  switch (message) {
    case 'Failed to load transfer branches':
      return l10n.managerTransferBranchesLoadFailed;
    case 'Failed to transfer branch':
      return l10n.invoiceTransferFailed;
    case 'Failed to fetch pending custom shipping requests':
      return l10n.managerPendingCustomShippingLoadFailed;
    case 'Failed to load employee ledger':
      return l10n.managerEmployeeLedgerLoadFailed;
    default:
      return message.isEmpty ? l10n.commonError : message;
  }
}

String _localizedManagerApproveError(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = _normalizedManagerError(error);

  if (message == 'Failed to approve') {
    return l10n.managerApproveDefaultError;
  }

  return l10n.managerApproveFailed(_localizedManagerErrorDetail(context, error));
}

String _localizedManagerRejectError(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = _normalizedManagerError(error);

  if (message == 'Failed to reject') {
    return l10n.managerRejectDefaultError;
  }

  return l10n.managerRejectFailed(_localizedManagerErrorDetail(context, error));
}

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final ordersAsync = ref.watch(managerOrdersProvider);
    final statesAsync = ref.watch(managerStatesProvider);
    final pendingCustomShippingAsync = ref.watch(pendingCustomShippingProvider);
    final employeeLedgerAsync = ref.watch(employeeLedgerProvider);

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
          ref.invalidate(employeeLedgerProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(managerOrdersProvider.future),
            ref.read(pendingCustomShippingProvider.future),
            ref.read(employeeLedgerProvider.future),
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
            Text(l10n.managerEmployeeLedgerTitle, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.managerEmployeeLedgerSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            const _EmployeeLedgerWindowFilter(),
            const SizedBox(height: 8),
            employeeLedgerAsync.when(
              data: (ledger) => _EmployeeLedgerSection(ledger: ledger),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )),
              error: (e, st) => _ErrorTile(error: e, onRetry: () {
                ref.invalidate(employeeLedgerProvider);
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
        title: Text('${invoice.displayId} • ${invoice.customerName}'),
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
                  Text(context.l10n.settlementTerritoryLabel(
                    territoryLabel(nameAr: item.territoryNameAr, raw: item.territory),
                  )),
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
      if (!context.mounted) return;
      ref.invalidate(pendingCustomShippingProvider);
      ref.invalidate(managerOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerCustomShippingApproved)));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_localizedManagerApproveError(context, e))));
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, CustomShippingRequest item) async {
    final messenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;

        return AlertDialog(
          title: Text(l10n.managerRejectCustomShippingTitle),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.commonReasonLabel,
              hintText: l10n.managerRejectReasonHint,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(reasonController.text.trim()), child: Text(l10n.managerReject)),
          ],
        );
      },
    );
    if (reason == null) return;

    try {
      await ref.read(managerApiProvider).rejectCustomShipping(item.name, reason: reason);
      if (!context.mounted) return;
      ref.invalidate(pendingCustomShippingProvider);
      ref.invalidate(managerOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.managerCustomShippingRejected)));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_localizedManagerRejectError(context, e))));
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
                  width: ResponsiveUtils.getDialogWidth(ctx, small: 320, medium: 380, large: 400),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: ResponsiveUtils.getDialogHeight(ctx, phoneFraction: 0.55, tabletFraction: 0.45, max: 400),
                    ),
                    child: SingleChildScrollView(
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
          if (!context.mounted) return;
          final errorMessage = _localizedManagerErrorDetail(context, e);
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
    final message = _localizedManagerErrorDetail(context, error);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(message == l10n.commonError ? message : l10n.commonErrorWithDetails(message)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}

// ── Employee ledger ───────────────────────────────────────────────────────
//
// One manager view of what each person owes the company. Two independent
// debts add into a single balance: HRMS cash advances that were paid out and
// not yet claimed or returned, and Employee-purpose POS orders settled on the
// employee account, which stay an unpaid receivable. The outstanding totals
// are therefore the visually dominant element on this whole screen.

/// The lookback control. Anything older than the window is simply not fetched,
/// so the range is spelled out under the totals.
class _EmployeeLedgerWindowFilter extends ConsumerWidget {
  const _EmployeeLedgerWindowFilter();

  String _label(BuildContext context, EmployeeLedgerWindow window) {
    final l10n = context.l10n;
    return switch (window) {
      EmployeeLedgerWindow.days30 => l10n.managerEmployeeLedgerWindow30,
      EmployeeLedgerWindow.days90 => l10n.managerEmployeeLedgerWindow90,
      EmployeeLedgerWindow.days180 => l10n.managerEmployeeLedgerWindow180,
      EmployeeLedgerWindow.days365 => l10n.managerEmployeeLedgerWindow365,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(employeeLedgerWindowProvider);

    return Row(
      children: [
        Text(l10n.managerEmployeeLedgerPeriodLabel),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<EmployeeLedgerWindow>(
            value: selected,
            isExpanded: true,
            onChanged: (value) {
              if (value == null) return;
              ref.read(employeeLedgerWindowProvider.notifier).state = value;
            },
            items: [
              for (final window in EmployeeLedgerWindow.values)
                DropdownMenuItem<EmployeeLedgerWindow>(
                  value: window,
                  child: Text(_label(context, window)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeLedgerSection extends StatelessWidget {
  final EmployeeLedger ledger;
  const _EmployeeLedgerSection({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = ledger.summary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ledger.hasNotice) _EmployeeLedgerNotice(ledger: ledger),
        _EmployeeLedgerSummaryCard(ledger: ledger),
        const SizedBox(height: 12),
        // Everything from here down is window-scoped, and says so. The date
        // range belongs to the listed rows, never to the balance above it.
        if (ledger.fromDate.isNotEmpty && ledger.toDate.isNotEmpty)
          Text(
            l10n.managerEmployeeLedgerActivityRange(
              formatDateString(context, ledger.fromDate),
              formatDateString(context, ledger.toDate),
            ),
            style: theme.textTheme.labelLarge?.copyWith(color: muted),
          ),
        // These counts describe the rows listed in the window. They explain
        // the lists below, not the totals above, which is why they live here.
        Text(
          '${l10n.managerEmployeeLedgerAdvanceCount(summary.advanceCount)}'
          ' • ${l10n.managerEmployeeLedgerOrderCount(summary.orderCount)}',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        if (ledger.employees.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(l10n.managerEmployeeLedgerEmpty),
            ),
          )
        else
          for (final row in ledger.employees)
            _EmployeeLedgerRowTile(ledger: ledger, row: row),
      ],
    );
  }
}

/// A `notice_code` is information, never a failure — a missing HRMS or a
/// truncated result set still leaves real money on screen, so this reads as a
/// banner and not as an error tile.
class _EmployeeLedgerNotice extends StatelessWidget {
  final EmployeeLedger ledger;
  const _EmployeeLedgerNotice({required this.ledger});

  String _message(BuildContext context) {
    final l10n = context.l10n;
    switch (ledger.noticeCode) {
      case 'no_branch_assigned':
        return l10n.managerEmployeeLedgerNoticeNoBranchAssigned;
      case 'branch_not_permitted':
        return l10n.managerEmployeeLedgerNoticeBranchNotPermitted;
      case 'hrms_unavailable':
        return l10n.managerEmployeeLedgerNoticeHrmsUnavailable;
      case 'results_truncated':
        return l10n.managerEmployeeLedgerNoticeResultsTruncated;
      default:
        // An unknown code still carries a server-written explanation.
        return (ledger.notice ?? '').trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message(context);
    if (message.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeLedgerSummaryCard extends StatelessWidget {
  final EmployeeLedger ledger;
  const _EmployeeLedgerSummaryCard({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = ledger.summary;
    final currency = summary.currency;
    // The backend reports whether the money ignores the date window. The label
    // follows that flag rather than assuming, so the card can never claim a
    // windowed figure is the whole debt.
    final allTime = summary.outstandingIsAllTime;
    // A zero balance rendered in alarm red reads as a problem; it is the
    // opposite of one.
    final amountColor = summary.totalOutstanding == 0
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              allTime
                  ? l10n.managerEmployeeLedgerTotalOutstandingAllTime
                  : l10n.managerEmployeeLedgerTotalOutstanding,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(
                context,
                summary.totalOutstanding,
                currencyCode: currency,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 2),
            // employee_count is people carrying a balance, which is not the
            // same as employees.length: somebody with activity in the window
            // but nothing owed is listed at zero and not counted here.
            Text(
              l10n.managerEmployeeLedgerEmployeeCount(summary.employeeCount),
              style: theme.textTheme.bodySmall,
            ),
            if (allTime) ...[
              const SizedBox(height: 6),
              Text(
                l10n.managerEmployeeLedgerAllTimeHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Divider(height: 22),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _EmployeeLedgerHalf(
                      icon: Icons.savings_outlined,
                      label: l10n.managerEmployeeLedgerAdvancesLabel,
                      amount: formatCurrency(
                        context,
                        summary.advanceOutstanding,
                        currencyCode: currency,
                      ),
                      // HRMS absent means this half is legitimately zero, not
                      // broken — dim it so nobody reads it as a real balance.
                      dimmed: !ledger.hrmsAvailable,
                    ),
                  ),
                  const VerticalDivider(width: 20),
                  Expanded(
                    child: _EmployeeLedgerHalf(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.managerEmployeeLedgerOrdersLabel,
                      amount: formatCurrency(
                        context,
                        summary.orderOutstanding,
                        currencyCode: currency,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One side of the balance split. Deliberately carries no row count: the
/// counts describe activity in the window, and putting one under a balance
/// invites reading it as the number of items that produced that balance.
class _EmployeeLedgerHalf extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final bool dimmed;

  const _EmployeeLedgerHalf({
    required this.icon,
    required this.label,
    required this.amount,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: dimmed ? theme.disabledColor : null,
          ),
        ),
      ],
    );
  }
}

/// One person, collapsed to a single all-time balance and expandable to the
/// activity listed for the selected window.
class _EmployeeLedgerRowTile extends StatelessWidget {
  final EmployeeLedger ledger;
  final EmployeeLedgerRow row;
  const _EmployeeLedgerRowTile({required this.ledger, required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency = ledger.summary.currency;
    final advances = ledger.advancesFor(row.employee);
    final orders = ledger.ordersFor(row.employee);

    // A balance with nothing listed is a normal case, not an inconsistency:
    // the debt is simply older than the window. It must never read as
    // "nothing owed", so it gets an explicit line and the amount stays loud.
    final nothingListed = advances.isEmpty && orders.isEmpty;
    final owesMoney = row.totalOutstanding != 0;

    final meta = <String>[
      if (row.branch.isNotEmpty) row.branch,
      // An order whose customer maps to no Employee still owes real money, so
      // it is labelled rather than dropped.
      if (row.isUnmatched) l10n.managerEmployeeLedgerUnmatched,
    ].join(' • ');

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            Expanded(
              child: Text(
                row.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatCurrency(
                context,
                row.totalOutstanding,
                currencyCode: currency,
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: owesMoney
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.managerEmployeeLedgerSplit(
                formatCurrency(
                  context,
                  row.advanceOutstanding,
                  currencyCode: currency,
                ),
                formatCurrency(
                  context,
                  row.orderOutstanding,
                  currencyCode: currency,
                ),
              ),
              style: theme.textTheme.bodySmall,
            ),
            if (meta.isNotEmpty)
              Text(
                meta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l10n.managerEmployeeLedgerActivityInPeriod,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (nothingListed && owesMoney)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.managerEmployeeLedgerBalancePredatesPeriod,
                style: theme.textTheme.bodySmall,
              ),
            ),
          _EmployeeLedgerGroupLabel(
            label: l10n.managerEmployeeLedgerAdvancesLabel,
            detail: l10n.managerEmployeeLedgerAdvanceCount(advances.length),
          ),
          if (advances.isEmpty)
            _EmployeeLedgerEmptyLine(text: l10n.managerEmployeeLedgerNoAdvances)
          else
            for (final advance in advances)
              _EmployeeLedgerAdvanceTile(
                advance: advance,
                fallbackCurrency: currency,
              ),
          const SizedBox(height: 10),
          _EmployeeLedgerGroupLabel(
            label: l10n.managerEmployeeLedgerOrdersLabel,
            detail: l10n.managerEmployeeLedgerOrderCount(orders.length),
          ),
          if (orders.isEmpty)
            _EmployeeLedgerEmptyLine(text: l10n.managerEmployeeLedgerNoOrders)
          else
            for (final order in orders)
              _EmployeeLedgerOrderTile(order: order, currency: currency),
        ],
      ),
    );
  }
}

class _EmployeeLedgerGroupLabel extends StatelessWidget {
  final String label;
  final String detail;
  const _EmployeeLedgerGroupLabel({required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(detail, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmployeeLedgerEmptyLine extends StatelessWidget {
  final String text;
  const _EmployeeLedgerEmptyLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmployeeLedgerAdvanceTile extends StatelessWidget {
  final EmployeeLedgerAdvance advance;
  final String fallbackCurrency;
  const _EmployeeLedgerAdvanceTile({
    required this.advance,
    required this.fallbackCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency =
        advance.currency.isNotEmpty ? advance.currency : fallbackCurrency;
    final meta = <String>[
      if (advance.postingDate.isNotEmpty)
        formatDateString(context, advance.postingDate),
      if (advance.status.isNotEmpty)
        _localizedAdvanceStatus(context, advance.status),
      if (advance.branch.isNotEmpty) advance.branch,
    ].join(' • ');

    return _EmployeeLedgerLine(
      icon: Icons.savings_outlined,
      title: advance.purpose.isNotEmpty ? advance.purpose : advance.name,
      meta: meta,
      // The balance, not the original amount, is what is still owed.
      primaryAmount: formatCurrency(
        context,
        advance.balance,
        currencyCode: currency,
      ),
      secondary:
          '${l10n.managerEmployeeLedgerAdvanceAmountLabel} '
          '${formatCurrency(context, advance.amount, currencyCode: currency)}',
    );
  }
}

class _EmployeeLedgerOrderTile extends StatelessWidget {
  final EmployeeLedgerOrder order;
  final String currency;
  const _EmployeeLedgerOrderTile({required this.order, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = order.customerName.isNotEmpty
        ? '${order.displayId} • ${order.customerName}'
        : order.displayId;
    final meta = <String>[
      if (order.postingDate.isNotEmpty)
        formatDateString(context, order.postingDate),
      if (order.status.isNotEmpty) order.status,
      if (order.state.isNotEmpty) order.state,
      if (order.branch.isNotEmpty) order.branch,
    ].join(' • ');

    return _EmployeeLedgerLine(
      icon: Icons.receipt_long_outlined,
      title: title,
      meta: meta,
      primaryAmount: formatCurrency(
        context,
        order.outstandingAmount,
        currencyCode: currency,
      ),
      secondary:
          '${l10n.managerEmployeeLedgerOrderTotalLabel} '
          '${formatCurrency(context, order.grandTotal, currencyCode: currency)}',
    );
  }
}

/// Shared row shape for an advance and an order so the two halves read the
/// same way: what is owed on the right, in bold; context on the left.
class _EmployeeLedgerLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String meta;
  final String primaryAmount;
  final String secondary;

  const _EmployeeLedgerLine({
    required this.icon,
    required this.title,
    required this.meta,
    required this.primaryAmount,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  primaryAmount,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  secondary,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// HRMS Employee Advance statuses, reusing the labels the Expenses feature
/// already ships rather than translating the same eight words twice.
String _localizedAdvanceStatus(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status.trim().toLowerCase()) {
    case 'draft':
      return l10n.expensesAdvanceStatusDraft;
    case 'paid':
      return l10n.expensesAdvanceStatusPaid;
    case 'partially paid':
      return l10n.expensesAdvanceStatusPartiallyPaid;
    case 'unpaid':
      return l10n.expensesAdvanceStatusUnpaid;
    case 'claimed':
      return l10n.expensesAdvanceStatusClaimed;
    case 'returned':
      return l10n.expensesAdvanceStatusReturned;
    case 'partly claimed and returned':
      return l10n.expensesAdvanceStatusPartlyClaimedAndReturned;
    case 'cancelled':
      return l10n.expensesAdvanceStatusCancelled;
    default:
      return status;
  }
}
