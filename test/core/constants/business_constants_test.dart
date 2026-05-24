import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';

void main() {
  group('OutForDeliverySettlement', () {
    test('should default OFD settlement to later with mode picker hidden', () {
      expect(OutForDeliverySettlement.defaultMode, SettlementModes.later);
      expect(OutForDeliverySettlement.showModePicker, isFalse);
    });

    test('should preserve backend settlement mode strings', () {
      expect(SettlementModes.payNow, 'pay_now');
      expect(SettlementModes.later, 'later');
    });
  });
}