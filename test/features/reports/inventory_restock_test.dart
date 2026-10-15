import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/reports/data/models/inventory_intelligence.dart';
import 'package:jarz_pos/src/features/reports/data/models/report_envelopes.dart';
import 'package:jarz_pos/src/features/reports/data/models/velocity_alerts.dart';
import 'package:jarz_pos/src/features/reports/data/velocity_alerts_repository.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/inventory_intelligence_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

class _FakeVelocityAlertsRepository implements VelocityAlertsRepository {
  @override
  Future<VelocityAlertSummary> fetchAlertSummary() async =>
      VelocityAlertSummary();

  @override
  Future<ItemVelocityDetail> fetchItemVelocity(String itemCode) async {
    return const ItemVelocityDetail(
      velocity30d: 1.5,
      velocity60d: 1.0,
      trend: 'Accelerating',
      stockOnHand: 12,
    );
  }

  @override
  Future<int> runVelocityUpdateNow() async => 0;
}

Future<void> _pump(
  WidgetTester tester,
  InventoryReport report, {
  List<String> roles = const ['JARZ Manager'],
}) async {
  final view = tester.view;
  view.physicalSize = const Size(400 * 2, 3000 * 2);
  view.devicePixelRatio = 2;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryReportProvider.overrideWith((ref, query) => report),
        velocityAlertsRepositoryProvider
            .overrideWithValue(_FakeVelocityAlertsRepository()),
        reportBranchesProvider.overrideWith((ref) => const []),
        userRolesFutureProvider.overrideWith(
          (ref) async => UserRoles(user: 'u@jarz.pos', roles: roles),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: InventoryIntelligenceScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

InventoryReport _report() => InventoryReport(
      data: InventoryIntelligence.fromJson(const {}),
      restock: const [
        RestockRow(
          itemCode: 'ITEM-1',
          itemName: 'Chocolate Jar',
          stock: 2,
          uom: 'Nos',
          velocity30d: 1.5,
          daysCover: 1.3,
          status: RestockStatus.critical,
          suggestedQty: 40,
          stockValue: 500,
        ),
        RestockRow(
          itemCode: 'ITEM-2',
          itemName: 'Vanilla Jar',
          stock: 60,
          uom: 'Nos',
          velocity30d: 0.1,
          status: RestockStatus.overstock,
        ),
      ],
    );

void main() {
  testWidgets('one restock list with status filter, days cover and suggested '
      'qty', (tester) async {
    await _pump(tester, _report());

    expect(find.text('Inventory & restock'), findsOneWidget);
    expect(find.text('Days cover'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('Chocolate Jar'), findsOneWidget);
    expect(find.text('Vanilla Jar'), findsOneWidget);
    // Recalculate is offered to the manager tier.
    expect(find.byIcon(Icons.autorenew), findsOneWidget);

    // Filtering to Critical hides the overstocked row.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Critical  1'));
    await tester.pumpAndSettle();
    expect(find.text('Chocolate Jar'), findsOneWidget);
    expect(find.text('Vanilla Jar'), findsNothing);
  });

  testWidgets('recalculate is hidden below the manager tier', (tester) async {
    await _pump(tester, _report(), roles: const []);
    expect(find.byIcon(Icons.autorenew), findsNothing);
  });

  testWidgets('tapping a restock row opens the velocity detail sheet',
      (tester) async {
    await _pump(tester, _report());

    await tester.tap(find.text('Chocolate Jar'));
    await tester.pumpAndSettle();

    expect(find.text('Velocity Detail'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
  });
}
