// Chat inbox live behaviour without realtime events: the Open segment means
// "not Closed" (sent as status=all + exclude_closed, and Closed rows dropped
// on the client for an older backend, paging on the RAW server cursor), the
// inbox and thread polling timers (merge in place, back off after an error,
// pause in the background, stop on dispose), and a poll never undoing a send.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/chat_repository.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/chat_inbox/state/chat_providers.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

typedef _Handler = FutureOr<dynamic> Function(
  String method,
  String path,
  Map<String, dynamic>? query,
);

/// A [MockDio] whose answers are computed per call, so a test can change the
/// server's reply between polls, gate one reply, or fail one.
class _ScriptedDio extends MockDio {
  _ScriptedDio(this.handler);

  final _Handler handler;

  int count(String path) =>
      requestLog.where((r) => r['path'] == path).length;

  Future<Response<T>> _answer<T>(
    String method,
    String path,
    Object? data,
    Map<String, dynamic>? query,
  ) async {
    requestLog.add({
      'method': method,
      'path': path,
      'data': data,
      'queryParameters': query,
    });
    final body = await handler(method, path, query);
    return Response<T>(
      data: body as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _answer<T>('GET', path, data, queryParameters);

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _answer<T>('POST', path, data, queryParameters);
}

const _conv = 'CHAT-1';

Map<String, dynamic> _row(
  String name,
  String status,
  String lastAt, {
  int unread = 0,
}) =>
    {
      'name': name,
      'channel': 'WhatsApp',
      'status': status,
      'last_message_at': lastAt,
      'unread_count': unread,
    };

Map<String, dynamic> _page(
  List<Map<String, dynamic>> rows, {
  bool? hasMore,
  int openCount = 0,
}) =>
    {
      'message': {
        'conversations': rows,
        if (hasMore != null) 'has_more': hasMore ? 1 : 0,
        'open_count': openCount,
      },
    };

Map<String, dynamic> _thread(List<String> messages, {String? draft}) => {
      'message': {
        'conversation': _row(_conv, 'Open', '2026-10-16 10:00:00'),
        'messages': [
          for (var i = 0; i < messages.length; i++)
            {
              'name': messages[i],
              'body': messages[i],
              'direction': 'Inbound',
              'timestamp': '2026-10-16 10:0$i:00',
            },
        ],
        if (draft != null)
          'draft': {'name': draft, 'status': 'Pending', 'draft_text': 'Hi!'},
      },
    };

ProviderContainer _container(MockDio dio) => ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(ChatRepository(dio)),
        userRolesFutureProvider.overrideWith(
          (ref) async => UserRoles(
            user: 'mod@jarz.test',
            fullName: 'Mod',
            roles: const ['Moderator'],
            requirePosShift: false,
            canAccessB2b: false,
            isB2bSalesRep: false,
          ),
        ),
        webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
        chatUnreadTotalProvider
            .overrideWith((ref) async => ChatUnreadTotal.zero),
      ],
    );

List<String> _names(ProviderContainer c) => c
    .read(chatInboxProvider)
    .requireValue
    .conversations
    .map((s) => s.name)
    .toList();

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('Open = not Closed', () {
    test('Closed rows are dropped on the client; pages key on the raw cursor',
        () async {
      final dio = _ScriptedDio((method, path, query) {
        final before = query?['before'];
        if (before == null) {
          return _page([
            _row('A', 'Open', '2026-10-16 10:05:00'),
            _row('B', 'Closed', '2026-10-16 10:04:00'),
            _row('C', 'Answered', '2026-10-16 10:03:00'),
            _row('D', 'Closed', '2026-10-16 10:02:00'),
          ], hasMore: true, openCount: 1);
        }
        if (before == '2026-10-16 10:02:00') {
          return _page(
            [_row('E', 'Answered', '2026-10-16 09:00:00')],
            hasMore: false,
          );
        }
        throw StateError('unexpected cursor $before');
      });
      final container = _container(dio);
      addTearDown(container.dispose);
      final sub = container.listen(chatInboxProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(chatInboxProvider.future);

      expect(dio.requestLog.single['queryParameters'], {
        'status': 'all',
        'exclude_closed': 1,
        'limit': 30,
      });
      final first = container.read(chatInboxProvider).requireValue;
      expect(first.conversations.map((c) => c.name), ['A', 'C']);
      expect(first.hasMore, isTrue);
      // The cursor is the last RAW row (Closed D), not the last shown (C).
      expect(first.nextBefore, '2026-10-16 10:02:00');

      await container.read(chatInboxProvider.notifier).loadMore();
      expect(dio.requestLog.last['queryParameters']['before'],
          '2026-10-16 10:02:00');
      final second = container.read(chatInboxProvider).requireValue;
      expect(second.conversations.map((c) => c.name), ['A', 'C', 'E']);
      expect(second.hasMore, isFalse);
    });

    test('a raw page of only Closed rows reads on instead of showing nothing',
        () async {
      final dio = _ScriptedDio((method, path, query) {
        if (query?['before'] == null) {
          return _page([
            _row('X', 'Closed', '2026-10-16 10:05:00'),
            _row('Y', 'Closed', '2026-10-16 10:04:00'),
          ], hasMore: true);
        }
        return _page([_row('Z', 'Open', '2026-10-16 09:00:00')]);
      });
      final container = _container(dio);
      addTearDown(container.dispose);
      final sub = container.listen(chatInboxProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(chatInboxProvider.future);

      expect(_names(container), ['Z']);
      expect(dio.requestLog, hasLength(2));
      expect(dio.requestLog.last['queryParameters']['before'],
          '2026-10-16 10:04:00');
    });

    test('"has more" is judged on the raw page size, not the filtered rows',
        () async {
      final dio = _ScriptedDio((method, path, query) {
        return _page([
          _row('A', 'Open', '2026-10-16 10:59:00'),
          for (var i = 0; i < 29; i++)
            _row('C$i', 'Closed',
                '2026-10-16 10:${(30 - i).toString().padLeft(2, '0')}:00'),
        ]);
      });
      final container = _container(dio);
      addTearDown(container.dispose);
      final sub = container.listen(chatInboxProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(chatInboxProvider.future);

      final state = container.read(chatInboxProvider).requireValue;
      expect(state.conversations.map((c) => c.name), ['A']);
      expect(state.hasMore, isTrue);
      expect(state.nextBefore, '2026-10-16 10:02:00');
    });
  });

  group('mergeChatInboxFirstPage', () {
    ChatConversationSummary s(String name, String at,
            {String status = 'Open'}) =>
        ChatConversationSummary.fromJson(_row(name, status, at));

    test('replaces the fresh window, keeps older loaded pages and the cursor',
        () {
      final latest = ChatInboxState(
        conversations: [
          s('A', '2026-10-16 10:05:00'),
          s('B', '2026-10-16 10:03:00'),
          s('C', '2026-10-16 09:00:00'),
        ],
        hasMore: true,
        openCount: 2,
        nextBefore: '2026-10-16 09:00:00',
      );
      final merged = mergeChatInboxFirstPage(
        latest,
        ChatInboxFetch(
          rows: [
            s('A', '2026-10-16 10:05:00', status: 'Answered'),
            s('N', '2026-10-16 10:10:00'),
          ],
          cursor: '2026-10-16 10:02:00',
          hasMore: true,
          openCount: 1,
        ),
      );
      // B fell inside the fresh window but is gone (closed elsewhere); C is
      // on a later page and stays; the scroll cursor is not reset.
      expect(merged.conversations.map((c) => c.name), ['N', 'A', 'C']);
      expect(merged.conversations[1].status, 'Answered');
      expect(merged.nextBefore, '2026-10-16 09:00:00');
      expect(merged.hasMore, isTrue);
      expect(merged.openCount, 1);
    });

    test('a complete fresh page replaces the list', () {
      final latest = ChatInboxState(
        conversations: [s('A', '2026-10-16 10:05:00')],
        hasMore: true,
        nextBefore: '2026-10-16 10:05:00',
      );
      final merged = mergeChatInboxFirstPage(
        latest,
        ChatInboxFetch(
          rows: [s('B', '2026-10-16 10:06:00')],
          cursor: '2026-10-16 10:06:00',
          hasMore: false,
          openCount: 1,
        ),
      );
      expect(merged.conversations.map((c) => c.name), ['B']);
      expect(merged.hasMore, isFalse);
      expect(merged.nextBefore, '2026-10-16 10:06:00');
    });
  });

  group('polling', () {
    testWidgets(
        'inbox re-reads its first page every 15 s, pauses in the background, '
        'stops on dispose', (tester) async {
      var round = 0;
      final dio = _ScriptedDio((method, path, query) {
        round++;
        if (round == 1) {
          return _page([_row('A', 'Open', '2026-10-16 10:00:00', unread: 1)],
              openCount: 1);
        }
        return _page([
          _row('B', 'Open', '2026-10-16 10:06:00', unread: 1),
          _row('A', 'Answered', '2026-10-16 10:05:00'),
        ], openCount: 1);
      });
      final container = _container(dio);
      final sub = container.listen(chatInboxProvider, (_, _) {});
      await _settle(tester);
      expect(_names(container), ['A']);
      final reads = dio.count(ApiEndpoints.chatGetConversations);
      expect(reads, 1);

      await tester.pump(const Duration(seconds: 14));
      expect(dio.count(ApiEndpoints.chatGetConversations), 1);
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);
      expect(dio.count(ApiEndpoints.chatGetConversations), 2);
      // Merged in place: the new chat on top, the answered one still listed.
      expect(_names(container), ['B', 'A']);
      expect(
        container.read(chatInboxProvider).requireValue.conversations[1].status,
        'Answered',
      );
      expect(container.read(chatInboxProvider).isLoading, isFalse);

      // Backgrounded: no polling.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 45));
      await _settle(tester);
      expect(dio.count(ApiEndpoints.chatGetConversations), 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 15));
      await _settle(tester);
      expect(dio.count(ApiEndpoints.chatGetConversations), 3);

      sub.close();
      container.dispose();
      await tester.pump(const Duration(minutes: 2));
      expect(dio.count(ApiEndpoints.chatGetConversations), 3);
    });

    testWidgets(
        'thread re-reads every 5 s and shows new messages, backs off after an '
        'error, stops on dispose', (tester) async {
      var reads = 0;
      final dio = _ScriptedDio((method, path, query) {
        if (path != ApiEndpoints.chatGetConversation) {
          return _page(const []);
        }
        reads++;
        if (reads == 1) return _thread(['M1']);
        if (reads == 3) throw StateError('network down');
        return _thread(['M1', 'M2']);
      });
      final container = _container(dio);
      final sub = container.listen(chatThreadProvider(_conv), (_, _) {});
      await _settle(tester);
      List<String> messages() => container
          .read(chatThreadProvider(_conv))
          .requireValue
          .messages
          .map((m) => m.name)
          .toList();
      expect(messages(), ['M1']);

      await tester.pump(const Duration(seconds: 5));
      await _settle(tester);
      expect(reads, 2);
      expect(messages(), ['M1', 'M2']);

      // The third read fails silently ...
      await tester.pump(const Duration(seconds: 5));
      await _settle(tester);
      expect(reads, 3);
      expect(container.read(chatThreadProvider(_conv)).hasError, isFalse);
      expect(messages(), ['M1', 'M2']);
      // ... and the next one waits 15 s, not 5.
      await tester.pump(const Duration(seconds: 10));
      await _settle(tester);
      expect(reads, 3);
      await tester.pump(const Duration(seconds: 5));
      await _settle(tester);
      expect(reads, 4);

      sub.close();
      container.dispose();
      await tester.pump(const Duration(minutes: 2));
      expect(reads, 4);
    });
  });

  test('a refresh that overlapped a send never restores the sent draft',
      () async {
    final gate = Completer<dynamic>();
    var reads = 0;
    final dio = _ScriptedDio((method, path, query) {
      if (path == ApiEndpoints.chatSendMessage) {
        return {
          'message': {
            'message': {
              'name': 'M9',
              'body': 'typed reply',
              'direction': 'Outbound',
              'timestamp': '2026-10-16 10:09:00',
            },
          },
        };
      }
      if (path != ApiEndpoints.chatGetConversation) return _page(const []);
      reads++;
      if (reads == 1) return _thread(['M1'], draft: 'D1');
      if (reads == 2) return gate.future;
      return _thread(['M1', 'M2']);
    });
    final container = _container(dio);
    addTearDown(container.dispose);
    final sub = container.listen(chatThreadProvider(_conv), (_, _) {});
    addTearDown(sub.close);
    await container.read(chatThreadProvider(_conv).future);
    expect(container.read(chatThreadProvider(_conv)).requireValue.draft?.name,
        'D1');

    final notifier = container.read(chatThreadProvider(_conv).notifier);
    // A poll-style refresh starts, then the moderator sends before it lands.
    final stale = notifier.refresh();
    await notifier.sendMessage('typed reply');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(chatThreadProvider(_conv)).requireValue.draft,
        isNull);

    // The overlapping read answers with the pre-send draft: ignored.
    gate.complete(_thread(['M1'], draft: 'D1'));
    await stale;
    final state = container.read(chatThreadProvider(_conv)).requireValue;
    expect(state.draft, isNull);
    expect(state.messages.map((m) => m.name), containsAll(['M1', 'M2', 'M9']));
  });
}
