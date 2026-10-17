// ChatRepository: the wire calls of contract §3 (GET reads with query
// parameters, POST writes with bodies; get_conversation marks the thread read,
// so it is a POST) and the same-site media guard.
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/chat_repository.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockDio dio;
  late ChatRepository repo;

  setUp(() {
    dio = MockDio();
    repo = ChatRepository(dio);
  });

  Map<String, dynamic> lastRequest() => dio.requestLog.last;

  test('get_conversations is a GET; mine is sent only when true', () async {
    dio.setResponse(ApiEndpoints.chatGetConversations, {
      'message': {
        'conversations': [
          {'name': 'CHAT-1', 'channel': 'Instagram', 'status': 'Open'},
        ],
        'has_more': 1,
        'open_count': 5,
      },
    });

    final page = await repo.fetchConversations(status: 'Open');
    expect(lastRequest()['method'], 'GET');
    expect(lastRequest()['queryParameters'], {'status': 'Open', 'limit': 30});
    expect(page.conversations.single.name, 'CHAT-1');
    expect(page.hasMore, isTrue);
    expect(page.openCount, 5);

    await repo.fetchConversations(
      status: 'all',
      mine: true,
      channel: 'WhatsApp',
      search: '  mona ',
      before: '2026-10-16 09:00:00',
    );
    expect(lastRequest()['queryParameters'], {
      'status': 'all',
      'channel': 'WhatsApp',
      'search': 'mona',
      'mine': 1,
      'limit': 30,
      'before': '2026-10-16 09:00:00',
    });

    // The Open (not Closed) segment: exclude_closed is sent only when asked.
    await repo.fetchConversations(status: 'all', excludeClosed: true);
    expect(lastRequest()['queryParameters'], {
      'status': 'all',
      'exclude_closed': 1,
      'limit': 30,
    });
    await repo.fetchConversations(status: 'all');
    expect(
      (lastRequest()['queryParameters'] as Map).containsKey('exclude_closed'),
      isFalse,
    );
  });

  test('get_conversation is a POST with the name and page size', () async {
    dio.setResponse(ApiEndpoints.chatGetConversation, {
      'message': {
        'conversation': {'name': 'CHAT-1', 'channel': 'WhatsApp'},
        'messages': const [],
        'draft': null,
        'customer': null,
      },
    });
    final thread = await repo.fetchConversation('CHAT-1');
    expect(lastRequest()['method'], 'POST');
    expect(lastRequest()['data'], {'name': 'CHAT-1', 'limit': 50});
    expect(thread.conversation.name, 'CHAT-1');
    expect(thread.draft, isNull);
  });

  test('writes are POSTs with the contract bodies', () async {
    dio.setResponse(ApiEndpoints.chatSendDraft, {
      'message': {
        'message': null,
        'draft': {'name': 'D-1', 'status': 'Blocked', 'draft_text': 'x'},
        'planted': true,
        'caught': false,
      },
    });
    final sent = await repo.sendDraft(draft: 'D-1', finalText: 'x');
    expect(lastRequest()['method'], 'POST');
    expect(lastRequest()['data'], {'draft': 'D-1', 'final_text': 'x'});
    expect(sent.planted, isTrue);
    expect(sent.wasSent, isFalse);

    dio.setResponse(ApiEndpoints.chatRejectDraft, {
      'message': {
        'draft': {'name': 'D-1', 'status': 'Rejected', 'draft_text': 'x'},
      },
    });
    await repo.rejectDraft(draft: 'D-1', reason: 'Wrong tone: too formal');
    expect(lastRequest()['data'], {
      'draft': 'D-1',
      'reason': 'Wrong tone: too formal',
    });

    dio.setResponse(ApiEndpoints.chatRegenerateDraft, {
      'message': {
        'draft': {'name': 'D-2', 'status': 'Pending', 'draft_text': 'y'},
      },
    });
    final regenerated =
        await repo.regenerateDraft(conversation: 'CHAT-1', hint: ' shorter ');
    expect(lastRequest()['data'], {'conversation': 'CHAT-1', 'hint': 'shorter'});
    expect(regenerated?.name, 'D-2');
    await repo.regenerateDraft(conversation: 'CHAT-1');
    expect(lastRequest()['data'], {'conversation': 'CHAT-1'});

    dio.setResponse(ApiEndpoints.chatSendMessage, {
      'message': {
        'message': {'name': 'M-1', 'direction': 'Outbound', 'body': 'hi'},
      },
    });
    final message = await repo.sendMessage(conversation: 'CHAT-1', text: 'hi');
    expect(lastRequest()['data'], {'conversation': 'CHAT-1', 'text': 'hi'});
    expect(message.name, 'M-1');

    final summary = {
      'message': {
        'conversation': {'name': 'CHAT-1', 'status': 'Closed'},
      },
    };
    dio.setResponse(ApiEndpoints.chatAssignConversation, summary);
    await repo.assignConversation(conversation: 'CHAT-1');
    expect(lastRequest()['data'], {'conversation': 'CHAT-1', 'user': ''});

    dio.setResponse(ApiEndpoints.chatSetConversationStatus, summary);
    final closed = await repo.setConversationStatus(
      conversation: 'CHAT-1',
      status: 'Closed',
    );
    expect(lastRequest()['data'], {'conversation': 'CHAT-1', 'status': 'Closed'});
    expect(closed.isClosed, isTrue);

    dio.setResponse(ApiEndpoints.chatLinkCustomer, summary);
    await repo.linkCustomer(conversation: 'CHAT-1', customer: 'CUST-1');
    expect(lastRequest()['data'], {'conversation': 'CHAT-1', 'customer': 'CUST-1'});
  });

  test('prefill, metrics and unread total are GETs', () async {
    dio.setResponse(ApiEndpoints.chatGetOrderPrefill, {
      'message': {
        'customer': {'name': 'CUST-1', 'customer_name': 'Mona'},
      },
    });
    final prefill = await repo.fetchOrderPrefill('CHAT-1');
    expect(lastRequest()['method'], 'GET');
    expect(lastRequest()['queryParameters'], {'conversation': 'CHAT-1'});
    expect(prefill.customer?['name'], 'CUST-1');

    dio.setResponse(ApiEndpoints.chatGetMetrics, {
      'message': {'conversations': 2},
    });
    await repo.fetchMetrics(fromDate: '2026-10-10', toDate: '2026-10-16');
    expect(lastRequest()['queryParameters'], {
      'from_date': '2026-10-10',
      'to_date': '2026-10-16',
    });

    dio.setResponse(ApiEndpoints.chatGetUnreadTotal, {
      'message': {'open_count': 3, 'unread_total': 7},
    });
    final unread = await repo.fetchUnreadTotal();
    expect(lastRequest()['method'], 'GET');
    expect(unread.unreadTotal, 7);
  });

  test('customer search picks phone vs name', () async {
    dio.setResponse(ApiEndpoints.searchCustomers, {
      'message': [
        {'name': 'CUST-1', 'customer_name': 'Mona', 'mobile_no': '0100'},
        {'name': ''},
      ],
    });
    final byPhone = await repo.searchCustomers('0100 123');
    expect(lastRequest()['data'], {'phone': '0100 123'});
    expect(byPhone.single.name, 'CUST-1');
    await repo.searchCustomers('mona');
    expect(lastRequest()['data'], {'name': 'mona'});
    final count = dio.requestLog.length;
    expect(await repo.searchCustomers('  '), isEmpty);
    expect(dio.requestLog.length, count);
  });

  test('media: only same-site file paths are fetched with the session', () async {
    expect(ChatRepository.isSessionMediaUrl('/private/files/a.jpg'), isTrue);
    expect(ChatRepository.isSessionMediaUrl('/files/a.jpg'), isTrue);
    expect(ChatRepository.isSessionMediaUrl('https://evil.example/a.jpg'), isFalse);
    expect(ChatRepository.isSessionMediaUrl(null), isFalse);
    await expectLater(
      repo.fetchMediaBytes('https://evil.example/a.jpg'),
      throwsArgumentError,
    );
    expect(dio.requestLog, isEmpty);
  });

  test('chat calls are never replayed from the offline queue', () {
    for (final path in [
      ApiEndpoints.chatSendMessage,
      ApiEndpoints.chatSendDraft,
      ApiEndpoints.chatRejectDraft,
      ApiEndpoints.chatAssignConversation,
    ]) {
      expect(
        kOfflineReplayExcludedPrefixes.any(path.startsWith),
        isTrue,
        reason: path,
      );
    }
  });
}
