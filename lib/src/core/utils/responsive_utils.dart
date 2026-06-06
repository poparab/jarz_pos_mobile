import 'package:flutter/material.dart';

/// Responsive design utilities for adapting UI across all device sizes.
/// Supports phones (portrait & landscape) through large tablets.
class ResponsiveUtils {
  // ─── Breakpoints ─────────────────────────────────────────────────
  static const double phonePortrait = 480;   // phone portrait
  static const double phoneLandscape = 600;  // phone landscape / small tablet portrait
  static const double smallTablet = 1024;    // ~6.5" landscape
  static const double mediumTablet = 1280;   // ~8-9" landscape
  static const double largeTablet = 1600;    // ~10-11" landscape
  static const double ultraCompactPhone = 360;

  /// True when the device is phone-sized. Uses shortestSide so tall/wide
  /// phones (e.g., S22/S25 Ultra) still count as phones even with large width.
  static bool isPhone(BuildContext context) {
    return isPhoneSize(MediaQuery.sizeOf(context));
  }

  static bool isPhoneSize(Size size) => size.shortestSide < phoneLandscape;

  static bool isTabletOrDesktop(BuildContext context) => !isPhone(context);

  static bool isUltraCompactPhone(BuildContext context) {
    return isUltraCompactPhoneSize(MediaQuery.sizeOf(context));
  }

  static bool isUltraCompactPhoneSize(Size size) {
    return isPhoneSize(size) && size.shortestSide < ultraCompactPhone;
  }

  static bool isPhonePortrait(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return isPhoneSize(size) &&
        MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  static bool isPhoneLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return isPhoneSize(size) &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// True when the device is in portrait orientation.
  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  /// Get screen width from context
  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// Get screen height from context
  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  // ─── Grid columns ───────────────────────────────────────────────
  static int getGridColumns(BuildContext context, {int min = 2, int max = 5}) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return 2.clamp(min, max);
    if (width < smallTablet)    return 2.clamp(min, max);
    if (width < mediumTablet)   return 3.clamp(min, max);
    if (width < largeTablet)    return 4.clamp(min, max);
    return 5.clamp(min, max);
  }

  /// Item grid columns (optimised for product display)
  static int getItemGridColumns(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    // Phones: keep portrait cards readable; use more columns only on landscape.
    if (isPhoneSize(media.size)) {
      if (isPhonePortrait(context)) {
        if (width < 400) return 2;
        if (width < 520) return 3;
        return 4;
      }
      if (width < 640) return 3;
      if (width < 820) return 4;
      return 5; // ultra-wide phones / landscape
    }

    if (width < 900)  return 2;
    if (width < 1100) return 3;
    if (width < 1300) return 4;
    return 5;
  }

  /// Bundle grid columns
  static int getBundleGridColumns(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    if (isPhoneSize(media.size)) {
      if (isPhonePortrait(context)) return 2;
      if (width < 700) return 2;
      return 3; // keep bundles readable on phones
    }

    if (width < 900)  return 2;
    if (width < 1100) return 2;
    if (width < 1400) return 3;
    return 4;
  }

  // ─── Font ───────────────────────────────────────────────────────
  static double getFontScale(BuildContext context) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return 0.82;
    if (width < smallTablet)    return 0.85;
    if (width < mediumTablet)   return 0.92;
    return 1.0;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) =>
      baseSize * getFontScale(context);

  // ─── Icon size ──────────────────────────────────────────────────
  static double getIconSize(BuildContext context, {
    double small = 16,
    double medium = 18,
    double large = 20,
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return small;
    if (width < smallTablet)    return small;
    if (width < mediumTablet)   return medium;
    return large;
  }

  // ─── Paddings ───────────────────────────────────────────────────
  static EdgeInsets getButtonPadding(BuildContext context, {
    EdgeInsets small = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    EdgeInsets medium = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    EdgeInsets large = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return small;
    if (width < smallTablet)    return small;
    if (width < mediumTablet)   return medium;
    return large;
  }

  static EdgeInsets getCardPadding(BuildContext context, {
    EdgeInsets small = const EdgeInsets.all(10),
    EdgeInsets medium = const EdgeInsets.all(14),
    EdgeInsets large = const EdgeInsets.all(16),
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return const EdgeInsets.all(8);
    if (width < smallTablet)    return small;
    if (width < mediumTablet)   return medium;
    return large;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double small = 8,
    double medium = 12,
    double large = 16,
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return EdgeInsets.all(small * 0.75);
    if (width < smallTablet)    return EdgeInsets.all(small);
    if (width < mediumTablet)   return EdgeInsets.all(medium);
    return EdgeInsets.all(large);
  }

  // ─── Dialog width (never exceeds 90 % of screen) ───────────────
  static double getDialogWidth(BuildContext context, {
    double small = 400,
    double medium = 500,
    double large = 640,
  }) {
    final width = screenWidth(context);
    final maxWidth = width * 0.92;
    if (width < phoneLandscape) return maxWidth; // full-width on phones
    if (width < smallTablet)    return small.clamp(0, maxWidth);
    if (width < mediumTablet)   return medium.clamp(0, maxWidth);
    return large.clamp(0, maxWidth);
  }

  static double getDialogHeight(BuildContext context, {
    double phoneFraction = 0.82,
    double tabletFraction = 0.72,
    double max = 720,
  }) {
    final height = screenHeight(context);
    final target = height * (isPhone(context) ? phoneFraction : tabletFraction);
    return target.clamp(260.0, max).toDouble();
  }

  static double getCartBottomSheetInitialSize(BuildContext context) {
    if (!isPhone(context)) return 0.7;
    return isPhoneLandscape(context) ? 0.86 : 0.72;
  }

  static double getCartBottomSheetMinSize(BuildContext context) {
    if (!isPhone(context)) return 0.5;
    return isPhoneLandscape(context) ? 0.62 : 0.45;
  }

  static double getCartBottomSheetMaxSize(BuildContext context) =>
      isPhone(context) ? 0.96 : 0.95;

  // ─── Layout helpers ─────────────────────────────────────────────
  static bool isCompactLayout(BuildContext context) =>
      screenWidth(context) < smallTablet;

  /// True when the POS should stack cart below items (phones).
  static bool shouldStackVertically(BuildContext context) =>
      screenWidth(context) < phoneLandscape;

  /// Cart flex ratio [items, cart] – only meaningful in side-by-side mode.
  static List<int> getCartFlexRatio(BuildContext context) {
    final width = screenWidth(context);
    if (width < 900)  return [6, 4];
    if (width < 1200) return [65, 35];
    return [7, 3];
  }

  // ─── Spacing ────────────────────────────────────────────────────
  static double getSpacing(BuildContext context, {
    double small = 4,
    double medium = 8,
    double large = 12,
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return small;
    if (width < smallTablet)    return small;
    if (width < mediumTablet)   return medium;
    return large;
  }

  /// Aspect ratio for product grid cards.
  static double getGridAspectRatio(BuildContext context, {
    double compact = 1.0,
    double normal = 1.5,
  }) {
    final width = screenWidth(context);
    if (width < phoneLandscape) return compact;
    if (width < smallTablet)    return compact;
    return normal;
  }

  // ─── Kanban helpers ─────────────────────────────────────────────
  /// Width of a single Kanban column – fills the screen on phones.
  static double getKanbanColumnWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isPhone(context)) {
      final target = isPhoneLandscape(context) ? width * 0.48 : width - 32;
      return target.clamp(260.0, isPhoneLandscape(context) ? 420.0 : 400.0).toDouble();
    }
    return 300;
  }

  static double getKanbanColumnGap(BuildContext context) =>
      isPhone(context) ? 10 : 16;

  static EdgeInsets getKanbanBoardPadding(BuildContext context) =>
      EdgeInsets.all(isPhone(context) ? 10 : 16);

  /// AppBar header height – thinner on phones to save space.
  static double getHeaderHeight(BuildContext context) =>
      isPhone(context) ? 56 : 88;
}
