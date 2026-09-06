import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/reports/data/models/velocity_alerts.dart';
import 'package:jarz_pos/src/features/reports/data/velocity_alerts_repository.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/velocity_alerts_screen.dart';

class _FakeVelocityAlertsRepository implements VelocityAlertsRepository {
  _FakeVelocityAlertsRepository(this.summary);
  final VelocityAlertSummary summary;

  @override
  Future<VelocityAlertSummary> fetchAlertSummary() async => summary;

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

Future<void> _pump(WidgetTester tester, VelocityAlertSummary summary) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        velocityAlertsRepositoryProvider
            .overrideWithValue(_FakeVelocityAlertsRepository(summary)),
        userRolesFutureProvider.overrideWith(
          (ref) async => const UserRoles(
            user: 'manager@jarz.pos',
            roles: ['JARZ Manager'],
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
        home: const VelocityAlertsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the loaded alert summary with section counts',
      (tester) async {
    final summary = VelocityAlertSummary(
      critical: [
        {
          'item_code': 'ITEM-1',
          'item_name': 'Chocolate Jar',
          'item_group': 'Jars',
          'stock_on_hand': 2,
          'days_remaining': 1,
        },
      ],
      watchList: [
        {'item_code': 'ITEM-2', 'item_name': 'Vanilla Jar', 'days_remaining': 12},
      ],
      slowMovers: const [],
      overstocked: const [],
    );

    await _pump(tester, summary);

    expect(find.text('Reorder & Velocity Alerts'), findsOneWidget);
    expect(find.text('Chocolate Jar'), findsOneWidget);
    expect(find.text('Vanilla Jar'), findsOneWidget);
    // Recalculate action is visible for the JARZ Manager fixture.
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
  });

  testWidgets('tapping an alert row opens the velocity detail sheet',
      (tester) async {
    final summary = VelocityAlertSummary(
      critical: [
        {
          'item_code': 'ITEM-1',
          'item_name': 'Chocolate Jar',
          'days_remaining': 1,
        },
      ],
    );

    await _pump(tester, summary);
    await tester.tap(find.text('Chocolate Jar'));
    await tester.pumpAndSettle();

    expect(find.text('Velocity Detail'), findsOneWidget);
    expect(find.text('1.50'), findsOneWidget);
  });
}
