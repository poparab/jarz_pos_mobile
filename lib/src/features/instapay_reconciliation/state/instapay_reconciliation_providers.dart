import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/instapay_reconciliation_service.dart';
import '../data/models/escalated_payment_order.dart';
import '../data/models/unconfirmed_online_order.dart';

/// Age (in seconds) after which an awaiting online order is treated as stale
/// and highlighted red on the reconciliation screen. Default: 6 hours.
const int kInstapayStaleThresholdSeconds = 21600;

/// The list of online orders awaiting bank-transfer confirmation, keyed by the
/// POS profile the manager is reconciling (null = all accessible profiles).
///
/// Invalidate this after any confirm / convert-to-cash mutation to refresh.
final unconfirmedOnlineOrdersProvider = FutureProvider.autoDispose
    .family<List<UnconfirmedOnlineOrder>, String?>((ref, posProfile) async {
  final service = ref.watch(instapayReconciliationServiceProvider);
  return service.fetchUnconfirmedOnlineOrders(posProfile: posProfile);
});

/// Escalated online-payment orders (unpaid InstaPay/wallet, Out for Delivery
/// past the configured threshold), keyed by POS profile the same way as
/// [unconfirmedOnlineOrdersProvider]. Already sorted worst-first by the
/// service. Invalidate alongside [unconfirmedOnlineOrdersProvider] after any
/// confirm / convert-to-cash mutation.
final unconfirmedPaymentEscalationsProvider = FutureProvider.autoDispose
    .family<List<EscalatedPaymentOrder>, String?>((ref, posProfile) async {
  final service = ref.watch(instapayReconciliationServiceProvider);
  return service.fetchUnconfirmedPaymentEscalations(posProfile: posProfile);
});
