import 'package:uuid/uuid.dart';

/// The idempotency token for one credit-payment ATTEMPT.
///
/// The backend has two double-submit guards and they are not equal. The strong
/// one is an exact match on the Payment Entry's `reference_no`: if this token
/// comes back, the money is already in, whatever else happened to the network.
/// The weak one is a (customer, account, amount) lookback of two minutes, used
/// only when no token was sent — and it fails in both directions:
///
///   * a request that timed out and is retried three minutes later falls
///     outside the window and books the payment a second time;
///   * two genuine handovers of the same round figure at one branch inside two
///     minutes look identical, so the second is silently discarded.
///
/// Neither is a rare shape here: shops settle in round numbers, and the retry
/// after a timeout is the single most likely thing an operator does.
///
/// The token must therefore be **stable across retries of the same attempt and
/// new for a new attempt**, which is what [tokenFor] does: it mints a token for
/// the current form values and hands the SAME one back while those values are
/// unchanged. Tap submit, time out, tap again — same token, so the server
/// replays instead of posting twice. Change the amount, or settle a second
/// handover of the same figure — different signature, new token, and the
/// payment goes through as the distinct payment it is.
class CreditPaymentIdempotency {
  String? _token;
  String? _signature;

  /// The token to send with a payment of these exact values.
  String tokenFor({
    required String customer,
    required double amount,
    required String posProfile,
    required String paymentMethod,
    String remarks = '',
    String postingDate = '',
  }) {
    final signature = [
      customer.trim(),
      // Fixed precision so 100 and 100.00 are one attempt, not two.
      amount.toStringAsFixed(2),
      posProfile.trim(),
      paymentMethod.trim(),
      remarks.trim(),
      postingDate.trim(),
    ].join('|');

    final current = _token;
    if (current == null || _signature != signature) {
      _signature = signature;
      final minted = newCreditPaymentToken();
      _token = minted;
      return minted;
    }
    return current;
  }

  /// Forgets the current attempt, so the next submit is a new payment.
  ///
  /// Called after a submit that the server ACCEPTED. Reusing that token would
  /// make the next genuine settlement look like a replay of the last one and
  /// quietly post nothing.
  void reset() {
    _token = null;
    _signature = null;
  }

  /// The token currently in flight, or null before the first submit. Test seam.
  String? get current => _token;
}

/// A fresh token. Prefixed so a human reading `reference_no` in Desk can see
/// where it came from, and short enough to fit the Data field.
String newCreditPaymentToken() => 'cpay-${const Uuid().v4()}';
