import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';

/// A scrollable error body (so the surrounding `RefreshIndicator` still
/// works) with the user-facing error text and a Retry button.
///
/// Use as a sliver-free body: wrap in `RefreshIndicator(onRefresh: () =>
/// ref.refresh(provider(key).future), child: ReportErrorView(...))`.
class ReportErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;

  const ReportErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text(
          l10n.reportError,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          context.userErrorMessage(error),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reportsRetry),
            ),
          ),
        ],
      ],
    );
  }
}

/// A scrollable empty-state body ("No data for this period" by default).
class ReportEmptyView extends StatelessWidget {
  final String? message;
  final IconData icon;

  const ReportEmptyView({
    super.key,
    this.message,
    this.icon = Icons.insights_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(icon, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          message ?? context.l10n.reportNoData,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Placeholder body for a report screen that is not built yet.
class ReportComingSoonBody extends StatelessWidget {
  const ReportComingSoonBody({super.key});

  @override
  Widget build(BuildContext context) => ReportEmptyView(
        message: context.l10n.rptComingSoon,
        icon: Icons.construction_outlined,
      );
}

/// Full-screen denial with an app bar and back button, for a report the
/// user's roles do not allow. (The router normally redirects before this.)
class ReportAccessDeniedScreen extends StatelessWidget {
  final String? title;

  const ReportAccessDeniedScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.reportsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                l10n.rptAccessDenied,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
