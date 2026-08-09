import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase_request/models/purchase_request_models.dart';

void main() {
  // ── RequestStatus ────────────────────────────────────────────────────
  //
  // Values come from ERPNext's Material Request status map. Parsing must be
  // exact, because "still wants stock" drives whether a request appears on the
  // buying list at all.

  group('RequestStatus.parse', () {
    test('maps every ERPNext status the Purchase flow produces', () {
      expect(RequestStatus.parse('Pending'), RequestStatus.pending);
      expect(RequestStatus.parse('Partially Received'),
          RequestStatus.partiallyReceived);
      expect(RequestStatus.parse('Received'), RequestStatus.received);
      expect(RequestStatus.parse('Ordered'), RequestStatus.ordered);
      expect(RequestStatus.parse('Partially Ordered'),
          RequestStatus.partiallyOrdered);
      expect(RequestStatus.parse('Stopped'), RequestStatus.stopped);
      expect(RequestStatus.parse('Cancelled'), RequestStatus.cancelled);
    });

    test('is case and whitespace tolerant', () {
      expect(RequestStatus.parse('  pending '), RequestStatus.pending);
      expect(RequestStatus.parse('PARTIALLY RECEIVED'),
          RequestStatus.partiallyReceived);
    });

    test('falls back to unknown rather than throwing', () {
      expect(RequestStatus.parse(null), RequestStatus.unknown);
      expect(RequestStatus.parse('Something New'), RequestStatus.unknown);
    });

    test('open statuses are exactly those still awaiting stock', () {
      expect(RequestStatus.pending.isOpen, isTrue);
      expect(RequestStatus.partiallyReceived.isOpen, isTrue);
      expect(RequestStatus.ordered.isOpen, isTrue);
      expect(RequestStatus.partiallyOrdered.isOpen, isTrue);

      expect(RequestStatus.received.isOpen, isFalse);
      expect(RequestStatus.stopped.isOpen, isFalse);
      expect(RequestStatus.cancelled.isOpen, isFalse);
    });

    test('rejected covers both stopped and cancelled', () {
      expect(RequestStatus.stopped.isRejected, isTrue);
      expect(RequestStatus.cancelled.isRejected, isTrue);
      expect(RequestStatus.pending.isRejected, isFalse);
    });
  });

  // ── RequestLine ──────────────────────────────────────────────────────

  group('RequestLine.fromJson', () {
    test('parses a partially fulfilled line', () {
      final line = RequestLine.fromJson({
        'name': 'row-1',
        'item_code': 'RM-TOMATO',
        'item_name': 'Tomatoes',
        'qty': 40,
        'uom': 'Kg',
        'stock_uom': 'Kg',
        'conversion_factor': 1,
        'stock_qty': 40,
        'received_qty': 15,
        'outstanding_qty': 25,
        'warehouse': 'Raw Materials - J',
      });

      expect(line.itemCode, 'RM-TOMATO');
      expect(line.outstandingQty, 25);
      expect(line.isFulfilled, isFalse);
      expect(line.progress, closeTo(0.375, 0.0001));
    });

    test('treats a zero conversion factor as 1', () {
      // A zero would silently zero out any quantity converted through it.
      final line = RequestLine.fromJson({'conversion_factor': 0});
      expect(line.conversionFactor, 1);
    });

    test('falls back to item_code when item_name is missing', () {
      final line = RequestLine.fromJson({'item_code': 'RM-X'});
      expect(line.itemName, 'RM-X');
    });

    test('progress is clamped and safe when nothing was requested', () {
      final line = RequestLine.fromJson({'stock_qty': 0, 'received_qty': 0});
      expect(line.progress, 0);

      final over =
          RequestLine.fromJson({'stock_qty': 10, 'received_qty': 25});
      expect(over.progress, 1.0);
    });

    test('a fully received line reports fulfilled', () {
      final line = RequestLine.fromJson({
        'stock_qty': 10,
        'received_qty': 10,
        'outstanding_qty': 0,
      });
      expect(line.isFulfilled, isTrue);
    });
  });

  // ── ItemRequest ──────────────────────────────────────────────────────

  group('ItemRequest', () {
    Map<String, dynamic> base({
      String status = 'Pending',
      String? scheduleDate,
    }) =>
        {
          'name': 'MAT-MR-0001',
          'status': status,
          'transaction_date': '2026-08-01',
          if (scheduleDate != null) 'schedule_date': scheduleDate,
          'per_received': 0,
          'pos_profile': 'Dokki',
          'requested_by': 'Sara',
          'requested_by_user': 'sara@jarz.test',
          'is_mine': true,
          'items': [
            {'item_code': 'RM-TOMATO', 'stock_qty': 40, 'received_qty': 0},
          ],
        };

    test('parses core fields and nested lines', () {
      final request = ItemRequest.fromJson(base());
      expect(request.name, 'MAT-MR-0001');
      expect(request.status, RequestStatus.pending);
      expect(request.posProfile, 'Dokki');
      expect(request.requestedBy, 'Sara');
      expect(request.isMine, isTrue);
      expect(request.itemCount, 1);
    });

    test('a past needed-by date on an open request is overdue', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final request = ItemRequest.fromJson(
        base(scheduleDate: yesterday.toIso8601String().split('T').first),
      );
      expect(request.isOverdue, isTrue);
    });

    test('a closed request is never overdue', () {
      // A request that was already bought should not keep nagging.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final request = ItemRequest.fromJson(
        base(
          status: 'Received',
          scheduleDate: yesterday.toIso8601String().split('T').first,
        ),
      );
      expect(request.isOverdue, isFalse);
    });

    test('today is not yet overdue', () {
      final today = DateTime.now().toIso8601String().split('T').first;
      final request = ItemRequest.fromJson(base(scheduleDate: today));
      expect(request.isOverdue, isFalse);
    });

    test('a request with no due date is never overdue', () {
      expect(ItemRequest.fromJson(base()).isOverdue, isFalse);
    });
  });

  // ── RequestDemandLine ────────────────────────────────────────────────
  //
  // The consolidated buying list. Its whole purpose is summing demand across
  // requesters so one order covers everyone.

  group('RequestDemandLine', () {
    final json = {
      'item_code': 'RM-TOMATO',
      'item_name': 'Tomatoes',
      'stock_uom': 'Kg',
      'outstanding_qty': 40,
      'requested_qty': 55,
      'received_qty': 15,
      'on_hand_qty': 8,
      'last_purchase_rate': 22.5,
      'earliest_needed_by': '2026-08-05',
      'sources': [
        {
          'material_request': 'MAT-MR-0001',
          'material_request_item': 'row-1',
          'pos_profile': 'Dokki',
          'requested_by': 'Sara',
          'outstanding_qty': 25,
          'uom': 'Kg',
          'conversion_factor': 1,
          'needed_by': '2026-08-05',
        },
        {
          'material_request': 'MAT-MR-0002',
          'material_request_item': 'row-2',
          'pos_profile': 'Nasr city',
          'requested_by': 'Omar',
          'outstanding_qty': 15,
          'uom': 'Kg',
          'conversion_factor': 1,
          'needed_by': '2026-08-07',
        },
      ],
    };

    test('parses the roll-up and its per-branch sources', () {
      final line = RequestDemandLine.fromJson(json);
      expect(line.outstandingQty, 40);
      expect(line.onHandQty, 8);
      expect(line.lastPurchaseRate, 22.5);
      expect(line.sources, hasLength(2));
    });

    test('carries the item tax template so a bought line keeps its VAT', () {
      final line = RequestDemandLine.fromJson({
        ...json,
        'item_tax_template': 'VAT 14% - JZ',
      });
      expect(line.itemTaxTemplate, 'VAT 14% - JZ');
    });

    test('a missing or blank tax template reads as no VAT, not an empty name',
        () {
      expect(RequestDemandLine.fromJson(json).itemTaxTemplate, isNull);
      expect(
        RequestDemandLine.fromJson({...json, 'item_tax_template': ''})
            .itemTaxTemplate,
        isNull,
      );
    });

    test('source quantities sum to the rolled-up outstanding total', () {
      // If these ever diverge, the cart would allocate the wrong amounts back
      // to the requests.
      final line = RequestDemandLine.fromJson(json);
      final sum = line.sources
          .fold<double>(0, (total, source) => total + source.outstandingQty);
      expect(sum, line.outstandingQty);
    });

    test('branches are distinct and sorted', () {
      final line = RequestDemandLine.fromJson(json);
      expect(line.branches, ['Dokki', 'Nasr city']);
    });

    test('branches ignores sources with no branch', () {
      final line = RequestDemandLine.fromJson({
        ...json,
        'sources': [
          {'pos_profile': null, 'outstanding_qty': 5},
          {'pos_profile': '', 'outstanding_qty': 5},
          {'pos_profile': 'Dokki', 'outstanding_qty': 5},
        ],
      });
      expect(line.branches, ['Dokki']);
    });

    test('a due date in the past or today is urgent', () {
      final past = RequestDemandLine.fromJson({
        ...json,
        'earliest_needed_by':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      });
      expect(past.isUrgent, isTrue);

      final future = RequestDemandLine.fromJson({
        ...json,
        'earliest_needed_by':
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      });
      expect(future.isUrgent, isFalse);
    });

    test('no due date is not urgent', () {
      final line = RequestDemandLine.fromJson({...json}..remove('earliest_needed_by'));
      expect(line.isUrgent, isFalse);
    });
  });

  // ── DraftRequestLine ─────────────────────────────────────────────────

  group('DraftRequestLine', () {
    test('serialises only what the API needs', () {
      const line = DraftRequestLine(
        itemCode: 'RM-TOMATO',
        itemName: 'Tomatoes',
        uom: 'Kg',
        qty: 3,
      );
      expect(line.toJson(), {'item_code': 'RM-TOMATO', 'qty': 3.0, 'uom': 'Kg'});
    });

    test('copyWith changes qty without losing identity', () {
      const line = DraftRequestLine(
        itemCode: 'RM-TOMATO',
        itemName: 'Tomatoes',
        uom: 'Kg',
        qty: 1,
      );
      final bumped = line.copyWith(qty: 4);
      expect(bumped.qty, 4);
      expect(bumped.itemCode, 'RM-TOMATO');
      expect(bumped.itemName, 'Tomatoes');
      expect(bumped.uom, 'Kg');
    });
  });

  // ── ItemRequestPage ──────────────────────────────────────────────────

  group('ItemRequestPage.fromJson', () {
    test('parses the paging envelope', () {
      final page = ItemRequestPage.fromJson({
        'requests': [
          {'name': 'MAT-MR-0001', 'status': 'Pending'},
        ],
        'total': 12,
        'can_review': true,
      });
      expect(page.requests, hasLength(1));
      expect(page.total, 12);
      expect(page.canReview, isTrue);
    });

    test('defaults to an empty, non-review page', () {
      final page = ItemRequestPage.fromJson({});
      expect(page.requests, isEmpty);
      expect(page.total, 0);
      expect(page.canReview, isFalse);
    });
  });
}
