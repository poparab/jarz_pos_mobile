import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/router.dart';
import '../../../core/utils/order_display_id.dart';
import '../../../core/websocket/websocket_service.dart';
import 'kanban_provider.dart';

/// Lets the collect-cash dialog through once per invoice within [window].
///
/// A Sales Partner hand-off announces itself several times over (the tap's own
/// response plus three realtime events), each of which used to open a dialog.
class CollectCashPromptGate {
  CollectCashPromptGate({this.window = const Duration(seconds: 30), DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final Duration window;
  final DateTime Function() _clock;
  final Map<String, DateTime> _shownAt = {};

  bool shouldShow(String? invoiceId) {
    // Without an invoice there is nothing to match echoes against.
    if (invoiceId == null || invoiceId.isEmpty) return true;
    final now = _clock();
    _shownAt.removeWhere((_, at) => now.difference(at) >= window);
    if (_shownAt.containsKey(invoiceId)) return false;
    _shownAt[invoiceId] = now;
    return true;
  }
}

/// The one gate every collect-cash path consults.
///
/// A provider rather than a field on [KanbanNotifier]: the realtime listener
/// below runs for the whole signed-in session while the notifier exists only
/// once someone opens Kanban, and the tap on a card and the socket echo of that
/// same tap must be judged by the same memory or both open a dialog.
final collectCashPromptGateProvider = Provider<CollectCashPromptGate>(
  (ref) => CollectCashPromptGate(),
);

final collectCashPrompterProvider = Provider<CollectCashPrompter>(
  (ref) => CollectCashPrompter(ref),
);

/// Opens the collect-cash dialog on the root navigator, whatever screen is up.
class CollectCashPrompter {
  CollectCashPrompter(this._ref);

  final Ref _ref;

  /// Shows the dialog and returns true, or returns false when it is suppressed:
  /// signed out, no navigator to anchor it, or already shown for [invoiceId]
  /// within the gate's window.
  bool show({required String amount, String? invoiceId, Object? wooOrderId}) {
    // The socket is dropped on sign-out, but an event already in flight must
    // not put the previous user's cash prompt on the login screen.
    if (!_ref.read(currentAuthStateProvider)) return false;
    try {
      // Prefer the global navigator key so the dialog appears even when focus
      // is elsewhere (POS, reports, a sheet on top of the board).
      final navKey = _ref.read(navigatorKeyProvider);
      BuildContext? ctx = navKey.currentContext;
      ctx ??= WidgetsBinding.instance.focusManager.primaryFocus?.context;
      if (ctx == null) return false;
      // Consulted only once a dialog can actually open, so an event that lands
      // before the navigator exists does not swallow the next one.
      if (!_ref.read(collectCashPromptGateProvider).shouldShow(invoiceId)) {
        return false;
      }
      String amountLabel;
      try {
        amountLabel = double.parse(amount).toStringAsFixed(2);
      } catch (_) {
        amountLabel = amount;
      }
      unawaited(showDialog<void>(
        context: ctx,
        builder: (c) {
          final l10n = AppLocalizations.of(c);
          return AlertDialog(
            title: Text(l10n.websocketCollectCashTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amountLabel,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(l10n.websocketCollectCashMessage),
                if (invoiceId != null && invoiceId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // The Woo order number is what staff call the order by.
                  Text(
                    l10n.websocketInvoiceLabel(orderDisplayId(invoiceId, wooOrderId: wooOrderId)),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: Text(l10n.commonOk),
              ),
            ],
          );
        },
      ));
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// What a realtime event asks the collect-cash dialog to show.
@immutable
class CollectCashPromptRequest {
  const CollectCashPromptRequest({required this.invoiceId, required this.amount, this.wooOrderId});

  final String invoiceId;
  final String amount;
  final Object? wooOrderId;
}

/// Whether [event] is one of the three realtime shapes that mean "a Sales
/// Partner order left with cash to collect", and if so what to show.
///
/// 1. `sales_partner_collect_prompt` - the explicit pre-payment prompt.
/// 2. `sales_partner_unpaid_cash` with a Payment Entry - the unpaid fast path.
/// 3. A move into Out For Delivery for a partner order that carries the cash
///    Payment Entry created on that transition.
///
/// One hand-off usually produces several of these; the gate collapses them.
@visibleForTesting
CollectCashPromptRequest? collectCashPromptFor(Map<String, dynamic> event) {
  final invoiceId = (event['invoice'] ?? event['invoice_id'])?.toString().trim() ?? '';
  if (invoiceId.isEmpty) return null;
  final mode = (event['mode'] ?? '').toString();
  final wooOrderId = event['woo_order_id'];
  final hasPartner = (event['sales_partner'] ?? event['salesPartner'] ?? '').toString().isNotEmpty;

  if (mode == 'sales_partner_collect_prompt') {
    return CollectCashPromptRequest(
      invoiceId: invoiceId,
      amount: (event['outstanding'] ?? event['amount'] ?? '').toString(),
      wooOrderId: wooOrderId,
    );
  }
  if (hasPartner && mode == 'sales_partner_unpaid_cash' && event['payment_entry'] != null) {
    return CollectCashPromptRequest(
      invoiceId: invoiceId,
      amount: (event['amount'] ?? '').toString(),
      wooOrderId: wooOrderId,
    );
  }
  final cashPE = event['cash_payment_entry'] ?? event['cashPaymentEntry'];
  if (event['new_state_key'] == 'out_for_delivery' && hasPartner && cashPE != null) {
    return CollectCashPromptRequest(
      invoiceId: invoiceId,
      amount: (event['amount'] ?? '').toString(),
      wooOrderId: wooOrderId,
    );
  }
  return null;
}

/// Turns collect-cash realtime events into the dialog for the whole signed-in
/// session, on any screen.
///
/// This used to live inside [KanbanNotifier]'s socket listener, which exists
/// only after a Kanban widget first reads `kanbanProvider` - so a cashier who
/// opened the app into POS and never visited the board never saw the prompt.
/// Watched from the authenticated app shell instead. It deliberately does not
/// create `kanbanProvider` (that would load the board for users who never open
/// it); it only reads the board's branch filter when the board already exists.
/// autoDispose, so it stops when the shell stops watching it on sign-out.
final collectCashPromptListenerProvider = Provider.autoDispose<void>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  final sub = ws.kanbanUpdates.listen((event) {
    try {
      final request = collectCashPromptFor(event);
      if (request == null) return;
      // The server addresses these to the owning branch's users. A user who
      // has filtered the open board down to some of their branches is not
      // handling the others' orders, so honour that filter when it exists.
      if (ref.exists(kanbanProvider) &&
          !kanbanEventIsForBranches(event, ref.read(kanbanProvider).selectedBranches)) {
        return;
      }
      ref.read(collectCashPrompterProvider).show(
            amount: request.amount,
            invoiceId: request.invoiceId,
            wooOrderId: request.wooOrderId,
          );
    } catch (error) {
      if (kDebugMode) debugPrint('Collect-cash prompt failed: $error');
    }
  });
  ref.onDispose(sub.cancel);
});
