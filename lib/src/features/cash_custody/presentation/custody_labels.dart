import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../models/cash_custody_models.dart';

/// The icon every custody source/option wears, wherever it is listed
/// (Expenses pay-from, Purchase payment, the custody screen).
const IconData custodyIcon = Icons.wallet;
Color custodyColor(BuildContext context) => Colors.indigo.shade600;

/// `Custody - {name}` for somebody else's custody.
///
/// The server's label for a custody account may already say so ("Custody -
/// Ahmed", "عهدة أحمد"); prefixing it again would read "Custody - Custody -
/// Ahmed", so a label that already names itself is used as it is.
String custodyDisplayLabel(AppLocalizations l10n, String rawLabel) {
  final label = rawLabel.trim();
  final lower = label.toLowerCase();
  if (lower.contains('custody') || label.contains('عهدة') || label.contains('عهده')) {
    return label;
  }
  return l10n.custodyOfHolder(label);
}

String custodyKindLabel(AppLocalizations l10n, CustodyEntryKind kind) {
  switch (kind) {
    case CustodyEntryKind.issue:
      return l10n.custodyKindIssue;
    case CustodyEntryKind.returned:
      return l10n.custodyKindReturn;
    case CustodyEntryKind.expense:
      return l10n.custodyKindExpense;
    case CustodyEntryKind.purchase:
      return l10n.custodyKindPurchase;
    case CustodyEntryKind.transferIn:
      return l10n.custodyKindTransferIn;
    case CustodyEntryKind.transferOut:
      return l10n.custodyKindTransferOut;
    case CustodyEntryKind.other:
      return l10n.custodyKindOther;
  }
}

IconData custodyKindIcon(CustodyEntryKind kind) {
  switch (kind) {
    case CustodyEntryKind.issue:
      return Icons.south_west;
    case CustodyEntryKind.returned:
      return Icons.north_east;
    case CustodyEntryKind.expense:
      return Icons.receipt_long;
    case CustodyEntryKind.purchase:
      return Icons.shopping_cart_outlined;
    case CustodyEntryKind.transferIn:
      return Icons.call_received;
    case CustodyEntryKind.transferOut:
      return Icons.call_made;
    case CustodyEntryKind.other:
      return Icons.swap_horiz;
  }
}

IconData custodyAccountCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'cash':
      return Icons.payments;
    case 'bank':
      return Icons.account_balance;
    case 'mobile':
      return Icons.phone_iphone;
    case 'pos_profile':
      return Icons.storefront;
    case 'custody':
      return custodyIcon;
    default:
      return Icons.account_balance_wallet;
  }
}
