import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/business_constants.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../credit/data/models/credit_models.dart';
import '../../../credit/state/credit_providers.dart';

/// Payment method selection dialog.
///
/// Shows Cash, Instapay, Mobile Wallet and — for approved customers only —
/// Credit (on account). Credit means the goods are delivered and nothing is
/// paid at the door; it is a PER-ORDER choice, so the same shop can pay cash
/// on this order and take the next one on credit.
class PaymentMethodDialog extends ConsumerWidget {
  /// The customer the order is for, or empty for a walk-in. Credit is only
  /// ever considered when there is a customer to put the debt on.
  final String customer;

  /// The `credit_allowed` flag carried on the customer's `search_customers`
  /// row. A cheap hint, NOT the decision: it decides whether the dialog spends
  /// a request resolving the live profile at all, so a retail checkout for an
  /// unapproved individual costs nothing.
  final bool creditAllowedHint;

  /// Whether to render the Credit row when the customer turns out NOT to be
  /// approved. B2B orders show it disabled with the reason, because a rep who
  /// expected credit needs to know why it is missing; a B2C order hides it,
  /// since an individual will never be approved and a permanently greyed row
  /// is noise on the main flow.
  final bool showCreditWhenNotAllowed;

  const PaymentMethodDialog({
    super.key,
    this.customer = '',
    this.creditAllowedHint = false,
    this.showCreditWhenNotAllowed = false,
  });

  /// Whether the Credit row is rendered at all. Rendering it is what triggers
  /// the profile lookup, so this is deliberately the narrow condition.
  bool get _showsCreditRow =>
      customer.trim().isNotEmpty &&
      (creditAllowedHint || showCreditWhenNotAllowed);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(context, 24);
    final buttonSpacing = ResponsiveUtils.getSpacing(context, small: 12, medium: 14, large: 16);
    final padding = ResponsiveUtils.getCardPadding(context,
      small: const EdgeInsets.all(18),
      medium: const EdgeInsets.all(20),
      large: const EdgeInsets.all(24),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getDialogWidth(context, small: 320, medium: 380, large: 450),
        ),
        child: Padding(
          padding: padding,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  context.l10n.paymentMethodSelectTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: buttonSpacing * 1.5),

                // Cash option
                _PaymentMethodButton(
                  icon: Icons.attach_money,
                  label: context.l10n.paymentMethodCash,
                  color: Colors.green,
                  onTap: () => Navigator.of(context).pop(PaymentModes.cash),
                ),
                SizedBox(height: buttonSpacing),

                // Instapay option
                _PaymentMethodButton(
                  icon: Icons.account_balance,
                  label: context.l10n.paymentMethodInstapay,
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).pop('Instapay'),
                ),
                SizedBox(height: buttonSpacing),

                // Mobile Wallet option
                _PaymentMethodButton(
                  icon: Icons.phone_android,
                  label: context.l10n.paymentMethodMobileWallet,
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).pop('Mobile Wallet'),
                ),

                // Credit (on account). Absent entirely for a walk-in, and
                // for a retail customer the search row never flagged.
                if (_showsCreditRow) ...[
                  SizedBox(height: buttonSpacing),
                  _CreditPaymentOption(
                    customer: customer.trim(),
                    showWhenNotAllowed: showCreditWhenNotAllowed,
                  ),
                ],
                SizedBox(height: buttonSpacing),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.commonCancel,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show the payment method dialog.
  ///
  /// [customer] is the selected customer id; pass empty for a walk-in and the
  /// Credit option is not rendered at all.
  static Future<String?> show(
    BuildContext context, {
    String customer = '',
    bool creditAllowedHint = false,
    bool showCreditWhenNotAllowed = false,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentMethodDialog(
        customer: customer,
        creditAllowedHint: creditAllowedHint,
        showCreditWhenNotAllowed: showCreditWhenNotAllowed,
      ),
    );
  }
}

/// The Credit row, gated on the customer's live credit profile.
///
/// The profile — not the cached `credit_allowed` flag on the search row — is
/// what decides, because a shop's approval and its remaining headroom both
/// move between the moment it was searched and the moment the order is placed.
/// The server re-checks the limit on submit regardless, so this gate is a
/// courtesy, never the enforcement.
class _CreditPaymentOption extends ConsumerWidget {
  final String customer;
  final bool showWhenNotAllowed;

  const _CreditPaymentOption({
    required this.customer,
    required this.showWhenNotAllowed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(customerCreditProfileProvider(customer));

    return profileAsync.when(
      loading: () => _PaymentMethodButton(
        icon: Icons.schedule,
        label: l10n.paymentMethodCredit,
        color: Colors.orange,
        onTap: null,
        disabledReason: l10n.paymentMethodCreditChecking,
      ),
      // A failed profile lookup must not silently open credit. It also must
      // not pretend the customer was refused, so the row says the check could
      // not be made and stays inert; Cash/Instapay/Wallet are unaffected.
      error: (error, _) => showWhenNotAllowed
          ? _PaymentMethodButton(
              icon: Icons.schedule,
              label: l10n.paymentMethodCredit,
              color: Colors.orange,
              onTap: null,
              disabledReason: l10n.paymentMethodCreditUnavailable,
            )
          : const SizedBox.shrink(),
      data: (profile) => _buildForProfile(context, l10n, profile),
    );
  }

  Widget _buildForProfile(
    BuildContext context,
    AppLocalizations l10n,
    CustomerCreditProfile profile,
  ) {
    if (!profile.creditAllowed) {
      if (!showWhenNotAllowed) return const SizedBox.shrink();
      return _PaymentMethodButton(
        icon: Icons.schedule,
        label: l10n.paymentMethodCredit,
        color: Colors.orange,
        onTap: null,
        disabledReason: l10n.paymentMethodCreditNotAllowed,
      );
    }

    // Approved. The terms and the remaining headroom sit under the row so the
    // operator sees what they are committing the shop to before tapping.
    final details = <String>[
      if (profile.hasLimit)
        l10n.paymentMethodCreditAvailable(
          formatCurrency(
            context,
            profile.availableCredit,
            currencyCode: profile.currency,
          ),
        )
      else
        l10n.paymentMethodCreditNoLimit,
      if (profile.hasTerms) l10n.paymentMethodCreditTerms(profile.creditDays),
      if (profile.currentBalance != 0)
        l10n.paymentMethodCreditOnAccount(
          formatCurrency(
            context,
            profile.currentBalance,
            currencyCode: profile.currency,
          ),
        ),
    ];

    return _PaymentMethodButton(
      icon: Icons.schedule,
      label: l10n.paymentMethodCredit,
      color: Colors.orange,
      // Being over the limit is NOT blocked here: the backend owns that call
      // and may allow an override. The row warns and stays tappable, and the
      // server's refusal is what the operator sees if it does refuse.
      subtitle: profile.isOverLimit
          ? l10n.paymentMethodCreditOverLimit
          : l10n.paymentMethodCreditSubtitle,
      details: details,
      onTap: () => Navigator.of(context).pop(PaymentModes.credit),
    );
  }
}

/// Payment method button widget. A null [onTap] renders it disabled, with
/// [disabledReason] shown underneath.
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final String? disabledReason;
  final List<String> details;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.disabledReason,
    this.details = const <String>[],
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveUtils.getIconSize(context, small: 26, medium: 29, large: 32);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 18);
    final padding = ResponsiveUtils.getCardPadding(context,
      small: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      medium: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
      large: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    );
    final spacing = ResponsiveUtils.getSpacing(context, small: 12, medium: 14, large: 16);

    final disabled = onTap == null;
    final theme = Theme.of(context);
    final foreground = disabled ? theme.disabledColor : color;
    final caption = disabled ? disabledReason : subtitle;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Material(
        color: (disabled ? theme.disabledColor : color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: foreground),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      if (caption != null && caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            caption,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: disabled
                                  ? theme.disabledColor
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      for (final detail in details)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            detail,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
