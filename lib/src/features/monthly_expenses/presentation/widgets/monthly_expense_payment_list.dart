import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/monthly_expense_models.dart';

/// The `payments` array for one item, with a cancel action per payment.
///
/// Shared by the recurring cards and the salary rows: both pay through the same
/// `Jarz Expense Request` and both reverse through `cancel_expense_payment`, so
/// showing the history two different ways would be a difference with no cause.
class MonthlyExpensePaymentList extends StatelessWidget {
  final List<MonthlyExpensePayment> payments;
  final String currency;

  /// Null hides the cancel affordance — a read-only viewer, or a screen busy
  /// with another mutation.
  final void Function(MonthlyExpensePayment payment)? onCancel;

  const MonthlyExpensePaymentList({
    super.key,
    required this.payments,
    required this.currency,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (payments.isEmpty) {
      return Row(
        children: [
          Icon(Icons.history, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.monthlyExpensesPaymentsEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.monthlyExpensesPaymentsTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        for (final payment in payments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.payments_outlined,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCurrency(context, payment.amount,
                            currencyCode: currency),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        [
                          if (payment.date != null)
                            formatDate(context, payment.date!),
                          if (payment.sourceLabel.isNotEmpty)
                            payment.sourceLabel,
                          if ((payment.by ?? '').isNotEmpty)
                            l10n.commonByUser(payment.by!),
                        ].join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if ((payment.remarks ?? '').isNotEmpty)
                        Text(
                          payment.remarks!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      // The journal entry is the audit trail: without it a
                      // manager cannot find in Desk the posting this row is
                      // talking about.
                      if ((payment.journalEntry ?? '').isNotEmpty)
                        Text(
                          payment.journalEntry!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onCancel != null)
                  IconButton(
                    tooltip: l10n.monthlyExpensesPaymentCancelAction,
                    icon: const Icon(Icons.undo, size: 18),
                    color: theme.colorScheme.error,
                    onPressed: () => onCancel!(payment),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
