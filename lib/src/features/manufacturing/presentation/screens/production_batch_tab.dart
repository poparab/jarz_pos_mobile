import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../data/manufacturing_service.dart';
import '../../data/models/basket_rollup.dart';
import '../../data/models/batch_line.dart';
import '../../state/production_basket_notifier.dart';
import '../../state/production_providers.dart';
import '../../state/running_batches_notifier.dart';
import '../widgets/basket_shortage_banner.dart';
import '../widgets/batch_date_bar.dart';
import '../widgets/batch_line_card.dart';
import '../widgets/production_format.dart';

/// The queued batch: one date, one consolidated pick list, one submit.
class ProductionBatchTab extends ConsumerWidget {
  const ProductionBatchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final basket = ref.watch(productionBasketProvider);
    final notifier = ref.read(productionBasketProvider.notifier);

    if (basket.isEmpty) {
      return Center(child: Text(l10n.productionBasketEmpty));
    }

    final rollupAsync = ref.watch(basketRollupProvider);
    final rollup = rollupAsync.valueOrNull;
    final shortages = shortageItemCodes(rollup);
    final today = DateTime.now();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(
              context,
              small: 10,
              medium: 12,
              large: 12,
            ),
            children: [
              BatchDateBar(
                date: basket.postingDate ?? today,
                onChanged: notifier.setPostingDate,
              ),
              const SizedBox(height: 8),
              if (rollupAsync.isLoading && rollup == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: LinearProgressIndicator()),
                )
              else if (rollup != null) ...[
                BasketPickList(rollup: rollup),
                const SizedBox(height: 12),
              ],
              for (var index = 0; index < basket.lines.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BatchLineCard(
                    line: basket.lines[index],
                    shortages: shortages,
                    onBatchesChanged: (value) =>
                        notifier.setBatches(index, value),
                    onUnitsChanged: (value) => notifier.setUnits(index, value),
                    onRemove: () => notifier.remove(index),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        _BatchFooter(rollup: rollup),
      ],
    );
  }
}

class _BatchFooter extends ConsumerWidget {
  const _BatchFooter({required this.rollup});

  final BasketRollup? rollup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final basket = ref.watch(productionBasketProvider);

    final blocked = rollup?.hasShortages ?? false;
    final nothingToSubmit = basket.positiveLines.isEmpty;

    final disabled = blocked || nothingToSubmit;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.productionBasketTitle(basket.positiveLines.length),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.productionBatchTotals(
                  trimQty(basket.totalBatches),
                  trimQty(basket.totalUnits),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              // Three actions no longer fit beside the totals on a phone, so
              // the buttons get their own row. Wrapped rather than spaced: the
              // Arabic labels are longer and a fixed Row overflows on a 360dp
              // screen.
              Row(
                children: [
                  TextButton(
                    onPressed: ref.read(productionBasketProvider.notifier).clear,
                    child: Text(l10n.productionClearBasket),
                  ),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // The escape hatch, unchanged: transfer and manufacture
                        // in one call, for items where the method genuinely
                        // does not matter.
                        OutlinedButton(
                          onPressed:
                              disabled ? null : () => _submit(context, ref),
                          child: Text(l10n.productionQuickProduce),
                        ),
                        FilledButton(
                          onPressed:
                              disabled ? null : () => _startBatch(context, ref),
                          child: Text(l10n.productionStart),
                        ),
                      ],
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

  /// Starts each queued line: Work Order plus material transfer, no Manufacture
  /// entry. What comes out is recorded later on the Running tab.
  ///
  /// Deliberately one call per line rather than a bulk endpoint — a start that
  /// fails on line three must not roll back the two batches already physically
  /// on the bench.
  Future<void> _startBatch(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final basket = ref.read(productionBasketProvider);
    final postingDate = basket.postingDate ?? DateTime.now();

    // Checked before the confirmation dialog so the refusal names the actual
    // reason instead of arriving as a server error after two more taps.
    if (_isBackDated(postingDate) &&
        !ref.read(canBackDateProductionProvider)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.productionBackDateNotAllowed)),
      );
      return;
    }

    final confirmed = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
    );
    if (!confirmed || !context.mounted) return;

    final lines = basket.positiveLines;
    if (lines.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.manufacturingNothingToSubmit)),
      );
      return;
    }

    final scheduledAt = _timestamp(postingDate);
    final service = ref.read(manufacturingServiceProvider);

    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);
    final started = <BatchLine, String>{};
    final issues = <String>[];

    for (final line in lines) {
      try {
        final result = await service.startProductionBatch(
          itemCode: line.itemCode,
          bomName: line.bomName,
          itemQty: line.units,
          scheduledAt: scheduledAt,
        );
        started[line] = result.workOrder;
      } catch (error) {
        issues.add(
          '${line.itemCode}: '
          '${extractFrappeErrorMessage(error, fallback: l10n.commonError)}',
        );
      }
    }
    ref.read(loadingOverlayProvider.notifier).hide();

    // Only started lines leave the basket, so a partial failure stays visible
    // and retryable instead of vanishing into a snackbar.
    final notifier = ref.read(productionBasketProvider.notifier);
    for (final line in started.keys) {
      final index = ref.read(productionBasketProvider).indexOfItem(line.itemCode);
      if (index >= 0) notifier.remove(index);
    }

    if (started.isNotEmpty) {
      ref.invalidate(productionSuggestionsProvider);
      await ref.read(runningBatchesProvider.notifier).refresh();
      ref.read(productionTabRequestProvider.notifier).state =
          kProductionRunningTabIndex;
    }

    if (!context.mounted) return;
    if (issues.isNotEmpty) {
      await _showIssues(context, issues);
    }
    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          started.length == 1
              ? l10n.productionStarted(started.values.first)
              : l10n.manufacturingSubmitAllResult(started.length, lines.length),
        ),
      ),
    );
  }

  /// True when [date] falls on an earlier calendar day than today.
  static bool _isBackDated(DateTime date) {
    final now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final basket = ref.read(productionBasketProvider);
    final postingDate = basket.postingDate ?? DateTime.now();

    final confirmed = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
    );
    if (!confirmed || !context.mounted) return;

    final lines = basket.toApiLines(scheduledAt: _timestamp(postingDate));
    if (lines.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.manufacturingNothingToSubmit)),
      );
      return;
    }

    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);
    Map<String, dynamic> result;
    try {
      result = await ref
          .read(manufacturingServiceProvider)
          .submitWorkOrders(lines);
    } catch (error) {
      ref.read(loadingOverlayProvider.notifier).hide();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.manufacturingSubmitFailed(
              extractFrappeErrorMessage(error, fallback: l10n.commonError),
            ),
          ),
        ),
      );
      return;
    }
    ref.read(loadingOverlayProvider.notifier).hide();

    final entries = (result['results'] as List?) ?? const [];
    final succeeded = <String>{};
    final issues = <String>[];

    for (final entry in entries) {
      if (entry is! Map) continue;
      final row = Map<String, dynamic>.from(entry);
      final line = row['line'] is Map
          ? Map<String, dynamic>.from(row['line'] as Map)
          : const <String, dynamic>{};
      final itemCode = '${line['item_code'] ?? ''}';

      if (row['ok'] == true ||
          (row['work_order'] ?? '').toString().isNotEmpty) {
        succeeded.add(itemCode);
      } else {
        final error = '${row['error'] ?? l10n.commonError}';
        issues.add(itemCode.isEmpty ? error : '$itemCode: $error');
      }
    }

    // Only successful lines leave the basket, so a partial failure stays
    // visible and retryable instead of vanishing into a snackbar.
    final notifier = ref.read(productionBasketProvider.notifier);
    for (final itemCode in succeeded) {
      final index = ref.read(productionBasketProvider).indexOfItem(itemCode);
      if (index >= 0) notifier.remove(index);
    }
    ref.invalidate(productionSuggestionsProvider);

    if (!context.mounted) return;
    if (issues.isNotEmpty) {
      await _showIssues(context, issues);
    }
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.manufacturingSubmitAllResult(succeeded.length, entries.length),
        ),
      ),
    );
  }

  Future<void> _showIssues(BuildContext context, List<String> issues) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.commonError),
        content: SizedBox(
          width: ResponsiveUtils.getDialogWidth(
            dialogContext,
            small: 340,
            medium: 440,
            large: 520,
          ),
          child: SingleChildScrollView(child: Text(issues.join('\n\n'))),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: Text(dialogContext.l10n.commonOk),
          ),
        ],
      ),
    );
  }

  static String _timestamp(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final now = DateTime.now();
    // Keeps the clock component of "now" so a same-day batch posts at the time
    // it was actually submitted, while a back-dated one lands mid-morning
    // rather than at midnight.
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(now.hour)}:${two(now.minute)}:00';
  }
}
