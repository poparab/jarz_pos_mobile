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
