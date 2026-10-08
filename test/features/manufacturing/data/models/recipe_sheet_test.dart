import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/recipe_sheet.dart';

void main() {
  group('RecipeSheetResponse.fromJson', () {
    test('reads a full sheet', () {
      final response = RecipeSheetResponse.fromJson({
        'sheets': [
          {
            'title': 'Tiramisu',
            'items': [
              {
                'item_code': 'Tiramisu Large',
                'item_name': 'Tiramisu Large',
                'qty': 10,
              },
              {
                'item_code': 'Tiramisu Medium',
                'item_name': 'Tiramisu Medium',
                'qty': 12.0,
              },
            ],
            'total_qty': 22,
            'ingredients': [
              {
                'item_code': 'Coffee beans',
                'item_name': 'Coffee beans',
                'qty': 0.1653,
                'uom': 'Kg',
                'display': '165.3 g',
              },
            ],
            'steps': [
              {
                'step_no': 1,
                'title': 'Brew the coffee',
                'text': 'Brew 165.3 g\nاعمل 496 جرام',
                'per_item': null,
              },
              {
                'step_no': 4,
                'title': 'Fill each jar',
                'text': null,
                'per_item': [
                  {
                    'item_code': 'Tiramisu Large',
                    'item_name': 'Tiramisu Large',
                    'qty': 10,
                    'text': '40 g savoiardi\n40 جرام سافوياردي',
                  },
                ],
              },
            ],
            'unresolved_tokens': ['{{x}}'],
          },
        ],
      });

      expect(response.sheets, hasLength(1));
      final sheet = response.sheets.single;
      expect(sheet.title, 'Tiramisu');
      expect(sheet.items.map((i) => i.qty), [10.0, 12.0]);
      expect(sheet.totalQty, 22.0);
      final coffee = sheet.ingredients.single;
      expect(coffee.itemName, 'Coffee beans');
      expect(coffee.qty, closeTo(0.1653, 1e-9));
      expect(coffee.uom, 'Kg');
      expect(coffee.display, '165.3 g');
      expect(sheet.steps.first.stepNo, 1);
      expect(sheet.steps.first.text, contains('اعمل'));
      expect(sheet.steps.first.perItem, isNull);
      final fill = sheet.steps.last;
      expect(fill.text, isNull);
      expect(fill.perItem!.single.itemCode, 'Tiramisu Large');
      expect(fill.perItem!.single.qty, 10.0);
      expect(fill.perItem!.single.text, startsWith('40 g'));
      expect(sheet.unresolvedTokens, ['{{x}}']);
    });

    test('missing keys fall back to defaults', () {
      final response = RecipeSheetResponse.fromJson({
        'sheets': [
          <String, dynamic>{},
          {
            'items': [<String, dynamic>{}],
            'ingredients': [
              {'item_code': 'Sugar', 'qty': '0.5'},
            ],
            'steps': [
              {'step_no': 2.0},
              'not a map',
            ],
            'total_qty': 'not a number',
          },
        ],
      });

      final empty = response.sheets.first;
      expect(empty.title, '');
      expect(empty.items, isEmpty);
      expect(empty.ingredients, isEmpty);
      expect(empty.steps, isEmpty);
      expect(empty.unresolvedTokens, isEmpty);
      expect(empty.totalQty, 0);

      final partial = response.sheets.last;
      expect(partial.items.single.itemCode, '');
      expect(partial.items.single.qty, 0);
      expect(partial.ingredients.single.displayName, 'Sugar');
      expect(partial.ingredients.single.qty, 0.5);
      expect(partial.ingredients.single.display, '');
      expect(partial.steps, hasLength(1));
      expect(partial.steps.single.stepNo, 2);
      expect(partial.steps.single.title, '');
      expect(partial.steps.single.text, isNull);
      expect(partial.steps.single.perItem, isNull);
      expect(partial.totalQty, 0);
    });

    test('no sheets at all is an empty response', () {
      expect(RecipeSheetResponse.fromJson({}).isEmpty, isTrue);
      expect(RecipeSheetResponse.fromJson({'sheets': null}).isEmpty, isTrue);
    });
  });
}
