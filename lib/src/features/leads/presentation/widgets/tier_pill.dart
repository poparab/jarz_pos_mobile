import 'package:flutter/material.dart';

import '../leads_theme.dart';

/// A compact colored pill showing a lead's tier (A / B / C / REF).
class TierPill extends StatelessWidget {
  const TierPill(this.tier, {super.key, this.dense = false});

  final String tier;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final label = tier.trim().isEmpty ? '?' : tier.trim().toUpperCase();
    final colors = LeadsTheme.tierColors(label);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: LeadsTheme.bodyFont,
          color: colors.fg,
          fontSize: dense ? 10 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
