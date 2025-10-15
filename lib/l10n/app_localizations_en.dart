// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jarz POS';

  @override
  String get drawerHeaderTitle => 'Jarz POS';

  @override
  String get drawerHeaderSubtitle => 'Mobile Point of Sale';

  @override
  String get menuPointOfSale => 'Point of Sale';

  @override
  String get menuSalesKanban => 'Sales Kanban';

  @override
  String get menuExpenses => 'Expenses';

  @override
  String get menuCourierBalances => 'Courier Balances';

  @override
  String get menuManagerDashboard => 'Manager Dashboard';

  @override
  String get menuPurchaseInvoice => 'Purchase Invoice';

  @override
  String get menuManufacturing => 'Manufacturing';

  @override
  String get menuStockTransfer => 'Stock Transfer';

  @override
  String get menuCashTransfer => 'Cash Transfer';

  @override
  String get menuInventoryCount => 'Inventory Count';

  @override
  String get menuHome => 'Home';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLogout => 'Logout';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuLanguageEnglish => 'English';

  @override
  String get menuLanguageArabic => 'Arabic';

  @override
  String menuSelectedLanguage(Object language) {
    return 'Current language: $language';
  }

  @override
  String menuConfirmLanguage(Object language) {
    return 'Switch language to $language?';
  }

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonChoose => 'Choose';

  @override
  String get commonSearchItems => 'Search items';

  @override
  String get commonSearchSuppliers => 'Search suppliers';

  @override
  String get commonNoItems => 'No items';

  @override
  String get commonNoSuppliers => 'No suppliers';

  @override
  String get commonQtyLabel => 'Qty:';

  @override
  String get commonRateLabel => 'Rate:';

  @override
  String commonAmountValue(Object amount) {
    return 'Amount: $amount';
  }

  @override
  String commonTotalValue(Object amount) {
    return 'Total: $amount';
  }

  @override
  String commonNameWithCode(Object code, Object name) {
    return '$name ($code)';
  }

  @override
  String get commonUomLabel => 'UOM:';

  @override
  String commonUomValue(Object uom) {
    return 'UOM: $uom';
  }

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonOk => 'OK';

  @override
  String get commonOnline => 'Online';

  @override
  String get commonOffline => 'Offline';

  @override
  String get commonError => 'Error';

  @override
  String commonErrorWithDetails(Object details) {
    return 'Error: $details';
  }

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String commonQtyWithUom(Object uom) {
    return 'Qty ($uom)';
  }

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesRefreshTooltip => 'Refresh';

  @override
  String get expensesNewExpense => 'New Expense';

  @override
  String get expensesRecorded => 'Expense recorded';

  @override
  String get expensesSubmitted => 'Expense submitted for approval';

  @override
  String get expensesMonthLabel => 'Month';

  @override
  String get expensesMonthCurrent => 'Current Month';

  @override
  String get expensesEmptyTitle => 'No expenses recorded for this month.';

  @override
  String get expensesEmptyManagerBody =>
      'Use the New Expense button to log team spending.';

  @override
  String get expensesEmptyStaffBody =>
      'Submit a request and a manager will review it shortly.';

  @override
  String get expensesFiltersClear => 'Clear filters';

  @override
  String get expensesFiltersTitle => 'Filter by payment method';

  @override
  String get expensesFiltersEmpty => 'No payment sources available';

  @override
  String get expensesSummaryTotal => 'Total';

  @override
  String get expensesSummaryApproved => 'Approved';

  @override
  String get expensesSummaryPending => 'Pending';

  @override
  String expensesSummaryReceipts(Object count) {
    return '$count receipts';
  }

  @override
  String expensesSummaryPendingAmount(Object amount, Object count) {
    return '$count | $amount';
  }

  @override
  String get expensesReasonLabel => 'Reason (Indirect expense account)';

  @override
  String get expensesPayFromLabel => 'Pay from';

  @override
  String get expensesAmountLabel => 'Amount';

  @override
  String get expensesAmountHint => 'Enter amount';

  @override
  String get expensesAmountInvalid => 'Enter a valid amount';

  @override
  String get expensesDateLabel => 'Expense date';

  @override
  String get expensesRemarksLabel => 'Remarks (optional)';

  @override
  String get expensesSubmitManager => 'Record expense';

  @override
  String get expensesSubmitStaff => 'Submit for approval';

  @override
  String get expensesNoOptions =>
      'Expenses cannot be created until a reason and payment source are available.';

  @override
  String get expensesApprove => 'Approve';

  @override
  String get expensesPendingStatus => 'Pending Approval';

  @override
  String get expensesApprovedStatus => 'Approved';

  @override
  String get expensesDraftStatus => 'Draft';

  @override
  String get expensesJournalEntry => 'Journal Entry';

  @override
  String get expensesPosProfile => 'POS Profile';

  @override
  String get expensesPayingAccount => 'Paying account';

  @override
  String get expensesReasonAccount => 'Expense account';

  @override
  String get expensesTimelineTitle => 'Timeline';

  @override
  String get expensesTimelineEmpty => 'No timeline available';

  @override
  String get expensesPullToRefresh => 'Pull to refresh';

  @override
  String languageChanged(Object language) {
    return 'Language changed to $language.';
  }

  @override
  String get purchaseTitle => 'Purchase Invoice';

  @override
  String get purchaseSupplierSectionTitle => 'Supplier';

  @override
  String get purchaseTapToPickSupplier => 'Tap to pick supplier';

  @override
  String get purchaseItemsSectionTitle => 'Items';

  @override
  String get purchaseShippingLabel => 'Shipping (Freight & Forwarding):';

  @override
  String get purchaseSubmit => 'Create Purchase Invoice';

  @override
  String get purchaseSelectSupplier => 'Select Supplier';

  @override
  String get purchaseRecent => 'Recent';

  @override
  String get purchaseSupplierDisabledSuffix => ' (Disabled)';

  @override
  String get purchaseNoItemsInCart => 'No items in cart';

  @override
  String purchaseCreated(Object invoice) {
    return 'Purchase created: $invoice';
  }

  @override
  String purchaseSubmitFailed(Object error) {
    return 'Purchase failed: $error';
  }

  @override
  String get purchaseSelectPayment => 'Select Payment Source';

  @override
  String get purchasePaymentProfileSubtitle =>
      'Use exact-named POS Profile cash account';

  @override
  String get purchasePaymentInstapayTitle => 'InstaPay (Bank)';

  @override
  String get purchasePaymentInstapaySubtitle =>
      'Use bank account mapped to InstaPay';

  @override
  String get purchasePaymentCashTitle => 'Cash';

  @override
  String get purchasePaymentCashSubtitle => 'Use company default Cash account';

  @override
  String get posProfileSelectionTitle => 'Select POS Profile';

  @override
  String get posProfileSelectionErrorTitle => 'Error loading POS profiles';

  @override
  String get posProfileSelectionNoProfilesTitle => 'No POS Profiles Available';

  @override
  String get posProfileSelectionNoProfilesBody =>
      'Contact your administrator to assign you to a POS profile';

  @override
  String get posProfileSelectionUnknownProfile => 'Unknown Profile';

  @override
  String posProfileSelectionWarehouseLabel(Object warehouse) {
    return 'Warehouse: $warehouse';
  }

  @override
  String get posProfileSelectionPrompt => 'Choose a POS profile:';

  @override
  String get posProfileSelectionCycleHint => 'Select POS';

  @override
  String get posProfileSelectionShortFallback => 'POS';

  @override
  String get posCartTitle => 'Shopping Cart';

  @override
  String posCartHeader(Object count) {
    return 'Cart ($count)';
  }

  @override
  String get posCartClear => 'Clear cart';

  @override
  String get posCartEmptyTitle => 'Cart is empty';

  @override
  String get posCartEmptyBody => 'Add items to get started';

  @override
  String get posCustomerUnselect => 'Remove customer';

  @override
  String get posCustomerAdd => 'Add customer';

  @override
  String posCustomerDeliveryIncomeValue(Object amount) {
    return 'Delivery income: $amount';
  }

  @override
  String get posUnknownCustomer => 'Unknown Customer';

  @override
  String get posCartPickupTitle => 'Pickup (no delivery fee)';

  @override
  String get posCartPickupDescription =>
      'Customer will collect the order from branch.';

  @override
  String get posCartDeliveryDescription =>
      'Deliver to customer at selected time.';

  @override
  String get posCartPickupChip => 'Pickup';

  @override
  String get posSubtotalLabel => 'Subtotal:';

  @override
  String get posDeliveryLabel => 'Delivery:';

  @override
  String get posTotalLabel => 'Total:';

  @override
  String get posCheckoutButton => 'Checkout';

  @override
  String get posOperationalInfoTitle => 'Operational Info';

  @override
  String get posDeliveryExpenseLabel => 'Delivery Expense:';

  @override
  String posDeliveryCostTo(Object territory) {
    return 'Cost to $territory';
  }

  @override
  String get posDeliveryCostGeneric => 'Cost to deliver';

  @override
  String get posUnknownItem => 'Unknown Item';

  @override
  String get posCartEditBundle => 'Edit Bundle';

  @override
  String get posCartClearTitle => 'Clear Cart';

  @override
  String get posCartClearMessage =>
      'Are you sure you want to remove all items from the cart?';

  @override
  String get posCartClearConfirm => 'Clear';

  @override
  String get posDeliverySelectSlot => 'Please select a delivery time';

  @override
  String get posDeliveryDialogTitle => 'Select Delivery Time';

  @override
  String get posDeliveryLoadFailed => 'Failed to load delivery slots';

  @override
  String get posDeliveryEmptyTitle => 'No delivery slots available';

  @override
  String get posDeliveryEmptyBody =>
      'Please check the POS profile timetable configuration';

  @override
  String get posDeliveryDefaultChip => 'Next';

  @override
  String get posDeliveryLoading => 'Loading delivery slots...';

  @override
  String get posDeliveryFieldLabel => 'Delivery Time';

  @override
  String get posDeliveryErrorLabel => 'Error loading slots';

  @override
  String get posDeliveryNoSlotsLabel => 'No slots available';

  @override
  String get posDeliverySelectPrompt => 'Select delivery time';

  @override
  String get posSalesPartnerPaymentTitle => 'Sales Partner Payment';

  @override
  String get posSalesPartnerPaymentDescription =>
      'Choose how the sales partner is paying for this order.';

  @override
  String get posSalesPartnerPaymentCash => 'Cash (collected now)';

  @override
  String get posSalesPartnerPaymentOnline => 'Online (already paid)';

  @override
  String get posCheckoutSuccess => 'Order placed successfully!';

  @override
  String posCheckoutFailed(Object error) {
    return 'Failed to place order: $error';
  }

  @override
  String get posBundleContentsTitle => 'Bundle Contents:';

  @override
  String get posBundleUpdated => 'Bundle updated successfully!';

  @override
  String get printerStatusBle => 'Printer: BLE';

  @override
  String get printerStatusClassic => 'Printer: Classic';

  @override
  String get printerStatusConnecting => 'Printer: Connecting…';

  @override
  String get printerStatusError => 'Printer Error';

  @override
  String get printerStatusDisconnected => 'Printer: Not Connected';

  @override
  String get branchFilterTitle => 'Filter Branches';

  @override
  String get branchFilterAllBranches => 'All Branches';

  @override
  String get branchFilterApply => 'Apply';

  @override
  String get websocketCollectCashTitle => 'Collect Cash';

  @override
  String get websocketCollectCashMessage =>
      'Collect the full order amount now from the Sales Partner courier.';

  @override
  String websocketInvoiceLabel(Object invoice) {
    return 'Invoice: $invoice';
  }

  @override
  String get systemStatusChecking => 'Checking...';

  @override
  String get systemStatusRealtime => 'Real-time';

  @override
  String get systemStatusNoRealtime => 'No real-time';

  @override
  String get systemStatusSynced => 'Synced';

  @override
  String systemStatusPendingCount(Object count) {
    return '$count pending';
  }

  @override
  String get systemStatusCouriers => 'Couriers';

  @override
  String systemStatusCourierCount(Object count) {
    return '$count couriers';
  }

  @override
  String get systemStatusPartnerChip => 'Partner';

  @override
  String get systemStatusSalesPartnerFallback => 'Sales Partner';

  @override
  String get systemStatusSyncComplete => 'Sync completed & couriers refreshed';

  @override
  String get systemStatusForceSyncTooltip => 'Force sync now';

  @override
  String get courierBalancesTitle => 'Courier Balances';

  @override
  String get courierBalancesEmpty => 'No couriers found.';

  @override
  String get courierBalancesSettledLabel => 'Settled';

  @override
  String get courierBalancesPayCourierLabel => 'Pay courier';

  @override
  String get courierBalancesCourierPaysUsLabel => 'Courier pays us';

  @override
  String courierBalancesDetailsTitle(Object courier) {
    return 'Details – $courier';
  }

  @override
  String courierBalancesCityOrderLine(
    Object city,
    Object order,
    Object shipping,
  ) {
    return 'City: $city\nOrder: $order • Shipping: $shipping';
  }

  @override
  String get courierBalancesNetLabel => 'Net';

  @override
  String get courierBalancesPreviewTooltip => 'Preview settlement';

  @override
  String courierBalancesPreviewFailed(Object error) {
    return 'Failed to load settlement preview: $error';
  }

  @override
  String get manufacturingTitle => 'Manufacturing';

  @override
  String get manufacturingManagersOnly => 'Managers only';

  @override
  String get manufacturingRecentWorkOrdersTooltip => 'Recent Work Orders';

  @override
  String get manufacturingSearchDefaultBom => 'Search items with Default BOM';

  @override
  String manufacturingWorkOrdersTitle(Object count) {
    return 'Work Orders ($count)';
  }

  @override
  String get manufacturingSubmitAll => 'Submit All';

  @override
  String get manufacturingNoItemsSelected => 'No items selected';

  @override
  String get manufacturingNoItemsFound => 'No items found';

  @override
  String manufacturingBomDescription(Object bom, Object quantity, Object uom) {
    return 'BOM: $bom • Yields $quantity $uom';
  }

  @override
  String get manufacturingBomLabel => 'BOM x';

  @override
  String get manufacturingRequiredItems => 'Required Items';

  @override
  String get manufacturingNothingToSubmit => 'Nothing to submit.';

  @override
  String get manufacturingSubmittingWorkOrders => 'Submitting work orders...';

  @override
  String manufacturingSubmitFailed(Object error) {
    return 'Submit failed: $error';
  }

  @override
  String get manufacturingSubmitAllSuccess => 'Submitted successfully';

  @override
  String manufacturingSubmitAllResult(Object success, Object total) {
    return 'Processed $total line(s). Success: $success';
  }

  @override
  String get manufacturingQuantityMustBePositive =>
      'Quantity must be greater than zero';

  @override
  String get manufacturingSubmittingSingleWorkOrder =>
      'Submitting work order...';

  @override
  String get manufacturingSubmitResult => 'Submitted';

  @override
  String manufacturingSubmitStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String manufacturingSubmitWorkOrder(Object workOrder) {
    return ' • WO: $workOrder';
  }

  @override
  String manufacturingLoadFailed(Object error) {
    return 'Failed to load: $error';
  }

  @override
  String get manufacturingRecentWorkOrdersTitle => 'Recent Work Orders';

  @override
  String get manufacturingNoWorkOrders => 'No Work Orders found';

  @override
  String manufacturingRecentWorkOrderTitle(Object name, Object status) {
    return '$name • $status';
  }

  @override
  String manufacturingRecentWorkOrderSubtitle(
    Object bom,
    Object item,
    Object quantity,
  ) {
    return '$item • $quantity • $bom';
  }

  @override
  String manufacturingComponentAvailable(Object quantity, Object uom) {
    return 'Available: $quantity $uom';
  }

  @override
  String get stockTransferTitle => 'Stock Transfer';

  @override
  String get stockTransferManagersOnly => 'Managers only';

  @override
  String stockTransferLinesTitle(Object count) {
    return 'Transfer Lines ($count)';
  }

  @override
  String stockTransferPostingChip(Object date) {
    return 'Posting: $date';
  }

  @override
  String get stockTransferSubmit => 'Submit';

  @override
  String get stockTransferProfilesMustDiffer => 'Source and Target must differ';

  @override
  String get stockTransferProfileLabelSource => 'Source';

  @override
  String get stockTransferProfileLabelTarget => 'Target';

  @override
  String get stockTransferProfilePlaceholder => 'Select POS Profile';

  @override
  String stockTransferProfileOption(Object profile, Object warehouse) {
    return '$profile • $warehouse';
  }

  @override
  String get stockTransferProfileWarehouseFallback => 'No warehouse';

  @override
  String get stockTransferSelectBranches => 'Select source and target branches';

  @override
  String get stockTransferSameProfile => 'Source and Target cannot be the same';

  @override
  String stockTransferAvailability(Object source, Object target) {
    return 'Src: $source • Dst: $target';
  }

  @override
  String stockTransferReservedSource(Object reservedSource) {
    return ' • Res Src: $reservedSource';
  }

  @override
  String stockTransferReservedTarget(Object reservedTarget) {
    return ' • Res Dst: $reservedTarget';
  }

  @override
  String get stockTransferPosTag => ' • POS';

  @override
  String get stockTransferPostingToday => 'Posting Date: Today';

  @override
  String stockTransferPostingDate(Object date) {
    return 'Posting Date: $date';
  }

  @override
  String get stockTransferUseToday => 'Use Today';

  @override
  String get stockTransferNoLines => 'No lines';

  @override
  String stockTransferBeforeBase(Object source, Object target) {
    return 'Before — Src: $source • Dst: $target';
  }

  @override
  String stockTransferAfterBase(Object source, Object target) {
    return 'After  — Src: $source • Dst: $target';
  }

  @override
  String stockTransferTransferCreated(Object stockEntry) {
    return 'Transfer created: $stockEntry';
  }

  @override
  String stockTransferSubmitFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String stockTransferBulkAddFailed(Object error) {
    return 'Bulk add failed: $error';
  }

  @override
  String get stockTransferQuickQuantity => 'Quick quantity';

  @override
  String get stockTransferQuantityPerItem => 'Quantity for each item';

  @override
  String get stockTransferItemGroup => 'Item Group';

  @override
  String get stockTransferAllGroups => 'All Groups';

  @override
  String get stockTransferAddAll => 'Add All';

  @override
  String get stockTransferAddGroup => 'Add Group';
}
