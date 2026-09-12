import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/monthly_expense_models.dart';

/// The `gaps` list, rendered above the money.
///
/// These are the reasons the figures below might be wrong — an employee with no
/// salary structure, an item that looks overpaid, salary GL nobody can claim,
/// an empty registry. They go at the TOP on purpose: a caveat printed under the
/// total is a caveat nobody reads before acting on the total.
class MonthlyExpenseGapsBanner extends StatelessWidget {
  final List<MonthlyExpenseGap> gaps;

  const MonthlyExpenseGapsBanner({super.key, required this.gaps});

  @override
  Widget build(BuildContext context) {
    if (gaps.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // A month whose only gaps are INFO is not a month with a problem. Those
    // entries are standing facts — "no order has ever been rung up as a staff
    // order", so the jar-debt column is legitimately zero — and painting them
    // in the error colour every month is how a banner stops being read.
    final onlyInfo = gaps.every((gap) => gap.isInfo);

    return Card(
      elevation: 0,
      color: onlyInfo
          ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.45)
          : theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  onlyInfo
                      ? Icons.lightbulb_outline
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: onlyInfo
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  onlyInfo
                      ? l10n.monthlyExpensesGapsInfoTitle
                      : l10n.monthlyExpensesGapsTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final gap in gaps)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      gap.isCritical
                          ? Icons.report_gmailerrorred
                          : Icons.info_outline,
                      size: 16,
                      color: gap.isCritical
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(gap.message, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
