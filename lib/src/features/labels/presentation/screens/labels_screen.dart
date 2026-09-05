import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/app_drawer.dart';

import '../../data/labels_repository.dart';
import '../../models/label_models.dart';
import '../../state/labels_notifier.dart';
import '../widgets/label_card.dart';
import '../widgets/label_sheets.dart';

/// The label board: every B2B customer whose labels JARZ prints, one block per
/// customer with a row per flavour, ordered by how close they are to running out.
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
            SnackBar(content: Text(context.userErrorMessage(error))),
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
    final groups = state.visibleGroups;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(context.l10n.labelsTitle),
          actions: [
            IconButton(
              tooltip: context.l10n.labelsHelpTooltip,
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelp(context, state.settings),
            ),
            IconButton(
              tooltip: context.l10n.labelsRefreshTooltip,
              icon: const Icon(Icons.refresh),
              onPressed: state.isLoading ? null : notifier.refresh,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.isSubmitting ? null : () => _openSetupWizard(),
          icon: const Icon(Icons.add_business),
          label: Text(context.l10n.labelsSetUpCustomer),
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
                      locations: state.dashboard.locations,
                      location: state.location,
                      onChanged: notifier.setFilter,
                      onLocationChanged: notifier.setLocation,
                    ),
                    _SearchField(
                      controller: _searchController,
                      onChanged: notifier.setSearch,
                    ),
                    if (state.isLoading) const LinearProgressIndicator(),
                    Expanded(
                      child: groups.isEmpty
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
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return LabelCustomerCard(
                                  group: group,
                                  onOpen: (label) =>
                                      _openDetail(context, label),
                                  onPrint: (label) =>
                                      _orderBatch(context, label),
                                  onAddFlavour: () => _openSetupWizard(
                                    customer: group.customer,
                                    customerName: group.customerName,
                                  ),
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

  /// Launches the setup wizard, optionally with a customer already picked
  /// (the "Add flavour" path from a customer header).
  Future<void> _openSetupWizard({String? customer, String? customerName}) async {
    final result = await context.push<LabelSetupResult>(
      AppRoutes.labelSetup,
      extra: customer == null
          ? null
          : <String, dynamic>{
              'customer': customer,
              if (customerName != null) 'customer_name': customerName,
            },
    );
    if (!mounted) return;
    ref.read(labelsNotifierProvider.notifier).refresh();
    if (result != null) {
      final l10n = context.l10n;
      final created = result.createdCount;
      final skipped = result.skippedCount;
      final base = created == 0
          ? l10n.labelsSetupNothingNew
          : l10n.labelsSetupTrackingCount(created);
      final suffix =
          skipped > 0 ? l10n.labelsSetupSkippedSuffix(skipped) : '';
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('$base$suffix.')),
      );
    }
  }

  Future<void> _orderBatch(BuildContext context, CustomerLabel label) async {
    final l10n = context.l10n;
    final localeName = l10n.localeName;
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
            qtySheets: request.qtySheets,
            supplier: request.supplier,
            totalCost: request.totalCost,
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
                ? l10n.labelsPrintOrderSent(request.qtySheets)
                : l10n.labelsPrintOrderDueBack(
                    request.qtySheets,
                    DateFormat('d MMM', localeName).format(due),
                  ),
          ),
        ),
      );
    }
  }

  void _showHelp(BuildContext context, LabelSettings settings) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.labelsHelpTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.labelsHelpRows),
              const SizedBox(height: 12),
              Text(
                l10n.labelsHelpSheets(
                  settings.sheetMedium,
                  settings.sheetLarge,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.labelsHelpLeadTime(
                  settings.leadDaysMin,
                  settings.leadDaysMax,
                  settings.restDay,
                  settings.bufferDays,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.labelsHelpQuiet),
              if (!settings.alertsEnabled) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.labelsHelpAlertsOff,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.labelsHelpGotIt),
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
    final l10n = context.l10n;
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
                      ? l10n.labelsSummaryUrgent(urgent)
                      : summary.reorderSoon > 0
                          ? l10n.labelsSummarySoon(summary.reorderSoon)
                          : l10n.labelsSummaryNothing,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.labelsSummaryLeadTime(
                  settings.leadDaysMin,
                  settings.leadDaysMax,
                  settings.restDay,
                ) +
                (settings.expectedReadyIfOrderedToday == null
                    ? ''
                    : l10n.labelsSummaryReadySuffix(formatDate(
                        context,
                        settings.expectedReadyIfOrderedToday!,
                        pattern: 'd MMM',
                      ))),
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
  final List<String> locations;
  final String? location;
  final ValueChanged<LabelFilter> onChanged;
  final ValueChanged<String?> onLocationChanged;

  const _FilterBar({
    required this.filter,
    required this.summary,
    required this.locations,
    required this.location,
    required this.onChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = <(LabelFilter, String, int?)>[
      (
        LabelFilter.attention,
        l10n.labelsFilterNeedsPrinting,
        summary.needsAttention
      ),
      (LabelFilter.all, l10n.labelsFilterAll, summary.total),
      (LabelFilter.onOrder, l10n.labelsFilterAtPrinter, summary.onOrder),
      (
        LabelFilter.notTracked,
        l10n.labelsFilterCustomerPrints,
        summary.notTracked
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final (value, text, count) in entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: filter == value,
                onSelected: (_) => onChanged(value),
                label: Text(count == null || count == 0
                    ? text
                    : l10n.labelsFilterWithCount(text, count)),
              ),
            ),
          if (locations.isNotEmpty)
            _LocationFilter(
              locations: locations,
              location: location,
              onChanged: onLocationChanged,
            ),
        ],
      ),
    );
  }
}

/// Compact "where is it stored" dropdown, living alongside the status chips.
class _LocationFilter extends StatelessWidget {
  final List<String> locations;
  final String? location;
  final ValueChanged<String?> onChanged;

  const _LocationFilter({
    required this.locations,
    required this.location,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = location != null && locations.contains(location);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selected ? location : null,
          icon: const Icon(Icons.place_outlined, size: 18),
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurface),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(context.l10n.labelsAllLocations),
            ),
            for (final loc in locations)
              DropdownMenuItem<String?>(
                value: loc,
                child: Text(loc, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
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
          hintText: context.l10n.labelsSearchHint,
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
    final l10n = context.l10n;

    if (!hasAnyLabels) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.label_outline,
              size: 56, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Center(
            child: Text(l10n.labelsEmptyNoneTitle,
                style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.labelsEmptyNoneBody,
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
                ? l10n.labelsEmptyEnoughCover
                : l10n.labelsEmptyNoMatch,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: onShowAll,
            child: Text(l10n.labelsShowAll),
          ),
        ),
      ],
    );
  }
}
