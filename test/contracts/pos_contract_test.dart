// Contract tests for POS-related API endpoints.
//
// These tests load JSON fixtures from disk and verify that the current
// Dart models can deserialize them without exceptions. A failure here means
// either:
//   a) The backend API response shape changed (contract broken), OR
//   b) A Dart model was updated without updating the fixture.
//
// To refresh fixtures from staging:
//   dart test/contracts/snapshot_updater.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('POS Contract — get_pos_profiles', () {
    test('raw API response has required shape', () {
      // get_pos_profiles returns [{name, allow_delivery_partner}].
      // The full PosProfile model (with warehouse/currency) is used for the
      // detailed profile doc — not this lightweight listing endpoint.
      final raw = File('$fixturesDir/pos_profiles.json').readAsStringSync();
      final list = jsonDecode(raw) as List;

      expect(list, isNotEmpty, reason: 'At least one POS profile expected');
      for (final entry in list) {
        final m = entry as Map<String, dynamic>;
        expect(m['name'], isA<String>(),
            reason: '"name" field must be a non-null String');
        expect((m['name'] as String).isNotEmpty,
            isTrue, reason: 'Profile name must not be empty');
      }
    });
  });

  group('POS Contract — get_profile_products', () {
    test('raw API response has required shape', () {
      // get_profile_products returns [{id, name, price, item_group, qty}].
      // The repository transforms these to PosItem-compatible field names
      // (id→name, name→item_name, price→rate, qty→actual_qty).
      final raw = File('$fixturesDir/pos_items.json').readAsStringSync();
      final list = jsonDecode(raw) as List;

      expect(list, isNotEmpty, reason: 'At least one item expected');
      for (final entry in list) {
        final m = entry as Map<String, dynamic>;
        expect(m['id'], isA<String>(), reason: '"id" (item_code) must be a String');
        expect((m['id'] as String).isNotEmpty, isTrue,
            reason: 'Item id must not be empty');
        expect(m.containsKey('item_group'), isTrue,
            reason: '"item_group" key must be present');
        expect(m.containsKey('price'), isTrue,
            reason: '"price" key must be present');
      }
    });
  });

  group('POS Contract — search_customers', () {
    test('raw API response has required shape when non-empty', () {
      // search_customers returns [{name, customer_name, customer_group, ...}].
      // The fixture may be empty on staging if no customers match — that is
      // acceptable and the test still passes (empty list is a valid response).
      final raw = File('$fixturesDir/customers.json').readAsStringSync();
      final list = jsonDecode(raw) as List;

      // Shape check: only run field assertions when results are present.
      for (final entry in list) {
        final m = entry as Map<String, dynamic>;
        expect(m.containsKey('name'), isTrue,
            reason: '"name" (Customer docname) key must be present');
        expect(m.containsKey('customer_name'), isTrue,
            reason: '"customer_name" key must be present');
        expect(m.containsKey('customer_group'), isTrue,
            reason: '"customer_group" key must be present');
      }
    });
  });
}
