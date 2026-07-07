import 'package:flutter/material.dart';

import '../leads_theme.dart';

/// A score number plus a thin Berry-Pink progress bar (0–100 by default).
class ScoreBar extends StatelessWidget {
  const ScoreBar(this.score, {super.key, this.max = 100, this.width = 44});

  final int score;
  final int max;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (score / max).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$score',
          style: const TextStyle(
            fontFamily: LeadsTheme.bodyFont,
            color: LeadsTheme.deepPlum,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFeatures: LeadsTheme.tabular,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: LeadsTheme.line,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(LeadsTheme.berryPink),
            ),
          ),
        ),
      ],
    );
  }
}
