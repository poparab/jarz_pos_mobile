import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/b2b_models.dart';
import 'b2b_stage_chip.dart';

/// A single draggable card on the B2B pipeline board.
class B2bPipelineCard extends StatelessWidget {
  final B2bCard card;
  final VoidCallback? onTap;

  /// All pipeline stages, in order. Used to build the explicit "Move to" menu.
  final List<String> stages;

  /// Explicit (tap-based) stage move. When provided (and there is at least one
  /// other stage to move to), the card shows a "Move to" menu so a user can
  /// change stage without fighting the long-press drag.
  final void Function(B2bCard card, String stage)? onMove;

  const B2bPipelineCard({
    super.key,
    required this.card,
    this.onTap,
    this.stages = const [],
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLead = card.doctype == 'Lead';
    // Stages the card can move to: every pipeline stage except its current one.
    final moveTargets =
        stages.where((s) => s != card.stage).toList(growable: false);
    final canMove = onMove != null && moveTargets.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isLead ? Icons.person_add_alt : Icons.business_center,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canMove)
                    _MoveMenu(
                      card: card,
                      targets: moveTargets,
                      onMove: onMove!,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _chip(
                    context,
                    isLead ? 'Lead' : 'Opportunity',
                    Icons.label_outline,
                  ),
                  if (card.leadScore != null)
                    _chip(
                      context,
                      'Score ${card.leadScore}',
                      Icons.star_outline,
                    ),
                  if (card.customer != null && card.customer!.isNotEmpty)
                    _chip(context, card.customer!, Icons.account_circle_outlined),
                ],
              ),
              if (card.lastActivity != null &&
                  card.lastActivity!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  card.lastActivity!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// The explicit "Move to" affordance on a pipeline card: a compact overflow
/// (⋮) menu listing every stage the card can move to. Selecting one calls the
/// same [onMove] path the drag-and-drop uses.
class _MoveMenu extends StatelessWidget {
  const _MoveMenu({
    required this.card,
    required this.targets,
    required this.onMove,
  });

  final B2bCard card;
  final List<String> targets;
  final void Function(B2bCard card, String stage) onMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: context.l10n.b2bMoveTo,
      icon: const Icon(Icons.more_vert, size: 18),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 180),
      onSelected: (stage) => onMove(card, stage),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            context.l10n.b2bMoveTo,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const PopupMenuDivider(),
        for (final stage in targets)
          PopupMenuItem<String>(
            value: stage,
            child: Row(
              children: [
                B2bStageChip(stage: stage),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
