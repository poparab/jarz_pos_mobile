import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/followups/data/followup_results.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';

FollowupSentItem _item(
  String name, {
  String customerName = '',
  String phone = '',
  String step = 'day32',
  String sentAt = '2026-10-20 10:00:00',
  String waStatus = 'delivered',
  String offerCode = '',
  String codeStatus = '',
  List<Map<String, Object?>> replies = const [],
  List<Map<String, Object?>> orders = const [],
}) => FollowupSentItem.fromJson({
  'name': name,
  'customer': 'CUST-$name',
  'customer_name': customerName,
  'phone': phone,
  'step': step,
  'sent_at': sentAt,
  'wa_status': waStatus,
  'offer_code': offerCode,
  'code_status': codeStatus,
  'replies': replies,
  'orders': orders,
});

Map<String, Object?> _order(
  String invoice,
  String at,
  num total, {
  bool usedCode = false,
  String woo = '',
}) => {
  'invoice': invoice,
  'at': at,
  'grand_total': total,
  'woo_order_id': woo,
  'used_code': usedCode ? 1 : 0,
};

void main() {
  group('filterSentItems', () {
    final mona = _item(
      'A',
      customerName: 'Mona Ali',
      phone: '01012345678',
      step: 'day32',
      waStatus: 'read',
      offerCode: 'JRZ-MONA',
      codeStatus: 'used',
      replies: [
        {'at': '2026-10-20 12:00:00', 'text': 'thanks', 'type': 'text'},
      ],
      orders: [_order('SINV-1', '2026-10-21 09:00:00', 300, usedCode: true)],
    );
    final omar = _item(
      'B',
      customerName: 'Omar',
      phone: '01199998888',
      step: '3h',
      waStatus: 'failed',
    );
    final sara = _item(
      'C',
      customerName: 'سارة',
      phone: '01255556666',
      step: 'day50',
      waStatus: 'delivered',
      offerCode: 'JRZ-SARA',
      codeStatus: 'expired',
      orders: [_order('SINV-2', '2026-10-22 09:00:00', 150)],
    );
    final all = [mona, omar, sara];

    List<String> names(FollowupMessageFilter f) =>
        filterSentItems(all, f).map((i) => i.name).toList();

    test('an empty filter returns everything, in order', () {
      expect(names(const FollowupMessageFilter()), ['A', 'B', 'C']);
      expect(const FollowupMessageFilter().isActive, isFalse);
    });

    test('query matches name, phone, code and invoice', () {
      expect(names(const FollowupMessageFilter(query: 'mona')), ['A']);
      expect(names(const FollowupMessageFilter(query: 'سارة')), ['C']);
      expect(names(const FollowupMessageFilter(query: '0119999')), ['B']);
      expect(names(const FollowupMessageFilter(query: 'jrz-sara')), ['C']);
      expect(names(const FollowupMessageFilter(query: 'sinv-1')), ['A']);
      expect(names(const FollowupMessageFilter(query: 'nobody')), isEmpty);
    });

    test('a phone typed with spaces or dashes still matches', () {
      expect(names(const FollowupMessageFilter(query: '0101 234-5678')), ['A']);
    });

    test('step chips are OR inside the group', () {
      expect(names(const FollowupMessageFilter(steps: {'3h', 'day50'})), [
        'B',
        'C',
      ]);
    });

    test('status: delivered includes read, failed is exact', () {
      expect(names(const FollowupMessageFilter(statuses: {'delivered'})), [
        'A',
        'C',
      ]);
      expect(names(const FollowupMessageFilter(statuses: {'read'})), ['A']);
      expect(names(const FollowupMessageFilter(statuses: {'failed'})), ['B']);
    });

    test('outcome chips', () {
      expect(
        names(
          const FollowupMessageFilter(
            outcomes: {FollowupMessageOutcome.replied},
          ),
        ),
        ['A'],
      );
      expect(
        names(
          const FollowupMessageFilter(
            outcomes: {FollowupMessageOutcome.ordered},
          ),
        ),
        ['A', 'C'],
      );
      expect(
        names(
          const FollowupMessageFilter(
            outcomes: {FollowupMessageOutcome.usedCode},
          ),
        ),
        ['A'],
      );
      expect(
        names(
          const FollowupMessageFilter(
            outcomes: {FollowupMessageOutcome.noResponse},
          ),
        ),
        ['B'],
      );
    });

    test('groups are AND-ed', () {
      expect(
        names(
          const FollowupMessageFilter(
            statuses: {'delivered'},
            outcomes: {FollowupMessageOutcome.ordered},
            steps: {'day50'},
          ),
        ),
        ['C'],
      );
      expect(
        names(
          const FollowupMessageFilter(
            query: 'omar',
            outcomes: {FollowupMessageOutcome.ordered},
          ),
        ),
        isEmpty,
      );
    });

    test('toggle adds and removes without mutating', () {
      const original = <String>{'a'};
      final added = FollowupMessageFilter.toggle(original, 'b');
      expect(added, {'a', 'b'});
      expect(FollowupMessageFilter.toggle(added, 'a'), {'b'});
      expect(original, {'a'});
    });

    test('sentItemSteps orders 3h first, then by day number', () {
      expect(sentItemSteps(all), ['3h', 'day32', 'day50']);
    });
  });

  group('distinctOrders', () {
    test('one invoice after two messages is listed once, on the latest', () {
      final first = _item(
        'M1',
        sentAt: '2026-10-10 10:00:00',
        step: 'day32',
        orders: [_order('SINV-9', '2026-10-15 10:00:00', 400)],
      );
      final second = _item(
        'M2',
        sentAt: '2026-10-14 10:00:00',
        step: 'day50',
        orders: [
          _order('SINV-9', '2026-10-15 10:00:00', 400, usedCode: true),
          _order('SINV-10', '2026-10-18 10:00:00', 100),
        ],
      );
      final rows = distinctOrders([first, second]);
      expect(rows.map((r) => r.order.invoice), ['SINV-10', 'SINV-9']);
      final shared = rows.last;
      expect(shared.item.name, 'M2');
      expect(shared.order.usedCode, isTrue);
      expect(ordersTotal(rows), 500);
    });

    test('is order independent', () {
      final a = _item(
        'A',
        sentAt: '2026-10-10 10:00:00',
        orders: [_order('S1', '2026-10-12 00:00:00', 10)],
      );
      final b = _item(
        'B',
        sentAt: '2026-10-11 10:00:00',
        orders: [_order('S1', '2026-10-12 00:00:00', 10)],
      );
      expect(distinctOrders([a, b]).single.item.name, 'B');
      expect(distinctOrders([b, a]).single.item.name, 'B');
    });

    test('messages without orders add nothing', () {
      expect(distinctOrders([_item('X')]), isEmpty);
      expect(ordersTotal(const []), 0);
    });
  });

  group('repliedItems', () {
    test('keeps only replied messages, latest reply first', () {
      final old = _item(
        'OLD',
        replies: [
          {'at': '2026-10-20 12:00:00', 'text': 'a'},
        ],
      );
      final fresh = _item(
        'NEW',
        sentAt: '2026-10-19 08:00:00',
        replies: [
          {'at': '2026-10-25 09:00:00', 'text': 'b'},
        ],
      );
      final none = _item('NONE');
      expect(repliedItems([old, none, fresh]).map((i) => i.name), [
        'NEW',
        'OLD',
      ]);
    });

    test(
      'an older server that only says replied=1 still lists the message',
      () {
        final legacy = FollowupSentItem.fromJson({
          'name': 'L',
          'replied': 1,
          'sent_at': '2026-10-20 10:00:00',
        });
        expect(repliedItems([legacy]), hasLength(1));
      },
    );
  });

  group('FollowupRange', () {
    final now = DateTime(2026, 10, 29, 15, 30);

    test('last 7 days include today', () {
      final r = FollowupRange.preset(FollowupRangePreset.last7, now: now);
      expect(r.fromDate, '2026-10-23');
      expect(r.toDate, '2026-10-29');
    });

    test('last 30 days and this month', () {
      final r30 = FollowupRange.preset(FollowupRangePreset.last30, now: now);
      expect(r30.fromDate, '2026-09-30');
      expect(r30.toDate, '2026-10-29');
      final month = FollowupRange.preset(
        FollowupRangePreset.thisMonth,
        now: now,
      );
      expect(month.fromDate, '2026-10-01');
      expect(month.toDate, '2026-10-29');
    });

    test('custom ranges are normalised and swap a backwards pick', () {
      final r = FollowupRange.custom(
        DateTime(2026, 10, 20, 23),
        DateTime(2026, 10, 3, 1),
      );
      expect(r.preset, FollowupRangePreset.custom);
      expect(r.fromDate, '2026-10-03');
      expect(r.toDate, '2026-10-20');
    });

    test('equal ranges compare equal (provider does not refetch)', () {
      expect(
        FollowupRange.preset(FollowupRangePreset.last7, now: now),
        FollowupRange.preset(
          FollowupRangePreset.last7,
          now: DateTime(2026, 10, 29, 1),
        ),
      );
    });
  });
}
