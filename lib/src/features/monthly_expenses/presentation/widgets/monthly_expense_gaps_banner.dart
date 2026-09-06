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

    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  l10n.monthlyExpensesGapsTitle,
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
