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
    final notifier = PosNotifier(
      PosRepository(Dio()),
      _MemoryDraftRepository(),
    );
    addTearDown(notifier.dispose);
    await notifier.startB2bOrder(const {
      'name': 'ilo specialty coffee',
      'customer_name': 'ILO Specialty Coffee',
      'selected_shipping_address_name': 'ILO-HELIOPOLIS',
    });

    final applied = await notifier.setCommercialPolicyByOrderPurpose(
      'B2B Supply',
    );
    notifier.markB2bSetupComplete();
    notifier.addToCart(const {
      'name': 'COFFEE',
      'item_name': 'Coffee',
      'rate': 100,
    });
    await notifier.checkout();

    expect(applied, isFalse);
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
}
