import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/stock_alternative.dart';
import 'package:jarz_pos/src/features/manufacturing/domain/stock_elsewhere.dart';

void main() {
  group('StockElsewhere.resolve', () {
    test('absent fields resolve to null — nobody looked', () {
      // The screens render exactly what they rendered before the feature: no
      // empty row, no "unknown".
      expect(
        StockElsewhere.resolve(availableElsewhere: null, alternatives: null),
        isNull,
      );
    });

    test('zero with an empty list is a real answer, not an absence', () {
      final hint = StockElsewhere.resolve(
        availableElsewhere: 0.0,
        alternatives: const <StockAlternative>[],
      );

      expect(hint, isNotNull);
      expect(hint!.verdict, StockElsewhereVerdict.nowhere);
      expect(hint.isFound, isFalse);
      expect(hint.alternatives, isEmpty);
    });

    test('an empty list on its own still counts as having looked', () {
      // A backend that sends the list but omits the total has still answered.
      final hint = StockElsewhere.resolve(
        alternatives: const <StockAlternative>[],
      );
      expect(hint!.verdict, StockElsewhereVerdict.nowhere);
    });

    test('populated names the fullest warehouse first', () {
      final hint = StockElsewhere.resolve(
        availableElsewhere: 48.5,
        alternatives: const [
          StockAlternative(warehouse: 'Nasr City - J', availableQty: 8.0),
          StockAlternative(warehouse: 'Stores - J', availableQty: 40.5),
        ],
      );

      expect(hint!.isFound, isTrue);
      expect(hint.top.warehouse, 'Stores - J');
      expect(hint.top.availableQty, 40.5);
      // One line, not a list: the banner is dense and one place to go is enough.
      expect(hint.otherCount, 1);
    });

    test('a single warehouse has nothing to count as "and N more"', () {
      final hint = StockElsewhere.resolve(
        availableElsewhere: 40.5,
        alternatives: const [
          StockAlternative(warehouse: 'Stores - J', availableQty: 40.5),
        ],
      );

      expect(hint!.otherCount, 0);
    });

    test('empty or non-positive rows are dropped', () {
      // A warehouse holding nothing is not somewhere to go, and an unnamed one
      // cannot be told to the operator.
      final hint = StockElsewhere.resolve(
        availableElsewhere: 5.0,
        alternatives: const [
          StockAlternative(warehouse: '', availableQty: 3.0),
          StockAlternative(warehouse: 'Stores - J', availableQty: 0.0),
          StockAlternative(warehouse: 'Nasr City - J', availableQty: 5.0),
        ],
      );

      expect(hint!.alternatives, hasLength(1));
      expect(hint.top.warehouse, 'Nasr City - J');
    });

    test('a positive total with nothing to name stays silent', () {
      // Degenerate: reporting "none in any other store" against a positive
      // figure would be worse than saying nothing at all.
      final hint = StockElsewhere.resolve(
        availableElsewhere: 12.0,
        alternatives: const <StockAlternative>[],
      );

      expect(hint, isNull);
    });
  });
}
