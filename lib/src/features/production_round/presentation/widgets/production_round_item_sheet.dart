import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_round.dart';
import 'production_round_format.dart';

/// Why one jar is on the list: every branch's rate, target and stock, what
/// the factory already holds, and which missing material is holding it up.
Future<void> showProductionRoundItemSheet(
  BuildContext context,
  ProductionRound round,
  ProductionRoundItem item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ProductionRoundItemDetail(round: round, item: item),
        ),
      ),
    ),
  );
}

class ProductionRoundItemDetail extends StatelessWidget {
  const ProductionRoundItemDetail({
    super.key,
    required this.round,
    required this.item,
  });

  final ProductionRound round;
  final ProductionRoundItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(item.fullName, style: theme.textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          item.isToMake
              ? '${batchesLabel(l10n, item.batches)} · ${jarsLabel(l10n, item.jars)}'
              : (item.status == ProductionRoundStatus.noSales
                    ? l10n.productionRoundStatusNoSales
                    : l10n.productionRoundStatusCovered),
          style: theme.textTheme.titleSmall?.copyWith(
            color: item.isToMake
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Text(
              l10n.productionRoundSellsPerWeek(fmtApprox(item.weeklySales)),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              l10n.productionRoundBranchesNeed(fmtQty(item.totalFill)),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              l10n.productionRoundFactoryHas(fmtQty(item.factoryOnHand)),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              l10n.productionRoundNetNeed(fmtQty(item.netNeed)),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (item.isBlocked) ...[
          const SizedBox(height: 12),
          _BlockedBy(round: round, item: item),
        ],
        const SizedBox(height: 16),
        if (item.branches.isEmpty)
          Text(l10n.productionRoundNoBranchRows, style: muted)
        else
          _BranchTable(item: item),
      ],
    );
  }
}

class _BlockedBy extends StatelessWidget {
  const _BlockedBy({required this.round, required this.item});

  final ProductionRound round;
  final ProductionRoundItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = warningColor(theme);

    final lines = [
      for (final code in item.blockedBy)
        () {
          final material = round.materialFor(code);
          if (material == null || material.missing <= 0) {
            return isolateLtr(code);
          }
          return l10n.productionRoundMissingQty(
            isolateLtr(material.displayName),
            fmtMaterialQty(material.missing, material.uom),
          );
        }(),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productionRoundBlockedBy,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
                for (final line in lines)
                  Text(
                    line,
                    style: theme.textTheme.bodyMedium?.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Branch | Sells/wk | Target | Has | Needs — five narrow columns, so the
/// branch column takes the slack and every figure is one short token.
class _BranchTable extends StatelessWidget {
  const _BranchTable({required this.item});

  final ProductionRoundItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final head = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final cell = theme.textTheme.bodyMedium;

    Widget figure(String text, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: style ?? cell,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(l10n.productionRoundColBranch, style: head),
            ),
            Text(
              l10n.productionRoundColSells,
              style: head,
              textAlign: TextAlign.end,
            ),
            Text(
              l10n.productionRoundColTarget,
              style: head,
              textAlign: TextAlign.end,
            ),
            Text(
              l10n.productionRoundColHas,
              style: head,
              textAlign: TextAlign.end,
            ),
            Text(
              l10n.productionRoundColNeeds,
              style: head,
              textAlign: TextAlign.end,
            ),
          ],
        ),
        for (final branch in item.branches)
          TableRow(
            children: [
              _BranchCell(branch: branch),
              figure(fmtQty(branch.weeklySales, decimals: 1)),
              figure(fmtQty(branch.par, decimals: 0)),
              figure(
                fmtQty(branch.onHand, decimals: 1),
                style: branch.stockIsNegative
                    ? cell?.copyWith(color: theme.colorScheme.error)
                    : null,
              ),
              figure(
                fmtQty(branch.fill, decimals: 0),
                style: cell?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: branch.fill > 0 ? null : theme.colorScheme.outline,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BranchCell extends StatelessWidget {
  const _BranchCell({required this.branch});

  final ProductionRoundItemBranch branch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;

    final String? note;
    final Color? noteColor;
    if (branch.stockIsNegative) {
      note = l10n.productionRoundCountFirst;
      noteColor = theme.colorScheme.error;
    } else if (branch.daysOfCover == null) {
      note = l10n.productionRoundStatusNoSales;
      noteColor = theme.colorScheme.onSurfaceVariant;
    } else {
      note = l10n.productionRoundDaysLeft(
        fmtQty(branch.daysOfCover!, decimals: 1),
      );
      noteColor = branch.belowBackup
          ? theme.colorScheme.error
          : theme.colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.displayName,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            note,
            style: small?.copyWith(
              color: noteColor,
              fontWeight: branch.belowBackup || branch.stockIsNegative
                  ? FontWeight.w600
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
