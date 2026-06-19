import 'package:flutter/material.dart';

import '../../data/models/b2b_models.dart';

/// A single draggable card on the B2B pipeline board.
class B2bPipelineCard extends StatelessWidget {
  final B2bCard card;
  final VoidCallback? onTap;

  const B2bPipelineCard({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLead = card.doctype == 'Lead';
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
