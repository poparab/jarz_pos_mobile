/// What a dispatch response says about the CUSTOMER's money.
///
/// Out for Delivery used to mean one thing for the ledger: the receivable moved
/// to Courier Outstanding and the invoice was marked Paid. Two dispatch shapes
/// deliberately leave it unpaid instead, and a card that claims "Paid" for
/// either of them repeats — one layer up, in the UI — the lie the backend fix
/// removed:
///
/// * `unpaid_online_deliver_unconfirmed` — the customer is paying by bank
///   transfer, so the rider carries nothing. Since backend `1b3933b` an order
///   that carries a transfer screenshot is routed here even while it is still
///   declared Cash, because WooCommerce labels every order placed without an
///   online gateway `cod`. The receivable stays on Debtors until a manager
///   confirms the screenshot.
/// * `credit_deliver_on_account` — a B2B order taken on account. The money
///   arrives days later, by agreement.
///
/// Pure functions over the response payload so the rule can be tested without a
/// board, a socket or a widget tree.
library;

/// Dispatch modes that hand the goods over without collecting the money.
const Set<String> unpaidDispatchModes = {
  'unpaid_online_deliver_unconfirmed',
  'credit_deliver_on_account',
};

String _token(Object? value) => (value ?? '').toString().trim().toLowerCase();

/// Whether this dispatch left the customer's money uncollected.
///
/// Read the MODE first and the confirmation stamp second: the stamp is absent
/// from a credit dispatch by design (stamping one would arm the hourly transfer
/// escalation over a debt that is legitimately 30 days old), so a check on the
/// stamp alone would call a credit order paid.
bool dispatchLeftInvoiceUnpaid(Map<String, dynamic> payload) {
  if (unpaidDispatchModes.contains(_token(payload['mode']))) return true;
  return _token(payload['payment_confirmation_status']) == 'awaiting payment';
}

/// The document status a card should carry after a dispatch that collected nothing.
///
/// Not simply "keep what the card had": `outForDeliveryUnified` moves the card
/// optimistically BEFORE the request, and that move defaults a card with no
/// status to `Paid`. Preserving the card's value would then preserve that
/// guess, so an unpaid dispatch is stated outright. A status that is already
/// honest about being unpaid (`Overdue`, `Return`) is left alone — the board
/// normalises Overdue to Unpaid server-side anyway.
String docStatusAfterUnpaidDispatch(String? current) {
  final value = (current ?? '').trim();
  if (value.isEmpty || value.toLowerCase() == 'paid') return 'Unpaid';
  return value;
}

/// Whether this dispatch is waiting on a bank transfer the customer still owes.
///
/// Narrower than [dispatchLeftInvoiceUnpaid] on purpose: a credit order is
/// unpaid but is not awaiting a transfer, and marking one "Awaiting Payment"
/// would put it in the manager's transfer-reconciliation queue, where nobody
/// can ever clear it.
bool dispatchAwaitsTransfer(Map<String, dynamic> payload) {
  if (_token(payload['payment_confirmation_status']) == 'awaiting payment') {
    return true;
  }
  return _token(payload['mode']) == 'unpaid_online_deliver_unconfirmed';
}
