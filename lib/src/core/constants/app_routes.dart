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

  /// Monthly shift distribution — who works which shift, and who is off.
  /// Distinct from [shiftMonitor], which watches POS cash drawers: the two
  /// senses of "shift" in this app are unrelated.
  static const roster = '/roster';
  static const purchase = '/purchase';

  /// Team item requests. Open to all floor staff, unlike [purchase] which is
  /// manager-gated — noticing a shortage is not a manager's job.
  static const itemRequests = '/item-requests';
  static const manufacturing = '/manufacturing';

  /// The collapsed front screen of the Production Board: one list of what is
  /// coming out of the kitchen today, one Make button. [manufacturing] stays
  /// registered behind it as the advanced board, so every `?tab=N` deep link
  /// and the SOP screen's own navigation keep working.
  static const productionToday = '/manufacturing/today';

  /// Full-screen SOP execution. A real destination rather than a sheet: the
  /// operator stays in it for the length of a batch.
  static const productionSop = '/manufacturing/sop';
  static const stockTransfer = '/stock-transfer';
  static const cashTransfer = '/cash-transfer';
  static const inventoryCount = '/inventory-count';
  static const expenses = '/expenses';

  /// The company's monthly bill — the recurring-expense registry plus payroll
  /// for one month, with Pay actions. Distinct from [expenses], which records
  /// one-off spending; this pays a *period* of a standing commitment.
  static const monthlyExpenses = '/monthly-expenses';
  static const trips = '/trips';

  /// Live courier map. Supervisor-only: the tracking API deliberately refuses
  /// couriers, who may see their own run but never a colleague's position.
  static const fleetMap = '/fleet';
  static const reports = '/reports';
  static const reportsShipping = '/reports/shipping';
  static const reportsInventory = '/reports/inventory';
  static const reportsProduct = '/reports/product';
  static const reportsCustomer = '/reports/customer';
  static const reportsExecutive = '/reports/executive';
  static const reportsB2b = '/reports/b2b';
  static const masterOrders = '/master-orders';
  static const instapayReconciliation = '/instapay-reconciliation';
  static const profile = '/profile';
  static const shiftStart = '/shift/start';
  static const shiftEnd = '/shift/end';
  static const root = '/';

  // ── B2B Mode ──────────────────────────────────────────────────────────
  static const b2b = '/b2b';
  static const b2bToday = '/b2b/today';
  static const b2bAccount = '/b2b/account';
  // Everything due, on a month grid — the cross-account view of the same next
  // actions the per-account journey timeline writes.
  static const b2bCalendar = '/b2b/calendar';

  // ── Visit planner ─────────────────────────────────────────────────────
  // The rep's field days: a month of routes, one route, and the builder that
  // turns a filtered slice of the catalog into a driveable day.
  static const b2bVisits = '/b2b/visits';
  static const b2bVisitPlan = '/b2b/visits/plan';
  static const b2bVisitBuilder = '/b2b/visits/build';

  // ── Pricing (Price Lists) ─────────────────────────────────────────────
  static const pricing = '/pricing';

  // ── B2B customer labels (printed-label stock + reorder alerts) ────────
  static const labels = '/labels';
  static const labelDetail = '/labels/detail';
  static const labelSetup = '/labels/setup';

  // ── Leads (B2B prospect research) ─────────────────────────────────────
  static const leads = '/leads';
  static const leadsMap = '/leads/map';
  static const leadForm = '/leads/new';
  static const leadDetail = '/leads/:id';

  // ── Partner settlements ───────────────────────────────────────────────
  // Two payables that were only ever cleared outside the app: the delivery
  // partner's weekly bank transfer, and sales partner commission.
  static const partnerSettlements = '/partner-settlements';

  // ── Address pin correction ────────────────────────────────────────────
  // Pushed from an address or an order, never a drawer entry.
  static const addressPin = '/address-pin';

  // ── Reports added to the existing hub ─────────────────────────────────
  static const reportsVelocity = '/reports/velocity';
  static const reportsSegments = '/reports/segments';
  static const reportsWarehouseAlignment = '/reports/warehouse-alignment';

  // ── WooCommerce sync operations ───────────────────────────────────────
  // The retry / review / breaker workflow that lived only in Desk.
  static const wooSync = '/woo-sync';
  static const wooDuplicates = '/woo-sync/duplicates';
}
