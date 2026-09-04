// A Kanban card can be torn out of the tree while one of its own async
// actions is still in flight: the board rebuilds after a payment, a websocket
// refresh lands, or the card is dragged to another column. Everything the
// continuation touches afterwards — `context`, `setState`, `ref` — is dead by
// then, and because these continuations run inside `catch` blocks, whatever
// they throw has nothing above it to handle it. It reaches
// `PlatformDispatcher.onError` and the app dies.
//
// These tests dispose the card mid-await on purpose and assert the flow ends
// quietly. The host tree keeps its MaterialApp (and therefore its
// ScaffoldMessenger) mounted across the rebuild, which is what actually happens
// on the board — only the card goes away.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/pos/order_alert/data/order_alert_service.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

/// Inert stand-in for the real KanbanNotifier, whose constructor opens sockets
/// and arms polling timers. `payInvoice` hands back a future the test settles
/// by hand, so the card can be disposed while the call is still outstanding.
class _PendingPaymentKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _PendingPaymentKanbanNotifier() : super(KanbanState());

  final Completer<Map<String, dynamic>?> payment =
      Completer<Map<String, dynamic>?>();
  int loadInvoicesCalls = 0;

  @override
  Future<Map<String, dynamic>?> payInvoice({
    required String invoiceId,
    required String paymentMode,
    String? posProfile,
  }) => payment.future;

  @override
  Future<void> loadInvoices({bool immediate = false}) async {
    loadInvoicesCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PosNotifierStub extends StateNotifier<PosState> implements PosNotifier {
  _PosNotifierStub() : super(PosState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Acknowledgement never returns on its own; the test completes it.
class _PendingOrderAlertService implements OrderAlertService {
  final Completer<void> acknowledged = Completer<void>();

  @override
  Future<void> acknowledgeInvoice(String invoiceId) => acknowledged.future;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not stubbed');
}

InvoiceCard _card({bool requiresAcceptance = false}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-00042',
    invoiceIdShort: '42',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: 'Ready',
    postingDate: '2026-08-05',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    requiresAcceptanceFlag: requiresAcceptance,
    outstandingAmount: 450,
    isPickup: false,
  );
}

/// Host that can drop the card without taking the app — and therefore the
/// ScaffoldMessenger the card captured — down with it.
Widget _host({
  required bool showCard,
  required InvoiceCard invoice,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [
            if (showCard)
              SizedBox(width: 380, child: InvoiceCardWidget(invoice: invoice)),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'a payment that fails after the card left the tree does not go fatal',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final kanban = _PendingPaymentKanbanNotifier();
      final invoice = _card();
      final overrides = <Override>[
        kanbanProvider.overrideWith((ref) => kanban),
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
      ];

      await tester.pumpWidget(
        _host(showCard: true, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      // Open the payment sheet and submit InstaPay (Cash would need a selected
      // POS profile and bail out before the await).
      await tester.tap(find.byIcon(Icons.payment).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instapay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // The board rebuilds and the card is gone while payInvoice is still out.
      await tester.pumpWidget(
        _host(showCard: false, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      // Now the payment fails. Before the l10n hoist this ran
      // `AppLocalizations.of(context)!` on a dead context from inside the
      // outer catch, so the null-assert threw out of the catch and went fatal.
      kanban.payment.completeError(Exception('gateway refused'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a payment that succeeds after the card left the tree does not go fatal',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final kanban = _PendingPaymentKanbanNotifier();
      final invoice = _card();
      final overrides = <Override>[
        kanbanProvider.overrideWith((ref) => kanban),
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
      ];

      await tester.pumpWidget(
        _host(showCard: true, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.payment).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instapay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _host(showCard: false, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      // The success branch reached `context.l10n` unguarded too, so it threw
      // into the outer catch, which then threw again on the same expression.
      kanban.payment.complete({'success': true, 'payment_entry': 'PE-001'});
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'accepting an order on a card that left the tree does not touch ref',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final kanban = _PendingPaymentKanbanNotifier();
      final alerts = _PendingOrderAlertService();
      final invoice = _card(requiresAcceptance: true);
      final overrides = <Override>[
        kanbanProvider.overrideWith((ref) => kanban),
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        orderAlertServiceProvider.overrideWithValue(alerts),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
      ];

      await tester.pumpWidget(
        _host(showCard: true, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      // The card's own Accept button is gone by now (`_isAccepting` hides it),
      // so the remaining one is the dialog's. `ElevatedButton.icon` builds a
      // private subclass, so match on the label rather than the type.
      await tester.tap(find.text('Accept').last);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _host(showCard: false, invoice: invoice, overrides: overrides),
      );
      await tester.pumpAndSettle();

      // The failure path used to call `setState` BEFORE its mounted guard, so
      // a disposed card threw "setState() called after dispose()" out of a
      // catch block.
      alerts.acknowledged.completeError(Exception('offline'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // And the success path must not reach `ref` on a disposed ConsumerState.
      expect(kanban.loadInvoicesCalls, 0);
    },
  );
}
