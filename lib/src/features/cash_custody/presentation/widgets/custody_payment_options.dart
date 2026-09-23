import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/cash_custody_models.dart';
import '../../state/cash_custody_notifier.dart';
import '../custody_labels.dart';

/// The custodies a purchase may be paid from, as payment-dialog options.
///
/// Values are `custody:<holder name>`, the form `create_purchase_invoice`
/// and `pay_purchase_invoice` accept.
class CustodyPaymentChoices {
  final List<CustodyHolder> holders;
  final String? myHolderName;

  const CustodyPaymentChoices({required this.holders, this.myHolderName});

  static const none = CustodyPaymentChoices(holders: []);

  bool get isEmpty => holders.isEmpty;

  /// Loads a fresh overview (balances move all day). A failure only means no
  /// custody options are offered; the other payment modes are unaffected.
  static Future<CustodyPaymentChoices> load(WidgetRef ref) async {
    final overview = await refreshCustodyOverview(ref);
    if (overview == null) return none;
    return CustodyPaymentChoices(
      holders: overview.payableHolders,
      myHolderName: overview.myHolder?.name,
    );
  }

  CustodyHolder? holderForOption(String option) {
    const prefix = 'custody:';
    if (!option.startsWith(prefix)) return null;
    final name = option.substring(prefix.length);
    for (final holder in holders) {
      if (holder.name == name) return holder;
    }
    return null;
  }

  /// Whether [option] is a custody that cannot cover [amount].
  bool isShort(String option, double amount) {
    final holder = holderForOption(option);
    return holder != null && amount > holder.balance + custodyBalanceEpsilon;
  }

  /// Radio tiles for a [RadioGroup] of payment options.
  List<Widget> radioTiles(BuildContext context, {required double amount}) {
    if (holders.isEmpty) return const [];
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final errorColor = Theme.of(context).colorScheme.error;
    return [
      for (final holder in holders)
        Builder(builder: (context) {
          final short = amount > holder.balance + custodyBalanceEpsilon;
          final title = holder.name == myHolderName
              ? l10n.custodyMine
              : l10n.custodyOfHolder(holder.localizedName(languageCode));
          final balance =
              l10n.custodyAvailable(formatCurrency(context, holder.balance));
          return RadioListTile<String>(
            value: custodyPurchasePaymentOption(holder.name),
            secondary: Icon(custodyIcon, color: custodyColor(context)),
            title: Text(title),
            subtitle: Text(
              short ? '$balance • ${l10n.custodyInsufficientBalance}' : balance,
              style: short ? TextStyle(color: errorColor) : null,
            ),
            dense: true,
          );
        }),
    ];
  }
}
