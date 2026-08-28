import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/employee_advance_models.dart';

/// Mirrors `ExpenseCard`: Card > ExpansionTile, a status CircleAvatar, and
/// server-supplied labels resolved through the shared `label`/`label_en`/
/// `label_ar` helper.
///
/// The approve action is worded and confirmed as "approve & pay" throughout:
/// the backend submits the HRMS Employee Advance AND posts the Payment Entry in
/// the same call, so there is no reviewable middle state where the manager
/// could still change their mind.
class EmployeeAdvanceCard extends StatelessWidget {
  final EmployeeAdvance advance;

  /// Client role gate AND the bootstrap's `can_approve` flag, already ANDed by
  /// the caller. The server is still the authority; this only draws buttons.
  final bool canApprove;
  final bool isBusy;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onReject;

  const EmployeeAdvanceCard({
    super.key,
    required this.advance,
    required this.canApprove,
    this.isBusy = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final paymentLabel = advance.localizedPaymentLabel(languageCode);
    final statusColor = _statusColor(theme);
    final showActions =
        canApprove && advance.isPendingApproval && onApprove != null;

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
          child: Icon(_statusIcon(), color: statusColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                advance.employeeName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              formatCurrency(context, advance.amount,
                  currencyCode: advance.currency),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (paymentLabel.isNotEmpty)
              Text(
                '${l10n.expensesAdvancePayFromLabel}: $paymentLabel',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (advance.postingDate != null)
                  Text(formatDate(context, advance.postingDate!)),
                _StatusChip(
                  status: localizedAdvanceStatus(context, advance.status),
                  color: statusColor,
                ),
                if (advance.branch != null && advance.branch!.isNotEmpty)
                  Text(
                    advance.branch!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          _InfoRow(label: l10n.expensesAdvanceIdLabel, value: advance.name),
          if (advance.purpose != null && advance.purpose!.isNotEmpty)
            _InfoRow(
              label: l10n.expensesAdvancePurposeLabel,
              value: advance.purpose!,
            ),
          if (advance.branch != null && advance.branch!.isNotEmpty)
            _InfoRow(
              label: l10n.expensesAdvanceBranchLabel,
              value: advance.branch!,
            ),
          if (advance.payingAccount != null &&
              advance.payingAccount!.isNotEmpty)
            _InfoRow(
              label: l10n.expensesAdvancePayingAccountLabel,
              value: advance.payingAccount!,
            ),
          _InfoRow(
            label: l10n.expensesAdvancePaidLabel,
            value: formatCurrency(context, advance.paidAmount,
                currencyCode: advance.currency),
          ),
          if (advance.claimedAmount > 0)
            _InfoRow(
              label: l10n.expensesAdvanceClaimedLabel,
              value: formatCurrency(context, advance.claimedAmount,
                  currencyCode: advance.currency),
            ),
          if (advance.returnAmount > 0)
            _InfoRow(
              label: l10n.expensesAdvanceReturnedLabel,
              value: formatCurrency(context, advance.returnAmount,
                  currencyCode: advance.currency),
            ),
          _InfoRow(
            label: l10n.expensesAdvanceBalanceLabel,
            value: formatCurrency(context, advance.balance,
                currencyCode: advance.currency),
          ),
          if (advance.requestedByName != null || advance.requestedBy != null)
            _InfoRow(
              label: l10n.expensesAdvanceRequestedByLabel,
              value: advance.requestedByName ?? advance.requestedBy!,
            ),
          if (advance.approvedBy != null && advance.approvedBy!.isNotEmpty)
            _InfoRow(
              label: l10n.expensesAdvanceApprovedByLabel,
              value: advance.approvedBy!,
            ),
          if (advance.approvedOn != null)
            _InfoRow(
              label: l10n.expensesAdvanceApprovedOnLabel,
              value: formatDateTime(context, advance.approvedOn!.toLocal()),
            ),
          if (advance.paymentEntry != null && advance.paymentEntry!.isNotEmpty)
            _InfoRow(
              label: l10n.expensesAdvancePaymentEntryLabel,
              value: advance.paymentEntry!,
            ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l10n.expensesAdvanceReject),
                    onPressed:
                        isBusy || onReject == null ? null : () => onReject!(),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.expensesAdvanceApprove),
                    onPressed: isBusy ? null : () => onApprove!(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(ThemeData theme) {
    if (advance.isCancelled) return Colors.red;
    if (advance.isPendingApproval) return Colors.orange;
    if (advance.isPaid) return Colors.green;
    return theme.colorScheme.primary;
  }

  IconData _statusIcon() {
    if (advance.isCancelled) return Icons.cancel;
    if (advance.isPendingApproval) return Icons.hourglass_bottom;
    if (advance.isPaid) return Icons.verified;
    return Icons.account_balance_wallet_outlined;
  }
}

/// Maps the HRMS-derived status string onto a localized label.
///
/// `Draft` is rendered as "Awaiting approval" rather than "Draft": on this
/// screen a draft is not a scratch document, it is a request sitting in a
/// manager's queue. Unknown statuses fall through to the raw server string so a
/// new HRMS state shows up as itself instead of vanishing.
String localizedAdvanceStatus(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status) {
    case EmployeeAdvanceStatus.draft:
      return l10n.expensesAdvanceStatusDraft;
    case EmployeeAdvanceStatus.paid:
      return l10n.expensesAdvanceStatusPaid;
    case EmployeeAdvanceStatus.partiallyPaid:
      return l10n.expensesAdvanceStatusPartiallyPaid;
    case EmployeeAdvanceStatus.unpaid:
      return l10n.expensesAdvanceStatusUnpaid;
    case EmployeeAdvanceStatus.claimed:
      return l10n.expensesAdvanceStatusClaimed;
    case EmployeeAdvanceStatus.returned:
      return l10n.expensesAdvanceStatusReturned;
    case EmployeeAdvanceStatus.partlyClaimedAndReturned:
      return l10n.expensesAdvanceStatusPartlyClaimedAndReturned;
    case EmployeeAdvanceStatus.cancelled:
      return l10n.expensesAdvanceStatusCancelled;
    default:
      return status;
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
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
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
