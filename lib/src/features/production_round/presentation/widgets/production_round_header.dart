import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_round.dart';
import 'production_round_format.dart';

/// The round at a glance: batches and jars per size, three alarm chips that
/// only appear when they are non-zero, and one muted line saying what the
/// figures were computed from.
class ProductionRoundHeader extends StatelessWidget {
  const ProductionRoundHeader({super.key, required this.round});

  final ProductionRound round;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = round.summary;
    final sizes = round.sizes;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sizes.isEmpty)
              Text(
                l10n.productionRoundEmptyTitle,
                style: theme.textTheme.titleMedium,
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sizes.length; i++) ...[
                      if (i > 0) const VerticalDivider(width: 20),
                      Expanded(
                        child: _SizeFigure(
                          key: ValueKey('production-round-size-${sizes[i]}'),
                          size: sizes[i],
                          batches: summary.batches[sizes[i]] ?? 0,
                          jars: summary.jars[sizes[i]] ?? 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (summary.neededNowCount > 0 ||
                summary.missingCount > 0 ||
                summary.blockedCount > 0) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (summary.neededNowCount > 0)
                    StatChip(
                      icon: Icons.priority_high,
                      label: l10n.productionRoundNeededNow(
                        summary.neededNowCount,
                      ),
                      color: theme.colorScheme.error,
                    ),
                  if (summary.missingCount > 0)
                    StatChip(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.productionRoundMissingMaterials(
                        summary.missingCount,
                      ),
                      color: warningColor(theme),
                    ),
                  if (summary.blockedCount > 0)
                    StatChip(
                      icon: Icons.block,
                      label: l10n.productionRoundBlockedItems(
                        summary.blockedCount,
                      ),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _basisLine(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (round.notices.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: Text(
                    l10n.productionRoundNotices(round.notices.length),
                  ),
                  onPressed: () => _showNotices(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "Covers 14 days + 7 days backup · last 8 weeks of sales · updated 18:00".
  String _basisLine(BuildContext context) {
    final l10n = context.l10n;
    final cover = StringBuffer(l10n.productionRoundCoverDays(round.cycleDays));
    if (round.backupDays > 0) {
      cover.write(' ${l10n.productionRoundBackupDays(round.backupDays)}');
    }
    final parts = <String>[
      cover.toString(),
      if (round.salesWeeks > 0)
        l10n.productionRoundSalesWeeks(round.salesWeeks),
      if (fmtClock(round.generatedAt).isNotEmpty)
        l10n.productionRoundUpdatedAt(isolateLtr(fmtClock(round.generatedAt))),
    ];
    return parts.join(' · ');
  }

  void _showNotices(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(
              l10n.productionRoundNoticesTitle,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final notice in round.notices)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.info_outline, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(notice)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SizeFigure extends StatelessWidget {
  const _SizeFigure({
    super.key,
    required this.size,
    required this.batches,
    required this.jars,
  });

  final String size;
  final double batches;
  final double jars;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sizeLabel(l10n, size),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            batchesLabel(l10n, batches),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: batches > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(jarsLabel(l10n, jars), style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// A small tinted count pill. Used for the header alarms only, so it stays a
/// quiet shape rather than a full Material chip with a tap affordance.
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
