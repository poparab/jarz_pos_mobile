import 'package:flutter/material.dart';

/// Responsive design utilities for adapting UI to different screen sizes.
/// Optimized for tablets from 6.5" to 11"+
class ResponsiveUtils {
  /// Screen width breakpoints (landscape orientation)
  static const double smallTablet = 1024; // ~6.5" landscape
  static const double mediumTablet = 1280; // ~8-9" landscape
  static const double largeTablet = 1600; // ~10-11" landscape

  /// Get screen width from context
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height from context
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Calculate optimal grid column count based on screen width
  /// - Small tablets (6.5"): 2-3 columns
  /// - Medium tablets (8-9"): 3-4 columns
  /// - Large tablets (10"+): 4-5 columns
  static int getGridColumns(BuildContext context, {int min = 2, int max = 5}) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      // 6.5" and smaller: 2-3 columns
      return 2.clamp(min, max);
    } else if (width < mediumTablet) {
      // 8-9" tablets: 3-4 columns
      return 3.clamp(min, max);
    } else if (width < largeTablet) {
      // 9-10" tablets: 4 columns
      return 4.clamp(min, max);
    } else {
      // 10"+ tablets: 5 columns
      return 5.clamp(min, max);
    }
  }

  /// Calculate item grid columns specifically (optimized for product display)
  static int getItemGridColumns(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 900) {
      return 2; // Very small screens
    } else if (width < 1100) {
      return 3; // 6.5-7" tablets
    } else if (width < 1300) {
      return 4; // 8-9" tablets
    } else {
      return 5; // 10"+ tablets
    }
  }

  /// Calculate bundle grid columns
  static int getBundleGridColumns(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 900) {
      return 2; // Very small screens
    } else if (width < 1100) {
      return 2; // 6.5-7" tablets
    } else if (width < 1400) {
      return 3; // 8-9" tablets
    } else {
      return 4; // 10"+ tablets
    }
  }

  /// Get responsive font scale factor
  static double getFontScale(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return 0.85; // Smaller fonts on small screens
    } else if (width < mediumTablet) {
      return 0.92; // Almost normal
    } else {
      return 1.0; // Normal font size
    }
  }

  /// Get responsive font size with base size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final scale = getFontScale(context);
    return baseSize * scale;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {
    double small = 16,
    double medium = 18,
    double large = 20,
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return small;
    } else if (width < mediumTablet) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive button padding
  static EdgeInsets getButtonPadding(BuildContext context, {
    EdgeInsets small = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    EdgeInsets medium = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    EdgeInsets large = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return small;
    } else if (width < mediumTablet) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context, {
    double small = 400,
    double medium = 500,
    double large = 640,
  }) {
    final width = screenWidth(context);
    final maxWidth = width * 0.9; // Never exceed 90% of screen width
    
    if (width < smallTablet) {
      return small.clamp(0, maxWidth);
    } else if (width < mediumTablet) {
      return medium.clamp(0, maxWidth);
    } else {
      return large.clamp(0, maxWidth);
    }
  }

  /// Get responsive card padding
  static EdgeInsets getCardPadding(BuildContext context, {
    EdgeInsets small = const EdgeInsets.all(10),
    EdgeInsets medium = const EdgeInsets.all(14),
    EdgeInsets large = const EdgeInsets.all(16),
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return small;
    } else if (width < mediumTablet) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double small = 8,
    double medium = 12,
    double large = 16,
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return EdgeInsets.all(small);
    } else if (width < mediumTablet) {
      return EdgeInsets.all(medium);
    } else {
      return EdgeInsets.all(large);
    }
  }

  /// Determine if screen should use compact layout
  static bool isCompactLayout(BuildContext context) {
    return screenWidth(context) < smallTablet;
  }

  /// Determine if screen should stack cart vertically (for very small screens)
  static bool shouldStackVertically(BuildContext context) {
    return screenWidth(context) < 800; // Below ~6" landscape
  }

  /// Get optimal cart width flex ratio
  /// Returns [itemsFlex, cartFlex] for Row layout
  static List<int> getCartFlexRatio(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 900) {
      // Small screens: give cart more space
      return [6, 4]; // 60/40 split
    } else if (width < 1200) {
      // Medium screens: balanced
      return [65, 35]; // 65/35 split
    } else {
      // Large screens: original ratio
      return [7, 3]; // 70/30 split
    }
  }

  /// Get responsive spacing value
  static double getSpacing(BuildContext context, {
    double small = 4,
    double medium = 8,
    double large = 12,
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return small;
    } else if (width < mediumTablet) {
      return medium;
    } else {
      return large;
    }
  }

  /// Calculate child aspect ratio for grid items
  static double getGridAspectRatio(BuildContext context, {
    double compact = 1.2,
    double normal = 1.5,
  }) {
    final width = screenWidth(context);
    
    if (width < smallTablet) {
      return compact; // Taller cards on small screens
    } else {
      return normal; // Original aspect ratio
    }
  }
}
