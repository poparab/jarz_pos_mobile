import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/ws_events.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/kanban/providers/collect_cash_prompt.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';

const _invoice = 'ACC-SINV-2026-00001';

Map<String, dynamic> _collectPromptMessage() => {
      'event': WsEvents.salesPartnerCollectPrompt,
      'data': {
        'invoice': _invoice,
        'amount': 250.0,
        'outstanding': 250.0,
        'sales_partner': 'Talabat',
        'mode': 'sales_partner_collect_prompt',
      },
    };

Map<String, dynamic> _unpaidOfdMessage() => {
      'event': WsEvents.salesPartnerUnpaidOfd,
      'data': {
        'invoice': _invoice,
        'amount': 250.0,
        'sales_partner': 'Talabat',
        'payment_entry': 'ACC-PAY-2026-00001',
        'mode': 'sales_partner_unpaid_cash',
      },
    };

/// The signed-in shell in miniature: a root navigator on its own key and a
/// widget that keeps the app-wide collect-cash listener alive, the way
/// `_AuthenticatedServiceBootstrap` does. No Kanban widget anywhere.
Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  required WebSocketService socket,
  bool signedIn = true,
}) async {
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        webSocketServiceProvider.overrideWithValue(socket),
        navigatorKeyProvider.overrideWithValue(navKey),
        currentAuthStateProvider.overrideWith((ref) => signedIn),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Consumer(
          builder: (context, ref, _) {
            ref.watch(collectCashPromptListenerProvider);
            return const Scaffold(body: Text('POS'));
          },
        ),
      ),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.text('POS')));
}

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

  group('App-wide collect-cash listener', () {
    testWidgets('prompts once on POS when Kanban was never opened', (tester) async {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);
      final container = await _pumpShell(tester, socket: socket);

      socket.debugHandleMessage(_collectPromptMessage());
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Collect Cash'), findsOneWidget);
      expect(find.text('250.00'), findsOneWidget);
      // The prompt did not come from the board, and did not start it either.
      expect(container.exists(kanbanProvider), isFalse);
    });

    testWidgets('a second path for the same invoice within 30 s shows nothing', (tester) async {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);
      final container = await _pumpShell(tester, socket: socket);

      socket.debugHandleMessage(_collectPromptMessage());
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // The unpaid-OFD echo of the same hand-off.
      socket.debugHandleMessage(_unpaidOfdMessage());
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // The board's own tap path shares the same gate.
      final shown = container.read(collectCashPrompterProvider).show(
            amount: '250',
            invoiceId: _invoice,
          );
      await tester.pumpAndSettle();
      expect(shown, isFalse);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('a tap path first suppresses the realtime echo', (tester) async {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);
      final container = await _pumpShell(tester, socket: socket);

      expect(
        container.read(collectCashPrompterProvider).show(amount: '250', invoiceId: _invoice),
        isTrue,
      );
      await tester.pumpAndSettle();
      socket.debugHandleMessage(_unpaidOfdMessage());
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('opens nothing while signed out', (tester) async {
      final socket = _RecordingSocket();
      addTearDown(socket.dispose);
      await _pumpShell(tester, socket: socket, signedIn: false);

      socket.debugHandleMessage(_collectPromptMessage());
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    test('only the three collect-cash shapes ask for a prompt', () {
      expect(collectCashPromptFor(_collectPromptMessage()['data'] as Map<String, dynamic>), isNotNull);
      expect(collectCashPromptFor(_unpaidOfdMessage()['data'] as Map<String, dynamic>), isNotNull);
      expect(
        collectCashPromptFor({
          'invoice_id': _invoice,
          'old_state_key': 'ready',
          'new_state_key': 'out_for_delivery',
          'sales_partner': 'Talabat',
          'cash_payment_entry': 'ACC-PAY-2026-00002',
          'amount': 100,
        })?.invoiceId,
        _invoice,
      );
      // A plain courier OFD move, and a partner one without a cash PE.
      expect(
        collectCashPromptFor({'invoice_id': _invoice, 'new_state_key': 'out_for_delivery'}),
        isNull,
      );
      expect(
        collectCashPromptFor({
          'invoice_id': _invoice,
          'new_state_key': 'out_for_delivery',
          'sales_partner': 'Talabat',
        }),
        isNull,
      );
      expect(collectCashPromptFor({'mode': 'sales_partner_collect_prompt'}), isNull);
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
