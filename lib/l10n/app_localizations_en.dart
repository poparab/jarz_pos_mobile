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
  String get menuB2bMode => 'B2B Mode';

  @override
  String get drawerGroupPosSales => 'POS / Sales';

  @override
  String get drawerGroupCrm => 'CRM / B2B';

  @override
  String get drawerGroupDelivery => 'Delivery / Logistics';

  @override
  String get drawerGroupFinance => 'Finance / Expenses';

  @override
  String get drawerGroupPurchasing => 'Purchasing / Inventory';

  @override
  String get drawerGroupManagement => 'Management / Reports';

  @override
  String get drawerGroupPricing => 'Pricing';

  @override
  String get menuPriceLists => 'Price Lists';

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
  String get managerMenuTooltip => 'Menu';

  @override
  String get managerDashboardTitle => 'Manager Dashboard';

  @override
  String get managerRecentOrders => 'Recent Orders';

  @override
  String get managerNoRecentOrders => 'No recent orders';

  @override
  String get managerBranchBalances => 'Branch Balances';

  @override
  String get managerSwitchProfileTip =>
      'Tip: Switch POS profiles from the POS/Kanban headers.';

  @override
  String get managerSwitchProfile => 'Switch Profile';

  @override
  String get managerTotalCash => 'Total Cash';

  @override
  String get managerAll => 'All';

  @override
  String get managerFilterByState => 'Filter by state:';

  @override
  String get managerChangeBranch => 'Change Branch';

  @override
  String get managerAssignToBranch => 'Assign to Branch';

  @override
  String get managerBranchUpdated => 'Branch updated';

  @override
  String managerBranchUpdateFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get menuPurchaseInvoice => 'Purchase Invoice';

  @override
  String get menuAbout => 'About';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppSection => 'App';

  @override
  String get aboutReleaseSection => 'Release';

  @override
  String get aboutShorebirdSection => 'Shorebird';

  @override
  String get aboutAppName => 'App name';

  @override
  String get aboutPackageName => 'Package name';

  @override
  String get aboutPlatform => 'Platform';

  @override
  String get aboutEnvironment => 'Environment';

  @override
  String get aboutBuildName => 'Build name';

  @override
  String get aboutBuildNumber => 'Build number';

  @override
  String get aboutReleaseId => 'Release ID';

  @override
  String get aboutReleaseDist => 'Release dist';

  @override
  String get aboutPatchNumber => 'Patch number';

  @override
  String get aboutPatchStatus => 'Patch status';

  @override
  String get aboutLastChecked => 'Last checked';

  @override
  String get aboutNotAvailable => 'Not available';

  @override
  String get aboutPatchNotInstalled => 'Base release only';

  @override
  String get aboutPatchUnavailable => 'Unavailable on this platform';

  @override
  String get aboutPatchStatusUpToDate => 'Up to date';

  @override
  String get aboutPatchStatusUpdateAvailable => 'Update available';

  @override
  String get aboutPatchStatusRestartRequired => 'Restart required';

  @override
  String get aboutPatchStatusUnavailable => 'Unavailable';

  @override
  String get aboutPatchStatusUnknown => 'Unknown';

  @override
  String get aboutPatchStatusUnknownDetail => 'Patch check error';

  @override
  String get aboutRefresh => 'Refresh';

  @override
  String get aboutCopyDiagnostics => 'Copy diagnostics';

  @override
  String get aboutCopiedDiagnostics => 'Diagnostics copied';

  @override
  String get aboutRetry => 'Retry';

  @override
  String aboutError(Object error) {
    return 'Error: $error';
  }

  @override
  String get menuManufacturing => 'Manufacturing';

  @override
  String get menuStockTransfer => 'Stock Transfer';

  @override
  String get menuCashTransfer => 'Cash Transfer';

  @override
  String get cashTransferFromAccount => 'From Account';

  @override
  String get cashTransferToAccount => 'To Account';

  @override
  String get cashTransferPostingToday => 'Posting: Today';

  @override
  String cashTransferPostingDate(Object date) {
    return 'Posting: $date';
  }

  @override
  String get cashTransferRemarkOptional => 'Remark (optional)';

  @override
  String get cashTransferFrom => 'From';

  @override
  String get cashTransferTo => 'To';

  @override
  String get cashTransferAccountsMustDiffer => 'Accounts must differ';

  @override
  String get cashTransferSelectAccount => 'Select account';

  @override
  String cashTransferBefore(Object amount) {
    return 'Before: $amount';
  }

  @override
  String cashTransferAfter(Object amount) {
    return 'After: $amount';
  }

  @override
  String get cashTransferNoAccountsFound => 'No accounts found';

  @override
  String cashTransferJournalEntry(Object entry) {
    return 'Journal Entry: $entry';
  }

  @override
  String cashTransferFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get postingDateConfirmationTitle => 'Confirm posting date';

  @override
  String get postingDateConfirmationMessage =>
      'Please confirm the posting date before submitting.';

  @override
  String postingDateConfirmationDate(Object date) {
    return 'Posting date: $date';
  }

  @override
  String get postingDateConfirmationDates => 'Posting dates:';

  @override
  String get menuInventoryCount => 'Inventory Count';

  @override
  String get inventoryCountOfflineUsingCache => 'Offline using cached data';

  @override
  String inventoryCountConfirmAllBeforeSubmit(int remaining) {
    return 'Please confirm all items before submitting ($remaining remaining)';
  }

  @override
  String get inventoryCountConfirmAtLeastOne =>
      'Confirm at least one item before submitting';

  @override
  String inventoryCountSubmitted(Object result) {
    return 'Submitted: $result';
  }

  @override
  String get inventoryCountNoDifferences => 'No differences';

  @override
  String get inventoryCountUncategorized => 'Uncategorized';

  @override
  String get inventoryCountManagerAccessRequired => 'Manager access required';

  @override
  String get inventoryCountSelectWarehouse => 'Select Warehouse';

  @override
  String get inventoryCountEnforceAll => 'Enforce all';

  @override
  String inventoryCountConfirmedProgress(int confirmed, int total) {
    return 'Confirmed $confirmed / $total';
  }

  @override
  String get inventoryCountClearAllEnteredData => 'Clear all entered data';

  @override
  String get inventoryCountAllEnteredDataCleared => 'All entered data cleared';

  @override
  String inventoryCountCurrentAmount(Object amount, Object uom) {
    return 'Current: $amount $uom';
  }

  @override
  String get inventoryCountDecrease => 'Decrease';

  @override
  String get inventoryCountCount => 'Count';

  @override
  String get inventoryCountIncrease => 'Increase';

  @override
  String inventoryCountValuation(Object amount, Object uom) {
    return 'Valuation: $amount / $uom';
  }

  @override
  String get inventoryCountDeltaLabel => 'Delta: ';

  @override
  String get inventoryCountSubmitCount => 'Submit Count';

  @override
  String get inventoryCountSetupStep => 'Setup';

  @override
  String get inventoryCountBlindEntryStep => 'Blind entry';

  @override
  String get inventoryCountReviewStep => 'Review discrepancies';

  @override
  String get inventoryCountSpotCount => 'Spot count';

  @override
  String get inventoryCountSpotCountDescription =>
      'Submit only the items you counted.';

  @override
  String get inventoryCountFullWarehouseCountDescription =>
      'Count every loaded item before final submit.';

  @override
  String get inventoryCountWarehouseLabel => 'Warehouse';

  @override
  String get inventoryCountPostingDateLabel => 'Posting date';

  @override
  String get inventoryCountCountModeLabel => 'Count mode';

  @override
  String get inventoryCountContinueCount => 'Continue count';

  @override
  String get inventoryCountStartCount => 'Start count';

  @override
  String get inventoryCountBackToSetup => 'Back to setup';

  @override
  String get inventoryCountReviewButton => 'Review discrepancies';

  @override
  String get inventoryCountBackToCounting => 'Back to counting';

  @override
  String inventoryCountFilteredItems(int visible, int total) {
    return '$visible of $total items';
  }

  @override
  String get inventoryCountCountedStatus => 'Counted';

  @override
  String get inventoryCountPendingStatus => 'Pending';

  @override
  String get inventoryCountClearEntry => 'Clear entry';

  @override
  String get inventoryCountSummaryCountedItems => 'Counted items';

  @override
  String get inventoryCountSummaryChangedItems => 'Changed items';

  @override
  String get inventoryCountSummaryMissingItems => 'Missing items';

  @override
  String get inventoryCountReviewDiscrepancies => 'Discrepancies';

  @override
  String get inventoryCountReviewNoCountedItems => 'No counted items yet.';

  @override
  String get inventoryCountReviewNoDiscrepancies =>
      'No discrepancies found yet.';

  @override
  String get inventoryCountReviewUnchanged => 'Unchanged counted items';

  @override
  String get inventoryCountReviewMissing => 'Missing items';

  @override
  String inventoryCountCountedAmount(Object amount, Object uom) {
    return 'Counted: $amount $uom';
  }

  @override
  String inventoryCountStockEquivalent(Object amount, Object uom) {
    return 'Stock equivalent: $amount $uom';
  }

  @override
  String get inventoryCountMissingItemNote => 'Not counted yet';

  @override
  String get inventoryCountBatchTracked => 'Batch tracked';

  @override
  String get inventoryCountSerialTracked => 'Serial tracked';

  @override
  String get menuEndShift => 'End Shift';

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
  String get commonCustomerLabel => 'Customer';

  @override
  String get commonPosProfileLabel => 'POS Profile';

  @override
  String get commonTotalLabel => 'Total';

  @override
  String get commonAmountLabel => 'Amount';

  @override
  String get commonDateLabel => 'Date';

  @override
  String get commonCourierLabel => 'Courier';

  @override
  String get commonDeliveryLabel => 'Delivery';

  @override
  String get commonItemsLabel => 'Items';

  @override
  String get commonItemLabel => 'Item';

  @override
  String get commonNotesLabel => 'Notes';

  @override
  String get commonPaymentLabel => 'Payment';

  @override
  String get commonOutstandingLabel => 'Outstanding';

  @override
  String get commonUploadedByLabel => 'Uploaded by';

  @override
  String get commonReasonLabel => 'Reason';

  @override
  String get ofdShortageDialogTitle => 'Approve stock shortage for dispatch';

  @override
  String get ofdShortageDialogMessage =>
      'These items are short at the dispatch warehouse. Add a reason to continue the Out For Delivery move.';

  @override
  String ofdShortageLine(
    String item,
    String required,
    String available,
    String warehouse,
  ) {
    return '$item: required $required, available $available, warehouse $warehouse';
  }

  @override
  String get ofdShortageReasonHint =>
      'Explain why dispatch should continue despite the shortage';

  @override
  String get ofdShortageReasonRequired =>
      'Provide a shortage reason to continue';

  @override
  String get ofdShortageApprove => 'Approve and continue';

  @override
  String get commonNotSpecified => 'Not specified';

  @override
  String get commonWalkIn => 'Walk-in';

  @override
  String get commonScheduled => 'Scheduled';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonNew => 'New';

  @override
  String get commonPreview => 'Preview';

  @override
  String commonByUser(Object user) {
    return 'by $user';
  }

  @override
  String commonQtyWithUom(Object uom) {
    return 'Qty ($uom)';
  }

  @override
  String orderAlertTitle(Object invoiceId) {
    return 'New Order: $invoiceId';
  }

  @override
  String get orderAlertNoLineItems => 'No line items';

  @override
  String orderAlertMoreItems(Object count) {
    return '+$count more item(s)';
  }

  @override
  String get orderAlertMuteAlarm => 'Mute Alarm';

  @override
  String get orderAlertUnmuteAlarm => 'Unmute Alarm';

  @override
  String get orderAlertAccepting => 'Accepting...';

  @override
  String get orderAlertAcceptOrder => 'Accept Order';

  @override
  String get posDraftDeleteTitle => 'Delete Draft';

  @override
  String posDraftDeleteBody(Object label) {
    return 'Delete \"$label\"? This cannot be undone.';
  }

  @override
  String posDraftLimitReached(Object max) {
    return 'Draft limit reached ($max max). Delete a draft to create a new one.';
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
  String get expensesReasonRequired => 'Select a reason';

  @override
  String get expensesPaymentSourceRequired => 'Select a payment source';

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
  String get shiftStartTitle => 'Start Shift';

  @override
  String get shiftEndTitle => 'End Shift';

  @override
  String get shiftNoActive => 'No active shift found.';

  @override
  String get shiftBackToPos => 'Back to POS';

  @override
  String get shiftOpeningPrompt => 'Count opening cash and enter it:';

  @override
  String shiftPosProfile(Object profile) {
    return 'POS Profile: $profile';
  }

  @override
  String shiftAccount(Object account) {
    return 'Account: $account';
  }

  @override
  String shiftSystemBalance(Object amount) {
    return 'System Balance: $amount';
  }

  @override
  String get shiftConfirmedOpeningAmount => 'Confirmed Opening Amount';

  @override
  String get shiftCountedOpeningAmount => 'Counted Opening Cash';

  @override
  String shiftDifferenceAmount(Object amount) {
    return 'Difference: $amount';
  }

  @override
  String get shiftClosingPrompt => 'Count closing cash and enter it:';

  @override
  String get shiftClosingAmountLabel => 'Closing Amount';

  @override
  String get shiftCountedClosingAmount => 'Counted Closing Cash';

  @override
  String get shiftBlindCountHint =>
      'Count the cash in the drawer and enter the amount.';

  @override
  String get shiftNoClosingPaymentMethodsTitle => 'Cash entry is unavailable';

  @override
  String get shiftNoClosingPaymentMethodsBody =>
      'No closing payment method is available for this shift. Reopen the shift or contact support.';

  @override
  String get shiftCashCountRequired => 'Enter the counted cash amount.';

  @override
  String get shiftCashCountInvalid => 'Enter a valid cash amount.';

  @override
  String get shiftCashCountNegative => 'Cash amount cannot be negative.';

  @override
  String shiftExpectedAmount(Object amount) {
    return 'Expected: $amount';
  }

  @override
  String shiftLoadActiveFailed(Object error) {
    return 'Failed to load active shift: $error';
  }

  @override
  String get shiftSummaryLoadFailed => 'Unable to load shift summary.';

  @override
  String shiftLabel(Object shift) {
    return 'Shift: $shift';
  }

  @override
  String get shiftUnexpectedStartResponse =>
      'Unexpected server response while starting the shift.';

  @override
  String get shiftUnexpectedSummaryResponse =>
      'Unexpected server response while loading the shift summary.';

  @override
  String get shiftUnexpectedEndResponse =>
      'Unexpected server response while ending the shift.';

  @override
  String get shiftCourierBlockTitle =>
      'Settle courier balances before ending the shift';

  @override
  String shiftCourierBlockBody(
    int transactions,
    int couriers,
    int invoices,
    Object profile,
  ) {
    return 'This shift still has $transactions unsettled courier transaction(s) for $couriers courier(s) across $invoices invoice(s) on POS Profile $profile.';
  }

  @override
  String get shiftCourierBlockHint =>
      'Open courier balances, settle what is still pending, then come back to finish the shift.';

  @override
  String get shiftCourierReviewButton => 'Review & Settle Couriers';

  @override
  String shiftCourierBlockPartySummary(
    Object name,
    int transactions,
    int invoices,
  ) {
    return '$name: $transactions transaction(s) on $invoices invoice(s)';
  }

  @override
  String shiftCourierBlockNetBalance(Object amount) {
    return 'Net balance: $amount';
  }

  @override
  String shiftCourierBlockMore(int count) {
    return '+$count more courier(s)';
  }

  @override
  String shiftOutflows(Object amount) {
    return 'Outflows: $amount';
  }

  @override
  String shiftNetMovement(Object amount) {
    return 'Net Movement: $amount';
  }

  @override
  String get shiftAccountMovements => 'Account Movements';

  @override
  String get shiftOther => 'Other';

  @override
  String shiftSubtotal(Object amount) {
    return 'Subtotal: $amount';
  }

  @override
  String shiftInvoices(Object count) {
    return 'Invoices: $count';
  }

  @override
  String shiftGrandTotal(Object amount) {
    return 'Grand Total: $amount';
  }

  @override
  String get shiftStartButton => 'Start Shift';

  @override
  String get shiftEndButton => 'End Shift';

  @override
  String get shiftEndedSuccess => 'Shift ended successfully.';

  @override
  String get shiftStatusActive => 'Shift Active';

  @override
  String shiftStartedAt(Object time) {
    return 'Started at $time';
  }

  @override
  String shiftProfileMismatch(Object activeProfile, Object selectedProfile) {
    return 'Active shift is on $activeProfile. Selected profile is $selectedProfile.';
  }

  @override
  String get shiftAlreadyOpenByAnotherTitle => 'Shift Already Open';

  @override
  String shiftAlreadyOpenByAnotherBody(Object branch, Object user) {
    return 'POS Profile \"$branch\" already has an open shift started by $user. That shift must be closed before you can start a new one.';
  }

  @override
  String get shiftRefresh => 'Refresh';

  @override
  String get shiftLogout => 'Logout';

  @override
  String get shiftSwitchToActiveProfile => 'Switch to active shift profile';

  @override
  String shiftOpenOnOtherProfile(Object otherProfile, Object shiftName) {
    return 'You have an open shift ($shiftName) on profile \"$otherProfile\". Close that shift before starting a new one here.';
  }

  @override
  String get shiftGoToEnd => 'Go to End Shift';

  @override
  String get shiftAccountBalance => 'Account Balance';

  @override
  String get shiftDifference => 'Difference';

  @override
  String get shiftSalesInvoices => 'Sales Invoices';

  @override
  String get shiftNoDeliveryStatus => 'No status';

  @override
  String get shiftClosedSummaryTitle => 'Shift Summary';

  @override
  String get shiftClosingEntry => 'Closing Entry';

  @override
  String get shiftJournalCreated => 'Cash discrepancy recorded';

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
  String get posCartPricingTitle => 'Manager Pricing';

  @override
  String get posCartPriceListLabel => 'Price list';

  @override
  String get posCartPriceListHint =>
      'Use the profile default or switch to a B2B list.';

  @override
  String get posCartPriceListDefaultChip => 'Default';

  @override
  String get posCartOrderPurposeLabel => 'Order purpose';

  @override
  String get posCartOrderPurposeHint =>
      'Apply a commercial policy or keep this a standard order.';

  @override
  String get posCartOrderPurposeStandard => 'Standard';

  @override
  String get posCartOrderPurposeWaivesShipping => 'Shipping income waived';

  @override
  String get posCartOrderPurposeNoCourier => 'No courier expense';

  @override
  String get posCartOrderPurposeReasonLabel => 'Reason (optional)';

  @override
  String get posCartOrderPurposeReasonHint =>
      'Add a note explaining why this purpose applies.';

  @override
  String get posCartZeroShippingTitle => 'Zero shipping income';

  @override
  String get posCartZeroShippingDescription =>
      'Do not charge shipping income on this order.';

  @override
  String get posCartZeroShippingPriceListDefault =>
      'Enabled automatically for this price list.';

  @override
  String get posCartZeroShippingManagedByPickup =>
      'Pickup already disables delivery charges.';

  @override
  String get posCartZeroShippingManagedByPartner =>
      'Sales partner orders already suppress shipping income.';

  @override
  String get posSubtotalLabel => 'Subtotal:';

  @override
  String get posDeliveryLabel => 'Delivery:';

  @override
  String get posTotalLabel => 'Total:';

  @override
  String get posCheckoutButton => 'Checkout';

  @override
  String get posCheckoutStockExceedTitle => 'Items exceed available stock';

  @override
  String get posCheckoutStockExceedMessage =>
      'The following cart items exceed current system stock. The order can still be created, but fulfillment may need incoming stock or inventory correction.';

  @override
  String posCheckoutStockExceedLine(
    String item,
    String requested,
    String available,
  ) {
    return '$item: requested $requested, available $available';
  }

  @override
  String get posCheckoutProceedAnyway => 'Proceed with order';

  @override
  String get posTerritoryMismatchTitle => 'Profile Mismatch';

  @override
  String get posTerritoryMismatchBody =>
      'The customer\'s territory is mapped to a different POS profile.';

  @override
  String posTerritoryMismatchUseSelected(String profile) {
    return 'Keep selected: $profile';
  }

  @override
  String posTerritoryMismatchUseTerritory(String profile) {
    return 'Switch to territory profile: $profile';
  }

  @override
  String posTerritoryMismatchNoTerritory(String profile) {
    return 'No territory profile assigned - keep selected: $profile';
  }

  @override
  String get posTerritoryMismatchCancel => 'Cancel';

  @override
  String get posTerritoryMismatchConfirm => 'Proceed';

  @override
  String get posAmendmentDraftButton => 'Submit Amendment';

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
  String get posCartItemPricingDialogTitle => 'Edit line pricing';

  @override
  String posCartItemPricingBaseRate(String amount) {
    return 'Current catalog rate: $amount';
  }

  @override
  String get posCartItemPricingCustomRateLabel => 'Custom unit price';

  @override
  String get posCartItemPricingDiscountAmountLabel => 'Discount amount';

  @override
  String get posCartItemPricingDiscountPercentLabel => 'Discount percentage';

  @override
  String get posCartItemPricingDiscountHint =>
      'Use discount amount or discount percentage, not both.';

  @override
  String get posCartItemPricingReset => 'Reset pricing';

  @override
  String get posCartItemPricingSave => 'Apply';

  @override
  String posCartItemCustomPriceApplied(String amount) {
    return 'Custom $amount';
  }

  @override
  String posCartItemDiscountAmountApplied(String amount) {
    return 'Discount $amount';
  }

  @override
  String posCartItemDiscountPercentApplied(String amount) {
    return 'Discount $amount%';
  }

  @override
  String get posCartItemPricingInvalidNumber => 'Enter a valid number.';

  @override
  String get posCartItemPricingInvalidCustomRate =>
      'Custom price must be zero or more.';

  @override
  String get posCartItemPricingInvalidDiscountAmount =>
      'Discount amount must be zero or more.';

  @override
  String get posCartItemPricingInvalidDiscountPercent =>
      'Discount percentage must be between 0 and 100.';

  @override
  String get posCartItemPricingChooseSingleDiscount =>
      'Use discount amount or discount percentage, not both.';

  @override
  String get posCartItemPricingDiscountTooHigh =>
      'Discount amount cannot exceed the effective unit price.';

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
  String get printerSelectTitle => 'Select Printer';

  @override
  String get printerCompatibilityTooltip => 'Printer compatibility settings';

  @override
  String get printerCompatibilityTitle => 'Compatibility';

  @override
  String get printerCompatibilitySubtitle =>
      'Safe defaults keep normal receipts as text and only use raster output where it is needed.';

  @override
  String get printerCompatibilitySaved =>
      'Printer compatibility settings saved';

  @override
  String get printerCompatibilityReset => 'Reset defaults';

  @override
  String get printerDiagnosticsTitle => 'Diagnostics';

  @override
  String printerDiagnosticsAdapter(Object state) {
    return 'Adapter: $state';
  }

  @override
  String printerDiagnosticsScan(Object status) {
    return 'Perm scan: $status';
  }

  @override
  String printerDiagnosticsConnect(Object status) {
    return 'Perm connect: $status';
  }

  @override
  String printerDiagnosticsLocation(Object status) {
    return 'Perm location: $status';
  }

  @override
  String get printerDeviceIdLabel => 'Device ID (MAC / Identifier)';

  @override
  String get printerConnectById => 'Connect by ID';

  @override
  String get printerConnectingById => 'Connecting by ID...';

  @override
  String get printerConnecting => 'Connecting...';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get printerConnectionFailed => 'Failed to connect';

  @override
  String get printerForgetSavedTooltip => 'Forget saved printer';

  @override
  String get printerForgotSaved => 'Forgot saved printer';

  @override
  String get printerRescanTooltip => 'Rescan';

  @override
  String get printerReconnecting => 'Reconnecting...';

  @override
  String get printerReconnected => 'Reconnected';

  @override
  String get printerReconnectFailed => 'Reconnect failed';

  @override
  String get printerReconnect => 'Reconnect';

  @override
  String printerConnectedTo(Object name) {
    return 'Connected: $name';
  }

  @override
  String get printerTestPrint => 'Test Print';

  @override
  String get printerTestSent => 'Test print sent';

  @override
  String printerTestFailed(Object error) {
    return 'Test failed: $error';
  }

  @override
  String get printerBleDevices => 'BLE Devices';

  @override
  String get printerRescanBleTooltip => 'Rescan BLE';

  @override
  String get printerNoBleDevices => 'No BLE devices discovered.';

  @override
  String get printerUnknownName => 'Unknown Printer';

  @override
  String get printerConnect => 'Connect';

  @override
  String get printerClassicDevices => 'Paired Classic Devices';

  @override
  String get printerPaperSizeLabel => 'Paper size';

  @override
  String get printerPaper58mm => '58 mm';

  @override
  String get printerPaper80mm => '80 mm';

  @override
  String get printerPrintLogo => 'Print logo';

  @override
  String get printerPrintLogoHint =>
      'Disable this first if the printer prints gibberish near the top of the receipt.';

  @override
  String get printerRasterizeArabic => 'Rasterize Arabic text';

  @override
  String get printerRasterizeArabicHint =>
      'Needed for printers that cannot print Arabic natively.';

  @override
  String get printerRasterizeStyledText => 'Rasterize styled ASCII text';

  @override
  String get printerRasterizeStyledTextHint =>
      'Enable this only if your printer handles bitmap text reliably.';

  @override
  String get printerRasterWidthLabel => 'Raster width (px)';

  @override
  String get printerCodeTableLabel => 'Code table';

  @override
  String get printerBleChunkSizeLabel => 'BLE chunk size';

  @override
  String get printerBleChunkDelayLabel => 'BLE chunk delay (ms)';

  @override
  String get printerClassicChunkSizeLabel => 'Classic chunk size';

  @override
  String get printerClassicChunkDelayLabel => 'Classic chunk delay (ms)';

  @override
  String get printerClassicTailDelayLabel => 'Classic tail delay (ms)';

  @override
  String get printerRefreshClassicTooltip => 'Refresh Classic List';

  @override
  String get printerNoClassicDevices =>
      'No paired classic printers found. Ensure the printer is paired in System Bluetooth settings and that Location (Android 8) is enabled.';

  @override
  String printerClassicMacConnected(Object mac) {
    return '$mac  (Classic)';
  }

  @override
  String get printerDisconnect => 'Disconnect';

  @override
  String get printerConnectingClassic => 'Connecting (Classic)...';

  @override
  String printerLastSavedNotAdvertising(Object id) {
    return 'Last saved printer: $id\nIt is not currently advertising. You can still attempt to reconnect.';
  }

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
  String get courierSettlementComplete => 'Settlement complete';

  @override
  String get courierSettlementFailed => 'Settlement failed';

  @override
  String get courierSettleButton => 'Settle';

  @override
  String courierPayCourierAmount(Object amount) {
    return 'Pay Courier $amount';
  }

  @override
  String courierCollectAmount(Object amount) {
    return 'Collect $amount';
  }

  @override
  String courierSettleAllInvoicesQuestion(int count) {
    return 'Settle all $count invoices for this courier?';
  }

  @override
  String get courierSettled => 'Settled';

  @override
  String get courierSettleAllButton => 'Settle All';

  @override
  String courierSettleAllDialogTitle(Object action, Object total) {
    return '$action - Total $total';
  }

  @override
  String courierSettleAllWillSettle(int count) {
    return 'This will settle $count invoice(s).';
  }

  @override
  String get courierInvoicesLabel => 'Invoices:';

  @override
  String get courierSettleAllCollectInfo =>
      'You will collect the net amount from the courier.';

  @override
  String get courierSettleAllPayInfo =>
      'You will pay the courier the net amount now.';

  @override
  String courierSettleAllComplete(int success, int failed) {
    return 'Settle All complete: $success ok, $failed failed';
  }

  @override
  String get courierBalancesPreviewTooltip => 'Preview settlement';

  @override
  String courierBalancesPreviewFailed(Object error) {
    return 'Failed to load settlement preview: $error';
  }

  @override
  String get settlementTitleCollectFromCourier => 'Collect From Courier';

  @override
  String get settlementTitlePayCourier => 'Pay Courier';

  @override
  String get settlementTitleCourierSettlement => 'Courier Settlement';

  @override
  String get settlementStatusUnpaid => 'Unpaid';

  @override
  String get settlementStatusPaid => 'Paid';

  @override
  String get settlementPaidNoteRecent => ' (just paid, treating as Unpaid)';

  @override
  String get settlementPaidNoteAfterOfd => ' (after OFD)';

  @override
  String get settlementPaidNoteAfterOfdUnpaid =>
      ' (paid after OFD, treated as Unpaid)';

  @override
  String settlementInvoiceStatus(Object status, Object note) {
    return 'Invoice is: $status$note';
  }

  @override
  String get settlementOnlineUnconfirmedNote =>
      'Customer pays online — the courier collected nothing. Only the shipping fee is settled here.';

  @override
  String get settlementCollectFormula => 'Collect (Order - Shipping):';

  @override
  String get settlementPayFormula => 'Pay the courier (Order - Shipping):';

  @override
  String get settlementNetToCollect => 'Net to Collect';

  @override
  String get settlementPayAmount => 'Pay Amount';

  @override
  String get settlementNothingToSettle => 'Nothing to pay or collect.';

  @override
  String settlementOrderLabel(Object amount) {
    return 'Order: $amount';
  }

  @override
  String settlementShippingLabel(Object amount) {
    return 'Shipping: $amount';
  }

  @override
  String settlementTerritoryLabel(Object territory) {
    return 'Territory: $territory';
  }

  @override
  String get cancelOrderTitle => 'Cancel Order';

  @override
  String cancelOrderInvoiceLabel(Object invoice) {
    return 'Invoice: $invoice';
  }

  @override
  String cancelOrderTotalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String cancelOrderOutstandingLabel(Object amount) {
    return 'Outstanding: $amount';
  }

  @override
  String get cancelOrderPartialPaymentWarning =>
      'This invoice has a partial payment. Please settle or refund the payment before cancelling.';

  @override
  String get cancelOrderReasonLabel => 'Cancellation reason';

  @override
  String get cancelOrderSelectReasonValidation => 'Select a reason to continue';

  @override
  String get cancelOrderProvideReasonValidation => 'Provide a reason';

  @override
  String get cancelOrderCustomReasonLabel => 'Custom reason';

  @override
  String get cancelOrderDescribeReasonValidation =>
      'Please describe the cancellation reason';

  @override
  String get cancelOrderAdditionalNotesOptional =>
      'Additional notes (optional)';

  @override
  String get cancelOrderCreditNoteInfo =>
      'The payment on this order will be reversed. Hand the money back to the customer before confirming.';

  @override
  String get cancelOrderConfirmButton => 'Confirm cancellation';

  @override
  String get invoicePreparingReceipt => 'Preparing receipt...';

  @override
  String invoiceItemsCount(int count) {
    return 'Items ($count)';
  }

  @override
  String get invoicePrinterNotConnectedHint =>
      'Printer not connected. Open Printer Selection from menu.';

  @override
  String get invoicePrintedSuccessfully => 'Printed successfully';

  @override
  String get invoicePrinterDisconnected => 'Printer disconnected';

  @override
  String invoicePrintFailed(Object result) {
    return 'Print failed: $result';
  }

  @override
  String get invoiceAcceptOrderTitle => 'Accept Order';

  @override
  String invoiceAcceptOrderQuestion(Object invoice, Object customer) {
    return 'Accept order $invoice for $customer?';
  }

  @override
  String get invoiceAcceptAction => 'Accept';

  @override
  String invoiceOrderAccepted(Object invoice) {
    return 'Order $invoice accepted!';
  }

  @override
  String invoiceAcceptFailed(Object error) {
    return 'Failed to accept order: $error';
  }

  @override
  String get invoiceMoreOptions => 'More Options';

  @override
  String get invoiceAddNote => 'Notes';

  @override
  String get invoiceNotesTitle => 'Invoice Notes';

  @override
  String get invoiceNotesTooltip => 'View invoice notes';

  @override
  String get invoiceNotesHint => 'Add an operational note for this invoice';

  @override
  String get invoiceNotesEmpty => 'No notes yet for this invoice.';

  @override
  String get invoiceLatestNoteLabel => 'LATEST NOTE';

  @override
  String invoiceLatestNoteLabelWithCount(Object count) {
    return 'LATEST NOTE ($count)';
  }

  @override
  String get invoiceLatestNoteTapToRead =>
      'Tap to read the notes on this order';

  @override
  String get invoiceAddingNote => 'Adding...';

  @override
  String get invoiceNoteAdded => 'Note added';

  @override
  String invoiceNotesLoadFailed(Object error) {
    return 'Failed to load invoice notes: $error';
  }

  @override
  String invoiceNoteAddFailed(Object error) {
    return 'Failed to add note: $error';
  }

  @override
  String get invoiceEditInvoice => 'Edit Invoice';

  @override
  String get invoiceEditInvoiceFailed =>
      'Could not open the invoice draft. Please try again.';

  @override
  String get invoiceAmendmentUnavailable =>
      'Invoice amendment is not available for this order.';

  @override
  String get invoiceEditCustomerAddress => 'Edit Customer Address';

  @override
  String get invoiceChangeDeliverySlot => 'Change Delivery Slot';

  @override
  String get invoiceTransferOrder => 'Transfer Order';

  @override
  String get invoiceCancelOrderSettleFirst =>
      'Cancel Order (settle payments first)';

  @override
  String get invoiceCustomerLabel => 'Customer';

  @override
  String get invoiceShippingExpenseShort => 'Shipping Exp:';

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
  String get manufacturingInsufficientInventory => 'Insufficient inventory';

  @override
  String get manufacturingSubmissionBlocked =>
      'Submission blocked until shortages are resolved.';

  @override
  String manufacturingLineShortageSummary(Object components, Object item) {
    return '$item: $components';
  }

  @override
  String manufacturingComponentRequired(Object quantity, Object uom) {
    return 'Required: $quantity $uom';
  }

  @override
  String manufacturingComponentMissing(Object quantity, Object uom) {
    return 'Missing: $quantity $uom';
  }

  @override
  String get menuProductionBoard => 'Production Board';

  @override
  String get productionBoardTitle => 'Production Board';

  @override
  String get productionTabPlan => 'Plan';

  @override
  String get productionTabDaily => 'Daily';

  @override
  String get dailyPlanNoItems => 'No fillable items have a default BOM yet.';

  @override
  String get dailyPlanNoMix => 'No cheesecake mix';

  @override
  String dailyPlanPerBatch(int count) {
    return '$count per batch';
  }

  @override
  String dailyPlanTotalJars(int count) {
    return '$count jars planned';
  }

  @override
  String get dailyPlanEnterQuantities =>
      'Enter how many jars you plan to fill.';

  @override
  String dailyPlanMixTotal(String qty, String uom, String batches) {
    return '$qty $uom of mix = $batches batches';
  }

  @override
  String get dailyPlanNoRuns =>
      'The mixer is not configured, so the split cannot be calculated.';

  @override
  String get dailyPlanRunPreferred => 'ideal';

  @override
  String get dailyPlanRunAcceptable => 'stretching';

  @override
  String get dailyPlanRunPoor => 'mixes badly';

  @override
  String dailyPlanSpareMix(String batches) {
    return '$batches batches of spare mix from rounding to whole runs.';
  }

  @override
  String get dailyPlanCheckMaterials => 'Check stock';

  @override
  String get dailyPlanSave => 'Save plan';

  @override
  String dailyPlanSaved(String name) {
    return 'Plan $name saved.';
  }

  @override
  String dailyPlanShortages(int count) {
    return '$count materials short';
  }

  @override
  String dailyPlanShortageLine(String item, String qty, String uom) {
    return '$item: $qty $uom short';
  }

  @override
  String dailyPlanShortagesMore(int count) {
    return 'and $count more';
  }

  @override
  String get dailyPlanMaterialsUnavailable =>
      'Stock could not be checked for this plan.';

  @override
  String dailyPlanBomIssues(int count) {
    return '$count BOMs need attention before the mix total is right';
  }

  @override
  String get dailyPlanBomIssuesTitle => 'BOM issues affecting the plan';

  @override
  String get productionTabBatch => 'Batch';

  @override
  String get productionAccessDenied => 'Production access required';

  @override
  String get productionSearchHint => 'Search items with a BOM';

  @override
  String get productionFilterAll => 'All';

  @override
  String get productionStatusCritical => 'Critical';

  @override
  String get productionStatusLow => 'Low';

  @override
  String get productionStatusOk => 'Covered';

  @override
  String get productionStatusOverstocked => 'Overstocked';

  @override
  String get productionStatusNoVelocity => 'No sales data';

  @override
  String get productionOnHand => 'On hand';

  @override
  String get productionSellsPerDay => 'Sells / day';

  @override
  String get productionCover => 'Cover';

  @override
  String productionCoverDays(Object days) {
    return '$days d';
  }

  @override
  String get productionCoverUnknown => '—';

  @override
  String get productionTrend => 'Trend';

  @override
  String productionMakeBatches(Object batches, Object units, Object uom) {
    return 'Make $batches batches · $units $uom';
  }

  @override
  String productionReachCover(Object days) {
    return 'to reach $days days cover';
  }

  @override
  String productionCappedBy(Object capped, Object limiter, Object wanted) {
    return 'capped at $capped — $limiter is short (wanted $wanted)';
  }

  @override
  String productionSeasonApplied(Object name, Object value) {
    return 'Season $name: ×$value';
  }

  @override
  String get productionAddToBatch => 'Add';

  @override
  String get productionFillTheDay => 'Fill the day';

  @override
  String productionFillTheDayResult(Object added, Object batches) {
    return 'Added $added items · $batches batches';
  }

  @override
  String productionFillTheDaySkipped(Object skipped) {
    return '$skipped skipped — no materials';
  }

  @override
  String get productionFillTheDayNothing => 'Nothing to add';

  @override
  String get productionNoSuggestions => 'Nothing needs producing';

  @override
  String get productionVelocityNever =>
      'Sales velocity has never been calculated — suggestions will stay empty until it runs';

  @override
  String productionVelocityUpdated(Object when) {
    return 'Velocity updated $when';
  }

  @override
  String productionBelowCover(Object count) {
    return '$count items below cover';
  }

  @override
  String get productionBasketEmpty => 'Nothing queued yet';

  @override
  String productionBasketTitle(Object count) {
    return 'Batch ($count)';
  }

  @override
  String get productionPostingDate => 'Production date';

  @override
  String get productionClearBasket => 'Clear';

  @override
  String get productionBatchesLabel => 'Batches';

  @override
  String get productionPickListTitle => 'Consolidated pick list';

  @override
  String productionPickListShort(Object quantity, Object uom) {
    return 'Short by $quantity $uom';
  }

  @override
  String get productionPickListOk => 'All materials available';

  @override
  String productionSharedAcrossLines(Object count) {
    return 'shared by $count lines';
  }

  @override
  String get productionSubmitting => 'Submitting…';

  @override
  String get productionScaleToFit => 'Reduce to what materials allow';

  @override
  String productionTargetDays(Object days) {
    return 'Target $days days';
  }

  @override
  String get productionNoSourceWarehouse => 'No source warehouse configured';

  @override
  String productionStockElsewhere(Object quantity, Object warehouse) {
    return '$quantity is in $warehouse — needs a stock transfer, not a purchase';
  }

  @override
  String productionStockElsewhereMore(
    Object count,
    Object quantity,
    Object warehouse,
  ) {
    return '$quantity is in $warehouse and $count more — needs a stock transfer, not a purchase';
  }

  @override
  String get productionStockNowhere =>
      'None of it in any other store — this one has to be bought';

  @override
  String get productionNegativeStock => 'Stock is negative — count this item';

  @override
  String productionMakeUnits(Object units, Object uom) {
    return 'Make $units $uom';
  }

  @override
  String productionCannotStart(Object limiter) {
    return 'Cannot start — $limiter is short';
  }

  @override
  String productionBatchTotals(Object batches, Object units) {
    return '$batches batches · $units units';
  }

  @override
  String get productionTabRunning => 'Running';

  @override
  String get productionStart => 'Start batch';

  @override
  String get productionQuickProduce => 'Quick produce';

  @override
  String get productionFinish => 'Finish';

  @override
  String get productionFinishTitle => 'Finish batch';

  @override
  String get productionActualQty => 'Actual produced';

  @override
  String get productionScrapQty => 'Scrap / waste';

  @override
  String get productionBatchNotes => 'Notes';

  @override
  String productionActualExceedsPlanned(Object planned) {
    return 'More than the $planned planned';
  }

  @override
  String get productionQtyMustBePositive => 'Enter how much actually came out';

  @override
  String get productionRunningEmpty => 'No batches running';

  @override
  String productionRunningSince(Object when, Object who) {
    return 'Started $when by $who';
  }

  @override
  String productionElapsed(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String productionElapsedMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String productionPlannedVsProduced(Object planned, Object produced) {
    return '$planned planned · $produced produced';
  }

  @override
  String productionWipLeftover(Object quantity, Object uom) {
    return '$quantity $uom left in WIP';
  }

  @override
  String get productionReturnToStore => 'Return to store';

  @override
  String get productionReturnedToStore => 'Material returned to store';

  @override
  String get productionCostTitle => 'Batch cost';

  @override
  String get productionMaterialCost => 'Materials';

  @override
  String get productionCostPerUnit => 'Per unit';

  @override
  String get productionStandardCost => 'Standard';

  @override
  String get productionVariance => 'Variance';

  @override
  String productionVarianceOver(Object percent) {
    return '$percent% over standard';
  }

  @override
  String productionVarianceUnder(Object percent) {
    return '$percent% under standard';
  }

  @override
  String get productionCostUnavailable => 'No cost yet — nothing produced';

  @override
  String get productionPrintBatchSheet => 'Print batch sheet';

  @override
  String get productionBackDateNotAllowed =>
      'You cannot post production on a past date';

  @override
  String productionStarted(Object workOrder) {
    return 'Batch started · $workOrder';
  }

  @override
  String productionFinished(Object quantity, Object uom) {
    return 'Batch finished · $quantity $uom';
  }

  @override
  String get productionNotStartedYet => 'This batch was never started';

  @override
  String get productionTabBases => 'Bases';

  @override
  String get basesHeaderHint =>
      'Bases never sell, so the plan cannot suggest them. Pick one and set how many batches to mix.';

  @override
  String get basesEmpty => 'No bases configured';

  @override
  String basesSummaryShort(Object count) {
    return '$count below what the jars need';
  }

  @override
  String basesSummaryBlocked(Object count) {
    return '$count blocked — no materials';
  }

  @override
  String basesBatchYield(Object quantity, Object uom) {
    return '1 batch = $quantity $uom';
  }

  @override
  String get basesInFreezer => 'In freezer';

  @override
  String basesBatchesValue(Object batches) {
    return '$batches batches';
  }

  @override
  String basesQtyValue(Object quantity, Object uom) {
    return '$quantity $uom';
  }

  @override
  String get basesCanMakeNow => 'Can make now';

  @override
  String basesDemandHint(Object needed, Object onHand) {
    return 'The plan needs $needed batches · you have $onHand';
  }

  @override
  String basesDemandDriver(Object driver) {
    return 'from $driver';
  }

  @override
  String basesUseBatches(Object batches) {
    return 'Use $batches';
  }

  @override
  String get basesRunSizes => 'Mixer runs';

  @override
  String get basesRunSizeOff =>
      'Not one of the mixer\'s usual runs — double-check before mixing';

  @override
  String basesMakes(Object quantity, Object uom) {
    return 'Makes $quantity $uom';
  }

  @override
  String get basesConsumes => 'Consumes';

  @override
  String basesEstimatedCost(Object amount) {
    return 'Est. materials $amount';
  }

  @override
  String get basesChecking => 'Checking materials…';

  @override
  String basesPreviewFailed(Object reason) {
    return 'Could not check materials — $reason';
  }

  @override
  String basesShortage(Object component, Object quantity, Object uom) {
    return '$component is short by $quantity $uom';
  }

  @override
  String basesReduceTo(Object batches) {
    return 'Reduce to $batches';
  }

  @override
  String get basesNothingPossible =>
      'Not enough materials for even half a batch';

  @override
  String get sopTitle => 'Work instructions';

  @override
  String get sopViewSop => 'View SOP';

  @override
  String get sopNoSopForItem => 'No work instructions for this item';

  @override
  String sopStepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get sopNext => 'Next';

  @override
  String get sopPrevious => 'Back';

  @override
  String get sopConfirmStep => 'Done';

  @override
  String get sopCaptureNumber => 'Enter the reading';

  @override
  String get sopCaptureTemperature => 'Enter the temperature';

  @override
  String get sopCapturePhoto => 'Take a photo';

  @override
  String get sopCaptureRequired => 'Record this before continuing';

  @override
  String sopCaptureOutOfRange(Object from, Object to) {
    return 'Allowed range $from to $to';
  }

  @override
  String sopDurationMins(Object minutes) {
    return '$minutes min';
  }

  @override
  String sopTotalDuration(Object minutes) {
    return 'About $minutes min total';
  }

  @override
  String sopScaledFor(Object batches) {
    return 'Scaled for $batches batches';
  }

  @override
  String get sopEquipment => 'Equipment';

  @override
  String sopExpectedYield(Object percent) {
    return 'Expected yield $percent%';
  }

  @override
  String sopVersionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get sopFinishExecution => 'Finish instructions';

  @override
  String get sopExitConfirm =>
      'Leave the instructions? Your place is not saved.';

  @override
  String sopUnresolvedTokens(Object count) {
    return '$count instruction reference(s) could not be resolved';
  }

  @override
  String get sopPhotoCaptured => 'Photo recorded';

  @override
  String get sopCameraPermissionDenied =>
      'Camera permission is needed to record a photo';

  @override
  String get sopPhotoEmpty => 'Couldn\'t read that photo. Take it again.';

  @override
  String get sopImageUnavailable =>
      'Image unavailable — you may not have access to it';

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

  @override
  String get commonClear => 'Clear';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonSave => 'Save';

  @override
  String get paymentMethodSelectTitle => 'Select Payment Method';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodInstapay => 'Instapay';

  @override
  String get paymentMethodMobileWallet => 'Mobile Wallet';

  @override
  String get paymentMethodSettleLater => 'Settle Later';

  @override
  String get paymentMethodOnline => 'Online';

  @override
  String get checkoutTotal => 'Total:';

  @override
  String get checkoutPay => 'Pay';

  @override
  String get checkoutSelectProfileFirst => 'Select POS profile first';

  @override
  String get checkoutOrderSuccess => 'Order completed successfully!';

  @override
  String checkoutFailed(Object error) {
    return 'Checkout failed: $error';
  }

  @override
  String get salesPartnerTitle => 'Sales Partner';

  @override
  String get salesPartnerSearchHint => 'Search partner';

  @override
  String get salesPartnerNotFound => 'No partners found';

  @override
  String get itemGridBundles => 'Bundles';

  @override
  String get itemGridAll => 'All';

  @override
  String get itemGridUncategorized => 'Uncategorized';

  @override
  String get itemGridSelectCustomerWarning => 'Please select a customer first';

  @override
  String get itemGridNoItemsFound => 'No items found';

  @override
  String get itemGridNoItemsAvailable => 'No items available';

  @override
  String get itemGridTryDifferentCategory => 'Try a different category';

  @override
  String get itemGridItemsWillAppear => 'Items will appear here';

  @override
  String get itemGridFreeDelivery => 'Free delivery';

  @override
  String itemGridBundlesCount(Object count) {
    return '$count bundles';
  }

  @override
  String itemGridItemsCount(Object count) {
    return '$count items';
  }

  @override
  String itemGridInCart(Object count) {
    return 'In cart: $count';
  }

  @override
  String get itemGridAddedToCart => 'Added to cart';

  @override
  String get itemGridSelectCustomerFirst => 'Select customer first';

  @override
  String get itemGridOutOfStock => 'Out of stock';

  @override
  String get itemGridCannotAdd => 'Cannot add item';

  @override
  String get kanbanFilterTitle => 'Filters';

  @override
  String kanbanFilterActiveCount(Object count) {
    return '$count active';
  }

  @override
  String get kanbanFilterClearAll => 'Clear All';

  @override
  String get kanbanFilterSearch => 'Search';

  @override
  String get kanbanFilterSearchHint => 'Order #, customer, or phone';

  @override
  String kanbanFilterMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching orders',
      one: '1 matching order',
      zero: 'No matching orders',
    );
    return '$_temp0';
  }

  @override
  String get kanbanFilterDone => 'Done';

  @override
  String get kanbanFilterDateToday => 'Today';

  @override
  String get kanbanFilterDateLast7Days => 'Last 7 days';

  @override
  String get kanbanFilterDateLast30Days => 'Last 30 days';

  @override
  String get kanbanFilterDateThisMonth => 'This month';

  @override
  String get kanbanFilterDateCustom => 'Custom range…';

  @override
  String get kanbanFilterAllCustomers => 'All Customers';

  @override
  String get kanbanFilterAllStatuses => 'All Statuses';

  @override
  String get kanbanFilterDateRange => 'Date Range';

  @override
  String get kanbanFilterFromDate => 'From Date';

  @override
  String get kanbanFilterToDate => 'To Date';

  @override
  String get kanbanFilterAllDates => 'All Dates';

  @override
  String get kanbanFilterAmountRange => 'Amount Range';

  @override
  String get kanbanFilterMinAmount => 'Min Amount';

  @override
  String get kanbanFilterMaxAmount => 'Max Amount';

  @override
  String get kanbanFilterAllAmounts => 'All Amounts';

  @override
  String get kanbanFilterActiveLabel => 'Active Filters:';

  @override
  String get kanbanFilterByBranches => 'Filter by Branches';

  @override
  String get kanbanFilterCustomerTitle => 'Customer';

  @override
  String get kanbanFilterCustomerName => 'Customer name';

  @override
  String get kanbanFilterCustomerHint => 'Enter customer name';

  @override
  String get kanbanFilterStatusTitle => 'Status';

  @override
  String get kanbanFilterFromAmount => 'From Amount';

  @override
  String get kanbanFilterToAmount => 'To Amount';

  @override
  String get kanbanFilterApply => 'Apply';

  @override
  String get kanbanRefreshOrders => 'Refresh Orders';

  @override
  String get kanbanOrdersRefreshed => 'Orders refreshed';

  @override
  String get kanbanHideFilters => 'Hide Filters';

  @override
  String get kanbanShowFilters => 'Show Filters';

  @override
  String get kanbanMoreActions => 'More Actions';

  @override
  String get kanbanMenu => 'Menu';

  @override
  String get kanbanMenuReceipts => 'Payment Receipts';

  @override
  String get kanbanMenuPrinters => 'Printers';

  @override
  String get kanbanMenuCouriers => 'Courier Balances';

  @override
  String get kanbanMenuProfile => 'Profile';

  @override
  String get kanbanMenuPos => 'Point of Sale';

  @override
  String get kanbanPaymentReceipts => 'Payment Receipts';

  @override
  String get kanbanCourierBalances => 'Courier Balances';

  @override
  String get kanbanUserProfile => 'User Profile';

  @override
  String get kanbanOpenPos => 'Open POS';

  @override
  String get kanbanTitleShort => 'Kanban';

  @override
  String get kanbanTitleFull => 'Sales Kanban';

  @override
  String get kanbanPrinterBle => 'BLE';

  @override
  String get kanbanPrinterClassic => 'Classic';

  @override
  String get kanbanPrinterConnecting => 'Connecting...';

  @override
  String get kanbanPrinterNotConnected => 'Not Connected';

  @override
  String get kanbanErrorLoadingData => 'Error loading data';

  @override
  String get kanbanNoColumnsConfigured => 'No columns configured';

  @override
  String get kanbanEnsureStateField =>
      'Ensure the state field is configured properly.';

  @override
  String get kanbanSelectPosProfileFirst => 'Select POS profile first';

  @override
  String get kanbanSelectPosProfile => 'Select POS Profile';

  @override
  String get kanbanNoPosProfiles => 'No POS profiles available';

  @override
  String kanbanWarehouse(Object warehouse) {
    return 'Warehouse: $warehouse';
  }

  @override
  String get kanbanCourierAndMode => 'Courier & Mode';

  @override
  String get kanbanNoCouriersAvailable => 'No couriers available';

  @override
  String get kanbanCreateCourierHint => 'Create a courier to proceed.';

  @override
  String get kanbanNewCourier => 'New Courier';

  @override
  String get kanbanFirstName => 'First Name';

  @override
  String get kanbanLastName => 'Last Name';

  @override
  String get kanbanPhone => 'Phone';

  @override
  String get kanbanType => 'Type';

  @override
  String get kanbanEmployee => 'Employee';

  @override
  String get kanbanSupplier => 'Supplier';

  @override
  String get kanbanBack => 'Back';

  @override
  String kanbanCreateFailed(Object error) {
    return 'Create failed: $error';
  }

  @override
  String get kanbanMode => 'Mode';

  @override
  String get kanbanPayNowCash => 'Pay Now (Cash)';

  @override
  String get kanbanSettleLater => 'Settle Later';

  @override
  String get kanbanSettleLaterSubtitle => 'Courier settles with branch later';

  @override
  String get kanbanContinue => 'Continue';

  @override
  String get kanbanSettleLaterMissingParty =>
      'Settle Later failed: courier party missing.';

  @override
  String get kanbanSettleLaterPreviewExpired =>
      'Settle Later: preview expired. Please retry.';

  @override
  String get kanbanSettleLaterFailed => 'Settle Later failed';

  @override
  String get kanbanMarkedSettleLater => 'Marked to Settle Later';

  @override
  String kanbanSettleLaterError(Object error) {
    return 'Settle Later error: $error';
  }

  @override
  String get kanbanSettlementMissingParty =>
      'Settlement failed: courier party missing.';

  @override
  String get kanbanPreviewExpired => 'Preview expired. Please retry.';

  @override
  String get kanbanConfirmingSettlement => 'Confirming settlement...';

  @override
  String get kanbanSettlementFailed => 'Settlement failed';

  @override
  String get kanbanSettlementConfirmed => 'Settlement confirmed';

  @override
  String kanbanSettlementError(Object error) {
    return 'Settlement error: $error';
  }

  @override
  String kanbanPreviewFailed(Object error) {
    return 'Preview failed: $error';
  }

  @override
  String get kanbanPickupNoSettlement =>
      'Pickup orders don\'t require settlement';

  @override
  String get kanbanCannotMoveBackward => 'Cannot move backward';

  @override
  String get kanbanCancelViaMenuOnly =>
      'Orders can\'t be cancelled by dragging. Use the card menu and pick \"Cancel Order\".';

  @override
  String get kanbanReturnViaMenuOnly =>
      'Orders can\'t be returned by dragging. Use the card menu and pick \"Return Order\".';

  @override
  String get kanbanFullyReturnedLocked =>
      'This order was fully returned and can no longer be moved.';

  @override
  String get kanbanPinBadgePinned => 'Pinned';

  @override
  String get kanbanPinBadgePinnedTooltip => 'This address has map coordinates';

  @override
  String get kanbanPinBadgeMissing => 'No map pin';

  @override
  String get kanbanPinBadgeMissingTooltip =>
      'No map pin yet — add the location link before dispatch';

  @override
  String get kanbanMoveOneStage => 'Can only move one stage at a time';

  @override
  String get kanbanAllBranches => 'All Branches';

  @override
  String kanbanBranchCount(Object count) {
    return '$count branches';
  }

  @override
  String get kanbanLoadingBranches => 'Loading branches...';

  @override
  String get kanbanTapToRefreshBalance => 'Tap to refresh balance';

  @override
  String get kanbanPressBackAgain => 'Press back again to exit';

  @override
  String get invoiceDeliveryAddress => 'Delivery Address';

  @override
  String get invoiceItems => 'Items';

  @override
  String get invoiceNetTotal => 'Net Total';

  @override
  String get invoiceShippingIncome => 'Shipping Income';

  @override
  String get invoiceShippingExpense => 'Shipping Expense';

  @override
  String get invoiceGrandTotal => 'Grand Total';

  @override
  String invoiceAlreadyStatus(Object status) {
    return 'Invoice already $status';
  }

  @override
  String get invoiceSelectPaymentMethod => 'Select Payment Method';

  @override
  String get invoiceWallet => 'Wallet';

  @override
  String get invoiceSubmit => 'Submit';

  @override
  String get invoiceNoPosProfileCash =>
      'No POS profile selected for Cash payment';

  @override
  String invoiceProcessingPayment(Object method) {
    return 'Processing $method payment...';
  }

  @override
  String invoicePaymentSuccess(Object entry) {
    return 'Payment successful ($entry)';
  }

  @override
  String get invoiceReceiptAmountWarning =>
      'Warning: Could not get payment amount for receipt';

  @override
  String get invoiceReceiptNoPosProfile =>
      'Warning: No POS profile found - receipt not created. Please select a POS profile.';

  @override
  String invoiceReceiptCreated(Object receipt) {
    return 'Payment receipt created ($receipt) - please upload receipt image from header';
  }

  @override
  String invoiceReceiptReturnedWarning(Object message) {
    return 'Warning: Receipt creation returned: $message';
  }

  @override
  String invoiceReceiptCreationFailed(Object error) {
    return 'Warning: Receipt creation failed: $error';
  }

  @override
  String get invoicePaymentFailed => 'Payment failed';

  @override
  String invoicePaymentError(Object error) {
    return 'Payment error: $error';
  }

  @override
  String get invoiceCollectCashTitle => 'Collect Cash';

  @override
  String invoiceCollectCashBody(Object amount, Object invoiceId) {
    return 'Please collect from the customer:\n\nTotal Amount: $amount EGP\n\nThis includes:\n• Order items\n• Shipping fee\n\nInvoice: $invoiceId';
  }

  @override
  String get invoiceSelectPosFirst => 'Select POS profile first';

  @override
  String get invoiceChangeCollectionMethod => 'Change collection method';

  @override
  String get invoiceRequestedPaymentMethod => 'Requested method';

  @override
  String get invoiceActualCollectionMethod => 'Actual collection';

  @override
  String get invoiceCollectionReferenceLabel => 'Reference number';

  @override
  String get invoiceCollectionReferenceRequired =>
      'Online collection requires a reference number.';

  @override
  String get invoiceCollectionCashAtBranchNotice =>
      'The courier for this order has already closed out, so this cash is recorded as received at the branch and will be expected in the drawer at the next count.';

  @override
  String get invoiceChangingCollectionMethod => 'Changing collection method...';

  @override
  String invoiceCollectionMethodChanged(Object method) {
    return 'Collection method changed to $method';
  }

  @override
  String invoiceCollectionMethodChangeError(Object error) {
    return 'Collection method error: $error';
  }

  @override
  String get invoiceCollectingCashPartner =>
      'Collecting cash & dispatching (Sales Partner)...';

  @override
  String get invoiceCashCollectedOfd =>
      'Cash collected & sent Out For Delivery';

  @override
  String invoiceOfdFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String invoiceOfdError(Object error) {
    return 'Error: $error';
  }

  @override
  String get invoiceSentOfd => 'Sent Out For Delivery (DN will be created)';

  @override
  String invoiceActionFailed(Object error) {
    return 'Action failed: $error';
  }

  @override
  String get invoiceSettleLaterMissingParty =>
      'Settle Later failed: courier party missing.';

  @override
  String get invoiceMarkedSettleLater => 'Marked to Settle Later';

  @override
  String get invoiceSettleLaterFailed => 'Settle Later failed';

  @override
  String invoiceSettleLaterError(Object error) {
    return 'Settle Later error: $error';
  }

  @override
  String get invoiceSettlementMissingParty =>
      'Settlement failed: courier party missing.';

  @override
  String get invoicePreviewExpired => 'Preview expired. Please retry.';

  @override
  String get invoiceConfirmingSettlement => 'Confirming settlement...';

  @override
  String get invoiceSettlementConfirmed => 'Settlement confirmed';

  @override
  String get invoiceSettlementFailed => 'Settlement failed';

  @override
  String invoiceSettlementError(Object error) {
    return 'Settlement error: $error';
  }

  @override
  String get invoiceProcessingDelivery => 'Processing Delivery...';

  @override
  String get invoiceUpdated => 'Updated';

  @override
  String get customerShippingAddressTitle => 'Choose Shipping Address';

  @override
  String get customerShippingAddressSubtitle =>
      'Select a saved shipping address or add a new one for this customer.';

  @override
  String get customerShippingAddressSavedTab => 'Saved Addresses';

  @override
  String get customerShippingAddressNewTab => 'Add New Address';

  @override
  String get customerShippingAddressEmpty => 'No saved shipping addresses yet.';

  @override
  String get customerShippingAddressSelectRequired =>
      'Choose a shipping address or add a new one.';

  @override
  String get customerShippingAddressLoadFailed =>
      'Failed to load shipping addresses.';

  @override
  String get customerShippingAddressEditTab => 'Edit Address';

  @override
  String get customerShippingAddressEditTitle => 'Edit Shipping Address';

  @override
  String get customerShippingAddressDeleteConfirm =>
      'Delete this address? This cannot be undone.';

  @override
  String get customerShippingAddressDeleteSuccess => 'Address deleted.';

  @override
  String get customerShippingAddressDeleteFailed => 'Failed to delete address.';

  @override
  String get customerShippingAddressUpdateSuccess => 'Address updated.';

  @override
  String get customerShippingAddressUpdateFailed => 'Failed to update address.';

  @override
  String get customerShippingAddressLine1Label => 'Address Line 1';

  @override
  String get customerShippingAddressLine2Label => 'Address Line 2 (optional)';

  @override
  String get customerShippingAddressTerritoryLabel => 'Territory';

  @override
  String get customerShippingAddressPincodeLabel => 'Postal Code (optional)';

  @override
  String get customerShippingAddressTerritoryRequired =>
      'Please select a territory.';

  @override
  String get customerShippingAddressLine1Required =>
      'Address line 1 is required.';

  @override
  String get posAmendmentDraftTitle => 'Invoice amendment draft';

  @override
  String get posAmendmentDraftMessage =>
      'Review the changes carefully, then submit to replace the original invoice.';

  @override
  String get posAmendmentCheckoutBlocked =>
      'Amendment submission is unavailable for this draft. Return to the order and reopen the amendment.';

  @override
  String get invoiceDeliveryFailed => 'Delivery action failed';

  @override
  String invoiceDeliveryError(Object error) {
    return 'Error: $error';
  }

  @override
  String get invoiceDeliveryTitle => 'Delivery';

  @override
  String get invoiceUnpaidWarning =>
      'Invoice is UNPAID. Choose Courier Collects Cash Now to record a cash payment before marking Out For Delivery.';

  @override
  String get invoiceCannotSettleParty =>
      'Cannot settle: courier party not resolved. Assign courier or retry.';

  @override
  String get invoiceNothingToSettle => 'Nothing to settle';

  @override
  String get invoiceSettlementComplete => 'Settlement complete';

  @override
  String get invoiceEditAddress => 'Edit Customer Address';

  @override
  String get invoicePhoneNumber => 'Phone Number';

  @override
  String get invoiceDeliveryAddressLabel => 'Delivery Address';

  @override
  String get invoiceAddressHelper => 'Enter the full delivery address';

  @override
  String get invoiceAddressUpdateInfo =>
      'This will update the customer\'s default address and phone number.';

  @override
  String get invoiceAddressEmpty => 'Address cannot be empty';

  @override
  String get invoiceUpdatingAddress => 'Updating customer address...';

  @override
  String get invoiceAddressUpdated => 'Customer address updated successfully';

  @override
  String invoiceAddressUpdatedWithShipping(
    Object oldExpense,
    Object newExpense,
  ) {
    return 'Address updated. Shipping: $oldExpense → $newExpense EGP';
  }

  @override
  String get invoiceAddressUpdateFailed => 'Failed to update address';

  @override
  String invoiceCopiedNumber(Object number) {
    return 'Copied: $number';
  }

  @override
  String get invoiceCopy => 'Copy';

  @override
  String get invoiceCannotCall => 'Unable to make phone call';

  @override
  String get invoiceCall => 'Call';

  @override
  String get invoiceSettleBeforeCancel =>
      'Settle or refund partial payments before cancelling this order.';

  @override
  String get invoiceCancelFailed => 'Failed to cancel order. Please try again.';

  @override
  String invoiceCancelledWithCn(Object creditNote) {
    return 'Order cancelled. Credit note $creditNote created.';
  }

  @override
  String get invoiceCancelledSuccess => 'Order cancelled successfully.';

  @override
  String get invoiceNoPosProfile => 'No POS profile selected';

  @override
  String get invoiceAssignBranch => 'Assign to Branch';

  @override
  String invoiceCustomerName(Object name) {
    return 'Customer: $name';
  }

  @override
  String invoiceInvoiceLabel(Object name) {
    return 'Invoice: $name';
  }

  @override
  String get invoiceTransferInfo =>
      'The order will be moved to the selected branch and reset to Received state.';

  @override
  String get invoiceTransferring => 'Transferring order...';

  @override
  String invoiceTransferSuccess(Object branch) {
    return 'Order transferred successfully to $branch';
  }

  @override
  String get invoiceTransferFailed => 'Transfer failed. Please try again.';

  @override
  String get invoiceCannotDetermineProfile =>
      'Unable to determine POS profile for this invoice';

  @override
  String get invoiceLoadingSlots => 'Loading delivery slots...';

  @override
  String get invoiceNoSlots => 'No delivery slots available for this branch';

  @override
  String get invoiceChangeSlot => 'Change Delivery Slot';

  @override
  String invoiceCurrentSlot(Object slot) {
    return 'Current: $slot';
  }

  @override
  String get invoiceSlotUpdateInfo =>
      'The delivery slot will be updated for this order.';

  @override
  String get invoiceNoChanges => 'No changes made';

  @override
  String get invoiceUpdatingSlot => 'Updating delivery slot...';

  @override
  String invoiceSlotUpdated(Object slot) {
    return 'Delivery slot updated to $slot';
  }

  @override
  String get invoiceSlotUpdateFailed => 'Failed to update delivery slot';

  @override
  String get tripsDeliveryTripsTitle => 'Delivery Trips';

  @override
  String get tripsActiveTab => 'Active';

  @override
  String get tripsCompletedTab => 'Completed';

  @override
  String get tripsCreateTripTitle => 'Create Delivery Trip';

  @override
  String get tripsCreateTripButton => 'Create Trip';

  @override
  String tripsCreateTripFailed(Object error) {
    return 'Failed to create trip: $error';
  }

  @override
  String get tripsOrdersLabel => 'Orders';

  @override
  String get tripsTotalAmount => 'Total Amount';

  @override
  String get tripsTotalShipping => 'Total Shipping';

  @override
  String tripsSameTerritory(Object territory) {
    return 'Same territory: $territory';
  }

  @override
  String get tripsSelectCourier => 'Select Courier';

  @override
  String get tripsNoTrips => 'No trips';

  @override
  String tripsOrdersCount(Object count) {
    return '$count orders';
  }

  @override
  String get tripsDoubleShippingLabel => 'Double Shipping';

  @override
  String get tripsNotesLabel => 'Notes';

  @override
  String get tripsMarkTripAsDeliveredTitle => 'Mark Trip as Delivered';

  @override
  String tripsMarkTripAsDeliveredContent(Object tripName, Object count) {
    return 'Mark \"$tripName\" with $count orders as delivered?';
  }

  @override
  String tripsTripMarkedAsDelivered(Object tripName) {
    return '$tripName marked as delivered';
  }

  @override
  String tripsFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get tripsSendForDeliveryTitle => 'Send for Delivery';

  @override
  String tripsSendForDeliveryContent(Object count, Object courierName) {
    return 'Send $count orders for delivery?\n\nCourier: $courierName';
  }

  @override
  String get tripsSentForDeliverySuccess => 'Trip sent for delivery';

  @override
  String get tripsMarkAsDeliveredButton => 'Mark as Delivered';

  @override
  String tripsMarkAllAsDeliveredContent(Object count) {
    return 'Mark all $count orders as delivered?\n\nThis will complete the trip.';
  }

  @override
  String get tripsTripMarkedSuccess => 'Trip marked as delivered';

  @override
  String get tripsSending => 'Sending...';

  @override
  String get tripsMarking => 'Marking...';

  @override
  String tripsSubTerritoryRequired(Object invoices) {
    return 'Please select a sub-territory for the following orders before creating a trip: $invoices';
  }

  @override
  String tripsInvoicesCount(Object count) {
    return 'Invoices ($count)';
  }

  @override
  String get subTerritorySelectTitle => 'Select Sub-territory';

  @override
  String subTerritoryForTerritory(Object territory) {
    return 'for $territory';
  }

  @override
  String get subTerritoryNoResults => 'No sub-territories found';

  @override
  String get subTerritoryLoadFailed => 'Failed to load sub-territories';

  @override
  String get customShippingBadgePending => 'Custom shipping pending';

  @override
  String get customShippingBadgeApproved => 'Custom shipping approved';

  @override
  String customShippingBadgeAmount(Object amount) {
    return 'Custom shipping $amount';
  }

  @override
  String get customShippingBadgeRejected => 'Custom shipping rejected';

  @override
  String get returnBadgeFull => 'Returned';

  @override
  String get returnBadgePartial => 'Partially returned';

  @override
  String returnBadgeFullAmount(Object amount) {
    return 'Returned $amount';
  }

  @override
  String returnBadgePartialAmount(Object amount) {
    return 'Partially returned $amount';
  }

  @override
  String get receiptSelectImageSource => 'Select Image Source';

  @override
  String get receiptCamera => 'Camera';

  @override
  String get receiptGallery => 'Gallery';

  @override
  String get receiptUploading => 'Uploading receipt image...';

  @override
  String get receiptUploadedSuccess => 'Receipt image uploaded successfully';

  @override
  String get receiptUploadFailed => 'Failed to upload receipt image';

  @override
  String get receiptImageEmpty =>
      'Couldn\'t read that photo. Try again, or pick a different one.';

  @override
  String receiptUploadError(Object error) {
    return 'Error uploading image: $error';
  }

  @override
  String get receiptConfirming => 'Confirming receipt...';

  @override
  String get receiptConfirmedSuccess => 'Receipt confirmed successfully';

  @override
  String get receiptConfirmFailed => 'Failed to confirm receipt';

  @override
  String receiptConfirmError(Object error) {
    return 'Error confirming receipt: $error';
  }

  @override
  String get receiptAllProfiles => 'All Profiles';

  @override
  String get receiptFilterByPosProfile => 'Filter by POS Profile';

  @override
  String get receiptNoReceiptsFound => 'No payment receipts found';

  @override
  String get receiptUploadImageButton => 'Upload Receipt Image';

  @override
  String get receiptReplaceImageButton => 'Replace Image';

  @override
  String get receiptRemoveImageButton => 'Remove Image';

  @override
  String get receiptRemoveConfirmTitle => 'Remove receipt image?';

  @override
  String get receiptRemoveConfirmBody =>
      'The uploaded screenshot will be deleted. You can upload a new one afterwards.';

  @override
  String get receiptRemoving => 'Removing receipt image...';

  @override
  String get receiptRemovedSuccess => 'Receipt image removed';

  @override
  String get receiptRemoveFailed => 'Failed to remove receipt image';

  @override
  String receiptRemoveError(Object error) {
    return 'Error removing image: $error';
  }

  @override
  String get receiptPreviewTitle => 'Receipt Preview';

  @override
  String get receiptPreviewButton => 'Preview Receipt';

  @override
  String get commonPrint => 'Print';

  @override
  String get statusCreated => 'Created';

  @override
  String get statusOutForDelivery => 'Out for Delivery';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusReturn => 'Return';

  @override
  String get statusReturned => 'Returned';

  @override
  String get statusReturnedToSender => 'Returned to Sender';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusUnconfirmed => 'Unconfirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPendingApproval => 'Pending Approval';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusDraft => 'Draft';

  @override
  String get kanbanNoInvoices => 'No invoices';

  @override
  String get kanbanTripCreatedSuccess => 'Delivery trip created successfully';

  @override
  String kanbanPartOfTripWarning(Object tripName) {
    return 'This order is part of trip $tripName. Send the entire trip for delivery from the Trips screen.';
  }

  @override
  String get kanbanOfdAwaitingInstapay =>
      'Out for delivery — awaiting InstaPay';

  @override
  String kanbanOfdAwaitingInstapayWithCourier(Object courier) {
    return 'Out for delivery with $courier — awaiting InstaPay';
  }

  @override
  String get kanbanDeliveryPartnerCourier => 'Delivery Partner Courier';

  @override
  String get kanbanDeliveryPartnerCourierSubtitle =>
      'This courier belongs to a delivery partner';

  @override
  String get kanbanRequestCustomShipping => 'Request Custom Shipping';

  @override
  String get customShippingCurrentShipping => 'Current Shipping';

  @override
  String get customShippingRequestedAmount => 'Requested Amount';

  @override
  String get customShippingReasonHint => 'Why custom shipping is needed...';

  @override
  String get customShippingAmountRequired => 'Amount is required';

  @override
  String get customShippingAmountInvalid => 'Enter a valid positive amount';

  @override
  String get customShippingReasonRequired =>
      'Please provide a reason (min 10 characters)';

  @override
  String get customShippingSubmitRequest => 'Submit Request';

  @override
  String get kanbanCustomShippingSubmitted =>
      'Custom shipping request submitted';

  @override
  String kanbanCustomShippingFailed(Object error) {
    return 'Failed to submit request: $error';
  }

  @override
  String get settlementPartnerDeliveryTitle => 'Partner Delivery Settlement';

  @override
  String get settlementPartnerInfoTitle => 'Partner Settlement Info';

  @override
  String settlementPartnerLabel(Object name) {
    return 'Partner: $name';
  }

  @override
  String get settlementPartnerCollectFull =>
      'Collect full order amount from courier:';

  @override
  String get settlementPartnerOnlinePaid =>
      'Online-paid — no cash exchange with courier';

  @override
  String get settlementPartnerCollectFullChip => 'Collect (Full Amount)';

  @override
  String get settlementNoExchange => 'No Cash Exchange';

  @override
  String settlementPartnerFeeTracked(Object amount) {
    return 'Partner fee (tracked): $amount';
  }

  @override
  String get settlementPartnerCollectedFull =>
      'Collected full order amount from courier';

  @override
  String get settlementPartnerFullAmountChip => 'Full amount';

  @override
  String get settlementPartnerOnlinePaidInfo =>
      'Online paid — no cash exchange';

  @override
  String get managerPendingCustomShipping =>
      'Pending Custom Shipping Approvals';

  @override
  String get managerNoPendingRequests => 'No pending requests';

  @override
  String managerReasonLabel(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get managerCustomShippingApproved => 'Custom shipping approved';

  @override
  String managerApproveFailed(Object error) {
    return 'Approve failed: $error';
  }

  @override
  String get managerRejectCustomShippingTitle => 'Reject Custom Shipping';

  @override
  String get managerReject => 'Reject';

  @override
  String get managerCustomShippingRejected => 'Custom shipping rejected';

  @override
  String managerRejectFailed(Object error) {
    return 'Reject failed: $error';
  }

  @override
  String get managerRejectReasonHint => 'Optional rejection reason';

  @override
  String get managerPendingCustomShippingLoadFailed =>
      'Failed to load pending custom shipping requests';

  @override
  String get managerTransferBranchesLoadFailed =>
      'Failed to load transfer branches';

  @override
  String get managerApproveDefaultError => 'Unable to approve the request.';

  @override
  String get managerRejectDefaultError => 'Unable to reject the request.';

  @override
  String get purchaseNoInvoicesYet => 'No purchase invoices yet';

  @override
  String get purchaseReorderFromSupplier => 'Reorder from same supplier';

  @override
  String get purchaseHistoryTitle => 'Purchase History';

  @override
  String get posCreateCustomer => 'Create Customer';

  @override
  String get posCustomerCreatedSuccess => 'Customer created successfully!';

  @override
  String get settingsUserProfileTitle => 'User Profile';

  @override
  String get settingsRolesTitle => 'Roles';

  @override
  String get settingsNoRolesAssigned => 'No roles assigned';

  @override
  String get settingsNotificationSettings => 'Notification Settings';

  @override
  String get settingsNoAlarmSounds => 'No alarm sounds available';

  @override
  String get settingsAlarmSoundLabel => 'Alarm Sound';

  @override
  String settingsFailedToLoadAlarmSounds(Object error) {
    return 'Failed to load alarm sounds: $error';
  }

  @override
  String settingsAlarmSoundChanged(Object title) {
    return 'Alarm sound changed to $title';
  }

  @override
  String settingsAlarmSoundUnavailable(Object title) {
    return '$title can\'t be used on this device. Keeping the default alarm sound.';
  }

  @override
  String settingsCustomAlarmSoundSet(Object title) {
    return 'Custom alarm sound set: $title';
  }

  @override
  String get settingsNoFileSelected => 'No file selected';

  @override
  String get settingsBrowseCustomSoundFile => 'Browse Custom Sound File';

  @override
  String get settingsCustomSoundTitle => 'Custom Sound';

  @override
  String itemGridStockLimitReached(Object stockQty) {
    return 'Stock limit reached. Only $stockQty available.';
  }

  @override
  String get menuDeliveryTrips => 'Delivery Trips';

  @override
  String get authLoginTitle => 'Login';

  @override
  String get printingPrintersTitle => 'Printers';

  @override
  String get printingUseBitmapReceipt => 'Use new bitmap receipt';

  @override
  String get printingUseBitmapReceiptHint =>
      'Renders the full receipt as an image and helps with Arabic, missing data, and gibberish issues.';

  @override
  String kanbanOrdersSelectedCount(int count) {
    return '$count orders selected';
  }

  @override
  String get loginModeDialogTitle => 'Choose Login Mode';

  @override
  String get loginModeLineManager => 'Line Manager';

  @override
  String get loginModeLineManagerDesc =>
      'Skip shift opening — manage operations directly';

  @override
  String get loginModeEmployee => 'Employee';

  @override
  String get loginModeEmployeeDesc => 'Open a shift before starting work';

  @override
  String get customerSearchHint => 'Search by name or phone';

  @override
  String get customerSearchStartTyping =>
      'Start typing a name or phone number to find a customer';

  @override
  String get customerSearchNoResults => 'No customers found';

  @override
  String get customerSearchByPhone => 'Search by phone number...';

  @override
  String get customerSearchByName => 'Search by customer name...';

  @override
  String get quickAddCustomerTitle => 'Quick Add Customer';

  @override
  String get quickAddCustomerTap => 'Tap to create new customer';

  @override
  String get customerNameLabel => 'Customer Name *';

  @override
  String get customerNameRequired => 'Customer name is required';

  @override
  String get customerTypeLabel => 'Customer type';

  @override
  String get customerTypeIndividual => 'Individual';

  @override
  String get customerTypeCompany => 'Company';

  @override
  String get customerGroupLabel => 'Customer group';

  @override
  String get customerGroupRequired => 'Please select a customer group';

  @override
  String get mobileNumberLabel => 'Mobile Number *';

  @override
  String get mobileNumberRequired => 'Mobile number is required';

  @override
  String get secondaryPhoneLabel => 'Secondary Phone (Optional)';

  @override
  String get secondaryPhoneHint => 'Additional contact number';

  @override
  String get locationLinkLabel => 'Location Link (Optional)';

  @override
  String get locationLinkHint => 'Google Maps link, etc.';

  @override
  String get locationLinkFieldLabel => 'Location link';

  @override
  String get locationLinkPasteHint =>
      'Paste a Google Maps link or 30.0444, 31.2357';

  @override
  String get locationLinkChecking => 'Checking the location…';

  @override
  String get locationLinkConfirmed => 'Location confirmed';

  @override
  String get locationLinkUnconfirmed => 'Location not confirmed yet';

  @override
  String get locationLinkClear => 'Clear location link';

  @override
  String get locationLinkRetry => 'Check again';

  @override
  String locationLinkDistanceKm(Object value) {
    return '$value km from the branch';
  }

  @override
  String locationLinkDistanceMeters(Object value) {
    return '$value m from the branch';
  }

  @override
  String get locationLinkErrorUnrecognized =>
      'That does not look like a Maps link. Paste a Google Maps link or coordinates like 30.0444, 31.2357.';

  @override
  String get locationLinkErrorUnresolved =>
      'Could not read a location from this link. Open it in Maps, share it again, and paste the new link.';

  @override
  String locationLinkErrorTooFar(Object distance) {
    return 'This point is $distance — too far to be a delivery address. Check the link.';
  }

  @override
  String get locationLinkErrorNetwork =>
      'Could not check the location. Try again.';

  @override
  String get detailedAddressRequired => 'Detailed Address *';

  @override
  String get detailedAddressOptional => 'Detailed Address (Optional)';

  @override
  String get addressOptionalPartner =>
      'Optional when Sales Partner is selected';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get territoryLabel => 'Territory *';

  @override
  String get territorySelectRequired => 'Please select a territory';

  @override
  String get territoryLoadFailed => 'Failed to load territories';

  @override
  String get unknownTerritory => 'Unknown Territory';

  @override
  String get customerCreateFailed => 'Failed to create customer';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authInvalidCredentials => 'Invalid credentials';

  @override
  String get authCannotReachServer =>
      'Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.';

  @override
  String get authConnectionFailed =>
      'Connection failed. Please verify network and server availability.';

  @override
  String get authLoginFailed => 'Login failed. Please try again.';

  @override
  String get menuReports => 'Reports';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsFinalProducts => 'Final Products';

  @override
  String get reportsFinalProductsDesc =>
      'Stock count by warehouse for Medium & Large items';

  @override
  String get reportsMaterials => 'Materials & Consumables';

  @override
  String get reportsMaterialsDesc =>
      'Raw materials, sub assemblies, and consumables stock';

  @override
  String get reportsRawMaterials => 'Raw Materials';

  @override
  String get reportsSubAssemblies => 'Sub Assemblies';

  @override
  String get reportsConsumables => 'Consumables';

  @override
  String get reportsItemName => 'Item';

  @override
  String get reportsItemGroup => 'Group';

  @override
  String get reportsTotal => 'Total';

  @override
  String get reportsNoData => 'No data available';

  @override
  String get reportsRetry => 'Retry';

  @override
  String get reportsComingSoon => 'Coming soon';

  @override
  String get reportsFrom => 'From';

  @override
  String get reportsTo => 'To';

  @override
  String get reportsRangeThisMonth => 'This Month';

  @override
  String get reportsRangeLast30Days => 'Last 30 Days';

  @override
  String get reportsRangeLast90Days => 'Last 90 Days';

  @override
  String get reportShippingTitle => 'Shipping Analytics';

  @override
  String get reportShippingSubtitle =>
      'Delivery cost, courier settlements & shipping P&L';

  @override
  String get reportInventoryTitle => 'Inventory Intelligence';

  @override
  String get reportInventorySubtitle =>
      'Stock velocity, critical items & movers';

  @override
  String get reportProductTitle => 'Product Analytics';

  @override
  String get reportProductSubtitle =>
      'Revenue, gross profit & best sellers by product';

  @override
  String get reportCustomerTitle => 'Customer Analytics';

  @override
  String get reportCustomerSubtitle =>
      'Segments, retention & at-risk customers';

  @override
  String get reportExecutiveTitle => 'Executive Overview';

  @override
  String get reportExecutiveSubtitle =>
      'Top-line KPIs across the whole business';

  @override
  String get reportB2bTitle => 'B2B Sales & Clients';

  @override
  String get reportB2bSubtitle => 'B2B revenue, pipeline & client health';

  @override
  String get reportNoData => 'No data for this period';

  @override
  String get reportError => 'Couldn\'t load report';

  @override
  String get reportAlerts => 'Alerts';

  @override
  String get reportShipKpiTotalOrders => 'Total Orders';

  @override
  String get reportShipKpiDeliveryOrders => 'Delivery Orders';

  @override
  String get reportShipKpiPickupOrders => 'Pickup Orders';

  @override
  String get reportShipKpiExpense => 'Shipping Expense';

  @override
  String get reportShipKpiIncome => 'Delivery Income';

  @override
  String get reportShipKpiNetPl => 'Net P&L';

  @override
  String get reportShipKpiAvgCost => 'Avg Cost / Order';

  @override
  String get reportShipKpiPendingOverrides => 'Pending Overrides';

  @override
  String get reportShipKpiUnsettled => 'Unsettled';

  @override
  String get reportCostByTerritory => 'Cost by Territory';

  @override
  String get reportCostBySubTerritory => 'Cost by Sub-Territory';

  @override
  String get reportCostByBranch => 'Cost by Branch';

  @override
  String get reportCostByCourier => 'Cost by Courier';

  @override
  String get reportShippingOverrides => 'Shipping Overrides';

  @override
  String get reportDoubleShipping => 'Double-Shipping Impact';

  @override
  String get reportDailyTrend => 'Daily Trend';

  @override
  String get reportPickupVsDelivery => 'Pickup vs Delivery';

  @override
  String get reportUnsettledBalances => 'Unsettled Courier Balances';

  @override
  String get reportPickupDeliveryTrend => 'Pickup / Delivery Trend';

  @override
  String get reportInvKpiStockItems => 'Stock Items';

  @override
  String get reportInvKpiCritical => 'Critical';

  @override
  String get reportInvKpiWatch => 'Watch List';

  @override
  String get reportInvKpiSlow => 'Slow Movers';

  @override
  String get reportInvKpiOverstock => 'Overstocked';

  @override
  String get reportInvKpiStockValue => 'Stock Value';

  @override
  String get reportStockVelocity => 'Stock Velocity';

  @override
  String get reportTopMovers => 'Top Movers';

  @override
  String get reportRestockAlerts => 'Restock Alerts';

  @override
  String get reportCriticalItems => 'Critical';

  @override
  String get reportWatchList => 'Watch List';

  @override
  String get reportSlowMovers => 'Slow Movers';

  @override
  String get reportOverstocked => 'Overstocked';

  @override
  String get reportTopSellers => 'Top Sellers';

  @override
  String get reportKpiTotalRevenue => 'Total Revenue';

  @override
  String get reportKpiTotalOrders => 'Total Orders';

  @override
  String get reportKpiGrossProfit => 'Gross Profit';

  @override
  String get reportKpiGrossMargin => 'Gross Margin';

  @override
  String get reportKpiAov => 'Avg Order Value';

  @override
  String get reportKpiBestSeller => 'Best Seller';

  @override
  String get reportKpiTopTerritory => 'Top Territory';

  @override
  String get reportRevenueByType => 'Revenue by Type';

  @override
  String get reportTopProducts => 'Top Products';

  @override
  String get reportByTerritory => 'By Territory';

  @override
  String get reportRevenueTrend => 'Revenue Trend';

  @override
  String get reportBundleComposition => 'Bundle Composition';

  @override
  String get reportKpiTotalCustomers => 'Total Customers';

  @override
  String get reportKpiActive => 'Active';

  @override
  String get reportKpiNew => 'New';

  @override
  String get reportKpiRepeatRate => 'Repeat Rate';

  @override
  String get reportKpiChampions => 'Champions';

  @override
  String get reportKpiAtRisk => 'At Risk';

  @override
  String get reportKpiLost => 'Lost';

  @override
  String get reportSegmentDistribution => 'Segment Distribution';

  @override
  String get reportSegmentDetail => 'Segment Detail';

  @override
  String get reportTopCustomers => 'Top Customers';

  @override
  String get reportAtRiskWinBack => 'At-Risk / Win-Back';

  @override
  String get reportNewCustomerAcquisition => 'New Customer Acquisition';

  @override
  String get reportKpiRevenue => 'Revenue';

  @override
  String get reportKpiOrders => 'Orders';

  @override
  String get reportKpiNetShippingPl => 'Net Shipping P&L';

  @override
  String get reportKpiCustomers => 'Customers';

  @override
  String get reportKpiCriticalStock => 'Critical Stock';

  @override
  String get reportProductMix => 'Product Mix';

  @override
  String get reportCustomerSegments => 'Customer Segments';

  @override
  String get reportTopTerritories => 'Top Territories';

  @override
  String get reportKpiB2bRevenue => 'B2B Revenue';

  @override
  String get reportKpiB2bOrders => 'B2B Orders';

  @override
  String get reportKpiActiveClients => 'Active Clients';

  @override
  String get reportKpiNewClients => 'New Clients';

  @override
  String get reportKpiReorderDue => 'Reorder Due';

  @override
  String get reportSalesPipeline => 'Sales Pipeline';

  @override
  String get reportTopClients => 'Top Clients';

  @override
  String get reportRevenueByPolicy => 'Revenue by Commercial Policy';

  @override
  String get reportClientsByGroup => 'Clients by Group';

  @override
  String get reportReorderDue => 'Reorder Due';

  @override
  String get reportAtRiskClients => 'At-Risk Clients';

  @override
  String get reportConversion => 'Conversion';

  @override
  String get menuMasterOrders => 'Master Orders';

  @override
  String get masterOrdersTitle => 'Master Orders';

  @override
  String get masterOrdersSearchHint => 'Search by order ID, customer...';

  @override
  String get masterOrdersNoResults => 'No orders found';

  @override
  String get masterOrdersClearFilters => 'Clear Filters';

  @override
  String masterOrdersResultCount(int count) {
    return '$count orders';
  }

  @override
  String get masterOrdersFilterStatus => 'Status';

  @override
  String get masterOrdersFilterBranch => 'Branch';

  @override
  String get masterOrdersFilterPayment => 'Payment';

  @override
  String get masterOrdersFilterDate => 'Date Range';

  @override
  String get masterOrdersFilterDateFrom => 'From';

  @override
  String get masterOrdersFilterDateTo => 'To';

  @override
  String get masterOrdersOutstanding => 'Outstanding';

  @override
  String get masterOrdersCurrency => 'EGP';

  @override
  String get menuShiftMonitor => 'Shift Monitor';

  @override
  String get shiftMonitorTitle => 'POS Shift Monitor';

  @override
  String get shiftMonitorAccessRequired => 'Manager access required';

  @override
  String get shiftMonitorAccessDeniedBody =>
      'This page is available to JARZ Manager roles and above.';

  @override
  String get shiftMonitorFiltersTitle => 'Filters';

  @override
  String get shiftMonitorToday => 'Today';

  @override
  String get shiftMonitorLast7Days => 'Last 7 Days';

  @override
  String get shiftMonitorCustomRange => 'Custom Range';

  @override
  String get shiftMonitorPickDateRange => 'Pick Date Range';

  @override
  String shiftMonitorDateRangeValue(Object from, Object to) {
    return '$from to $to';
  }

  @override
  String get shiftMonitorProfileFilter => 'POS Profile';

  @override
  String get shiftMonitorStatusFilter => 'Status';

  @override
  String get shiftMonitorStatusAll => 'All';

  @override
  String get shiftMonitorStatusOpen => 'Open';

  @override
  String get shiftMonitorStatusClosed => 'Closed';

  @override
  String get shiftMonitorNoData => 'No shifts found for the selected filters.';

  @override
  String get shiftMonitorOpenCount => 'Open Shifts';

  @override
  String get shiftMonitorClosedCount => 'Closed Shifts';

  @override
  String get shiftMonitorDiscrepancyCount => 'Discrepancies';

  @override
  String get shiftMonitorDiscrepancyTotal => 'Discrepancy Total';

  @override
  String shiftMonitorLatestStart(Object value) {
    return 'Latest start: $value';
  }

  @override
  String shiftMonitorShiftCount(Object count) {
    return '$count shifts';
  }

  @override
  String get shiftMonitorOpenedAt => 'Opened At';

  @override
  String get shiftMonitorOpenedBy => 'Opened By';

  @override
  String get shiftMonitorClosedAt => 'Closed At';

  @override
  String get shiftMonitorClosedBy => 'Closed By';

  @override
  String get shiftMonitorCashAccount => 'Cash Account';

  @override
  String get shiftMonitorOpeningCash => 'Opening Cash';

  @override
  String get shiftMonitorExpectedClosingCash => 'Expected Closing';

  @override
  String get shiftMonitorActualClosingCash => 'Actual Closing';

  @override
  String get shiftMonitorDifference => 'Difference';

  @override
  String get shiftMonitorDifferenceSurplus => 'Surplus';

  @override
  String get shiftMonitorDifferenceShortage => 'Shortage';

  @override
  String get shiftMonitorNoDiscrepancy => 'No discrepancy';

  @override
  String get shorebirdUpdateBannerMessage =>
      'A new version is ready — fully close and reopen the app to apply it.';

  @override
  String get aboutRestartInstruction =>
      'Force-close and reopen the app to apply the downloaded patch.';

  @override
  String get aboutPatchPending => 'Pending patch (after restart)';

  @override
  String get menuLeads => 'Leads';

  @override
  String get leadFieldEmail => 'Email';

  @override
  String get leadFieldSource => 'Source';

  @override
  String get leadFieldTerritory => 'Territory';

  @override
  String get leadB2bStage => 'B2B Stage';

  @override
  String get leadFitScore => 'Fit Score';

  @override
  String get b2bMoveTo => 'Move to';

  @override
  String get shiftMonitorForceCloseAction => 'Close This Shift';

  @override
  String shiftMonitorForceCloseTitle(String user) {
    return 'Close $user\'s Shift';
  }

  @override
  String shiftMonitorForceCloseIntro(String user, String branch) {
    return 'You are closing a shift opened by $user on $branch. Enter the cash actually counted in the drawer — any difference posts a Cash Over/Short entry, exactly as a normal close would.';
  }

  @override
  String get shiftMonitorForceCloseReasonLabel => 'Reason (required)';

  @override
  String get shiftMonitorForceCloseReasonHint =>
      'e.g. staff member left without closing';

  @override
  String get shiftMonitorForceCloseReasonRequired =>
      'Please give a reason for closing another user\'s shift.';

  @override
  String shiftMonitorForceCloseCountLabel(String mode) {
    return 'Counted amount — $mode';
  }

  @override
  String shiftMonitorForceCloseCountRequired(String mode) {
    return 'Enter a counted amount for $mode.';
  }

  @override
  String shiftMonitorForceCloseExpected(String amount) {
    return 'System expected: $amount';
  }

  @override
  String shiftMonitorForceCloseCourierWarning(int transactions, int invoices) {
    return 'This branch still has $transactions unsettled courier transaction(s) across $invoices order(s). They stay outstanding after closing and must still be settled.';
  }

  @override
  String get shiftMonitorForceCloseCourierAck =>
      'I understand and want to close anyway';

  @override
  String get shiftMonitorForceCloseConfirm => 'Close Shift';

  @override
  String get shiftMonitorForceCloseSuccess => 'Shift closed.';

  @override
  String get returnOrderTitle => 'Return Order';

  @override
  String get returnOrderLinesLabel => 'Items coming back';

  @override
  String returnOrderLineAvailable(String qty) {
    return 'Up to $qty can be returned';
  }

  @override
  String returnOrderLineAvailableAfterPrior(String qty, String returned) {
    return 'Up to $qty can be returned ($returned already returned)';
  }

  @override
  String get returnOrderLineFullyReturned => 'Already returned';

  @override
  String get returnOrderCreditAmountLabel => 'Customer will be credited';

  @override
  String get returnOrderFullNotice =>
      'The whole order is coming back. Stock returns to the branch and the order is credited in full.';

  @override
  String get returnOrderPartialNotice =>
      'Part of the order is coming back. Only the selected items are credited and returned to stock.';

  @override
  String get returnOrderTypeLabel => 'Return type';

  @override
  String get returnTypeCustomerReturn => 'Customer return';

  @override
  String get returnTypeFailedDelivery => 'Failed delivery';

  @override
  String get returnTypeDamaged => 'Damaged';

  @override
  String get returnTypeWrongItem => 'Wrong item';

  @override
  String get returnOrderReasonLabel => 'Reason';

  @override
  String get returnOrderReasonRequired =>
      'Please describe why the order is coming back';

  @override
  String get returnOrderNotesOptional => 'Additional notes (optional)';

  @override
  String get returnOrderPayCourierTitle => 'Pay the courier for this trip';

  @override
  String get returnOrderPayCourierYes =>
      'The courier keeps their delivery fee.';

  @override
  String get returnOrderPayCourierNo =>
      'The delivery fee will be reversed off the courier\'s balance.';

  @override
  String get returnOrderRefundLabel => 'Money already collected';

  @override
  String get returnOrderRefundCredit => 'Keep as customer credit';

  @override
  String get returnOrderRefundNow => 'Refund cash now';

  @override
  String get returnOrderRefundUnavailable => 'No collected payment to refund.';

  @override
  String get returnOrderConfirmButton => 'Confirm return';

  @override
  String get returnOrderProcessing => 'Processing return…';

  @override
  String get returnOrderPreviewFailed => 'Could not load the return details.';

  @override
  String get returnOrderNotAvailable => 'This order cannot be returned.';

  @override
  String get returnOrderFailed => 'The return could not be completed.';

  @override
  String get returnOrderSuccess => 'Return completed.';

  @override
  String returnOrderSuccessWithCn(String creditNote) {
    return 'Return completed. Credit note $creditNote created.';
  }

  @override
  String get menuItemRequests => 'Item Requests';

  @override
  String get requestsTitle => 'Item Requests';

  @override
  String get requestsFilterOpen => 'Open';

  @override
  String get requestsFilterMine => 'Mine';

  @override
  String get requestsFilterAll => 'All';

  @override
  String get requestsEmptyOpen => 'Nothing is being requested right now';

  @override
  String get requestsEmptyMine => 'You have not requested anything yet';

  @override
  String get requestsEmptyAll => 'No requests yet';

  @override
  String get requestsEmptyHint =>
      'Tap + to ask for something you are running out of.';

  @override
  String get requestsNewTitle => 'Request items';

  @override
  String get requestsAddItems => 'Add items';

  @override
  String get requestsNeededBy => 'Needed by';

  @override
  String get requestsNoteLabel => 'Note (optional)';

  @override
  String get requestsNoteHint => 'Brand, size, urgency';

  @override
  String get requestsSubmit => 'Send request';

  @override
  String requestsSubmitted(Object name) {
    return 'Request $name sent';
  }

  @override
  String requestsSubmitFailed(Object error) {
    return 'Could not send request: $error';
  }

  @override
  String get requestsNoItemsYet => 'No items added yet';

  @override
  String requestsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String requestsRequestedBy(Object name) {
    return 'by $name';
  }

  @override
  String get requestsOverdue => 'Overdue';

  @override
  String get requestsStatusPending => 'Waiting';

  @override
  String get requestsStatusPartiallyReceived => 'Partly bought';

  @override
  String get requestsStatusReceived => 'Bought';

  @override
  String get requestsStatusStopped => 'Rejected';

  @override
  String get requestsStatusCancelled => 'Cancelled';

  @override
  String get requestsStatusOrdered => 'Ordered';

  @override
  String get requestsReject => 'Reject';

  @override
  String get requestsRejectTitle => 'Reject this request?';

  @override
  String get requestsRejectReason => 'Reason (optional)';

  @override
  String get requestsRejected => 'Request rejected';

  @override
  String get requestsReopen => 'Reopen';

  @override
  String get requestsReopened => 'Request reopened';

  @override
  String requestsLineProgress(Object received, Object requested, Object uom) {
    return '$received of $requested $uom';
  }

  @override
  String get requestsBranchLabel => 'Branch';

  @override
  String get purchaseFromRequests => 'From requests';

  @override
  String get purchaseFromRequestsTitle => 'Buy requested items';

  @override
  String get purchaseFromRequestsEmpty => 'No open requests to buy';

  @override
  String get purchaseFromRequestsHint =>
      'Quantities are pre-filled with what is still outstanding. Change anything before adding.';

  @override
  String purchaseRequestedQty(Object qty) {
    return 'requested $qty';
  }

  @override
  String purchaseBuyingLess(Object requested, Object buying) {
    return 'requested $requested, buying $buying';
  }

  @override
  String purchaseOnHand(Object qty) {
    return 'on hand $qty';
  }

  @override
  String purchaseLastPaid(Object rate) {
    return 'last paid $rate';
  }

  @override
  String purchaseAddSelected(Object count) {
    return 'Add $count to cart';
  }

  @override
  String purchaseNeededBy(Object date) {
    return 'needed $date';
  }

  @override
  String get purchaseRequestSources => 'Requested by';

  @override
  String get purchaseUrgent => 'Urgent';

  @override
  String get purchasePaymentCredit => 'On account (pay later)';

  @override
  String get purchasePaymentCreditSubtitle =>
      'Leaves an outstanding balance with the supplier';

  @override
  String get purchaseBillNoLabel => 'Supplier bill no.';

  @override
  String get purchaseBillNoHint => 'From the supplier\'s own invoice';

  @override
  String get purchaseBillDateLabel => 'Bill date';

  @override
  String get purchaseTaxesLabel => 'Taxes';

  @override
  String get purchaseTaxesNone => 'No tax';

  @override
  String get purchaseNoVat => 'No VAT';

  @override
  String purchaseVatValue(Object amount) {
    return 'VAT: $amount';
  }

  @override
  String purchaseNetTotalValue(Object amount) {
    return 'Net: $amount';
  }

  @override
  String get purchaseNewSupplier => 'New supplier';

  @override
  String get purchaseNewSupplierName => 'Supplier name';

  @override
  String get purchaseNewSupplierGroup => 'Supplier group';

  @override
  String get purchaseNewSupplierPhone => 'Phone (optional)';

  @override
  String purchaseSupplierCreated(Object name) {
    return 'Supplier $name created';
  }

  @override
  String get purchaseSubmitting => 'Creating purchase';

  @override
  String get purchaseOutstandingLabel => 'Outstanding';

  @override
  String get purchasePayNow => 'Pay now';

  @override
  String purchasePaid(Object entry) {
    return 'Payment recorded ($entry)';
  }

  @override
  String get purchaseReturnAction => 'Return to supplier';

  @override
  String get purchaseReturnTitle => 'Return to supplier';

  @override
  String get purchaseReturnReason => 'Reason';

  @override
  String get purchaseReturnQtyLabel => 'Return qty';

  @override
  String get purchaseReturnSubmit => 'Create return';

  @override
  String purchaseReturned(Object name) {
    return 'Return $name created';
  }

  @override
  String get purchaseHistoryFilterSupplier => 'Supplier';

  @override
  String get purchaseHistoryFilterStatus => 'Status';

  @override
  String get purchaseHistoryFilterAll => 'All';

  @override
  String get purchaseHistoryFilterClear => 'Clear filters';

  @override
  String get purchaseHistorySearchHint => 'Invoice or bill no.';

  @override
  String purchaseItemsInvoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String kanbanRunProgressLabel(int delivered, int total) {
    return '$delivered/$total delivered';
  }

  @override
  String kanbanRunProgressTooltip(String courier, int delivered, int total) {
    return '$courier: $delivered of $total stops delivered on this board';
  }

  @override
  String get kanbanRunProgressComplete => 'Run complete';

  @override
  String kanbanRunStopLabel(int sequence) {
    return 'Stop $sequence';
  }

  @override
  String kanbanRunFailedLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missed',
      one: '1 missed',
    );
    return '$_temp0';
  }

  @override
  String kanbanRunFailedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops on this run were attempted and not delivered',
      one: '1 stop on this run was attempted and not delivered',
    );
    return '$_temp0';
  }

  @override
  String get kanbanRunAttemptFailedLabel => 'Delivery missed';

  @override
  String kanbanRunAttemptFailedTooltip(int attempts) {
    String _temp0 = intl.Intl.pluralLogic(
      attempts,
      locale: localeName,
      other: '$attempts times',
      one: 'once',
    );
    return 'This stop was attempted $_temp0 and has not been delivered';
  }

  @override
  String get menuLiveCourierMap => 'Live courier map';

  @override
  String get fleetTitle => 'Live courier map';

  @override
  String get fleetRefreshTooltip => 'Refresh now';

  @override
  String fleetUpdatedAgo(String ago) {
    return 'Updated $ago';
  }

  @override
  String get fleetUpdating => 'Updating…';

  @override
  String fleetCouriersOnMap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count couriers on the map',
      one: '1 courier on the map',
    );
    return '$_temp0';
  }

  @override
  String get fleetRefreshFailed =>
      'Refresh failed — these positions are only getting older';

  @override
  String get fleetLegendTitle => 'How old is each dot';

  @override
  String fleetLegendFresh(int minutes) {
    return 'Fresh · under $minutes min';
  }

  @override
  String fleetLegendAgeing(int from, int to) {
    return 'Ageing · $from–$to min';
  }

  @override
  String fleetLegendStale(int minutes) {
    return 'Stale · over $minutes min, do not act on it';
  }

  @override
  String get fleetFreshnessFresh => 'Fresh';

  @override
  String get fleetFreshnessAgeing => 'Ageing';

  @override
  String get fleetFreshnessStale => 'Stale';

  @override
  String get fleetStaleWarning =>
      'Some couriers have not reported recently — check before dispatching';

  @override
  String get fleetAgeJustNow => 'just now';

  @override
  String fleetAgeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String fleetAgeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hr ago',
      one: '1 hr ago',
    );
    return '$_temp0';
  }

  @override
  String fleetAgeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get fleetAgeUnknown => 'no timestamp';

  @override
  String get fleetAgeShortNow => 'now';

  @override
  String fleetAgeShortMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String fleetAgeShortHours(int hours) {
    return '${hours}h';
  }

  @override
  String fleetAgeShortDays(int days) {
    return '${days}d';
  }

  @override
  String get fleetBranchLabel => 'Branch';

  @override
  String get fleetBranchUnknown => 'No branch';

  @override
  String get fleetLastFixLabel => 'Last fix';

  @override
  String get fleetAccuracyLabel => 'Accuracy';

  @override
  String fleetAccuracyValue(String meters) {
    return '±$meters m';
  }

  @override
  String get fleetAccuracyUnknown => 'Not reported';

  @override
  String get fleetEmptyNoCouriersTitle => 'No couriers on shift';

  @override
  String get fleetEmptyNoCouriersBody =>
      'Nobody is signed on to the courier app right now, so there is nothing to track. Positions appear here as soon as a courier starts their shift.';

  @override
  String get fleetEmptyNoPositionsTitle => 'On shift, but no position yet';

  @override
  String get fleetEmptyNoPositionsBody =>
      'These couriers are signed on, but their phones have not sent a location. Check that the courier app has location permission and a signal.';

  @override
  String fleetEmptyNoPositionsNames(String names) {
    return 'Waiting on: $names';
  }

  @override
  String fleetUnlocatedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count couriers on shift have sent no position',
      one: '1 courier on shift has sent no position',
    );
    return '$_temp0';
  }

  @override
  String get fleetForbiddenTitle => 'Supervisors only';

  @override
  String get fleetForbiddenBody =>
      'Live courier positions are limited to managers and supervisors. Retrying will not help — ask a manager to open this screen.';

  @override
  String get fleetErrorTitle => 'Could not load courier positions';

  @override
  String get labelsTitle => 'Customer Labels';

  @override
  String get labelsHelpTooltip => 'How this works';

  @override
  String get labelsRefreshTooltip => 'Refresh';

  @override
  String get labelsSetUpCustomer => 'Set up customer';

  @override
  String get labelsSetupNothingNew => 'Nothing new to track';

  @override
  String labelsSetupTrackingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Now tracking $count flavours',
      one: 'Now tracking 1 flavour',
    );
    return '$_temp0';
  }

  @override
  String labelsSetupSkippedSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' ($count already tracked)',
      one: ' (1 already tracked)',
    );
    return '$_temp0';
  }

  @override
  String labelsPrintOrderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets sent to the printer',
      one: '1 sheet sent to the printer',
    );
    return '$_temp0';
  }

  @override
  String labelsPrintOrderDueBack(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets ordered — due back $date',
      one: '1 sheet ordered — due back $date',
    );
    return '$_temp0';
  }

  @override
  String get labelsHelpTitle => 'How label tracking works';

  @override
  String get labelsHelpRows =>
      'Every flavour has its own label design, so each is tracked on its own row. Labels come off stock automatically when an invoice is submitted for a customer whose labels we print. Customers who bring their own are marked \"Customer prints\" and are never counted.';

  @override
  String labelsHelpSheets(Object medium, Object large) {
    return 'Printing is ordered in sheets — $medium Medium or $large Large labels per sheet.';
  }

  @override
  String labelsHelpLeadTime(
    Object min,
    Object max,
    String restDay,
    Object buffer,
  ) {
    return 'Printing takes $min–$max working days with $restDay excluded, so a label is flagged \"Print now\" once its remaining stock would not survive that wait — and \"Print soon\" $buffer days before that point.';
  }

  @override
  String get labelsHelpQuiet =>
      'Once a batch is at the printer the label goes quiet and shows its due-back date instead, so the same shortage is not raised every morning.';

  @override
  String get labelsHelpAlertsOff =>
      'Daily alerts are currently switched off in Jarz POS Settings.';

  @override
  String get labelsHelpGotIt => 'Got it';

  @override
  String labelsSummaryUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels must go to the printer now',
      one: '1 label must go to the printer now',
    );
    return '$_temp0';
  }

  @override
  String labelsSummarySoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels to print soon',
      one: '1 label to print soon',
    );
    return '$_temp0';
  }

  @override
  String get labelsSummaryNothing => 'Nothing needs printing';

  @override
  String labelsSummaryLeadTime(Object min, Object max, String restDay) {
    return 'Printing takes $min–$max working days · $restDay excluded';
  }

  @override
  String labelsSummaryReadySuffix(String date) {
    return ' · order today, ready $date';
  }

  @override
  String get labelsFilterNeedsPrinting => 'Needs printing';

  @override
  String get labelsFilterAll => 'All';

  @override
  String get labelsFilterAtPrinter => 'At printer';

  @override
  String get labelsFilterCustomerPrints => 'Customer prints';

  @override
  String labelsFilterWithCount(String text, int count) {
    return '$text ($count)';
  }

  @override
  String get labelsAllLocations => 'All locations';

  @override
  String get labelsSearchHint => 'Search customer or flavour';

  @override
  String get labelsEmptyNoneTitle => 'No labels tracked yet';

  @override
  String get labelsEmptyNoneBody =>
      'Set up the B2B customers whose jar labels JARZ prints — one label per flavour. Stock then comes down on its own as their orders are invoiced.';

  @override
  String get labelsEmptyEnoughCover => 'Every label has enough cover';

  @override
  String get labelsEmptyNoMatch => 'Nothing matches this filter';

  @override
  String get labelsShowAll => 'Show all labels';

  @override
  String get labelStatusOutOfStock => 'Out of stock';

  @override
  String get labelStatusOutOfStockWhy =>
      'No labels left. This customer cannot be packed.';

  @override
  String get labelStatusPrintNow => 'Print now';

  @override
  String labelStatusPrintNowWhy(int days) {
    return 'Stock runs out before a new batch could arrive ($days working days).';
  }

  @override
  String get labelStatusPrintSoon => 'Print soon';

  @override
  String get labelStatusPrintSoonWhy =>
      'Getting close to the point of no return.';

  @override
  String get labelStatusAtPrinter => 'At the printer';

  @override
  String get labelStatusAtPrinterWhy => 'A batch is already on its way.';

  @override
  String get labelStatusOk => 'OK';

  @override
  String get labelStatusOkWhy => 'Comfortable cover.';

  @override
  String get labelStatusCustomerPrints => 'Customer prints';

  @override
  String get labelStatusCustomerPrintsWhy =>
      'This customer supplies their own labels, so nothing is counted.';

  @override
  String get labelStatusUnknown => 'Unknown';

  @override
  String labelCardFlavours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flavours',
      one: '1 flavour',
    );
    return '$_temp0';
  }

  @override
  String labelCardNeedPrintingSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count need printing',
      one: ' · 1 needs printing',
    );
    return '$_temp0';
  }

  @override
  String get labelCardCustomerActions => 'Customer actions';

  @override
  String get labelCardAddFlavour => 'Add flavour';

  @override
  String get labelCardOnHand => 'on hand';

  @override
  String get labelCardOfCover => 'of cover';

  @override
  String labelCardOrderSheets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Order $count sheets',
      one: 'Order 1 sheet',
    );
    return '$_temp0';
  }

  @override
  String get labelCardOrderBatch => 'Order a batch';

  @override
  String get labelCardCoverOver99 => '99+ d';

  @override
  String labelCardCoverDays(String days) {
    return '$days d';
  }

  @override
  String get labelCardCoverNone => '—';

  @override
  String get labelCardCustomerSupplies => 'Customer supplies their own labels';

  @override
  String labelCardSheetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets',
      one: '1 sheet',
    );
    return '$_temp0';
  }

  @override
  String labelCardLabelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels',
      one: '1 label',
    );
    return '$_temp0';
  }

  @override
  String labelCardAtPrinter(String what) {
    return '$what at the printer';
  }

  @override
  String labelCardOverdueSince(String what, String date) {
    return '$what overdue at the printer since $date';
  }

  @override
  String labelCardDueBack(String what, String date) {
    return '$what due back $date';
  }

  @override
  String labelCardRunsOutAround(String date) {
    return 'Runs out around $date';
  }

  @override
  String get labelCardNoUsage => 'No usage recorded yet';

  @override
  String labelCardOrderAhead(int days) {
    return 'Order $days working days ahead';
  }

  @override
  String get labelPrintStatusRequested => 'Requested';

  @override
  String get labelPrintStatusPrinting => 'Printing';

  @override
  String get labelPrintStatusReady => 'Ready';

  @override
  String get labelPrintStatusReceived => 'Received';

  @override
  String get labelPrintStatusCancelled => 'Cancelled';

  @override
  String get labelMovementConsumed => 'Used on jars';

  @override
  String get labelMovementPrintReceived => 'Received from the printer';

  @override
  String get labelMovementScrapped => 'Damaged or thrown away';

  @override
  String get labelMovementAdjustment => 'Correction (+/-)';

  @override
  String get labelDetailFallbackTitle => 'Label';

  @override
  String get labelDetailSettingsTooltip => 'Label settings';

  @override
  String labelDetailLoadFailed(String error) {
    return 'Could not load this label.\n$error';
  }

  @override
  String labelDetailSentToPrinter(String what) {
    return '$what sent to the printer';
  }

  @override
  String get labelDetailCountSaved => 'Count saved';

  @override
  String get labelDetailMovementRecorded => 'Movement recorded';

  @override
  String labelDetailReceivedAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels added to stock',
      one: '1 label added to stock',
    );
    return '$_temp0';
  }

  @override
  String labelDetailBatchMarked(String status) {
    return 'Batch marked $status';
  }

  @override
  String get labelDetailBillRecorded =>
      'Bill recorded — purchase invoice created';

  @override
  String get labelDetailSettingsSaved => 'Settings saved';

  @override
  String labelDetailStoredAt(String location) {
    return 'Stored at $location';
  }

  @override
  String get labelDetailLabelsOnHand => 'labels on hand';

  @override
  String get labelDetailDaysOfCover => 'Days of cover';

  @override
  String get labelDetailUnknownValue => 'unknown';

  @override
  String get labelDetailUsedPerDay => 'Used per day';

  @override
  String get labelDetailRunsOut => 'Runs out';

  @override
  String labelDetailUsedInDays(int days) {
    return 'Used in ${days}d';
  }

  @override
  String get labelDetailStockValue => 'Stock value';

  @override
  String get labelDetailAvgCost => 'Avg cost/label';

  @override
  String get labelDetailRetired =>
      'This label is retired. Turn it back on in label settings to resume counting.';

  @override
  String get labelDetailCustomerSupplies =>
      'This customer supplies their own labels, so nothing is counted and no alerts are raised. Turn on \"We print this label\" in settings if that changes.';

  @override
  String get labelDetailActionOrder => 'Order';

  @override
  String get labelDetailActionCount => 'Count';

  @override
  String get labelDetailActionRecord => 'Record';

  @override
  String get labelDetailSectionBatches => 'Print batches';

  @override
  String labelDetailOrderedOn(String date) {
    return 'ordered $date';
  }

  @override
  String labelDetailOverdueSince(String date) {
    return 'overdue since $date';
  }

  @override
  String labelDetailDueOn(String date) {
    return 'due $date';
  }

  @override
  String labelDetailReceivedOn(String date) {
    return 'received $date';
  }

  @override
  String labelDetailReceivedOnQty(String date, int qty) {
    return 'received $date ($qty)';
  }

  @override
  String get labelDetailReceiveIntoStock => 'Receive into stock';

  @override
  String get labelDetailMarkPrinting => 'Mark printing';

  @override
  String get labelDetailMarkReady => 'Mark ready';

  @override
  String get labelDetailRecordBill => 'Record the printer\'s bill';

  @override
  String get labelDetailCancelBatch => 'Cancel batch';

  @override
  String get labelDetailBilled => 'Billed';

  @override
  String labelDetailBilledWithInvoice(String invoice) {
    return 'Billed · $invoice';
  }

  @override
  String get labelDetailUnbilled => 'Unbilled';

  @override
  String labelDetailUnbilledQuoted(String amount) {
    return 'Unbilled · quoted $amount';
  }

  @override
  String get labelDetailPolicyFlavour => 'Flavour';

  @override
  String get labelDetailPolicySize => 'Size';

  @override
  String get labelDetailPolicyStoredAt => 'Stored at';

  @override
  String get labelDetailPolicyNotSet => 'Not set';

  @override
  String get labelDetailPolicyMinStock => 'Minimum stock';

  @override
  String get labelDetailPolicyUsualBatch => 'Usual print batch';

  @override
  String get labelDetailPolicyLabelsPerSheet => 'Labels per sheet';

  @override
  String get labelDetailPolicyLabelsPerJar => 'Labels per jar';

  @override
  String get labelDetailPolicyLeadTime => 'Print lead time';

  @override
  String labelDetailPolicyLeadTimeValue(
    Object min,
    Object max,
    String restDay,
  ) {
    return '$min–$max working days ($restDay excluded)';
  }

  @override
  String get labelDetailPolicyLastCounted => 'Last counted';

  @override
  String get labelDetailPolicyLastMovement => 'Last movement';

  @override
  String get labelDetailSectionSetup => 'Setup';

  @override
  String get labelDetailSectionHistory => 'History';

  @override
  String get labelDetailHistoryEmpty =>
      'Nothing recorded yet. Labels come off automatically as this customer\'s orders are invoiced.';

  @override
  String get labelDetailAutoPosted => 'Posted automatically from the invoice';

  @override
  String get labelSheetSupplierOptional => 'Print supplier (optional)';

  @override
  String get labelSheetPrintSupplier => 'Print supplier';

  @override
  String get labelSheetCountTitle => 'Count labels';

  @override
  String get labelSheetCountSubtitle =>
      'Enter what is physically on the shelf. The difference is posted to the ledger, so a label that keeps going missing shows up as a run of corrections rather than vanishing quietly.';

  @override
  String get labelSheetCountedQty => 'Counted quantity';

  @override
  String labelSheetSystemShows(int qty) {
    return 'System currently shows $qty.';
  }

  @override
  String labelSheetDeltaMore(int count) {
    return '$count more than recorded';
  }

  @override
  String labelSheetDeltaFewer(int count) {
    return '$count fewer than recorded';
  }

  @override
  String get labelSheetNoteOptional => 'Note (optional)';

  @override
  String get labelSheetNotesOptional => 'Notes (optional)';

  @override
  String get labelSheetSaveCount => 'Save count';

  @override
  String get labelSheetOrderTitle => 'Order a print batch';

  @override
  String labelSheetLeadPlain(Object min, Object max, String restDay) {
    return 'Printing takes $min–$max working days ($restDay excluded).';
  }

  @override
  String labelSheetLeadReady(
    String date,
    Object min,
    Object max,
    String restDay,
  ) {
    return 'Ordered today, ready around $date — $min–$max working days, $restDay excluded.';
  }

  @override
  String get labelSheetSheetsToPrint => 'Sheets to print';

  @override
  String labelSheetSuggestedSheets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Suggested $count sheets, based on current usage and the usual batch.',
      one: 'Suggested 1 sheet, based on current usage and the usual batch.',
    );
    return '$_temp0';
  }

  @override
  String labelSheetSheetsEquals(String sheets, String labels) {
    return '$sheets = $labels';
  }

  @override
  String get labelSheetNetCostOptional => 'Net cost (optional)';

  @override
  String get labelSheetNetCostQuoteHelper =>
      'What the printer quoted for the batch, before VAT. The bill itself is recorded when it arrives.';

  @override
  String get labelSheetSendToPrinter => 'Send to printer';

  @override
  String get labelSheetReceiveTitle => 'Receive batch';

  @override
  String labelSheetReceiveSubtitle(String name, String ordered) {
    return '$name · ordered $ordered';
  }

  @override
  String get labelSheetLabelsReceived => 'Labels received';

  @override
  String get labelSheetReceivedHelper =>
      'Adjust if the printer delivered short. Only this many are added to stock.';

  @override
  String get labelSheetAddToStock => 'Add to stock';

  @override
  String get labelSheetBillTitle => 'Record the printer\'s bill';

  @override
  String labelSheetBillSubtitle(String name, String ordered) {
    return '$name · $ordered. This books a supplier purchase invoice, so the batch lands on the books at its real cost.';
  }

  @override
  String get labelSheetNetCost => 'Net cost';

  @override
  String get labelSheetNetCostBillHelper =>
      'What the printer charged for this batch, before VAT.';

  @override
  String get labelSheetBillNoOptional => 'Supplier\'s bill no. (optional)';

  @override
  String get labelSheetRecordBill => 'Record bill';

  @override
  String get labelSheetMovementTitle => 'Record a movement';

  @override
  String get labelSheetWhatHappened => 'What happened';

  @override
  String get labelSheetQuantity => 'Quantity';

  @override
  String get labelSheetAdjustmentHelper => 'Use a minus sign to reduce stock.';

  @override
  String get labelSheetQtyHelper =>
      'Enter a plain number — the direction follows from the type.';

  @override
  String get labelSheetLabelName => 'Label name';

  @override
  String get labelSheetWePrint => 'We print this label';

  @override
  String get labelSheetWePrintHelp =>
      'Off means the customer supplies their own — stops all counting and alerting without losing the history.';

  @override
  String get labelSheetActive => 'Active';

  @override
  String get labelSheetActiveHelp =>
      'Turn off to retire a design that is no longer used.';

  @override
  String get labelSheetStoredAtHelper =>
      'The branch or factory where this label physically lives.';

  @override
  String get labelSheetUsualBatchSheets => 'Usual batch (sheets)';

  @override
  String get labelSheetLabelsPerSheetHelper =>
      'Leave 0 for the size default: 21 Medium, 18 Large.';

  @override
  String get labelSheetLabelsPerJarHelper => 'Usually 1.';

  @override
  String get labelWizardTitle => 'Set up customer labels';

  @override
  String get labelWizardStartTracking => 'Start tracking';

  @override
  String get labelWizardContinue => 'Continue';

  @override
  String get labelWizardBack => 'Back';

  @override
  String get labelWizardStepCustomer => 'Customer';

  @override
  String get labelWizardStepFlavours => 'Flavours';

  @override
  String labelWizardPickedCount(int count) {
    return '$count picked';
  }

  @override
  String get labelWizardStepLocation => 'Where the labels live';

  @override
  String get labelWizardStepConfirm => 'Confirm';

  @override
  String get labelWizardChange => 'Change';

  @override
  String labelWizardCustomerPriceList(String customer, String priceList) {
    return '$customer · price list: $priceList';
  }

  @override
  String get labelWizardSearchCustomers => 'Search customers';

  @override
  String get labelWizardSearching => 'Searching…';

  @override
  String get labelWizardNoCustomers => 'No company customers matched.';

  @override
  String labelWizardPriceList(String priceList) {
    return 'Price list: $priceList';
  }

  @override
  String labelWizardFlavoursLoadFailed(String error) {
    return 'Could not load flavours.\n$error';
  }

  @override
  String get labelWizardPickCustomerFirst => 'Pick a customer first.';

  @override
  String get labelWizardNoFlavours =>
      'No flavours found for this customer — nothing on their price list and no order history yet.';

  @override
  String get labelWizardSizeOther => 'Other';

  @override
  String get labelWizardFlavourHelp =>
      'Tick every flavour whose label JARZ prints. Enter what is already on the shelf so nothing starts life as Out of Stock.';

  @override
  String get labelWizardAlreadyTracked => 'Already tracked';

  @override
  String get labelWizardOnPriceList => 'On price list';

  @override
  String get labelWizardOrderedBefore => 'Ordered before';

  @override
  String get labelWizardLabelsInStock => 'Labels in stock now';

  @override
  String get labelWizardLocationsLoadFailed =>
      'Could not load locations — you can set one per label later.';

  @override
  String get labelWizardStoredAtHelper =>
      'The branch or factory where these labels physically live.';

  @override
  String get labelWizardUsualBatchSheets => 'Usual print batch (sheets)';

  @override
  String get labelWizardUsualBatchHelper =>
      'Applied to every flavour; changeable per label later.';

  @override
  String get labelWizardConfirmPriceList => 'Price list';

  @override
  String get labelWizardConfirmUsualBatch => 'Usual batch';

  @override
  String get labelWizardSafeToRerun =>
      'Flavours already tracked are left untouched — running this again is always safe.';

  @override
  String get b2bStageLead => 'Lead';

  @override
  String get b2bStageQualify => 'Qualify';

  @override
  String get b2bStageSample => 'Sample';

  @override
  String get b2bStageApproved => 'Approved';

  @override
  String get b2bStageTrial => 'Trial';

  @override
  String get b2bStageCheckup => 'Check-up';

  @override
  String get b2bStageActive => 'Active';

  @override
  String get b2bStageLostOnHold => 'Lost/On-hold';

  @override
  String get leadsTitle => 'Leads';

  @override
  String get leadsMapTitle => 'Leads map';

  @override
  String get leadsMapViewTooltip => 'Map view';

  @override
  String get leadsListViewTooltip => 'List view';

  @override
  String get leadsRefreshTooltip => 'Refresh';

  @override
  String get leadsAddLead => 'Add lead';

  @override
  String get leadsStatShowing => 'Showing';

  @override
  String get leadsStatTierA => 'Tier A';

  @override
  String get leadsStatBranches => 'Branches';

  @override
  String get leadsSearchHint => 'Search leads…';

  @override
  String get leadsAdvancedFilters => 'Advanced filters';

  @override
  String get leadsEmptyFiltered => 'No leads match these filters';

  @override
  String leadsDistanceMetres(String value) {
    return '$value m';
  }

  @override
  String leadsDistanceKm(String value) {
    return '$value km';
  }

  @override
  String get leadsLocationServicesOff =>
      'Location services are off. Turn them on in your device settings.';

  @override
  String get leadsLocationBlocked =>
      'Location permission is blocked for this app.';

  @override
  String get leadsLocationDenied => 'Location permission was declined.';

  @override
  String get leadsLocationNoFix =>
      'Could not get a location fix. Try again outdoors.';

  @override
  String get leadsLocationSettings => 'Settings';

  @override
  String leadsOnMapCount(int count) {
    return '$count on map';
  }

  @override
  String leadsOnMapWithStages(int count, String stages) {
    return '$count on map  ·  $stages';
  }

  @override
  String leadsStageSummaryCount(int count) {
    return '$count stages';
  }

  @override
  String get leadsHideLegend => 'Hide legend';

  @override
  String get leadsCategoryLegend => 'Category legend';

  @override
  String get leadsShowMyLocation => 'Show my location';

  @override
  String leadsBranchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '1 branch',
    );
    return '$_temp0';
  }

  @override
  String leadsDistanceAway(String distance) {
    return '$distance away (straight line)';
  }

  @override
  String leadsFilterActiveCount(int count) {
    return '$count active';
  }

  @override
  String get leadsFilterPipelineStage => 'Pipeline stage';

  @override
  String get leadsFilterRatingRange => 'Rating range';

  @override
  String leadsFilterMinReviews(int count) {
    return 'Minimum reviews: $count';
  }

  @override
  String get leadsFilterMinBranches => 'Minimum branch count';

  @override
  String get leadsFilterHasSahel => 'Has Sahel branches';

  @override
  String get leadsFilterSpecialtyOnly => 'Specialty only';

  @override
  String get leadsFilterTakeawayOnly => 'Takeaway confirmed';

  @override
  String get leadsFilterTalabat => 'Talabat';

  @override
  String get leadsFilterTalabatOn => 'On Talabat';

  @override
  String get leadsFilterTalabatOff => 'Not on Talabat';

  @override
  String get leadsTalabatBadge => 'Talabat';

  @override
  String get leadsTalabatRatingFromGoogle =>
      'Rating shown is from Google — no Talabat rating yet';

  @override
  String get leadsTalabatUnrated => 'Listed on Talabat, not yet rated';

  @override
  String get leadsFilterHasPhone => 'Has phone';

  @override
  String get leadsFilterHasInstagram => 'Has Instagram';

  @override
  String get leadsFilterHasWebsite => 'Has website';

  @override
  String get leadsFilterShowNotSuitable => 'Show not suitable';

  @override
  String get leadsFilterPriceBand => 'Price band';

  @override
  String get leadsFilterClearAll => 'Clear all';

  @override
  String leadsAreaClearCount(int count) {
    return 'Clear ($count)';
  }

  @override
  String get leadsAreaSearchHint => 'Search areas';

  @override
  String leadsAreaNoMatch(String query) {
    return 'No area matches \"$query\"';
  }

  @override
  String get leadsAreaAll => 'All areas';

  @override
  String leadsAreaSelectedCount(int count) {
    return '$count areas';
  }

  @override
  String leadsMergeConfirmTitle(int count, String survivor) {
    return 'Merge $count into \"$survivor\"?';
  }

  @override
  String leadsMergeConfirmBody(String survivor) {
    return 'Their branches, areas and any details \"$survivor\" is missing move onto it. The merged leads stay on file for audit but leave the catalog and the pipeline board.';
  }

  @override
  String leadsMergeFailed(String error) {
    return 'Merge failed: $error';
  }

  @override
  String get leadsMergeTitle => 'Merge duplicates';

  @override
  String leadsMergeSubtitle(String name) {
    return 'Fold other records of the same brand into \"$name\".';
  }

  @override
  String get leadsMergeSearchHint =>
      'Search by name, or leave blank for suggestions';

  @override
  String leadsMergeAction(int count) {
    return 'Merge $count';
  }

  @override
  String get leadsMergeNoDuplicates =>
      'No likely duplicates found. Search by name if you know of one.';

  @override
  String get leadsMergeNoMatch => 'No leads match that search.';

  @override
  String get leadsMergedSuccess => 'Leads merged';

  @override
  String get leadsAllStages => 'All stages';

  @override
  String get leadsFilterTitle => 'Filters';

  @override
  String get leadsFilterAreas => 'Areas';

  @override
  String get leadsFilterAny => 'Any';

  @override
  String get leadsFilterAll => 'All';

  @override
  String get leadsFilterDone => 'Done';

  @override
  String get leadDetailTitle => 'Lead';

  @override
  String leadDetailBranchesCount(int count) {
    return 'Branches ($count)';
  }

  @override
  String get leadDetailStatusNotes => 'Status & notes';

  @override
  String get leadDetailStatusField => 'Status';

  @override
  String get leadDetailCategoryField => 'Category';

  @override
  String get leadDetailCategoryNone => 'None';

  @override
  String get leadDetailUpdated => 'Lead updated';

  @override
  String leadDetailFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get leadDetailFitScoreUpdated => 'Fit score updated';

  @override
  String leadDetailScoreOutOf(int score) {
    return '$score / 100';
  }

  @override
  String leadDetailStageUpdated(String stage) {
    return 'Stage updated to $stage';
  }

  @override
  String get leadDetailReasonTitle => 'Reason';

  @override
  String get leadDetailReasonHint => 'Why is this lost / on hold?';

  @override
  String get leadDetailNotSuitable => 'Not suitable';

  @override
  String leadDetailByWhom(String user) {
    return 'by $user';
  }

  @override
  String leadDetailOnDate(String date) {
    return 'on $date';
  }

  @override
  String get leadDetailMarkedNotSuitable => 'Marked not suitable';

  @override
  String get leadDetailRestoreTitle => 'Restore lead?';

  @override
  String get leadDetailRestoreBody =>
      'This clears the not-suitable verdict and puts the lead back in the catalog at the Lead stage.';

  @override
  String get leadDetailRestore => 'Restore';

  @override
  String get leadDetailRestored => 'Lead restored';

  @override
  String get leadDetailSuitability => 'Suitability';

  @override
  String get leadDetailSuitabilityMarked =>
      'This prospect was judged not suitable after manual inspection. It is hidden from the catalog and off the pipeline board.';

  @override
  String get leadDetailSuitabilityPrompt =>
      'Inspected this prospect and it is not worth pursuing? Mark it not suitable to take it out of the working catalog.';

  @override
  String get leadDetailRestoreLead => 'Restore lead';

  @override
  String get leadDetailMarkNotSuitable => 'Mark not suitable';

  @override
  String get leadDetailNotesOptional => 'Notes (optional)';

  @override
  String get leadDetailInspectionHint => 'What did the inspection show?';

  @override
  String get leadDetailMergedAway => 'Merged into another lead';

  @override
  String get leadDetailOpenSurvivor => 'Open the surviving lead';

  @override
  String get leadDetailDuplicates => 'Duplicates';

  @override
  String get leadDetailDuplicatesBody =>
      'The catalog was built per location, so one brand can appear as several leads. Merge them here to keep every branch on one record.';

  @override
  String get leadDetailAddresses => 'Addresses';

  @override
  String get leadDetailPrimaryAddress => 'Primary address';

  @override
  String get leadDetailShippingAddress => 'Shipping address';

  @override
  String leadDetailAddressSaved(String title) {
    return '$title saved';
  }

  @override
  String leadDetailSaveAddress(String title) {
    return 'Save $title';
  }

  @override
  String get leadFieldAddressLine1 => 'Address line 1';

  @override
  String get leadFieldAddressLine2 => 'Address line 2';

  @override
  String get leadFieldCity => 'City';

  @override
  String get leadFieldState => 'State';

  @override
  String get leadFieldCountry => 'Country';

  @override
  String get leadFieldPincode => 'Pincode';

  @override
  String get leadFieldPhone => 'Phone';

  @override
  String get leadFormEditTitle => 'Edit lead';

  @override
  String get leadFormSaved => 'Lead saved';

  @override
  String get leadFormNewCategory => 'New category';

  @override
  String get leadFormCategoryName => 'Category name';

  @override
  String get leadFormAddCategory => 'Add category';

  @override
  String get leadFormLeadName => 'Lead name *';

  @override
  String get leadFormCompanyName => 'Company name';

  @override
  String get leadFormPrimaryArea => 'Primary area';

  @override
  String get leadFormPriceBand => 'Price band';

  @override
  String leadFormFitScoreRange(String label) {
    return '$label (0–100)';
  }

  @override
  String get leadFormSaveChanges => 'Save changes';

  @override
  String get leadFormCreate => 'Create lead';

  @override
  String get leadFormCardBrand => 'Brand';

  @override
  String get leadFormCardClassification => 'Classification';

  @override
  String get leadFormCardContact => 'Contact';

  @override
  String get leadFormTier => 'Tier';

  @override
  String get leadFormSpecialty => 'Specialty';

  @override
  String get leadFieldMobile => 'Mobile';

  @override
  String get leadFieldWebsite => 'Website';

  @override
  String get leadFieldInstagram => 'Instagram';

  @override
  String get leadFieldFacebook => 'Facebook';

  @override
  String get leadFormRequired => 'Required';

  @override
  String get leadFormScoreRangeError => '0–100';

  @override
  String get leadFormCategoryLabel => 'Category';

  @override
  String get leadsSortTooltip => 'Sort';

  @override
  String get leadsSortScore => 'Score';

  @override
  String get leadsSortRating => 'Rating';

  @override
  String get leadsSortReviews => 'Reviews';

  @override
  String get leadsSortBranches => 'Branches';

  @override
  String get leadsSortName => 'Name';

  @override
  String get leadsSortNearest => 'Nearest';

  @override
  String get leadsMapCategories => 'Categories';

  @override
  String get leadActionCall => 'Call';

  @override
  String get leadActionInstagram => 'Instagram';

  @override
  String get leadActionWebsite => 'Website';

  @override
  String get leadActionMap => 'Map';

  @override
  String get leadsMergeConfirmAction => 'Merge';

  @override
  String get b2bAccountTitle => 'Account';

  @override
  String b2bAccountLoadFailed(String error) {
    return 'Failed to load account.\n$error';
  }

  @override
  String b2bFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get b2bLogCall => 'Log call';

  @override
  String get b2bLogCallHint => 'What was discussed?';

  @override
  String get b2bActivityLogged => 'Activity logged';

  @override
  String b2bLogActivityFailed(String error) {
    return 'Failed to log activity: $error';
  }

  @override
  String get b2bMarkLostTitle => 'Mark lost / on-hold';

  @override
  String get b2bReasonHint => 'Reason';

  @override
  String get b2bMarkedLost => 'Marked Lost/On-hold';

  @override
  String get b2bCreateCustomerTitle => 'Create customer for lead';

  @override
  String get b2bCustomerName => 'Customer name';

  @override
  String get b2bAddress => 'Address';

  @override
  String get b2bContinue => 'Continue';

  @override
  String get b2bLoadingTerritories => 'Loading territories…';

  @override
  String get b2bTerritoriesFailed => 'Failed to load territories';

  @override
  String get b2bOpenLeadPage => 'Open lead page';

  @override
  String get b2bSectionContact => 'Contact';

  @override
  String get b2bSectionInsights => 'Insights';

  @override
  String get b2bSectionRecentInvoices => 'Recent invoices';

  @override
  String get b2bSectionOpenTodos => 'Open to-dos';

  @override
  String get b2bNone => 'None';

  @override
  String get b2bPredictedNextOrder => 'Predicted next order';

  @override
  String get b2bAvgOrderCycle => 'Avg order cycle';

  @override
  String b2bDaysValue(String days) {
    return '$days days';
  }

  @override
  String get b2bSendSample => 'Send sample';

  @override
  String get b2bPlaceOrder => 'Place order';

  @override
  String get b2bMarkLost => 'Mark lost';

  @override
  String get b2bViewPricing => 'View pricing';

  @override
  String get b2bLabelsSection => 'Labels';

  @override
  String b2bLabelsNeedPrinting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need printing',
      one: '1 needs printing',
    );
    return '$_temp0';
  }

  @override
  String get b2bNoLabelsTracked => 'No labels tracked for this customer yet.';

  @override
  String get b2bSetUpLabels => 'Set up labels';

  @override
  String get b2bLoadingLeadProfile => 'Loading lead profile…';

  @override
  String get b2bLeadProfile => 'Lead profile';

  @override
  String b2bMoreBranches(int count) {
    return '+ $count more';
  }

  @override
  String get b2bPipelineTitle => 'B2B Pipeline';

  @override
  String get b2bMyFollowUps => 'My follow-ups';

  @override
  String get b2bRefresh => 'Refresh';

  @override
  String get b2bSwitchMode => 'Switch mode';

  @override
  String get b2bGoToPos => 'Go to POS (B2C)';

  @override
  String get b2bGoToKanban => 'Go to Dispatch Kanban';

  @override
  String get b2bNewLead => 'New lead';

  @override
  String b2bMovedToStage(String title, String stage) {
    return 'Moved \"$title\" to $stage';
  }

  @override
  String b2bAdvanceStageFailed(String error) {
    return 'Failed to advance stage: $error';
  }

  @override
  String get b2bFollowUpReminder => 'Follow-up reminder';

  @override
  String b2bFollowUpPrompt(String stage) {
    return 'When should you follow up after moving to \"$stage\"?';
  }

  @override
  String get b2bSkip => 'Skip';

  @override
  String get b2bSetReminder => 'Set reminder';

  @override
  String get b2bLostReasonHint => 'Why is this lost / on hold?';

  @override
  String b2bPipelineLoadFailed(String error) {
    return 'Could not load the pipeline.\n$error';
  }

  @override
  String get b2bTodayTitle => 'Today';

  @override
  String b2bTodayLoadFailed(String error) {
    return 'Failed to load follow-ups.\n$error';
  }

  @override
  String get b2bNoFollowUpsToday => 'No follow-ups today';

  @override
  String get b2bNoReordersDue => 'No reorders due';

  @override
  String get b2bFollowUpDone => 'Follow-up marked done';

  @override
  String b2bFollowUpFailed(String error) {
    return 'Could not complete follow-up: $error';
  }

  @override
  String get b2bDone => 'Done';

  @override
  String b2bOverdueSuffix(String date) {
    return '$date · overdue';
  }

  @override
  String b2bAvgBasket(String amount) {
    return 'Avg: $amount';
  }

  @override
  String b2bScoreLabel(int score) {
    return 'Score $score';
  }

  @override
  String get b2bNoAccounts => 'No accounts';

  @override
  String b2bLabelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels',
      one: '1 label',
    );
    return '$_temp0';
  }

  @override
  String b2bLastOrder(String date) {
    return 'Last: $date';
  }

  @override
  String b2bNextOrder(String date) {
    return 'Next: $date';
  }

  @override
  String get b2bCardLead => 'Lead';

  @override
  String get b2bCardOpportunity => 'Opportunity';

  @override
  String b2bLabelsNeedPrintingTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels need printing',
      one: '1 label needs printing',
    );
    return '$_temp0';
  }

  @override
  String get pricingTitle => 'Price Lists';

  @override
  String get pricingCustomerLookup => 'Customer pricing lookup';

  @override
  String get pricingRefresh => 'Refresh';

  @override
  String get pricingNewPriceList => 'New price list';

  @override
  String get pricingNoPriceLists => 'No price lists yet.';

  @override
  String get pricingNameField => 'Name';

  @override
  String get pricingCurrencyField => 'Currency';

  @override
  String get pricingCreate => 'Create';

  @override
  String pricingCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String pricingCreateFailed(String error) {
    return 'Could not create price list: $error';
  }

  @override
  String get pricingDefaultBadge => 'Default';

  @override
  String pricingLoadFailed(String error) {
    return 'Could not load price lists.\n$error';
  }

  @override
  String pricingDetailLoadFailed(String name, String error) {
    return 'Could not load \"$name\".\n$error';
  }

  @override
  String pricingSetRateTitle(String category) {
    return 'Set $category rate';
  }

  @override
  String pricingRateUpdated(String category) {
    return '$category rate updated';
  }

  @override
  String pricingRateSet(String category) {
    return '$category rate set';
  }

  @override
  String get pricingAllCategoriesHaveRows =>
      'All categories already have a row.';

  @override
  String pricingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String pricingOverrideTitle(String item) {
    return 'Override $item';
  }

  @override
  String get pricingOverrideUpdated => 'Override updated';

  @override
  String get pricingRemoveOverrideTitle => 'Remove override?';

  @override
  String pricingRemoveOverrideBody(String item) {
    return '$item will fall back to its category rate.';
  }

  @override
  String get pricingRemove => 'Remove';

  @override
  String get pricingOverrideRemoved => 'Override removed';

  @override
  String get pricingAddOverride => 'Add override';

  @override
  String get pricingItemCode => 'Item code';

  @override
  String get pricingRateField => 'Rate';

  @override
  String get pricingOverrideAdded => 'Override added';

  @override
  String get pricingUnassignTitle => 'Unassign customer?';

  @override
  String pricingUnassignBody(String customer) {
    return '$customer will revert to their customer group default.';
  }

  @override
  String get pricingUnassign => 'Unassign';

  @override
  String get pricingCustomerUnassigned => 'Customer unassigned';

  @override
  String pricingFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get pricingCategoryPrices => 'Category prices';

  @override
  String get pricingAddCategory => 'Add category';

  @override
  String get pricingNoCategoryRates => 'No category rates set.';

  @override
  String pricingEditRateTooltip(String category) {
    return 'Edit $category rate';
  }

  @override
  String get pricingPerFlavorOverrides => 'Per-flavor overrides';

  @override
  String pricingOverrideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overrides',
      one: '1 override',
    );
    return '$_temp0';
  }

  @override
  String get pricingNoOverrides => 'No per-item overrides.';

  @override
  String get pricingEditOverride => 'Edit override';

  @override
  String get pricingRemoveOverride => 'Remove override';

  @override
  String get pricingAssignedCustomers => 'Assigned customers';

  @override
  String pricingCustomerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers',
      one: '1 customer',
    );
    return '$_temp0';
  }

  @override
  String get pricingNoCustomers => 'No customers use this list.';

  @override
  String pricingViaGroup(String group) {
    return 'via group $group';
  }

  @override
  String get pricingDirectAssignment => 'direct assignment';

  @override
  String get customerPricingTitle => 'Customer pricing';

  @override
  String get customerPricingSearchHint => 'Search company customers…';

  @override
  String customerPricingSearchFailed(String error) {
    return 'Search failed.\n$error';
  }

  @override
  String get customerPricingNoCustomers => 'No customers found.';

  @override
  String customerPricingLoadFailed(String customer, String error) {
    return 'Could not load pricing for \"$customer\".\n$error';
  }

  @override
  String get customerPricingEffective => 'Effective prices';

  @override
  String get customerPricingNoResolved => 'No resolved prices.';

  @override
  String customerPricingSource(String group, String source) {
    return '$group · source: $source';
  }

  @override
  String get pricingNoCategoryRatesShort => 'No category rates set';

  @override
  String pricingCardSummary(String customers, String currency) {
    return '$customers · $currency';
  }

  @override
  String get pricingDisabledSuffix => ' · disabled';

  @override
  String customerPricingGroupLine(
    String group,
    String priceList,
    String assignment,
  ) {
    return 'Group: $group\nPrice list: $priceList ($assignment)';
  }

  @override
  String get pricingNoneValue => '(none)';

  @override
  String get pricingDash => '—';

  @override
  String get journeyToday => 'Today';

  @override
  String get journeyYesterday => 'Yesterday';

  @override
  String get journeyTomorrow => 'Tomorrow';

  @override
  String journeyDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String journeyWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String journeyMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String journeyOverdueByDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue by $count days',
      one: 'Overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String get journeyOverdue => 'Overdue';

  @override
  String journeyInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String journeyInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count months',
      one: 'In 1 month',
    );
    return '$_temp0';
  }

  @override
  String get journeyTypeVisit => 'Visit';

  @override
  String get journeyTypeCall => 'Call';

  @override
  String get journeyTypeWhatsapp => 'WhatsApp';

  @override
  String get journeyTypeSampleDrop => 'Sample Drop';

  @override
  String get journeyTypeMeeting => 'Meeting';

  @override
  String get journeyTypeEmail => 'Email';

  @override
  String get journeyTypeOther => 'Other';

  @override
  String get journeyOutcomeInterested => 'Interested';

  @override
  String get journeyOutcomeNeedsFollowUp => 'Needs Follow-up';

  @override
  String get journeyOutcomeSampleRequested => 'Sample Requested';

  @override
  String get journeyOutcomeOrderPlaced => 'Order Placed';

  @override
  String get journeyOutcomeNotNow => 'Not Now';

  @override
  String get journeyOutcomeRejected => 'Rejected';

  @override
  String get journeyEditorEditTitle => 'Edit journey note';

  @override
  String get journeyEditorNewTitle => 'Log a visit or call';

  @override
  String get journeyEditorSubtitle =>
      'What happened, who you spoke to, and what happens next.';

  @override
  String get journeyEditorDate => 'Date';

  @override
  String get journeyEditorType => 'Type';

  @override
  String get journeyEditorNote => 'Note';

  @override
  String get journeyEditorNoteHint =>
      'They liked the matcha, asked about wholesale pricing…';

  @override
  String get journeyEditorWhoSpoke => 'Who you spoke to';

  @override
  String get journeyEditorWhoHint => 'Tap who you met, or add someone new.';

  @override
  String get journeyEditorNewPerson => 'New person';

  @override
  String journeyEditorContactFailed(String error) {
    return 'Could not save the contact: $error';
  }

  @override
  String get journeyEditorPerson => 'Person';

  @override
  String get journeyEditorPersonHint => 'Mostafa';

  @override
  String get journeyEditorRole => 'Role';

  @override
  String get journeyEditorRoleHint => 'Branch manager';

  @override
  String get journeyEditorTheirPhone => 'Their phone';

  @override
  String get journeyEditorOutcome => 'Outcome';

  @override
  String get journeyEditorNextAction => 'Next action';

  @override
  String get journeyEditorNextActionHelp =>
      'A date here also sets the follow-up reminder on this account.';

  @override
  String get journeyEditorWhatToDo => 'What to do';

  @override
  String get journeyEditorWhatToDoHint =>
      'Call the manager to confirm the trial order';

  @override
  String get journeyEditorWhen => 'When';

  @override
  String get journeyEditorNoReminder => 'No reminder';

  @override
  String get journeyEditorLogIt => 'Log it';

  @override
  String get journeyEditorPickDate => 'Pick a date';

  @override
  String get journeyEditorClear => 'Clear';

  @override
  String get journeySectionTitle => 'Journey';

  @override
  String get journeyLogVisit => 'Log visit';

  @override
  String get journeyNoteAdded => 'Journey note added';

  @override
  String get journeyNoteUpdated => 'Journey note updated';

  @override
  String get journeyNoteDeleted => 'Journey note deleted';

  @override
  String get journeyDeleteTitle => 'Delete this note?';

  @override
  String get journeyDeleteBody =>
      'The visit record is removed for everyone. This cannot be undone.';

  @override
  String journeyFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get journeyEdit => 'Edit';

  @override
  String journeyLoggedBy(String user) {
    return 'Logged by $user';
  }

  @override
  String get journeyEmptyTitle => 'No visits logged yet.';

  @override
  String get journeyEmptyBody =>
      'Log what was said, who said it, and when to follow up — a dated next action also sets this account\'s reminder.';

  @override
  String get journeyLoadFailed => 'Could not load the journey.';

  @override
  String get journeyMarkDone => 'Mark done';

  @override
  String get journeyMarkNotDone => 'Mark as not done';

  @override
  String get journeyDoneLabel => 'Done';

  @override
  String journeyDoneOn(String date) {
    return 'Done $date';
  }

  @override
  String journeyDoneByOn(String date, String user) {
    return 'Done $date · $user';
  }

  @override
  String get journeyActionMarkedDone => 'Next action marked done';

  @override
  String get journeyActionReopened => 'Next action reopened';

  @override
  String get journeyCalendarTitle => 'Action calendar';

  @override
  String get journeyCalendarPreviousMonth => 'Previous month';

  @override
  String get journeyCalendarNextMonth => 'Next month';

  @override
  String get journeyCalendarScopeMine => 'Mine';

  @override
  String get journeyCalendarScopeAll => 'All';

  @override
  String get journeyCalendarShowDone => 'Show done';

  @override
  String journeyCalendarPendingCount(int count) {
    return 'Pending $count';
  }

  @override
  String journeyCalendarOverdueCount(int count) {
    return 'Overdue $count';
  }

  @override
  String journeyCalendarDoneCount(int count) {
    return 'Done $count';
  }

  @override
  String journeyCalendarDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
    );
    return '$_temp0';
  }

  @override
  String get journeyCalendarNothingOnDay => 'Nothing due on this day.';

  @override
  String get journeyCalendarEmptyMonth => 'Nothing due this month.';

  @override
  String get journeyCalendarLoadFailed => 'Could not load the calendar.';

  @override
  String get journeyCalendarSourceFollowup => 'Reminder';

  @override
  String get journeyCalendarNoAction => 'No action written';

  @override
  String get errorConsoleCopyError => 'Copy error';

  @override
  String get errorConsoleCopied => 'Error details copied';

  @override
  String get errorConsoleSummary => 'Summary';

  @override
  String get errorConsoleFatal => 'Fatal';

  @override
  String get errorConsoleYes => 'Yes';

  @override
  String get errorConsoleNo => 'No';

  @override
  String get errorConsoleOccurrences => 'Occurrences';

  @override
  String get errorConsoleDetails => 'Details';

  @override
  String get errorConsoleStackTrace => 'Stack trace';

  @override
  String get menuInstapayReconciliation => 'InstaPay Reconciliation';

  @override
  String get instapayTitle => 'InstaPay Reconciliation';

  @override
  String get instapayNoOrders => 'No orders awaiting InstaPay confirmation';

  @override
  String get instapayCourierRequired =>
      'A courier is required for cash collection';

  @override
  String get instapayConvertedToCod => 'Converted to cash on delivery';

  @override
  String get instapayCollectedCashInstead => 'Collected cash instead';

  @override
  String get instapayConfirmReceived => 'Confirm received';

  @override
  String get instapayPaymentConfirmed => 'Payment confirmed';

  @override
  String get instapayBankReference => 'Bank reference number';

  @override
  String get kanbanMoveAction => 'Move';

  @override
  String get kanbanDeliveryPartnerField => 'Delivery Partner';

  @override
  String get kanbanSetDeliveryIncome => 'Set Delivery Income';

  @override
  String get kanbanDeliveryIncomeField => 'Delivery income';

  @override
  String get kanbanInvalidAmount => 'Enter a valid non-negative amount';

  @override
  String get kanbanUpdatingDeliveryIncome => 'Updating delivery income…';

  @override
  String kanbanErrorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get posShowHeaderTooltip => 'Show header';

  @override
  String get posCartDeliveryAmountField => 'Delivery amount';

  @override
  String get posCartResetToDefault => 'Reset to Default';

  @override
  String get posCartSetAction => 'Set';

  @override
  String get posCartPromoCode => 'Promo code';

  @override
  String get posCartPromoCodeHint => 'e.g. EGY2026';

  @override
  String get reportsColumnSegment => 'Segment';

  @override
  String get reportsColumnRecencyDays => 'Recency (d)';

  @override
  String get reportsColumnFrequency => 'Frequency';

  @override
  String get reportsColumnAov => 'AOV';

  @override
  String get tripsOneBranchOnly =>
      'Select invoices from one branch only to create a trip.';

  @override
  String get webPushOnlyInWebApp =>
      'Web push notifications are only available in the web app.';

  @override
  String get webPushEnabled =>
      'Web push notifications are enabled for this device.';

  @override
  String get webPushDisabledForEnv =>
      'Web push notifications are disabled for this environment.';

  @override
  String get webPushNotConfigured =>
      'Web push notifications are not configured for this environment.';

  @override
  String get webPushUnsupportedPrompt =>
      'This browser does not support notification permission prompts.';

  @override
  String get webPushPermissionRequired =>
      'Tap Enable Notifications to allow web push on this device.';

  @override
  String get webPushPermissionDenied => 'Notification permission was denied.';

  @override
  String get webPushNoToken =>
      'No web push token is available yet. Try again after reopening the app.';

  @override
  String get webPushTokenReady => 'Web push token is ready for registration.';

  @override
  String get webPushEnableFailed =>
      'Failed to enable notifications. Reopen the Home Screen app and try again.';

  @override
  String get b2bCustomerLabelsTooltip => 'Customer labels';

  @override
  String get b2bFollowUpsHeader => 'Follow-ups';

  @override
  String get b2bReorderDueHeader => 'Reorder due';

  @override
  String get expensesEmptyManagerHint =>
      'Create a new expense to capture operational spending.';

  @override
  String get expensesEmptyStaffHint =>
      'Submit a new expense and your manager will review it.';

  @override
  String get expenseSourceCash => 'Cash';

  @override
  String get expenseSourceBank => 'Bank';

  @override
  String get expenseSourceMobileWallet => 'Mobile Wallet';

  @override
  String get expenseSourcePosProfile => 'POS Profile';

  @override
  String get expenseSourceAccount => 'Account';

  @override
  String get instapayConvertFailed => 'Failed to convert order to cash';

  @override
  String get instapayConfirmFailed => 'Failed to confirm payment';

  @override
  String get instapayConfirmSheetTitle => 'Confirm InstaPay received';

  @override
  String get instapayAwaitingBadge => 'Awaiting InstaPay';

  @override
  String get inventoryCountSubmitting => 'Submitting reconciliation';

  @override
  String get inventoryCountSubmitError => 'Submit reconciliation error';

  @override
  String get kanbanExitSelection => 'Exit Selection';

  @override
  String get kanbanSelectOrders => 'Select Orders';

  @override
  String get kanbanMoveOrderTitle => 'Move order';

  @override
  String get kanbanCreateFailedFallback => 'Create failed';

  @override
  String get kanbanDeliveryIncomeHelp =>
      'Enter a custom delivery income for this order. Leave blank to revert to the territory default. This will create an amendment of the order.';

  @override
  String get kanbanCannotAmend => 'This order cannot be amended';

  @override
  String get kanbanDeliveryIncomeReset =>
      'Delivery income reset to territory default';

  @override
  String get kanbanAmendmentFailed => 'Amendment failed';

  @override
  String get kanbanShippingNotUpdated =>
      'shipping cost was not updated. Fix the address territory.';

  @override
  String get leadsNotSuitableBadge => 'Not suitable';

  @override
  String get bundleSelectionTitle => 'Bundle Selection';

  @override
  String get bundleUpdateAction => 'Update Bundle';

  @override
  String get bundleAddToCartAction => 'Add to Cart';

  @override
  String get bundleSelectFromGroups => 'Select items from each group below:';

  @override
  String get bundleCatalogDriftWarning =>
      'Bundle options may have changed since this order was placed. Please review and confirm your selections.';

  @override
  String get bundleNoItemsInGroup => 'No items available in this group';

  @override
  String get bundleUnknownItem => 'Unknown Item';

  @override
  String get bundleUnknownBundle => 'Unknown Bundle';

  @override
  String get bundleNoItemGroups => 'No item groups found';

  @override
  String get bundleNoItemGroupsBody =>
      'This bundle has no available item groups';

  @override
  String get posCartPromoDiscount => 'Promo discount';

  @override
  String get posCartFreeDelivery => 'Free delivery';

  @override
  String get posCartDeliveryAmountHelp =>
      'Enter a custom delivery amount. Leave blank to restore the territory default.';

  @override
  String get posCartBundleLoadFailed =>
      'Bundle contents could not be loaded. Edit this bundle and reselect items before submitting.';

  @override
  String get posCartPromoApplied => 'Applied';

  @override
  String get posCartPromoNotEligible => 'Not eligible';

  @override
  String get posSalesPartnerFallback => 'Sales Partner';

  @override
  String get reportsColumnBomCost => 'BOM Cost';

  @override
  String get reportsColumnTimesInBundle => 'Times in Bundle';

  @override
  String get settingsIosWebPushTitle => 'iPhone web push notifications';

  @override
  String get settingsIosWebPushBody =>
      'Install this app to the iPhone Home Screen, then tap Enable Notifications to receive background alerts.';

  @override
  String get settingsEnablingNotifications => 'Enabling notifications...';

  @override
  String get settingsEnableNotifications => 'Enable Notifications';

  @override
  String get settingsNotificationAlerts => 'Notification Alerts';

  @override
  String get settingsAlarmsMutedAll =>
      'All order notification alarms are currently muted';

  @override
  String get settingsAlarmsActive => 'Order notification alarms are active';

  @override
  String get settingsAlarmsEnabledDevice =>
      'Notification alarms enabled on this device';

  @override
  String get settingsAlarmsMutedDevice =>
      'Notification alarms muted on this device';

  @override
  String get settingsChooseAlarmSound => 'Choose the in-app staff alarm sound:';

  @override
  String get settingsAlarmSoundNote =>
      'This sound is used for the in-app staff alarm. Closed-app order notifications use the app order tone.';

  @override
  String get settingsProfileLoadFailed => 'Failed to load user profile';

  @override
  String get shiftUnknownUser => 'Unknown user';

  @override
  String kanbanDeliveryIncomeUpdated(String amount) {
    return 'Delivery income updated to $amount';
  }

  @override
  String kanbanAddressNoTerritory(String city) {
    return 'Address saved, but \"$city\" matches no territory — shipping cost was not updated. Fix the address territory.';
  }

  @override
  String get reportsColumnComponent => 'Component';

  @override
  String get leadContactsTitle => 'Contacts';

  @override
  String leadContactsTitleCount(int count) {
    return 'Contacts ($count)';
  }

  @override
  String get leadContactsEmpty =>
      'No people recorded yet. Add the owner, the manager, or whoever you meet on a visit.';

  @override
  String get leadContactsAdd => 'Add contact';

  @override
  String get leadContactsEdit => 'Edit contact';

  @override
  String get leadContactsRemove => 'Remove';

  @override
  String get leadContactsRemoveTitle => 'Remove contact?';

  @override
  String leadContactsRemoveBody(String name) {
    return 'Remove $name from this lead?';
  }

  @override
  String get leadContactsMakePrimary => 'Make primary';

  @override
  String get leadContactsPrimary => 'Primary contact';

  @override
  String get leadContactsPrimaryHint => 'The person to ring first.';

  @override
  String get leadContactsSaved => 'Contacts updated';

  @override
  String get leadContactsName => 'Name';

  @override
  String get leadContactsRole => 'Role / title';

  @override
  String get leadContactsRoleHint => 'Owner, Manager, Barista…';

  @override
  String get leadContactsPhone => 'Phone';

  @override
  String get leadContactsEmail => 'Email';

  @override
  String get leadContactsNotes => 'Notes';

  @override
  String get leadContactsPickFromPhone => 'Pick from phone contacts';

  @override
  String get leadContactsNeedNameOrPhone => 'Add a name or a phone number.';

  @override
  String get leadContactRoleOwner => 'Owner';

  @override
  String get leadContactRoleManager => 'Manager';

  @override
  String get leadContactRoleShiftManager => 'Shift Manager';

  @override
  String get leadContactRoleBarista => 'Barista';

  @override
  String get leadContactRolePurchasing => 'Purchasing';

  @override
  String get leadContactRoleAccountant => 'Accountant';

  @override
  String get visitPlannerTitle => 'Visit planner';

  @override
  String get visitPlanDay => 'Plan a day';

  @override
  String get visitBuildDay => 'Build a day';

  @override
  String get visitRouteTitle => 'Route';

  @override
  String visitRouteFallbackTitle(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString stops',
      one: '1 stop',
      zero: 'Empty route',
    );
    return '$_temp0';
  }

  @override
  String get visitScopeMine => 'My routes';

  @override
  String get visitScopeAll => 'Everyone\'s routes';

  @override
  String get visitNoRoutesOnDay => 'No route planned for this day.';

  @override
  String get visitPlansLoadFailed =>
      'Could not load routes. Pull down to try again.';

  @override
  String visitStopsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString stops',
      one: '1 stop',
      zero: 'No stops',
    );
    return '$_temp0';
  }

  @override
  String visitDistanceKm(String km) {
    return '$km km';
  }

  @override
  String visitDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String visitDayTotal(String duration) {
    return 'Day $duration';
  }

  @override
  String visitLeg(String km, int minutes) {
    return '$km km · $minutes min';
  }

  @override
  String get visitNextStop => 'Next stop';

  @override
  String get visitGo => 'Go';

  @override
  String get visitNavigate => 'Navigate';

  @override
  String get visitCall => 'Call';

  @override
  String get visitCheckIn => 'Check in';

  @override
  String get visitSkip => 'Skip';

  @override
  String get visitReopen => 'Reopen';

  @override
  String get visitPin => 'Pin to this position';

  @override
  String get visitUnpin => 'Unpin';

  @override
  String get visitRemoveStop => 'Remove from route';

  @override
  String get visitOptimise => 'Optimise route';

  @override
  String get visitOptimiseFromHere => 'Optimise from where I am';

  @override
  String get visitNavigateWholeRoute => 'Open whole route in Maps';

  @override
  String get visitDeleteRoute => 'Delete route';

  @override
  String get visitDeleteRouteConfirm =>
      'The route is removed. Visits already recorded stay in the diary.';

  @override
  String get visitNoStops => 'This route has no stops yet.';

  @override
  String get visitLocationUnavailable => 'Could not get your location.';

  @override
  String visitRouteTruncated(int handed, int total) {
    return 'Maps takes $handed of $total stops at once. Navigate stop by stop for the rest.';
  }

  @override
  String get visitOutcome => 'Outcome';

  @override
  String get visitLogJourneyNote => 'Log a journey note';

  @override
  String get visitLogJourneyNoteHint =>
      'Records the visit on the lead\'s diary and drives its follow-up reminder.';

  @override
  String get visitNoteWhatHappened => 'What happened';

  @override
  String get visitNextAction => 'Next action';

  @override
  String get visitNextActionDate => 'Pick a date';

  @override
  String get visitMarkVisited => 'Visited';

  @override
  String get visitSuggestDay => 'Plan my day';

  @override
  String get visitMaxStops => 'Max stops';

  @override
  String get visitDayHours => 'Day (hours)';

  @override
  String get visitStartFromMyLocation => 'Start from my location';

  @override
  String get visitStartFromMyLocationHint =>
      'Off plans around the best cluster anywhere.';

  @override
  String get visitIncludeCustomers => 'Include existing clients';

  @override
  String get visitIncludeCustomersHint =>
      'Check-ups on active accounts along the way.';

  @override
  String get visitCandidateDoors => 'Doors worth visiting';

  @override
  String get visitClearSelection => 'Clear';

  @override
  String get visitNoCandidates => 'Nothing matches those filters.';

  @override
  String get visitTargetsLoadFailed => 'Could not load candidates.';

  @override
  String visitProposedDay(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString stops proposed',
      one: '1 stop proposed',
    );
    return '$_temp0';
  }

  @override
  String visitConsidered(int count) {
    return 'Weighed $count doors';
  }

  @override
  String visitDroppedForTime(int count) {
    return '$count dropped to fit the day';
  }

  @override
  String visitSelectedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString stops selected',
      one: '1 stop selected',
    );
    return '$_temp0';
  }

  @override
  String get visitCreateRoute => 'Create route';

  @override
  String get visitEngineRoadExplained =>
      'Distances and times come from the road network.';

  @override
  String get visitEngineEstimateExplained =>
      'Distances are straight-line estimates adjusted for city driving. The visiting order is still solved properly; the minutes are approximate.';

  @override
  String get visitEngineRecheck => 'Check again';

  @override
  String get materialsSectionTitle => 'Price list & materials';

  @override
  String get materialsSendCta => 'Send price list';

  @override
  String get materialsSendTitle => 'Send materials';

  @override
  String get materialsRecipientLabel => 'Send to';

  @override
  String get materialsNoRecipient =>
      'No contacts on this lead yet. Add one first, or send anyway and pick the chat in WhatsApp.';

  @override
  String get materialsPickLabel => 'What to send';

  @override
  String get materialsPreparing => 'still preparing';

  @override
  String get materialsMessageLabel => 'Message';

  @override
  String get materialsSending => 'Creating link…';

  @override
  String get materialsLinkReady => 'Link created and logged on the lead.';

  @override
  String get materialsCopyLink => 'Copy link';

  @override
  String get materialsLinkCopied => 'Link copied';

  @override
  String get materialsLibraryEmpty =>
      'No materials in the library yet. Ask a manager to upload the price list.';

  @override
  String get materialsRetry => 'Retry';

  @override
  String get materialsNothingSent => 'Nothing sent yet.';

  @override
  String get materialsHistoryUnavailable =>
      'Could not load what was sent before.';

  @override
  String get materialsNotOpenedYet => 'Not opened yet';

  @override
  String materialsPageCount(Object count) {
    return '$count pages';
  }

  @override
  String materialsStillPreparing(Object count) {
    return '$count of these files are still being prepared. The link works now; the first open may take a few seconds.';
  }

  @override
  String materialsOpenedCount(Object count) {
    return 'Opened $count×';
  }

  @override
  String materialsSendFailed(Object error) {
    return 'Could not create the link: $error';
  }

  @override
  String materialsLoadFailed(Object error) {
    return 'Could not load the material library: $error';
  }

  @override
  String materialsLinkPlaceholderHint(Object token) {
    return 'Leave $token where you want the link; it is replaced automatically when you send.';
  }

  @override
  String get appUpdateRequiredTitle => 'Update Required';

  @override
  String get appUpdateRequiredBody =>
      'This version of Jarz POS is out of date and can no longer be used. Install the latest version to continue.';

  @override
  String appUpdateBuildLine(Object current, Object minimum) {
    return 'Installed build $current · Required build $minimum';
  }

  @override
  String get appUpdateDownloadButton => 'Download Update';

  @override
  String get appUpdateRecheckButton => 'I have installed it — retry';

  @override
  String get appUpdateOpenFailed =>
      'Could not open the download page. Ask your manager for the install link.';

  @override
  String get appUpdateInstallHint =>
      'Your browser will ask permission to install apps from this source. Allow it, then open the downloaded file to install.';

  @override
  String get appUpdateAvailableBanner =>
      'A new version is available — tap to download.';

  @override
  String get materialsZoomedIn => 'zoomed in';

  @override
  String get materialsDownloadedFile => 'downloaded';

  @override
  String materialsReadFor(Object time) {
    return 'Read for $time';
  }

  @override
  String materialsPagesRead(Object count) {
    return '$count pages';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get visitAddToRoute => 'Add to a route';

  @override
  String get visitAddStop => 'Add';

  @override
  String get visitAddedToRoute => 'Added to the route';

  @override
  String get visitOpenRoute => 'Open';

  @override
  String visitWhichDoor(int count) {
    return 'Which branch? ($count located)';
  }

  @override
  String get visitWhichDay => 'Which day';

  @override
  String get visitNewRoute => 'New route…';

  @override
  String visitNewRouteOn(String date) {
    return 'New route on $date';
  }

  @override
  String get visitNoUpcomingRoutes => 'No upcoming routes yet.';

  @override
  String get visitNoDoorsToRoute => 'Nothing here can be routed to.';

  @override
  String get visitNoDoorsToRouteHint =>
      'This record has no branch with a location on it. Add a pin first and it becomes a stop.';

  @override
  String get visitFilters => 'Filters';

  @override
  String get visitClearFilters => 'Clear all';

  @override
  String get visitFilterTier => 'Fit tier';

  @override
  String get visitFilterCategory => 'Category';

  @override
  String get visitFilterArea => 'Area';

  @override
  String visitFilterMinFit(int score) {
    return 'Minimum fit score: $score';
  }

  @override
  String get visitFilterSpecialty => 'Specialty only';

  @override
  String get visitFilterNeverVisited => 'Never visited only';

  @override
  String get visitFilterNeverVisitedHint => 'Doors nobody has walked into yet.';

  @override
  String get visitEmptyDayHint =>
      'Pick doors below, or tap Plan my day. The route builds as you choose.';

  @override
  String get visitCostingDay => 'Working out the route…';

  @override
  String get visitManualOrderNote =>
      'Your order — tap Optimise to hand it back.';

  @override
  String visitSkippedNoPin(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString doors have no location and are not on the route',
      one: '1 door has no location and is not on the route',
    );
    return '$_temp0';
  }

  @override
  String get visitSaveDraft => 'Save draft';

  @override
  String get shiftCourierCarryTitle => 'Money still with couriers';

  @override
  String shiftCourierCarryBody(int transactions, Object amount, int couriers) {
    return '$transactions order(s) worth $amount are still out with $couriers courier(s). Confirm each one, or settle it now.';
  }

  @override
  String get shiftCourierCarryHint =>
      'Tick every order whose cash is still with the courier. Anything you leave unticked must be settled before you can close.';

  @override
  String get shiftCourierCarryConfirmAll => 'Confirm all';

  @override
  String get shiftCourierCarryClearAll => 'Clear all';

  @override
  String get shiftCourierCarrySettleNow => 'Settle a courier now';

  @override
  String shiftCourierCarryConfirmedOf(int confirmed, int total) {
    return '$confirmed of $total confirmed';
  }

  @override
  String shiftCourierCarryRowLabel(Object invoice, Object customer) {
    return '$invoice — $customer';
  }

  @override
  String get shiftCourierCarryCheckboxLabel => 'Cash still with the courier';

  @override
  String shiftCourierCarryCarriedBadge(int count, int days) {
    return 'Carried $count shift(s) · $days day(s) out';
  }

  @override
  String get shiftCourierCarryUnconfirmed =>
      'Confirm every order still out with a courier, or settle it, before closing.';

  @override
  String shiftCourierCarriedSummary(int count, Object amount) {
    return '$count order(s) worth $amount left the shift still with couriers. They stay open until settled.';
  }

  @override
  String shiftMonitorCarriedOut(int count, Object amount) {
    return 'Carried out: $count · $amount';
  }

  @override
  String shiftMonitorSettledIn(int count, Object amount) {
    return 'Collected from earlier shifts: $count · $amount';
  }

  @override
  String get shiftMonitorCourierOutstandingTitle => 'Out with couriers now';

  @override
  String shiftMonitorCourierOutstandingSummary(
    Object amount,
    int transactions,
    int days,
  ) {
    return '$amount across $transactions order(s); oldest $days day(s) out.';
  }

  @override
  String get shiftMonitorCourierOutstandingEmpty =>
      'No courier is holding cash right now.';

  @override
  String shiftMonitorCourierRow(Object name, Object branch) {
    return '$name · $branch';
  }

  @override
  String shiftMonitorCourierRowDetail(int count, Object amount, int days) {
    return '$count order(s) · $amount · oldest $days day(s)';
  }

  @override
  String get expensesAdvanceTabExpenses => 'Expenses';

  @override
  String get expensesAdvanceTabAdvances => 'Employee Advances';

  @override
  String get expensesAdvanceNewRequest => 'New Advance';

  @override
  String get expensesAdvanceFormTitle => 'Request Employee Advance';

  @override
  String get expensesAdvanceEmployeeLabel => 'Employee';

  @override
  String get expensesAdvanceEmployeeRequired => 'Select an employee';

  @override
  String get expensesAdvanceEmployeeHint => 'Tap to choose an employee';

  @override
  String get expensesAdvanceEmployeePickerTitle => 'Choose employee';

  @override
  String get expensesAdvanceEmployeeSearchHint =>
      'Search by name, branch or department';

  @override
  String get expensesAdvanceEmployeeNoMatches =>
      'No employees match that search';

  @override
  String get expensesAdvanceAmountLabel => 'Advance amount';

  @override
  String get expensesAdvanceAmountInvalid => 'Enter a valid amount';

  @override
  String get expensesAdvancePurposeLabel => 'Purpose';

  @override
  String get expensesAdvancePurposeRequired =>
      'Describe what the advance is for';

  @override
  String get expensesAdvancePayFromLabel => 'Pay from';

  @override
  String get expensesAdvancePaymentSourceRequired => 'Select a payment source';

  @override
  String get expensesAdvanceDateLabel => 'Advance date (optional)';

  @override
  String get expensesAdvanceDateNotSet => 'Today';

  @override
  String get expensesAdvanceDateClear => 'Clear date';

  @override
  String get expensesAdvanceSubmit => 'Submit request';

  @override
  String get expensesAdvanceNoOptions =>
      'Advances cannot be requested until an employee list and a payment source are available.';

  @override
  String get expensesAdvanceSubmitted =>
      'Advance request submitted for approval';

  @override
  String get expensesAdvanceMonthLabel => 'Month';

  @override
  String get expensesAdvanceStatusFilterLabel => 'Status';

  @override
  String get expensesAdvanceStatusFilterAll => 'All statuses';

  @override
  String get expensesAdvanceEmptyTitle =>
      'No employee advances for this month.';

  @override
  String get expensesAdvanceEmptyApproverBody =>
      'Requests raised by line managers will appear here for approval.';

  @override
  String get expensesAdvanceEmptyRequesterBody =>
      'Use the New Advance button to request cash for an employee.';

  @override
  String get expensesAdvanceEmptyReadOnlyBody =>
      'You do not have permission to request or approve advances.';

  @override
  String get expensesAdvanceUnavailableTitle =>
      'Employee advances are unavailable';

  @override
  String get expensesAdvanceUnavailableBody =>
      'The HR module is not installed on this site, so advances cannot be requested here.';

  @override
  String get expensesAdvanceSummaryTotal => 'Total';

  @override
  String get expensesAdvanceSummaryPending => 'Awaiting approval';

  @override
  String get expensesAdvanceSummaryApproved => 'Approved';

  @override
  String get expensesAdvanceSummaryOutstanding => 'Outstanding';

  @override
  String expensesAdvanceSummaryCount(int count) {
    return '$count request(s)';
  }

  @override
  String expensesAdvanceSummaryPendingValue(int count, Object amount) {
    return '$count | $amount';
  }

  @override
  String get expensesAdvanceApprove => 'Approve & pay';

  @override
  String get expensesAdvanceReject => 'Reject';

  @override
  String get expensesAdvanceApproveTitle => 'Approve advance?';

  @override
  String expensesAdvanceApproveBody(
    Object amount,
    Object employee,
    Object source,
  ) {
    return 'Approving pays $amount to $employee right now, out of $source. The cash leaves that account immediately and cannot be undone from this screen.';
  }

  @override
  String get expensesAdvanceApproveConfirm => 'Approve & pay now';

  @override
  String get expensesAdvanceApproved => 'Advance approved and paid';

  @override
  String expensesAdvanceApprovedWithEntry(Object entry) {
    return 'Advance approved and paid · $entry';
  }

  @override
  String get expensesAdvanceRejectTitle => 'Reject advance request?';

  @override
  String get expensesAdvanceRejectHint =>
      'Tell the requester why this was rejected';

  @override
  String get expensesAdvanceRejectReasonRequired => 'A reason is required';

  @override
  String get expensesAdvanceRejected => 'Advance request rejected';

  @override
  String get expensesAdvanceIdLabel => 'Advance';

  @override
  String get expensesAdvancePostingDateLabel => 'Advance date';

  @override
  String get expensesAdvanceBranchLabel => 'Branch';

  @override
  String get expensesAdvancePayingAccountLabel => 'Paying account';

  @override
  String get expensesAdvancePaidLabel => 'Paid';

  @override
  String get expensesAdvanceClaimedLabel => 'Claimed';

  @override
  String get expensesAdvanceReturnedLabel => 'Returned';

  @override
  String get expensesAdvanceBalanceLabel => 'Outstanding balance';

  @override
  String get expensesAdvanceRequestedByLabel => 'Requested by';

  @override
  String get expensesAdvanceApprovedByLabel => 'Approved by';

  @override
  String get expensesAdvanceApprovedOnLabel => 'Approved on';

  @override
  String get expensesAdvancePaymentEntryLabel => 'Payment Entry';

  @override
  String get expensesAdvanceStatusDraft => 'Awaiting approval';

  @override
  String get expensesAdvanceStatusPaid => 'Paid';

  @override
  String get expensesAdvanceStatusPartiallyPaid => 'Partially Paid';

  @override
  String get expensesAdvanceStatusUnpaid => 'Unpaid';

  @override
  String get expensesAdvanceStatusClaimed => 'Claimed';

  @override
  String get expensesAdvanceStatusReturned => 'Returned';

  @override
  String get expensesAdvanceStatusPartlyClaimedAndReturned =>
      'Partly Claimed and Returned';

  @override
  String get expensesAdvanceStatusCancelled => 'Cancelled';

  @override
  String get managerEmployeeLedgerTitle => 'Employee Ledger';

  @override
  String get managerEmployeeLedgerSubtitle =>
      'What each employee owes: cash advances plus unpaid employee orders';

  @override
  String get managerEmployeeLedgerPeriodLabel => 'Period';

  @override
  String get managerEmployeeLedgerWindow30 => 'Last 30 days';

  @override
  String get managerEmployeeLedgerWindow90 => 'Last 90 days';

  @override
  String get managerEmployeeLedgerWindow180 => 'Last 180 days';

  @override
  String get managerEmployeeLedgerWindow365 => 'Last 365 days';

  @override
  String managerEmployeeLedgerActivityRange(Object from, Object to) {
    return 'Listed activity: $from to $to';
  }

  @override
  String get managerEmployeeLedgerActivityInPeriod => 'Activity in this period';

  @override
  String get managerEmployeeLedgerTotalOutstanding =>
      'Total outstanding in this period';

  @override
  String get managerEmployeeLedgerTotalOutstandingAllTime =>
      'Total outstanding (all time)';

  @override
  String get managerEmployeeLedgerAllTimeHint =>
      'Every open item, whatever its age. The period below only controls which lines are listed.';

  @override
  String get managerEmployeeLedgerAdvancesLabel => 'Cash advances';

  @override
  String get managerEmployeeLedgerOrdersLabel => 'Unpaid orders';

  @override
  String managerEmployeeLedgerAdvanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count advances',
      one: '1 advance',
      zero: 'No advances',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: 'No orders',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people owe money',
      one: '1 person owes money',
      zero: 'Nobody owes anything',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerSplit(Object advances, Object orders) {
    return 'Advances $advances • Orders $orders';
  }

  @override
  String get managerEmployeeLedgerOutstandingLabel => 'Outstanding';

  @override
  String get managerEmployeeLedgerOrderTotalLabel => 'Order total';

  @override
  String get managerEmployeeLedgerAdvanceAmountLabel => 'Advance';

  @override
  String get managerEmployeeLedgerEmpty =>
      'Nothing outstanding, and no activity in this period';

  @override
  String get managerEmployeeLedgerNoAdvances =>
      'No cash advances in this period';

  @override
  String get managerEmployeeLedgerNoOrders => 'No unpaid orders in this period';

  @override
  String get managerEmployeeLedgerBalancePredatesPeriod =>
      'Nothing listed in this period. The balance above is older than that, so widen the period to see the lines behind it.';

  @override
  String get managerEmployeeLedgerUnmatched => 'No employee record';

  @override
  String get managerEmployeeLedgerLoadFailed =>
      'Failed to load employee ledger';

  @override
  String get managerEmployeeLedgerNoticeNoBranchAssigned =>
      'You have no branch assigned, so there is nothing to show here yet.';

  @override
  String get managerEmployeeLedgerNoticeBranchNotPermitted =>
      'You cannot view that branch, so it was ignored.';

  @override
  String get managerEmployeeLedgerNoticeHrmsUnavailable =>
      'HRMS is not installed, so cash advances are not tracked. Unpaid employee orders are still shown.';

  @override
  String get managerEmployeeLedgerNoticeResultsTruncated =>
      'Only the first results are shown. Narrow the branch or the period to see the rest.';

  @override
  String get kanbanStateReceived => 'Received';

  @override
  String get kanbanStateInProgress => 'In Progress';

  @override
  String get kanbanStateReady => 'Ready';

  @override
  String get cancelReasonCustomerRequested => 'Customer requested cancellation';

  @override
  String get cancelReasonCreatedInError => 'Order created in error / duplicate';

  @override
  String get cancelReasonInventoryUnavailable => 'Inventory unavailable';

  @override
  String get cancelReasonPaymentIssue => 'Payment issue';

  @override
  String get cancelReasonOther => 'Other';

  @override
  String get notSuitableReasonOutOfBusiness => 'Out of Business';

  @override
  String get notSuitableReasonWrongCategory => 'Wrong Category';

  @override
  String get notSuitableReasonTooSmall => 'Too Small';

  @override
  String get notSuitableReasonNoContactInfo => 'No Contact Info';

  @override
  String get notSuitableReasonUnreachable => 'Unreachable';

  @override
  String get notSuitableReasonAlreadySupplied => 'Already Supplied';

  @override
  String get notSuitableReasonPriceMismatch => 'Price Mismatch';

  @override
  String get notSuitableReasonOutsideDeliveryArea => 'Outside Delivery Area';

  @override
  String get notSuitableReasonDuplicate => 'Duplicate';

  @override
  String get notSuitableReasonNotInterested => 'Not Interested';

  @override
  String get notSuitableReasonOther => 'Other';

  @override
  String get leadSourceWalkIn => 'Walk In';

  @override
  String get leadSourceReference => 'Reference';

  @override
  String get leadSourceCampaign => 'Campaign';

  @override
  String get leadSourceExistingCustomer => 'Existing Customer';

  @override
  String get leadSourceColdCall => 'Cold Call';

  @override
  String get leadSourceSocialMedia => 'Social Media';

  @override
  String get customerSegmentChampion => 'Champion';

  @override
  String get customerSegmentLoyal => 'Loyal';

  @override
  String get customerSegmentPotentialLoyalist => 'Potential Loyalist';

  @override
  String get customerSegmentNewCustomer => 'New Customer';

  @override
  String get customerSegmentAtRisk => 'At Risk';

  @override
  String get customerSegmentCantLoseThem => 'Can\'t Lose Them';

  @override
  String get customerSegmentLost => 'Lost';

  @override
  String get customerSegmentOneTime => 'One-Time';

  @override
  String get customerSegmentUnclassified => 'Unclassified';

  @override
  String get velocityTrendAccelerating => 'Accelerating';

  @override
  String get velocityTrendStable => 'Stable';

  @override
  String get velocityTrendDeclining => 'Declining';

  @override
  String get velocityTrendNewItem => 'New Item';

  @override
  String get velocityTrendNoSales => 'No Sales';

  @override
  String get visitStatusPlanned => 'Planned';

  @override
  String get visitStatusInProgress => 'In Progress';

  @override
  String get visitStatusVisited => 'Visited';

  @override
  String get visitStatusSkipped => 'Skipped';

  @override
  String get materialTypePriceList => 'Price List';

  @override
  String get materialTypeProductPhotos => 'Product Photos';

  @override
  String get materialTypeCatalog => 'Catalog';

  @override
  String get materialTypeCertificate => 'Certificate';

  @override
  String get materialTypeOther => 'Other';

  @override
  String get b2bStageShortLead => 'Lead';

  @override
  String get b2bStageShortQualify => 'Qual';

  @override
  String get b2bStageShortSample => 'Samp';

  @override
  String get b2bStageShortApproved => 'Appr';

  @override
  String get b2bStageShortTrial => 'Trial';

  @override
  String get b2bStageShortCheckup => 'Chk';

  @override
  String get b2bStageShortActive => 'Actv';

  @override
  String get b2bStageShortLostOnHold => 'Lost';

  @override
  String get statusChanged => 'Changed';

  @override
  String get statusSettled => 'Settled';

  @override
  String get statusUnsettled => 'Unsettled';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusEnded => 'Ended';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get reportsColumnItem => 'Item';

  @override
  String get reportsColumnVelocity30d => 'Vel 30d';

  @override
  String get reportsColumnVelocity60d => 'Vel 60d';

  @override
  String get reportsColumnTrend => 'Trend';

  @override
  String get reportsColumnStock => 'Stock';

  @override
  String get reportsColumnCover => 'Cover';

  @override
  String get reportsColumnSold => 'Sold';

  @override
  String get reportsColumnRevenue => 'Revenue';

  @override
  String get reportsColumnVelocity => 'Velocity';

  @override
  String get menuShiftDistribution => 'Shift Distribution';

  @override
  String get rosterTitle => 'Shift Distribution';

  @override
  String get rosterAccessDenied =>
      'Shift distribution is for managers and line managers only.';

  @override
  String get rosterHoursTitle => 'Hours & overtime';

  @override
  String get rosterHoursBasis =>
      'Rostered hours — what people were scheduled to work. Overtime is credited at each person\'s rate.';

  @override
  String get rosterPreviousMonth => 'Previous month';

  @override
  String get rosterNextMonth => 'Next month';

  @override
  String get rosterAllBranches => 'All branches';

  @override
  String get rosterEmployeeColumn => 'Employee';

  @override
  String get rosterHrmsMissing =>
      'HRMS is not installed on this site, so there is no roster to show.';

  @override
  String get rosterNobodyRostered => 'Nobody is rostered for this month yet.';

  @override
  String get rosterScopeUnconfigured =>
      'No branches are linked to your POS profiles yet, so there is nobody to show. Ask an administrator to set the HR Shift Location on your POS Profile.';

  @override
  String rosterUncoveredWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days off with nobody covering',
      one: '1 day off with nobody covering',
    );
    return '$_temp0';
  }

  @override
  String rosterStandardDay(Object hours) {
    return 'Normal day: ${hours}h';
  }

  @override
  String get rosterOffShort => 'OFF';

  @override
  String get rosterHolidayShort => 'HOL';

  @override
  String get rosterChangeShift => 'Change shift';

  @override
  String get rosterMarkDayOff => 'Mark day off';

  @override
  String get rosterClearDayOff => 'Cancel this day off';

  @override
  String get rosterNoShiftTypes => 'No shift types are configured yet.';

  @override
  String rosterShiftWindow(Object window, Object hours) {
    return '$window · ${hours}h';
  }

  @override
  String rosterWorkingShift(Object shiftType, Object hours, Object location) {
    return 'On $shiftType · ${hours}h · $location';
  }

  @override
  String rosterOffCoveredBy(Object offType, Object name) {
    return 'Off ($offType) — covered by $name';
  }

  @override
  String rosterOffUncovered(Object offType) {
    return 'Off ($offType) — nobody is covering this day';
  }

  @override
  String get rosterHoliday => 'Holiday';

  @override
  String get rosterUnrosteredWarning =>
      'Not on the roster — this person cannot check in on this day.';

  @override
  String get rosterOffType => 'Reason';

  @override
  String get rosterCoveredBy => 'Covered by';

  @override
  String get rosterCoverHelper => 'Who absorbs this day at the branch.';

  @override
  String get rosterNobodyCovers => 'Nobody';

  @override
  String get rosterCoverShift => 'Cover shift';

  @override
  String get rosterCoverShiftHelper =>
      'The shift they move onto for this day, normally the longer full-day one.';

  @override
  String get rosterNotes => 'Notes (optional)';

  @override
  String get rosterOffTypeWeekly => 'Weekly off';

  @override
  String get rosterOffTypeVacation => 'Vacation';

  @override
  String get rosterOffTypeSick => 'Sick';

  @override
  String get rosterOffTypeUnpaid => 'Unpaid';

  @override
  String get rosterOffTypeOther => 'Other';

  @override
  String get rosterWorkedHours => 'Worked';

  @override
  String get rosterOvertimeHours => 'Overtime';

  @override
  String get rosterCreditedOvertime => 'Credited OT';

  @override
  String get rosterCreditedHours => 'Paid hours';

  @override
  String rosterCourierTag(Object multiplier) {
    return 'Courier ×$multiplier';
  }

  @override
  String rosterRowDays(Object worked, Object off, Object cover) {
    return '$worked worked · $off off · $cover cover';
  }

  @override
  String get rosterLegendWorking => 'Working';

  @override
  String get rosterLegendOff => 'Day off';

  @override
  String get rosterLegendUnrostered => 'Not rostered';

  @override
  String get rosterLegendHoliday => 'Holiday';

  @override
  String get settlementPartnerFeeInputLabel => 'Partner delivery cost';

  @override
  String get settlementPartnerFeeInputHint => 'Read it from the partner\'s app';

  @override
  String get settlementPartnerFeeRequired =>
      'Enter the partner\'s delivery cost for this order';

  @override
  String get settlementPartnerFeeInvalid => 'Enter a valid amount';

  @override
  String get settlementPartnerFeeWhy =>
      'Our area rates don\'t apply to the partner - they price this address themselves.';

  @override
  String get settlementPartnerNoDeduction =>
      'The rider hands over the full amount. Nothing is deducted for his fee - his company is billed weekly.';

  @override
  String get commonReasonRequired => 'A reason is required';

  @override
  String get expensesReject => 'Reject';

  @override
  String get expensesRejectTitle => 'Reject this expense?';

  @override
  String get expensesRejectHint => 'Tell the person who filed it why';

  @override
  String get expensesRejected => 'Expense rejected';

  @override
  String get expensesRejectedStatus => 'Rejected';

  @override
  String get expensesRejectionReason => 'Rejection reason';

  @override
  String get expensesCancelAction => 'Cancel expense';

  @override
  String get expensesCancelTitle => 'Cancel this approved expense?';

  @override
  String expensesCancelBody(Object amount, Object source) {
    return 'This reverses the journal entry for $amount and puts the money back in $source.';
  }

  @override
  String get expensesCancelHint => 'Why is this being reversed?';

  @override
  String get expensesCancelConfirm => 'Cancel & reverse';

  @override
  String get expensesCancelled =>
      'Expense cancelled and journal entry reversed';

  @override
  String get productionCancelBatch => 'Cancel batch';

  @override
  String get productionCancelBatchTitle => 'Cancel this batch?';

  @override
  String productionCancelBatchBody(Object item) {
    return 'Everything still in WIP for $item goes back to the store. Nothing has been produced yet, so no finished goods are affected.';
  }

  @override
  String get productionCancelBatchHint =>
      'Why is this batch not being finished?';

  @override
  String get productionCancelBatchConfirm => 'Cancel batch';

  @override
  String get productionBatchCancelled =>
      'Batch cancelled and material returned to store';

  @override
  String get productionPlanCancel => 'Cancel plan';

  @override
  String get productionPlanCancelTitle => 'Cancel this day\'s plan?';

  @override
  String get productionPlanCancelBody =>
      'Use this when the day will not be produced at all. Closing with zero counts instead would record a day that tried and made nothing.';

  @override
  String get productionPlanCancelHint => 'Why is the day being called off?';

  @override
  String get productionPlanCancelConfirm => 'Cancel plan';

  @override
  String get productionPlanCancelled => 'Production plan cancelled';

  @override
  String get productionPlanCancelledStatus => 'Cancelled';

  @override
  String get receiptReject => 'Reject';

  @override
  String get receiptRejectTitle => 'Reject this receipt?';

  @override
  String get receiptRejectHint => 'What is wrong with the proof of transfer?';

  @override
  String get receiptRejectConfirm => 'Reject receipt';

  @override
  String get receiptRejected => 'Receipt rejected';

  @override
  String get receiptRejectedStatus => 'Rejected';

  @override
  String get receiptRejectionReason => 'Rejection reason';

  @override
  String get historyDateRangeAll => 'All dates';

  @override
  String historyDateRangeValue(Object from, Object to) {
    return '$from - $to';
  }

  @override
  String get stockTransferHistoryTitle => 'Transfer history';

  @override
  String get stockTransferHistorySearchHint => 'Entry no. or item';

  @override
  String get stockTransferHistoryEmpty => 'No stock transfers yet.';

  @override
  String stockTransferHistoryRoute(Object source, Object target) {
    return '$source to $target';
  }

  @override
  String get stockTransferHistoryMixed => 'Multiple warehouses';

  @override
  String stockTransferHistorySummary(Object items, Object qty) {
    return '$items items, $qty units';
  }

  @override
  String get cashTransferHistoryTitle => 'Cash transfer history';

  @override
  String get cashTransferHistorySearchHint => 'Entry no. or remark';

  @override
  String get cashTransferHistoryEmpty => 'No cash transfers yet.';

  @override
  String get inventoryCountHistoryTitle => 'Count history';

  @override
  String get inventoryCountHistorySearchHint => 'Count no. or item';

  @override
  String get inventoryCountHistoryEmpty => 'No stock counts yet.';

  @override
  String inventoryCountHistoryAdjusted(Object items) {
    return '$items items adjusted';
  }

  @override
  String inventoryCountHistoryDeltas(Object up, Object down) {
    return '$up up, $down down';
  }

  @override
  String get inventoryCountHistoryValueChange => 'Value change';

  @override
  String get shiftHistoryTitle => 'Shift history';

  @override
  String get shiftHistoryEmpty => 'No shifts yet.';

  @override
  String get shiftHistoryStatusOpen => 'Open';

  @override
  String get shiftHistoryStatusClosed => 'Closed';

  @override
  String get shiftHistoryAmountsHidden => 'Amounts are shown to managers only.';

  @override
  String get shiftHistoryDifference => 'Over / short';

  @override
  String get shiftHistoryMineOnly => 'My shifts only';

  @override
  String get shiftHistoryStillOpen => 'Still open';

  @override
  String shiftHistoryDuration(Object start, Object end) {
    return '$start to $end';
  }

  @override
  String shiftHistoryOpenedBy(Object name) {
    return 'Opened by $name';
  }
}
