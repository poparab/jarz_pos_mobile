import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/sop.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';

const _key = 'WO-SOP-0001';

SopStep _step({
  required int no,
  bool requiresConfirmation = true,
  String captureType = SopCapture.none,
  double? min,
  double? max,
}) {
  return SopStep(
    stepNo: no,
    title: 'Step $no',
    instructionText: 'Do the thing $no',
    requiresConfirmation: requiresConfirmation,
    captureType: captureType,
    captureMin: min,
    captureMax: max,
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    // autoDispose: without a live listener the notifier is thrown away between
    // reads and every mutation would silently start from a fresh state.
    container.listen(sopExecutionProvider(_key), (_, _) {});
  });

  tearDown(() => container.dispose());

  SopExecutionNotifier notifier() =>
      container.read(sopExecutionProvider(_key).notifier);
  SopExecutionState read() => container.read(sopExecutionProvider(_key));

  group('SopRequest', () {
    test('is value-equal, so a rebuilt key does not refetch', () {
      const a = SopRequest(itemCode: 'CAKE-A', batches: 3);
      const b = SopRequest(itemCode: 'CAKE-A', batches: 3);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('separates different batch counts and different BOMs', () {
      const three = SopRequest(itemCode: 'CAKE-A', batches: 3);
      const four = SopRequest(itemCode: 'CAKE-A', batches: 4);
      const otherBom = SopRequest(itemCode: 'CAKE-A', bom: 'BOM-2', batches: 3);

      expect(three == four, isFalse);
      expect(three == otherBom, isFalse);
    });
  });

  group('advancing is gated on the current step', () {
    test('cannot advance past an unconfirmed step', () {
      notifier().bindSteps([_step(no: 1), _step(no: 2)]);

      expect(read().canAdvance, isFalse);
      expect(notifier().next(), isFalse);
      expect(read().currentIndex, 0);

      notifier().setConfirmed(0, true);

      expect(read().canAdvance, isTrue);
      expect(notifier().next(), isTrue);
      expect(read().currentIndex, 1);
    });

    test('cannot advance past a required-but-uncaptured step', () {
      notifier().bindSteps([
        _step(no: 1, captureType: SopCapture.temperature, min: 60, max: 80),
        _step(no: 2),
      ]);

      // Confirmation alone is not enough when a reading is required.
      notifier().setConfirmed(0, true);
      expect(read().canAdvance, isFalse);
      expect(notifier().next(), isFalse);
      expect(read().currentIndex, 0);

      notifier().recordValue(0, 72);
      expect(read().canAdvance, isTrue);
      expect(notifier().next(), isTrue);
      expect(read().currentIndex, 1);
    });

    test('clearing a reading closes the gate again', () {
      notifier().bindSteps([
        _step(no: 1, captureType: SopCapture.number),
        _step(no: 2),
      ]);
      notifier()
        ..setConfirmed(0, true)
        ..recordValue(0, 12);
      expect(read().canAdvance, isTrue);

      // What the capture field does with an out-of-range or blank entry.
      notifier().recordValue(0, null);
      expect(read().canAdvance, isFalse);
    });

    test('a photo step is satisfied by a local-only photo', () {
      notifier().bindSteps([
        _step(no: 1, captureType: SopCapture.photo, requiresConfirmation: false),
        _step(no: 2),
      ]);
      expect(read().canAdvance, isFalse);

      // Upload failed but the photo was genuinely taken: the operator is not
      // stranded, and the state still says nothing reached the server.
      notifier().recordPhoto(0, localPath: '/tmp/shot.jpg');
      expect(read().canAdvance, isTrue);
      expect(read().progressAt(0).photoIsLocalOnly, isTrue);
    });

    test('a step needing neither confirmation nor capture is already satisfied',
        () {
      notifier().bindSteps([
        _step(no: 1, requiresConfirmation: false),
        _step(no: 2),
      ]);

      expect(read().canAdvance, isTrue);
    });

    test('next() stops at the last step', () {
      notifier().bindSteps([_step(no: 1, requiresConfirmation: false)]);

      expect(read().isOnLastStep, isTrue);
      expect(notifier().next(), isFalse);
      expect(read().currentIndex, 0);
    });

    test('goTo allows going back but not jumping the gate', () {
      notifier().bindSteps([
        _step(no: 1, requiresConfirmation: false),
        _step(no: 2),
        _step(no: 3),
      ]);
      notifier().next();
      expect(read().currentIndex, 1);

      // Step 2 is unconfirmed — no skipping ahead to step 3.
      expect(notifier().goTo(2), isFalse);
      expect(read().currentIndex, 1);

      // Going back to re-read is always allowed.
      expect(notifier().goTo(0), isTrue);
      expect(read().currentIndex, 0);
    });
  });

  group('progress', () {
    test('fraction counts satisfied steps, not pages visited', () {
      notifier().bindSteps([
        _step(no: 1),
        _step(no: 2),
        _step(no: 3),
        _step(no: 4),
      ]);

      expect(read().progressFraction, 0);

      notifier().setConfirmed(0, true);
      expect(read().progressFraction, 0.25);
      expect(read().satisfiedCount, 1);

      // Moving the pager on its own changes nothing.
      notifier().next();
      expect(read().currentIndex, 1);
      expect(read().progressFraction, 0.25);

      notifier().setConfirmed(1, true);
      notifier().setConfirmed(2, true);
      notifier().setConfirmed(3, true);
      expect(read().progressFraction, 1.0);
      expect(read().isComplete, isTrue);
      expect(read().satisfiedFlags, [true, true, true, true]);
    });

    test('an empty document has no progress and cannot advance', () {
      expect(read().progressFraction, 0);
      expect(read().isComplete, isFalse);
      expect(read().canAdvance, isFalse);
    });
  });

  group('bindSteps', () {
    test('re-binding the same steps keeps the operator in place', () {
      final steps = [_step(no: 1), _step(no: 2)];
      notifier().bindSteps(steps);
      notifier().setConfirmed(0, true);
      notifier().next();

      notifier().bindSteps(List<SopStep>.from(steps));

      expect(read().currentIndex, 1);
      expect(read().progressAt(0).confirmed, isTrue);
    });

    test('a different document resets the run', () {
      notifier().bindSteps([_step(no: 1), _step(no: 2)]);
      notifier().setConfirmed(0, true);
      notifier().next();

      notifier().bindSteps([_step(no: 1), _step(no: 2), _step(no: 3)]);

      expect(read().currentIndex, 0);
      expect(read().satisfiedCount, 0);
    });
  });
}
