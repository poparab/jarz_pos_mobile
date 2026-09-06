import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_models.dart';

void main() {
  test('B2B draft preserves branch and commercial policy', () {
    final original = DraftCart(
      id: 'b2b-draft',
      label: 'ILO • 1 item',
      cartItems: const [
        {'item_code': 'COFFEE', 'quantity': 1, 'rate': 100},
      ],
      customer: const {
        'name': 'ilo specialty coffee',
        'selected_shipping_address_name': 'ilo specialty coffee-16815-Shipping',
        'selected_shipping_branch_name': 'All Seasons Park',
        'selected_shipping_address_territory': 'EGMADINATY',
        'selected_shipping_address_territory_pos_profile': 'Madinaty POS',
      },
      selectedCommercialPolicy: const CommercialPolicy(
        name: 'B2B Supply',
        policyName: 'B2B Supply',
        orderPurpose: 'B2B Supply',
      ),
      isB2bOrder: true,
      boundB2bOrderPurpose: 'B2B Supply',
      policyReason: 'Negotiated ILO supply order',
      isPickup: false,
      createdAt: DateTime(2026, 9, 6),
      updatedAt: DateTime(2026, 9, 6),
    );

    final restored = DraftCart.fromMap(original.toMap());

    expect(restored.isB2bOrder, isTrue);
    expect(
      restored.customer?['selected_shipping_address_name'],
      'ilo specialty coffee-16815-Shipping',
    );
    expect(restored.selectedCommercialPolicy?.orderPurpose, 'B2B Supply');
    expect(restored.boundB2bOrderPurpose, 'B2B Supply');
    expect(restored.policyReason, 'Negotiated ILO supply order');
    expect(
      restored.customer?['selected_shipping_address_territory_pos_profile'],
      'Madinaty POS',
    );
    expect(DraftCartSummary.from(restored).isB2bOrder, isTrue);
  });

  test('legacy draft stays retail when B2B metadata is absent', () {
    final restored = DraftCart.fromMap({
      'id': 'legacy',
      'label': 'Legacy',
      'cart_items': '[]',
      'is_pickup': false,
    });

    expect(restored.isB2bOrder, isFalse);
    expect(restored.selectedCommercialPolicy, isNull);
  });
}
