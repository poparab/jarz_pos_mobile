import 'package:flutter/widgets.dart';

import '../../../../core/localization/localized_formatters.dart';

const _ltrIsolate = '\u{2066}'; // LEFT-TO-RIGHT ISOLATE
const _popIsolate = '\u{2069}'; // POP DIRECTIONAL ISOLATE

/// A handover quantity: "12", not "12.000"; up to 3 decimals otherwise.
///
/// A local copy rather than an import from another feature's presentation
/// layer, like the replenishment and production boards keep theirs.
String handoverQty(double value) {
  if (value == value.roundToDouble() && value.abs() < 1e9) {
    return value.toStringAsFixed(0);
  }
  return value
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Wraps always-Latin data (an entry name) so bidi cannot reorder it inside
/// an Arabic sentence.
String handoverLtr(String value) =>
    value.isEmpty ? value : '$_ltrIsolate$value$_popIsolate';

/// "Oct 20 • 2:05 PM" — handovers live for hours, so the year is noise.
String handoverTime(BuildContext context, DateTime? at) {
  if (at == null) return '';
  return formatDateTime(context, at, pattern: 'MMM d • h:mm a');
}
