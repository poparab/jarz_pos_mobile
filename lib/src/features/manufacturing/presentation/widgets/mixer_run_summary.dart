import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/daily_plan.dart';

/// The answer the morning screen owes the floor: how many mixes, and how to
/// split them.
///
/// Pinned rather than scrolled to, because it changes on every jar entered and
/// is the only reason this screen exists. Each run carries its quality — a plan
/// that quietly schedules the sizes the mixer handles badly would look
/// identical to a good one otherwise.
class MixerRunSummary extends StatelessWidget {
  const MixerRunSummary({
    super.key,
    required this.preview,
    required this.calculating,
    required this.mixUom,
    required this.totalJars,
    this.onSave,
    this.onCheckMaterials,
  });

  final DailyPlanPreview? preview;
  final bool calculating;
  final String mixUom;
  final int totalJars;
  final VoidCallback? onSave;
  final VoidCallback? onCheckMaterials;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = preview;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.dailyPlanTotalJars(totalJars),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  if (calculating)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (data == null)
                Text(
                  l10n.dailyPlanEnterQuantities,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else ...[
                Text(
                  l10n.dailyPlanMixTotal(
                    _fmt(data.totalMixQty),
                    mixUom,
                    _fmt(data.requiredBatches),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                if (data.runs.isEmpty)
                  Text(
                    l10n.dailyPlanNoRuns,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final run in data.runs) _RunChip(run: run),
                    ],
                  ),
                if (data.overproductionBatches > 0.001) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.dailyPlanSpareMix(_fmt(data.overproductionBatches)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
                if (data.materials?.unavailable == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.dailyPlanMaterialsUnavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (data.materials != null &&
                    data.materials!.shortages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ShortageList(shortages: data.materials!.shortages),
                ],
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCheckMaterials,
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(l10n.dailyPlanCheckMaterials),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(l10n.dailyPlanSave),
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

  /// Trims the trailing zeros a Float carries so "2" does not read as "2.000".
  static String _fmt(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

class _RunChip extends StatelessWidget {
  const _RunChip({required this.run});

  final MixerRun run;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final (colour, label) = switch (run.quality) {
      RunQuality.preferred => (scheme.primary, l10n.dailyPlanRunPreferred),
      RunQuality.acceptable => (scheme.tertiary, l10n.dailyPlanRunAcceptable),
      RunQuality.poor => (scheme.error, l10n.dailyPlanRunPoor),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MixerRunSummary._fmt(run.size),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: colour),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colour),
          ),
        ],
      ),
    );
  }
}

class _ShortageList extends StatelessWidget {
  const _ShortageList({required this.shortages});

  final List<MaterialShortage> shortages;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dailyPlanShortages(shortages.length),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.error, fontWeight: FontWeight.w600),
        ),
        // Only the worst few: the roll-up can list dozens of components and this
        // bar has to stay a summary.
        for (final shortage in shortages.take(3))
          Text(
            l10n.dailyPlanShortageLine(
              shortage.itemName.isNotEmpty
                  ? shortage.itemName
                  : shortage.itemCode,
              MixerRunSummary._fmt(shortage.missingQty),
              shortage.uom,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (shortages.length > 3)
          Text(
            l10n.dailyPlanShortagesMore(shortages.length - 3),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}
