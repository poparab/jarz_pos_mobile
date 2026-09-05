import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/reason_prompt_dialog.dart';
import '../../../printing/pos_printer_provider.dart';
import '../../../printing/pos_printer_service.dart'
    if (dart.library.html) '../../../printing/pos_printer_service_web.dart';
import '../../data/models/running_batch.dart';
import '../../state/running_batches_notifier.dart';
import '../widgets/finish_batch_sheet.dart';
import '../widgets/production_format.dart';
import '../widgets/running_batch_card.dart';

/// "What is on the floor right now?"
///
/// The tab that only exists because starting and finishing became two separate
/// moments. Everything half-done lives here, including the material that went
/// into WIP and has not come back out.
class ProductionRunningTab extends ConsumerWidget {
  const ProductionRunningTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final batchesAsync = ref.watch(runningBatchesProvider);

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorRetry(
        message: context.userErrorMessage(error, fallback: l10n.commonError),
        onRetry: () => ref.invalidate(runningBatchesProvider),
      ),
      data: (batches) {
        final canExecute = ref.watch(canExecuteProductionProvider);
        final canManageWip = ref.watch(canManageProductionWipProvider);

        return RefreshIndicator(
          onRefresh: () => ref.read(runningBatchesProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              if (batches.isEmpty)
                SliverFillRemaining(
                  // hasScrollBody false still leaves the view scrollable, so
                  // pull-to-refresh works on the empty state too — otherwise the
                  // only way out of an empty list is to leave the screen.
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.productionRunningEmpty)),
                )
              else
                SliverPadding(
                  padding: ResponsiveUtils.getResponsivePadding(
                    context,
                    small: 10,
                    medium: 12,
                    large: 12,
                  ),
                  sliver: SliverList.separated(
                    itemCount: batches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final batch = batches[index];
                      return RunningBatchCard(
                        batch: batch,
                        onFinish: canExecute
                            ? () => _finish(context, ref, batch)
                            : null,
                        onViewSop: batch.hasSop
                            ? () => _openSop(context, batch)
                            : null,
                        onReturnWip: canManageWip
                            ? () => _returnWip(context, ref, batch)
                            : null,
                        // Hidden once anything has been produced: the server
                        // refuses that case outright, and the batch has to be
                        // finished for what it actually made.
                        onCancel: canExecute && batch.producedQty <= 0
                            ? () => _cancelBatch(context, ref, batch)
                            : null,
                        onPrint: () => _printBatchSheet(context, ref, batch),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  /// Navigates by route so this tab never imports the SOP feature.
  ///
  /// The keys are the snake_case shape the SOP screen's launch args accept.
  /// No batch count is sent on purpose: with a Work Order the SOP is fetched by
  /// work order, which pins the version stamped at start and is scaled
  /// server-side from the order's own quantity — sending a client-side batch
  /// count would be a second, worse answer to a question already settled.
  void _openSop(BuildContext context, RunningBatch batch) {
    context.push(
      AppRoutes.productionSop,
      extra: <String, dynamic>{
        'work_order': batch.workOrder,
        'item_code': batch.itemCode,
        'item_name': batch.itemName,
        'bom': batch.bomName,
      },
    );
  }

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    RunningBatch batch,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final result = await showFinishBatchSheet(context, batch: batch);
    if (result == null) return;

    ref.invalidate(runningBatchesProvider);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.productionFinished(
            trimQty(result.actualQty, decimals: 3),
            batch.stockUom,
          ),
        ),
      ),
    );

    // The finished Work Order drops off this list, and with it the only place
    // leftover WIP was visible. Said once, loudly, while somebody is still
    // holding the phone.
    if (result.hasWipLeftover && context.mounted) {
      await _warnAboutLeftover(context, ref, batch, result.wipLeftoverQty);
    }
  }

  Future<void> _warnAboutLeftover(
    BuildContext context,
    WidgetRef ref,
    RunningBatch batch,
    double leftover,
  ) {
    final canManageWip = ref.read(canManageProductionWipProvider);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: Text(
          dialogContext.l10n.productionWipLeftover(
            trimQty(leftover, decimals: 3),
            batch.stockUom,
          ),
        ),
        actions: [
          if (canManageWip)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _returnWip(context, ref, batch);
              },
              child: Text(dialogContext.l10n.productionReturnToStore),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.commonOk),
          ),
        ],
      ),
    );
  }

  /// Prints the paper that goes on the bench with the batch.
  ///
  /// Reconnects to the last saved printer first, exactly like the Kanban
  /// receipt action — a disconnected Bluetooth printer is the normal state
  /// between two prints, not an error worth showing.
  Future<void> _printBatchSheet(
    BuildContext context,
    WidgetRef ref,
    RunningBatch batch,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final printer = ref.read(posPrinterServiceProvider);

    if (!printer.isConnected && !printer.isClassicConnected) {
      final ok = await printer.connectLastSaved();
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.invoicePrinterNotConnectedHint)),
        );
        return;
      }
    }

    final result = await printer.printBatchSheet(
      PrintableBatchSheet(
        workOrder: batch.workOrder,
        itemName: batch.itemName.isEmpty ? batch.itemCode : batch.itemName,
        itemCode: batch.itemCode,
        plannedQty: batch.qty,
        uom: batch.stockUom,
        bom: batch.bomName.isEmpty ? null : batch.bomName,
        startedAt: DateTime.tryParse((batch.startedAt ?? '').trim()),
        startedBy: batch.startedBy,
        sopVersion: batch.sopVersion,
      ),
    );

    switch (result) {
      case PrintResult.success:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.invoicePrintedSuccessfully)),
        );
      case PrintResult.disconnected:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.invoicePrinterDisconnected)),
        );
      case PrintResult.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(context.userErrorMessage(result, fallback: l10n.printerStatusError))),
        );
    }
  }

  /// Aborts a batch that was started and must not be finished.
  ///
  /// The dialog spells out what happens to the material, because the operator's
  /// real question is "where does the cream go" — and answers it before asking
  /// for the reason the server requires.
  Future<void> _cancelBatch(
    BuildContext context,
    WidgetRef ref,
    RunningBatch batch,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final reason = await promptForReason(
      context,
      title: l10n.productionCancelBatchTitle,
      message: l10n.productionCancelBatchBody(
        batch.itemName.isEmpty ? batch.itemCode : batch.itemName,
      ),
      hint: l10n.productionCancelBatchHint,
      confirmLabel: l10n.productionCancelBatchConfirm,
    );
    if (reason == null || !context.mounted) return;

    ref.loading.show(l10n.productionSubmitting);
    try {
      await ref.read(runningBatchesProvider.notifier).cancel(
            workOrder: batch.workOrder,
            reason: reason,
          );
    } catch (error) {
      ref.loading.hide();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
      return;
    }
    ref.loading.hide();

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.productionBatchCancelled)),
    );
  }

  Future<void> _returnWip(
    BuildContext context,
    WidgetRef ref,
    RunningBatch batch,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    ref.loading.show(l10n.productionSubmitting);
    try {
      await ref.read(runningBatchesProvider.notifier).returnWip(batch.workOrder);
    } catch (error) {
      ref.loading.hide();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
      return;
    }
    ref.loading.hide();

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.productionReturnedToStore)),
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
