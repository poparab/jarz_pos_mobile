import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/expense_models.dart';

class ExpenseFiltersBar extends StatelessWidget {
  final List<ExpensePaymentSource> paymentSources;
  final Set<String> activeFilters;
  final ValueChanged<String> onToggle;
  final VoidCallback? onClear;
  final String? clearLabel;

  const ExpenseFiltersBar({
    super.key,
    required this.paymentSources,
    required this.activeFilters,
    required this.onToggle,
    this.onClear,
    this.clearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (paymentSources.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.expensesFiltersEmpty),
            if (onClear != null)
              TextButton(
                onPressed: onClear,
                child: Text(clearLabel ?? l10n.expensesFiltersClear),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.expensesFiltersTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (onClear != null)
              TextButton(
                onPressed: onClear,
                child: Text(clearLabel ?? l10n.expensesFiltersClear),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final source in paymentSources)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(source.label),
                    avatar: Icon(_iconForCategory(source.category), size: 18),
                    selected: activeFilters.contains(source.id),
                    onSelected: (_) => onToggle(source.id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'cash':
        return Icons.payments;
      case 'bank':
        return Icons.account_balance;
      case 'mobile':
        return Icons.phone_android;
      case 'pos_profile':
        return Icons.storefront;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
