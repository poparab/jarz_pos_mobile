/// WebSocket / Socket.IO event names.
///
/// These must match the strings published by the backend via
/// `frappe.publish_realtime()`.
///
/// The invariant is one-directional: every event this app listens to must exist
/// verbatim in the Python `jarz_pos.constants.WS_EVENTS`. The reverse does not
/// hold — Python carries events with no Dart counterpart (the `TRIP_*` and
/// `CUSTOM_SHIPPING_*` families), and the legacy/room constants below have no
/// Python counterpart. The two sets are not equal and never have been.
abstract final class WsEvents {
  // ── Invoice lifecycle ─────────────────────────────────────────────────
  static const newInvoice = 'jarz_pos_new_invoice';
  static const invoiceStateChange = 'jarz_pos_invoice_state_change';
  static const kanbanUpdate = 'kanban_update';
  static const invoiceCancelled = 'jarz_pos_invoice_cancelled';
  static const invoiceAccepted = 'jarz_pos_invoice_accepted';

  // ── Delivery / courier ────────────────────────────────────────────────
  static const outForDeliveryTransition =
      'jarz_pos_out_for_delivery_transition';
  static const courierOutstanding = 'jarz_pos_courier_outstanding';
  static const courierExpensePaid = 'jarz_pos_courier_expense_paid';
  static const courierExpenseOnly = 'jarz_pos_courier_expense_only';
  static const courierSettled = 'jarz_pos_courier_settled';
  static const singleCourierSettlement = 'jarz_pos_single_courier_settlement';
  static const courierCollectedSettlement =
      'jarz_pos_courier_collected_settlement';

  // ── Sales Partner ─────────────────────────────────────────────────────
  static const salesPartnerCollectPrompt =
      'jarz_pos_sales_partner_collect_prompt';
  static const salesPartnerUnpaidOfd =
      'jarz_pos_sales_partner_unpaid_ofd';
  static const salesPartnerPaidOfd = 'jarz_pos_sales_partner_paid_ofd';

  // ── Shift ─────────────────────────────────────────────────────────────
  static const shiftStarted = 'jarz_pos_shift_started';
  static const shiftEnded = 'jarz_pos_shift_ended';

  // ── Courier app (COURIER_CONTRACTS.md §7 — frozen 2026-08-05) ──────────
  static const courierStopArrived = 'jarz_pos_courier_stop_arrived';
  static const courierStopDelivered = 'jarz_pos_courier_stop_delivered';
  static const courierStopFailed = 'jarz_pos_courier_stop_failed';
  static const courierDutyChanged = 'jarz_pos_courier_duty_changed';
  static const courierDepositDeclared = 'jarz_pos_courier_deposit_declared';
  static const addressPinUpdated = 'jarz_pos_address_pin_updated';

  // ── Legacy / generic ─────────────────────────────────────────────────
  static const newPosInvoice = 'new_pos_invoice';
  static const posProfileUpdate = 'pos_profile_update';
  static const itemStockUpdate = 'item_stock_update';
  static const testEvent = 'test_event';
  static const message = 'message';
  static const pong = 'pong';

  // ── Raw WS rooms / actions ────────────────────────────────────────────
  static const roomPosUpdates = 'pos_updates';
  static const roomInvoiceUpdates = 'invoice_updates';
  static const roomStockUpdates = 'stock_updates';
  static const actionSubscribe = 'subscribe';
  static const actionPing = 'ping';
}
