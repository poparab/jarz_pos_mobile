import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/label_models.dart';
import 'label_status_chip.dart';

/// One customer's label design on the board.
///
/// The card leads with the two numbers a planner acts on — how many are left and
/// how many days that buys — and only then explains itself. The urgency stripe
/// down the left edge means the list can be triaged without reading any of it.
class LabelCard extends StatelessWidget {
  final CustomerLabel label;
  final VoidCallback onTap;
  final VoidCallback? onPrint;

  const LabelCard({
    super.key,
    required this.label,
    required this.onTap,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = LabelStatusStyle.of(label.status, leadDaysMax: label.leadDaysMax);
    final dateFormat = DateFormat('d MMM');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: style.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label.customerName,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      if (label.labelTitle != 'Default')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            label.labelTitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Metric(
                            value: label.tracked ? '${label.onHandQty}' : '—',
                            unit: 'labels left',
                            emphasis: true,
                            color: style.color,
                          ),
                          const SizedBox(width: 18),
                          _Metric(
                            value: _coverText(label),
                            unit: 'of cover',
                          ),
                          const SizedBox(width: 18),
                          _Metric(
                            value: label.avgDailyUsage > 0
                                ? label.avgDailyUsage.toStringAsFixed(
                                    label.avgDailyUsage >= 10 ? 0 : 1)
                                : '—',
                            unit: 'per day',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _Footnote(label: label, dateFormat: dateFormat),
                      if (onPrint != null && label.needsAttention) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: FilledButton.tonalIcon(
                            onPressed: onPrint,
                            icon: const Icon(Icons.local_printshop, size: 18),
                            label: Text(
                              label.suggestedPrintQty > 0
                                  ? 'Order ${label.suggestedPrintQty}'
                                  : 'Order a batch',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _coverText(CustomerLabel label) {
    if (!label.tracked) return '—';
    final cover = label.daysOfCover;
    if (cover == null) return '—';
    if (cover >= 100) return '99+ d';
    return '${cover.toStringAsFixed(cover >= 10 ? 0 : 1)} d';
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
                  ? theme.textTheme.headlineSmall
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
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    if (!label.tracked) {
      return Text('Customer supplies their own labels', style: muted);
    }

    final arrival = label.nextArrival;
    if (arrival != null) {
      final due = arrival.expectedReadyDate;
      final overdue = arrival.isOverdue;
      return Row(
        children: [
          Icon(
            overdue ? Icons.warning_amber : Icons.local_shipping,
            size: 14,
            color: overdue ? const Color(0xFFE65100) : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              due == null
                  ? '${arrival.qty} at the printer'
                  : overdue
                      ? '${arrival.qty} overdue at the printer since ${dateFormat.format(due)}'
                      : '${arrival.qty} due back ${dateFormat.format(due)}',
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
      return Text('Runs out around ${dateFormat.format(runsOut)}', style: muted);
    }
    if (label.avgDailyUsage <= 0) {
      return Text('No usage recorded yet', style: muted);
    }
    return Text('Order ${label.leadDaysMax} working days ahead', style: muted);
  }
}
