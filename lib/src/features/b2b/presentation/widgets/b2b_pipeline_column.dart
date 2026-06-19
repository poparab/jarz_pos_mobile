import 'package:flutter/material.dart';

import '../../data/models/b2b_models.dart';
import 'b2b_pipeline_card.dart';
import 'b2b_stage_chip.dart';

/// One column of the B2B pipeline board: a stage header and its draggable cards.
/// Dropping a card here triggers [onAccept] (advance to this stage).
class B2bPipelineColumn extends StatelessWidget {
  final String stage;
  final List<B2bCard> cards;
  final void Function(B2bCard card) onAccept;
  final void Function(B2bCard card) onCardTap;
  final double width;

  const B2bPipelineColumn({
    super.key,
    required this.stage,
    required this.cards,
    required this.onAccept,
    required this.onCardTap,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<B2bCard>(
      onWillAcceptWithDetails: (details) => details.data.stage != stage,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return Container(
          width: width,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: highlight
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: highlight
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(child: B2bStageChip(stage: stage)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cards.length}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cards.isEmpty
                    ? Center(
                        child: Text(
                          'No accounts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return LongPressDraggable<B2bCard>(
                            data: card,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: width - 16,
                                child: B2bPipelineCard(card: card),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.4,
                              child: B2bPipelineCard(card: card),
                            ),
                            child: B2bPipelineCard(
                              card: card,
                              onTap: () => onCardTap(card),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
