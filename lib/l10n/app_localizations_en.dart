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
      'A credit note will be issued automatically so the accounts stay balanced.';

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
  String get kanbanFilterSearchHint => 'Search orders...';

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
}
