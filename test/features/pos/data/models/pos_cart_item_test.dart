import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_cart_item.dart';

void main() {
  group('PosCartItem', () {
    test('constructor sets all fields', () {
      final item = PosCartItem(
        itemCode: 'ITEM-1',
        quantity: 3,
        rate: 12.5,
        isBundle: true,
        priceListRate: 15.0,
        discountAmount: 2.5,
        discountPercentage: 10.0,
      );

      expect(item.itemCode, 'ITEM-1');
      expect(item.quantity, 3);
      expect(item.rate, 12.5);
      expect(item.isBundle, true);
      expect(item.priceListRate, 15.0);
      expect(item.discountAmount, 2.5);
      expect(item.discountPercentage, 10.0);
    });

    test('defaults isBundle to false and optionals to null', () {
      final item = PosCartItem(itemCode: 'X', quantity: 1, rate: 5);
      expect(item.isBundle, false);
      expect(item.priceListRate, isNull);
      expect(item.discountAmount, isNull);
      expect(item.discountPercentage, isNull);
    });

    test('copyWith returns a new instance with overridden fields', () {
      final original = PosCartItem(itemCode: 'A', quantity: 1, rate: 10);
      final copy = original.copyWith(quantity: 5, rate: 20, isBundle: true);

      expect(copy.itemCode, 'A');
      expect(copy.quantity, 5);
      expect(copy.rate, 20);
      expect(copy.isBundle, true);
    });

    test('copyWith preserves unchanged fields', () {
      final original = PosCartItem(
        itemCode: 'A',
        quantity: 2,
        rate: 10,
        priceListRate: 12,
        discountAmount: 1,
      );
      final copy = original.copyWith(quantity: 3);

      expect(copy.itemCode, 'A');
      expect(copy.rate, 10);
      expect(copy.priceListRate, 12);
      expect(copy.discountAmount, 1);
      expect(copy.quantity, 3);
    });

    test('copyWith with no args returns identical values', () {
      final original = PosCartItem(itemCode: 'Z', quantity: 7, rate: 3.5);
      final copy = original.copyWith();
      expect(copy.itemCode, original.itemCode);
      expect(copy.quantity, original.quantity);
      expect(copy.rate, original.rate);
      expect(copy.isBundle, original.isBundle);
    });
  });
}
