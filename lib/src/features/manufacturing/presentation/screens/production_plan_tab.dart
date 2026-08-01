import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/models/batch_line.dart';
import '../../data/models/production_suggestion.dart';
import '../../state/production_basket_notifier.dart';
import '../../state/production_providers.dart';
import '../widgets/suggestion_row.dart';

/// "What should we make today?"
///
/// The tab opens on a ranked answer rather than an empty search box — the old
/// screen made whoever held the phone arrive with the quantity already worked
/// out on paper, while the velocity data to compute it sat unused on every Item.
class ProductionPlanTab extends ConsumerWidget {
  const ProductionPlanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pageAsync = ref.watch(productionSuggestionsProvider);

    return pageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorRetry(
        message: extractFrappeErrorMessage(error, fallback: l10n.commonError),
        onRetry: () => ref.invalidate(productionSuggestionsProvider),
      ),
      data: (page) {
        final visible = ref.watch(visibleSuggestionsProvider);

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(productionSuggestionsProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _PlanHeader(page: page)),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.productionNoSuggestions)),
                )
              else
                SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final suggestion = visible[index];
                    return SuggestionRow(
                      suggestion: suggestion,
                      onAdd: (batches) =>
                          _addOne(context, ref, suggestion, batches),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  void _addOne(
    BuildContext context,
    WidgetRef ref,
    ProductionSuggestion suggestion,
    int batches,
  ) {
    // Deliberately not routed through fillTheDay: that filters on
    // `isActionable`, so an explicit tap on an item outside critical/low — an
    // "ok" item with a long per-item cover target, say — would silently add
    // nothing.
    ref.read(productionBasketProvider.notifier).addOrRaise(
          BatchLine(
            itemCode: suggestion.itemCode,
            itemName: suggestion.itemName,
            bomName: suggestion.defaultBom,
            stockUom: suggestion.stockUom,
            bomQtyYield: suggestion.bomQty,
            batches: batches.toDouble(),
          ),
        );
    _attachComponents(ref, suggestion.itemCode);
  }
}

/// Backfills a line's component list once its BOM resolves.
///
/// Suggestion rows carry no component detail, so a line added from the Plan tab
/// needs its BOM fetched before the Batch tab can show a pick list for it.
void _attachComponents(WidgetRef ref, String itemCode) {
  ref.read(bomDetailsProvider(itemCode).future).then(
    (bom) => ref.read(productionBasketProvider.notifier).attachComponents(itemCode, bom),
    onError: (_) {
      // The roll-up endpoint recomputes materials server-side anyway, so a
      // failed prefetch costs a collapsed component list, nothing more.
    },
  );
}

class _PlanHeader extends ConsumerWidget {
  const _PlanHeader({required this.page});

  final ProductionSuggestionsPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filter = ref.watch(productionFilterProvider);

    final actionable = page.summary.actionable;
    final neverRan = (page.velocityUpdatedOn ?? '').isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (neverRan)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: scheme.tertiaryContainer,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: scheme.onTertiaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.productionVelocityNever,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
          ),
        if (actionable > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: scheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.productionBelowCover(actionable),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (page.season.name != null)
                        Text(
                          l10n.productionSeasonApplied(
                            page.season.name!,
                            page.season.multiplier,
                          ),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.playlist_add, size: 18),
                  label: Text(l10n.productionFillTheDay),
                  onPressed: () => _fillTheDay(context, ref),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.productionFilterAll),
                selected: filter.isAll,
                onSelected: (_) => ref
                    .read(productionFilterProvider.notifier)
                    .state = const ProductionFilter(),
              ),
              for (final entry in <(String, String)>[
                (ProductionStatus.critical, l10n.productionStatusCritical),
                (ProductionStatus.low, l10n.productionStatusLow),
                (ProductionStatus.ok, l10n.productionStatusOk),
                (ProductionStatus.overstocked, l10n.productionStatusOverstocked),
                (ProductionStatus.noVelocity, l10n.productionStatusNoVelocity),
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(entry.$2),
                    selected: filter.statuses.contains(entry.$1),
                    onSelected: (_) => ref
                        .read(productionFilterProvider.notifier)
                        .state = filter.toggle(entry.$1),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _fillTheDay(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final result =
        ref.read(productionBasketProvider.notifier).fillTheDay(page.items);

    for (final item in page.items.where((i) => i.isActionable)) {
      _attachComponents(ref, item.itemCode);
    }

    // Says what it skipped rather than quietly adding less than the board
    // suggested — a silent cap reads as "covered everything" when it wasn't.
    final message = StringBuffer(
      result.addedNothing
          ? l10n.productionFillTheDayNothing
          : l10n.productionFillTheDayResult(
              result.itemsAdded,
              result.batchesAdded.toStringAsFixed(0),
            ),
    );
    if (result.skippedNoMaterials > 0) {
      message
        ..write(' · ')
        ..write(l10n.productionFillTheDaySkipped(result.skippedNoMaterials));
    }

    messenger.showSnackBar(SnackBar(content: Text(message.toString())));
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
