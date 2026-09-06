import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/warehouse_alignment_row.dart';
import '../../data/warehouse_alignment_service.dart';

/// Read-only watchlist of submitted invoices whose item warehouses disagree
/// with their branch — the drift upstream of the recurring negative-bin
/// problem that keeps forcing branch stock recounts.
///
/// This screen is deliberately a dead end: there is NO repair action here.
/// The repair endpoint kept a stricter admin gate and must never be called
/// from mobile — the point of this screen is early visibility, not action.
/// Same chrome / loading / error / empty handling as the other report
/// screens (see [InventoryIntelligenceScreen]).
class WarehouseAlignmentScreen extends ConsumerWidget {
  const WarehouseAlignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(warehouseAlignmentFilterProvider);
    final async = ref.watch(warehouseAlignmentReportProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouseAlignTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBody(
                onRetry: () =>
                    ref.invalidate(warehouseAlignmentReportProvider(filter)),
              ),
              data: (rows) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(warehouseAlignmentReportProvider(filter)),
                child: rows.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Text(l10n.warehouseAlignEmpty),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _FilterBar extends ConsumerStatefulWidget {
  const _FilterBar();

  @override
  ConsumerState<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<_FilterBar> {
  late final TextEditingController _branchController;

  static const _limitOptions = [25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    final filter = ref.read(warehouseAlignmentFilterProvider);
    _branchController = TextEditingController(text: filter.branch ?? '');
  }

  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  void _applyBranch(String value) {
    final trimmed = value.trim();
    ref.read(warehouseAlignmentFilterProvider.notifier).update(
          (f) => f.copyWith(branch: trimmed.isEmpty ? null : trimmed),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(warehouseAlignmentFilterProvider);
    final limit = _limitOptions.contains(filter.limit)
        ? filter.limit
        : _limitOptions.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _branchController,
              decoration: InputDecoration(
                isDense: true,
                labelText: l10n.warehouseAlignBranchFilterLabel,
                hintText: l10n.warehouseAlignBranchFilterAll,
                prefixIcon: const Icon(Icons.storefront_outlined, size: 18),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _applyBranch,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: limit,
            underline: const SizedBox.shrink(),
            items: [
              for (final option in _limitOptions)
                DropdownMenuItem(value: option, child: Text('$option')),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
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
      padding: const EdgeInsets.all(8),
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

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reportError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.reportsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
