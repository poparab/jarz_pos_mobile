import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_models.dart';

class ExpensesSummaryHeader extends StatelessWidget {
  final ExpenseSummary summary;
  final bool isManager;

  const ExpensesSummaryHeader({super.key, required this.summary, required this.isManager});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final cards = <_SummaryInfo>[
      _SummaryInfo(
        title: 'Total',
        value: numberFormat.format(summary.totalAmount),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.blue.shade50,
        accent: Colors.blue,
      ),
      _SummaryInfo(
        title: 'Approved',
        value: '${summary.approvedCount} receipts',
        icon: Icons.verified_outlined,
        color: Colors.green.shade50,
        accent: Colors.green,
      ),
    ];

    if (isManager || summary.pendingCount > 0) {
      cards.add(
        _SummaryInfo(
          title: 'Pending',
          value: '${summary.pendingCount} | ${numberFormat.format(summary.pendingAmount)}',
          icon: Icons.hourglass_bottom,
          color: Colors.orange.shade50,
          accent: Colors.orange,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 560;
        final gridDelegate = isWide
            ? const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.2,
              )
            : const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.2,
              );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: gridDelegate,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _SummaryTile(info: card);
          },
        );
      },
    );
  }
}

class _SummaryInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color accent;

  _SummaryInfo({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.accent,
  });
}

class _SummaryTile extends StatelessWidget {
  final _SummaryInfo info;

  const _SummaryTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: info.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: info.accent.withOpacity(0.15),
              child: Icon(info.icon, color: info.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: info.accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
