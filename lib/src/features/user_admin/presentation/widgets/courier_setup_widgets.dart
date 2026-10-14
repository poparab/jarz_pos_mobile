import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../printing/receipt/receipt_delivery.dart';
import '../../../printing/receipt/receipt_share.dart';
import '../../data/courier_invite_text.dart';
import '../../models/courier_setup_models.dart';
import 'user_admin_widgets.dart';

/// Short chip text for a diagnosis problem code. An unknown code (from a newer
/// server) is shown as-is rather than hidden.
String courierProblemLabel(AppLocalizations l10n, String code) {
  switch (code) {
    case 'no_identity':
      return l10n.courierSetupProblemNoIdentity;
    case 'no_pos_profile':
      return l10n.courierSetupProblemNoPosProfile;
    case 'no_employee_branch':
      return l10n.courierSetupProblemNoEmployeeBranch;
    case 'branch_not_assigned':
      return l10n.courierSetupProblemBranchNotAssigned;
    default:
      return code;
  }
}

/// One sentence on how to fix a problem code; null for an unknown code.
String? courierProblemHint(AppLocalizations l10n, String code) {
  switch (code) {
    case 'no_identity':
      return l10n.courierSetupHintNoIdentity;
    case 'no_pos_profile':
      return l10n.courierSetupHintNoPosProfile;
    case 'no_employee_branch':
      return l10n.courierSetupHintNoEmployeeBranch;
    case 'branch_not_assigned':
      return l10n.courierSetupHintBranchNotAssigned;
    default:
      return null;
  }
}

/// Problems as readable chips, each with its fix hint underneath.
class CourierProblemList extends StatelessWidget {
  const CourierProblemList({super.key, required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (problems.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final code in problems)
              UserAdminTag(
                text: courierProblemLabel(l10n, code),
                color: theme.colorScheme.error,
                icon: Icons.warning_amber_rounded,
              ),
          ],
        ),
        for (final code in problems)
          if (courierProblemHint(l10n, code) != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                courierProblemHint(l10n, code)!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
      ],
    );
  }
}

/// The one-time result of a setup or PIN reset.
///
/// The PIN lives only in the arguments of this dialog, so it disappears the
/// moment the dialog closes; nothing here writes it to a provider, to storage
/// or to the log. The dialog cannot be dismissed by tapping outside, so a stray
/// tap does not lose a PIN nobody can read again.
class CourierResultDialog extends StatelessWidget {
  const CourierResultDialog({
    super.key,
    required this.signInId,
    required this.pin,
    this.displayName,
    this.links = const CourierLinks(),
    this.diagnosis,
    this.phone,
    this.isReset = false,
  });

  final String signInId;
  final String? pin;
  final String? displayName;
  final CourierLinks links;

  /// Present after a full setup; shows what is still missing, if anything.
  final CourierDiagnosis? diagnosis;

  /// The courier's mobile when the manager typed one, so WhatsApp opens their
  /// chat. Without it WhatsApp opens with the text ready and lets them choose.
  final String? phone;
  final bool isReset;

  static Future<void> show(
    BuildContext context, {
    required String signInId,
    required String? pin,
    String? displayName,
    CourierLinks links = const CourierLinks(),
    CourierDiagnosis? diagnosis,
    String? phone,
    bool isReset = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CourierResultDialog(
        signInId: signInId,
        pin: pin,
        displayName: displayName,
        links: links,
        diagnosis: diagnosis,
        phone: phone,
        isReset: isReset,
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text, String message) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    final text = buildCourierInviteText(
      signInId: signInId,
      pin: pin ?? '',
      displayName: displayName,
      webUrl: links.webUrl,
      apkUrl: links.apkUrl,
      isReset: isReset,
    );
    await openWhatsAppOrOfferRetry(
      messenger: ScaffoldMessenger.of(context),
      uri: whatsappReceiptUri(phone, text),
      failureMessage: l10n.invoiceWhatsAppOpenFailed,
      retryLabel: l10n.commonRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final diag = diagnosis;
    final hasPin = pin != null && pin!.isNotEmpty;

    Widget labelled(String label, String value, {VoidCallback? onCopy}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(child: SelectableText(value)),
            if (onCopy != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n.courierSetupCopy,
                icon: const Icon(Icons.copy, size: 18),
                onPressed: onCopy,
              ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(
        isReset ? l10n.courierSetupPinResetTitle : l10n.courierSetupDoneTitle,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((displayName ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    displayName!,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              labelled(
                l10n.courierSetupLoginId,
                signInId,
                onCopy: () =>
                    _copy(context, signInId, l10n.courierSetupCopied),
              ),
              const SizedBox(height: 8),
              if (hasPin) ...[
                Text(
                  l10n.courierSetupPinLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          // Scales down on a narrow phone rather than
                          // overflowing the card.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SelectableText(
                              pin!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.courierSetupCopy,
                        icon: const Icon(Icons.copy),
                        onPressed: () =>
                            _copy(context, pin!, l10n.courierSetupCopied),
                      ),
                    ],
                  ),
                ),
                UserAdminBanner(
                  icon: Icons.visibility_off_outlined,
                  text: l10n.courierSetupPinOnce,
                  color: theme.colorScheme.error,
                ),
              ] else
                UserAdminBanner(
                  icon: Icons.info_outline,
                  text: l10n.courierSetupNoPin,
                  color: theme.colorScheme.error,
                ),
              if (links.webUrl != null) ...[
                const SizedBox(height: 8),
                labelled(
                  l10n.courierSetupWebLink,
                  links.webUrl!,
                  onCopy: () =>
                      _copy(context, links.webUrl!, l10n.courierSetupCopied),
                ),
              ],
              if (links.apkUrl != null)
                labelled(
                  l10n.courierSetupApkLink,
                  links.apkUrl!,
                  onCopy: () =>
                      _copy(context, links.apkUrl!, l10n.courierSetupCopied),
                ),
              if (diag != null && !diag.ok && diag.problems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.courierSetupStillMissing,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                CourierProblemList(problems: diag.problems),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (hasPin)
          // A plain Row (not TextButton.icon) so the long label wraps on a
          // narrow phone instead of overflowing the dialog.
          TextButton(
            onPressed: () => _share(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat, size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(l10n.courierSetupShareWhatsapp)),
              ],
            ),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonDone),
        ),
      ],
    );
  }
}
