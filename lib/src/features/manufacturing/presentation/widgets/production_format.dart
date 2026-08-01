/// Unicode LTR isolate. Without it the bidi algorithm reorders a leading minus
/// to the trailing edge in an Arabic paragraph, so "-18" renders as "18-" and a
/// negative stock figure can be misread as positive. That matters here: the
/// board deliberately highlights negative stock.
/// Written as escapes rather than the literal characters: they are invisible in
/// source and the analyzer rightly refuses them in a string literal.
const _ltrIsolate = '\u{2066}'; // LEFT-TO-RIGHT ISOLATE
const _popIsolate = '\u{2069}'; // POP DIRECTIONAL ISOLATE

/// Formats a production quantity for display.
///
/// Drops trailing zeros so a batch count of 5 renders as "5", not "5.000",
/// while keeping enough precision for weight-based BOMs where 1.25 kg matters.
/// Negative values are direction-isolated so they read correctly in Arabic.
String trimQty(double value, {int decimals = 2}) {
  final text = _plainQty(value, decimals);
  return value < 0 ? '$_ltrIsolate$text$_popIsolate' : text;
}

String _plainQty(double value, int decimals) {
  if (value == value.roundToDouble() && value.abs() < 1e9) {
    return value.toStringAsFixed(0);
  }
  final fixed = value.toStringAsFixed(decimals);
  if (!fixed.contains('.')) return fixed;
  return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
