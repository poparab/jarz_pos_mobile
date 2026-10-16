// Chat inbox payload parsing (contract §3 shapes), including the lenient
// readers Frappe's loose typing needs and the optional training-check fields.
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/chat_inbox/presentation/widgets/chat_dialogs.dart';

Map<String, dynamic> summaryJson({
  String name = 'CHAT-0001',
  String status = 'Open',
  String? waitingSince = '2026-10-16 10:00:00',
  Object? windowOpen,
  bool includeWindowOpen = false,
}) =>
    {
      'name': name,
      'channel': 'WhatsApp',
      'contact_name': 'Mona',
      'phone': '+201000000001',
      'customer': null,
      'customer_name': null,
      'status': status,
      'assigned_to': 'mod@jarz.test',
      'assigned_to_name': 'Mod',
      'intent': 'Order',
      'is_complaint': 0,
      'last_message_at': '2026-10-16 10:00:00',
      'last_message_preview': 'Hi',
      'last_direction': 'Inbound',
      'unread_count': '3',
      'waiting_since': waitingSince,
      'window_expires_at': '2026-10-17 10:00:00',
      if (includeWindowOpen) 'window_open': windowOpen,
      'has_pending_draft': true,
      'last_order': null,
    };

Map<String, dynamic> draftJson({
  String name = 'DRAFT-1',
  String status = 'Pending',
  Object? warnings,
  Map<String, dynamic> extra = const {},
}) =>
    {
      'name': name,
      'status': status,
      'draft_text': 'Hello, the jar is 120 EGP.',
      'upsell_item': 'ITEM-9',
      'upsell_item_name': 'Brownie',
      'upsell_text': 'Add a brownie for 40?',
      'intent': 'Inquiry',
      'is_complaint': 0,
      'needs_human_reason': null,
      'warnings': warnings ?? const ['price check'],
      'created_at': '2026-10-16 10:00:05',
      ...extra,
    };

void main() {
  group('lenient readers', () {
    test('chatInt / chatBool accept bool, num, string and null', () {
      expect(chatInt(true), 1);
      expect(chatInt(2.9), 2);
      expect(chatInt('7'), 7);
      expect(chatInt('7.0'), 7);
      expect(chatInt(null), 0);
      expect(chatInt('nope', fallback: 5), 5);
      expect(chatBool('1'), isTrue);
      expect(chatBool('false'), isFalse);
      expect(chatBool(0), isFalse);
    });

    test('chatStringList reads a list, a JSON string, or a bare string', () {
      expect(chatStringList(['a', ' ', 'b']), ['a', 'b']);
      expect(chatStringList('["x","y"]'), ['x', 'y']);
      expect(chatStringList('just one'), ['just one']);
      expect(chatStringList(null), isEmpty);
      expect(chatStringList(''), isEmpty);
    });
  });

  group('ChatConversationSummary', () {
    test('parses the contract shape', () {
      final s = ChatConversationSummary.fromJson(summaryJson());
      expect(s.name, 'CHAT-0001');
      expect(s.channel, ChatChannels.whatsApp);
      expect(s.unreadCount, 3);
      expect(s.hasPendingDraft, isTrue);
      expect(s.isComplaint, isFalse);
      expect(s.displayName, 'Mona');
      expect(s.isOpen, isTrue);
    });

    test('window_open defaults to true when absent, honours an explicit 0', () {
      expect(ChatConversationSummary.fromJson(summaryJson()).windowOpen, isTrue);
      expect(
        ChatConversationSummary.fromJson(
          summaryJson(includeWindowOpen: true, windowOpen: 0),
        ).windowOpen,
        isFalse,
      );
    });

    test('waitingMinutes counts from waiting_since; null when closed or unset',
        () {
      final now = DateTime(2026, 10, 16, 10, 12, 30);
      expect(
        ChatConversationSummary.fromJson(summaryJson()).waitingMinutes(now),
        12,
      );
      expect(
        ChatConversationSummary.fromJson(summaryJson(status: 'Closed'))
            .waitingMinutes(now),
        isNull,
      );
      expect(
        ChatConversationSummary.fromJson(summaryJson(waitingSince: null))
            .waitingMinutes(now),
        isNull,
      );
    });

    test('display name falls back to phone then id', () {
      final json = summaryJson()..remove('contact_name');
      expect(ChatConversationSummary.fromJson(json).displayName, '+201000000001');
      json.remove('phone');
      expect(ChatConversationSummary.fromJson(json).displayName, 'CHAT-0001');
    });
  });

  group('ChatDraft', () {
    test('parses fields, upsell label and warnings given as a JSON string', () {
      final d = ChatDraft.fromJson(draftJson(warnings: '["a","b"]'));
      expect(d.isPending, isTrue);
      expect(d.upsellLabel, 'Brownie');
      expect(d.warnings, ['a', 'b']);
      expect(d.isUnchanged('  Hello, the jar is 120 EGP. '), isTrue);
      expect(d.isUnchanged('Hello, the jar is 150 EGP.'), isFalse);
      expect(d.isPlanted, isFalse);
    });

    test('maybeFromJson is null for a missing or empty draft', () {
      expect(ChatDraft.maybeFromJson(null), isNull);
      expect(ChatDraft.maybeFromJson(const <String, dynamic>{}), isNull);
    });
  });

  group('send_draft result', () {
    test('a planted draft sent as-is: not sent, outcome notSent', () {
      final r = ChatSendDraftResult.fromJson({
        'message': null,
        'draft': draftJson(status: 'Blocked'),
        'planted': true,
        'caught': false,
        'next_draft': draftJson(name: 'DRAFT-2'),
        'planted_error': 'price 120 to 150',
      });
      expect(r.wasSent, isFalse);
      expect(r.planted, isTrue);
      expect(r.draft.plantedError, 'price 120 to 150');
      expect(r.nextDraft?.name, 'DRAFT-2');
      expect(chatPlantedOutcome(r), ChatPlantedOutcome.notSent);
    });

    test('edited planted draft: caught vs missed', () {
      Map<String, dynamic> body(bool caught) => {
            'message': {
              'name': 'MSG-9',
              'direction': 'Outbound',
              'message_type': 'text',
              'body': 'ok',
              'timestamp': '2026-10-16 10:01:00',
            },
            'draft': draftJson(status: 'Sent Edited'),
            'planted': 1,
            'caught': caught ? 1 : 0,
          };
      expect(
        chatPlantedOutcome(ChatSendDraftResult.fromJson(body(true))),
        ChatPlantedOutcome.caught,
      );
      expect(
        chatPlantedOutcome(ChatSendDraftResult.fromJson(body(false))),
        ChatPlantedOutcome.missed,
      );
    });

    test('a normal draft has no planted outcome', () {
      final r = ChatSendDraftResult.fromJson({
        'message': {'name': 'MSG-1', 'direction': 'Outbound', 'body': 'hi'},
        'draft': draftJson(status: 'Sent As-Is'),
        'planted': false,
        'caught': false,
      });
      expect(r.wasSent, isTrue);
      expect(chatPlantedOutcome(r), isNull);
    });
  });

  test('reject_draft: planted from top-level flag or the draft', () {
    expect(
      ChatRejectResult.fromJson({'draft': draftJson(status: 'Rejected')}).planted,
      isFalse,
    );
    expect(
      ChatRejectResult.fromJson({
        'draft': draftJson(status: 'Rejected', extra: {'is_planted': 1}),
      }).planted,
      isTrue,
    );
    expect(
      ChatRejectResult.fromJson({
        'draft': draftJson(status: 'Rejected'),
        'planted': true,
        'next_draft': draftJson(name: 'DRAFT-3'),
      }).nextDraft?.name,
      'DRAFT-3',
    );
  });

  group('order prefill', () {
    test('a linked customer becomes the POS selectCustomer map', () {
      final p = ChatOrderPrefill.fromJson({
        'customer': {
          'name': 'CUST-1',
          'customer_name': 'Mona Ali',
          'mobile_no': '01000000001',
        },
        'phone': '+201000000001',
        'contact_name': 'Mona',
      });
      expect(p.customer, {
        'name': 'CUST-1',
        'customer_name': 'Mona Ali',
        'mobile_no': '01000000001',
      });
    });

    test('no linked customer gives a null customer', () {
      final p = ChatOrderPrefill.fromJson({
        'customer': null,
        'phone': '+201000000001',
      });
      expect(p.customer, isNull);
      expect(p.phone, '+201000000001');
    });
  });

  test('thread, unread total and metrics parse', () {
    final t = ChatThread.fromJson({
      'conversation': summaryJson(),
      'messages': [
        {'name': 'MSG-1', 'direction': 'Inbound', 'body': 'Hi',
          'timestamp': '2026-10-16 10:00:00'},
        {'name': 'MSG-2', 'direction': 'Outbound', 'body': 'Hello',
          'status': 'failed', 'error': 'window closed',
          'timestamp': '2026-10-16 10:01:00'},
      ],
      'draft': draftJson(),
      'customer': null,
    });
    expect(t.messages, hasLength(2));
    expect(t.messages.last.isFailed, isTrue);
    expect(t.draft?.name, 'DRAFT-1');
    expect(t.customer, isNull);

    final u = ChatUnreadTotal.fromJson({'open_count': 4, 'unread_total': '9'});
    expect(u.openCount, 4);
    expect(u.unreadTotal, 9);

    final m = ChatMetrics.fromJson({
      'from_date': '2026-10-10',
      'to_date': '2026-10-16',
      'conversations': 12,
      'drafts': {'total': 10, 'sent_as_is': 6, 'sent_edited': 2},
      'as_is_rate': 0.6,
      'planted': {'total': 3, 'caught': 2},
      'by_moderator': [
        {'user': 'mod@jarz.test', 'sent': 5, 'as_is': 3},
      ],
      'cost_usd': 1.25,
    });
    expect(m.conversations, 12);
    expect(m.drafts.sentAsIs, 6);
    expect(m.asIsPercent, closeTo(60, 0.001));
    expect(m.plantedTotal, 3);
    expect(m.plantedCaught, 2);
    expect(m.byModerator.single.fullName, 'mod@jarz.test');
    expect(m.medianFirstResponseMinutes, isNull);
  });

  test('a socket event without a conversation name falls back to the summary',
      () {
    final e = ChatUpdateEvent.fromJson({
      'kind': 'status',
      'summary': summaryJson(name: 'CHAT-0042'),
    });
    expect(e.conversation, 'CHAT-0042');
    expect(e.summary?.name, 'CHAT-0042');
    expect(e.message, isNull);
  });
}
