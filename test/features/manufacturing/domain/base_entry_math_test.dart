import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/domain/base_entry_math.dart';

void main() {
  group('roundQty', () {
    test('clears the float noise a jar sum leaves behind', () {
      // 40 mediums at 0.030 plus 20 larges at 0.040 is exactly 2 Kg to anybody
      // holding a tub, and 2.0000000000000004 in IEEE-754.
      expect(roundQty(40 * 0.03 + 20 * 0.04), 2.0);
    });

    test('keeps the gram', () {
      expect(roundQty(0.0304), 0.03);
      expect(roundQty(0.0306), 0.031);
    });

    test('degrades rather than propagating a NaN into a field', () {
      expect(roundQty(double.nan), 0);
      expect(roundQty(double.infinity), 0);
    });
  });

  group('roundQtyUpTo', () {
    test('rounds a shortfall up to something weighable', () {
      expect(roundQtyUpTo(1.42, 0.5), 1.5);
      expect(roundQtyUpTo(0.01, 0.5), 0.5);
    });

    test('leaves a figure already on the step alone', () {
      // The guard that matters: 2.0 arriving off a division as
      // 2.0000000000000004 must not ask for half a tub nobody needs.
      expect(roundQtyUpTo(2.0, 0.5), 2.0);
      expect(roundQtyUpTo(4 * 0.5, 0.5), 2.0);
    });

    test('a non-positive step is no step at all, not a division by zero', () {
      expect(roundQtyUpTo(1.234, 0), 1.234);
      expect(roundQtyUpTo(0, 0.5), 0);
    });
  });

  group('qtyForJarCounts', () {
    const perJar = {'MED': 0.03, 'LRG': 0.04};

    test('adds the sizes up', () {
      expect(qtyForJarCounts({'MED': 40, 'LRG': 20}, perJar), 2.0);
    });

    test('ignores a jar nobody lists rather than guessing a rate', () {
      expect(qtyForJarCounts({'MED': 10, 'MYSTERY': 999}, perJar), 0.3);
    });

    test('a negative count never subtracts another jar''s mix', () {
      expect(qtyForJarCounts({'MED': 10, 'LRG': -50}, perJar), 0.3);
    });

    test('a zero rate contributes nothing and cannot poison the sum', () {
      expect(qtyForJarCounts({'MED': 10}, const {'MED': 0}), 0);
    });

    test('nothing typed is nothing needed', () {
      expect(qtyForJarCounts(const {}, perJar), 0);
    });
  });

  group('jarsFromQty', () {
    test('floors, because a jar is either filled or it is not', () {
      expect(jarsFromQty(0.58, 0.03), 19);
      expect(jarsFromQty(0.09, 0.03), 3);
    });

    test('does not lose a jar to float error', () {
      // 0.3 / 0.1 is 2.9999999999999996 in IEEE-754; a naive floor says 2.
      expect(jarsFromQty(0.3, 0.1), 3);
      expect(jarsFromQty(0.7, 0.1), 7);
    });

    test('an unusable rate or an empty store fills nothing', () {
      expect(jarsFromQty(1.0, 0), 0);
      expect(jarsFromQty(0, 0.03), 0);
      expect(jarsFromQty(-5, 0.03), 0);
    });
  });

  group('qtyStillNeeded', () {
    test('counts what the store already covers', () {
      expect(qtyStillNeeded(required: 2.0, onHand: 0.58), 1.42);
    });

    test('a covered requirement needs nothing', () {
      expect(qtyStillNeeded(required: 0.4, onHand: 0.58), 0);
      expect(qtyStillNeeded(required: 0.58, onHand: 0.58), 0);
    });

    test('a negative Bin is a counting lag, never an extra requirement', () {
      // The error that put 81 invented batches on the jar board: subtracting a
      // negative adds a phantom hole on top of the real need.
      expect(qtyStillNeeded(required: 2.0, onHand: -3.0), 2.0);
    });
  });

  group('clampQty', () {
    test('holds a typed figure to what the materials cover', () {
      expect(clampQty(5.0, max: 2.5), 2.5);
      expect(clampQty(1.0, max: 2.5), 1.0);
    });

    test('an unknown ceiling does not clamp to zero', () {
      // Null max means nobody worked one out. Treating that as "nothing is
      // possible" would make every base un-makeable the moment a preview fails.
      expect(clampQty(7.0), 7.0);
      expect(clampQty(7.0, max: 0), 7.0);
    });

    test('never negative', () {
      expect(clampQty(-3), 0);
      expect(clampQty(double.nan), 0);
    });
  });

  group('niceQtyStep', () {
    test('steps a mix by a quarter of its recipe, landing on a round figure', () {
      expect(niceQtyStep(2.0), 0.5);
      expect(niceQtyStep(3.0), 0.5);
      expect(niceQtyStep(5.898), 1.0);
    });

    test('a tiny or missing yield still steps by something usable', () {
      expect(niceQtyStep(0.1), 0.05);
      expect(niceQtyStep(0), 0.05);
    });
  });
}
