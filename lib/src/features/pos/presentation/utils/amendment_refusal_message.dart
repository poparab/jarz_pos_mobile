import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/user_error_message.dart';

/// The text shown when the server refuses an order edit.
///
/// `submit_invoice_amendment` refuses with HTTP 200, `success: false` and a
/// human `error` sentence. [userErrorMessageFor] keeps a bare sentence only
/// when it reads like a validation rule, so a refusal such as "the order
/// changed since you opened it" became "something went wrong" (and an Arabic
/// UI dropped every English one). Here the reason is shown as written, after
/// the same technical-leak screen as [detailedServerMessage] (traceback, SQL,
/// exception class, URL). Missing or unsafe text yields the localized
/// "amendment failed" line; an Arabic UI keeps that line above an English
/// reason, as the presenter does for validation refusals.
String amendmentRefusalMessageFor(AppLocalizations l10n, Object? reason) {
  final lead = l10n.kanbanAmendmentFailed;
  final candidate = detailedServerMessage(reason);
  if (candidate == null || candidate.isEmpty) return lead;
  if (!l10n.localeName.toLowerCase().startsWith('ar')) return candidate;
  final hasArabic = RegExp(r'[؀-ۿ]').hasMatch(candidate);
  final hasEnglish = RegExp(r'[A-Za-z]').hasMatch(candidate);
  if (hasArabic && !hasEnglish) return candidate;
  return '$lead\n$candidate';
}
