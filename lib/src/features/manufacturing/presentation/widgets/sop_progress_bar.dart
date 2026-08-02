import 'package:flutter/material.dart';

/// How much of the SOP is actually done, step by step.
///
/// Driven by "satisfied" rather than "pages seen": an operator can page back
/// and forth, and a bar that tracked the pager would claim work that never
/// happened.
class SopProgressBar extends StatelessWidget {
  const SopProgressBar({
    super.key,
    required this.satisfied,
    required this.currentIndex,
    this.onStepTap,
  });

  /// One flag per step, in order.
  final List<bool> satisfied;

  final int currentIndex;

  /// Optional jump-to-step. The caller decides whether a jump is allowed —
  /// forward moves are gated by the execution notifier.
  final void Function(int index)? onStepTap;

  double get fraction {
    if (satisfied.isEmpty) return 0;
    final done = satisfied.where((s) => s).length;
    return done / satisfied.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (satisfied.isEmpty) {
      return const SizedBox(height: 6);
    }

    // Beyond a couple of dozen steps the per-step segments become slivers with
    // untappable hit boxes, so fall back to a plain bar.
    if (satisfied.length > 24) {
      return LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: scheme.surfaceContainerHighest,
      );
    }

    return SizedBox(
      height: 18,
      child: Row(
        children: [
          for (var i = 0; i < satisfied.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: onStepTap == null ? null : () => onStepTap!(i),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Container(
                    height: i == currentIndex ? 8 : 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: satisfied[i]
                          ? scheme.primary
                          : (i == currentIndex
                              ? scheme.primary.withValues(alpha: 0.45)
                              : scheme.surfaceContainerHighest),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
