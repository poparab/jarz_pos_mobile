import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';

class _TestPosRepository extends PosRepository {
  _TestPosRepository() : super(Dio());
}

void main() {
  group('PosState helpers', () {
    test('cart totals and shipping react to pickup and partner flags', () {
      final state = PosState(
        cartItems: const [
          {
            'item_code': 'ITEM-1',
            'rate': 20,
            'quantity': 2,
            'type': 'item',
          },
        ],
        selectedCustomer: const {
          'name': 'CUST-1',
          'delivery_income': 30,
        },
      );

      expect(state.cartTotal, 40);
      expect(state.shippingCost, 30);
      expect(state.totalWithShipping, 70);

      final pickupState = state.copyWith(isPickup: true);
      expect(pickupState.shippingCost, 0);

      final partnerState = state.copyWith(selectedSalesPartner: const {'name': 'SP-1'});
      expect(partnerState.shippingCost, 0);
    });

    test('shipping waived when bundle with free shipping is present', () {
      final state = PosState(
        cartItems: const [
          {
            'item_code': 'BUNDLE-1',
            'rate': 100,
            'quantity': 1,
            'type': 'bundle',
            'bundle_details': {
              'bundle_info': {'free_shipping': true},
            },
          },
        ],
        selectedCustomer: const {
          'delivery_income': 40,
        },
      );

      expect(state.shippingCost, 0);
      expect(state.totalWithShipping, 100);
    });
  });

  group('PosNotifier cart operations', () {
    late PosNotifier notifier;

    setUp(() {
      notifier = PosNotifier(_TestPosRepository());
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

    test('setPickup toggles flag and clears selected delivery slot', () {
      final slot = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '10 AM - 11 AM',
      );

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
  });
}
