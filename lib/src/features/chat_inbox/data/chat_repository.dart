import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio);
});

/// Talks to `jarz_pos.api.chat.*` (contract §3). Reads are GETs with query
/// parameters; every write is a POST. All of them are excluded from offline
/// replay, so a failure surfaces instead of re-sending a customer message.
class ChatRepository {
  final Dio _dio;
  ChatRepository(this._dio);

  /// `regenerate_draft` calls the model synchronously (up to ~20s server
  /// side), longer than the app's default receive timeout.
  static const regenerateTimeout = Duration(seconds: 40);

  String get baseUrl => _dio.options.baseUrl;

  /// The `message` payload, or the bare body when it is not enveloped.
  dynamic _payload(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _map(Response response) {
    final payload = _payload(response);
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return const <String, dynamic>{};
  }

  /// `get_conversations`. [status] is `Open` / `Answered` / `Closed` / `all`;
  /// [before] is the `last_message_at` of the last row already shown.
  Future<ChatConversationPage> fetchConversations({
    String status = ChatStatuses.open,
    String? channel,
    String? search,
    bool mine = false,
    int limit = 30,
    String? before,
  }) async {
    final trimmedSearch = search?.trim() ?? '';
    final response = await _dio.get(
      ApiEndpoints.chatGetConversations,
      queryParameters: {
        'status': status,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
        if (trimmedSearch.isNotEmpty) 'search': trimmedSearch,
        if (mine) 'mine': 1,
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
      },
    );
    return ChatConversationPage.fromJson(_payload(response));
  }

  /// `get_conversation` — header, messages (oldest → newest), the Pending
  /// draft and the customer card. Opening a thread resets its unread count,
  /// which is a write, so this is a POST (a forged GET must not mark it read).
  Future<ChatThread> fetchConversation(
    String name, {
    int limit = 50,
    String? before,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatGetConversation,
      data: {
        'name': name,
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
      },
    );
    return ChatThread.fromJson(_payload(response));
  }

  /// `send_message` — a reply typed from scratch.
  Future<ChatMessage> sendMessage({
    required String conversation,
    required String text,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatSendMessage,
      data: {'conversation': conversation, 'text': text},
    );
    return ChatMessage.fromJson(_map(response)['message']);
  }

  /// `send_draft` — the draft as-is or edited ([finalText] decides which).
  Future<ChatSendDraftResult> sendDraft({
    required String draft,
    required String finalText,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatSendDraft,
      data: {'draft': draft, 'final_text': finalText},
    );
    return ChatSendDraftResult.fromJson(_payload(response));
  }

  /// `reject_draft` with the moderator's [reason].
  Future<ChatRejectResult> rejectDraft({
    required String draft,
    required String reason,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatRejectDraft,
      data: {'draft': draft, 'reason': reason},
    );
    return ChatRejectResult.fromJson(_payload(response));
  }

  /// `regenerate_draft`, optionally steered by [hint].
  Future<ChatDraft?> regenerateDraft({
    required String conversation,
    String? hint,
  }) async {
    final trimmedHint = hint?.trim() ?? '';
    final response = await _dio.post(
      ApiEndpoints.chatRegenerateDraft,
      data: {
        'conversation': conversation,
        if (trimmedHint.isNotEmpty) 'hint': trimmedHint,
      },
      options: Options(receiveTimeout: regenerateTimeout),
    );
    return ChatDraft.maybeFromJson(_map(response)['draft']);
  }

  /// `assign_conversation`; an empty [user] assigns it to the caller.
  Future<ChatConversationSummary> assignConversation({
    required String conversation,
    String user = '',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatAssignConversation,
      data: {'conversation': conversation, 'user': user},
    );
    return ChatConversationSummary.fromJson(_map(response)['conversation']);
  }

  /// `set_conversation_status` — `Open` or `Closed`.
  Future<ChatConversationSummary> setConversationStatus({
    required String conversation,
    required String status,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatSetConversationStatus,
      data: {'conversation': conversation, 'status': status},
    );
    return ChatConversationSummary.fromJson(_map(response)['conversation']);
  }

  /// `link_customer`.
  Future<ChatLinkResult> linkCustomer({
    required String conversation,
    required String customer,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chatLinkCustomer,
      data: {'conversation': conversation, 'customer': customer},
    );
    return ChatLinkResult.fromJson(_payload(response));
  }

  /// `get_order_prefill` — what "Start order" hands to the POS.
  Future<ChatOrderPrefill> fetchOrderPrefill(String conversation) async {
    final response = await _dio.get(
      ApiEndpoints.chatGetOrderPrefill,
      queryParameters: {'conversation': conversation},
    );
    return ChatOrderPrefill.fromJson(_payload(response));
  }

  /// `get_chat_metrics` for `from_date`..`to_date` (`YYYY-MM-DD`, inclusive).
  Future<ChatMetrics> fetchMetrics({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.chatGetMetrics,
      queryParameters: {'from_date': fromDate, 'to_date': toDate},
    );
    return ChatMetrics.fromJson(_payload(response));
  }

  /// `get_unread_total` — the drawer badge.
  Future<ChatUnreadTotal> fetchUnreadTotal() async {
    final response = await _dio.get(ApiEndpoints.chatGetUnreadTotal);
    return ChatUnreadTotal.fromJson(_payload(response));
  }

  /// The POS customer search (name or phone), reused by "Link customer".
  Future<List<ChatCustomerOption>> searchCustomers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <ChatCustomerOption>[];
    final isPhone = RegExp(r'^[0-9+\-\s()]+$').hasMatch(trimmed);
    final response = await _dio.post(
      ApiEndpoints.searchCustomers,
      data: isPhone ? {'phone': trimmed} : {'name': trimmed},
    );
    final payload = _payload(response);
    if (payload is! List) return const <ChatCustomerOption>[];
    return payload
        .whereType<Map>()
        .map(ChatCustomerOption.fromJson)
        .where((c) => c.name.isNotEmpty)
        .toList(growable: false);
  }

  /// Whether [url] is a same-site file path this client may fetch with the
  /// session cookie. Absolute URLs are refused: the session interceptor would
  /// attach the cookie to whatever host they name.
  static bool isSessionMediaUrl(String? url) {
    final value = url?.trim() ?? '';
    return value.startsWith('/private/files/') || value.startsWith('/files/');
  }

  /// Bytes of a message attachment (`/private/files/...`), fetched with the
  /// session so private files work.
  Future<Uint8List> fetchMediaBytes(String mediaUrl) async {
    if (!isSessionMediaUrl(mediaUrl)) {
      throw ArgumentError.value(mediaUrl, 'mediaUrl', 'not a site file path');
    }
    final response = await _dio.get<List<int>>(
      mediaUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': '*/*'},
      ),
    );
    final data = response.data;
    if (data == null) throw Exception('Empty media response');
    return data is Uint8List ? data : Uint8List.fromList(data);
  }

  /// Absolute URL of a site file, for the browser (web) to open with its own
  /// cookie.
  String absoluteMediaUrl(String mediaUrl) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$base$mediaUrl';
  }
}
