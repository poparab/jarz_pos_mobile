import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketio;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../constants/ws_events.dart';
import '../constants/timing_config.dart';
import '../router.dart';
import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  socketio.Socket? _io;
  final _invoiceStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _posUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _kanbanUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _courierUpdateStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  Stream<Map<String, dynamic>> get invoiceStream => _invoiceStreamController.stream;
  Stream<Map<String, dynamic>> get posUpdateStream => _posUpdateStreamController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get kanbanUpdates => _kanbanUpdateStreamController.stream;
  Stream<Map<String, dynamic>> get courierUpdates => _courierUpdateStreamController.stream;

  void connect() {
    if (_isConnecting) return;
    _isConnecting = true;
    
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
    if (kDebugMode) {
      debugPrint('🔌 SOCKET.IO: Connecting to $socketBase/socket.io (site=$siteName)');
    }
    _io = socketio.io(socketBase,
      socketio.OptionBuilder()
          .setPath('/socket.io/')
          .setQuery({'site_name': siteName})
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build());

        _io!.onConnect((_) {
          if (kDebugMode) {
            debugPrint('✅ SOCKET.IO: Connected');
          }
          _connectionStatusController.add(true);
          _isConnecting = false;
          _subscribeToUpdates();
          _startHeartbeat();
        });
        // Listen to specific Frappe realtime events by name
        void bindEvent(String eventName) {
          _io!.on(eventName, (payload) {
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
        for (final ev in [
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
  ]) { bindEvent(ev); }
        // Generic fallback
        _io!.on(WsEvents.message, (data) {
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
        _io!.onDisconnect((_) {
          if (kDebugMode) {
            debugPrint('🔌 SOCKET.IO: Disconnected');
          }
          _connectionStatusController.add(false);
          _isConnecting = false;
          if (_shouldReconnect) _scheduleReconnect();
        });
        _io!.onError((err) {
          if (kDebugMode) {
            debugPrint('❌ SOCKET.IO: Error: $err');
          }
          _connectionStatusController.add(false);
          _isConnecting = false;
          // If no explicit SOCKET_IO_URL override and baseUrl looks like :8000, try :9000 once
          final noOverride = (socketOverride == null || socketOverride.isEmpty);
          if (noOverride && (baseUrl.contains(':8000'))) {
            try {
              final alt = baseUrl.replaceFirst(':8000', ':9000');
              if (kDebugMode) {
                debugPrint('🔁 SOCKET.IO: Retrying on $alt/socket.io (site=$siteName)');
              }
              _io?.dispose();
              _io = socketio.io(alt,
                socketio.OptionBuilder()
                    .setPath('/socket.io/')
                    .setQuery({'site_name': siteName})
                    .setTransports(['websocket', 'polling'])
                    .disableAutoConnect()
                    .build());
              _io!.onConnect((_) {
                if (kDebugMode) {
                  debugPrint('✅ SOCKET.IO: Connected (alt port)');
                }
                _connectionStatusController.add(true);
                _isConnecting = false;
                _subscribeToUpdates();
                _startHeartbeat();
              });
              _io!.onDisconnect((_) {
                if (kDebugMode) {
                  debugPrint('🔌 SOCKET.IO: Disconnected (alt port)');
                }
                _connectionStatusController.add(false);
                _isConnecting = false;
                if (_shouldReconnect) _scheduleReconnect();
              });
              _io!.onError((err2) {
                if (kDebugMode) {
                  debugPrint('❌ SOCKET.IO: Alt Error: $err2');
                }
                if (_shouldReconnect) _scheduleReconnect();
              });
              _io!.connect();
              return;
            } catch (_) {}
          }
          if (_shouldReconnect) _scheduleReconnect();
        });
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
          // Fire an immediate UI prompt using the global navigator if available
          try {
            final navigatorKey = rootNavigatorKey; // imported via router.dart
            final ctx = navigatorKey.currentContext;
            if (ctx != null) {
              final inv = (data['invoice'] ?? '').toString();
              final amtRaw = (data['outstanding'] ?? data['amount'] ?? '').toString();
              String amt = amtRaw;
              try { amt = double.parse(amtRaw).toStringAsFixed(2); } catch (_) {}
              showDialog(
                context: ctx,
                builder: (c) {
                  final dialogL10n = c.l10n;
                  return AlertDialog(
                    title: Text(dialogL10n.websocketCollectCashTitle),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amt,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(dialogL10n.websocketCollectCashMessage),
                        if (inv.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(dialogL10n.websocketInvoiceLabel(inv), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(),
                        child: Text(dialogL10n.commonOk),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (_) {}
        }
        break;
      case WsEvents.pong:
        // Heartbeat response
        break;
      default:
        if (kDebugMode) {
          debugPrint('🔔 WEBSOCKET: Unknown event: $event');
        }
    }
  }

  void _subscribeToUpdates() {
    if (_io != null) {
      // Frappe socket.io rooms: use event names per publish_realtime
      // For compatibility, emit a custom subscribe event consumed by a small server bridge (if any).
      // If none, rely on receiving global events (user="*") which requires no room join.
      // No-op for now.
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

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(NetworkTimeouts.wsReconnectDelay, () {
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
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
  try { _channel?.sink.close(); } catch (_) {}
    try { _io?.dispose(); } catch (_) {}
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
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  // Ensure connection starts when first watched
  // Safe to call repeatedly; service guards concurrent connects
  service.connect();
  ref.onDispose(() => service.dispose());
  return service;
});
