import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/daily_plan.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/plan_board_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';

/// The join and the single write path behind the merged Plan tab.
///
/// Worth its own test: the whole point of merging three tabs was that one
/// quantity now has to be three things at once — the day's target, the mixer's
/// input and the Work Order quantity — and the way that goes wrong is silently,
/// with two stores holding different numbers.
class _FakeBasketRepository implements ProductionBasketRepository {
  ProductionBasket? saved;

  @override
  Future<ProductionBasket?> load() async => saved;
  @override
  Future<void> save(ProductionBasket basket) async => saved = basket;
  @override
  Future<void> clear() async => saved = null;
}

class _StubSuggestions extends ProductionSuggestionsNotifier {
  _StubSuggestions(this._page);
  final ProductionSuggestionsPage _page;
  @override
  Future<ProductionSuggestionsPage> build() async => _page;
}

ProductionSuggestion _suggestion({
  required String itemCode,
  String status = ProductionStatus.critical,
  String itemGroup = 'Jars',
  double bomQty = 10,
  int suggestedBatches = 5,
  int? canMakeNowBatches,
}) {
  return ProductionSuggestion(
    itemCode: itemCode,
    itemName: '$itemCode name',
    itemGroup: itemGroup,
    stockUom: 'Nos',
    defaultBom: 'BOM-$itemCode',
    bomQty: bomQty,
    status: status,
    targetDays: 10,
    suggestedBatches: suggestedBatches,
    suggestedUnits: suggestedBatches * bomQty,
    canMakeNowBatches: canMakeNowBatches,
  );
}

DailyPlanItem _templateItem(String code, {String group = 'Jars', String? bom}) {
  return DailyPlanItem(
    itemCode: code,
    itemName: '$code name',
    itemGroup: group,
    defaultBom: bom,
    jarsPerBatch: 120,
    usesMix: true,
  );
}

ProviderContainer _container({
  required ProductionSuggestionsPage page,
  required DailyPlanTemplate template,
  _FakeBasketRepository? repo,
}) {
  final container = ProviderContainer(
    overrides: [
      productionBasketRepositoryProvider.overrideWithValue(
        repo ?? _FakeBasketRepository(),
      ),
      productionSuggestionsProvider.overrideWith(() => _StubSuggestions(page)),
      dailyPlanTemplateProvider.overrideWith((ref) async => template),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle(ProviderContainer container) async {
  await container.read(productionSuggestionsProvider.future);
  await container.read(dailyPlanTemplateProvider.future);
}

void main() {
  test('the board joins the flavour list to the ranked figures', () async {
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A'),
          // Ranked but not on the plan template — it must still be visible on a
          // board whose job is to say what is running low.
          _suggestion(itemCode: 'CAKE-EXTRA', itemGroup: 'Trays'),
        ],
      ),
      template: DailyPlanTemplate(
        items: [_templateItem('CAKE-A'), _templateItem('CAKE-NOBOM')],
      ),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    expect(board.groups.map((g) => g.name), ['Jars', 'Trays']);
    expect(board.rows.map((r) => r.itemCode), [
      'CAKE-A',
      'CAKE-NOBOM',
      'CAKE-EXTRA',
    ]);

    final joined = board.rows.first;
    expect(joined.suggestion, isNotNull);
    expect(joined.jarsPerBatch, 120);
    expect(joined.bomQty, 10);
    expect(joined.canQueue, isTrue);
    expect(joined.suggestedJars, 50);

    // A flavour with no BOM is still part of the target and still has no run.
    final noBom = board.rows.elementAt(1);
    expect(noBom.suggestion, isNull);
    expect(noBom.canQueue, isFalse);
    expect(noBom.suggestedJars, 0);
  });

  test('one source failing still leaves a usable board', () async {
    final container = ProviderContainer(
      overrides: [
        productionBasketRepositoryProvider.overrideWithValue(
          _FakeBasketRepository(),
        ),
        productionSuggestionsProvider.overrideWith(
          () => _StubSuggestions(
            ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
          ),
        ),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => throw Exception('template is down'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(productionSuggestionsProvider.future);
    await expectLater(
      container.read(dailyPlanTemplateProvider.future),
      throwsA(isA<Exception>()),
    );

    final board = container.read(planBoardProvider);
    expect(board.error, isNull);
    expect(board.rows.map((r) => r.itemCode), ['CAKE-A']);
  });

  test('a quantity written once lands in both stores', () async {
    final container = _container(
      page: ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);

    final row = container.read(planBoardProvider).rows.first;
    container.read(planEntryProvider).setQuantity(row, 24);

    expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 24});
    final line = container.read(productionBasketProvider).lines.single;
    expect(line.units, 24);
    expect(line.batches, closeTo(2.4, 1e-9));

    // Corrected DOWNWARDS, which `addOrRaise` could not do: it takes the larger
    // of the two, so 24 typed over 50 would have stayed 50.
    container.read(planEntryProvider).setQuantity(row, 12);
    expect(container.read(productionBasketProvider).lines.single.units, 12);

    container.read(planEntryProvider).setQuantity(row, 0);
    expect(container.read(productionBasketProvider).lines, isEmpty);
    expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
  });

  test('fill the day caps at what materials allow and reports the rest', () async {
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A', suggestedBatches: 4),
          _suggestion(
            itemCode: 'CAKE-B',
            status: ProductionStatus.low,
            suggestedBatches: 6,
            canMakeNowBatches: 2,
          ),
          _suggestion(
            itemCode: 'CAKE-BLOCKED',
            suggestedBatches: 6,
            canMakeNowBatches: 0,
          ),
          _suggestion(
            itemCode: 'CAKE-OK',
            status: ProductionStatus.ok,
            suggestedBatches: 0,
          ),
        ],
      ),
      template: const DailyPlanTemplate(),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    final result = container.read(planEntryProvider).fillTheDay(board.rows);

    expect(result.itemsFilled, 2);
    expect(result.jarsFilled, 60);
    expect(result.skippedNoMaterials, 1);
    expect(container.read(dailyPlanDraftProvider).quantities, {
      'CAKE-A': 40,
      'CAKE-B': 20,
    });
  });

  test('fill the day never lowers a number the operator typed', () async {
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [_suggestion(itemCode: 'CAKE-A', suggestedBatches: 4)],
      ),
      template: const DailyPlanTemplate(),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    final entry = container.read(planEntryProvider);
    entry.setQuantity(board.rows.first, 90);
    entry.fillTheDay(board.rows);

    expect(container.read(dailyPlanDraftProvider).quantities['CAKE-A'], 90);
  });

  group('hydrate', () {
    test('a restored queue fills the fields it came from', () async {
      final container = _container(
        page: ProductionSuggestionsPage(
          items: [_suggestion(itemCode: 'CAKE-A')],
        ),
        template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
      );
      await _settle(container);

      container.read(productionBasketProvider.notifier).addOrRaise(
        const BatchLine(
          itemCode: 'CAKE-A',
          itemName: 'CAKE-A name',
          bomName: 'BOM-CAKE-A',
          stockUom: 'Nos',
          bomQtyYield: 10,
          batches: 3,
        ),
      );

      container.read(planEntryProvider).hydrate();
      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 30});
    });

    test('a saved plan is never poured into the fields', () async {
      // The rule the Today screen already keeps: a filed plan is a TARGET.
      // Seeding the fields from it would rebuild the queue behind it, so a run
      // started this morning could be started again by re-opening the tab.
      final container = _container(
        page: ProductionSuggestionsPage(
          items: [_suggestion(itemCode: 'CAKE-A')],
        ),
        template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
      );
      await _settle(container);

      container.read(dailyPlanDraftProvider.notifier).attachSavedPlan(
        'DPP-0001',
      );
      container.read(planEntryProvider).hydrate();

      expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
      expect(container.read(productionBasketProvider).lines, isEmpty);
      // The document is still attached, so Save updates it rather than filing
      // a second plan for the same day.
      expect(container.read(dailyPlanDraftProvider).savedPlanName, 'DPP-0001');
    });

    test('never overwrites what is already typed', () async {
      final container = _container(
        page: ProductionSuggestionsPage(
          items: [_suggestion(itemCode: 'CAKE-A')],
        ),
        template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
      );
      await _settle(container);

      final row = container.read(planBoardProvider).rows.first;
      container.read(planEntryProvider).setQuantity(row, 7);
      // A queue arriving late from Hive must not clobber an entry already
      // under way.
      container.read(productionBasketProvider.notifier).addOrRaise(
        const BatchLine(
          itemCode: 'CAKE-B',
          itemName: 'CAKE-B name',
          bomName: 'BOM-CAKE-B',
          stockUom: 'Nos',
          bomQtyYield: 10,
          batches: 9,
        ),
      );
      container.read(planEntryProvider).hydrate();

      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 7});
    });
  });

  test('the heavy checks only see the queue once it settles', () async {
    // A typed "50" is three states. The roll-up costs a BOM explosion per line
    // server-side, so it must not be asked three times, twice about a basket
    // that existed for eighty milliseconds.
    final container = _container(
      page: ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);
    // autoDispose: without a listener it would be torn down between reads.
    container.listen(settledBasketProvider, (_, _) {});

    final row = container.read(planBoardProvider).rows.first;
    final entry = container.read(planEntryProvider);
    entry.setQuantity(row, 5);
    entry.setQuantity(row, 50);

    // The buttons and the totals read the live queue, so what the operator
    // sees is never the stale copy.
    expect(container.read(productionBasketProvider).totalUnits, 50);
    expect(container.read(settledBasketProvider).isLoading, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(
      container.read(settledBasketProvider).valueOrNull?.totalUnits,
      50,
    );
  });

  test('an emptied queue clears the heavy checks at once', () async {
    // The other direction needs no wait: leaving yesterday's shortage on
    // screen for another half second after the last row is cleared reads as a
    // board that has not noticed.
    final container = _container(
      page: ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);
    container.listen(settledBasketProvider, (_, _) {});

    // A timeout well inside the debounce window: waiting it out would prove
    // nothing, answering before it is the whole claim.
    final settled = await container
        .read(settledBasketProvider.future)
        .timeout(const Duration(milliseconds: 50));
    expect(settled.isEmpty, isTrue);
  });

  test('a started line leaves both stores', () async {
    // The jars are on the floor now. A number left in the field invites the
    // same run to be started twice; what was planned survives on the saved
    // plan document.
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A'),
          _suggestion(itemCode: 'CAKE-B'),
        ],
      ),
      template: const DailyPlanTemplate(),
    );
    await _settle(container);

    final rows = container.read(planBoardProvider).rows.toList();
    final entry = container.read(planEntryProvider);
    entry.setQuantity(rows[0], 20);
    entry.setQuantity(rows[1], 30);

    entry.forgetStarted(['CAKE-A']);

    expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-B': 30});
    expect(
      container.read(productionBasketProvider).lines.map((l) => l.itemCode),
      ['CAKE-B'],
    );
  });
}
