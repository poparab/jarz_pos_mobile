import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/daily_plan.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_policy.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_today_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/sop_execute_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/plan_jar_row.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/view_sop_button.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/plan_board_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';

import '../../../helpers/mock_services.dart';

/// The jar rows on the Today screen and on the Plan tab offer the recipe only
/// for an item the server says has an SOP, and open it scaled to the jars
/// typed on that row.

const _tiramisu = DailyPlanItem(
  itemCode: 'Tiramisu Large',
  itemName: 'Tiramisu Large',
  itemGroup: 'Jars',
  defaultBom: 'BOM-Tiramisu Large-001',
);

const _lotus = DailyPlanItem(
  itemCode: 'JAR-LOTUS',
  itemName: 'Lotus Jar',
  itemGroup: 'Jars',
  defaultBom: 'BOM-JAR-LOTUS-001',
);

const _template = DailyPlanTemplate(
  planDate: '2026-10-08',
  mix: DailyPlanMix(itemCode: 'MIX-CHEESECAKE', batchQty: 30, uom: 'Kg'),
  items: [_tiramisu, _lotus],
);

class _StubBaseItems extends BaseItemsNotifier {
  @override
  Future<BaseItemsPage> build() async => const BaseItemsPage();
}

class _StubRunningBatches extends RunningBatchesNotifier {
  @override
  Future<List<RunningBatch>> build() async => const <RunningBatch>[];
}

class _FakeBasketRepository implements ProductionBasketRepository {
  ProductionBasket? stored;

  @override
  Future<ProductionBasket?> load() async => stored;
  @override
  Future<void> save(ProductionBasket basket) async => stored = basket;
  @override
  Future<void> clear() async => stored = null;
}

const _localizations = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// What the SOP route was pushed with, or null when it was never reached.
class _Pushed {
  SopLaunchArgs? args;
}

GoRouter _router(Widget home, _Pushed pushed) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => home),
    GoRoute(
      path: AppRoutes.productionSop,
      builder: (_, state) {
        pushed.args = SopLaunchArgs.fromExtra(state.extra);
        return const Scaffold(body: Text('sop screen'));
      },
    ),
  ],
);

/// [sopListError] makes `list_items_with_sop` fail the way an older backend
/// does — the real provider is exercised, not overridden.
Future<_Pushed> _pumpToday(
  WidgetTester tester, {
  List<String> sopItems = const ['Tiramisu Large'],
  bool sopListError = false,
}) async {
  final dio = MockDio();
  if (sopListError) {
    dio.setError(
      ApiEndpoints.listItemsWithSop,
      createMockDioException(
        statusCode: 404,
        path: ApiEndpoints.listItemsWithSop,
      ),
    );
  } else {
    dio.setResponse(ApiEndpoints.listItemsWithSop, {
      'message': {'item_codes': sopItems},
    });
  }
  dio.setResponse(ApiEndpoints.dailyPlanPreview, {
    'message': {
      'mix': {'item_code': 'MIX-CHEESECAKE', 'batch_qty': 30.0, 'uom': 'Kg'},
      'total_mix_qty': 0.0,
      'required_batches': 0.0,
      'planned_batches': 0.0,
      'run_detail': const <Map<String, dynamic>>[],
      'run_count': 0,
    },
  });

  final pushed = _Pushed();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        canExecuteProductionProvider.overrideWithValue(true),
        productionPolicyProvider.overrideWith(
          (ref) async => const ProductionPolicy(canExecute: true),
        ),
        baseItemsProvider.overrideWith(_StubBaseItems.new),
        dailyPlanTemplateProvider.overrideWith((ref) async => _template),
        runningBatchesProvider.overrideWith(_StubRunningBatches.new),
        manufacturingServiceProvider.overrideWithValue(
          ManufacturingService(dio),
        ),
        dailyPlanServiceProvider.overrideWithValue(DailyPlanService(dio)),
        productionBasketRepositoryProvider.overrideWithValue(
          _FakeBasketRepository(),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: _localizations,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router(const ProductionTodayScreen(), pushed),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return pushed;
}

/// The jar field on [itemCode]'s row. Rows are in template order and the bases
/// section is empty, so the fields are the jars in order.
Finder _jarField(int index) => find.byType(TextField).at(index);

Finder _recipeOn(String rowName) => find.descendant(
  of: find.ancestor(of: find.text(rowName), matching: find.byType(Row)).first,
  matching: find.byType(ViewSopButton),
);

const _tiramisuRow = PlanRow(
  itemCode: 'Tiramisu Large',
  itemName: 'Tiramisu Large',
  itemGroup: 'Jars',
  bomName: 'BOM-Tiramisu Large-001',
);

Future<_Pushed> _pumpPlanRow(
  WidgetTester tester, {
  PlanRow row = _tiramisuRow,
  int quantity = 0,
  bool hasRecipe = true,
}) async {
  final pushed = _Pushed();
  await tester.pumpWidget(
    MaterialApp.router(
      localizationsDelegates: _localizations,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router(
        Scaffold(
          body: PlanJarRow(
            row: row,
            quantity: quantity,
            hasRecipe: hasRecipe,
            onQuantityChanged: (_) {},
            onUseSuggestion: () {},
          ),
        ),
        pushed,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return pushed;
}

Future<void> _expandPlanRow(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.expand_more));
  await tester.pumpAndSettle();
}

void main() {
  group('sopItemCodesProvider', () {
    test('reads the item codes off the envelope', () async {
      final dio = MockDio()
        ..setResponse(ApiEndpoints.listItemsWithSop, {
          'message': {
            'item_codes': ['Tiramisu Large', 'Tiramisu Small', ''],
          },
        });
      final container = ProviderContainer(
        overrides: [
          manufacturingServiceProvider.overrideWithValue(
            ManufacturingService(dio),
          ),
        ],
      );
      addTearDown(container.dispose);

      final codes = await container.read(sopItemCodesProvider.future);
      expect(codes, {'Tiramisu Large', 'Tiramisu Small'});
    });

    test('an older backend without the endpoint is an empty set', () async {
      final dio = MockDio()
        ..setError(
          ApiEndpoints.listItemsWithSop,
          createMockDioException(
            statusCode: 417,
            path: ApiEndpoints.listItemsWithSop,
          ),
        );
      final container = ProviderContainer(
        overrides: [
          manufacturingServiceProvider.overrideWithValue(
            ManufacturingService(dio),
          ),
        ],
      );
      addTearDown(container.dispose);

      final codes = await container.read(sopItemCodesProvider.future);
      expect(codes, isEmpty);
    });
  });

  group('Today screen', () {
    testWidgets('offers the recipe only on a jar that has an SOP', (
      tester,
    ) async {
      await _pumpToday(tester);

      expect(find.byType(ViewSopButton), findsOneWidget);
      expect(_recipeOn('Tiramisu Large'), findsOneWidget);
      expect(_recipeOn('Lotus Jar'), findsNothing);
    });

    testWidgets('hides every recipe when the SOP list fails to load', (
      tester,
    ) async {
      await _pumpToday(tester, sopListError: true);

      expect(find.byType(ViewSopButton), findsNothing);
      // Not an error screen either: the rows are all still there.
      expect(find.text('Tiramisu Large'), findsOneWidget);
      expect(find.text('Lotus Jar'), findsOneWidget);
    });

    testWidgets('opens the recipe scaled to the jars typed on the row', (
      tester,
    ) async {
      final pushed = await _pumpToday(tester);

      await tester.enterText(_jarField(0), '12');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ViewSopButton));
      await tester.pumpAndSettle();

      expect(find.text('sop screen'), findsOneWidget);
      final args = pushed.args!;
      expect(args.itemCode, 'Tiramisu Large');
      expect(args.bom, 'BOM-Tiramisu Large-001');
      expect(args.batches, 12);
      expect(args.forJars, isTrue);
      expect(args.hasWorkOrder, isFalse);
    });

    testWidgets('an empty field opens the recipe for one jar', (tester) async {
      final pushed = await _pumpToday(tester);

      await tester.tap(find.byType(ViewSopButton));
      await tester.pumpAndSettle();

      expect(pushed.args!.batches, 1);
      expect(pushed.args!.forJars, isTrue);
    });
  });

  group('Plan row', () {
    testWidgets('keeps the recipe behind the caret', (tester) async {
      await _pumpPlanRow(tester);

      expect(find.byType(ViewSopButton), findsNothing);
      await _expandPlanRow(tester);
      expect(find.byType(ViewSopButton), findsOneWidget);
    });

    testWidgets('offers nothing for an item without an SOP', (tester) async {
      await _pumpPlanRow(tester, hasRecipe: false);
      await _expandPlanRow(tester);

      expect(find.byType(ViewSopButton), findsNothing);
    });

    testWidgets('opens the recipe scaled to the jars in the field', (
      tester,
    ) async {
      final pushed = await _pumpPlanRow(tester, quantity: 8);
      await _expandPlanRow(tester);

      await tester.tap(find.byType(ViewSopButton));
      await tester.pumpAndSettle();

      final args = pushed.args!;
      expect(args.itemCode, 'Tiramisu Large');
      expect(args.bom, 'BOM-Tiramisu Large-001');
      expect(args.batches, 8);
      expect(args.forJars, isTrue);
    });

    testWidgets('an empty field opens the recipe for one jar', (tester) async {
      final pushed = await _pumpPlanRow(tester);
      await _expandPlanRow(tester);

      await tester.tap(find.byType(ViewSopButton));
      await tester.pumpAndSettle();

      expect(pushed.args!.batches, 1);
    });

    testWidgets('a BOM that makes several jars is scaled in runs, not jars', (
      tester,
    ) async {
      final pushed = await _pumpPlanRow(
        tester,
        quantity: 24,
        row: const PlanRow(
          itemCode: 'Tiramisu Large',
          itemName: 'Tiramisu Large',
          itemGroup: 'Jars',
          bomName: 'BOM-Tiramisu Large-001',
          bomQty: 12,
        ),
      );
      await _expandPlanRow(tester);

      await tester.tap(find.byType(ViewSopButton));
      await tester.pumpAndSettle();

      expect(pushed.args!.batches, 2);
    });
  });
}
