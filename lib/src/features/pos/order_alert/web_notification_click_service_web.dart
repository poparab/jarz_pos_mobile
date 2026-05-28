// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'web_notification_click_utils.dart';
import 'web_push_paths.dart';

class WebNotificationClickService {
  static final StreamController<String> _clickController =
      StreamController<String>.broadcast();
  static bool _isListening = false;

  static String? consumeInitialNotificationId() {
    final notificationId =
        Uri.base.queryParameters['notification']?.trim() ?? '';
    if (notificationId.isEmpty) {
      return null;
    }

    final basePath = normalizeWebAppBasePath(Uri.base.path);
    html.window.history.replaceState(null, html.document.title, basePath);
    return notificationId;
  }

  static Stream<String> notificationClicks() {
    _ensureListening();
    return _clickController.stream;
  }

  static void _ensureListening() {
    if (_isListening) {
      return;
    }
    _isListening = true;

    final serviceWorker = html.window.navigator.serviceWorker;
    if (serviceWorker == null) {
      return;
    }

    serviceWorker.onMessage.listen((event) {
      final message = js_util.dartify(event.data);
      if (message is! Map) {
        return;
      }

      final type = message['type']?.toString();
      if (type != 'jarz_pos_notification_click') {
        return;
      }

      final notificationId = extractNotificationIdFromUrl(
        message['url']?.toString(),
      );
      if (notificationId == null) {
        return;
      }

      _clickController.add(notificationId);
    });
  }
}