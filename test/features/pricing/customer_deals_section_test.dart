import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/pricing/data/customer_deals_repository.dart';
import 'package:jarz_pos/src/features/pricing/data/models/customer_deal_models.dart';
import 'package:jarz_pos/src/features/pricing/presentation/widgets/customer_deals_section.dart';

/// The "Special prices" card on the B2B account screen: a customer's
/// time-limited deals, the normal price beside each deal price, and the
/// editor that saves them. The pricing itself is the server's; these pin the
/// wire shape both ways and what a rep (read-only) versus a manager sees.

Map<String, dynamic> _payload({bool canEdit = true}) => {
  'customer': 'Cafe Orbit',
  'customer_name': 'Café Orbit',
  'price_list': 'B2B Selling',
  'today': '2026-10-02',
  'can_edit': canEdit,
  'deals': [
    {
      'name': 'DEAL-00001',
      'valid_from': '2026-10-01',
      'valid_upto': '2026-10-15',
      'status': 'active',
      'editable': true,
      'has_orders': true,
      'notes': 'Opening month',
      'items': [
        {
          'item_group': 'Large',
          'item_code': null,
          'label': 'Large',
          'rate': 80,
          'normal_rate': 92,
        },
        {
          'item_group': null,
          'item_code': 'Molten Medium',
          'label': 'Molten Medium',
          'rate': 60,
          'normal_rate': 77,
        },
      ],
    },
    {
      'name': 'DEAL-00002',
      'valid_from': '2026-10-20',
      'valid_upto': '2026-10-25',
      'status': 'upcoming',
      'editable': true,
      'items': [
        {'item_group': 'Medium', 'label': 'Medium', 'rate': 65},
      ],
    },
    {
      'name': 'DEAL-00000',
      'valid_from': '2026-09-01',
      'valid_upto': '2026-09-10',
      'status': 'expired',
      'editable': false,
      'items': [
        {'item_group': 'Medium', 'label': 'Medium', 'rate': 70},
      ],
    },
  ],
  'catalog': {
    'categories': [
      {'item_group': 'Large', 'item_count': 10, 'normal_rate': 92},
      {'item_group': 'Medium', 'item_count': 10, 'normal_rate': 77},
    ],
    'items': [
      {
        'item_code': 'Molten Medium',
        'item_name': 'Molten Medium',
        'item_group': 'Medium',
        'normal_rate': 77,
      },
    ],
  },
};

class _FakeDealsRepository extends CustomerDealsRepository {
  _FakeDealsRepository({this.canEdit = true, this.fail = false}) : super(Dio());

  final bool canEdit;
  final bool fail;
  final List<Map<String, dynamic>> saves = [];
  final List<String> ended = [];

  @override
  Future<CustomerDeals> getCustomerDeals(String customer) async {
    if (fail) throw Exception('403');
    return CustomerDeals.fromJson(_payload(canEdit: canEdit));
  }

  @override
  Future<CustomerDeal> saveCustomerDeal({
    required String customer,
    required DateTime validFrom,
    required DateTime validUpto,
    required List<CustomerDealLine> items,
    String? notes,
    String? deal,
  }) async {
    saves.add({
      'customer': customer,
      'from': validFrom,
      'to': validUpto,
      'items': items.map((e) => e.toPayload()).toList(),
      'notes': notes,
      'deal': deal,
    });
    return CustomerDeal.fromJson(
      (_payload()['deals'] as List).first as Map<String, dynamic>,
    );
  }

  @override
  Future<CustomerDeal> endCustomerDeal(String deal) async {
    ended.add(deal);
    return CustomerDeal.fromJson(
      (_payload()['deals'] as List).first as Map<String, dynamic>,
    );
  }
}

Widget _app(CustomerDealsRepository repo) {
  return ProviderScope(
    overrides: [customerDealsRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: CustomerDealsSection(customer: 'Cafe Orbit'),
        ),
      ),
    ),
  );
}

void main() {
  group('CustomerDeals.fromJson', () {
    test('parses deals, lines and the catalog', () {
      final data = CustomerDeals.fromJson(_payload());
      expect(data.canEdit, isTrue);
      expect(data.live.map((d) => d.name), ['DEAL-00001', 'DEAL-00002']);
      expect(data.history.single.status, CustomerDealStatus.expired);
    expect(data.live.first.hasOrders, isTrue);
    expect(data.live.last.hasOrders, isFalse);
      final lines = data.live.first.items;
      expect(lines.first.isCategory, isTrue);
      expect(lines.first.normalRate, 92);
      expect(lines.last.itemCode, 'Molten Medium');
      expect(data.live.first.validUpto, DateTime(2026, 10, 15));
      expect(data.normalRateFor(itemGroup: 'Medium'), 77);
      expect(data.normalRateFor(itemCode: 'Molten Medium'), 77);
    });

    test('a line sends exactly one target', () {
      expect(
        const CustomerDealLine(
          itemGroup: 'Large',
          label: 'Large',
          rate: 80,
        ).toPayload(),
        {'item_group': 'Large', 'rate': 80.0},
      );
      expect(
        const CustomerDealLine(
          itemCode: 'Molten Large',
          itemGroup: 'Large',
          label: 'Molten Large',
          rate: 70,
        ).toPayload(),
        {'item_code': 'Molten Large', 'rate': 70.0},
      );
    });
  });

  testWidgets('shows live deals with the normal price beside each', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeDealsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Special prices'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.textContaining('All Large: EGP'), findsOneWidget);
    expect(find.textContaining('normally EGP'), findsNWidgets(2));
    expect(find.text('Past deals (1)'), findsOneWidget);
    expect(find.byKey(const ValueKey('deals-new')), findsOneWidget);
  });

  testWidgets('a rep sees deals but cannot add or edit', (tester) async {
    await tester.pumpWidget(_app(_FakeDealsRepository(canEdit: false)));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.byKey(const ValueKey('deals-new')), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('renders nothing when deals cannot be read', (tester) async {
    await tester.pumpWidget(_app(_FakeDealsRepository(fail: true)));
    await tester.pumpAndSettle();

    expect(find.text('Special prices'), findsNothing);
  });

  testWidgets('a new deal needs dates before it saves', (tester) async {
    final repo = _FakeDealsRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deals-new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deal-save')));
    await tester.pumpAndSettle();

    expect(find.text('Choose the deal dates first'), findsOneWidget);
    expect(repo.saves, isEmpty);
  });

  testWidgets('a running deal keeps its prices; only the end can move', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _FakeDealsRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit deal'), findsOneWidget);
    expect(
      find.textContaining('A running deal keeps its start date and prices'),
      findsOneWidget,
    );
    final rateFields = tester.widgetList<TextField>(
      find.widgetWithText(TextField, 'Deal price'),
    );
    expect(rateFields, hasLength(2));
    expect(rateFields.every((f) => f.enabled == false), isTrue);
    expect(
      tester
          .widget<ButtonStyleButton>(
            find.byKey(const ValueKey('deal-add-item')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('deal-save')));
    await tester.pumpAndSettle();

    final save = repo.saves.single;
    expect(save['deal'], 'DEAL-00001');
    expect(save['from'], DateTime(2026, 10, 1));
    expect(save['to'], DateTime(2026, 10, 15));
    expect(save['items'], [
      {'item_group': 'Large', 'rate': 80.0},
      {'item_code': 'Molten Medium', 'rate': 60.0},
    ]);
  });

  testWidgets('an upcoming deal can change its prices', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _FakeDealsRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Deal price'),
      '62.5',
    );
    await tester.tap(find.byKey(const ValueKey('deal-save')));
    await tester.pumpAndSettle();

    final save = repo.saves.single;
    expect(save['deal'], 'DEAL-00002');
    expect(save['items'], [
      {'item_group': 'Medium', 'rate': 62.5},
    ]);
    expect(find.text('Deal saved'), findsOneWidget);
  });

  testWidgets('ending a deal asks first, then calls the server', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _FakeDealsRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deal-end')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Orders placed today keep the deal price'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'End deal'));
    await tester.pumpAndSettle();

    expect(repo.ended, ['DEAL-00001']);
    // The server kept it for today's orders, so the app says when it stops.
    expect(find.textContaining('The deal ends tonight'), findsOneWidget);
  });
}
