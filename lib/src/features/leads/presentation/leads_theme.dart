import 'package:flutter/material.dart';

/// The Jarz brand palette + typography helpers for the Leads feature.
///
/// Uses only the fonts already bundled in `pubspec.yaml`
/// (DMSerifDisplay / Inter / Tajawal) — never google_fonts.
abstract final class LeadsTheme {
  // ── Palette ───────────────────────────────────────────────────────────
  static const berryPink = Color(0xFFEF6B7A); // accent / score bar
  static const deepPlum = Color(0xFF434057); // text / headings
  static const gold = Color(0xFFC4A265);
  static const blush = Color(0xFFF1CBE1);
  static const bg = Color(0xFFFDFCFA);
  static const line = Color(0xFFE8E6E1);
  static const muted = Color(0xFF78746D);
  static const sahelBlue = Color(0xFF3F6FA6);
  static const sahelBlueBg = Color(0xFFEAF1F8);
  // "Not suitable" verdict — deliberately desaturated, not alarm-red: it marks
  // a prospect as set aside, not an error.
  static const rejected = Color(0xFF8C5A5A);
  static const rejectedBg = Color(0xFFF6EDED);

  // ── Fonts ─────────────────────────────────────────────────────────────
  static const headingFont = 'DMSerifDisplay';
  static const bodyFont = 'Inter';
  static const arabicFont = 'Tajawal';

  /// Numeric columns use tabular figures so digits line up.
  static const tabular = [FontFeature.tabularFigures()];

  // ── Text styles ───────────────────────────────────────────────────────
  static const heading = TextStyle(
    fontFamily: headingFont,
    color: deepPlum,
    fontSize: 20,
    height: 1.1,
  );

  static const body = TextStyle(
    fontFamily: bodyFont,
    color: deepPlum,
    fontSize: 14,
  );

  static const bodyMuted = TextStyle(
    fontFamily: bodyFont,
    color: muted,
    fontSize: 13,
  );

  static const number = TextStyle(
    fontFamily: bodyFont,
    color: deepPlum,
    fontSize: 14,
    fontFeatures: tabular,
  );

  /// True when [text] contains Arabic script (used for RTL-aware rendering).
  static bool isArabic(String text) {
    return RegExp(r'[؀-ۿ]').hasMatch(text);
  }

  /// Picks the right font family for a piece of user text.
  static String fontFamilyFor(String text) =>
      isArabic(text) ? arabicFont : bodyFont;

  /// A heading style that switches to Tajawal for Arabic text.
  static TextStyle nameStyle(String text, {double fontSize = 16}) {
    return TextStyle(
      fontFamily: isArabic(text) ? arabicFont : headingFont,
      color: deepPlum,
      fontSize: fontSize,
      height: 1.15,
    );
  }

  // ── Tier pill colors ──────────────────────────────────────────────────
  /// Returns background + foreground for a tier pill.
  /// Fallback palette for lead categories the backend has given no colour.
  ///
  /// Picked to stay distinguishable against OSM tiles — which are pale beige,
  /// grey and green — so no entry is a washed-out pastel or a road-yellow.
  /// Assignment is by a stable hash of the category name, so a category keeps
  /// its colour across sessions and devices without anything being stored.
  static const categoryPalette = <Color>[
    Color(0xFFD7263D), // red
    Color(0xFF1B6CA8), // blue
    Color(0xFF2E933C), // green
    Color(0xFF7B2CBF), // purple
    Color(0xFFE07A00), // orange
    Color(0xFF00838F), // teal
    Color(0xFFB5179E), // magenta
    Color(0xFF5C4033), // brown
  ];

  /// The colour for a category. Prefers the colour configured on the
  /// `Jarz Lead Category` master so the map agrees with the filter chips;
  /// falls back to a stable palette entry when none is set.
  static Color categoryColor(String? category, {String? configuredColor}) {
    final parsed = parseHexColor(configuredColor);
    if (parsed != null) return parsed;
    final key = (category ?? '').trim().toLowerCase();
    if (key.isEmpty) return muted;
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return categoryPalette[hash % categoryPalette.length];
  }

  /// Parses `#RRGGBB` / `#AARRGGBB` / bare hex. Null when unusable, so a
  /// mistyped colour in Desk degrades to the palette instead of crashing.
  static Color? parseHexColor(String? value) {
    var hex = (value ?? '').trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  static ({Color bg, Color fg}) tierColors(String tier) {
    switch (tier.trim().toUpperCase()) {
      case 'A':
        return (bg: gold, fg: Colors.white);
      case 'B':
        return (bg: blush, fg: deepPlum);
      case 'REF':
        return (bg: deepPlum, fg: Colors.white);
      case 'C':
      default:
        return (bg: const Color(0xFFEDECEA), fg: muted);
    }
  }
}
