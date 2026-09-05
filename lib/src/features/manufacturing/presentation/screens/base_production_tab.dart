import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/base_item.dart';
import '../../state/base_production_providers.dart';
import '../widgets/base_item_card.dart';

/// "Make a base."
///
/// Fudge Cake, Sponge Cake, Savoiardi, Butter Biscuit, Cheesecake Mix — the
/// sub-assemblies every jar is built from. They are never sold, so the
/// sales-driven Plan tab computes a suggestion of zero for them and hides its
/// action panel entirely: the floor could not start one from the app at all,
/// and every jar made ate freezer stock nothing replenished.
///
/// This tab asks the batch question directly instead. No role gate of its own —
/// the host screen already refuses the whole board to anyone outside
/// `canAccessProductionBoardProvider`, and a second check here would drift.
class BaseProductionTab extends ConsumerWidget {
  const BaseProductionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pageAsync = ref.watch(baseItemsProvider);

    return pageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorRetry(
        message: context.userErrorMessage(error, fallback: l10n.commonError),
        onRetry: () => ref.invalidate(baseItemsProvider),
      ),
      data: (page) => RefreshIndicator(
        onRefresh: () => ref.read(baseItemsProvider.notifier).refresh(),
        child: page.isEmpty
            ? const _EmptyList()
            : ListView.separated(
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  small: 10,
                  medium: 12,
                  large: 12,
                ),
                // One extra leading entry for the header, so the whole tab is a
                // single scrollable and pull-to-refresh works from anywhere on
                // it — same shape as the Plan tab.
                itemCount: page.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => index == 0
                    ? _BasesHeader(page: page)
                    : BaseItemCard(item: page.items[index - 1]),
              ),
      ),
    );
  }
}

class _BasesHeader extends StatelessWidget {
  const _BasesHeader({required this.page});

  final BaseItemsPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final short = page.summary.shortOfDemand;
    final blocked = page.summary.blockedByMaterials;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basesHeaderHint,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (short > 0 || blocked > 0) ...[
          const SizedBox(height: 8),
          // Wrap, not Row: both Arabic summary lines on one row overflow a
          // 360 dp screen.
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (short > 0)
                _SummaryPill(
                  text: l10n.basesSummaryShort(short),
                  background: scheme.tertiaryContainer,
                  foreground: scheme.onTertiaryContainer,
                ),
              if (blocked > 0)
                _SummaryPill(
                  text: l10n.basesSummaryBlocked(blocked),
                  background: scheme.errorContainer,
                  foreground: scheme.onErrorContainer,
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Empty, but still scrollable: a `Center` alone would kill pull-to-refresh,
/// leaving no way to re-ask after the bases are configured.
class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          l10n.basesEmpty,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.basesHeaderHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
