import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';

/// Storage is not the unit under test, and Hive is not initialised in tests.
class _FakeBasketRepository implements ProductionBasketRepository {
  ProductionBasket? stored;
  int saveCount = 0;

  @override
  Future<ProductionBasket?> load() async => stored;

  @override
  Future<void> save(ProductionBasket basket) async {
    saveCount++;
    stored = basket;
  }

  @override
  Future<void> clear() async => stored = null;
}

ProductionSuggestion _suggestion({
  required String itemCode,
  String status = ProductionStatus.critical,
  int suggestedBatches = 5,
  int? canMakeNowBatches,
  double bomQty = 10,
}) {
  return ProductionSuggestion(
    itemCode: itemCode,
    itemName: '$itemCode name',
    defaultBom: 'BOM-$itemCode',
    stockUom: 'Nos',
    bomQty: bomQty,
    status: status,
    suggestedBatches: suggestedBatches,
    suggestedUnits: suggestedBatches * bomQty,
    canMakeNowBatches: canMakeNowBatches,
  );
}

void main() {
  late ProviderContainer container;
  late _FakeBasketRepository repo;

  setUp(() {
    repo = _FakeBasketRepository();
    container = ProviderContainer(
      overrides: [
        productionBasketRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  ProductionBasketNotifier notifier() =>
      container.read(productionBasketProvider.notifier);
  ProductionBasket basket() => container.read(productionBasketProvider);

  group('addOrRaise', () {
    test('adds a new line', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 3,
      ));

      expect(basket().lines, hasLength(1));
      expect(basket().lines.first.batches, 3);
      expect(basket().lines.first.units, 30);
    });

    test('raises an existing line to the larger value rather than summing', () {
      // Tapping Add twice on a row suggesting 5 batches means 5, not 10.
      final line = const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 5,
      );
      notifier().addOrRaise(line);
      notifier().addOrRaise(line);

      expect(basket().lines, hasLength(1));
      expect(basket().lines.first.batches, 5);
    });

    test('never lowers an existing line', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 8,
      ));
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 2,
      ));

      expect(basket().lines.first.batches, 8);
    });
  });

  group('quantity linkage', () {
    setUp(() {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 8,
        batches: 1,
      ));
    });

    test('setting batches derives units', () {
      notifier().setBatches(0, 3);
      expect(basket().lines.first.units, 24);
    });

    test('setting units derives batches', () {
      notifier().setUnits(0, 24);
      expect(basket().lines.first.batches, 3);
    });

    test('negative input clamps to zero rather than inverting the line', () {
      notifier().setBatches(0, -5);
      expect(basket().lines.first.batches, 0);
      expect(basket().lines.first.units, 0);
    });

    test('a zero-yield BOM does not divide by zero', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'ODD',
        itemName: 'Odd',
        bomName: 'BOM-ODD',
        bomQtyYield: 0,
        batches: 1,
      ));
      notifier().setUnits(1, 10);
      expect(basket().lines[1].batches, 0);
    });

    test('an out-of-range index is ignored', () {
      notifier().setBatches(99, 3);
      expect(basket().lines.first.batches, 1);
    });
  });

  group('fillTheDay', () {
    test('adds critical and low items and skips covered ones', () {
      final result = notifier().fillTheDay([
        _suggestion(itemCode: 'CRIT', status: ProductionStatus.critical),
        _suggestion(itemCode: 'LOW', status: ProductionStatus.low),
        _suggestion(
          itemCode: 'FINE',
          status: ProductionStatus.ok,
          suggestedBatches: 0,
        ),
        _suggestion(
          itemCode: 'DEAD',
          status: ProductionStatus.noVelocity,
          suggestedBatches: 0,
        ),
      ]);

      expect(basket().lines.map((l) => l.itemCode), ['CRIT', 'LOW']);
      expect(result.itemsAdded, 2);
      expect(result.batchesAdded, 10);
    });

    test('caps each line at what materials actually allow', () {
      final result = notifier().fillTheDay([
        _suggestion(
          itemCode: 'CAPPED',
          suggestedBatches: 5,
          canMakeNowBatches: 3,
        ),
      ]);

      expect(basket().lines.first.batches, 3);
      expect(result.cappedByMaterials, 1);
      expect(result.itemsAdded, 1);
    });

    test('reports items it could not start at all instead of dropping them', () {
      // A silent skip reads as "covered everything" when it wasn't.
      final result = notifier().fillTheDay([
        _suggestion(
          itemCode: 'BLOCKED',
          suggestedBatches: 5,
          canMakeNowBatches: 0,
        ),
      ]);

      expect(basket().lines, isEmpty);
      expect(result.skippedNoMaterials, 1);
      expect(result.addedNothing, isTrue);
    });

    test('capByCapacity false ignores material limits', () {
      notifier().fillTheDay(
        [
          _suggestion(
            itemCode: 'CAPPED',
            suggestedBatches: 5,
            canMakeNowBatches: 3,
          ),
        ],
        capByCapacity: false,
      );

      expect(basket().lines.first.batches, 5);
    });

    test('null capacity means unconstrained, not zero', () {
      notifier().fillTheDay([
        _suggestion(itemCode: 'NOCAP', suggestedBatches: 4),
      ]);
      expect(basket().lines.first.batches, 4);
    });

    test('running it twice does not double the basket', () {
      final suggestions = [_suggestion(itemCode: 'CRIT', suggestedBatches: 5)];
      notifier().fillTheDay(suggestions);
      final second = notifier().fillTheDay(suggestions);

      expect(basket().lines, hasLength(1));
      expect(basket().lines.first.batches, 5);
      expect(second.itemsAdded, 0);
    });

    test('raises a line the user had already queued lower', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CRIT',
        itemName: 'Crit',
        bomName: 'BOM-CRIT',
        bomQtyYield: 10,
        batches: 2,
      ));

      final result = notifier().fillTheDay([
        _suggestion(itemCode: 'CRIT', suggestedBatches: 5),
      ]);

      expect(basket().lines.first.batches, 5);
      // only the incremental batches are reported as added
      expect(result.batchesAdded, 3);
    });
  });

  group('basket bookkeeping', () {
    test('positiveLines excludes zeroed lines but keeps them visible', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'A',
        itemName: 'A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 1,
      ));
      notifier().addOrRaise(const BatchLine(
        itemCode: 'B',
        itemName: 'B',
        bomName: 'BOM-B',
        bomQtyYield: 10,
        batches: 1,
      ));
      notifier().setBatches(1, 0);

      expect(basket().lines, hasLength(2));
      expect(basket().positiveLines, hasLength(1));
      expect(basket().totalUnits, 10);
    });

    test('toApiLines emits the backend payload shape', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 2.5,
      ));

      final lines = basket().toApiLines(scheduledAt: '2026-08-01 09:00:00');

      expect(lines, hasLength(1));
      expect(lines.first['item_code'], 'CAKE-A');
      expect(lines.first['bom_name'], 'BOM-A');
      expect(lines.first['item_qty'], 25);
      expect(lines.first['scheduled_at'], '2026-08-01 09:00:00');
    });

    test('toApiLines omits scheduled_at when not given', () {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'CAKE-A',
        itemName: 'Cake A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 1,
      ));
      expect(basket().toApiLines().first.containsKey('scheduled_at'), isFalse);
    });

    test('remove drops the right line', () {
      for (final code in ['A', 'B', 'C']) {
        notifier().addOrRaise(BatchLine(
          itemCode: code,
          itemName: code,
          bomName: 'BOM-$code',
          bomQtyYield: 10,
          batches: 1,
        ));
      }
      notifier().remove(1);
      expect(basket().lines.map((l) => l.itemCode), ['A', 'C']);
    });

    test('clear empties the basket and the stored copy', () async {
      notifier().addOrRaise(const BatchLine(
        itemCode: 'A',
        itemName: 'A',
        bomName: 'BOM-A',
        bomQtyYield: 10,
        batches: 1,
      ));
      notifier().clear();
      await Future<void>.delayed(Duration.zero);

      expect(basket().isEmpty, isTrue);
      expect(repo.stored, isNull);
    });
  });

  group('restore', () {
    test('hydrates a basket saved by a previous session', () async {
      repo.stored = const ProductionBasket(lines: [
        BatchLine(
          itemCode: 'CAKE-A',
          itemName: 'Cake A',
          bomName: 'BOM-A',
          bomQtyYield: 10,
          batches: 4,
        ),
      ]);

      await notifier().restore();

      expect(basket().lines, hasLength(1));
      expect(basket().lines.first.batches, 4);
    });

    test('never clobbers work the user has already started', () async {
      // A restore arriving late must not overwrite a live basket.
      repo.stored = const ProductionBasket(lines: [
        BatchLine(
          itemCode: 'OLD',
          itemName: 'Old',
          bomName: 'BOM-OLD',
          bomQtyYield: 10,
          batches: 9,
        ),
      ]);
      notifier().addOrRaise(const BatchLine(
        itemCode: 'NEW',
        itemName: 'New',
        bomName: 'BOM-NEW',
        bomQtyYield: 10,
        batches: 1,
      ));

      await notifier().restore();

      expect(basket().lines.map((l) => l.itemCode), ['NEW']);
    });

    test('an empty stored basket is a no-op', () async {
      repo.stored = const ProductionBasket();
      await notifier().restore();
      expect(basket().isEmpty, isTrue);
    });
  });
}
