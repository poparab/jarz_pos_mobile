import 'package:flutter/material.dart';

import '../leads_theme.dart';

/// A small "🌊 N" badge shown when a lead has Sahel (coastal) branches.
class SahelBadge extends StatelessWidget {
  const SahelBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LeadsTheme.sahelBlueBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '🌊 $count',
        style: const TextStyle(
          fontFamily: LeadsTheme.bodyFont,
          color: LeadsTheme.sahelBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFeatures: LeadsTheme.tabular,
        ),
      ),
    );
  }
}
