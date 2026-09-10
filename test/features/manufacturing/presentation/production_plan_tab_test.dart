import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/stock_alternative.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_plan_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

class _FakeBasketRepository implements ProductionBasketRepository {
  @override
  Future<ProductionBasket?> load() async => null;
  @override
  Future<void> save(ProductionBasket basket) async {}
  @override
  Future<void> clear() async {}
}

ProductionSuggestion _item({
  required String itemCode,
  String status = ProductionStatus.critical,
  double onHand = 20,
  double? daysOfCover = 2.2,
  int suggestedBatches = 5,
  int? canMakeNowBatches,
  bool stockIsNegative = false,
  LimitingComponent? limiting,
}) {
  return ProductionSuggestion(
    itemCode: itemCode,
    itemName: '$itemCode name',
    stockUom: 'Nos',
    defaultBom: 'BOM-$itemCode',
    bomQty: 10,
    onHand: onHand,
    velocity60d: 5,
    effectiveVelocity: 9,
    targetDays: 10,
    daysOfCover: daysOfCover,
    status: status,
    stockIsNegative: stockIsNegative,
    suggestedBatches: suggestedBatches,
    suggestedUnits: suggestedBatches * 10,
    canMakeNowBatches: canMakeNowBatches,
    limitingComponent: limiting,
  );
}

Future<void> _pump(WidgetTester tester, ProductionSuggestionsPage page) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productionBasketRepositoryProvider
            .overrideWithValue(_FakeBasketRepository()),
        productionSuggestionsProvider.overrideWith(
          () => _StubSuggestionsNotifier(page),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ProductionPlanTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The scope's own container, read the way every test in this file reads it.
ProviderContainer _container(WidgetTester tester) => ProviderScope.containerOf(
      tester.element(find.byType(ProductionPlanTab)),
    );

/// Closes the confirmation SnackBar without moving the clock.
///
/// Its auto-dismiss is a `Timer` rather than a frame, so `pumpAndSettle()`
/// returns with the timer still pending and the binding fails the test on
/// teardown. Waiting it out is the wrong cure — advancing the fake clock four
/// seconds also runs the BOM prefetch these tests do not stub. Clearing the
/// messenger cancels the timer and settles the exit in the same frame.
Future<void> _drainSnackBar(WidgetTester tester) async {
  await tester.pumpAndSettle();
  ScaffoldMessenger.of(
    tester.element(find.byType(ProductionPlanTab)),
  ).clearSnackBars();
  await tester.pumpAndSettle();
}

class _StubSuggestionsNotifier extends ProductionSuggestionsNotifier {
  _StubSuggestionsNotifier(this._page);
  final ProductionSuggestionsPage _page;

  @override
  Future<ProductionSuggestionsPage> build() async => _page;
}

void main() {
  testWidgets('renders a suggestion with its computed quantity', (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [_item(itemCode: 'CAKE-A', suggestedBatches: 5)],
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(find.text('CAKE-A name'), findsOneWidget);
    expect(find.text('CAKE-A'), findsOneWidget);
    // "Make 5 batches · 50 Nos" — the arithmetic is already done.
    expect(find.textContaining('5'), findsWidgets);
    // Two matches: the status chip on the row and the "Critical" filter chip.
    expect(find.text('Critical'), findsNWidgets(2));
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('flags negative stock so somebody counts the item',
      (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-NEG',
            onHand: -36,
            daysOfCover: 0,
            stockIsNegative: true,
            suggestedBatches: 15,
          ),
        ],
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(find.text('Stock is negative — count this item'), findsOneWidget);
    // cover clamps at zero rather than rendering a negative day count
    expect(find.text('0 d'), findsOneWidget);
  });

  testWidgets('a materials-capped row offers the achievable number and names '
      'the component', (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-CAP',
            suggestedBatches: 12,
            canMakeNowBatches: 3,
            limiting: const LimitingComponent(
              itemCode: 'RM-LABEL',
              itemName: 'Molten Jar Label',
              reason: 'insufficient_stock',
            ),
          ),
        ],
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(find.textContaining('Molten Jar Label'), findsOneWidget);
    expect(find.textContaining('capped at 3'), findsOneWidget);
    // still actionable, at the achievable quantity
    final addButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(addButton.onPressed, isNotNull);
  });

  testWidgets('a row with no original material can be queued as a draft',
      (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-BLOCKED',
            suggestedBatches: 12,
            canMakeNowBatches: 0,
            limiting: const LimitingComponent(
              itemCode: 'RM-GONE',
              itemName: 'Missing material',
              reason: 'insufficient_stock',
            ),
          ),
        ],
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(
      find.text('Cannot start — Missing material is short'),
      findsOneWidget,
    );
    final addButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(addButton.onPressed, isNotNull);

    await tester.tap(find.text('Add'));
    await _drainSnackBar(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductionPlanTab)),
    );
    final line = container.read(productionBasketProvider).lines.single;
    expect(line.itemCode, 'CAKE-BLOCKED');
    expect(line.bomName, 'BOM-CAKE-BLOCKED');
    expect(line.batches, 12);
  });

  testWidgets('a blocked row whose material is in another store can be queued',
      (tester) async {
    // Naming the store is a hint, not an override: the material is not in the
    // warehouse this recipe draws on. The row can still become a draft so the
    // operator can choose a stocked alternative on the Batch tab.
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-BLOCKED',
            suggestedBatches: 12,
            canMakeNowBatches: 0,
            limiting: const LimitingComponent(
              itemCode: 'RM-LABEL',
              itemName: 'Jar label',
              uom: 'Nos',
              sourceWarehouse: 'Raw Material - J',
              requiredQty: 8,
              reason: 'insufficient_stock',
              availableElsewhere: 40.5,
              alternatives: [
                StockAlternative(warehouse: 'Stores - J', availableQty: 40.5),
              ],
            ),
          ),
        ],
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(
      find.text(
        '40.5 Nos is in Stores - J '
        '— needs a stock transfer, not a purchase',
      ),
      findsOneWidget,
    );

    final addButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(addButton.onPressed, isNotNull);
  });

  testWidgets('warns when velocity has never been calculated', (tester) async {
    // A board full of zeroes almost always means the weekly job never ran, not
    // that nothing sells.
    await _pump(
      tester,
      const ProductionSuggestionsPage(
        items: [],
        summary: ProductionSummary(),
      ),
    );

    expect(
      find.textContaining('Sales velocity has never been calculated'),
      findsOneWidget,
    );
    expect(find.text('Nothing needs producing'), findsOneWidget);
  });

  testWidgets('Fill the day is hidden when nothing needs producing',
      (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-OK',
            status: ProductionStatus.ok,
            daysOfCover: 30,
            suggestedBatches: 0,
          ),
        ],
        summary: const ProductionSummary(ok: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(find.text('Fill the day'), findsNothing);
  });

  testWidgets('Fill the day appears when items are below cover',
      (tester) async {
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [_item(itemCode: 'CAKE-A')],
        summary: const ProductionSummary(critical: 1, low: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(find.text('Fill the day'), findsOneWidget);
    expect(find.text('2 items below cover'), findsOneWidget);
  });

  testWidgets('Fill the day queues the actionable items', (tester) async {
    late WidgetRef capturedRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productionBasketRepositoryProvider
              .overrideWithValue(_FakeBasketRepository()),
          productionSuggestionsProvider.overrideWith(
            () => _StubSuggestionsNotifier(
              ProductionSuggestionsPage(
                items: [
                  _item(itemCode: 'CAKE-A', suggestedBatches: 4),
                  _item(
                    itemCode: 'CAKE-B',
                    status: ProductionStatus.low,
                    suggestedBatches: 6,
                    canMakeNowBatches: 2,
                  ),
                  _item(
                    itemCode: 'CAKE-OK',
                    status: ProductionStatus.ok,
                    suggestedBatches: 0,
                  ),
                ],
                summary: const ProductionSummary(critical: 1, low: 1),
                velocityUpdatedOn: '2026-08-01 00:00:00',
              ),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const ProductionPlanTab();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fill the day'));
    await _drainSnackBar(tester);

    final basket = capturedRef.read(productionBasketProvider);
    expect(basket.lines.map((l) => l.itemCode), ['CAKE-A', 'CAKE-B']);
    // CAKE-B is capped by materials at 2 rather than the suggested 6
    expect(basket.lines[1].batches, 2);
  });

  testWidgets('Add points at the tab the line just moved to', (tester) async {
    // Before this, adding answered with a badge on a tab one along and
    // nothing else — the line left the screen the operator was looking at and
    // the only way to it was knowing which tab to press.
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [_item(itemCode: 'CAKE-A')],
        season: const ProductionSeason(name: null, multiplier: 1),
        defaultTargetDays: 10,
        thresholds: const ProductionThresholds(
          criticalDays: 5,
          watchDays: 14,
          overstockDays: 90,
        ),
        summary: const ProductionSummary(critical: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final container = _container(tester);
    expect(find.text('CAKE-A name added to the batch'), findsOneWidget);
    expect(container.read(productionTabRequestProvider), isNull);

    await tester.tap(find.text('View batch'));
    await _drainSnackBar(tester);

    expect(
      container.read(productionTabRequestProvider),
      kProductionBatchTabIndex,
    );
  });

  testWidgets('Fill the day offers no route to an empty batch', (tester) async {
    // "Nothing to add" plus a button to go and look at nothing.
    await _pump(
      tester,
      ProductionSuggestionsPage(
        items: [
          _item(
            itemCode: 'CAKE-OK',
            status: ProductionStatus.ok,
            daysOfCover: 40,
            suggestedBatches: 0,
          ),
        ],
        season: const ProductionSeason(name: null, multiplier: 1),
        defaultTargetDays: 10,
        thresholds: const ProductionThresholds(
          criticalDays: 5,
          watchDays: 14,
          overstockDays: 90,
        ),
        summary: const ProductionSummary(ok: 1),
        velocityUpdatedOn: '2026-08-01 00:00:00',
      ),
    );

    expect(_container(tester).read(productionBasketProvider).isEmpty, isTrue);
    expect(find.text('View batch'), findsNothing);
  });
}
