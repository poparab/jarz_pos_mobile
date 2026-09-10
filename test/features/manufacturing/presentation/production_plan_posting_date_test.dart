import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/basket_rollup.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/bom_details.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/daily_plan.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/material_options.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_policy.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_plan_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';

import '../../../helpers/mock_services.dart';

/// The posting date the Plan tab shows when the operator has not picked one.
///
/// It used to come from `DateTime.now()` while every verdict about it — the
/// caption, `isBackDated`, the refusal that gates Start batches and Quick
/// produce — came from `policy.today()`, the SERVER's day. Two clocks, one
/// date, and the disagreement only appears on a tablet whose clock is off:
/// exactly the device nobody is looking at.
///
/// These tests pin the policy to a day the device clock cannot be on, so a
/// regression shows up as the machine's real date appearing in the bar. They
/// belonged to the Batch tab until Daily, Plan and Batch merged; the date bar
/// moved with the queue, so they moved with it.
void main() {
  testWidgets('defaults the posting date to the server day, not the device', (
    tester,
  ) async {
    // A day no machine running this test is on, so the assertion cannot pass by
    // coincidence.
    final serverDay = DateTime(2020, 3, 4);

    await _pumpTab(tester, policy: ProductionPolicy(serverDate: serverDay));

    expect(find.text('2020-03-04'), findsOneWidget);
    expect(find.text(_format(DateTime.now())), findsNothing);
  });

  testWidgets('a server day AHEAD of the device does not read as backdated', (
    tester,
  ) async {
    // The dangerous direction. A tablet a day slow used to default to the
    // server's yesterday, so `isBackDated` was true, and Start refused with
    // "backdating not allowed" for a date the operator never chose. The
    // operator's only recourse was a date picker the same policy had locked.
    final serverDay = DateTime.now().add(const Duration(days: 2));
    final day = DateTime(serverDay.year, serverDay.month, serverDay.day);

    await _pumpTab(tester, policy: ProductionPolicy(serverDate: day));

    expect(find.text(_format(day)), findsOneWidget);
    // The caption that only renders for a backdated day.
    expect(find.text('Recording production for a past date'), findsNothing);
  });

  testWidgets('an explicitly picked date still wins over the server day', (
    tester,
  ) async {
    final picked = DateTime(2020, 5, 6);

    await _pumpTab(
      tester,
      policy: ProductionPolicy(serverDate: DateTime(2020, 5, 20)),
      postingDate: picked,
    );

    expect(find.text('2020-05-06'), findsOneWidget);
  });
}

String _format(DateTime value) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

class _FakeBasketRepository implements ProductionBasketRepository {
  @override
  Future<ProductionBasket?> load() async => null;
  @override
  Future<void> save(ProductionBasket basket) async {}
  @override
  Future<void> clear() async {}
}

class _SeededBasket extends ProductionBasketNotifier {
  _SeededBasket(this._seed);
  final ProductionBasket _seed;
  @override
  ProductionBasket build() => _seed;
}

class _StubSuggestions extends ProductionSuggestionsNotifier {
  @override
  Future<ProductionSuggestionsPage> build() async =>
      const ProductionSuggestionsPage(velocityUpdatedOn: '2020-01-01 00:00:00');
}

Future<void> _pumpTab(
  WidgetTester tester, {
  required ProductionPolicy policy,
  DateTime? postingDate,
}) async {
  final basket = ProductionBasket(
    postingDate: postingDate,
    lines: const [
      BatchLine(
        itemCode: 'FG-CAKE',
        itemName: 'Cake',
        bomName: 'BOM-CAKE-001',
        stockUom: 'Nos',
        bomQtyYield: 12,
        batches: 2,
        components: [
          BomComponent(
            itemCode: 'RM-FLOUR',
            itemName: 'Flour',
            uom: 'Kg',
            qtyPerBom: 1.0,
            sourceWarehouse: 'Stores - J',
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productionBasketRepositoryProvider.overrideWithValue(
          _FakeBasketRepository(),
        ),
        productionBasketProvider.overrideWith(() => _SeededBasket(basket)),
        productionPolicyOrFallbackProvider.overrideWithValue(policy),
        productionSuggestionsProvider.overrideWith(_StubSuggestions.new),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => const DailyPlanTemplate(
            items: [
              DailyPlanItem(
                itemCode: 'FG-CAKE',
                itemName: 'Cake',
                itemGroup: 'Jars',
                defaultBom: 'BOM-CAKE-001',
                usesMix: true,
                jarsPerBatch: 120,
              ),
            ],
          ),
        ),
        bomReadinessProvider.overrideWith(
          (ref) async => const BomReadiness(ok: true),
        ),
        dailyPlanServiceProvider.overrideWithValue(DailyPlanService(MockDio())),
        // Both stubbed so nothing here reaches Dio: the tab watches the rollup
        // and one MaterialOptions per queued line on every build.
        basketRollupProvider.overrideWith(
          (ref) async => const BasketRollup(ok: true, lineCount: 1),
        ),
        materialOptionsProvider.overrideWith(
          (ref, request) async => MaterialOptions(
            bomName: request.bomName,
            qty: request.qty,
            components: const [],
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
        home: const Scaffold(body: ProductionPlanTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
