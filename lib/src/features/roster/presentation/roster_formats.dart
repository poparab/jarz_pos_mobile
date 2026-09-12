import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/localization_extensions.dart';

/// Every number on the roster screens, in the locale's own digits.
///
/// Arabic gets Arabic-Indic throughout instead of the previous mix — an
/// Arabic-Indic month title over Western day numbers over Western cell hours,
/// three numeral systems on one screen. Hours keep at most one decimal, since
/// "9" and "12.5" are the only two shapes a shift length takes.
String rosterNumber(BuildContext context, num value) {
  final format = NumberFormat.decimalPattern(context.l10n.localeName);
  format.maximumFractionDigits = value == value.roundToDouble() ? 0 : 1;
  return format.format(value);
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
  if (words.length >= 2) {
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
  }
  return words.first.characters.take(2).toString().toUpperCase();
}
