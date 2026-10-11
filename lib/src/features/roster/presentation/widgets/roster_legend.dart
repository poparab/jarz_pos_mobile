import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';
import '../roster_shift_palette.dart';

/// Opens the legend in a bottom sheet, from the ⓘ in the app bar.
///
/// It used to be an always-visible strip above the grid. Managers read it once;
/// after that it was two rows of chips pushing the people they were rostering
/// below the fold, so it now lives one tap away.
Future<void> showRosterLegendSheet(
  BuildContext context, {
  required RosterShiftPalette palette,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sheetContext.l10n.rosterLegendButton,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            RosterLegend(palette: palette),
          ],
        ),
      ),
    ),
  );
}

/// What the grid is showing, generated from the grid's own resolver.
///
/// Every entry comes from [RosterStyleResolver.legendEntries], which is built
/// by walking `RosterCellState.values` and [RosterStyleResolver.gridMarkers] —
/// so the legend cannot describe something the grid does not draw, and the
/// grid cannot draw something the legend leaves out. The previous version was
/// hand-listed and had drifted all the way to describing a `primaryContainer`
/// "Working" swatch that appeared nowhere on the screen, while the ~80% of
/// cells that actually were working days went unexplained.
///
/// The shift list below the states is the other half of that promise: a
/// working cell's colour is per shift type, so the only honest legend for it is
/// the list of this month's shift types with their colours and codes.
class RosterLegend extends StatelessWidget {
  const RosterLegend({super.key, required this.palette});

  final RosterShiftPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolver = RosterStyleResolver.of(context, palette: palette);
    final entries = resolver.legendEntries();
    final states = entries.where((e) => e.state != null).toList();
    final markers = entries.where((e) => e.marker != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(l10n.rosterLegendStatesTitle),
        _Entries(children: [for (final e in states) _LegendChip(entry: e)]),
        const SizedBox(height: 12),
        _SectionLabel(l10n.rosterLegendMarkersTitle),
        _Entries(children: [for (final e in markers) _LegendChip(entry: e)]),
        if (!palette.isEmpty) ...[
          const SizedBox(height: 12),
          _SectionLabel(l10n.rosterLegendShiftsTitle),
          _Entries(
            children: [
              for (final shift in palette.entries)
                _ShiftLegendChip(shift: shift),
            ],
          ),
        ],
      ],
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 12, runSpacing: 8, children: children);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One state or marker, drawn the way the grid draws it.
class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.entry});

  final RosterLegendEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: entry.foreground,
      fontWeight: FontWeight.w700,
      fontSize: 10,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final Widget swatch;
    if (entry.marker == RosterCellMarker.overtime) {
      // The overtime dot, after a sample number, exactly as the cell draws it.
      swatch = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rosterNumber(context, 12), style: textStyle),
          const SizedBox(width: 1),
          const RosterOvertimeDot(color: RosterColors.markerInk),
        ],
      );
    } else if (entry.marker != null) {
      swatch = Icon(entry.icon, size: 12, color: entry.foreground);
    } else {
      // A state: the cell draws its token (or, for a working day, the hours),
      // so the swatch does too — in the locale's own digits, like the grid.
      swatch = Text(
        entry.token.isEmpty ? rosterNumber(context, 9) : entry.token,
        style: textStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 22,
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
          child: FittedBox(fit: BoxFit.scaleDown, child: swatch),
        ),
        const SizedBox(width: 6),
        Text(entry.label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// The overtime marker as the grid draws it: one small dot beside the hours.
class RosterOvertimeDot extends StatelessWidget {
  const RosterOvertimeDot({super.key, required this.color});

  final Color color;

  /// Diameter. Small enough not to compete with the hours, large enough to
  /// see on a phone.
  static const double size = 6;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// One shift type: its colour, its code, and its name.
///
/// The code is what stops two similar colours being a silent collision. The
/// grid cell no longer prints it; the day sheet does.
class _ShiftLegendChip extends StatelessWidget {
  const _ShiftLegendChip({required this.shift});

  final RosterShiftStyle shift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
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
        const SizedBox(width: 6),
        Text(shift.shiftType, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
