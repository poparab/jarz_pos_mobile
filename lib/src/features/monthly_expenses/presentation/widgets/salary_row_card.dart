import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/monthly_expense_models.dart';
import 'monthly_expense_payment_list.dart';
import 'monthly_expense_status_chip.dart';

/// One employee's salary for the month.
///
/// Deliberately the same shape as [RecurringExpenseCard] minus the manage menu:
/// a salary is not a registry entry, so there is nothing here to edit, pause or
/// end — that lives in HR.
class SalaryRowCard extends StatelessWidget {
  final SalaryRow row;
  final String currency;
  final bool isBusy;

  final VoidCallback? onPay;
  final void Function(MonthlyExpensePayment payment)? onCancelPayment;

  const SalaryRowCard({
    super.key,
    required this.row,
    required this.currency,
    this.isBusy = false,
    this.onPay,
    this.onCancelPayment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String money(double value) =>
        formatCurrency(context, value, currencyCode: currency);

    final statusColor = monthlyExpenseStatusColor(context, row.paymentStatus);
    final payable = row.canPay && !isBusy && onPay != null;
    final subtitleParts = [
      if ((row.designation ?? '').isNotEmpty) row.designation!,
      if ((row.department ?? '').isNotEmpty) row.department!,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(Icons.badge_outlined, color: statusColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                row.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              money(row.dueAmount),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitleParts.isNotEmpty)
                Text(
                  subtitleParts.join(' • '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  MonthlyExpenseStatusChip(status: row.paymentStatus),
                  if (row.hasSalarySlip)
                    MonthlyExpenseStatusChip(
                      status: row.paymentStatus,
                      overrideLabel: l10n.monthlyExpensesSalarySlipBadge,
                      overrideColor: Colors.teal,
                      icon: Icons.description_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 20,
                runSpacing: 6,
                children: [
                  _cell(context, l10n.monthlyExpensesDue, money(row.dueAmount)),
                  _cell(context, l10n.monthlyExpensesPaid, money(row.paidAmount)),
                  _cell(
                    context,
                    l10n.monthlyExpensesRemaining,
                    money(row.remaining),
                    emphasise: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          if (row.hasSalarySlip)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.monthlyExpensesSalarySlipExists,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.teal.shade700),
                    ),
                  ),
                ],
              ),
            ),
          _InfoRow(
            label: l10n.monthlyExpensesSalaryBaseLabel,
            value: money(row.base),
          ),
          if (row.variable.abs() > 0.005)
            _InfoRow(
              label: l10n.monthlyExpensesSalaryVariableLabel,
              value: money(row.variable),
            ),
          const SizedBox(height: 12),
          MonthlyExpensePaymentList(
            payments: row.payments,
            currency: currency,
            onCancel: (isBusy || onCancelPayment == null)
                ? null
                : (payment) => onCancelPayment!(payment),
          ),
          if (row.canPay) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(l10n.monthlyExpensesPayAction),
                onPressed: payable ? onPay : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String label,
    String value, {
    bool emphasise = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: emphasise ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
