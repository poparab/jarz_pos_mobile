import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Jarz POS'**
  String get appTitle;

  /// No description provided for @drawerHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Jarz POS'**
  String get drawerHeaderTitle;

  /// No description provided for @drawerHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Point of Sale'**
  String get drawerHeaderSubtitle;

  /// No description provided for @menuB2bMode.
  ///
  /// In en, this message translates to:
  /// **'B2B Mode'**
  String get menuB2bMode;

  /// No description provided for @drawerGroupPosSales.
  ///
  /// In en, this message translates to:
  /// **'POS / Sales'**
  String get drawerGroupPosSales;

  /// No description provided for @drawerGroupCrm.
  ///
  /// In en, this message translates to:
  /// **'CRM / B2B'**
  String get drawerGroupCrm;

  /// No description provided for @drawerGroupDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery / Logistics'**
  String get drawerGroupDelivery;

  /// No description provided for @drawerGroupFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance / Expenses'**
  String get drawerGroupFinance;

  /// No description provided for @drawerGroupPurchasing.
  ///
  /// In en, this message translates to:
  /// **'Purchasing / Inventory'**
  String get drawerGroupPurchasing;

  /// No description provided for @drawerGroupManagement.
  ///
  /// In en, this message translates to:
  /// **'Management / Reports'**
  String get drawerGroupManagement;

  /// No description provided for @drawerGroupPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get drawerGroupPricing;

  /// No description provided for @menuPriceLists.
  ///
  /// In en, this message translates to:
  /// **'Price Lists'**
  String get menuPriceLists;

  /// No description provided for @menuPointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get menuPointOfSale;

  /// No description provided for @menuSalesKanban.
  ///
  /// In en, this message translates to:
  /// **'Sales Kanban'**
  String get menuSalesKanban;

  /// No description provided for @menuExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get menuExpenses;

  /// No description provided for @menuCourierBalances.
  ///
  /// In en, this message translates to:
  /// **'Courier Balances'**
  String get menuCourierBalances;

  /// No description provided for @menuManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get menuManagerDashboard;

  /// No description provided for @managerMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get managerMenuTooltip;

  /// No description provided for @managerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get managerDashboardTitle;

  /// No description provided for @managerRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get managerRecentOrders;

  /// No description provided for @managerNoRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'No recent orders'**
  String get managerNoRecentOrders;

  /// No description provided for @managerBranchBalances.
  ///
  /// In en, this message translates to:
  /// **'Branch Balances'**
  String get managerBranchBalances;

  /// No description provided for @managerSwitchProfileTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Switch POS profiles from the POS/Kanban headers.'**
  String get managerSwitchProfileTip;

  /// No description provided for @managerSwitchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get managerSwitchProfile;

  /// No description provided for @managerTotalCash.
  ///
  /// In en, this message translates to:
  /// **'Total Cash'**
  String get managerTotalCash;

  /// No description provided for @managerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get managerAll;

  /// No description provided for @managerFilterByState.
  ///
  /// In en, this message translates to:
  /// **'Filter by state:'**
  String get managerFilterByState;

  /// No description provided for @managerChangeBranch.
  ///
  /// In en, this message translates to:
  /// **'Change Branch'**
  String get managerChangeBranch;

  /// No description provided for @managerAssignToBranch.
  ///
  /// In en, this message translates to:
  /// **'Assign to Branch'**
  String get managerAssignToBranch;

  /// No description provided for @managerBranchUpdated.
  ///
  /// In en, this message translates to:
  /// **'Branch updated'**
  String get managerBranchUpdated;

  /// No description provided for @managerBranchUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String managerBranchUpdateFailed(Object error);

  /// No description provided for @menuPurchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get menuPurchaseInvoice;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get aboutAppSection;

  /// No description provided for @aboutReleaseSection.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get aboutReleaseSection;

  /// No description provided for @aboutShorebirdSection.
  ///
  /// In en, this message translates to:
  /// **'Shorebird'**
  String get aboutShorebirdSection;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get aboutAppName;

  /// No description provided for @aboutPackageName.
  ///
  /// In en, this message translates to:
  /// **'Package name'**
  String get aboutPackageName;

  /// No description provided for @aboutPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get aboutPlatform;

  /// No description provided for @aboutEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get aboutEnvironment;

  /// No description provided for @aboutBuildName.
  ///
  /// In en, this message translates to:
  /// **'Build name'**
  String get aboutBuildName;

  /// No description provided for @aboutBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get aboutBuildNumber;

  /// No description provided for @aboutReleaseId.
  ///
  /// In en, this message translates to:
  /// **'Release ID'**
  String get aboutReleaseId;

  /// No description provided for @aboutReleaseDist.
  ///
  /// In en, this message translates to:
  /// **'Release dist'**
  String get aboutReleaseDist;

  /// No description provided for @aboutPatchNumber.
  ///
  /// In en, this message translates to:
  /// **'Patch number'**
  String get aboutPatchNumber;

  /// No description provided for @aboutPatchStatus.
  ///
  /// In en, this message translates to:
  /// **'Patch status'**
  String get aboutPatchStatus;

  /// No description provided for @aboutLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked'**
  String get aboutLastChecked;

  /// No description provided for @aboutNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get aboutNotAvailable;

  /// No description provided for @aboutPatchNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Base release only'**
  String get aboutPatchNotInstalled;

  /// No description provided for @aboutPatchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable on this platform'**
  String get aboutPatchUnavailable;

  /// No description provided for @aboutPatchStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get aboutPatchStatusUpToDate;

  /// No description provided for @aboutPatchStatusUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get aboutPatchStatusUpdateAvailable;

  /// No description provided for @aboutPatchStatusRestartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart required'**
  String get aboutPatchStatusRestartRequired;

  /// No description provided for @aboutPatchStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get aboutPatchStatusUnavailable;

  /// No description provided for @aboutPatchStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get aboutPatchStatusUnknown;

  /// No description provided for @aboutPatchStatusUnknownDetail.
  ///
  /// In en, this message translates to:
  /// **'Patch check error'**
  String get aboutPatchStatusUnknownDetail;

  /// No description provided for @aboutRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get aboutRefresh;

  /// No description provided for @aboutCopyDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get aboutCopyDiagnostics;

  /// No description provided for @aboutCopiedDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied'**
  String get aboutCopiedDiagnostics;

  /// No description provided for @aboutRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get aboutRetry;

  /// No description provided for @aboutError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String aboutError(Object error);

  /// No description provided for @menuManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get menuManufacturing;

  /// No description provided for @menuStockTransfer.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer'**
  String get menuStockTransfer;

  /// No description provided for @menuCashTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cash Transfer'**
  String get menuCashTransfer;

  /// No description provided for @cashTransferFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get cashTransferFromAccount;

  /// No description provided for @cashTransferToAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get cashTransferToAccount;

  /// No description provided for @cashTransferPostingToday.
  ///
  /// In en, this message translates to:
  /// **'Posting: Today'**
  String get cashTransferPostingToday;

  /// No description provided for @cashTransferPostingDate.
  ///
  /// In en, this message translates to:
  /// **'Posting: {date}'**
  String cashTransferPostingDate(Object date);

  /// No description provided for @cashTransferRemarkOptional.
  ///
  /// In en, this message translates to:
  /// **'Remark (optional)'**
  String get cashTransferRemarkOptional;

  /// No description provided for @cashTransferFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get cashTransferFrom;

  /// No description provided for @cashTransferTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get cashTransferTo;

  /// No description provided for @cashTransferAccountsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Accounts must differ'**
  String get cashTransferAccountsMustDiffer;

  /// No description provided for @cashTransferSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get cashTransferSelectAccount;

  /// No description provided for @cashTransferBefore.
  ///
  /// In en, this message translates to:
  /// **'Before: {amount}'**
  String cashTransferBefore(Object amount);

  /// No description provided for @cashTransferAfter.
  ///
  /// In en, this message translates to:
  /// **'After: {amount}'**
  String cashTransferAfter(Object amount);

  /// No description provided for @cashTransferNoAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found'**
  String get cashTransferNoAccountsFound;

  /// No description provided for @cashTransferJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry: {entry}'**
  String cashTransferJournalEntry(Object entry);

  /// No description provided for @cashTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String cashTransferFailed(Object error);

  /// No description provided for @postingDateConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm posting date'**
  String get postingDateConfirmationTitle;

  /// No description provided for @postingDateConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the posting date before submitting.'**
  String get postingDateConfirmationMessage;

  /// No description provided for @postingDateConfirmationDate.
  ///
  /// In en, this message translates to:
  /// **'Posting date: {date}'**
  String postingDateConfirmationDate(Object date);

  /// No description provided for @postingDateConfirmationDates.
  ///
  /// In en, this message translates to:
  /// **'Posting dates:'**
  String get postingDateConfirmationDates;

  /// No description provided for @menuInventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get menuInventoryCount;

  /// No description provided for @inventoryCountOfflineUsingCache.
  ///
  /// In en, this message translates to:
  /// **'Offline using cached data'**
  String get inventoryCountOfflineUsingCache;

  /// No description provided for @inventoryCountConfirmAllBeforeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Please confirm all items before submitting ({remaining} remaining)'**
  String inventoryCountConfirmAllBeforeSubmit(int remaining);

  /// No description provided for @inventoryCountConfirmAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Confirm at least one item before submitting'**
  String get inventoryCountConfirmAtLeastOne;

  /// No description provided for @inventoryCountSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {result}'**
  String inventoryCountSubmitted(Object result);

  /// No description provided for @inventoryCountNoDifferences.
  ///
  /// In en, this message translates to:
  /// **'No differences'**
  String get inventoryCountNoDifferences;

  /// No description provided for @inventoryCountUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get inventoryCountUncategorized;

  /// No description provided for @inventoryCountManagerAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager access required'**
  String get inventoryCountManagerAccessRequired;

  /// No description provided for @inventoryCountSelectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Select Warehouse'**
  String get inventoryCountSelectWarehouse;

  /// No description provided for @inventoryCountEnforceAll.
  ///
  /// In en, this message translates to:
  /// **'Enforce all'**
  String get inventoryCountEnforceAll;

  /// No description provided for @inventoryCountConfirmedProgress.
  ///
  /// In en, this message translates to:
  /// **'Confirmed {confirmed} / {total}'**
  String inventoryCountConfirmedProgress(int confirmed, int total);

  /// No description provided for @inventoryCountClearAllEnteredData.
  ///
  /// In en, this message translates to:
  /// **'Clear all entered data'**
  String get inventoryCountClearAllEnteredData;

  /// No description provided for @inventoryCountAllEnteredDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All entered data cleared'**
  String get inventoryCountAllEnteredDataCleared;

  /// No description provided for @inventoryCountCurrentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current: {amount} {uom}'**
  String inventoryCountCurrentAmount(Object amount, Object uom);

  /// No description provided for @inventoryCountDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get inventoryCountDecrease;

  /// No description provided for @inventoryCountCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get inventoryCountCount;

  /// No description provided for @inventoryCountIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get inventoryCountIncrease;

  /// No description provided for @inventoryCountValuation.
  ///
  /// In en, this message translates to:
  /// **'Valuation: {amount} / {uom}'**
  String inventoryCountValuation(Object amount, Object uom);

  /// No description provided for @inventoryCountDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Delta: '**
  String get inventoryCountDeltaLabel;

  /// No description provided for @inventoryCountSubmitCount.
  ///
  /// In en, this message translates to:
  /// **'Submit Count'**
  String get inventoryCountSubmitCount;

  /// No description provided for @inventoryCountSetupStep.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get inventoryCountSetupStep;

  /// No description provided for @inventoryCountBlindEntryStep.
  ///
  /// In en, this message translates to:
  /// **'Blind entry'**
  String get inventoryCountBlindEntryStep;

  /// No description provided for @inventoryCountReviewStep.
  ///
  /// In en, this message translates to:
  /// **'Review discrepancies'**
  String get inventoryCountReviewStep;

  /// No description provided for @inventoryCountSpotCount.
  ///
  /// In en, this message translates to:
  /// **'Spot count'**
  String get inventoryCountSpotCount;

  /// No description provided for @inventoryCountSpotCountDescription.
  ///
  /// In en, this message translates to:
  /// **'Submit only the items you counted.'**
  String get inventoryCountSpotCountDescription;

  /// No description provided for @inventoryCountFullWarehouseCountDescription.
  ///
  /// In en, this message translates to:
  /// **'Count every loaded item before final submit.'**
  String get inventoryCountFullWarehouseCountDescription;

  /// No description provided for @inventoryCountWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryCountWarehouseLabel;

  /// No description provided for @inventoryCountPostingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Posting date'**
  String get inventoryCountPostingDateLabel;

  /// No description provided for @inventoryCountCountModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Count mode'**
  String get inventoryCountCountModeLabel;

  /// No description provided for @inventoryCountContinueCount.
  ///
  /// In en, this message translates to:
  /// **'Continue count'**
  String get inventoryCountContinueCount;

  /// No description provided for @inventoryCountStartCount.
  ///
  /// In en, this message translates to:
  /// **'Start count'**
  String get inventoryCountStartCount;

  /// No description provided for @inventoryCountBackToSetup.
  ///
  /// In en, this message translates to:
  /// **'Back to setup'**
  String get inventoryCountBackToSetup;

  /// No description provided for @inventoryCountReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review discrepancies'**
  String get inventoryCountReviewButton;

  /// No description provided for @inventoryCountBackToCounting.
  ///
  /// In en, this message translates to:
  /// **'Back to counting'**
  String get inventoryCountBackToCounting;

  /// No description provided for @inventoryCountFilteredItems.
  ///
  /// In en, this message translates to:
  /// **'{visible} of {total} items'**
  String inventoryCountFilteredItems(int visible, int total);

  /// No description provided for @inventoryCountCountedStatus.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get inventoryCountCountedStatus;

  /// No description provided for @inventoryCountPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get inventoryCountPendingStatus;

  /// No description provided for @inventoryCountClearEntry.
  ///
  /// In en, this message translates to:
  /// **'Clear entry'**
  String get inventoryCountClearEntry;

  /// No description provided for @inventoryCountSummaryCountedItems.
  ///
  /// In en, this message translates to:
  /// **'Counted items'**
  String get inventoryCountSummaryCountedItems;

  /// No description provided for @inventoryCountSummaryChangedItems.
  ///
  /// In en, this message translates to:
  /// **'Changed items'**
  String get inventoryCountSummaryChangedItems;

  /// No description provided for @inventoryCountSummaryMissingItems.
  ///
  /// In en, this message translates to:
  /// **'Missing items'**
  String get inventoryCountSummaryMissingItems;

  /// No description provided for @inventoryCountReviewDiscrepancies.
  ///
  /// In en, this message translates to:
  /// **'Discrepancies'**
  String get inventoryCountReviewDiscrepancies;

  /// No description provided for @inventoryCountReviewNoCountedItems.
  ///
  /// In en, this message translates to:
  /// **'No counted items yet.'**
  String get inventoryCountReviewNoCountedItems;

  /// No description provided for @inventoryCountReviewNoDiscrepancies.
  ///
  /// In en, this message translates to:
  /// **'No discrepancies found yet.'**
  String get inventoryCountReviewNoDiscrepancies;

  /// No description provided for @inventoryCountReviewUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Unchanged counted items'**
  String get inventoryCountReviewUnchanged;

  /// No description provided for @inventoryCountReviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing items'**
  String get inventoryCountReviewMissing;

  /// No description provided for @inventoryCountCountedAmount.
  ///
  /// In en, this message translates to:
  /// **'Counted: {amount} {uom}'**
  String inventoryCountCountedAmount(Object amount, Object uom);

  /// No description provided for @inventoryCountStockEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Stock equivalent: {amount} {uom}'**
  String inventoryCountStockEquivalent(Object amount, Object uom);

  /// No description provided for @inventoryCountMissingItemNote.
  ///
  /// In en, this message translates to:
  /// **'Not counted yet'**
  String get inventoryCountMissingItemNote;

  /// No description provided for @inventoryCountBatchTracked.
  ///
  /// In en, this message translates to:
  /// **'Batch tracked'**
  String get inventoryCountBatchTracked;

  /// No description provided for @inventoryCountSerialTracked.
  ///
  /// In en, this message translates to:
  /// **'Serial tracked'**
  String get inventoryCountSerialTracked;

  /// No description provided for @menuEndShift.
  ///
  /// In en, this message translates to:
  /// **'End Shift'**
  String get menuEndShift;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get menuLanguageEnglish;

  /// No description provided for @menuLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get menuLanguageArabic;

  /// No description provided for @menuSelectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language: {language}'**
  String menuSelectedLanguage(Object language);

  /// No description provided for @menuConfirmLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language to {language}?'**
  String menuConfirmLanguage(Object language);

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get commonChoose;

  /// No description provided for @commonSearchItems.
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get commonSearchItems;

  /// No description provided for @commonSearchSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers'**
  String get commonSearchSuppliers;

  /// No description provided for @commonNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get commonNoItems;

  /// No description provided for @commonNoSuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers'**
  String get commonNoSuppliers;

  /// No description provided for @commonQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty:'**
  String get commonQtyLabel;

  /// No description provided for @commonRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate:'**
  String get commonRateLabel;

  /// No description provided for @commonAmountValue.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String commonAmountValue(Object amount);

  /// No description provided for @commonTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String commonTotalValue(Object amount);

  /// No description provided for @commonNameWithCode.
  ///
  /// In en, this message translates to:
  /// **'{name} ({code})'**
  String commonNameWithCode(Object code, Object name);

  /// No description provided for @commonUomLabel.
  ///
  /// In en, this message translates to:
  /// **'UOM:'**
  String get commonUomLabel;

  /// No description provided for @commonUomValue.
  ///
  /// In en, this message translates to:
  /// **'UOM: {uom}'**
  String commonUomValue(Object uom);

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get commonOnline;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get commonOffline;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String commonErrorWithDetails(Object details);

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get commonCustomerLabel;

  /// No description provided for @commonPosProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'POS Profile'**
  String get commonPosProfileLabel;

  /// No description provided for @commonTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotalLabel;

  /// No description provided for @commonAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmountLabel;

  /// No description provided for @commonDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDateLabel;

  /// No description provided for @commonCourierLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get commonCourierLabel;

  /// No description provided for @commonDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get commonDeliveryLabel;

  /// No description provided for @commonItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get commonItemsLabel;

  /// No description provided for @commonItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get commonItemLabel;

  /// No description provided for @commonNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotesLabel;

  /// No description provided for @commonPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get commonPaymentLabel;

  /// No description provided for @commonOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get commonOutstandingLabel;

  /// No description provided for @commonUploadedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploaded by'**
  String get commonUploadedByLabel;

  /// No description provided for @commonReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get commonReasonLabel;

  /// No description provided for @ofdShortageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve stock shortage for dispatch'**
  String get ofdShortageDialogTitle;

  /// No description provided for @ofdShortageDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'These items are short at the dispatch warehouse. Add a reason to continue the Out For Delivery move.'**
  String get ofdShortageDialogMessage;

  /// No description provided for @ofdShortageLine.
  ///
  /// In en, this message translates to:
  /// **'{item}: required {required}, available {available}, warehouse {warehouse}'**
  String ofdShortageLine(
    String item,
    String required,
    String available,
    String warehouse,
  );

  /// No description provided for @ofdShortageReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why dispatch should continue despite the shortage'**
  String get ofdShortageReasonHint;

  /// No description provided for @ofdShortageReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Provide a shortage reason to continue'**
  String get ofdShortageReasonRequired;

  /// No description provided for @ofdShortageApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve and continue'**
  String get ofdShortageApprove;

  /// No description provided for @commonNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get commonNotSpecified;

  /// No description provided for @commonWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get commonWalkIn;

  /// No description provided for @commonScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get commonScheduled;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @commonPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get commonPreview;

  /// No description provided for @commonByUser.
  ///
  /// In en, this message translates to:
  /// **'by {user}'**
  String commonByUser(Object user);

  /// No description provided for @commonQtyWithUom.
  ///
  /// In en, this message translates to:
  /// **'Qty ({uom})'**
  String commonQtyWithUom(Object uom);

  /// No description provided for @orderAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'New Order: {invoiceId}'**
  String orderAlertTitle(Object invoiceId);

  /// No description provided for @orderAlertNoLineItems.
  ///
  /// In en, this message translates to:
  /// **'No line items'**
  String get orderAlertNoLineItems;

  /// No description provided for @orderAlertMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more item(s)'**
  String orderAlertMoreItems(Object count);

  /// No description provided for @orderAlertMuteAlarm.
  ///
  /// In en, this message translates to:
  /// **'Mute Alarm'**
  String get orderAlertMuteAlarm;

  /// No description provided for @orderAlertUnmuteAlarm.
  ///
  /// In en, this message translates to:
  /// **'Unmute Alarm'**
  String get orderAlertUnmuteAlarm;

  /// No description provided for @orderAlertAccepting.
  ///
  /// In en, this message translates to:
  /// **'Accepting...'**
  String get orderAlertAccepting;

  /// No description provided for @orderAlertAcceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get orderAlertAcceptOrder;

  /// No description provided for @posDraftDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get posDraftDeleteTitle;

  /// No description provided for @posDraftDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{label}\"? This cannot be undone.'**
  String posDraftDeleteBody(Object label);

  /// No description provided for @posDraftLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Draft limit reached ({max} max). Delete a draft to create a new one.'**
  String posDraftLimitReached(Object max);

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get expensesRefreshTooltip;

  /// No description provided for @expensesNewExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get expensesNewExpense;

  /// No description provided for @expensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded'**
  String get expensesRecorded;

  /// No description provided for @expensesSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Expense submitted for approval'**
  String get expensesSubmitted;

  /// No description provided for @expensesMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get expensesMonthLabel;

  /// No description provided for @expensesMonthCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get expensesMonthCurrent;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded for this month.'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptyManagerBody.
  ///
  /// In en, this message translates to:
  /// **'Use the New Expense button to log team spending.'**
  String get expensesEmptyManagerBody;

  /// No description provided for @expensesEmptyStaffBody.
  ///
  /// In en, this message translates to:
  /// **'Submit a request and a manager will review it shortly.'**
  String get expensesEmptyStaffBody;

  /// No description provided for @expensesFiltersClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get expensesFiltersClear;

  /// No description provided for @expensesFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by payment method'**
  String get expensesFiltersTitle;

  /// No description provided for @expensesFiltersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payment sources available'**
  String get expensesFiltersEmpty;

  /// No description provided for @expensesSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get expensesSummaryTotal;

  /// No description provided for @expensesSummaryApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get expensesSummaryApproved;

  /// No description provided for @expensesSummaryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get expensesSummaryPending;

  /// No description provided for @expensesSummaryReceipts.
  ///
  /// In en, this message translates to:
  /// **'{count} receipts'**
  String expensesSummaryReceipts(Object count);

  /// No description provided for @expensesSummaryPendingAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} | {amount}'**
  String expensesSummaryPendingAmount(Object amount, Object count);

  /// No description provided for @expensesReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (Indirect expense account)'**
  String get expensesReasonLabel;

  /// No description provided for @expensesPayFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get expensesPayFromLabel;

  /// No description provided for @expensesAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expensesAmountLabel;

  /// No description provided for @expensesAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get expensesAmountHint;

  /// No description provided for @expensesAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get expensesAmountInvalid;

  /// No description provided for @expensesDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expensesDateLabel;

  /// No description provided for @expensesReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get expensesReasonRequired;

  /// No description provided for @expensesPaymentSourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a payment source'**
  String get expensesPaymentSourceRequired;

  /// No description provided for @expensesRemarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks (optional)'**
  String get expensesRemarksLabel;

  /// No description provided for @expensesSubmitManager.
  ///
  /// In en, this message translates to:
  /// **'Record expense'**
  String get expensesSubmitManager;

  /// No description provided for @expensesSubmitStaff.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval'**
  String get expensesSubmitStaff;

  /// No description provided for @expensesNoOptions.
  ///
  /// In en, this message translates to:
  /// **'Expenses cannot be created until a reason and payment source are available.'**
  String get expensesNoOptions;

  /// No description provided for @expensesApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get expensesApprove;

  /// No description provided for @expensesPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get expensesPendingStatus;

  /// No description provided for @expensesApprovedStatus.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get expensesApprovedStatus;

  /// No description provided for @expensesDraftStatus.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get expensesDraftStatus;

  /// No description provided for @expensesJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get expensesJournalEntry;

  /// No description provided for @expensesPosProfile.
  ///
  /// In en, this message translates to:
  /// **'POS Profile'**
  String get expensesPosProfile;

  /// No description provided for @expensesPayingAccount.
  ///
  /// In en, this message translates to:
  /// **'Paying account'**
  String get expensesPayingAccount;

  /// No description provided for @expensesReasonAccount.
  ///
  /// In en, this message translates to:
  /// **'Expense account'**
  String get expensesReasonAccount;

  /// No description provided for @expensesTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get expensesTimelineTitle;

  /// No description provided for @expensesTimelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No timeline available'**
  String get expensesTimelineEmpty;

  /// No description provided for @expensesPullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get expensesPullToRefresh;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}.'**
  String languageChanged(Object language);

  /// No description provided for @purchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get purchaseTitle;

  /// No description provided for @purchaseSupplierSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get purchaseSupplierSectionTitle;

  /// No description provided for @purchaseTapToPickSupplier.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick supplier'**
  String get purchaseTapToPickSupplier;

  /// No description provided for @purchaseItemsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get purchaseItemsSectionTitle;

  /// No description provided for @purchaseShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping (Freight & Forwarding):'**
  String get purchaseShippingLabel;

  /// No description provided for @purchaseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Invoice'**
  String get purchaseSubmit;

  /// No description provided for @purchaseSelectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get purchaseSelectSupplier;

  /// No description provided for @purchaseRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get purchaseRecent;

  /// No description provided for @purchaseSupplierDisabledSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Disabled)'**
  String get purchaseSupplierDisabledSuffix;

  /// No description provided for @purchaseNoItemsInCart.
  ///
  /// In en, this message translates to:
  /// **'No items in cart'**
  String get purchaseNoItemsInCart;

  /// No description provided for @purchaseCreated.
  ///
  /// In en, this message translates to:
  /// **'Purchase created: {invoice}'**
  String purchaseCreated(Object invoice);

  /// No description provided for @purchaseSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseSubmitFailed(Object error);

  /// No description provided for @purchaseSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Source'**
  String get purchaseSelectPayment;

  /// No description provided for @purchasePaymentProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use exact-named POS Profile cash account'**
  String get purchasePaymentProfileSubtitle;

  /// No description provided for @purchasePaymentInstapayTitle.
  ///
  /// In en, this message translates to:
  /// **'InstaPay (Bank)'**
  String get purchasePaymentInstapayTitle;

  /// No description provided for @purchasePaymentInstapaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use bank account mapped to InstaPay'**
  String get purchasePaymentInstapaySubtitle;

  /// No description provided for @purchasePaymentCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get purchasePaymentCashTitle;

  /// No description provided for @purchasePaymentCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use company default Cash account'**
  String get purchasePaymentCashSubtitle;

  /// No description provided for @posProfileSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select POS Profile'**
  String get posProfileSelectionTitle;

  /// No description provided for @posProfileSelectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading POS profiles'**
  String get posProfileSelectionErrorTitle;

  /// No description provided for @posProfileSelectionNoProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'No POS Profiles Available'**
  String get posProfileSelectionNoProfilesTitle;

  /// No description provided for @posProfileSelectionNoProfilesBody.
  ///
  /// In en, this message translates to:
  /// **'Contact your administrator to assign you to a POS profile'**
  String get posProfileSelectionNoProfilesBody;

  /// No description provided for @posProfileSelectionUnknownProfile.
  ///
  /// In en, this message translates to:
  /// **'Unknown Profile'**
  String get posProfileSelectionUnknownProfile;

  /// No description provided for @posProfileSelectionWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse: {warehouse}'**
  String posProfileSelectionWarehouseLabel(Object warehouse);

  /// No description provided for @posProfileSelectionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a POS profile:'**
  String get posProfileSelectionPrompt;

  /// No description provided for @posProfileSelectionCycleHint.
  ///
  /// In en, this message translates to:
  /// **'Select POS'**
  String get posProfileSelectionCycleHint;

  /// No description provided for @posProfileSelectionShortFallback.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get posProfileSelectionShortFallback;

  /// No description provided for @shiftStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get shiftStartTitle;

  /// No description provided for @shiftEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End Shift'**
  String get shiftEndTitle;

  /// No description provided for @shiftNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active shift found.'**
  String get shiftNoActive;

  /// No description provided for @shiftBackToPos.
  ///
  /// In en, this message translates to:
  /// **'Back to POS'**
  String get shiftBackToPos;

  /// No description provided for @shiftOpeningPrompt.
  ///
  /// In en, this message translates to:
  /// **'Count opening cash and enter it:'**
  String get shiftOpeningPrompt;

  /// No description provided for @shiftPosProfile.
  ///
  /// In en, this message translates to:
  /// **'POS Profile: {profile}'**
  String shiftPosProfile(Object profile);

  /// No description provided for @shiftAccount.
  ///
  /// In en, this message translates to:
  /// **'Account: {account}'**
  String shiftAccount(Object account);

  /// No description provided for @shiftSystemBalance.
  ///
  /// In en, this message translates to:
  /// **'System Balance: {amount}'**
  String shiftSystemBalance(Object amount);

  /// No description provided for @shiftConfirmedOpeningAmount.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Opening Amount'**
  String get shiftConfirmedOpeningAmount;

  /// No description provided for @shiftCountedOpeningAmount.
  ///
  /// In en, this message translates to:
  /// **'Counted Opening Cash'**
  String get shiftCountedOpeningAmount;

  /// No description provided for @shiftDifferenceAmount.
  ///
  /// In en, this message translates to:
  /// **'Difference: {amount}'**
  String shiftDifferenceAmount(Object amount);

  /// No description provided for @shiftClosingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Count closing cash and enter it:'**
  String get shiftClosingPrompt;

  /// No description provided for @shiftClosingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing Amount'**
  String get shiftClosingAmountLabel;

  /// No description provided for @shiftCountedClosingAmount.
  ///
  /// In en, this message translates to:
  /// **'Counted Closing Cash'**
  String get shiftCountedClosingAmount;

  /// No description provided for @shiftBlindCountHint.
  ///
  /// In en, this message translates to:
  /// **'Count the cash in the drawer and enter the amount.'**
  String get shiftBlindCountHint;

  /// No description provided for @shiftNoClosingPaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash entry is unavailable'**
  String get shiftNoClosingPaymentMethodsTitle;

  /// No description provided for @shiftNoClosingPaymentMethodsBody.
  ///
  /// In en, this message translates to:
  /// **'No closing payment method is available for this shift. Reopen the shift or contact support.'**
  String get shiftNoClosingPaymentMethodsBody;

  /// No description provided for @shiftCashCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the counted cash amount.'**
  String get shiftCashCountRequired;

  /// No description provided for @shiftCashCountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid cash amount.'**
  String get shiftCashCountInvalid;

  /// No description provided for @shiftCashCountNegative.
  ///
  /// In en, this message translates to:
  /// **'Cash amount cannot be negative.'**
  String get shiftCashCountNegative;

  /// No description provided for @shiftExpectedAmount.
  ///
  /// In en, this message translates to:
  /// **'Expected: {amount}'**
  String shiftExpectedAmount(Object amount);

  /// No description provided for @shiftLoadActiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load active shift: {error}'**
  String shiftLoadActiveFailed(Object error);

  /// No description provided for @shiftSummaryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load shift summary.'**
  String get shiftSummaryLoadFailed;

  /// No description provided for @shiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift: {shift}'**
  String shiftLabel(Object shift);

  /// No description provided for @shiftUnexpectedStartResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server response while starting the shift.'**
  String get shiftUnexpectedStartResponse;

  /// No description provided for @shiftUnexpectedSummaryResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server response while loading the shift summary.'**
  String get shiftUnexpectedSummaryResponse;

  /// No description provided for @shiftUnexpectedEndResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server response while ending the shift.'**
  String get shiftUnexpectedEndResponse;

  /// No description provided for @shiftCourierBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Settle courier balances before ending the shift'**
  String get shiftCourierBlockTitle;

  /// No description provided for @shiftCourierBlockBody.
  ///
  /// In en, this message translates to:
  /// **'This shift still has {transactions} unsettled courier transaction(s) for {couriers} courier(s) across {invoices} invoice(s) on POS Profile {profile}.'**
  String shiftCourierBlockBody(
    int transactions,
    int couriers,
    int invoices,
    Object profile,
  );

  /// No description provided for @shiftCourierBlockHint.
  ///
  /// In en, this message translates to:
  /// **'Open courier balances, settle what is still pending, then come back to finish the shift.'**
  String get shiftCourierBlockHint;

  /// No description provided for @shiftCourierReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review & Settle Couriers'**
  String get shiftCourierReviewButton;

  /// No description provided for @shiftCourierBlockPartySummary.
  ///
  /// In en, this message translates to:
  /// **'{name}: {transactions} transaction(s) on {invoices} invoice(s)'**
  String shiftCourierBlockPartySummary(
    Object name,
    int transactions,
    int invoices,
  );

  /// No description provided for @shiftCourierBlockNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance: {amount}'**
  String shiftCourierBlockNetBalance(Object amount);

  /// No description provided for @shiftCourierBlockMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more courier(s)'**
  String shiftCourierBlockMore(int count);

  /// No description provided for @shiftOutflows.
  ///
  /// In en, this message translates to:
  /// **'Outflows: {amount}'**
  String shiftOutflows(Object amount);

  /// No description provided for @shiftNetMovement.
  ///
  /// In en, this message translates to:
  /// **'Net Movement: {amount}'**
  String shiftNetMovement(Object amount);

  /// No description provided for @shiftAccountMovements.
  ///
  /// In en, this message translates to:
  /// **'Account Movements'**
  String get shiftAccountMovements;

  /// No description provided for @shiftOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get shiftOther;

  /// No description provided for @shiftSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: {amount}'**
  String shiftSubtotal(Object amount);

  /// No description provided for @shiftInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices: {count}'**
  String shiftInvoices(Object count);

  /// No description provided for @shiftGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total: {amount}'**
  String shiftGrandTotal(Object amount);

  /// No description provided for @shiftStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get shiftStartButton;

  /// No description provided for @shiftEndButton.
  ///
  /// In en, this message translates to:
  /// **'End Shift'**
  String get shiftEndButton;

  /// No description provided for @shiftEndedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shift ended successfully.'**
  String get shiftEndedSuccess;

  /// No description provided for @shiftStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Shift Active'**
  String get shiftStatusActive;

  /// No description provided for @shiftStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started at {time}'**
  String shiftStartedAt(Object time);

  /// No description provided for @shiftProfileMismatch.
  ///
  /// In en, this message translates to:
  /// **'Active shift is on {activeProfile}. Selected profile is {selectedProfile}.'**
  String shiftProfileMismatch(Object activeProfile, Object selectedProfile);

  /// No description provided for @shiftAlreadyOpenByAnotherTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Already Open'**
  String get shiftAlreadyOpenByAnotherTitle;

  /// No description provided for @shiftAlreadyOpenByAnotherBody.
  ///
  /// In en, this message translates to:
  /// **'POS Profile \"{branch}\" already has an open shift started by {user}. That shift must be closed before you can start a new one.'**
  String shiftAlreadyOpenByAnotherBody(Object branch, Object user);

  /// No description provided for @shiftRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get shiftRefresh;

  /// No description provided for @shiftLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get shiftLogout;

  /// No description provided for @shiftSwitchToActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch to active shift profile'**
  String get shiftSwitchToActiveProfile;

  /// No description provided for @shiftOpenOnOtherProfile.
  ///
  /// In en, this message translates to:
  /// **'You have an open shift ({shiftName}) on profile \"{otherProfile}\". Close that shift before starting a new one here.'**
  String shiftOpenOnOtherProfile(Object otherProfile, Object shiftName);

  /// No description provided for @shiftGoToEnd.
  ///
  /// In en, this message translates to:
  /// **'Go to End Shift'**
  String get shiftGoToEnd;

  /// No description provided for @shiftAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get shiftAccountBalance;

  /// No description provided for @shiftDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get shiftDifference;

  /// No description provided for @shiftSalesInvoices.
  ///
  /// In en, this message translates to:
  /// **'Sales Invoices'**
  String get shiftSalesInvoices;

  /// No description provided for @shiftNoDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'No status'**
  String get shiftNoDeliveryStatus;

  /// No description provided for @shiftClosedSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Summary'**
  String get shiftClosedSummaryTitle;

  /// No description provided for @shiftClosingEntry.
  ///
  /// In en, this message translates to:
  /// **'Closing Entry'**
  String get shiftClosingEntry;

  /// No description provided for @shiftJournalCreated.
  ///
  /// In en, this message translates to:
  /// **'Cash discrepancy recorded'**
  String get shiftJournalCreated;

  /// No description provided for @posCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get posCartTitle;

  /// No description provided for @posCartHeader.
  ///
  /// In en, this message translates to:
  /// **'Cart ({count})'**
  String posCartHeader(Object count);

  /// No description provided for @posCartClear.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get posCartClear;

  /// No description provided for @posCartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get posCartEmptyTitle;

  /// No description provided for @posCartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add items to get started'**
  String get posCartEmptyBody;

  /// No description provided for @posCustomerUnselect.
  ///
  /// In en, this message translates to:
  /// **'Remove customer'**
  String get posCustomerUnselect;

  /// No description provided for @posCustomerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get posCustomerAdd;

  /// No description provided for @posCustomerDeliveryIncomeValue.
  ///
  /// In en, this message translates to:
  /// **'Delivery income: {amount}'**
  String posCustomerDeliveryIncomeValue(Object amount);

  /// No description provided for @posUnknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Customer'**
  String get posUnknownCustomer;

  /// No description provided for @posCartPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup (no delivery fee)'**
  String get posCartPickupTitle;

  /// No description provided for @posCartPickupDescription.
  ///
  /// In en, this message translates to:
  /// **'Customer will collect the order from branch.'**
  String get posCartPickupDescription;

  /// No description provided for @posCartDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Deliver to customer at selected time.'**
  String get posCartDeliveryDescription;

  /// No description provided for @posCartPickupChip.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get posCartPickupChip;

  /// No description provided for @posCartPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manager Pricing'**
  String get posCartPricingTitle;

  /// No description provided for @posCartPriceListLabel.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get posCartPriceListLabel;

  /// No description provided for @posCartPriceListHint.
  ///
  /// In en, this message translates to:
  /// **'Use the profile default or switch to a B2B list.'**
  String get posCartPriceListHint;

  /// No description provided for @posCartPriceListDefaultChip.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get posCartPriceListDefaultChip;

  /// No description provided for @posCartOrderPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order purpose'**
  String get posCartOrderPurposeLabel;

  /// No description provided for @posCartOrderPurposeHint.
  ///
  /// In en, this message translates to:
  /// **'Apply a commercial policy or keep this a standard order.'**
  String get posCartOrderPurposeHint;

  /// No description provided for @posCartOrderPurposeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get posCartOrderPurposeStandard;

  /// No description provided for @posCartOrderPurposeWaivesShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping income waived'**
  String get posCartOrderPurposeWaivesShipping;

  /// No description provided for @posCartOrderPurposeNoCourier.
  ///
  /// In en, this message translates to:
  /// **'No courier expense'**
  String get posCartOrderPurposeNoCourier;

  /// No description provided for @posCartOrderPurposeReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get posCartOrderPurposeReasonLabel;

  /// No description provided for @posCartOrderPurposeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note explaining why this purpose applies.'**
  String get posCartOrderPurposeReasonHint;

  /// No description provided for @posCartZeroShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Zero shipping income'**
  String get posCartZeroShippingTitle;

  /// No description provided for @posCartZeroShippingDescription.
  ///
  /// In en, this message translates to:
  /// **'Do not charge shipping income on this order.'**
  String get posCartZeroShippingDescription;

  /// No description provided for @posCartZeroShippingPriceListDefault.
  ///
  /// In en, this message translates to:
  /// **'Enabled automatically for this price list.'**
  String get posCartZeroShippingPriceListDefault;

  /// No description provided for @posCartZeroShippingManagedByPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup already disables delivery charges.'**
  String get posCartZeroShippingManagedByPickup;

  /// No description provided for @posCartZeroShippingManagedByPartner.
  ///
  /// In en, this message translates to:
  /// **'Sales partner orders already suppress shipping income.'**
  String get posCartZeroShippingManagedByPartner;

  /// No description provided for @posSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal:'**
  String get posSubtotalLabel;

  /// No description provided for @posDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery:'**
  String get posDeliveryLabel;

  /// No description provided for @posTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get posTotalLabel;

  /// No description provided for @posCheckoutButton.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get posCheckoutButton;

  /// No description provided for @posCheckoutStockExceedTitle.
  ///
  /// In en, this message translates to:
  /// **'Items exceed available stock'**
  String get posCheckoutStockExceedTitle;

  /// No description provided for @posCheckoutStockExceedMessage.
  ///
  /// In en, this message translates to:
  /// **'The following cart items exceed current system stock. The order can still be created, but fulfillment may need incoming stock or inventory correction.'**
  String get posCheckoutStockExceedMessage;

  /// No description provided for @posCheckoutStockExceedLine.
  ///
  /// In en, this message translates to:
  /// **'{item}: requested {requested}, available {available}'**
  String posCheckoutStockExceedLine(
    String item,
    String requested,
    String available,
  );

  /// No description provided for @posCheckoutProceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed with order'**
  String get posCheckoutProceedAnyway;

  /// No description provided for @posTerritoryMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Mismatch'**
  String get posTerritoryMismatchTitle;

  /// No description provided for @posTerritoryMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'The customer\'\'s territory is mapped to a different POS profile.'**
  String get posTerritoryMismatchBody;

  /// No description provided for @posTerritoryMismatchUseSelected.
  ///
  /// In en, this message translates to:
  /// **'Keep selected: {profile}'**
  String posTerritoryMismatchUseSelected(String profile);

  /// No description provided for @posTerritoryMismatchUseTerritory.
  ///
  /// In en, this message translates to:
  /// **'Switch to territory profile: {profile}'**
  String posTerritoryMismatchUseTerritory(String profile);

  /// No description provided for @posTerritoryMismatchNoTerritory.
  ///
  /// In en, this message translates to:
  /// **'No territory profile assigned - keep selected: {profile}'**
  String posTerritoryMismatchNoTerritory(String profile);

  /// No description provided for @posTerritoryMismatchCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get posTerritoryMismatchCancel;

  /// No description provided for @posTerritoryMismatchConfirm.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get posTerritoryMismatchConfirm;

  /// No description provided for @posAmendmentDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Amendment'**
  String get posAmendmentDraftButton;

  /// No description provided for @posOperationalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational Info'**
  String get posOperationalInfoTitle;

  /// No description provided for @posDeliveryExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Expense:'**
  String get posDeliveryExpenseLabel;

  /// No description provided for @posDeliveryCostTo.
  ///
  /// In en, this message translates to:
  /// **'Cost to {territory}'**
  String posDeliveryCostTo(Object territory);

  /// No description provided for @posDeliveryCostGeneric.
  ///
  /// In en, this message translates to:
  /// **'Cost to deliver'**
  String get posDeliveryCostGeneric;

  /// No description provided for @posUnknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get posUnknownItem;

  /// No description provided for @posCartEditBundle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bundle'**
  String get posCartEditBundle;

  /// No description provided for @posCartItemPricingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit line pricing'**
  String get posCartItemPricingDialogTitle;

  /// No description provided for @posCartItemPricingBaseRate.
  ///
  /// In en, this message translates to:
  /// **'Current catalog rate: {amount}'**
  String posCartItemPricingBaseRate(String amount);

  /// No description provided for @posCartItemPricingCustomRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom unit price'**
  String get posCartItemPricingCustomRateLabel;

  /// No description provided for @posCartItemPricingDiscountAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount amount'**
  String get posCartItemPricingDiscountAmountLabel;

  /// No description provided for @posCartItemPricingDiscountPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount percentage'**
  String get posCartItemPricingDiscountPercentLabel;

  /// No description provided for @posCartItemPricingDiscountHint.
  ///
  /// In en, this message translates to:
  /// **'Use discount amount or discount percentage, not both.'**
  String get posCartItemPricingDiscountHint;

  /// No description provided for @posCartItemPricingReset.
  ///
  /// In en, this message translates to:
  /// **'Reset pricing'**
  String get posCartItemPricingReset;

  /// No description provided for @posCartItemPricingSave.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get posCartItemPricingSave;

  /// No description provided for @posCartItemCustomPriceApplied.
  ///
  /// In en, this message translates to:
  /// **'Custom {amount}'**
  String posCartItemCustomPriceApplied(String amount);

  /// No description provided for @posCartItemDiscountAmountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount {amount}'**
  String posCartItemDiscountAmountApplied(String amount);

  /// No description provided for @posCartItemDiscountPercentApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount {amount}%'**
  String posCartItemDiscountPercentApplied(String amount);

  /// No description provided for @posCartItemPricingInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get posCartItemPricingInvalidNumber;

  /// No description provided for @posCartItemPricingInvalidCustomRate.
  ///
  /// In en, this message translates to:
  /// **'Custom price must be zero or more.'**
  String get posCartItemPricingInvalidCustomRate;

  /// No description provided for @posCartItemPricingInvalidDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount amount must be zero or more.'**
  String get posCartItemPricingInvalidDiscountAmount;

  /// No description provided for @posCartItemPricingInvalidDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount percentage must be between 0 and 100.'**
  String get posCartItemPricingInvalidDiscountPercent;

  /// No description provided for @posCartItemPricingChooseSingleDiscount.
  ///
  /// In en, this message translates to:
  /// **'Use discount amount or discount percentage, not both.'**
  String get posCartItemPricingChooseSingleDiscount;

  /// No description provided for @posCartItemPricingDiscountTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Discount amount cannot exceed the effective unit price.'**
  String get posCartItemPricingDiscountTooHigh;

  /// No description provided for @posCartClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get posCartClearTitle;

  /// No description provided for @posCartClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from the cart?'**
  String get posCartClearMessage;

  /// No description provided for @posCartClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get posCartClearConfirm;

  /// No description provided for @posDeliverySelectSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery time'**
  String get posDeliverySelectSlot;

  /// No description provided for @posDeliveryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Time'**
  String get posDeliveryDialogTitle;

  /// No description provided for @posDeliveryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load delivery slots'**
  String get posDeliveryLoadFailed;

  /// No description provided for @posDeliveryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No delivery slots available'**
  String get posDeliveryEmptyTitle;

  /// No description provided for @posDeliveryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Please check the POS profile timetable configuration'**
  String get posDeliveryEmptyBody;

  /// No description provided for @posDeliveryDefaultChip.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get posDeliveryDefaultChip;

  /// No description provided for @posDeliveryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading delivery slots...'**
  String get posDeliveryLoading;

  /// No description provided for @posDeliveryFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get posDeliveryFieldLabel;

  /// No description provided for @posDeliveryErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error loading slots'**
  String get posDeliveryErrorLabel;

  /// No description provided for @posDeliveryNoSlotsLabel.
  ///
  /// In en, this message translates to:
  /// **'No slots available'**
  String get posDeliveryNoSlotsLabel;

  /// No description provided for @posDeliverySelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select delivery time'**
  String get posDeliverySelectPrompt;

  /// No description provided for @posSalesPartnerPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Partner Payment'**
  String get posSalesPartnerPaymentTitle;

  /// No description provided for @posSalesPartnerPaymentDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how the sales partner is paying for this order.'**
  String get posSalesPartnerPaymentDescription;

  /// No description provided for @posSalesPartnerPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash (collected now)'**
  String get posSalesPartnerPaymentCash;

  /// No description provided for @posSalesPartnerPaymentOnline.
  ///
  /// In en, this message translates to:
  /// **'Online (already paid)'**
  String get posSalesPartnerPaymentOnline;

  /// No description provided for @posCheckoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get posCheckoutSuccess;

  /// No description provided for @posCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order: {error}'**
  String posCheckoutFailed(Object error);

  /// No description provided for @posBundleContentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bundle Contents:'**
  String get posBundleContentsTitle;

  /// No description provided for @posBundleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bundle updated successfully!'**
  String get posBundleUpdated;

  /// No description provided for @printerStatusBle.
  ///
  /// In en, this message translates to:
  /// **'Printer: BLE'**
  String get printerStatusBle;

  /// No description provided for @printerStatusClassic.
  ///
  /// In en, this message translates to:
  /// **'Printer: Classic'**
  String get printerStatusClassic;

  /// No description provided for @printerStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Printer: Connecting…'**
  String get printerStatusConnecting;

  /// No description provided for @printerStatusError.
  ///
  /// In en, this message translates to:
  /// **'Printer Error'**
  String get printerStatusError;

  /// No description provided for @printerStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Printer: Not Connected'**
  String get printerStatusDisconnected;

  /// No description provided for @printerSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Printer'**
  String get printerSelectTitle;

  /// No description provided for @printerCompatibilityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Printer compatibility settings'**
  String get printerCompatibilityTooltip;

  /// No description provided for @printerCompatibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get printerCompatibilityTitle;

  /// No description provided for @printerCompatibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe defaults keep normal receipts as text and only use raster output where it is needed.'**
  String get printerCompatibilitySubtitle;

  /// No description provided for @printerCompatibilitySaved.
  ///
  /// In en, this message translates to:
  /// **'Printer compatibility settings saved'**
  String get printerCompatibilitySaved;

  /// No description provided for @printerCompatibilityReset.
  ///
  /// In en, this message translates to:
  /// **'Reset defaults'**
  String get printerCompatibilityReset;

  /// No description provided for @printerDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get printerDiagnosticsTitle;

  /// No description provided for @printerDiagnosticsAdapter.
  ///
  /// In en, this message translates to:
  /// **'Adapter: {state}'**
  String printerDiagnosticsAdapter(Object state);

  /// No description provided for @printerDiagnosticsScan.
  ///
  /// In en, this message translates to:
  /// **'Perm scan: {status}'**
  String printerDiagnosticsScan(Object status);

  /// No description provided for @printerDiagnosticsConnect.
  ///
  /// In en, this message translates to:
  /// **'Perm connect: {status}'**
  String printerDiagnosticsConnect(Object status);

  /// No description provided for @printerDiagnosticsLocation.
  ///
  /// In en, this message translates to:
  /// **'Perm location: {status}'**
  String printerDiagnosticsLocation(Object status);

  /// No description provided for @printerDeviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID (MAC / Identifier)'**
  String get printerDeviceIdLabel;

  /// No description provided for @printerConnectById.
  ///
  /// In en, this message translates to:
  /// **'Connect by ID'**
  String get printerConnectById;

  /// No description provided for @printerConnectingById.
  ///
  /// In en, this message translates to:
  /// **'Connecting by ID...'**
  String get printerConnectingById;

  /// No description provided for @printerConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get printerConnecting;

  /// No description provided for @printerConnected.
  ///
  /// In en, this message translates to:
  /// **'Printer connected'**
  String get printerConnected;

  /// No description provided for @printerConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect'**
  String get printerConnectionFailed;

  /// No description provided for @printerForgetSavedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Forget saved printer'**
  String get printerForgetSavedTooltip;

  /// No description provided for @printerForgotSaved.
  ///
  /// In en, this message translates to:
  /// **'Forgot saved printer'**
  String get printerForgotSaved;

  /// No description provided for @printerRescanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get printerRescanTooltip;

  /// No description provided for @printerReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get printerReconnecting;

  /// No description provided for @printerReconnected.
  ///
  /// In en, this message translates to:
  /// **'Reconnected'**
  String get printerReconnected;

  /// No description provided for @printerReconnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Reconnect failed'**
  String get printerReconnectFailed;

  /// No description provided for @printerReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get printerReconnect;

  /// No description provided for @printerConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected: {name}'**
  String printerConnectedTo(Object name);

  /// No description provided for @printerTestPrint.
  ///
  /// In en, this message translates to:
  /// **'Test Print'**
  String get printerTestPrint;

  /// No description provided for @printerTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test print sent'**
  String get printerTestSent;

  /// No description provided for @printerTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Test failed: {error}'**
  String printerTestFailed(Object error);

  /// No description provided for @printerBleDevices.
  ///
  /// In en, this message translates to:
  /// **'BLE Devices'**
  String get printerBleDevices;

  /// No description provided for @printerRescanBleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rescan BLE'**
  String get printerRescanBleTooltip;

  /// No description provided for @printerNoBleDevices.
  ///
  /// In en, this message translates to:
  /// **'No BLE devices discovered.'**
  String get printerNoBleDevices;

  /// No description provided for @printerUnknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Printer'**
  String get printerUnknownName;

  /// No description provided for @printerConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get printerConnect;

  /// No description provided for @printerClassicDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired Classic Devices'**
  String get printerClassicDevices;

  /// No description provided for @printerPaperSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Paper size'**
  String get printerPaperSizeLabel;

  /// No description provided for @printerPaper58mm.
  ///
  /// In en, this message translates to:
  /// **'58 mm'**
  String get printerPaper58mm;

  /// No description provided for @printerPaper80mm.
  ///
  /// In en, this message translates to:
  /// **'80 mm'**
  String get printerPaper80mm;

  /// No description provided for @printerPrintLogo.
  ///
  /// In en, this message translates to:
  /// **'Print logo'**
  String get printerPrintLogo;

  /// No description provided for @printerPrintLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Disable this first if the printer prints gibberish near the top of the receipt.'**
  String get printerPrintLogoHint;

  /// No description provided for @printerRasterizeArabic.
  ///
  /// In en, this message translates to:
  /// **'Rasterize Arabic text'**
  String get printerRasterizeArabic;

  /// No description provided for @printerRasterizeArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Needed for printers that cannot print Arabic natively.'**
  String get printerRasterizeArabicHint;

  /// No description provided for @printerRasterizeStyledText.
  ///
  /// In en, this message translates to:
  /// **'Rasterize styled ASCII text'**
  String get printerRasterizeStyledText;

  /// No description provided for @printerRasterizeStyledTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enable this only if your printer handles bitmap text reliably.'**
  String get printerRasterizeStyledTextHint;

  /// No description provided for @printerRasterWidthLabel.
  ///
  /// In en, this message translates to:
  /// **'Raster width (px)'**
  String get printerRasterWidthLabel;

  /// No description provided for @printerCodeTableLabel.
  ///
  /// In en, this message translates to:
  /// **'Code table'**
  String get printerCodeTableLabel;

  /// No description provided for @printerBleChunkSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'BLE chunk size'**
  String get printerBleChunkSizeLabel;

  /// No description provided for @printerBleChunkDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'BLE chunk delay (ms)'**
  String get printerBleChunkDelayLabel;

  /// No description provided for @printerClassicChunkSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Classic chunk size'**
  String get printerClassicChunkSizeLabel;

  /// No description provided for @printerClassicChunkDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Classic chunk delay (ms)'**
  String get printerClassicChunkDelayLabel;

  /// No description provided for @printerClassicTailDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Classic tail delay (ms)'**
  String get printerClassicTailDelayLabel;

  /// No description provided for @printerRefreshClassicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Classic List'**
  String get printerRefreshClassicTooltip;

  /// No description provided for @printerNoClassicDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired classic printers found. Ensure the printer is paired in System Bluetooth settings and that Location (Android 8) is enabled.'**
  String get printerNoClassicDevices;

  /// No description provided for @printerClassicMacConnected.
  ///
  /// In en, this message translates to:
  /// **'{mac}  (Classic)'**
  String printerClassicMacConnected(Object mac);

  /// No description provided for @printerDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get printerDisconnect;

  /// No description provided for @printerConnectingClassic.
  ///
  /// In en, this message translates to:
  /// **'Connecting (Classic)...'**
  String get printerConnectingClassic;

  /// No description provided for @printerLastSavedNotAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Last saved printer: {id}\nIt is not currently advertising. You can still attempt to reconnect.'**
  String printerLastSavedNotAdvertising(Object id);

  /// No description provided for @branchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Branches'**
  String get branchFilterTitle;

  /// No description provided for @branchFilterAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get branchFilterAllBranches;

  /// No description provided for @branchFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get branchFilterApply;

  /// No description provided for @websocketCollectCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect Cash'**
  String get websocketCollectCashTitle;

  /// No description provided for @websocketCollectCashMessage.
  ///
  /// In en, this message translates to:
  /// **'Collect the full order amount now from the Sales Partner courier.'**
  String get websocketCollectCashMessage;

  /// No description provided for @websocketInvoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {invoice}'**
  String websocketInvoiceLabel(Object invoice);

  /// No description provided for @systemStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get systemStatusChecking;

  /// No description provided for @systemStatusRealtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time'**
  String get systemStatusRealtime;

  /// No description provided for @systemStatusNoRealtime.
  ///
  /// In en, this message translates to:
  /// **'No real-time'**
  String get systemStatusNoRealtime;

  /// No description provided for @systemStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get systemStatusSynced;

  /// No description provided for @systemStatusPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String systemStatusPendingCount(Object count);

  /// No description provided for @systemStatusCouriers.
  ///
  /// In en, this message translates to:
  /// **'Couriers'**
  String get systemStatusCouriers;

  /// No description provided for @systemStatusCourierCount.
  ///
  /// In en, this message translates to:
  /// **'{count} couriers'**
  String systemStatusCourierCount(Object count);

  /// No description provided for @systemStatusPartnerChip.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get systemStatusPartnerChip;

  /// No description provided for @systemStatusSalesPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Sales Partner'**
  String get systemStatusSalesPartnerFallback;

  /// No description provided for @systemStatusSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync completed & couriers refreshed'**
  String get systemStatusSyncComplete;

  /// No description provided for @systemStatusForceSyncTooltip.
  ///
  /// In en, this message translates to:
  /// **'Force sync now'**
  String get systemStatusForceSyncTooltip;

  /// No description provided for @courierBalancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier Balances'**
  String get courierBalancesTitle;

  /// No description provided for @courierBalancesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No couriers found.'**
  String get courierBalancesEmpty;

  /// No description provided for @courierBalancesSettledLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get courierBalancesSettledLabel;

  /// No description provided for @courierBalancesPayCourierLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay courier'**
  String get courierBalancesPayCourierLabel;

  /// No description provided for @courierBalancesCourierPaysUsLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier pays us'**
  String get courierBalancesCourierPaysUsLabel;

  /// No description provided for @courierBalancesDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details – {courier}'**
  String courierBalancesDetailsTitle(Object courier);

  /// No description provided for @courierBalancesCityOrderLine.
  ///
  /// In en, this message translates to:
  /// **'City: {city}\nOrder: {order} • Shipping: {shipping}'**
  String courierBalancesCityOrderLine(
    Object city,
    Object order,
    Object shipping,
  );

  /// No description provided for @courierBalancesNetLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get courierBalancesNetLabel;

  /// No description provided for @courierSettlementComplete.
  ///
  /// In en, this message translates to:
  /// **'Settlement complete'**
  String get courierSettlementComplete;

  /// No description provided for @courierSettlementFailed.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed'**
  String get courierSettlementFailed;

  /// No description provided for @courierSettleButton.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get courierSettleButton;

  /// No description provided for @courierPayCourierAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay Courier {amount}'**
  String courierPayCourierAmount(Object amount);

  /// No description provided for @courierCollectAmount.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount}'**
  String courierCollectAmount(Object amount);

  /// No description provided for @courierSettleAllInvoicesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Settle all {count} invoices for this courier?'**
  String courierSettleAllInvoicesQuestion(int count);

  /// No description provided for @courierSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get courierSettled;

  /// No description provided for @courierSettleAllButton.
  ///
  /// In en, this message translates to:
  /// **'Settle All'**
  String get courierSettleAllButton;

  /// No description provided for @courierSettleAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{action} - Total {total}'**
  String courierSettleAllDialogTitle(Object action, Object total);

  /// No description provided for @courierSettleAllWillSettle.
  ///
  /// In en, this message translates to:
  /// **'This will settle {count} invoice(s).'**
  String courierSettleAllWillSettle(int count);

  /// No description provided for @courierInvoicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoices:'**
  String get courierInvoicesLabel;

  /// No description provided for @courierSettleAllCollectInfo.
  ///
  /// In en, this message translates to:
  /// **'You will collect the net amount from the courier.'**
  String get courierSettleAllCollectInfo;

  /// No description provided for @courierSettleAllPayInfo.
  ///
  /// In en, this message translates to:
  /// **'You will pay the courier the net amount now.'**
  String get courierSettleAllPayInfo;

  /// No description provided for @courierSettleAllComplete.
  ///
  /// In en, this message translates to:
  /// **'Settle All complete: {success} ok, {failed} failed'**
  String courierSettleAllComplete(int success, int failed);

  /// No description provided for @courierBalancesPreviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview settlement'**
  String get courierBalancesPreviewTooltip;

  /// No description provided for @courierBalancesPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settlement preview: {error}'**
  String courierBalancesPreviewFailed(Object error);

  /// No description provided for @settlementTitleCollectFromCourier.
  ///
  /// In en, this message translates to:
  /// **'Collect From Courier'**
  String get settlementTitleCollectFromCourier;

  /// No description provided for @settlementTitlePayCourier.
  ///
  /// In en, this message translates to:
  /// **'Pay Courier'**
  String get settlementTitlePayCourier;

  /// No description provided for @settlementTitleCourierSettlement.
  ///
  /// In en, this message translates to:
  /// **'Courier Settlement'**
  String get settlementTitleCourierSettlement;

  /// No description provided for @settlementStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get settlementStatusUnpaid;

  /// No description provided for @settlementStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get settlementStatusPaid;

  /// No description provided for @settlementPaidNoteRecent.
  ///
  /// In en, this message translates to:
  /// **' (just paid, treating as Unpaid)'**
  String get settlementPaidNoteRecent;

  /// No description provided for @settlementPaidNoteAfterOfd.
  ///
  /// In en, this message translates to:
  /// **' (after OFD)'**
  String get settlementPaidNoteAfterOfd;

  /// No description provided for @settlementPaidNoteAfterOfdUnpaid.
  ///
  /// In en, this message translates to:
  /// **' (paid after OFD, treated as Unpaid)'**
  String get settlementPaidNoteAfterOfdUnpaid;

  /// No description provided for @settlementInvoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Invoice is: {status}{note}'**
  String settlementInvoiceStatus(Object status, Object note);

  /// No description provided for @settlementOnlineUnconfirmedNote.
  ///
  /// In en, this message translates to:
  /// **'Customer pays online — the courier collected nothing. Only the shipping fee is settled here.'**
  String get settlementOnlineUnconfirmedNote;

  /// No description provided for @settlementCollectFormula.
  ///
  /// In en, this message translates to:
  /// **'Collect (Order - Shipping):'**
  String get settlementCollectFormula;

  /// No description provided for @settlementPayFormula.
  ///
  /// In en, this message translates to:
  /// **'Pay the courier (Order - Shipping):'**
  String get settlementPayFormula;

  /// No description provided for @settlementNetToCollect.
  ///
  /// In en, this message translates to:
  /// **'Net to Collect'**
  String get settlementNetToCollect;

  /// No description provided for @settlementPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay Amount'**
  String get settlementPayAmount;

  /// No description provided for @settlementNothingToSettle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay or collect.'**
  String get settlementNothingToSettle;

  /// No description provided for @settlementOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order: {amount}'**
  String settlementOrderLabel(Object amount);

  /// No description provided for @settlementShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping: {amount}'**
  String settlementShippingLabel(Object amount);

  /// No description provided for @settlementTerritoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory: {territory}'**
  String settlementTerritoryLabel(Object territory);

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderInvoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {invoice}'**
  String cancelOrderInvoiceLabel(Object invoice);

  /// No description provided for @cancelOrderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String cancelOrderTotalLabel(Object amount);

  /// No description provided for @cancelOrderOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {amount}'**
  String cancelOrderOutstandingLabel(Object amount);

  /// No description provided for @cancelOrderPartialPaymentWarning.
  ///
  /// In en, this message translates to:
  /// **'This invoice has a partial payment. Please settle or refund the payment before cancelling.'**
  String get cancelOrderPartialPaymentWarning;

  /// No description provided for @cancelOrderReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancelOrderReasonLabel;

  /// No description provided for @cancelOrderSelectReasonValidation.
  ///
  /// In en, this message translates to:
  /// **'Select a reason to continue'**
  String get cancelOrderSelectReasonValidation;

  /// No description provided for @cancelOrderProvideReasonValidation.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason'**
  String get cancelOrderProvideReasonValidation;

  /// No description provided for @cancelOrderCustomReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom reason'**
  String get cancelOrderCustomReasonLabel;

  /// No description provided for @cancelOrderDescribeReasonValidation.
  ///
  /// In en, this message translates to:
  /// **'Please describe the cancellation reason'**
  String get cancelOrderDescribeReasonValidation;

  /// No description provided for @cancelOrderAdditionalNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get cancelOrderAdditionalNotesOptional;

  /// No description provided for @cancelOrderCreditNoteInfo.
  ///
  /// In en, this message translates to:
  /// **'The payment on this order will be reversed. Hand the money back to the customer before confirming.'**
  String get cancelOrderCreditNoteInfo;

  /// No description provided for @cancelOrderConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get cancelOrderConfirmButton;

  /// No description provided for @invoicePreparingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Preparing receipt...'**
  String get invoicePreparingReceipt;

  /// No description provided for @invoiceItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String invoiceItemsCount(int count);

  /// No description provided for @invoicePrinterNotConnectedHint.
  ///
  /// In en, this message translates to:
  /// **'Printer not connected. Open Printer Selection from menu.'**
  String get invoicePrinterNotConnectedHint;

  /// No description provided for @invoicePrintedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Printed successfully'**
  String get invoicePrintedSuccessfully;

  /// No description provided for @invoicePrinterDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Printer disconnected'**
  String get invoicePrinterDisconnected;

  /// No description provided for @invoicePrintFailed.
  ///
  /// In en, this message translates to:
  /// **'Print failed: {result}'**
  String invoicePrintFailed(Object result);

  /// No description provided for @invoiceAcceptOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get invoiceAcceptOrderTitle;

  /// No description provided for @invoiceAcceptOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept order {invoice} for {customer}?'**
  String invoiceAcceptOrderQuestion(Object invoice, Object customer);

  /// No description provided for @invoiceAcceptAction.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get invoiceAcceptAction;

  /// No description provided for @invoiceOrderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order {invoice} accepted!'**
  String invoiceOrderAccepted(Object invoice);

  /// No description provided for @invoiceAcceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept order: {error}'**
  String invoiceAcceptFailed(Object error);

  /// No description provided for @invoiceMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get invoiceMoreOptions;

  /// No description provided for @invoiceAddNote.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get invoiceAddNote;

  /// No description provided for @invoiceNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Notes'**
  String get invoiceNotesTitle;

  /// No description provided for @invoiceNotesTooltip.
  ///
  /// In en, this message translates to:
  /// **'View invoice notes'**
  String get invoiceNotesTooltip;

  /// No description provided for @invoiceNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add an operational note for this invoice'**
  String get invoiceNotesHint;

  /// No description provided for @invoiceNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet for this invoice.'**
  String get invoiceNotesEmpty;

  /// No description provided for @invoiceLatestNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'LATEST NOTE'**
  String get invoiceLatestNoteLabel;

  /// No description provided for @invoiceLatestNoteLabelWithCount.
  ///
  /// In en, this message translates to:
  /// **'LATEST NOTE ({count})'**
  String invoiceLatestNoteLabelWithCount(Object count);

  /// No description provided for @invoiceLatestNoteTapToRead.
  ///
  /// In en, this message translates to:
  /// **'Tap to read the notes on this order'**
  String get invoiceLatestNoteTapToRead;

  /// No description provided for @invoiceAddingNote.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get invoiceAddingNote;

  /// No description provided for @invoiceNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get invoiceNoteAdded;

  /// No description provided for @invoiceNotesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load invoice notes: {error}'**
  String invoiceNotesLoadFailed(Object error);

  /// No description provided for @invoiceNoteAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add note: {error}'**
  String invoiceNoteAddFailed(Object error);

  /// No description provided for @invoiceEditInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get invoiceEditInvoice;

  /// No description provided for @invoiceEditInvoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the invoice draft. Please try again.'**
  String get invoiceEditInvoiceFailed;

  /// No description provided for @invoiceAmendmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Invoice amendment is not available for this order.'**
  String get invoiceAmendmentUnavailable;

  /// No description provided for @invoiceEditCustomerAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer Address'**
  String get invoiceEditCustomerAddress;

  /// No description provided for @invoiceChangeDeliverySlot.
  ///
  /// In en, this message translates to:
  /// **'Change Delivery Slot'**
  String get invoiceChangeDeliverySlot;

  /// No description provided for @invoiceTransferOrder.
  ///
  /// In en, this message translates to:
  /// **'Transfer Order'**
  String get invoiceTransferOrder;

  /// No description provided for @invoiceCancelOrderSettleFirst.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order (settle payments first)'**
  String get invoiceCancelOrderSettleFirst;

  /// No description provided for @invoiceCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get invoiceCustomerLabel;

  /// No description provided for @invoiceShippingExpenseShort.
  ///
  /// In en, this message translates to:
  /// **'Shipping Exp:'**
  String get invoiceShippingExpenseShort;

  /// No description provided for @manufacturingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get manufacturingTitle;

  /// No description provided for @manufacturingManagersOnly.
  ///
  /// In en, this message translates to:
  /// **'Managers only'**
  String get manufacturingManagersOnly;

  /// No description provided for @manufacturingRecentWorkOrdersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recent Work Orders'**
  String get manufacturingRecentWorkOrdersTooltip;

  /// No description provided for @manufacturingSearchDefaultBom.
  ///
  /// In en, this message translates to:
  /// **'Search items with Default BOM'**
  String get manufacturingSearchDefaultBom;

  /// No description provided for @manufacturingWorkOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Orders ({count})'**
  String manufacturingWorkOrdersTitle(Object count);

  /// No description provided for @manufacturingSubmitAll.
  ///
  /// In en, this message translates to:
  /// **'Submit All'**
  String get manufacturingSubmitAll;

  /// No description provided for @manufacturingNoItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get manufacturingNoItemsSelected;

  /// No description provided for @manufacturingNoItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get manufacturingNoItemsFound;

  /// No description provided for @manufacturingBomDescription.
  ///
  /// In en, this message translates to:
  /// **'BOM: {bom} • Yields {quantity} {uom}'**
  String manufacturingBomDescription(Object bom, Object quantity, Object uom);

  /// No description provided for @manufacturingBomLabel.
  ///
  /// In en, this message translates to:
  /// **'BOM x'**
  String get manufacturingBomLabel;

  /// No description provided for @manufacturingRequiredItems.
  ///
  /// In en, this message translates to:
  /// **'Required Items'**
  String get manufacturingRequiredItems;

  /// No description provided for @manufacturingNothingToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Nothing to submit.'**
  String get manufacturingNothingToSubmit;

  /// No description provided for @manufacturingSubmittingWorkOrders.
  ///
  /// In en, this message translates to:
  /// **'Submitting work orders...'**
  String get manufacturingSubmittingWorkOrders;

  /// No description provided for @manufacturingSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed: {error}'**
  String manufacturingSubmitFailed(Object error);

  /// No description provided for @manufacturingSubmitAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully'**
  String get manufacturingSubmitAllSuccess;

  /// No description provided for @manufacturingSubmitAllResult.
  ///
  /// In en, this message translates to:
  /// **'Processed {total} line(s). Success: {success}'**
  String manufacturingSubmitAllResult(Object success, Object total);

  /// No description provided for @manufacturingQuantityMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than zero'**
  String get manufacturingQuantityMustBePositive;

  /// No description provided for @manufacturingSubmittingSingleWorkOrder.
  ///
  /// In en, this message translates to:
  /// **'Submitting work order...'**
  String get manufacturingSubmittingSingleWorkOrder;

  /// No description provided for @manufacturingSubmitResult.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get manufacturingSubmitResult;

  /// No description provided for @manufacturingSubmitStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String manufacturingSubmitStatus(Object status);

  /// No description provided for @manufacturingSubmitWorkOrder.
  ///
  /// In en, this message translates to:
  /// **' • WO: {workOrder}'**
  String manufacturingSubmitWorkOrder(Object workOrder);

  /// No description provided for @manufacturingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String manufacturingLoadFailed(Object error);

  /// No description provided for @manufacturingRecentWorkOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Work Orders'**
  String get manufacturingRecentWorkOrdersTitle;

  /// No description provided for @manufacturingNoWorkOrders.
  ///
  /// In en, this message translates to:
  /// **'No Work Orders found'**
  String get manufacturingNoWorkOrders;

  /// No description provided for @manufacturingRecentWorkOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} • {status}'**
  String manufacturingRecentWorkOrderTitle(Object name, Object status);

  /// No description provided for @manufacturingRecentWorkOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{item} • {quantity} • {bom}'**
  String manufacturingRecentWorkOrderSubtitle(
    Object bom,
    Object item,
    Object quantity,
  );

  /// No description provided for @manufacturingComponentAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {quantity} {uom}'**
  String manufacturingComponentAvailable(Object quantity, Object uom);

  /// No description provided for @manufacturingInsufficientInventory.
  ///
  /// In en, this message translates to:
  /// **'Insufficient inventory'**
  String get manufacturingInsufficientInventory;

  /// No description provided for @manufacturingSubmissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Submission blocked until shortages are resolved.'**
  String get manufacturingSubmissionBlocked;

  /// No description provided for @manufacturingLineShortageSummary.
  ///
  /// In en, this message translates to:
  /// **'{item}: {components}'**
  String manufacturingLineShortageSummary(Object components, Object item);

  /// No description provided for @manufacturingComponentRequired.
  ///
  /// In en, this message translates to:
  /// **'Required: {quantity} {uom}'**
  String manufacturingComponentRequired(Object quantity, Object uom);

  /// No description provided for @manufacturingComponentMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing: {quantity} {uom}'**
  String manufacturingComponentMissing(Object quantity, Object uom);

  /// No description provided for @menuProductionBoard.
  ///
  /// In en, this message translates to:
  /// **'Production Board'**
  String get menuProductionBoard;

  /// No description provided for @productionBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Production Board'**
  String get productionBoardTitle;

  /// No description provided for @productionTabPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get productionTabPlan;

  /// No description provided for @productionTabDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get productionTabDaily;

  /// No description provided for @dailyPlanNoItems.
  ///
  /// In en, this message translates to:
  /// **'No fillable items have a default BOM yet.'**
  String get dailyPlanNoItems;

  /// No description provided for @dailyPlanNoMix.
  ///
  /// In en, this message translates to:
  /// **'No cheesecake mix'**
  String get dailyPlanNoMix;

  /// No description provided for @dailyPlanPerBatch.
  ///
  /// In en, this message translates to:
  /// **'{count} per batch'**
  String dailyPlanPerBatch(int count);

  /// No description provided for @dailyPlanTotalJars.
  ///
  /// In en, this message translates to:
  /// **'{count} jars planned'**
  String dailyPlanTotalJars(int count);

  /// No description provided for @dailyPlanEnterQuantities.
  ///
  /// In en, this message translates to:
  /// **'Enter how many jars you plan to fill.'**
  String get dailyPlanEnterQuantities;

  /// No description provided for @dailyPlanMixTotal.
  ///
  /// In en, this message translates to:
  /// **'{qty} {uom} of mix = {batches} batches'**
  String dailyPlanMixTotal(String qty, String uom, String batches);

  /// No description provided for @dailyPlanNoRuns.
  ///
  /// In en, this message translates to:
  /// **'The mixer is not configured, so the split cannot be calculated.'**
  String get dailyPlanNoRuns;

  /// No description provided for @dailyPlanRunPreferred.
  ///
  /// In en, this message translates to:
  /// **'ideal'**
  String get dailyPlanRunPreferred;

  /// No description provided for @dailyPlanRunAcceptable.
  ///
  /// In en, this message translates to:
  /// **'stretching'**
  String get dailyPlanRunAcceptable;

  /// No description provided for @dailyPlanRunPoor.
  ///
  /// In en, this message translates to:
  /// **'mixes badly'**
  String get dailyPlanRunPoor;

  /// No description provided for @dailyPlanSpareMix.
  ///
  /// In en, this message translates to:
  /// **'{batches} batches of spare mix from rounding to whole runs.'**
  String dailyPlanSpareMix(String batches);

  /// No description provided for @dailyPlanCheckMaterials.
  ///
  /// In en, this message translates to:
  /// **'Check stock'**
  String get dailyPlanCheckMaterials;

  /// No description provided for @dailyPlanSave.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get dailyPlanSave;

  /// No description provided for @dailyPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Plan {name} saved.'**
  String dailyPlanSaved(String name);

  /// No description provided for @dailyPlanShortages.
  ///
  /// In en, this message translates to:
  /// **'{count} materials short'**
  String dailyPlanShortages(int count);

  /// No description provided for @dailyPlanShortageLine.
  ///
  /// In en, this message translates to:
  /// **'{item}: {qty} {uom} short'**
  String dailyPlanShortageLine(String item, String qty, String uom);

  /// No description provided for @dailyPlanShortagesMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String dailyPlanShortagesMore(int count);

  /// No description provided for @dailyPlanMaterialsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Stock could not be checked for this plan.'**
  String get dailyPlanMaterialsUnavailable;

  /// No description provided for @dailyPlanBomIssues.
  ///
  /// In en, this message translates to:
  /// **'{count} BOMs need attention before the mix total is right'**
  String dailyPlanBomIssues(int count);

  /// No description provided for @dailyPlanBomIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'BOM issues affecting the plan'**
  String get dailyPlanBomIssuesTitle;

  /// No description provided for @productionTabBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get productionTabBatch;

  /// No description provided for @productionAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Production access required'**
  String get productionAccessDenied;

  /// No description provided for @productionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items with a BOM'**
  String get productionSearchHint;

  /// No description provided for @productionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productionFilterAll;

  /// No description provided for @productionStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get productionStatusCritical;

  /// No description provided for @productionStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get productionStatusLow;

  /// No description provided for @productionStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Covered'**
  String get productionStatusOk;

  /// No description provided for @productionStatusOverstocked.
  ///
  /// In en, this message translates to:
  /// **'Overstocked'**
  String get productionStatusOverstocked;

  /// No description provided for @productionStatusNoVelocity.
  ///
  /// In en, this message translates to:
  /// **'No sales data'**
  String get productionStatusNoVelocity;

  /// No description provided for @productionOnHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get productionOnHand;

  /// No description provided for @productionSellsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Sells / day'**
  String get productionSellsPerDay;

  /// No description provided for @productionCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get productionCover;

  /// No description provided for @productionCoverDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String productionCoverDays(Object days);

  /// No description provided for @productionCoverUnknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get productionCoverUnknown;

  /// No description provided for @productionTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get productionTrend;

  /// No description provided for @productionMakeBatches.
  ///
  /// In en, this message translates to:
  /// **'Make {batches} batches · {units} {uom}'**
  String productionMakeBatches(Object batches, Object units, Object uom);

  /// No description provided for @productionReachCover.
  ///
  /// In en, this message translates to:
  /// **'to reach {days} days cover'**
  String productionReachCover(Object days);

  /// No description provided for @productionCappedBy.
  ///
  /// In en, this message translates to:
  /// **'capped at {capped} — {limiter} is short (wanted {wanted})'**
  String productionCappedBy(Object capped, Object limiter, Object wanted);

  /// No description provided for @productionSeasonApplied.
  ///
  /// In en, this message translates to:
  /// **'Season {name}: ×{value}'**
  String productionSeasonApplied(Object name, Object value);

  /// No description provided for @productionAddToBatch.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get productionAddToBatch;

  /// No description provided for @productionFillTheDay.
  ///
  /// In en, this message translates to:
  /// **'Fill the day'**
  String get productionFillTheDay;

  /// No description provided for @productionFillTheDayResult.
  ///
  /// In en, this message translates to:
  /// **'Added {added} items · {batches} batches'**
  String productionFillTheDayResult(Object added, Object batches);

  /// No description provided for @productionFillTheDaySkipped.
  ///
  /// In en, this message translates to:
  /// **'{skipped} skipped — no materials'**
  String productionFillTheDaySkipped(Object skipped);

  /// No description provided for @productionFillTheDayNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to add'**
  String get productionFillTheDayNothing;

  /// No description provided for @productionNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs producing'**
  String get productionNoSuggestions;

  /// No description provided for @productionVelocityNever.
  ///
  /// In en, this message translates to:
  /// **'Sales velocity has never been calculated — suggestions will stay empty until it runs'**
  String get productionVelocityNever;

  /// No description provided for @productionVelocityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Velocity updated {when}'**
  String productionVelocityUpdated(Object when);

  /// No description provided for @productionBelowCover.
  ///
  /// In en, this message translates to:
  /// **'{count} items below cover'**
  String productionBelowCover(Object count);

  /// No description provided for @productionBasketEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing queued yet'**
  String get productionBasketEmpty;

  /// No description provided for @productionBasketTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch ({count})'**
  String productionBasketTitle(Object count);

  /// No description provided for @productionPostingDate.
  ///
  /// In en, this message translates to:
  /// **'Production date'**
  String get productionPostingDate;

  /// No description provided for @productionClearBasket.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get productionClearBasket;

  /// No description provided for @productionBatchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get productionBatchesLabel;

  /// No description provided for @productionPickListTitle.
  ///
  /// In en, this message translates to:
  /// **'Consolidated pick list'**
  String get productionPickListTitle;

  /// No description provided for @productionPickListShort.
  ///
  /// In en, this message translates to:
  /// **'Short by {quantity} {uom}'**
  String productionPickListShort(Object quantity, Object uom);

  /// No description provided for @productionPickListOk.
  ///
  /// In en, this message translates to:
  /// **'All materials available'**
  String get productionPickListOk;

  /// No description provided for @productionSharedAcrossLines.
  ///
  /// In en, this message translates to:
  /// **'shared by {count} lines'**
  String productionSharedAcrossLines(Object count);

  /// No description provided for @productionSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get productionSubmitting;

  /// No description provided for @productionScaleToFit.
  ///
  /// In en, this message translates to:
  /// **'Reduce to what materials allow'**
  String get productionScaleToFit;

  /// No description provided for @productionTargetDays.
  ///
  /// In en, this message translates to:
  /// **'Target {days} days'**
  String productionTargetDays(Object days);

  /// No description provided for @productionNoSourceWarehouse.
  ///
  /// In en, this message translates to:
  /// **'No source warehouse configured'**
  String get productionNoSourceWarehouse;

  /// No description provided for @productionStockElsewhere.
  ///
  /// In en, this message translates to:
  /// **'{quantity} is in {warehouse} — needs a stock transfer, not a purchase'**
  String productionStockElsewhere(Object quantity, Object warehouse);

  /// No description provided for @productionStockElsewhereMore.
  ///
  /// In en, this message translates to:
  /// **'{quantity} is in {warehouse} and {count} more — needs a stock transfer, not a purchase'**
  String productionStockElsewhereMore(
    Object count,
    Object quantity,
    Object warehouse,
  );

  /// No description provided for @productionStockNowhere.
  ///
  /// In en, this message translates to:
  /// **'None of it in any other store — this one has to be bought'**
  String get productionStockNowhere;

  /// No description provided for @productionNegativeStock.
  ///
  /// In en, this message translates to:
  /// **'Stock is negative — count this item'**
  String get productionNegativeStock;

  /// No description provided for @productionMakeUnits.
  ///
  /// In en, this message translates to:
  /// **'Make {units} {uom}'**
  String productionMakeUnits(Object units, Object uom);

  /// No description provided for @productionCannotStart.
  ///
  /// In en, this message translates to:
  /// **'Cannot start — {limiter} is short'**
  String productionCannotStart(Object limiter);

  /// No description provided for @productionBatchTotals.
  ///
  /// In en, this message translates to:
  /// **'{batches} batches · {units} units'**
  String productionBatchTotals(Object batches, Object units);

  /// No description provided for @productionTabRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get productionTabRunning;

  /// No description provided for @productionStart.
  ///
  /// In en, this message translates to:
  /// **'Start batch'**
  String get productionStart;

  /// No description provided for @productionQuickProduce.
  ///
  /// In en, this message translates to:
  /// **'Quick produce'**
  String get productionQuickProduce;

  /// No description provided for @productionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get productionFinish;

  /// No description provided for @productionFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish batch'**
  String get productionFinishTitle;

  /// No description provided for @productionActualQty.
  ///
  /// In en, this message translates to:
  /// **'Actual produced'**
  String get productionActualQty;

  /// No description provided for @productionScrapQty.
  ///
  /// In en, this message translates to:
  /// **'Scrap / waste'**
  String get productionScrapQty;

  /// No description provided for @productionBatchNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get productionBatchNotes;

  /// No description provided for @productionActualExceedsPlanned.
  ///
  /// In en, this message translates to:
  /// **'More than the {planned} planned'**
  String productionActualExceedsPlanned(Object planned);

  /// No description provided for @productionQtyMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter how much actually came out'**
  String get productionQtyMustBePositive;

  /// No description provided for @productionRunningEmpty.
  ///
  /// In en, this message translates to:
  /// **'No batches running'**
  String get productionRunningEmpty;

  /// No description provided for @productionRunningSince.
  ///
  /// In en, this message translates to:
  /// **'Started {when} by {who}'**
  String productionRunningSince(Object when, Object who);

  /// No description provided for @productionElapsed.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String productionElapsed(Object hours, Object minutes);

  /// No description provided for @productionElapsedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String productionElapsedMinutes(Object minutes);

  /// No description provided for @productionPlannedVsProduced.
  ///
  /// In en, this message translates to:
  /// **'{planned} planned · {produced} produced'**
  String productionPlannedVsProduced(Object planned, Object produced);

  /// No description provided for @productionWipLeftover.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {uom} left in WIP'**
  String productionWipLeftover(Object quantity, Object uom);

  /// No description provided for @productionReturnToStore.
  ///
  /// In en, this message translates to:
  /// **'Return to store'**
  String get productionReturnToStore;

  /// No description provided for @productionReturnedToStore.
  ///
  /// In en, this message translates to:
  /// **'Material returned to store'**
  String get productionReturnedToStore;

  /// No description provided for @productionCostTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch cost'**
  String get productionCostTitle;

  /// No description provided for @productionMaterialCost.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get productionMaterialCost;

  /// No description provided for @productionCostPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per unit'**
  String get productionCostPerUnit;

  /// No description provided for @productionStandardCost.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get productionStandardCost;

  /// No description provided for @productionVariance.
  ///
  /// In en, this message translates to:
  /// **'Variance'**
  String get productionVariance;

  /// No description provided for @productionVarianceOver.
  ///
  /// In en, this message translates to:
  /// **'{percent}% over standard'**
  String productionVarianceOver(Object percent);

  /// No description provided for @productionVarianceUnder.
  ///
  /// In en, this message translates to:
  /// **'{percent}% under standard'**
  String productionVarianceUnder(Object percent);

  /// No description provided for @productionCostUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No cost yet — nothing produced'**
  String get productionCostUnavailable;

  /// No description provided for @productionPrintBatchSheet.
  ///
  /// In en, this message translates to:
  /// **'Print batch sheet'**
  String get productionPrintBatchSheet;

  /// No description provided for @productionBackDateNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You cannot post production on a past date'**
  String get productionBackDateNotAllowed;

  /// No description provided for @productionStarted.
  ///
  /// In en, this message translates to:
  /// **'Batch started · {workOrder}'**
  String productionStarted(Object workOrder);

  /// No description provided for @productionFinished.
  ///
  /// In en, this message translates to:
  /// **'Batch finished · {quantity} {uom}'**
  String productionFinished(Object quantity, Object uom);

  /// No description provided for @productionNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'This batch was never started'**
  String get productionNotStartedYet;

  /// No description provided for @productionTabBases.
  ///
  /// In en, this message translates to:
  /// **'Bases'**
  String get productionTabBases;

  /// No description provided for @basesHeaderHint.
  ///
  /// In en, this message translates to:
  /// **'Bases never sell, so the plan cannot suggest them. Pick one and set how many batches to mix.'**
  String get basesHeaderHint;

  /// No description provided for @basesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bases configured'**
  String get basesEmpty;

  /// No description provided for @basesSummaryShort.
  ///
  /// In en, this message translates to:
  /// **'{count} below what the jars need'**
  String basesSummaryShort(Object count);

  /// No description provided for @basesSummaryBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} blocked — no materials'**
  String basesSummaryBlocked(Object count);

  /// No description provided for @basesBatchYield.
  ///
  /// In en, this message translates to:
  /// **'1 batch = {quantity} {uom}'**
  String basesBatchYield(Object quantity, Object uom);

  /// No description provided for @basesInFreezer.
  ///
  /// In en, this message translates to:
  /// **'In freezer'**
  String get basesInFreezer;

  /// No description provided for @basesBatchesValue.
  ///
  /// In en, this message translates to:
  /// **'{batches} batches'**
  String basesBatchesValue(Object batches);

  /// No description provided for @basesQtyValue.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {uom}'**
  String basesQtyValue(Object quantity, Object uom);

  /// No description provided for @basesCanMakeNow.
  ///
  /// In en, this message translates to:
  /// **'Can make now'**
  String get basesCanMakeNow;

  /// No description provided for @basesDemandHint.
  ///
  /// In en, this message translates to:
  /// **'The plan needs {needed} batches · you have {onHand}'**
  String basesDemandHint(Object needed, Object onHand);

  /// No description provided for @basesDemandDriver.
  ///
  /// In en, this message translates to:
  /// **'from {driver}'**
  String basesDemandDriver(Object driver);

  /// No description provided for @basesUseBatches.
  ///
  /// In en, this message translates to:
  /// **'Use {batches}'**
  String basesUseBatches(Object batches);

  /// No description provided for @basesRunSizes.
  ///
  /// In en, this message translates to:
  /// **'Mixer runs'**
  String get basesRunSizes;

  /// No description provided for @basesRunSizeOff.
  ///
  /// In en, this message translates to:
  /// **'Not one of the mixer\'\'s usual runs — double-check before mixing'**
  String get basesRunSizeOff;

  /// No description provided for @basesMakes.
  ///
  /// In en, this message translates to:
  /// **'Makes {quantity} {uom}'**
  String basesMakes(Object quantity, Object uom);

  /// No description provided for @basesConsumes.
  ///
  /// In en, this message translates to:
  /// **'Consumes'**
  String get basesConsumes;

  /// No description provided for @basesEstimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Est. materials {amount}'**
  String basesEstimatedCost(Object amount);

  /// No description provided for @basesChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking materials…'**
  String get basesChecking;

  /// No description provided for @basesPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check materials — {reason}'**
  String basesPreviewFailed(Object reason);

  /// No description provided for @basesShortage.
  ///
  /// In en, this message translates to:
  /// **'{component} is short by {quantity} {uom}'**
  String basesShortage(Object component, Object quantity, Object uom);

  /// No description provided for @basesReduceTo.
  ///
  /// In en, this message translates to:
  /// **'Reduce to {batches}'**
  String basesReduceTo(Object batches);

  /// No description provided for @basesNothingPossible.
  ///
  /// In en, this message translates to:
  /// **'Not enough materials for even half a batch'**
  String get basesNothingPossible;

  /// No description provided for @sopTitle.
  ///
  /// In en, this message translates to:
  /// **'Work instructions'**
  String get sopTitle;

  /// No description provided for @sopViewSop.
  ///
  /// In en, this message translates to:
  /// **'View SOP'**
  String get sopViewSop;

  /// No description provided for @sopNoSopForItem.
  ///
  /// In en, this message translates to:
  /// **'No work instructions for this item'**
  String get sopNoSopForItem;

  /// No description provided for @sopStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String sopStepOf(Object current, Object total);

  /// No description provided for @sopNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get sopNext;

  /// No description provided for @sopPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get sopPrevious;

  /// No description provided for @sopConfirmStep.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sopConfirmStep;

  /// No description provided for @sopCaptureNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the reading'**
  String get sopCaptureNumber;

  /// No description provided for @sopCaptureTemperature.
  ///
  /// In en, this message translates to:
  /// **'Enter the temperature'**
  String get sopCaptureTemperature;

  /// No description provided for @sopCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get sopCapturePhoto;

  /// No description provided for @sopCaptureRequired.
  ///
  /// In en, this message translates to:
  /// **'Record this before continuing'**
  String get sopCaptureRequired;

  /// No description provided for @sopCaptureOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Allowed range {from} to {to}'**
  String sopCaptureOutOfRange(Object from, Object to);

  /// No description provided for @sopDurationMins.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sopDurationMins(Object minutes);

  /// No description provided for @sopTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min total'**
  String sopTotalDuration(Object minutes);

  /// No description provided for @sopScaledFor.
  ///
  /// In en, this message translates to:
  /// **'Scaled for {batches} batches'**
  String sopScaledFor(Object batches);

  /// No description provided for @sopEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get sopEquipment;

  /// No description provided for @sopExpectedYield.
  ///
  /// In en, this message translates to:
  /// **'Expected yield {percent}%'**
  String sopExpectedYield(Object percent);

  /// No description provided for @sopVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String sopVersionLabel(Object version);

  /// No description provided for @sopFinishExecution.
  ///
  /// In en, this message translates to:
  /// **'Finish instructions'**
  String get sopFinishExecution;

  /// No description provided for @sopExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave the instructions? Your place is not saved.'**
  String get sopExitConfirm;

  /// No description provided for @sopUnresolvedTokens.
  ///
  /// In en, this message translates to:
  /// **'{count} instruction reference(s) could not be resolved'**
  String sopUnresolvedTokens(Object count);

  /// No description provided for @sopPhotoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo recorded'**
  String get sopPhotoCaptured;

  /// No description provided for @sopCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to record a photo'**
  String get sopCameraPermissionDenied;

  /// No description provided for @sopImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable — you may not have access to it'**
  String get sopImageUnavailable;

  /// No description provided for @stockTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer'**
  String get stockTransferTitle;

  /// No description provided for @stockTransferManagersOnly.
  ///
  /// In en, this message translates to:
  /// **'Managers only'**
  String get stockTransferManagersOnly;

  /// No description provided for @stockTransferLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Lines ({count})'**
  String stockTransferLinesTitle(Object count);

  /// No description provided for @stockTransferPostingChip.
  ///
  /// In en, this message translates to:
  /// **'Posting: {date}'**
  String stockTransferPostingChip(Object date);

  /// No description provided for @stockTransferSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get stockTransferSubmit;

  /// No description provided for @stockTransferProfilesMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Source and Target must differ'**
  String get stockTransferProfilesMustDiffer;

  /// No description provided for @stockTransferProfileLabelSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get stockTransferProfileLabelSource;

  /// No description provided for @stockTransferProfileLabelTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get stockTransferProfileLabelTarget;

  /// No description provided for @stockTransferProfilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select POS Profile'**
  String get stockTransferProfilePlaceholder;

  /// No description provided for @stockTransferProfileOption.
  ///
  /// In en, this message translates to:
  /// **'{profile} • {warehouse}'**
  String stockTransferProfileOption(Object profile, Object warehouse);

  /// No description provided for @stockTransferProfileWarehouseFallback.
  ///
  /// In en, this message translates to:
  /// **'No warehouse'**
  String get stockTransferProfileWarehouseFallback;

  /// No description provided for @stockTransferSelectBranches.
  ///
  /// In en, this message translates to:
  /// **'Select source and target branches'**
  String get stockTransferSelectBranches;

  /// No description provided for @stockTransferSameProfile.
  ///
  /// In en, this message translates to:
  /// **'Source and Target cannot be the same'**
  String get stockTransferSameProfile;

  /// No description provided for @stockTransferAvailability.
  ///
  /// In en, this message translates to:
  /// **'Src: {source} • Dst: {target}'**
  String stockTransferAvailability(Object source, Object target);

  /// No description provided for @stockTransferReservedSource.
  ///
  /// In en, this message translates to:
  /// **' • Res Src: {reservedSource}'**
  String stockTransferReservedSource(Object reservedSource);

  /// No description provided for @stockTransferReservedTarget.
  ///
  /// In en, this message translates to:
  /// **' • Res Dst: {reservedTarget}'**
  String stockTransferReservedTarget(Object reservedTarget);

  /// No description provided for @stockTransferPosTag.
  ///
  /// In en, this message translates to:
  /// **' • POS'**
  String get stockTransferPosTag;

  /// No description provided for @stockTransferPostingToday.
  ///
  /// In en, this message translates to:
  /// **'Posting Date: Today'**
  String get stockTransferPostingToday;

  /// No description provided for @stockTransferPostingDate.
  ///
  /// In en, this message translates to:
  /// **'Posting Date: {date}'**
  String stockTransferPostingDate(Object date);

  /// No description provided for @stockTransferUseToday.
  ///
  /// In en, this message translates to:
  /// **'Use Today'**
  String get stockTransferUseToday;

  /// No description provided for @stockTransferNoLines.
  ///
  /// In en, this message translates to:
  /// **'No lines'**
  String get stockTransferNoLines;

  /// No description provided for @stockTransferBeforeBase.
  ///
  /// In en, this message translates to:
  /// **'Before — Src: {source} • Dst: {target}'**
  String stockTransferBeforeBase(Object source, Object target);

  /// No description provided for @stockTransferAfterBase.
  ///
  /// In en, this message translates to:
  /// **'After  — Src: {source} • Dst: {target}'**
  String stockTransferAfterBase(Object source, Object target);

  /// No description provided for @stockTransferTransferCreated.
  ///
  /// In en, this message translates to:
  /// **'Transfer created: {stockEntry}'**
  String stockTransferTransferCreated(Object stockEntry);

  /// No description provided for @stockTransferSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String stockTransferSubmitFailed(Object error);

  /// No description provided for @stockTransferBulkAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Bulk add failed: {error}'**
  String stockTransferBulkAddFailed(Object error);

  /// No description provided for @stockTransferQuickQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quick quantity'**
  String get stockTransferQuickQuantity;

  /// No description provided for @stockTransferQuantityPerItem.
  ///
  /// In en, this message translates to:
  /// **'Quantity for each item'**
  String get stockTransferQuantityPerItem;

  /// No description provided for @stockTransferItemGroup.
  ///
  /// In en, this message translates to:
  /// **'Item Group'**
  String get stockTransferItemGroup;

  /// No description provided for @stockTransferAllGroups.
  ///
  /// In en, this message translates to:
  /// **'All Groups'**
  String get stockTransferAllGroups;

  /// No description provided for @stockTransferAddAll.
  ///
  /// In en, this message translates to:
  /// **'Add All'**
  String get stockTransferAddAll;

  /// No description provided for @stockTransferAddGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get stockTransferAddGroup;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @paymentMethodSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get paymentMethodSelectTitle;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodInstapay.
  ///
  /// In en, this message translates to:
  /// **'Instapay'**
  String get paymentMethodInstapay;

  /// No description provided for @paymentMethodMobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile Wallet'**
  String get paymentMethodMobileWallet;

  /// No description provided for @paymentMethodSettleLater.
  ///
  /// In en, this message translates to:
  /// **'Settle Later'**
  String get paymentMethodSettleLater;

  /// No description provided for @paymentMethodOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get paymentMethodOnline;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get checkoutTotal;

  /// No description provided for @checkoutPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get checkoutPay;

  /// No description provided for @checkoutSelectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Select POS profile first'**
  String get checkoutSelectProfileFirst;

  /// No description provided for @checkoutOrderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order completed successfully!'**
  String get checkoutOrderSuccess;

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed: {error}'**
  String checkoutFailed(Object error);

  /// No description provided for @salesPartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Partner'**
  String get salesPartnerTitle;

  /// No description provided for @salesPartnerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search partner'**
  String get salesPartnerSearchHint;

  /// No description provided for @salesPartnerNotFound.
  ///
  /// In en, this message translates to:
  /// **'No partners found'**
  String get salesPartnerNotFound;

  /// No description provided for @itemGridBundles.
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get itemGridBundles;

  /// No description provided for @itemGridAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get itemGridAll;

  /// No description provided for @itemGridUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get itemGridUncategorized;

  /// No description provided for @itemGridSelectCustomerWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer first'**
  String get itemGridSelectCustomerWarning;

  /// No description provided for @itemGridNoItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get itemGridNoItemsFound;

  /// No description provided for @itemGridNoItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get itemGridNoItemsAvailable;

  /// No description provided for @itemGridTryDifferentCategory.
  ///
  /// In en, this message translates to:
  /// **'Try a different category'**
  String get itemGridTryDifferentCategory;

  /// No description provided for @itemGridItemsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Items will appear here'**
  String get itemGridItemsWillAppear;

  /// No description provided for @itemGridFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get itemGridFreeDelivery;

  /// No description provided for @itemGridBundlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bundles'**
  String itemGridBundlesCount(Object count);

  /// No description provided for @itemGridItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemGridItemsCount(Object count);

  /// No description provided for @itemGridInCart.
  ///
  /// In en, this message translates to:
  /// **'In cart: {count}'**
  String itemGridInCart(Object count);

  /// No description provided for @itemGridAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get itemGridAddedToCart;

  /// No description provided for @itemGridSelectCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Select customer first'**
  String get itemGridSelectCustomerFirst;

  /// No description provided for @itemGridOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get itemGridOutOfStock;

  /// No description provided for @itemGridCannotAdd.
  ///
  /// In en, this message translates to:
  /// **'Cannot add item'**
  String get itemGridCannotAdd;

  /// No description provided for @kanbanFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get kanbanFilterTitle;

  /// No description provided for @kanbanFilterActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String kanbanFilterActiveCount(Object count);

  /// No description provided for @kanbanFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get kanbanFilterClearAll;

  /// No description provided for @kanbanFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get kanbanFilterSearch;

  /// No description provided for @kanbanFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Order #, customer, or phone'**
  String get kanbanFilterSearchHint;

  /// No description provided for @kanbanFilterMatchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matching orders} =1{1 matching order} other{{count} matching orders}}'**
  String kanbanFilterMatchCount(int count);

  /// No description provided for @kanbanFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get kanbanFilterDone;

  /// No description provided for @kanbanFilterDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get kanbanFilterDateToday;

  /// No description provided for @kanbanFilterDateLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get kanbanFilterDateLast7Days;

  /// No description provided for @kanbanFilterDateLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get kanbanFilterDateLast30Days;

  /// No description provided for @kanbanFilterDateThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get kanbanFilterDateThisMonth;

  /// No description provided for @kanbanFilterDateCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range…'**
  String get kanbanFilterDateCustom;

  /// No description provided for @kanbanFilterAllCustomers.
  ///
  /// In en, this message translates to:
  /// **'All Customers'**
  String get kanbanFilterAllCustomers;

  /// No description provided for @kanbanFilterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get kanbanFilterAllStatuses;

  /// No description provided for @kanbanFilterDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get kanbanFilterDateRange;

  /// No description provided for @kanbanFilterFromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get kanbanFilterFromDate;

  /// No description provided for @kanbanFilterToDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get kanbanFilterToDate;

  /// No description provided for @kanbanFilterAllDates.
  ///
  /// In en, this message translates to:
  /// **'All Dates'**
  String get kanbanFilterAllDates;

  /// No description provided for @kanbanFilterAmountRange.
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get kanbanFilterAmountRange;

  /// No description provided for @kanbanFilterMinAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get kanbanFilterMinAmount;

  /// No description provided for @kanbanFilterMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get kanbanFilterMaxAmount;

  /// No description provided for @kanbanFilterAllAmounts.
  ///
  /// In en, this message translates to:
  /// **'All Amounts'**
  String get kanbanFilterAllAmounts;

  /// No description provided for @kanbanFilterActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Filters:'**
  String get kanbanFilterActiveLabel;

  /// No description provided for @kanbanFilterByBranches.
  ///
  /// In en, this message translates to:
  /// **'Filter by Branches'**
  String get kanbanFilterByBranches;

  /// No description provided for @kanbanFilterCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get kanbanFilterCustomerTitle;

  /// No description provided for @kanbanFilterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get kanbanFilterCustomerName;

  /// No description provided for @kanbanFilterCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter customer name'**
  String get kanbanFilterCustomerHint;

  /// No description provided for @kanbanFilterStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get kanbanFilterStatusTitle;

  /// No description provided for @kanbanFilterFromAmount.
  ///
  /// In en, this message translates to:
  /// **'From Amount'**
  String get kanbanFilterFromAmount;

  /// No description provided for @kanbanFilterToAmount.
  ///
  /// In en, this message translates to:
  /// **'To Amount'**
  String get kanbanFilterToAmount;

  /// No description provided for @kanbanFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get kanbanFilterApply;

  /// No description provided for @kanbanRefreshOrders.
  ///
  /// In en, this message translates to:
  /// **'Refresh Orders'**
  String get kanbanRefreshOrders;

  /// No description provided for @kanbanOrdersRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Orders refreshed'**
  String get kanbanOrdersRefreshed;

  /// No description provided for @kanbanHideFilters.
  ///
  /// In en, this message translates to:
  /// **'Hide Filters'**
  String get kanbanHideFilters;

  /// No description provided for @kanbanShowFilters.
  ///
  /// In en, this message translates to:
  /// **'Show Filters'**
  String get kanbanShowFilters;

  /// No description provided for @kanbanMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More Actions'**
  String get kanbanMoreActions;

  /// No description provided for @kanbanMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get kanbanMenu;

  /// No description provided for @kanbanMenuReceipts.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipts'**
  String get kanbanMenuReceipts;

  /// No description provided for @kanbanMenuPrinters.
  ///
  /// In en, this message translates to:
  /// **'Printers'**
  String get kanbanMenuPrinters;

  /// No description provided for @kanbanMenuCouriers.
  ///
  /// In en, this message translates to:
  /// **'Courier Balances'**
  String get kanbanMenuCouriers;

  /// No description provided for @kanbanMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get kanbanMenuProfile;

  /// No description provided for @kanbanMenuPos.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get kanbanMenuPos;

  /// No description provided for @kanbanPaymentReceipts.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipts'**
  String get kanbanPaymentReceipts;

  /// No description provided for @kanbanCourierBalances.
  ///
  /// In en, this message translates to:
  /// **'Courier Balances'**
  String get kanbanCourierBalances;

  /// No description provided for @kanbanUserProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get kanbanUserProfile;

  /// No description provided for @kanbanOpenPos.
  ///
  /// In en, this message translates to:
  /// **'Open POS'**
  String get kanbanOpenPos;

  /// No description provided for @kanbanTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Kanban'**
  String get kanbanTitleShort;

  /// No description provided for @kanbanTitleFull.
  ///
  /// In en, this message translates to:
  /// **'Sales Kanban'**
  String get kanbanTitleFull;

  /// No description provided for @kanbanPrinterBle.
  ///
  /// In en, this message translates to:
  /// **'BLE'**
  String get kanbanPrinterBle;

  /// No description provided for @kanbanPrinterClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get kanbanPrinterClassic;

  /// No description provided for @kanbanPrinterConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get kanbanPrinterConnecting;

  /// No description provided for @kanbanPrinterNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get kanbanPrinterNotConnected;

  /// No description provided for @kanbanErrorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get kanbanErrorLoadingData;

  /// No description provided for @kanbanNoColumnsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No columns configured'**
  String get kanbanNoColumnsConfigured;

  /// No description provided for @kanbanEnsureStateField.
  ///
  /// In en, this message translates to:
  /// **'Ensure the state field is configured properly.'**
  String get kanbanEnsureStateField;

  /// No description provided for @kanbanSelectPosProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Select POS profile first'**
  String get kanbanSelectPosProfileFirst;

  /// No description provided for @kanbanSelectPosProfile.
  ///
  /// In en, this message translates to:
  /// **'Select POS Profile'**
  String get kanbanSelectPosProfile;

  /// No description provided for @kanbanNoPosProfiles.
  ///
  /// In en, this message translates to:
  /// **'No POS profiles available'**
  String get kanbanNoPosProfiles;

  /// No description provided for @kanbanWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse: {warehouse}'**
  String kanbanWarehouse(Object warehouse);

  /// No description provided for @kanbanCourierAndMode.
  ///
  /// In en, this message translates to:
  /// **'Courier & Mode'**
  String get kanbanCourierAndMode;

  /// No description provided for @kanbanNoCouriersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No couriers available'**
  String get kanbanNoCouriersAvailable;

  /// No description provided for @kanbanCreateCourierHint.
  ///
  /// In en, this message translates to:
  /// **'Create a courier to proceed.'**
  String get kanbanCreateCourierHint;

  /// No description provided for @kanbanNewCourier.
  ///
  /// In en, this message translates to:
  /// **'New Courier'**
  String get kanbanNewCourier;

  /// No description provided for @kanbanFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get kanbanFirstName;

  /// No description provided for @kanbanLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get kanbanLastName;

  /// No description provided for @kanbanPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get kanbanPhone;

  /// No description provided for @kanbanType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get kanbanType;

  /// No description provided for @kanbanEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get kanbanEmployee;

  /// No description provided for @kanbanSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get kanbanSupplier;

  /// No description provided for @kanbanBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get kanbanBack;

  /// No description provided for @kanbanCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Create failed: {error}'**
  String kanbanCreateFailed(Object error);

  /// No description provided for @kanbanMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get kanbanMode;

  /// No description provided for @kanbanPayNowCash.
  ///
  /// In en, this message translates to:
  /// **'Pay Now (Cash)'**
  String get kanbanPayNowCash;

  /// No description provided for @kanbanSettleLater.
  ///
  /// In en, this message translates to:
  /// **'Settle Later'**
  String get kanbanSettleLater;

  /// No description provided for @kanbanSettleLaterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courier settles with branch later'**
  String get kanbanSettleLaterSubtitle;

  /// No description provided for @kanbanContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get kanbanContinue;

  /// No description provided for @kanbanSettleLaterMissingParty.
  ///
  /// In en, this message translates to:
  /// **'Settle Later failed: courier party missing.'**
  String get kanbanSettleLaterMissingParty;

  /// No description provided for @kanbanSettleLaterPreviewExpired.
  ///
  /// In en, this message translates to:
  /// **'Settle Later: preview expired. Please retry.'**
  String get kanbanSettleLaterPreviewExpired;

  /// No description provided for @kanbanSettleLaterFailed.
  ///
  /// In en, this message translates to:
  /// **'Settle Later failed'**
  String get kanbanSettleLaterFailed;

  /// No description provided for @kanbanMarkedSettleLater.
  ///
  /// In en, this message translates to:
  /// **'Marked to Settle Later'**
  String get kanbanMarkedSettleLater;

  /// No description provided for @kanbanSettleLaterError.
  ///
  /// In en, this message translates to:
  /// **'Settle Later error: {error}'**
  String kanbanSettleLaterError(Object error);

  /// No description provided for @kanbanSettlementMissingParty.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed: courier party missing.'**
  String get kanbanSettlementMissingParty;

  /// No description provided for @kanbanPreviewExpired.
  ///
  /// In en, this message translates to:
  /// **'Preview expired. Please retry.'**
  String get kanbanPreviewExpired;

  /// No description provided for @kanbanConfirmingSettlement.
  ///
  /// In en, this message translates to:
  /// **'Confirming settlement...'**
  String get kanbanConfirmingSettlement;

  /// No description provided for @kanbanSettlementFailed.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed'**
  String get kanbanSettlementFailed;

  /// No description provided for @kanbanSettlementConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Settlement confirmed'**
  String get kanbanSettlementConfirmed;

  /// No description provided for @kanbanSettlementError.
  ///
  /// In en, this message translates to:
  /// **'Settlement error: {error}'**
  String kanbanSettlementError(Object error);

  /// No description provided for @kanbanPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed: {error}'**
  String kanbanPreviewFailed(Object error);

  /// No description provided for @kanbanPickupNoSettlement.
  ///
  /// In en, this message translates to:
  /// **'Pickup orders don\'\'t require settlement'**
  String get kanbanPickupNoSettlement;

  /// No description provided for @kanbanCannotMoveBackward.
  ///
  /// In en, this message translates to:
  /// **'Cannot move backward'**
  String get kanbanCannotMoveBackward;

  /// No description provided for @kanbanCancelViaMenuOnly.
  ///
  /// In en, this message translates to:
  /// **'Orders can\'\'t be cancelled by dragging. Use the card menu and pick \"Cancel Order\".'**
  String get kanbanCancelViaMenuOnly;

  /// No description provided for @kanbanReturnViaMenuOnly.
  ///
  /// In en, this message translates to:
  /// **'Orders can\'\'t be returned by dragging. Use the card menu and pick \"Return Order\".'**
  String get kanbanReturnViaMenuOnly;

  /// No description provided for @kanbanFullyReturnedLocked.
  ///
  /// In en, this message translates to:
  /// **'This order was fully returned and can no longer be moved.'**
  String get kanbanFullyReturnedLocked;

  /// No description provided for @kanbanPinBadgePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get kanbanPinBadgePinned;

  /// No description provided for @kanbanPinBadgePinnedTooltip.
  ///
  /// In en, this message translates to:
  /// **'This address has map coordinates'**
  String get kanbanPinBadgePinnedTooltip;

  /// No description provided for @kanbanPinBadgeMissing.
  ///
  /// In en, this message translates to:
  /// **'No map pin'**
  String get kanbanPinBadgeMissing;

  /// No description provided for @kanbanPinBadgeMissingTooltip.
  ///
  /// In en, this message translates to:
  /// **'No map pin yet — add the location link before dispatch'**
  String get kanbanPinBadgeMissingTooltip;

  /// No description provided for @kanbanMoveOneStage.
  ///
  /// In en, this message translates to:
  /// **'Can only move one stage at a time'**
  String get kanbanMoveOneStage;

  /// No description provided for @kanbanAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get kanbanAllBranches;

  /// No description provided for @kanbanBranchCount.
  ///
  /// In en, this message translates to:
  /// **'{count} branches'**
  String kanbanBranchCount(Object count);

  /// No description provided for @kanbanLoadingBranches.
  ///
  /// In en, this message translates to:
  /// **'Loading branches...'**
  String get kanbanLoadingBranches;

  /// No description provided for @kanbanTapToRefreshBalance.
  ///
  /// In en, this message translates to:
  /// **'Tap to refresh balance'**
  String get kanbanTapToRefreshBalance;

  /// No description provided for @kanbanPressBackAgain.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get kanbanPressBackAgain;

  /// No description provided for @invoiceDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get invoiceDeliveryAddress;

  /// No description provided for @invoiceItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get invoiceItems;

  /// No description provided for @invoiceNetTotal.
  ///
  /// In en, this message translates to:
  /// **'Net Total'**
  String get invoiceNetTotal;

  /// No description provided for @invoiceShippingIncome.
  ///
  /// In en, this message translates to:
  /// **'Shipping Income'**
  String get invoiceShippingIncome;

  /// No description provided for @invoiceShippingExpense.
  ///
  /// In en, this message translates to:
  /// **'Shipping Expense'**
  String get invoiceShippingExpense;

  /// No description provided for @invoiceGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get invoiceGrandTotal;

  /// No description provided for @invoiceAlreadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Invoice already {status}'**
  String invoiceAlreadyStatus(Object status);

  /// No description provided for @invoiceSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get invoiceSelectPaymentMethod;

  /// No description provided for @invoiceWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get invoiceWallet;

  /// No description provided for @invoiceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get invoiceSubmit;

  /// No description provided for @invoiceNoPosProfileCash.
  ///
  /// In en, this message translates to:
  /// **'No POS profile selected for Cash payment'**
  String get invoiceNoPosProfileCash;

  /// No description provided for @invoiceProcessingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing {method} payment...'**
  String invoiceProcessingPayment(Object method);

  /// No description provided for @invoicePaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful ({entry})'**
  String invoicePaymentSuccess(Object entry);

  /// No description provided for @invoiceReceiptAmountWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Could not get payment amount for receipt'**
  String get invoiceReceiptAmountWarning;

  /// No description provided for @invoiceReceiptNoPosProfile.
  ///
  /// In en, this message translates to:
  /// **'Warning: No POS profile found - receipt not created. Please select a POS profile.'**
  String get invoiceReceiptNoPosProfile;

  /// No description provided for @invoiceReceiptCreated.
  ///
  /// In en, this message translates to:
  /// **'Payment receipt created ({receipt}) - please upload receipt image from header'**
  String invoiceReceiptCreated(Object receipt);

  /// No description provided for @invoiceReceiptReturnedWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Receipt creation returned: {message}'**
  String invoiceReceiptReturnedWarning(Object message);

  /// No description provided for @invoiceReceiptCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Warning: Receipt creation failed: {error}'**
  String invoiceReceiptCreationFailed(Object error);

  /// No description provided for @invoicePaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get invoicePaymentFailed;

  /// No description provided for @invoicePaymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error: {error}'**
  String invoicePaymentError(Object error);

  /// No description provided for @invoiceCollectCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect Cash'**
  String get invoiceCollectCashTitle;

  /// No description provided for @invoiceCollectCashBody.
  ///
  /// In en, this message translates to:
  /// **'Please collect from the customer:\n\nTotal Amount: {amount} EGP\n\nThis includes:\n• Order items\n• Shipping fee\n\nInvoice: {invoiceId}'**
  String invoiceCollectCashBody(Object amount, Object invoiceId);

  /// No description provided for @invoiceSelectPosFirst.
  ///
  /// In en, this message translates to:
  /// **'Select POS profile first'**
  String get invoiceSelectPosFirst;

  /// No description provided for @invoiceChangeCollectionMethod.
  ///
  /// In en, this message translates to:
  /// **'Change collection method'**
  String get invoiceChangeCollectionMethod;

  /// No description provided for @invoiceRequestedPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Requested method'**
  String get invoiceRequestedPaymentMethod;

  /// No description provided for @invoiceActualCollectionMethod.
  ///
  /// In en, this message translates to:
  /// **'Actual collection'**
  String get invoiceActualCollectionMethod;

  /// No description provided for @invoiceCollectionReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get invoiceCollectionReferenceLabel;

  /// No description provided for @invoiceCollectionReferenceRequired.
  ///
  /// In en, this message translates to:
  /// **'Online collection requires a reference number.'**
  String get invoiceCollectionReferenceRequired;

  /// No description provided for @invoiceCollectionCashAtBranchNotice.
  ///
  /// In en, this message translates to:
  /// **'The courier for this order has already closed out, so this cash is recorded as received at the branch and will be expected in the drawer at the next count.'**
  String get invoiceCollectionCashAtBranchNotice;

  /// No description provided for @invoiceChangingCollectionMethod.
  ///
  /// In en, this message translates to:
  /// **'Changing collection method...'**
  String get invoiceChangingCollectionMethod;

  /// No description provided for @invoiceCollectionMethodChanged.
  ///
  /// In en, this message translates to:
  /// **'Collection method changed to {method}'**
  String invoiceCollectionMethodChanged(Object method);

  /// No description provided for @invoiceCollectionMethodChangeError.
  ///
  /// In en, this message translates to:
  /// **'Collection method error: {error}'**
  String invoiceCollectionMethodChangeError(Object error);

  /// No description provided for @invoiceCollectingCashPartner.
  ///
  /// In en, this message translates to:
  /// **'Collecting cash & dispatching (Sales Partner)...'**
  String get invoiceCollectingCashPartner;

  /// No description provided for @invoiceCashCollectedOfd.
  ///
  /// In en, this message translates to:
  /// **'Cash collected & sent Out For Delivery'**
  String get invoiceCashCollectedOfd;

  /// No description provided for @invoiceOfdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String invoiceOfdFailed(Object error);

  /// No description provided for @invoiceOfdError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String invoiceOfdError(Object error);

  /// No description provided for @invoiceSentOfd.
  ///
  /// In en, this message translates to:
  /// **'Sent Out For Delivery (DN will be created)'**
  String get invoiceSentOfd;

  /// No description provided for @invoiceActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String invoiceActionFailed(Object error);

  /// No description provided for @invoiceSettleLaterMissingParty.
  ///
  /// In en, this message translates to:
  /// **'Settle Later failed: courier party missing.'**
  String get invoiceSettleLaterMissingParty;

  /// No description provided for @invoiceMarkedSettleLater.
  ///
  /// In en, this message translates to:
  /// **'Marked to Settle Later'**
  String get invoiceMarkedSettleLater;

  /// No description provided for @invoiceSettleLaterFailed.
  ///
  /// In en, this message translates to:
  /// **'Settle Later failed'**
  String get invoiceSettleLaterFailed;

  /// No description provided for @invoiceSettleLaterError.
  ///
  /// In en, this message translates to:
  /// **'Settle Later error: {error}'**
  String invoiceSettleLaterError(Object error);

  /// No description provided for @invoiceSettlementMissingParty.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed: courier party missing.'**
  String get invoiceSettlementMissingParty;

  /// No description provided for @invoicePreviewExpired.
  ///
  /// In en, this message translates to:
  /// **'Preview expired. Please retry.'**
  String get invoicePreviewExpired;

  /// No description provided for @invoiceConfirmingSettlement.
  ///
  /// In en, this message translates to:
  /// **'Confirming settlement...'**
  String get invoiceConfirmingSettlement;

  /// No description provided for @invoiceSettlementConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Settlement confirmed'**
  String get invoiceSettlementConfirmed;

  /// No description provided for @invoiceSettlementFailed.
  ///
  /// In en, this message translates to:
  /// **'Settlement failed'**
  String get invoiceSettlementFailed;

  /// No description provided for @invoiceSettlementError.
  ///
  /// In en, this message translates to:
  /// **'Settlement error: {error}'**
  String invoiceSettlementError(Object error);

  /// No description provided for @invoiceProcessingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Processing Delivery...'**
  String get invoiceProcessingDelivery;

  /// No description provided for @invoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get invoiceUpdated;

  /// No description provided for @customerShippingAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Shipping Address'**
  String get customerShippingAddressTitle;

  /// No description provided for @customerShippingAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a saved shipping address or add a new one for this customer.'**
  String get customerShippingAddressSubtitle;

  /// No description provided for @customerShippingAddressSavedTab.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get customerShippingAddressSavedTab;

  /// No description provided for @customerShippingAddressNewTab.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get customerShippingAddressNewTab;

  /// No description provided for @customerShippingAddressEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved shipping addresses yet.'**
  String get customerShippingAddressEmpty;

  /// No description provided for @customerShippingAddressSelectRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a shipping address or add a new one.'**
  String get customerShippingAddressSelectRequired;

  /// No description provided for @customerShippingAddressLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shipping addresses.'**
  String get customerShippingAddressLoadFailed;

  /// No description provided for @customerShippingAddressEditTab.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get customerShippingAddressEditTab;

  /// No description provided for @customerShippingAddressEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Shipping Address'**
  String get customerShippingAddressEditTitle;

  /// No description provided for @customerShippingAddressDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this address? This cannot be undone.'**
  String get customerShippingAddressDeleteConfirm;

  /// No description provided for @customerShippingAddressDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address deleted.'**
  String get customerShippingAddressDeleteSuccess;

  /// No description provided for @customerShippingAddressDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete address.'**
  String get customerShippingAddressDeleteFailed;

  /// No description provided for @customerShippingAddressUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated.'**
  String get customerShippingAddressUpdateSuccess;

  /// No description provided for @customerShippingAddressUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update address.'**
  String get customerShippingAddressUpdateFailed;

  /// No description provided for @customerShippingAddressLine1Label.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get customerShippingAddressLine1Label;

  /// No description provided for @customerShippingAddressLine2Label.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2 (optional)'**
  String get customerShippingAddressLine2Label;

  /// No description provided for @customerShippingAddressTerritoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory'**
  String get customerShippingAddressTerritoryLabel;

  /// No description provided for @customerShippingAddressPincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal Code (optional)'**
  String get customerShippingAddressPincodeLabel;

  /// No description provided for @customerShippingAddressTerritoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a territory.'**
  String get customerShippingAddressTerritoryRequired;

  /// No description provided for @customerShippingAddressLine1Required.
  ///
  /// In en, this message translates to:
  /// **'Address line 1 is required.'**
  String get customerShippingAddressLine1Required;

  /// No description provided for @posAmendmentDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice amendment draft'**
  String get posAmendmentDraftTitle;

  /// No description provided for @posAmendmentDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'Review the changes carefully, then submit to replace the original invoice.'**
  String get posAmendmentDraftMessage;

  /// No description provided for @posAmendmentCheckoutBlocked.
  ///
  /// In en, this message translates to:
  /// **'Amendment submission is unavailable for this draft. Return to the order and reopen the amendment.'**
  String get posAmendmentCheckoutBlocked;

  /// No description provided for @invoiceDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery action failed'**
  String get invoiceDeliveryFailed;

  /// No description provided for @invoiceDeliveryError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String invoiceDeliveryError(Object error);

  /// No description provided for @invoiceDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get invoiceDeliveryTitle;

  /// No description provided for @invoiceUnpaidWarning.
  ///
  /// In en, this message translates to:
  /// **'Invoice is UNPAID. Choose Courier Collects Cash Now to record a cash payment before marking Out For Delivery.'**
  String get invoiceUnpaidWarning;

  /// No description provided for @invoiceCannotSettleParty.
  ///
  /// In en, this message translates to:
  /// **'Cannot settle: courier party not resolved. Assign courier or retry.'**
  String get invoiceCannotSettleParty;

  /// No description provided for @invoiceNothingToSettle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to settle'**
  String get invoiceNothingToSettle;

  /// No description provided for @invoiceSettlementComplete.
  ///
  /// In en, this message translates to:
  /// **'Settlement complete'**
  String get invoiceSettlementComplete;

  /// No description provided for @invoiceEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer Address'**
  String get invoiceEditAddress;

  /// No description provided for @invoicePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get invoicePhoneNumber;

  /// No description provided for @invoiceDeliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get invoiceDeliveryAddressLabel;

  /// No description provided for @invoiceAddressHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the full delivery address'**
  String get invoiceAddressHelper;

  /// No description provided for @invoiceAddressUpdateInfo.
  ///
  /// In en, this message translates to:
  /// **'This will update the customer\'\'s default address and phone number.'**
  String get invoiceAddressUpdateInfo;

  /// No description provided for @invoiceAddressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Address cannot be empty'**
  String get invoiceAddressEmpty;

  /// No description provided for @invoiceUpdatingAddress.
  ///
  /// In en, this message translates to:
  /// **'Updating customer address...'**
  String get invoiceUpdatingAddress;

  /// No description provided for @invoiceAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer address updated successfully'**
  String get invoiceAddressUpdated;

  /// No description provided for @invoiceAddressUpdatedWithShipping.
  ///
  /// In en, this message translates to:
  /// **'Address updated. Shipping: {oldExpense} → {newExpense} EGP'**
  String invoiceAddressUpdatedWithShipping(
    Object oldExpense,
    Object newExpense,
  );

  /// No description provided for @invoiceAddressUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update address'**
  String get invoiceAddressUpdateFailed;

  /// No description provided for @invoiceCopiedNumber.
  ///
  /// In en, this message translates to:
  /// **'Copied: {number}'**
  String invoiceCopiedNumber(Object number);

  /// No description provided for @invoiceCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get invoiceCopy;

  /// No description provided for @invoiceCannotCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to make phone call'**
  String get invoiceCannotCall;

  /// No description provided for @invoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get invoiceCall;

  /// No description provided for @invoiceSettleBeforeCancel.
  ///
  /// In en, this message translates to:
  /// **'Settle or refund partial payments before cancelling this order.'**
  String get invoiceSettleBeforeCancel;

  /// No description provided for @invoiceCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order. Please try again.'**
  String get invoiceCancelFailed;

  /// No description provided for @invoiceCancelledWithCn.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled. Credit note {creditNote} created.'**
  String invoiceCancelledWithCn(Object creditNote);

  /// No description provided for @invoiceCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully.'**
  String get invoiceCancelledSuccess;

  /// No description provided for @invoiceNoPosProfile.
  ///
  /// In en, this message translates to:
  /// **'No POS profile selected'**
  String get invoiceNoPosProfile;

  /// No description provided for @invoiceAssignBranch.
  ///
  /// In en, this message translates to:
  /// **'Assign to Branch'**
  String get invoiceAssignBranch;

  /// No description provided for @invoiceCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String invoiceCustomerName(Object name);

  /// No description provided for @invoiceInvoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {name}'**
  String invoiceInvoiceLabel(Object name);

  /// No description provided for @invoiceTransferInfo.
  ///
  /// In en, this message translates to:
  /// **'The order will be moved to the selected branch and reset to Received state.'**
  String get invoiceTransferInfo;

  /// No description provided for @invoiceTransferring.
  ///
  /// In en, this message translates to:
  /// **'Transferring order...'**
  String get invoiceTransferring;

  /// No description provided for @invoiceTransferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order transferred successfully to {branch}'**
  String invoiceTransferSuccess(Object branch);

  /// No description provided for @invoiceTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed. Please try again.'**
  String get invoiceTransferFailed;

  /// No description provided for @invoiceCannotDetermineProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine POS profile for this invoice'**
  String get invoiceCannotDetermineProfile;

  /// No description provided for @invoiceLoadingSlots.
  ///
  /// In en, this message translates to:
  /// **'Loading delivery slots...'**
  String get invoiceLoadingSlots;

  /// No description provided for @invoiceNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No delivery slots available for this branch'**
  String get invoiceNoSlots;

  /// No description provided for @invoiceChangeSlot.
  ///
  /// In en, this message translates to:
  /// **'Change Delivery Slot'**
  String get invoiceChangeSlot;

  /// No description provided for @invoiceCurrentSlot.
  ///
  /// In en, this message translates to:
  /// **'Current: {slot}'**
  String invoiceCurrentSlot(Object slot);

  /// No description provided for @invoiceSlotUpdateInfo.
  ///
  /// In en, this message translates to:
  /// **'The delivery slot will be updated for this order.'**
  String get invoiceSlotUpdateInfo;

  /// No description provided for @invoiceNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes made'**
  String get invoiceNoChanges;

  /// No description provided for @invoiceUpdatingSlot.
  ///
  /// In en, this message translates to:
  /// **'Updating delivery slot...'**
  String get invoiceUpdatingSlot;

  /// No description provided for @invoiceSlotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Delivery slot updated to {slot}'**
  String invoiceSlotUpdated(Object slot);

  /// No description provided for @invoiceSlotUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update delivery slot'**
  String get invoiceSlotUpdateFailed;

  /// No description provided for @tripsDeliveryTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Trips'**
  String get tripsDeliveryTripsTitle;

  /// No description provided for @tripsActiveTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tripsActiveTab;

  /// No description provided for @tripsCompletedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tripsCompletedTab;

  /// No description provided for @tripsCreateTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Delivery Trip'**
  String get tripsCreateTripTitle;

  /// No description provided for @tripsCreateTripButton.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get tripsCreateTripButton;

  /// No description provided for @tripsCreateTripFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create trip: {error}'**
  String tripsCreateTripFailed(Object error);

  /// No description provided for @tripsOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tripsOrdersLabel;

  /// No description provided for @tripsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get tripsTotalAmount;

  /// No description provided for @tripsTotalShipping.
  ///
  /// In en, this message translates to:
  /// **'Total Shipping'**
  String get tripsTotalShipping;

  /// No description provided for @tripsSameTerritory.
  ///
  /// In en, this message translates to:
  /// **'Same territory: {territory}'**
  String tripsSameTerritory(Object territory);

  /// No description provided for @tripsSelectCourier.
  ///
  /// In en, this message translates to:
  /// **'Select Courier'**
  String get tripsSelectCourier;

  /// No description provided for @tripsNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips'**
  String get tripsNoTrips;

  /// No description provided for @tripsOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String tripsOrdersCount(Object count);

  /// No description provided for @tripsDoubleShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Double Shipping'**
  String get tripsDoubleShippingLabel;

  /// No description provided for @tripsNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tripsNotesLabel;

  /// No description provided for @tripsMarkTripAsDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark Trip as Delivered'**
  String get tripsMarkTripAsDeliveredTitle;

  /// No description provided for @tripsMarkTripAsDeliveredContent.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{tripName}\" with {count} orders as delivered?'**
  String tripsMarkTripAsDeliveredContent(Object tripName, Object count);

  /// No description provided for @tripsTripMarkedAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'{tripName} marked as delivered'**
  String tripsTripMarkedAsDelivered(Object tripName);

  /// No description provided for @tripsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String tripsFailed(Object error);

  /// No description provided for @tripsSendForDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Send for Delivery'**
  String get tripsSendForDeliveryTitle;

  /// No description provided for @tripsSendForDeliveryContent.
  ///
  /// In en, this message translates to:
  /// **'Send {count} orders for delivery?\n\nCourier: {courierName}'**
  String tripsSendForDeliveryContent(Object count, Object courierName);

  /// No description provided for @tripsSentForDeliverySuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip sent for delivery'**
  String get tripsSentForDeliverySuccess;

  /// No description provided for @tripsMarkAsDeliveredButton.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get tripsMarkAsDeliveredButton;

  /// No description provided for @tripsMarkAllAsDeliveredContent.
  ///
  /// In en, this message translates to:
  /// **'Mark all {count} orders as delivered?\n\nThis will complete the trip.'**
  String tripsMarkAllAsDeliveredContent(Object count);

  /// No description provided for @tripsTripMarkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip marked as delivered'**
  String get tripsTripMarkedSuccess;

  /// No description provided for @tripsSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get tripsSending;

  /// No description provided for @tripsMarking.
  ///
  /// In en, this message translates to:
  /// **'Marking...'**
  String get tripsMarking;

  /// No description provided for @tripsSubTerritoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a sub-territory for the following orders before creating a trip: {invoices}'**
  String tripsSubTerritoryRequired(Object invoices);

  /// No description provided for @tripsInvoicesCount.
  ///
  /// In en, this message translates to:
  /// **'Invoices ({count})'**
  String tripsInvoicesCount(Object count);

  /// No description provided for @subTerritorySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Sub-territory'**
  String get subTerritorySelectTitle;

  /// No description provided for @subTerritoryForTerritory.
  ///
  /// In en, this message translates to:
  /// **'for {territory}'**
  String subTerritoryForTerritory(Object territory);

  /// No description provided for @subTerritoryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No sub-territories found'**
  String get subTerritoryNoResults;

  /// No description provided for @subTerritoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sub-territories'**
  String get subTerritoryLoadFailed;

  /// No description provided for @customShippingBadgePending.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping pending'**
  String get customShippingBadgePending;

  /// No description provided for @customShippingBadgeApproved.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping approved'**
  String get customShippingBadgeApproved;

  /// No description provided for @customShippingBadgeAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping {amount}'**
  String customShippingBadgeAmount(Object amount);

  /// No description provided for @customShippingBadgeRejected.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping rejected'**
  String get customShippingBadgeRejected;

  /// No description provided for @returnBadgeFull.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returnBadgeFull;

  /// No description provided for @returnBadgePartial.
  ///
  /// In en, this message translates to:
  /// **'Partially returned'**
  String get returnBadgePartial;

  /// No description provided for @returnBadgeFullAmount.
  ///
  /// In en, this message translates to:
  /// **'Returned {amount}'**
  String returnBadgeFullAmount(Object amount);

  /// No description provided for @returnBadgePartialAmount.
  ///
  /// In en, this message translates to:
  /// **'Partially returned {amount}'**
  String returnBadgePartialAmount(Object amount);

  /// No description provided for @receiptSelectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get receiptSelectImageSource;

  /// No description provided for @receiptCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get receiptCamera;

  /// No description provided for @receiptGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get receiptGallery;

  /// No description provided for @receiptUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading receipt image...'**
  String get receiptUploading;

  /// No description provided for @receiptUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt image uploaded successfully'**
  String get receiptUploadedSuccess;

  /// No description provided for @receiptUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload receipt image'**
  String get receiptUploadFailed;

  /// No description provided for @receiptUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String receiptUploadError(Object error);

  /// No description provided for @receiptConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming receipt...'**
  String get receiptConfirming;

  /// No description provided for @receiptConfirmedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt confirmed successfully'**
  String get receiptConfirmedSuccess;

  /// No description provided for @receiptConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm receipt'**
  String get receiptConfirmFailed;

  /// No description provided for @receiptConfirmError.
  ///
  /// In en, this message translates to:
  /// **'Error confirming receipt: {error}'**
  String receiptConfirmError(Object error);

  /// No description provided for @receiptAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'All Profiles'**
  String get receiptAllProfiles;

  /// No description provided for @receiptFilterByPosProfile.
  ///
  /// In en, this message translates to:
  /// **'Filter by POS Profile'**
  String get receiptFilterByPosProfile;

  /// No description provided for @receiptNoReceiptsFound.
  ///
  /// In en, this message translates to:
  /// **'No payment receipts found'**
  String get receiptNoReceiptsFound;

  /// No description provided for @receiptUploadImageButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt Image'**
  String get receiptUploadImageButton;

  /// No description provided for @receiptReplaceImageButton.
  ///
  /// In en, this message translates to:
  /// **'Replace Image'**
  String get receiptReplaceImageButton;

  /// No description provided for @receiptRemoveImageButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get receiptRemoveImageButton;

  /// No description provided for @receiptRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt image?'**
  String get receiptRemoveConfirmTitle;

  /// No description provided for @receiptRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The uploaded screenshot will be deleted. You can upload a new one afterwards.'**
  String get receiptRemoveConfirmBody;

  /// No description provided for @receiptRemoving.
  ///
  /// In en, this message translates to:
  /// **'Removing receipt image...'**
  String get receiptRemoving;

  /// No description provided for @receiptRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt image removed'**
  String get receiptRemovedSuccess;

  /// No description provided for @receiptRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove receipt image'**
  String get receiptRemoveFailed;

  /// No description provided for @receiptRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error removing image: {error}'**
  String receiptRemoveError(Object error);

  /// No description provided for @receiptPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt Preview'**
  String get receiptPreviewTitle;

  /// No description provided for @receiptPreviewButton.
  ///
  /// In en, this message translates to:
  /// **'Preview Receipt'**
  String get receiptPreviewButton;

  /// No description provided for @commonPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get commonPrint;

  /// No description provided for @statusCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get statusCreated;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get statusOutForDelivery;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get statusReturn;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @statusReturnedToSender.
  ///
  /// In en, this message translates to:
  /// **'Returned to Sender'**
  String get statusReturnedToSender;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed'**
  String get statusUnconfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPendingApproval;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @kanbanNoInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices'**
  String get kanbanNoInvoices;

  /// No description provided for @kanbanTripCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delivery trip created successfully'**
  String get kanbanTripCreatedSuccess;

  /// No description provided for @kanbanPartOfTripWarning.
  ///
  /// In en, this message translates to:
  /// **'This order is part of trip {tripName}. Send the entire trip for delivery from the Trips screen.'**
  String kanbanPartOfTripWarning(Object tripName);

  /// No description provided for @kanbanOfdAwaitingInstapay.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery — awaiting InstaPay'**
  String get kanbanOfdAwaitingInstapay;

  /// No description provided for @kanbanOfdAwaitingInstapayWithCourier.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery with {courier} — awaiting InstaPay'**
  String kanbanOfdAwaitingInstapayWithCourier(Object courier);

  /// No description provided for @kanbanDeliveryPartnerCourier.
  ///
  /// In en, this message translates to:
  /// **'Delivery Partner Courier'**
  String get kanbanDeliveryPartnerCourier;

  /// No description provided for @kanbanDeliveryPartnerCourierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This courier belongs to a delivery partner'**
  String get kanbanDeliveryPartnerCourierSubtitle;

  /// No description provided for @kanbanRequestCustomShipping.
  ///
  /// In en, this message translates to:
  /// **'Request Custom Shipping'**
  String get kanbanRequestCustomShipping;

  /// No description provided for @customShippingCurrentShipping.
  ///
  /// In en, this message translates to:
  /// **'Current Shipping'**
  String get customShippingCurrentShipping;

  /// No description provided for @customShippingRequestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get customShippingRequestedAmount;

  /// No description provided for @customShippingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why custom shipping is needed...'**
  String get customShippingReasonHint;

  /// No description provided for @customShippingAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get customShippingAmountRequired;

  /// No description provided for @customShippingAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount'**
  String get customShippingAmountInvalid;

  /// No description provided for @customShippingReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason (min 10 characters)'**
  String get customShippingReasonRequired;

  /// No description provided for @customShippingSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get customShippingSubmitRequest;

  /// No description provided for @kanbanCustomShippingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping request submitted'**
  String get kanbanCustomShippingSubmitted;

  /// No description provided for @kanbanCustomShippingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request: {error}'**
  String kanbanCustomShippingFailed(Object error);

  /// No description provided for @settlementPartnerDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Delivery Settlement'**
  String get settlementPartnerDeliveryTitle;

  /// No description provided for @settlementPartnerInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Settlement Info'**
  String get settlementPartnerInfoTitle;

  /// No description provided for @settlementPartnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner: {name}'**
  String settlementPartnerLabel(Object name);

  /// No description provided for @settlementPartnerCollectFull.
  ///
  /// In en, this message translates to:
  /// **'Collect full order amount from courier:'**
  String get settlementPartnerCollectFull;

  /// No description provided for @settlementPartnerOnlinePaid.
  ///
  /// In en, this message translates to:
  /// **'Online-paid — no cash exchange with courier'**
  String get settlementPartnerOnlinePaid;

  /// No description provided for @settlementPartnerCollectFullChip.
  ///
  /// In en, this message translates to:
  /// **'Collect (Full Amount)'**
  String get settlementPartnerCollectFullChip;

  /// No description provided for @settlementNoExchange.
  ///
  /// In en, this message translates to:
  /// **'No Cash Exchange'**
  String get settlementNoExchange;

  /// No description provided for @settlementPartnerFeeTracked.
  ///
  /// In en, this message translates to:
  /// **'Partner fee (tracked): {amount}'**
  String settlementPartnerFeeTracked(Object amount);

  /// No description provided for @settlementPartnerCollectedFull.
  ///
  /// In en, this message translates to:
  /// **'Collected full order amount from courier'**
  String get settlementPartnerCollectedFull;

  /// No description provided for @settlementPartnerFullAmountChip.
  ///
  /// In en, this message translates to:
  /// **'Full amount'**
  String get settlementPartnerFullAmountChip;

  /// No description provided for @settlementPartnerOnlinePaidInfo.
  ///
  /// In en, this message translates to:
  /// **'Online paid — no cash exchange'**
  String get settlementPartnerOnlinePaidInfo;

  /// No description provided for @managerPendingCustomShipping.
  ///
  /// In en, this message translates to:
  /// **'Pending Custom Shipping Approvals'**
  String get managerPendingCustomShipping;

  /// No description provided for @managerNoPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get managerNoPendingRequests;

  /// No description provided for @managerReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String managerReasonLabel(Object reason);

  /// No description provided for @managerCustomShippingApproved.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping approved'**
  String get managerCustomShippingApproved;

  /// No description provided for @managerApproveFailed.
  ///
  /// In en, this message translates to:
  /// **'Approve failed: {error}'**
  String managerApproveFailed(Object error);

  /// No description provided for @managerRejectCustomShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Custom Shipping'**
  String get managerRejectCustomShippingTitle;

  /// No description provided for @managerReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get managerReject;

  /// No description provided for @managerCustomShippingRejected.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping rejected'**
  String get managerCustomShippingRejected;

  /// No description provided for @managerRejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Reject failed: {error}'**
  String managerRejectFailed(Object error);

  /// No description provided for @managerRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Optional rejection reason'**
  String get managerRejectReasonHint;

  /// No description provided for @managerPendingCustomShippingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load pending custom shipping requests'**
  String get managerPendingCustomShippingLoadFailed;

  /// No description provided for @managerTransferBranchesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transfer branches'**
  String get managerTransferBranchesLoadFailed;

  /// No description provided for @managerApproveDefaultError.
  ///
  /// In en, this message translates to:
  /// **'Unable to approve the request.'**
  String get managerApproveDefaultError;

  /// No description provided for @managerRejectDefaultError.
  ///
  /// In en, this message translates to:
  /// **'Unable to reject the request.'**
  String get managerRejectDefaultError;

  /// No description provided for @purchaseNoInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchase invoices yet'**
  String get purchaseNoInvoicesYet;

  /// No description provided for @purchaseReorderFromSupplier.
  ///
  /// In en, this message translates to:
  /// **'Reorder from same supplier'**
  String get purchaseReorderFromSupplier;

  /// No description provided for @purchaseHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistoryTitle;

  /// No description provided for @posCreateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get posCreateCustomer;

  /// No description provided for @posCustomerCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer created successfully!'**
  String get posCustomerCreatedSuccess;

  /// No description provided for @settingsUserProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get settingsUserProfileTitle;

  /// No description provided for @settingsRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get settingsRolesTitle;

  /// No description provided for @settingsNoRolesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No roles assigned'**
  String get settingsNoRolesAssigned;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsNoAlarmSounds.
  ///
  /// In en, this message translates to:
  /// **'No alarm sounds available'**
  String get settingsNoAlarmSounds;

  /// No description provided for @settingsAlarmSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get settingsAlarmSoundLabel;

  /// No description provided for @settingsFailedToLoadAlarmSounds.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alarm sounds: {error}'**
  String settingsFailedToLoadAlarmSounds(Object error);

  /// No description provided for @settingsAlarmSoundChanged.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound changed to {title}'**
  String settingsAlarmSoundChanged(Object title);

  /// No description provided for @settingsAlarmSoundUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{title} can\'\'t be used on this device. Keeping the default alarm sound.'**
  String settingsAlarmSoundUnavailable(Object title);

  /// No description provided for @settingsCustomAlarmSoundSet.
  ///
  /// In en, this message translates to:
  /// **'Custom alarm sound set: {title}'**
  String settingsCustomAlarmSoundSet(Object title);

  /// No description provided for @settingsNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get settingsNoFileSelected;

  /// No description provided for @settingsBrowseCustomSoundFile.
  ///
  /// In en, this message translates to:
  /// **'Browse Custom Sound File'**
  String get settingsBrowseCustomSoundFile;

  /// No description provided for @settingsCustomSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Sound'**
  String get settingsCustomSoundTitle;

  /// No description provided for @itemGridStockLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Stock limit reached. Only {stockQty} available.'**
  String itemGridStockLimitReached(Object stockQty);

  /// No description provided for @menuDeliveryTrips.
  ///
  /// In en, this message translates to:
  /// **'Delivery Trips'**
  String get menuDeliveryTrips;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTitle;

  /// No description provided for @printingPrintersTitle.
  ///
  /// In en, this message translates to:
  /// **'Printers'**
  String get printingPrintersTitle;

  /// No description provided for @printingUseBitmapReceipt.
  ///
  /// In en, this message translates to:
  /// **'Use new bitmap receipt'**
  String get printingUseBitmapReceipt;

  /// No description provided for @printingUseBitmapReceiptHint.
  ///
  /// In en, this message translates to:
  /// **'Renders the full receipt as an image and helps with Arabic, missing data, and gibberish issues.'**
  String get printingUseBitmapReceiptHint;

  /// No description provided for @kanbanOrdersSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders selected'**
  String kanbanOrdersSelectedCount(int count);

  /// No description provided for @loginModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Login Mode'**
  String get loginModeDialogTitle;

  /// No description provided for @loginModeLineManager.
  ///
  /// In en, this message translates to:
  /// **'Line Manager'**
  String get loginModeLineManager;

  /// No description provided for @loginModeLineManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Skip shift opening — manage operations directly'**
  String get loginModeLineManagerDesc;

  /// No description provided for @loginModeEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get loginModeEmployee;

  /// No description provided for @loginModeEmployeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Open a shift before starting work'**
  String get loginModeEmployeeDesc;

  /// No description provided for @customerSearchByPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by phone number...'**
  String get customerSearchByPhone;

  /// No description provided for @customerSearchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by customer name...'**
  String get customerSearchByName;

  /// No description provided for @quickAddCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Add Customer'**
  String get quickAddCustomerTitle;

  /// No description provided for @quickAddCustomerTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to create new customer'**
  String get quickAddCustomerTap;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name *'**
  String get customerNameLabel;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer name is required'**
  String get customerNameRequired;

  /// No description provided for @customerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer type'**
  String get customerTypeLabel;

  /// No description provided for @customerTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get customerTypeIndividual;

  /// No description provided for @customerTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get customerTypeCompany;

  /// No description provided for @customerGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer group'**
  String get customerGroupLabel;

  /// No description provided for @customerGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer group'**
  String get customerGroupRequired;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number *'**
  String get mobileNumberLabel;

  /// No description provided for @mobileNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberRequired;

  /// No description provided for @secondaryPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary Phone (Optional)'**
  String get secondaryPhoneLabel;

  /// No description provided for @secondaryPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Additional contact number'**
  String get secondaryPhoneHint;

  /// No description provided for @locationLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Link (Optional)'**
  String get locationLinkLabel;

  /// No description provided for @locationLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Google Maps link, etc.'**
  String get locationLinkHint;

  /// No description provided for @locationLinkFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Location link'**
  String get locationLinkFieldLabel;

  /// No description provided for @locationLinkPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a Google Maps link or 30.0444, 31.2357'**
  String get locationLinkPasteHint;

  /// No description provided for @locationLinkChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the location…'**
  String get locationLinkChecking;

  /// No description provided for @locationLinkConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Location confirmed'**
  String get locationLinkConfirmed;

  /// No description provided for @locationLinkUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Location not confirmed yet'**
  String get locationLinkUnconfirmed;

  /// No description provided for @locationLinkClear.
  ///
  /// In en, this message translates to:
  /// **'Clear location link'**
  String get locationLinkClear;

  /// No description provided for @locationLinkRetry.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get locationLinkRetry;

  /// No description provided for @locationLinkDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km from the branch'**
  String locationLinkDistanceKm(Object value);

  /// No description provided for @locationLinkDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m from the branch'**
  String locationLinkDistanceMeters(Object value);

  /// No description provided for @locationLinkErrorUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a Maps link. Paste a Google Maps link or coordinates like 30.0444, 31.2357.'**
  String get locationLinkErrorUnrecognized;

  /// No description provided for @locationLinkErrorUnresolved.
  ///
  /// In en, this message translates to:
  /// **'Could not read a location from this link. Open it in Maps, share it again, and paste the new link.'**
  String get locationLinkErrorUnresolved;

  /// No description provided for @locationLinkErrorTooFar.
  ///
  /// In en, this message translates to:
  /// **'This point is {distance} — too far to be a delivery address. Check the link.'**
  String locationLinkErrorTooFar(Object distance);

  /// No description provided for @locationLinkErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not check the location. Try again.'**
  String get locationLinkErrorNetwork;

  /// No description provided for @detailedAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address *'**
  String get detailedAddressRequired;

  /// No description provided for @detailedAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address (Optional)'**
  String get detailedAddressOptional;

  /// No description provided for @addressOptionalPartner.
  ///
  /// In en, this message translates to:
  /// **'Optional when Sales Partner is selected'**
  String get addressOptionalPartner;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @territoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory *'**
  String get territoryLabel;

  /// No description provided for @territorySelectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a territory'**
  String get territorySelectRequired;

  /// No description provided for @territoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load territories'**
  String get territoryLoadFailed;

  /// No description provided for @unknownTerritory.
  ///
  /// In en, this message translates to:
  /// **'Unknown Territory'**
  String get unknownTerritory;

  /// No description provided for @customerCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create customer'**
  String get customerCreateFailed;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get authInvalidCredentials;

  /// No description provided for @authCannotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.'**
  String get authCannotReachServer;

  /// No description provided for @authConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please verify network and server availability.'**
  String get authConnectionFailed;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get authLoginFailed;

  /// No description provided for @menuReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsFinalProducts.
  ///
  /// In en, this message translates to:
  /// **'Final Products'**
  String get reportsFinalProducts;

  /// No description provided for @reportsFinalProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stock count by warehouse for Medium & Large items'**
  String get reportsFinalProductsDesc;

  /// No description provided for @reportsMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials & Consumables'**
  String get reportsMaterials;

  /// No description provided for @reportsMaterialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Raw materials, sub assemblies, and consumables stock'**
  String get reportsMaterialsDesc;

  /// No description provided for @reportsRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw Materials'**
  String get reportsRawMaterials;

  /// No description provided for @reportsSubAssemblies.
  ///
  /// In en, this message translates to:
  /// **'Sub Assemblies'**
  String get reportsSubAssemblies;

  /// No description provided for @reportsConsumables.
  ///
  /// In en, this message translates to:
  /// **'Consumables'**
  String get reportsConsumables;

  /// No description provided for @reportsItemName.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get reportsItemName;

  /// No description provided for @reportsItemGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get reportsItemGroup;

  /// No description provided for @reportsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportsTotal;

  /// No description provided for @reportsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get reportsNoData;

  /// No description provided for @reportsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get reportsRetry;

  /// No description provided for @reportsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get reportsComingSoon;

  /// No description provided for @reportsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get reportsFrom;

  /// No description provided for @reportsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get reportsTo;

  /// No description provided for @reportsRangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get reportsRangeThisMonth;

  /// No description provided for @reportsRangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get reportsRangeLast30Days;

  /// No description provided for @reportsRangeLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get reportsRangeLast90Days;

  /// No description provided for @reportShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping Analytics'**
  String get reportShippingTitle;

  /// No description provided for @reportShippingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery cost, courier settlements & shipping P&L'**
  String get reportShippingSubtitle;

  /// No description provided for @reportInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Intelligence'**
  String get reportInventoryTitle;

  /// No description provided for @reportInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stock velocity, critical items & movers'**
  String get reportInventorySubtitle;

  /// No description provided for @reportProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Analytics'**
  String get reportProductTitle;

  /// No description provided for @reportProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue, gross profit & best sellers by product'**
  String get reportProductSubtitle;

  /// No description provided for @reportCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Analytics'**
  String get reportCustomerTitle;

  /// No description provided for @reportCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Segments, retention & at-risk customers'**
  String get reportCustomerSubtitle;

  /// No description provided for @reportExecutiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Executive Overview'**
  String get reportExecutiveTitle;

  /// No description provided for @reportExecutiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top-line KPIs across the whole business'**
  String get reportExecutiveSubtitle;

  /// No description provided for @reportB2bTitle.
  ///
  /// In en, this message translates to:
  /// **'B2B Sales & Clients'**
  String get reportB2bTitle;

  /// No description provided for @reportB2bSubtitle.
  ///
  /// In en, this message translates to:
  /// **'B2B revenue, pipeline & client health'**
  String get reportB2bSubtitle;

  /// Empty state on an analytics dashboard when the selected period has no data
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get reportNoData;

  /// Error state shown when an analytics dashboard fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'\'t load report'**
  String get reportError;

  /// Section header for alerts/warnings on an analytics dashboard
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get reportAlerts;

  /// Shipping analytics KPI: total number of orders
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get reportShipKpiTotalOrders;

  /// Shipping analytics KPI: number of delivery orders
  ///
  /// In en, this message translates to:
  /// **'Delivery Orders'**
  String get reportShipKpiDeliveryOrders;

  /// Shipping analytics KPI: number of pickup orders
  ///
  /// In en, this message translates to:
  /// **'Pickup Orders'**
  String get reportShipKpiPickupOrders;

  /// Shipping analytics KPI: total shipping/courier expense
  ///
  /// In en, this message translates to:
  /// **'Shipping Expense'**
  String get reportShipKpiExpense;

  /// Shipping analytics KPI: total delivery income charged
  ///
  /// In en, this message translates to:
  /// **'Delivery Income'**
  String get reportShipKpiIncome;

  /// Shipping analytics KPI: net shipping profit and loss
  ///
  /// In en, this message translates to:
  /// **'Net P&L'**
  String get reportShipKpiNetPl;

  /// Shipping analytics KPI: average shipping cost per order
  ///
  /// In en, this message translates to:
  /// **'Avg Cost / Order'**
  String get reportShipKpiAvgCost;

  /// Shipping analytics KPI: number of pending shipping overrides
  ///
  /// In en, this message translates to:
  /// **'Pending Overrides'**
  String get reportShipKpiPendingOverrides;

  /// Shipping analytics KPI: unsettled courier balances amount
  ///
  /// In en, this message translates to:
  /// **'Unsettled'**
  String get reportShipKpiUnsettled;

  /// Shipping analytics section: shipping cost broken down by territory
  ///
  /// In en, this message translates to:
  /// **'Cost by Territory'**
  String get reportCostByTerritory;

  /// Shipping analytics section: shipping cost broken down by sub-territory
  ///
  /// In en, this message translates to:
  /// **'Cost by Sub-Territory'**
  String get reportCostBySubTerritory;

  /// Shipping analytics section: shipping cost broken down by branch
  ///
  /// In en, this message translates to:
  /// **'Cost by Branch'**
  String get reportCostByBranch;

  /// Shipping analytics section: shipping cost broken down by courier
  ///
  /// In en, this message translates to:
  /// **'Cost by Courier'**
  String get reportCostByCourier;

  /// Shipping analytics section: list of shipping fee overrides
  ///
  /// In en, this message translates to:
  /// **'Shipping Overrides'**
  String get reportShippingOverrides;

  /// Shipping analytics section: financial impact of double-shipping
  ///
  /// In en, this message translates to:
  /// **'Double-Shipping Impact'**
  String get reportDoubleShipping;

  /// Shipping analytics section: daily trend chart
  ///
  /// In en, this message translates to:
  /// **'Daily Trend'**
  String get reportDailyTrend;

  /// Shipping analytics section: pickup versus delivery comparison
  ///
  /// In en, this message translates to:
  /// **'Pickup vs Delivery'**
  String get reportPickupVsDelivery;

  /// Shipping analytics section: unsettled courier balances list
  ///
  /// In en, this message translates to:
  /// **'Unsettled Courier Balances'**
  String get reportUnsettledBalances;

  /// Shipping analytics section: pickup and delivery trend over time
  ///
  /// In en, this message translates to:
  /// **'Pickup / Delivery Trend'**
  String get reportPickupDeliveryTrend;

  /// Inventory analytics KPI: total number of stock items
  ///
  /// In en, this message translates to:
  /// **'Stock Items'**
  String get reportInvKpiStockItems;

  /// Inventory analytics KPI: number of critical stock items
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get reportInvKpiCritical;

  /// Inventory analytics KPI: number of watch-list items
  ///
  /// In en, this message translates to:
  /// **'Watch List'**
  String get reportInvKpiWatch;

  /// Inventory analytics KPI: number of slow-moving items
  ///
  /// In en, this message translates to:
  /// **'Slow Movers'**
  String get reportInvKpiSlow;

  /// Inventory analytics KPI: number of overstocked items
  ///
  /// In en, this message translates to:
  /// **'Overstocked'**
  String get reportInvKpiOverstock;

  /// Inventory analytics KPI: total valuation of stock on hand
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get reportInvKpiStockValue;

  /// Inventory analytics section: stock velocity chart
  ///
  /// In en, this message translates to:
  /// **'Stock Velocity'**
  String get reportStockVelocity;

  /// Inventory analytics section: fastest-moving items
  ///
  /// In en, this message translates to:
  /// **'Top Movers'**
  String get reportTopMovers;

  /// Inventory analytics section: items needing restock
  ///
  /// In en, this message translates to:
  /// **'Restock Alerts'**
  String get reportRestockAlerts;

  /// Inventory analytics section header: critical items
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get reportCriticalItems;

  /// Inventory analytics section header: watch-list items
  ///
  /// In en, this message translates to:
  /// **'Watch List'**
  String get reportWatchList;

  /// Inventory analytics section header: slow-moving items
  ///
  /// In en, this message translates to:
  /// **'Slow Movers'**
  String get reportSlowMovers;

  /// Inventory analytics section header: overstocked items
  ///
  /// In en, this message translates to:
  /// **'Overstocked'**
  String get reportOverstocked;

  /// Inventory analytics section: best-selling items
  ///
  /// In en, this message translates to:
  /// **'Top Sellers'**
  String get reportTopSellers;

  /// Product analytics KPI: total revenue
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get reportKpiTotalRevenue;

  /// Product analytics KPI: total number of orders
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get reportKpiTotalOrders;

  /// Product analytics KPI: gross profit
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get reportKpiGrossProfit;

  /// Product analytics KPI: gross margin percentage
  ///
  /// In en, this message translates to:
  /// **'Gross Margin'**
  String get reportKpiGrossMargin;

  /// Product analytics KPI: average order value
  ///
  /// In en, this message translates to:
  /// **'Avg Order Value'**
  String get reportKpiAov;

  /// Product analytics KPI: best-selling product
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get reportKpiBestSeller;

  /// Product analytics KPI: top territory by revenue
  ///
  /// In en, this message translates to:
  /// **'Top Territory'**
  String get reportKpiTopTerritory;

  /// Product analytics section: revenue split by product type
  ///
  /// In en, this message translates to:
  /// **'Revenue by Type'**
  String get reportRevenueByType;

  /// Product analytics section: top products by revenue
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get reportTopProducts;

  /// Product analytics section: breakdown by territory
  ///
  /// In en, this message translates to:
  /// **'By Territory'**
  String get reportByTerritory;

  /// Revenue trend chart, shared by Product/Executive/B2B dashboards
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get reportRevenueTrend;

  /// Product analytics section: composition of bundle sales
  ///
  /// In en, this message translates to:
  /// **'Bundle Composition'**
  String get reportBundleComposition;

  /// Customer analytics KPI: total number of customers
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get reportKpiTotalCustomers;

  /// Customer analytics KPI: number of active customers
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get reportKpiActive;

  /// Customer analytics KPI: number of new customers
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get reportKpiNew;

  /// Customer analytics KPI: repeat purchase rate
  ///
  /// In en, this message translates to:
  /// **'Repeat Rate'**
  String get reportKpiRepeatRate;

  /// Customer analytics KPI: number of champion customers
  ///
  /// In en, this message translates to:
  /// **'Champions'**
  String get reportKpiChampions;

  /// Customer analytics KPI: number of at-risk customers
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get reportKpiAtRisk;

  /// Customer analytics KPI: number of lost customers
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get reportKpiLost;

  /// Customer analytics section: distribution across segments
  ///
  /// In en, this message translates to:
  /// **'Segment Distribution'**
  String get reportSegmentDistribution;

  /// Customer analytics section: detail for a customer segment
  ///
  /// In en, this message translates to:
  /// **'Segment Detail'**
  String get reportSegmentDetail;

  /// Customer analytics section: top customers by revenue
  ///
  /// In en, this message translates to:
  /// **'Top Customers'**
  String get reportTopCustomers;

  /// Customer analytics section: at-risk and win-back customers
  ///
  /// In en, this message translates to:
  /// **'At-Risk / Win-Back'**
  String get reportAtRiskWinBack;

  /// Customer analytics section: new customer acquisition trend
  ///
  /// In en, this message translates to:
  /// **'New Customer Acquisition'**
  String get reportNewCustomerAcquisition;

  /// Executive analytics KPI: total revenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get reportKpiRevenue;

  /// Executive analytics KPI: total orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get reportKpiOrders;

  /// Executive analytics KPI: net shipping profit and loss
  ///
  /// In en, this message translates to:
  /// **'Net Shipping P&L'**
  String get reportKpiNetShippingPl;

  /// Executive analytics KPI: total customers
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get reportKpiCustomers;

  /// Executive analytics KPI: number of critical-stock items
  ///
  /// In en, this message translates to:
  /// **'Critical Stock'**
  String get reportKpiCriticalStock;

  /// Executive analytics section: product mix breakdown
  ///
  /// In en, this message translates to:
  /// **'Product Mix'**
  String get reportProductMix;

  /// Executive analytics section: customer segment breakdown
  ///
  /// In en, this message translates to:
  /// **'Customer Segments'**
  String get reportCustomerSegments;

  /// Executive analytics section: top territories by revenue
  ///
  /// In en, this message translates to:
  /// **'Top Territories'**
  String get reportTopTerritories;

  /// B2B analytics KPI: total B2B revenue
  ///
  /// In en, this message translates to:
  /// **'B2B Revenue'**
  String get reportKpiB2bRevenue;

  /// B2B analytics KPI: total B2B orders
  ///
  /// In en, this message translates to:
  /// **'B2B Orders'**
  String get reportKpiB2bOrders;

  /// B2B analytics KPI: number of active clients
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get reportKpiActiveClients;

  /// B2B analytics KPI: number of new clients
  ///
  /// In en, this message translates to:
  /// **'New Clients'**
  String get reportKpiNewClients;

  /// B2B analytics KPI: number of clients due for reorder
  ///
  /// In en, this message translates to:
  /// **'Reorder Due'**
  String get reportKpiReorderDue;

  /// B2B analytics section: sales pipeline by stage
  ///
  /// In en, this message translates to:
  /// **'Sales Pipeline'**
  String get reportSalesPipeline;

  /// B2B analytics section: top clients by revenue
  ///
  /// In en, this message translates to:
  /// **'Top Clients'**
  String get reportTopClients;

  /// B2B analytics section: revenue split by commercial policy
  ///
  /// In en, this message translates to:
  /// **'Revenue by Commercial Policy'**
  String get reportRevenueByPolicy;

  /// B2B analytics section: clients grouped by customer group
  ///
  /// In en, this message translates to:
  /// **'Clients by Group'**
  String get reportClientsByGroup;

  /// B2B analytics section header: clients due for reorder
  ///
  /// In en, this message translates to:
  /// **'Reorder Due'**
  String get reportReorderDue;

  /// B2B analytics section: at-risk clients
  ///
  /// In en, this message translates to:
  /// **'At-Risk Clients'**
  String get reportAtRiskClients;

  /// B2B analytics section: lead-to-client conversion
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get reportConversion;

  /// No description provided for @menuMasterOrders.
  ///
  /// In en, this message translates to:
  /// **'Master Orders'**
  String get menuMasterOrders;

  /// No description provided for @masterOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Orders'**
  String get masterOrdersTitle;

  /// No description provided for @masterOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order ID, customer...'**
  String get masterOrdersSearchHint;

  /// No description provided for @masterOrdersNoResults.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get masterOrdersNoResults;

  /// No description provided for @masterOrdersClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get masterOrdersClearFilters;

  /// No description provided for @masterOrdersResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String masterOrdersResultCount(int count);

  /// No description provided for @masterOrdersFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get masterOrdersFilterStatus;

  /// No description provided for @masterOrdersFilterBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get masterOrdersFilterBranch;

  /// No description provided for @masterOrdersFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get masterOrdersFilterPayment;

  /// No description provided for @masterOrdersFilterDate.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get masterOrdersFilterDate;

  /// No description provided for @masterOrdersFilterDateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get masterOrdersFilterDateFrom;

  /// No description provided for @masterOrdersFilterDateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get masterOrdersFilterDateTo;

  /// No description provided for @masterOrdersOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get masterOrdersOutstanding;

  /// No description provided for @masterOrdersCurrency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get masterOrdersCurrency;

  /// No description provided for @menuShiftMonitor.
  ///
  /// In en, this message translates to:
  /// **'Shift Monitor'**
  String get menuShiftMonitor;

  /// No description provided for @shiftMonitorTitle.
  ///
  /// In en, this message translates to:
  /// **'POS Shift Monitor'**
  String get shiftMonitorTitle;

  /// No description provided for @shiftMonitorAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager access required'**
  String get shiftMonitorAccessRequired;

  /// No description provided for @shiftMonitorAccessDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'This page is available to JARZ Manager roles and above.'**
  String get shiftMonitorAccessDeniedBody;

  /// No description provided for @shiftMonitorFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get shiftMonitorFiltersTitle;

  /// No description provided for @shiftMonitorToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get shiftMonitorToday;

  /// No description provided for @shiftMonitorLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get shiftMonitorLast7Days;

  /// No description provided for @shiftMonitorCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get shiftMonitorCustomRange;

  /// No description provided for @shiftMonitorPickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Pick Date Range'**
  String get shiftMonitorPickDateRange;

  /// No description provided for @shiftMonitorDateRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String shiftMonitorDateRangeValue(Object from, Object to);

  /// No description provided for @shiftMonitorProfileFilter.
  ///
  /// In en, this message translates to:
  /// **'POS Profile'**
  String get shiftMonitorProfileFilter;

  /// No description provided for @shiftMonitorStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get shiftMonitorStatusFilter;

  /// No description provided for @shiftMonitorStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shiftMonitorStatusAll;

  /// No description provided for @shiftMonitorStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shiftMonitorStatusOpen;

  /// No description provided for @shiftMonitorStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get shiftMonitorStatusClosed;

  /// No description provided for @shiftMonitorNoData.
  ///
  /// In en, this message translates to:
  /// **'No shifts found for the selected filters.'**
  String get shiftMonitorNoData;

  /// No description provided for @shiftMonitorOpenCount.
  ///
  /// In en, this message translates to:
  /// **'Open Shifts'**
  String get shiftMonitorOpenCount;

  /// No description provided for @shiftMonitorClosedCount.
  ///
  /// In en, this message translates to:
  /// **'Closed Shifts'**
  String get shiftMonitorClosedCount;

  /// No description provided for @shiftMonitorDiscrepancyCount.
  ///
  /// In en, this message translates to:
  /// **'Discrepancies'**
  String get shiftMonitorDiscrepancyCount;

  /// No description provided for @shiftMonitorDiscrepancyTotal.
  ///
  /// In en, this message translates to:
  /// **'Discrepancy Total'**
  String get shiftMonitorDiscrepancyTotal;

  /// No description provided for @shiftMonitorLatestStart.
  ///
  /// In en, this message translates to:
  /// **'Latest start: {value}'**
  String shiftMonitorLatestStart(Object value);

  /// No description provided for @shiftMonitorShiftCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shifts'**
  String shiftMonitorShiftCount(Object count);

  /// No description provided for @shiftMonitorOpenedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened At'**
  String get shiftMonitorOpenedAt;

  /// No description provided for @shiftMonitorOpenedBy.
  ///
  /// In en, this message translates to:
  /// **'Opened By'**
  String get shiftMonitorOpenedBy;

  /// No description provided for @shiftMonitorClosedAt.
  ///
  /// In en, this message translates to:
  /// **'Closed At'**
  String get shiftMonitorClosedAt;

  /// No description provided for @shiftMonitorClosedBy.
  ///
  /// In en, this message translates to:
  /// **'Closed By'**
  String get shiftMonitorClosedBy;

  /// No description provided for @shiftMonitorCashAccount.
  ///
  /// In en, this message translates to:
  /// **'Cash Account'**
  String get shiftMonitorCashAccount;

  /// No description provided for @shiftMonitorOpeningCash.
  ///
  /// In en, this message translates to:
  /// **'Opening Cash'**
  String get shiftMonitorOpeningCash;

  /// No description provided for @shiftMonitorExpectedClosingCash.
  ///
  /// In en, this message translates to:
  /// **'Expected Closing'**
  String get shiftMonitorExpectedClosingCash;

  /// No description provided for @shiftMonitorActualClosingCash.
  ///
  /// In en, this message translates to:
  /// **'Actual Closing'**
  String get shiftMonitorActualClosingCash;

  /// No description provided for @shiftMonitorDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get shiftMonitorDifference;

  /// No description provided for @shiftMonitorDifferenceSurplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get shiftMonitorDifferenceSurplus;

  /// No description provided for @shiftMonitorDifferenceShortage.
  ///
  /// In en, this message translates to:
  /// **'Shortage'**
  String get shiftMonitorDifferenceShortage;

  /// No description provided for @shiftMonitorNoDiscrepancy.
  ///
  /// In en, this message translates to:
  /// **'No discrepancy'**
  String get shiftMonitorNoDiscrepancy;

  /// No description provided for @shorebirdUpdateBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version is ready — fully close and reopen the app to apply it.'**
  String get shorebirdUpdateBannerMessage;

  /// No description provided for @aboutRestartInstruction.
  ///
  /// In en, this message translates to:
  /// **'Force-close and reopen the app to apply the downloaded patch.'**
  String get aboutRestartInstruction;

  /// No description provided for @aboutPatchPending.
  ///
  /// In en, this message translates to:
  /// **'Pending patch (after restart)'**
  String get aboutPatchPending;

  /// No description provided for @menuLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get menuLeads;

  /// No description provided for @leadFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get leadFieldEmail;

  /// No description provided for @leadFieldSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get leadFieldSource;

  /// No description provided for @leadFieldTerritory.
  ///
  /// In en, this message translates to:
  /// **'Territory'**
  String get leadFieldTerritory;

  /// No description provided for @leadB2bStage.
  ///
  /// In en, this message translates to:
  /// **'B2B Stage'**
  String get leadB2bStage;

  /// No description provided for @leadFitScore.
  ///
  /// In en, this message translates to:
  /// **'Fit Score'**
  String get leadFitScore;

  /// No description provided for @b2bMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get b2bMoveTo;

  /// No description provided for @shiftMonitorForceCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close This Shift'**
  String get shiftMonitorForceCloseAction;

  /// No description provided for @shiftMonitorForceCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Close {user}\'\'s Shift'**
  String shiftMonitorForceCloseTitle(String user);

  /// No description provided for @shiftMonitorForceCloseIntro.
  ///
  /// In en, this message translates to:
  /// **'You are closing a shift opened by {user} on {branch}. Enter the cash actually counted in the drawer — any difference posts a Cash Over/Short entry, exactly as a normal close would.'**
  String shiftMonitorForceCloseIntro(String user, String branch);

  /// No description provided for @shiftMonitorForceCloseReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get shiftMonitorForceCloseReasonLabel;

  /// No description provided for @shiftMonitorForceCloseReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. staff member left without closing'**
  String get shiftMonitorForceCloseReasonHint;

  /// No description provided for @shiftMonitorForceCloseReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please give a reason for closing another user\'\'s shift.'**
  String get shiftMonitorForceCloseReasonRequired;

  /// No description provided for @shiftMonitorForceCloseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Counted amount — {mode}'**
  String shiftMonitorForceCloseCountLabel(String mode);

  /// No description provided for @shiftMonitorForceCloseCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a counted amount for {mode}.'**
  String shiftMonitorForceCloseCountRequired(String mode);

  /// No description provided for @shiftMonitorForceCloseExpected.
  ///
  /// In en, this message translates to:
  /// **'System expected: {amount}'**
  String shiftMonitorForceCloseExpected(String amount);

  /// No description provided for @shiftMonitorForceCloseCourierWarning.
  ///
  /// In en, this message translates to:
  /// **'This branch still has {transactions} unsettled courier transaction(s) across {invoices} order(s). They stay outstanding after closing and must still be settled.'**
  String shiftMonitorForceCloseCourierWarning(int transactions, int invoices);

  /// No description provided for @shiftMonitorForceCloseCourierAck.
  ///
  /// In en, this message translates to:
  /// **'I understand and want to close anyway'**
  String get shiftMonitorForceCloseCourierAck;

  /// No description provided for @shiftMonitorForceCloseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close Shift'**
  String get shiftMonitorForceCloseConfirm;

  /// No description provided for @shiftMonitorForceCloseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shift closed.'**
  String get shiftMonitorForceCloseSuccess;

  /// No description provided for @returnOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Order'**
  String get returnOrderTitle;

  /// No description provided for @returnOrderLinesLabel.
  ///
  /// In en, this message translates to:
  /// **'Items coming back'**
  String get returnOrderLinesLabel;

  /// No description provided for @returnOrderLineAvailable.
  ///
  /// In en, this message translates to:
  /// **'Up to {qty} can be returned'**
  String returnOrderLineAvailable(String qty);

  /// No description provided for @returnOrderLineAvailableAfterPrior.
  ///
  /// In en, this message translates to:
  /// **'Up to {qty} can be returned ({returned} already returned)'**
  String returnOrderLineAvailableAfterPrior(String qty, String returned);

  /// No description provided for @returnOrderLineFullyReturned.
  ///
  /// In en, this message translates to:
  /// **'Already returned'**
  String get returnOrderLineFullyReturned;

  /// No description provided for @returnOrderCreditAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer will be credited'**
  String get returnOrderCreditAmountLabel;

  /// No description provided for @returnOrderFullNotice.
  ///
  /// In en, this message translates to:
  /// **'The whole order is coming back. Stock returns to the branch and the order is credited in full.'**
  String get returnOrderFullNotice;

  /// No description provided for @returnOrderPartialNotice.
  ///
  /// In en, this message translates to:
  /// **'Part of the order is coming back. Only the selected items are credited and returned to stock.'**
  String get returnOrderPartialNotice;

  /// No description provided for @returnOrderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Return type'**
  String get returnOrderTypeLabel;

  /// No description provided for @returnTypeCustomerReturn.
  ///
  /// In en, this message translates to:
  /// **'Customer return'**
  String get returnTypeCustomerReturn;

  /// No description provided for @returnTypeFailedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Failed delivery'**
  String get returnTypeFailedDelivery;

  /// No description provided for @returnTypeDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get returnTypeDamaged;

  /// No description provided for @returnTypeWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong item'**
  String get returnTypeWrongItem;

  /// No description provided for @returnOrderReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get returnOrderReasonLabel;

  /// No description provided for @returnOrderReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe why the order is coming back'**
  String get returnOrderReasonRequired;

  /// No description provided for @returnOrderNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get returnOrderNotesOptional;

  /// No description provided for @returnOrderPayCourierTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay the courier for this trip'**
  String get returnOrderPayCourierTitle;

  /// No description provided for @returnOrderPayCourierYes.
  ///
  /// In en, this message translates to:
  /// **'The courier keeps their delivery fee.'**
  String get returnOrderPayCourierYes;

  /// No description provided for @returnOrderPayCourierNo.
  ///
  /// In en, this message translates to:
  /// **'The delivery fee will be reversed off the courier\'\'s balance.'**
  String get returnOrderPayCourierNo;

  /// No description provided for @returnOrderRefundLabel.
  ///
  /// In en, this message translates to:
  /// **'Money already collected'**
  String get returnOrderRefundLabel;

  /// No description provided for @returnOrderRefundCredit.
  ///
  /// In en, this message translates to:
  /// **'Keep as customer credit'**
  String get returnOrderRefundCredit;

  /// No description provided for @returnOrderRefundNow.
  ///
  /// In en, this message translates to:
  /// **'Refund cash now'**
  String get returnOrderRefundNow;

  /// No description provided for @returnOrderRefundUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No collected payment to refund.'**
  String get returnOrderRefundUnavailable;

  /// No description provided for @returnOrderConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm return'**
  String get returnOrderConfirmButton;

  /// No description provided for @returnOrderProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing return…'**
  String get returnOrderProcessing;

  /// No description provided for @returnOrderPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the return details.'**
  String get returnOrderPreviewFailed;

  /// No description provided for @returnOrderNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This order cannot be returned.'**
  String get returnOrderNotAvailable;

  /// No description provided for @returnOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'The return could not be completed.'**
  String get returnOrderFailed;

  /// No description provided for @returnOrderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return completed.'**
  String get returnOrderSuccess;

  /// No description provided for @returnOrderSuccessWithCn.
  ///
  /// In en, this message translates to:
  /// **'Return completed. Credit note {creditNote} created.'**
  String returnOrderSuccessWithCn(String creditNote);

  /// No description provided for @menuItemRequests.
  ///
  /// In en, this message translates to:
  /// **'Item Requests'**
  String get menuItemRequests;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Requests'**
  String get requestsTitle;

  /// No description provided for @requestsFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get requestsFilterOpen;

  /// No description provided for @requestsFilterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get requestsFilterMine;

  /// No description provided for @requestsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get requestsFilterAll;

  /// No description provided for @requestsEmptyOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing is being requested right now'**
  String get requestsEmptyOpen;

  /// No description provided for @requestsEmptyMine.
  ///
  /// In en, this message translates to:
  /// **'You have not requested anything yet'**
  String get requestsEmptyMine;

  /// No description provided for @requestsEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get requestsEmptyAll;

  /// No description provided for @requestsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to ask for something you are running out of.'**
  String get requestsEmptyHint;

  /// No description provided for @requestsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Request items'**
  String get requestsNewTitle;

  /// No description provided for @requestsAddItems.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get requestsAddItems;

  /// No description provided for @requestsNeededBy.
  ///
  /// In en, this message translates to:
  /// **'Needed by'**
  String get requestsNeededBy;

  /// No description provided for @requestsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get requestsNoteLabel;

  /// No description provided for @requestsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Brand, size, urgency'**
  String get requestsNoteHint;

  /// No description provided for @requestsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get requestsSubmit;

  /// No description provided for @requestsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request {name} sent'**
  String requestsSubmitted(Object name);

  /// No description provided for @requestsSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send request: {error}'**
  String requestsSubmitFailed(Object error);

  /// No description provided for @requestsNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get requestsNoItemsYet;

  /// No description provided for @requestsItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String requestsItemCount(int count);

  /// No description provided for @requestsRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String requestsRequestedBy(Object name);

  /// No description provided for @requestsOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get requestsOverdue;

  /// No description provided for @requestsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get requestsStatusPending;

  /// No description provided for @requestsStatusPartiallyReceived.
  ///
  /// In en, this message translates to:
  /// **'Partly bought'**
  String get requestsStatusPartiallyReceived;

  /// No description provided for @requestsStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get requestsStatusReceived;

  /// No description provided for @requestsStatusStopped.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestsStatusStopped;

  /// No description provided for @requestsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get requestsStatusCancelled;

  /// No description provided for @requestsStatusOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get requestsStatusOrdered;

  /// No description provided for @requestsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get requestsReject;

  /// No description provided for @requestsRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this request?'**
  String get requestsRejectTitle;

  /// No description provided for @requestsRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get requestsRejectReason;

  /// No description provided for @requestsRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestsRejected;

  /// No description provided for @requestsReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get requestsReopen;

  /// No description provided for @requestsReopened.
  ///
  /// In en, this message translates to:
  /// **'Request reopened'**
  String get requestsReopened;

  /// No description provided for @requestsLineProgress.
  ///
  /// In en, this message translates to:
  /// **'{received} of {requested} {uom}'**
  String requestsLineProgress(Object received, Object requested, Object uom);

  /// No description provided for @requestsBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get requestsBranchLabel;

  /// No description provided for @purchaseFromRequests.
  ///
  /// In en, this message translates to:
  /// **'From requests'**
  String get purchaseFromRequests;

  /// No description provided for @purchaseFromRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy requested items'**
  String get purchaseFromRequestsTitle;

  /// No description provided for @purchaseFromRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open requests to buy'**
  String get purchaseFromRequestsEmpty;

  /// No description provided for @purchaseFromRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'Quantities are pre-filled with what is still outstanding. Change anything before adding.'**
  String get purchaseFromRequestsHint;

  /// No description provided for @purchaseRequestedQty.
  ///
  /// In en, this message translates to:
  /// **'requested {qty}'**
  String purchaseRequestedQty(Object qty);

  /// No description provided for @purchaseBuyingLess.
  ///
  /// In en, this message translates to:
  /// **'requested {requested}, buying {buying}'**
  String purchaseBuyingLess(Object requested, Object buying);

  /// No description provided for @purchaseOnHand.
  ///
  /// In en, this message translates to:
  /// **'on hand {qty}'**
  String purchaseOnHand(Object qty);

  /// No description provided for @purchaseLastPaid.
  ///
  /// In en, this message translates to:
  /// **'last paid {rate}'**
  String purchaseLastPaid(Object rate);

  /// No description provided for @purchaseAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add {count} to cart'**
  String purchaseAddSelected(Object count);

  /// No description provided for @purchaseNeededBy.
  ///
  /// In en, this message translates to:
  /// **'needed {date}'**
  String purchaseNeededBy(Object date);

  /// No description provided for @purchaseRequestSources.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get purchaseRequestSources;

  /// No description provided for @purchaseUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get purchaseUrgent;

  /// No description provided for @purchasePaymentCredit.
  ///
  /// In en, this message translates to:
  /// **'On account (pay later)'**
  String get purchasePaymentCredit;

  /// No description provided for @purchasePaymentCreditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leaves an outstanding balance with the supplier'**
  String get purchasePaymentCreditSubtitle;

  /// No description provided for @purchaseBillNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier bill no.'**
  String get purchaseBillNoLabel;

  /// No description provided for @purchaseBillNoHint.
  ///
  /// In en, this message translates to:
  /// **'From the supplier\'\'s own invoice'**
  String get purchaseBillNoHint;

  /// No description provided for @purchaseBillDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill date'**
  String get purchaseBillDateLabel;

  /// No description provided for @purchaseTaxesLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get purchaseTaxesLabel;

  /// No description provided for @purchaseTaxesNone.
  ///
  /// In en, this message translates to:
  /// **'No tax'**
  String get purchaseTaxesNone;

  /// No description provided for @purchaseNoVat.
  ///
  /// In en, this message translates to:
  /// **'No VAT'**
  String get purchaseNoVat;

  /// No description provided for @purchaseVatValue.
  ///
  /// In en, this message translates to:
  /// **'VAT: {amount}'**
  String purchaseVatValue(Object amount);

  /// No description provided for @purchaseNetTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Net: {amount}'**
  String purchaseNetTotalValue(Object amount);

  /// No description provided for @purchaseNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get purchaseNewSupplier;

  /// No description provided for @purchaseNewSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get purchaseNewSupplierName;

  /// No description provided for @purchaseNewSupplierGroup.
  ///
  /// In en, this message translates to:
  /// **'Supplier group'**
  String get purchaseNewSupplierGroup;

  /// No description provided for @purchaseNewSupplierPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get purchaseNewSupplierPhone;

  /// No description provided for @purchaseSupplierCreated.
  ///
  /// In en, this message translates to:
  /// **'Supplier {name} created'**
  String purchaseSupplierCreated(Object name);

  /// No description provided for @purchaseSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Creating purchase'**
  String get purchaseSubmitting;

  /// No description provided for @purchaseOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get purchaseOutstandingLabel;

  /// No description provided for @purchasePayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get purchasePayNow;

  /// No description provided for @purchasePaid.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded ({entry})'**
  String purchasePaid(Object entry);

  /// No description provided for @purchaseReturnAction.
  ///
  /// In en, this message translates to:
  /// **'Return to supplier'**
  String get purchaseReturnAction;

  /// No description provided for @purchaseReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to supplier'**
  String get purchaseReturnTitle;

  /// No description provided for @purchaseReturnReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get purchaseReturnReason;

  /// No description provided for @purchaseReturnQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Return qty'**
  String get purchaseReturnQtyLabel;

  /// No description provided for @purchaseReturnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create return'**
  String get purchaseReturnSubmit;

  /// No description provided for @purchaseReturned.
  ///
  /// In en, this message translates to:
  /// **'Return {name} created'**
  String purchaseReturned(Object name);

  /// No description provided for @purchaseHistoryFilterSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get purchaseHistoryFilterSupplier;

  /// No description provided for @purchaseHistoryFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get purchaseHistoryFilterStatus;

  /// No description provided for @purchaseHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get purchaseHistoryFilterAll;

  /// No description provided for @purchaseHistoryFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get purchaseHistoryFilterClear;

  /// No description provided for @purchaseHistorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Invoice or bill no.'**
  String get purchaseHistorySearchHint;

  /// No description provided for @purchaseItemsInvoiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String purchaseItemsInvoiceCount(int count);

  /// Compact courier run progress on a Kanban card, e.g. 7/12 delivered.
  ///
  /// In en, this message translates to:
  /// **'{delivered}/{total} delivered'**
  String kanbanRunProgressLabel(int delivered, int total);

  /// Tooltip explaining the courier run progress badge and that it is scoped to the visible board.
  ///
  /// In en, this message translates to:
  /// **'{courier}: {delivered} of {total} stops delivered on this board'**
  String kanbanRunProgressTooltip(String courier, int delivered, int total);

  /// No description provided for @kanbanRunProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'Run complete'**
  String get kanbanRunProgressComplete;

  /// This order's position in the courier's sequenced run.
  ///
  /// In en, this message translates to:
  /// **'Stop {sequence}'**
  String kanbanRunStopLabel(int sequence);

  /// How many stops on the run were attempted and missed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 missed} other{{count} missed}}'**
  String kanbanRunFailedLabel(int count);

  /// No description provided for @kanbanRunFailedTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop on this run was attempted and not delivered} other{{count} stops on this run were attempted and not delivered}}'**
  String kanbanRunFailedTooltip(int count);

  /// No description provided for @kanbanRunAttemptFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery missed'**
  String get kanbanRunAttemptFailedLabel;

  /// No description provided for @kanbanRunAttemptFailedTooltip.
  ///
  /// In en, this message translates to:
  /// **'This stop was attempted {attempts, plural, =1{once} other{{attempts} times}} and has not been delivered'**
  String kanbanRunAttemptFailedTooltip(int attempts);

  /// No description provided for @menuLiveCourierMap.
  ///
  /// In en, this message translates to:
  /// **'Live courier map'**
  String get menuLiveCourierMap;

  /// No description provided for @fleetTitle.
  ///
  /// In en, this message translates to:
  /// **'Live courier map'**
  String get fleetTitle;

  /// No description provided for @fleetRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh now'**
  String get fleetRefreshTooltip;

  /// Header line showing how long ago the last successful poll landed.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}'**
  String fleetUpdatedAgo(String ago);

  /// No description provided for @fleetUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get fleetUpdating;

  /// No description provided for @fleetCouriersOnMap.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 courier on the map} other{{count} couriers on the map}}'**
  String fleetCouriersOnMap(int count);

  /// No description provided for @fleetRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed — these positions are only getting older'**
  String get fleetRefreshFailed;

  /// No description provided for @fleetLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'How old is each dot'**
  String get fleetLegendTitle;

  /// No description provided for @fleetLegendFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh · under {minutes} min'**
  String fleetLegendFresh(int minutes);

  /// No description provided for @fleetLegendAgeing.
  ///
  /// In en, this message translates to:
  /// **'Ageing · {from}–{to} min'**
  String fleetLegendAgeing(int from, int to);

  /// No description provided for @fleetLegendStale.
  ///
  /// In en, this message translates to:
  /// **'Stale · over {minutes} min, do not act on it'**
  String fleetLegendStale(int minutes);

  /// No description provided for @fleetFreshnessFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get fleetFreshnessFresh;

  /// No description provided for @fleetFreshnessAgeing.
  ///
  /// In en, this message translates to:
  /// **'Ageing'**
  String get fleetFreshnessAgeing;

  /// No description provided for @fleetFreshnessStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get fleetFreshnessStale;

  /// No description provided for @fleetStaleWarning.
  ///
  /// In en, this message translates to:
  /// **'Some couriers have not reported recently — check before dispatching'**
  String get fleetStaleWarning;

  /// No description provided for @fleetAgeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get fleetAgeJustNow;

  /// No description provided for @fleetAgeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min ago} other{{minutes} min ago}}'**
  String fleetAgeMinutes(int minutes);

  /// No description provided for @fleetAgeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hr ago} other{{hours} hr ago}}'**
  String fleetAgeHours(int hours);

  /// No description provided for @fleetAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String fleetAgeDays(int days);

  /// No description provided for @fleetAgeUnknown.
  ///
  /// In en, this message translates to:
  /// **'no timestamp'**
  String get fleetAgeUnknown;

  /// No description provided for @fleetAgeShortNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get fleetAgeShortNow;

  /// No description provided for @fleetAgeShortMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String fleetAgeShortMinutes(int minutes);

  /// No description provided for @fleetAgeShortHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String fleetAgeShortHours(int hours);

  /// No description provided for @fleetAgeShortDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String fleetAgeShortDays(int days);

  /// No description provided for @fleetBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get fleetBranchLabel;

  /// No description provided for @fleetBranchUnknown.
  ///
  /// In en, this message translates to:
  /// **'No branch'**
  String get fleetBranchUnknown;

  /// No description provided for @fleetLastFixLabel.
  ///
  /// In en, this message translates to:
  /// **'Last fix'**
  String get fleetLastFixLabel;

  /// No description provided for @fleetAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get fleetAccuracyLabel;

  /// No description provided for @fleetAccuracyValue.
  ///
  /// In en, this message translates to:
  /// **'±{meters} m'**
  String fleetAccuracyValue(String meters);

  /// No description provided for @fleetAccuracyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not reported'**
  String get fleetAccuracyUnknown;

  /// No description provided for @fleetEmptyNoCouriersTitle.
  ///
  /// In en, this message translates to:
  /// **'No couriers on shift'**
  String get fleetEmptyNoCouriersTitle;

  /// No description provided for @fleetEmptyNoCouriersBody.
  ///
  /// In en, this message translates to:
  /// **'Nobody is signed on to the courier app right now, so there is nothing to track. Positions appear here as soon as a courier starts their shift.'**
  String get fleetEmptyNoCouriersBody;

  /// No description provided for @fleetEmptyNoPositionsTitle.
  ///
  /// In en, this message translates to:
  /// **'On shift, but no position yet'**
  String get fleetEmptyNoPositionsTitle;

  /// No description provided for @fleetEmptyNoPositionsBody.
  ///
  /// In en, this message translates to:
  /// **'These couriers are signed on, but their phones have not sent a location. Check that the courier app has location permission and a signal.'**
  String get fleetEmptyNoPositionsBody;

  /// No description provided for @fleetEmptyNoPositionsNames.
  ///
  /// In en, this message translates to:
  /// **'Waiting on: {names}'**
  String fleetEmptyNoPositionsNames(String names);

  /// No description provided for @fleetUnlocatedBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 courier on shift has sent no position} other{{count} couriers on shift have sent no position}}'**
  String fleetUnlocatedBanner(int count);

  /// No description provided for @fleetForbiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervisors only'**
  String get fleetForbiddenTitle;

  /// No description provided for @fleetForbiddenBody.
  ///
  /// In en, this message translates to:
  /// **'Live courier positions are limited to managers and supervisors. Retrying will not help — ask a manager to open this screen.'**
  String get fleetForbiddenBody;

  /// No description provided for @fleetErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load courier positions'**
  String get fleetErrorTitle;

  /// No description provided for @labelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Labels'**
  String get labelsTitle;

  /// No description provided for @labelsHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'How this works'**
  String get labelsHelpTooltip;

  /// No description provided for @labelsRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get labelsRefreshTooltip;

  /// No description provided for @labelsSetUpCustomer.
  ///
  /// In en, this message translates to:
  /// **'Set up customer'**
  String get labelsSetUpCustomer;

  /// No description provided for @labelsSetupNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to track'**
  String get labelsSetupNothingNew;

  /// No description provided for @labelsSetupTrackingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Now tracking 1 flavour} other{Now tracking {count} flavours}}'**
  String labelsSetupTrackingCount(int count);

  /// No description provided for @labelsSetupSkippedSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ (1 already tracked)} other{ ({count} already tracked)}}'**
  String labelsSetupSkippedSuffix(int count);

  /// No description provided for @labelsPrintOrderSent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sheet sent to the printer} other{{count} sheets sent to the printer}}'**
  String labelsPrintOrderSent(int count);

  /// No description provided for @labelsPrintOrderDueBack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sheet ordered — due back {date}} other{{count} sheets ordered — due back {date}}}'**
  String labelsPrintOrderDueBack(int count, String date);

  /// No description provided for @labelsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How label tracking works'**
  String get labelsHelpTitle;

  /// No description provided for @labelsHelpRows.
  ///
  /// In en, this message translates to:
  /// **'Every flavour has its own label design, so each is tracked on its own row. Labels come off stock automatically when an invoice is submitted for a customer whose labels we print. Customers who bring their own are marked \"Customer prints\" and are never counted.'**
  String get labelsHelpRows;

  /// No description provided for @labelsHelpSheets.
  ///
  /// In en, this message translates to:
  /// **'Printing is ordered in sheets — {medium} Medium or {large} Large labels per sheet.'**
  String labelsHelpSheets(Object medium, Object large);

  /// No description provided for @labelsHelpLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Printing takes {min}–{max} working days with {restDay} excluded, so a label is flagged \"Print now\" once its remaining stock would not survive that wait — and \"Print soon\" {buffer} days before that point.'**
  String labelsHelpLeadTime(
    Object min,
    Object max,
    String restDay,
    Object buffer,
  );

  /// No description provided for @labelsHelpQuiet.
  ///
  /// In en, this message translates to:
  /// **'Once a batch is at the printer the label goes quiet and shows its due-back date instead, so the same shortage is not raised every morning.'**
  String get labelsHelpQuiet;

  /// No description provided for @labelsHelpAlertsOff.
  ///
  /// In en, this message translates to:
  /// **'Daily alerts are currently switched off in Jarz POS Settings.'**
  String get labelsHelpAlertsOff;

  /// No description provided for @labelsHelpGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get labelsHelpGotIt;

  /// No description provided for @labelsSummaryUrgent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label must go to the printer now} other{{count} labels must go to the printer now}}'**
  String labelsSummaryUrgent(int count);

  /// No description provided for @labelsSummarySoon.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label to print soon} other{{count} labels to print soon}}'**
  String labelsSummarySoon(int count);

  /// No description provided for @labelsSummaryNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs printing'**
  String get labelsSummaryNothing;

  /// No description provided for @labelsSummaryLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Printing takes {min}–{max} working days · {restDay} excluded'**
  String labelsSummaryLeadTime(Object min, Object max, String restDay);

  /// No description provided for @labelsSummaryReadySuffix.
  ///
  /// In en, this message translates to:
  /// **' · order today, ready {date}'**
  String labelsSummaryReadySuffix(String date);

  /// No description provided for @labelsFilterNeedsPrinting.
  ///
  /// In en, this message translates to:
  /// **'Needs printing'**
  String get labelsFilterNeedsPrinting;

  /// No description provided for @labelsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labelsFilterAll;

  /// No description provided for @labelsFilterAtPrinter.
  ///
  /// In en, this message translates to:
  /// **'At printer'**
  String get labelsFilterAtPrinter;

  /// No description provided for @labelsFilterCustomerPrints.
  ///
  /// In en, this message translates to:
  /// **'Customer prints'**
  String get labelsFilterCustomerPrints;

  /// No description provided for @labelsFilterWithCount.
  ///
  /// In en, this message translates to:
  /// **'{text} ({count})'**
  String labelsFilterWithCount(String text, int count);

  /// No description provided for @labelsAllLocations.
  ///
  /// In en, this message translates to:
  /// **'All locations'**
  String get labelsAllLocations;

  /// No description provided for @labelsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search customer or flavour'**
  String get labelsSearchHint;

  /// No description provided for @labelsEmptyNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No labels tracked yet'**
  String get labelsEmptyNoneTitle;

  /// No description provided for @labelsEmptyNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Set up the B2B customers whose jar labels JARZ prints — one label per flavour. Stock then comes down on its own as their orders are invoiced.'**
  String get labelsEmptyNoneBody;

  /// No description provided for @labelsEmptyEnoughCover.
  ///
  /// In en, this message translates to:
  /// **'Every label has enough cover'**
  String get labelsEmptyEnoughCover;

  /// No description provided for @labelsEmptyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this filter'**
  String get labelsEmptyNoMatch;

  /// No description provided for @labelsShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all labels'**
  String get labelsShowAll;

  /// No description provided for @labelStatusOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get labelStatusOutOfStock;

  /// No description provided for @labelStatusOutOfStockWhy.
  ///
  /// In en, this message translates to:
  /// **'No labels left. This customer cannot be packed.'**
  String get labelStatusOutOfStockWhy;

  /// No description provided for @labelStatusPrintNow.
  ///
  /// In en, this message translates to:
  /// **'Print now'**
  String get labelStatusPrintNow;

  /// No description provided for @labelStatusPrintNowWhy.
  ///
  /// In en, this message translates to:
  /// **'Stock runs out before a new batch could arrive ({days} working days).'**
  String labelStatusPrintNowWhy(int days);

  /// No description provided for @labelStatusPrintSoon.
  ///
  /// In en, this message translates to:
  /// **'Print soon'**
  String get labelStatusPrintSoon;

  /// No description provided for @labelStatusPrintSoonWhy.
  ///
  /// In en, this message translates to:
  /// **'Getting close to the point of no return.'**
  String get labelStatusPrintSoonWhy;

  /// No description provided for @labelStatusAtPrinter.
  ///
  /// In en, this message translates to:
  /// **'At the printer'**
  String get labelStatusAtPrinter;

  /// No description provided for @labelStatusAtPrinterWhy.
  ///
  /// In en, this message translates to:
  /// **'A batch is already on its way.'**
  String get labelStatusAtPrinterWhy;

  /// No description provided for @labelStatusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get labelStatusOk;

  /// No description provided for @labelStatusOkWhy.
  ///
  /// In en, this message translates to:
  /// **'Comfortable cover.'**
  String get labelStatusOkWhy;

  /// No description provided for @labelStatusCustomerPrints.
  ///
  /// In en, this message translates to:
  /// **'Customer prints'**
  String get labelStatusCustomerPrints;

  /// No description provided for @labelStatusCustomerPrintsWhy.
  ///
  /// In en, this message translates to:
  /// **'This customer supplies their own labels, so nothing is counted.'**
  String get labelStatusCustomerPrintsWhy;

  /// No description provided for @labelStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelStatusUnknown;

  /// No description provided for @labelCardFlavours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 flavour} other{{count} flavours}}'**
  String labelCardFlavours(int count);

  /// No description provided for @labelCardNeedPrintingSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ · 1 needs printing} other{ · {count} need printing}}'**
  String labelCardNeedPrintingSuffix(int count);

  /// No description provided for @labelCardCustomerActions.
  ///
  /// In en, this message translates to:
  /// **'Customer actions'**
  String get labelCardCustomerActions;

  /// No description provided for @labelCardAddFlavour.
  ///
  /// In en, this message translates to:
  /// **'Add flavour'**
  String get labelCardAddFlavour;

  /// No description provided for @labelCardOnHand.
  ///
  /// In en, this message translates to:
  /// **'on hand'**
  String get labelCardOnHand;

  /// No description provided for @labelCardOfCover.
  ///
  /// In en, this message translates to:
  /// **'of cover'**
  String get labelCardOfCover;

  /// No description provided for @labelCardOrderSheets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Order 1 sheet} other{Order {count} sheets}}'**
  String labelCardOrderSheets(int count);

  /// No description provided for @labelCardOrderBatch.
  ///
  /// In en, this message translates to:
  /// **'Order a batch'**
  String get labelCardOrderBatch;

  /// No description provided for @labelCardCoverOver99.
  ///
  /// In en, this message translates to:
  /// **'99+ d'**
  String get labelCardCoverOver99;

  /// No description provided for @labelCardCoverDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String labelCardCoverDays(String days);

  /// No description provided for @labelCardCoverNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get labelCardCoverNone;

  /// No description provided for @labelCardCustomerSupplies.
  ///
  /// In en, this message translates to:
  /// **'Customer supplies their own labels'**
  String get labelCardCustomerSupplies;

  /// No description provided for @labelCardSheetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sheet} other{{count} sheets}}'**
  String labelCardSheetsCount(int count);

  /// No description provided for @labelCardLabelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label} other{{count} labels}}'**
  String labelCardLabelsCount(int count);

  /// No description provided for @labelCardAtPrinter.
  ///
  /// In en, this message translates to:
  /// **'{what} at the printer'**
  String labelCardAtPrinter(String what);

  /// No description provided for @labelCardOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'{what} overdue at the printer since {date}'**
  String labelCardOverdueSince(String what, String date);

  /// No description provided for @labelCardDueBack.
  ///
  /// In en, this message translates to:
  /// **'{what} due back {date}'**
  String labelCardDueBack(String what, String date);

  /// No description provided for @labelCardRunsOutAround.
  ///
  /// In en, this message translates to:
  /// **'Runs out around {date}'**
  String labelCardRunsOutAround(String date);

  /// No description provided for @labelCardNoUsage.
  ///
  /// In en, this message translates to:
  /// **'No usage recorded yet'**
  String get labelCardNoUsage;

  /// No description provided for @labelCardOrderAhead.
  ///
  /// In en, this message translates to:
  /// **'Order {days} working days ahead'**
  String labelCardOrderAhead(int days);

  /// No description provided for @labelPrintStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get labelPrintStatusRequested;

  /// No description provided for @labelPrintStatusPrinting.
  ///
  /// In en, this message translates to:
  /// **'Printing'**
  String get labelPrintStatusPrinting;

  /// No description provided for @labelPrintStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get labelPrintStatusReady;

  /// No description provided for @labelPrintStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get labelPrintStatusReceived;

  /// No description provided for @labelPrintStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get labelPrintStatusCancelled;

  /// No description provided for @labelMovementConsumed.
  ///
  /// In en, this message translates to:
  /// **'Used on jars'**
  String get labelMovementConsumed;

  /// No description provided for @labelMovementPrintReceived.
  ///
  /// In en, this message translates to:
  /// **'Received from the printer'**
  String get labelMovementPrintReceived;

  /// No description provided for @labelMovementScrapped.
  ///
  /// In en, this message translates to:
  /// **'Damaged or thrown away'**
  String get labelMovementScrapped;

  /// No description provided for @labelMovementAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Correction (+/-)'**
  String get labelMovementAdjustment;

  /// No description provided for @labelDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelDetailFallbackTitle;

  /// No description provided for @labelDetailSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Label settings'**
  String get labelDetailSettingsTooltip;

  /// No description provided for @labelDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this label.\n{error}'**
  String labelDetailLoadFailed(String error);

  /// No description provided for @labelDetailSentToPrinter.
  ///
  /// In en, this message translates to:
  /// **'{what} sent to the printer'**
  String labelDetailSentToPrinter(String what);

  /// No description provided for @labelDetailCountSaved.
  ///
  /// In en, this message translates to:
  /// **'Count saved'**
  String get labelDetailCountSaved;

  /// No description provided for @labelDetailMovementRecorded.
  ///
  /// In en, this message translates to:
  /// **'Movement recorded'**
  String get labelDetailMovementRecorded;

  /// No description provided for @labelDetailReceivedAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label added to stock} other{{count} labels added to stock}}'**
  String labelDetailReceivedAdded(int count);

  /// No description provided for @labelDetailBatchMarked.
  ///
  /// In en, this message translates to:
  /// **'Batch marked {status}'**
  String labelDetailBatchMarked(String status);

  /// No description provided for @labelDetailBillRecorded.
  ///
  /// In en, this message translates to:
  /// **'Bill recorded — purchase invoice created'**
  String get labelDetailBillRecorded;

  /// No description provided for @labelDetailSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get labelDetailSettingsSaved;

  /// No description provided for @labelDetailStoredAt.
  ///
  /// In en, this message translates to:
  /// **'Stored at {location}'**
  String labelDetailStoredAt(String location);

  /// No description provided for @labelDetailLabelsOnHand.
  ///
  /// In en, this message translates to:
  /// **'labels on hand'**
  String get labelDetailLabelsOnHand;

  /// No description provided for @labelDetailDaysOfCover.
  ///
  /// In en, this message translates to:
  /// **'Days of cover'**
  String get labelDetailDaysOfCover;

  /// No description provided for @labelDetailUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get labelDetailUnknownValue;

  /// No description provided for @labelDetailUsedPerDay.
  ///
  /// In en, this message translates to:
  /// **'Used per day'**
  String get labelDetailUsedPerDay;

  /// No description provided for @labelDetailRunsOut.
  ///
  /// In en, this message translates to:
  /// **'Runs out'**
  String get labelDetailRunsOut;

  /// No description provided for @labelDetailUsedInDays.
  ///
  /// In en, this message translates to:
  /// **'Used in {days}d'**
  String labelDetailUsedInDays(int days);

  /// No description provided for @labelDetailStockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get labelDetailStockValue;

  /// No description provided for @labelDetailAvgCost.
  ///
  /// In en, this message translates to:
  /// **'Avg cost/label'**
  String get labelDetailAvgCost;

  /// No description provided for @labelDetailRetired.
  ///
  /// In en, this message translates to:
  /// **'This label is retired. Turn it back on in label settings to resume counting.'**
  String get labelDetailRetired;

  /// No description provided for @labelDetailCustomerSupplies.
  ///
  /// In en, this message translates to:
  /// **'This customer supplies their own labels, so nothing is counted and no alerts are raised. Turn on \"We print this label\" in settings if that changes.'**
  String get labelDetailCustomerSupplies;

  /// No description provided for @labelDetailActionOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get labelDetailActionOrder;

  /// No description provided for @labelDetailActionCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get labelDetailActionCount;

  /// No description provided for @labelDetailActionRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get labelDetailActionRecord;

  /// No description provided for @labelDetailSectionBatches.
  ///
  /// In en, this message translates to:
  /// **'Print batches'**
  String get labelDetailSectionBatches;

  /// No description provided for @labelDetailOrderedOn.
  ///
  /// In en, this message translates to:
  /// **'ordered {date}'**
  String labelDetailOrderedOn(String date);

  /// No description provided for @labelDetailOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'overdue since {date}'**
  String labelDetailOverdueSince(String date);

  /// No description provided for @labelDetailDueOn.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String labelDetailDueOn(String date);

  /// No description provided for @labelDetailReceivedOn.
  ///
  /// In en, this message translates to:
  /// **'received {date}'**
  String labelDetailReceivedOn(String date);

  /// No description provided for @labelDetailReceivedOnQty.
  ///
  /// In en, this message translates to:
  /// **'received {date} ({qty})'**
  String labelDetailReceivedOnQty(String date, int qty);

  /// No description provided for @labelDetailReceiveIntoStock.
  ///
  /// In en, this message translates to:
  /// **'Receive into stock'**
  String get labelDetailReceiveIntoStock;

  /// No description provided for @labelDetailMarkPrinting.
  ///
  /// In en, this message translates to:
  /// **'Mark printing'**
  String get labelDetailMarkPrinting;

  /// No description provided for @labelDetailMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get labelDetailMarkReady;

  /// No description provided for @labelDetailRecordBill.
  ///
  /// In en, this message translates to:
  /// **'Record the printer\'\'s bill'**
  String get labelDetailRecordBill;

  /// No description provided for @labelDetailCancelBatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel batch'**
  String get labelDetailCancelBatch;

  /// No description provided for @labelDetailBilled.
  ///
  /// In en, this message translates to:
  /// **'Billed'**
  String get labelDetailBilled;

  /// No description provided for @labelDetailBilledWithInvoice.
  ///
  /// In en, this message translates to:
  /// **'Billed · {invoice}'**
  String labelDetailBilledWithInvoice(String invoice);

  /// No description provided for @labelDetailUnbilled.
  ///
  /// In en, this message translates to:
  /// **'Unbilled'**
  String get labelDetailUnbilled;

  /// No description provided for @labelDetailUnbilledQuoted.
  ///
  /// In en, this message translates to:
  /// **'Unbilled · quoted {amount}'**
  String labelDetailUnbilledQuoted(String amount);

  /// No description provided for @labelDetailPolicyFlavour.
  ///
  /// In en, this message translates to:
  /// **'Flavour'**
  String get labelDetailPolicyFlavour;

  /// No description provided for @labelDetailPolicySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get labelDetailPolicySize;

  /// No description provided for @labelDetailPolicyStoredAt.
  ///
  /// In en, this message translates to:
  /// **'Stored at'**
  String get labelDetailPolicyStoredAt;

  /// No description provided for @labelDetailPolicyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get labelDetailPolicyNotSet;

  /// No description provided for @labelDetailPolicyMinStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get labelDetailPolicyMinStock;

  /// No description provided for @labelDetailPolicyUsualBatch.
  ///
  /// In en, this message translates to:
  /// **'Usual print batch'**
  String get labelDetailPolicyUsualBatch;

  /// No description provided for @labelDetailPolicyLabelsPerSheet.
  ///
  /// In en, this message translates to:
  /// **'Labels per sheet'**
  String get labelDetailPolicyLabelsPerSheet;

  /// No description provided for @labelDetailPolicyLabelsPerJar.
  ///
  /// In en, this message translates to:
  /// **'Labels per jar'**
  String get labelDetailPolicyLabelsPerJar;

  /// No description provided for @labelDetailPolicyLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Print lead time'**
  String get labelDetailPolicyLeadTime;

  /// No description provided for @labelDetailPolicyLeadTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} working days ({restDay} excluded)'**
  String labelDetailPolicyLeadTimeValue(Object min, Object max, String restDay);

  /// No description provided for @labelDetailPolicyLastCounted.
  ///
  /// In en, this message translates to:
  /// **'Last counted'**
  String get labelDetailPolicyLastCounted;

  /// No description provided for @labelDetailPolicyLastMovement.
  ///
  /// In en, this message translates to:
  /// **'Last movement'**
  String get labelDetailPolicyLastMovement;

  /// No description provided for @labelDetailSectionSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get labelDetailSectionSetup;

  /// No description provided for @labelDetailSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get labelDetailSectionHistory;

  /// No description provided for @labelDetailHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet. Labels come off automatically as this customer\'\'s orders are invoiced.'**
  String get labelDetailHistoryEmpty;

  /// No description provided for @labelDetailAutoPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted automatically from the invoice'**
  String get labelDetailAutoPosted;

  /// No description provided for @labelSheetSupplierOptional.
  ///
  /// In en, this message translates to:
  /// **'Print supplier (optional)'**
  String get labelSheetSupplierOptional;

  /// No description provided for @labelSheetPrintSupplier.
  ///
  /// In en, this message translates to:
  /// **'Print supplier'**
  String get labelSheetPrintSupplier;

  /// No description provided for @labelSheetCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Count labels'**
  String get labelSheetCountTitle;

  /// No description provided for @labelSheetCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter what is physically on the shelf. The difference is posted to the ledger, so a label that keeps going missing shows up as a run of corrections rather than vanishing quietly.'**
  String get labelSheetCountSubtitle;

  /// No description provided for @labelSheetCountedQty.
  ///
  /// In en, this message translates to:
  /// **'Counted quantity'**
  String get labelSheetCountedQty;

  /// No description provided for @labelSheetSystemShows.
  ///
  /// In en, this message translates to:
  /// **'System currently shows {qty}.'**
  String labelSheetSystemShows(int qty);

  /// No description provided for @labelSheetDeltaMore.
  ///
  /// In en, this message translates to:
  /// **'{count} more than recorded'**
  String labelSheetDeltaMore(int count);

  /// No description provided for @labelSheetDeltaFewer.
  ///
  /// In en, this message translates to:
  /// **'{count} fewer than recorded'**
  String labelSheetDeltaFewer(int count);

  /// No description provided for @labelSheetNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get labelSheetNoteOptional;

  /// No description provided for @labelSheetNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get labelSheetNotesOptional;

  /// No description provided for @labelSheetSaveCount.
  ///
  /// In en, this message translates to:
  /// **'Save count'**
  String get labelSheetSaveCount;

  /// No description provided for @labelSheetOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order a print batch'**
  String get labelSheetOrderTitle;

  /// No description provided for @labelSheetLeadPlain.
  ///
  /// In en, this message translates to:
  /// **'Printing takes {min}–{max} working days ({restDay} excluded).'**
  String labelSheetLeadPlain(Object min, Object max, String restDay);

  /// No description provided for @labelSheetLeadReady.
  ///
  /// In en, this message translates to:
  /// **'Ordered today, ready around {date} — {min}–{max} working days, {restDay} excluded.'**
  String labelSheetLeadReady(
    String date,
    Object min,
    Object max,
    String restDay,
  );

  /// No description provided for @labelSheetSheetsToPrint.
  ///
  /// In en, this message translates to:
  /// **'Sheets to print'**
  String get labelSheetSheetsToPrint;

  /// No description provided for @labelSheetSuggestedSheets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Suggested 1 sheet, based on current usage and the usual batch.} other{Suggested {count} sheets, based on current usage and the usual batch.}}'**
  String labelSheetSuggestedSheets(int count);

  /// No description provided for @labelSheetSheetsEquals.
  ///
  /// In en, this message translates to:
  /// **'{sheets} = {labels}'**
  String labelSheetSheetsEquals(String sheets, String labels);

  /// No description provided for @labelSheetNetCostOptional.
  ///
  /// In en, this message translates to:
  /// **'Net cost (optional)'**
  String get labelSheetNetCostOptional;

  /// No description provided for @labelSheetNetCostQuoteHelper.
  ///
  /// In en, this message translates to:
  /// **'What the printer quoted for the batch, before VAT. The bill itself is recorded when it arrives.'**
  String get labelSheetNetCostQuoteHelper;

  /// No description provided for @labelSheetSendToPrinter.
  ///
  /// In en, this message translates to:
  /// **'Send to printer'**
  String get labelSheetSendToPrinter;

  /// No description provided for @labelSheetReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive batch'**
  String get labelSheetReceiveTitle;

  /// No description provided for @labelSheetReceiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · ordered {ordered}'**
  String labelSheetReceiveSubtitle(String name, String ordered);

  /// No description provided for @labelSheetLabelsReceived.
  ///
  /// In en, this message translates to:
  /// **'Labels received'**
  String get labelSheetLabelsReceived;

  /// No description provided for @labelSheetReceivedHelper.
  ///
  /// In en, this message translates to:
  /// **'Adjust if the printer delivered short. Only this many are added to stock.'**
  String get labelSheetReceivedHelper;

  /// No description provided for @labelSheetAddToStock.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get labelSheetAddToStock;

  /// No description provided for @labelSheetBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Record the printer\'\'s bill'**
  String get labelSheetBillTitle;

  /// No description provided for @labelSheetBillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {ordered}. This books a supplier purchase invoice, so the batch lands on the books at its real cost.'**
  String labelSheetBillSubtitle(String name, String ordered);

  /// No description provided for @labelSheetNetCost.
  ///
  /// In en, this message translates to:
  /// **'Net cost'**
  String get labelSheetNetCost;

  /// No description provided for @labelSheetNetCostBillHelper.
  ///
  /// In en, this message translates to:
  /// **'What the printer charged for this batch, before VAT.'**
  String get labelSheetNetCostBillHelper;

  /// No description provided for @labelSheetBillNoOptional.
  ///
  /// In en, this message translates to:
  /// **'Supplier\'\'s bill no. (optional)'**
  String get labelSheetBillNoOptional;

  /// No description provided for @labelSheetRecordBill.
  ///
  /// In en, this message translates to:
  /// **'Record bill'**
  String get labelSheetRecordBill;

  /// No description provided for @labelSheetMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a movement'**
  String get labelSheetMovementTitle;

  /// No description provided for @labelSheetWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get labelSheetWhatHappened;

  /// No description provided for @labelSheetQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get labelSheetQuantity;

  /// No description provided for @labelSheetAdjustmentHelper.
  ///
  /// In en, this message translates to:
  /// **'Use a minus sign to reduce stock.'**
  String get labelSheetAdjustmentHelper;

  /// No description provided for @labelSheetQtyHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter a plain number — the direction follows from the type.'**
  String get labelSheetQtyHelper;

  /// No description provided for @labelSheetLabelName.
  ///
  /// In en, this message translates to:
  /// **'Label name'**
  String get labelSheetLabelName;

  /// No description provided for @labelSheetWePrint.
  ///
  /// In en, this message translates to:
  /// **'We print this label'**
  String get labelSheetWePrint;

  /// No description provided for @labelSheetWePrintHelp.
  ///
  /// In en, this message translates to:
  /// **'Off means the customer supplies their own — stops all counting and alerting without losing the history.'**
  String get labelSheetWePrintHelp;

  /// No description provided for @labelSheetActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labelSheetActive;

  /// No description provided for @labelSheetActiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn off to retire a design that is no longer used.'**
  String get labelSheetActiveHelp;

  /// No description provided for @labelSheetStoredAtHelper.
  ///
  /// In en, this message translates to:
  /// **'The branch or factory where this label physically lives.'**
  String get labelSheetStoredAtHelper;

  /// No description provided for @labelSheetUsualBatchSheets.
  ///
  /// In en, this message translates to:
  /// **'Usual batch (sheets)'**
  String get labelSheetUsualBatchSheets;

  /// No description provided for @labelSheetLabelsPerSheetHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave 0 for the size default: 21 Medium, 18 Large.'**
  String get labelSheetLabelsPerSheetHelper;

  /// No description provided for @labelSheetLabelsPerJarHelper.
  ///
  /// In en, this message translates to:
  /// **'Usually 1.'**
  String get labelSheetLabelsPerJarHelper;

  /// No description provided for @labelWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up customer labels'**
  String get labelWizardTitle;

  /// No description provided for @labelWizardStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get labelWizardStartTracking;

  /// No description provided for @labelWizardContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get labelWizardContinue;

  /// No description provided for @labelWizardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get labelWizardBack;

  /// No description provided for @labelWizardStepCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get labelWizardStepCustomer;

  /// No description provided for @labelWizardStepFlavours.
  ///
  /// In en, this message translates to:
  /// **'Flavours'**
  String get labelWizardStepFlavours;

  /// No description provided for @labelWizardPickedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} picked'**
  String labelWizardPickedCount(int count);

  /// No description provided for @labelWizardStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Where the labels live'**
  String get labelWizardStepLocation;

  /// No description provided for @labelWizardStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get labelWizardStepConfirm;

  /// No description provided for @labelWizardChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get labelWizardChange;

  /// No description provided for @labelWizardCustomerPriceList.
  ///
  /// In en, this message translates to:
  /// **'{customer} · price list: {priceList}'**
  String labelWizardCustomerPriceList(String customer, String priceList);

  /// No description provided for @labelWizardSearchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get labelWizardSearchCustomers;

  /// No description provided for @labelWizardSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get labelWizardSearching;

  /// No description provided for @labelWizardNoCustomers.
  ///
  /// In en, this message translates to:
  /// **'No company customers matched.'**
  String get labelWizardNoCustomers;

  /// No description provided for @labelWizardPriceList.
  ///
  /// In en, this message translates to:
  /// **'Price list: {priceList}'**
  String labelWizardPriceList(String priceList);

  /// No description provided for @labelWizardFlavoursLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load flavours.\n{error}'**
  String labelWizardFlavoursLoadFailed(String error);

  /// No description provided for @labelWizardPickCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a customer first.'**
  String get labelWizardPickCustomerFirst;

  /// No description provided for @labelWizardNoFlavours.
  ///
  /// In en, this message translates to:
  /// **'No flavours found for this customer — nothing on their price list and no order history yet.'**
  String get labelWizardNoFlavours;

  /// No description provided for @labelWizardSizeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelWizardSizeOther;

  /// No description provided for @labelWizardFlavourHelp.
  ///
  /// In en, this message translates to:
  /// **'Tick every flavour whose label JARZ prints. Enter what is already on the shelf so nothing starts life as Out of Stock.'**
  String get labelWizardFlavourHelp;

  /// No description provided for @labelWizardAlreadyTracked.
  ///
  /// In en, this message translates to:
  /// **'Already tracked'**
  String get labelWizardAlreadyTracked;

  /// No description provided for @labelWizardOnPriceList.
  ///
  /// In en, this message translates to:
  /// **'On price list'**
  String get labelWizardOnPriceList;

  /// No description provided for @labelWizardOrderedBefore.
  ///
  /// In en, this message translates to:
  /// **'Ordered before'**
  String get labelWizardOrderedBefore;

  /// No description provided for @labelWizardLabelsInStock.
  ///
  /// In en, this message translates to:
  /// **'Labels in stock now'**
  String get labelWizardLabelsInStock;

  /// No description provided for @labelWizardLocationsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load locations — you can set one per label later.'**
  String get labelWizardLocationsLoadFailed;

  /// No description provided for @labelWizardStoredAtHelper.
  ///
  /// In en, this message translates to:
  /// **'The branch or factory where these labels physically live.'**
  String get labelWizardStoredAtHelper;

  /// No description provided for @labelWizardUsualBatchSheets.
  ///
  /// In en, this message translates to:
  /// **'Usual print batch (sheets)'**
  String get labelWizardUsualBatchSheets;

  /// No description provided for @labelWizardUsualBatchHelper.
  ///
  /// In en, this message translates to:
  /// **'Applied to every flavour; changeable per label later.'**
  String get labelWizardUsualBatchHelper;

  /// No description provided for @labelWizardConfirmPriceList.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get labelWizardConfirmPriceList;

  /// No description provided for @labelWizardConfirmUsualBatch.
  ///
  /// In en, this message translates to:
  /// **'Usual batch'**
  String get labelWizardConfirmUsualBatch;

  /// No description provided for @labelWizardSafeToRerun.
  ///
  /// In en, this message translates to:
  /// **'Flavours already tracked are left untouched — running this again is always safe.'**
  String get labelWizardSafeToRerun;

  /// No description provided for @b2bStageLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get b2bStageLead;

  /// No description provided for @b2bStageQualify.
  ///
  /// In en, this message translates to:
  /// **'Qualify'**
  String get b2bStageQualify;

  /// No description provided for @b2bStageSample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get b2bStageSample;

  /// No description provided for @b2bStageApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get b2bStageApproved;

  /// No description provided for @b2bStageTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get b2bStageTrial;

  /// No description provided for @b2bStageCheckup.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get b2bStageCheckup;

  /// No description provided for @b2bStageActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get b2bStageActive;

  /// No description provided for @b2bStageLostOnHold.
  ///
  /// In en, this message translates to:
  /// **'Lost/On-hold'**
  String get b2bStageLostOnHold;

  /// No description provided for @leadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leadsTitle;

  /// No description provided for @leadsMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Leads map'**
  String get leadsMapTitle;

  /// No description provided for @leadsMapViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get leadsMapViewTooltip;

  /// No description provided for @leadsListViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get leadsListViewTooltip;

  /// No description provided for @leadsRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get leadsRefreshTooltip;

  /// No description provided for @leadsAddLead.
  ///
  /// In en, this message translates to:
  /// **'Add lead'**
  String get leadsAddLead;

  /// No description provided for @leadsStatShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get leadsStatShowing;

  /// No description provided for @leadsStatTierA.
  ///
  /// In en, this message translates to:
  /// **'Tier A'**
  String get leadsStatTierA;

  /// No description provided for @leadsStatBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get leadsStatBranches;

  /// No description provided for @leadsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search leads…'**
  String get leadsSearchHint;

  /// No description provided for @leadsAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get leadsAdvancedFilters;

  /// No description provided for @leadsEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No leads match these filters'**
  String get leadsEmptyFiltered;

  /// No description provided for @leadsDistanceMetres.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String leadsDistanceMetres(String value);

  /// No description provided for @leadsDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String leadsDistanceKm(String value);

  /// No description provided for @leadsLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on in your device settings.'**
  String get leadsLocationServicesOff;

  /// No description provided for @leadsLocationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked for this app.'**
  String get leadsLocationBlocked;

  /// No description provided for @leadsLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was declined.'**
  String get leadsLocationDenied;

  /// No description provided for @leadsLocationNoFix.
  ///
  /// In en, this message translates to:
  /// **'Could not get a location fix. Try again outdoors.'**
  String get leadsLocationNoFix;

  /// No description provided for @leadsLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get leadsLocationSettings;

  /// No description provided for @leadsOnMapCount.
  ///
  /// In en, this message translates to:
  /// **'{count} on map'**
  String leadsOnMapCount(int count);

  /// No description provided for @leadsOnMapWithStages.
  ///
  /// In en, this message translates to:
  /// **'{count} on map  ·  {stages}'**
  String leadsOnMapWithStages(int count, String stages);

  /// No description provided for @leadsStageSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stages'**
  String leadsStageSummaryCount(int count);

  /// No description provided for @leadsHideLegend.
  ///
  /// In en, this message translates to:
  /// **'Hide legend'**
  String get leadsHideLegend;

  /// No description provided for @leadsCategoryLegend.
  ///
  /// In en, this message translates to:
  /// **'Category legend'**
  String get leadsCategoryLegend;

  /// No description provided for @leadsShowMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get leadsShowMyLocation;

  /// No description provided for @leadsBranchesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 branch} other{{count} branches}}'**
  String leadsBranchesCount(int count);

  /// No description provided for @leadsDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away (straight line)'**
  String leadsDistanceAway(String distance);

  /// No description provided for @leadsFilterActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String leadsFilterActiveCount(int count);

  /// No description provided for @leadsFilterPipelineStage.
  ///
  /// In en, this message translates to:
  /// **'Pipeline stage'**
  String get leadsFilterPipelineStage;

  /// No description provided for @leadsFilterRatingRange.
  ///
  /// In en, this message translates to:
  /// **'Rating range'**
  String get leadsFilterRatingRange;

  /// No description provided for @leadsFilterMinReviews.
  ///
  /// In en, this message translates to:
  /// **'Minimum reviews: {count}'**
  String leadsFilterMinReviews(int count);

  /// No description provided for @leadsFilterMinBranches.
  ///
  /// In en, this message translates to:
  /// **'Minimum branch count'**
  String get leadsFilterMinBranches;

  /// No description provided for @leadsFilterHasSahel.
  ///
  /// In en, this message translates to:
  /// **'Has Sahel branches'**
  String get leadsFilterHasSahel;

  /// No description provided for @leadsFilterSpecialtyOnly.
  ///
  /// In en, this message translates to:
  /// **'Specialty only'**
  String get leadsFilterSpecialtyOnly;

  /// No description provided for @leadsFilterTakeawayOnly.
  ///
  /// In en, this message translates to:
  /// **'Takeaway confirmed'**
  String get leadsFilterTakeawayOnly;

  /// No description provided for @leadsFilterTalabat.
  ///
  /// In en, this message translates to:
  /// **'Talabat'**
  String get leadsFilterTalabat;

  /// No description provided for @leadsFilterTalabatOn.
  ///
  /// In en, this message translates to:
  /// **'On Talabat'**
  String get leadsFilterTalabatOn;

  /// No description provided for @leadsFilterTalabatOff.
  ///
  /// In en, this message translates to:
  /// **'Not on Talabat'**
  String get leadsFilterTalabatOff;

  /// No description provided for @leadsTalabatBadge.
  ///
  /// In en, this message translates to:
  /// **'Talabat'**
  String get leadsTalabatBadge;

  /// No description provided for @leadsTalabatRatingFromGoogle.
  ///
  /// In en, this message translates to:
  /// **'Rating shown is from Google — no Talabat rating yet'**
  String get leadsTalabatRatingFromGoogle;

  /// No description provided for @leadsTalabatUnrated.
  ///
  /// In en, this message translates to:
  /// **'Listed on Talabat, not yet rated'**
  String get leadsTalabatUnrated;

  /// No description provided for @leadsFilterHasPhone.
  ///
  /// In en, this message translates to:
  /// **'Has phone'**
  String get leadsFilterHasPhone;

  /// No description provided for @leadsFilterHasInstagram.
  ///
  /// In en, this message translates to:
  /// **'Has Instagram'**
  String get leadsFilterHasInstagram;

  /// No description provided for @leadsFilterHasWebsite.
  ///
  /// In en, this message translates to:
  /// **'Has website'**
  String get leadsFilterHasWebsite;

  /// No description provided for @leadsFilterShowNotSuitable.
  ///
  /// In en, this message translates to:
  /// **'Show not suitable'**
  String get leadsFilterShowNotSuitable;

  /// No description provided for @leadsFilterPriceBand.
  ///
  /// In en, this message translates to:
  /// **'Price band'**
  String get leadsFilterPriceBand;

  /// No description provided for @leadsFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get leadsFilterClearAll;

  /// No description provided for @leadsAreaClearCount.
  ///
  /// In en, this message translates to:
  /// **'Clear ({count})'**
  String leadsAreaClearCount(int count);

  /// No description provided for @leadsAreaSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search areas'**
  String get leadsAreaSearchHint;

  /// No description provided for @leadsAreaNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No area matches \"{query}\"'**
  String leadsAreaNoMatch(String query);

  /// No description provided for @leadsAreaAll.
  ///
  /// In en, this message translates to:
  /// **'All areas'**
  String get leadsAreaAll;

  /// No description provided for @leadsAreaSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} areas'**
  String leadsAreaSelectedCount(int count);

  /// No description provided for @leadsMergeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge {count} into \"{survivor}\"?'**
  String leadsMergeConfirmTitle(int count, String survivor);

  /// No description provided for @leadsMergeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Their branches, areas and any details \"{survivor}\" is missing move onto it. The merged leads stay on file for audit but leave the catalog and the pipeline board.'**
  String leadsMergeConfirmBody(String survivor);

  /// No description provided for @leadsMergeFailed.
  ///
  /// In en, this message translates to:
  /// **'Merge failed: {error}'**
  String leadsMergeFailed(String error);

  /// No description provided for @leadsMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge duplicates'**
  String get leadsMergeTitle;

  /// No description provided for @leadsMergeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fold other records of the same brand into \"{name}\".'**
  String leadsMergeSubtitle(String name);

  /// No description provided for @leadsMergeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, or leave blank for suggestions'**
  String get leadsMergeSearchHint;

  /// No description provided for @leadsMergeAction.
  ///
  /// In en, this message translates to:
  /// **'Merge {count}'**
  String leadsMergeAction(int count);

  /// No description provided for @leadsMergeNoDuplicates.
  ///
  /// In en, this message translates to:
  /// **'No likely duplicates found. Search by name if you know of one.'**
  String get leadsMergeNoDuplicates;

  /// No description provided for @leadsMergeNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No leads match that search.'**
  String get leadsMergeNoMatch;

  /// No description provided for @leadsMergedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Leads merged'**
  String get leadsMergedSuccess;

  /// No description provided for @leadsAllStages.
  ///
  /// In en, this message translates to:
  /// **'All stages'**
  String get leadsAllStages;

  /// No description provided for @leadsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get leadsFilterTitle;

  /// No description provided for @leadsFilterAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get leadsFilterAreas;

  /// No description provided for @leadsFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get leadsFilterAny;

  /// No description provided for @leadsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get leadsFilterAll;

  /// No description provided for @leadsFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get leadsFilterDone;

  /// No description provided for @leadDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get leadDetailTitle;

  /// No description provided for @leadDetailBranchesCount.
  ///
  /// In en, this message translates to:
  /// **'Branches ({count})'**
  String leadDetailBranchesCount(int count);

  /// No description provided for @leadDetailStatusNotes.
  ///
  /// In en, this message translates to:
  /// **'Status & notes'**
  String get leadDetailStatusNotes;

  /// No description provided for @leadDetailStatusField.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get leadDetailStatusField;

  /// No description provided for @leadDetailCategoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get leadDetailCategoryField;

  /// No description provided for @leadDetailCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get leadDetailCategoryNone;

  /// No description provided for @leadDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Lead updated'**
  String get leadDetailUpdated;

  /// No description provided for @leadDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String leadDetailFailed(String error);

  /// No description provided for @leadDetailFitScoreUpdated.
  ///
  /// In en, this message translates to:
  /// **'Fit score updated'**
  String get leadDetailFitScoreUpdated;

  /// No description provided for @leadDetailScoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'{score} / 100'**
  String leadDetailScoreOutOf(int score);

  /// No description provided for @leadDetailStageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stage updated to {stage}'**
  String leadDetailStageUpdated(String stage);

  /// No description provided for @leadDetailReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leadDetailReasonTitle;

  /// No description provided for @leadDetailReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this lost / on hold?'**
  String get leadDetailReasonHint;

  /// No description provided for @leadDetailNotSuitable.
  ///
  /// In en, this message translates to:
  /// **'Not suitable'**
  String get leadDetailNotSuitable;

  /// No description provided for @leadDetailByWhom.
  ///
  /// In en, this message translates to:
  /// **'by {user}'**
  String leadDetailByWhom(String user);

  /// No description provided for @leadDetailOnDate.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String leadDetailOnDate(String date);

  /// No description provided for @leadDetailMarkedNotSuitable.
  ///
  /// In en, this message translates to:
  /// **'Marked not suitable'**
  String get leadDetailMarkedNotSuitable;

  /// No description provided for @leadDetailRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore lead?'**
  String get leadDetailRestoreTitle;

  /// No description provided for @leadDetailRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'This clears the not-suitable verdict and puts the lead back in the catalog at the Lead stage.'**
  String get leadDetailRestoreBody;

  /// No description provided for @leadDetailRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get leadDetailRestore;

  /// No description provided for @leadDetailRestored.
  ///
  /// In en, this message translates to:
  /// **'Lead restored'**
  String get leadDetailRestored;

  /// No description provided for @leadDetailSuitability.
  ///
  /// In en, this message translates to:
  /// **'Suitability'**
  String get leadDetailSuitability;

  /// No description provided for @leadDetailSuitabilityMarked.
  ///
  /// In en, this message translates to:
  /// **'This prospect was judged not suitable after manual inspection. It is hidden from the catalog and off the pipeline board.'**
  String get leadDetailSuitabilityMarked;

  /// No description provided for @leadDetailSuitabilityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Inspected this prospect and it is not worth pursuing? Mark it not suitable to take it out of the working catalog.'**
  String get leadDetailSuitabilityPrompt;

  /// No description provided for @leadDetailRestoreLead.
  ///
  /// In en, this message translates to:
  /// **'Restore lead'**
  String get leadDetailRestoreLead;

  /// No description provided for @leadDetailMarkNotSuitable.
  ///
  /// In en, this message translates to:
  /// **'Mark not suitable'**
  String get leadDetailMarkNotSuitable;

  /// No description provided for @leadDetailNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get leadDetailNotesOptional;

  /// No description provided for @leadDetailInspectionHint.
  ///
  /// In en, this message translates to:
  /// **'What did the inspection show?'**
  String get leadDetailInspectionHint;

  /// No description provided for @leadDetailMergedAway.
  ///
  /// In en, this message translates to:
  /// **'Merged into another lead'**
  String get leadDetailMergedAway;

  /// No description provided for @leadDetailOpenSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Open the surviving lead'**
  String get leadDetailOpenSurvivor;

  /// No description provided for @leadDetailDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get leadDetailDuplicates;

  /// No description provided for @leadDetailDuplicatesBody.
  ///
  /// In en, this message translates to:
  /// **'The catalog was built per location, so one brand can appear as several leads. Merge them here to keep every branch on one record.'**
  String get leadDetailDuplicatesBody;

  /// No description provided for @leadDetailAddresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get leadDetailAddresses;

  /// No description provided for @leadDetailPrimaryAddress.
  ///
  /// In en, this message translates to:
  /// **'Primary address'**
  String get leadDetailPrimaryAddress;

  /// No description provided for @leadDetailShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get leadDetailShippingAddress;

  /// No description provided for @leadDetailAddressSaved.
  ///
  /// In en, this message translates to:
  /// **'{title} saved'**
  String leadDetailAddressSaved(String title);

  /// No description provided for @leadDetailSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save {title}'**
  String leadDetailSaveAddress(String title);

  /// No description provided for @leadFieldAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get leadFieldAddressLine1;

  /// No description provided for @leadFieldAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get leadFieldAddressLine2;

  /// No description provided for @leadFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get leadFieldCity;

  /// No description provided for @leadFieldState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get leadFieldState;

  /// No description provided for @leadFieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get leadFieldCountry;

  /// No description provided for @leadFieldPincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get leadFieldPincode;

  /// No description provided for @leadFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get leadFieldPhone;

  /// No description provided for @leadFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit lead'**
  String get leadFormEditTitle;

  /// No description provided for @leadFormSaved.
  ///
  /// In en, this message translates to:
  /// **'Lead saved'**
  String get leadFormSaved;

  /// No description provided for @leadFormNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get leadFormNewCategory;

  /// No description provided for @leadFormCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get leadFormCategoryName;

  /// No description provided for @leadFormAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get leadFormAddCategory;

  /// No description provided for @leadFormLeadName.
  ///
  /// In en, this message translates to:
  /// **'Lead name *'**
  String get leadFormLeadName;

  /// No description provided for @leadFormCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get leadFormCompanyName;

  /// No description provided for @leadFormPrimaryArea.
  ///
  /// In en, this message translates to:
  /// **'Primary area'**
  String get leadFormPrimaryArea;

  /// No description provided for @leadFormPriceBand.
  ///
  /// In en, this message translates to:
  /// **'Price band'**
  String get leadFormPriceBand;

  /// No description provided for @leadFormFitScoreRange.
  ///
  /// In en, this message translates to:
  /// **'{label} (0–100)'**
  String leadFormFitScoreRange(String label);

  /// No description provided for @leadFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get leadFormSaveChanges;

  /// No description provided for @leadFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create lead'**
  String get leadFormCreate;

  /// No description provided for @leadFormCardBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get leadFormCardBrand;

  /// No description provided for @leadFormCardClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get leadFormCardClassification;

  /// No description provided for @leadFormCardContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get leadFormCardContact;

  /// No description provided for @leadFormTier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get leadFormTier;

  /// No description provided for @leadFormSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get leadFormSpecialty;

  /// No description provided for @leadFieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get leadFieldMobile;

  /// No description provided for @leadFieldWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get leadFieldWebsite;

  /// No description provided for @leadFieldInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get leadFieldInstagram;

  /// No description provided for @leadFieldFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get leadFieldFacebook;

  /// No description provided for @leadFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get leadFormRequired;

  /// No description provided for @leadFormScoreRangeError.
  ///
  /// In en, this message translates to:
  /// **'0–100'**
  String get leadFormScoreRangeError;

  /// No description provided for @leadFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get leadFormCategoryLabel;

  /// No description provided for @leadsSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get leadsSortTooltip;

  /// No description provided for @leadsSortScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get leadsSortScore;

  /// No description provided for @leadsSortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get leadsSortRating;

  /// No description provided for @leadsSortReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get leadsSortReviews;

  /// No description provided for @leadsSortBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get leadsSortBranches;

  /// No description provided for @leadsSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get leadsSortName;

  /// No description provided for @leadsSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get leadsSortNearest;

  /// No description provided for @leadsMapCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get leadsMapCategories;

  /// No description provided for @leadActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get leadActionCall;

  /// No description provided for @leadActionInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get leadActionInstagram;

  /// No description provided for @leadActionWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get leadActionWebsite;

  /// No description provided for @leadActionMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get leadActionMap;

  /// No description provided for @leadsMergeConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get leadsMergeConfirmAction;

  /// No description provided for @b2bAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get b2bAccountTitle;

  /// No description provided for @b2bAccountLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load account.\n{error}'**
  String b2bAccountLoadFailed(String error);

  /// No description provided for @b2bFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String b2bFailed(String error);

  /// No description provided for @b2bLogCall.
  ///
  /// In en, this message translates to:
  /// **'Log call'**
  String get b2bLogCall;

  /// No description provided for @b2bLogCallHint.
  ///
  /// In en, this message translates to:
  /// **'What was discussed?'**
  String get b2bLogCallHint;

  /// No description provided for @b2bActivityLogged.
  ///
  /// In en, this message translates to:
  /// **'Activity logged'**
  String get b2bActivityLogged;

  /// No description provided for @b2bLogActivityFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log activity: {error}'**
  String b2bLogActivityFailed(String error);

  /// No description provided for @b2bMarkLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark lost / on-hold'**
  String get b2bMarkLostTitle;

  /// No description provided for @b2bReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get b2bReasonHint;

  /// No description provided for @b2bMarkedLost.
  ///
  /// In en, this message translates to:
  /// **'Marked Lost/On-hold'**
  String get b2bMarkedLost;

  /// No description provided for @b2bCreateCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create customer for lead'**
  String get b2bCreateCustomerTitle;

  /// No description provided for @b2bCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get b2bCustomerName;

  /// No description provided for @b2bAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get b2bAddress;

  /// No description provided for @b2bContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get b2bContinue;

  /// No description provided for @b2bLoadingTerritories.
  ///
  /// In en, this message translates to:
  /// **'Loading territories…'**
  String get b2bLoadingTerritories;

  /// No description provided for @b2bTerritoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load territories'**
  String get b2bTerritoriesFailed;

  /// No description provided for @b2bOpenLeadPage.
  ///
  /// In en, this message translates to:
  /// **'Open lead page'**
  String get b2bOpenLeadPage;

  /// No description provided for @b2bSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get b2bSectionContact;

  /// No description provided for @b2bSectionInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get b2bSectionInsights;

  /// No description provided for @b2bSectionRecentInvoices.
  ///
  /// In en, this message translates to:
  /// **'Recent invoices'**
  String get b2bSectionRecentInvoices;

  /// No description provided for @b2bSectionOpenTodos.
  ///
  /// In en, this message translates to:
  /// **'Open to-dos'**
  String get b2bSectionOpenTodos;

  /// No description provided for @b2bNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get b2bNone;

  /// No description provided for @b2bPredictedNextOrder.
  ///
  /// In en, this message translates to:
  /// **'Predicted next order'**
  String get b2bPredictedNextOrder;

  /// No description provided for @b2bAvgOrderCycle.
  ///
  /// In en, this message translates to:
  /// **'Avg order cycle'**
  String get b2bAvgOrderCycle;

  /// No description provided for @b2bDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String b2bDaysValue(String days);

  /// No description provided for @b2bSendSample.
  ///
  /// In en, this message translates to:
  /// **'Send sample'**
  String get b2bSendSample;

  /// No description provided for @b2bPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get b2bPlaceOrder;

  /// No description provided for @b2bMarkLost.
  ///
  /// In en, this message translates to:
  /// **'Mark lost'**
  String get b2bMarkLost;

  /// No description provided for @b2bViewPricing.
  ///
  /// In en, this message translates to:
  /// **'View pricing'**
  String get b2bViewPricing;

  /// No description provided for @b2bLabelsSection.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get b2bLabelsSection;

  /// No description provided for @b2bLabelsNeedPrinting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs printing} other{{count} need printing}}'**
  String b2bLabelsNeedPrinting(int count);

  /// No description provided for @b2bNoLabelsTracked.
  ///
  /// In en, this message translates to:
  /// **'No labels tracked for this customer yet.'**
  String get b2bNoLabelsTracked;

  /// No description provided for @b2bSetUpLabels.
  ///
  /// In en, this message translates to:
  /// **'Set up labels'**
  String get b2bSetUpLabels;

  /// No description provided for @b2bLoadingLeadProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading lead profile…'**
  String get b2bLoadingLeadProfile;

  /// No description provided for @b2bLeadProfile.
  ///
  /// In en, this message translates to:
  /// **'Lead profile'**
  String get b2bLeadProfile;

  /// No description provided for @b2bMoreBranches.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String b2bMoreBranches(int count);

  /// No description provided for @b2bPipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'B2B Pipeline'**
  String get b2bPipelineTitle;

  /// No description provided for @b2bMyFollowUps.
  ///
  /// In en, this message translates to:
  /// **'My follow-ups'**
  String get b2bMyFollowUps;

  /// No description provided for @b2bRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get b2bRefresh;

  /// No description provided for @b2bSwitchMode.
  ///
  /// In en, this message translates to:
  /// **'Switch mode'**
  String get b2bSwitchMode;

  /// No description provided for @b2bGoToPos.
  ///
  /// In en, this message translates to:
  /// **'Go to POS (B2C)'**
  String get b2bGoToPos;

  /// No description provided for @b2bGoToKanban.
  ///
  /// In en, this message translates to:
  /// **'Go to Dispatch Kanban'**
  String get b2bGoToKanban;

  /// No description provided for @b2bNewLead.
  ///
  /// In en, this message translates to:
  /// **'New lead'**
  String get b2bNewLead;

  /// No description provided for @b2bMovedToStage.
  ///
  /// In en, this message translates to:
  /// **'Moved \"{title}\" to {stage}'**
  String b2bMovedToStage(String title, String stage);

  /// No description provided for @b2bAdvanceStageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to advance stage: {error}'**
  String b2bAdvanceStageFailed(String error);

  /// No description provided for @b2bFollowUpReminder.
  ///
  /// In en, this message translates to:
  /// **'Follow-up reminder'**
  String get b2bFollowUpReminder;

  /// No description provided for @b2bFollowUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'When should you follow up after moving to \"{stage}\"?'**
  String b2bFollowUpPrompt(String stage);

  /// No description provided for @b2bSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get b2bSkip;

  /// No description provided for @b2bSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get b2bSetReminder;

  /// No description provided for @b2bLostReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this lost / on hold?'**
  String get b2bLostReasonHint;

  /// No description provided for @b2bPipelineLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the pipeline.\n{error}'**
  String b2bPipelineLoadFailed(String error);

  /// No description provided for @b2bTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get b2bTodayTitle;

  /// No description provided for @b2bTodayLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load follow-ups.\n{error}'**
  String b2bTodayLoadFailed(String error);

  /// No description provided for @b2bNoFollowUpsToday.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups today'**
  String get b2bNoFollowUpsToday;

  /// No description provided for @b2bNoReordersDue.
  ///
  /// In en, this message translates to:
  /// **'No reorders due'**
  String get b2bNoReordersDue;

  /// No description provided for @b2bFollowUpDone.
  ///
  /// In en, this message translates to:
  /// **'Follow-up marked done'**
  String get b2bFollowUpDone;

  /// No description provided for @b2bFollowUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete follow-up: {error}'**
  String b2bFollowUpFailed(String error);

  /// No description provided for @b2bDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get b2bDone;

  /// No description provided for @b2bOverdueSuffix.
  ///
  /// In en, this message translates to:
  /// **'{date} · overdue'**
  String b2bOverdueSuffix(String date);

  /// No description provided for @b2bAvgBasket.
  ///
  /// In en, this message translates to:
  /// **'Avg: {amount}'**
  String b2bAvgBasket(String amount);

  /// No description provided for @b2bScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String b2bScoreLabel(int score);

  /// No description provided for @b2bNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get b2bNoAccounts;

  /// No description provided for @b2bLabelCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label} other{{count} labels}}'**
  String b2bLabelCount(int count);

  /// No description provided for @b2bLastOrder.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String b2bLastOrder(String date);

  /// No description provided for @b2bNextOrder.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String b2bNextOrder(String date);

  /// No description provided for @b2bCardLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get b2bCardLead;

  /// No description provided for @b2bCardOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Opportunity'**
  String get b2bCardOpportunity;

  /// No description provided for @b2bLabelsNeedPrintingTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 label needs printing} other{{count} labels need printing}}'**
  String b2bLabelsNeedPrintingTooltip(int count);

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Lists'**
  String get pricingTitle;

  /// No description provided for @pricingCustomerLookup.
  ///
  /// In en, this message translates to:
  /// **'Customer pricing lookup'**
  String get pricingCustomerLookup;

  /// No description provided for @pricingRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get pricingRefresh;

  /// No description provided for @pricingNewPriceList.
  ///
  /// In en, this message translates to:
  /// **'New price list'**
  String get pricingNewPriceList;

  /// No description provided for @pricingNoPriceLists.
  ///
  /// In en, this message translates to:
  /// **'No price lists yet.'**
  String get pricingNoPriceLists;

  /// No description provided for @pricingNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pricingNameField;

  /// No description provided for @pricingCurrencyField.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get pricingCurrencyField;

  /// No description provided for @pricingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get pricingCreate;

  /// No description provided for @pricingCreated.
  ///
  /// In en, this message translates to:
  /// **'Created \"{name}\"'**
  String pricingCreated(String name);

  /// No description provided for @pricingCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create price list: {error}'**
  String pricingCreateFailed(String error);

  /// No description provided for @pricingDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get pricingDefaultBadge;

  /// No description provided for @pricingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load price lists.\n{error}'**
  String pricingLoadFailed(String error);

  /// No description provided for @pricingDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load \"{name}\".\n{error}'**
  String pricingDetailLoadFailed(String name, String error);

  /// No description provided for @pricingSetRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Set {category} rate'**
  String pricingSetRateTitle(String category);

  /// No description provided for @pricingRateUpdated.
  ///
  /// In en, this message translates to:
  /// **'{category} rate updated'**
  String pricingRateUpdated(String category);

  /// No description provided for @pricingRateSet.
  ///
  /// In en, this message translates to:
  /// **'{category} rate set'**
  String pricingRateSet(String category);

  /// No description provided for @pricingAllCategoriesHaveRows.
  ///
  /// In en, this message translates to:
  /// **'All categories already have a row.'**
  String get pricingAllCategoriesHaveRows;

  /// No description provided for @pricingItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String pricingItemCount(int count);

  /// No description provided for @pricingOverrideTitle.
  ///
  /// In en, this message translates to:
  /// **'Override {item}'**
  String pricingOverrideTitle(String item);

  /// No description provided for @pricingOverrideUpdated.
  ///
  /// In en, this message translates to:
  /// **'Override updated'**
  String get pricingOverrideUpdated;

  /// No description provided for @pricingRemoveOverrideTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove override?'**
  String get pricingRemoveOverrideTitle;

  /// No description provided for @pricingRemoveOverrideBody.
  ///
  /// In en, this message translates to:
  /// **'{item} will fall back to its category rate.'**
  String pricingRemoveOverrideBody(String item);

  /// No description provided for @pricingRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pricingRemove;

  /// No description provided for @pricingOverrideRemoved.
  ///
  /// In en, this message translates to:
  /// **'Override removed'**
  String get pricingOverrideRemoved;

  /// No description provided for @pricingAddOverride.
  ///
  /// In en, this message translates to:
  /// **'Add override'**
  String get pricingAddOverride;

  /// No description provided for @pricingItemCode.
  ///
  /// In en, this message translates to:
  /// **'Item code'**
  String get pricingItemCode;

  /// No description provided for @pricingRateField.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get pricingRateField;

  /// No description provided for @pricingOverrideAdded.
  ///
  /// In en, this message translates to:
  /// **'Override added'**
  String get pricingOverrideAdded;

  /// No description provided for @pricingUnassignTitle.
  ///
  /// In en, this message translates to:
  /// **'Unassign customer?'**
  String get pricingUnassignTitle;

  /// No description provided for @pricingUnassignBody.
  ///
  /// In en, this message translates to:
  /// **'{customer} will revert to their customer group default.'**
  String pricingUnassignBody(String customer);

  /// No description provided for @pricingUnassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get pricingUnassign;

  /// No description provided for @pricingCustomerUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Customer unassigned'**
  String get pricingCustomerUnassigned;

  /// No description provided for @pricingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String pricingFailed(String error);

  /// No description provided for @pricingCategoryPrices.
  ///
  /// In en, this message translates to:
  /// **'Category prices'**
  String get pricingCategoryPrices;

  /// No description provided for @pricingAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get pricingAddCategory;

  /// No description provided for @pricingNoCategoryRates.
  ///
  /// In en, this message translates to:
  /// **'No category rates set.'**
  String get pricingNoCategoryRates;

  /// No description provided for @pricingEditRateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit {category} rate'**
  String pricingEditRateTooltip(String category);

  /// No description provided for @pricingPerFlavorOverrides.
  ///
  /// In en, this message translates to:
  /// **'Per-flavor overrides'**
  String get pricingPerFlavorOverrides;

  /// No description provided for @pricingOverrideCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 override} other{{count} overrides}}'**
  String pricingOverrideCount(int count);

  /// No description provided for @pricingNoOverrides.
  ///
  /// In en, this message translates to:
  /// **'No per-item overrides.'**
  String get pricingNoOverrides;

  /// No description provided for @pricingEditOverride.
  ///
  /// In en, this message translates to:
  /// **'Edit override'**
  String get pricingEditOverride;

  /// No description provided for @pricingRemoveOverride.
  ///
  /// In en, this message translates to:
  /// **'Remove override'**
  String get pricingRemoveOverride;

  /// No description provided for @pricingAssignedCustomers.
  ///
  /// In en, this message translates to:
  /// **'Assigned customers'**
  String get pricingAssignedCustomers;

  /// No description provided for @pricingCustomerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 customer} other{{count} customers}}'**
  String pricingCustomerCount(int count);

  /// No description provided for @pricingNoCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers use this list.'**
  String get pricingNoCustomers;

  /// No description provided for @pricingViaGroup.
  ///
  /// In en, this message translates to:
  /// **'via group {group}'**
  String pricingViaGroup(String group);

  /// No description provided for @pricingDirectAssignment.
  ///
  /// In en, this message translates to:
  /// **'direct assignment'**
  String get pricingDirectAssignment;

  /// No description provided for @customerPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer pricing'**
  String get customerPricingTitle;

  /// No description provided for @customerPricingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search company customers…'**
  String get customerPricingSearchHint;

  /// No description provided for @customerPricingSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed.\n{error}'**
  String customerPricingSearchFailed(String error);

  /// No description provided for @customerPricingNoCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers found.'**
  String get customerPricingNoCustomers;

  /// No description provided for @customerPricingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load pricing for \"{customer}\".\n{error}'**
  String customerPricingLoadFailed(String customer, String error);

  /// No description provided for @customerPricingEffective.
  ///
  /// In en, this message translates to:
  /// **'Effective prices'**
  String get customerPricingEffective;

  /// No description provided for @customerPricingNoResolved.
  ///
  /// In en, this message translates to:
  /// **'No resolved prices.'**
  String get customerPricingNoResolved;

  /// No description provided for @customerPricingSource.
  ///
  /// In en, this message translates to:
  /// **'{group} · source: {source}'**
  String customerPricingSource(String group, String source);

  /// No description provided for @pricingNoCategoryRatesShort.
  ///
  /// In en, this message translates to:
  /// **'No category rates set'**
  String get pricingNoCategoryRatesShort;

  /// No description provided for @pricingCardSummary.
  ///
  /// In en, this message translates to:
  /// **'{customers} · {currency}'**
  String pricingCardSummary(String customers, String currency);

  /// No description provided for @pricingDisabledSuffix.
  ///
  /// In en, this message translates to:
  /// **' · disabled'**
  String get pricingDisabledSuffix;

  /// No description provided for @customerPricingGroupLine.
  ///
  /// In en, this message translates to:
  /// **'Group: {group}\nPrice list: {priceList} ({assignment})'**
  String customerPricingGroupLine(
    String group,
    String priceList,
    String assignment,
  );

  /// No description provided for @pricingNoneValue.
  ///
  /// In en, this message translates to:
  /// **'(none)'**
  String get pricingNoneValue;

  /// No description provided for @pricingDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get pricingDash;

  /// No description provided for @journeyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get journeyToday;

  /// No description provided for @journeyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get journeyYesterday;

  /// No description provided for @journeyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get journeyTomorrow;

  /// No description provided for @journeyDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String journeyDaysAgo(int count);

  /// No description provided for @journeyWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String journeyWeeksAgo(int count);

  /// No description provided for @journeyMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String journeyMonthsAgo(int count);

  /// No description provided for @journeyOverdueByDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overdue by 1 day} other{Overdue by {count} days}}'**
  String journeyOverdueByDays(int count);

  /// No description provided for @journeyOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get journeyOverdue;

  /// No description provided for @journeyInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 day} other{In {count} days}}'**
  String journeyInDays(int count);

  /// No description provided for @journeyInMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 month} other{In {count} months}}'**
  String journeyInMonths(int count);

  /// No description provided for @journeyTypeVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get journeyTypeVisit;

  /// No description provided for @journeyTypeCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get journeyTypeCall;

  /// No description provided for @journeyTypeWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get journeyTypeWhatsapp;

  /// No description provided for @journeyTypeSampleDrop.
  ///
  /// In en, this message translates to:
  /// **'Sample Drop'**
  String get journeyTypeSampleDrop;

  /// No description provided for @journeyTypeMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get journeyTypeMeeting;

  /// No description provided for @journeyTypeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get journeyTypeEmail;

  /// No description provided for @journeyTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get journeyTypeOther;

  /// No description provided for @journeyOutcomeInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get journeyOutcomeInterested;

  /// No description provided for @journeyOutcomeNeedsFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Needs Follow-up'**
  String get journeyOutcomeNeedsFollowUp;

  /// No description provided for @journeyOutcomeSampleRequested.
  ///
  /// In en, this message translates to:
  /// **'Sample Requested'**
  String get journeyOutcomeSampleRequested;

  /// No description provided for @journeyOutcomeOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get journeyOutcomeOrderPlaced;

  /// No description provided for @journeyOutcomeNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get journeyOutcomeNotNow;

  /// No description provided for @journeyOutcomeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get journeyOutcomeRejected;

  /// No description provided for @journeyEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit journey note'**
  String get journeyEditorEditTitle;

  /// No description provided for @journeyEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a visit or call'**
  String get journeyEditorNewTitle;

  /// No description provided for @journeyEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What happened, who you spoke to, and what happens next.'**
  String get journeyEditorSubtitle;

  /// No description provided for @journeyEditorDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get journeyEditorDate;

  /// No description provided for @journeyEditorType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get journeyEditorType;

  /// No description provided for @journeyEditorNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get journeyEditorNote;

  /// No description provided for @journeyEditorNoteHint.
  ///
  /// In en, this message translates to:
  /// **'They liked the matcha, asked about wholesale pricing…'**
  String get journeyEditorNoteHint;

  /// No description provided for @journeyEditorWhoSpoke.
  ///
  /// In en, this message translates to:
  /// **'Who you spoke to'**
  String get journeyEditorWhoSpoke;

  /// No description provided for @journeyEditorWhoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap who you met, or add someone new.'**
  String get journeyEditorWhoHint;

  /// No description provided for @journeyEditorNewPerson.
  ///
  /// In en, this message translates to:
  /// **'New person'**
  String get journeyEditorNewPerson;

  /// No description provided for @journeyEditorContactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the contact: {error}'**
  String journeyEditorContactFailed(String error);

  /// No description provided for @journeyEditorPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get journeyEditorPerson;

  /// No description provided for @journeyEditorPersonHint.
  ///
  /// In en, this message translates to:
  /// **'Mostafa'**
  String get journeyEditorPersonHint;

  /// No description provided for @journeyEditorRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get journeyEditorRole;

  /// No description provided for @journeyEditorRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Branch manager'**
  String get journeyEditorRoleHint;

  /// No description provided for @journeyEditorTheirPhone.
  ///
  /// In en, this message translates to:
  /// **'Their phone'**
  String get journeyEditorTheirPhone;

  /// No description provided for @journeyEditorOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get journeyEditorOutcome;

  /// No description provided for @journeyEditorNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next action'**
  String get journeyEditorNextAction;

  /// No description provided for @journeyEditorNextActionHelp.
  ///
  /// In en, this message translates to:
  /// **'A date here also sets the follow-up reminder on this account.'**
  String get journeyEditorNextActionHelp;

  /// No description provided for @journeyEditorWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get journeyEditorWhatToDo;

  /// No description provided for @journeyEditorWhatToDoHint.
  ///
  /// In en, this message translates to:
  /// **'Call the manager to confirm the trial order'**
  String get journeyEditorWhatToDoHint;

  /// No description provided for @journeyEditorWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get journeyEditorWhen;

  /// No description provided for @journeyEditorNoReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get journeyEditorNoReminder;

  /// No description provided for @journeyEditorLogIt.
  ///
  /// In en, this message translates to:
  /// **'Log it'**
  String get journeyEditorLogIt;

  /// No description provided for @journeyEditorPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get journeyEditorPickDate;

  /// No description provided for @journeyEditorClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get journeyEditorClear;

  /// No description provided for @journeySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journeySectionTitle;

  /// No description provided for @journeyLogVisit.
  ///
  /// In en, this message translates to:
  /// **'Log visit'**
  String get journeyLogVisit;

  /// No description provided for @journeyNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Journey note added'**
  String get journeyNoteAdded;

  /// No description provided for @journeyNoteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Journey note updated'**
  String get journeyNoteUpdated;

  /// No description provided for @journeyNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Journey note deleted'**
  String get journeyNoteDeleted;

  /// No description provided for @journeyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get journeyDeleteTitle;

  /// No description provided for @journeyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The visit record is removed for everyone. This cannot be undone.'**
  String get journeyDeleteBody;

  /// No description provided for @journeyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String journeyFailed(String error);

  /// No description provided for @journeyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get journeyEdit;

  /// No description provided for @journeyLoggedBy.
  ///
  /// In en, this message translates to:
  /// **'Logged by {user}'**
  String journeyLoggedBy(String user);

  /// No description provided for @journeyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No visits logged yet.'**
  String get journeyEmptyTitle;

  /// No description provided for @journeyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log what was said, who said it, and when to follow up — a dated next action also sets this account\'\'s reminder.'**
  String get journeyEmptyBody;

  /// No description provided for @journeyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the journey.'**
  String get journeyLoadFailed;

  /// No description provided for @journeyMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get journeyMarkDone;

  /// No description provided for @journeyMarkNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get journeyMarkNotDone;

  /// No description provided for @journeyDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get journeyDoneLabel;

  /// No description provided for @journeyDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String journeyDoneOn(String date);

  /// No description provided for @journeyDoneByOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date} · {user}'**
  String journeyDoneByOn(String date, String user);

  /// No description provided for @journeyActionMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Next action marked done'**
  String get journeyActionMarkedDone;

  /// No description provided for @journeyActionReopened.
  ///
  /// In en, this message translates to:
  /// **'Next action reopened'**
  String get journeyActionReopened;

  /// No description provided for @journeyCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Action calendar'**
  String get journeyCalendarTitle;

  /// No description provided for @journeyCalendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get journeyCalendarPreviousMonth;

  /// No description provided for @journeyCalendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get journeyCalendarNextMonth;

  /// No description provided for @journeyCalendarScopeMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get journeyCalendarScopeMine;

  /// No description provided for @journeyCalendarScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get journeyCalendarScopeAll;

  /// No description provided for @journeyCalendarShowDone.
  ///
  /// In en, this message translates to:
  /// **'Show done'**
  String get journeyCalendarShowDone;

  /// No description provided for @journeyCalendarPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending {count}'**
  String journeyCalendarPendingCount(int count);

  /// No description provided for @journeyCalendarOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'Overdue {count}'**
  String journeyCalendarOverdueCount(int count);

  /// No description provided for @journeyCalendarDoneCount.
  ///
  /// In en, this message translates to:
  /// **'Done {count}'**
  String journeyCalendarDoneCount(int count);

  /// No description provided for @journeyCalendarDueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 due} other{{count} due}}'**
  String journeyCalendarDueCount(int count);

  /// No description provided for @journeyCalendarNothingOnDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing due on this day.'**
  String get journeyCalendarNothingOnDay;

  /// No description provided for @journeyCalendarEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'Nothing due this month.'**
  String get journeyCalendarEmptyMonth;

  /// No description provided for @journeyCalendarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the calendar.'**
  String get journeyCalendarLoadFailed;

  /// No description provided for @journeyCalendarSourceFollowup.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get journeyCalendarSourceFollowup;

  /// No description provided for @journeyCalendarNoAction.
  ///
  /// In en, this message translates to:
  /// **'No action written'**
  String get journeyCalendarNoAction;

  /// No description provided for @errorConsoleCopyError.
  ///
  /// In en, this message translates to:
  /// **'Copy error'**
  String get errorConsoleCopyError;

  /// No description provided for @errorConsoleCopied.
  ///
  /// In en, this message translates to:
  /// **'Error details copied'**
  String get errorConsoleCopied;

  /// No description provided for @errorConsoleSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get errorConsoleSummary;

  /// No description provided for @errorConsoleFatal.
  ///
  /// In en, this message translates to:
  /// **'Fatal'**
  String get errorConsoleFatal;

  /// No description provided for @errorConsoleYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get errorConsoleYes;

  /// No description provided for @errorConsoleNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get errorConsoleNo;

  /// No description provided for @errorConsoleOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Occurrences'**
  String get errorConsoleOccurrences;

  /// No description provided for @errorConsoleDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get errorConsoleDetails;

  /// No description provided for @errorConsoleStackTrace.
  ///
  /// In en, this message translates to:
  /// **'Stack trace'**
  String get errorConsoleStackTrace;

  /// No description provided for @menuInstapayReconciliation.
  ///
  /// In en, this message translates to:
  /// **'InstaPay Reconciliation'**
  String get menuInstapayReconciliation;

  /// No description provided for @instapayTitle.
  ///
  /// In en, this message translates to:
  /// **'InstaPay Reconciliation'**
  String get instapayTitle;

  /// No description provided for @instapayNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders awaiting InstaPay confirmation'**
  String get instapayNoOrders;

  /// No description provided for @instapayCourierRequired.
  ///
  /// In en, this message translates to:
  /// **'A courier is required for cash collection'**
  String get instapayCourierRequired;

  /// No description provided for @instapayConvertedToCod.
  ///
  /// In en, this message translates to:
  /// **'Converted to cash on delivery'**
  String get instapayConvertedToCod;

  /// No description provided for @instapayCollectedCashInstead.
  ///
  /// In en, this message translates to:
  /// **'Collected cash instead'**
  String get instapayCollectedCashInstead;

  /// No description provided for @instapayConfirmReceived.
  ///
  /// In en, this message translates to:
  /// **'Confirm received'**
  String get instapayConfirmReceived;

  /// No description provided for @instapayPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get instapayPaymentConfirmed;

  /// No description provided for @instapayBankReference.
  ///
  /// In en, this message translates to:
  /// **'Bank reference number'**
  String get instapayBankReference;

  /// No description provided for @kanbanMoveAction.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get kanbanMoveAction;

  /// No description provided for @kanbanDeliveryPartnerField.
  ///
  /// In en, this message translates to:
  /// **'Delivery Partner'**
  String get kanbanDeliveryPartnerField;

  /// No description provided for @kanbanSetDeliveryIncome.
  ///
  /// In en, this message translates to:
  /// **'Set Delivery Income'**
  String get kanbanSetDeliveryIncome;

  /// No description provided for @kanbanDeliveryIncomeField.
  ///
  /// In en, this message translates to:
  /// **'Delivery income'**
  String get kanbanDeliveryIncomeField;

  /// No description provided for @kanbanInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative amount'**
  String get kanbanInvalidAmount;

  /// No description provided for @kanbanUpdatingDeliveryIncome.
  ///
  /// In en, this message translates to:
  /// **'Updating delivery income…'**
  String get kanbanUpdatingDeliveryIncome;

  /// No description provided for @kanbanErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String kanbanErrorWithMessage(String error);

  /// No description provided for @posShowHeaderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show header'**
  String get posShowHeaderTooltip;

  /// No description provided for @posCartDeliveryAmountField.
  ///
  /// In en, this message translates to:
  /// **'Delivery amount'**
  String get posCartDeliveryAmountField;

  /// No description provided for @posCartResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get posCartResetToDefault;

  /// No description provided for @posCartSetAction.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get posCartSetAction;

  /// No description provided for @posCartPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get posCartPromoCode;

  /// No description provided for @posCartPromoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EGY2026'**
  String get posCartPromoCodeHint;

  /// No description provided for @reportsColumnSegment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get reportsColumnSegment;

  /// No description provided for @reportsColumnRecencyDays.
  ///
  /// In en, this message translates to:
  /// **'Recency (d)'**
  String get reportsColumnRecencyDays;

  /// No description provided for @reportsColumnFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get reportsColumnFrequency;

  /// No description provided for @reportsColumnAov.
  ///
  /// In en, this message translates to:
  /// **'AOV'**
  String get reportsColumnAov;

  /// No description provided for @tripsOneBranchOnly.
  ///
  /// In en, this message translates to:
  /// **'Select invoices from one branch only to create a trip.'**
  String get tripsOneBranchOnly;

  /// No description provided for @webPushOnlyInWebApp.
  ///
  /// In en, this message translates to:
  /// **'Web push notifications are only available in the web app.'**
  String get webPushOnlyInWebApp;

  /// No description provided for @webPushEnabled.
  ///
  /// In en, this message translates to:
  /// **'Web push notifications are enabled for this device.'**
  String get webPushEnabled;

  /// No description provided for @webPushDisabledForEnv.
  ///
  /// In en, this message translates to:
  /// **'Web push notifications are disabled for this environment.'**
  String get webPushDisabledForEnv;

  /// No description provided for @webPushNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Web push notifications are not configured for this environment.'**
  String get webPushNotConfigured;

  /// No description provided for @webPushUnsupportedPrompt.
  ///
  /// In en, this message translates to:
  /// **'This browser does not support notification permission prompts.'**
  String get webPushUnsupportedPrompt;

  /// No description provided for @webPushPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Tap Enable Notifications to allow web push on this device.'**
  String get webPushPermissionRequired;

  /// No description provided for @webPushPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was denied.'**
  String get webPushPermissionDenied;

  /// No description provided for @webPushNoToken.
  ///
  /// In en, this message translates to:
  /// **'No web push token is available yet. Try again after reopening the app.'**
  String get webPushNoToken;

  /// No description provided for @webPushTokenReady.
  ///
  /// In en, this message translates to:
  /// **'Web push token is ready for registration.'**
  String get webPushTokenReady;

  /// No description provided for @webPushEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable notifications. Reopen the Home Screen app and try again.'**
  String get webPushEnableFailed;

  /// No description provided for @b2bCustomerLabelsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Customer labels'**
  String get b2bCustomerLabelsTooltip;

  /// No description provided for @b2bFollowUpsHeader.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get b2bFollowUpsHeader;

  /// No description provided for @b2bReorderDueHeader.
  ///
  /// In en, this message translates to:
  /// **'Reorder due'**
  String get b2bReorderDueHeader;

  /// No description provided for @expensesEmptyManagerHint.
  ///
  /// In en, this message translates to:
  /// **'Create a new expense to capture operational spending.'**
  String get expensesEmptyManagerHint;

  /// No description provided for @expensesEmptyStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a new expense and your manager will review it.'**
  String get expensesEmptyStaffHint;

  /// No description provided for @expenseSourceCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get expenseSourceCash;

  /// No description provided for @expenseSourceBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get expenseSourceBank;

  /// No description provided for @expenseSourceMobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile Wallet'**
  String get expenseSourceMobileWallet;

  /// No description provided for @expenseSourcePosProfile.
  ///
  /// In en, this message translates to:
  /// **'POS Profile'**
  String get expenseSourcePosProfile;

  /// No description provided for @expenseSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get expenseSourceAccount;

  /// No description provided for @instapayConvertFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to convert order to cash'**
  String get instapayConvertFailed;

  /// No description provided for @instapayConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm payment'**
  String get instapayConfirmFailed;

  /// No description provided for @instapayConfirmSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm InstaPay received'**
  String get instapayConfirmSheetTitle;

  /// No description provided for @instapayAwaitingBadge.
  ///
  /// In en, this message translates to:
  /// **'Awaiting InstaPay'**
  String get instapayAwaitingBadge;

  /// No description provided for @inventoryCountSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting reconciliation'**
  String get inventoryCountSubmitting;

  /// No description provided for @inventoryCountSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Submit reconciliation error'**
  String get inventoryCountSubmitError;

  /// No description provided for @kanbanExitSelection.
  ///
  /// In en, this message translates to:
  /// **'Exit Selection'**
  String get kanbanExitSelection;

  /// No description provided for @kanbanSelectOrders.
  ///
  /// In en, this message translates to:
  /// **'Select Orders'**
  String get kanbanSelectOrders;

  /// No description provided for @kanbanMoveOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Move order'**
  String get kanbanMoveOrderTitle;

  /// No description provided for @kanbanCreateFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Create failed'**
  String get kanbanCreateFailedFallback;

  /// No description provided for @kanbanDeliveryIncomeHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom delivery income for this order. Leave blank to revert to the territory default. This will create an amendment of the order.'**
  String get kanbanDeliveryIncomeHelp;

  /// No description provided for @kanbanCannotAmend.
  ///
  /// In en, this message translates to:
  /// **'This order cannot be amended'**
  String get kanbanCannotAmend;

  /// No description provided for @kanbanDeliveryIncomeReset.
  ///
  /// In en, this message translates to:
  /// **'Delivery income reset to territory default'**
  String get kanbanDeliveryIncomeReset;

  /// No description provided for @kanbanAmendmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Amendment failed'**
  String get kanbanAmendmentFailed;

  /// No description provided for @kanbanShippingNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'shipping cost was not updated. Fix the address territory.'**
  String get kanbanShippingNotUpdated;

  /// No description provided for @leadsNotSuitableBadge.
  ///
  /// In en, this message translates to:
  /// **'Not suitable'**
  String get leadsNotSuitableBadge;

  /// No description provided for @bundleSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bundle Selection'**
  String get bundleSelectionTitle;

  /// No description provided for @bundleUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update Bundle'**
  String get bundleUpdateAction;

  /// No description provided for @bundleAddToCartAction.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get bundleAddToCartAction;

  /// No description provided for @bundleSelectFromGroups.
  ///
  /// In en, this message translates to:
  /// **'Select items from each group below:'**
  String get bundleSelectFromGroups;

  /// No description provided for @bundleCatalogDriftWarning.
  ///
  /// In en, this message translates to:
  /// **'Bundle options may have changed since this order was placed. Please review and confirm your selections.'**
  String get bundleCatalogDriftWarning;

  /// No description provided for @bundleNoItemsInGroup.
  ///
  /// In en, this message translates to:
  /// **'No items available in this group'**
  String get bundleNoItemsInGroup;

  /// No description provided for @bundleUnknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get bundleUnknownItem;

  /// No description provided for @bundleUnknownBundle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Bundle'**
  String get bundleUnknownBundle;

  /// No description provided for @bundleNoItemGroups.
  ///
  /// In en, this message translates to:
  /// **'No item groups found'**
  String get bundleNoItemGroups;

  /// No description provided for @bundleNoItemGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'This bundle has no available item groups'**
  String get bundleNoItemGroupsBody;

  /// No description provided for @posCartPromoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo discount'**
  String get posCartPromoDiscount;

  /// No description provided for @posCartFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get posCartFreeDelivery;

  /// No description provided for @posCartDeliveryAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom delivery amount. Leave blank to restore the territory default.'**
  String get posCartDeliveryAmountHelp;

  /// No description provided for @posCartBundleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Bundle contents could not be loaded. Edit this bundle and reselect items before submitting.'**
  String get posCartBundleLoadFailed;

  /// No description provided for @posCartPromoApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get posCartPromoApplied;

  /// No description provided for @posCartPromoNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Not eligible'**
  String get posCartPromoNotEligible;

  /// No description provided for @posSalesPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Sales Partner'**
  String get posSalesPartnerFallback;

  /// No description provided for @reportsColumnBomCost.
  ///
  /// In en, this message translates to:
  /// **'BOM Cost'**
  String get reportsColumnBomCost;

  /// No description provided for @reportsColumnTimesInBundle.
  ///
  /// In en, this message translates to:
  /// **'Times in Bundle'**
  String get reportsColumnTimesInBundle;

  /// No description provided for @settingsIosWebPushTitle.
  ///
  /// In en, this message translates to:
  /// **'iPhone web push notifications'**
  String get settingsIosWebPushTitle;

  /// No description provided for @settingsIosWebPushBody.
  ///
  /// In en, this message translates to:
  /// **'Install this app to the iPhone Home Screen, then tap Enable Notifications to receive background alerts.'**
  String get settingsIosWebPushBody;

  /// No description provided for @settingsEnablingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enabling notifications...'**
  String get settingsEnablingNotifications;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsNotificationAlerts.
  ///
  /// In en, this message translates to:
  /// **'Notification Alerts'**
  String get settingsNotificationAlerts;

  /// No description provided for @settingsAlarmsMutedAll.
  ///
  /// In en, this message translates to:
  /// **'All order notification alarms are currently muted'**
  String get settingsAlarmsMutedAll;

  /// No description provided for @settingsAlarmsActive.
  ///
  /// In en, this message translates to:
  /// **'Order notification alarms are active'**
  String get settingsAlarmsActive;

  /// No description provided for @settingsAlarmsEnabledDevice.
  ///
  /// In en, this message translates to:
  /// **'Notification alarms enabled on this device'**
  String get settingsAlarmsEnabledDevice;

  /// No description provided for @settingsAlarmsMutedDevice.
  ///
  /// In en, this message translates to:
  /// **'Notification alarms muted on this device'**
  String get settingsAlarmsMutedDevice;

  /// No description provided for @settingsChooseAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Choose the in-app staff alarm sound:'**
  String get settingsChooseAlarmSound;

  /// No description provided for @settingsAlarmSoundNote.
  ///
  /// In en, this message translates to:
  /// **'This sound is used for the in-app staff alarm. Closed-app order notifications use the app order tone.'**
  String get settingsAlarmSoundNote;

  /// No description provided for @settingsProfileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user profile'**
  String get settingsProfileLoadFailed;

  /// No description provided for @shiftUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get shiftUnknownUser;

  /// No description provided for @kanbanDeliveryIncomeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Delivery income updated to {amount}'**
  String kanbanDeliveryIncomeUpdated(String amount);

  /// No description provided for @kanbanAddressNoTerritory.
  ///
  /// In en, this message translates to:
  /// **'Address saved, but \"{city}\" matches no territory — shipping cost was not updated. Fix the address territory.'**
  String kanbanAddressNoTerritory(String city);

  /// No description provided for @reportsColumnComponent.
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get reportsColumnComponent;

  /// No description provided for @leadContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get leadContactsTitle;

  /// No description provided for @leadContactsTitleCount.
  ///
  /// In en, this message translates to:
  /// **'Contacts ({count})'**
  String leadContactsTitleCount(int count);

  /// No description provided for @leadContactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No people recorded yet. Add the owner, the manager, or whoever you meet on a visit.'**
  String get leadContactsEmpty;

  /// No description provided for @leadContactsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get leadContactsAdd;

  /// No description provided for @leadContactsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get leadContactsEdit;

  /// No description provided for @leadContactsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get leadContactsRemove;

  /// No description provided for @leadContactsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove contact?'**
  String get leadContactsRemoveTitle;

  /// No description provided for @leadContactsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this lead?'**
  String leadContactsRemoveBody(String name);

  /// No description provided for @leadContactsMakePrimary.
  ///
  /// In en, this message translates to:
  /// **'Make primary'**
  String get leadContactsMakePrimary;

  /// No description provided for @leadContactsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary contact'**
  String get leadContactsPrimary;

  /// No description provided for @leadContactsPrimaryHint.
  ///
  /// In en, this message translates to:
  /// **'The person to ring first.'**
  String get leadContactsPrimaryHint;

  /// No description provided for @leadContactsSaved.
  ///
  /// In en, this message translates to:
  /// **'Contacts updated'**
  String get leadContactsSaved;

  /// No description provided for @leadContactsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get leadContactsName;

  /// No description provided for @leadContactsRole.
  ///
  /// In en, this message translates to:
  /// **'Role / title'**
  String get leadContactsRole;

  /// No description provided for @leadContactsRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Owner, Manager, Barista…'**
  String get leadContactsRoleHint;

  /// No description provided for @leadContactsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get leadContactsPhone;

  /// No description provided for @leadContactsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get leadContactsEmail;

  /// No description provided for @leadContactsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get leadContactsNotes;

  /// No description provided for @leadContactsPickFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Pick from phone contacts'**
  String get leadContactsPickFromPhone;

  /// No description provided for @leadContactsNeedNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Add a name or a phone number.'**
  String get leadContactsNeedNameOrPhone;

  /// No description provided for @leadContactRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get leadContactRoleOwner;

  /// No description provided for @leadContactRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get leadContactRoleManager;

  /// No description provided for @leadContactRoleShiftManager.
  ///
  /// In en, this message translates to:
  /// **'Shift Manager'**
  String get leadContactRoleShiftManager;

  /// No description provided for @leadContactRoleBarista.
  ///
  /// In en, this message translates to:
  /// **'Barista'**
  String get leadContactRoleBarista;

  /// No description provided for @leadContactRolePurchasing.
  ///
  /// In en, this message translates to:
  /// **'Purchasing'**
  String get leadContactRolePurchasing;

  /// No description provided for @leadContactRoleAccountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get leadContactRoleAccountant;

  /// No description provided for @visitPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit planner'**
  String get visitPlannerTitle;

  /// No description provided for @visitPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Plan a day'**
  String get visitPlanDay;

  /// No description provided for @visitBuildDay.
  ///
  /// In en, this message translates to:
  /// **'Build a day'**
  String get visitBuildDay;

  /// No description provided for @visitRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get visitRouteTitle;

  /// No description provided for @visitRouteFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty route} =1{1 stop} other{{count} stops}}'**
  String visitRouteFallbackTitle(num count);

  /// No description provided for @visitScopeMine.
  ///
  /// In en, this message translates to:
  /// **'My routes'**
  String get visitScopeMine;

  /// No description provided for @visitScopeAll.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'\'s routes'**
  String get visitScopeAll;

  /// No description provided for @visitNoRoutesOnDay.
  ///
  /// In en, this message translates to:
  /// **'No route planned for this day.'**
  String get visitNoRoutesOnDay;

  /// No description provided for @visitPlansLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load routes. Pull down to try again.'**
  String get visitPlansLoadFailed;

  /// No description provided for @visitStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stops} =1{1 stop} other{{count} stops}}'**
  String visitStopsCount(num count);

  /// No description provided for @visitDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String visitDistanceKm(String km);

  /// No description provided for @visitDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String visitDurationMinutes(int minutes);

  /// No description provided for @visitDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {duration}'**
  String visitDayTotal(String duration);

  /// No description provided for @visitLeg.
  ///
  /// In en, this message translates to:
  /// **'{km} km · {minutes} min'**
  String visitLeg(String km, int minutes);

  /// No description provided for @visitNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get visitNextStop;

  /// No description provided for @visitGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get visitGo;

  /// No description provided for @visitNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get visitNavigate;

  /// No description provided for @visitCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get visitCall;

  /// No description provided for @visitCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get visitCheckIn;

  /// No description provided for @visitSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get visitSkip;

  /// No description provided for @visitReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get visitReopen;

  /// No description provided for @visitPin.
  ///
  /// In en, this message translates to:
  /// **'Pin to this position'**
  String get visitPin;

  /// No description provided for @visitUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get visitUnpin;

  /// No description provided for @visitRemoveStop.
  ///
  /// In en, this message translates to:
  /// **'Remove from route'**
  String get visitRemoveStop;

  /// No description provided for @visitOptimise.
  ///
  /// In en, this message translates to:
  /// **'Optimise route'**
  String get visitOptimise;

  /// No description provided for @visitOptimiseFromHere.
  ///
  /// In en, this message translates to:
  /// **'Optimise from where I am'**
  String get visitOptimiseFromHere;

  /// No description provided for @visitNavigateWholeRoute.
  ///
  /// In en, this message translates to:
  /// **'Open whole route in Maps'**
  String get visitNavigateWholeRoute;

  /// No description provided for @visitDeleteRoute.
  ///
  /// In en, this message translates to:
  /// **'Delete route'**
  String get visitDeleteRoute;

  /// No description provided for @visitDeleteRouteConfirm.
  ///
  /// In en, this message translates to:
  /// **'The route is removed. Visits already recorded stay in the diary.'**
  String get visitDeleteRouteConfirm;

  /// No description provided for @visitNoStops.
  ///
  /// In en, this message translates to:
  /// **'This route has no stops yet.'**
  String get visitNoStops;

  /// No description provided for @visitLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location.'**
  String get visitLocationUnavailable;

  /// No description provided for @visitRouteTruncated.
  ///
  /// In en, this message translates to:
  /// **'Maps takes {handed} of {total} stops at once. Navigate stop by stop for the rest.'**
  String visitRouteTruncated(int handed, int total);

  /// No description provided for @visitOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get visitOutcome;

  /// No description provided for @visitLogJourneyNote.
  ///
  /// In en, this message translates to:
  /// **'Log a journey note'**
  String get visitLogJourneyNote;

  /// No description provided for @visitLogJourneyNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Records the visit on the lead\'\'s diary and drives its follow-up reminder.'**
  String get visitLogJourneyNoteHint;

  /// No description provided for @visitNoteWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get visitNoteWhatHappened;

  /// No description provided for @visitNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next action'**
  String get visitNextAction;

  /// No description provided for @visitNextActionDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get visitNextActionDate;

  /// No description provided for @visitMarkVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visitMarkVisited;

  /// No description provided for @visitSuggestDay.
  ///
  /// In en, this message translates to:
  /// **'Plan my day'**
  String get visitSuggestDay;

  /// No description provided for @visitMaxStops.
  ///
  /// In en, this message translates to:
  /// **'Max stops'**
  String get visitMaxStops;

  /// No description provided for @visitDayHours.
  ///
  /// In en, this message translates to:
  /// **'Day (hours)'**
  String get visitDayHours;

  /// No description provided for @visitStartFromMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Start from my location'**
  String get visitStartFromMyLocation;

  /// No description provided for @visitStartFromMyLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Off plans around the best cluster anywhere.'**
  String get visitStartFromMyLocationHint;

  /// No description provided for @visitIncludeCustomers.
  ///
  /// In en, this message translates to:
  /// **'Include existing clients'**
  String get visitIncludeCustomers;

  /// No description provided for @visitIncludeCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Check-ups on active accounts along the way.'**
  String get visitIncludeCustomersHint;

  /// No description provided for @visitCandidateDoors.
  ///
  /// In en, this message translates to:
  /// **'Doors worth visiting'**
  String get visitCandidateDoors;

  /// No description provided for @visitClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get visitClearSelection;

  /// No description provided for @visitNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches those filters.'**
  String get visitNoCandidates;

  /// No description provided for @visitTargetsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load candidates.'**
  String get visitTargetsLoadFailed;

  /// No description provided for @visitProposedDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop proposed} other{{count} stops proposed}}'**
  String visitProposedDay(num count);

  /// No description provided for @visitConsidered.
  ///
  /// In en, this message translates to:
  /// **'Weighed {count} doors'**
  String visitConsidered(int count);

  /// No description provided for @visitDroppedForTime.
  ///
  /// In en, this message translates to:
  /// **'{count} dropped to fit the day'**
  String visitDroppedForTime(int count);

  /// No description provided for @visitSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop selected} other{{count} stops selected}}'**
  String visitSelectedCount(num count);

  /// No description provided for @visitCreateRoute.
  ///
  /// In en, this message translates to:
  /// **'Create route'**
  String get visitCreateRoute;

  /// No description provided for @visitEngineRoadExplained.
  ///
  /// In en, this message translates to:
  /// **'Distances and times come from the road network.'**
  String get visitEngineRoadExplained;

  /// No description provided for @visitEngineEstimateExplained.
  ///
  /// In en, this message translates to:
  /// **'Distances are straight-line estimates adjusted for city driving. The visiting order is still solved properly; the minutes are approximate.'**
  String get visitEngineEstimateExplained;

  /// No description provided for @visitEngineRecheck.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get visitEngineRecheck;

  /// No description provided for @materialsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Price list & materials'**
  String get materialsSectionTitle;

  /// No description provided for @materialsSendCta.
  ///
  /// In en, this message translates to:
  /// **'Send price list'**
  String get materialsSendCta;

  /// No description provided for @materialsSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send materials'**
  String get materialsSendTitle;

  /// No description provided for @materialsRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get materialsRecipientLabel;

  /// No description provided for @materialsNoRecipient.
  ///
  /// In en, this message translates to:
  /// **'No contacts on this lead yet. Add one first, or send anyway and pick the chat in WhatsApp.'**
  String get materialsNoRecipient;

  /// No description provided for @materialsPickLabel.
  ///
  /// In en, this message translates to:
  /// **'What to send'**
  String get materialsPickLabel;

  /// No description provided for @materialsPreparing.
  ///
  /// In en, this message translates to:
  /// **'still preparing'**
  String get materialsPreparing;

  /// No description provided for @materialsMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get materialsMessageLabel;

  /// No description provided for @materialsSending.
  ///
  /// In en, this message translates to:
  /// **'Creating link…'**
  String get materialsSending;

  /// No description provided for @materialsLinkReady.
  ///
  /// In en, this message translates to:
  /// **'Link created and logged on the lead.'**
  String get materialsLinkReady;

  /// No description provided for @materialsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get materialsCopyLink;

  /// No description provided for @materialsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get materialsLinkCopied;

  /// No description provided for @materialsLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials in the library yet. Ask a manager to upload the price list.'**
  String get materialsLibraryEmpty;

  /// No description provided for @materialsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get materialsRetry;

  /// No description provided for @materialsNothingSent.
  ///
  /// In en, this message translates to:
  /// **'Nothing sent yet.'**
  String get materialsNothingSent;

  /// No description provided for @materialsHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not load what was sent before.'**
  String get materialsHistoryUnavailable;

  /// No description provided for @materialsNotOpenedYet.
  ///
  /// In en, this message translates to:
  /// **'Not opened yet'**
  String get materialsNotOpenedYet;

  /// No description provided for @materialsPageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String materialsPageCount(Object count);

  /// No description provided for @materialsStillPreparing.
  ///
  /// In en, this message translates to:
  /// **'{count} of these files are still being prepared. The link works now; the first open may take a few seconds.'**
  String materialsStillPreparing(Object count);

  /// No description provided for @materialsOpenedCount.
  ///
  /// In en, this message translates to:
  /// **'Opened {count}×'**
  String materialsOpenedCount(Object count);

  /// No description provided for @materialsSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the link: {error}'**
  String materialsSendFailed(Object error);

  /// No description provided for @materialsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the material library: {error}'**
  String materialsLoadFailed(Object error);

  /// No description provided for @materialsLinkPlaceholderHint.
  ///
  /// In en, this message translates to:
  /// **'Leave {token} where you want the link; it is replaced automatically when you send.'**
  String materialsLinkPlaceholderHint(Object token);

  /// Title of the non-dismissible force-update screen
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get appUpdateRequiredTitle;

  /// Body of the non-dismissible force-update screen
  ///
  /// In en, this message translates to:
  /// **'This version of Jarz POS is out of date and can no longer be used. Install the latest version to continue.'**
  String get appUpdateRequiredBody;

  /// Installed vs required build numbers on the force-update screen
  ///
  /// In en, this message translates to:
  /// **'Installed build {current} · Required build {minimum}'**
  String appUpdateBuildLine(Object current, Object minimum);

  /// Opens the APK download page
  ///
  /// In en, this message translates to:
  /// **'Download Update'**
  String get appUpdateDownloadButton;

  /// Re-runs the version check after installing
  ///
  /// In en, this message translates to:
  /// **'I have installed it — retry'**
  String get appUpdateRecheckButton;

  /// Shown when the download URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the download page. Ask your manager for the install link.'**
  String get appUpdateOpenFailed;

  /// Explains the Android unknown-sources install prompt
  ///
  /// In en, this message translates to:
  /// **'Your browser will ask permission to install apps from this source. Allow it, then open the downloaded file to install.'**
  String get appUpdateInstallHint;

  /// Dismissible banner for an optional update
  ///
  /// In en, this message translates to:
  /// **'A new version is available — tap to download.'**
  String get appUpdateAvailableBanner;

  /// No description provided for @materialsZoomedIn.
  ///
  /// In en, this message translates to:
  /// **'zoomed in'**
  String get materialsZoomedIn;

  /// No description provided for @materialsDownloadedFile.
  ///
  /// In en, this message translates to:
  /// **'downloaded'**
  String get materialsDownloadedFile;

  /// No description provided for @materialsReadFor.
  ///
  /// In en, this message translates to:
  /// **'Read for {time}'**
  String materialsReadFor(Object time);

  /// No description provided for @materialsPagesRead.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String materialsPagesRead(Object count);

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @visitAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to a route'**
  String get visitAddToRoute;

  /// No description provided for @visitAddStop.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get visitAddStop;

  /// No description provided for @visitAddedToRoute.
  ///
  /// In en, this message translates to:
  /// **'Added to the route'**
  String get visitAddedToRoute;

  /// No description provided for @visitOpenRoute.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get visitOpenRoute;

  /// No description provided for @visitWhichDoor.
  ///
  /// In en, this message translates to:
  /// **'Which branch? ({count} located)'**
  String visitWhichDoor(int count);

  /// No description provided for @visitWhichDay.
  ///
  /// In en, this message translates to:
  /// **'Which day'**
  String get visitWhichDay;

  /// No description provided for @visitNewRoute.
  ///
  /// In en, this message translates to:
  /// **'New route…'**
  String get visitNewRoute;

  /// No description provided for @visitNewRouteOn.
  ///
  /// In en, this message translates to:
  /// **'New route on {date}'**
  String visitNewRouteOn(String date);

  /// No description provided for @visitNoUpcomingRoutes.
  ///
  /// In en, this message translates to:
  /// **'No upcoming routes yet.'**
  String get visitNoUpcomingRoutes;

  /// No description provided for @visitNoDoorsToRoute.
  ///
  /// In en, this message translates to:
  /// **'Nothing here can be routed to.'**
  String get visitNoDoorsToRoute;

  /// No description provided for @visitNoDoorsToRouteHint.
  ///
  /// In en, this message translates to:
  /// **'This record has no branch with a location on it. Add a pin first and it becomes a stop.'**
  String get visitNoDoorsToRouteHint;

  /// No description provided for @visitFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get visitFilters;

  /// No description provided for @visitClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get visitClearFilters;

  /// No description provided for @visitFilterTier.
  ///
  /// In en, this message translates to:
  /// **'Fit tier'**
  String get visitFilterTier;

  /// No description provided for @visitFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get visitFilterCategory;

  /// No description provided for @visitFilterArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get visitFilterArea;

  /// No description provided for @visitFilterMinFit.
  ///
  /// In en, this message translates to:
  /// **'Minimum fit score: {score}'**
  String visitFilterMinFit(int score);

  /// No description provided for @visitFilterSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty only'**
  String get visitFilterSpecialty;

  /// No description provided for @visitFilterNeverVisited.
  ///
  /// In en, this message translates to:
  /// **'Never visited only'**
  String get visitFilterNeverVisited;

  /// No description provided for @visitFilterNeverVisitedHint.
  ///
  /// In en, this message translates to:
  /// **'Doors nobody has walked into yet.'**
  String get visitFilterNeverVisitedHint;

  /// No description provided for @visitEmptyDayHint.
  ///
  /// In en, this message translates to:
  /// **'Pick doors below, or tap Plan my day. The route builds as you choose.'**
  String get visitEmptyDayHint;

  /// No description provided for @visitCostingDay.
  ///
  /// In en, this message translates to:
  /// **'Working out the route…'**
  String get visitCostingDay;

  /// No description provided for @visitManualOrderNote.
  ///
  /// In en, this message translates to:
  /// **'Your order — tap Optimise to hand it back.'**
  String get visitManualOrderNote;

  /// No description provided for @visitSkippedNoPin.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 door has no location and is not on the route} other{{count} doors have no location and are not on the route}}'**
  String visitSkippedNoPin(num count);

  /// No description provided for @visitSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get visitSaveDraft;

  /// No description provided for @shiftCourierCarryTitle.
  ///
  /// In en, this message translates to:
  /// **'Money still with couriers'**
  String get shiftCourierCarryTitle;

  /// No description provided for @shiftCourierCarryBody.
  ///
  /// In en, this message translates to:
  /// **'{transactions} order(s) worth {amount} are still out with {couriers} courier(s). Confirm each one, or settle it now.'**
  String shiftCourierCarryBody(int transactions, Object amount, int couriers);

  /// No description provided for @shiftCourierCarryHint.
  ///
  /// In en, this message translates to:
  /// **'Tick every order whose cash is still with the courier. Anything you leave unticked must be settled before you can close.'**
  String get shiftCourierCarryHint;

  /// No description provided for @shiftCourierCarryConfirmAll.
  ///
  /// In en, this message translates to:
  /// **'Confirm all'**
  String get shiftCourierCarryConfirmAll;

  /// No description provided for @shiftCourierCarryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get shiftCourierCarryClearAll;

  /// No description provided for @shiftCourierCarrySettleNow.
  ///
  /// In en, this message translates to:
  /// **'Settle a courier now'**
  String get shiftCourierCarrySettleNow;

  /// No description provided for @shiftCourierCarryConfirmedOf.
  ///
  /// In en, this message translates to:
  /// **'{confirmed} of {total} confirmed'**
  String shiftCourierCarryConfirmedOf(int confirmed, int total);

  /// No description provided for @shiftCourierCarryRowLabel.
  ///
  /// In en, this message translates to:
  /// **'{invoice} — {customer}'**
  String shiftCourierCarryRowLabel(Object invoice, Object customer);

  /// No description provided for @shiftCourierCarryCheckboxLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash still with the courier'**
  String get shiftCourierCarryCheckboxLabel;

  /// No description provided for @shiftCourierCarryCarriedBadge.
  ///
  /// In en, this message translates to:
  /// **'Carried {count} shift(s) · {days} day(s) out'**
  String shiftCourierCarryCarriedBadge(int count, int days);

  /// No description provided for @shiftCourierCarryUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm every order still out with a courier, or settle it, before closing.'**
  String get shiftCourierCarryUnconfirmed;

  /// No description provided for @shiftCourierCarriedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} order(s) worth {amount} left the shift still with couriers. They stay open until settled.'**
  String shiftCourierCarriedSummary(int count, Object amount);

  /// No description provided for @shiftMonitorCarriedOut.
  ///
  /// In en, this message translates to:
  /// **'Carried out: {count} · {amount}'**
  String shiftMonitorCarriedOut(int count, Object amount);

  /// No description provided for @shiftMonitorSettledIn.
  ///
  /// In en, this message translates to:
  /// **'Collected from earlier shifts: {count} · {amount}'**
  String shiftMonitorSettledIn(int count, Object amount);

  /// No description provided for @shiftMonitorCourierOutstandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Out with couriers now'**
  String get shiftMonitorCourierOutstandingTitle;

  /// No description provided for @shiftMonitorCourierOutstandingSummary.
  ///
  /// In en, this message translates to:
  /// **'{amount} across {transactions} order(s); oldest {days} day(s) out.'**
  String shiftMonitorCourierOutstandingSummary(
    Object amount,
    int transactions,
    int days,
  );

  /// No description provided for @shiftMonitorCourierOutstandingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No courier is holding cash right now.'**
  String get shiftMonitorCourierOutstandingEmpty;

  /// No description provided for @shiftMonitorCourierRow.
  ///
  /// In en, this message translates to:
  /// **'{name} · {branch}'**
  String shiftMonitorCourierRow(Object name, Object branch);

  /// No description provided for @shiftMonitorCourierRowDetail.
  ///
  /// In en, this message translates to:
  /// **'{count} order(s) · {amount} · oldest {days} day(s)'**
  String shiftMonitorCourierRowDetail(int count, Object amount, int days);

  /// No description provided for @expensesAdvanceTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesAdvanceTabExpenses;

  /// No description provided for @expensesAdvanceTabAdvances.
  ///
  /// In en, this message translates to:
  /// **'Employee Advances'**
  String get expensesAdvanceTabAdvances;

  /// No description provided for @expensesAdvanceNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New Advance'**
  String get expensesAdvanceNewRequest;

  /// No description provided for @expensesAdvanceFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Employee Advance'**
  String get expensesAdvanceFormTitle;

  /// No description provided for @expensesAdvanceEmployeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get expensesAdvanceEmployeeLabel;

  /// No description provided for @expensesAdvanceEmployeeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an employee'**
  String get expensesAdvanceEmployeeRequired;

  /// No description provided for @expensesAdvanceEmployeeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose an employee'**
  String get expensesAdvanceEmployeeHint;

  /// No description provided for @expensesAdvanceEmployeePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose employee'**
  String get expensesAdvanceEmployeePickerTitle;

  /// No description provided for @expensesAdvanceEmployeeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, branch or department'**
  String get expensesAdvanceEmployeeSearchHint;

  /// No description provided for @expensesAdvanceEmployeeNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No employees match that search'**
  String get expensesAdvanceEmployeeNoMatches;

  /// No description provided for @expensesAdvanceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance amount'**
  String get expensesAdvanceAmountLabel;

  /// No description provided for @expensesAdvanceAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get expensesAdvanceAmountInvalid;

  /// No description provided for @expensesAdvancePurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get expensesAdvancePurposeLabel;

  /// No description provided for @expensesAdvancePurposeRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe what the advance is for'**
  String get expensesAdvancePurposeRequired;

  /// No description provided for @expensesAdvancePayFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get expensesAdvancePayFromLabel;

  /// No description provided for @expensesAdvancePaymentSourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a payment source'**
  String get expensesAdvancePaymentSourceRequired;

  /// No description provided for @expensesAdvanceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance date (optional)'**
  String get expensesAdvanceDateLabel;

  /// No description provided for @expensesAdvanceDateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get expensesAdvanceDateNotSet;

  /// No description provided for @expensesAdvanceDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get expensesAdvanceDateClear;

  /// No description provided for @expensesAdvanceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get expensesAdvanceSubmit;

  /// No description provided for @expensesAdvanceNoOptions.
  ///
  /// In en, this message translates to:
  /// **'Advances cannot be requested until an employee list and a payment source are available.'**
  String get expensesAdvanceNoOptions;

  /// No description provided for @expensesAdvanceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Advance request submitted for approval'**
  String get expensesAdvanceSubmitted;

  /// No description provided for @expensesAdvanceMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get expensesAdvanceMonthLabel;

  /// No description provided for @expensesAdvanceStatusFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get expensesAdvanceStatusFilterLabel;

  /// No description provided for @expensesAdvanceStatusFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get expensesAdvanceStatusFilterAll;

  /// No description provided for @expensesAdvanceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No employee advances for this month.'**
  String get expensesAdvanceEmptyTitle;

  /// No description provided for @expensesAdvanceEmptyApproverBody.
  ///
  /// In en, this message translates to:
  /// **'Requests raised by line managers will appear here for approval.'**
  String get expensesAdvanceEmptyApproverBody;

  /// No description provided for @expensesAdvanceEmptyRequesterBody.
  ///
  /// In en, this message translates to:
  /// **'Use the New Advance button to request cash for an employee.'**
  String get expensesAdvanceEmptyRequesterBody;

  /// No description provided for @expensesAdvanceEmptyReadOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to request or approve advances.'**
  String get expensesAdvanceEmptyReadOnlyBody;

  /// No description provided for @expensesAdvanceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee advances are unavailable'**
  String get expensesAdvanceUnavailableTitle;

  /// No description provided for @expensesAdvanceUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'The HR module is not installed on this site, so advances cannot be requested here.'**
  String get expensesAdvanceUnavailableBody;

  /// No description provided for @expensesAdvanceSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get expensesAdvanceSummaryTotal;

  /// No description provided for @expensesAdvanceSummaryPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get expensesAdvanceSummaryPending;

  /// No description provided for @expensesAdvanceSummaryApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get expensesAdvanceSummaryApproved;

  /// No description provided for @expensesAdvanceSummaryOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get expensesAdvanceSummaryOutstanding;

  /// No description provided for @expensesAdvanceSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} request(s)'**
  String expensesAdvanceSummaryCount(int count);

  /// No description provided for @expensesAdvanceSummaryPendingValue.
  ///
  /// In en, this message translates to:
  /// **'{count} | {amount}'**
  String expensesAdvanceSummaryPendingValue(int count, Object amount);

  /// No description provided for @expensesAdvanceApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve & pay'**
  String get expensesAdvanceApprove;

  /// No description provided for @expensesAdvanceReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get expensesAdvanceReject;

  /// No description provided for @expensesAdvanceApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve advance?'**
  String get expensesAdvanceApproveTitle;

  /// No description provided for @expensesAdvanceApproveBody.
  ///
  /// In en, this message translates to:
  /// **'Approving pays {amount} to {employee} right now, out of {source}. The cash leaves that account immediately and cannot be undone from this screen.'**
  String expensesAdvanceApproveBody(
    Object amount,
    Object employee,
    Object source,
  );

  /// No description provided for @expensesAdvanceApproveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve & pay now'**
  String get expensesAdvanceApproveConfirm;

  /// No description provided for @expensesAdvanceApproved.
  ///
  /// In en, this message translates to:
  /// **'Advance approved and paid'**
  String get expensesAdvanceApproved;

  /// No description provided for @expensesAdvanceApprovedWithEntry.
  ///
  /// In en, this message translates to:
  /// **'Advance approved and paid · {entry}'**
  String expensesAdvanceApprovedWithEntry(Object entry);

  /// No description provided for @expensesAdvanceRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject advance request?'**
  String get expensesAdvanceRejectTitle;

  /// No description provided for @expensesAdvanceRejectHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the requester why this was rejected'**
  String get expensesAdvanceRejectHint;

  /// No description provided for @expensesAdvanceRejectReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required'**
  String get expensesAdvanceRejectReasonRequired;

  /// No description provided for @expensesAdvanceRejected.
  ///
  /// In en, this message translates to:
  /// **'Advance request rejected'**
  String get expensesAdvanceRejected;

  /// No description provided for @expensesAdvanceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get expensesAdvanceIdLabel;

  /// No description provided for @expensesAdvancePostingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance date'**
  String get expensesAdvancePostingDateLabel;

  /// No description provided for @expensesAdvanceBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get expensesAdvanceBranchLabel;

  /// No description provided for @expensesAdvancePayingAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Paying account'**
  String get expensesAdvancePayingAccountLabel;

  /// No description provided for @expensesAdvancePaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get expensesAdvancePaidLabel;

  /// No description provided for @expensesAdvanceClaimedLabel.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get expensesAdvanceClaimedLabel;

  /// No description provided for @expensesAdvanceReturnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get expensesAdvanceReturnedLabel;

  /// No description provided for @expensesAdvanceBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance'**
  String get expensesAdvanceBalanceLabel;

  /// No description provided for @expensesAdvanceRequestedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get expensesAdvanceRequestedByLabel;

  /// No description provided for @expensesAdvanceApprovedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved by'**
  String get expensesAdvanceApprovedByLabel;

  /// No description provided for @expensesAdvanceApprovedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved on'**
  String get expensesAdvanceApprovedOnLabel;

  /// No description provided for @expensesAdvancePaymentEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Entry'**
  String get expensesAdvancePaymentEntryLabel;

  /// No description provided for @expensesAdvanceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get expensesAdvanceStatusDraft;

  /// No description provided for @expensesAdvanceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get expensesAdvanceStatusPaid;

  /// No description provided for @expensesAdvanceStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get expensesAdvanceStatusPartiallyPaid;

  /// No description provided for @expensesAdvanceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get expensesAdvanceStatusUnpaid;

  /// No description provided for @expensesAdvanceStatusClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get expensesAdvanceStatusClaimed;

  /// No description provided for @expensesAdvanceStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get expensesAdvanceStatusReturned;

  /// No description provided for @expensesAdvanceStatusPartlyClaimedAndReturned.
  ///
  /// In en, this message translates to:
  /// **'Partly Claimed and Returned'**
  String get expensesAdvanceStatusPartlyClaimedAndReturned;

  /// No description provided for @expensesAdvanceStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get expensesAdvanceStatusCancelled;

  /// No description provided for @managerEmployeeLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Ledger'**
  String get managerEmployeeLedgerTitle;

  /// No description provided for @managerEmployeeLedgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What each employee owes: cash advances plus unpaid employee orders'**
  String get managerEmployeeLedgerSubtitle;

  /// No description provided for @managerEmployeeLedgerPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get managerEmployeeLedgerPeriodLabel;

  /// No description provided for @managerEmployeeLedgerWindow30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get managerEmployeeLedgerWindow30;

  /// No description provided for @managerEmployeeLedgerWindow90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get managerEmployeeLedgerWindow90;

  /// No description provided for @managerEmployeeLedgerWindow180.
  ///
  /// In en, this message translates to:
  /// **'Last 180 days'**
  String get managerEmployeeLedgerWindow180;

  /// No description provided for @managerEmployeeLedgerWindow365.
  ///
  /// In en, this message translates to:
  /// **'Last 365 days'**
  String get managerEmployeeLedgerWindow365;

  /// No description provided for @managerEmployeeLedgerActivityRange.
  ///
  /// In en, this message translates to:
  /// **'Listed activity: {from} to {to}'**
  String managerEmployeeLedgerActivityRange(Object from, Object to);

  /// No description provided for @managerEmployeeLedgerActivityInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Activity in this period'**
  String get managerEmployeeLedgerActivityInPeriod;

  /// No description provided for @managerEmployeeLedgerTotalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total outstanding in this period'**
  String get managerEmployeeLedgerTotalOutstanding;

  /// No description provided for @managerEmployeeLedgerTotalOutstandingAllTime.
  ///
  /// In en, this message translates to:
  /// **'Total outstanding (all time)'**
  String get managerEmployeeLedgerTotalOutstandingAllTime;

  /// No description provided for @managerEmployeeLedgerAllTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Every open item, whatever its age. The period below only controls which lines are listed.'**
  String get managerEmployeeLedgerAllTimeHint;

  /// No description provided for @managerEmployeeLedgerAdvancesLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash advances'**
  String get managerEmployeeLedgerAdvancesLabel;

  /// No description provided for @managerEmployeeLedgerOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid orders'**
  String get managerEmployeeLedgerOrdersLabel;

  /// No description provided for @managerEmployeeLedgerAdvanceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No advances} =1{1 advance} other{{count} advances}}'**
  String managerEmployeeLedgerAdvanceCount(int count);

  /// No description provided for @managerEmployeeLedgerOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 order} other{{count} orders}}'**
  String managerEmployeeLedgerOrderCount(int count);

  /// No description provided for @managerEmployeeLedgerEmployeeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody owes anything} =1{1 person owes money} other{{count} people owe money}}'**
  String managerEmployeeLedgerEmployeeCount(int count);

  /// No description provided for @managerEmployeeLedgerSplit.
  ///
  /// In en, this message translates to:
  /// **'Advances {advances} • Orders {orders}'**
  String managerEmployeeLedgerSplit(Object advances, Object orders);

  /// No description provided for @managerEmployeeLedgerOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get managerEmployeeLedgerOutstandingLabel;

  /// No description provided for @managerEmployeeLedgerOrderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Order total'**
  String get managerEmployeeLedgerOrderTotalLabel;

  /// No description provided for @managerEmployeeLedgerAdvanceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get managerEmployeeLedgerAdvanceAmountLabel;

  /// No description provided for @managerEmployeeLedgerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing outstanding, and no activity in this period'**
  String get managerEmployeeLedgerEmpty;

  /// No description provided for @managerEmployeeLedgerNoAdvances.
  ///
  /// In en, this message translates to:
  /// **'No cash advances in this period'**
  String get managerEmployeeLedgerNoAdvances;

  /// No description provided for @managerEmployeeLedgerNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No unpaid orders in this period'**
  String get managerEmployeeLedgerNoOrders;

  /// No description provided for @managerEmployeeLedgerBalancePredatesPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing listed in this period. The balance above is older than that, so widen the period to see the lines behind it.'**
  String get managerEmployeeLedgerBalancePredatesPeriod;

  /// No description provided for @managerEmployeeLedgerUnmatched.
  ///
  /// In en, this message translates to:
  /// **'No employee record'**
  String get managerEmployeeLedgerUnmatched;

  /// No description provided for @managerEmployeeLedgerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load employee ledger'**
  String get managerEmployeeLedgerLoadFailed;

  /// No description provided for @managerEmployeeLedgerNoticeNoBranchAssigned.
  ///
  /// In en, this message translates to:
  /// **'You have no branch assigned, so there is nothing to show here yet.'**
  String get managerEmployeeLedgerNoticeNoBranchAssigned;

  /// No description provided for @managerEmployeeLedgerNoticeBranchNotPermitted.
  ///
  /// In en, this message translates to:
  /// **'You cannot view that branch, so it was ignored.'**
  String get managerEmployeeLedgerNoticeBranchNotPermitted;

  /// No description provided for @managerEmployeeLedgerNoticeHrmsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'HRMS is not installed, so cash advances are not tracked. Unpaid employee orders are still shown.'**
  String get managerEmployeeLedgerNoticeHrmsUnavailable;

  /// No description provided for @managerEmployeeLedgerNoticeResultsTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first results are shown. Narrow the branch or the period to see the rest.'**
  String get managerEmployeeLedgerNoticeResultsTruncated;

  /// Kanban column: order received, not started yet
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get kanbanStateReceived;

  /// Kanban column: order being prepared
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get kanbanStateInProgress;

  /// Kanban column: order packed and ready to dispatch
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get kanbanStateReady;

  /// Cancel reason option
  ///
  /// In en, this message translates to:
  /// **'Customer requested cancellation'**
  String get cancelReasonCustomerRequested;

  /// Cancel reason option
  ///
  /// In en, this message translates to:
  /// **'Order created in error / duplicate'**
  String get cancelReasonCreatedInError;

  /// Cancel reason option
  ///
  /// In en, this message translates to:
  /// **'Inventory unavailable'**
  String get cancelReasonInventoryUnavailable;

  /// Cancel reason option
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get cancelReasonPaymentIssue;

  /// Cancel reason option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOther;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Out of Business'**
  String get notSuitableReasonOutOfBusiness;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Wrong Category'**
  String get notSuitableReasonWrongCategory;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Too Small'**
  String get notSuitableReasonTooSmall;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'No Contact Info'**
  String get notSuitableReasonNoContactInfo;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get notSuitableReasonUnreachable;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Already Supplied'**
  String get notSuitableReasonAlreadySupplied;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Price Mismatch'**
  String get notSuitableReasonPriceMismatch;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Outside Delivery Area'**
  String get notSuitableReasonOutsideDeliveryArea;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get notSuitableReasonDuplicate;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get notSuitableReasonNotInterested;

  /// Lead disqualify reason
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get notSuitableReasonOther;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Walk In'**
  String get leadSourceWalkIn;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get leadSourceReference;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get leadSourceCampaign;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Existing Customer'**
  String get leadSourceExistingCustomer;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Cold Call'**
  String get leadSourceColdCall;

  /// Lead source option
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get leadSourceSocialMedia;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get customerSegmentChampion;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get customerSegmentLoyal;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Potential Loyalist'**
  String get customerSegmentPotentialLoyalist;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get customerSegmentNewCustomer;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get customerSegmentAtRisk;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t Lose Them'**
  String get customerSegmentCantLoseThem;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get customerSegmentLost;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'One-Time'**
  String get customerSegmentOneTime;

  /// RFM customer segment
  ///
  /// In en, this message translates to:
  /// **'Unclassified'**
  String get customerSegmentUnclassified;

  /// Item sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'Accelerating'**
  String get velocityTrendAccelerating;

  /// Item sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get velocityTrendStable;

  /// Item sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get velocityTrendDeclining;

  /// Item sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get velocityTrendNewItem;

  /// Item sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'No Sales'**
  String get velocityTrendNoSales;

  /// Visit plan or stop status
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get visitStatusPlanned;

  /// Visit plan status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get visitStatusInProgress;

  /// Visit stop status
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visitStatusVisited;

  /// Visit stop status
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get visitStatusSkipped;

  /// Sales material type
  ///
  /// In en, this message translates to:
  /// **'Price List'**
  String get materialTypePriceList;

  /// Sales material type
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get materialTypeProductPhotos;

  /// Sales material type
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get materialTypeCatalog;

  /// Sales material type
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get materialTypeCertificate;

  /// Sales material type
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get materialTypeOther;

  /// Short axis label for the Lead pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get b2bStageShortLead;

  /// Short axis label for the Qualify pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Qual'**
  String get b2bStageShortQualify;

  /// Short axis label for the Sample pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Samp'**
  String get b2bStageShortSample;

  /// Short axis label for the Approved pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Appr'**
  String get b2bStageShortApproved;

  /// Short axis label for the Trial pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get b2bStageShortTrial;

  /// Short axis label for the Check-up pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Chk'**
  String get b2bStageShortCheckup;

  /// Short axis label for the Active pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Actv'**
  String get b2bStageShortActive;

  /// Short axis label for the Lost/On-hold pipeline stage
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get b2bStageShortLostOnHold;

  /// Payment receipt status: the collected method was changed
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get statusChanged;

  /// Courier / sales-partner transaction status
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get statusSettled;

  /// Courier / sales-partner transaction status
  ///
  /// In en, this message translates to:
  /// **'Unsettled'**
  String get statusUnsettled;

  /// Generic accepted status
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// Generic active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Generic paused status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// Generic ended status
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusEnded;

  /// Generic closed status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// Generic in-progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Report table column header
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get reportsColumnItem;

  /// Report column: 30-day sales velocity
  ///
  /// In en, this message translates to:
  /// **'Vel 30d'**
  String get reportsColumnVelocity30d;

  /// Report column: 60-day sales velocity
  ///
  /// In en, this message translates to:
  /// **'Vel 60d'**
  String get reportsColumnVelocity60d;

  /// Report column: sales-velocity trend
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get reportsColumnTrend;

  /// Report column: current stock on hand
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get reportsColumnStock;

  /// Report column: days of cover
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get reportsColumnCover;

  /// Report column: quantity sold
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get reportsColumnSold;

  /// Report column: revenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get reportsColumnRevenue;

  /// Report column: sales velocity
  ///
  /// In en, this message translates to:
  /// **'Velocity'**
  String get reportsColumnVelocity;

  /// No description provided for @menuShiftDistribution.
  ///
  /// In en, this message translates to:
  /// **'Shift Distribution'**
  String get menuShiftDistribution;

  /// No description provided for @rosterTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Distribution'**
  String get rosterTitle;

  /// No description provided for @rosterAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Shift distribution is for managers and line managers only.'**
  String get rosterAccessDenied;

  /// No description provided for @rosterHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Hours & overtime'**
  String get rosterHoursTitle;

  /// No description provided for @rosterHoursBasis.
  ///
  /// In en, this message translates to:
  /// **'Rostered hours — what people were scheduled to work. Overtime is credited at each person\'\'s rate.'**
  String get rosterHoursBasis;

  /// No description provided for @rosterPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get rosterPreviousMonth;

  /// No description provided for @rosterNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get rosterNextMonth;

  /// No description provided for @rosterAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get rosterAllBranches;

  /// No description provided for @rosterEmployeeColumn.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get rosterEmployeeColumn;

  /// No description provided for @rosterHrmsMissing.
  ///
  /// In en, this message translates to:
  /// **'HRMS is not installed on this site, so there is no roster to show.'**
  String get rosterHrmsMissing;

  /// No description provided for @rosterNobodyRostered.
  ///
  /// In en, this message translates to:
  /// **'Nobody is rostered for this month yet.'**
  String get rosterNobodyRostered;

  /// No description provided for @rosterScopeUnconfigured.
  ///
  /// In en, this message translates to:
  /// **'No branches are linked to your POS profiles yet, so there is nobody to show. Ask an administrator to set the HR Shift Location on your POS Profile.'**
  String get rosterScopeUnconfigured;

  /// No description provided for @rosterUncoveredWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day off with nobody covering} other{{count} days off with nobody covering}}'**
  String rosterUncoveredWarning(int count);

  /// No description provided for @rosterStandardDay.
  ///
  /// In en, this message translates to:
  /// **'Normal day: {hours}h'**
  String rosterStandardDay(Object hours);

  /// No description provided for @rosterOffShort.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get rosterOffShort;

  /// No description provided for @rosterHolidayShort.
  ///
  /// In en, this message translates to:
  /// **'HOL'**
  String get rosterHolidayShort;

  /// No description provided for @rosterChangeShift.
  ///
  /// In en, this message translates to:
  /// **'Change shift'**
  String get rosterChangeShift;

  /// No description provided for @rosterMarkDayOff.
  ///
  /// In en, this message translates to:
  /// **'Mark day off'**
  String get rosterMarkDayOff;

  /// No description provided for @rosterClearDayOff.
  ///
  /// In en, this message translates to:
  /// **'Cancel this day off'**
  String get rosterClearDayOff;

  /// No description provided for @rosterNoShiftTypes.
  ///
  /// In en, this message translates to:
  /// **'No shift types are configured yet.'**
  String get rosterNoShiftTypes;

  /// No description provided for @rosterShiftWindow.
  ///
  /// In en, this message translates to:
  /// **'{window} · {hours}h'**
  String rosterShiftWindow(Object window, Object hours);

  /// No description provided for @rosterWorkingShift.
  ///
  /// In en, this message translates to:
  /// **'On {shiftType} · {hours}h · {location}'**
  String rosterWorkingShift(Object shiftType, Object hours, Object location);

  /// No description provided for @rosterOffCoveredBy.
  ///
  /// In en, this message translates to:
  /// **'Off ({offType}) — covered by {name}'**
  String rosterOffCoveredBy(Object offType, Object name);

  /// No description provided for @rosterOffUncovered.
  ///
  /// In en, this message translates to:
  /// **'Off ({offType}) — nobody is covering this day'**
  String rosterOffUncovered(Object offType);

  /// No description provided for @rosterHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get rosterHoliday;

  /// No description provided for @rosterUnrosteredWarning.
  ///
  /// In en, this message translates to:
  /// **'Not on the roster — this person cannot check in on this day.'**
  String get rosterUnrosteredWarning;

  /// No description provided for @rosterOffType.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rosterOffType;

  /// No description provided for @rosterCoveredBy.
  ///
  /// In en, this message translates to:
  /// **'Covered by'**
  String get rosterCoveredBy;

  /// No description provided for @rosterCoverHelper.
  ///
  /// In en, this message translates to:
  /// **'Who absorbs this day at the branch.'**
  String get rosterCoverHelper;

  /// No description provided for @rosterNobodyCovers.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get rosterNobodyCovers;

  /// No description provided for @rosterCoverShift.
  ///
  /// In en, this message translates to:
  /// **'Cover shift'**
  String get rosterCoverShift;

  /// No description provided for @rosterCoverShiftHelper.
  ///
  /// In en, this message translates to:
  /// **'The shift they move onto for this day, normally the longer full-day one.'**
  String get rosterCoverShiftHelper;

  /// No description provided for @rosterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get rosterNotes;

  /// No description provided for @rosterOffTypeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly off'**
  String get rosterOffTypeWeekly;

  /// No description provided for @rosterOffTypeVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get rosterOffTypeVacation;

  /// No description provided for @rosterOffTypeSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get rosterOffTypeSick;

  /// No description provided for @rosterOffTypeUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get rosterOffTypeUnpaid;

  /// No description provided for @rosterOffTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rosterOffTypeOther;

  /// No description provided for @rosterWorkedHours.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get rosterWorkedHours;

  /// No description provided for @rosterOvertimeHours.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get rosterOvertimeHours;

  /// No description provided for @rosterCreditedOvertime.
  ///
  /// In en, this message translates to:
  /// **'Credited OT'**
  String get rosterCreditedOvertime;

  /// No description provided for @rosterCreditedHours.
  ///
  /// In en, this message translates to:
  /// **'Paid hours'**
  String get rosterCreditedHours;

  /// No description provided for @rosterCourierTag.
  ///
  /// In en, this message translates to:
  /// **'Courier ×{multiplier}'**
  String rosterCourierTag(Object multiplier);

  /// No description provided for @rosterRowDays.
  ///
  /// In en, this message translates to:
  /// **'{worked} worked · {off} off · {cover} cover'**
  String rosterRowDays(Object worked, Object off, Object cover);

  /// No description provided for @rosterLegendWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get rosterLegendWorking;

  /// No description provided for @rosterLegendOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get rosterLegendOff;

  /// No description provided for @rosterLegendUnrostered.
  ///
  /// In en, this message translates to:
  /// **'Not rostered'**
  String get rosterLegendUnrostered;

  /// No description provided for @rosterLegendHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get rosterLegendHoliday;

  /// No description provided for @settlementPartnerFeeInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner delivery cost'**
  String get settlementPartnerFeeInputLabel;

  /// No description provided for @settlementPartnerFeeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Read it from the partner\'\'s app'**
  String get settlementPartnerFeeInputHint;

  /// No description provided for @settlementPartnerFeeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the partner\'\'s delivery cost for this order'**
  String get settlementPartnerFeeRequired;

  /// No description provided for @settlementPartnerFeeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get settlementPartnerFeeInvalid;

  /// No description provided for @settlementPartnerFeeWhy.
  ///
  /// In en, this message translates to:
  /// **'Our area rates don\'\'t apply to the partner - they price this address themselves.'**
  String get settlementPartnerFeeWhy;

  /// No description provided for @settlementPartnerNoDeduction.
  ///
  /// In en, this message translates to:
  /// **'The rider hands over the full amount. Nothing is deducted for his fee - his company is billed weekly.'**
  String get settlementPartnerNoDeduction;

  /// No description provided for @commonReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required'**
  String get commonReasonRequired;

  /// No description provided for @expensesReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get expensesReject;

  /// No description provided for @expensesRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this expense?'**
  String get expensesRejectTitle;

  /// No description provided for @expensesRejectHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the person who filed it why'**
  String get expensesRejectHint;

  /// No description provided for @expensesRejected.
  ///
  /// In en, this message translates to:
  /// **'Expense rejected'**
  String get expensesRejected;

  /// No description provided for @expensesRejectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get expensesRejectedStatus;

  /// No description provided for @expensesRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get expensesRejectionReason;

  /// No description provided for @expensesCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel expense'**
  String get expensesCancelAction;

  /// No description provided for @expensesCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this approved expense?'**
  String get expensesCancelTitle;

  /// No description provided for @expensesCancelBody.
  ///
  /// In en, this message translates to:
  /// **'This reverses the journal entry for {amount} and puts the money back in {source}.'**
  String expensesCancelBody(Object amount, Object source);

  /// No description provided for @expensesCancelHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this being reversed?'**
  String get expensesCancelHint;

  /// No description provided for @expensesCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel & reverse'**
  String get expensesCancelConfirm;

  /// No description provided for @expensesCancelled.
  ///
  /// In en, this message translates to:
  /// **'Expense cancelled and journal entry reversed'**
  String get expensesCancelled;

  /// No description provided for @productionCancelBatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel batch'**
  String get productionCancelBatch;

  /// No description provided for @productionCancelBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this batch?'**
  String get productionCancelBatchTitle;

  /// No description provided for @productionCancelBatchBody.
  ///
  /// In en, this message translates to:
  /// **'Everything still in WIP for {item} goes back to the store. Nothing has been produced yet, so no finished goods are affected.'**
  String productionCancelBatchBody(Object item);

  /// No description provided for @productionCancelBatchHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this batch not being finished?'**
  String get productionCancelBatchHint;

  /// No description provided for @productionCancelBatchConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel batch'**
  String get productionCancelBatchConfirm;

  /// No description provided for @productionBatchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Batch cancelled and material returned to store'**
  String get productionBatchCancelled;

  /// No description provided for @productionPlanCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get productionPlanCancel;

  /// No description provided for @productionPlanCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this day\'\'s plan?'**
  String get productionPlanCancelTitle;

  /// No description provided for @productionPlanCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Use this when the day will not be produced at all. Closing with zero counts instead would record a day that tried and made nothing.'**
  String get productionPlanCancelBody;

  /// No description provided for @productionPlanCancelHint.
  ///
  /// In en, this message translates to:
  /// **'Why is the day being called off?'**
  String get productionPlanCancelHint;

  /// No description provided for @productionPlanCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get productionPlanCancelConfirm;

  /// No description provided for @productionPlanCancelled.
  ///
  /// In en, this message translates to:
  /// **'Production plan cancelled'**
  String get productionPlanCancelled;

  /// No description provided for @productionPlanCancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get productionPlanCancelledStatus;

  /// No description provided for @receiptReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get receiptReject;

  /// No description provided for @receiptRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this receipt?'**
  String get receiptRejectTitle;

  /// No description provided for @receiptRejectHint.
  ///
  /// In en, this message translates to:
  /// **'What is wrong with the proof of transfer?'**
  String get receiptRejectHint;

  /// No description provided for @receiptRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reject receipt'**
  String get receiptRejectConfirm;

  /// No description provided for @receiptRejected.
  ///
  /// In en, this message translates to:
  /// **'Receipt rejected'**
  String get receiptRejected;

  /// No description provided for @receiptRejectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get receiptRejectedStatus;

  /// No description provided for @receiptRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get receiptRejectionReason;

  /// No description provided for @historyDateRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get historyDateRangeAll;

  /// No description provided for @historyDateRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{from} - {to}'**
  String historyDateRangeValue(Object from, Object to);

  /// No description provided for @stockTransferHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer history'**
  String get stockTransferHistoryTitle;

  /// No description provided for @stockTransferHistorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Entry no. or item'**
  String get stockTransferHistorySearchHint;

  /// No description provided for @stockTransferHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stock transfers yet.'**
  String get stockTransferHistoryEmpty;

  /// No description provided for @stockTransferHistoryRoute.
  ///
  /// In en, this message translates to:
  /// **'{source} to {target}'**
  String stockTransferHistoryRoute(Object source, Object target);

  /// No description provided for @stockTransferHistoryMixed.
  ///
  /// In en, this message translates to:
  /// **'Multiple warehouses'**
  String get stockTransferHistoryMixed;

  /// No description provided for @stockTransferHistorySummary.
  ///
  /// In en, this message translates to:
  /// **'{items} items, {qty} units'**
  String stockTransferHistorySummary(Object items, Object qty);

  /// No description provided for @cashTransferHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash transfer history'**
  String get cashTransferHistoryTitle;

  /// No description provided for @cashTransferHistorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Entry no. or remark'**
  String get cashTransferHistorySearchHint;

  /// No description provided for @cashTransferHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cash transfers yet.'**
  String get cashTransferHistoryEmpty;

  /// No description provided for @inventoryCountHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Count history'**
  String get inventoryCountHistoryTitle;

  /// No description provided for @inventoryCountHistorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Count no. or item'**
  String get inventoryCountHistorySearchHint;

  /// No description provided for @inventoryCountHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stock counts yet.'**
  String get inventoryCountHistoryEmpty;

  /// No description provided for @inventoryCountHistoryAdjusted.
  ///
  /// In en, this message translates to:
  /// **'{items} items adjusted'**
  String inventoryCountHistoryAdjusted(Object items);

  /// No description provided for @inventoryCountHistoryDeltas.
  ///
  /// In en, this message translates to:
  /// **'{up} up, {down} down'**
  String inventoryCountHistoryDeltas(Object up, Object down);

  /// No description provided for @inventoryCountHistoryValueChange.
  ///
  /// In en, this message translates to:
  /// **'Value change'**
  String get inventoryCountHistoryValueChange;

  /// No description provided for @shiftHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift history'**
  String get shiftHistoryTitle;

  /// No description provided for @shiftHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shifts yet.'**
  String get shiftHistoryEmpty;

  /// No description provided for @shiftHistoryStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shiftHistoryStatusOpen;

  /// No description provided for @shiftHistoryStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get shiftHistoryStatusClosed;

  /// No description provided for @shiftHistoryAmountsHidden.
  ///
  /// In en, this message translates to:
  /// **'Amounts are shown to managers only.'**
  String get shiftHistoryAmountsHidden;

  /// No description provided for @shiftHistoryDifference.
  ///
  /// In en, this message translates to:
  /// **'Over / short'**
  String get shiftHistoryDifference;

  /// No description provided for @shiftHistoryMineOnly.
  ///
  /// In en, this message translates to:
  /// **'My shifts only'**
  String get shiftHistoryMineOnly;

  /// No description provided for @shiftHistoryStillOpen.
  ///
  /// In en, this message translates to:
  /// **'Still open'**
  String get shiftHistoryStillOpen;

  /// No description provided for @shiftHistoryDuration.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String shiftHistoryDuration(Object start, Object end);

  /// No description provided for @shiftHistoryOpenedBy.
  ///
  /// In en, this message translates to:
  /// **'Opened by {name}'**
  String shiftHistoryOpenedBy(Object name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
