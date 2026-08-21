import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/label_models.dart';
import 'label_status_chip.dart';

/// One customer's block on the board: a header carrying the customer's
/// worst-status stripe, then one row per flavour label underneath.
///
/// The board is triaged by customer because that is how printing is decided —
/// "does Cafe X need anything printed" — while each flavour keeps its own
/// numbers, because every flavour has its own artwork and its own ledger.
class LabelCustomerCard extends StatelessWidget {
  final LabelCustomerGroup group;
  final void Function(CustomerLabel label) onOpen;
  final void Function(CustomerLabel label)? onPrint;
  final VoidCallback? onAddFlavour;

  const LabelCustomerCard({
    super.key,
    required this.group,
    required this.onOpen,
    this.onPrint,
    this.onAddFlavour,
  });

  @override
  Widget build(BuildContext context) {
    final style = LabelStatusStyle.of(context, group.worstStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: style.color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CustomerHeader(group: group, onAddFlavour: onAddFlavour),
                  for (final label in group.labels) ...[
                    const Divider(height: 1),
                    LabelFlavourRow(
                      label: label,
                      onTap: () => onOpen(label),
                      onPrint: onPrint == null ? null : () => onPrint!(label),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  final LabelCustomerGroup group;
  final VoidCallback? onAddFlavour;

  const _CustomerHeader({required this.group, this.onAddFlavour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final attention = group.needsAttentionCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.customerName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.labelCardFlavours(group.labels.length) +
                      (attention > 0
                          ? l10n.labelCardNeedPrintingSuffix(attention)
                          : ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: attention > 0
                        ? const Color(0xFFB3261E)
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: attention > 0 ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          if (onAddFlavour != null)
            PopupMenuButton<String>(
              tooltip: l10n.labelCardCustomerActions,
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'add') onAddFlavour!();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'add',
                  child: Text(l10n.labelCardAddFlavour),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One flavour label inside a customer block: name, size, the two numbers a
/// planner acts on, and the status.
class LabelFlavourRow extends StatelessWidget {
  final CustomerLabel label;
  final VoidCallback onTap;
  final VoidCallback? onPrint;

  const LabelFlavourRow({
    super.key,
    required this.label,
    required this.onTap,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = LabelStatusStyle.of(context, label.status,
        leadDaysMax: label.leadDaysMax);
    final dateFormat = DateFormat('d MMM', l10n.localeName);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          label.labelTitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (label.size != null) ...[
                        const SizedBox(width: 6),
                        LabelSizeChip(size: label.size!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                LabelStatusChip(
                  status: label.status,
                  leadDaysMax: label.leadDaysMax,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Metric(
                  value: label.tracked
                      ? '${label.onHandQty}'
                      : l10n.labelCardCoverNone,
                  unit: l10n.labelCardOnHand,
                  emphasis: true,
                  color: style.color,
                ),
                const SizedBox(width: 18),
                _Metric(
                  value: _coverText(context, label),
                  unit: l10n.labelCardOfCover,
                ),
                const Spacer(),
                if (onPrint != null && label.needsAttention)
                  FilledButton.tonalIcon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.local_printshop, size: 16),
                    label: Text(
                      label.suggestedPrintSheets > 0
                          ? l10n.labelCardOrderSheets(label.suggestedPrintSheets)
                          : l10n.labelCardOrderBatch,
                    ),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            _Footnote(label: label, dateFormat: dateFormat),
          ],
        ),
      ),
    );
  }

  String _coverText(BuildContext context, CustomerLabel label) {
    final l10n = context.l10n;
    if (!label.tracked) return l10n.labelCardCoverNone;
    final cover = label.daysOfCover;
    if (cover == null) return l10n.labelCardCoverNone;
    if (cover >= 100) return l10n.labelCardCoverOver99;
    return l10n.labelCardCoverDays(
      cover.toStringAsFixed(cover >= 10 ? 0 : 1),
    );
  }
}

/// Small pill naming the jar size (which is what decides the sheet layout).
class LabelSizeChip extends StatelessWidget {
  final String size;

  const LabelSizeChip({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        size,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String unit;
  final bool emphasis;
  final Color? color;

  const _Metric({
    required this.value,
    required this.unit,
    this.emphasis = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: (emphasis
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasis ? color : theme.colorScheme.onSurface,
            height: 1.05,
          ),
        ),
        Text(
          unit,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The one-line "so what" under the numbers: when it runs out, or when the
/// batch already at the printer is due back.
class _Footnote extends StatelessWidget {
  final CustomerLabel label;
  final DateFormat dateFormat;

  const _Footnote({required this.label, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    if (!label.tracked) {
      return Text(l10n.labelCardCustomerSupplies, style: muted);
    }

    final arrival = label.nextArrival;
    if (arrival != null) {
      final due = arrival.expectedReadyDate;
      final overdue = arrival.isOverdue;
      final what = arrival.qtySheets > 0
          ? l10n.labelCardSheetsCount(arrival.qtySheets)
          : l10n.labelCardLabelsCount(arrival.qty);
      return Row(
        children: [
          Icon(
            overdue ? Icons.warning_amber : Icons.local_shipping,
            size: 14,
            color: overdue
                ? const Color(0xFFE65100)
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              due == null
                  ? l10n.labelCardAtPrinter(what)
                  : overdue
                      ? l10n.labelCardOverdueSince(
                          what, dateFormat.format(due))
                      : l10n.labelCardDueBack(what, dateFormat.format(due)),
              style: muted?.copyWith(
                color: overdue ? const Color(0xFFE65100) : null,
                fontWeight: overdue ? FontWeight.w600 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final runsOut = label.runsOutOn;
    if (runsOut != null) {
      return Text(
        l10n.labelCardRunsOutAround(dateFormat.format(runsOut)),
        style: muted,
      );
    }
    if (label.avgDailyUsage <= 0) {
      return Text(l10n.labelCardNoUsage, style: muted);
    }
    return Text(
      l10n.labelCardOrderAhead(label.leadDaysMax),
      style: muted,
    );
  }
}
