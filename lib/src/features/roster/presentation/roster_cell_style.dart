/// The one place that decides what a roster day looks like.
///
/// Everything that draws a day — the grid cell, the legend, the day sheet's
/// header — resolves through [RosterStyleResolver]. That is the point: before
/// this existed the screen carried five different colour mappings for the same
/// six states, and the legend described a `primaryContainer` "Working" swatch
/// that the grid had never once drawn.
///
/// Two rules hold throughout:
/// * **one meaning per hue** — red is "this blocks somebody working", amber is
///   "nobody has this covered", green is "off and handled", indigo is "public
///   holiday", and an unfilled cell is "nothing happened here". No hue is
///   reused for chrome, and chrome (headers, control bar) uses no state hue;
/// * **never colour alone** — every state also carries an icon or a text token,
///   so the grid still reads under glare, on a cheap screen, or to the roughly
///   1 in 12 men who cannot separate the red and the green.
library;

import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../models/roster_models.dart';
import 'roster_shift_palette.dart';

/// The six things a day can be. Exhaustive by construction: the legend is
/// generated from `RosterCellState.values`, so a state cannot be added to the
/// grid without appearing in the legend.
enum RosterCellState {
  /// Rostered onto a shift.
  working,

  /// A granted day off with a colleague named to absorb it.
  offCovered,

  /// A granted day off with nobody named — the mistake the screen exists to
  /// catch, and the reason the top banner exists.
  offUncovered,

  /// On the shift type's holiday list and not working.
  holiday,

  /// Today or later with no assignment: the check-in gate will turn this
  /// person away, and nobody decided that.
  unrosteredFuture,

  /// Already gone, with no assignment. HRMS retires assignments once their end
  /// date passes, so this is ordinary history rather than a problem — drawn as
  /// an empty outline so it recedes instead of shouting.
  unrosteredPast,
}

/// Things that can be true *on top of* a state.
///
/// Kept separate from [RosterCellState] because they combine: one cell can be
/// a cover day, over the normal day's hours, and on a public holiday at once.
/// Markers are distinguished by glyph and drawn in one ink, so they stay
/// readable over whatever colour Desk gave the shift type.
enum RosterCellMarker {
  /// More hours than this person's normal day — the comparison the standard
  /// hours under their name exists to invite.
  overtime,

  /// This person is absorbing a colleague's day off.
  cover,

  /// Working a day on the holiday list.
  holidayWorked,

  /// Friday or Saturday: Egypt's weekend is both days. Drawn on the column
  /// header, never on a cell, so it cannot be mistaken for a state.
  weekend,

  /// Part of the current bulk selection.
  selected,
}

/// Light-mode-only semantic colours.
///
/// Hard-coded rather than pulled from `ColorScheme` for two reasons. First, the
/// scheme has no "warning" role, and the previous screen borrowed `error` for
/// it — which is how one hue ended up meaning a gap, an unrostered day and a
/// destructive button at the same time. Second, `core/app.dart` declares
/// `theme:` with no `darkTheme`/`themeMode`, so there is exactly one brightness
/// to design against; the old dark-mode branch in the cell painter was dead
/// code that could never run.
abstract final class RosterColors {
  /// "This stops somebody working."
  static const attentionFill = Color(0xFFFBE0DD);
  static const attentionInk = Color(0xFF8C1D18);
  static const attentionLine = Color(0xFFB3261E);

  /// "Nobody has this covered."
  static const riskFill = Color(0xFFFFE3AC);
  static const riskInk = Color(0xFF5F3D00);
  static const riskLine = Color(0xFFB26A00);

  /// "Off, and handled."
  static const settledFill = Color(0xFFD6EED8);
  static const settledInk = Color(0xFF12501A);
  static const settledLine = Color(0xFF3E8A44);

  /// "Public holiday."
  static const holidayFill = Color(0xFFE1DEF6);
  static const holidayInk = Color(0xFF2F2A63);
  static const holidayLine = Color(0xFF6E63C4);

  /// "Nothing happened here" — an outline, not a fill, so it cannot be
  /// confused with the grey chrome of the headers.
  static const emptyFill = Color(0x00000000);
  static const emptyInk = Color(0xFF7A756F);
  static const emptyLine = Color(0xFFDCD8D4);

  /// Markers: one ink, told apart by glyph.
  static const markerInk = Color(0xFF1B1B1B);
  static const markerChip = Color(0xFFFFFFFF);

  /// Weekend columns (Friday and Saturday). A warm neutral on the header band
  /// only — deliberately not one of the state hues.
  static const weekendHeader = Color(0xFFF3E9DA);

  static const transparent = Color(0x00000000);
}

/// How one state is drawn, everywhere it is drawn.
@immutable
class RosterCellStyle {
  const RosterCellStyle({
    required this.state,
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.borderWidth,
    required this.icon,
    required this.token,
    required this.label,
    this.accent,
    this.shiftCode,
  });

  final RosterCellState state;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;

  /// The glyph half of "never colour alone". Null only for [working] and
  /// [unrosteredPast], the two states whose text token is already unique: a
  /// number for one, a lone dot for the other.
  final IconData? icon;

  /// The text half — `OFF`, `HOL`, `—`, `·`, or empty for [working], where the
  /// hours take the token's place.
  final String token;

  /// The legend wording, reused verbatim as the cell's semantics label.
  final String label;

  /// The shift type's own colour, for [working] only.
  final Color? accent;

  /// The shift type's short code, for [working] only.
  final String? shiftCode;

  bool get hasBorder => borderWidth > 0;
}

/// How one marker is drawn.
@immutable
class RosterMarkerStyle {
  const RosterMarkerStyle({
    required this.marker,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.borderColor = RosterColors.transparent,
    this.borderWidth = 0,
  });

  final RosterCellMarker marker;
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;
}

/// One row of the legend. A legend entry is either a state or a marker, never
/// invented separately from them.
@immutable
class RosterLegendEntry {
  RosterLegendEntry.forState(RosterCellStyle style)
    : state = style.state,
      marker = null,
      background = style.background,
      foreground = style.foreground,
      borderColor = style.borderColor,
      borderWidth = style.borderWidth,
      icon = style.icon,
      token = style.token,
      label = style.label;

  RosterLegendEntry.forMarker(RosterMarkerStyle style)
    : state = null,
      marker = style.marker,
      background = style.background,
      foreground = style.foreground,
      borderColor = style.borderColor,
      borderWidth = style.borderWidth,
      icon = style.icon,
      token = '',
      label = style.label;

  final RosterCellState? state;
  final RosterCellMarker? marker;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;
  final IconData? icon;
  final String token;
  final String label;
}

/// Resolves a [RosterCell] to a state, its markers, and the style for both.
///
/// Holds the localisations and the shift palette so a caller cannot accidentally
/// resolve half a cell against one month's palette and half against another's.
class RosterStyleResolver {
  RosterStyleResolver({
    required this.palette,
    required this.l10n,
    DateTime? today,
  }) : today = _dateOnly(today ?? DateTime.now());

  factory RosterStyleResolver.of(
    BuildContext context, {
    required RosterShiftPalette palette,
    DateTime? today,
  }) {
    return RosterStyleResolver(
      palette: palette,
      l10n: AppLocalizations.of(context),
      today: today,
    );
  }

  final RosterShiftPalette palette;
  final AppLocalizations l10n;

  /// Injected rather than read from the clock inside the resolver so "past"
  /// versus "future" is testable, and so every cell in one build agrees about
  /// where the boundary is even if the build straddles midnight.
  final DateTime today;

  /// Which of the six states [cell] is on [date].
  ///
  /// A missing cell is not a separate state: the backend simply omits days it
  /// has nothing to say about, and "nothing to say" is exactly unrostered.
  RosterCellState stateFor({required RosterCell? cell, required String date}) {
    if (cell != null) {
      if (cell.isOff) {
        return cell.dayOff!.isCovered
            ? RosterCellState.offCovered
            : RosterCellState.offUncovered;
      }
      if (cell.isWorking) return RosterCellState.working;
      if (cell.isHoliday) return RosterCellState.holiday;
    }
    return isPast(date)
        ? RosterCellState.unrosteredPast
        : RosterCellState.unrosteredFuture;
  }

  /// Whether [date] has already gone.
  ///
  /// Date-only: today must never count as past, because today is the one day
  /// where an empty cell has an immediate consequence.
  bool isPast(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return false;
    return _dateOnly(parsed).isBefore(today);
  }

  /// Everything true about this cell on top of its state.
  Set<RosterCellMarker> markersFor({
    required RosterCell? cell,
    required RosterEmployee employee,
    bool isCover = false,
    bool isSelected = false,
  }) {
    final markers = <RosterCellMarker>{};
    if (isSelected) markers.add(RosterCellMarker.selected);
    if (cell == null) return markers;
    if (isCover) markers.add(RosterCellMarker.cover);
    if (cell.isWorking) {
      if (cell.isHoliday) markers.add(RosterCellMarker.holidayWorked);
      if (isOvertime(cell: cell, employee: employee)) {
        markers.add(RosterCellMarker.overtime);
      }
    }
    return markers;
  }

  /// More hours than the person's normal day.
  ///
  /// The tolerance keeps a 9.0 against a 9.0 standard from flagging on a float
  /// that arrived as 9.000000001; a standard of 0 means nobody set a baseline,
  /// and inventing one would mark every shift as overtime.
  bool isOvertime({required RosterCell cell, required RosterEmployee employee}) {
    if (employee.standardHours <= 0) return false;
    return cell.hours > employee.standardHours + 0.01;
  }

  /// The style for a state. [shiftType] is used only by [working].
  RosterCellStyle styleFor(
    RosterCellState state, {
    String? shiftType,
  }) {
    switch (state) {
      case RosterCellState.working:
        final shift = shiftType == null || shiftType.trim().isEmpty
            ? null
            : palette.styleFor(shiftType);
        final color = shift?.color ?? palette.representativeColor;
        return RosterCellStyle(
          state: state,
          background: color,
          foreground: RosterShiftPalette.readableOn(color),
          borderColor: RosterColors.transparent,
          borderWidth: 0,
          icon: null,
          token: '',
          label: l10n.rosterLegendWorkingHours,
          accent: color,
          shiftCode: shift?.code,
        );
      case RosterCellState.offCovered:
        return RosterCellStyle(
          state: state,
          background: RosterColors.settledFill,
          foreground: RosterColors.settledInk,
          borderColor: RosterColors.settledLine,
          borderWidth: 1,
          icon: Icons.check_circle,
          token: l10n.rosterOffShort,
          label: l10n.rosterLegendOffCovered,
        );
      case RosterCellState.offUncovered:
        // The heaviest treatment on the grid on purpose. This used to be a
        // 10px icon in `onTertiaryContainer` — the warning was not
        // warning-coloured, and the difference between a covered day off and
        // an uncovered one was the shape of a tiny glyph.
        return RosterCellStyle(
          state: state,
          background: RosterColors.riskFill,
          foreground: RosterColors.riskInk,
          borderColor: RosterColors.riskLine,
          borderWidth: 2,
          icon: Icons.warning_amber_rounded,
          token: l10n.rosterOffShort,
          label: l10n.rosterLegendOffUncovered,
        );
      case RosterCellState.holiday:
        return RosterCellStyle(
          state: state,
          background: RosterColors.holidayFill,
          foreground: RosterColors.holidayInk,
          borderColor: RosterColors.holidayLine,
          borderWidth: 1,
          icon: Icons.flag_outlined,
          token: l10n.rosterHolidayShort,
          label: l10n.rosterLegendHoliday,
        );
      case RosterCellState.unrosteredFuture:
        return RosterCellStyle(
          state: state,
          background: RosterColors.attentionFill,
          foreground: RosterColors.attentionInk,
          borderColor: RosterColors.attentionLine,
          borderWidth: 1.5,
          icon: Icons.block,
          token: '—',
          label: l10n.rosterLegendNotRosteredFuture,
        );
      case RosterCellState.unrosteredPast:
        return RosterCellStyle(
          state: state,
          background: RosterColors.emptyFill,
          foreground: RosterColors.emptyInk,
          borderColor: RosterColors.emptyLine,
          borderWidth: 1,
          icon: null,
          token: '·',
          label: l10n.rosterLegendNotRosteredPast,
        );
    }
  }

  RosterMarkerStyle markerStyle(RosterCellMarker marker) {
    switch (marker) {
      case RosterCellMarker.overtime:
        return RosterMarkerStyle(
          marker: marker,
          icon: Icons.trending_up,
          label: l10n.rosterLegendMarkerOvertime,
          background: RosterColors.markerChip,
          foreground: RosterColors.markerInk,
        );
      case RosterCellMarker.cover:
        return RosterMarkerStyle(
          marker: marker,
          icon: Icons.swap_horiz,
          label: l10n.rosterLegendMarkerCover,
          background: RosterColors.markerChip,
          foreground: RosterColors.markerInk,
        );
      case RosterCellMarker.holidayWorked:
        return RosterMarkerStyle(
          marker: marker,
          icon: Icons.flag,
          label: l10n.rosterLegendMarkerHolidayWorked,
          background: RosterColors.markerChip,
          foreground: RosterColors.markerInk,
        );
      case RosterCellMarker.weekend:
        return RosterMarkerStyle(
          marker: marker,
          icon: Icons.weekend_outlined,
          label: l10n.rosterLegendMarkerWeekend,
          background: RosterColors.weekendHeader,
          foreground: RosterColors.markerInk,
        );
      case RosterCellMarker.selected:
        return RosterMarkerStyle(
          marker: marker,
          icon: Icons.check,
          label: l10n.rosterLegendMarkerSelected,
          background: RosterColors.markerChip,
          foreground: RosterColors.markerInk,
          borderColor: selectionColor,
          borderWidth: 2,
        );
    }
  }

  /// The bulk-selection border. The one place a `ColorScheme` role is still
  /// used for a cell, because selection is app chrome rather than roster
  /// meaning — and it is a border, not a fill, so it never competes with a
  /// state's hue.
  static const Color selectionColor = Color(0xFF1A4FCC);

  /// Every state, then every marker — the legend, in order.
  ///
  /// Generated from the enums rather than hand-listed: this is what makes
  /// "the legend describes the grid" a property of the code instead of a
  /// promise somebody has to keep.
  List<RosterLegendEntry> legendEntries() => <RosterLegendEntry>[
    for (final state in RosterCellState.values)
      RosterLegendEntry.forState(styleFor(state)),
    for (final marker in RosterCellMarker.values)
      RosterLegendEntry.forMarker(markerStyle(marker)),
  ];

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Egypt's weekend is Friday **and** Saturday. The grid used to tint Friday
/// only, which quietly told every manager that Saturday was a working day.
bool isRosterWeekend(DateTime date) =>
    date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
