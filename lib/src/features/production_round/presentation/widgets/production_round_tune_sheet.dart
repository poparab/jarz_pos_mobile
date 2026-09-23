import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/production_round_providers.dart';

const cycleDayOptions = [7, 14, 21];
const backupDayOptions = [0, 3, 7, 14];
const salesWeekOptions = [4, 8, 12];

/// The three planning knobs. Batch sizes are deliberately absent: they are a
/// property of the recipe, not something to tweak on a phone.
///
/// [current*] are the values the last payload was computed with, so the
/// selected chip always matches the numbers on screen even when the user has
/// never touched the sheet.
Future<void> showProductionRoundTuneSheet(
  BuildContext context, {
  required int currentCycleDays,
  required int currentBackupDays,
  required int currentSalesWeeks,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ProductionRoundTuneSheet(
      currentCycleDays: currentCycleDays,
      currentBackupDays: currentBackupDays,
      currentSalesWeeks: currentSalesWeeks,
    ),
  );
}

class ProductionRoundTuneSheet extends ConsumerWidget {
  const ProductionRoundTuneSheet({
    super.key,
    required this.currentCycleDays,
    required this.currentBackupDays,
    required this.currentSalesWeeks,
  });

  final int currentCycleDays;
  final int currentBackupDays;
  final int currentSalesWeeks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final params = ref.watch(productionRoundParamsProvider);
    // The latest payload wins over the values the sheet opened with, so a
    // reset shows the server's defaults as soon as they arrive.
    final latest = ref.watch(productionRoundProvider).valueOrNull;
    final cycle = params.cycleDays ?? latest?.cycleDays ?? currentCycleDays;
    final backup = params.backupDays ?? latest?.backupDays ?? currentBackupDays;
    final weeks = params.salesWeeks ?? latest?.salesWeeks ?? currentSalesWeeks;
    final notifier = ref.read(productionRoundParamsProvider.notifier);

    Widget group(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.productionRoundTuneTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            group(l10n.productionRoundTuneCycle, [
              for (final days in cycleDayOptions)
                ChoiceChip(
                  label: Text(l10n.productionRoundDaysValue(days)),
                  selected: cycle == days,
                  onSelected: (_) =>
                      notifier.state = params.copyWith(cycleDays: days),
                ),
            ]),
            group(l10n.productionRoundTuneBackup, [
              for (final days in backupDayOptions)
                ChoiceChip(
                  label: Text(l10n.productionRoundDaysValue(days)),
                  selected: backup == days,
                  onSelected: (_) =>
                      notifier.state = params.copyWith(backupDays: days),
                ),
            ]),
            group(l10n.productionRoundTuneSales, [
              for (final w in salesWeekOptions)
                ChoiceChip(
                  label: Text(l10n.productionRoundWeeksValue(w)),
                  selected: weeks == w,
                  onSelected: (_) =>
                      notifier.state = params.copyWith(salesWeeks: w),
                ),
            ]),
            Text(
              l10n.productionRoundTuneHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!params.isDefault)
                  TextButton(
                    onPressed: () =>
                        notifier.state = const ProductionRoundParams(),
                    child: Text(l10n.productionRoundTuneReset),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonDone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
