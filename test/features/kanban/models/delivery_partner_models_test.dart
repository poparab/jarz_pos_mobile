import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/courier_option.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';

void main() {
  group('CourierOption - Delivery Partner', () {
    test('fromJson parses delivery_partner', () {
      final option = CourierOption.fromJson({
        'party_type': 'Employee',
        'party': 'EMP-001',
        'display_name': 'John Doe',
        'delivery_partner': 'Partner A',
      });

      expect(option.deliveryPartner, 'Partner A');
      expect(option.isPartnerCourier, true);
    });

    test('fromJson handles null delivery_partner', () {
      final option = CourierOption.fromJson({
        'party_type': 'Supplier',
        'party': 'SUP-001',
        'display_name': 'Courier Co',
      });

      expect(option.deliveryPartner, isNull);
      expect(option.isPartnerCourier, false);
    });

    test('fromJson handles empty string delivery_partner', () {
      final option = CourierOption.fromJson({
        'party_type': 'Employee',
        'party': 'EMP-002',
        'display_name': 'Jane',
        'delivery_partner': '',
      });

      expect(option.deliveryPartner, isNull);
      expect(option.isPartnerCourier, false);
    });

    test('toMap includes delivery_partner when set', () {
      final option = CourierOption(
        partyType: 'Employee',
        party: 'EMP-001',
        displayName: 'John',
        deliveryPartner: 'Partner B',
      );

      final map = option.toMap();
      expect(map['delivery_partner'], 'Partner B');
    });

    test('toMap excludes delivery_partner when null', () {
      final option = CourierOption(
        partyType: 'Employee',
        party: 'EMP-001',
        displayName: 'John',
      );

      final map = option.toMap();
      expect(map.containsKey('delivery_partner'), false);
    });
  });

  group('CourierBalance - Delivery Partner', () {
    test('fromMap parses delivery_partner', () {
      final balance = CourierBalance.fromMap({
        'courier': 'EMP-001',
        'courier_name': 'John Doe',
        'balance': 500.0,
        'details': [],
        'party_type': 'Employee',
        'party': 'EMP-001',
        'delivery_partner': 'Partner A',
      });

      expect(balance.deliveryPartner, 'Partner A');
      expect(balance.isPartnerCourier, true);
    });

    test('fromMap handles null delivery_partner', () {
      final balance = CourierBalance.fromMap({
        'courier': 'SUP-001',
        'courier_name': 'Regular Courier',
        'balance': 200.0,
        'details': [],
        'party_type': 'Supplier',
        'party': 'SUP-001',
      });

      expect(balance.deliveryPartner, isNull);
      expect(balance.isPartnerCourier, false);
    });

    test('fromMap handles empty delivery_partner string', () {
      final balance = CourierBalance.fromMap({
        'courier': 'EMP-002',
        'courier_name': 'Jane',
        'balance': 0,
        'details': [],
        'party_type': 'Employee',
        'party': 'EMP-002',
        'delivery_partner': '',
      });

      expect(balance.deliveryPartner, isNull);
      expect(balance.isPartnerCourier, false);
    });

    test('fromMap parses partner balance with details', () {
      final balance = CourierBalance.fromMap({
        'courier': 'EMP-001',
        'courier_name': 'John',
        'balance': 800.0,
        'details': [
          {'invoice': 'INV-001', 'city': 'Amman', 'amount': 500, 'shipping': 50},
          {'invoice': 'INV-002', 'city': 'Zarqa', 'amount': 300, 'shipping': 30},
        ],
        'party_type': 'Employee',
        'party': 'EMP-001',
        'delivery_partner': 'Fast Delivery Co',
      });

      expect(balance.deliveryPartner, 'Fast Delivery Co');
      expect(balance.isPartnerCourier, true);
      expect(balance.details.length, 2);
      expect(balance.details[0].invoice, 'INV-001');
      expect(balance.details[1].shipping, 30.0);
    });
  });

  group('CourierBalanceDetail', () {
    test('fromMap parses correctly', () {
      final detail = CourierBalanceDetail.fromMap({
        'invoice': 'INV-100',
        'city': 'Amman',
        'amount': 500.0,
        'shipping': 50.0,
      });

      expect(detail.invoice, 'INV-100');
      expect(detail.city, 'Amman');
      expect(detail.amount, 500.0);
      expect(detail.shipping, 50.0);
    });

    test('fromMap handles string numbers', () {
      final detail = CourierBalanceDetail.fromMap({
        'invoice': 'INV-101',
        'city': 'Irbid',
        'amount': '350.5',
        'shipping': '35',
      });

      expect(detail.amount, 350.5);
      expect(detail.shipping, 35.0);
    });

    test('fromMap handles missing fields', () {
      final detail = CourierBalanceDetail.fromMap({});

      expect(detail.invoice, '');
      expect(detail.city, '');
      expect(detail.amount, 0.0);
      expect(detail.shipping, 0.0);
    });
  });
}
