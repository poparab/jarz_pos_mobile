// Courier run progress — "7/12 delivered" on the Kanban board.
//
// A dispatcher's alternative to this badge is phoning the courier, so the count
// has to be trustworthy in the two ways that matter: it must not invent progress
// a backend never reported, and it must not report a finished run as unfinished.
// These tests pin the grouping rules and, in particular, the degradation path for
// a backend that has not migrated the §2 outcome fields yet.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/kanban/models/courier_run_progress.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';

InvoiceCard _stop({
  required String id,
  String status = 'Out for Delivery',
  String? courierParty = 'EMP-COURIER-001',
  String? courier = 'Ahmed Hassan',
  String? deliveredAt,
  String? failureReason,
  int? attemptNo,
  int? sequence,
  bool isPickup = false,
}) {
  return InvoiceCard(
    id: id,
    invoiceIdShort: id,
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: status,
    postingDate: '2026-08-08',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    requiresAcceptanceFlag: false,
    outstandingAmount: 0,
    isPickup: isPickup,
    courier: courier,
    courierParty: courierParty,
    deliveredAt: deliveredAt,
    deliveryFailureReason: failureReason,
    deliveryAttemptNo: attemptNo,
    deliverySequence: sequence,
  );
}

void main() {
  group('InvoiceCard delivery outcome parsing', () {
    test('reads the raw custom_* fieldnames', () {
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Out for Delivery',
        'posting_date': '2026-08-08',
        'grand_total': 450,
        'items': const [],
        'custom_delivered_at': '2026-08-08 14:32:00',
        'custom_delivery_attempt_no': 2,
        'custom_delivery_sequence': 3,
        'custom_delivery_failure_reason': 'CUSTOMER_UNREACHABLE',
      });

      expect(card.deliveredAt, '2026-08-08 14:32:00');
      expect(card.deliveryAttemptNo, 2);
      expect(card.deliverySequence, 3);
      expect(card.deliveryFailureReason, 'CUSTOMER_UNREACHABLE');
    });

    test('reads the flat aliases too', () {
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Out for Delivery',
        'posting_date': '2026-08-08',
        'grand_total': 450,
        'items': const [],
        'delivered_at': '2026-08-08 14:32:00',
        'delivery_sequence': '4',
      });

      expect(card.deliveredAt, '2026-08-08 14:32:00');
      // Numeric strings are normal in a Frappe payload.
      expect(card.deliverySequence, 4);
    });

    test('a cleared Small Text arrives as "" and must read as no failure', () {
      // §2 clears custom_delivery_failure_reason on a successful delivery, and
      // Frappe writes "" rather than NULL. Treating "" as a reason would flag
      // every delivered stop as failed.
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Out for Delivery',
        'posting_date': '2026-08-08',
        'grand_total': 450,
        'items': const [],
        'custom_delivery_failure_reason': '   ',
      });

      expect(card.deliveryFailureReason, isNull);
      expect(card.hasOpenDeliveryFailure, isFalse);
    });

    test('a payload predating the fields leaves every one null', () {
      final legacy = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Out for Delivery',
        'posting_date': '2026-08-08',
        'grand_total': 450,
        'items': const [],
      });

      expect(legacy.deliveredAt, isNull);
      expect(legacy.deliveryAttemptNo, isNull);
      expect(legacy.deliverySequence, isNull);
      expect(legacy.stopNumber, isNull);
      expect(legacy.hasOpenDeliveryFailure, isFalse);
    });

    test('survives a cache round trip', () {
      final original = _stop(
        id: 'ACC-SINV-2026-00042',
        deliveredAt: '2026-08-08 14:32:00',
        sequence: 5,
        attemptNo: 1,
      );
      final restored = InvoiceCard.fromJson(original.toJson());

      expect(restored.deliveredAt, '2026-08-08 14:32:00');
      expect(restored.deliverySequence, 5);
      expect(restored.deliveryAttemptNo, 1);
      expect(restored.isDeliveredStop, isTrue);
    });

    test('sequence 0 is unsequenced, not stop zero', () {
      expect(_stop(id: 'A', sequence: 0).stopNumber, isNull);
      expect(_stop(id: 'A', sequence: 1).stopNumber, 1);
    });
  });

  group('InvoiceCard run membership', () {
    test('groups on the courier party, not the display name', () {
      final card = _stop(id: 'A', courierParty: 'SUP-001', courier: 'Ahmed');
      expect(card.courierRunKey, 'SUP-001');
      expect(card.courierRunLabel, 'Ahmed');
    });

    test('falls back to the display name when no party is on the payload', () {
      final card = _stop(id: 'A', courierParty: null, courier: 'Ahmed');
      expect(card.courierRunKey, 'Ahmed');
    });

    test('an unassigned order is not a stop', () {
      expect(
        _stop(id: 'A', courierParty: null, courier: null).isCourierRunStop,
        isFalse,
      );
    });

    test('a pickup is never a stop on a run', () {
      expect(_stop(id: 'A', isPickup: true).isCourierRunStop, isFalse);
    });

    test('only dispatched states count as stops', () {
      for (final status in const [
        'Out for Delivery',
        'out_for_delivery',
        'Delivered',
        'Completed',
        'Returned',
      ]) {
        expect(_stop(id: 'A', status: status).isCourierRunStop, isTrue,
            reason: status);
      }
      for (final status in const [
        'Recieved',
        'In Progress',
        'Ready',
        'Cancelled',
      ]) {
        expect(_stop(id: 'A', status: status).isCourierRunStop, isFalse,
            reason: status);
      }
    });
  });

  group('InvoiceCard stop outcome', () {
    test('custom_delivered_at marks the stop done even at Out for Delivery', () {
      // The POD lands before anybody drags the card, so the field has to win.
      final card = _stop(
        id: 'A',
        status: 'Out for Delivery',
        deliveredAt: '2026-08-08 14:32:00',
      );
      expect(card.isDeliveredStop, isTrue);
    });

    test('the Delivered column still counts when the field is absent', () {
      // The degradation that keeps the badge honest on an unmigrated backend.
      final card = _stop(id: 'A', status: 'Delivered');
      expect(card.deliveredAt, isNull);
      expect(card.isDeliveredStop, isTrue);
    });

    test('a failure reason on an undelivered stop is an open failure', () {
      final card = _stop(id: 'A', failureReason: 'WRONG_ADDRESS');
      expect(card.hasOpenDeliveryFailure, isTrue);
    });

    test('an attempt counter alone is enough — the state never changes', () {
      // §5 invariant 4: a failure does not move the invoice, so the counter can
      // be the only evidence on the board.
      final card = _stop(id: 'A', attemptNo: 2);
      expect(card.hasOpenDeliveryFailure, isTrue);
    });

    test('a delivered stop is never an open failure, stale counter or not', () {
      final card = _stop(
        id: 'A',
        deliveredAt: '2026-08-08 14:32:00',
        attemptNo: 2,
        failureReason: 'CUSTOMER_UNREACHABLE',
      );
      expect(card.isDeliveredStop, isTrue);
      expect(card.hasOpenDeliveryFailure, isFalse);
    });
  });

  group('CourierRunProgressIndex', () {
    test('counts a mixed run', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', status: 'Delivered'),
        _stop(id: 'B', deliveredAt: '2026-08-08 12:00:00'),
        _stop(id: 'C', failureReason: 'CUSTOMER_UNREACHABLE'),
        _stop(id: 'D'),
      ]);

      final run = index.forCourier('EMP-COURIER-001')!;
      expect(run.total, 4);
      expect(run.delivered, 2);
      expect(run.failed, 1);
      expect(run.pending, 1);
      expect(run.hasFailures, isTrue);
      expect(run.isComplete, isFalse);
    });

    test('separates couriers', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', courierParty: 'EMP-1', status: 'Delivered'),
        _stop(id: 'B', courierParty: 'EMP-1'),
        _stop(id: 'C', courierParty: 'EMP-2', status: 'Delivered'),
      ]);

      expect(index.forCourier('EMP-1')!.delivered, 1);
      expect(index.forCourier('EMP-1')!.total, 2);
      expect(index.forCourier('EMP-2')!.isComplete, isTrue);
    });

    test('excludes cancelled orders from the denominator', () {
      // A cancelled order was pulled — counting it would leave a finished run
      // reading as incomplete forever.
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', status: 'Delivered'),
        _stop(id: 'B', status: 'Cancelled'),
      ]);

      final run = index.forCourier('EMP-COURIER-001')!;
      expect(run.total, 1);
      expect(run.isComplete, isTrue);
    });

    test('counts a returned stop as an attended, non-delivered stop', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', status: 'Delivered'),
        _stop(id: 'B', status: 'Returned'),
      ]);

      final run = index.forCourier('EMP-COURIER-001')!;
      expect(run.total, 2);
      expect(run.delivered, 1);
    });

    test('ignores unassigned and pickup orders entirely', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', courierParty: null, courier: null),
        _stop(id: 'B', isPickup: true),
      ]);
      expect(index.isEmpty, isTrue);
    });

    test('dedupes a card that appears in two column lists', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', status: 'Delivered'),
        _stop(id: 'A', status: 'Delivered'),
      ]);
      expect(index.forCourier('EMP-COURIER-001')!.total, 1);
    });

    test('an unmigrated backend still reports column-derived progress', () {
      // The important degradation: no outcome fields at all, progress still
      // truthful from the columns rather than collapsing to 0/N.
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', status: 'Delivered'),
        _stop(id: 'B', status: 'Delivered'),
        _stop(id: 'C', status: 'Out for Delivery'),
      ]);

      final run = index.forCourier('EMP-COURIER-001')!;
      expect(run.delivered, 2);
      expect(run.total, 3);
      expect(run.failed, 0);
    });

    test('an unknown courier and an empty board return null / empty', () {
      final index = CourierRunProgressIndex.fromInvoices([_stop(id: 'A')]);
      expect(index.forCourier('NOBODY'), isNull);
      expect(index.forCourier(null), isNull);
      expect(index.forCourier(''), isNull);
      expect(const CourierRunProgressIndex.empty().isEmpty, isTrue);
    });

    test('fraction is 0 for an empty run rather than NaN', () {
      const empty = CourierRunProgress(
        courierKey: 'EMP-1',
        courierLabel: 'Ahmed',
        total: 0,
        delivered: 0,
        failed: 0,
      );
      expect(empty.fraction, 0);
      expect(empty.isComplete, isFalse);
      expect(empty.pending, 0);
    });

    test('runs are ordered by courier label', () {
      final index = CourierRunProgressIndex.fromInvoices([
        _stop(id: 'A', courierParty: 'EMP-2', courier: 'Zaki'),
        _stop(id: 'B', courierParty: 'EMP-1', courier: 'Ahmed'),
      ]);
      expect(index.runs.map((r) => r.courierLabel), ['Ahmed', 'Zaki']);
    });
  });
}
