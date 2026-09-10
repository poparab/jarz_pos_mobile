import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/manufacturing_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/base_production_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_batch_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_running_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

import '../../../helpers/mock_services.dart';

class _FakeBasketRepository implements ProductionBasketRepository {
  @override
  Future<ProductionBasket?> load() async => null;
  @override
  Future<void> save(ProductionBasket basket) async {}
  @override
  Future<void> clear() async {}
}

Future<void> _pump(WidgetTester tester, {int initialTab = 0}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        productionBasketRepositoryProvider
            .overrideWithValue(_FakeBasketRepository()),
        manufacturingServiceProvider
            .overrideWithValue(ManufacturingService(MockDio())),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ManufacturingScreen(initialTab: initialTab),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// The board inside a router that also knows the Today route.
///
/// The five-tab board and the Today screen are two destinations of one
/// feature, so "can I get from here to there" is a routing question and has
/// to be pumped as one. Today itself is stubbed: this asserts the link, not
/// that screen's own content.
Future<void> _pumpRouted(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: AppRoutes.manufacturing,
    routes: [
      GoRoute(
        path: AppRoutes.manufacturing,
        builder: (_, _) => const ManufacturingScreen(),
      ),
      GoRoute(
        path: AppRoutes.productionToday,
        builder: (_, _) => const Scaffold(body: Text('today screen')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        productionBasketRepositoryProvider
            .overrideWithValue(_FakeBasketRepository()),
        manufacturingServiceProvider
            .overrideWithValue(ManufacturingService(MockDio())),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  group('tab index constants', () {
    // Not a tautology: these three are agreed on by the host, the Batch tab and
    // the Bases card, and inserting a tab without moving all of them is exactly
    // how the Running tab ends up unreachable.
    test('Batch, Bases and Running keep their order inside the tab count', () {
      expect(kProductionBatchTabIndex, lessThan(kProductionBasesTabIndex));
      expect(kProductionBasesTabIndex, lessThan(kProductionRunningTabIndex));
      expect(kProductionRunningTabIndex, lessThan(kProductionTabCount));
      expect(kProductionBatchTabIndex, greaterThanOrEqualTo(0));
    });
  });

  testWidgets('the board reads Daily · Plan · Batch · Bases · Running',
      (tester) async {
    await _pump(tester);

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.tabs, hasLength(kProductionTabCount));

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Batch'), findsOneWidget);
    expect(find.text('Bases'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);

    // Left-to-right order, which is what the index constants encode.
    final xs = <String, double>{
      for (final label in ['Daily', 'Plan', 'Batch', 'Bases', 'Running'])
        label: tester.getCenter(find.text(label)).dx,
    };
    expect(xs['Daily']!, lessThan(xs['Plan']!));
    expect(xs['Plan']!, lessThan(xs['Batch']!));
    expect(xs['Batch']!, lessThan(xs['Bases']!));
    expect(xs['Bases']!, lessThan(xs['Running']!));
  });

  testWidgets('kProductionBasesTabIndex opens the Bases tab', (tester) async {
    await _pump(tester, initialTab: kProductionBasesTabIndex);
    expect(find.byType(BaseProductionTab), findsOneWidget);
  });

  testWidgets('kProductionRunningTabIndex still opens the Running tab',
      (tester) async {
    // The index moved 3 → 4 when Bases was inserted. A stale value here means
    // starting a batch drops the operator on the wrong tab.
    await _pump(tester, initialTab: kProductionRunningTabIndex);
    expect(find.byType(ProductionRunningTab), findsOneWidget);
  });

  testWidgets('a deep link past the last tab is clamped, not thrown',
      (tester) async {
    await _pump(tester, initialTab: 99);
    expect(find.byType(ProductionRunningTab), findsOneWidget);
  });

  testWidgets('the board offers the way back to Today', (tester) async {
    // Today reaches the board with `go`, which replaces rather than pushes —
    // so there is no back button, and without this action the only route home
    // is a drawer tile labelled with the board's own name.
    await _pumpRouted(tester);

    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('today screen'), findsOneWidget);
  });

  testWidgets('the app bar still fits a 360 dp phone', (tester) async {
    // Title plus a labelled Today button plus two icons is the tightest the
    // bar gets, and the narrowest tablet on the floor is a phone.
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpRouted(tester);

    expect(tester.takeException(), isNull);
    // Icon-only here, so the label does not squeeze the title into an
    // ellipsis — but still reachable, and still announced.
    expect(find.byTooltip('Today'), findsOneWidget);
    expect(find.text('Production Board'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Production Board'));
    expect(title.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('kProductionBatchTabIndex opens the Batch tab', (tester) async {
    // What the Plan tab's "View batch" asks the host for.
    await _pump(tester, initialTab: kProductionBatchTabIndex);
    expect(find.byType(ProductionBatchTab), findsOneWidget);
  });
}
