import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_notification_click_utils.dart';

void main() {
  group('extractNotificationIdFromUrl', () {
    test('returns null for empty or invalid values', () {
      expect(extractNotificationIdFromUrl(null), isNull);
      expect(extractNotificationIdFromUrl(''), isNull);
      expect(extractNotificationIdFromUrl('not a url'), isNull);
      expect(extractNotificationIdFromUrl('/pos/'), isNull);
    });

    test('extracts notification query parameter from relative and absolute urls', () {
      expect(
        extractNotificationIdFromUrl('/pos/?notification=INV-0001'),
        'INV-0001',
      );
      expect(
        extractNotificationIdFromUrl('https://erp.orderjarz.com/pos/?notification=INV-0002'),
        'INV-0002',
      );
    });
  });
}