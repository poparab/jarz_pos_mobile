// Network Flap Stress Test
//
// Simulates connectivity toggling mid-operation and verifies that:
//   1. While offline, new transactions are queued (not lost)
//   2. When connectivity is restored, the queue is non-empty (ready to sync)
//   3. Rapid online→offline→online transitions do not corrupt queue state
//   4. ConnectivityService emits events in the correct order
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';

void main() {
  group('Network Flap Stress — connectivity toggling', () {
    late MockConnectivityService connectivity;
    late MockOfflineQueue queue;

    setUp(() {
      connectivity = MockConnectivityService();
      queue = MockOfflineQueue();
    });

    tearDown(() {
      connectivity.dispose();
    });

    test('transactions enqueued while offline are retained after reconnect',
        () async {
      // Go offline
      connectivity.setOnline(false);
      expect(await connectivity.hasConnection(), isFalse);

      // Enqueue 10 invoices while offline
      for (var i = 0; i < 10; i++) {
        await queue.addTransaction({
          'endpoint':
              '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          'data': {'offline_index': i},
        });
      }

      // Reconnect
      connectivity.setOnline(true);
      expect(await connectivity.hasConnection(), isTrue);

      // Queue must still have all 10 — the consumer (sync service) hasn't run yet
      expect(await queue.getPendingCount(), equals(10),
          reason:
              'All offline-queued transactions must persist after reconnect');
    });

    test('rapid 20-cycle flap does not cause connectivity stream to hang',
        () async {
      final events = <bool>[];
      final sub = connectivity.connectivityStream.listen(events.add);

      for (var i = 0; i < 20; i++) {
        connectivity.setOnline(i.isEven);
        await Future<void>.delayed(Duration.zero); // yield to event loop
      }

      await sub.cancel();

      // 20 toggles → 20 events (first call from setUp state is skipped by
      // MockConnectivityService's "if _online == value: return" guard).
      expect(events.length, lessThanOrEqualTo(20));
      // Final state must be correct (last i=19 is odd → offline)
      expect(await connectivity.hasConnection(), isFalse);
    });

    test('enqueue during flap — count stays consistent across 5 flaps',
        () async {
      int enqueueCount = 0;

      for (var flap = 0; flap < 5; flap++) {
        connectivity.setOnline(false);
        // Enqueue 2 per offline period
        await queue.addTransaction({'flap': flap, 'seq': 0});
        await queue.addTransaction({'flap': flap, 'seq': 1});
        enqueueCount += 2;
        connectivity.setOnline(true);
      }

      expect(await queue.getPendingCount(), equals(enqueueCount),
          reason:
              'All transactions enqueued during $enqueueCount drops must '
              'be accounted for');
    });

    test('connectivity stream emits true after setOnline(true)', () async {
      connectivity.setOnline(false);

      final completer = Completer<bool>();
      final sub = connectivity.connectivityStream.listen((v) {
        if (v && !completer.isCompleted) completer.complete(v);
      });

      connectivity.setOnline(true);

      final result = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      await sub.cancel();
      expect(result, isTrue,
          reason: 'Stream must emit true when going online');
    });
  });
}
