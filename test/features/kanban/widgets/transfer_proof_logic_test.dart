// Decision logic behind Kanban card -> Pay -> InstaPay / Wallet.
//
// Production, 2026-09-13 (ACC-SINV-2026-18289): `pay_invoice` refuses a
// transfer payment until a POS Payment Receipt is Confirmed with a screenshot,
// but the card paid first and created the receipt only after a success that
// never came. These tests pin the new ordering: proof first, pay last.
library;

import 'package:dio/dio.dart';
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
      expect(
        transferReceiptStateFor(invoice, 'InstaPay'),
        TransferReceiptState.none,
      );
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
      expect(
        transferReceiptStateFor(invoice, 'InstaPay'),
        TransferReceiptState.none,
      );
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
      expect(
        transferReceiptStateFor(invoice, 'InstaPay'),
        TransferReceiptState.missingImage,
      );
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
      expect(
        transferPaymentStepFor(unconfirmed, 'InstaPay'),
        TransferPaymentStep.proofRequired,
      );

      expect(rejectedState, TransferReceiptState.rejected);
      expect(canContinueWithExistingProof(rejectedState), isFalse);
      expect(
        transferPaymentStepFor(rejected, 'InstaPay'),
        TransferPaymentStep.proofRequired,
      );
    });
  });

  group('after the screenshot is attached', () {
    test(
      'a confirm-tier user is asked to confirm; others wait for a manager',
      () {
        expect(
          transferProofNextStep(canConfirm: true),
          TransferProofNextStep.askToConfirmThenPay,
        );
        expect(
          transferProofNextStep(canConfirm: false),
          TransferProofNextStep.awaitManager,
        );
      },
    );

    test(
      'a permission refusal from confirmReceipt means "needs a manager"',
      () {
        expect(
          isPermissionRefusal(
            Exception(
              'Failed to confirm receipt: Not permitted to confirm receipts',
            ),
          ),
          isTrue,
        );
        expect(
          isPermissionRefusal(
            Exception(
              'Failed to confirm receipt: You do not have permission for Maadi',
            ),
          ),
          isTrue,
        );
        expect(
          isPermissionRefusal(
            Exception(
              'Only branch managers and above can confirm payment receipts.',
            ),
          ),
          isTrue,
        );
        expect(
          isPermissionRefusal(
            Exception('Failed to confirm receipt: Network connection failed.'),
          ),
          isFalse,
        );
      },
    );

    test('only the server reply says the payment was recorded', () {
      // A plain stamp — whatever the card believed about the order.
      expect(confirmRecordsPayment({'success': true}), isFalse);
      expect(
        confirmRecordsPayment({
          'success': true,
          'message': 'Receipt confirmed successfully',
        }),
        isFalse,
      );
      expect(confirmRecordsPayment(null), isFalse);
      // The server's own "recorded" replies (api/payment_receipts.py).
      expect(
        confirmRecordsPayment({'success': true, 'payment_entry': 'ACC-PAY-1'}),
        isTrue,
      );
      expect(
        confirmRecordsPayment({
          'success': true,
          'message': 'Receipt confirmed and payment recorded',
          'payment_entry': null,
        }),
        isTrue,
      );
    });

    test('a shift refusal is not a "needs a manager" refusal', () {
      final shift = Exception(
        'Failed to confirm receipt: No open shift on branch Maadi, so '
        'confirming an online payment is not allowed. Start a shift on this '
        'branch first.',
      );
      expect(isShiftRefusal(shift), isTrue);
      expect(isPermissionRefusal(shift), isFalse);
      expect(
        isShiftRefusal(
          Exception(
            'Only branch managers and above can confirm payment receipts.',
          ),
        ),
        isFalse,
      );
    });
  });

  group('receipt state re-read from the server', () {
    Map<String, dynamic> row({
      String status = 'Unconfirmed',
      String method = 'InstaPay',
      String? image = '/private/files/transfer.jpg',
    }) => {
      'name': 'PR-0042',
      'payment_method': method,
      'status': status,
      'receipt_image_url': image,
    };

    test('reads each server status as it applies to the method', () {
      expect(
        transferReceiptStateFromRow(row(), 'InstaPay'),
        TransferReceiptState.uploadedUnconfirmed,
      );
      expect(
        transferReceiptStateFromRow(row(status: 'Rejected'), 'InstaPay'),
        TransferReceiptState.rejected,
      );
      expect(
        transferReceiptStateFromRow(row(status: 'Confirmed'), 'InstaPay'),
        TransferReceiptState.confirmed,
      );
      expect(
        transferReceiptStateFromRow(row(image: ''), 'InstaPay'),
        TransferReceiptState.missingImage,
      );
      expect(
        transferReceiptStateFromRow(row(method: 'Wallet'), 'InstaPay'),
        TransferReceiptState.none,
      );
    });

    test('a receipt that is gone or Changed has nothing to confirm', () {
      expect(
        transferReceiptStateFromRow(null, 'InstaPay'),
        TransferReceiptState.none,
      );
      expect(
        transferReceiptStateFromRow(row(status: 'Changed'), 'InstaPay'),
        TransferReceiptState.none,
      );
      expect(findReceiptRow([row()], 'PR-9999'), isNull);
      expect(findReceiptRow([row()], 'PR-0042'), isNotNull);
    });
  });

  group('classifyReceiptLookupError', () {
    DioException http(int status, Object? body) {
      final options = RequestOptions(
        path: '/api/method/jarz_pos.api.payment_receipts.get_payment_receipt',
      );
      return DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: status,
          data: body,
        ),
      );
    }

    test('an old server without the method falls back', () {
      // Frappe v15: ValidationError, HTTP 417.
      expect(
        classifyReceiptLookupError(
          http(417, {
            'exc_type': 'ValidationError',
            'exception':
                'frappe.exceptions.ValidationError: Failed to get method for '
                'command jarz_pos.api.payment_receipts.get_payment_receipt '
                "with module 'jarz_pos.api.payment_receipts' has no attribute "
                "'get_payment_receipt'",
          }),
        ),
        ReceiptLookupFailure.methodMissing,
      );
      // Even when the not-found text is wrapped in a DoesNotExistError 404.
      expect(
        classifyReceiptLookupError(
          http(404, {
            'exc_type': 'DoesNotExistError',
            'exception': "module 'jarz_pos.api.payment_receipts' has no "
                "attribute 'get_payment_receipt'",
          }),
        ),
        ReceiptLookupFailure.methodMissing,
      );
      expect(
        classifyReceiptLookupError(http(404, '<html>Page Missing</html>')),
        ReceiptLookupFailure.methodMissing,
      );
      expect(
        classifyReceiptLookupError(http(417, null)),
        ReceiptLookupFailure.methodMissing,
      );
      expect(
        classifyReceiptLookupError(
          Exception('Method get_payment_receipt is not whitelisted'),
        ),
        ReceiptLookupFailure.methodMissing,
      );
    });

    test('a missing receipt or another branch is a real answer', () {
      expect(
        classifyReceiptLookupError(
          http(404, {
            'exc_type': 'DoesNotExistError',
            'exception':
                'frappe.exceptions.DoesNotExistError: POS Payment Receipt '
                'PR-0042 not found',
          }),
        ),
        ReceiptLookupFailure.noReceipt,
      );
      expect(
        classifyReceiptLookupError(
          http(403, {
            'exc_type': 'PermissionError',
            'exception': 'frappe.exceptions.PermissionError: Not permitted',
          }),
        ),
        ReceiptLookupFailure.noReceipt,
      );
      expect(
        classifyReceiptLookupError(
          Exception('POS Payment Receipt PR-0042 not found'),
        ),
        ReceiptLookupFailure.noReceipt,
      );
      expect(
        classifyReceiptLookupError(
          Exception('You do not have permission to read this receipt'),
        ),
        ReceiptLookupFailure.noReceipt,
      );
    });

    test('network and server failures neither fall back nor claim absence', () {
      final options = RequestOptions(path: '/x');
      expect(
        classifyReceiptLookupError(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        ReceiptLookupFailure.unavailable,
      );
      expect(
        classifyReceiptLookupError(http(500, {'exc_type': 'OperationalError'})),
        ReceiptLookupFailure.unavailable,
      );
      expect(
        classifyReceiptLookupError(null),
        ReceiptLookupFailure.unavailable,
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
      expect(
        transferReceiptPosProfile(_invoice(posProfile: ' '), null),
        isNull,
      );
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
      expect(
        paymentFailureMessage(en, error),
        en.userErrorTransferReceiptRequired,
      );
      expect(
        paymentFailureMessage(ar, error),
        ar.userErrorTransferReceiptRequired,
      );
    });

    test(
      'an English UI shows an unmapped server reason after the generic copy',
      () {
        final error = Exception(
          'Invoice ACC-SINV-2026-18289 is on hold by finance',
        );
        expect(
          paymentFailureMessage(en, error),
          '${en.invoicePaymentFailed}: Invoice ACC-SINV-2026-18289 is on hold by finance',
        );
        // An Arabic UI never surfaces an English server sentence.
        expect(paymentFailureMessage(ar, error), ar.invoicePaymentFailed);
      },
    );

    test('a bare "Payment failed" is not repeated', () {
      expect(
        paymentFailureMessage(en, Exception('Payment failed')),
        en.invoicePaymentFailed,
      );
    });
  });
}
