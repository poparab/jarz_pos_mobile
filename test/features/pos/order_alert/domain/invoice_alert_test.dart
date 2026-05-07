// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/domain/invoice_alert.dart';

void main() {
  // ── InvoiceAlertItem ──────────────────────────────────────────────────

  group('InvoiceAlertItem.fromMap', () {
    test('parses all fields', () {
      final item = InvoiceAlertItem.fromMap({
        'item_code': 'ITEM-001',
        'item_name': 'Test Item',
        'qty': 3.0,
      });
      expect(item.itemCode, 'ITEM-001');
      expect(item.itemName, 'Test Item');
      expect(item.quantity, 3.0);
    });

    test('parses qty from string', () {
      final item = InvoiceAlertItem.fromMap({
        'item_code': 'X',
        'qty': '2.5',
      });
      expect(item.quantity, 2.5);
    });

    test('defaults qty to 0 when missing', () {
      final item = InvoiceAlertItem.fromMap({});
      expect(item.itemCode, isNull);
      expect(item.itemName, isNull);
      expect(item.quantity, 0);
    });

    test('defaults qty to 0 when unparseable', () {
      final item = InvoiceAlertItem.fromMap({'qty': 'abc'});
      expect(item.quantity, 0);
    });
  });

  // ── InvoiceAlert.fromDynamic ──────────────────────────────────────────

  group('InvoiceAlert.fromDynamic', () {
    Map<String, dynamic> _fullPayload() => {
          'invoice_id': 'INV-001',
          'customer_name': 'Test Customer',
          'pos_profile': 'Main POS',
          'grand_total': 150.5,
          'net_total': 130.0,
          'sales_invoice_state': 'Received',
          'acceptance_status': 'Pending',
          'requires_acceptance': true,
          'delivery_date': '2024-01-15',
          'delivery_time': '14:00',
          'item_summary': '2 items',
          'items': [
            {'item_code': 'A', 'item_name': 'Item A', 'qty': 1},
            {'item_code': 'B', 'item_name': 'Item B', 'qty': 2},
          ],
          'timestamp': '2024-01-15T10:00:00',
        };

    test('parses all fields from complete payload', () {
      final alert = InvoiceAlert.fromDynamic(_fullPayload());
      expect(alert.invoiceId, 'INV-001');
      expect(alert.customerName, 'Test Customer');
      expect(alert.posProfile, 'Main POS');
      expect(alert.grandTotal, 150.5);
      expect(alert.netTotal, 130.0);
      expect(alert.salesInvoiceState, 'Received');
      expect(alert.acceptanceStatus, 'Pending');
      expect(alert.requiresAcceptance, isTrue);
      expect(alert.deliveryDate, '2024-01-15');
      expect(alert.deliveryTime, '14:00');
      expect(alert.itemSummary, '2 items');
      expect(alert.items, hasLength(2));
      expect(alert.timestamp, DateTime(2024, 1, 15, 10));
      expect(alert.raw, isNotEmpty);
    });

    test('falls back to "name" when invoice_id is missing', () {
      final alert = InvoiceAlert.fromDynamic({
        'name': 'SINV-999',
        'pos_profile': 'P',
      });
      expect(alert.invoiceId, 'SINV-999');
    });

    test('invoiceId defaults to empty string when both keys missing', () {
      final alert = InvoiceAlert.fromDynamic({'pos_profile': 'P'});
      expect(alert.invoiceId, '');
    });

    test('falls back to "customer" when customer_name is missing', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'customer': 'Fallback Customer',
        'pos_profile': 'P',
      });
      expect(alert.customerName, 'Fallback Customer');
    });

    test('customerName is null when both customer keys missing', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
      });
      expect(alert.customerName, isNull);
    });

    test('falls back custom_acceptance_status', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'custom_acceptance_status': 'Accepted',
      });
      expect(alert.acceptanceStatus, 'Accepted');
    });

    test('acceptanceStatus defaults to Pending', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
      });
      expect(alert.acceptanceStatus, 'Pending');
    });

    test('requires_acceptance inferred from accepted status', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'acceptance_status': 'Accepted',
      });
      // requires_acceptance is null → inferred from acceptance != 'accepted'
      expect(alert.requiresAcceptance, isFalse);
    });

    test('requires_acceptance explicit override', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'acceptance_status': 'Accepted',
        'requires_acceptance': true,
      });
      expect(alert.requiresAcceptance, isTrue);
    });

    test('grand_total from string', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'grand_total': '99.99',
      });
      expect(alert.grandTotal, 99.99);
    });

    test('grand_total defaults to 0 when missing', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
      });
      expect(alert.grandTotal, 0);
    });

    test('parses status fallback for salesInvoiceState', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'status': 'Draft',
      });
      expect(alert.salesInvoiceState, 'Draft');
    });

    test('delivery_time falls back to delivery_time_from', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'delivery_time_from': '09:00',
      });
      expect(alert.deliveryTime, '09:00');
    });

    test('timestamp null for unparseable value', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'timestamp': 'not-a-date',
      });
      expect(alert.timestamp, isNull);
    });

    test('items from list of Map entries', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'items': [
          {'item_code': 'C', 'qty': 5},
        ],
      });
      expect(alert.items, hasLength(1));
      expect(alert.items.first.itemCode, 'C');
      expect(alert.items.first.quantity, 5);
    });

    test('items empty when key is null', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
      });
      expect(alert.items, isEmpty);
    });
  });

  // ── InvoiceAlert.fromFcmData ──────────────────────────────────────────

  group('InvoiceAlert.fromFcmData', () {
    test('parses items from JSON string', () {
      final alert = InvoiceAlert.fromFcmData({
        'invoice_id': 'INV-FCM',
        'pos_profile': 'P',
        'grand_total': '50',
        'items': '[{"item_code":"X","qty":1}]',
      });
      expect(alert.invoiceId, 'INV-FCM');
      expect(alert.items, hasLength(1));
      expect(alert.items.first.itemCode, 'X');
    });

    test('survives invalid JSON string for items', () {
      final alert = InvoiceAlert.fromFcmData({
        'invoice_id': 'INV-FCM',
        'pos_profile': 'P',
        'items': 'not json',
      });
      // items stays as string → _parseItems gets a string → returns empty
      expect(alert.items, isEmpty);
    });

    test('infers requiresAcceptance from acceptance_status', () {
      final alert = InvoiceAlert.fromFcmData({
        'invoice_id': 'INV-FCM',
        'pos_profile': 'P',
        'acceptance_status': 'Accepted',
      });
      expect(alert.requiresAcceptance, isFalse);
    });

    test('explicit requires_acceptance from FCM data', () {
      final alert = InvoiceAlert.fromFcmData({
        'invoice_id': 'INV-FCM',
        'pos_profile': 'P',
        'requires_acceptance': '1',
      });
      expect(alert.requiresAcceptance, isTrue);
    });
  });

  // ── InvoiceAlert.copyWith ─────────────────────────────────────────────

  group('InvoiceAlert.copyWith', () {
    late InvoiceAlert base;

    setUp(() {
      base = InvoiceAlert.fromDynamic({
        'invoice_id': 'INV-CW',
        'pos_profile': 'P',
        'acceptance_status': 'Pending',
        'requires_acceptance': true,
        'grand_total': 100,
      });
    });

    test('overrides acceptanceStatus', () {
      final copy = base.copyWith(acceptanceStatus: 'Accepted');
      expect(copy.acceptanceStatus, 'Accepted');
      expect(copy.invoiceId, 'INV-CW');
      expect(copy.requiresAcceptance, isTrue); // unchanged
    });

    test('overrides requiresAcceptance', () {
      final copy = base.copyWith(requiresAcceptance: false);
      expect(copy.requiresAcceptance, isFalse);
      expect(copy.acceptanceStatus, 'Pending'); // unchanged
    });

    test('preserves all fields with no args', () {
      final copy = base.copyWith();
      expect(copy.invoiceId, base.invoiceId);
      expect(copy.acceptanceStatus, base.acceptanceStatus);
      expect(copy.requiresAcceptance, base.requiresAcceptance);
      expect(copy.grandTotal, base.grandTotal);
    });
  });

  // ── InvoiceAlert getters ──────────────────────────────────────────────

  group('InvoiceAlert getters', () {
    test('isAccepted true when status is Accepted', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'acceptance_status': 'Accepted',
      });
      expect(alert.isAccepted, isTrue);
    });

    test('isAccepted true case-insensitive', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'acceptance_status': 'ACCEPTED',
      });
      expect(alert.isAccepted, isTrue);
    });

    test('isAccepted false for Pending', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'acceptance_status': 'Pending',
      });
      expect(alert.isAccepted, isFalse);
    });

    test('displayTotal formats to 2 decimals', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'grand_total': 123.4,
      });
      expect(alert.displayTotal, '123.40');
    });

    test('displayTotal for zero', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
      });
      expect(alert.displayTotal, '0.00');
    });
  });

  // ── Helper functions (tested indirectly via fromDynamic) ──────────────

  group('helper functions (indirect)', () {
    test('_parseBool handles num 0/1', () {
      // requires_acceptance: 0 → false
      final a1 = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'requires_acceptance': 0,
      });
      expect(a1.requiresAcceptance, isFalse);

      // requires_acceptance: 1 → true
      final a2 = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'requires_acceptance': 1,
      });
      expect(a2.requiresAcceptance, isTrue);
    });

    test('_parseBool handles string values', () {
      final a = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'requires_acceptance': 'yes',
      });
      expect(a.requiresAcceptance, isTrue);
    });

    test('_optionalString trims and returns null for empty', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'customer_name': '   ',
        'delivery_date': '',
      });
      expect(alert.customerName, isNull);
      expect(alert.deliveryDate, isNull);
    });

    test('_parseDate handles DateTime input', () {
      final dt = DateTime(2024, 6, 1, 12);
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'timestamp': dt,
      });
      expect(alert.timestamp, dt);
    });

    test('_parseItems handles non-Map entries gracefully', () {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'X',
        'pos_profile': 'P',
        'items': [42, 'string', null],
      });
      expect(alert.items, isEmpty);
    });
  });
}
