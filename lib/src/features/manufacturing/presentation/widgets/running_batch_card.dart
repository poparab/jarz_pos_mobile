import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/running_batch.dart';
import 'batch_cost_panel.dart';
import 'production_format.dart';
import 'view_sop_button.dart';

/// One batch that is started but not finished.
///
/// The card exists because production is now two moments instead of one. The
/// old flow filed the transfer and the manufacture entry back to back, so there
/// was no in-progress state to look at — and no place for material that went
/// into WIP and never came out to become visible.
class RunningBatchCard extends StatefulWidget {
  const RunningBatchCard({
    super.key,
    required this.batch,
    this.onFinish,
    this.onViewSop,
    this.onReturnWip,
    this.onCancel,
    this.onPrint,
  });

  final RunningBatch batch;

  /// Null hides the action — used to gate on execute permission.
  final VoidCallback? onFinish;

  /// Null hides the SOP button. The card never imports the SOP feature: the tab
  /// owns the navigation so this stays a leaf widget.
  final VoidCallback? onViewSop;

  /// Manager-only. Null hides the action even when WIP is stranded, so an
  /// operator sees the problem without being handed a stock correction.
  final VoidCallback? onReturnWip;

  /// Abort the batch: WIP goes back to the store and the Work Order stops.
  ///
  /// Sits next to Finish because those are the two ways a started batch ends,
  /// and hiding one of them behind a menu is what left "finish a batch that was
  /// never made" as the only exit. Hidden once anything has been produced —
  /// the server refuses that case, and offering a button that always fails is
  /// worse than not offering one.
  final VoidCallback? onCancel;

  /// Null hides the printer action — the tab owns the printer service so this
  /// widget stays free of Bluetooth and of the web/mobile conditional import.
  final VoidCallback? onPrint;

  @override
  State<RunningBatchCard> createState() => _RunningBatchCardState();
}

class _RunningBatchCardState extends State<RunningBatchCard> {
  bool _showCost = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final batch = widget.batch;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: batch.hasWipLeftover ? scheme.error : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.itemName.isEmpty ? batch.itemCode : batch.itemName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        batch.workOrder,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ElapsedChip(minutes: batch.elapsedMinutes),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.productionPlannedVsProduced(
                '${trimQty(batch.qty)} ${batch.stockUom}'.trim(),
                trimQty(batch.producedQty),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            if (_startedAt(batch) == null)
              // Kept as a note rather than a hard block: the server owns the
              // rule, and a card that refuses to finish because a timestamp is
              // missing would strand real material on the floor.
              Row(
                children: [
                  Icon(Icons.help_outline, size: 14, color: scheme.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.productionNotStartedYet,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              )
            else
              Text(
                l10n.productionRunningSince(
                  formatDateTime(
                    context,
                    _startedAt(batch)!,
                    pattern: 'MMM d • h:mm a',
                  ),
                  batch.startedBy ?? l10n.commonNotSpecified,
                ),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            if (batch.hasWipLeftover) ...[
              const SizedBox(height: 10),
              _WipLeftoverBanner(
                batch: batch,
                onReturnWip: widget.onReturnWip,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.productionCostTitle,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    _showCost ? Icons.expand_less : Icons.payments_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _showCost = !_showCost),
                ),
                if (widget.onPrint != null)
                  IconButton(
                    tooltip: l10n.productionPrintBatchSheet,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.print_outlined, size: 20),
                    onPressed: widget.onPrint,
                  ),
                // The shared widget rather than a second copy of the same
                // affordance: it hides itself when there is no SOP, so the
                // null-check lives in one place.
                ViewSopButton(
                  onTap: widget.onViewSop,
                  hasSop: widget.onViewSop != null,
                ),
                const Spacer(),
                if (widget.onCancel != null) ...[
                  TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.error,
                    ),
                    child: Text(l10n.productionCancelBatch),
                  ),
                  const SizedBox(width: 4),
                ],
                if (widget.onFinish != null)
                  FilledButton(
                    onPressed: widget.onFinish,
                    child: Text(l10n.productionFinish),
                  ),
              ],
            ),
            if (_showCost) ...[
              const Divider(height: 16),
              BatchCostPanel(workOrder: batch.workOrder),
            ],
          ],
        ),
      ),
    );
  }

  /// Frappe hands back a naive local datetime string; anything unparseable is
  /// treated as absent rather than rendered raw.
  DateTime? _startedAt(RunningBatch batch) {
    final raw = (batch.startedAt ?? '').trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// The stranded-WIP warning.
///
/// Deliberately loud. Material transferred into WIP and never consumed is the
/// one number in this flow that nobody goes looking for: it does not show up on
/// the board, it does not block anything, and it only ever surfaces months later
/// as a variance nobody can explain.
class _WipLeftoverBanner extends StatelessWidget {
  const _WipLeftoverBanner({required this.batch, this.onReturnWip});

  final RunningBatch batch;
  final VoidCallback? onReturnWip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.productionWipLeftover(
                trimQty(batch.wipLeftoverQty, decimals: 3),
                batch.stockUom,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onReturnWip != null) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: onReturnWip,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
              ),
              child: Text(l10n.productionReturnToStore),
            ),
          ],
        ],
      ),
    );
  }
}

class _ElapsedChip extends StatelessWidget {
  const _ElapsedChip({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            // A batch that has been on the bench three hours should read
            // "3h 5m", not "185 min" — the operator is judging elapsed time at
            // a glance, not doing division.
            _formatElapsed(context, minutes),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Elapsed minutes as "3h 5m" once past the hour, "45 min" below it.
///
/// A batch on the bench since breakfast reads as "185 min" otherwise, which
/// makes the operator do the division the board is supposed to do for them.
String _formatElapsed(BuildContext context, int minutes) {
  final l10n = context.l10n;
  final safe = minutes < 0 ? 0 : minutes;
  if (safe < 60) return l10n.productionElapsedMinutes(safe);
  return l10n.productionElapsed(safe ~/ 60, safe % 60);
}
