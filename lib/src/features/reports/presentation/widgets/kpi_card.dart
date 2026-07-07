import 'package:flutter/material.dart';

/// A compact KPI tile: a label, a prominent value, and an optional icon plus
/// a delta chip (e.g. "+12%"). Designed to tile inside a Wrap/GridView so the
/// six dashboard screens can lay several out per row. RTL-safe.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;

  /// Optional secondary line under the value (e.g. a change / delta string).
  final String? delta;

  /// When set, tints the delta chip; otherwise a neutral tone is used.
  final Color? deltaColor;

  final IconData? icon;

  /// Accent colour for the icon + value. Falls back to the theme primary.
  final Color? color;

  /// Optional fixed width; when null the card fills its parent constraint.
  final double? width;

  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaColor,
    this.icon,
    this.color,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;

    final card = Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: accent),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (delta != null && delta!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (deltaColor ?? theme.colorScheme.secondary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    delta!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: deltaColor ?? theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}
