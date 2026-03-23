import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_filter_options.dart';

void main() {
  group('FilterOption', () {
    test('fromJson parses value and label', () {
      final opt = FilterOption.fromJson({'value': 'CUST-1', 'label': 'Alice'});
      expect(opt.value, 'CUST-1');
      expect(opt.label, 'Alice');
    });

    test('fromJson defaults to empty strings on missing keys', () {
      final opt = FilterOption.fromJson({});
      expect(opt.value, '');
      expect(opt.label, '');
    });

    test('toJson produces the correct map', () {
      final opt = FilterOption(value: 'V', label: 'L');
      expect(opt.toJson(), {'value': 'V', 'label': 'L'});
    });

    test('roundtrip fromJson → toJson preserves data', () {
      final original = {'value': 'X', 'label': 'Y'};
      final parsed = FilterOption.fromJson(original);
      expect(parsed.toJson(), original);
    });
  });

  group('KanbanFilterOptions', () {
    test('holds customers and states lists', () {
      final opts = KanbanFilterOptions(
        customers: [FilterOption(value: 'C1', label: 'Customer One')],
        states: [FilterOption(value: 'Received', label: 'Received')],
      );
      expect(opts.customers, hasLength(1));
      expect(opts.states, hasLength(1));
      expect(opts.customers.first.value, 'C1');
      expect(opts.states.first.label, 'Received');
    });

    test('accepts empty lists', () {
      final opts =
          KanbanFilterOptions(customers: const [], states: const []);
      expect(opts.customers, isEmpty);
      expect(opts.states, isEmpty);
    });
  });
}
