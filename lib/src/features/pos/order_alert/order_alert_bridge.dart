import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/user_service.dart';
import '../../../core/websocket/websocket_service.dart';
import 'data/order_alert_service.dart';
import 'domain/invoice_alert.dart';
import 'order_alert_native_channel.dart';
import 'state/order_alert_controller.dart';

final orderAlertBridgeProvider = Provider<OrderAlertBridge>((ref) {
  final bridge = OrderAlertBridge(ref);
  ref.onDispose(bridge.dispose);
  return bridge;
});

class OrderAlertBridge {
  OrderAlertBridge(this._ref) {
    Future.microtask(_initialise);
  }

  final Ref _ref;
  final Logger _logger = Logger('OrderAlertBridge');

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  StreamSubscription<Map<String, dynamic>>? _invoiceStreamSub;
  bool _hasInit = false;

  Future<void> _initialise() async {
    if (_hasInit) return;
    _hasInit = true;

    await OrderAlertNativeChannel.ensureInitialised();
    OrderAlertNativeChannel.setLaunchHandler(_handleLaunchPayload);

    // Realtime fallback via websocket to guarantee in-app popups even if FCM is delayed.
    final ws = _ref.read(webSocketServiceProvider);
    _invoiceStreamSub = ws.invoiceStream.listen(_handleRealtimeInvoice, onError: (error) {
      _logger.error('Failed processing websocket invoice alert', error, StackTrace.current);
    });

    // Listen for authentication transitions
    _ref.listen<bool>(currentAuthStateProvider, (previous, next) {
      if (next) {
        unawaited(_onAuthenticated());
      } else {
        unawaited(_onLoggedOut());
      }
    }, fireImmediately: true);

    // Foreground message handling
    _onMessageSub = FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );

    // Process initial launch intent and background messages
    final launchPayload = await OrderAlertNativeChannel.consumeLaunchPayload();
    if (launchPayload != null) {
      _handleLaunchPayload(launchPayload);
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage, openedApp: true);
    }

    _onTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      unawaited(_registerToken(token));
    });

    // Request runtime permission (Android 13+)
    await FirebaseMessaging.instance.requestPermission();
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
    _onTokenRefreshSub?.cancel();
    _invoiceStreamSub?.cancel();
    OrderAlertNativeChannel.setLaunchHandler(null);
  }

  Future<void> _onAuthenticated() async {
    await _registerToken(await FirebaseMessaging.instance.getToken());
    await _ref.read(orderAlertControllerProvider.notifier).syncPendingAlerts();
  }

  Future<void> _onLoggedOut() async {
    final controller = _ref.read(orderAlertControllerProvider.notifier);
    await controller.clearAll();
    await controller.resetTokenCache();
  }

  void _handleRemoteMessage(RemoteMessage message, {bool openedApp = false}) {
    final data = message.data;
    if (data.isEmpty) {
      return;
    }
    final type = data['type'];
    _logger.info('FCM message received type=$type openedApp=$openedApp');
    switch (type) {
      case 'new_invoice':
        unawaited(_queueAlert(InvoiceAlert.fromFcmData(data)));
        unawaited(
          _ref.read(orderAlertControllerProvider.notifier).syncPendingAlerts(),
        );
        break;
      case 'invoice_accepted':
        final invoiceId = data['invoice_id']?.toString();
        if (invoiceId != null && invoiceId.isNotEmpty) {
          final controller = _ref.read(orderAlertControllerProvider.notifier);
          unawaited(controller.handleInvoiceAccepted(invoiceId));
          unawaited(controller.syncPendingAlerts());
        }
        break;
      default:
        _logger.debug('Ignored push message of type $type');
    }
  }

  void _handleLaunchPayload(Map<String, String> payload) {
    final type = payload['type'];
    if (type == 'new_invoice') {
      unawaited(_queueAlert(InvoiceAlert.fromFcmData(payload)));
      unawaited(
        _ref.read(orderAlertControllerProvider.notifier).syncPendingAlerts(),
      );
    } else if (type == 'invoice_accepted') {
      final invoiceId = payload['invoice_id'];
      if (invoiceId != null && invoiceId.isNotEmpty) {
        final controller = _ref.read(orderAlertControllerProvider.notifier);
        unawaited(controller.handleInvoiceAccepted(invoiceId));
        unawaited(controller.syncPendingAlerts());
      }
    }
  }

  Future<void> _queueAlert(InvoiceAlert alert) async {
    if (!alert.requiresAcceptance) {
      return;
    }
    await _ref
        .read(orderAlertControllerProvider.notifier)
        .enqueueAlert(alert, fromNotification: true);
  }

  void _handleRealtimeInvoice(Map<String, dynamic> payload) {
    try {
      _logger.info("Websocket invoice received: ${payload.toString()}");
      
      final alert = InvoiceAlert.fromDynamic(payload);
      final id = payload['name'] ?? payload['invoice_id'];
      final acceptanceStatus = payload['acceptance_status'] ?? payload['custom_acceptance_status'] ?? 'Unknown';
      
      _logger.info(
        "Websocket invoice payload name=$id "
        "requires=${alert.requiresAcceptance} "
        "acceptance=$acceptanceStatus "
        "posProfile=${alert.posProfile}"
      );
      
      if (!alert.requiresAcceptance) {
        _logger.info("Skipping invoice $id - does not require acceptance (status=$acceptanceStatus)");
        return;
      }
      
      final controller = _ref.read(orderAlertControllerProvider.notifier);
      _logger.info("Enqueuing alert for invoice $id");
      unawaited(controller.enqueueAlert(alert, fromNotification: false));
      
      // Sync pending alerts to ensure we have the latest from server
      unawaited(controller.syncPendingAlerts());
    } catch (error, stackTrace) {
      _logger.error('Failed to enqueue realtime invoice alert', error, stackTrace);
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) {
      _logger.warning('FCM token unavailable; registration skipped');
      return;
    }

    final isAuthenticated = _ref.read(currentAuthStateProvider);
    if (!isAuthenticated) {
      _logger.debug('Skipping token registration while logged out');
      return;
    }

    try {
      final userRoles = await _ref.read(userRolesFutureProvider.future);
      final user = userRoles.user;
      final controller = _ref.read(orderAlertControllerProvider.notifier);
      final shouldRegister = await controller.shouldRegisterToken(token, user);
      if (!shouldRegister) {
        _logger.debug('Token already registered for $user');
        return;
      }

      await _ref
          .read(orderAlertServiceProvider)
          .registerDevice(
            token: token,
            platform: 'Android',
            deviceName: 'Android POS',
          );
      await controller.markTokenRegistered(token, user);
      _logger.info('Registered FCM token for $user');
    } catch (error, stackTrace) {
      _logger.error('Failed to register FCM token', error, stackTrace);
      await _ref.read(orderAlertControllerProvider.notifier).resetTokenCache();
    }
  }
}
