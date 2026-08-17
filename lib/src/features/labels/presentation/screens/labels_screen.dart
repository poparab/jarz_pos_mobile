import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/labels_repository.dart';
import '../../models/label_models.dart';
import '../../state/labels_notifier.dart';
import '../widgets/label_card.dart';
import '../widgets/label_sheets.dart';

/// The label board: every B2B customer whose labels JARZ prints, ordered by how
/// close they are to running out.
///
/// Printing is outsourced and takes working days, so the question this screen
/// exists to answer is not "how many labels do we have" but "which of these has
/// to go to the print house today to land before it runs out". That is why the
/// default filter is the alert list and the headline number is the urgent count.
class LabelsScreen extends ConsumerStatefulWidget {
  const LabelsScreen({super.key});

  @override
  ConsumerState<LabelsScreen> createState() => _LabelsScreenState();
}

class _LabelsScreenState extends ConsumerState<LabelsScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _searchController = TextEditingController();
  late final ProviderSubscription<LabelsState> _errorListener;

  @override
  void initState() {
    super.initState();
    _errorListener = ref.listenManual<LabelsState>(
      labelsNotifierProvider,
      (previous, next) {
        final error = next.error;
        if (error == null || error.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _messengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(error)),
          );
          ref.read(labelsNotifierProvider.notifier).clearError();
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(labelsNotifierProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _errorListener.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(labelsNotifierProvider);
    final notifier = ref.read(labelsNotifierProvider.notifier);
    final labels = state.visibleLabels;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Customer Labels'),
          actions: [
            IconButton(
              tooltip: 'How this works',
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelp(context, state.settings),
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: state.isLoading ? null : notifier.refresh,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.isSubmitting ? null : () => _addLabel(context),
          icon: const Icon(Icons.add),
          label: const Text('Track a label'),
        ),
        body: !state.initialized && state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: notifier.refresh,
                child: Column(
                  children: [
                    _SummaryHeader(
                      summary: state.summary,
                      settings: state.settings,
                    ),
                    _FilterBar(
                      filter: state.filter,
                      summary: state.summary,
                      onChanged: notifier.setFilter,
                    ),
                    _SearchField(
                      controller: _searchController,
                      onChanged: notifier.setSearch,
                    ),
                    if (state.isLoading) const LinearProgressIndicator(),
                    Expanded(
                      child: labels.isEmpty
                          ? _EmptyState(
                              filter: state.filter,
                              hasAnyLabels: state.dashboard.labels.isNotEmpty,
                              onShowAll: () =>
                                  notifier.setFilter(LabelFilter.all),
                            )
                          : ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 90, top: 4),
                              itemCount: labels.length,
                              itemBuilder: (context, index) {
                                final label = labels[index];
                                return LabelCard(
                                  label: label,
                                  onTap: () => _openDetail(context, label),
                                  onPrint: () => _orderBatch(context, label),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, CustomerLabel label) async {
    await context.push(AppRoutes.labelDetail, extra: label.name);
    if (mounted) ref.read(labelsNotifierProvider.notifier).refresh();
  }

  Future<void> _addLabel(BuildContext context) async {
    final request = await showModalBottomSheet<NewLabelRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NewLabelSheet(),
    );
    if (request == null || !mounted) return;

    final notifier = ref.read(labelsNotifierProvider.notifier);
    final created = await notifier.run(
      () => ref.read(labelsRepositoryProvider).createLabel(
            customer: request.customer,
            labelTitle: request.labelTitle,
            wePrint: request.wePrint,
            appliesToItemGroup: request.itemGroup,
            labelsPerUnit: request.labelsPerUnit,
            minStockQty: request.minStockQty,
            reorderQty: request.reorderQty,
            openingQty: request.openingQty,
            notes: request.notes,
          ),
    );
    if (created != null && mounted) {
      notifier.applyUpdated(created);
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Now tracking ${created.displayTitle}')),
      );
    }
  }

  Future<void> _orderBatch(BuildContext context, CustomerLabel label) async {
    final request = await showModalBottomSheet<PrintOrderRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PrintOrderSheet(label: label),
    );
    if (request == null || !mounted) return;

    final notifier = ref.read(labelsNotifierProvider.notifier);
    final updated = await notifier.run(
      () => ref.read(labelsRepositoryProvider).createPrintOrder(
            label: label.name,
            qty: request.qty,
            printerName: request.printerName,
            notes: request.notes,
          ),
    );
    if (updated != null && mounted) {
      notifier.applyUpdated(updated);
      final due = updated.nextArrival?.expectedReadyDate;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            due == null
                ? 'Batch of ${request.qty} sent to the printer'
                : '${request.qty} ordered — due back ${DateFormat('d MMM').format(due)}',
          ),
        ),
      );
    }
  }

  void _showHelp(BuildContext context, LabelSettings settings) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('How label tracking works'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Labels come off stock automatically when an invoice is '
                'submitted for a customer whose labels we print. Customers who '
                'bring their own are marked "Customer prints" and are never '
                'counted.',
              ),
              const SizedBox(height: 12),
              Text(
                'Printing takes ${settings.leadDaysMin}–${settings.leadDaysMax} '
                'working days with ${settings.restDay} excluded, so a label is '
                'flagged "Print now" once its remaining stock would not survive '
                'that wait — and "Print soon" ${settings.bufferDays} days before '
                'that point.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Once a batch is at the printer the label goes quiet and shows '
                'its due-back date instead, so the same shortage is not raised '
                'every morning.',
              ),
              if (!settings.alertsEnabled) ...[
                const SizedBox(height: 12),
                const Text(
                  'Daily alerts are currently switched off in Jarz POS Settings.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final LabelSummary summary;
  final LabelSettings settings;

  const _SummaryHeader({required this.summary, required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgent = summary.urgent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      color: urgent > 0
          ? const Color(0xFFB3261E).withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                urgent > 0 ? Icons.local_printshop : Icons.verified,
                color: urgent > 0
                    ? const Color(0xFFB3261E)
                    : const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  urgent > 0
                      ? '$urgent label${urgent == 1 ? '' : 's'} must go to the printer now'
                      : summary.reorderSoon > 0
                          ? '${summary.reorderSoon} label${summary.reorderSoon == 1 ? '' : 's'} to print soon'
                          : 'Nothing needs printing',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Printing takes ${settings.leadDaysMin}–${settings.leadDaysMax} working '
            'days · ${settings.restDay} excluded'
            '${settings.expectedReadyIfOrderedToday == null ? '' : ' · order today, ready ${DateFormat('d MMM').format(settings.expectedReadyIfOrderedToday!)}'}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final LabelFilter filter;
  final LabelSummary summary;
  final ValueChanged<LabelFilter> onChanged;

  const _FilterBar({
    required this.filter,
    required this.summary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <(LabelFilter, String, int?)>[
      (LabelFilter.attention, 'Needs printing', summary.needsAttention),
      (LabelFilter.all, 'All', summary.total),
      (LabelFilter.onOrder, 'At printer', summary.onOrder),
      (LabelFilter.notTracked, 'Customer prints', summary.notTracked),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, text, count) = entries[index];
          return ChoiceChip(
            selected: filter == value,
            onSelected: (_) => onChanged(value),
            label: Text(count == null || count == 0 ? text : '$text ($count)'),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search customer or label',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final LabelFilter filter;
  final bool hasAnyLabels;
  final VoidCallback onShowAll;

  const _EmptyState({
    required this.filter,
    required this.hasAnyLabels,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasAnyLabels) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.label_outline,
              size: 56, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Center(
            child: Text('No labels tracked yet',
                style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add the B2B customers whose jar labels JARZ prints. Stock then '
              'comes down on its own as their orders are invoiced.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(
          filter == LabelFilter.attention ? Icons.check_circle_outline : Icons.filter_alt_off,
          size: 56,
          color: filter == LabelFilter.attention
              ? const Color(0xFF2E7D32)
              : theme.colorScheme.outlineVariant,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            filter == LabelFilter.attention
                ? 'Every label has enough cover'
                : 'Nothing matches this filter',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: onShowAll,
            child: const Text('Show all labels'),
          ),
        ),
      ],
    );
  }
}
