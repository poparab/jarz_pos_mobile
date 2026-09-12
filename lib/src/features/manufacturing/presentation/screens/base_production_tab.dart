import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/base_item.dart';
import '../../data/models/production_suggestion.dart' show ProductionStatus;
import '../../state/base_production_providers.dart';
import '../../state/running_batches_notifier.dart';
import '../widgets/base_run_row.dart';

/// "Make the bases the jars are built from."
///
/// Two kinds of thing live here and they are not made the same way, which is
/// what the screen now says out loud:
///
/// * **Mixes** are weighed — blueberry mix is a kilo of fruit and a kilo of
///   jelly. Asking them for "1.5 batches" was asking a question the kitchen
///   does not have an answer to. They are entered in jars or in kilos, and
///   making one books it outright: a five-minute stir has nothing to come back
///   and finish, and a mix left sitting in WIP is exactly how four Work Orders
///   were stranded there for three months.
/// * **Cakes and biscuits** are counted in eggs — 30 of them is one tray of
///   Fudge Cake and 45 is one and a half. Those go into the oven, so making one
///   moves its material into WIP and the Running tab records what came out.
///
/// One action for the lot, at the bottom, because doing several mixes at once
/// is the normal morning rather than the exception.
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
      data: (page) => page.isEmpty ? const _EmptyList() : _Loaded(page: page),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.page});

  final BaseItemsPage page;

  /// Mixes above cakes, because a mix is the quicker, more frequent job and the
  /// one the jars run out of first.
  ///
  /// Within a group, whatever is running out comes first: critical, then low,
  /// then everything else by name. The floor reads down until it stops
  /// recognising urgency.
  List<BaseItem> _sorted(bool madeByQuantity) {
    final rows = page.items
        .where((item) => item.isMadeByQuantity == madeByQuantity)
        .toList();
    rows.sort((a, b) {
      final rank = _urgency(a).compareTo(_urgency(b));
      if (rank != 0) return rank;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return rows;
  }

  static int _urgency(BaseItem item) => switch (item.status) {
    ProductionStatus.critical => 0,
    ProductionStatus.low => 1,
    _ => 2,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mixes = _sorted(true);
    final batched = _sorted(false);
    final padding = ResponsiveUtils.getResponsivePadding(
      context,
      small: 10,
      medium: 12,
      large: 12,
    );

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(baseItemsProvider.notifier).refresh(),
            child: ListView(
              padding: padding,
              children: [
                _Header(page: page),
                if (mixes.isNotEmpty) ...[
                  _GroupHeading(
                    label: l10n.basesGroupMixes,
                    hint: l10n.basesGroupMixesHint,
                  ),
                  for (final item in mixes) ...[
                    BaseRunRow(key: ValueKey(item.itemCode), item: item),
                    const SizedBox(height: 8),
                  ],
                ],
                if (batched.isNotEmpty) ...[
                  _GroupHeading(
                    label: l10n.basesGroupBatches,
                    hint: l10n.basesGroupBatchesHint,
                  ),
                  for (final item in batched) ...[
                    BaseRunRow(key: ValueKey(item.itemCode), item: item),
                    const SizedBox(height: 8),
                  ],
                ],
                // Room for the action bar, so the last row is reachable rather
                // than pinned under it.
                const SizedBox(height: 72),
              ],
            ),
          ),
        ),
        _MakeBar(page: page),
      ],
    );
  }
}

/// Only what is wrong, and nothing when nothing is.
///
/// The old header printed a standing explanation of why bases have no
/// suggestions on every load. That sentence was true and nobody needed it twice.
class _Header extends StatelessWidget {
  const _Header({required this.page});

  final BaseItemsPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final belowCover = page.coverIncluded ? page.belowCoverCount : 0;
    final blocked = page.summary.blockedByMaterials;
    final seasonName = page.coverIncluded ? page.season.name : null;

    if (belowCover == 0 && blocked == 0 && seasonName == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (belowCover > 0)
            _Pill(
              text: l10n.productionBelowCover(belowCover),
              background: scheme.tertiaryContainer,
              foreground: scheme.onTertiaryContainer,
            ),
          if (blocked > 0)
            _Pill(
              text: l10n.basesSummaryBlocked(blocked),
              background: scheme.errorContainer,
              foreground: scheme.onErrorContainer,
            ),
          if (seasonName != null)
            _Pill(
              text: l10n.productionSeasonApplied(
                seasonName,
                page.season.multiplier,
              ),
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          Text(
            hint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one action on the screen.
///
/// It knows which of the ticked rows are mixes and which are cakes, so it can
/// say what pressing it will actually do — "Make 3 mixes", "Start 2 batches", or
/// both — rather than a generic Submit that hides the fact one of them posts
/// finished stock and the other does not.
class _MakeBar extends ConsumerWidget {
  const _MakeBar({required this.page});

  final BaseItemsPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selected = ref.watch(baseSelectionProvider);
    if (selected.isEmpty) return const SizedBox.shrink();

    final byCode = <String, BaseItem>{
      for (final item in page.items) item.itemCode: item,
    };

    var mixCount = 0;
    var cakeCount = 0;
    var shortCount = 0;
    var qtyMissing = 0;
    for (final code in selected) {
      final item = byCode[code];
      if (item == null) continue;
      final draft = ref.watch(baseRunDraftProvider(code));
      if (!draft.isRunnable) {
        qtyMissing++;
        continue;
      }
      if (item.isMadeByQuantity) {
        mixCount++;
      } else {
        cakeCount++;
      }
      // A known shortage on ONE ticked row would take the whole call down with
      // it: the server's basket check is all-or-nothing by design, which is what
      // stops a basket that passes line by line from emptying a store. So the
      // button waits rather than posting a call that is certain to be refused.
      if (draft.previewIsCurrent && (draft.preview?.hasShortage ?? false)) {
        shortCount++;
      }
    }

    final total = mixCount + cakeCount;
    final submitting = ref.watch(baseMakeProvider);
    final canMake = total > 0 && shortCount == 0 && !submitting;

    final String label;
    if (total == 0) {
      label = l10n.basesNothingToMake;
    } else if (cakeCount == 0) {
      label = l10n.basesMakeMixes(mixCount);
    } else if (mixCount == 0) {
      label = l10n.basesStartBatches(cakeCount);
    } else {
      label = l10n.basesMakeBoth(mixCount, cakeCount);
    }

    final String? note;
    if (shortCount > 0) {
      note = l10n.basesSelectedShort(shortCount);
    } else if (qtyMissing > 0) {
      note = l10n.basesSelectedEmpty(qtyMissing);
    } else if (cakeCount > 0 && mixCount > 0) {
      note = l10n.basesMixedNote;
    } else {
      note = null;
    }

    return Material(
      elevation: 3,
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    note,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: shortCount > 0
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Row(
                children: [
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () =>
                              ref.read(baseSelectionProvider.notifier).clear(),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: canMake ? () => _make(context, ref) : null,
                      child: Text(label),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _make(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);
    BaseMakeReport report;
    try {
      report = await ref
          .read(baseMakeProvider.notifier)
          .make(scheduledAt: nowStampToTheMinute());
    } finally {
      ref.read(loadingOverlayProvider.notifier).hide();
    }

    // Stock has physically moved for every line that succeeded, so every figure
    // the list was showing is now wrong.
    if (!report.postedNothing) {
      ref.read(baseItemsProvider.notifier).refresh();
      if (report.hasRunningWork) {
        await ref.read(runningBatchesProvider.notifier).refresh();
      }
    }

    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text(_message(context, report))),
    );

    // Only a cake has left something to do. Yanking somebody to the Running tab
    // after booking three mixes would be moving them away from the screen they
    // are still working on.
    if (report.hasRunningWork) {
      ref.read(productionTabRequestProvider.notifier).state =
          kProductionRunningTabIndex;
    }
  }

  String _message(BuildContext context, BaseMakeReport report) {
    final l10n = context.l10n;

    if (report.unresolved.isNotEmpty) return l10n.basesCatalogueStale;
    if (report.nothingToDo) return l10n.basesNothingToMake;

    // A shortage the server found beats any count: it is why nothing posted.
    if (report.postedNothing) {
      final failure = report.failures
          .map((f) => f.error ?? '')
          .firstWhere((message) => message.isNotEmpty, orElse: () => '');
      if (failure.isNotEmpty) return failure;
      final transport = report.mixError ?? report.cakeError;
      if (transport != null) {
        return context.userErrorMessage(transport, fallback: l10n.commonError);
      }
      return l10n.commonError;
    }

    final parts = <String>[
      if (report.madeCount > 0) l10n.basesReportMade(report.madeCount),
      if (report.startedCount > 0)
        l10n.basesReportStarted(report.startedCount),
    ];
    final summary = parts.join(' · ');
    final failed = report.failures.length;
    return failed == 0 ? summary : '$summary · ${l10n.basesReportFailed(failed)}';
  }
}

/// Now, to the minute — a base run is always posted as it happens, so there is
/// no back-dating path here and no posting-date confirmation either.
String nowStampToTheMinute() {
  String two(int v) => v.toString().padLeft(2, '0');
  final now = DateTime.now();
  return '${now.year}-${two(now.month)}-${two(now.day)} '
      '${two(now.hour)}:${two(now.minute)}:00';
}

class _Pill extends StatelessWidget {
  const _Pill({
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
/// leaving no way to re-ask once the bases are configured.
class _EmptyList extends ConsumerWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () => ref.read(baseItemsProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            l10n.basesEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
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
