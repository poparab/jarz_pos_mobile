/// Formats a production quantity for display.
///
/// Drops trailing zeros so a batch count of 5 renders as "5", not "5.000",
/// while keeping enough precision for weight-based BOMs where 1.25 kg matters.
String trimQty(double value, {int decimals = 2}) {
  if (value == value.roundToDouble() && value.abs() < 1e9) {
    return value.toStringAsFixed(0);
  }
  final fixed = value.toStringAsFixed(decimals);
  if (!fixed.contains('.')) return fixed;
  return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
