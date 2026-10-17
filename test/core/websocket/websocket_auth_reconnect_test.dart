import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/ws_events.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';

/// A real [WebSocketService] whose transport never opens, so the session
/// bookkeeping can be checked without a server.
class _RecordingSocket extends WebSocketService {
  int connects = 0;
  int reconnects = 0;
  int disconnects = 0;

  @override
  void connect() => connects++;

  @override
  void reconnect() {
    reconnects++;
    super.reconnect();
  }

  @override
  void disconnect() {
    disconnects++;
    super.disconnect();
  }
}

void main() {
  group('WebSocketService session changes', () {
    test('reconnect re-arms retries and connects at once', () {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);

      socket.disconnect();
      expect(socket.debugShouldReconnect, isFalse);

      socket.reconnect();
      expect(socket.debugShouldReconnect, isTrue);
      expect(socket.debugFailedConnects, 0);
      expect(socket.connects, 1);
    });

    test('dispose after disconnect does not throw', () {
      final socket = _RecordingSocket();
      socket.disconnect();
      expect(socket.dispose, returnsNormally);
    });
  });

  group('followAuthState', () {
    late _RecordingSocket socket;
    late ProviderContainer container;

    setUp(() {
      socket = _RecordingSocket();
      final probe = Provider<int>((ref) {
        followAuthState(ref, socket);
        return 0;
      });
      container = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) async => false),
      ]);
      container.read(probe);
      // Keep the probe (and so its listener) alive for the whole test.
      container.listen<int>(probe, (_, _) {});
    });

    tearDown(() {
      container.dispose();
      socket.dispose();
    });

    test('sign-in reconnects with the new session', () {
      container.read(currentAuthStateProvider.notifier).state = true;
      expect(socket.reconnects, 1);
      expect(socket.disconnects, 0);
    });

    test('sign-out drops the socket and stops retrying', () {
      container.read(currentAuthStateProvider.notifier).state = true;
      container.read(currentAuthStateProvider.notifier).state = false;
      expect(socket.reconnects, 1);
      expect(socket.disconnects, 1);
      expect(socket.debugShouldReconnect, isFalse);
    });

    test('a second user signing in after logout reconnects again', () {
      final auth = container.read(currentAuthStateProvider.notifier);
      auth.state = true;
      auth.state = false;
      auth.state = true;
      expect(socket.reconnects, 2);
      expect(socket.debugShouldReconnect, isTrue);
    });

    test('setting the same state again does nothing', () {
      final auth = container.read(currentAuthStateProvider.notifier);
      auth.state = false;
      expect(socket.reconnects, 0);
      expect(socket.disconnects, 0);
    });
  });

  group('Sales Partner collect prompt', () {
    test('reaches the Kanban stream once and opens nothing itself', () async {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);
      final updates = <Map<String, dynamic>>[];
      socket.kanbanUpdates.listen(updates.add);

      // No navigator exists here; the old service-side dialog looked one up.
      socket.debugHandleMessage({
        'event': WsEvents.salesPartnerCollectPrompt,
        'data': {
          'invoice': 'ACC-SINV-2026-00001',
          'woo_order_id': 17529,
          'amount': 250.0,
          'outstanding': 250.0,
          'mode': 'sales_partner_collect_prompt',
        },
      });
      await Future<void>.delayed(Duration.zero);

      expect(updates, hasLength(1));
      expect(updates.single['mode'], 'sales_partner_collect_prompt');
    });
  });

  group('CollectCashPromptGate', () {
    test('lets one dialog through per invoice and drops the echoes', () {
      var now = DateTime(2026, 10, 17, 12);
      final gate = CollectCashPromptGate(clock: () => now);

      expect(gate.shouldShow('INV-1'), isTrue);
      expect(gate.shouldShow('INV-1'), isFalse);
      expect(gate.shouldShow('INV-1'), isFalse);
      expect(gate.shouldShow('INV-2'), isTrue);

      now = now.add(const Duration(seconds: 31));
      expect(gate.shouldShow('INV-1'), isTrue);
    });

    test('never blocks a prompt without an invoice', () {
      final gate = CollectCashPromptGate();
      expect(gate.shouldShow(null), isTrue);
      expect(gate.shouldShow(null), isTrue);
    });
  });
}
