/// Pure text helpers for the inline recipe sheet. No Flutter imports, so they
/// are unit-tested on their own.
library;

final RegExp _arabicChar = RegExp(r'[؀-ۿ]');

/// The lines of a bilingual recipe [text] worth showing in one language.
///
/// The server writes each instruction as an English line and an Arabic line
/// separated by `\n`. Split on newlines, drop blank lines, then keep the lines
/// that contain Arabic characters when [arabic] is true and those that contain
/// none otherwise. When that filter leaves nothing (an English-only step on an
/// Arabic tablet, say) every line is shown rather than an empty step.
List<String> recipeLinesForLocale(String? text, {required bool arabic}) {
  if (text == null) return const <String>[];
  final lines = [
    for (final raw in text.split('\n'))
      if (raw.trim().isNotEmpty) raw.trim(),
  ];
  if (lines.isEmpty) return const <String>[];
  final kept = [
    for (final line in lines)
      if (_arabicChar.hasMatch(line) == arabic) line,
  ];
  return kept.isEmpty ? lines : kept;
}

/// "Tiramisu Large" on a "Tiramisu" sheet reads as "Large".
///
/// Only strips when [name] starts with [title] (case-insensitive) and something
/// meaningful is left after it; otherwise the full name is returned.
String shortSizeName(String name, String title) {
  final trimmedName = name.trim();
  final trimmedTitle = title.trim();
  if (trimmedTitle.isEmpty ||
      trimmedName.length <= trimmedTitle.length ||
      !trimmedName.toLowerCase().startsWith(trimmedTitle.toLowerCase())) {
    return trimmedName;
  }
  final rest = trimmedName
      .substring(trimmedTitle.length)
      .replaceFirst(RegExp(r'^[\s\-–—·:,()]+'), '')
      .trim();
  return rest.isEmpty ? trimmedName : rest;
}

/// A whole number without its ".0"; otherwise one decimal place.
String formatRecipeCount(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final rounded = value.round();
  if ((value - rounded).abs() < 0.05) return '$rounded';
  return value.toStringAsFixed(1);
}

/// Weights and volumes inside a recipe line — "165.3 g", "24 جرام", "0.5 kg" —
/// so they can be set in bold on a kitchen tablet.
final RegExp recipeQuantityPattern = RegExp(
  r'\d+(?:[.,]\d+)?\s?(?:kg|g|ml|جرام|جم|كجم|كيلو|مل)(?![A-Za-z؀-ۿ])',
  caseSensitive: false,
);

/// [line] cut into alternating plain / quantity pieces, in order.
///
/// Each record is `(text, isQuantity)`; concatenating the texts gives [line]
/// back exactly.
List<(String, bool)> splitRecipeQuantities(String line) {
  final pieces = <(String, bool)>[];
  var cursor = 0;
  for (final match in recipeQuantityPattern.allMatches(line)) {
    if (match.start > cursor) {
      pieces.add((line.substring(cursor, match.start), false));
    }
    pieces.add((match.group(0)!, true));
    cursor = match.end;
  }
  if (cursor < line.length) pieces.add((line.substring(cursor), false));
  return pieces;
}
