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

  /// No description provided for @menuPurchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get menuPurchaseInvoice;

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

  /// No description provided for @menuInventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get menuInventoryCount;

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

  /// No description provided for @commonQtyWithUom.
  ///
  /// In en, this message translates to:
  /// **'Qty ({uom})'**
  String commonQtyWithUom(Object uom);

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
