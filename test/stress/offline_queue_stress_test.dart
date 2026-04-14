// Offline Queue Stress Test
//
// Verifies that the offline queue survives high-volume enqueue/dequeue cycles
// without data loss, corruption, or duplicates.
//
// Key invariants tested:
//   1. All enqueued transactions are eventually retrievable as pending
//   2. markAsProcessed moves exactly one transaction per call
//   3. A full process cycle leaves zero pending transactions
//   4. clearAll always results in zero pending (idempotent under stress)
//   5. No duplicate IDs after bulk enqueue
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';

void main() {
  group('OfflineQueue Stress — bulk enqueue/dequeue', () {
    late MockOfflineQueue queue;

    setUp(() {
      queue = MockOfflineQueue();
    });

    test('50 transactions enqueued — all returned as pending', () async {
      const count = 50;
      for (var i = 0; i < count; i++) {
        await queue.addTransaction({
          'endpoint': '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          'data': {'invoice_index': i, 'grand_total': (i + 1) * 100.0},
        });
      }

      final pending = await queue.getPendingTransactions();
      expect(pending.length, equals(count),
          reason: '$count transactions enqueued must all be pending');
      expect(await queue.getPendingCount(), equals(count));
    });

    test('50 transactions — no duplicate IDs after bulk enqueue', () async {
      const count = 50;
      for (var i = 0; i < count; i++) {
        await queue.addTransaction({'idx': i});
      }

      final pending = await queue.getPendingTransactions();
      final ids = pending.map((tx) => tx['id'] as String).toList();
      final uniqueIds = ids.toSet();

      expect(uniqueIds.length, equals(ids.length),
          reason: 'Every transaction must have a unique ID');
    });

    test('process all 50 transactions — zero pending remain', () async {
      const count = 50;
      final List<String> ids = [];

      for (var i = 0; i < count; i++) {
        await queue.addTransaction({'idx': i});
      }

      final pending = await queue.getPendingTransactions();
      for (final tx in pending) {
        ids.add(tx['id'] as String);
      }

      for (final id in ids) {
        await queue.markAsProcessed(id);
      }

      expect(await queue.getPendingCount(), isZero,
          reason: 'After processing all, zero pending expected');
    });

    test('markAsProcessed is idempotent — double-processing same ID is safe',
        () async {
      await queue.addTransaction({'idx': 0});
      final pending = await queue.getPendingTransactions();
      final id = pending.first['id'] as String;

      await queue.markAsProcessed(id);
      await queue.markAsProcessed(id); // second call — must not throw

      expect(await queue.getPendingCount(), isZero);
    });

    test('clearAll after 50 enqueues leaves queue empty', () async {
      for (var i = 0; i < 50; i++) {
        await queue.addTransaction({'idx': i});
      }

      await queue.clearAll();

      expect(await queue.getPendingCount(), isZero,
          reason: 'clearAll must remove every entry');
    });

    test('mixed processed/error/pending — getPendingCount reflects only pending',
        () async {
      // Enqueue 10
      for (var i = 0; i < 10; i++) {
        await queue.addTransaction({'idx': i});
      }

      final all = await queue.getPendingTransactions();
      final allIds = all.map((tx) => tx['id'] as String).toList();

      // Process 3
      for (var i = 0; i < 3; i++) {
        await queue.markAsProcessed(allIds[i]);
      }
      // Error 2
      for (var i = 3; i < 5; i++) {
        await queue.markAsError(allIds[i], 'simulated network failure');
      }

      // 5 should remain pending
      expect(await queue.getPendingCount(), equals(5),
          reason: '3 processed + 2 errored = 5 still pending');
    });
  });
}
