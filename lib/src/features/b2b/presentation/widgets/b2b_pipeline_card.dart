import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../journey/presentation/widgets/journey_badge.dart';
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

  /// Jumps straight to the lead's catalog page. Null for Opportunity cards,
  /// which have no lead page behind them.
  final void Function(B2bCard card)? onOpenLead;

  const B2bPipelineCard({
    super.key,
    required this.card,
    this.onTap,
    this.stages = const [],
    this.onMove,
    this.onOpenLead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLead = card.doctype == 'Lead';
    // Stages the card can move to: every pipeline stage except its current one.
    final moveTargets =
        stages.where((s) => s != card.stage).toList(growable: false);
    final canMove = onMove != null && moveTargets.isNotEmpty;
    final canOpenLead = isLead && onOpenLead != null;
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
                  if (canMove || canOpenLead)
                    _CardMenu(
                      card: card,
                      targets: canMove ? moveTargets : const [],
                      onMove: onMove,
                      onOpenLead: canOpenLead ? onOpenLead : null,
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
                    isLead
                        ? context.l10n.b2bCardLead
                        : context.l10n.b2bCardOpportunity,
                    Icons.label_outline,
                  ),
                  if (card.leadScore != null)
                    _chip(
                      context,
                      context.l10n.b2bScoreLabel(card.leadScore!),
                      Icons.star_outline,
                    ),
                  if (card.customer != null && card.customer!.isNotEmpty)
                    _chip(context, card.customer!, Icons.account_circle_outlined),
                  // Printed-label shortage flag: red because a label that needs
                  // printing is a days-long lead time, not a same-day fix.
                  if (card.labelAlert > 0) _LabelAlertChip(count: card.labelAlert),
                ],
              ),
              // The journey read-out: when this prospect was last visited and
              // what is due. Replaces the raw `modified` timestamp, which said
              // when the ROW changed — not when anyone actually spoke to them.
              if (!card.journey.isEmpty) ...[
                const SizedBox(height: 6),
                JourneyCardBadge(summary: card.journey),
              ] else if (card.lastActivity != null &&
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

/// Small red label badge: how many of this account's printed labels currently
/// need attention (out of stock / reorder now / reorder soon).
class _LabelAlertChip extends StatelessWidget {
  final int count;

  const _LabelAlertChip({required this.count});

  static const _red = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: context.l10n.b2bLabelsNeedPrintingTooltip(count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _red.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label_important, size: 12, color: _red),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: _red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The overflow (⋮) menu on a pipeline card: "Open lead page" plus every stage
/// the card can move to. Selecting a stage calls the same [onMove] path the
/// drag-and-drop uses; the lead entry jumps to the full catalog page, which is
/// otherwise several taps away from the board.
class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.card,
    required this.targets,
    required this.onMove,
    required this.onOpenLead,
  });

  static const _openLeadValue = '__open_lead__';

  final B2bCard card;
  final List<String> targets;
  final void Function(B2bCard card, String stage)? onMove;
  final void Function(B2bCard card)? onOpenLead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: context.l10n.b2bMoveTo,
      icon: const Icon(Icons.more_vert, size: 18),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 180),
      onSelected: (value) {
        if (value == _openLeadValue) {
          onOpenLead?.call(card);
          return;
        }
        onMove?.call(card, value);
      },
      itemBuilder: (context) => [
        if (onOpenLead != null) ...[
          PopupMenuItem<String>(
            value: _openLeadValue,
            child: Row(
              children: [
                const Icon(Icons.open_in_new, size: 16),
                const SizedBox(width: 8),
                Text(context.l10n.b2bOpenLeadPage),
              ],
            ),
          ),
          if (targets.isNotEmpty) const PopupMenuDivider(),
        ],
        if (targets.isNotEmpty) ...[
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
      ],
    );
  }
}
