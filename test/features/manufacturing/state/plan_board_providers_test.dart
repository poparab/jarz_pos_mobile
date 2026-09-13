import 'dart:async';

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

class _FailingSuggestions extends ProductionSuggestionsNotifier {
  @override
  Future<ProductionSuggestionsPage> build() async =>
      throw Exception('suggestions are down');
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
      page: ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
      template: DailyPlanTemplate(
        items: [_templateItem('CAKE-A'), _templateItem('CAKE-NOBOM')],
      ),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    expect(board.hasJarList, isTrue);
    expect(board.groups.map((g) => g.name), ['Jars']);
    expect(board.rows.map((r) => r.itemCode), ['CAKE-A', 'CAKE-NOBOM']);

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

  test('a ranked base the template does not list is not a jar row', () async {
    // The ranked board also ranks the bases, because they own a BOM too. On
    // this tab they got a whole-jar field, and the 1.36 Kg a strawberry mix
    // needed was typed as "1.360" and queued as 1360 Kg. Bases belong to the
    // Bases tab, in their own unit.
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A'),
          _suggestion(
            itemCode: 'strawberry mix',
            itemGroup: 'Sub Assemblies',
            bomQty: 2,
          ),
        ],
      ),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    expect(board.rows.map((r) => r.itemCode), ['CAKE-A']);
  });

  test(
    'a queued line for an unlisted item is dropped from both stores',
    () async {
      // A tablet can carry a persisted line from before bases left this tab.
      // Unpruned it is invisible, still counted in the badge, and still posted
      // by Start batches.
      final container = _container(
        page: ProductionSuggestionsPage(
          items: [_suggestion(itemCode: 'CAKE-A')],
        ),
        template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
      );
      await _settle(container);

      final row = container.read(planBoardProvider).rows.first;
      final entry = container.read(planEntryProvider);
      entry.setQuantity(row, 12);
      container
          .read(productionBasketProvider.notifier)
          .addOrRaise(
            const BatchLine(
              itemCode: 'strawberry mix',
              itemName: 'strawberry mix',
              bomName: 'BOM-strawberry mix-004',
              stockUom: 'Kg',
              bomQtyYield: 2,
              batches: 680,
            ),
          );
      container
          .read(dailyPlanDraftProvider.notifier)
          .setQuantity('strawberry mix', 1360);

      expect(entry.dropUnlisted(container.read(planBoardProvider)), isTrue);
      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 12});
      expect(
        container.read(productionBasketProvider).lines.map((l) => l.itemCode),
        ['CAKE-A'],
      );
      // Idempotent: nothing left to drop.
      expect(entry.dropUnlisted(container.read(planBoardProvider)), isFalse);
    },
  );

  test(
    'nothing is pruned against a board still waiting for its jar list',
    () async {
      final container = ProviderContainer(
        overrides: [
          productionBasketRepositoryProvider.overrideWithValue(
            _FakeBasketRepository(),
          ),
          productionSuggestionsProvider.overrideWith(
            () => _StubSuggestions(const ProductionSuggestionsPage()),
          ),
          dailyPlanTemplateProvider.overrideWith(
            (ref) => Completer<DailyPlanTemplate>().future,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(dailyPlanDraftProvider.notifier).setQuantity('CAKE-A', 5);
      final board = container.read(planBoardProvider);
      expect(board.hasJarList, isFalse);
      expect(container.read(planEntryProvider).dropUnlisted(board), isFalse);
      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 5});
    },
  );

  test('the ranked board failing still leaves a usable plan form', () async {
    final container = ProviderContainer(
      overrides: [
        productionBasketRepositoryProvider.overrideWithValue(
          _FakeBasketRepository(),
        ),
        productionSuggestionsProvider.overrideWith(_FailingSuggestions.new),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(productionSuggestionsProvider.future),
      throwsA(isA<Exception>()),
    );
    await container.read(dailyPlanTemplateProvider.future);

    final board = container.read(planBoardProvider);
    expect(board.error, isNull);
    expect(board.rows.map((r) => r.itemCode), ['CAKE-A']);
    expect(board.rows.single.suggestion, isNull);
  });

  test('without the jar list the board says so instead of guessing', () async {
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

    // The ranked board alone cannot tell a jar from a base, and guessing is
    // what put 1360 Kg of strawberry mix in a jar field.
    final board = container.read(planBoardProvider);
    expect(board.error, isNotNull);
    expect(board.rows, isEmpty);
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

  test(
    'fill the day caps at what materials allow and reports the rest',
    () async {
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
        template: DailyPlanTemplate(
          items: [
            for (final code in ['CAKE-A', 'CAKE-B', 'CAKE-BLOCKED', 'CAKE-OK'])
              _templateItem(code),
          ],
        ),
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
    },
  );

  test('fill the day never lowers a number the operator typed', () async {
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [_suggestion(itemCode: 'CAKE-A', suggestedBatches: 4)],
      ),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);

    final board = container.read(planBoardProvider);
    final entry = container.read(planEntryProvider);
    entry.setQuantity(board.rows.first, 90);
    entry.fillTheDay(board.rows);

    expect(container.read(dailyPlanDraftProvider).quantities['CAKE-A'], 90);
  });

  group('reconcile', () {
    const cakeALine = BatchLine(
      itemCode: 'CAKE-A',
      itemName: 'CAKE-A name',
      bomName: 'BOM-CAKE-A',
      stockUom: 'Nos',
      bomQtyYield: 10,
      batches: 3,
    );

    Map<String, double> queued(ProviderContainer container) => {
      for (final l in container.read(productionBasketProvider).positiveLines)
        l.itemCode: l.units,
    };

    ProviderContainer twoJars() => _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A'),
          _suggestion(itemCode: 'CAKE-B'),
        ],
      ),
      template: DailyPlanTemplate(
        items: [_templateItem('CAKE-A'), _templateItem('CAKE-B')],
      ),
    );

    void reconcile(ProviderContainer container) => container
        .read(planEntryProvider)
        .reconcile(container.read(planBoardProvider));

    test('a restored queue fills the fields it came from', () async {
      final container = twoJars();
      await _settle(container);

      container.read(productionBasketProvider.notifier).addOrRaise(cakeALine);

      final entry = container.read(planEntryProvider);
      final board = container.read(planBoardProvider);
      expect(entry.isReconciled(board), isFalse);
      expect(entry.reconcile(board), isTrue);

      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 30});
      expect(queued(container), {'CAKE-A': 30.0});
      expect(entry.isReconciled(board), isTrue);
      expect(entry.reconcile(board), isFalse);
    });

    test(
      'jars typed on Today and a restored queue end up in both stores',
      () async {
        // The draft is shared with the Today screen, which never touches the
        // queue. The old hydrate skipped whenever the draft held anything, so
        // yesterday's queued CAKE-A was posted by Start batches with no field
        // showing it, and Today's CAKE-B showed with nothing queued.
        final container = twoJars();
        await _settle(container);

        container
            .read(dailyPlanDraftProvider.notifier)
            .setQuantity('CAKE-B', 12);
        container.read(productionBasketProvider.notifier).addOrRaise(cakeALine);

        reconcile(container);

        expect(container.read(dailyPlanDraftProvider).quantities, {
          'CAKE-A': 30,
          'CAKE-B': 12,
        });
        expect(queued(container), {'CAKE-A': 30.0, 'CAKE-B': 12.0});
      },
    );

    test('the draft wins for a jar it has already decided', () async {
      final container = twoJars();
      await _settle(container);

      container.read(dailyPlanDraftProvider.notifier).setQuantity('CAKE-A', 7);
      container.read(productionBasketProvider.notifier).addOrRaise(cakeALine);
      reconcile(container);

      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 7});
      expect(queued(container), {'CAKE-A': 7.0});
    });

    test('a jar Today already made is not started again from here', () async {
      // Today's Make zeroes the draft and leaves the queue alone. An empty
      // field there is a decision, not a gap to refill from the queue.
      final container = twoJars();
      await _settle(container);

      final row = container.read(planBoardProvider).rows.first;
      container.read(planEntryProvider).setQuantity(row, 30);
      container.read(dailyPlanDraftProvider.notifier).setQuantity('CAKE-A', 0);
      reconcile(container);

      expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
      expect(queued(container), isEmpty);
    });

    test('a cleared day drops a queue that lands after it', () async {
      final container = twoJars();
      await _settle(container);

      container.read(dailyPlanDraftProvider.notifier).clear();
      container.read(productionBasketProvider.notifier).addOrRaise(cakeALine);
      reconcile(container);

      expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
      expect(queued(container), isEmpty);
    });

    test('a part-jar queued line is rounded in both stores', () async {
      final container = twoJars();
      await _settle(container);

      container
          .read(productionBasketProvider.notifier)
          .addOrRaise(cakeALine.withBatches(0.25));
      reconcile(container);

      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 3});
      expect(queued(container), {'CAKE-A': 3.0});
      expect(
        container
            .read(planEntryProvider)
            .isReconciled(container.read(planBoardProvider)),
        isTrue,
      );
    });

    test(
      'an unqueueable row keeps its plan quantity and queues nothing',
      () async {
        final container = _container(
          page: const ProductionSuggestionsPage(),
          template: DailyPlanTemplate(items: [_templateItem('CAKE-NOBOM')]),
        );
        await _settle(container);

        container
            .read(dailyPlanDraftProvider.notifier)
            .setQuantity('CAKE-NOBOM', 4);
        final entry = container.read(planEntryProvider);
        final board = container.read(planBoardProvider);

        expect(entry.isReconciled(board), isTrue);
        expect(entry.reconcile(board), isFalse);
        expect(container.read(dailyPlanDraftProvider).quantities, {
          'CAKE-NOBOM': 4,
        });
      },
    );

    test('a saved plan is never poured into the fields', () async {
      // The rule the Today screen already keeps: a filed plan is a TARGET.
      // Seeding the fields from it would rebuild the queue behind it, so a run
      // started this morning could be started again by re-opening the tab.
      final container = twoJars();
      await _settle(container);

      container
          .read(dailyPlanDraftProvider.notifier)
          .attachSavedPlan('DPP-0001');
      reconcile(container);

      expect(container.read(dailyPlanDraftProvider).quantities, isEmpty);
      expect(container.read(productionBasketProvider).lines, isEmpty);
      // The document is still attached, so Save updates it rather than filing
      // a second plan for the same day.
      expect(container.read(dailyPlanDraftProvider).savedPlanName, 'DPP-0001');
    });

    test('nothing moves before the jar list is in', () async {
      final container = ProviderContainer(
        overrides: [
          productionBasketRepositoryProvider.overrideWithValue(
            _FakeBasketRepository(),
          ),
          productionSuggestionsProvider.overrideWith(
            () => _StubSuggestions(const ProductionSuggestionsPage()),
          ),
          dailyPlanTemplateProvider.overrideWith(
            (ref) => Completer<DailyPlanTemplate>().future,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(dailyPlanDraftProvider.notifier).setQuantity('CAKE-A', 5);
      final board = container.read(planBoardProvider);
      final entry = container.read(planEntryProvider);
      expect(entry.isReconciled(board), isTrue);
      expect(entry.reconcile(board), isFalse);
      expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 5});
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
    expect(container.read(settledBasketProvider).valueOrNull?.totalUnits, 50);
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

  test('a red entry outlives the screen, and leaves with the day', () async {
    // Root-scoped: switching to the Bases tab disposes the Plan tab, and an
    // entry held there came back as a plain "1" with Start enabled.
    final container = _container(
      page: ProductionSuggestionsPage(
        items: [
          _suggestion(itemCode: 'CAKE-A'),
          _suggestion(itemCode: 'CAKE-B'),
        ],
      ),
      template: DailyPlanTemplate(
        items: [_templateItem('CAKE-A'), _templateItem('CAKE-B')],
      ),
    );
    await _settle(container);

    final entry = container.read(planEntryProvider);
    entry.setInvalidEntry('CAKE-A', '1.360');
    entry.setInvalidEntry('CAKE-B', '2.5');
    expect(container.read(planInvalidEntriesProvider), {
      'CAKE-A': '1.360',
      'CAKE-B': '2.5',
    });

    entry.forgetStarted(['CAKE-B']);
    expect(container.read(planInvalidEntriesProvider), {'CAKE-A': '1.360'});

    entry.setInvalidEntry('CAKE-A', null);
    expect(container.read(planInvalidEntriesProvider), isEmpty);

    entry.setInvalidEntry('CAKE-A', '1.');
    entry.clear();
    expect(container.read(planInvalidEntriesProvider), isEmpty);
  });

  test('a number written from outside replaces a red entry', () async {
    // "Fill the day", "Use 60" and "Use planned" write the quantity while the
    // row may be scrolled away, so the row's own didUpdateWidget never runs.
    // The red "1.36" would then stay on the field over a 60 the draft and the
    // queue both hold — and the Today screen would book.
    final container = _container(
      page: ProductionSuggestionsPage(items: [_suggestion(itemCode: 'CAKE-A')]),
      template: DailyPlanTemplate(items: [_templateItem('CAKE-A')]),
    );
    await _settle(container);

    final row = container.read(planBoardProvider).rows.first;
    final entry = container.read(planEntryProvider);

    // The row's own invalid path: the red text, then a 0. The 0 must not
    // clear the text it was reported for.
    entry.setInvalidEntry('CAKE-A', '1.36');
    entry.setQuantity(row, 0);
    expect(container.read(planInvalidEntriesProvider), {'CAKE-A': '1.36'});

    entry.setQuantity(row, 60);
    expect(container.read(planInvalidEntriesProvider), isEmpty);
    expect(container.read(dailyPlanDraftProvider).quantities, {'CAKE-A': 60});

    entry.setInvalidEntry('CAKE-A', '5.');
    expect(entry.fillSuggestion(row), 50);
    expect(container.read(planInvalidEntriesProvider), isEmpty);
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
      template: DailyPlanTemplate(
        items: [_templateItem('CAKE-A'), _templateItem('CAKE-B')],
      ),
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
