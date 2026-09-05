import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../reports/presentation/widgets/kpi_card.dart';
import '../../data/models/running_batch.dart';
import '../../state/running_batches_notifier.dart';
import 'production_format.dart';

/// What a batch actually cost, next to what it should have cost.
///
/// Every figure here is nullable on purpose. A batch that has produced nothing
/// has no per-unit cost, and a BOM with no costing has no standard — rendering
/// either as `0.00` invents a number that reads as real and quietly turns into a
/// 100% favourable variance. Where the server says "unknown", so does this.
class BatchCostPanel extends ConsumerWidget {
  const BatchCostPanel({super.key, required this.workOrder});

  final String workOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final costAsync = ref.watch(batchCostProvider(workOrder));

    return costAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.userErrorMessage(error, fallback: l10n.commonError),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(batchCostProvider(workOrder)),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
      data: (cost) => BatchCostView(cost: cost),
    );
  }
}

/// The rendered figures, split out from the fetch so it can be laid out — and
/// tested — without a provider container.
class BatchCostView extends StatelessWidget {
  const BatchCostView({super.key, required this.cost});

  final BatchCost cost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final currency = cost.currency.isEmpty ? null : cost.currency;
    final perUnit = cost.costPerUnit;
    final standard = cost.standardPerUnit;

    final cards = <Widget>[
      KpiCard(
        label: l10n.productionMaterialCost,
        value: formatCurrency(context, cost.materialCost,
            currencyCode: currency),
        icon: Icons.inventory_2_outlined,
        width: 150,
      ),
      if (perUnit != null)
        KpiCard(
          label: l10n.productionCostPerUnit,
          value: formatCurrency(context, perUnit, currencyCode: currency),
          icon: Icons.straighten,
          width: 150,
        ),
      if (cost.hasStandard)
        KpiCard(
          label: l10n.productionStandardCost,
          value: formatCurrency(context, standard!, currencyCode: currency),
          icon: Icons.rule,
          width: 150,
        ),
      if (cost.isComparable && cost.varianceAmount != null)
        KpiCard(
          label: l10n.productionVariance,
          value: formatCurrency(context, cost.varianceAmount!,
              currencyCode: currency),
          delta: _varianceLabel(context, cost),
          deltaColor: cost.isOverStandard ? scheme.error : scheme.tertiary,
          color: cost.isOverStandard ? scheme.error : scheme.tertiary,
          icon: cost.isOverStandard
              ? Icons.trending_up
              : Icons.trending_down,
          width: 150,
        ),
    ];

    // One honest sentence beats three cards of zeroes: says which half of the
    // comparison is missing rather than implying the batch cost nothing.
    final unavailable = perUnit == null || !cost.hasStandard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productionCostTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: cards),
        if (unavailable) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.productionCostUnavailable,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String? _varianceLabel(BuildContext context, BatchCost cost) {
    final pct = cost.variancePct;
    if (pct == null) return null;
    final l10n = context.l10n;
    final magnitude = trimQty(pct.abs(), decimals: 1);
    return cost.isOverStandard
        ? l10n.productionVarianceOver(magnitude)
        : l10n.productionVarianceUnder(magnitude);
  }
}
