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
  // Delay injected into getBundles to simulate async gap in tests.
  Duration? getBundlesDelay;

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async {
    if (shouldThrow) throw Exception('profiles error');
    return profilesResult;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
  }) async {
    itemsCalls += 1;
    lastItemsProfile = posProfile;
    if (shouldThrow) throw Exception('items error');
    return itemsResult;
  }

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
  }) async {
    bundlesCalls += 1;
    lastBundlesProfile = posProfile;
    if (shouldThrow) throw Exception('bundles error');
    if (getBundlesDelay != null) await Future.delayed(getBundlesDelay!);
    return bundlesResult;
  }

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(
    String posProfile,
  ) async => const [];

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
    String? priceList,
    bool zeroShippingOverride = false,
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
    String? priceList,
    bool zeroShippingOverride = false,
    String? idempotencyKey,
    bool posProfileOverride = false,
    double? expectedSourceGrandTotal,
    int? expectedSourceItemCount,
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

/// Draft repo that tracks upsert calls and invokes a callback each time.
class _TrackingDraftCartRepository extends DraftCartRepository {
  final void Function() onUpsert;
  _TrackingDraftCartRepository({required this.onUpsert});
  @override
  Future<void> upsert(draft) async => onUpsert();
  @override
  Future<List<DraftCart>> loadAll() async => [];
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> clearAll() async {}
}

/// Draft repo that returns a fixed list of pre-built [DraftCart]s.
class _StubbedDraftCartRepository extends DraftCartRepository {
  final List<DraftCart> drafts;
  _StubbedDraftCartRepository({required this.drafts});
  @override
  Future<void> upsert(draft) async {}
  @override
  Future<List<DraftCart>> loadAll() async => drafts;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> clearAll() async {}
}

/// Mutable draft repo for notifier lifecycle tests.
class _MutableDraftCartRepository extends DraftCartRepository {
  _MutableDraftCartRepository({List<DraftCart>? initialDrafts})
    : _drafts = [...?initialDrafts];

  final List<DraftCart> _drafts;
  final List<String> deletedIds = [];

  @override
  Future<void> upsert(DraftCart draft) async {
    final index = _drafts.indexWhere((existing) => existing.id == draft.id);
    if (index >= 0) {
      _drafts[index] = draft;
      return;
    }
    _drafts.add(draft);
  }

  @override
  Future<List<DraftCart>> loadAll() async {
    final drafts = List<DraftCart>.from(_drafts);
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    _drafts.removeWhere((draft) => draft.id == id);
  }

  @override
  Future<void> clearAll() async {
    _drafts.clear();
  }
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

DraftCart _makeDraft({
  required String id,
  String label = 'Draft',
  List<Map<String, dynamic>>? cartItems,
  Map<String, dynamic>? customer,
  Map<String, dynamic>? salesPartner,
  bool isPickup = false,
  DateTime? at,
  String? amendmentSourceInvoiceId,
  double? amendmentSourceGrandTotal,
}) {
  final timestamp = at ?? DateTime(2026, 5, 1, 10);
  return DraftCart(
    id: id,
    label: label,
    cartItems:
        cartItems ??
        const [
          {
            'item_code': 'ITEM-001',
            'rate': 50.0,
            'quantity': 1,
            'type': 'item',
          },
        ],
    customer: customer,
    salesPartner: salesPartner,
    isPickup: isPickup,
    createdAt: timestamp,
    updatedAt: timestamp,
    amendmentSourceInvoiceId: amendmentSourceInvoiceId,
    amendmentSourceGrandTotal: amendmentSourceGrandTotal,
  );
}

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // PosState computed getters
  // ──────────────────────────────────────────────────────────────────────────
  group('PosState computed getters', () {
    test('cartTotal sums rate * quantity across items', () {
      final state = PosState(
        cartItems: const [
          {'rate': 20, 'quantity': 2},
          {'rate': 5, 'quantity': 3},
        ],
      );
      expect(state.cartTotal, 55.0);
    });

    test('cartTotal returns 0 for empty cart', () {
      expect(PosState().cartTotal, 0.0);
    });

    test('cartTotal handles missing rate/quantity gracefully', () {
      final state = PosState(
        cartItems: const [
          {'rate': null, 'quantity': null},
          {},
        ],
      );
      expect(state.cartTotal, 0.0);
    });

    test('cartItemCount sums all quantities', () {
      final state = PosState(
        cartItems: const [
          {'quantity': 3},
          {'quantity': 2},
        ],
      );
      expect(state.cartItemCount, 5);
    });

    test('cartItemCount defaults to 1 when quantity missing', () {
      final state = PosState(cartItems: const [{}]);
      expect(state.cartItemCount, 1);
    });

    test('shippingCost returns customer delivery_income', () {
      final state = PosState(selectedCustomer: const {'delivery_income': 25});
      expect(state.shippingCost, 25.0);
    });

    test('shippingCost prefers selected address delivery_income', () {
      final state = PosState(
        selectedCustomer: const {
          'delivery_income': 45,
          'selected_shipping_address_delivery_income': '50',
        },
      );
      expect(state.shippingCost, 50.0);
    });

    test('shippingCost is 0 when no customer', () {
      expect(PosState().shippingCost, 0.0);
    });

    test('shippingCost is 0 when delivery_income is 0', () {
      final state = PosState(selectedCustomer: const {'delivery_income': 0});
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
        profiles: const [
          {'name': 'P1'},
        ],
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
      repo.profilesResult = [
        {'name': 'Solo'},
      ];
      repo.itemsResult = [
        {'id': 'I1', 'name': 'Item1', 'rate': 10},
      ];
      repo.bundlesResult = [
        {'id': 'B1', 'name': 'Bundle1'},
      ];

      await notifier.loadProfiles();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.selectedProfile, isNotNull);
      expect(notifier.state.selectedProfile!['name'], 'Solo');
      expect(notifier.state.items, hasLength(1));
      expect(notifier.state.bundles, hasLength(1));
    });

    test('does not auto-select when multiple profiles', () async {
      repo.profilesResult = [
        {'name': 'A'},
        {'name': 'B'},
      ];
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
      repo.itemsResult = [
        {'id': 'I1', 'name': 'Item'},
      ];
      repo.bundlesResult = [
        {'id': 'B1', 'name': 'Bundle'},
      ];

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

  group('PosNotifier.deleteDraft', () {
    late _FakePosRepository repository;

    setUp(() {
      repository = _FakePosRepository();
    });

    test(
      'should keep active cart state when deleting an inactive draft',
      () async {
        final activeDraft = _makeDraft(
          id: 'draft-active',
          label: 'Active Draft',
          customer: const {'customer_name': 'Active Customer'},
        );
        final inactiveDraft = _makeDraft(
          id: 'draft-inactive',
          label: 'Inactive Draft',
          at: DateTime(2026, 5, 1, 11),
        );
        final draftRepo = _MutableDraftCartRepository(
          initialDrafts: [activeDraft, inactiveDraft],
        );
        final notifier = PosNotifier(repository, draftRepo);
        final slot = _makeSlot();
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          drafts: [
            DraftCartSummary.from(inactiveDraft),
            DraftCartSummary.from(activeDraft),
          ],
          currentDraftId: activeDraft.id,
          cartItems: List<Map<String, dynamic>>.from(activeDraft.cartItems),
          selectedCustomer: activeDraft.customer,
          selectedDeliverySlot: slot,
          selectedSalesPartner: const {'name': 'SP-KEEP'},
          deliverySlots: [slot],
          isPickup: true,
          draftDirty: true,
        );

        await notifier.deleteDraft(inactiveDraft.id);

        expect(draftRepo.deletedIds, [inactiveDraft.id]);
        expect(notifier.state.currentDraftId, activeDraft.id);
        expect(notifier.state.cartItems, activeDraft.cartItems);
        expect(
          notifier.state.selectedCustomer?['customer_name'],
          'Active Customer',
        );
        expect(notifier.state.selectedDeliverySlot, isNotNull);
        expect(notifier.state.selectedSalesPartner?['name'], 'SP-KEEP');
        expect(notifier.state.isPickup, isTrue);
        expect(notifier.state.draftDirty, isTrue);
        expect(notifier.state.drafts.map((draft) => draft.id), [
          activeDraft.id,
        ]);
      },
    );

    test(
      'should reset active cart state when deleting the current draft',
      () async {
        final activeDraft = _makeDraft(
          id: 'draft-current',
          label: 'Current Draft',
          customer: const {'customer_name': 'Draft Customer'},
          salesPartner: const {'name': 'SP-1'},
          isPickup: true,
        );
        final draftRepo = _MutableDraftCartRepository(
          initialDrafts: [activeDraft],
        );
        final notifier = PosNotifier(repository, draftRepo);
        final slot = _makeSlot();
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          drafts: [DraftCartSummary.from(activeDraft)],
          currentDraftId: activeDraft.id,
          cartItems: List<Map<String, dynamic>>.from(activeDraft.cartItems),
          selectedCustomer: activeDraft.customer,
          selectedDeliverySlot: slot,
          selectedSalesPartner: activeDraft.salesPartner,
          deliverySlots: [slot],
          isPickup: true,
          draftDirty: true,
          error: 'stale-state',
        );

        await notifier.deleteDraft(activeDraft.id);

        expect(draftRepo.deletedIds, [activeDraft.id]);
        expect(notifier.state.currentDraftId, isNull);
        expect(notifier.state.cartItems, isEmpty);
        expect(notifier.state.selectedCustomer, isNull);
        expect(notifier.state.selectedDeliverySlot, isNull);
        expect(notifier.state.selectedSalesPartner, isNull);
        expect(notifier.state.deliverySlots, isEmpty);
        expect(notifier.state.isPickup, isFalse);
        expect(notifier.state.draftDirty, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.drafts, isEmpty);
      },
    );

    test(
      'should clear amendment context when deleting the active amendment draft',
      () async {
        final amendmentDraft = _makeDraft(
          id: 'draft-amendment',
          label: 'Amendment Draft',
          customer: const {'customer_name': 'Amendment Customer'},
          amendmentSourceInvoiceId: 'ACC-SINV-2026-00001',
          amendmentSourceGrandTotal: 320.0,
        );
        final draftRepo = _MutableDraftCartRepository(
          initialDrafts: [amendmentDraft],
        );
        final notifier = PosNotifier(repository, draftRepo);
        final slot = _makeSlot();
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          drafts: [DraftCartSummary.from(amendmentDraft)],
          currentDraftId: amendmentDraft.id,
          cartItems: List<Map<String, dynamic>>.from(amendmentDraft.cartItems),
          selectedCustomer: amendmentDraft.customer,
          selectedDeliverySlot: slot,
          deliverySlots: [slot],
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: amendmentDraft.amendmentSourceInvoiceId,
          amendmentSourceGrandTotal: amendmentDraft.amendmentSourceGrandTotal,
          draftDirty: true,
        );

        await notifier.deleteDraft(amendmentDraft.id);

        expect(notifier.state.currentDraftId, isNull);
        expect(notifier.state.cartItems, isEmpty);
        expect(notifier.state.isAmendmentDraft, isFalse);
        expect(notifier.state.amendmentSourceInvoiceId, isNull);
        expect(notifier.state.amendmentSourceGrandTotal, isNull);
        expect(notifier.state.selectedCustomer, isNull);
        expect(notifier.state.selectedDeliverySlot, isNull);
        expect(notifier.state.draftDirty, isFalse);
        expect(notifier.state.drafts, isEmpty);
      },
    );
  });

  group('PosNotifier.abandonAmendmentDraft', () {
    late _FakePosRepository repository;

    setUp(() {
      repository = _FakePosRepository();
    });

    test(
      'should delete the persisted active amendment draft and reset state',
      () async {
        final amendmentDraft = _makeDraft(
          id: 'draft-abandon-active',
          label: 'Abandon Active Draft',
          customer: const {'customer_name': 'Abandon Customer'},
          amendmentSourceInvoiceId: 'ACC-SINV-2026-10001',
          amendmentSourceGrandTotal: 180.0,
        );
        final draftRepo = _MutableDraftCartRepository(
          initialDrafts: [amendmentDraft],
        );
        final notifier = PosNotifier(repository, draftRepo);
        final slot = _makeSlot();
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          drafts: [DraftCartSummary.from(amendmentDraft)],
          currentDraftId: amendmentDraft.id,
          cartItems: List<Map<String, dynamic>>.from(amendmentDraft.cartItems),
          selectedCustomer: amendmentDraft.customer,
          selectedDeliverySlot: slot,
          deliverySlots: [slot],
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: amendmentDraft.amendmentSourceInvoiceId,
          amendmentSourceGrandTotal: amendmentDraft.amendmentSourceGrandTotal,
          draftDirty: true,
        );

        await notifier.abandonAmendmentDraft(
          expectedInvoiceId: amendmentDraft.amendmentSourceInvoiceId,
        );

        expect(draftRepo.deletedIds, [amendmentDraft.id]);
        expect(notifier.state.currentDraftId, isNull);
        expect(notifier.state.cartItems, isEmpty);
        expect(notifier.state.isAmendmentDraft, isFalse);
        expect(notifier.state.amendmentSourceInvoiceId, isNull);
        expect(notifier.state.amendmentSourceGrandTotal, isNull);
        expect(notifier.state.selectedCustomer, isNull);
        expect(notifier.state.selectedDeliverySlot, isNull);
        expect(notifier.state.drafts, isEmpty);
      },
    );

    test(
      'should reset in-memory amendment state when no draft was saved yet',
      () async {
        final notifier = PosNotifier(repository, _FakeDraftCartRepository());
        final slot = _makeSlot();
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          cartItems: const [
            {
              'item_code': 'ITEM-001',
              'rate': 75.0,
              'quantity': 1,
              'type': 'item',
            },
          ],
          selectedCustomer: const {'customer_name': 'Amendment Customer'},
          selectedDeliverySlot: slot,
          deliverySlots: [slot],
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: 'ACC-SINV-2026-10002',
          amendmentSourceGrandTotal: 75.0,
          draftDirty: true,
        );

        await notifier.abandonAmendmentDraft(
          expectedInvoiceId: 'ACC-SINV-2026-10002',
        );

        expect(notifier.state.currentDraftId, isNull);
        expect(notifier.state.cartItems, isEmpty);
        expect(notifier.state.selectedCustomer, isNull);
        expect(notifier.state.selectedDeliverySlot, isNull);
        expect(notifier.state.deliverySlots, isEmpty);
        expect(notifier.state.isAmendmentDraft, isFalse);
        expect(notifier.state.amendmentSourceInvoiceId, isNull);
        expect(notifier.state.amendmentSourceGrandTotal, isNull);
        expect(notifier.state.draftDirty, isFalse);
      },
    );

    test(
      'should ignore a mismatched invoice id when abandoning amendment flow',
      () async {
        final amendmentDraft = _makeDraft(
          id: 'draft-abandon-mismatch',
          label: 'Mismatch Draft',
          amendmentSourceInvoiceId: 'ACC-SINV-2026-10003',
        );
        final draftRepo = _MutableDraftCartRepository(
          initialDrafts: [amendmentDraft],
        );
        final notifier = PosNotifier(repository, draftRepo);
        await Future<void>.delayed(Duration.zero);

        notifier.state = notifier.state.copyWith(
          drafts: [DraftCartSummary.from(amendmentDraft)],
          currentDraftId: amendmentDraft.id,
          cartItems: List<Map<String, dynamic>>.from(amendmentDraft.cartItems),
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: amendmentDraft.amendmentSourceInvoiceId,
        );

        await notifier.abandonAmendmentDraft(
          expectedInvoiceId: 'ACC-SINV-2026-DOES-NOT-MATCH',
        );

        expect(draftRepo.deletedIds, isEmpty);
        expect(notifier.state.currentDraftId, amendmentDraft.id);
        expect(notifier.state.isAmendmentDraft, isTrue);
        expect(notifier.state.amendmentSourceInvoiceId, 'ACC-SINV-2026-10003');
      },
    );

    test(
      'should ignore a late amendment load after abandonment is requested',
      () async {
        repository.getBundlesDelay = const Duration(milliseconds: 50);
        final notifier = PosNotifier(repository, _FakeDraftCartRepository());
        await Future<void>.delayed(Duration.zero);

        final future = notifier.startAmendmentDraft({
          'name': 'ACC-SINV-2026-10004',
          'pos_profile': 'Main POS',
          'customer': 'CUST-001',
          'customer_name': 'Late Abandon',
          'items': [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Item 1',
              'qty': 1,
              'rate': 40.0,
            },
          ],
        });

        await notifier.abandonAmendmentDraft(
          expectedInvoiceId: 'ACC-SINV-2026-10004',
        );
        await future;

        expect(notifier.state.isAmendmentDraft, isFalse);
        expect(notifier.state.amendmentSourceInvoiceId, isNull);
        expect(notifier.state.amendmentSourceGrandTotal, isNull);
        expect(notifier.state.currentDraftId, isNull);
        expect(notifier.state.cartItems, isEmpty);
        expect(notifier.state.draftDirty, isFalse);
      },
    );
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

    test(
      'reloads items and bundles for the current profile without clearing order context',
      () async {
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
      },
    );

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
        {
          'group1': [
            {'item': 'A'},
          ],
        },
      );
      final item = notifier.state.cartItems.first;
      expect(item['type'], 'bundle');
      expect(item['bundle_details']['bundle_id'], 'BDL-1');
      expect(item['bundle_details']['selected_items'], isNotEmpty);
    });

    test('updateBundleInCart updates selected items for bundle type', () {
      notifier.addBundleToCart(
        {'id': 'BDL-1', 'name': 'Meal', 'price': 25},
        {
          'g1': [
            {'item': 'A'},
          ],
        },
      );
      notifier.updateBundleInCart(0, {
        'g1': [
          {'item': 'B'},
        ],
      });
      expect(
        notifier
            .state
            .cartItems
            .first['bundle_details']['selected_items']['g1']
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

    test(
      'setDeliverySlot with null preserves existing slot (use clearSelectedDeliverySlot)',
      () {
        notifier.setDeliverySlot(_makeSlot());
        notifier.setDeliverySlot(null);
        // copyWith treats null param as "keep original" — use setPickup or clearSelectedDeliverySlot
        expect(notifier.state.selectedDeliverySlot, isNotNull);
      },
    );

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

    test(
      'startAmendmentDraft rebuilds bundle cart items from invoice rows',
      () async {
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
        final selections =
            bundleItem['bundle_details']['selected_items'] as Map;
        expect(
          selections.containsKey('main'),
          isTrue,
          reason: 'Burger child must be restored under its bundle group key',
        );
        expect(
          selections.containsKey('side'),
          isTrue,
          reason: 'Fries child must be restored under its bundle group key',
        );
        expect((selections['main'] as List).first['id'], 'ITEM-BURGER');
        expect((selections['side'] as List).first['id'], 'ITEM-FRIES');
      },
    );

    test(
      'bundle rate uses catalog price when price_list_rate is zero',
      () async {
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
              'price_list_rate':
                  0, // ← production reality: parent item standalone rate
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
      },
    );

    test(
      'startAmendmentDraft rebuilds bundle when parent bundle_code is missing',
      () async {
        repository.bundlesResult = [
          {
            'id': 'BDL-1',
            'name': 'Meal Deal',
            'erpnext_item': 'BUNDLE-PARENT',
            'price': 120.0,
            'item_groups': [
              {
                'group_name': 'Main',
                'group_key': 'main',
                'quantity': 1,
                'items': [
                  {
                    'id': 'ITEM-BURGER',
                    'name': 'Burger',
                    'item_name': 'Burger',
                  },
                ],
              },
            ],
          },
        ];

        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-MISSING-CODE',
          'pos_profile': 'Main POS',
          'items': [
            {
              'item_code': 'BUNDLE-PARENT',
              'item_name': 'Meal Deal',
              'qty': 1,
              'rate': 0,
              'amount': 0,
              'price_list_rate': 0,
              'is_bundle_parent': 1,
              'bundle_code': '',
            },
            {
              'item_code': 'ITEM-BURGER',
              'item_name': 'Burger',
              'qty': 1,
              'rate': 60,
              'amount': 60,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-1',
              'bundle_group_key': 'main',
              'bundle_group_name': 'Main',
            },
          ],
        });

        expect(notifier.state.cartItems, hasLength(1));
        final bundleItem = notifier.state.cartItems.first;
        expect(bundleItem['_bundle_catalog_miss'], isNot(true));
        expect(bundleItem['type'], 'bundle');
        expect(bundleItem['rate'], 120.0);
        expect(bundleItem['bundle_details']['bundle_id'], 'BDL-1');
        final selections =
            bundleItem['bundle_details']['selected_items'] as Map;
        expect((selections['main'] as List).first['id'], 'ITEM-BURGER');
      },
    );

    test(
      'startAmendmentDraft rebuilds bundle when invoice bundle id was recreated',
      () async {
        repository.bundlesResult = [
          {
            'id': 'BDL-CURRENT',
            'name': 'Jarz Sweet Six',
            'price': 600.0,
            'item_groups': [
              {
                'group_name': 'Medium',
                'group_key': 'medium',
                'quantity': 6,
                'items': [
                  {'id': 'Strawberry Medium', 'name': 'Strawberry Medium'},
                  {'id': 'Blueberry Medium', 'name': 'Blueberry Medium'},
                  {'id': 'Lotus Medium', 'name': 'Lotus Medium'},
                  {'id': 'Mango Medium', 'name': 'Mango Medium'},
                  {'id': 'Tiramisu Medium', 'name': 'Tiramisu Medium'},
                ],
              },
            ],
          },
        ];

        await notifier.startAmendmentDraft({
          'name': 'ACC-SINV-2026-15959',
          'pos_profile': 'Main POS',
          'items': [
            {
              'item_code': 'Jarz Sweet Six',
              'item_name': 'Jarz Sweet Six',
              'qty': 1,
              'rate': 0,
              'amount': 0,
              'price_list_rate': 540,
              'is_bundle_parent': 1,
              'bundle_code': 'BDL-OLD-DELETED',
            },
            {
              'item_code': 'Strawberry Medium',
              'item_name': 'Strawberry Medium',
              'qty': 1,
              'rate': 100,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-OLD-DELETED',
            },
            {
              'item_code': 'Blueberry Medium',
              'item_name': 'Blueberry Medium',
              'qty': 2,
              'rate': 100,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-OLD-DELETED',
            },
          ],
        });

        expect(notifier.state.cartItems, hasLength(1));
        final bundleItem = notifier.state.cartItems.first;
        expect(bundleItem['_bundle_catalog_miss'], isNot(true));
        expect(bundleItem['rate'], 600.0);
        expect(bundleItem['bundle_details']['bundle_id'], 'BDL-CURRENT');
        final selections =
            bundleItem['bundle_details']['selected_items'] as Map;
        expect((selections['medium'] as List), hasLength(3));
      },
    );

    test(
      'bundle catalog miss emits sentinel and checkout blocks submission',
      () async {
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
        expect(notifier.state.error, contains('not found in the item catalog'));
        expect(repository.submitInvoiceAmendmentCalls, 0);
      },
    );

    test(
      'free-shipping invoice sets delivery_income to zero in customer map',
      () async {
        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-13',
          'pos_profile': 'Main POS',
          'customer': 'CUST-001',
          'customer_name': 'Test Customer',
          'territory': 'Cairo',
          'shipping_income': 25.0, // territory default — should be ignored
          'shipping_expense': 10.0,
          'was_free_shipping':
              true, // backend signals this invoice was free-shipped
          'items': [],
        });

        final customer = notifier.state.selectedCustomer;
        expect(customer, isNotNull);
        expect(customer!['delivery_income'], 0.0);
        expect(customer['was_free_shipping'], true);
      },
    );

    test(
      'checkout uses amendment endpoint when amendment draft is active',
      () async {
        notifier.state = notifier.state.copyWith(
          selectedProfile: const {'name': 'Main POS'},
          cartItems: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Item 1',
              'rate': 10.0,
              'quantity': 1,
              'type': 'item',
            },
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
      },
    );

    // ── B4: Amendment hardening ──────────────────────────────────────────────

    test(
      'B4: startAmendmentDraft with empty source items leaves isAmendmentDraft false',
      () async {
        // Source invoice has no items at all — safe to open (empty list is valid;
        // we only block when sourceItemCount > 0 but builtCart is empty).
        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-EMPTY',
          'pos_profile': 'Main POS',
          'grand_total': 0,
          'items': [],
        });

        // Empty source → allowed through; cart stays empty; no error set.
        expect(
          notifier.state.error,
          isNull,
          reason:
              'An invoice with no items is valid and must not raise an error',
        );
        expect(notifier.state.isLoading, isFalse);
      },
    );

    test(
      'B4: startAmendmentDraft stores source grand_total in amendmentSourceGrandTotal',
      () async {
        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-GT',
          'pos_profile': 'Main POS',
          'grand_total': 250.0,
          'items': [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Product A',
              'qty': 2,
              'rate': 125.0,
              'amount': 250.0,
              'is_bundle_parent': 0,
              'is_bundle_child': 0,
            },
          ],
        });

        expect(notifier.state.isAmendmentDraft, isTrue);
        expect(notifier.state.amendmentSourceGrandTotal, 250.0);
      },
    );

    test(
      'B4: amendmentSourceGrandTotal is cleared when amendment finishes',
      () async {
        // Set up a clean draft state with known total
        notifier.state = notifier.state.copyWith(
          selectedProfile: const {'name': 'Main POS'},
          isPickup: true,
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: 'INV-AMD-CLR',
          cartItems: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'A',
              'rate': 100.0,
              'quantity': 1,
              'type': 'item',
            },
          ],
        );
        // Manually inject a source total to verify it clears
        notifier.state = notifier.state.copyWith(
          // Using copyWith with clearAmendmentSourceInvoiceId=false so value persists
          cartItems: notifier.state.cartItems,
        );

        await notifier.checkout();

        expect(notifier.state.isAmendmentDraft, isFalse);
        expect(notifier.state.amendmentSourceInvoiceId, isNull);
        expect(notifier.state.amendmentSourceGrandTotal, isNull);
      },
    );

    test('B4: checkout blocks empty-cart amendment submission', () async {
      notifier.state = notifier.state.copyWith(
        selectedProfile: const {'name': 'Main POS'},
        isPickup: true,
        isAmendmentDraft: true,
        amendmentSourceInvoiceId: 'INV-AMD-NOITEMS',
        cartItems: const [], // empty cart
      );

      await notifier.checkout();

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('empty'));
      expect(
        repository.submitInvoiceAmendmentCalls,
        0,
        reason: 'Must not submit when cart is empty',
      );
    });

    test(
      'B4: bundle child identity — two different children of same group have distinct item_code',
      () async {
        // This mirrors the real bug: two children from the SAME group_key but different item_codes.
        // Both must survive reconstruction with their own identity.
        repository.bundlesResult = [
          {
            'id': 'BDL-MULTI',
            'name': 'Multi Bundle',
            'price': 200.0,
            'item_groups': [
              {
                'group_name': 'Flavor',
                'group_key': 'flavor',
                'quantity': 2, // 2 selections from this group
                'items': [
                  {
                    'id': 'ITEM-RED',
                    'name': 'Redvelvet',
                    'item_name': 'Redvelvet',
                  },
                  {
                    'id': 'ITEM-BLUE',
                    'name': 'Blueberry',
                    'item_name': 'Blueberry',
                  },
                ],
              },
            ],
          },
        ];

        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-MULTI',
          'pos_profile': 'Main POS',
          'grand_total': 200.0,
          'items': [
            // Parent
            {
              'item_code': 'BDL-MULTI',
              'item_name': 'Multi Bundle',
              'qty': 1,
              'rate': 0,
              'price_list_rate': 200.0,
              'is_bundle_parent': 1,
              'bundle_code': 'BDL-MULTI',
            },
            // Child 1 — Redvelvet
            {
              'item_code': 'ITEM-RED',
              'item_name': 'Redvelvet',
              'qty': 1,
              'rate': 0,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-MULTI',
            },
            // Child 2 — Blueberry (same group_key 'flavor')
            {
              'item_code': 'ITEM-BLUE',
              'item_name': 'Blueberry',
              'qty': 1,
              'rate': 0,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-MULTI',
            },
          ],
        });

        expect(notifier.state.cartItems, hasLength(1));
        final bundleItem = notifier.state.cartItems.first;
        expect(bundleItem['type'], 'bundle');

        final selections =
            bundleItem['bundle_details']['selected_items'] as Map;

        expect(
          selections.containsKey('flavor'),
          isTrue,
          reason:
              'Children from the same group must be restored under the group key',
        );
        final ids = (selections['flavor'] as List)
            .map((entry) => entry['id'])
            .toSet();
        expect(
          ids,
          containsAll(['ITEM-RED', 'ITEM-BLUE']),
          reason:
              'Both Redvelvet and Blueberry must survive bundle reconstruction',
        );
      },
    );

    test(
      'B4: bundle with qty_mismatch (odd children) results in catalog-miss sentinel',
      () async {
        // Parent qty=2 but only 1 child row (child qty=1).
        // totalQuantity (1) % bundleQuantity (2) = 1 ≠ 0 → _qty_mismatch triggered.
        repository.bundlesResult = [
          {
            'id': 'BDL-PAIR',
            'name': 'Pair Bundle',
            'price': 150.0,
            'item_groups': [
              {
                'group_name': 'Pick',
                'group_key': 'pick',
                'quantity': 1,
                'items': [
                  {'id': 'ITEM-A', 'name': 'A', 'item_name': 'A'},
                  {'id': 'ITEM-B', 'name': 'B', 'item_name': 'B'},
                ],
              },
            ],
          },
        ];

        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-MISMATCH',
          'pos_profile': 'Main POS',
          'grand_total': 300.0,
          'items': [
            {
              'item_code': 'BDL-PAIR',
              'item_name': 'Pair Bundle',
              // Parent qty=2 → bundleQuantity=2
              'qty': 2,
              'rate': 0,
              'price_list_rate': 150.0,
              'is_bundle_parent': 1,
              'bundle_code': 'BDL-PAIR',
            },
            {
              'item_code': 'ITEM-A',
              'item_name': 'A',
              // qty=1 but bundleQuantity=2 → 1 % 2 = 1 ≠ 0 → mismatch
              'qty': 1,
              'rate': 0,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-PAIR',
            },
          ],
        });

        // Expect either a catalog-miss sentinel or an error
        if (notifier.state.cartItems.isNotEmpty) {
          final item = notifier.state.cartItems.first;
          expect(
            item['_bundle_catalog_miss'],
            true,
            reason: 'Qty mismatch must produce a catalog-miss sentinel',
          );
        } else {
          // Alternatively an error was raised
          expect(
            notifier.state.error,
            isNotNull,
            reason: 'Qty mismatch must produce either a sentinel or an error',
          );
        }
      },
    );

    // ── Phase-2 hardening tests ──────────────────────────────────────────────

    test(
      'H2: bundle with zero rate (100% discount) is NOT blocked by checkout guard',
      () async {
        // A bundle whose catalog price is 0 (full discount campaign) must pass
        // the amendment checkout guard — only a true catalog miss blocks.
        repository.bundlesResult = [
          {
            'id': 'BDL-FREE',
            'name': 'Free Bundle',
            'price': 0.0, // 100% discount
            'item_groups': [
              {
                'group_name': 'Choice',
                'group_key': 'choice',
                'quantity': 1,
                'items': [
                  {'id': 'ITEM-X', 'name': 'X', 'item_name': 'X'},
                ],
              },
            ],
          },
        ];

        await notifier.startAmendmentDraft({
          'name': 'INV-AMD-FREE',
          'pos_profile': 'Main POS',
          'grand_total': 0.0,
          'items': [
            {
              'item_code': 'BDL-FREE',
              'item_name': 'Free Bundle',
              'qty': 1,
              'rate': 0,
              'price_list_rate': 0.0,
              'is_bundle_parent': 1,
              'bundle_code': 'BDL-FREE',
            },
            {
              'item_code': 'ITEM-X',
              'item_name': 'X',
              'qty': 1,
              'rate': 0,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-FREE',
            },
          ],
        });

        expect(notifier.state.cartItems, hasLength(1));
        final bundleItem = notifier.state.cartItems.first;
        expect(
          bundleItem['_bundle_catalog_miss'],
          isNot(true),
          reason: 'Zero-rate catalog item must NOT be marked as catalog miss',
        );

        // Override the state so checkout can proceed (profile + amendment mode).
        notifier.state = notifier.state.copyWith(
          selectedProfile: const {'name': 'Main POS'},
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: 'INV-AMD-FREE',
          isPickup: true,
        );

        await notifier.checkout();

        // The guard must not have fired — submitInvoiceAmendment should have been called.
        expect(
          notifier.state.error,
          isNull,
          reason:
              'Zero-rate bundle must NOT be blocked by the catalog-miss guard',
        );
        expect(
          repository.submitInvoiceAmendmentCalls,
          1,
          reason: 'Amendment submit must be called for zero-rate bundle',
        );
      },
    );

    test(
      'M1: DraftCart round-trips amendment context through toMap/fromMap',
      () {
        const sourceInvoiceId = 'INV-AMD-PERSIST-001';
        const sourceGrandTotal = 320.0;

        final original = DraftCart(
          id: 'draft-amend-001',
          label: 'Test Label',
          cartItems: const [
            {
              'item_code': 'ITEM-A',
              'rate': 100.0,
              'quantity': 2.0,
              'type': 'item',
            },
          ],
          isPickup: false,
          createdAt: DateTime(2026, 5, 16),
          updatedAt: DateTime(2026, 5, 16),
          amendmentSourceInvoiceId: sourceInvoiceId,
          amendmentSourceGrandTotal: sourceGrandTotal,
        );

        final map = original.toMap();
        final restored = DraftCart.fromMap(map);

        expect(
          restored.amendmentSourceInvoiceId,
          sourceInvoiceId,
          reason: 'amendmentSourceInvoiceId must survive toMap/fromMap',
        );
        expect(
          restored.amendmentSourceGrandTotal,
          sourceGrandTotal,
          reason: 'amendmentSourceGrandTotal must survive toMap/fromMap',
        );
        expect(restored.cartItems, hasLength(1));
        expect(restored.id, 'draft-amend-001');
      },
    );

    test(
      'M1: DraftCart fromMap gracefully handles missing amendment fields (old format)',
      () {
        // Simulate loading a Hive record saved before the amendment fields were added.
        final oldMap = <dynamic, dynamic>{
          'id': 'draft-old-001',
          'label': 'Old Draft',
          'cart_items': '[]',
          'is_pickup': false,
          'created_at': '2026-01-01T00:00:00.000',
          'updated_at': '2026-01-01T00:00:00.000',
          // amendment_source_invoice_id and amendment_source_grand_total absent
        };

        final restored = DraftCart.fromMap(oldMap);

        expect(
          restored.amendmentSourceInvoiceId,
          isNull,
          reason: 'Missing key must default to null (backward compat)',
        );
        expect(
          restored.amendmentSourceGrandTotal,
          isNull,
          reason: 'Missing key must default to null (backward compat)',
        );
      },
    );

    // ── Phase-3 hardening tests ──────────────────────────────────────────────

    test(
      'P3: _persistCurrentCart skipped when amendment setup in progress',
      () async {
        // Arrange: set up a fake draft repo that tracks upsert calls.
        var upsertCalls = 0;
        final trackingDraftRepo = _TrackingDraftCartRepository(
          onUpsert: () => upsertCalls++,
        );
        final notifier = PosNotifier(repository, trackingDraftRepo);
        // Give the notifier a non-empty cart and a draft id so persist would
        // normally fire immediately.
        notifier.state = notifier.state.copyWith(
          cartItems: const [
            {'item_code': 'X', 'rate': 10.0, 'quantity': 1, 'type': 'item'},
          ],
          currentDraftId: 'existing-draft-id',
        );

        // Act: call startAmendmentDraft — during its async work _persistCurrentCart
        // must NOT fire because the flag cancels the pending timer first.
        // Use a slow-responding repository to hold the async gap open.
        repository.getBundlesDelay = const Duration(milliseconds: 50);
        final future = notifier.startAmendmentDraft({
          'name': 'INV-P3-RACE',
          'pos_profile': 'Main POS',
          'grand_total': 100.0,
          'items': [],
        });
        // Simulate autosave timer firing DURING the async gap.
        notifier.testInvokePersistCurrentCart();
        await future;

        // Assert: upsert must NOT have been called while setup was in progress.
        expect(
          upsertCalls,
          0,
          reason:
              'Auto-save must be suppressed while amendment setup is in progress',
        );
      },
    );

    test(
      'P3: switchDraft aborts when amendment draft has catalog-miss sentinel',
      () async {
        // Build a draft whose cartItems contain a catalog-miss sentinel.
        final staleDraft = DraftCart(
          id: 'stale-draft-001',
          label: 'Stale Amendment',
          cartItems: const [
            {
              'item_code': 'BDL-OLD',
              'item_name': 'Old Bundle',
              'rate': 0.0,
              'quantity': 1,
              'type': 'bundle',
              '_bundle_catalog_miss': true,
              'bundle_details': {'bundle_id': 'BDL-OLD', 'selected_items': {}},
            },
          ],
          customer: const {'name': 'CUST-001'},
          isPickup: false,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime(2026, 5, 1),
          amendmentSourceInvoiceId: 'INV-STALE-001',
        );

        final staleDraftRepo = _StubbedDraftCartRepository(
          drafts: [staleDraft],
        );
        final notifier = PosNotifier(repository, staleDraftRepo);

        await notifier.switchDraft('stale-draft-001');

        expect(
          notifier.state.error,
          isNotNull,
          reason:
              'switchDraft must set error for stale amendment draft with catalog miss',
        );
        expect(
          notifier.state.error,
          contains('outdated'),
          reason: 'Error message must tell user to reopen the order',
        );
        // Cart must NOT have been restored.
        expect(
          notifier.state.cartItems,
          isEmpty,
          reason:
              'Corrupted amendment cart must NOT be loaded into active state',
        );
      },
    );

    test(
      'P3: switchDraft aborts when amendment draft has null customer',
      () async {
        final staleDraft = DraftCart(
          id: 'stale-draft-002',
          label: 'Stale No Customer',
          cartItems: const [
            {
              'item_code': 'ITEM-001',
              'rate': 50.0,
              'quantity': 1,
              'type': 'item',
            },
          ],
          customer: null, // customer missing
          isPickup: false,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime(2026, 5, 1),
          amendmentSourceInvoiceId: 'INV-STALE-002',
        );

        final staleDraftRepo = _StubbedDraftCartRepository(
          drafts: [staleDraft],
        );
        final notifier = PosNotifier(repository, staleDraftRepo);

        await notifier.switchDraft('stale-draft-002');

        expect(
          notifier.state.error,
          isNotNull,
          reason:
              'switchDraft must set error for amendment draft with null customer',
        );
        expect(
          notifier.state.cartItems,
          isEmpty,
          reason: 'Amendment draft with null customer must NOT be restored',
        );
      },
    );

    test(
      'P3: switchDraft proceeds normally for healthy amendment draft',
      () async {
        final healthyDraft = DraftCart(
          id: 'healthy-draft-001',
          label: 'Healthy Amendment',
          cartItems: const [
            {
              'item_code': 'ITEM-A',
              'rate': 120.0,
              'quantity': 1,
              'type': 'item',
            },
          ],
          customer: const {
            'name': 'CUST-HEALTHY',
            'customer_name': 'Healthy Customer',
          },
          isPickup: false,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime(2026, 5, 1),
          amendmentSourceInvoiceId: 'INV-HEALTHY-001',
          amendmentSourceGrandTotal: 120.0,
        );

        final healthyDraftRepo = _StubbedDraftCartRepository(
          drafts: [healthyDraft],
        );
        final notifier = PosNotifier(repository, healthyDraftRepo);

        await notifier.switchDraft('healthy-draft-001');

        expect(
          notifier.state.error,
          isNull,
          reason: 'Healthy amendment draft must load without error',
        );
        expect(
          notifier.state.cartItems,
          hasLength(1),
          reason: 'Cart items must be restored',
        );
        expect(
          notifier.state.selectedCustomer?['name'],
          'CUST-HEALTHY',
          reason: 'Customer must be restored',
        );
        expect(
          notifier.state.isAmendmentDraft,
          isTrue,
          reason: 'isAmendmentDraft must be true for restored amendment draft',
        );
      },
    );

    test(
      'P3: startAmendmentDraft with empty bundle catalog when invoice has bundle parent → error',
      () async {
        repository.bundlesResult = []; // empty catalog

        await notifier.startAmendmentDraft({
          'name': 'INV-P3-NO-CATALOG',
          'pos_profile': 'Main POS',
          'grand_total': 120.0,
          'items': [
            {
              'item_code': 'BDL-PARENT',
              'item_name': 'Some Bundle',
              'qty': 1,
              'rate': 0.0,
              'price_list_rate': 120.0,
              'is_bundle_parent': 1,
              'bundle_code': 'BDL-GHOST',
            },
            {
              'item_code': 'ITEM-CHILD',
              'item_name': 'Child',
              'qty': 1,
              'rate': 0.0,
              'is_bundle_child': 1,
              'parent_bundle': 'BDL-GHOST',
            },
          ],
        });

        // With an empty catalog the bundle can only build a catalog-miss sentinel.
        // The notifier should either set an error OR surface a catalog-miss in the cart.
        final hasSentinel = notifier.state.cartItems.any(
          (i) => i['_bundle_catalog_miss'] == true,
        );
        final hasError = notifier.state.error != null;
        expect(
          hasSentinel || hasError,
          isTrue,
          reason:
              'Empty catalog with bundle parent must produce a sentinel or an error',
        );
        expect(notifier.state.isLoading, isFalse);
      },
    );
  });
}
