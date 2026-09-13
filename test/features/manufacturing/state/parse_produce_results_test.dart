import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_today_providers.dart';

void main() {
  group('parseProduceResults', () {
    test('a per-line ERPNext stock refusal reads as text, not HTML', () {
      final outcomes = parseProduceResults({
        'results': [
          {
            'ok': false,
            'line': {'item_code': 'Chocolate Hazelnut Large'},
            'error':
                '<strong>21.0</strong> units of <a href="/desk/item/Chocolate%20Hazelnut%20Jar%20Label%20330" '
                'style="font-weight: bold;">Item Chocolate Hazelnut Jar Label 330</a> needed in '
                '<a href="/desk/warehouse/Raw%20Material%20-%20J" style="font-weight: bold;">'
                'Warehouse Raw Material - J</a> to complete this transaction.',
          },
        ],
      });

      expect(outcomes.single.ok, isFalse);
      expect(
        outcomes.single.error,
        '21.0 units of Item Chocolate Hazelnut Jar Label 330 needed in '
        'Warehouse Raw Material - J to complete this transaction.',
      );
    });

    test('a success carries no error and a blank error stays blank', () {
      final outcomes = parseProduceResults({
        'results': [
          {
            'ok': true,
            'work_order': 'MFG-WO-1',
            'line': {'item_code': 'A'},
          },
          {
            'ok': false,
            'line': {'item_code': 'B'},
          },
        ],
      });

      expect(outcomes[0].error, isNull);
      expect(outcomes[1].error, '');
    });
  });
}
