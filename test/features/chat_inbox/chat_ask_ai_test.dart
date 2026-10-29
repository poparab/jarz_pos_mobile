// "Ask AI for a message" when our message is the newest: which AI affordance
// the thread shows (draft panel / ask bar / window-closed note / nothing),
// the required instruction in the dialog, and the regenerate_draft call.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/chat_repository.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/chat_inbox/presentation/screens/chat_thread_screen.dart';
import 'package:jarz_pos/src/features/chat_inbox/state/chat_providers.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

const _me = 'mod@jarz.test';
final _now = DateTime(2026, 10, 16, 10, 30);

UserRoles _moderator() => UserRoles(
      user: _me,
      fullName: 'Mod',
      roles: const ['Moderator', 'POS User', 'Sales User'],
      requirePosShift: true,
      canAccessB2b: false,
      isB2bSalesRep: false,
    );

Map<String, dynamic> _summaryJson({
  bool windowOpen = true,
  String lastDirection = 'Outbound',
}) =>
    {
      'name': 'CHAT-1',
      'channel': 'WhatsApp',
      'contact_name': 'Lina',
      'status': 'Answered',
      'last_message_at': '2026-10-16 10:05:00',
      'last_direction': lastDirection,
      'unread_count': 0,
      'window_open': windowOpen ? 1 : 0,
      'has_pending_draft': 0,
    };

Map<String, dynamic> _messageJson(String name, String direction, String ts) => {
      'name': name,
      'direction': direction,
      'message_type': 'text',
      'body': '$direction $name',
      'timestamp': ts,
    };

ChatMessage _msg(String name, String direction, String ts) =>
    ChatMessage.fromJson(_messageJson(name, direction, ts));

ChatThreadState _state({
  List<ChatMessage> messages = const [],
  ChatDraft? draft,
  bool windowOpen = true,
  String lastDirection = 'Outbound',
}) =>
    ChatThreadState(
      conversation: ChatConversationSummary.fromJson(
        _summaryJson(windowOpen: windowOpen, lastDirection: lastDirection),
      ),
      messages: messages,
      draft: draft,
    );

final _inbound = _msg('M-1', 'Inbound', '2026-10-16 10:00:00');
final _outbound = _msg('M-2', 'Outbound', '2026-10-16 10:05:00');

ChatDraft _draft(String status) => ChatDraft.fromJson({
      'name': 'D-1',
      'status': status,
      'draft_text': 'Hello from Jarz',
    });

List<Override> _overrides(MockDio dio) => [
      chatRepositoryProvider.overrideWithValue(ChatRepository(dio)),
      userRolesFutureProvider.overrideWith((ref) async => _moderator()),
      webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
      chatClockProvider.overrideWithValue(() => _now),
      chatUnreadTotalProvider.overrideWith(
        (ref) async => const ChatUnreadTotal(openCount: 0, unreadTotal: 0),
      ),
    ];

Widget _app(List<Override> overrides, Widget home, {String locale = 'en'}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

MockDio _dio({
  required List<Map<String, dynamic>> messages,
  Map<String, dynamic>? draft,
  bool windowOpen = true,
  String lastDirection = 'Outbound',
}) =>
    MockDio()
      ..setResponse(ApiEndpoints.chatGetConversation, {
        'message': {
          'conversation': _summaryJson(
            windowOpen: windowOpen,
            lastDirection: lastDirection,
          ),
          'messages': messages,
          'draft': draft,
          'customer': null,
        },
      });

Future<void> _pumpThread(WidgetTester tester, MockDio dio,
    {String locale = 'en'}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _app(
      _overrides(dio),
      const ChatThreadScreen(conversation: 'CHAT-1'),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('chatAiSlot', () {
    test('customer spoke last, no draft: nothing (unchanged behaviour)', () {
      expect(chatAiSlot(_state(messages: [_inbound])), ChatAiSlot.none);
      expect(chatNewestIsOurs(_state(messages: [_inbound])), isFalse);
    });

    test('customer spoke last with a Pending or Failed draft: the panel', () {
      for (final status in ['Pending', 'Failed']) {
        expect(
          chatAiSlot(_state(messages: [_inbound], draft: _draft(status))),
          ChatAiSlot.draft,
        );
      }
    });

    test('a non-showable draft does not count as a draft', () {
      expect(
        chatAiSlot(_state(messages: [_inbound], draft: _draft('Sent As-Is'))),
        ChatAiSlot.none,
      );
      expect(
        chatAiSlot(_state(
          messages: [_inbound, _outbound],
          draft: _draft('Superseded'),
        )),
        ChatAiSlot.askForMessage,
      );
    });

    test('we spoke last, window open: ask for a message', () {
      final state = _state(messages: [_inbound, _outbound]);
      expect(chatNewestIsOurs(state), isTrue);
      expect(chatAiSlot(state), ChatAiSlot.askForMessage);
    });

    test('we spoke last, window closed: the note instead of the ask', () {
      expect(
        chatAiSlot(_state(messages: [_inbound, _outbound], windowOpen: false)),
        ChatAiSlot.windowClosed,
      );
    });

    test('a showable draft wins even when we spoke last', () {
      // e.g. the follow-up the AI just drafted on request.
      expect(
        chatAiSlot(_state(
          messages: [_inbound, _outbound],
          draft: _draft('Pending'),
          windowOpen: false,
        )),
        ChatAiSlot.draft,
      );
    });

    test('no messages loaded: falls back to last_direction', () {
      expect(chatAiSlot(_state()), ChatAiSlot.askForMessage);
      expect(
        chatAiSlot(_state(lastDirection: 'Inbound')),
        ChatAiSlot.none,
      );
    });
  });

  testWidgets(
      'we spoke last: Ask AI needs an instruction and sends it as the hint',
      (tester) async {
    final dio = _dio(messages: [
      _messageJson('M-1', 'Inbound', '2026-10-16 10:00:00'),
      _messageJson('M-2', 'Outbound', '2026-10-16 10:05:00'),
    ])
      ..setResponse(ApiEndpoints.chatRegenerateDraft, {
        'message': {
          'draft': {
            'name': 'D-9',
            'status': 'Pending',
            'draft_text': 'Just a reminder: the offer ends today.',
          },
        },
      });
    await _pumpThread(tester, dio);

    expect(find.byKey(const ValueKey('chat-draft-panel')), findsNothing);
    expect(find.byKey(const ValueKey('chat-ask-ai')), findsOneWidget);
    expect(find.text('Ask AI for a message'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-ask-ai-window-closed')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('chat-ask-ai')));
    await tester.pumpAndSettle();

    FilledButton confirm() => tester.widget<FilledButton>(
          find.byKey(const ValueKey('chat-regenerate-confirm')),
        );
    expect(find.text('What should the message say?'), findsOneWidget);
    expect(confirm().onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('chat-regenerate-hint')),
      '   ',
    );
    await tester.pump();
    expect(confirm().onPressed, isNull, reason: 'blank is not an instruction');

    await tester.enterText(
      find.byKey(const ValueKey('chat-regenerate-hint')),
      '  remind her the offer ends today ',
    );
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey('chat-regenerate-confirm')));
    await tester.pumpAndSettle();

    final call = dio.requestLog
        .firstWhere((r) => r['path'] == ApiEndpoints.chatRegenerateDraft);
    expect(call['data'], {
      'conversation': 'CHAT-1',
      'hint': 'remind her the offer ends today',
    });

    // The result is a normal draft: panel with Send / Edit / Reject.
    expect(find.byKey(const ValueKey('chat-draft-panel')), findsOneWidget);
    expect(find.text('Just a reminder: the offer ends today.'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-draft-send')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-draft-reject')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-ask-ai')), findsNothing);
  });

  testWidgets('cancelling the ask makes no call', (tester) async {
    final dio = _dio(messages: [
      _messageJson('M-2', 'Outbound', '2026-10-16 10:05:00'),
    ]);
    await _pumpThread(tester, dio);

    await tester.tap(find.byKey(const ValueKey('chat-ask-ai')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      dio.requestLog.where((r) => r['path'] == ApiEndpoints.chatRegenerateDraft),
      isEmpty,
    );
    expect(find.byKey(const ValueKey('chat-ask-ai')), findsOneWidget);
  });

  testWidgets('we spoke last, window closed: a note and no ask button',
      (tester) async {
    final dio = _dio(
      windowOpen: false,
      messages: [
        _messageJson('M-1', 'Inbound', '2026-10-14 10:00:00'),
        _messageJson('M-2', 'Outbound', '2026-10-14 10:05:00'),
      ],
    );
    await _pumpThread(tester, dio);

    expect(
      find.byKey(const ValueKey('chat-ask-ai-window-closed')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('chat-ask-ai')), findsNothing);
    expect(find.byKey(const ValueKey('chat-draft-panel')), findsNothing);
  });

  testWidgets('Arabic labels for the ask action', (tester) async {
    final dio = _dio(messages: [
      _messageJson('M-2', 'Outbound', '2026-10-16 10:05:00'),
    ]);
    await _pumpThread(tester, dio, locale: 'ar');

    expect(find.text('اطلب رسالة من الذكاء الاصطناعي'), findsOneWidget);
  });

  testWidgets(
      'customer spoke last: draft panel, Regenerate hint stays optional',
      (tester) async {
    final dio = _dio(
      lastDirection: 'Inbound',
      messages: [_messageJson('M-1', 'Inbound', '2026-10-16 10:00:00')],
      draft: {'name': 'D-1', 'status': 'Pending', 'draft_text': 'Hi!'},
    )..setResponse(ApiEndpoints.chatRegenerateDraft, {
        'message': {
          'draft': {'name': 'D-2', 'status': 'Pending', 'draft_text': 'Hello!'},
        },
      });
    await _pumpThread(tester, dio);

    expect(find.byKey(const ValueKey('chat-draft-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-ask-ai-bar')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('chat-draft-regenerate')));
    await tester.pumpAndSettle();
    expect(find.text('Regenerate the draft'), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
      find.byKey(const ValueKey('chat-regenerate-confirm')),
    );
    expect(confirm.onPressed, isNotNull, reason: 'the hint is optional here');
    await tester.tap(find.byKey(const ValueKey('chat-regenerate-confirm')));
    await tester.pumpAndSettle();

    final call = dio.requestLog
        .firstWhere((r) => r['path'] == ApiEndpoints.chatRegenerateDraft);
    expect(call['data'], {'conversation': 'CHAT-1'});
    expect(find.text('Hello!'), findsOneWidget);
  });

  testWidgets('customer spoke last, no draft: no AI affordance at all',
      (tester) async {
    final dio = _dio(
      lastDirection: 'Inbound',
      messages: [_messageJson('M-1', 'Inbound', '2026-10-16 10:00:00')],
    );
    await _pumpThread(tester, dio);

    expect(find.byKey(const ValueKey('chat-draft-panel')), findsNothing);
    expect(find.byKey(const ValueKey('chat-ask-ai-bar')), findsNothing);
  });
}
