import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/basket_rollup.dart';
import 'production_format.dart';
import 'stock_elsewhere_note.dart';

/// The consolidated pick list, and the shortages only it can see.
///
/// A material used by three lines is summed once here. The per-line check
/// measured each line against the same available quantity, so a basket could
/// pass line by line and still be short overall — and the submit loop commits
/// per line, so that was discovered only after real stock had been consumed.
class BasketPickList extends StatelessWidget {
  const BasketPickList({super.key, required this.rollup});

  final BasketRollup rollup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rollup.hasShortages ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rollup.hasShortages ? scheme.error : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                rollup.hasShortages
                    ? Icons.warning_amber_rounded
                    : Icons.checklist_rtl,
                color: rollup.hasShortages ? scheme.error : scheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rollup.hasShortages
                      ? l10n.manufacturingInsufficientInventory
                      : l10n.productionPickListTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (!rollup.hasShortages) ...[
            const SizedBox(height: 4),
            Text(l10n.productionPickListOk, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 8),
          for (final component in rollup.components)
            _PickListRow(component: component),
        ],
      ),
    );
  }
}

class _PickListRow extends StatelessWidget {
  const _PickListRow({required this.component});

  final RollupComponent component;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commonNameWithCode(component.itemName, component.itemCode),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                l10n.manufacturingComponentRequired(
                  trimQty(component.requiredQty, decimals: 3),
                  component.uom,
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          // Wrap rather than Row: available + "shared by N lines" + the
          // shortfall is more than a phone width of text once quantities and
          // UOMs are real, and a Row overflowed by 200px.
          Wrap(
            spacing: 10,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.manufacturingComponentAvailable(
                  trimQty(component.availableQty, decimals: 3),
                  component.uom,
                ),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (component.isSharedAcrossLines)
                Text(
                  l10n.productionSharedAcrossLines(
                    component.contributingLines.length,
                  ),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              if (component.isMissingWarehouse)
                Text(
                  l10n.productionNoSourceWarehouse,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (component.isShort)
                Text(
                  l10n.productionPickListShort(
                    trimQty(component.missingQty, decimals: 3),
                    component.uom,
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          // Only ever under a line that is already short, and only when the
          // backend looked: the shortage above still blocks Start, this just
          // says whether the fix is a transfer or a purchase.
          if (component.isShort)
            StockElsewhereNote(
              availableElsewhere: component.availableElsewhere,
              alternatives: component.alternatives,
              uom: component.uom,
            ),
        ],
      ),
    );
  }
}
