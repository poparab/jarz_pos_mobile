import 'package:flutter/material.dart';

import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../models/expense_models.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseRecord expense;
  final bool canApprove;
  final Future<void> Function()? onApprove;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.canApprove,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final reasonLabel = expense.localizedReasonLabel(languageCode);
    final paymentLabel = expense.localizedPaymentLabel(languageCode);
    final localizedStatus = _localizedStatus(context);

    final statusColor = _statusColor(expense, Theme.of(context));
    final statusIcon = _statusIcon(expense);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reasonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(formatCurrency(context, expense.amount, currencyCode: expense.currency)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${context.l10n.expensesPayFromLabel}: $paymentLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (expense.expenseDate != null)
                  Text(formatDate(context, expense.expenseDate!)),
                const SizedBox(width: 8),
                _StatusChip(status: localizedStatus, color: statusColor),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          _InfoRow(label: context.l10n.expensesReasonAccount, value: expense.reasonAccount),
          _InfoRow(label: context.l10n.expensesPayingAccount, value: expense.payingAccount),
          if (expense.posProfile != null && expense.posProfile!.isNotEmpty)
            _InfoRow(label: context.l10n.expensesPosProfile, value: expense.posProfile!),
          if (expense.remarks != null && expense.remarks!.isNotEmpty)
            _InfoRow(label: context.l10n.expensesRemarksLabel, value: expense.remarks!),
          if (expense.journalEntry != null && expense.journalEntry!.isNotEmpty)
            _InfoRow(label: context.l10n.expensesJournalEntry, value: expense.journalEntry!),
          const SizedBox(height: 12),
          _Timeline(events: expense.timeline),
          if (expense.isPending && canApprove && onApprove != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(context.l10n.expensesApprove),
                  onPressed: () => onApprove?.call(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(ExpenseRecord record, ThemeData theme) {
    if (record.isApproved) return Colors.green;
    if (record.isPending) return Colors.orange;
    if (record.docstatus == 2) return Colors.red;
    return theme.colorScheme.primary;
  }

  IconData _statusIcon(ExpenseRecord record) {
    if (record.isApproved) return Icons.verified;
    if (record.isPending) return Icons.hourglass_bottom;
    if (record.docstatus == 2) return Icons.cancel;
    return Icons.receipt_long;
  }

  String _localizedStatus(BuildContext context) {
    if (expense.isApproved) return context.l10n.expensesApprovedStatus;
    if (expense.isPending) return context.l10n.expensesPendingStatus;
    if (expense.docstatus == 0) return context.l10n.expensesDraftStatus;
    return localizedStatusLabel(context, expense.status);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<ExpenseTimelineEvent> events;

  const _Timeline({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Row(
        children: [
          Icon(Icons.history, color: Colors.grey.shade500, size: 18),
          const SizedBox(width: 6),
          Text(
            context.l10n.expensesTimelineEmpty,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.expensesTimelineTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        for (final event in events)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (event.timestamp != null || (event.user != null && event.user!.isNotEmpty))
                        Text(
                          [
                            if (event.timestamp != null) formatDateTime(context, event.timestamp!.toLocal()),
                            if (event.user != null && event.user!.isNotEmpty) context.l10n.commonByUser(event.user!),
                          ].join(' '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
