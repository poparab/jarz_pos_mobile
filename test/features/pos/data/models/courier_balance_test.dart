import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';

void main() {
  group('CourierBalance.fromMap', () {
    test('parses a complete map', () {
      final bal = CourierBalance.fromMap({
        'courier': 'EMP-001',
        'courier_name': 'Ali',
        'balance': 150.5,
        'party_type': 'Employee',
        'party': 'HR-EMP-00001',
        'details': [
          {'invoice': 'INV-1', 'city': 'Metro', 'amount': 100, 'shipping': 50.5},
        ],
      });

      expect(bal.courier, 'EMP-001');
      expect(bal.courierName, 'Ali');
      expect(bal.balance, 150.5);
      expect(bal.partyType, 'Employee');
      expect(bal.party, 'HR-EMP-00001');
      expect(bal.details, hasLength(1));
    });

    test('uses courierName fallback key', () {
      final bal = CourierBalance.fromMap({
        'courierName': 'Fallback',
        'balance': 0,
        'details': [],
      });
      expect(bal.courierName, 'Fallback');
    });

    test('handles null/missing fields with defaults', () {
      final bal = CourierBalance.fromMap({});
      expect(bal.courier, '');
      expect(bal.courierName, '');
      expect(bal.balance, 0.0);
      expect(bal.partyType, '');
      expect(bal.party, '');
      expect(bal.details, isEmpty);
    });

    test('parses balance from string', () {
      final bal = CourierBalance.fromMap({
        'balance': '123.45',
        'details': [],
      });
      expect(bal.balance, 123.45);
    });

    test('parses balance from int', () {
      final bal = CourierBalance.fromMap({
        'balance': 100,
        'details': [],
      });
      expect(bal.balance, 100.0);
    });

    test('parses balance from null as 0', () {
      final bal = CourierBalance.fromMap({
        'balance': null,
        'details': [],
      });
      expect(bal.balance, 0.0);
    });

    test('parses balance from unparseable string as 0', () {
      final bal = CourierBalance.fromMap({
        'balance': 'not-a-number',
        'details': [],
      });
      expect(bal.balance, 0.0);
    });
  });

  group('CourierBalanceDetail.fromMap', () {
    test('parses a complete detail map', () {
      final detail = CourierBalanceDetail.fromMap({
        'invoice': 'INV-001',
        'city': 'Downtown',
        'amount': 75.0,
        'shipping': 25.0,
      });

      expect(detail.invoice, 'INV-001');
      expect(detail.city, 'Downtown');
      expect(detail.amount, 75.0);
      expect(detail.shipping, 25.0);
    });

    test('handles missing fields with defaults', () {
      final detail = CourierBalanceDetail.fromMap({});
      expect(detail.invoice, '');
      expect(detail.city, '');
      expect(detail.amount, 0.0);
      expect(detail.shipping, 0.0);
    });

    test('parses numeric strings', () {
      final detail = CourierBalanceDetail.fromMap({
        'amount': '99.9',
        'shipping': '10',
      });
      expect(detail.amount, 99.9);
      expect(detail.shipping, 10.0);
    });
  });
}
