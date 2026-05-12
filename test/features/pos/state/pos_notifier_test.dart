import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';

/// Fake PosRepository that returns controllable data for testing.
class _FakePosRepository extends PosRepository {
  _FakePosRepository() : super(Dio());

  List<Map<String, dynamic>> profilesResult = [];
  List<Map<String, dynamic>> itemsResult = [];
  List<Map<String, dynamic>> bundlesResult = [];
  List<DeliverySlot> slotsResult = [];
  bool shouldThrow = false;
  String? lastItemsProfile;
  String? lastBundlesProfile;
  String? lastAmendmentSourceInvoiceId;
  int itemsCalls = 0;
  int bundlesCalls = 0;
  int createInvoiceCalls = 0;
  int submitInvoiceAmendmentCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async {
    if (shouldThrow) throw Exception('profiles error');
    return profilesResult;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String posProfile) async {
    itemsCalls += 1;
    lastItemsProfile = posProfile;
    if (shouldThrow) throw Exception('items error');
    return itemsResult;
  }

  @override
  Future<List<Map<String, dynamic>>> getBundles(String posProfile) async {
    bundlesCalls += 1;
    lastBundlesProfile = posProfile;
    if (shouldThrow) throw Exception('bundles error');
    return bundlesResult;
  }

  @override
  Future<List<DeliverySlot>> getDeliverySlots(String posProfile) async {
    return slotsResult;
  }

  @override
  Future<Map<String, dynamic>> createInvoice({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    String? deliveryEndDatetime,
    String? salesPartner,
    String? paymentType,
    bool isPickup = false,
    String? paymentMethod,
    bool posProfileOverride = false,
  }) async {
    createInvoiceCalls += 1;
    return {'invoice_name': 'INV-NEW-001'};
  }

  @override
  Future<Map<String, dynamic>> submitInvoiceAmendment({
    required String sourceInvoiceId,
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    String? deliveryEndDatetime,
    String? salesPartner,
    String? paymentType,
    bool isPickup = false,
    String? paymentMethod,
    String? idempotencyKey,
    bool posProfileOverride = false,
  }) async {
    submitInvoiceAmendmentCalls += 1;
    lastAmendmentSourceInvoiceId = sourceInvoiceId;
    return {'replacement_invoice_id': 'INV-AMD-001'};
  }

  @override
  Future<String?> getTerritoryPosProfile(String customerName) async => null;
}

/// Fake DraftCartRepository that skips Hive initialisation in unit tests.
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

DeliverySlot _makeSlot({String label = 'Morning'}) => DeliverySlot(
      date: '2025-05-01',
      time: '10:00:00',
      datetime: '2025-05-01 10:00:00',
      endDatetime: '2025-05-01 11:00:00',
      label: label,
      dayLabel: 'Thu',
      timeLabel: '10 AM - 11 AM',
    );

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // PosState computed getters
  // ──────────────────────────────────────────────────────────────────────────
  group('PosState computed getters', () {
    test('cartTotal sums rate * quantity across items', () {
      final state = PosState(cartItems: const [
        {'rate': 20, 'quantity': 2},
        {'rate': 5, 'quantity': 3},
      ]);
      expect(state.cartTotal, 55.0);
    });

    test('cartTotal returns 0 for empty cart', () {
      expect(PosState().cartTotal, 0.0);
    });

    test('cartTotal handles missing rate/quantity gracefully', () {
      final state = PosState(cartItems: const [
        {'rate': null, 'quantity': null},
        {},
      ]);
      expect(state.cartTotal, 0.0);
    });

    test('cartItemCount sums all quantities', () {
      final state = PosState(cartItems: const [
        {'quantity': 3},
        {'quantity': 2},
      ]);
      expect(state.cartItemCount, 5);
    });

    test('cartItemCount defaults to 1 when quantity missing', () {
      final state = PosState(cartItems: const [{}]);
      expect(state.cartItemCount, 1);
    });

    test('shippingCost returns customer delivery_income', () {
      final state = PosState(
        selectedCustomer: const {'delivery_income': 25},
      );
      expect(state.shippingCost, 25.0);
    });

    test('shippingCost is 0 when no customer', () {
      expect(PosState().shippingCost, 0.0);
    });

    test('shippingCost is 0 when delivery_income is 0', () {
      final state = PosState(
        selectedCustomer: const {'delivery_income': 0},
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost suppressed when sales partner selected', () {
      final state = PosState(
        selectedCustomer: const {'delivery_income': 30},
        selectedSalesPartner: const {'name': 'SP-1'},
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost suppressed in pickup mode', () {
      final state = PosState(
        selectedCustomer: const {'delivery_income': 30},
        isPickup: true,
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost waived for bundle with free_shipping bool', () {
      final state = PosState(
        cartItems: const [
          {
            'type': 'bundle',
            'rate': 100,
            'quantity': 1,
            'bundle_details': {
              'bundle_info': {'free_shipping': true},
            },
          },
        ],
        selectedCustomer: const {'delivery_income': 40},
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost waived for bundle with free_shipping numeric 1', () {
      final state = PosState(
        cartItems: const [
          {
            'type': 'bundle',
            'rate': 50,
            'quantity': 1,
            'bundle_details': {
              'bundle_info': {'free_shipping': 1},
            },
          },
        ],
        selectedCustomer: const {'delivery_income': 40},
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost waived for bundle with free_shipping string "1"', () {
      final state = PosState(
        cartItems: const [
          {
            'type': 'bundle',
            'rate': 50,
            'quantity': 1,
            'bundle_details': {
              'bundle_info': {'free_shipping': '1'},
            },
          },
        ],
        selectedCustomer: const {'delivery_income': 40},
      );
      expect(state.shippingCost, 0.0);
    });

    test('shippingCost not waived for non-bundle items', () {
      final state = PosState(
        cartItems: const [
          {'type': 'item', 'rate': 50, 'quantity': 1},
        ],
        selectedCustomer: const {'delivery_income': 40},
      );
      expect(state.shippingCost, 40.0);
    });

    test('totalWithShipping = cartTotal + shippingCost', () {
      final state = PosState(
        cartItems: const [
          {'rate': 20, 'quantity': 2},
        ],
        selectedCustomer: const {'delivery_income': 30},
      );
      expect(state.totalWithShipping, 70.0);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosState.copyWith
  // ──────────────────────────────────────────────────────────────────────────
  group('PosState.copyWith', () {
    test('copies all fields when no overrides given', () {
      final original = PosState(
        profiles: const [{'name': 'P1'}],
        selectedCustomer: const {'name': 'C1'},
        isPickup: true,
      );
      final copy = original.copyWith();
      expect(copy.profiles, original.profiles);
      expect(copy.selectedCustomer, original.selectedCustomer);
      expect(copy.isPickup, true);
    });

    test('clearSelectedCustomer nulls the customer', () {
      final state = PosState(selectedCustomer: const {'name': 'C1'});
      final cleared = state.copyWith(clearSelectedCustomer: true);
      expect(cleared.selectedCustomer, isNull);
    });

    test('clearSelectedDeliverySlot nulls the slot', () {
      final state = PosState(selectedDeliverySlot: _makeSlot());
      final cleared = state.copyWith(clearSelectedDeliverySlot: true);
      expect(cleared.selectedDeliverySlot, isNull);
    });

    test('clearSelectedSalesPartner nulls the partner', () {
      final state = PosState(selectedSalesPartner: const {'name': 'SP-1'});
      final cleared = state.copyWith(clearSelectedSalesPartner: true);
      expect(cleared.selectedSalesPartner, isNull);
    });

    test('clearError nulls the error', () {
      final state = PosState(error: 'boom');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('clearDeliverySlots empties the list', () {
      final state = PosState(deliverySlots: [_makeSlot()]);
      final cleared = state.copyWith(clearDeliverySlots: true);
      expect(cleared.deliverySlots, isEmpty);
    });

    test('overriding isPickup works', () {
      final state = PosState();
      expect(state.copyWith(isPickup: true).isPickup, true);
      expect(state.copyWith(isPickup: false).isPickup, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosNotifier – loadProfiles
  // ──────────────────────────────────────────────────────────────────────────
  group('PosNotifier.loadProfiles', () {
    late _FakePosRepository repo;
    late PosNotifier notifier;

    setUp(() {
      repo = _FakePosRepository();
      notifier = PosNotifier(repo, _FakeDraftCartRepository());
    });

    test('auto-selects when only one profile returned', () async {
      repo.profilesResult = [{'name': 'Solo'}];
      repo.itemsResult = [{'id': 'I1', 'name': 'Item1', 'rate': 10}];
      repo.bundlesResult = [{'id': 'B1', 'name': 'Bundle1'}];

      await notifier.loadProfiles();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.selectedProfile, isNotNull);
      expect(notifier.state.selectedProfile!['name'], 'Solo');
      expect(notifier.state.items, hasLength(1));
      expect(notifier.state.bundles, hasLength(1));
    });

    test('does not auto-select when multiple profiles', () async {
      repo.profilesResult = [{'name': 'A'}, {'name': 'B'}];
      await notifier.loadProfiles();

      expect(notifier.state.profiles, hasLength(2));
      expect(notifier.state.selectedProfile, isNull);
    });

    test('sets error on exception', () async {
      repo.shouldThrow = true;
      await notifier.loadProfiles();

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosNotifier – selectProfile
  // ──────────────────────────────────────────────────────────────────────────
  group('PosNotifier.selectProfile', () {
    late _FakePosRepository repo;
    late PosNotifier notifier;

    setUp(() {
      repo = _FakePosRepository();
      notifier = PosNotifier(repo, _FakeDraftCartRepository());
    });

    test('loads items and bundles for selected profile', () async {
      repo.itemsResult = [{'id': 'I1', 'name': 'Item'}];
      repo.bundlesResult = [{'id': 'B1', 'name': 'Bundle'}];

      await notifier.selectProfile({'name': 'Test'});

      expect(notifier.state.selectedProfile!['name'], 'Test');
      expect(notifier.state.items, hasLength(1));
      expect(notifier.state.bundles, hasLength(1));
      expect(notifier.state.isLoading, false);
    });

    test('clears delivery slots and slot on profile switch', () async {
      notifier.state = notifier.state.copyWith(
        deliverySlots: [_makeSlot()],
        selectedDeliverySlot: _makeSlot(),
      );

      await notifier.selectProfile({'name': 'New'});

      expect(notifier.state.deliverySlots, isEmpty);
      expect(notifier.state.selectedDeliverySlot, isNull);
    });

    test('sets error when items/bundles fetch fails', () async {
      repo.shouldThrow = true;
      await notifier.selectProfile({'name': 'Fail'});

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosNotifier – refreshCatalog
  // ──────────────────────────────────────────────────────────────────────────
  group('PosNotifier.refreshCatalog', () {
    late _FakePosRepository repo;
    late PosNotifier notifier;

    setUp(() {
      repo = _FakePosRepository();
      notifier = PosNotifier(repo, _FakeDraftCartRepository());
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': '6th of october'},
        cartItems: const [
          {'item_code': 'ITEM-1', 'quantity': 2, 'rate': 10.0},
        ],
        selectedCustomer: const {'name': 'CUST-1'},
      );
    });

    test('reloads items and bundles for the current profile without clearing order context', () async {
      repo.itemsResult = [
        {'name': 'ITEM-1', 'actual_qty': 4.0},
      ];
      repo.bundlesResult = [
        {'id': 'BUNDLE-1', 'name': 'Bundle 1'},
      ];

      await notifier.refreshCatalog();

      expect(repo.itemsCalls, 1);
      expect(repo.bundlesCalls, 1);
      expect(repo.lastItemsProfile, '6th of october');
      expect(repo.lastBundlesProfile, '6th of october');
      expect(notifier.state.items, hasLength(1));
      expect(notifier.state.bundles, hasLength(1));
      expect(notifier.state.cartItems, hasLength(1));
      expect(notifier.state.selectedCustomer?['name'], 'CUST-1');
      expect(notifier.state.isLoading, isFalse);
    });

    test('does nothing when no profile is selected', () async {
      notifier.state = PosState();

      await notifier.refreshCatalog();

      expect(repo.itemsCalls, 0);
      expect(repo.bundlesCalls, 0);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosNotifier – cart operations
  // ──────────────────────────────────────────────────────────────────────────
  group('PosNotifier cart operations', () {
    late PosNotifier notifier;

    setUp(() {
      notifier = PosNotifier(_FakePosRepository(), _FakeDraftCartRepository());
    });

    test('addToCart inserts new items and increments existing quantity', () {
      notifier.addToCart({
        'name': 'ITEM-1',
        'item_name': 'Sample',
        'rate': 12.5,
      });
      expect(notifier.state.cartItems, hasLength(1));
      expect(notifier.state.cartItems.first['quantity'], 1);

      notifier.addToCart({
        'name': 'ITEM-1',
        'item_name': 'Sample',
        'rate': 12.5,
      });
      expect(notifier.state.cartItems.first['quantity'], 2);
    });

    test('addToCart marks type as item', () {
      notifier.addToCart({'name': 'X', 'item_name': 'X', 'rate': 1});
      expect(notifier.state.cartItems.first['type'], 'item');
    });

    test('addToCart skips delivery items when sales partner selected', () {
      notifier.state = notifier.state.copyWith(
        selectedSalesPartner: const {'name': 'SP-1'},
      );

      notifier.addToCart({
        'name': 'DELIVERY-CHARGE',
        'item_name': 'Delivery Fee',
        'rate': 50,
        'item_group': 'Delivery Charges',
      });
      expect(notifier.state.cartItems, isEmpty);
    });

    test('addToCart skips items with shipping in name when partner set', () {
      notifier.state = notifier.state.copyWith(
        selectedSalesPartner: const {'name': 'SP-1'},
      );

      notifier.addToCart({
        'name': 'SHIPPING-FEE',
        'item_name': 'Shipping Fee',
        'rate': 50,
      });
      expect(notifier.state.cartItems, isEmpty);
    });

    test('addToCart allows regular items when partner set', () {
      notifier.state = notifier.state.copyWith(
        selectedSalesPartner: const {'name': 'SP-1'},
      );
      notifier.addToCart({'name': 'BURGER', 'item_name': 'Burger', 'rate': 10});
      expect(notifier.state.cartItems, hasLength(1));
    });

    test('addBundleToCart adds bundle with correct structure', () {
      notifier.addBundleToCart(
        {'id': 'BDL-1', 'name': 'Meal Deal', 'price': 25},
        {'group1': [{'item': 'A'}]},
      );
      final item = notifier.state.cartItems.first;
      expect(item['type'], 'bundle');
      expect(item['bundle_details']['bundle_id'], 'BDL-1');
      expect(item['bundle_details']['selected_items'], isNotEmpty);
    });

    test('updateBundleInCart updates selected items for bundle type', () {
      notifier.addBundleToCart(
        {'id': 'BDL-1', 'name': 'Meal', 'price': 25},
        {'g1': [{'item': 'A'}]},
      );
      notifier.updateBundleInCart(0, {'g1': [{'item': 'B'}]});
      expect(
        notifier.state.cartItems.first['bundle_details']['selected_items']['g1']
            .first['item'],
        'B',
      );
    });

    test('updateCartItemQuantity increases quantity', () {
      notifier.addToCart({'name': 'X', 'item_name': 'X', 'rate': 5});
      notifier.updateCartItemQuantity(0, 3);
      expect(notifier.state.cartItems.first['quantity'], 3);
    });

    test('updateCartItemQuantity with 0 removes item', () {
      notifier.addToCart({'name': 'X', 'item_name': 'X', 'rate': 5});
      notifier.updateCartItemQuantity(0, 0);
      expect(notifier.state.cartItems, isEmpty);
    });

    test('updateCartItemQuantity with negative removes item', () {
      notifier.addToCart({'name': 'X', 'item_name': 'X', 'rate': 5});
      notifier.updateCartItemQuantity(0, -1);
      expect(notifier.state.cartItems, isEmpty);
    });

    test('removeFromCart removes the item at index', () {
      notifier.addToCart({'name': 'A', 'item_name': 'A', 'rate': 1});
      notifier.addToCart({'name': 'B', 'item_name': 'B', 'rate': 2});
      notifier.removeFromCart(0);
      expect(notifier.state.cartItems, hasLength(1));
      expect(notifier.state.cartItems.first['item_code'], 'B');
    });

    test('clearCart empties the cart', () {
      notifier.addToCart({'name': 'A', 'item_name': 'A', 'rate': 1});
      notifier.addToCart({'name': 'B', 'item_name': 'B', 'rate': 2});
      notifier.clearCart();
      expect(notifier.state.cartItems, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PosNotifier – customer & delivery
  // ──────────────────────────────────────────────────────────────────────────
  group('PosNotifier customer & delivery', () {
    late PosNotifier notifier;

    setUp(() {
      notifier = PosNotifier(_FakePosRepository(), _FakeDraftCartRepository());
    });

    test('selectCustomer sets customer on state', () {
      notifier.selectCustomer({'name': 'CUST-1', 'delivery_income': 10});
      expect(notifier.state.selectedCustomer, isNotNull);
      expect(notifier.state.selectedCustomer!['name'], 'CUST-1');
    });

    test('unselectCustomer clears customer', () {
      notifier.selectCustomer({'name': 'CUST-1', 'delivery_income': 10});
      notifier.unselectCustomer();
      expect(notifier.state.selectedCustomer, isNull);
    });

    test('setDeliverySlot updates selected slot', () {
      final slot = _makeSlot();
      notifier.setDeliverySlot(slot);
      expect(notifier.state.selectedDeliverySlot, slot);
    });

    test('setDeliverySlot with null preserves existing slot (use clearSelectedDeliverySlot)', () {
      notifier.setDeliverySlot(_makeSlot());
      notifier.setDeliverySlot(null);
      // copyWith treats null param as "keep original" — use setPickup or clearSelectedDeliverySlot
      expect(notifier.state.selectedDeliverySlot, isNotNull);
    });

    test('setPickup toggles flag and clears selected delivery slot', () {
      final slot = _makeSlot();
      notifier.state = notifier.state.copyWith(
        selectedDeliverySlot: slot,
        deliverySlots: [slot],
      );

      notifier.setPickup(true);
      expect(notifier.state.isPickup, isTrue);
      expect(notifier.state.selectedDeliverySlot, isNull);

      notifier.setPickup(false);
      expect(notifier.state.isPickup, isFalse);
    });

    test('setSalesPartner sets and clears partner', () {
      notifier.setSalesPartner({'name': 'SP-1'});
      expect(notifier.state.selectedSalesPartner, isNotNull);

      notifier.setSalesPartner(null);
      expect(notifier.state.selectedSalesPartner, isNull);
    });
  });

  group('PosNotifier amendment flow', () {
    late _FakePosRepository repository;
    late PosNotifier notifier;

    setUp(() {
      repository = _FakePosRepository();
      notifier = PosNotifier(repository, _FakeDraftCartRepository());
      repository.profilesResult = const [
        {'name': 'Main POS'},
      ];
      repository.bundlesResult = [
        {
          'id': 'BDL-1',
          'name': 'Meal Deal',
          'price': 120.0,
          'item_groups': [
            {
              'group_name': 'Main',
              'group_key': 'main',
              'quantity': 1,
              'items': [
                {'id': 'ITEM-BURGER', 'name': 'Burger', 'item_name': 'Burger'},
              ],
            },
            {
              'group_name': 'Side',
              'group_key': 'side',
              'quantity': 1,
              'items': [
                {'id': 'ITEM-FRIES', 'name': 'Fries', 'item_name': 'Fries'},
              ],
            },
          ],
        },
      ];
    });

    test('startAmendmentDraft rebuilds bundle cart items from invoice rows', () async {
      await notifier.startAmendmentDraft({
        'name': 'INV-AMD-10',
        'pos_profile': 'Main POS',
        'items': [
          {
            'item_code': 'BUNDLE-PARENT',
            'item_name': 'Meal Deal',
            'qty': 2,
            'rate': 0,
            'amount': 0,
            'price_list_rate': 120,
            'is_bundle_parent': 1,
            'bundle_code': 'BDL-1',
          },
          {
            'item_code': 'ITEM-BURGER',
            'item_name': 'Burger',
            'qty': 2,
            'rate': 60,
            'amount': 120,
            'is_bundle_child': 1,
            'parent_bundle': 'BDL-1',
          },
          {
            'item_code': 'ITEM-FRIES',
            'item_name': 'Fries',
            'qty': 2,
            'rate': 0,
            'amount': 0,
            'is_bundle_child': 1,
            'parent_bundle': 'BDL-1',
          },
        ],
      });

      expect(notifier.state.cartItems, hasLength(1));
      final bundleItem = notifier.state.cartItems.first;
      expect(bundleItem['type'], 'bundle');
      expect(bundleItem['quantity'], 2);
      expect(bundleItem['rate'], 120.0);
      expect(bundleItem['bundle_details']['bundle_id'], 'BDL-1');
      expect(bundleItem['bundle_details']['selected_items']['main'].first['id'], 'ITEM-BURGER');
      expect(bundleItem['bundle_details']['selected_items']['side'].first['id'], 'ITEM-FRIES');
    });

    test('bundle rate uses catalog price when price_list_rate is zero', () async {
      // Production shape: parent item has price_list_rate=0 and rate=0;
      // the bundle price must come from bundleInfo['price'] = 120.
      await notifier.startAmendmentDraft({
        'name': 'INV-AMD-11',
        'pos_profile': 'Main POS',
        'items': [
          {
            'item_code': 'BUNDLE-PARENT',
            'item_name': 'Meal Deal',
            'qty': 1,
            'rate': 0,
            'amount': 0,
            'price_list_rate': 0, // ← production reality: parent item standalone rate
            'is_bundle_parent': 1,
            'bundle_code': 'BDL-1',
          },
          {
            'item_code': 'ITEM-BURGER',
            'item_name': 'Burger',
            'qty': 1,
            'rate': 70,
            'is_bundle_child': 1,
            'parent_bundle': 'BDL-1',
          },
          {
            'item_code': 'ITEM-FRIES',
            'item_name': 'Fries',
            'qty': 1,
            'rate': 50,
            'is_bundle_child': 1,
            'parent_bundle': 'BDL-1',
          },
        ],
      });

      expect(notifier.state.cartItems, hasLength(1));
      final bundleItem = notifier.state.cartItems.first;
      expect(bundleItem['type'], 'bundle');
      // Must be 120.0 from the catalog, not 0.0 from price_list_rate.
      expect(bundleItem['rate'], 120.0);
    });

    test('bundle catalog miss emits sentinel and checkout blocks submission', () async {
      // No matching bundle in the catalog → should produce a catalog-miss
      // sentinel, not a silent zero-priced regular item.
      repository.bundlesResult = []; // empty catalog

      await notifier.startAmendmentDraft({
        'name': 'INV-AMD-12',
        'pos_profile': 'Main POS',
        'items': [
          {
            'item_code': 'BUNDLE-PARENT',
            'item_name': 'Meal Deal',
            'qty': 1,
            'rate': 0,
            'price_list_rate': 0,
            'is_bundle_parent': 1,
            'bundle_code': 'BDL-1',
          },
          {
            'item_code': 'ITEM-BURGER',
            'item_name': 'Burger',
            'qty': 1,
            'rate': 70,
            'is_bundle_child': 1,
            'parent_bundle': 'BDL-1',
          },
        ],
      });

      // Cart should have one sentinel item (not empty, not a child item).
      expect(notifier.state.cartItems, hasLength(1));
      final sentinel = notifier.state.cartItems.first;
      expect(sentinel['type'], 'bundle');
      expect(sentinel['_bundle_catalog_miss'], true);
      expect(sentinel['rate'], 0.0);

      // Attempting checkout must be blocked with an error.
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': 'Main POS'},
        isAmendmentDraft: true,
        amendmentSourceInvoiceId: 'INV-AMD-12',
      );
      await notifier.checkout();

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('could not be priced'));
      expect(repository.submitInvoiceAmendmentCalls, 0);
    });

    test('free-shipping invoice sets delivery_income to zero in customer map', () async {
      await notifier.startAmendmentDraft({
        'name': 'INV-AMD-13',
        'pos_profile': 'Main POS',
        'customer': 'CUST-001',
        'customer_name': 'Test Customer',
        'territory': 'Cairo',
        'shipping_income': 25.0, // territory default — should be ignored
        'shipping_expense': 10.0,
        'was_free_shipping': true, // backend signals this invoice was free-shipped
        'items': [],
      });

      final customer = notifier.state.selectedCustomer;
      expect(customer, isNotNull);
      expect(customer!['delivery_income'], 0.0);
      expect(customer['was_free_shipping'], true);
    });

    test('checkout uses amendment endpoint when amendment draft is active', () async {
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': 'Main POS'},
        cartItems: const [
          {'item_code': 'ITEM-001', 'item_name': 'Item 1', 'rate': 10.0, 'quantity': 1, 'type': 'item'},
        ],
        isPickup: true,
        isAmendmentDraft: true,
        amendmentSourceInvoiceId: 'INV-ORIG-001',
      );

      await notifier.checkout();

      expect(repository.submitInvoiceAmendmentCalls, 1);
      expect(repository.createInvoiceCalls, 0);
      expect(repository.lastAmendmentSourceInvoiceId, 'INV-ORIG-001');
      expect(notifier.state.isAmendmentDraft, isFalse);
      expect(notifier.state.amendmentSourceInvoiceId, isNull);
    });
  });
}
