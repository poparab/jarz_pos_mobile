import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';
import '../roster_shift_palette.dart';

/// What the grid is showing, generated from the grid's own resolver.
///
/// Every entry comes from [RosterStyleResolver.legendEntries], which is built
/// by walking `RosterCellState.values` and `RosterCellMarker.values` — so the
/// legend cannot describe something the grid does not draw, and the grid cannot
/// draw something the legend leaves out. The previous version was hand-listed
/// and had drifted all the way to describing a `primaryContainer` "Working"
/// swatch that appeared nowhere on the screen, while the ~80% of cells that
/// actually were working days went unexplained.
///
/// The shift strip below the states is the other half of that promise: a
/// working cell's colour is per shift type, so the only honest legend for it is
/// the list of this month's shift types with their colours and codes.
class RosterLegend extends StatelessWidget {
  const RosterLegend({super.key, required this.palette});

  final RosterShiftPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final resolver = RosterStyleResolver.of(context, palette: palette);
    final entries = resolver.legendEntries();
    final states = entries.where((e) => e.state != null).toList();
    final markers = entries.where((e) => e.marker != null).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SectionLabel(l10n.rosterLegendStatesTitle),
                for (final entry in states) _LegendChip(entry: entry),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  color: theme.dividerColor,
                ),
                _SectionLabel(l10n.rosterLegendMarkersTitle),
                for (final entry in markers) _LegendChip(entry: entry),
              ],
            ),
          ),
          if (!palette.isEmpty) ...[
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SectionLabel(l10n.rosterLegendShiftsTitle),
                  for (final shift in palette.entries)
                    _ShiftLegendChip(shift: shift),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One state or marker, drawn the way the cell draws it.
class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.entry});

  final RosterLegendEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: entry.borderWidth > 0
                    ? entry.borderColor
                    : theme.dividerColor,
                width: entry.borderWidth > 0 ? entry.borderWidth : 1,
              ),
            ),
            child: entry.icon != null
                ? Icon(entry.icon, size: 12, color: entry.foreground)
                : Text(
                    // A working cell's token IS its hours, so the swatch shows
                    // a sample number — in the locale's own digits, like the
                    // grid.
                    entry.token.isEmpty
                        ? rosterNumber(context, 9)
                        : entry.token,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: entry.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
          const SizedBox(width: 5),
          Text(entry.label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// One shift type: its colour, its code, and its name.
///
/// The code is what stops two similar colours being a silent collision, and it
/// is the same code the cell prints in its corner.
class _ShiftLegendChip extends StatelessWidget {
  const _ShiftLegendChip({required this.shift});

  final RosterShiftStyle shift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shift.color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              shift.code,
              style: theme.textTheme.labelSmall?.copyWith(
                color: shift.onColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(shift.shiftType, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
