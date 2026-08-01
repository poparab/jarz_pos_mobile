import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_suggestion.dart';
import 'production_format.dart';
import 'status_chip.dart';

/// One producible item on the Plan tab.
///
/// The whole point of the row is that every number on it is already computed:
/// nobody should be subtracting stock from demand or dividing by a BOM yield.
class SuggestionRow extends StatelessWidget {
  const SuggestionRow({
    super.key,
    required this.suggestion,
    required this.onAdd,
  });

  final ProductionSuggestion suggestion;
  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final cover = suggestion.daysOfCover;
    final coverColor = switch (suggestion.status) {
      ProductionStatus.critical => scheme.error,
      ProductionStatus.low => scheme.tertiary,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.itemName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      suggestion.itemCode,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ProductionStatusChip(status: suggestion.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              ProductionStat(
                label: l10n.productionOnHand,
                value: trimQty(suggestion.onHand),
                emphasis: suggestion.stockIsNegative ? scheme.error : null,
              ),
              ProductionStat(
                label: l10n.productionSellsPerDay,
                value: trimQty(suggestion.effectiveVelocity),
              ),
              ProductionStat(
                label: l10n.productionCover,
                value: cover == null
                    ? l10n.productionCoverUnknown
                    : l10n.productionCoverDays(trimQty(cover)),
                emphasis: coverColor,
              ),
              if ((suggestion.velocityTrend ?? '').isNotEmpty)
                ProductionStat(
                  label: l10n.productionTrend,
                  value: suggestion.velocityTrend!,
                ),
            ],
          ),
          if (suggestion.stockIsNegative) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline, size: 15, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    // The suggestion below ignores the hole on purpose, so the
                    // row has to say the stock figure cannot be trusted.
                    l10n.productionNegativeStock,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (suggestion.suggestedBatches > 0) ...[
            const SizedBox(height: 10),
            _SuggestionAction(suggestion: suggestion, onAdd: onAdd),
          ],
        ],
      ),
    );
  }
}

class _SuggestionAction extends StatelessWidget {
  const _SuggestionAction({required this.suggestion, required this.onAdd});

  final ProductionSuggestion suggestion;
  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final achievable = suggestion.achievableBatches;
    final capped = suggestion.isCappedByMaterials;
    final blocked = achievable <= 0;

    // A shortage names the component that caused it and offers the achievable
    // number, rather than presenting a red wall with no way forward.
    final limiter = suggestion.limitingComponent;
    final why = capped && limiter != null
        ? l10n.productionCappedBy(
            achievable,
            limiter.itemName.isEmpty ? limiter.itemCode : limiter.itemName,
            suggestion.suggestedBatches,
          )
        : l10n.productionReachCover(suggestion.targetDays);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: capped ? scheme.tertiaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.productionMakeBatches(
                    blocked ? suggestion.suggestedBatches : achievable,
                    trimQty(
                      (blocked ? suggestion.suggestedBatches : achievable) *
                          suggestion.bomQty,
                    ),
                    suggestion.stockUom,
                  ),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  blocked && limiter != null
                      ? (limiter.isMissingWarehouse
                          ? l10n.productionNoSourceWarehouse
                          : why)
                      : why,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: blocked ? null : () => onAdd(achievable),
            child: Text(l10n.productionAddToBatch),
          ),
        ],
      ),
    );
  }
}

