import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/draft_cart_repository.dart';
import '../../data/models/draft_cart.dart';
import '../../state/pos_notifier.dart';

/// Horizontal chip bar that shows [+ New] plus one chip per saved draft.
/// Mounts above the item grid, below the customer search bar.
class DraftTabsBar extends ConsumerWidget {
  const DraftTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(posNotifierProvider.select((s) => s.drafts));
    final currentDraftId = ref.watch(posNotifierProvider.select((s) => s.currentDraftId));
    final draftDirty = ref.watch(posNotifierProvider.select((s) => s.draftDirty));

    if (drafts.isEmpty && currentDraftId == null) {
      // No drafts yet — nothing to show until the first item is added.
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 48,
      color: colorScheme.surfaceContainerHighest,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: drafts.length + 1, // +1 for the [+ New] chip
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // [+ New] chip
          if (index == 0) {
            return ActionChip(
              avatar: Icon(
                Icons.add,
                size: 16,
                color: currentDraftId == null && drafts.isEmpty
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              label: const Text('New'),
              backgroundColor: currentDraftId == null
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              side: BorderSide(
                color: currentDraftId == null
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.5),
              ),
              onPressed: () {
                if (drafts.length >= kDraftCartLimit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Draft limit reached ($kDraftCartLimit max). Delete a draft to create a new one.',
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                ref.read(posNotifierProvider.notifier).newDraft();
              },
            );
          }

          // Draft chips (index - 1 maps to drafts list)
          final draft = drafts[index - 1];
          final isActive = draft.id == currentDraftId;
          final showDot = isActive && draftDirty;

          return GestureDetector(
            onLongPress: () => _confirmDelete(context, ref, draft),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      draft.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showDot) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              selected: isActive,
              onSelected: (_) {
                if (!isActive) {
                  ref.read(posNotifierProvider.notifier).switchDraft(draft.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DraftCartSummary draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Draft'),
        content: Text('Delete "${draft.label}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(posNotifierProvider.notifier).deleteDraft(draft.id);
    }
  }
}

/// Badge showing how many open drafts exist.
/// Renders as a small counter over [child] — typically used in the app bar.
class DraftCountBadge extends ConsumerWidget {
  final Widget child;
  const DraftCountBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(posNotifierProvider.select((s) => s.drafts.length));
    if (count == 0) return child;
    return Badge(
      label: Text('$count'),
      child: child,
    );
  }
}
