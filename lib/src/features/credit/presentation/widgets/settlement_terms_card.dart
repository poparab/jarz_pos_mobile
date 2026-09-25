import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/settlement_models.dart';
import '../settlement_labels.dart';

/// "Payment terms" on a shop's credit account: when the shop settles, what
/// is due, and whether it is late.
///
/// A reminder surface, never a gate: the state chip is the only alarm colour
/// on the credit screens, and it only turns red when the shop's OWN agreed
/// schedule has passed — an old invoice alone is not "overdue" here.
class SettlementTermsCard extends StatelessWidget {
  final SettlementTermsResponse data;

  /// Opens the edit sheet. Ignored unless the server said `can_edit`.
  final VoidCallback? onEdit;

  const SettlementTermsCard({super.key, required this.data, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final terms = data.terms;
    final status = data.status;
    final currency = data.currency;
    final hasTerms = data.hasTerms;
    final canEdit = data.canEdit && onEdit != null;

    // A shop with no terms still has a state worth showing when it owes
    // money: nobody has agreed when it pays.
    final chipState = hasTerms
        ? status.state
        : (status.openBalance > 0.005 ? SettlementState.unscheduled : '');

    String money(double amount) =>
        formatCurrency(context, amount, currencyCode: currency);

    final rows = <(String, String)>[
      if (hasTerms && status.hasNextDue)
        (
          l10n.settlementNextDueLabel,
          formatDateString(context, status.nextDueDate),
        ),
      if (hasTerms && status.hasNextDue && status.nextDueAmount > 0.005)
        (l10n.settlementNextDueAmountLabel, money(status.nextDueAmount)),
      if (hasTerms && status.dueNowAmount > 0.005)
        (l10n.settlementDueNowLabel, money(status.dueNowAmount)),
      if (hasTerms && status.overdueAmount > 0.005)
        (l10n.settlementOverdueAmountLabel, money(status.overdueAmount)),
      if (hasTerms &&
          status.overdueAmount > 0.005 &&
          status.oldestOverdueDate.isNotEmpty)
        (
          l10n.settlementOverdueSinceLabel,
          formatDateString(context, status.oldestOverdueDate),
        ),
      if (hasTerms && (status.collectOnNextDelivery ?? 0) > 0.005)
        (
          l10n.settlementCollectNextDeliveryLabel,
          money(status.collectOnNextDelivery!),
        ),
      if (hasTerms)
        (
          l10n.settlementRemindsLabel,
          terms!.responsibleUser.isNotEmpty
              ? terms.responsibleUser
              : l10n.settlementRemindsAllManagers,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note_outlined, size: 20, color: muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.settlementTermsTitle,
                    style: theme.textTheme.labelLarge?.copyWith(color: muted),
                  ),
                ),
                if (chipState.isNotEmpty) SettlementStateChip(state: chipState),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasTerms)
              Text(l10n.settlementTermsNotSet, style: theme.textTheme.bodyMedium)
            else ...[
              Text(
                settlementDescription(l10n, terms, fallback: data.description),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!terms!.enabled)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    l10n.settlementTermsPaused,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              if (rows.isNotEmpty) const SizedBox(height: 8),
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style:
                              theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          value,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (terms.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.settlementNotesLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                Text(terms.notes, style: theme.textTheme.bodyMedium),
              ],
            ],
            if (canEdit)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  icon: Icon(
                    hasTerms ? Icons.edit_outlined : Icons.add,
                    size: 18,
                  ),
                  label: Text(
                    hasTerms
                        ? l10n.settlementTermsEditAction
                        : l10n.settlementTermsSetAction,
                  ),
                  onPressed: onEdit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The coloured state pill, shared by the terms card and the Collections list.
class SettlementStateChip extends StatelessWidget {
  final String state;
  const SettlementStateChip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = settlementStateColor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(settlementStateIcon(state), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            settlementStateLabel(context.l10n, state),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
