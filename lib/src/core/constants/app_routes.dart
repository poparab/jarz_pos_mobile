/// Centralised GoRouter path constants.
///
/// Use these instead of raw route strings in `context.go()` / `context.push()`
/// and in the GoRouter definition so every reference points to the same source.
abstract final class AppRoutes {
  static const login = '/login';
  static const about = '/about';
  static const pos = '/pos';
  static const selectProfile = '/pos/select-profile';
  static const kanban = '/kanban';
  static const courierBalances = '/courier-balances';
  static const printers = '/printers';
  static const manager = '/manager';
  static const shiftMonitor = '/shift-monitor';
  static const purchase = '/purchase';
  static const manufacturing = '/manufacturing';
  static const stockTransfer = '/stock-transfer';
  static const cashTransfer = '/cash-transfer';
  static const inventoryCount = '/inventory-count';
  static const expenses = '/expenses';
  static const trips = '/trips';
  static const reports = '/reports';
  static const masterOrders = '/master-orders';
  static const profile = '/profile';
  static const shiftStart = '/shift/start';
  static const shiftEnd = '/shift/end';
  static const root = '/';

  // ── B2B Mode ──────────────────────────────────────────────────────────
  static const b2b = '/b2b';
  static const b2bToday = '/b2b/today';
  static const b2bLeadAdd = '/b2b/lead/add';
  static const b2bAccount = '/b2b/account';
}
