import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';

Map<String, dynamic> _row({Map<String, dynamic> overrides = const {}}) => {
      'name': 'CF-0001',
      'customer': 'CUST-1',
      'customer_name': 'منى أحمد',
      'phone': '01012345678',
      'whatsapp_msisdn': '201012345678',
      'message_text': 'أهلاً يا منى',
      'step': 'day7',
      'channel': 'Message',
      'due_at': '2026-10-12 14:30:00',
      'is_overdue': 0,
      'customer_type': 'Repeat',
      'value_band': 'High',
      'order_value': 1250.5,
      'invoice': 'ACC-SINV-1',
      'woo_order_id': 17901,
      'lifetime_orders': 4,
      'customer_segment': 'Loyal',
      'rfm_is_regular': 1,
      'territory': 'Nasr City',
      ...overrides,
    };

void main() {
  group('lenient scalars', () {
    test('followupInt reads bool, num, numeric strings and junk', () {
      expect(followupInt(true), 1);
      expect(followupInt(false), 0);
      expect(followupInt(3), 3);
      expect(followupInt(3.9), 3);
      expect(followupInt('7'), 7);
      expect(followupInt('7.0'), 7);
      expect(followupInt('true'), 1);
      expect(followupInt(''), 0);
      expect(followupInt(null), 0);
      expect(followupInt('abc', fallback: -1), -1);
    });

    test('followupDouble reads strings and ints', () {
      expect(followupDouble('99.5'), 99.5);
      expect(followupDouble(10), 10.0);
      expect(followupDouble(null), 0);
    });
  });

  group('FollowupRow.fromJson', () {
    test('parses the AI fields and defaults them to empty', () {
      final row = FollowupRow.fromJson(_row(overrides: {
        'ai_message': 'رسالة Claude',
        'ai_brief': 'نبذة',
        'template_text': 'قالب',
      }));
      expect(row.aiMessage, 'رسالة Claude');
      expect(row.aiBrief, 'نبذة');
      expect(row.templateText, 'قالب');
      final plain = FollowupRow.fromJson(_row());
      expect(plain.aiMessage, '');
      expect(plain.aiBrief, '');
      expect(plain.templateText, '');
      final updated = row.copyWithAi(messageText: 'x');
      expect(updated.messageText, 'x');
      expect(updated.aiBrief, 'نبذة');
      expect(updated.name, row.name);
    });

    test('draft and brief results parse source and cached', () {
      final d = FollowupDraftResult.fromJson(
          {'name': 'A', 'message_text': 'hi', 'source': 'claude', 'cached': 1});
      expect(d.isClaude, isTrue);
      expect(d.cached, isTrue);
      final b = FollowupBriefResult.fromJson(
          {'name': 'A', 'brief': 'br', 'source': 'template', 'error': 'e'});
      expect(b.isClaude, isFalse);
      expect(b.error, 'e');
      expect(FollowupBriefResult.fromJson(null).brief, '');
    });

    test('parses a well-formed row', () {
      final row = FollowupRow.fromJson(_row());

      expect(row.name, 'CF-0001');
      expect(row.displayName, 'منى أحمد');
      expect(row.channel, FollowupChannel.message);
      expect(row.isCall, isFalse);
      expect(row.isRepeat, isTrue);
      expect(row.isHighValue, isTrue);
      expect(row.orderValue, 1250.5);
      expect(row.wooOrderId, 17901);
      expect(row.lifetimeOrders, 4);
      expect(row.customerSegment, 'Loyal');
      expect(row.rfmIsRegular, isTrue);
      expect(row.stepDay, 7);
      expect(row.dueAt, DateTime(2026, 10, 12, 14, 30));
    });

    test('tolerates messy types and missing keys', () {
      final row = FollowupRow.fromJson({
        'name': 'CF-0002',
        'customer': 'CUST-2',
        'channel': 'call',
        'is_overdue': true,
        'order_value': '480',
        'woo_order_id': '0',
        'lifetime_orders': 2.0,
        'rfm_is_regular': '0',
        'customer_segment': null,
        'step': '3h',
        'due_at': null,
      });

      expect(row.isCall, isTrue);
      expect(row.isOverdue, isTrue);
      expect(row.orderValue, 480);
      expect(row.wooOrderId, 0);
      expect(row.lifetimeOrders, 2);
      expect(row.rfmIsRegular, isFalse);
      expect(row.customerSegment, isNull);
      expect(row.stepDay, isNull);
      expect(row.dueAt, isNull);
      expect(row.phone, '');
      expect(row.whatsappMsisdn, '');
      expect(row.displayName, 'CUST-2');
    });

    test('blank segment reads as null', () {
      final row =
          FollowupRow.fromJson(_row(overrides: {'customer_segment': '  '}));
      expect(row.customerSegment, isNull);
    });
  });

  group('FollowupsToday', () {
    test('splits overdue and today, drops nameless rows', () {
      final today = FollowupsToday.fromJson({
        'summary': {'due': '3', 'overdue': 1, 'calls': true, 'messages': 2.0},
        'rows': [
          _row(overrides: {'name': 'A', 'is_overdue': 1, 'channel': 'Call'}),
          _row(overrides: {'name': 'B'}),
          _row(overrides: {'name': 'C'}),
          {'customer': 'no-name'},
          'not a map',
        ],
      });

      expect(today.summary.due, 3);
      expect(today.summary.calls, 1);
      expect(today.summary.messages, 2);
      expect(today.rows.map((r) => r.name), ['A', 'B', 'C']);
      expect(today.overdueRows.map((r) => r.name), ['A']);
      expect(today.todayRows.map((r) => r.name), ['B', 'C']);
    });

    test('without() removes the row and adjusts the summary', () {
      final today = FollowupsToday.fromJson({
        'summary': {'due': 2, 'overdue': 1, 'calls': 1, 'messages': 1},
        'rows': [
          _row(overrides: {'name': 'A', 'is_overdue': 1, 'channel': 'Call'}),
          _row(overrides: {'name': 'B'}),
        ],
      });

      final after = today.without('A');

      expect(after.rows.map((r) => r.name), ['B']);
      expect(after.summary.due, 1);
      expect(after.summary.overdue, 0);
      expect(after.summary.calls, 0);
      expect(after.summary.messages, 1);
      expect(identical(after.without('missing'), after), isTrue);
    });

    test('reads the shipped `items` key and the logged fields', () {
      final today = FollowupsToday.fromJson({
        'summary': {'due': 1},
        'items': [
          _row(overrides: {
            'name': 'I1',
            'status': 'Pending',
            'reached': null,
            'outcome': '',
            'notes': null,
            'apology_code': null,
          }),
        ],
        'rows': [
          _row(overrides: {'name': 'ignored'}),
        ],
      });

      expect(today.rows.map((r) => r.name), ['I1']);
      final row = today.rows.single;
      expect(row.status, 'Pending');
      expect(row.reached, '');
      expect(row.outcome, '');
      expect(row.notes, '');
      expect(row.apologyCode, isNull);
    });

    test('non-map payload yields an empty list', () {
      final today = FollowupsToday.fromJson(['oops']);
      expect(today.rows, isEmpty);
      expect(today.summary.due, 0);
    });
  });

  group('FollowupLogResult.fromJson', () {
    test('reads flat row plus apology code and escalation task', () {
      final result = FollowupLogResult.fromJson({
        ..._row(),
        'apology_code': 'SORRY-7K2',
        'escalation_task': 'TASK-0042',
      });
      expect(result.row?.name, 'CF-0001');
      expect(result.apologyCode, 'SORRY-7K2');
      expect(result.escalationTask, 'TASK-0042');
    });

    test('reads extras from a nested row too', () {
      final result = FollowupLogResult.fromJson({
        'row': {
          ..._row(),
          'apology_code': 'SORRY-N',
          'escalation_task': 'TASK-N',
        },
      });
      expect(result.row?.apologyCode, 'SORRY-N');
      expect(result.apologyCode, 'SORRY-N');
      expect(result.escalationTask, 'TASK-N');
    });

    test('null and empty extras read as null', () {
      final result = FollowupLogResult.fromJson({
        'name': 'CF-1',
        'apology_code': null,
        'escalation_task': '',
      });
      expect(result.apologyCode, isNull);
      expect(result.escalationTask, isNull);
    });
  });

  group('FollowupStats.fromJson', () {
    test('parses counts and normalises the reach rate', () {
      final stats = FollowupStats.fromJson({
        'by_status': {'Done': '5', 'Pending': 2},
        'by_outcome': {'Happy': 4, 'No Reply': true},
        'calls_total': 10,
        'calls_reached': '6',
        'reach_rate': 0.6,
        'reordered': '3',
      });
      expect(stats.byStatus, {'Done': 5, 'Pending': 2});
      expect(stats.byOutcome, {'Happy': 4, 'No Reply': 1});
      expect(stats.callsReached, 6);
      expect(stats.reachPercent, closeTo(60, 0.001));
      expect(stats.reordered, 3);
    });

    test('reads the shipped stats keys', () {
      final stats = FollowupStats.fromJson({
        'from_date': '2026-09-13',
        'to_date': '2026-10-12',
        'total': '40',
        'by_status': {'Done': 30},
        'by_outcome': {},
        'calls_done': 12,
        'calls_reached': 9,
        'reach_rate': 75,
        'touched_customers': 20,
        'reordered_customers': '5',
        'reorder_rate': 0.25,
      });
      expect(stats.fromDate, '2026-09-13');
      expect(stats.total, 40);
      expect(stats.callsTotal, 12);
      expect(stats.reachPercent, closeTo(75, 0.001));
      expect(stats.touchedCustomers, 20);
      expect(stats.reordered, 5);
      expect(stats.reorderPercent, closeTo(25, 0.001));
    });

    test('percentage-scale and missing reach rate', () {
      expect(
        FollowupStats.fromJson({'reach_rate': '45.5'}).reachPercent,
        closeTo(45.5, 0.001),
      );
      expect(
        FollowupStats.fromJson({'calls_total': 4, 'calls_reached': 1})
            .reachPercent,
        closeTo(25, 0.001),
      );
      expect(FollowupStats.fromJson(null).callsTotal, 0);
    });
  });

  test('FollowupOutcome wire values and leavesCycle', () {
    expect(FollowupOutcome.noReply.wire, 'No Reply');
    expect(FollowupOutcome.optedOut.wire, 'Opted Out');
    expect(FollowupOutcome.fromWire('Quality'), FollowupOutcome.quality);
    expect(FollowupOutcome.fromWire('Unknown'), isNull);
    expect(
      FollowupOutcome.values.where((o) => o.leavesCycle),
      [FollowupOutcome.quality, FollowupOutcome.optedOut],
    );
  });
}
