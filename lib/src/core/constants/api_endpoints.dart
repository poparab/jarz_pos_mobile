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
  static const getPosProfiles = '/api/method/jarz_pos.api.pos.get_pos_profiles';
  static const getProfileBundles =
      '/api/method/jarz_pos.api.pos.get_profile_bundles';
  static const getPosProfileAccountBalance =
      '/api/method/jarz_pos.api.pos.get_pos_profile_account_balance';
  static const getProfileProducts =
      '/api/method/jarz_pos.api.pos.get_profile_products';
  static const getPosPriceLists =
      '/api/method/jarz_pos.api.pos.get_pos_price_lists';
  static const getCommercialPolicies =
      '/api/method/jarz_pos.api.pos.get_commercial_policies';
  static const resolveCustomerPriceList =
      '/api/method/jarz_pos.api.pos.resolve_customer_price_list';
  static const getSalesPartners =
      '/api/method/jarz_pos.api.pos.get_sales_partners';
  static const isPosProfileOpen =
      '/api/method/jarz_pos.api.pos.is_pos_profile_open';
  static const getTerritoryPosProfile =
      '/api/method/jarz_pos.api.pos.get_territory_pos_profile';

  // ── Customer ──────────────────────────────────────────────────────────
  static const getTerritories =
      '/api/method/jarz_pos.api.customer.get_territories';
  static const searchCustomers =
      '/api/method/jarz_pos.api.customer.search_customers';
  static const createCustomer =
      '/api/method/jarz_pos.api.customer.create_customer';
  static const updateDefaultAddress =
      '/api/method/jarz_pos.api.customer.update_default_address';
  static const getCustomerShippingAddresses =
      '/api/method/jarz_pos.api.customer.get_customer_shipping_addresses';
  static const saveCustomerShippingAddress =
      '/api/method/jarz_pos.api.customer.save_customer_shipping_address';
  static const updateCustomerShippingAddress =
      '/api/method/jarz_pos.api.customer.update_customer_shipping_address';
  static const deleteCustomerShippingAddress =
      '/api/method/jarz_pos.api.customer.delete_customer_shipping_address';
  static const changeInvoiceShippingAddress =
      '/api/method/jarz_pos.api.customer.change_invoice_shipping_address';

  // ── Geo ───────────────────────────────────────────────────────────────
  /// Read-only resolve of a pasted Maps link into coordinates + the distance
  /// from the branch. Writes nothing; the address save carries the result.
  static const previewMapsLink =
      '/api/method/jarz_pos.api.geo.preview_maps_link';

  // ── Invoices ──────────────────────────────────────────────────────────
  static const createPosInvoice =
      '/api/method/jarz_pos.api.invoices.create_pos_invoice';
  static const validatePromoCodes =
      '/api/method/jarz_pos.api.promo.validate_promo_codes';
  static const submitInvoiceAmendment =
      '/api/method/jarz_pos.api.manager.submit_invoice_amendment';
  static const payInvoice = '/api/method/jarz_pos.api.invoices.pay_invoice';
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
  static const startShift = '/api/method/jarz_pos.api.shift.start_shift';
  static const getShiftSummary =
      '/api/method/jarz_pos.api.shift.get_shift_summary';
  static const endShift = '/api/method/jarz_pos.api.shift.end_shift';
  static const getForceCloseShiftPreview =
      '/api/method/jarz_pos.api.shift.get_force_close_preview';
  static const forceCloseShift =
      '/api/method/jarz_pos.api.shift.force_close_shift';

  // ── Kanban ────────────────────────────────────────────────────────────
  static const getKanbanColumns =
      '/api/method/jarz_pos.api.kanban.get_kanban_columns';
  static const getKanbanInvoices =
      '/api/method/jarz_pos.api.kanban.get_kanban_invoices';
  static const updateInvoiceState =
      '/api/method/jarz_pos.api.kanban.update_invoice_state';
  static const previewInvoiceOutForDelivery =
      '/api/method/jarz_pos.api.kanban.preview_invoice_out_for_delivery';
  static const cancelInvoice = '/api/method/jarz_pos.api.kanban.cancel_invoice';
  // Post-dispatch return workflow (credit note + return delivery note).
  static const getReturnPreview =
      '/api/method/jarz_pos.api.returns.get_return_preview';
  static const submitInvoiceReturn =
      '/api/method/jarz_pos.api.returns.submit_invoice_return';
  static const getInvoiceDetails =
      '/api/method/jarz_pos.api.kanban.get_invoice_details';
  static const getInvoiceNotes =
      '/api/method/jarz_pos.api.kanban.get_invoice_notes';
  static const addInvoiceNote =
      '/api/method/jarz_pos.api.kanban.add_invoice_note';
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
  static const getDeliveryPartnersList =
      '/api/method/jarz_pos.api.couriers.get_delivery_partners_list';
  static const settleSingleInvoicePaid =
      '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid';
  static const settleCourierCollectedPayment =
      '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment';
  static const changePaymentCollectionMethod =
      '/api/method/jarz_pos.api.couriers.change_payment_collection_method';
  static const generateSettlementPreview =
      '/api/method/jarz_pos.api.couriers.generate_settlement_preview';
  static const confirmSettlement =
      '/api/method/jarz_pos.api.couriers.confirm_settlement';

  // ── InstaPay-on-delivery reconciliation (online payment assurance) ─────
  static const deliverOnlineUnconfirmed =
      '/api/method/jarz_pos.api.couriers.deliver_online_unconfirmed';
  static const listUnconfirmedOnlineOrders =
      '/api/method/jarz_pos.api.couriers.list_unconfirmed_online_orders';
  static const confirmOnlinePayment =
      '/api/method/jarz_pos.api.couriers.confirm_online_payment';
  static const convertOnlineOrderToCod =
      '/api/method/jarz_pos.api.couriers.convert_online_order_to_cod';

  // ── Delivery Handling (service-level endpoints) ───────────────────────
  static const settleDeliveryParty =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_delivery_party';
  static const settleCourier =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.settle_courier';
  static const salesPartnerUnpaidOutForDelivery =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery';
  static const salesPartnerPaidOutForDelivery =
      '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery';

  // ── App releases ──────────────────────────────────────────────────────
  /// Guest-callable on purpose: the update check runs before login, so a build
  /// below the floor is stopped at the splash screen rather than after it has
  /// authenticated and started writing.
  static const getAppRequirement =
      '/api/method/jarz_pos.api.app_release.get_app_requirement';

  // ── Notifications ─────────────────────────────────────────────────────
  static const registerMobileDevice =
      '/api/method/jarz_pos.api.notifications.register_mobile_device';
  static const getVapidPublicKey =
      '/api/method/jarz_pos.api.notifications.get_vapid_public_key';
  static const registerVapidSubscription =
      '/api/method/jarz_pos.api.notifications.register_vapid_subscription';
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
  static const getSuppliers = '/api/method/jarz_pos.api.purchase.get_suppliers';
  static const getRecentSuppliers =
      '/api/method/jarz_pos.api.purchase.get_recent_suppliers';
  static const searchItems = '/api/method/jarz_pos.api.purchase.search_items';
  static const getItemDetails =
      '/api/method/jarz_pos.api.purchase.get_item_details';
  static const getItemPrice =
      '/api/method/jarz_pos.api.purchase.get_item_price';
  static const createPurchaseInvoice =
      '/api/method/jarz_pos.api.purchase.create_purchase_invoice';
  static const getPurchaseInvoices =
      '/api/method/jarz_pos.api.purchase.get_purchase_invoices';
  static const createSupplier =
      '/api/method/jarz_pos.api.purchase.create_supplier';
  static const getSupplierGroups =
      '/api/method/jarz_pos.api.purchase.get_supplier_groups';
  static const getPurchaseTaxesTemplates =
      '/api/method/jarz_pos.api.purchase.get_purchase_taxes_templates';
  static const getItemTaxTemplates =
      '/api/method/jarz_pos.api.purchase.get_item_tax_templates';
  static const payPurchaseInvoice =
      '/api/method/jarz_pos.api.purchase.pay_purchase_invoice';
  static const returnPurchaseInvoice =
      '/api/method/jarz_pos.api.purchase.return_purchase_invoice';

  // ── Purchase requests (team item requests) ────────────────────────────
  static const createItemRequest =
      '/api/method/jarz_pos.api.purchase_request.create_request';
  static const listItemRequests =
      '/api/method/jarz_pos.api.purchase_request.list_requests';
  static const stopItemRequest =
      '/api/method/jarz_pos.api.purchase_request.stop_request';
  static const reopenItemRequest =
      '/api/method/jarz_pos.api.purchase_request.reopen_request';
  static const getOpenRequestLines =
      '/api/method/jarz_pos.api.purchase_request.get_open_request_lines';

  // ── Manager ───────────────────────────────────────────────────────────
  static const getManagerDashboardSummary =
      '/api/method/jarz_pos.api.manager.get_manager_dashboard_summary';
  static const getPosShiftMonitor =
      '/api/method/jarz_pos.api.manager.get_pos_shift_monitor';
  static const getManagerTransferTargetBranches =
      '/api/method/jarz_pos.api.manager.get_transfer_target_branches';
  static const getManagerOrders =
      '/api/method/jarz_pos.api.manager.get_manager_orders';
  static const getManagerStates =
      '/api/method/jarz_pos.api.manager.get_manager_states';
  static const updateInvoiceBranch =
      '/api/method/jarz_pos.api.manager.update_invoice_branch';
  // Per-employee outstanding: HRMS cash advances + unpaid Employee-purpose
  // POS orders, rolled up into a single balance per person.
  static const getEmployeeLedger =
      '/api/method/jarz_pos.api.manager.get_employee_ledger';

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

  // ── Manufacturing / Production ────────────────────────────────────────
  static const getProductionSuggestions =
      '/api/method/jarz_pos.api.production.get_production_suggestions';
  static const getBasketMaterialRollup =
      '/api/method/jarz_pos.api.production.get_basket_material_rollup';
  static const setItemTargetDays =
      '/api/method/jarz_pos.api.production.set_item_target_days';
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
  static const startProductionBatch =
      '/api/method/jarz_pos.api.manufacturing.start_production_batch';
  static const finishProductionBatch =
      '/api/method/jarz_pos.api.manufacturing.finish_production_batch';
  static const listRunningWorkOrders =
      '/api/method/jarz_pos.api.manufacturing.list_running_work_orders';
  static const getBatchCost =
      '/api/method/jarz_pos.api.manufacturing.get_batch_cost';
  static const returnWipToStore =
      '/api/method/jarz_pos.api.manufacturing.return_wip_to_store';

  // ── Sub-assemblies (bases) ────────────────────────────────────────────
  // Bases are never sold, so the sales-driven board computes zero for them.
  // These two answer "what bases exist" and "what would N batches cost me"
  // instead; starting one still goes through `start_production_batch`.
  static const getBaseItems =
      '/api/method/jarz_pos.api.subassembly.get_base_items';
  static const previewBaseBatch =
      '/api/method/jarz_pos.api.subassembly.preview_base_batch';

  // ── Daily Production Plan ─────────────────────────────────────────────
  static const dailyPlanTemplate =
      '/api/method/jarz_pos.api.daily_plan.get_plan_template';
  static const dailyPlanPreview =
      '/api/method/jarz_pos.api.daily_plan.preview_plan';
  static const dailyPlanSave = '/api/method/jarz_pos.api.daily_plan.save_plan';
  static const dailyPlanClose = '/api/method/jarz_pos.api.daily_plan.close_plan';
  static const dailyPlanGet = '/api/method/jarz_pos.api.daily_plan.get_plan';
  static const dailyPlanList = '/api/method/jarz_pos.api.daily_plan.list_plans';
  static const dailyPlanBomReadiness =
      '/api/method/jarz_pos.api.daily_plan.check_bom_readiness';

  // ── Production SOPs ───────────────────────────────────────────────────
  static const getSopForItem = '/api/method/jarz_pos.api.sop.get_sop_for_item';
  static const getSopForWorkOrder =
      '/api/method/jarz_pos.api.sop.get_sop_for_work_order';
  static const recordSopStepCapture =
      '/api/method/jarz_pos.api.sop.record_sop_step_capture';
  static const listSops = '/api/method/jarz_pos.api.sop.list_sops';

  /// Frappe core, not a jarz_pos method — SOP photo captures have to become a
  /// File on the site before `record_sop_step_capture` can reference a URL.
  static const uploadFile = '/api/method/upload_file';

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

  // ── Employee Advances ─────────────────────────────────────────────────
  // Cash advances a line manager requests for an employee and a JARZ Manager
  // approves. Approval submits the HRMS Employee Advance AND posts the Payment
  // Entry in one call, so cash leaves the chosen branch account immediately.
  static const getEmployeeAdvanceBootstrap =
      '/api/method/jarz_pos.api.employee_advances.get_employee_advance_bootstrap';
  static const createEmployeeAdvanceRequest =
      '/api/method/jarz_pos.api.employee_advances.create_employee_advance_request';
  static const approveEmployeeAdvance =
      '/api/method/jarz_pos.api.employee_advances.approve_employee_advance';
  static const rejectEmployeeAdvance =
      '/api/method/jarz_pos.api.employee_advances.reject_employee_advance';

  // ── Payment Receipts ──────────────────────────────────────────────────
  static const listPaymentReceipts =
      '/api/method/jarz_pos.api.payment_receipts.list_payment_receipts';
  static const createPaymentReceipt =
      '/api/method/jarz_pos.api.payment_receipts.create_payment_receipt';
  static const uploadReceiptImage =
      '/api/method/jarz_pos.api.payment_receipts.upload_receipt_image';
  static const removeReceiptImage =
      '/api/method/jarz_pos.api.payment_receipts.remove_receipt_image';
  static const confirmReceipt =
      '/api/method/jarz_pos.api.payment_receipts.confirm_receipt';
  static const getAccessiblePosProfiles =
      '/api/method/jarz_pos.api.payment_receipts.get_accessible_pos_profiles';

  // ── Reports ───────────────────────────────────────────────────────────
  static const getFinalProductsReport =
      '/api/method/jarz_pos.api.reports.get_final_products_report';
  static const getMaterialsReport =
      '/api/method/jarz_pos.api.reports.get_materials_report';
  static const getMasterOrders =
      '/api/method/jarz_pos.api.orders.get_master_orders';

  // ── Reports · Analytics dashboards ────────────────────────────────────
  static const getShippingAnalytics =
      '/api/method/jarz_pos.api.shipping_analytics.get_shipping_analytics';
  static const getInventoryAnalytics =
      '/api/method/jarz_pos.api.inventory_analytics.get_inventory_analytics';
  static const getProductAnalytics =
      '/api/method/jarz_pos.api.product_analytics.get_product_analytics';
  static const getCustomerAnalytics =
      '/api/method/jarz_pos.api.customer_analytics.get_customer_analytics';
  static const getExecutiveOverview =
      '/api/method/jarz_pos.api.executive_analytics.get_executive_overview';
  static const getB2bAnalytics =
      '/api/method/jarz_pos.api.b2b_analytics.get_b2b_analytics';

  // ── Settings ──────────────────────────────────────────────────────────
  static const getReceiptConfig =
      '/api/method/jarz_pos.api.pos.get_receipt_config';

  // ── Sub-territories ───────────────────────────────────────────────────
  static const getSubTerritories =
      '/api/method/jarz_pos.api.territories.get_sub_territories';
  static const setInvoiceSubTerritory =
      '/api/method/jarz_pos.api.territories.set_invoice_sub_territory';

  // ── Delivery Trips ────────────────────────────────────────────────────
  static const createDeliveryTrip =
      '/api/method/jarz_pos.api.trips.create_delivery_trip';
  static const getDeliveryTrips =
      '/api/method/jarz_pos.api.trips.get_delivery_trips';
  static const getTripDetails =
      '/api/method/jarz_pos.api.trips.get_trip_details';
  static const previewTripForDelivery =
      '/api/method/jarz_pos.api.trips.preview_trip_for_delivery';
  static const sendTripForDelivery =
      '/api/method/jarz_pos.api.trips.send_trip_for_delivery';
  static const markTripAsDelivered =
      '/api/method/jarz_pos.api.trips.mark_trip_as_delivered';

  // ── B2B CRM ───────────────────────────────────────────────────────────
  static const getB2bPipeline =
      '/api/method/jarz_pos.api.crm.get_b2b_pipeline';
  static const getB2bAccount = '/api/method/jarz_pos.api.crm.get_account';
  static const b2bAdvanceStage = '/api/method/jarz_pos.api.crm.advance_stage';
  static const b2bCreateLead = '/api/method/jarz_pos.api.crm.create_lead';
  static const b2bLogActivity = '/api/method/jarz_pos.api.crm.log_activity';
  static const getB2bFollowups =
      '/api/method/jarz_pos.api.crm.get_my_followups';
  static const getB2bReorderDue = '/api/method/jarz_pos.api.crm.get_reorder_due';
  static const b2bRequestSample = '/api/method/jarz_pos.api.crm.request_sample';
  static const b2bPlaceOrder = '/api/method/jarz_pos.api.crm.place_b2b_order';
  static const getLeadSources =
      '/api/method/jarz_pos.api.crm.get_lead_sources';
  static const completeFollowup =
      '/api/method/jarz_pos.api.crm.complete_followup';

  // ── Pricing (Price Lists) ─────────────────────────────────────────────
  static const getPriceLists =
      '/api/method/jarz_pos.api.price_lists.get_price_lists';
  static const getPriceListDetail =
      '/api/method/jarz_pos.api.price_lists.get_price_list_detail';
  static const getCustomerPricing =
      '/api/method/jarz_pos.api.price_lists.get_customer_pricing';
  static const listPricingCategories =
      '/api/method/jarz_pos.api.price_lists.list_pricing_categories';
  static const searchB2bCustomers =
      '/api/method/jarz_pos.api.price_lists.search_b2b_customers';
  static const createPriceList =
      '/api/method/jarz_pos.api.price_lists.create_price_list';
  static const setCategoryPrice =
      '/api/method/jarz_pos.api.price_lists.set_category_price';
  static const setItemOverride =
      '/api/method/jarz_pos.api.price_lists.set_item_override';
  static const assignCustomerToPriceList =
      '/api/method/jarz_pos.api.price_lists.assign_customer_to_price_list';

  // ── Leads (B2B prospect research) ─────────────────────────────────────
  static const getLeads = '/api/method/jarz_pos.api.leads.get_leads';
  static const getLead = '/api/method/jarz_pos.api.leads.get_lead';
  static const saveLead = '/api/method/jarz_pos.api.leads.save_lead';
  static const saveLeadContacts =
      '/api/method/jarz_pos.api.leads.save_lead_contacts';
  static const setLeadAddress =
      '/api/method/jarz_pos.api.leads.set_lead_address';
  static const getLeadCategories =
      '/api/method/jarz_pos.api.leads.get_lead_categories';
  static const saveLeadCategory =
      '/api/method/jarz_pos.api.leads.save_lead_category';
  static const getNotSuitableReasons =
      '/api/method/jarz_pos.api.leads.get_not_suitable_reasons';
  static const setLeadSuitability =
      '/api/method/jarz_pos.api.leads.set_lead_suitability';
  static const getMergeCandidates =
      '/api/method/jarz_pos.api.leads.get_merge_candidates';
  static const mergeLeads = '/api/method/jarz_pos.api.leads.merge_leads';

  // ── Journey notes (the rep's dated field diary) ───────────────────────
  // Shared by the leads catalog and the B2B pipeline: the same note timeline
  // hangs off a Lead, an Opportunity or a Customer.
  static const getJourneyNotes =
      '/api/method/jarz_pos.api.journey.get_journey_notes';
  static const addJourneyNote =
      '/api/method/jarz_pos.api.journey.add_journey_note';
  static const updateJourneyNote =
      '/api/method/jarz_pos.api.journey.update_journey_note';
  static const deleteJourneyNote =
      '/api/method/jarz_pos.api.journey.delete_journey_note';
  static const getJourneyOptions =
      '/api/method/jarz_pos.api.journey.get_journey_options';
  // The people already recorded on the account, so the editor's "who I spoke
  // to" box is a pick, not a retype. Both read and write land on the SAME
  // roster the lead page's contacts section edits.
  static const getJourneyContacts =
      '/api/method/jarz_pos.api.journey.get_journey_contacts';
  static const addJourneyContact =
      '/api/method/jarz_pos.api.journey.add_journey_contact';
  // Closing the loop on a promise, and the calendar of everything still open.
  // A next action with no done state keeps tinting cards and keeps its
  // reminder nagging long after the rep actually made the call.
  static const setJourneyActionDone =
      '/api/method/jarz_pos.api.journey.set_journey_action_done';
  static const getJourneyActionCalendar =
      '/api/method/jarz_pos.api.journey.get_action_calendar';

  // ── Sales material sharing ────────────────────────────────────────────
  // The price list a rep sends on WhatsApp after a visit. The app never sees
  // the files: it picks a pack, the backend mints one public link, and the
  // customer opens a page built for reading a price list on a phone.
  static const getSalesMaterials =
      '/api/method/jarz_pos.api.materials.get_sales_materials';
  static const createMaterialShare =
      '/api/method/jarz_pos.api.materials.create_material_share';
  static const getMaterialShares =
      '/api/method/jarz_pos.api.materials.get_material_shares';

  // ── B2B visit planning ────────────────────────────────────────────────
  // A day's field route: which doors, in what order. The catalog answers "who
  // is worth visiting"; these answer "and when am I actually going".
  static const getVisitPlans =
      '/api/method/jarz_pos.api.visits.get_visit_plans';
  static const getVisitPlan = '/api/method/jarz_pos.api.visits.get_visit_plan';
  static const createVisitPlan =
      '/api/method/jarz_pos.api.visits.create_visit_plan';
  static const updateVisitPlan =
      '/api/method/jarz_pos.api.visits.update_visit_plan';
  static const deleteVisitPlan =
      '/api/method/jarz_pos.api.visits.delete_visit_plan';
  static const setVisitStops =
      '/api/method/jarz_pos.api.visits.set_visit_stops';
  static const addVisitStops =
      '/api/method/jarz_pos.api.visits.add_stops_to_plan';
  static const optimizeVisitPlan =
      '/api/method/jarz_pos.api.visits.optimize_visit_plan';
  static const setVisitStopStatus =
      '/api/method/jarz_pos.api.visits.set_visit_stop_status';
  static const getVisitTargets =
      '/api/method/jarz_pos.api.visits.get_visit_targets';
  static const suggestVisitPlan =
      '/api/method/jarz_pos.api.visits.suggest_visit_plan';
  // Tells the UI whether distances are real road distances or straight-line
  // estimates — and, when they are estimates, whether that is configuration or
  // a failure. Identical symptoms, different fixes.
  static const getRouteEngineStatus =
      '/api/method/jarz_pos.api.visits.get_route_engine_status';
  // Adding a door to a day from wherever the rep already is — the kanban card,
  // the leads list, the map callout, the lead page. Resolves one record to its
  // routable doors so no screen needs to know how doors are stored.
  static const getRecordVisitTargets =
      '/api/method/jarz_pos.api.visits.get_record_visit_targets';
  static const getAddableVisitPlans =
      '/api/method/jarz_pos.api.visits.get_addable_visit_plans';
  // Orders and costs a stop list without saving, so the builder can show the
  // real route while the rep is still choosing.
  static const previewVisitRoute =
      '/api/method/jarz_pos.api.visits.preview_visit_route';

  // ── Courier tracking (jarz_courier app) ───────────────────────────────
  // Supervisor-only and Redis-backed, so it is safe to poll. Couriers are
  // deliberately excluded server-side: a courier may see their own run, never
  // a colleague's live position.
  static const getLiveCourierPositions =
      '/api/method/jarz_courier.api.tracking.get_live_positions';

  // ── B2B customer labels ───────────────────────────────────────────────
  // Printed-label stock per B2B customer: how many are left, how fast they are
  // going, and when a batch has to go to the print house to land before they
  // run out. Gated server-side on B2B or manager access.
  static const getLabelDashboard =
      '/api/method/jarz_pos.api.labels.get_label_dashboard';
  static const getLabelAlertCount =
      '/api/method/jarz_pos.api.labels.get_label_alert_count';
  static const getLabelDetail =
      '/api/method/jarz_pos.api.labels.get_label_detail';
  static const searchLabelCustomers =
      '/api/method/jarz_pos.api.labels.search_label_customers';
  static const getLabelFlavourOptions =
      '/api/method/jarz_pos.api.labels.get_flavour_options';
  static const getLabelStorageLocations =
      '/api/method/jarz_pos.api.labels.get_storage_locations';
  static const getLabelPrintSuppliers =
      '/api/method/jarz_pos.api.labels.get_print_suppliers';
  static const setupCustomerLabels =
      '/api/method/jarz_pos.api.labels.setup_customer_labels';
  static const createLabel = '/api/method/jarz_pos.api.labels.create_label';
  static const updateLabel = '/api/method/jarz_pos.api.labels.update_label';
  static const recordLabelMovement =
      '/api/method/jarz_pos.api.labels.record_movement';
  static const recordLabelCount =
      '/api/method/jarz_pos.api.labels.record_count';
  static const createLabelPrintOrder =
      '/api/method/jarz_pos.api.labels.create_print_order';
  static const updateLabelPrintOrder =
      '/api/method/jarz_pos.api.labels.update_print_order';
  static const billLabelPrintOrder =
      '/api/method/jarz_pos.api.labels.bill_print_order';

  // ── Custom Shipping ───────────────────────────────────────────────────
  static const requestCustomShipping =
      '/api/method/jarz_pos.api.custom_shipping.request_custom_shipping';
  static const approveCustomShipping =
      '/api/method/jarz_pos.api.custom_shipping.approve_custom_shipping';
  static const rejectCustomShipping =
      '/api/method/jarz_pos.api.custom_shipping.reject_custom_shipping';
  static const getPendingCustomShippingRequests =
      '/api/method/jarz_pos.api.custom_shipping.get_pending_custom_shipping_requests';
}
