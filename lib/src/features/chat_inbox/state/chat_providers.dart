import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../../../core/websocket/websocket_service.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_models.dart';

/// The clock the inbox's "waiting N min" labels read. Overridden in tests.
final chatClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Subscribes [onEvent] to `jarz_chat_update`. Returns null when the socket
/// service cannot be built (no env in a test), so a screen still loads over
/// plain HTTP.
StreamSubscription<Map<String, dynamic>>? listenChatUpdates(
  Ref ref,
  void Function(ChatUpdateEvent event) onEvent,
) {
  try {
    final ws = ref.read(webSocketServiceProvider);
    return ws.chatUpdates.listen((raw) {
      final ChatUpdateEvent event;
      try {
        event = ChatUpdateEvent.fromJson(raw);
      } catch (_) {
        return;
      }
      if (event.conversation.isEmpty) return;
      onEvent(event);
    });
  } catch (_) {
    return null;
  }
}

String? _currentUser(Ref ref) =>
    ref.read(userRolesFutureProvider).valueOrNull?.user;

// ─────────────────────────────────────────────────────────────────────────
// Inbox
// ─────────────────────────────────────────────────────────────────────────

/// The inbox's segmented control.
enum ChatInboxSegment { open, mine, all, closed }

/// What the inbox is showing: segment, optional channel, search text.
class ChatInboxFilter {
  final ChatInboxSegment segment;
  final String? channel;
  final String search;

  const ChatInboxFilter({
    this.segment = ChatInboxSegment.open,
    this.channel,
    this.search = '',
  });

  /// `status` for `get_conversations`. "Mine" spans every status: the API
  /// has no "not closed" filter, and a moderator's own answered chats are
  /// still theirs.
  String get wireStatus => switch (segment) {
        ChatInboxSegment.open => ChatStatuses.open,
        ChatInboxSegment.closed => ChatStatuses.closed,
        ChatInboxSegment.mine || ChatInboxSegment.all => 'all',
      };

  bool get mine => segment == ChatInboxSegment.mine;
  bool get hasSearch => search.trim().isNotEmpty;

  ChatInboxFilter copyWith({
    ChatInboxSegment? segment,
    String? channel,
    bool clearChannel = false,
    String? search,
  }) {
    return ChatInboxFilter(
      segment: segment ?? this.segment,
      channel: clearChannel ? null : (channel ?? this.channel),
      search: search ?? this.search,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChatInboxFilter &&
      other.segment == segment &&
      other.channel == channel &&
      other.search == search;

  @override
  int get hashCode => Object.hash(segment, channel, search);
}

/// Whether [summary] belongs in a list loaded with [filter], judged locally
/// so a socket update can add, move or drop a row without a refetch. Search
/// is not re-implemented here: with a search active only rows already shown
/// are updated (see [ChatInboxNotifier.applySummary]).
bool chatSummaryMatchesFilter(
  ChatConversationSummary summary,
  ChatInboxFilter filter,
  String? currentUser,
) {
  if (filter.channel != null && summary.channel != filter.channel) {
    return false;
  }
  return switch (filter.segment) {
    ChatInboxSegment.open => summary.status == ChatStatuses.open,
    ChatInboxSegment.closed => summary.status == ChatStatuses.closed,
    ChatInboxSegment.mine =>
      currentUser != null && summary.assignedTo == currentUser,
    ChatInboxSegment.all => true,
  };
}

/// Newest activity first; rows with no timestamp sink to the bottom.
int compareChatSummaries(ChatConversationSummary a, ChatConversationSummary b) {
  final at = a.lastMessageAt ?? '';
  final bt = b.lastMessageAt ?? '';
  return bt.compareTo(at);
}

class ChatInboxState {
  final ChatInboxFilter filter;
  final List<ChatConversationSummary> conversations;
  final bool hasMore;
  final int openCount;
  final bool loadingMore;

  const ChatInboxState({
    this.filter = const ChatInboxFilter(),
    this.conversations = const <ChatConversationSummary>[],
    this.hasMore = false,
    this.openCount = 0,
    this.loadingMore = false,
  });

  ChatInboxState copyWith({
    ChatInboxFilter? filter,
    List<ChatConversationSummary>? conversations,
    bool? hasMore,
    int? openCount,
    bool? loadingMore,
  }) {
    return ChatInboxState(
      filter: filter ?? this.filter,
      conversations: conversations ?? this.conversations,
      hasMore: hasMore ?? this.hasMore,
      openCount: openCount ?? this.openCount,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class ChatInboxNotifier extends AutoDisposeAsyncNotifier<ChatInboxState> {
  static const pageSize = 30;

  ChatInboxFilter _filter = const ChatInboxFilter();
  int _requestSeq = 0;

  ChatInboxFilter get filter => _filter;

  @override
  Future<ChatInboxState> build() async {
    final sub = listenChatUpdates(ref, _onChatUpdate);
    ref.onDispose(() => sub?.cancel());
    return _load(_filter);
  }

  Future<ChatInboxState> _load(ChatInboxFilter filter) async {
    final page = await ref.read(chatRepositoryProvider).fetchConversations(
          status: filter.wireStatus,
          channel: filter.channel,
          search: filter.search,
          mine: filter.mine,
          limit: pageSize,
        );
    return ChatInboxState(
      filter: filter,
      conversations: page.conversations,
      hasMore: page.hasMore,
      openCount: page.openCount,
    );
  }

  /// Reload with the current filter. The old rows stay on screen meanwhile;
  /// a slower, older request never overwrites a newer one.
  Future<void> refresh() => _reload(_filter);

  Future<void> setFilter(ChatInboxFilter filter) async {
    if (filter == _filter && state.hasValue) return;
    _filter = filter;
    await _reload(filter);
  }

  Future<void> _reload(ChatInboxFilter filter) async {
    final seq = ++_requestSeq;
    state = const AsyncLoading<ChatInboxState>().copyWithPrevious(state);
    final next = await AsyncValue.guard(() => _load(filter));
    if (seq != _requestSeq) return;
    state = next;
  }

  /// Next page, keyed on the last row's `last_message_at`.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    if (current.conversations.isEmpty) return;
    final seq = _requestSeq;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref.read(chatRepositoryProvider).fetchConversations(
            status: current.filter.wireStatus,
            channel: current.filter.channel,
            search: current.filter.search,
            mine: current.filter.mine,
            limit: pageSize,
            before: current.conversations.last.lastMessageAt,
          );
      if (seq != _requestSeq) return;
      final latest = state.valueOrNull ?? current;
      final seen = latest.conversations.map((c) => c.name).toSet();
      state = AsyncData(latest.copyWith(
        conversations: [
          ...latest.conversations,
          ...page.conversations.where((c) => !seen.contains(c.name)),
        ],
        hasMore: page.hasMore,
        loadingMore: false,
      ));
    } catch (_) {
      if (seq != _requestSeq) return;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(loadingMore: false));
      rethrow;
    }
  }

  /// Merge a fresh summary (socket event or the thread's own mutation):
  /// update, insert, or drop the row depending on whether it still matches.
  void applySummary(ChatConversationSummary summary) {
    final current = state.valueOrNull;
    if (current == null || summary.name.isEmpty) return;
    final rows = [...current.conversations];
    final index = rows.indexWhere((c) => c.name == summary.name);
    final matches =
        chatSummaryMatchesFilter(summary, current.filter, _currentUser(ref));
    if (matches) {
      if (index >= 0) {
        rows[index] = summary;
      } else if (current.filter.hasSearch) {
        // Cannot tell locally whether it matches the search text.
        return;
      } else {
        rows.add(summary);
      }
      rows.sort(compareChatSummaries);
    } else if (index >= 0) {
      rows.removeAt(index);
    } else {
      return;
    }
    state = AsyncData(current.copyWith(conversations: rows));
  }

  /// Zero a row's unread count when its thread is opened.
  void markRead(String name) {
    final current = state.valueOrNull;
    if (current == null) return;
    final index = current.conversations.indexWhere((c) => c.name == name);
    if (index < 0 || current.conversations[index].unreadCount == 0) return;
    final rows = [...current.conversations];
    rows[index] = rows[index].copyWith(unreadCount: 0);
    state = AsyncData(current.copyWith(conversations: rows));
  }

  void _onChatUpdate(ChatUpdateEvent event) {
    final summary = event.summary;
    if (summary != null) applySummary(summary);
  }
}

final chatInboxProvider =
    AsyncNotifierProvider.autoDispose<ChatInboxNotifier, ChatInboxState>(
  ChatInboxNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────
// Thread
// ─────────────────────────────────────────────────────────────────────────

class ChatThreadState {
  final ChatConversationSummary conversation;

  /// Oldest → newest.
  final List<ChatMessage> messages;

  /// The draft in the panel: Pending, or Failed ("draft unavailable").
  final ChatDraft? draft;
  final ChatCustomerCard? customer;
  final bool hasMoreOlder;
  final bool loadingOlder;

  const ChatThreadState({
    required this.conversation,
    this.messages = const <ChatMessage>[],
    this.draft,
    this.customer,
    this.hasMoreOlder = false,
    this.loadingOlder = false,
  });

  ChatThreadState copyWith({
    ChatConversationSummary? conversation,
    List<ChatMessage>? messages,
    ChatDraft? draft,
    bool clearDraft = false,
    ChatCustomerCard? customer,
    bool? hasMoreOlder,
    bool? loadingOlder,
  }) {
    return ChatThreadState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      draft: clearDraft ? null : (draft ?? this.draft),
      customer: customer ?? this.customer,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      loadingOlder: loadingOlder ?? this.loadingOlder,
    );
  }
}

/// Union of two message lists by `name` ([incoming] wins), oldest → newest.
/// Timestamps are `YYYY-MM-DD HH:MM:SS`, so string order is time order; the
/// sort is stable, so equal timestamps keep their arrival order.
List<ChatMessage> mergeChatMessages(
  List<ChatMessage> existing,
  List<ChatMessage> incoming,
) {
  final byName = <String, ChatMessage>{};
  final order = <String>[];
  for (final message in [...existing, ...incoming]) {
    final key = message.name.isEmpty
        ? 'anon-${order.length}'
        : message.name;
    if (!byName.containsKey(key)) order.add(key);
    byName[key] = message;
  }
  final merged = [for (final key in order) byName[key]!];
  final indexed = merged.asMap().entries.toList()
    ..sort((a, b) {
      final at = a.value.timestamp ?? '￿';
      final bt = b.value.timestamp ?? '￿';
      final byTime = at.compareTo(bt);
      return byTime != 0 ? byTime : a.key.compareTo(b.key);
    });
  return [for (final entry in indexed) entry.value];
}

/// Whether [draft] belongs in the draft panel.
bool chatDraftIsShowable(ChatDraft? draft) =>
    draft != null && (draft.isPending || draft.isFailed);

class ChatThreadNotifier
    extends AutoDisposeFamilyAsyncNotifier<ChatThreadState, String> {
  static const pageSize = 50;

  Timer? _silentRefresh;

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  @override
  Future<ChatThreadState> build(String arg) async {
    final sub = listenChatUpdates(ref, _onChatUpdate);
    ref.onDispose(() {
      sub?.cancel();
      _silentRefresh?.cancel();
    });
    final thread = await _repo.fetchConversation(arg, limit: pageSize);
    _afterServerRead(thread.conversation);
    return ChatThreadState(
      conversation: thread.conversation,
      messages: thread.messages,
      draft: thread.draft,
      customer: thread.customer,
      hasMoreOlder: thread.messages.length >= pageSize,
    );
  }

  /// `get_conversation` reset the unread count; reflect that in the inbox
  /// row and the drawer badge.
  void _afterServerRead(ChatConversationSummary conversation) {
    if (ref.exists(chatInboxProvider)) {
      final inbox = ref.read(chatInboxProvider.notifier);
      inbox.applySummary(conversation.copyWith(unreadCount: 0));
      inbox.markRead(conversation.name);
    }
    if (ref.exists(chatUnreadTotalProvider)) {
      ref.invalidate(chatUnreadTotalProvider);
    }
  }

  void _publishSummary(ChatConversationSummary summary) {
    if (summary.name.isEmpty) return;
    if (ref.exists(chatInboxProvider)) {
      ref.read(chatInboxProvider.notifier).applySummary(summary);
    }
  }

  /// Re-read the newest page and merge it, keeping older pages already
  /// loaded. Errors are swallowed unless [silent] is false.
  Future<void> refresh({bool silent = true}) async {
    try {
      final thread = await _repo.fetchConversation(arg, limit: pageSize);
      final current = state.valueOrNull;
      if (current == null) {
        state = AsyncData(ChatThreadState(
          conversation: thread.conversation,
          messages: thread.messages,
          draft: thread.draft,
          customer: thread.customer,
          hasMoreOlder: thread.messages.length >= pageSize,
        ));
      } else {
        // `get_conversation` only returns a Pending draft; keep a Failed one
        // the socket delivered, so "draft unavailable" does not vanish.
        final keepFailed = thread.draft == null &&
            (current.draft?.isFailed ?? false);
        state = AsyncData(current.copyWith(
          conversation: thread.conversation,
          messages: mergeChatMessages(current.messages, thread.messages),
          draft: thread.draft,
          clearDraft: thread.draft == null && !keepFailed,
          customer: thread.customer,
        ));
      }
      _afterServerRead(thread.conversation);
    } catch (e, st) {
      if (!silent) {
        state = AsyncError<ChatThreadState>(e, st).copyWithPrevious(state);
      }
    }
  }

  Future<void> loadOlder() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMoreOlder || current.loadingOlder) {
      return;
    }
    if (current.messages.isEmpty) return;
    state = AsyncData(current.copyWith(loadingOlder: true));
    try {
      final page = await _repo.fetchConversation(
        arg,
        limit: pageSize,
        before: current.messages.first.timestamp,
      );
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(
        messages: mergeChatMessages(page.messages, latest.messages),
        hasMoreOlder: page.messages.length >= pageSize,
        loadingOlder: false,
      ));
    } catch (_) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(loadingOlder: false));
      rethrow;
    }
  }

  void _update(ChatThreadState Function(ChatThreadState s) change) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(change(current));
  }

  void _appendMessage(ChatMessage? message) {
    if (message == null || message.name.isEmpty) return;
    _update((s) => s.copyWith(messages: mergeChatMessages(s.messages, [message])));
  }

  /// `send_draft`. Returns the full result so the screen can show the
  /// planted-draft dialog.
  Future<ChatSendDraftResult> sendDraft({
    required String draft,
    required String finalText,
  }) async {
    final result = await _repo.sendDraft(draft: draft, finalText: finalText);
    _appendMessage(result.message);
    final next = result.nextDraft;
    _update((s) => chatDraftIsShowable(next)
        ? s.copyWith(draft: next)
        : s.copyWith(clearDraft: true));
    unawaited(refresh());
    return result;
  }

  Future<ChatRejectResult> rejectDraft({
    required String draft,
    required String reason,
  }) async {
    final result = await _repo.rejectDraft(draft: draft, reason: reason);
    final next = result.nextDraft;
    _update((s) => chatDraftIsShowable(next)
        ? s.copyWith(draft: next)
        : s.copyWith(clearDraft: true));
    return result;
  }

  Future<ChatDraft?> regenerateDraft({String? hint}) async {
    final draft = await _repo.regenerateDraft(conversation: arg, hint: hint);
    _update((s) => draft != null
        ? s.copyWith(draft: draft)
        : s.copyWith(clearDraft: true));
    return draft;
  }

  /// A reply typed from scratch; it supersedes any Pending draft.
  Future<ChatMessage> sendMessage(String text) async {
    final message = await _repo.sendMessage(conversation: arg, text: text);
    _appendMessage(message);
    _update((s) => s.copyWith(clearDraft: true));
    unawaited(refresh());
    return message;
  }

  Future<void> assignToMe() async {
    final summary = await _repo.assignConversation(conversation: arg);
    _update((s) => s.copyWith(conversation: summary));
    _publishSummary(summary);
  }

  Future<void> setStatus(String status) async {
    final summary =
        await _repo.setConversationStatus(conversation: arg, status: status);
    _update((s) => s.copyWith(conversation: summary));
    _publishSummary(summary);
    if (ref.exists(chatUnreadTotalProvider)) {
      ref.invalidate(chatUnreadTotalProvider);
    }
  }

  Future<ChatLinkResult> linkCustomer(String customer) async {
    final result =
        await _repo.linkCustomer(conversation: arg, customer: customer);
    _update((s) => s.copyWith(
          conversation: result.conversation,
          customer: result.customer,
        ));
    _publishSummary(result.conversation);
    return result;
  }

  Future<ChatOrderPrefill> orderPrefill() => _repo.fetchOrderPrefill(arg);

  void _onChatUpdate(ChatUpdateEvent event) {
    if (event.conversation != arg) return;
    final current = state.valueOrNull;
    if (current == null) return;
    var next = current;
    final summary = event.summary;
    if (summary != null) next = next.copyWith(conversation: summary);
    final message = event.message;
    if (message != null && message.name.isNotEmpty) {
      next = next.copyWith(
        messages: mergeChatMessages(next.messages, [message]),
      );
    }
    final draft = event.draft;
    if (draft != null) {
      if (chatDraftIsShowable(draft)) {
        next = next.copyWith(draft: draft);
      } else if (next.draft?.name == draft.name) {
        next = next.copyWith(clearDraft: true);
      }
    } else if (summary != null &&
        !summary.hasPendingDraft &&
        (next.draft?.isPending ?? false) &&
        message != null &&
        message.isOutbound) {
      // An outbound (app or phone echo) superseded the Pending draft.
      next = next.copyWith(clearDraft: true);
    }
    state = AsyncData(next);

    if (message != null && message.isInbound) {
      // The server counts this as unread until the thread is read again;
      // re-read it shortly (debounced across a burst) while it is on screen.
      _silentRefresh?.cancel();
      _silentRefresh = Timer(const Duration(seconds: 2), () {
        unawaited(refresh());
      });
    }
  }
}

final chatThreadProvider = AsyncNotifierProvider.autoDispose
    .family<ChatThreadNotifier, ChatThreadState, String>(
  ChatThreadNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────
// Badge, media, metrics
// ─────────────────────────────────────────────────────────────────────────

/// `get_unread_total` for the drawer badge. Zero for users without a chat
/// role (no call is made) and on any error: a badge must never break the
/// drawer. Re-reads itself, debounced, on every `jarz_chat_update`.
final chatUnreadTotalProvider =
    FutureProvider.autoDispose<ChatUnreadTotal>((ref) async {
  if (!ref.watch(canAccessChatsProvider)) return ChatUnreadTotal.zero;
  Timer? debounce;
  final sub = listenChatUpdates(ref, (_) {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 2), ref.invalidateSelf);
  });
  ref.onDispose(() {
    debounce?.cancel();
    sub?.cancel();
  });
  try {
    return await ref.read(chatRepositoryProvider).fetchUnreadTotal();
  } catch (_) {
    return ChatUnreadTotal.zero;
  }
});

/// Bytes of a message image, fetched with the session. Kept five minutes
/// after the last viewer scrolls away, like task attachment thumbnails.
final chatMediaBytesProvider =
    FutureProvider.autoDispose.family<Uint8List, String>((ref, url) async {
  final bytes = await ref.watch(chatRepositoryProvider).fetchMediaBytes(url);
  final link = ref.keepAlive();
  Timer? release;
  ref.onCancel(() => release = Timer(const Duration(minutes: 5), link.close));
  ref.onResume(() => release?.cancel());
  ref.onDispose(() => release?.cancel());
  return bytes;
});

/// `get_chat_metrics` for an inclusive `YYYY-MM-DD` range.
final chatMetricsProvider = FutureProvider.autoDispose
    .family<ChatMetrics, ({String from, String to})>((ref, range) {
  return ref
      .read(chatRepositoryProvider)
      .fetchMetrics(fromDate: range.from, toDate: range.to);
});

/// Called by the push bridge on a `chat_waiting` push: refresh whatever chat
/// state is already alive, and nothing that is not.
void refreshChatsAfterPush(Ref ref, {String? conversation}) {
  ref.invalidate(chatUnreadTotalProvider);
  if (ref.exists(chatInboxProvider)) {
    unawaited(ref.read(chatInboxProvider.notifier).refresh());
  }
  final name = conversation?.trim() ?? '';
  if (name.isNotEmpty && ref.exists(chatThreadProvider(name))) {
    unawaited(ref.read(chatThreadProvider(name).notifier).refresh());
  }
}
