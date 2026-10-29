// "Start order" from the chat: the order the AI read is matched against the
// POS catalog and put in the cart through the cashier's own cart methods.
// Nothing is guessed: unknown codes and unfilled bundles go to the panel.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/state/chat_order_apply.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _FakePosRepository extends PosRepository {
  _FakePosRepository() : super(Dio());

  /// Codes the server refuses, with the reason it gives.
  final Map<String, String> refuse = {};
  bool promoThrows = false;
  final List<List<String>> promoCalls = [];
  final List<int> promoCartSizes = [];

  @override
  Future<Map<String, dynamic>> validatePromoCodes({
    required List<String> codes,
    required List<Map<String, dynamic>> items,
    String? customer,
    required String posProfile,
    bool isPickup = false,
  }) async {
    promoCalls.add(List.of(codes));
    promoCartSizes.add(items.length);
    if (promoThrows) throw Exception('promo service down');
    return {
      'results': [
        for (final code in codes)
          refuse.containsKey(code)
              ? {'code': code, 'accepted': false, 'reason': refuse[code]}
              : {'code': code, 'accepted': true, 'discount_amount': 10},
      ],
      'total_discount': 10.0 * codes.where((c) => !refuse.containsKey(c)).length,
      'free_delivery': false,
    };
  }
}

class _FakeDraftCartRepository extends DraftCartRepository {
  @override
  Future<void> upsert(draft) async {}
  @override
  Future<List<DraftCart>> loadAll() async => [];
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> clearAll() async {}
}

const _hazelnut = 'Chocolate Hazelnut Large';
const _lotus = 'Lotus Large';

final _items = <Map<String, dynamic>>[
  {
    'name': _hazelnut,
    'item_name': 'Chocolate Hazelnut (L)',
    'rate': 120.0,
    'price_list_rate': 120.0,
    'actual_qty': 50,
  },
  {
    'name': _lotus,
    'item_name': 'Lotus (L)',
    'rate': 110.0,
    'price_list_rate': 110.0,
    'actual_qty': 1,
  },
];

Map<String, dynamic> _trio() => {
  'id': 'BNDL-0001',
  'name': 'Jarz Signature Trio',
  'erpnext_item': 'Jarz Signature Trio',
  'price': 300.0,
  'item_groups': [
    {
      'group_key': 'Jars::1',
      'group_name': 'Jars',
      'quantity': 3,
      'items': [
        {'id': _hazelnut, 'name': 'Chocolate Hazelnut (L)', 'price': 120.0,
          'qty': 40, 'actual_qty': 40},
        {'id': _lotus, 'name': 'Lotus (L)', 'price': 110.0, 'qty': 1,
          'actual_qty': 1},
      ],
    },
  ],
};

ChatPrefillLine _itemLine(String code, num qty) => ChatPrefillLine.fromJson({
  'kind': 'item',
  'item_code': code,
  'item_name': code,
  'qty': qty,
});

ChatPrefillLine _trioLine(
  List<Map<String, dynamic>> picks, {
  bool complete = true,
  String? bundleId = 'BNDL-0001',
  String groupKey = 'Jars::1',
}) => ChatPrefillLine.fromJson({
  'kind': 'bundle',
  'bundle_id': bundleId,
  'item_code': 'Jarz Signature Trio',
  'item_name': 'Jarz Signature Trio',
  'qty': 1,
  'selections': {groupKey: picks},
  'complete': complete,
});

void main() {
  group('planChatOrder', () {
    ChatOrderPlan plan(List<ChatPrefillLine> lines) => planChatOrder(
      ChatPrefillOrder(lines: lines),
      items: _items,
      bundles: [_trio()],
    );

    test('an item line keeps its quantity', () {
      final p = plan([_itemLine(_hazelnut, 2)]);
      expect(p.items.single.item['name'], _hazelnut);
      expect(p.items.single.qty, 2);
      expect(p.skipped, isEmpty);
    });

    test('an unknown code is skipped, not guessed', () {
      final p = plan([_itemLine('Mango Small', 1)]);
      expect(p.items, isEmpty);
      expect(p.skipped.single.reason, ChatOrderSkipReason.notInCatalog);
    });

    test('a fractional or zero quantity is skipped', () {
      final p = plan([_itemLine(_hazelnut, 1.5), _itemLine(_lotus, 0)]);
      expect(p.items, isEmpty);
      expect(
        p.skipped.map((s) => s.reason),
        everyElement(ChatOrderSkipReason.unclearQuantity),
      );
    });

    test('a complete bundle builds the dialog selection shape', () {
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 3},
        ]),
      ]);
      expect(p.skipped, isEmpty);
      final add = p.bundles.single;
      expect(add.bundle['id'], 'BNDL-0001');
      final picks = add.selectedItems['Jars::1']!;
      expect(picks, hasLength(3), reason: 'one entry per unit picked');
      expect(picks.first, {
        'id': _hazelnut,
        'name': 'Chocolate Hazelnut (L)',
        'price': 120.0,
        'qty': 40,
        'actual_qty': 40,
        'allow_negative_stock': null,
        'group_name': 'Jars',
      });
    });

    test('a bundle is found by its ERPNext item when the id is missing', () {
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 3},
        ], bundleId: null),
      ]);
      expect(p.bundles.single.bundle['id'], 'BNDL-0001');
    });

    test('an incomplete bundle goes to the panel', () {
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 1},
        ], complete: false),
      ]);
      expect(p.bundles, isEmpty);
      expect(p.skipped.single.reason, ChatOrderSkipReason.incompleteBundle);
    });

    test('"complete" is re-checked against the group quantity', () {
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 2},
        ]),
      ]);
      expect(p.skipped.single.reason, ChatOrderSkipReason.incompleteBundle);
    });

    test('a flavour the group does not offer goes to the panel', () {
      final p = plan([
        _trioLine([
          {'item_code': 'Mango Small', 'qty': 3},
        ]),
      ]);
      expect(p.skipped.single.reason, ChatOrderSkipReason.selectionNotInCatalog);
    });

    test('an unknown group key goes to the panel', () {
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 3},
        ], groupKey: 'Nope::9'),
      ]);
      expect(p.skipped.single.reason, ChatOrderSkipReason.incompleteBundle);
    });

    test('a flavour short of stock goes to the panel', () {
      final p = plan([
        _trioLine([
          {'item_code': _lotus, 'qty': 3},
        ]),
      ]);
      expect(p.skipped.single.reason, ChatOrderSkipReason.outOfStock);
    });

    test('a bundle missing from the catalog goes to the panel', () {
      // bundle_id misses but the ERPNext item still matches: found.
      final p = plan([
        _trioLine([
          {'item_code': _hazelnut, 'qty': 3},
        ], bundleId: 'BNDL-9999'),
      ]);
      expect(p.bundles, hasLength(1));
      final missing = planChatOrder(
        ChatPrefillOrder(lines: [
          ChatPrefillLine.fromJson({
            'kind': 'bundle',
            'bundle_id': 'BNDL-9999',
            'item_code': 'Unknown Box',
            'qty': 1,
            'complete': true,
          }),
        ]),
        items: _items,
        bundles: [_trio()],
      );
      expect(missing.skipped.single.reason, ChatOrderSkipReason.notInCatalog);
    });

    test('group keys follow the bundle dialog rule', () {
      expect(bundleGroupKey({'group_key': 'k'}, 0), 'k');
      expect(bundleGroupKey({'group_name': 'Jars'}, 0), 'Jars::1');
      expect(bundleGroupKey({'group_name': 'Jars', 'idx': 4}, 0), 'Jars::4');
    });
  });

  group('PosNotifier.applyChatOrder', () {
    late PosNotifier notifier;

    setUp(() {
      notifier = PosNotifier(_FakePosRepository(), _FakeDraftCartRepository());
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': 'Dokki'},
        items: _items,
        bundles: [_trio()],
        selectedCustomer: const {'name': 'CUST-1', 'customer_name': 'Mona'},
      );
    });

    tearDown(() => notifier.dispose());

    test('items land with their quantity, priced like a grid tap', () {
      final result = notifier.applyChatOrder(
        ChatPrefillOrder(lines: [_itemLine(_hazelnut, 2)]),
      );
      expect(result.added, hasLength(1));
      expect(result.skipped, isEmpty);
      final line = notifier.state.cartItems.single;
      expect(line['item_code'], _hazelnut);
      expect(line['quantity'], 2);
      expect(line['type'], 'item');

      // Same line a cashier gets by tapping the tile twice.
      final byHand = PosNotifier(
        _FakePosRepository(),
        _FakeDraftCartRepository(),
      );
      addTearDown(byHand.dispose);
      byHand.state = notifier.state.copyWith(cartItems: const []);
      byHand.addToCart(_items.first);
      byHand.addToCart(_items.first);
      expect(line, byHand.state.cartItems.single);
    });

    test('adds to a line already in the cart', () {
      notifier.addToCart(_items.first);
      notifier.applyChatOrder(
        ChatPrefillOrder(lines: [_itemLine(_hazelnut, 2)]),
      );
      expect(notifier.state.cartItems.single['quantity'], 3);
    });

    test('a complete bundle becomes one bundle cart line', () {
      final result = notifier.applyChatOrder(
        ChatPrefillOrder(lines: [
          _trioLine([
            {'item_code': _hazelnut, 'qty': 3},
          ]),
        ]),
      );
      expect(result.added, hasLength(1));
      final line = notifier.state.cartItems.single;
      expect(line['type'], 'bundle');
      expect(line['item_code'], 'BNDL-0001');
      expect(line['rate'], 300.0);
      final details = line['bundle_details'] as Map;
      expect(details['bundle_id'], 'BNDL-0001');
      final selected = details['selected_items'] as Map;
      expect((selected['Jars::1'] as List), hasLength(3));
    });

    test('two bundle lines are two independent cart lines', () {
      notifier.applyChatOrder(
        ChatPrefillOrder(lines: [
          _trioLine([
            {'item_code': _hazelnut, 'qty': 3},
          ]),
          _trioLine([
            {'item_code': _hazelnut, 'qty': 3},
          ]),
        ]),
      );
      final cart = notifier.state.cartItems;
      expect(cart, hasLength(2));
      final a = (cart[0]['bundle_details'] as Map)['selected_items'];
      final b = (cart[1]['bundle_details'] as Map)['selected_items'];
      expect(identical(a, b), isFalse);
    });

    test('incomplete bundles and unknown codes stay out of the cart', () {
      final result = notifier.applyChatOrder(
        ChatPrefillOrder(lines: [
          _itemLine(_hazelnut, 1),
          _itemLine('Mango Small', 2),
          _trioLine([
            {'item_code': _hazelnut, 'qty': 1},
          ], complete: false),
        ]),
      );
      expect(notifier.state.cartItems, hasLength(1));
      expect(result.added.single.itemCode, _hazelnut);
      expect(
        result.skipped.map((s) => (s.line.itemCode, s.reason)),
        [
          ('Mango Small', ChatOrderSkipReason.notInCatalog),
          ('Jarz Signature Trio', ChatOrderSkipReason.incompleteBundle),
        ],
      );
    });

    test('an item past its stock is added and flagged', () {
      final result = notifier.applyChatOrder(
        ChatPrefillOrder(lines: [_itemLine(_lotus, 3)]),
      );
      expect(notifier.state.cartItems.single['quantity'], 3);
      expect(result.overStock, [_lotus]);
    });
  });

  group('PosNotifier.applyChatPromoCodes', () {
    late _FakePosRepository repo;
    late PosNotifier notifier;

    setUp(() {
      repo = _FakePosRepository();
      notifier = PosNotifier(repo, _FakeDraftCartRepository());
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': 'Dokki'},
        items: _items,
        bundles: [_trio()],
        selectedCustomer: const {'name': 'CUST-1', 'customer_name': 'Mona'},
      );
    });

    tearDown(() => notifier.dispose());

    test('codes go through the POS promo path once, after the cart', () async {
      notifier.applyChatOrder(
        ChatPrefillOrder(lines: [_itemLine(_hazelnut, 2)]),
      );
      final outcomes = await notifier.applyChatPromoCodes(
        ['backxq33vv', 'BACKXQ33VV', 'SPRING'],
      );

      expect(outcomes.map((o) => (o.code, o.status)), [
        ('BACKXQ33VV', ChatPromoStatus.applied),
        ('SPRING', ChatPromoStatus.applied),
      ]);
      // One preview per code, each sent with the filled cart.
      expect(repo.promoCalls, [
        ['BACKXQ33VV'],
        ['BACKXQ33VV', 'SPRING'],
      ]);
      expect(repo.promoCartSizes, everyElement(1));
      expect(notifier.state.appliedPromoCodes, ['BACKXQ33VV', 'SPRING']);
      expect(notifier.state.promoDiscount, 20.0);

      // Applying again is a no-op, as typing the same code twice is.
      await notifier.applyChatPromoCodes(['BACKXQ33VV']);
      expect(repo.promoCalls, hasLength(2));
    });

    test('nothing is applied when the cart is empty', () async {
      final outcomes = await notifier.applyChatPromoCodes(['BACKXQ33VV']);
      expect(outcomes.single.status, ChatPromoStatus.notApplied);
      expect(repo.promoCalls, isEmpty);
      expect(notifier.state.appliedPromoCodes, isEmpty);
    });

    test('a refused code carries the server reason', () async {
      repo.refuse['OLD10'] = 'This code has expired';
      notifier.addToCart(_items.first);
      final outcomes = await notifier.applyChatPromoCodes(['OLD10']);
      expect(outcomes.single.status, ChatPromoStatus.refused);
      expect(outcomes.single.reason, 'This code has expired');
      // Left on the cart as a refused chip, exactly as if typed.
      expect(notifier.state.appliedPromoCodes, ['OLD10']);
    });

    test('a failed preview is a refusal with the error', () async {
      repo.promoThrows = true;
      notifier.addToCart(_items.first);
      final outcomes = await notifier.applyChatPromoCodes(['BACKXQ33VV']);
      expect(outcomes.single.status, ChatPromoStatus.refused);
      expect(outcomes.single.reason, contains('promo service down'));
    });
  });
}
