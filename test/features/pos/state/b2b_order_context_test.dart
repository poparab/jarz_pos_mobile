import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_models.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _MemoryDraftRepository extends DraftCartRepository {
  final List<DraftCart> saved = [];

  @override
  Future<void> upsert(DraftCart draft) async => saved.add(draft);

  @override
  Future<List<DraftCart>> loadAll() async => List.of(saved);
}

class _B2bPosRepository extends PosRepository {
  _B2bPosRepository() : super(Dio());

  final calls = <String>[];
  final delayedContexts = <String, Completer<B2bPricingContext>>{};
  final contextErrors = <String, Object>{};
  List<Map<String, dynamic>> profilesResult = const [
    {'name': 'Retail'},
    {'name': 'Nasr city'},
    {'name': 'Dokki'},
  ];
  int managerPriceListCalls = 0;
  int managerPolicyCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async => profilesResult;

  @override
  Future<B2bPricingContext> getB2bPricingContext({
    required String profile,
    required String customer,
    required String orderPurpose,
  }) async {
    calls.add('context:$profile:$customer:$orderPurpose');
    final error = contextErrors[profile];
    if (error != null) throw error;
    final delayed = delayedContexts[profile];
    if (delayed != null) return delayed.future;
    return contextFor(profile, customer, orderPurpose);
  }

  B2bPricingContext contextFor(
    String profile,
    String customer,
    String orderPurpose,
  ) {
    final priceList = '$profile $orderPurpose Price';
    return B2bPricingContext(
      profile: profile,
      customer: customer,
      orderPurpose: orderPurpose,
      commercialPolicy: CommercialPolicy(
        name: orderPurpose == 'Sample - Courier' ? 'POL-SAMPLE' : 'POL-B2B',
        policyName: orderPurpose,
        orderPurpose: orderPurpose,
        priceList: null,
        discountPercentage: orderPurpose == 'Sample - Courier' ? 100 : null,
        waivesShippingIncome: orderPurpose == 'Sample - Courier',
      ),
      priceList: {
        'name': priceList,
        'display_label': priceList,
        'currency': 'EGP',
        'is_default': true,
        'zero_shipping_default': false,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async {
    calls.add('items:$posProfile:$customer:$orderPurpose:$priceList');
    final rate = posProfile == 'Dokki' ? 80.0 : 100.0;
    return [
      {
        'name': 'COFFEE',
        'item_name': 'Coffee',
        'rate': rate,
        'price_list_rate': rate,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async {
    calls.add('bundles:$posProfile:$customer:$orderPurpose:$priceList');
    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(String posProfile) async {
    managerPriceListCalls++;
    return const [
      {'name': 'Retail Price', 'is_default': true},
    ];
  }

  @override
  Future<List<CommercialPolicy>> getCommercialPolicies(
    String posProfile,
  ) async {
    managerPolicyCalls++;
    return const [];
  }
}

Map<String, dynamic> _branchCustomer(String name, String profile) => {
  'name': name,
  'customer_name': name,
  'selected_shipping_address_name': '$name-$profile',
  'selected_shipping_address_territory_pos_profile': profile,
};

const _b2bSupplyPolicy = CommercialPolicy(
  name: 'POL-B2B',
  policyName: 'B2B Supply',
  orderPurpose: 'B2B Supply',
  priceList: 'B2B Price',
);

const _samplePolicy = CommercialPolicy(
  name: 'POL-SAMPLE',
  policyName: 'Sample',
  orderPurpose: 'Sample',
  priceList: 'Sample Price',
);

const _sampleCourierPolicy = CommercialPolicy(
  name: 'POL-SAMPLE',
  policyName: 'Sample order',
  orderPurpose: 'Sample - Courier',
  discountPercentage: 100,
  waivesShippingIncome: true,
);

void main() {
  test(
    'startB2bOrder saves current cart before opening clean B2B context',
    () async {
      final drafts = _MemoryDraftRepository();
      final notifier = PosNotifier(PosRepository(Dio()), drafts);
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        cartItems: const [
          {'item_code': 'OLD', 'quantity': 2, 'rate': 10},
        ],
        selectedCustomer: const {
          'name': 'OLD-CUSTOMER',
          'customer_name': 'Old Customer',
        },
        draftDirty: true,
      );

      await notifier.startB2bOrder(const {
        'name': 'ilo specialty coffee',
        'customer_name': 'ILO Specialty Coffee',
        'selected_shipping_address_name': 'ilo specialty coffee-16815-Shipping',
      });

      expect(drafts.saved, hasLength(1));
      expect(drafts.saved.single.customer?['name'], 'OLD-CUSTOMER');
      expect(drafts.saved.single.cartItems.single['item_code'], 'OLD');
      expect(notifier.state.cartItems, isEmpty);
      expect(notifier.state.isB2bOrder, isTrue);
      expect(notifier.state.selectedCustomer?['name'], 'ilo specialty coffee');
    },
  );

  test('missing B2B policy keeps checkout blocked', () async {
    final repository = _B2bPosRepository();
    repository.contextErrors['Nasr city'] = Exception('policy unavailable');
    final notifier = PosNotifier(repository, _MemoryDraftRepository());
    addTearDown(notifier.dispose);
    notifier.state = notifier.state.copyWith(
      profiles: await repository.getPosProfiles(),
    );
    await notifier.startB2bOrder(
      _branchCustomer('ilo specialty coffee', 'Nasr city'),
    );

    await expectLater(
      notifier.setCommercialPolicyByOrderPurpose('B2B Supply'),
      throwsException,
    );
    notifier.markB2bSetupComplete();
    notifier.addToCart(const {
      'name': 'COFFEE',
      'item_name': 'Coffee',
      'rate': 100,
    });
    await notifier.checkout();

    expect(notifier.state.b2bSetupComplete, isFalse);
    expect(notifier.state.error, contains('B2B order policy is not ready'));
    expect(notifier.state.cartItems, isNotEmpty);
  });

  test('completed B2B order cannot switch purpose or price list', () async {
    final notifier = PosNotifier(
      PosRepository(Dio()),
      _MemoryDraftRepository(),
    );
    addTearDown(notifier.dispose);
    notifier.state = notifier.state.copyWith(
      isB2bOrder: true,
      b2bSetupComplete: true,
      boundB2bOrderPurpose: 'B2B Supply',
      availableCommercialPolicies: const [_b2bSupplyPolicy, _samplePolicy],
      selectedCommercialPolicy: _b2bSupplyPolicy,
      availablePriceLists: const [
        {'name': 'B2B Price'},
        {'name': 'Standard Price'},
      ],
      selectedPriceList: const {'name': 'B2B Price'},
    );

    await notifier.setCommercialPolicy(null);
    await notifier.setCommercialPolicy(_samplePolicy);
    await notifier.setSelectedPriceList('Standard Price');

    expect(notifier.state.selectedCommercialPolicy, _b2bSupplyPolicy);
    expect(notifier.state.selectedPriceListName, 'B2B Price');
    expect(notifier.state.b2bSetupComplete, isTrue);
  });

  test('B2B checkout blocks a branch whose POS profile is missing', () async {
    final notifier = PosNotifier(
      PosRepository(Dio()),
      _MemoryDraftRepository(),
    );
    addTearDown(notifier.dispose);
    notifier.state = notifier.state.copyWith(
      cartItems: const [
        {'item_code': 'COFFEE', 'quantity': 1, 'rate': 100},
      ],
      selectedProfile: const {'name': 'Heliopolis POS'},
      selectedCustomer: const {
        'name': 'ilo specialty coffee',
        'selected_shipping_address_name': 'ILO-MADINATY',
        'selected_shipping_address_territory': 'EGMADINATY',
      },
      isB2bOrder: true,
      b2bSetupComplete: true,
      boundB2bOrderPurpose: 'B2B Supply',
      availableCommercialPolicies: const [_b2bSupplyPolicy],
      selectedCommercialPolicy: _b2bSupplyPolicy,
      availablePriceLists: const [
        {'name': 'B2B Price'},
      ],
      selectedPriceList: const {'name': 'B2B Price'},
    );

    await notifier.checkout();

    expect(notifier.state.error, contains('has no POS profile'));
    expect(notifier.state.cartItems, isNotEmpty);
  });

  test('restored B2B draft with unavailable policy cannot checkout', () async {
    final drafts = _MemoryDraftRepository();
    drafts.saved.add(
      DraftCart(
        id: 'stale-b2b',
        label: 'Stale B2B',
        cartItems: const [
          {'item_code': 'COFFEE', 'quantity': 1, 'rate': 100},
        ],
        customer: const {'name': 'ilo specialty coffee'},
        selectedPriceList: const {'name': 'B2B Price'},
        selectedCommercialPolicy: _b2bSupplyPolicy,
        isB2bOrder: true,
        boundB2bOrderPurpose: 'B2B Supply',
        policyReason: 'Negotiated supply order',
        isPickup: false,
        createdAt: DateTime(2026, 9, 6),
        updatedAt: DateTime(2026, 9, 6),
      ),
    );
    final notifier = PosNotifier(PosRepository(Dio()), drafts);
    addTearDown(notifier.dispose);

    await notifier.switchDraft('stale-b2b');
    await notifier.checkout();

    expect(notifier.state.isB2bOrder, isTrue);
    expect(notifier.state.policyReason, 'Negotiated supply order');
    expect(notifier.state.b2bSetupComplete, isFalse);
    expect(notifier.state.error, contains('B2B order policy is not ready'));
  });

  test(
    'fresh B2B setup replaces a prior retail profile with the branch context',
    () async {
      final repository = _B2bPosRepository();
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
        selectedProfile: const {'name': 'Retail'},
        availablePriceLists: const [
          {'name': 'Retail Price', 'is_default': true},
        ],
        selectedPriceList: const {'name': 'Retail Price', 'is_default': true},
      );

      await notifier.startB2bOrder(_branchCustomer('CUST-A', 'Nasr city'));
      final applied = await notifier.setCommercialPolicyByOrderPurpose(
        'B2B Supply',
      );
      notifier.markB2bSetupComplete();

      expect(applied, isTrue);
      expect(notifier.state.selectedProfile?['name'], 'Nasr city');
      expect(
        notifier.state.selectedPriceListName,
        'Nasr city B2B Supply Price',
      );
      expect(notifier.state.selectedCommercialPolicy?.name, 'POL-B2B');
      expect(notifier.state.b2bSetupComplete, isTrue);
      expect(repository.managerPriceListCalls, 0);
      expect(repository.managerPolicyCalls, 0);
      expect(repository.calls.first, 'context:Nasr city:CUST-A:B2B Supply');
      expect(
        repository.calls,
        containsAll([
          'items:Nasr city:CUST-A:B2B Supply:Nasr city B2B Supply Price',
          'bundles:Nasr city:CUST-A:B2B Supply:Nasr city B2B Supply Price',
        ]),
      );
    },
  );

  test('Sample - Courier uses the exact server-owned B2B context', () async {
    final repository = _B2bPosRepository();
    final notifier = PosNotifier(repository, _MemoryDraftRepository());
    addTearDown(notifier.dispose);
    notifier.state = notifier.state.copyWith(
      profiles: await repository.getPosProfiles(),
    );
    await notifier.startB2bOrder(_branchCustomer('CUST-S', 'Dokki'));

    final applied = await notifier.setCommercialPolicyByOrderPurpose(
      'Sample - Courier',
    );
    notifier.markB2bSetupComplete();

    expect(applied, isTrue);
    expect(notifier.state.selectedCommercialPolicy?.name, 'POL-SAMPLE');
    expect(notifier.state.selectedPriceListName, contains('Sample - Courier'));
    expect(notifier.state.zeroShippingOverride, isTrue);
    expect(notifier.addToCart(notifier.state.items.single), isTrue);
    expect(notifier.state.cartItems.single['price_list_rate'], 80.0);
    expect(notifier.state.cartItems.single['discount_percentage'], 100.0);
    expect(notifier.state.cartItems.single['rate'], 0.0);
    expect(notifier.state.cartTotal, 0.0);
    expect(notifier.state.shippingCost, 0.0);
    expect(notifier.state.totalWithShipping, 0.0);
    expect(
      await notifier.changeB2bBranch(_branchCustomer('CUST-S', 'Nasr city')),
      isTrue,
    );
    expect(notifier.state.cartItems.single['price_list_rate'], 100.0);
    expect(notifier.state.cartItems.single['discount_percentage'], 100.0);
    expect(notifier.state.cartItems.single['rate'], 0.0);
    expect(notifier.state.totalWithShipping, 0.0);
    expect(
      await notifier.setCommercialPolicyByOrderPurpose('Employee'),
      isFalse,
    );
    expect(notifier.state.b2bSetupComplete, isFalse);
    expect(
      repository.calls.where((call) => call.contains('Employee')),
      isEmpty,
    );
  });

  test(
    'Sample draft restore re-applies policy defaults and its reason',
    () async {
      final repository = _B2bPosRepository();
      final drafts = _MemoryDraftRepository();
      drafts.saved.add(
        DraftCart(
          id: 'sample-draft',
          label: 'Sample draft',
          cartItems: const [
            {
              'item_code': 'COFFEE',
              'item_name': 'Coffee',
              'quantity': 1,
              'rate': 120.0,
              'price_list_rate': 120.0,
              'type': 'item',
            },
          ],
          customer: _branchCustomer('CUST-S', 'Nasr city'),
          selectedCommercialPolicy: _sampleCourierPolicy,
          selectedPriceList: const {'name': 'STALE'},
          isB2bOrder: true,
          boundB2bOrderPurpose: 'Sample - Courier',
          policyReason: 'Disposable sample visit',
          isPickup: false,
          createdAt: DateTime(2026, 9, 6),
          updatedAt: DateTime(2026, 9, 6),
        ),
      );
      final notifier = PosNotifier(repository, drafts);
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: repository.profilesResult,
      );

      await notifier.switchDraft('sample-draft');

      expect(notifier.state.cartItems.single['discount_percentage'], 100.0);
      expect(notifier.state.cartItems.single['rate'], 0.0);
      expect(notifier.state.totalWithShipping, 0.0);
      expect(notifier.state.policyReason, 'Disposable sample visit');
    },
  );

  test(
    'an inaccessible delivery-branch profile leaves catalog unchanged',
    () async {
      final repository = _B2bPosRepository();
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: const [
          {'name': 'Nasr city'},
        ],
        selectedProfile: const {'name': 'Nasr city'},
        items: const [
          {'name': 'OLD'},
        ],
      );
      await notifier.startB2bOrder(_branchCustomer('CUST-A', 'Dokki'));

      await expectLater(
        notifier.setCommercialPolicyByOrderPurpose('B2B Supply'),
        throwsException,
      );

      expect(notifier.state.selectedProfile?['name'], 'Nasr city');
      expect(notifier.state.items, const [
        {'name': 'OLD'},
      ]);
      expect(notifier.state.b2bSetupComplete, isFalse);
      expect(repository.calls, isEmpty);
    },
  );

  test(
    'branch change atomically reprices the cart and preserves the reason',
    () async {
      final repository = _B2bPosRepository();
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
      );
      await notifier.startB2bOrder(_branchCustomer('CUST-A', 'Nasr city'));
      await notifier.setCommercialPolicyByOrderPurpose('B2B Supply');
      notifier.markB2bSetupComplete();
      notifier.state = notifier.state.copyWith(
        cartItems: const [
          {
            'item_code': 'COFFEE',
            'item_name': 'Coffee',
            'quantity': 1,
            'rate': 100.0,
          },
        ],
      );
      notifier.setPolicyReason('Negotiated annual supply');

      final applied = await notifier.changeB2bBranch(
        _branchCustomer('CUST-A', 'Dokki'),
      );

      expect(applied, isTrue);
      expect(notifier.state.selectedProfile?['name'], 'Dokki');
      expect(notifier.state.selectedPriceListName, 'Dokki B2B Supply Price');
      expect(notifier.state.cartItems.single['rate'], 80.0);
      expect(notifier.state.policyReason, 'Negotiated annual supply');
      expect(notifier.state.b2bSetupComplete, isTrue);
    },
  );

  test(
    'a stale branch error cannot replace a newer successful context',
    () async {
      final repository = _B2bPosRepository();
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
      );
      await notifier.startB2bOrder(_branchCustomer('CUST-A', 'Nasr city'));
      await notifier.setCommercialPolicyByOrderPurpose('B2B Supply');
      notifier.markB2bSetupComplete();

      final delayed = Completer<B2bPricingContext>();
      repository.delayedContexts['Dokki'] = delayed;
      final stale = notifier.changeB2bBranch(
        _branchCustomer('CUST-A', 'Dokki'),
      );
      await Future<void>.delayed(Duration.zero);
      final current = await notifier.changeB2bBranch(
        _branchCustomer('CUST-A', 'Nasr city'),
      );
      delayed.completeError(Exception('old Dokki request failed'));

      expect(current, isTrue);
      expect(await stale, isFalse);
      expect(notifier.state.selectedProfile?['name'], 'Nasr city');
      expect(notifier.state.b2bSetupComplete, isTrue);
      expect(notifier.state.error, isNull);
    },
  );

  test(
    'current refresh failure blocks checkout until explicit retry succeeds',
    () async {
      final repository = _B2bPosRepository();
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
      );
      await notifier.startB2bOrder(_branchCustomer('CUST-A', 'Nasr city'));
      await notifier.setCommercialPolicyByOrderPurpose('B2B Supply');
      notifier.markB2bSetupComplete();
      notifier.setPolicyReason('Keep this reason');

      repository.contextErrors['Nasr city'] = Exception(
        'temporary catalog failure',
      );
      await notifier.refreshCatalog();

      expect(notifier.state.b2bSetupComplete, isFalse);
      expect(notifier.state.error, contains('temporary catalog failure'));
      expect(notifier.state.policyReason, 'Keep this reason');

      repository.contextErrors.remove('Nasr city');
      final retried = await notifier.retryB2bPricingContext();

      expect(retried, isTrue);
      expect(notifier.state.b2bSetupComplete, isTrue);
      expect(notifier.state.error, isNull);
      expect(notifier.state.policyReason, 'Keep this reason');
    },
  );

  test(
    'draft restore revalidates its own customer, purpose, and branch',
    () async {
      final repository = _B2bPosRepository();
      final drafts = _MemoryDraftRepository();
      drafts.saved.add(
        DraftCart(
          id: 'dokki-b2b',
          label: 'Dokki B2B',
          cartItems: const [
            {
              'item_code': 'COFFEE',
              'item_name': 'Coffee',
              'quantity': 1,
              'rate': 999.0,
            },
          ],
          customer: _branchCustomer('TARGET-CUSTOMER', 'Dokki'),
          selectedPriceList: const {'name': 'STALE'},
          selectedCommercialPolicy: _b2bSupplyPolicy,
          isB2bOrder: true,
          boundB2bOrderPurpose: 'B2B Supply',
          policyReason: 'Saved negotiated reason',
          isPickup: false,
          createdAt: DateTime(2026, 9, 6),
          updatedAt: DateTime(2026, 9, 6),
        ),
      );
      final notifier = PosNotifier(repository, drafts);
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
        selectedProfile: const {'name': 'Retail'},
        selectedCustomer: _branchCustomer('CURRENT-CUSTOMER', 'Nasr city'),
      );

      await notifier.switchDraft('dokki-b2b');

      expect(
        repository.calls.first,
        'context:Dokki:TARGET-CUSTOMER:B2B Supply',
      );
      expect(notifier.state.selectedProfile?['name'], 'Dokki');
      expect(notifier.state.selectedCustomer?['name'], 'TARGET-CUSTOMER');
      expect(notifier.state.selectedPriceListName, 'Dokki B2B Supply Price');
      expect(notifier.state.cartItems.single['rate'], 80.0);
      expect(notifier.state.policyReason, 'Saved negotiated reason');
      expect(notifier.state.b2bSetupComplete, isTrue);
    },
  );

  test(
    'a stale draft pricing error cannot replace a newer restored draft',
    () async {
      final repository = _B2bPosRepository();
      final drafts = _MemoryDraftRepository();
      DraftCart draft(String id, String customer, String profile) => DraftCart(
        id: id,
        label: id,
        cartItems: const [
          {
            'item_code': 'COFFEE',
            'item_name': 'Coffee',
            'quantity': 1,
            'rate': 999.0,
          },
        ],
        customer: _branchCustomer(customer, profile),
        selectedCommercialPolicy: _b2bSupplyPolicy,
        selectedPriceList: const {'name': 'STALE'},
        isB2bOrder: true,
        boundB2bOrderPurpose: 'B2B Supply',
        isPickup: false,
        createdAt: DateTime(2026, 9, 6),
        updatedAt: DateTime(2026, 9, 6),
      );
      drafts.saved.addAll([
        draft('dokki-draft', 'CUST-DOKKI', 'Dokki'),
        draft('nasr-draft', 'CUST-NASR', 'Nasr city'),
      ]);
      final notifier = PosNotifier(repository, drafts);
      addTearDown(notifier.dispose);
      notifier.state = notifier.state.copyWith(
        profiles: await repository.getPosProfiles(),
        selectedProfile: const {'name': 'Retail'},
      );
      final delayed = Completer<B2bPricingContext>();
      repository.delayedContexts['Dokki'] = delayed;

      final stale = notifier.switchDraft('dokki-draft');
      await Future<void>.delayed(Duration.zero);
      await notifier.switchDraft('nasr-draft');
      delayed.completeError(Exception('old draft context failed'));
      await stale;

      expect(notifier.state.currentDraftId, 'nasr-draft');
      expect(notifier.state.selectedCustomer?['name'], 'CUST-NASR');
      expect(notifier.state.selectedProfile?['name'], 'Nasr city');
      expect(notifier.state.b2bSetupComplete, isTrue);
      expect(notifier.state.error, isNull);
    },
  );

  test(
    'standard single-profile load keeps the legacy manager catalog',
    () async {
      final repository = _B2bPosRepository()
        ..profilesResult = const [
          {'name': 'Retail'},
        ];
      final notifier = PosNotifier(repository, _MemoryDraftRepository());
      addTearDown(notifier.dispose);

      await notifier.loadProfiles();

      expect(notifier.state.selectedProfile?['name'], 'Retail');
      expect(repository.managerPriceListCalls, 1);
      expect(repository.managerPolicyCalls, 1);
      expect(
        repository.calls.where((call) => call.startsWith('context:')),
        isEmpty,
      );
    },
  );
}
