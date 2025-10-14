import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final dateFormat = DateFormat('MMM d, yyyy');
    final amountFormat = NumberFormat.currency(symbol: expense.currency ?? '', decimalDigits: 2);

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
                expense.reasonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(amountFormat.format(expense.amount)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Pay from ${expense.paymentLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (expense.expenseDate != null)
                  Text(dateFormat.format(expense.expenseDate!)),
                const SizedBox(width: 8),
                _StatusChip(status: expense.status, color: statusColor),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          _InfoRow(label: 'Expense account', value: expense.reasonAccount),
          _InfoRow(label: 'Paying account', value: expense.payingAccount),
          if (expense.posProfile != null && expense.posProfile!.isNotEmpty)
            _InfoRow(label: 'POS Profile', value: expense.posProfile!),
          if (expense.remarks != null && expense.remarks!.isNotEmpty)
            _InfoRow(label: 'Remarks', value: expense.remarks!),
          if (expense.journalEntry != null && expense.journalEntry!.isNotEmpty)
            _InfoRow(label: 'Journal Entry', value: expense.journalEntry!),
          const SizedBox(height: 12),
          _Timeline(events: expense.timeline),
          if (expense.isPending && canApprove && onApprove != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve'),
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
            'No timeline available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
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
                            if (event.timestamp != null) dateFormat.format(event.timestamp!.toLocal()),
                            if (event.user != null && event.user!.isNotEmpty) 'by ${event.user}',
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
