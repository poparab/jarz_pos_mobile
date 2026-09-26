import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../models/user_admin_models.dart';

/// The server's own refusal, verbatim, when there is one.
///
/// User management refusals carry the fact the manager needs ("linked to 42
/// Sales Invoices — disable instead"), and the shared presenter drops an
/// English server sentence on an Arabic UI in favour of a generic line. So,
/// as in branch access: when the server answered, show what it said (still
/// through the presenter's safety filter); only a transport failure falls back
/// to the localised message.
String userAdminErrorText(BuildContext context, Object? error) {
  if (error is DioException && error.response != null) {
    final text = detailedServerMessage(error.response!.data);
    if (text != null) return text;
  }
  return context.userErrorMessage(error);
}

String tierLabel(AppLocalizations l10n, UserTier tier) {
  switch (tier) {
    case UserTier.manager:
      return l10n.userAdminTierManager;
    case UserTier.lineManager:
      return l10n.userAdminTierLineManager;
    case UserTier.moderator:
      return l10n.userAdminTierModerator;
    case UserTier.b2b:
      return l10n.userAdminTierB2b;
    case UserTier.production:
      return l10n.userAdminTierProduction;
    case UserTier.staff:
      return l10n.userAdminTierStaff;
    case UserTier.other:
      return l10n.userAdminTierOther;
  }
}

String tierFilterLabel(AppLocalizations l10n, UserTier tier) {
  switch (tier) {
    case UserTier.manager:
      return l10n.userAdminFilterManagers;
    case UserTier.lineManager:
      return l10n.userAdminFilterLineManagers;
    case UserTier.moderator:
      return l10n.userAdminFilterModerators;
    case UserTier.b2b:
      return l10n.userAdminFilterB2b;
    case UserTier.production:
      return l10n.userAdminFilterProduction;
    case UserTier.staff:
      return l10n.userAdminFilterStaff;
    case UserTier.other:
      return l10n.userAdminFilterOther;
  }
}

/// One fixed hue per tier, so a tier reads the same on every row.
Color tierColor(ThemeData theme, UserTier tier) {
  final dark = theme.brightness == Brightness.dark;
  Color pick(MaterialColor c) => dark ? c.shade300 : c.shade700;
  switch (tier) {
    case UserTier.manager:
      return pick(Colors.deepPurple);
    case UserTier.lineManager:
      return pick(Colors.indigo);
    case UserTier.moderator:
      return pick(Colors.teal);
    case UserTier.b2b:
      return pick(Colors.orange);
    case UserTier.production:
      return pick(Colors.brown);
    case UserTier.staff:
      return pick(Colors.blue);
    case UserTier.other:
      return theme.colorScheme.onSurfaceVariant;
  }
}

/// A small outlined label: tier, "You", "Disabled".
class UserAdminTag extends StatelessWidget {
  const UserAdminTag({super.key, required this.text, this.color, this.icon});

  final String text;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        border: Border.all(color: c),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 3),
          ],
          Text(text, style: theme.textTheme.labelSmall?.copyWith(color: c)),
        ],
      ),
    );
  }
}

class TierTag extends StatelessWidget {
  const TierTag({super.key, required this.tier});

  final UserTier tier;

  @override
  Widget build(BuildContext context) => UserAdminTag(
    text: tierLabel(context.l10n, tier),
    color: tierColor(Theme.of(context), tier),
  );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final UserAdminUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = user.enabled
        ? tierColor(theme, user.tier)
        : theme.colorScheme.outline;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color,
      child: Text(
        user.initials,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.7),
      ),
    );
  }
}

class UserAdminMessage extends StatelessWidget {
  const UserAdminMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class UserAdminErrorPanel extends StatelessWidget {
  const UserAdminErrorPanel({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              userAdminErrorText(context, error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// A coloured strip with an icon: view-only, disabled, role replacement.
class UserAdminBanner extends StatelessWidget {
  const UserAdminBanner({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
