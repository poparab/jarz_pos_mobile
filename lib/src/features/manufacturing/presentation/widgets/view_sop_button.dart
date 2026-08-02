import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// The one control other screens use to reach the work instructions.
///
/// Takes plain values plus an [onTap] and imports nothing from the batch or
/// running-batch screens, so any of them can drop it in without pulling the
/// manufacturing tabs into their dependency graph.
///
/// [hasSop] false renders nothing at all: most items have no SOP, and a button
/// that opens an empty screen trains people to stop pressing it.
class ViewSopButton extends StatelessWidget {
  const ViewSopButton({
    super.key,
    required this.onTap,
    this.hasSop = true,
    this.dense = false,
    this.totalDurationMins,
  });

  final VoidCallback? onTap;

  /// Whether the item actually has an SOP. False hides the button.
  final bool hasSop;

  /// Compact form for a dense row (a batch line, a running-batch card).
  final bool dense;

  /// Optional badge showing the scaled total duration, in minutes.
  final double? totalDurationMins;

  @override
  Widget build(BuildContext context) {
    if (!hasSop) return const SizedBox.shrink();

    final l10n = context.l10n;

    if (dense) {
      return IconButton(
        onPressed: onTap,
        tooltip: l10n.sopViewSop,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.menu_book_outlined, size: 20),
      );
    }

    final duration = totalDurationMins;
    final label = (duration != null && duration > 0)
        ? '${l10n.sopViewSop} · ${l10n.sopDurationMins(duration.round())}'
        : l10n.sopViewSop;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.menu_book_outlined, size: 18),
      label: Text(label),
    );
  }
}
