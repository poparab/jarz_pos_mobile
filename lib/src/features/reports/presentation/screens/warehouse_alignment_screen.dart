import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/warehouse_alignment_row.dart';
import '../../data/warehouse_alignment_service.dart';
import '../../state/reports_providers.dart';
import '../widgets/report_branch_selector.dart';
import '../widgets/report_states.dart';

/// The filter the watchlist actually runs with: the shared report branch
/// ([reportBranchProvider], null = all branches) plus the row limit kept in
/// [warehouseAlignmentFilterProvider]. With no branch and the default limit
/// this equals `const WarehouseAlignmentFilter()`.
final _effectiveFilterProvider = Provider.autoDispose<WarehouseAlignmentFilter>(
  (ref) {
    final branch = ref.watch(reportBranchProvider);
    final base = ref.watch(warehouseAlignmentFilterProvider);
    return base.copyWith(
      branch: branch,
      clearBranch: branch == null || branch.isEmpty,
    );
  },
);

/// Read-only watchlist of submitted invoices whose item warehouses disagree
/// with their branch — the drift upstream of the recurring negative-bin
/// problem that keeps forcing branch stock recounts.
///
/// This screen is deliberately a dead end: there is NO repair action here.
/// The repair endpoint kept a stricter admin gate and must never be called
/// from mobile — the point of this screen is early visibility, not action.
class WarehouseAlignmentScreen extends ConsumerWidget {
  const WarehouseAlignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(_effectiveFilterProvider);
    final async = ref.watch(warehouseAlignmentReportProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouseAlignTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.rptG2Refresh,
            onPressed: () =>
                ref.invalidate(warehouseAlignmentReportProvider(filter)),
          ),
        ],
      ),
      body: Column(
        children: [
          const _WatchlistBanner(),
          const _FilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(warehouseAlignmentReportProvider(filter).future),
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => ReportErrorView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(warehouseAlignmentReportProvider(filter)),
                ),
                data: (rows) => rows.isEmpty
                    ? ReportEmptyView(
                        message: l10n.warehouseAlignEmpty,
                        icon: Icons.verified_outlined,
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            12, 4, 12, 24),
                        itemCount: rows.length,
                        itemBuilder: (context, i) =>
                            _AlignmentRowCard(row: rows[i]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistBanner extends StatelessWidget {
  const _WatchlistBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined,
              size: 16, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.warehouseAlignWatchlistBanner,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Branch (shared report selector, clearable via "All branches") and the
/// row limit.
class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  static const _limitOptions = [25, 50, 100, 200];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(warehouseAlignmentFilterProvider);
    final limit = _limitOptions.contains(filter.limit)
        ? filter.limit
        : _limitOptions.first;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: ReportBranchSelector(
              label: l10n.warehouseAlignBranchFilterLabel,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: limit,
            underline: const SizedBox.shrink(),
            items: [
              for (final option in _limitOptions)
                DropdownMenuItem(
                  value: option,
                  child: Text(formatCount(context, option)),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(warehouseAlignmentFilterProvider.notifier)
                  .update((f) => f.copyWith(limit: value));
            },
          ),
        ],
      ),
    );
  }
}

class _AlignmentRowCard extends StatelessWidget {
  final WarehouseAlignmentRow row;
  const _AlignmentRowCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.displayId,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatCurrency(context, row.amount),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if ((row.customer ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(row.customer!, style: theme.textTheme.bodyMedium),
            ],
            if ((row.company ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${l10n.rptG2Company}: ${row.company}',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if ((row.postingDate ?? '').isNotEmpty ||
                (row.operationalProfile ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                [
                  if ((row.postingDate ?? '').isNotEmpty) row.postingDate,
                  if ((row.operationalProfile ?? '').isNotEmpty)
                    row.operationalProfile,
                ].join(' · '),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 10),
            // Expected vs Actual side by side — the contrast IS the content.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _WarehouseColumn(
                    label: l10n.warehouseAlignExpectedLabel,
                    color: theme.colorScheme.primary,
                    background: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.35),
                    warehouses: row.targetWarehouse == null
                        ? const []
                        : [row.targetWarehouse!],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
                  child: Icon(Icons.compare_arrows,
                      size: 18, color: theme.colorScheme.error),
                ),
                Expanded(
                  child: _WarehouseColumn(
                    label: l10n.warehouseAlignActualLabel,
                    color: theme.colorScheme.error,
                    background:
                        theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                    warehouses: row.actualWarehouses,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehouseColumn extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final List<String> warehouses;

  const _WarehouseColumn({
    required this.label,
    required this.color,
    required this.background,
    required this.warehouses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          if (warehouses.isEmpty)
            Text('—', style: theme.textTheme.bodySmall)
          else
            for (final wh in warehouses)
              Text(
                wh,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        ],
      ),
    );
  }
}
