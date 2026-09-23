import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_round.dart';
import 'production_round_format.dart';
import 'production_round_item_sheet.dart';
import 'production_round_tab_scaffold.dart';

/// What to make, one section per size. Rows that need nothing are folded into
/// a collapsed "Covered" group so the list reads as a to-do, not a catalogue.
class ProductionRoundMakeTab extends StatelessWidget {
  const ProductionRoundMakeTab({
    super.key,
    required this.round,
    required this.onRefresh,
  });

  final ProductionRound round;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (round.items.isEmpty) {
      return RefreshableMessage(
        onRefresh: onRefresh,
        icon: Icons.check_circle_outline,
        title: l10n.productionRoundEmptyTitle,
        detail: l10n.productionRoundNoItems,
      );
    }

    final sizes = round.sizes;
    final unsized = round.items.where((i) => i.size.trim().isEmpty).toList();

    return RefreshableList(
      onRefresh: onRefresh,
      children: [
        if (round.summary.itemsToMake == 0 &&
            !round.items.any((i) => i.isToMake))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.productionRoundEmptyBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        for (final size in sizes)
          _SizeSection(
            round: round,
            title: sizeLabel(l10n, size),
            items: round.itemsOfSize(size),
            batches: round.summary.batches[size],
          ),
        if (unsized.isNotEmpty)
          _SizeSection(round: round, title: '—', items: unsized),
      ],
    );
  }
}

class _SizeSection extends StatelessWidget {
  const _SizeSection({
    required this.round,
    required this.title,
    required this.items,
    this.batches,
  });

  final ProductionRound round;
  final String title;
  final List<ProductionRoundItem> items;
  final double? batches;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final toMake = items.where((i) => i.isToMake).toList()..sort(_byUrgency);
    final covered = items.where((i) => !i.isToMake).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (batches != null && batches! > 0)
                  Text(
                    batchesLabel(l10n, batches!),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (toMake.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      l10n.productionRoundNothingInSize,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                for (var i = 0; i < toMake.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ItemRow(round: round, item: toMake[i]),
                ],
                if (covered.isNotEmpty) ...[
                  const Divider(height: 1),
                  Theme(
                    // ExpansionTile draws its own dividers when open; inside a
                    // card they double up with the row separators.
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey('covered-$title'),
                      dense: true,
                      title: Text(
                        l10n.productionRoundCoveredGroup(covered.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      children: [
                        for (final item in covered)
                          _ItemRow(round: round, item: item),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _byUrgency(ProductionRoundItem a, ProductionRoundItem b) {
    final aNow = a.status == ProductionRoundStatus.now ? 0 : 1;
    final bNow = b.status == ProductionRoundStatus.now ? 0 : 1;
    if (aNow != bNow) return aNow - bNow;
    return b.batches.compareTo(a.batches);
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.round, required this.item});

  final ProductionRound round;
  final ProductionRoundItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => showProductionRoundItemSheet(context, round, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            StatusDot(status: item.status),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.displayName,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.isBlocked)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Tooltip(
                  message: l10n.productionRoundBlockedTooltip,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: warningColor(theme),
                  ),
                ),
              ),
            if (item.isToMake)
              // Capped and scaled down rather than flexed: the pill keeps its
              // natural size on a normal row, and only a long Arabic label at
              // 360 dp shrinks instead of pushing the row off the edge.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: _Pill(
                    text:
                        '${batchesLabel(l10n, item.batches)} · ${jarsLabel(l10n, item.jars)}',
                  ),
                ),
              )
            else
              Text(
                item.status == ProductionRoundStatus.noSales
                    ? l10n.productionRoundStatusNoSales
                    : l10n.productionRoundStatusCovered,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The row's urgency, as a colour: needed now, this round, or nothing to do.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status});

  final ProductionRoundStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      ProductionRoundStatus.now => (
        scheme.error,
        l10n.productionRoundStatusNow,
      ),
      ProductionRoundStatus.round => (
        scheme.primary,
        l10n.productionRoundStatusRound,
      ),
      ProductionRoundStatus.covered => (
        scheme.outline,
        l10n.productionRoundStatusCovered,
      ),
      ProductionRoundStatus.noSales => (
        scheme.outlineVariant,
        l10n.productionRoundStatusNoSales,
      ),
    };
    return Semantics(
      label: label,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
