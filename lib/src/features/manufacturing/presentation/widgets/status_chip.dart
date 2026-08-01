import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_suggestion.dart';

/// Encodes stock status in form as well as colour, so the board reads at a
/// glance without anyone parsing a days-of-cover number.
class ProductionStatusChip extends StatelessWidget {
  const ProductionStatusChip({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final (label, background, foreground) = switch (status) {
      ProductionStatus.critical => (
          l10n.productionStatusCritical,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      ProductionStatus.low => (
          l10n.productionStatusLow,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      ProductionStatus.overstocked => (
          l10n.productionStatusOverstocked,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      ProductionStatus.noVelocity => (
          l10n.productionStatusNoVelocity,
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      _ => (
          l10n.productionStatusOk,
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// A labelled figure, used for the on-hand / velocity / cover row.
class ProductionStat extends StatelessWidget {
  const ProductionStat({
    super.key,
    required this.label,
    required this.value,
    this.emphasis,
  });

  final String label;
  final String value;
  final Color? emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasis,
            // Keeps the columns from jittering as digits change.
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
