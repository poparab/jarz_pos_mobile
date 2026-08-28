import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/domain/base_batch_math.dart';

/// The arithmetic the Bases tab acts on.
///
/// Every number the floor sees comes through here, and a half batch lost to a
/// rounding slip is a second trip to the mixer — so the edges are pinned down
/// rather than assumed.
void main() {
  group('half-batch snapping', () {
    test('rounds to the nearest half', () {
      expect(snapToHalf(1.2), 1.0);
      expect(snapToHalf(1.3), 1.5);
      expect(snapToHalf(1.5), 1.5);
      expect(snapToHalf(2.74), 2.5);
      expect(snapToHalf(2.76), 3.0);
    });

    test('demand rounds up — 3.2 batches of demand needs 3.5 of mixing', () {
      expect(snapUpToHalf(3.2), 3.5);
      expect(snapUpToHalf(3.5), 3.5);
      expect(snapUpToHalf(0.1), 0.5);
      expect(snapUpToHalf(0), 0);
    });

    test('capacity rounds down — 2.9 batches of material runs 2.5', () {
      expect(snapDownToHalf(2.9), 2.5);
      expect(snapDownToHalf(2.5), 2.5);
      expect(snapDownToHalf(0.4), 0.0);
    });
  });

  group('clampBatches', () {
    test('holds the value inside what the tab will submit', () {
      expect(clampBatches(0), kMinBatches);
      expect(clampBatches(-3), kMinBatches);
      expect(clampBatches(1.5), 1.5);
      expect(clampBatches(9999), kMaxBatches);
    });

    test('a NaN from an unparseable field becomes the minimum, not a crash', () {
      expect(clampBatches(double.nan), kMinBatches);
    });
  });

  group('stepBatches', () {
    test('moves in halves', () {
      expect(stepBatches(1.0, kBatchStep), 1.5);
      expect(stepBatches(1.5, kBatchStep), 2.0);
      expect(stepBatches(1.5, -kBatchStep), 1.0);
    });

    test('cannot step below half a batch', () {
      expect(stepBatches(kMinBatches, -kBatchStep), kMinBatches);
    });

    test('pulls an off-grid value back onto the grid rather than drifting', () {
      // Effectively snap-then-step: a typed 1.2 is a 1.0 run, so "+" lands on
      // 1.5 and "-" on 0.5. Never 1.7 or 0.7.
      expect(stepBatches(1.2, kBatchStep), 1.5);
      expect(stepBatches(1.2, -kBatchStep), 0.5);
      expect(stepBatches(1.4, kBatchStep), 2.0);
    });
  });

  group('batch ↔ quantity conversion', () {
    // The one bridge between what the operator thinks in (batches) and what
    // `start_production_batch` takes (a stock quantity).
    test('itemQty is batches × yield', () {
      expect(itemQtyForBatches(1, 9.52), closeTo(9.52, 1e-9));
      expect(itemQtyForBatches(1.5, 9.52), closeTo(14.28, 1e-9));
      expect(itemQtyForBatches(0.5, 9.52), closeTo(4.76, 1e-9));
    });

    test('a zero or missing yield is treated as one unit, never as zero', () {
      // A zero here would submit a Work Order for nothing at all.
      expect(itemQtyForBatches(2, 0), 2);
      expect(itemQtyForBatches(2, -5), 2);
      expect(batchesForQty(2, 0), 2);
    });

    test('reads stock back as batches', () {
      expect(batchesForQty(17.136, 9.52), closeTo(1.8, 1e-9));
      expect(batchesForQty(0, 9.52), 0);
    });

    test('round-trips', () {
      const batches = 2.5;
      const batchYield = 7.3;
      expect(
        batchesForQty(itemQtyForBatches(batches, batchYield), batchYield),
        closeTo(batches, 1e-9),
      );
    });
  });

  group('run-size matching', () {
    test('no published grid means every figure is on-grid', () {
      expect(isRunSizeOk(1.5, null), isTrue);
      expect(isRunSizeOk(1.5, const []), isTrue);
      expect(isRunSizeOk(7.25, null), isTrue);
    });

    test('matches a published size', () {
      expect(isRunSizeOk(1.5, const [1, 1.5, 2]), isTrue);
      expect(isRunSizeOk(1, const [1, 1.5, 2]), isTrue);
    });

    test('flags a figure off the grid', () {
      expect(isRunSizeOk(2.5, const [1, 1.5, 2]), isFalse);
      expect(isRunSizeOk(0.5, const [1, 1.5, 2]), isFalse);
    });

    test('a size that survived JSON as 1.5000000000000002 still matches', () {
      // The whole reason the comparison is not `==`.
      expect(isRunSizeOk(1.5000000000000002, const [1.5]), isTrue);
      expect(isRunSizeOk(1.5, const [1.4999999999999998]), isTrue);
    });

    test('nearestRunSize picks the closest', () {
      expect(nearestRunSize(1.4, const [1, 1.5, 2]), 1.5);
      expect(nearestRunSize(2.4, const [1, 1.5, 2]), 2);
      expect(nearestRunSize(0.5, const [1, 1.5, 2]), 1);
    });

    test('a tie resolves to the first size listed, not to iteration luck', () {
      expect(nearestRunSize(1.25, const [1, 1.5]), 1);
      expect(nearestRunSize(1.25, const [1.5, 1]), 1.5);
    });

    test('nearestRunSize is null when nothing was published', () {
      expect(nearestRunSize(1.5, null), isNull);
      expect(nearestRunSize(1.5, const []), isNull);
    });
  });

  group('achievableBatchesFor', () {
    test('a preview at 1 batch scales up to what the store can cover', () {
      // 10 kg per batch, 25 kg on hand → 2.5 batches, and the half matters.
      final result = achievableBatchesFor(1, const [(10.0, 25.0)]);
      expect(result, 2.5);
    });

    test('rounds down — 2.9 batches of material runs 2.5', () {
      expect(achievableBatchesFor(1, const [(10.0, 29.0)]), 2.5);
    });

    test('the tightest component wins', () {
      final result = achievableBatchesFor(
        2,
        const [
          (20.0, 100.0), // covers 10 batches
          (6.0, 9.0), // covers 3
          (4.0, 40.0), // covers 20
        ],
      );
      expect(result, 3.0);
    });

    test('nothing on hand means nothing can be run', () {
      expect(achievableBatchesFor(2, const [(10.0, 0.0)]), 0);
      expect(achievableBatchesFor(2, const [(10.0, 2.0)]), 0);
    });

    test('a zero-qty BOM line cannot constrain the run', () {
      // Half-migrated BOMs carry these; dividing by one would make every run
      // look impossible.
      expect(achievableBatchesFor(1, const [(0.0, 0.0), (10.0, 30.0)]), 3.0);
    });

    test('a BOM with no real lines is not a constraint at all', () {
      expect(achievableBatchesFor(2, const []), 2);
      expect(achievableBatchesFor(2, const [(0.0, 0.0)]), 2);
    });

    test('floating point cannot swallow a whole half batch', () {
      // available/perBatch lands on 0.9999999999999999 here. Without the
      // relative nudge that snaps down to 0.5 and the tab tells the floor to
      // halve a run it can make in full.
      final result = achievableBatchesFor(1, const [(3.0, 2.9999999999999996)]);
      expect(result, 1.0);
    });

    test('the nudge does not round a genuine 2.4999 up to 2.5', () {
      expect(achievableBatchesFor(1, const [(10.0, 24.999)]), 2.0);
    });

    test('a nonsensical batch count yields nothing rather than infinity', () {
      expect(achievableBatchesFor(0, const [(10.0, 30.0)]), 0);
      expect(achievableBatchesFor(-1, const [(10.0, 30.0)]), 0);
    });
  });
}
