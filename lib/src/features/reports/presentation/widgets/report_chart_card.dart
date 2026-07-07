import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// A titled card wrapper for an analytics chart (typically an `fl_chart`
/// widget). Renders a header row, an optional trailing action, and either the
/// [child] or an empty-state placeholder when [isEmpty] is true.
class ReportChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  /// When true, [child] is replaced by an empty-state message.
  final bool isEmpty;

  /// Optional override for the empty-state text; defaults to the shared
  /// "No data available" localization string.
  final String? emptyText;

  /// Optional trailing widget in the header (e.g. a legend toggle).
  final Widget? trailing;

  /// Fixed height for the chart body. Defaults to 220.
  final double height;

  const ReportChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.isEmpty = false,
    this.emptyText,
    this.trailing,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: height,
              width: double.infinity,
              child: isEmpty ? _EmptyState(text: emptyText) : child,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? text;
  const _EmptyState({this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            text ?? context.l10n.reportsNoData,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
