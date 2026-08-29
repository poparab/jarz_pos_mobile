import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// What the cell colours mean.
///
/// Carried because one of the four states — the empty cell — has a consequence
/// that is not guessable from looking at it: an unrostered day now refuses the
/// check-in, so a blank square is the difference between somebody working and
/// somebody being turned away at the door.
class RosterLegend extends StatelessWidget {
  const RosterLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            _LegendChip(
              color: theme.colorScheme.primaryContainer,
              label: l10n.rosterLegendWorking,
            ),
            _LegendChip(
              color: theme.colorScheme.tertiaryContainer,
              label: l10n.rosterLegendOff,
            ),
            _LegendChip(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              label: l10n.rosterLegendUnrostered,
            ),
            _LegendChip(
              color: theme.colorScheme.surfaceContainerHighest,
              label: l10n.rosterLegendHoliday,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: theme.dividerColor),
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
