import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_round.dart';
import 'production_round_format.dart';
import 'production_round_tab_scaffold.dart';

/// One compact card per selling branch: its rate, what it holds against its
/// target, and how many jars are already under the backup line there.
class ProductionRoundBranchesTab extends StatelessWidget {
  const ProductionRoundBranchesTab({
    super.key,
    required this.round,
    required this.onRefresh,
  });

  final ProductionRound round;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (round.branches.isEmpty) {
      return RefreshableMessage(
        onRefresh: onRefresh,
        icon: Icons.storefront_outlined,
        title: l10n.productionRoundNoBranches,
      );
    }
    return RefreshableList(
      onRefresh: onRefresh,
      children: [
        for (final branch in round.branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BranchCard(branch: branch),
          ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final ProductionRoundBranch branch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final coverage = branch.parTotal <= 0
        ? 1.0
        : (branch.onHandTotal / branch.parTotal).clamp(0.0, 1.0).toDouble();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.displayName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.productionRoundSellsPerWeek(
                          fmtApprox(branch.weeklySales),
                        ),
                        style: muted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.productionRoundBranchNeeds(
                    fmtQty(branch.fillTotal, decimals: 0),
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: branch.fillTotal > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.productionRoundBranchHolds(
                fmtQty(branch.onHandTotal, decimals: 0),
                fmtQty(branch.parTotal, decimals: 0),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: coverage,
                minHeight: 3,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
              ),
            ),
            if (branch.belowBackupCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.productionRoundBelowBackup(branch.belowBackupCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
