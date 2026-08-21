import 'package:flutter/material.dart';

import '../../../../core/localization/localized_display_mappers.dart';
import '../../data/models/journey_note.dart';
import '../journey_format.dart';

/// The compact journey read-out for a card: when this prospect was last
/// touched, and what is due next.
///
/// Two lines at most, because it rides on a kanban card. The next-action line
/// is tinted when it is due or overdue — that tint is the point of putting the
/// diary on the board at all.
class JourneyCardBadge extends StatelessWidget {
  const JourneyCardBadge({super.key, required this.summary, this.dense = true});

  final JourneySummary summary;

  /// Dense drops the note snippet, for the narrow pipeline column.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final lastLabel =
        JourneyFormat.relativePast(context, summary.lastJourneyDate);
    final type = (summary.lastJourneyType ?? '').trim();
    final contact = (summary.lastJourneyContact ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              JourneyFormat.typeIcon(type),
              size: 12,
              color: muted,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                [
                  if (lastLabel.isNotEmpty) lastLabel,
                  if (type.isNotEmpty) localizedJourneyType(context, type),
                  if (contact.isNotEmpty) contact,
                ].join(' · '),
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (summary.journeyCount > 1)
              Text(
                '${summary.journeyCount}',
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
          ],
        ),
        if (!dense && (summary.lastJourneyNote ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            summary.lastJourneyNote!.trim(),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (summary.hasNextAction) ...[
          const SizedBox(height: 4),
          _NextActionPill(summary: summary),
        ],
      ],
    );
  }
}

class _NextActionPill extends StatelessWidget {
  const _NextActionPill({required this.summary});

  final JourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = JourneyFormat.isDue(summary.nextActionDate);
    final bg = due ? const Color(0xFFFDF2E3) : const Color(0xFFF1F0EE);
    final fg = due
        ? const Color(0xFF9A6B12)
        : theme.colorScheme.onSurfaceVariant;
    final action = (summary.nextAction ?? '').trim();
    final label = [
      JourneyFormat.relativeFuture(context, summary.nextActionDate),
      if (action.isNotEmpty) action,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            due ? Icons.notifications_active_outlined : Icons.event_outlined,
            size: 12,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
