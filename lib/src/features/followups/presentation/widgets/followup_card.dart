import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/followup_whatsapp.dart';
import '../../data/models/followup_models.dart';

/// Arabic-first label for a reorder-plan step (`3h` → "بعد ٣ ساعات",
/// `day7` → "اليوم ٧"); the raw step when it is not one we know.
String followupStepLabel(BuildContext context, FollowupRow row) {
  final l10n = context.l10n;
  if (row.step.toLowerCase() == '3h') return l10n.followupsStep3h;
  final day = row.stepDay;
  if (day != null) return l10n.followupsStepDay(formatCount(context, day));
  return row.step;
}

/// One due touch: who, which step, why it matters, and what to do.
class FollowupCard extends StatelessWidget {
  const FollowupCard({
    super.key,
    required this.row,
    required this.onWhatsapp,
    required this.onCopy,
    required this.onCall,
    required this.onLog,
    required this.onSkip,
    this.busy = false,
  });

  final FollowupRow row;
  final VoidCallback onWhatsapp;
  final VoidCallback onCopy;
  final VoidCallback onCall;
  final VoidCallback onLog;
  final VoidCallback onSkip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasWhatsapp = followupMsisdn(row).isNotEmpty;
    final hasPhone = followupTelUri(row.phone) != null;
    final dueAt = row.dueAt;
    final dueText = dueAt == null
        ? null
        : DateFormat(
            row.isOverdue ? 'd MMM h:mm a' : 'h:mm a',
            l10n.localeName,
          ).format(dueAt);

    final chips = <Widget>[
      _InfoChip(
        icon: row.isCall ? Icons.call_outlined : Icons.chat_outlined,
        label: row.isCall
            ? l10n.followupsChannelCall
            : l10n.followupsChannelMessage,
        color: row.isCall ? Colors.indigo : Colors.green.shade700,
      ),
      if (row.isNew || row.isRepeat)
        _InfoChip(
          label: row.isRepeat
              ? l10n.followupsCustomerRepeat
              : l10n.followupsCustomerNew,
          color: row.isRepeat ? Colors.teal : Colors.blue,
        ),
      if (row.valueBand.isNotEmpty)
        _InfoChip(
          label: row.isHighValue
              ? l10n.followupsValueHigh
              : l10n.followupsValueLow,
          color: row.isHighValue ? Colors.amber.shade800 : Colors.blueGrey,
        ),
      if (row.customerSegment != null)
        _InfoChip(
          label: localizedCustomerSegment(context, row.customerSegment),
          color: Colors.purple,
        ),
      if (row.rfmIsRegular)
        _InfoChip(
          icon: Icons.verified_outlined,
          label: l10n.followupsRegular,
          color: Colors.deepPurple,
        ),
    ];

    final details = <String>[
      if (row.orderValue > 0) formatCurrency(context, row.orderValue),
      if (row.wooOrderId > 0) l10n.followupsWooOrder(row.wooOrderId.toString()),
      if (row.lifetimeOrders > 0)
        l10n.followupsLifetimeOrders(formatCount(context, row.lifetimeOrders)),
      if (row.territory.trim().isNotEmpty) row.territory.trim(),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: row.isOverdue
            ? BorderSide(color: scheme.error.withValues(alpha: 0.6))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.displayName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          followupStepLabel(context, row),
                          if (dueText != null) l10n.followupsDueAt(dueText),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: row.isOverdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !busy,
                  onSelected: (v) {
                    if (v == 'skip') onSkip();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'skip',
                      child: Text(l10n.followupsActionSkip),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                details.join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (!row.isCall || hasWhatsapp)
                  TextButton.icon(
                    onPressed: hasWhatsapp && !busy ? onWhatsapp : null,
                    icon: const Icon(Icons.chat, size: 18),
                    label: Text(
                      hasWhatsapp
                          ? l10n.followupsActionWhatsapp
                          : l10n.followupsNoWhatsapp,
                    ),
                  ),
                if (row.messageText.trim().isNotEmpty)
                  IconButton(
                    tooltip: l10n.followupsActionCopy,
                    onPressed: busy ? null : onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                  ),
                IconButton(
                  tooltip:
                      hasPhone ? l10n.followupsActionCall : l10n.followupsNoPhone,
                  onPressed: hasPhone && !busy ? onCall : null,
                  icon: const Icon(Icons.call, size: 18),
                ),
                FilledButton.tonalIcon(
                  onPressed: busy ? null : onLog,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.task_alt, size: 18),
                  label: Text(l10n.followupsActionLog),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
