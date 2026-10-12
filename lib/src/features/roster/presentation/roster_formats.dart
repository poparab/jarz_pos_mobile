import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/localization_extensions.dart';
import '../models/roster_models.dart';

/// Every number on the roster screens, in the locale's own digits.
///
/// Arabic gets Arabic-Indic throughout instead of the previous mix — an
/// Arabic-Indic month title over Western day numbers over Western cell hours,
/// three numeral systems on one screen. Hours keep at most one decimal, since
/// "9" and "12.5" are the only two shapes a shift length takes.
String rosterNumber(BuildContext context, num value) =>
    rosterNumberIn(context.l10n.localeName, value);

/// [rosterNumber] for code that holds the localisations but no context.
String rosterNumberIn(String localeName, num value) {
  final format = NumberFormat.decimalPattern(localeName);
  format.maximumFractionDigits = value == value.roundToDouble() ? 0 : 1;
  return format.format(value);
}

/// One clock time, as compact as a grid cell needs: `9a`, `12:30p`, `12a`.
///
/// [raw] is a Frappe `Time` string (`HH:MM` or `HH:MM:SS`). The minutes are
/// dropped when they are zero and kept otherwise, so the common case is one
/// or two digits and a letter. [am] and [pm] come from the localisations
/// (`a`/`p` in English, `ص`/`م` in Arabic), and the digits go through the same
/// [NumberFormat] as [rosterNumber], so a time never mixes numeral systems
/// with the day numbers above it. Null when [raw] is not a time.
String? rosterClockShort(
  String raw, {
  required String localeName,
  required String am,
  required String pm,
}) {
  final parts = raw.trim().split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 24 || minute < 0 || minute > 59) return null;
  final h24 = hour % 24;
  final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
  final suffix = h24 < 12 ? am : pm;
  final hourText = NumberFormat('0', localeName).format(h12);
  if (minute == 0) return '$hourText$suffix';
  final minuteText = NumberFormat('00', localeName).format(minute);
  return '$hourText:$minuteText$suffix';
}

/// A shift's time window for a grid cell: `9a–6p` with [withEnd], `9a`
/// without (the month view's narrow column).
///
/// An en dash with no spaces, never an arrow: see [RosterShift.window] — an
/// arrow points the wrong way inside Arabic text, a dash reads the same in
/// both directions. Null when the start time cannot be read, so the caller
/// can fall back to something else rather than draw junk.
String? rosterShiftTimeText(
  RosterShift shift,
  AppLocalizations l10n, {
  required bool withEnd,
}) {
  String? clock(String raw) => rosterClockShort(
    raw,
    localeName: l10n.localeName,
    am: l10n.rosterTimeAmShort,
    pm: l10n.rosterTimePmShort,
  );
  final start = clock(shift.startTime);
  if (start == null) return null;
  if (!withEnd) return start;
  final end = clock(shift.endTime);
  return end == null ? start : '$start–$end';
}

/// A 2-character stand-in for a branch name, for the corner of a 56px cell.
///
/// "Who is where today" is the question the grid could not answer at all —
/// `shift_location` was parsed, carried through the models, and then only ever
/// shown inside the day sheet: one tap away, one person at a time. The full
/// name is still on the cell's semantics label and in the sheet.
String branchToken(String branch) {
  final cleaned = branch.trim();
  if (cleaned.isEmpty) return '';
  final words = cleaned
      .split(RegExp(r'[\s\-_/]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  // A name made only of separators ("-", " / ") splits into no words at all.
  // `words.first` on that threw inside a day cell's build, so one badly typed
  // branch name broke every cell rostered to it. No letters, no token.
  if (words.isEmpty) return '';
  if (words.length >= 2) {
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
  }
  return words.first.characters.take(2).toString().toUpperCase();
}
