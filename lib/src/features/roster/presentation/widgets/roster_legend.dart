import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';

/// Opens the legend in a bottom sheet, from the ⓘ in the app bar.
///
/// It used to be an always-visible strip above the grid. Managers read it once;
/// after that it was two rows of chips pushing the people they were rostering
/// below the fold, so it now lives one tap away.
Future<void> showRosterLegendSheet(BuildContext context) {
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
            const RosterLegend(),
          ],
        ),
      ),
    ),
  );
}

/// The sample shift the legend's "working" entry writes, so the swatch shows
/// the same kind of text a working cell does (`9a–6p`).
const RosterShift rosterLegendSampleShift = RosterShift(
  shiftType: '',
  startTime: '09:00:00',
  endTime: '18:00:00',
  hours: 9,
);

/// What the grid is showing, generated from the grid's own resolver.
///
/// Every entry comes from [RosterStyleResolver.legendEntries], which is built
/// by walking `RosterCellState.values` and [RosterStyleResolver.gridMarkers] —
/// so the legend cannot describe something the grid does not draw, and the
/// grid cannot draw something the legend leaves out.
///
/// Three short sections: the two coloured "needs fixing" states first — the
/// only colours on the board — then the neutral cells, which say what they
/// are in words, then the markers.
class RosterLegend extends StatelessWidget {
  const RosterLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolver = RosterStyleResolver.of(context);
    final entries = resolver.legendEntries();
    final problems = entries.where((e) => e.isProblem).toList();
    final text = entries
        .where((e) => e.state != null && !e.isProblem)
        .toList();
    final markers = entries.where((e) => e.marker != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(l10n.rosterLegendProblemsTitle),
        _Entries(children: [for (final e in problems) _LegendChip(entry: e)]),
        const SizedBox(height: 12),
        _SectionLabel(l10n.rosterLegendTextTitle),
        _Entries(children: [for (final e in text) _LegendChip(entry: e)]),
        const SizedBox(height: 12),
        _SectionLabel(l10n.rosterLegendMarkersTitle),
        _Entries(children: [for (final e in markers) _LegendChip(entry: e)]),
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
    final l10n = context.l10n;
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: entry.foreground,
      fontWeight: FontWeight.w700,
      fontSize: 10,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final Widget swatch;
    if (entry.marker == RosterCellMarker.overtime) {
      // The overtime dot, after a sample start time, as the cell draws it.
      swatch = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rosterShiftTimeText(
                  rosterLegendSampleShift,
                  l10n,
                  withEnd: false,
                ) ??
                '',
            style: textStyle,
          ),
          const SizedBox(width: 1),
          const RosterOvertimeDot(color: RosterColors.markerInk),
        ],
      );
    } else if (entry.marker != null) {
      swatch = Icon(entry.icon, size: 12, color: entry.foreground);
    } else {
      // A state: the cell writes its word (or, for a working day, the shift's
      // time), so the swatch does too — with the warning / flag glyph where
      // the cell draws one.
      final word = entry.state == RosterCellState.working
          ? rosterShiftTimeText(rosterLegendSampleShift, l10n, withEnd: true)
          : entry.token;
      final showIcon =
          entry.state == RosterCellState.offUncovered ||
          entry.state == RosterCellState.holiday;
      swatch = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(entry.icon, size: 10, color: entry.foreground),
            const SizedBox(width: 2),
          ],
          Text(word ?? '', style: textStyle),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 24,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 3),
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

/// The overtime marker as the grid draws it: one small dot beside the time.
class RosterOvertimeDot extends StatelessWidget {
  const RosterOvertimeDot({super.key, required this.color});

  final Color color;

  /// Diameter. Small enough not to compete with the time, large enough to
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
