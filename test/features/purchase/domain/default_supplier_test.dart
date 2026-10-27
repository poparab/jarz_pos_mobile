import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/domain/default_supplier.dart';

void main() {
  group('defaultSupplierFor', () {
    test('picks the supplier most items were last bought from', () {
      expect(defaultSupplierFor(['Lactalis', 'Juhayna', 'Lactalis']), 'Lactalis');
    });

    test('a tie goes to the first item in the cart', () {
      expect(defaultSupplierFor(['Juhayna', 'Lactalis']), 'Juhayna');
    });

    test('items never bought are ignored', () {
      expect(defaultSupplierFor([null, '', '  ', 'Lactalis']), 'Lactalis');
    });

    test('nothing bought before means no default', () {
      expect(defaultSupplierFor([null, '']), isNull);
      expect(defaultSupplierFor(const []), isNull);
    });
  });
}
