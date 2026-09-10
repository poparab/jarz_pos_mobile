import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pos/data/repositories/pos_repository.dart';
import '../data/credit_repository.dart';
import '../data/models/credit_models.dart';

/// How far back the credit ledger's ACTIVITY FEED looks.
///
/// Mirrors `EmployeeLedgerWindow` deliberately: the two ledgers are the same
/// idiom (all-time balance, windowed activity) and a second spelling of the
/// same control would be a second thing to learn. 90 days is the backend's own
/// default when no dates are sent, so the two agree on first paint.
///
/// Widening the window never changes a balance — only which invoices are
/// listed. Rolling informal settlement means an open invoice can be much older
/// than the window, which is what the longer presets are for.
enum CreditLedgerWindow {
  days30(30),
  days90(90),
  days180(180),
  days365(365);

  const CreditLedgerWindow(this.days);
  final int days;
}

final creditLedgerWindowProvider =
    StateProvider<CreditLedgerWindow>((ref) => CreditLedgerWindow.days90);

/// Optional POS-profile (branch) filter for the accounts list. Null / empty
/// means every branch the user may see.
final creditLedgerPosProfileProvider = StateProvider<String?>((ref) => null);

/// Every shop with an open credit balance, plus the windowed invoice feed.
final creditLedgerProvider =
    FutureProvider.autoDispose<CreditLedger>((ref) async {
  final repository = ref.watch(creditRepositoryProvider);
  final window = ref.watch(creditLedgerWindowProvider);
  final posProfile = ref.watch(creditLedgerPosProfileProvider);

  final today = DateTime.now();
  final from = today.subtract(Duration(days: window.days));

  return repository.getCreditLedger(
    posProfile: posProfile,
    fromDate: isoDate(from),
    toDate: isoDate(today),
  );
});

/// One shop's credit standing, keyed by customer id.
///
/// Watched by the checkout payment selector (to gate and annotate the Credit
/// option) and by the account detail screen.
///
/// Deliberately NOT `autoDispose`: it is warmed the moment a customer is
/// selected, minutes before the payment dialog opens, and an autoDispose
/// family would throw that result away as soon as the warming read returned.
/// The cost is one small record per customer touched in a session. Callers
/// that MOVE the balance — placing a credit order, recording a payment —
/// invalidate this provider so nobody reads a headroom that no longer exists.
final customerCreditProfileProvider =
    FutureProvider.family<CustomerCreditProfile, String>((ref, customer) async {
  final repository = ref.watch(creditRepositoryProvider);
  return repository.getCustomerCreditProfile(customer);
});

/// The POS profiles the record-payment sheet can post against.
///
/// Reuses the POS repository rather than adding a second profile endpoint:
/// `get_pos_profiles` already returns exactly the profiles this user may use,
/// which is the same permission the payment needs.
final creditPaymentPosProfilesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(posRepositoryProvider);
  final profiles = await repository.getPosProfiles();
  return profiles
      .map((profile) => (profile['name'] ?? '').toString())
      .where((name) => name.isNotEmpty)
      .toList();
});

/// `YYYY-MM-DD`, the only date shape these endpoints accept.
String isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}
