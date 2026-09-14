import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations_ar.dart';
import 'package:jarz_pos/l10n/app_localizations_en.dart';
import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_models.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

// Production-shaped policies: two fix a list, B2B Supply resolves per customer,
// Free Shipping Waiver is a retail order.
const _employee = CommercialPolicy(
  name: 'Employee Order',
  policyName: 'Employee Order',
  orderPurpose: 'Employee',
  priceList: 'Employee',
);
const _sample = CommercialPolicy(
  name: 'Sample (Courier)',
  policyName: 'Sample (Courier)',
  orderPurpose: 'Sample - Courier',
  priceList: 'Sample',
);
const _b2bSupply = CommercialPolicy(
  name: 'B2B Supply',
  policyName: 'B2B Supply',
  orderPurpose: 'B2B Supply',
);
const _freeShipping = CommercialPolicy(
  name: 'Free Shipping Waiver',
  policyName: 'Free Shipping Waiver',
  orderPurpose: 'Free Shipping Waiver',
  waivesShippingIncome: true,
);
const _policies = [_employee, _sample, _b2bSupply, _freeShipping];

const _rates = <String, double>{
  'Standard Selling': 100,
  'Selling Bundle of 3': 90,
  'B2B Selling': 80,
  'B2B Tier A': 70,
  'Employee': 60,
  'Sample': 0,
};

/// Price-list options as an older backend sends them (no reservation key).
List<Map<String, dynamic>> _legacyLists() => [
  for (final name in _rates.keys)
    {
      'name': name,
      'display_label': name,
      'is_default': name == 'Standard Selling',
      'zero_shipping_default': false,
    },
];

/// The same options with the backend's `reserved_for_purposes`.
List<Map<String, dynamic>> _reservingLists() => [
  for (final option in _legacyLists())
    {
      ...option,
      reservedForPurposesKey: switch (option['name']) {
        'B2B Selling' || 'B2B Tier A' => ['B2B Supply'],
        'Employee' => ['Employee'],
        'Sample' => ['Sample - Courier', 'Sample - No Courier'],
        _ => <String>[],
      },
    },
];

class _FakePosRepository extends PosRepository {
  _FakePosRepository({List<Map<String, dynamic>>? priceLists})
    : priceLists = priceLists ?? _reservingLists(),
      super(Dio());

  List<Map<String, dynamic>> priceLists;
  String? customerPriceList = 'B2B Tier A';
  final itemPriceLists = <String?>[];
  final invoices = <Map<String, String?>>[];

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async {
    itemPriceLists.add(priceList);
    final rate = _rates[priceList] ?? 100;
    return [
      {'name': 'JAR-L', 'item_name': 'Large jar', 'rate': rate},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(
    String posProfile,
  ) async => priceLists;

  @override
  Future<List<CommercialPolicy>> getCommercialPolicies(
    String posProfile,
  ) async => _policies;

  @override
  Future<String?> getCustomerPriceList(
    String customer,
    String posProfile, {
    String? orderPurpose,
  }) async => customerPriceList;

  @override
  Future<List<DeliverySlot>> getDeliverySlots(String posProfile) async =>
      const [];

  @override
  Future<Map<String, dynamic>> createInvoice({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    String? deliveryEndDatetime,
    bool deliverySlotExplicit = false,
    String? salesPartner,
    String? paymentType,
    bool isPickup = false,
    String? paymentMethod,
    String? priceList,
    bool zeroShippingOverride = false,
    bool posProfileOverride = false,
    double? customDeliveryIncome,
    String? orderPurpose,
    String? commercialPolicy,
    String? policyReason,
    String? employeePayment,
    List<String> promoCodes = const [],
  }) async {
    invoices.add({
      'price_list': priceList,
      'order_purpose': orderPurpose,
      'commercial_policy': commercialPolicy,
    });
    return {'invoice_name': 'INV-0001'};
  }
}

class _MemoryDrafts extends DraftCartRepository {
  _MemoryDrafts([List<DraftCart>? drafts]) : _drafts = [...?drafts];

  final List<DraftCart> _drafts;

  @override
  Future<void> upsert(DraftCart draft) async {
    _drafts.removeWhere((existing) => existing.id == draft.id);
    _drafts.add(draft);
  }

  @override
  Future<List<DraftCart>> loadAll() async => List<DraftCart>.from(_drafts);

  @override
  Future<void> delete(String id) async =>
      _drafts.removeWhere((draft) => draft.id == id);

  @override
  Future<void> clearAll() async => _drafts.clear();
}

const _cartLine = <String, dynamic>{
  'item_code': 'JAR-L',
  'item_name': 'Large jar',
  'quantity': 1,
  'rate': 100,
  'type': 'item',
};

const _customer = <String, dynamic>{
  'name': 'CUST-B2B-1',
  'customer_name': 'Cafe One',
};

Map<String, dynamic> _option(String name, [List<Map<String, dynamic>>? from]) =>
    Map<String, dynamic>.from(
      (from ?? _reservingLists()).firstWhere((o) => o['name'] == name),
    );

PosNotifier _notifier(
  _FakePosRepository repository, {
  CommercialPolicy? policy,
  String priceList = 'Standard Selling',
  Map<String, dynamic>? customer,
  _MemoryDrafts? drafts,
}) {
  final notifier = PosNotifier(repository, drafts ?? _MemoryDrafts());
  addTearDown(notifier.dispose);
  notifier.state = PosState(
    selectedProfile: const {'name': 'Heliopolis POS'},
    availablePriceLists: repository.priceLists,
    selectedPriceList: _option(priceList, repository.priceLists),
    availableCommercialPolicies: _policies,
    selectedCommercialPolicy: policy,
    selectedCustomer: customer,
    cartItems: const [_cartLine],
    isPickup: true,
  );
  return notifier;
}

/// The server's three rules, restated independently of the client code.
void _expectServerAccepts(
  Map<String, String?> invoice, {
  String? customerResolvedList,
}) {
  final purpose = invoice['order_purpose'];
  final priceList = invoice['price_list'];
  final policy = _policies.where((p) => p.orderPurpose == purpose).firstOrNull;
  if (policy?.priceList != null) {
    expect(priceList, policy!.priceList, reason: 'rule 1 for $purpose');
  } else if (purpose == 'B2B Supply') {
    expect(priceList, customerResolvedList, reason: 'rule 2');
  } else {
    // Standard / Free Shipping Waiver: the POS default and nothing else.
    expect(
      priceList,
      'Standard Selling',
      reason: 'rule 3 for ${purpose ?? 'Standard'}',
    );
  }
}

void main() {
  group('PosState price list rule', () {
    test('should lock the list for a fixed-list purpose and B2B Supply', () {
      expect(
        PosState(
          selectedCommercialPolicy: _employee,
        ).isPriceListLockedByPurpose,
        isTrue,
      );
      expect(
        PosState(selectedCommercialPolicy: _sample).isPriceListLockedByPurpose,
        isTrue,
      );
      expect(
        PosState(
          selectedCommercialPolicy: _b2bSupply,
        ).isPriceListLockedByPurpose,
        isTrue,
      );
      expect(
        PosState(
          selectedCommercialPolicy: _freeShipping,
        ).isPriceListLockedByPurpose,
        isFalse,
      );
      expect(PosState().isPriceListLockedByPurpose, isFalse);
    });

    test('should reserve policy lists and the B2B base list on an older '
        'backend', () {
      final state = PosState(
        availablePriceLists: _legacyLists(),
        availableCommercialPolicies: _policies,
      );

      expect(state.isPriceListReserved('Employee'), isTrue);
      expect(state.isPriceListReserved('Sample'), isTrue);
      expect(state.isPriceListReserved('B2B Selling'), isTrue);
      expect(state.isPriceListReserved('Standard Selling'), isFalse);
      expect(state.isPriceListReserved('Selling Bundle of 3'), isFalse);
      expect(state.isPriceListReserved('B2B Tier A'), isFalse);
    });

    test('should follow reserved_for_purposes when the backend sends it', () {
      final lists = _reservingLists()
        ..firstWhere(
          (o) => o['name'] == 'B2B Selling',
        )[reservedForPurposesKey] = <String>[]
        ..firstWhere(
          (o) => o['name'] == 'Selling Bundle of 3',
        )[reservedForPurposesKey] = [
          'Talabat',
        ];
      final state = PosState(
        availablePriceLists: lists,
        availableCommercialPolicies: _policies,
      );

      expect(state.isPriceListReserved('B2B Selling'), isFalse);
      expect(state.isPriceListReserved('Selling Bundle of 3'), isTrue);
      expect(state.isPriceListReserved('B2B Tier A'), isTrue);
    });

    test('should reserve nothing by fallback when no policies are loaded, '
        'but still honour the backend flag', () {
      final legacy = PosState(availablePriceLists: _legacyLists());
      for (final name in _rates.keys) {
        expect(legacy.isPriceListReserved(name), isFalse, reason: name);
      }

      final flagged = PosState(availablePriceLists: _reservingLists());
      expect(flagged.isPriceListReserved('Employee'), isTrue);
      expect(flagged.isPriceListReserved('B2B Tier A'), isTrue);
      expect(flagged.isPriceListReserved('Standard Selling'), isFalse);
      expect(flagged.isPriceListReserved('Selling Bundle of 3'), isFalse);
    });

    test('should parse reserved_for_purposes leniently', () {
      expect(parseReservedForPurposes(null), isEmpty);
      expect(parseReservedForPurposes('Employee'), isEmpty);
      expect(parseReservedForPurposes({'a': 1}), isEmpty);
      expect(parseReservedForPurposes([' Employee ', '', null]), ['Employee']);
    });
  });

  group('guarded price list setter', () {
    test('should refuse any change while the purpose locks the list', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(
        repository,
        policy: _employee,
        priceList: 'Employee',
      );

      await notifier.setSelectedPriceList('Standard Selling');
      await notifier.setSelectedPriceList(null);

      expect(notifier.state.selectedPriceListName, 'Employee');
      expect(repository.itemPriceLists, isEmpty);
    });

    test('should refuse any non-default list for a Standard order', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository);

      await notifier.setSelectedPriceList('Sample');
      expect(notifier.state.selectedPriceListName, 'Standard Selling');

      // Not reserved, but not the POS default either: the server refuses it.
      await notifier.setSelectedPriceList('Selling Bundle of 3');
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(repository.itemPriceLists, isEmpty);
    });

    test('should refuse a non-default list for Free Shipping Waiver', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, policy: _freeShipping);

      await notifier.setSelectedPriceList('Selling Bundle of 3');

      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(repository.itemPriceLists, isEmpty);
    });

    test('should accept the POS default for a free-list order', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, priceList: 'Selling Bundle of 3');

      await notifier.setSelectedPriceList('Standard Selling');

      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(repository.itemPriceLists.last, 'Standard Selling');
    });

    test(
      'should refuse a fallback-reserved list on an older backend',
      () async {
        final repository = _FakePosRepository(priceLists: _legacyLists());
        final notifier = _notifier(repository, policy: _freeShipping);

        await notifier.setSelectedPriceList('B2B Selling');

        expect(notifier.state.selectedPriceListName, 'Standard Selling');
      },
    );
  });

  group('switching order purpose', () {
    test('should apply the purpose list, then return to the default on '
        'Standard', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, priceList: 'Selling Bundle of 3');

      await notifier.setCommercialPolicy(_employee);
      expect(notifier.state.selectedPriceListName, 'Employee');
      expect(notifier.state.cartItems.single['rate'], 60);

      await notifier.setCommercialPolicy(null);
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(notifier.state.cartItems.single['rate'], 100);
    });

    test('should return to the default on Free Shipping Waiver', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(
        repository,
        policy: _sample,
        priceList: 'Sample',
        customer: _customer,
      );

      await notifier.setCommercialPolicy(_freeShipping);

      expect(notifier.state.selectedPriceListName, 'Standard Selling');
    });

    test('should resolve B2B Supply per customer', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, customer: _customer);

      await notifier.setCommercialPolicy(_b2bSupply);

      expect(notifier.state.selectedPriceListName, 'B2B Tier A');
    });

    test('should not keep another purpose list while B2B Supply waits for a '
        'customer', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(
        repository,
        policy: _employee,
        priceList: 'Employee',
      );

      await notifier.setCommercialPolicy(_b2bSupply);

      expect(notifier.state.selectedPriceListName, 'Standard Selling');
    });

    test('should drop a locked list when the cart is cleared', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(
        repository,
        policy: _employee,
        priceList: 'Employee',
      );

      notifier.clearCart();
      // clearCart is synchronous; its price-list reset runs unawaited.
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(notifier.state.selectedCommercialPolicy, isNull);
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
    });
  });

  group('draft restore and catalog refresh', () {
    DraftCart draft({
      required CommercialPolicy? policy,
      required String priceList,
    }) => DraftCart(
      id: 'draft-1',
      label: 'Draft',
      cartItems: const [_cartLine],
      selectedPriceList: _option(priceList),
      selectedCommercialPolicy: policy,
      isPickup: true,
      createdAt: DateTime(2026, 9, 13),
      updatedAt: DateTime(2026, 9, 13),
    );

    test('should restore a locked purpose on its own list', () async {
      final repository = _FakePosRepository();
      final drafts = _MemoryDrafts([
        draft(policy: _sample, priceList: 'Standard Selling'),
      ]);
      final notifier = _notifier(repository, drafts: drafts);
      notifier.state = notifier.state.copyWith(cartItems: const []);

      await notifier.switchDraft('draft-1');

      expect(notifier.state.selectedCommercialPolicy?.name, _sample.name);
      expect(notifier.state.selectedPriceListName, 'Sample');
      expect(repository.itemPriceLists.last, 'Sample');
      expect(notifier.state.cartItems.single['rate'], 0);
    });

    test('should restore a Standard draft off a reserved list', () async {
      final repository = _FakePosRepository();
      final drafts = _MemoryDrafts([
        draft(policy: null, priceList: 'Employee'),
      ]);
      final notifier = _notifier(repository, drafts: drafts);
      notifier.state = notifier.state.copyWith(cartItems: const []);

      await notifier.switchDraft('draft-1');

      expect(notifier.state.selectedCommercialPolicy, isNull);
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(notifier.state.cartItems.single['rate'], 100);
    });

    for (final policy in <CommercialPolicy?>[null, _freeShipping]) {
      test('should restore a ${policy?.orderPurpose ?? 'Standard'} draft on '
          'a non-default list at the POS default', () async {
        final repository = _FakePosRepository();
        final drafts = _MemoryDrafts([
          draft(policy: policy, priceList: 'Selling Bundle of 3'),
        ]);
        final notifier = _notifier(repository, drafts: drafts);
        notifier.state = notifier.state.copyWith(cartItems: const []);

        await notifier.switchDraft('draft-1');

        expect(notifier.state.selectedCommercialPolicy?.name, policy?.name);
        expect(notifier.state.selectedPriceListName, 'Standard Selling');
        expect(repository.itemPriceLists.last, 'Standard Selling');
        expect(notifier.state.cartItems.single['rate'], 100);
      });
    }

    test(
      'should reconcile a non-default Standard list on catalog refresh',
      () async {
        final repository = _FakePosRepository();
        final notifier = _notifier(
          repository,
          priceList: 'Selling Bundle of 3',
        );

        await notifier.refreshCatalog();

        expect(notifier.state.selectedPriceListName, 'Standard Selling');
        expect(repository.itemPriceLists.last, 'Standard Selling');
        expect(notifier.state.cartItems.single['rate'], 100);
      },
    );

    test('should reconcile a mismatched pair on catalog refresh', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, priceList: 'B2B Selling');

      await notifier.refreshCatalog();

      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(repository.itemPriceLists.last, 'Standard Selling');
    });

    test(
      'should keep an amendment with no purpose on its source list',
      () async {
        final repository = _FakePosRepository();
        final notifier = _notifier(repository, priceList: 'Employee');
        notifier.state = notifier.state.copyWith(
          isAmendmentDraft: true,
          amendmentSourceInvoiceId: 'ACC-SINV-1',
        );

        await notifier.refreshCatalog();

        expect(notifier.state.selectedPriceListName, 'Employee');
      },
    );
  });

  group('checkout payload', () {
    test('should reprice and stop when a Standard order holds a reserved '
        'list, then send the default', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, priceList: 'Sample');

      await notifier.checkout();
      expect(repository.invoices, isEmpty);
      expect(notifier.state.error, PosNotifier.purposePriceListUpdatedError);
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(notifier.state.cartItems.single['rate'], 100);

      await notifier.checkout();
      expect(repository.invoices, hasLength(1));
      _expectServerAccepts(repository.invoices.single);
    });

    test('should reprice and stop when a Standard order holds a non-default '
        'list, then send the default', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, priceList: 'Selling Bundle of 3');
      notifier.state = notifier.state.copyWith(
        cartItems: [
          {..._cartLine, 'rate': 90},
        ],
      );

      await notifier.checkout();
      expect(repository.invoices, isEmpty);
      expect(notifier.state.error, PosNotifier.purposePriceListUpdatedError);
      expect(notifier.state.selectedPriceListName, 'Standard Selling');
      expect(notifier.state.cartItems.single['rate'], 100);

      await notifier.checkout();
      expect(repository.invoices.single['price_list'], 'Standard Selling');
      expect(repository.invoices.single['order_purpose'], isNull);
    });

    test('should reprice and stop when an Employee order holds a retail '
        'list', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, policy: _employee);
      notifier.state = notifier.state.copyWith(
        selectedCustomer: _customer,
        selectedStaffEmployee: 'HR-EMP-1',
        selectedStaffEmployeeName: 'Mona',
      );

      await notifier.checkout();
      expect(repository.invoices, isEmpty);
      expect(notifier.state.selectedPriceListName, 'Employee');

      await notifier.checkout();
      expect(repository.invoices.single['price_list'], 'Employee');
      expect(repository.invoices.single['order_purpose'], 'Employee');
    });

    test('should refuse B2B Supply until a customer is selected', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository, policy: _b2bSupply);

      await notifier.checkout();

      expect(repository.invoices, isEmpty);
      expect(
        notifier.state.error,
        PosNotifier.purposePriceListUnavailableError,
      );
    });

    test('should refuse B2B Supply when the customer has no list', () async {
      final repository = _FakePosRepository()..customerPriceList = null;
      final notifier = _notifier(
        repository,
        policy: _b2bSupply,
        customer: _customer,
      );

      await notifier.checkout();
      await notifier.checkout();

      expect(repository.invoices, isEmpty);
      expect(
        notifier.state.error,
        PosNotifier.purposePriceListUnavailableError,
      );
    });

    test('should send B2B Supply only on the customer-resolved list', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(
        repository,
        policy: _b2bSupply,
        customer: _customer,
      );

      await notifier.checkout();
      expect(repository.invoices, isEmpty);
      expect(notifier.state.selectedPriceListName, 'B2B Tier A');

      await notifier.checkout();
      _expectServerAccepts(
        repository.invoices.single,
        customerResolvedList: 'B2B Tier A',
      );
    });

    for (final policy in <CommercialPolicy?>[null, ..._policies]) {
      for (final priceList in _rates.keys) {
        test('should never send a mismatched pair: '
            '${policy?.orderPurpose ?? 'Standard'} on $priceList', () async {
          final repository = _FakePosRepository();
          final notifier = _notifier(
            repository,
            policy: policy,
            priceList: priceList,
            customer: _customer,
          );
          notifier.state = notifier.state.copyWith(
            selectedStaffEmployee: 'HR-EMP-1',
          );

          // At most one reconciliation, then the order goes through.
          await notifier.checkout();
          if (repository.invoices.isEmpty) await notifier.checkout();

          expect(repository.invoices, hasLength(1));
          _expectServerAccepts(
            repository.invoices.single,
            customerResolvedList: 'B2B Tier A',
          );
        });
      }
    }

    test('should localize both refusals in English and Arabic', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();

      expect(
        userErrorMessageFor(en, PosNotifier.purposePriceListUpdatedError),
        en.posPurposePriceListUpdated,
      );
      expect(
        userErrorMessageFor(ar, PosNotifier.purposePriceListUnavailableError),
        ar.posPurposePriceListUnavailable,
      );
    });
  });
}
