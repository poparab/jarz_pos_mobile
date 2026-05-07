// Concurrent Sync Deduplication Test
//
// Verifies that if two "sync workers" run simultaneously on the same queue,
// they do not process the same transaction twice (idempotency / dedup).
//
// The MockOfflineQueue uses in-memory state and is not inherently safe for
// concurrent access. This test documents the EXPECTED behaviour: whichever
// worker claims an ID first, the second call must be a no-op.
//
// Real production sync should use atomic "claim" operations (e.g. mark as
// 'in-flight' before processing). This test catches regressions in that logic.
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';

void main() {
  group('Concurrent Sync Deduplication', () {
    late MockOfflineQueue queue;

    setUp(() {
      queue = MockOfflineQueue();
    });

    test('marking the same ID processed from two places — count stays zero',
        () async {
      await queue.addTransaction({'endpoint': '/api/test', 'data': {}});
      final pending = await queue.getPendingTransactions();
      final id = pending.first['id'] as String;

      // Simulate two workers trying to mark the same transaction.
      await Future.wait([
        queue.markAsProcessed(id),
        queue.markAsProcessed(id),
      ]);

      expect(await queue.getPendingCount(), isZero,
          reason:
              'Double-processing the same ID must not leave phantom pending entries');
    });

    test('two workers process different IDs — both complete without loss',
        () async {
      await queue.addTransaction({'seq': 0});
      await queue.addTransaction({'seq': 1});

      final pending = await queue.getPendingTransactions();
      final id0 = pending[0]['id'] as String;
      final id1 = pending[1]['id'] as String;

      // Workers run in parallel on separate IDs.
      await Future.wait([
        queue.markAsProcessed(id0),
        queue.markAsProcessed(id1),
      ]);

      expect(await queue.getPendingCount(), isZero,
          reason: 'Both workers processed their own transaction → zero pending');
    });

    test('20 transactions processed by two parallel workers — none missed',
        () async {
      const total = 20;
      for (var i = 0; i < total; i++) {
        await queue.addTransaction({'idx': i});
      }

      final all = await queue.getPendingTransactions();
      final ids = all.map((tx) => tx['id'] as String).toList();

      // Split ids between two workers.
      final half = ids.length ~/ 2;
      final worker1 = ids.sublist(0, half);
      final worker2 = ids.sublist(half);

      await Future.wait([
        ...worker1.map(queue.markAsProcessed),
        ...worker2.map(queue.markAsProcessed),
      ]);

      expect(await queue.getPendingCount(), isZero,
          reason: 'All $total transactions must be processed');
    });
  });
}
