import 'package:jarz_pos/l10n/app_localizations.dart';

import '../data/models/production_policy.dart';

/// Why the server would refuse production posted at [date], or null when it
/// would accept it.
///
/// Mirrors `_assert_posting_date_allowed` deliberately: the role gate first,
/// then the day ceiling, which a System Manager is not bound by. Comparison is
/// against the SERVER's today, carried on [policy] — a tablet with a wrong
/// clock is refused here with a reason rather than by the server with a stack
/// of jargon.
///
/// Lives outside any one screen because both the Batch tab and the Today screen
/// gate on it, and the two drifting apart is how a path ends up with no gate at
/// all — which is what Quick Produce was before it got this one.
String? backDateRefusal(
  AppLocalizations l10n,
  ProductionPolicy policy,
  DateTime date,
) {
  if (!policy.isBackDated(date)) return null;
  if (!policy.canBackDate) return l10n.productionBackDateNotAllowed;
  if (policy.unlimitedBackDate) return null;

  final daysBack = policy
      .today()
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;
  if (daysBack > policy.maxBackDateDays) {
    return l10n.productionBackDateWindow(policy.maxBackDateDays);
  }
  return null;
}
