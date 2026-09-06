import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/monthly_expense_models.dart';

/// Due / Paid / **Remaining** for the selected month, plus the run-rate.
///
/// Remaining is the headline and is deliberately given the whole top row at
/// display size: the question this screen exists to answer is "what do we still
/// owe this month", and Due and Paid are only the working that produces it.
class MonthlyExpensesSummaryHeader extends StatelessWidget {
  final MonthlyExpenseSummary summary;
  final String currency;

  const MonthlyExpensesSummaryHeader({
    super.key,
    required this.summary,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String money(double value) =>
        formatCurrency(context, value, currencyCode: currency);

    // Green only when nothing is left; while anything is outstanding the number
    // is the alarming colour, because it is the outstanding one.
    final remainingColor =
        summary.remaining > 0.005 ? Colors.red.shade700 : Colors.green.shade700;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyExpensesRemaining,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              money(summary.remaining),
              key: const ValueKey('monthlyExpensesRemainingValue'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: remainingColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.monthlyExpensesRemainingCaption(
                money(summary.paid),
                money(summary.due),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (summary.overpaid > 0.005) ...[
              const SizedBox(height: 6),
              Text(
                l10n.monthlyExpensesOverpaidNotice(money(summary.overpaid)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Divider(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Figure(label: l10n.monthlyExpensesDue, value: money(summary.due)),
                _Figure(label: l10n.monthlyExpensesPaid, value: money(summary.paid)),
                _Figure(
                  label: l10n.monthlyExpensesRunRate,
                  value: money(summary.runRate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.monthlyExpensesItemsTotal(summary.itemsTotal),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.monthlyExpensesItemsBreakdown(
                summary.itemsPaid,
                summary.itemsPartial,
                summary.itemsUnpaid,
              ),
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

class _Figure extends StatelessWidget {
  final String label;
  final String value;

  const _Figure({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
