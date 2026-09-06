import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/woo_sync_event.dart';
import 'woo_sync_labels.dart';

/// One row in the sync-event list. State is encoded in form (a coloured
/// status stripe + tinted background when attention is needed) as well as in
/// text, so scanning the list is enough to see what needs attention without
/// reading every status label.
class WooSyncEventTile extends StatelessWidget {
  final WooSyncEvent event;
  final bool selected;
  final bool busy;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onRetry;
  final VoidCallback onProcessNow;
  final VoidCallback onSetReviewState;
  final VoidCallback? onPushInvoice;

  const WooSyncEventTile({
    super.key,
    required this.event,
    required this.selected,
    required this.busy,
    required this.onSelectedChanged,
    required this.onRetry,
    required this.onProcessNow,
    required this.onSetReviewState,
    this.onPushInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = wooSyncStatusColor(event.status);
    final needsAttention = event.needsAttention;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        color: needsAttention ? Colors.red.shade50 : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: statusColor, width: 5)),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Opacity(
        opacity: busy ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(value: selected, onChanged: busy ? null : onSelectedChanged),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        _chip(wooSyncStatusLabel(context, event.status), statusColor),
                        _chip(wooSyncDirectionLabel(context, event.direction), Colors.blueGrey),
                        if (event.reviewState != null && event.reviewState!.isNotEmpty)
                          _chip(
                            wooSyncReviewStateLabel(context, event.reviewState),
                            wooSyncReviewStateColor(event.reviewState),
                          ),
                      ],
                    ),
                  ),
                  if (busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventType,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    Text(
                      l10n.wooSyncEventAttempt(event.attemptCount, event.maxAttempts),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    if (event.hasLocalInvoice)
                      Text(
                        l10n.wooSyncEventLocalInvoiceLabel(event.localDocname!),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    if ((event.manualReviewReason ?? '').isNotEmpty)
                      Text(
                        l10n.wooSyncEventReviewReason(event.manualReviewReason!),
                        style: TextStyle(color: Colors.deepOrange.shade700, fontSize: 12),
                      ),
                    if ((event.lastError ?? '').isNotEmpty)
                      Text(
                        l10n.wooSyncEventLastError(event.lastError!),
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (event.isRetryable)
                      TextButton.icon(
                        onPressed: busy ? null : onRetry,
                        icon: const Icon(Icons.replay, size: 16),
                        label: Text(l10n.wooSyncEventRetry),
                      ),
                    TextButton.icon(
                      onPressed: busy ? null : onProcessNow,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(l10n.wooSyncEventProcessNow),
                    ),
                    TextButton.icon(
                      onPressed: busy ? null : onSetReviewState,
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: Text(l10n.wooSyncEventSetReviewState),
                    ),
                    if (onPushInvoice != null)
                      TextButton.icon(
                        onPressed: busy ? null : onPushInvoice,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                        label: Text(l10n.wooSyncEventPushInvoice),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
