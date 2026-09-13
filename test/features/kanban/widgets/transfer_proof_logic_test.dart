// Decision logic behind Kanban card -> Pay -> InstaPay / Wallet.
//
// Production, 2026-09-13 (ACC-SINV-2026-18289): `pay_invoice` refuses a
// transfer payment until a POS Payment Receipt is Confirmed with a screenshot,
// but the card paid first and created the receipt only after a success that
// never came. These tests pin the new ordering: proof first, pay last.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/widgets/transfer_proof_logic.dart';

InvoiceCard _invoice({
  String? receiptName,
  String? receiptMethod,
  String? receiptStatus,
  String? receiptImageUrl,
  double grandTotal = 450,
  double outstandingAmount = 450,
  String? posProfile = 'Maadi',
  String? paymentConfirmationStatus,
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-18289',
    invoiceIdShort: '18289',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: 'Ready',
    postingDate: '2026-09-13',
    grandTotal: grandTotal,
    netTotal: grandTotal,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    outstandingAmount: outstandingAmount,
    isPickup: false,
    paymentReceiptName: receiptName,
    paymentReceiptMethod: receiptMethod,
    paymentReceiptStatus: receiptStatus,
    paymentReceiptImageUrl: receiptImageUrl,
    posProfile: posProfile,
    paymentConfirmationStatus: paymentConfirmationStatus,
  );
}

void main() {
  group('transferReceiptMethod', () {
    test('normalizes every spelling the app and server use', () {
      expect(transferReceiptMethod('InstaPay'), 'InstaPay');
      expect(transferReceiptMethod('Instapay'), 'InstaPay');
      expect(transferReceiptMethod('instapay'), 'InstaPay');
      expect(transferReceiptMethod('Wallet'), 'Wallet');
      expect(transferReceiptMethod('Mobile Wallet'), 'Wallet');
      expect(transferReceiptMethod('Cash'), isNull);
      expect(transferReceiptMethod(null), isNull);
      expect(isTransferPaymentMethod('Mobile Wallet'), isTrue);
      expect(isTransferPaymentMethod('Cash'), isFalse);
    });
  });

  group('transferPaymentStepFor', () {
    test('a confirmed receipt with a screenshot pays directly', () {
      final invoice = _invoice(
        receiptName: 'PR-0001',
        receiptMethod: 'Instapay',
        receiptStatus: 'Confirmed',
        receiptImageUrl: '/private/files/shot.jpg',
      );
      expect(
        transferPaymentStepFor(invoice, 'InstaPay'),
        TransferPaymentStep.payDirectly,
      );
    });

    test('no receipt requires proof', () {
      final invoice = _invoice();
      expect(transferReceiptStateFor(invoice, 'InstaPay'),
          TransferReceiptState.none);
      expect(
        transferPaymentStepFor(invoice, 'InstaPay'),
        TransferPaymentStep.proofRequired,
      );
    });

    test('a confirmed receipt for a DIFFERENT method does not count', () {
      final invoice = _invoice(
        receiptName: 'PR-0001',
        receiptMethod: 'Wallet',
        receiptStatus: 'Confirmed',
        receiptImageUrl: '/private/files/shot.jpg',
      );
      expect(transferReceiptStateFor(invoice, 'InstaPay'),
          TransferReceiptState.none);
      expect(
        transferPaymentStepFor(invoice, 'InstaPay'),
        TransferPaymentStep.proofRequired,
      );
      expect(
        transferPaymentStepFor(invoice, 'Mobile Wallet'),
        TransferPaymentStep.payDirectly,
      );
    });

    test('a confirmed receipt without a screenshot still requires proof', () {
      final invoice = _invoice(
        receiptName: 'PR-0001',
        receiptMethod: 'InstaPay',
        receiptStatus: 'Confirmed',
      );
      expect(transferReceiptStateFor(invoice, 'InstaPay'),
          TransferReceiptState.missingImage);
      expect(
        transferPaymentStepFor(invoice, 'InstaPay'),
        TransferPaymentStep.proofRequired,
      );
    });

    test('an unconfirmed upload can be continued; a rejected one cannot', () {
      final unconfirmed = _invoice(
        receiptName: 'PR-0001',
        receiptMethod: 'InstaPay',
        receiptStatus: 'Unconfirmed',
        receiptImageUrl: '/private/files/shot.jpg',
      );
      final rejected = _invoice(
        receiptName: 'PR-0001',
        receiptMethod: 'InstaPay',
        receiptStatus: 'Rejected',
        receiptImageUrl: '/private/files/shot.jpg',
      );
      final unconfirmedState = transferReceiptStateFor(unconfirmed, 'InstaPay');
      final rejectedState = transferReceiptStateFor(rejected, 'InstaPay');

      expect(unconfirmedState, TransferReceiptState.uploadedUnconfirmed);
      expect(canContinueWithExistingProof(unconfirmedState), isTrue);
      expect(transferPaymentStepFor(unconfirmed, 'InstaPay'),
          TransferPaymentStep.proofRequired);

      expect(rejectedState, TransferReceiptState.rejected);
      expect(canContinueWithExistingProof(rejectedState), isFalse);
      expect(transferPaymentStepFor(rejected, 'InstaPay'),
          TransferPaymentStep.proofRequired);
    });
  });

  group('after the screenshot is attached', () {
    test('a confirm-tier user is asked to confirm; others wait for a manager',
        () {
      expect(transferProofNextStep(canConfirm: true),
          TransferProofNextStep.askToConfirmThenPay);
      expect(transferProofNextStep(canConfirm: false),
          TransferProofNextStep.awaitManager);
    });

    test('a permission refusal from confirmReceipt means "needs a manager"', () {
      expect(
        isPermissionRefusal(Exception(
            'Failed to confirm receipt: Not permitted to confirm receipts')),
        isTrue,
      );
      expect(
        isPermissionRefusal(Exception(
            'Failed to confirm receipt: You do not have permission for Maadi')),
        isTrue,
      );
      expect(
        isPermissionRefusal(Exception(
            'Only branch managers and above can confirm payment receipts.')),
        isTrue,
      );
      expect(
        isPermissionRefusal(
            Exception('Failed to confirm receipt: Network connection failed.')),
        isFalse,
      );
    });

    test('confirmation records the payment only for an awaiting order', () {
      expect(confirmRecordsPayment(_invoice(), {'success': true}), isFalse);
      expect(
        confirmRecordsPayment(
          _invoice(paymentConfirmationStatus: 'Awaiting Payment'),
          {'success': true},
        ),
        isTrue,
      );
      expect(
        confirmRecordsPayment(
            _invoice(), {'success': true, 'payment_entry': 'ACC-PAY-1'}),
        isTrue,
      );
    });
  });

  group('receipt amount and profile', () {
    test('uses the outstanding amount, falling back to the grand total', () {
      expect(transferReceiptAmount(_invoice(outstandingAmount: 120)), 120);
      expect(transferReceiptAmount(_invoice(outstandingAmount: 0)), 450);
    });

    test('uses the invoice branch, falling back to the selected profile', () {
      expect(transferReceiptPosProfile(_invoice(), 'Nasr City'), 'Maadi');
      expect(
        transferReceiptPosProfile(_invoice(posProfile: null), 'Nasr City'),
        'Nasr City',
      );
      expect(transferReceiptPosProfile(_invoice(posProfile: ' '), null), isNull);
    });
  });

  group('paymentFailureMessage', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ar = lookupAppLocalizations(const Locale('ar'));

    test('the transfer receipt refusal is localized, not "Payment failed"', () {
      final error = Exception(
        'InstaPay payments need a confirmed transfer receipt. Attach the '
        "customer's transfer screenshot to this order and have a manager "
        'confirm it.',
      );
      expect(paymentFailureMessage(en, error),
          en.userErrorTransferReceiptRequired);
      expect(paymentFailureMessage(ar, error),
          ar.userErrorTransferReceiptRequired);
    });

    test('an English UI shows an unmapped server reason after the generic copy',
        () {
      final error = Exception('Invoice ACC-SINV-2026-18289 is on hold by finance');
      expect(
        paymentFailureMessage(en, error),
        '${en.invoicePaymentFailed}: Invoice ACC-SINV-2026-18289 is on hold by finance',
      );
      // An Arabic UI never surfaces an English server sentence.
      expect(paymentFailureMessage(ar, error), ar.invoicePaymentFailed);
    });

    test('a bare "Payment failed" is not repeated', () {
      expect(paymentFailureMessage(en, Exception('Payment failed')),
          en.invoicePaymentFailed);
    });
  });
}
