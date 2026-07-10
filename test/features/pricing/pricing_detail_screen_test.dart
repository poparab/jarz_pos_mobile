import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/pricing/data/models/pricing_models.dart';
import 'package:jarz_pos/src/features/pricing/data/pricing_repository.dart';
import 'package:jarz_pos/src/features/pricing/presentation/screens/price_list_detail_screen.dart';

class _FakePricingRepository extends PricingRepository {
  _FakePricingRepository() : super(Dio());

  @override
  Future<PriceListDetail> getPriceListDetail(String priceList) async {
    return PriceListDetail(
      name: priceList,
      currency: 'EGP',
      categories: const [
        CategoryPrice(itemGroup: 'Medium', rate: 75, itemCount: 10),
        CategoryPrice(itemGroup: 'Large', rate: 120, itemCount: 8),
      ],
      itemOverrides: const [
        ItemOverride(
          itemCode: 'CHOC-M',
          itemName: 'Chocolate Medium',
          itemGroup: 'Medium',
          rate: 82.5,
        ),
      ],
      customers: const [
        AssignedCustomer(
          customer: 'CUST-1',
          customerName: 'Acme Co',
          assignment: 'direct',
          customerGroup: 'Companies',
        ),
      ],
    );
  }
}

UserRoles _manager() => const UserRoles(
      user: 'm@x.com',
      roles: [RoleNames.jarzManager],
    );

UserRoles _rep() => const UserRoles(
      user: 'r@x.com',
      roles: [RoleNames.b2bSalesRep],
      isB2bSalesRep: true,
    );

Widget _wrap({required UserRoles roles}) {
  return ProviderScope(
    overrides: [
      pricingRepositoryProvider.overrideWithValue(_FakePricingRepository()),
      userRolesFutureProvider.overrideWith((ref) async => roles),
    ],
    child: const MaterialApp(
      home: PriceListDetailScreen(priceList: 'Companies'),
    ),
  );
}

void main() {
  group('PriceListDetailScreen role gating', () {
    testWidgets('managers see inline edit controls', (tester) async {
      await tester.pumpWidget(_wrap(roles: _manager()));
      await tester.pumpAndSettle();

      // Category rows render.
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      // Managers get edit affordances (pencil icons) + the add-category button.
      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byTooltip('Add category'), findsOneWidget);
    });

    testWidgets('B2B reps get a read-only view (no edit controls)',
        (tester) async {
      await tester.pumpWidget(_wrap(roles: _rep()));
      await tester.pumpAndSettle();

      // Content still renders for reps...
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      // ...but NO edit / add / delete controls are present.
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byTooltip('Add category'), findsNothing);
    });
  });

  group('Per-flavor overrides section', () {
    testWidgets('is COLLAPSED by default (initiallyExpanded == false)',
        (tester) async {
      await tester.pumpWidget(_wrap(roles: _manager()));
      await tester.pumpAndSettle();

      // The section header is present.
      expect(find.text('Per-flavor overrides'), findsOneWidget);

      // The ExpansionTile is declared collapsed.
      final tile = tester.widget<ExpansionTile>(find.byType(ExpansionTile));
      expect(tile.initiallyExpanded, isFalse);

      // Its children (the override row) are offstage, so not found yet.
      expect(find.text('Chocolate Medium'), findsNothing);
    });

    testWidgets('reveals overrides after tapping the header', (tester) async {
      await tester.pumpWidget(_wrap(roles: _manager()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Per-flavor overrides'));
      await tester.pumpAndSettle();

      // Now the override row is visible.
      expect(find.text('Chocolate Medium'), findsOneWidget);
    });
  });
}
