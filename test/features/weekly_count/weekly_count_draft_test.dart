// The weekly-count draft: what a counter has typed so far.
//
// The rules a branch relies on: an uncounted item is not the same as a 0,
// "all zero" only fills what is still uncounted, and the submit unlocks only
// once every item on the sheet has a number.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_draft.dart';

WeeklyCountDraft _draft([Map<String, int>? counts]) => WeeklyCountDraft(
  posProfile: 'Maadi',
  weekStart: '2026-10-17',
  counts: counts,
);

void main() {
  group('uncounted vs 0', () {
    test('a fresh draft has nothing counted', () {
      final d = _draft();
      expect(d.isCounted('A'), isFalse);
      expect(d.qtyOf('A'), isNull);
    });

    test('a 0 is counted, an absent item is not', () {
      final d = _draft()..setQty('A', 0);
      expect(d.isCounted('A'), isTrue);
      expect(d.qtyOf('A'), 0);
      expect(d.isCounted('B'), isFalse);
    });

    test('+ on an uncounted item means one', () {
      final d = _draft()..increment('A');
      expect(d.qtyOf('A'), 1);
      d.increment('A');
      expect(d.qtyOf('A'), 2);
    });

    test('- on an uncounted item means none, and never goes below zero', () {
      final d = _draft()..decrement('A');
      expect(d.qtyOf('A'), 0);
      d.decrement('A');
      expect(d.qtyOf('A'), 0);
    });

    test('clear takes an item back to uncounted', () {
      final d = _draft({'A': 0})..clear('A');
      expect(d.isCounted('A'), isFalse);
    });

    test('a negative typed quantity is stored as 0', () {
      final d = _draft()..setQty('A', -3);
      expect(d.qtyOf('A'), 0);
    });
  });

  group('all zero', () {
    test('fills only the uncounted items and reports how many', () {
      final d = _draft({'A': 4, 'B': 0});
      final filled = d.zeroUncounted(['A', 'B', 'C', 'D']);
      expect(filled, 2);
      expect(d.counts, {'A': 4, 'B': 0, 'C': 0, 'D': 0});
    });

    test('does nothing when the section is already counted', () {
      final d = _draft({'A': 4});
      expect(d.zeroUncounted(['A']), 0);
      expect(d.counts, {'A': 4});
    });

    test('leaves items of other sections uncounted', () {
      final d = _draft()..zeroUncounted(['A', 'B']);
      expect(d.isCounted('C'), isFalse);
      expect(d.isComplete(['A', 'B', 'C']), isFalse);
    });
  });

  group('completeness', () {
    const codes = ['A', 'B', 'C'];

    test('incomplete until every item has a number, zeros included', () {
      final d = _draft();
      expect(d.isComplete(codes), isFalse);
      expect(d.countedOf(codes), 0);
      d
        ..setQty('A', 2)
        ..setQty('B', 0);
      expect(d.isComplete(codes), isFalse);
      expect(d.countedOf(codes), 2);
      d.setQty('C', 0);
      expect(d.isComplete(codes), isTrue);
      expect(d.countedOf(codes), 3);
    });

    test('firstUncounted follows sheet order', () {
      final d = _draft({'A': 1, 'C': 1});
      expect(d.firstUncounted(codes), 'B');
      d.setQty('B', 0);
      expect(d.firstUncounted(codes), isNull);
    });

    test('counts for items no longer on the sheet do not complete it', () {
      final d = _draft({'X': 1, 'A': 1, 'B': 1});
      expect(d.isComplete(codes), isFalse);
      expect(d.countedOf(codes), 2);
    });

    test('lines are in sheet order and leave out off-sheet items', () {
      final d = _draft({'C': 0, 'X': 9, 'A': 3, 'B': 0});
      expect(d.linesFor(codes), [
        {'item_code': 'A', 'qty': 3},
        {'item_code': 'B', 'qty': 0},
        {'item_code': 'C', 'qty': 0},
      ]);
    });
  });

  group('persistence', () {
    test('round-trips through JSON with its request id', () {
      final d = _draft({'A': 3, 'B': 0});
      final back = WeeklyCountDraft.fromJson(d.toJson())!;
      expect(back.posProfile, 'Maadi');
      expect(back.weekStart, '2026-10-17');
      expect(back.clientRequestId, d.clientRequestId);
      expect(back.counts, {'A': 3, 'B': 0});
    });

    test('every new draft gets its own request id', () {
      expect(_draft().clientRequestId, isNot(_draft().clientRequestId));
      expect(_draft().clientRequestId, isNotEmpty);
    });

    test('rejects a broken entry and drops bad quantities', () {
      expect(WeeklyCountDraft.fromJson(null), isNull);
      expect(WeeklyCountDraft.fromJson({'pos_profile': 'Maadi'}), isNull);
      final back = WeeklyCountDraft.fromJson({
        'pos_profile': 'Maadi',
        'week_start': '2026-10-17',
        'counts': {'A': 2, 'B': -1, 'C': 'x', 'D': '4'},
      })!;
      expect(back.counts, {'A': 2, 'D': 4});
    });

    test('the key is per branch and week', () {
      expect(
        WeeklyCountDraft.storageKey('Maadi', '2026-10-17'),
        'draft:Maadi:2026-10-17',
      );
    });

    test('the memory store saves, loads and deletes', () async {
      final store = MemoryWeeklyCountDraftStore();
      await store.save(_draft({'A': 1}));
      final loaded = await store.load('Maadi', '2026-10-17');
      expect(loaded?.counts, {'A': 1});
      await store.delete('Maadi', '2026-10-17');
      expect(await store.load('Maadi', '2026-10-17'), isNull);
    });
  });
}
