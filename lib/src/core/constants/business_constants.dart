/// Business-domain constants shared between the mobile app and backend.
///
/// Status strings, payment modes, role names, and voucher types that **must**
/// match their ERPNext / backend equivalents exactly.
library;

// ── Payment modes ───────────────────────────────────────────────────────
abstract final class PaymentModes {
  static const cash = 'Cash';
  static const cashLower = 'cash';
  static const online = 'Online';
  static const onlineLower = 'online';
}

// ── Courier settlement modes ───────────────────────────────────────────
abstract final class SettlementModes {
  static const payNow = 'pay_now';
  static const later = 'later';
}

abstract final class OutForDeliverySettlement {
  static const defaultMode = SettlementModes.later;
  static const showModePicker = false;
}

// ── Invoice / document statuses ─────────────────────────────────────────
abstract final class InvoiceStatus {
  static const draft = 'Draft';
  static const draftLower = 'draft';
  static const paid = 'Paid';
  static const paidLower = 'paid';
  static const paidUpper = 'PAID';
  static const unpaid = 'Unpaid';
  static const unpaidUpper = 'UNPAID';
  static const cancelled = 'Cancelled';
  static const cancelledLower = 'cancelled';
  static const submitted = 'Submitted';
  static const submittedLower = 'submitted';
  static const returnStatus = 'Return';
  static const open = 'Open';
}

// ── Delivery / acceptance statuses ──────────────────────────────────────
abstract final class DeliveryStatus {
  static const outForDelivery = 'out for delivery';
  static const outForDeliverySnake = 'out_for_delivery';
  static const delivered = 'delivered';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  /// Terminal kanban state a fully-returned order lands in. Set by the backend
  /// post-dispatch return workflow — never by a drag.
  static const returned = 'returned';
  static const pending = 'pending';
  static const accepted = 'accepted';
}

// ── Post-dispatch return statuses ───────────────────────────────────────
/// Values of the Sales Invoice `return_status` field. Must match the backend
/// return workflow exactly; an empty/absent value means "nothing returned".
abstract final class ReturnStatus {
  static const partiallyReturned = 'Partially Returned';
  static const fullyReturned = 'Fully Returned';
}

// ── Voucher types ───────────────────────────────────────────────────────
abstract final class VoucherTypes {
  static const salesInvoice = 'Sales Invoice';
  static const journalEntry = 'Journal Entry';
  static const paymentEntry = 'Payment Entry';
}

// ── Role names ──────────────────────────────────────────────────────────
abstract final class RoleNames {
  static const jarzManager = 'JARZ Manager';
  static const jarzLineManager = 'JARZ line manager';
  static const posManager = 'POS Manager';
  static const systemManager = 'System Manager';
  static const administrator = 'Administrator';
  static const moderator = 'Moderator';
  static const jarzPosStaff = 'Jarz POS Staff';
  static const b2bSalesRep = 'B2B Sales Rep';

  // Stock/manufacturing roles. Mirror the backend `ROLES.MANUFACTURING` set so
  // the Production Board's client-side gate matches its server-side one — the
  // Manufacturing screen used to gate on a role the API did not accept, so a
  // JARZ-Manager-only user could open it and then fail every call.
  static const manufacturingManager = 'Manufacturing Manager';
  static const stockManager = 'Stock Manager';
  static const purchaseManager = 'Purchase Manager';

  /// Floor role: may run batches but not back-date a posting, edit an SOP, or
  /// start a batch above the configured value limit.
  static const productionOperator = 'Production Operator';
}

// ── Cancel reasons (defaults — will later be fetched from backend) ─────
abstract final class CancelReasons {
  static const defaults = [
    'Customer requested cancellation',
    'Order created in error / duplicate',
    'Inventory unavailable',
    'Payment issue',
    'Other',
  ];
}
