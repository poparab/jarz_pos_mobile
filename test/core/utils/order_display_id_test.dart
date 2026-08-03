import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/utils/order_display_id.dart';

void main() {
  group('orderDisplayId', () {
    test('prefers the WooCommerce number over the ERPNext invoice name', () {
      expect(
        orderDisplayId('ACC-SINV-2026-00123', wooOrderId: 16834),
        '#16834',
      );
    });

    test('parses a Woo id that arrived as a string (FCM data payload)', () {
      expect(orderDisplayId('ACC-SINV-2026-00123', wooOrderId: '16834'), '#16834');
    });

    test('parses a Woo id that arrived as a num (JSON double)', () {
      expect(orderDisplayId('ACC-SINV-2026-00123', wooOrderId: 16834.0), '#16834');
    });

    test('treats woo_order_id 0 as no Woo order, never renders #0', () {
      // woo_order_id is an Int custom field, so POS-native orders read back as 0.
      expect(orderDisplayId('ACC-SINV-2026-00123', wooOrderId: 0), '2026-00123');
      expect(orderDisplayId('ACC-SINV-2026-00123', wooOrderId: '0'), '2026-00123');
    });

    test('falls back to the invoice name with the ACC-SINV- prefix stripped', () {
      expect(orderDisplayId('ACC-SINV-2026-00123'), '2026-00123');
    });

    test('leaves a name that does not carry the prefix untouched', () {
      expect(orderDisplayId('SINV-0007'), 'SINV-0007');
    });

    test('returns empty for a missing or blank invoice name and no Woo id', () {
      expect(orderDisplayId(null), '');
      expect(orderDisplayId('   '), '');
    });

    test('still renders the Woo id when the invoice name is missing', () {
      expect(orderDisplayId(null, wooOrderId: 42), '#42');
    });

    test('ignores an unparseable Woo id', () {
      expect(orderDisplayId('ACC-SINV-2026-00123', wooOrderId: 'not-a-number'),
          '2026-00123');
    });
  });

  group('normalizeWooOrderId', () {
    test('collapses null, zero and blank to null', () {
      expect(normalizeWooOrderId(null), isNull);
      expect(normalizeWooOrderId(0), isNull);
      expect(normalizeWooOrderId('0'), isNull);
      expect(normalizeWooOrderId(''), isNull);
      expect(normalizeWooOrderId('  '), isNull);
    });

    test('accepts int, num and String forms', () {
      expect(normalizeWooOrderId(16834), 16834);
      expect(normalizeWooOrderId(16834.0), 16834);
      expect(normalizeWooOrderId(' 16834 '), 16834);
    });
  });
}
