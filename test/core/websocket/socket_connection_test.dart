import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';

/// Pins the two things Frappe's socket server needs before it delivers a
/// single event: the `/<site>` namespace and the `sid` cookie.
void main() {
  group('socketIoUri', () {
    test('joins the site namespace', () {
      expect(
        WebSocketService.socketIoUri('https://erp.orderjarz.com', 'frontend'),
        'https://erp.orderjarz.com/frontend',
      );
    });

    test('drops trailing slashes from the base', () {
      expect(
        WebSocketService.socketIoUri('https://erpstg.orderjarz.com//', 'frontend'),
        'https://erpstg.orderjarz.com/frontend',
      );
    });

    test('falls back to the docker site when FRAPPE_SITE is unset', () {
      expect(
        WebSocketService.socketIoUri('https://erp.orderjarz.com', '  '),
        'https://erp.orderjarz.com/${WebSocketService.defaultSiteNamespace}',
      );
    });

    test('keeps a local dev site name', () {
      expect(
        WebSocketService.socketIoUri('http://192.168.1.7:9000', 'development.localhost'),
        'http://192.168.1.7:9000/development.localhost',
      );
    });
  });

  group('socketAuthHeaders', () {
    test('sends the sid cookie', () {
      expect(WebSocketService.socketAuthHeaders('abc123'), {'Cookie': 'sid=abc123'});
    });

    test('sends nothing before login', () {
      expect(WebSocketService.socketAuthHeaders(null), isEmpty);
      expect(WebSocketService.socketAuthHeaders(''), isEmpty);
    });
  });

  group('reconnectDelayFor', () {
    test('backs off from 5 s to a one-minute cap', () {
      final secs = [0, 1, 2, 3, 4, 5, 9]
          .map((n) => WebSocketService.reconnectDelayFor(n).inSeconds)
          .toList();
      expect(secs, [5, 5, 10, 20, 40, 60, 60]);
    });
  });
}
