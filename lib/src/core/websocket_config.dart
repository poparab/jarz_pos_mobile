import "dart:convert";
import "package:web_socket_channel/web_socket_channel.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "utils/logger.dart";

class WebSocketConfig {
  static final Logger _logger = Logger("WebSocketConfig");

  static String get _baseWsUrl {
    final httpUrl = dotenv.env["ERP_BASE_URL"] ?? "http://192.168.1.7:8000";
    // Convert HTTP URL to WebSocket URL
    return httpUrl
        .replaceFirst("http://", "ws://")
        .replaceFirst("https://", "wss://");
  }

  static String get kanbanUpdatesUrl => "$_baseWsUrl/kanban/updates";

  static WebSocketChannel createKanbanChannel() {
    _logger.info("Creating WebSocket connection to: $kanbanUpdatesUrl");
    return WebSocketChannel.connect(Uri.parse(kanbanUpdatesUrl));
  }

  static Map<String, dynamic>? parseMessage(dynamic message) {
    try {
      if (message is String) {
        return json.decode(message) as Map<String, dynamic>;
      }
      return message as Map<String, dynamic>?;
    } catch (e) {
      _logger.error("Error parsing WebSocket message", e);
      return null;
    }
  }

  static String encodeMessage(Map<String, dynamic> message) {
    return json.encode(message);
  }
}
