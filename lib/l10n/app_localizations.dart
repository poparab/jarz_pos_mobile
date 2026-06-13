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
  /// **'A credit note will be issued automatically so the accounts stay balanced.'**
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
  /// **'Search orders...'**
  String get kanbanFilterSearchHint;

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
  /// **'Update downloaded — restart the app to apply it.'**
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
