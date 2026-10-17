import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketio;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../constants/ws_events.dart';
import '../constants/timing_config.dart';
import '../network/cookie_manager.dart';
import '../router.dart';
import '../session/session_manager.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  socketio.Socket? _io;
  final _invoiceStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _posUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _kanbanUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _courierUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _shiftUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _branchAccessStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  /// Refused connects in a row; stretches the retry so a logged-out device or
  /// a broken proxy is not re-tried every 5 s for ever.
  int _failedConnects = 0;

  /// Bumped by [reconnect] and [disconnect]. An attempt that is still waiting
  /// on the stored sid when the session changes must not build a socket with
  /// the sid it read before the change.
  int _generation = 0;

  @visibleForTesting
  int get debugFailedConnects => _failedConnects;

  @visibleForTesting
  bool get debugShouldReconnect => _shouldReconnect;

  Stream<Map<String, dynamic>> get invoiceStream => _invoiceStreamController.stream;
  Stream<Map<String, dynamic>> get posUpdateStream => _posUpdateStreamController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get kanbanUpdates => _kanbanUpdateStreamController.stream;
  Stream<Map<String, dynamic>> get courierUpdates => _courierUpdateStreamController.stream;
  Stream<Map<String, dynamic>> get shiftUpdates => _shiftUpdateStreamController.stream;

  /// This user's branch access changed; re-read the POS branch list.
  Stream<Map<String, dynamic>> get branchAccessUpdates => _branchAccessStreamController.stream;

  /// `jarz_chat_update` payloads for the chat inbox, thread and badge.
  Stream<Map<String, dynamic>> get chatUpdates => _chatUpdateStreamController.stream;

  /// Every Socket.IO event this client binds a handler to.
  ///
  /// Public and named because binding and handling are two separate lists that
  /// must agree, and the failure when they do not is silent: socket.io only
  /// delivers events with a registered handler, so an event that is handled in
  /// [_handleWebSocketMessage] but missing here never arrives at all — no error,
  /// no log, the feature simply never updates. Exposing the list lets a test
  /// assert the two sides match instead of trusting a reviewer to notice.
  static const List<String> subscribedEvents = [
    WsEvents.newInvoice,
    WsEvents.invoiceStateChange,
    WsEvents.kanbanUpdate,
    WsEvents.outForDeliveryTransition,
    WsEvents.courierOutstanding,
    WsEvents.courierExpensePaid,
    WsEvents.courierSettled,
    // Sales Partner specific events
    WsEvents.salesPartnerCollectPrompt,
    WsEvents.salesPartnerUnpaidOfd,
    WsEvents.salesPartnerPaidOfd,
    // Courier app (COURIER_CONTRACTS §7)
    ...courierStopEvents,
    // Branch access (sent to the affected user only)
    WsEvents.branchAccessChanged,
    // Chat inbox (sent to chat-role users only)
    WsEvents.chatUpdate,
  ];

  /// Courier events that change a card's *contents* without moving it between
  /// columns, so the Kanban board has to re-read the invoice rather than animate
  /// a transition. The single definition both this service and the Kanban
  /// provider read, so the two can never drift apart.
  static const Set<String> courierStopEvents = {
    WsEvents.courierStopArrived,
    WsEvents.courierStopDelivered,
    WsEvents.courierStopFailed,
    WsEvents.addressPinUpdated,
  };

  /// Fallback when FRAPPE_SITE is unset: the docker site name on both servers.
  static const String defaultSiteNamespace = 'frontend';

  /// The Socket.IO URI for [base], on the `/<site>` namespace.
  ///
  /// Frappe's socket server authenticates and delivers events only on the
  /// namespace named after the site (`/frontend`). A client on the default `/`
  /// namespace connects and then hears nothing, which is how realtime stayed
  /// dead without a single error.
  @visibleForTesting
  static String socketIoUri(String base, String siteName) {
    var trimmed = base.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    final site = siteName.trim().isEmpty ? defaultSiteNamespace : siteName.trim();
    return '$trimmed/$site';
  }

  /// Headers the socket server needs to resolve this user.
  ///
  /// Frappe authenticates a socket by replaying its `sid` cookie against
  /// `frappe.realtime.get_user_info`; without it the connect is refused and the
  /// socket never joins the user's room, where `jarz_chat_update` is sent. On
  /// web the browser sends the cookie itself and refuses a scripted one.
  @visibleForTesting
  static Map<String, String> socketAuthHeaders(String? sessionId) {
    if (kIsWeb || sessionId == null || sessionId.isEmpty) return const {};
    return {'Cookie': 'sid=$sessionId'};
  }

  Future<String?> _readSessionId() async {
    try {
      return await SessionManager().getSessionId() ?? await CookieManager.getSessionId();
    } catch (_) {
      return null;
    }
  }

  socketio.Socket _buildSocket(String base, String siteName, String? sessionId) {
    return socketio.io(
      socketIoUri(base, siteName),
      socketio.OptionBuilder()
          .setPath('/socket.io/')
          .setQuery({'site_name': siteName})
          .setTransports(['websocket', 'polling'])
          .setExtraHeaders(socketAuthHeaders(sessionId))
          // A fresh manager per attempt, so a retry after login carries the new sid.
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );
  }

  void connect() {
    if (_isConnecting) return;
    _isConnecting = true;
    unawaited(_connect());
  }

  /// Drops the current socket and connects again at once with whatever sid is
  /// stored now.
  ///
  /// The socket is authenticated once, at connect, by the sid it carried. A
  /// live socket therefore keeps hearing the previous user's room after a
  /// logout and login, and one that was refused before login sits in the
  /// back-off for up to a minute. Called on every sign-in.
  void reconnect() {
    _generation++;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _dropTransport();
    _failedConnects = 0;
    _isConnecting = false;
    _shouldReconnect = true;
    connect();
  }

  void _dropTransport() {
    final io = _io;
    final channel = _channel;
    // Cleared before disposing, so the old socket's disconnect handler sees it
    // was replaced and does not schedule a retry of its own.
    _io = null;
    _channel = null;
    try { io?.dispose(); } catch (_) {}
    try { channel?.sink.close(); } catch (_) {}
  }

  Future<void> _connect() async {
    final generation = _generation;
  // Prefer explicit WEBSOCKET_URL. If not provided, DEFAULT TO SOCKET.IO at baseUrl/socket.io.
  // Only use raw ws when WEBSOCKET_URL explicitly contains a ws:// URL (optionally ending with /websocket or /ws).
  final explicit = dotenv.env['WEBSOCKET_URL'];
  final baseUrl = dotenv.env['ERP_BASE_URL'] ?? dotenv.env['API_BASE_URL'] ?? (throw StateError('ERP_BASE_URL env var is required'));
  final socketOverride = dotenv.env['SOCKET_IO_URL']; // e.g., http://192.168.1.5:9000
  // Frappe socket server segregates events per site; joining requires site name in query
  final siteName = dotenv.env['FRAPPE_SITE'] ?? dotenv.env['SITE_NAME'] ?? '';
  final useUrl = explicit; // may be null
    
    try {
  // Selection rules:
  // - If WEBSOCKET_URL is NOT set: use Socket.IO to baseUrl
  // - If WEBSOCKET_URL starts with ws:// or wss:// AND contains '/websocket' or '/ws': use raw WebSocket
  // - If WEBSOCKET_URL starts with http(s):// or contains 'socket.io': use Socket.IO
  final lower = (useUrl ?? '').toLowerCase();
  final hasExplicit = useUrl != null && useUrl.trim().isNotEmpty;
  final isExplicitWs = hasExplicit && (lower.startsWith('ws://') || lower.startsWith('wss://'));
  final isExplicitRawPath = isExplicitWs && (lower.contains('/websocket') || lower.contains('/ws'));
  final shouldUseSocketIo = !hasExplicit || lower.contains('socket.io') || lower.startsWith('http://') || lower.startsWith('https://');

  if (shouldUseSocketIo && !isExplicitRawPath) {
    final socketBase = (socketOverride != null && socketOverride.isNotEmpty) ? socketOverride : baseUrl;
    // Read on every attempt: the first connect usually runs before login, and
    // the reconnect after it is what carries the session.
    final sessionId = await _readSessionId();
    if (generation != _generation) return; // superseded by reconnect/disconnect
    if (!_shouldReconnect) {
      _isConnecting = false;
      return;
    }
    if (kDebugMode) {
      debugPrint('🔌 SOCKET.IO: Connecting to ${socketIoUri(socketBase, siteName)} '
          '(auth=${sessionId != null && sessionId.isNotEmpty})');
    }

    // Binds every handler to the current [_io]. Shared by the first attempt and
    // the :9000 retry so the retry hears the same events.
    void bindSocket({required bool allowAltRetry}) {
      final socket = _io!;
      socket.onConnect((_) {
        if (!identical(_io, socket)) return; // replaced before it got through
        if (kDebugMode) {
          debugPrint('✅ SOCKET.IO: Connected');
        }
        _failedConnects = 0;
        _connectionStatusController.add(true);
        _isConnecting = false;
        _subscribeToUpdates();
        _startHeartbeat();
      });
      // Listen to specific Frappe realtime events by name
      void bindEvent(String eventName) {
        socket.on(eventName, (payload) {
          try {
            if (payload is String) {
              final decoded = json.decode(payload);
              _handleWebSocketMessage({'event': eventName, 'data': decoded});
            } else if (payload is Map) {
              _handleWebSocketMessage({'event': eventName, 'data': Map<String, dynamic>.from(payload)});
            } else {
              _handleWebSocketMessage({'event': eventName, 'data': {}});
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ SOCKET.IO: Error handling $eventName: $e');
            }
          }
        });
      }
      for (final ev in subscribedEvents) { bindEvent(ev); }
      // Generic fallback
      socket.on(WsEvents.message, (data) {
        try {
          if (data is String) {
            final decoded = json.decode(data);
            _handleWebSocketMessage(decoded);
          } else if (data is Map<String, dynamic>) {
            _handleWebSocketMessage(Map<String, dynamic>.from(data));
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ SOCKET.IO: Error parsing message: $e');
          }
        }
      });
      socket.onDisconnect((_) {
        if (!identical(_io, socket)) return; // replaced on purpose
        if (kDebugMode) {
          debugPrint('🔌 SOCKET.IO: Disconnected');
        }
        _connectionStatusController.add(false);
        _isConnecting = false;
        if (_shouldReconnect) _scheduleReconnect();
      });
      void onFailure(dynamic err) {
        if (!identical(_io, socket)) return; // a stale socket we already replaced
        if (kDebugMode) {
          debugPrint('❌ SOCKET.IO: Error: $err');
        }
        _connectionStatusController.add(false);
        _isConnecting = false;
        // If no explicit SOCKET_IO_URL override and baseUrl looks like :8000, try :9000 once
        final noOverride = (socketOverride == null || socketOverride.isEmpty);
        if (allowAltRetry && noOverride && baseUrl.contains(':8000')) {
          try {
            final alt = baseUrl.replaceFirst(':8000', ':9000');
            if (kDebugMode) {
              debugPrint('🔁 SOCKET.IO: Retrying on ${socketIoUri(alt, siteName)}');
            }
            _io = _buildSocket(alt, siteName, sessionId);
            try { socket.dispose(); } catch (_) {}
            bindSocket(allowAltRetry: false);
            _io!.connect();
            return;
          } catch (_) {}
        }
        // The server refuses the namespace connect (no or expired sid) with a
        // connect_error, which socket.io does not retry by itself.
        _failedConnects++;
        try { socket.dispose(); } catch (_) {}
        if (_shouldReconnect) _scheduleReconnect();
      }
      socket.onConnectError(onFailure);
      socket.onError(onFailure);
    }

    final previous = _io;
    _io = _buildSocket(socketBase, siteName, sessionId);
    try { previous?.dispose(); } catch (_) {}
    bindSocket(allowAltRetry: true);
    _io!.connect();
  } else {
        // Raw WebSocket only when explicitly requested via WEBSOCKET_URL
  final endpoint = useUrl;
        if (kDebugMode) {
          debugPrint('🔌 WEBSOCKET: Connecting to $endpoint');
        }
        _channel = WebSocketChannel.connect(Uri.parse(endpoint));

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = json.decode(data);
            _handleWebSocketMessage(decoded);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ WEBSOCKET: Error parsing message: $e');
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('❌ WEBSOCKET: Connection error: $error');
          }
          _connectionStatusController.add(false);
          _isConnecting = false;
          if (_shouldReconnect) {
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('🔌 WEBSOCKET: Connection closed');
          }
          _connectionStatusController.add(false);
          _isConnecting = false;
          if (_shouldReconnect) {
            _scheduleReconnect();
          }
        },
      );
        // Send initial subscription
        _subscribeToUpdates();
        _connectionStatusController.add(true);
        _isConnecting = false;
        // Start heartbeat
        _startHeartbeat();
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ WEBSOCKET: Connection failed: $e');
      }
      _connectionStatusController.add(false);
      _isConnecting = false;
      if (_shouldReconnect) {
        _scheduleReconnect();
      }
    }
  }

  /// Feeds one decoded message through the same routing as a live socket.
  @visibleForTesting
  void debugHandleMessage(Map<String, dynamic> message) =>
      _handleWebSocketMessage(message);

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final event = message['event'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    switch (event) {
      case WsEvents.newInvoice:
        if (data != null) {
          _invoiceStreamController.add(data);
          if (kDebugMode) {
            debugPrint('📄 WEBSOCKET: New invoice (jarz) received: ${data['name']}');
          }
        }
        break;
      case WsEvents.newPosInvoice:
        if (data != null) {
          _invoiceStreamController.add(data);
          if (kDebugMode) {
            debugPrint('📄 WEBSOCKET: New invoice received: ${data['name']}');
          }
        }
        break;
      case WsEvents.posProfileUpdate:
        if (data != null) {
          _posUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🔄 WEBSOCKET: POS profile updated: ${data['profile']}');
          }
        }
        break;
      case WsEvents.itemStockUpdate:
        if (data != null) {
          _posUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('📦 WEBSOCKET: Stock updated for: ${data['item_code']}');
          }
        }
        break;
      case WsEvents.invoiceStateChange:
      case WsEvents.kanbanUpdate:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🗂️ WEBSOCKET: Kanban invoice state change ${data['invoice_id']} ${data['old_state']} -> ${data['new_state']}');
          }
        }
        break;
      case WsEvents.outForDeliveryTransition:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🚚 WEBSOCKET: Out For Delivery transition for ${data['invoice']} courier=${data['courier']}');
          }
        }
        break;
      case WsEvents.courierOutstanding:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          _courierUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🚚 WEBSOCKET: Courier Outstanding set for ${data['invoice']} courier=${data['courier']}');
          }
        }
        break;
      case WsEvents.courierSettled:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          _courierUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('✅ WEBSOCKET: Courier settled ${data['courier']}');
          }
        }
        break;
      case WsEvents.salesPartnerUnpaidOfd:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🤝 WEBSOCKET: Sales Partner unpaid OFD ${data['invoice']} PE=${data['payment_entry']}');
          }
        }
        break;
      case WsEvents.salesPartnerPaidOfd:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🤝 WEBSOCKET: Sales Partner paid OFD ${data['invoice']} DN=${data['delivery_note']}');
          }
        }
        break;
      case WsEvents.courierExpensePaid:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          _courierUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('💸 WEBSOCKET: Courier expense paid JE=${data['journal_entry']}');
          }
        }
        break;
      case WsEvents.salesPartnerCollectPrompt:
        if (data != null) {
          _kanbanUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('🤝 WEBSOCKET: Sales Partner collect prompt ${data['invoice']} amount=${data['amount']}');
          }
          // No dialog here: the Kanban provider shows the collect-cash dialog
          // for this event. A second one from this service stacked two dialogs.
        }
        break;
      // ── Courier stop outcomes (COURIER_CONTRACTS §7) ──────────────────
      // A courier's tap on Arrived / Delivered / Failed, and a pin correction on
      // the delivery address. All four change what a Kanban card should show
      // without changing the column the card sits in — a failed delivery
      // deliberately keeps the invoice at Out for Delivery (§5 invariant 4) — so
      // without these the board only tells the truth after a manual refresh.
      //
      // The case list mirrors [courierStopEvents], which the Kanban provider
      // dispatches on — keep the two together.
      case WsEvents.courierStopArrived:
      case WsEvents.courierStopDelivered:
      case WsEvents.courierStopFailed:
      case WsEvents.addressPinUpdated:
        if (data != null) {
          // Stamp the event name into the payload. The Kanban handler dispatches
          // on `data['event']`, and whether the backend includes that key is not
          // pinned by the contract — injecting it here makes the client correct
          // either way, and never overwrites a name the server did send.
          final enriched = Map<String, dynamic>.from(data);
          enriched.putIfAbsent('event', () => event);
          _kanbanUpdateStreamController.add(enriched);
          if (event != WsEvents.addressPinUpdated) {
            _courierUpdateStreamController.add(enriched);
          }
          if (kDebugMode) {
            debugPrint('🚚 WEBSOCKET: $event for ${enriched['invoice'] ?? enriched['invoice_id']}');
          }
        }
        break;
      case WsEvents.pong:
        // Heartbeat response
        break;
      case WsEvents.branchAccessChanged:
        // The payload is informational; the listener re-reads the whole list.
        _branchAccessStreamController.add(data ?? const <String, dynamic>{});
        break;
      case WsEvents.chatUpdate:
        if (data != null) {
          _chatUpdateStreamController.add(data);
        }
        break;
      case WsEvents.shiftStarted:
      case WsEvents.shiftEnded:
        if (data != null) {
          _shiftUpdateStreamController.add(data);
          if (kDebugMode) {
            debugPrint('📢 WEBSOCKET: Shift ${data['event_type']} by ${data['user_full_name']} on ${data['pos_profile']}');
          }
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint('🔔 WEBSOCKET: Unknown event: $event');
        }
    }
  }

  void _subscribeToUpdates() {
    if (_io != null) {
      // Nothing to send: once the sid authenticates, Frappe joins this socket
      // to its user room (and the site room for System Users) by itself.
    } else if (_channel != null) {
      // Subscribe to POS-related events
      _channel!.sink.add(json.encode({
        'event': WsEvents.actionSubscribe,
        'rooms': [WsEvents.roomPosUpdates, WsEvents.roomInvoiceUpdates, WsEvents.roomStockUpdates],
      }));
      if (kDebugMode) {
        print('✅ WEBSOCKET: Subscribed to updates');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(NetworkTimeouts.wsHeartbeat, (timer) {
      if (_io != null) {
        _io!.emit(WsEvents.actionPing, {});
      } else if (_channel != null) {
        _channel!.sink.add(json.encode({'event': WsEvents.actionPing}));
      }
    });
  }

  /// 5 s, doubling per refused connect, capped at a minute.
  @visibleForTesting
  static Duration reconnectDelayFor(int failedConnects) {
    final base = NetworkTimeouts.wsReconnectDelay;
    if (failedConnects <= 1) return base;
    final shift = failedConnects - 1 > 4 ? 4 : failedConnects - 1;
    final delay = base * (1 << shift);
    const cap = Duration(minutes: 1);
    return delay > cap ? cap : delay;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelayFor(_failedConnects), () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_io != null) {
      _io!.emit('message', message);
    } else if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  void disconnect() {
    _generation++;
    _shouldReconnect = false;
    _isConnecting = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _dropTransport();
    if (_connectionStatusController.isClosed) return;
    _connectionStatusController.add(false);
    if (kDebugMode) {
      debugPrint('🔌 WEBSOCKET: Disconnected');
    }
  }

  void dispose() {
    disconnect();
    _invoiceStreamController.close();
    _posUpdateStreamController.close();
    _connectionStatusController.close();
    _kanbanUpdateStreamController.close();
  _courierUpdateStreamController.close();
  _shiftUpdateStreamController.close();
    _branchAccessStreamController.close();
    _chatUpdateStreamController.close();
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  // Ensure connection starts when first watched
  // Safe to call repeatedly; service guards concurrent connects
  service.connect();
  followAuthState(ref, service);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Keeps [service] on the signed-in user's session.
///
/// The socket outlives a sign-in, and its sid is fixed when it connects. Sign
/// in: connect again with the new sid. Sign out: drop it, so the device stops
/// hearing the previous user's room and stops retrying a dead session.
@visibleForTesting
void followAuthState(Ref ref, WebSocketService service) {
  ref.listen<bool>(currentAuthStateProvider, (previous, next) {
    if (previous == next) return;
    if (next) {
      service.reconnect();
    } else {
      service.disconnect();
    }
  });
}
