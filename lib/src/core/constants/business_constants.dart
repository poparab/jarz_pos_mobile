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
  static const pending = 'pending';
  static const accepted = 'accepted';
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
  static const moderator = 'Moderator';
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
