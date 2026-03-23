import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/courier_option.dart';

void main() {
  group('CourierOption', () {
    test('fromJson parses all fields', () {
      final opt = CourierOption.fromJson({
        'party_type': 'Employee',
        'party': 'HR-EMP-00001',
        'display_name': 'Ahmed',
      });
      expect(opt.partyType, 'Employee');
      expect(opt.party, 'HR-EMP-00001');
      expect(opt.displayName, 'Ahmed');
    });

    test('fromJson falls back to name then party for displayName', () {
      // Falls back to json['name'] when display_name missing
      final opt1 = CourierOption.fromJson({
        'party_type': 'Supplier',
        'party': 'SUP-001',
        'name': 'Supplier John',
      });
      expect(opt1.displayName, 'Supplier John');

      // Falls back to party when both display_name and name missing
      final opt2 = CourierOption.fromJson({
        'party_type': 'Employee',
        'party': 'EMP-002',
      });
      expect(opt2.displayName, 'EMP-002');
    });

    test('fromJson defaults to empty strings on null values', () {
      final opt = CourierOption.fromJson({});
      expect(opt.partyType, '');
      expect(opt.party, '');
      expect(opt.displayName, '');
    });

    test('toMap produces snake_case keys', () {
      final opt = CourierOption(
        partyType: 'Employee',
        party: 'EMP-1',
        displayName: 'Ali',
      );
      final map = opt.toMap();
      expect(map, {
        'party_type': 'Employee',
        'party': 'EMP-1',
        'display_name': 'Ali',
      });
    });

    test('roundtrip fromJson → toMap preserves data', () {
      final json = {
        'party_type': 'Employee',
        'party': 'EMP-1',
        'display_name': 'Ali',
      };
      final opt = CourierOption.fromJson(json);
      expect(opt.toMap(), json);
    });
  });
}
