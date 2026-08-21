import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/item_grid_widget.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _DummyPosRepository extends PosRepository {
  _DummyPosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async => const [];

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(String posProfile) async =>
      const [];
}

class _DummyDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];

  @override
  Future<void> upsert(draft) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _PosNotifierStub extends PosNotifier {
  _PosNotifierStub(PosState initialState)
    : super(_DummyPosRepository(), _DummyDraftCartRepository()) {
    state = initialState;
  }
}

/// Catalog stock counts are deliberately far from the cart quantities under
/// test so a `find.text` never matches the stock badge by accident.
final _items = <Map<String, dynamic>>[
  {
    'name': 'ITEM-A',
    'item_name': 'Item A',
    'item_group': 'Drinks',
    'rate': 25.0,
    'actual_qty': 91,
  },
  {
    'name': 'ITEM-B',
    'item_name': 'Item B',
    'item_group': 'Drinks',
    'rate': 30.0,
    'actual_qty': 92,
  },
];

final _bundles = <Map<String, dynamic>>[
  {'id': 'BUNDLE-1', 'name': 'Bundle One', 'price': 99.0, 'item_groups': []},
];

PosState _stateWithCart(List<Map<String, dynamic>> cartItems) => PosState(
  items: _items,
  bundles: _bundles,
  cartItems: cartItems,
  selectedCustomer: const {'name': 'CUST-0001', 'customer_name': 'Walk In'},
);

Future<void> _pumpGrid(WidgetTester tester, PosState state) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub(state)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ItemGridWidget()),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Finder _cartBadge(String qty) => find.ancestor(
  of: find.text(qty),
  matching: find.byType(Tooltip),
);

void main() {
  testWidgets('no cart badge is shown while the cart is empty', (tester) async {
    await _pumpGrid(tester, _stateWithCart(const []));

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
  });

  testWidgets('item card shows the quantity already in the cart', (
    tester,
  ) async {
    await _pumpGrid(
      tester,
      _stateWithCart(const [
        {'item_code': 'ITEM-A', 'quantity': 3, 'rate': 25.0, 'type': 'item'},
      ]),
    );

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(_cartBadge('3'), findsOneWidget);
    expect(
      tester.widget<Tooltip>(_cartBadge('3')).message,
      'In cart: 3',
    );
  });

  testWidgets('bundle card counts every bundle line in the cart', (
    tester,
  ) async {
    await _pumpGrid(
      tester,
      _stateWithCart(const [
        {
          'item_code': 'BUNDLE-1',
          'quantity': 1,
          'rate': 99.0,
          'type': 'bundle',
          'bundle_details': {'bundle_id': 'BUNDLE-1'},
        },
        {
          'item_code': 'BUNDLE-1',
          'quantity': 1,
          'rate': 99.0,
          'type': 'bundle',
          'bundle_details': {'bundle_id': 'BUNDLE-1'},
        },
      ]),
    );

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(_cartBadge('2'), findsOneWidget);
  });

  testWidgets('shipping lines never produce a badge', (tester) async {
    await _pumpGrid(
      tester,
      _stateWithCart(const [
        {
          'item_code': 'ITEM-A',
          'quantity': 5,
          'rate': 0.0,
          'type': 'item',
          'is_shipping': true,
        },
      ]),
    );

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
  });
}
