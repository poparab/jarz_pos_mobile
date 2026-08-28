import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/manufacturing_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/base_production_tab.dart';
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

void main() {
  group('tab index constants', () {
    // Not a tautology: these three are agreed on by the host, the Batch tab and
    // the Bases card, and inserting a tab without moving all of them is exactly
    // how the Running tab ends up unreachable.
    test('Bases sits before Running, and both sit inside the tab count', () {
      expect(kProductionBasesTabIndex, lessThan(kProductionRunningTabIndex));
      expect(kProductionRunningTabIndex, lessThan(kProductionTabCount));
      expect(kProductionBasesTabIndex, greaterThanOrEqualTo(0));
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
}
