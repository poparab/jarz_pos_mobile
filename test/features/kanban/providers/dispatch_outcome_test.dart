import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/providers/dispatch_outcome.dart';

void main() {
  group('dispatchLeftInvoiceUnpaid', () {
    test('a transfer dispatch left the money with the customer', () {
      expect(
        dispatchLeftInvoiceUnpaid({
          'mode': 'unpaid_online_deliver_unconfirmed',
          'payment_confirmation_status': 'Awaiting Payment',
        }),
        isTrue,
      );
    });

    test('an on-account dispatch left the money with the customer', () {
      // A credit dispatch carries NO confirmation stamp by design, so the mode
      // is the only thing that can tell this apart from a collected order.
      expect(
        dispatchLeftInvoiceUnpaid({
          'mode': 'credit_deliver_on_account',
          'payment_confirmation_status': null,
        }),
        isTrue,
      );
    });

    test('the awaiting stamp alone is enough', () {
      // Older backends, and the realtime event, may not name the mode.
      expect(
        dispatchLeftInvoiceUnpaid({'payment_confirmation_status': 'Awaiting Payment'}),
        isTrue,
      );
    });

    test('an ordinary cash dispatch collected the money', () {
      expect(dispatchLeftInvoiceUnpaid({'mode': 'settle_later'}), isFalse);
      expect(dispatchLeftInvoiceUnpaid({'mode': 'paid_noops'}), isFalse);
      expect(dispatchLeftInvoiceUnpaid(const {}), isFalse);
    });

    test('reads the payload however it is spelled', () {
      expect(
        dispatchLeftInvoiceUnpaid({'mode': ' Unpaid_Online_Deliver_Unconfirmed '}),
        isTrue,
      );
      expect(
        dispatchLeftInvoiceUnpaid({'payment_confirmation_status': 'awaiting payment'}),
        isTrue,
      );
    });
  });

  group('docStatusAfterUnpaidDispatch', () {
    test('overwrites an optimistic Paid', () {
      // `outForDeliveryUnified` moves the card before the response arrives and
      // defaults a status-less card to Paid, so preserving the card's own value
      // would preserve that guess.
      expect(docStatusAfterUnpaidDispatch('Paid'), 'Unpaid');
      expect(docStatusAfterUnpaidDispatch('paid'), 'Unpaid');
    });

    test('states Unpaid when the card carries nothing', () {
      expect(docStatusAfterUnpaidDispatch(null), 'Unpaid');
      expect(docStatusAfterUnpaidDispatch('  '), 'Unpaid');
    });

    test('leaves a status that is already honest alone', () {
      expect(docStatusAfterUnpaidDispatch('Unpaid'), 'Unpaid');
      expect(docStatusAfterUnpaidDispatch('Return'), 'Return');
    });
  });

  group('dispatchAwaitsTransfer', () {
    test('true for the transfer shape', () {
      expect(
        dispatchAwaitsTransfer({'mode': 'unpaid_online_deliver_unconfirmed'}),
        isTrue,
      );
      expect(
        dispatchAwaitsTransfer({'payment_confirmation_status': 'Awaiting Payment'}),
        isTrue,
      );
    });

    test('false for an on-account dispatch, which owes no transfer', () {
      // Stamping a credit order "Awaiting Payment" would drop a 30-day debt
      // into the manager's transfer queue, where nobody can clear it.
      expect(
        dispatchAwaitsTransfer({'mode': 'credit_deliver_on_account'}),
        isFalse,
      );
    });

    test('false for a collected dispatch', () {
      expect(dispatchAwaitsTransfer({'mode': 'settle_later'}), isFalse);
      expect(dispatchAwaitsTransfer(const {}), isFalse);
    });
  });
}
