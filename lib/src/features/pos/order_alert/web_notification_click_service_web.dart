import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

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
    web.window.history.replaceState(null, web.document.title, basePath);
    return notificationId;
  }

  static Stream<String> notificationClicks() {
    _ensureListening();
    return _clickController.stream;
  }

  /// The notification id named by a service-worker `message` payload, or null
  /// when the message is not a Jarz notification click. Kept separate from the
  /// listener so a browser test can feed it a synthetic event.
  static String? notificationIdFromMessage(JSAny? data) {
    final message = data.dartify();
    if (message is! Map) {
      return null;
    }

    final type = message['type']?.toString();
    if (type != 'jarz_pos_notification_click') {
      return null;
    }

    return extractNotificationIdFromUrl(message['url']?.toString());
  }

  static void _ensureListening() {
    if (_isListening) {
      return;
    }
    _isListening = true;

    final serviceWorker = _serviceWorkerContainer();
    if (serviceWorker == null) {
      return;
    }

    // A plain listener rather than package:web's EventStreamProviders: those
    // live in its deprecated helpers library, and one callback is all this is.
    serviceWorker.addEventListener(
      'message',
      ((web.MessageEvent event) {
        final notificationId = notificationIdFromMessage(event.data);
        if (notificationId != null) {
          _clickController.add(notificationId);
        }
      }).toJS,
    );
  }

  /// `navigator.serviceWorker` is undefined in insecure contexts and some
  /// embedded browsers. package:web types it non-null, so read it dynamically
  /// rather than let a missing property surface as an exception.
  static web.ServiceWorkerContainer? _serviceWorkerContainer() {
    final value = web.window.navigator['serviceWorker'];
    if (value.isUndefinedOrNull) {
      return null;
    }
    return value as web.ServiceWorkerContainer;
  }
}
