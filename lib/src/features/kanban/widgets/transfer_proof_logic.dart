import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/user_error_message.dart';
import '../models/kanban_models.dart';

/// Pure decisions behind Kanban card → Pay → InstaPay / Wallet.
///
/// The backend (`pay_invoice`) refuses an InstaPay or Wallet payment unless a
/// POS Payment Receipt for the invoice is already Confirmed and carries the
/// customer's transfer screenshot. The card used to pay FIRST and only create
/// the receipt after a success that could never come, so the button was a dead
/// end. Everything here is side-effect free so the ordering can be tested
/// without a widget tree.

/// The receipt API's spelling of a transfer method, or null for anything that
/// is not a bank/wallet transfer (Cash, empty, unknown).
String? transferReceiptMethod(String? method) {
  final normalized =
      (method ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  switch (normalized) {
    case 'instapay':
      return 'InstaPay';
    case 'wallet':
    case 'mobilewallet':
      return 'Wallet';
    default:
      return null;
  }
}

/// Whether [method] needs a confirmed transfer receipt before payment.
bool isTransferPaymentMethod(String? method) =>
    transferReceiptMethod(method) != null;

/// What the card already knows about the receipt for the method being paid.
enum TransferReceiptState {
  /// No active receipt for this method (or only one for a different method).
  none,

  /// A receipt row exists but nobody attached a screenshot yet.
  missingImage,

  /// Screenshot attached, waiting for a manager.
  uploadedUnconfirmed,

  /// A manager turned the screenshot down; a new one is required.
  rejected,

  /// Confirmed with a screenshot: the server will accept the payment.
  confirmed,
}

/// Reads the invoice's latest active receipt, as it applies to [method].
TransferReceiptState transferReceiptStateFor(
  InvoiceCard invoice,
  String method,
) {
  final wanted = transferReceiptMethod(method);
  final existing = transferReceiptMethod(invoice.paymentReceiptMethod);
  final name = (invoice.paymentReceiptName ?? '').trim();
  if (wanted == null || existing != wanted || name.isEmpty) {
    return TransferReceiptState.none;
  }
  final status = (invoice.paymentReceiptStatus ?? '').trim().toLowerCase();
  final hasImage = (invoice.paymentReceiptImageUrl ?? '').trim().isNotEmpty;
  if (status == 'rejected') return TransferReceiptState.rejected;
  if (!hasImage) return TransferReceiptState.missingImage;
  if (status == 'confirmed') return TransferReceiptState.confirmed;
  return TransferReceiptState.uploadedUnconfirmed;
}

/// First branch of the flow: can the card go straight to `pay_invoice`?
enum TransferPaymentStep { payDirectly, proofRequired }

TransferPaymentStep transferPaymentStepFor(InvoiceCard invoice, String method) {
  return transferReceiptStateFor(invoice, method) ==
          TransferReceiptState.confirmed
      ? TransferPaymentStep.payDirectly
      : TransferPaymentStep.proofRequired;
}

/// Whether the proof sheet may continue without a fresh screenshot.
///
/// Only an Unconfirmed receipt that already carries an image qualifies. A
/// Rejected one was judged not to be proof, and a row without an image is
/// exactly what the server refuses.
bool canContinueWithExistingProof(TransferReceiptState state) =>
    state == TransferReceiptState.uploadedUnconfirmed;

/// What happens once the screenshot is on the receipt.
enum TransferProofNextStep {
  /// The user is in the confirm tier: ask them to check the bank, then
  /// confirm and pay.
  askToConfirmThenPay,

  /// Somebody else must confirm it in Payment Receipts.
  awaitManager,
}

TransferProofNextStep transferProofNextStep({required bool canConfirm}) =>
    canConfirm
        ? TransferProofNextStep.askToConfirmThenPay
        : TransferProofNextStep.awaitManager;

/// Whether confirming the receipt already recorded the payment, so the card
/// must NOT follow up with `pay_invoice`.
///
/// For an order that went out on the promise of a transfer ("Awaiting
/// Payment") the server posts the payment as part of the confirmation; paying
/// again would be refused as already paid. A normal order's confirmation only
/// stamps the receipt.
bool confirmRecordsPayment(
  InvoiceCard invoice,
  Map<String, dynamic>? confirmResult,
) {
  if (invoice.isAwaitingOnlinePayment) return true;
  final entry = (confirmResult?['payment_entry'] ?? '').toString().trim();
  return entry.isNotEmpty;
}

/// The amount the receipt claims: what the customer still owes, falling back
/// to the grand total for an invoice the board reports as fully outstanding
/// with no figure.
double transferReceiptAmount(InvoiceCard invoice) {
  final outstanding = invoice.outstandingAmount;
  if (outstanding > 0) return outstanding;
  return invoice.grandTotal;
}

/// The POS profile the receipt is filed under: the invoice's own branch first,
/// then whatever the user has selected.
String? transferReceiptPosProfile(InvoiceCard invoice, String? selected) {
  final own = (invoice.posProfile ?? '').trim();
  if (own.isNotEmpty) return own;
  final fallback = (selected ?? '').trim();
  return fallback.isEmpty ? null : fallback;
}

/// Whether a failed `confirmReceipt` means "you are not allowed to confirm".
///
/// The server stays the authority on the confirm tier; a client that believed
/// the user could confirm treats this refusal as "a manager must do it".
bool isPermissionRefusal(Object? error) {
  if (error == null) return false;
  final text = error.toString().toLowerCase();
  const needles = [
    'permission',
    'not permitted',
    'not allowed',
    'forbidden',
    'only managers',
    'only a manager',
    // `_ensure_payment_receipt_confirm_access` in api/payment_receipts.py.
    'only branch managers',
    'can confirm payment receipts',
    'insufficient privilege',
  ];
  return needles.any(text.contains);
}

/// The text a failed payment shows on the card.
///
/// The presenter maps known refusals (including the missing confirmed transfer
/// receipt) to localized copy. When it has nothing better than the generic
/// "Payment failed", an English UI appends the server's own safe sentence so the
/// real reason reaches staff; an Arabic UI keeps the generic Arabic copy rather
/// than an English server sentence.
String paymentFailureMessage(AppLocalizations l10n, Object error) {
  final generic = l10n.invoicePaymentFailed;
  final presented = userErrorMessageFor(l10n, error, fallback: generic);
  if (presented != generic && presented != l10n.userErrorUnexpected) {
    return presented;
  }
  if (l10n.localeName.toLowerCase().startsWith('ar')) return generic;
  final detail = detailedServerMessage(error)?.trim();
  if (detail == null ||
      detail.isEmpty ||
      detail.toLowerCase() == generic.toLowerCase()) {
    return generic;
  }
  return '$generic: $detail';
}
