import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_paths.dart';

void main() {
  group('normalizeWebAppBasePath', () {
    test('returns root slash for empty values', () {
      expect(normalizeWebAppBasePath(''), '/');
      expect(normalizeWebAppBasePath('/'), '/');
      expect(normalizeWebAppBasePath(null), '/');
    });

    test('normalizes nested application paths', () {
      expect(normalizeWebAppBasePath('pos'), '/pos/');
      expect(normalizeWebAppBasePath('/pos'), '/pos/');
      expect(normalizeWebAppBasePath('/pos/'), '/pos/');
      expect(normalizeWebAppBasePath('///pos///admin///'), '/pos/admin/');
    });
  });

  group('buildWebAppAssetUrl', () {
    test('joins assets under the normalized base path', () {
      expect(buildWebAppAssetUrl('/', 'firebase-messaging-sw.js'), '/firebase-messaging-sw.js');
      expect(buildWebAppAssetUrl('/pos/', 'firebase-messaging-sw.js'), '/pos/firebase-messaging-sw.js');
      expect(buildWebAppAssetUrl('/pos', '/icons/Icon-192.png'), '/pos/icons/Icon-192.png');
    });
  });
}