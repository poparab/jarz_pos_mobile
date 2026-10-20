import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../data/weekly_count_models.dart';
import '../data/weekly_count_service.dart';

/// Colours the weekly-count screens share.
abstract final class WeeklyCountColors {
  static const amber = Color(0xFFB26A00);
  static const amberBg = Color(0xFFFFF4DE);
  static const red = Color(0xFFB3261E);
  static const redBg = Color(0xFFFDECEA);
  static const green = Color(0xFF1B7F3B);
  static const greenBg = Color(0xFFE7F5EC);
}

/// A server timestamp (`YYYY-MM-DD HH:MM:SS`, Cairo) as "Tue 20 Oct · 1:05 PM".
/// Shown as sent: the server's clock is the branch's clock.
String weeklyCountTimeLabel(BuildContext context, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return '';
  final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
  if (parsed == null) return value;
  final locale = context.l10n.localeName;
  final day = DateFormat('EEE d MMM', locale).format(parsed);
  final time = DateFormat('h:mm a', locale).format(parsed);
  return '$day · $time';
}

/// A `YYYY-MM-DD` as "17 Oct".
String weeklyCountDayLabel(BuildContext context, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return '';
  final parsed = DateTime.tryParse(value.split(' ').first);
  if (parsed == null) return value;
  return DateFormat('d MMM', context.l10n.localeName).format(parsed);
}

/// A quantity without a pointless ".0".
String weeklyCountQty(num value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// A signed difference: "+3", "−2", "0".
String weeklyCountSignedQty(num value) {
  if (value.abs() < 1e-9) return '0';
  final text = weeklyCountQty(value.abs());
  return value > 0 ? '+$text' : '−$text';
}

Color weeklyCountDifferenceColor(num? value) {
  if (value == null || value.abs() < 1e-9) return Colors.grey.shade600;
  return value > 0 ? WeeklyCountColors.green : WeeklyCountColors.red;
}

/// The Arabic size word for the three jar sections; any other section keeps
/// the title the server sent (it is the item group's own name).
String weeklyCountSectionTitle(
  AppLocalizations l10n,
  WeeklyCountSection section,
) {
  switch (section.key.trim().toLowerCase()) {
    case 'large':
      return l10n.weeklyCountSectionLarge;
    case 'medium':
      return l10n.weeklyCountSectionMedium;
    case 'small':
      return l10n.weeklyCountSectionSmall;
    default:
      return section.title;
  }
}

/// A document status in words.
String weeklyCountDocStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case WeeklyCountDocStatus.pendingApproval:
      return l10n.weeklyCountStatusPendingApproval;
    case WeeklyCountDocStatus.approved:
      return l10n.weeklyCountStatusApproved;
    case WeeklyCountDocStatus.rejected:
      return l10n.weeklyCountStatusRejected;
    case WeeklyCountDocStatus.cancelled:
      return l10n.weeklyCountStatusCancelled;
    default:
      return status;
  }
}

(Color, Color) weeklyCountDocStatusColors(String status) {
  switch (status) {
    case WeeklyCountDocStatus.approved:
      return (WeeklyCountColors.green, WeeklyCountColors.greenBg);
    case WeeklyCountDocStatus.rejected:
      return (WeeklyCountColors.red, WeeklyCountColors.redBg);
    case WeeklyCountDocStatus.pendingApproval:
      return (WeeklyCountColors.amber, WeeklyCountColors.amberBg);
    default:
      return (Colors.grey.shade700, Colors.grey.shade200);
  }
}

/// The Arabic (or English) text for a weekly-count refusal.
///
/// Known `[error_code]` prefixes get the feature's own sentence; anything
/// else goes through the app-wide error presenter, which already turns
/// network failures and raw server text into something a counter can read.
String weeklyCountErrorMessage(AppLocalizations l10n, Object? error) {
  final text = weeklyCountKnownErrorMessage(l10n, weeklyCountErrorCode(error));
  return text ?? userErrorMessageFor(l10n, error);
}

/// The sentence for a known code, or null.
String? weeklyCountKnownErrorMessage(AppLocalizations l10n, String? code) {
  switch (code) {
    case WeeklyCountErrorCodes.missingItems:
      return l10n.weeklyCountErrMissingItems;
    case WeeklyCountErrorCodes.unknownItems:
      return l10n.weeklyCountErrUnknownItems;
    case WeeklyCountErrorCodes.invalidQty:
      return l10n.weeklyCountErrInvalidQty;
    case WeeklyCountErrorCodes.alreadyPending:
      return l10n.weeklyCountErrAlreadyPending;
    case WeeklyCountErrorCodes.alreadyDone:
      return l10n.weeklyCountErrAlreadyDone;
    case WeeklyCountErrorCodes.noAccess:
      return l10n.weeklyCountErrNoAccess;
    case WeeklyCountErrorCodes.noWarehouse:
      return l10n.weeklyCountErrNoWarehouse;
    case WeeklyCountErrorCodes.reasonRequired:
      return l10n.weeklyCountErrReasonRequired;
    case WeeklyCountErrorCodes.notPending:
      return l10n.weeklyCountErrNotPending;
    case WeeklyCountErrorCodes.notFound:
      return l10n.weeklyCountErrNotFound;
    case WeeklyCountErrorCodes.postFailed:
      return l10n.weeklyCountErrPostFailed;
    case WeeklyCountErrorCodes.noItems:
      return l10n.weeklyCountErrNoItems;
    case WeeklyCountErrorCodes.ownCount:
      return l10n.weeklyCountErrOwnCount;
    default:
      return null;
  }
}

/// A site-relative `/files/...` image path made loadable; empty when the
/// base URL is unknown (tests), which renders the placeholder.
String weeklyCountImageUrl(String? path) {
  final trimmed = path?.trim() ?? '';
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  var base = '';
  if (dotenv.isInitialized) {
    base = dotenv.get('ERP_BASE_URL', fallback: '').trim();
  }
  if (base.isEmpty) return '';
  final normalisedBase = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;
  return '$normalisedBase${trimmed.startsWith('/') ? trimmed : '/$trimmed'}';
}

/// A small square item picture, or a neutral box when there is none.
class WeeklyCountItemImage extends StatelessWidget {
  const WeeklyCountItemImage({super.key, required this.path, this.size = 48});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = weeklyCountImageUrl(path);
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: size * 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        errorBuilder: (context, _, _) => placeholder,
      ),
    );
  }
}

/// A rounded status pill.
class WeeklyCountStatusChip extends StatelessWidget {
  const WeeklyCountStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = weeklyCountDocStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        weeklyCountDocStatusLabel(context.l10n, status),
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

/// A centred error with a retry.
class WeeklyCountErrorView extends StatelessWidget {
  const WeeklyCountErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              l10n.weeklyCountLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              weeklyCountErrorMessage(l10n, error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
