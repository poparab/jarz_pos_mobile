import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/woo_sync_dashboard.dart';

/// Backlog depth as a row of stat chips — the summary a console shows before
/// any detail, per the house convention for an operations screen.
class WooBacklogSummary extends StatelessWidget {
  final WooSyncBacklog backlog;

  const WooBacklogSummary({super.key, required this.backlog});

  String? _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('yyyy-MM-dd HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final oldest = _formatTime(backlog.oldestDue);

    Widget stat(String label, int value, {Color? color, bool alert = false}) {
      final c = color ?? (alert && value > 0 ? Colors.deepOrange.shade700 : Colors.grey.shade800);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: alert && value > 0 ? Colors.deepOrange.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
            Text(label, style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.wooSyncBacklogTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            stat(l10n.wooSyncBacklogPending, backlog.pending),
            stat(l10n.wooSyncBacklogRetryScheduled, backlog.retryScheduled),
            stat(l10n.wooSyncBacklogProcessing, backlog.processing),
            stat(l10n.wooSyncBacklogNeedsAttention, backlog.needsAttention, alert: true),
            stat(l10n.wooSyncBacklogDueNow, backlog.dueNow, alert: true),
            stat(l10n.wooSyncBacklogExpiredProcessing, backlog.expiredProcessing, alert: true),
          ],
        ),
        if (oldest != null) ...[
          const SizedBox(height: 6),
          Text(l10n.wooSyncBacklogOldestDue(oldest), style: TextStyle(color: Colors.grey.shade700)),
        ],
      ],
    );
  }
}
