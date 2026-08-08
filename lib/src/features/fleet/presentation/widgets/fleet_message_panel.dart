import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// Full-area explanation for every state where the map has nothing useful.
///
/// The map is never left blank without one of these: an empty map with no
/// caption reads as "everything is fine and nobody is moving", which is the
/// most dangerous thing this screen could imply.
class FleetMessagePanel extends StatelessWidget {
  const FleetMessagePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.detail,
    this.iconColor,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Optional extra line, e.g. the names we are waiting on.
  final String? detail;

  final Color? iconColor;

  /// Omitted when retrying cannot possibly help (a 403).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 44,
                color: iconColor ?? theme.colorScheme.outline,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (detail != null && detail!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  detail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
