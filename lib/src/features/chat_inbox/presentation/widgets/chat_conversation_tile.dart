import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/chat_models.dart';
import '../chat_labels.dart';

/// One inbox row: channel icon, name, preview, live "waiting N min" (red at
/// [kChatWaitingAlertMinutes]+), complaint badge, draft-ready dot and the
/// unread count.
class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    super.key,
    required this.summary,
    required this.now,
    required this.onTap,
  });

  final ChatConversationSummary summary;

  /// The inbox's ticking clock, so every row's wait label moves together.
  final DateTime now;
  final VoidCallback onTap;

  String _timeLabel(BuildContext context, DateTime? time) {
    if (time == null) return '';
    final sameDay = time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
    return formatDateTime(
      context,
      time,
      pattern: sameDay ? 'h:mm a' : 'MMM d',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final channelColor = chatChannelColor(summary.channel);
    final waiting = summary.waitingMinutes(now);
    final waitingAlert =
        waiting != null && waiting >= kChatWaitingAlertMinutes;
    final unread = summary.unreadCount;
    final preview = summary.lastMessagePreview ?? '';
    final previewText = summary.lastDirection == 'Outbound' && preview.isNotEmpty
        ? l10n.chatPreviewYou(preview)
        : preview;

    return ListTile(
      key: ValueKey('chat-tile-${summary.name}'),
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: channelColor.withValues(alpha: 0.15),
            foregroundColor: channelColor,
            child: Icon(
              chatChannelIcon(summary.channel),
              semanticLabel: chatChannelLabel(l10n, summary.channel),
            ),
          ),
          if (summary.hasPendingDraft)
            PositionedDirectional(
              end: -2,
              top: -2,
              child: Tooltip(
                message: l10n.chatDraftReadyTooltip,
                child: Container(
                  key: ValueKey('chat-draft-dot-${summary.name}'),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              summary.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          if (summary.isComplaint) ...[
            const SizedBox(width: 6),
            _Pill(
              label: l10n.chatComplaintBadge,
              color: theme.colorScheme.error,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (previewText.isNotEmpty)
            Text(
              previewText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (waiting != null || summary.assignedToName != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                spacing: 8,
                children: [
                  if (waiting != null)
                    Text(
                      l10n.chatWaitingMinutes(formatCount(context, waiting)),
                      key: ValueKey('chat-waiting-${summary.name}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: waitingAlert
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            waitingAlert ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  if (summary.assignedToName != null)
                    Text(
                      l10n.chatAssignedTo(summary.assignedToName!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _timeLabel(context, summary.lastMessageTime),
            style: theme.textTheme.bodySmall,
          ),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              key: ValueKey('chat-unread-${summary.name}'),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                formatCount(context, unread),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
