/// Centralised API endpoint paths.
///
/// Every `/api/method/…` string used by the mobile app lives here so that
/// a backend module rename only requires a single-file update.
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/api/method/login';
  static const logout = '/api/method/logout';
  static const getLoggedUser = '/api/method/frappe.auth.get_logged_user';

  // ── User ──────────────────────────────────────────────────────────────
  static const getCurrentUserRoles =
      '/api/method/jarz_pos.api.user.get_current_user_roles';

  // ── POS ───────────────────────────────────────────────────────────────
  static const getPosProfiles =
      '/api/method/jarz_pos.api.pos.get_pos_profiles';
  static const getProfileBundles =
      '/api/method/jarz_pos.api.pos.get_profile_bundles';
  static const getPosProfileAccountBalance =
      '/api/method/jarz_pos.api.pos.get_pos_profile_account_balance';
  static const getProfileProducts =
      '/api/method/jarz_pos.api.pos.get_profile_products';
  static const getSalesPartners =
      '/api/method/jarz_pos.api.pos.get_sales_partners';
  static const isPosProfileOpen =
      '/api/method/jarz_pos.api.pos.is_pos_profile_open';

  // ── Customer ──────────────────────────────────────────────────────────
  static const getTerritories =
      '/api/method/jarz_pos.api.customer.get_territories';
  static const searchCustomers =
      '/api/method/jarz_pos.api.customer.search_customers';
  static const createCustomer =
      '/api/method/jarz_pos.api.customer.create_customer';
  static const updateDefaultAddress =
      '/api/method/jarz_pos.api.customer.update_default_address';

  // ── Invoices ──────────────────────────────────────────────────────────
  static const createPosInvoice =
      '/api/method/jarz_pos.api.invoices.create_pos_invoice';
  static const payInvoice =
      '/api/method/jarz_pos.api.invoices.pay_invoice';
  static const getInvoiceSettlementPreview =
      '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview';
  static const updateInvoiceDeliverySlot =
      '/api/method/jarz_pos.api.invoices.update_invoice_delivery_slot';

  // ── Delivery Slots ────────────────────────────────────────────────────
  static const getAvailableDeliverySlots =
      '/api/method/jarz_pos.api.delivery_slots.get_available_delivery_slots';
  static const getNextAvailableSlot =
      '/api/method/jarz_pos.api.delivery_slots.get_next_available_slot';

  // ── Shift ─────────────────────────────────────────────────────────────
  static const getActiveShift =
      '/api/method/jarz_pos.api.shift.get_active_shift';
  static const getShiftPaymentMethods =
      '/api/method/jarz_pos.api.shift.get_shift_payment_methods';
  static const startShift =
      '/api/method/jarz_pos.api.shift.start_shift';
  static const getShiftSummary =
      '/api/method/jarz_pos.api.shift.get_shift_summary';
  static const endShift =
      '/api/method/jarz_pos.api.shift.end_shift';

  // ── Kanban ────────────────────────────────────────────────────────────
  static const getKanbanColumns =
      '/api/method/jarz_pos.api.kanban.get_kanban_columns';
  static const getKanbanInvoices =
      '/api/method/jarz_pos.api.kanban.get_kanban_invoices';
  static const updateInvoiceState =
      '/api/method/jarz_pos.api.kanban.update_invoice_state';
  static const cancelInvoice =
      '/api/method/jarz_pos.api.kanban.cancel_invoice';
  static const getInvoiceDetails =
      '/api/method/jarz_pos.api.kanban.get_invoice_details';
  static const getKanbanFilters =
      '/api/method/jarz_pos.api.kanban.get_kanban_filters';

  // ── Couriers / Delivery ───────────────────────────────────────────────
  static const getCourierBalances =
      '/api/method/jarz_pos.api.couriers.get_courier_balances';
  static const handleOutForDeliveryTransition =
      '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition';
  static const getActiveCouriers =
      '/api/method/jarz_pos.api.couriers.get_active_couriers';
  static const markCourierOutstanding =
      '/api/method/jarz_pos.api.couriers.mark_courier_outstanding';
  static const createDeliveryParty =
      '/api/method/jarz_pos.api.couriers.create_delivery_party';
  static const settleSingleInvoicePaid =
      '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid';
  static const settleCourierCollectedPayment =
      '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment';
  static const generateSettlementPreview =
      '/api/method/jarz_pos.api.couriers.generate_settlement_preview';
  static const confirmSettlement =
      '/api/method/jarz_pos.api.couriers.confirm_settlement';

  // ── Delivery Handling (service-level endpoints) ───────────────────────
  static const settleDeliveryParty =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_delivery_party';
  static const settleCourier =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_courier';
  static const salesPartnerUnpaidOutForDelivery =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery';
  static const salesPartnerPaidOutForDelivery =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery';

  // ── Notifications ─────────────────────────────────────────────────────
  static const registerMobileDevice =
      '/api/method/jarz_pos.api.notifications.register_mobile_device';
  static const acknowledgeInvoice =
      '/api/method/jarz_pos.api.notifications.acknowledge_invoice';
  static const getPendingAlerts =
      '/api/method/jarz_pos.api.notifications.get_pending_alerts';
  static const checkForUpdates =
      '/api/method/jarz_pos.api.notifications.check_for_updates';
  static const getRecentInvoices =
      '/api/method/jarz_pos.api.notifications.get_recent_invoices';
  static const testWebsocketEmission =
      '/api/method/jarz_pos.api.notifications.test_websocket_emission';
  static const getWebsocketDebugInfo =
      '/api/method/jarz_pos.api.notifications.get_websocket_debug_info';

  // ── Purchase ──────────────────────────────────────────────────────────
  static const getSuppliers =
      '/api/method/jarz_pos.api.purchase.get_suppliers';
  static const getRecentSuppliers =
      '/api/method/jarz_pos.api.purchase.get_recent_suppliers';
  static const searchItems =
      '/api/method/jarz_pos.api.purchase.search_items';
  static const getItemDetails =
      '/api/method/jarz_pos.api.purchase.get_item_details';
  static const getItemPrice =
      '/api/method/jarz_pos.api.purchase.get_item_price';
  static const createPurchaseInvoice =
      '/api/method/jarz_pos.api.purchase.create_purchase_invoice';

  // ── Manager ───────────────────────────────────────────────────────────
  static const getManagerDashboardSummary =
      '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary';
  static const getManagerOrders =
      '/api/method/jarz_pos.api.manager.get_manager_orders';
  static const getManagerStates =
      '/api/method/jarz_pos.api.manager.get_manager_states';
  static const updateInvoiceBranch =
      '/api/method/jarz_pos.api.manager.update_invoice_branch';

  // ── Stock Transfer ────────────────────────────────────────────────────
  static const transferListPosProfiles =
      '/api/method/jarz_pos.api.transfer.list_pos_profiles';
  static const transferListItemGroups =
      '/api/method/jarz_pos.api.transfer.list_item_groups';
  static const searchItemsWithStock =
      '/api/method/jarz_pos.api.transfer.search_items_with_stock';
  static const submitTransfer =
      '/api/method/jarz_pos.api.transfer.submit_transfer';

  // ── Cash Transfer ─────────────────────────────────────────────────────
  static const cashTransferListAccounts =
      '/api/method/jarz_pos.api.cash_transfer.list_accounts';
  static const cashTransferSubmit =
      '/api/method/jarz_pos.api.cash_transfer.submit_transfer';

  // ── Manufacturing ─────────────────────────────────────────────────────
  static const listDefaultBomItems =
      '/api/method/jarz_pos.api.manufacturing.list_default_bom_items';
  static const getBomDetails =
      '/api/method/jarz_pos.api.manufacturing.get_bom_details';
  static const submitWorkOrders =
      '/api/method/jarz_pos.api.manufacturing.submit_work_orders';
  static const submitSingleWorkOrder =
      '/api/method/jarz_pos.api.manufacturing.submit_single_work_order';
  static const listRecentWorkOrders =
      '/api/method/jarz_pos.api.manufacturing.list_recent_work_orders';

  // ── Inventory Count ───────────────────────────────────────────────────
  static const listWarehouses =
      '/api/method/jarz_pos.api.inventory_count.list_warehouses';
  static const listItemsForCount =
      '/api/method/jarz_pos.api.inventory_count.list_items_for_count';
  static const submitReconciliation =
      '/api/method/jarz_pos.api.inventory_count.submit_reconciliation';

  // ── Expenses ──────────────────────────────────────────────────────────
  static const getExpenseBootstrap =
      '/api/method/jarz_pos.api.expenses.get_expense_bootstrap';
  static const createExpense =
      '/api/method/jarz_pos.api.expenses.create_expense';
  static const approveExpense =
      '/api/method/jarz_pos.api.expenses.approve_expense';

  // ── Payment Receipts ──────────────────────────────────────────────────
  static const listPaymentReceipts =
      '/api/method/jarz_pos.api.payment_receipts.list_payment_receipts';
  static const createPaymentReceipt =
      '/api/method/jarz_pos.api.payment_receipts.create_payment_receipt';
  static const uploadReceiptImage =
      '/api/method/jarz_pos.api.payment_receipts.upload_receipt_image';
  static const confirmReceipt =
      '/api/method/jarz_pos.api.payment_receipts.confirm_receipt';
  static const getAccessiblePosProfiles =
      '/api/method/jarz_pos.api.payment_receipts.get_accessible_pos_profiles';

  // ── Settings ──────────────────────────────────────────────────────────
  static const getReceiptConfig =
      '/api/method/jarz_pos.api.pos.get_receipt_config';
}
