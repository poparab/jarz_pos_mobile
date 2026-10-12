/// The one place that decides what a roster day looks like.
///
/// Everything that draws a day — the grid cell, the legend, the day sheet's
/// header — resolves through [RosterStyleResolver]. That is the point: before
/// this existed the screen carried five different colour mappings for the same
/// six states, and the legend described a `primaryContainer` "Working" swatch
/// that the grid had never once drawn.
///
/// Two rules hold throughout:
/// * **colour only means "needs fixing"** — red is "nobody has set a shift for
///   this day", amber is "a day off nobody is covering", and those are the
///   only two filled cells. Everything else — the shift's time, OFF, HOL, a
///   past blank — is written in the cell in neutral ink on an unfilled cell.
///   The board used to give every shift type its own strong fill plus a hue
///   per day-off and holiday state, about fifteen colours that nobody could
///   memorise, and the two problems were lost among them;
/// * **never colour alone** — the two problem states also carry a glyph or a
///   word, so the grid still reads under glare, on a cheap screen, or to the
///   roughly 1 in 12 men who cannot separate the red and the amber.
library;

import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../models/roster_models.dart';
import 'roster_formats.dart';

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
/// Markers are distinguished by glyph and drawn in one neutral ink.
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
/// to design against.
abstract final class RosterColors {
  /// "Nobody has set a shift for this day" — the check-in gate will refuse.
  static const attentionFill = Color(0xFFFBE0DD);
  static const attentionInk = Color(0xFF8C1D18);
  static const attentionLine = Color(0xFFB3261E);

  /// "A day off nobody is covering."
  static const riskFill = Color(0xFFFFE3AC);
  static const riskInk = Color(0xFF5F3D00);
  static const riskLine = Color(0xFFB26A00);

  /// Every cell that is NOT a problem: an outline, not a fill, so it cannot
  /// be confused with the grey chrome of the headers. [emptyInk] is the muted
  /// ink for OFF / HOL / a past blank; a working day's time uses [markerInk].
  static const emptyFill = Color(0x00000000);
  static const emptyInk = Color(0xFF7A756F);
  static const emptyLine = Color(0xFFDCD8D4);

  /// Markers and working-day text: one dark neutral ink.
  static const markerInk = Color(0xFF1B1B1B);
  static const markerChip = Color(0xFFFFFFFF);

  /// Weekend columns (Friday and Saturday). A warm neutral on the header band
  /// only — deliberately not one of the problem hues.
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
  });

  final RosterCellState state;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;

  /// The state's glyph, for the day sheet and the legend. The grid cell draws
  /// it only where the text alone is not enough: the warning beside an
  /// uncovered day off, and the flag beside a holiday. Null only for
  /// [RosterCellState.unrosteredPast], whose lone dot is already unique.
  final IconData? icon;

  /// What the cell says: the shift's time window for a working day (`9a–6p`,
  /// or `9a` in the month view; the hours when the shift type is not in the
  /// catalog), otherwise `OFF`, `HOL`, `Not set` or `·`. Empty only for a
  /// working style resolved without a shift (the legend's generic entry).
  final String token;

  /// The legend wording, reused verbatim as the cell's semantics label.
  final String label;

  bool get hasBorder => borderWidth > 0;

  /// Whether this is one of the two states that need fixing — the only ones
  /// drawn with a fill.
  bool get isProblem => RosterStyleResolver.problemStates.contains(state);
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

  /// A coloured "needs fixing" state, listed first in the legend.
  bool get isProblem =>
      state != null && RosterStyleResolver.problemStates.contains(state);
}

/// The month's shift types by name, so a working cell can write its time.
///
/// Built once per month payload and handed down, like the cover index, rather
/// than searched per cell.
@immutable
class RosterShiftCatalog {
  RosterShiftCatalog(Iterable<RosterShift> shifts)
    : _byType = {
        for (final shift in shifts)
          if (shift.shiftType.trim().isNotEmpty) shift.shiftType.trim(): shift,
      };

  static final RosterShiftCatalog empty = RosterShiftCatalog(
    const <RosterShift>[],
  );

  final Map<String, RosterShift> _byType;

  /// The shift type called [shiftType], or null — a type retired in Desk can
  /// still sit on days already worked, and the cell then falls back to hours.
  RosterShift? lookup(String? shiftType) {
    final name = (shiftType ?? '').trim();
    return name.isEmpty ? null : _byType[name];
  }
}

/// Resolves a [RosterCell] to a state, its markers, and the style for both.
///
/// Holds the localisations and the month's shift catalog so a caller cannot
/// accidentally resolve half a cell against one month and half against
/// another.
class RosterStyleResolver {
  RosterStyleResolver({
    RosterShiftCatalog? catalog,
    required this.l10n,
    DateTime? today,
  }) : catalog = catalog ?? RosterShiftCatalog.empty,
       today = _dateOnly(today ?? DateTime.now());

  factory RosterStyleResolver.of(
    BuildContext context, {
    RosterShiftCatalog? catalog,
    DateTime? today,
  }) {
    return RosterStyleResolver(
      catalog: catalog,
      l10n: AppLocalizations.of(context),
      today: today,
    );
  }

  final RosterShiftCatalog catalog;
  final AppLocalizations l10n;

  /// Injected rather than read from the clock inside the resolver so "past"
  /// versus "future" is testable, and so every cell in one build agrees about
  /// where the boundary is even if the build straddles midnight.
  final DateTime today;

  /// The only two states drawn with a fill: the ones that need somebody to
  /// act. Everything else is text on an unfilled cell.
  static const Set<RosterCellState> problemStates = <RosterCellState>{
    RosterCellState.offUncovered,
    RosterCellState.unrosteredFuture,
  };

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

  /// The style for a state.
  ///
  /// [shiftType] and [hours] are used only by [RosterCellState.working], to
  /// write the cell's text: the shift's time window from the catalog — start
  /// and end when [withEnd] (the week view's wider columns), start only
  /// otherwise (the month view) — or, for a shift type the catalog does not
  /// know, the hours.
  RosterCellStyle styleFor(
    RosterCellState state, {
    String? shiftType,
    double? hours,
    bool withEnd = true,
  }) {
    switch (state) {
      case RosterCellState.working:
        // No fill. Which shift it is used to be the cell's colour — one of
        // up to ten strong hues nobody could keep in their head. The time
        // says the same thing in words.
        return RosterCellStyle(
          state: state,
          background: RosterColors.emptyFill,
          foreground: RosterColors.markerInk,
          borderColor: RosterColors.emptyLine,
          borderWidth: 1,
          icon: Icons.schedule,
          token: workingText(
            shiftType: shiftType,
            hours: hours,
            withEnd: withEnd,
          ),
          label: l10n.rosterLegendWorkingTime,
        );
      case RosterCellState.offCovered:
        return RosterCellStyle(
          state: state,
          background: RosterColors.emptyFill,
          foreground: RosterColors.emptyInk,
          borderColor: RosterColors.emptyLine,
          borderWidth: 1,
          icon: Icons.check_circle_outline,
          token: l10n.rosterOffShort,
          label: l10n.rosterLegendOffCovered,
        );
      case RosterCellState.offUncovered:
        // The heaviest treatment on the grid on purpose: amber fill, thick
        // border, and a warning glyph beside the OFF, so it does not rely on
        // its colour alone to stand apart from a covered day off.
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
          background: RosterColors.emptyFill,
          foreground: RosterColors.emptyInk,
          borderColor: RosterColors.emptyLine,
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
          // Words, not a '?': the cell's whole message is "nobody has decided
          // this day yet", and a lone glyph had to be looked up in the legend.
          token: l10n.rosterNotSetShort,
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

  /// A working cell's text: the shift's time window, or the hours when the
  /// shift type is not in this month's catalog (or its times are unreadable).
  /// Empty when neither is known.
  String workingText({String? shiftType, double? hours, bool withEnd = true}) {
    final shift = catalog.lookup(shiftType);
    final time = shift == null
        ? null
        : rosterShiftTimeText(shift, l10n, withEnd: withEnd);
    if (time != null) return time;
    if (hours == null || hours <= 0) return '';
    return rosterNumberIn(l10n.localeName, hours);
  }

  RosterMarkerStyle markerStyle(RosterCellMarker marker) {
    switch (marker) {
      case RosterCellMarker.overtime:
        return RosterMarkerStyle(
          marker: marker,
          // A dot, because that is all the grid draws for it: one small dot
          // after the shift time. The day sheet spells out the numbers.
          icon: Icons.circle,
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

  /// The bulk-selection border. Selection is app chrome rather than roster
  /// meaning, and it is a border, not a fill, so it never competes with the
  /// two problem fills.
  static const Color selectionColor = Color(0xFF1A4FCC);

  /// The markers the GRID itself draws: the overtime dot after the time,
  /// the weekend tint on the column header, and the selection tick.
  ///
  /// The cover and holiday-worked markers still exist — they are on the cell's
  /// semantics label and spelled out in the day sheet — but the cell does not
  /// paint them, so the legend must not promise them. The cell carries one
  /// thing per day (the shift time, or the state's word) because line
  /// managers could not read a 56px box carrying a code, a branch token and up
  /// to three glyphs.
  static const List<RosterCellMarker> gridMarkers = <RosterCellMarker>[
    RosterCellMarker.overtime,
    RosterCellMarker.weekend,
    RosterCellMarker.selected,
  ];

  /// The legend, in order: the two coloured problem states first, then the
  /// neutral text states, then every marker the grid draws.
  ///
  /// Generated from the enum and [gridMarkers] rather than hand-listed: this
  /// is what makes "the legend describes the grid" a property of the code
  /// instead of a promise somebody has to keep.
  List<RosterLegendEntry> legendEntries() => <RosterLegendEntry>[
    for (final state in RosterCellState.values)
      if (problemStates.contains(state))
        RosterLegendEntry.forState(styleFor(state)),
    for (final state in RosterCellState.values)
      if (!problemStates.contains(state))
        RosterLegendEntry.forState(styleFor(state)),
    for (final marker in gridMarkers)
      RosterLegendEntry.forMarker(markerStyle(marker)),
  ];

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Egypt's weekend is Friday **and** Saturday. The grid used to tint Friday
/// only, which quietly told every manager that Saturday was a working day.
bool isRosterWeekend(DateTime date) =>
    date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
