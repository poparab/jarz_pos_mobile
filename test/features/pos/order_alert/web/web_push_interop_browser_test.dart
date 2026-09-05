// Real-browser tests for the three web-push interop files.
//
// These files only compile for the web, so the ordinary VM suite never
// executes a line of them - which is how an interop migration could pass
// analysis and every test while being broken at runtime. This file runs under
// `flutter test --platform chrome` and is skipped on the VM.
//
// Headless Chrome never grants notification permission, so the deep
// `pushManager.subscribe()` path cannot be reached here; what can be is every
// interop primitive that path is built from - property reads on window and
// navigator, method calls, JS object construction, promise bridging, dartify -
// exercised against the real globals and a planted `window.firebase_messaging`.
@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/data/order_alert_service.dart';
import 'package:jarz_pos/src/features/pos/order_alert/vapid_subscription_result.dart';
import 'package:jarz_pos/src/features/pos/order_alert/vapid_subscription_service_web.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_notification_click_service_web.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_registration_service_web.dart';
import 'package:web/web.dart' as web;

/// Shaped like a real FCM registration token so the normaliser treats it as one.
final _fakeToken = '${'c' * 22}:APA91b${'X' * 134}';

void main() {
  // FirebaseRuntimeConfig reads dotenv, which the app loads in main(). Nothing
  // does that here, and an uninitialised dotenv throws NotInitializedError the
  // moment `_newDiagnostics` or `_getWebPushToken` touches it. Load from a
  // string, synchronously: `dotenv.load()` goes through rootBundle, and on the
  // browser test platform that asset fetch hangs rather than failing - even
  // with `isOptional: true`, which only guards against errors, never a stall.
  setUpAll(() {
    dotenv.loadFromString(
      isOptional: true,
      mergeWith: const {
        'WEB_PUSH_ENABLED': 'true',
        'FIREBASE_WEB_VAPID_KEY': 'test-vapid-public-key',
      },
    );
  });

  group('VapidSubscriptionService in a real browser', () {
    // Both entry points must stop at the PERMISSION gate. That proves they got
    // past the service-worker lookup (a null there returns `unsupported`) and
    // read Notification.permission through the new interop.
    test('requestSubscription reaches the permission gate, not a support check',
        () async {
      final result = await VapidSubscriptionService.requestSubscription(
        service: OrderAlertService(Dio()),
      );

      expect(result.status, VapidSubscriptionStatus.permissionDenied);
      expect(result.failingStep, 'permission');
    });

    test('subscribeIfPermissionGranted reads Notification.permission', () async {
      final result = await VapidSubscriptionService.subscribeIfPermissionGranted(
        service: OrderAlertService(Dio()),
      );

      expect(result.status, VapidSubscriptionStatus.permissionDenied);
      expect(result.message, contains('not yet granted'));
    });
  });

  group('WebPushRegistrationService in a real browser', () {
    test('diagnostics see the service worker container and the Notification API',
        () {
      final diagnostics = WebPushRegistrationService.captureEmergencyDiagnostics();

      expect(diagnostics.serviceWorkerSupported, isTrue);
      expect(diagnostics.notificationSupported, isTrue);
    });

    test('the messaging bridge reports the library missing when it is', () async {
      globalContext.delete('firebase_messaging'.toJS);

      final result =
          await WebPushRegistrationService.resolveTokenThroughMessagingBridge(
        JSObject() as web.ServiceWorkerRegistration,
      );

      expect(result.libraryAvailable, isFalse);
      expect(result.resolved, isFalse);
      expect(result.token, isNull);
    });

    test('the messaging bridge calls getMessaging/getToken and dartifies the token',
        () async {
      JSObject? seenOptions;
      final bridge = JSObject()
        ..setProperty('getMessaging'.toJS, (() => JSObject()).toJS)
        ..setProperty(
          'getToken'.toJS,
          ((JSAny? messaging, JSObject options) {
            seenOptions = options;
            return Future<JSAny?>.value(_fakeToken.toJS).toJS;
          }).toJS,
        );
      globalContext.setProperty('firebase_messaging'.toJS, bridge);
      addTearDown(() => globalContext.delete('firebase_messaging'.toJS));

      final registration = JSObject() as web.ServiceWorkerRegistration;
      final result =
          await WebPushRegistrationService.resolveTokenThroughMessagingBridge(
        registration,
      );

      expect(result.libraryAvailable, isTrue);
      expect(result.resolved, isTrue);
      expect(result.token, _fakeToken);
      // The options object is what Firebase's getToken keys on: the VAPID key
      // and the SAME registration we were handed, not a copy.
      expect(seenOptions, isNotNull);
      expect(seenOptions!.has('vapidKey'), isTrue);
      expect(
        identical(seenOptions!['serviceWorkerRegistration'], registration),
        isTrue,
      );
    });
  });

  group('WebNotificationClickService in a real browser', () {
    test('consumeInitialNotificationId reads the query and clears it from the URL',
        () {
      final original = web.window.location.href;
      web.window.history.pushState(null, '', '?notification=INV-2026-00042');
      addTearDown(() => web.window.history.replaceState(null, '', original));

      expect(
        WebNotificationClickService.consumeInitialNotificationId(),
        'INV-2026-00042',
      );
      expect(web.window.location.search, isEmpty);
    });

    test('consumeInitialNotificationId is null without the query param', () {
      expect(WebNotificationClickService.consumeInitialNotificationId(), isNull);
    });

    test('a service-worker click message reaches the stream; others do not',
        () async {
      final received = <String>[];
      final subscription =
          WebNotificationClickService.notificationClicks().listen(received.add);
      addTearDown(subscription.cancel);

      final serviceWorker = web.window.navigator.serviceWorker;
      serviceWorker.dispatchEvent(
        web.MessageEvent(
          'message',
          web.MessageEventInit(
            data: {
              'type': 'something_else',
              'url': 'https://erp.orderjarz.com/pos/?notification=IGNORED',
            }.jsify(),
          ),
        ),
      );
      serviceWorker.dispatchEvent(
        web.MessageEvent(
          'message',
          web.MessageEventInit(
            data: {
              'type': 'jarz_pos_notification_click',
              'url': 'https://erp.orderjarz.com/pos/?notification=INV-7',
            }.jsify(),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, ['INV-7']);
    });

    test('notificationIdFromMessage ignores payloads that are not objects', () {
      expect(
        WebNotificationClickService.notificationIdFromMessage('plain'.toJS),
        isNull,
      );
      expect(WebNotificationClickService.notificationIdFromMessage(null), isNull);
    });
  });
}
