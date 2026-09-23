import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

/// Unicode LTR isolate. Without it the bidi algorithm moves a leading minus to
/// the trailing edge of an Arabic paragraph, so "-18" would read as "18-".
const _ltrIsolate = '\u{2066}'; // LEFT-TO-RIGHT ISOLATE
const _popIsolate = '\u{2069}'; // POP DIRECTIONAL ISOLATE

/// Formats a quantity with thousands grouping and without trailing zeros:
/// 12 → "12", 1120 → "1,120", 12.430 → "12.43", 0.25 → "0.25".
///
/// Latin digits on purpose, in both locales: the rest of the app prints them,
/// and a production sheet that mixes digit systems is harder to read aloud.
String fmtQty(double value, {int decimals = 2}) {
  final pattern = decimals <= 0 ? '#,##0' : '#,##0.${'#' * decimals}';
  final text = NumberFormat(pattern, 'en').format(value);
  return value < 0 ? '$_ltrIsolate$text$_popIsolate' : text;
}

/// Batches are multiples of 0.25, so two decimals is exact: 0.25, 0.5, 1, 1.5.
String fmtBatches(double value) => fmtQty(value, decimals: 2);

/// A "~331" style rate: a rounded figure, marked as approximate.
String fmtApprox(double value) => '~${fmtQty(value, decimals: 0)}';

/// Units counted in whole pieces. Their quantities print as integers and
/// without the unit, which is what the store room calls them anyway.
const _wholeUnits = {
  'nos',
  'no',
  'unit',
  'units',
  'pcs',
  'pc',
  'piece',
  'pieces',
  'jar',
  'jars',
  'box',
  'boxes',
};

bool isWholeUnit(String uom) => _wholeUnits.contains(uom.trim().toLowerCase());

/// A material quantity: "404" for Nos, "12.43 Kg" for anything weighed.
String fmtMaterialQty(double value, String uom) {
  if (uom.trim().isEmpty) return fmtQty(value);
  if (isWholeUnit(uom)) return fmtQty(value, decimals: 0);
  return '${fmtQty(value)} ${uom.trim()}';
}

/// Wraps always-Latin data (an item code, a warehouse) in a directional
/// isolate so bidi cannot reorder it inside an Arabic sentence.
String isolateLtr(String value) =>
    value.isEmpty ? value : '$_ltrIsolate$value$_popIsolate';

/// "0.75 batch", "2.5 batches", "1 batch" — and "تشغيلة" in Arabic, which
/// does not change with the number.
String batchesLabel(AppLocalizations l10n, double batches) {
  final value = fmtBatches(batches);
  return batches <= 1
      ? l10n.productionRoundBatchOne(value)
      : l10n.productionRoundBatches(value);
}

String jarsLabel(AppLocalizations l10n, double jars) =>
    l10n.productionRoundJars(jars.round());

/// The size group's display name. The two groups the factory runs today are
/// translated; anything new the server adds is shown as it arrives.
String sizeLabel(AppLocalizations l10n, String size) {
  switch (size.trim().toLowerCase()) {
    case 'medium':
      return l10n.productionRoundSizeMedium;
    case 'large':
      return l10n.productionRoundSizeLarge;
    default:
      return size;
  }
}

/// Amber for "short, but not an emergency" — the theme has no warning role,
/// so this picks a shade readable on both the light and the dark surface.
Color warningColor(ThemeData theme) => theme.brightness == Brightness.dark
    ? Colors.amber.shade300
    : Colors.amber.shade900;

/// `HH:mm` of a server timestamp, or '' when it does not parse.
String fmtClock(DateTime? when) =>
    when == null ? '' : DateFormat('HH:mm', 'en').format(when);
