// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'جارز لنقاط البيع';

  @override
  String get drawerHeaderTitle => 'جارز لنقاط البيع';

  @override
  String get drawerHeaderSubtitle => 'منصة نقاط البيع المحمولة';

  @override
  String get menuPointOfSale => 'نقطة البيع';

  @override
  String get menuSalesKanban => 'لوحة المبيعات';

  @override
  String get menuExpenses => 'المصروفات';

  @override
  String get menuCourierBalances => 'أرصدة المندوبين';

  @override
  String get menuManagerDashboard => 'لوحة تحكم المدير';

  @override
  String get managerMenuTooltip => 'القائمة';

  @override
  String get managerDashboardTitle => 'لوحة تحكم المدير';

  @override
  String get managerRecentOrders => 'أحدث الطلبات';

  @override
  String get managerNoRecentOrders => 'لا توجد طلبات حديثة';

  @override
  String get managerBranchBalances => 'أرصدة الفروع';

  @override
  String get managerSwitchProfileTip =>
      'معلومة: يمكنك تغيير ملف نقطة البيع من ترويسة شاشة نقطة البيع أو لوحة المبيعات.';

  @override
  String get managerSwitchProfile => 'تبديل الملف';

  @override
  String get managerTotalCash => 'إجمالي النقدية';

  @override
  String get managerAll => 'الكل';

  @override
  String get managerFilterByState => 'تصفية حسب الحالة:';

  @override
  String get managerChangeBranch => 'تغيير الفرع';

  @override
  String get managerAssignToBranch => 'إسناد إلى فرع';

  @override
  String get managerBranchUpdated => 'تم تحديث الفرع';

  @override
  String managerBranchUpdateFailed(Object error) {
    return 'فشل: $error';
  }

  @override
  String get menuPurchaseInvoice => 'فواتير الشراء';

  @override
  String get menuManufacturing => 'التصنيع';

  @override
  String get menuStockTransfer => 'تحويل المخزون';

  @override
  String get menuCashTransfer => 'تحويل النقدية';

  @override
  String get cashTransferFromAccount => 'من حساب';

  @override
  String get cashTransferToAccount => 'إلى حساب';

  @override
  String get cashTransferPostingToday => 'الترحيل: اليوم';

  @override
  String cashTransferPostingDate(Object date) {
    return 'الترحيل: $date';
  }

  @override
  String get cashTransferRemarkOptional => 'ملاحظة (اختياري)';

  @override
  String get cashTransferFrom => 'من';

  @override
  String get cashTransferTo => 'إلى';

  @override
  String get cashTransferAccountsMustDiffer => 'يجب أن يكون الحسابان مختلفين';

  @override
  String get cashTransferSelectAccount => 'اختر الحساب';

  @override
  String cashTransferBefore(Object amount) {
    return 'قبل: $amount';
  }

  @override
  String cashTransferAfter(Object amount) {
    return 'بعد: $amount';
  }

  @override
  String get cashTransferNoAccountsFound => 'لا توجد حسابات';

  @override
  String cashTransferJournalEntry(Object entry) {
    return 'قيد اليومية: $entry';
  }

  @override
  String cashTransferFailed(Object error) {
    return 'فشل: $error';
  }

  @override
  String get menuInventoryCount => 'جرد المخزون';

  @override
  String get inventoryCountOfflineUsingCache =>
      'غير متصل: سيتم استخدام البيانات المخزنة';

  @override
  String inventoryCountConfirmAllBeforeSubmit(int remaining) {
    return 'يرجى تأكيد جميع الأصناف قبل الإرسال ($remaining متبقي)';
  }

  @override
  String get inventoryCountConfirmAtLeastOne =>
      'أكد صنفًا واحدًا على الأقل قبل الإرسال';

  @override
  String inventoryCountSubmitted(Object result) {
    return 'تم الإرسال: $result';
  }

  @override
  String get inventoryCountNoDifferences => 'لا توجد فروقات';

  @override
  String get inventoryCountUncategorized => 'غير مصنف';

  @override
  String get inventoryCountManagerAccessRequired =>
      'هذه الشاشة متاحة للمدير فقط';

  @override
  String get inventoryCountSelectWarehouse => 'اختر المخزن';

  @override
  String get inventoryCountEnforceAll => 'إلزام تأكيد الكل';

  @override
  String inventoryCountConfirmedProgress(int confirmed, int total) {
    return 'تم تأكيد $confirmed / $total';
  }

  @override
  String get inventoryCountClearAllEnteredData => 'مسح كل البيانات المدخلة';

  @override
  String get inventoryCountAllEnteredDataCleared =>
      'تم مسح كل البيانات المدخلة';

  @override
  String inventoryCountCurrentAmount(Object amount, Object uom) {
    return 'الحالي: $amount $uom';
  }

  @override
  String get inventoryCountDecrease => 'تقليل';

  @override
  String get inventoryCountCount => 'العدد';

  @override
  String get inventoryCountIncrease => 'زيادة';

  @override
  String inventoryCountValuation(Object amount, Object uom) {
    return 'التقييم: $amount / $uom';
  }

  @override
  String get inventoryCountDeltaLabel => 'الفرق: ';

  @override
  String get inventoryCountSubmitCount => 'إرسال الجرد';

  @override
  String get menuEndShift => 'إنهاء الشيفت';

  @override
  String get menuHome => 'الرئيسية';

  @override
  String get menuSettings => 'الإعدادات';

  @override
  String get menuLogout => 'تسجيل الخروج';

  @override
  String get menuLanguage => 'اللغة';

  @override
  String get menuLanguageEnglish => 'الإنجليزية';

  @override
  String get menuLanguageArabic => 'العربية';

  @override
  String menuSelectedLanguage(Object language) {
    return 'اللغة الحالية: $language';
  }

  @override
  String menuConfirmLanguage(Object language) {
    return 'هل تريد تغيير اللغة إلى $language؟';
  }

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonChoose => 'اختر';

  @override
  String get commonSearchItems => 'ابحث عن الأصناف';

  @override
  String get commonSearchSuppliers => 'ابحث عن الموردين';

  @override
  String get commonNoItems => 'لا يوجد أصناف';

  @override
  String get commonNoSuppliers => 'لا يوجد موردون';

  @override
  String get commonQtyLabel => 'الكمية:';

  @override
  String get commonRateLabel => 'السعر:';

  @override
  String commonAmountValue(Object amount) {
    return 'المبلغ: $amount';
  }

  @override
  String commonTotalValue(Object amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String commonNameWithCode(Object code, Object name) {
    return '$name ($code)';
  }

  @override
  String get commonUomLabel => 'الوحدة:';

  @override
  String commonUomValue(Object uom) {
    return 'الوحدة: $uom';
  }

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonOnline => 'متصل';

  @override
  String get commonOffline => 'غير متصل';

  @override
  String get commonError => 'خطأ';

  @override
  String commonErrorWithDetails(Object details) {
    return 'خطأ: $details';
  }

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String commonQtyWithUom(Object uom) {
    return 'الكمية ($uom)';
  }

  @override
  String get expensesTitle => 'المصروفات';

  @override
  String get expensesRefreshTooltip => 'تحديث';

  @override
  String get expensesNewExpense => 'مصروف جديد';

  @override
  String get expensesRecorded => 'تم تسجيل المصروف';

  @override
  String get expensesSubmitted => 'تم إرسال المصروف لاعتماد المدير';

  @override
  String get expensesMonthLabel => 'الشهر';

  @override
  String get expensesMonthCurrent => 'الشهر الحالي';

  @override
  String get expensesEmptyTitle => 'لا توجد مصروفات مسجلة لهذا الشهر.';

  @override
  String get expensesEmptyManagerBody =>
      'استخدم زر مصروف جديد لتسجيل مصروفات الفريق.';

  @override
  String get expensesEmptyStaffBody =>
      'أرسل الطلب وسيقوم المدير بمراجعته قريبًا.';

  @override
  String get expensesFiltersClear => 'مسح الفلاتر';

  @override
  String get expensesFiltersTitle => 'تصفية حسب طريقة الدفع';

  @override
  String get expensesFiltersEmpty => 'لا يوجد مصادر دفع متاحة';

  @override
  String get expensesSummaryTotal => 'الإجمالي';

  @override
  String get expensesSummaryApproved => 'المعتمدة';

  @override
  String get expensesSummaryPending => 'قيد الاعتماد';

  @override
  String expensesSummaryReceipts(Object count) {
    return '$count إثبات';
  }

  @override
  String expensesSummaryPendingAmount(Object amount, Object count) {
    return '$count | $amount';
  }

  @override
  String get expensesReasonLabel => 'سبب الصرف (حساب مصروفات غير مباشرة)';

  @override
  String get expensesPayFromLabel => 'الدفع من';

  @override
  String get expensesAmountLabel => 'القيمة';

  @override
  String get expensesAmountHint => 'أدخل القيمة';

  @override
  String get expensesAmountInvalid => 'من فضلك أدخل قيمة صحيحة';

  @override
  String get expensesDateLabel => 'تاريخ المصروف';

  @override
  String get expensesRemarksLabel => 'ملاحظات (اختياري)';

  @override
  String get expensesSubmitManager => 'تسجيل المصروف';

  @override
  String get expensesSubmitStaff => 'إرسال للاعتماد';

  @override
  String get expensesNoOptions =>
      'لا يمكن إنشاء مصروف قبل تفعيل حساب السبب وجهة الدفع.';

  @override
  String get expensesApprove => 'اعتماد';

  @override
  String get expensesPendingStatus => 'قيد الاعتماد';

  @override
  String get expensesApprovedStatus => 'معتمد';

  @override
  String get expensesDraftStatus => 'مسودة';

  @override
  String get expensesJournalEntry => 'قيد اليومية';

  @override
  String get expensesPosProfile => 'ملف نقطة البيع';

  @override
  String get expensesPayingAccount => 'حساب الدفع';

  @override
  String get expensesReasonAccount => 'حساب المصروف';

  @override
  String get expensesTimelineTitle => 'الخط الزمني';

  @override
  String get expensesTimelineEmpty => 'لا يوجد سجل زمني';

  @override
  String get expensesPullToRefresh => 'اسحب للتحديث';

  @override
  String languageChanged(Object language) {
    return 'تم تغيير اللغة إلى $language.';
  }

  @override
  String get purchaseTitle => 'فاتورة شراء';

  @override
  String get purchaseSupplierSectionTitle => 'المورد';

  @override
  String get purchaseTapToPickSupplier => 'اضغط لاختيار المورد';

  @override
  String get purchaseItemsSectionTitle => 'الأصناف';

  @override
  String get purchaseShippingLabel => 'الشحن (مصاريف الشحن والمناولة):';

  @override
  String get purchaseSubmit => 'إنشاء فاتورة شراء';

  @override
  String get purchaseSelectSupplier => 'اختر المورد';

  @override
  String get purchaseRecent => 'الأحدث';

  @override
  String get purchaseSupplierDisabledSuffix => ' (معطل)';

  @override
  String get purchaseNoItemsInCart => 'لا توجد أصناف في السلة';

  @override
  String purchaseCreated(Object invoice) {
    return 'تم إنشاء فاتورة الشراء: $invoice';
  }

  @override
  String purchaseSubmitFailed(Object error) {
    return 'فشل إنشاء الفاتورة: $error';
  }

  @override
  String get purchaseSelectPayment => 'اختر مصدر الدفع';

  @override
  String get purchasePaymentProfileSubtitle =>
      'استخدم حساب النقد المرتبط باسم ملف نقطة البيع';

  @override
  String get purchasePaymentInstapayTitle => 'إنستا باي (بنك)';

  @override
  String get purchasePaymentInstapaySubtitle =>
      'استخدم الحساب البنكي المرتبط بإنستا باي';

  @override
  String get purchasePaymentCashTitle => 'نقدي';

  @override
  String get purchasePaymentCashSubtitle =>
      'استخدم حساب النقد الافتراضي للشركة';

  @override
  String get posProfileSelectionTitle => 'اختر ملف نقطة البيع';

  @override
  String get posProfileSelectionErrorTitle => 'تعذّر تحميل ملفات نقاط البيع';

  @override
  String get posProfileSelectionNoProfilesTitle =>
      'لا توجد ملفات نقاط بيع متاحة';

  @override
  String get posProfileSelectionNoProfilesBody =>
      'تواصل مع المسؤول لإسناد ملف نقطة بيع لك';

  @override
  String get posProfileSelectionUnknownProfile => 'ملف غير معروف';

  @override
  String posProfileSelectionWarehouseLabel(Object warehouse) {
    return 'المخزن: $warehouse';
  }

  @override
  String get posProfileSelectionPrompt => 'اختر ملف نقطة البيع:';

  @override
  String get posProfileSelectionCycleHint => 'اختر ملف نقطة البيع';

  @override
  String get posProfileSelectionShortFallback => 'نقطة بيع';

  @override
  String get shiftStartTitle => 'بدء الشيفت';

  @override
  String get shiftEndTitle => 'إنهاء الشيفت';

  @override
  String get shiftNoActive => 'لا يوجد شيفت مفتوح.';

  @override
  String get shiftBackToPos => 'العودة لنقطة البيع';

  @override
  String get shiftOpeningPrompt => 'أدخل رصيد البداية لكل طريقة دفع:';

  @override
  String shiftPosProfile(Object profile) {
    return 'ملف نقطة البيع: $profile';
  }

  @override
  String shiftAccount(Object account) {
    return 'الحساب: $account';
  }

  @override
  String shiftSystemBalance(Object amount) {
    return 'الرصيد بالنظام: $amount';
  }

  @override
  String get shiftConfirmedOpeningAmount => 'رصيد البداية المؤكد';

  @override
  String shiftDifferenceAmount(Object amount) {
    return 'الفرق: $amount';
  }

  @override
  String get shiftClosingPrompt => 'أدخل رصيد الإغلاق:';

  @override
  String get shiftClosingAmountLabel => 'رصيد الإغلاق';

  @override
  String shiftExpectedAmount(Object amount) {
    return 'المتوقع: $amount';
  }

  @override
  String shiftLoadActiveFailed(Object error) {
    return 'تعذر تحميل الشيفت النشط: $error';
  }

  @override
  String get shiftSummaryLoadFailed => 'تعذر تحميل ملخص الشيفت.';

  @override
  String shiftLabel(Object shift) {
    return 'الشيفت: $shift';
  }

  @override
  String shiftOutflows(Object amount) {
    return 'المصروفات الخارجة: $amount';
  }

  @override
  String shiftNetMovement(Object amount) {
    return 'صافي الحركة: $amount';
  }

  @override
  String get shiftAccountMovements => 'حركات الحساب';

  @override
  String get shiftOther => 'أخرى';

  @override
  String shiftSubtotal(Object amount) {
    return 'الإجمالي الفرعي: $amount';
  }

  @override
  String shiftInvoices(Object count) {
    return 'الفواتير: $count';
  }

  @override
  String shiftGrandTotal(Object amount) {
    return 'إجمالي المبيعات: $amount';
  }

  @override
  String get shiftStartButton => 'بدء الشيفت';

  @override
  String get shiftEndButton => 'إنهاء الشيفت';

  @override
  String get shiftEndedSuccess => 'تم إنهاء الشيفت بنجاح.';

  @override
  String get shiftStatusActive => 'شيفت مفتوح';

  @override
  String shiftStartedAt(Object time) {
    return 'بدأ في $time';
  }

  @override
  String shiftProfileMismatch(Object activeProfile, Object selectedProfile) {
    return 'الشيفت المفتوح على $activeProfile بينما الملف المختار هو $selectedProfile.';
  }

  @override
  String get shiftSwitchToActiveProfile => 'التبديل لملف الشيفت المفتوح';

  @override
  String get shiftGoToEnd => 'اذهب إلى إنهاء الشيفت';

  @override
  String get shiftAccountBalance => 'رصيد الحساب';

  @override
  String get shiftDifference => 'الفرق';

  @override
  String get shiftSalesInvoices => 'فواتير المبيعات';

  @override
  String get shiftNoDeliveryStatus => 'بدون حالة';

  @override
  String get shiftClosedSummaryTitle => 'ملخص الشيفت';

  @override
  String get shiftClosingEntry => 'قيد الإغلاق';

  @override
  String get shiftJournalCreated => 'تم تسجيل الفرق النقدي';

  @override
  String get posCartTitle => 'سلة المشتريات';

  @override
  String posCartHeader(Object count) {
    return 'السلة ($count)';
  }

  @override
  String get posCartClear => 'إفراغ السلة';

  @override
  String get posCartEmptyTitle => 'السلة فارغة';

  @override
  String get posCartEmptyBody => 'أضف أصنافًا للبدء';

  @override
  String get posCustomerUnselect => 'إزالة العميل';

  @override
  String get posCustomerAdd => 'إضافة عميل';

  @override
  String posCustomerDeliveryIncomeValue(Object amount) {
    return 'إيراد التوصيل: $amount';
  }

  @override
  String get posUnknownCustomer => 'عميل غير معروف';

  @override
  String get posCartPickupTitle => 'استلام من الفرع (بدون رسوم توصيل)';

  @override
  String get posCartPickupDescription => 'سيستلم العميل الطلب من الفرع.';

  @override
  String get posCartDeliveryDescription =>
      'سيوصل الطلب للعميل في الوقت المحدد.';

  @override
  String get posCartPickupChip => 'استلام';

  @override
  String get posSubtotalLabel => 'الإجمالي الفرعي:';

  @override
  String get posDeliveryLabel => 'التوصيل:';

  @override
  String get posTotalLabel => 'الإجمالي:';

  @override
  String get posCheckoutButton => 'إتمام الطلب';

  @override
  String get posOperationalInfoTitle => 'معلومات تشغيلية';

  @override
  String get posDeliveryExpenseLabel => 'تكلفة التوصيل:';

  @override
  String posDeliveryCostTo(Object territory) {
    return 'تكلفة التوصيل إلى $territory';
  }

  @override
  String get posDeliveryCostGeneric => 'تكلفة التوصيل';

  @override
  String get posUnknownItem => 'صنف غير معروف';

  @override
  String get posCartEditBundle => 'تعديل الباقة';

  @override
  String get posCartClearTitle => 'إفراغ السلة';

  @override
  String get posCartClearMessage =>
      'هل أنت متأكد من حذف جميع الأصناف من السلة؟';

  @override
  String get posCartClearConfirm => 'إفراغ';

  @override
  String get posDeliverySelectSlot => 'من فضلك اختر وقت التوصيل';

  @override
  String get posDeliveryDialogTitle => 'اختر وقت التوصيل';

  @override
  String get posDeliveryLoadFailed => 'فشل تحميل مواعيد التوصيل';

  @override
  String get posDeliveryEmptyTitle => 'لا توجد مواعيد توصيل متاحة';

  @override
  String get posDeliveryEmptyBody => 'برجاء مراجعة جدول مواعيد ملف نقطة البيع';

  @override
  String get posDeliveryDefaultChip => 'التالي';

  @override
  String get posDeliveryLoading => 'جارٍ تحميل مواعيد التوصيل...';

  @override
  String get posDeliveryFieldLabel => 'وقت التوصيل';

  @override
  String get posDeliveryErrorLabel => 'خطأ في تحميل المواعيد';

  @override
  String get posDeliveryNoSlotsLabel => 'لا توجد مواعيد متاحة';

  @override
  String get posDeliverySelectPrompt => 'اختر وقت التوصيل';

  @override
  String get posSalesPartnerPaymentTitle => 'دفع شريك المبيعات';

  @override
  String get posSalesPartnerPaymentDescription =>
      'اختر طريقة دفع شريك المبيعات لهذا الطلب.';

  @override
  String get posSalesPartnerPaymentCash => 'نقدًا (يُحصّل الآن)';

  @override
  String get posSalesPartnerPaymentOnline => 'أونلاين (تم الدفع بالفعل)';

  @override
  String get posCheckoutSuccess => 'تم إرسال الطلب بنجاح!';

  @override
  String posCheckoutFailed(Object error) {
    return 'فشل إرسال الطلب: $error';
  }

  @override
  String get posBundleContentsTitle => 'محتوى الباقة:';

  @override
  String get posBundleUpdated => 'تم تحديث الباقة بنجاح!';

  @override
  String get printerStatusBle => 'الطابعة: بلوتوث LE';

  @override
  String get printerStatusClassic => 'الطابعة: بلوتوث كلاسيكي';

  @override
  String get printerStatusConnecting => 'الطابعة: جاري الاتصال…';

  @override
  String get printerStatusError => 'خطأ في الطابعة';

  @override
  String get printerStatusDisconnected => 'الطابعة: غير متصلة';

  @override
  String get printerSelectTitle => 'اختيار الطابعة';

  @override
  String get printerDiagnosticsTitle => 'التشخيص';

  @override
  String printerDiagnosticsAdapter(Object state) {
    return 'المحول: $state';
  }

  @override
  String printerDiagnosticsScan(Object status) {
    return 'صلاحية الفحص: $status';
  }

  @override
  String printerDiagnosticsConnect(Object status) {
    return 'صلاحية الاتصال: $status';
  }

  @override
  String printerDiagnosticsLocation(Object status) {
    return 'صلاحية الموقع: $status';
  }

  @override
  String get printerDeviceIdLabel => 'معرّف الجهاز (MAC / Identifier)';

  @override
  String get printerConnectById => 'اتصال بالمعرّف';

  @override
  String get printerConnectingById => 'جارٍ الاتصال بالمعرّف...';

  @override
  String get printerConnecting => 'جارٍ الاتصال...';

  @override
  String get printerConnected => 'تم توصيل الطابعة';

  @override
  String get printerConnectionFailed => 'فشل الاتصال';

  @override
  String get printerForgetSavedTooltip => 'نسيان الطابعة المحفوظة';

  @override
  String get printerForgotSaved => 'تم نسيان الطابعة المحفوظة';

  @override
  String get printerRescanTooltip => 'إعادة الفحص';

  @override
  String get printerReconnecting => 'جارٍ إعادة الاتصال...';

  @override
  String get printerReconnected => 'تمت إعادة الاتصال';

  @override
  String get printerReconnectFailed => 'فشلت إعادة الاتصال';

  @override
  String get printerReconnect => 'إعادة الاتصال';

  @override
  String printerConnectedTo(Object name) {
    return 'متصل: $name';
  }

  @override
  String get printerTestPrint => 'طباعة تجريبية';

  @override
  String get printerTestSent => 'تم إرسال الطباعة التجريبية';

  @override
  String printerTestFailed(Object error) {
    return 'فشل الاختبار: $error';
  }

  @override
  String get printerBleDevices => 'أجهزة BLE';

  @override
  String get printerRescanBleTooltip => 'إعادة فحص BLE';

  @override
  String get printerNoBleDevices => 'لم يتم العثور على أجهزة BLE.';

  @override
  String get printerUnknownName => 'طابعة غير معروفة';

  @override
  String get printerConnect => 'اتصال';

  @override
  String get printerClassicDevices => 'أجهزة Classic المقترنة';

  @override
  String get printerRefreshClassicTooltip => 'تحديث قائمة Classic';

  @override
  String get printerNoClassicDevices =>
      'لا توجد طابعات Classic مقترنة. تأكد من إقران الطابعة من إعدادات البلوتوث بالنظام وتفعيل الموقع (Android 8).';

  @override
  String printerClassicMacConnected(Object mac) {
    return '$mac  (Classic)';
  }

  @override
  String get printerDisconnect => 'قطع الاتصال';

  @override
  String get printerConnectingClassic => 'جارٍ الاتصال (Classic)...';

  @override
  String printerLastSavedNotAdvertising(Object id) {
    return 'آخر طابعة محفوظة: $id\nهي غير مرئية الآن عبر البث، ويمكنك محاولة إعادة الاتصال.';
  }

  @override
  String get branchFilterTitle => 'تصفية الفروع';

  @override
  String get branchFilterAllBranches => 'جميع الفروع';

  @override
  String get branchFilterApply => 'تطبيق';

  @override
  String get websocketCollectCashTitle => 'تحصيل النقدية';

  @override
  String get websocketCollectCashMessage =>
      'حصّل كامل قيمة الطلب الآن من مندوب المبيعات.';

  @override
  String websocketInvoiceLabel(Object invoice) {
    return 'الفاتورة: $invoice';
  }

  @override
  String get systemStatusChecking => 'جاري الفحص...';

  @override
  String get systemStatusRealtime => 'تحديث فوري';

  @override
  String get systemStatusNoRealtime => 'بدون تحديث فوري';

  @override
  String get systemStatusSynced => 'تمت المزامنة';

  @override
  String systemStatusPendingCount(Object count) {
    return '$count قيد المزامنة';
  }

  @override
  String get systemStatusCouriers => 'المندوبون';

  @override
  String systemStatusCourierCount(Object count) {
    return '$count مندوب';
  }

  @override
  String get systemStatusPartnerChip => 'شريك';

  @override
  String get systemStatusSalesPartnerFallback => 'شريك المبيعات';

  @override
  String get systemStatusSyncComplete => 'تمت المزامنة وتحديث بيانات المندوبين';

  @override
  String get systemStatusForceSyncTooltip => 'تنفيذ مزامنة فورية';

  @override
  String get courierBalancesTitle => 'أرصدة المندوبين';

  @override
  String get courierBalancesEmpty => 'لا يوجد مندوبون.';

  @override
  String get courierBalancesSettledLabel => 'مُسوى';

  @override
  String get courierBalancesPayCourierLabel => 'سدد للمندوب';

  @override
  String get courierBalancesCourierPaysUsLabel => 'المندوب يسدد لنا';

  @override
  String courierBalancesDetailsTitle(Object courier) {
    return 'التفاصيل – $courier';
  }

  @override
  String courierBalancesCityOrderLine(
    Object city,
    Object order,
    Object shipping,
  ) {
    return 'المدينة: $city\nالطلب: $order • الشحن: $shipping';
  }

  @override
  String get courierBalancesNetLabel => 'الصافي';

  @override
  String get courierSettlementComplete => 'اكتملت التسوية';

  @override
  String get courierSettlementFailed => 'فشلت التسوية';

  @override
  String get courierSettleButton => 'تسوية';

  @override
  String courierPayCourierAmount(Object amount) {
    return 'سداد للمندوب $amount';
  }

  @override
  String courierCollectAmount(Object amount) {
    return 'تحصيل $amount';
  }

  @override
  String courierSettleAllInvoicesQuestion(int count) {
    return 'تسوية كل الفواتير ($count) لهذا المندوب؟';
  }

  @override
  String get courierSettled => 'تمت التسوية';

  @override
  String get courierSettleAllButton => 'تسوية الكل';

  @override
  String courierSettleAllDialogTitle(Object action, Object total) {
    return '$action - الإجمالي $total';
  }

  @override
  String courierSettleAllWillSettle(int count) {
    return 'سيتم تسوية عدد $count فاتورة.';
  }

  @override
  String get courierInvoicesLabel => 'الفواتير:';

  @override
  String get courierSettleAllCollectInfo =>
      'سيتم تحصيل صافي المبلغ من المندوب.';

  @override
  String get courierSettleAllPayInfo => 'سيتم سداد صافي المبلغ للمندوب الآن.';

  @override
  String courierSettleAllComplete(int success, int failed) {
    return 'اكتملت تسوية الكل: $success ناجح، $failed فشل';
  }

  @override
  String get courierBalancesPreviewTooltip => 'معاينة التسوية';

  @override
  String courierBalancesPreviewFailed(Object error) {
    return 'فشل تحميل معاينة التسوية: $error';
  }

  @override
  String get settlementTitleCollectFromCourier => 'تحصيل من المندوب';

  @override
  String get settlementTitlePayCourier => 'سداد للمندوب';

  @override
  String get settlementTitleCourierSettlement => 'تسوية المندوب';

  @override
  String get settlementStatusUnpaid => 'غير مدفوع';

  @override
  String get settlementStatusPaid => 'مدفوع';

  @override
  String get settlementPaidNoteRecent =>
      ' (دُفع للتو، ويتم التعامل معه كغير مدفوع)';

  @override
  String get settlementPaidNoteAfterOfd => ' (بعد الخروج للتسليم)';

  @override
  String get settlementPaidNoteAfterOfdUnpaid =>
      ' (دُفع بعد الخروج للتسليم ويُعامل كغير مدفوع)';

  @override
  String settlementInvoiceStatus(Object status, Object note) {
    return 'حالة الفاتورة: $status$note';
  }

  @override
  String get settlementCollectFormula => 'تحصيل (الطلب - الشحن):';

  @override
  String get settlementPayFormula => 'سداد للمندوب (الطلب - الشحن):';

  @override
  String get settlementNetToCollect => 'الصافي للتحصيل';

  @override
  String get settlementPayAmount => 'قيمة السداد';

  @override
  String get settlementNothingToSettle => 'لا يوجد مبلغ للتحصيل أو السداد.';

  @override
  String settlementOrderLabel(Object amount) {
    return 'الطلب: $amount';
  }

  @override
  String settlementShippingLabel(Object amount) {
    return 'الشحن: $amount';
  }

  @override
  String settlementTerritoryLabel(Object territory) {
    return 'المنطقة: $territory';
  }

  @override
  String get cancelOrderTitle => 'إلغاء الطلب';

  @override
  String cancelOrderInvoiceLabel(Object invoice) {
    return 'الفاتورة: $invoice';
  }

  @override
  String cancelOrderTotalLabel(Object amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String cancelOrderOutstandingLabel(Object amount) {
    return 'المتبقي: $amount';
  }

  @override
  String get cancelOrderPartialPaymentWarning =>
      'هذه الفاتورة تحتوي على دفعة جزئية. يرجى تسوية الدفعة أو ردها قبل الإلغاء.';

  @override
  String get cancelOrderReasonLabel => 'سبب الإلغاء';

  @override
  String get cancelOrderSelectReasonValidation => 'اختر سببًا للمتابعة';

  @override
  String get cancelOrderProvideReasonValidation => 'يرجى إدخال السبب';

  @override
  String get cancelOrderCustomReasonLabel => 'سبب مخصص';

  @override
  String get cancelOrderDescribeReasonValidation => 'يرجى وصف سبب الإلغاء';

  @override
  String get cancelOrderAdditionalNotesOptional => 'ملاحظات إضافية (اختياري)';

  @override
  String get cancelOrderCreditNoteInfo =>
      'سيتم إصدار إشعار دائن تلقائيًا للحفاظ على توازن الحسابات.';

  @override
  String get cancelOrderConfirmButton => 'تأكيد الإلغاء';

  @override
  String get invoicePreparingReceipt => 'جاري تجهيز الإيصال...';

  @override
  String invoiceItemsCount(int count) {
    return 'الأصناف ($count)';
  }

  @override
  String get invoicePrinterNotConnectedHint =>
      'الطابعة غير متصلة. افتح شاشة اختيار الطابعة من القائمة.';

  @override
  String get invoicePrintedSuccessfully => 'تمت الطباعة بنجاح';

  @override
  String get invoicePrinterDisconnected => 'تم فصل الطابعة';

  @override
  String invoicePrintFailed(Object result) {
    return 'فشلت الطباعة: $result';
  }

  @override
  String get invoiceAcceptOrderTitle => 'قبول الطلب';

  @override
  String invoiceAcceptOrderQuestion(Object invoice, Object customer) {
    return 'قبول الطلب $invoice للعميل $customer؟';
  }

  @override
  String get invoiceAcceptAction => 'قبول';

  @override
  String invoiceOrderAccepted(Object invoice) {
    return 'تم قبول الطلب $invoice!';
  }

  @override
  String invoiceAcceptFailed(Object error) {
    return 'فشل قبول الطلب: $error';
  }

  @override
  String get invoiceMoreOptions => 'خيارات إضافية';

  @override
  String get invoiceEditCustomerAddress => 'تعديل عنوان العميل';

  @override
  String get invoiceChangeDeliverySlot => 'تغيير موعد التوصيل';

  @override
  String get invoiceTransferOrder => 'تحويل الطلب';

  @override
  String get invoiceCancelOrderSettleFirst =>
      'إلغاء الطلب (يجب تسوية المدفوعات أولًا)';

  @override
  String get invoiceCustomerLabel => 'العميل';

  @override
  String get invoiceShippingExpenseShort => 'مصروف الشحن:';

  @override
  String get manufacturingTitle => 'التصنيع';

  @override
  String get manufacturingManagersOnly => 'للمدراء فقط';

  @override
  String get manufacturingRecentWorkOrdersTooltip => 'أوامر العمل الأخيرة';

  @override
  String get manufacturingSearchDefaultBom =>
      'ابحث عن الأصناف ذات الـ BOM الافتراضي';

  @override
  String manufacturingWorkOrdersTitle(Object count) {
    return 'أوامر العمل ($count)';
  }

  @override
  String get manufacturingSubmitAll => 'إرسال الكل';

  @override
  String get manufacturingNoItemsSelected => 'لا توجد أصناف محددة';

  @override
  String get manufacturingNoItemsFound => 'لا يوجد أصناف';

  @override
  String manufacturingBomDescription(Object bom, Object quantity, Object uom) {
    return 'BOM: $bom • ناتج $quantity $uom';
  }

  @override
  String get manufacturingBomLabel => 'BOM x';

  @override
  String get manufacturingRequiredItems => 'الأصناف المطلوبة';

  @override
  String get manufacturingNothingToSubmit => 'لا يوجد ما يتم إرساله.';

  @override
  String get manufacturingSubmittingWorkOrders => 'جاري إنشاء أوامر العمل...';

  @override
  String manufacturingSubmitFailed(Object error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get manufacturingSubmitAllSuccess => 'تم الإرسال بنجاح';

  @override
  String manufacturingSubmitAllResult(Object success, Object total) {
    return 'تمت معالجة $total بند. الناجحة: $success';
  }

  @override
  String get manufacturingQuantityMustBePositive =>
      'يجب أن تكون الكمية أكبر من صفر';

  @override
  String get manufacturingSubmittingSingleWorkOrder =>
      'جاري إنشاء أمر العمل...';

  @override
  String get manufacturingSubmitResult => 'تم الإرسال';

  @override
  String manufacturingSubmitStatus(Object status) {
    return 'الحالة: $status';
  }

  @override
  String manufacturingSubmitWorkOrder(Object workOrder) {
    return ' • رقم الأمر: $workOrder';
  }

  @override
  String manufacturingLoadFailed(Object error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get manufacturingRecentWorkOrdersTitle => 'أوامر العمل الأخيرة';

  @override
  String get manufacturingNoWorkOrders => 'لا توجد أوامر عمل';

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
    return 'المتوفر: $quantity $uom';
  }

  @override
  String get stockTransferTitle => 'تحويل مخزون';

  @override
  String get stockTransferManagersOnly => 'للمدراء فقط';

  @override
  String stockTransferLinesTitle(Object count) {
    return 'بنود التحويل ($count)';
  }

  @override
  String stockTransferPostingChip(Object date) {
    return 'الترحيل: $date';
  }

  @override
  String get stockTransferSubmit => 'إرسال';

  @override
  String get stockTransferProfilesMustDiffer =>
      'يجب أن يكون المصدر والوجهة مختلفين';

  @override
  String get stockTransferProfileLabelSource => 'المصدر';

  @override
  String get stockTransferProfileLabelTarget => 'الوجهة';

  @override
  String get stockTransferProfilePlaceholder => 'اختر ملف نقطة البيع';

  @override
  String stockTransferProfileOption(Object profile, Object warehouse) {
    return '$profile • $warehouse';
  }

  @override
  String get stockTransferProfileWarehouseFallback => 'بدون مخزن';

  @override
  String get stockTransferSelectBranches => 'اختر فروع المصدر والوجهة';

  @override
  String get stockTransferSameProfile =>
      'لا يمكن أن يكون المصدر والوجهة متطابقين';

  @override
  String stockTransferAvailability(Object source, Object target) {
    return 'المصدر: $source • الوجهة: $target';
  }

  @override
  String stockTransferReservedSource(Object reservedSource) {
    return ' • محجوز مصدر: $reservedSource';
  }

  @override
  String stockTransferReservedTarget(Object reservedTarget) {
    return ' • محجوز وجهة: $reservedTarget';
  }

  @override
  String get stockTransferPosTag => ' • نقطة بيع';

  @override
  String get stockTransferPostingToday => 'تاريخ الترحيل: اليوم';

  @override
  String stockTransferPostingDate(Object date) {
    return 'تاريخ الترحيل: $date';
  }

  @override
  String get stockTransferUseToday => 'استخدم اليوم';

  @override
  String get stockTransferNoLines => 'لا يوجد بنود';

  @override
  String stockTransferBeforeBase(Object source, Object target) {
    return 'قبل — المصدر: $source • الوجهة: $target';
  }

  @override
  String stockTransferAfterBase(Object source, Object target) {
    return 'بعد  — المصدر: $source • الوجهة: $target';
  }

  @override
  String stockTransferTransferCreated(Object stockEntry) {
    return 'تم إنشاء التحويل: $stockEntry';
  }

  @override
  String stockTransferSubmitFailed(Object error) {
    return 'فشل: $error';
  }

  @override
  String stockTransferBulkAddFailed(Object error) {
    return 'فشل الإضافة الجماعية: $error';
  }

  @override
  String get stockTransferQuickQuantity => 'كمية سريعة';

  @override
  String get stockTransferQuantityPerItem => 'الكمية لكل صنف';

  @override
  String get stockTransferItemGroup => 'مجموعة الأصناف';

  @override
  String get stockTransferAllGroups => 'كل المجموعات';

  @override
  String get stockTransferAddAll => 'إضافة الكل';

  @override
  String get stockTransferAddGroup => 'إضافة المجموعة';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonDismiss => 'تجاهل';

  @override
  String get commonSave => 'حفظ';

  @override
  String get paymentMethodSelectTitle => 'اختر طريقة الدفع';

  @override
  String get paymentMethodCash => 'نقدي';

  @override
  String get paymentMethodInstapay => 'إنستاباي';

  @override
  String get paymentMethodMobileWallet => 'محفظة إلكترونية';

  @override
  String get checkoutTotal => 'الإجمالي:';

  @override
  String get checkoutPay => 'ادفع';

  @override
  String get checkoutSelectProfileFirst => 'اختر ملف نقطة البيع أولاً';

  @override
  String get checkoutOrderSuccess => 'تم إتمام الطلب بنجاح!';

  @override
  String checkoutFailed(Object error) {
    return 'فشل الدفع: $error';
  }

  @override
  String get salesPartnerTitle => 'شريك المبيعات';

  @override
  String get salesPartnerSearchHint => 'بحث عن شريك';

  @override
  String get salesPartnerNotFound => 'لا يوجد شركاء';

  @override
  String get itemGridBundles => 'حزم';

  @override
  String get itemGridAll => 'الكل';

  @override
  String get itemGridUncategorized => 'بدون تصنيف';

  @override
  String get itemGridSelectCustomerWarning => 'يرجى اختيار عميل أولاً';

  @override
  String get itemGridNoItemsFound => 'لم يتم العثور على أصناف';

  @override
  String get itemGridNoItemsAvailable => 'لا توجد أصناف متاحة';

  @override
  String get itemGridTryDifferentCategory => 'جرّب تصنيفاً مختلفاً';

  @override
  String get itemGridItemsWillAppear => 'ستظهر الأصناف هنا';

  @override
  String get itemGridFreeDelivery => 'توصيل مجاني';

  @override
  String itemGridBundlesCount(Object count) {
    return '$count حزم';
  }

  @override
  String itemGridItemsCount(Object count) {
    return '$count أصناف';
  }

  @override
  String get itemGridAddedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get itemGridSelectCustomerFirst => 'اختر عميلاً أولاً';

  @override
  String get itemGridOutOfStock => 'نفدت الكمية';

  @override
  String get itemGridCannotAdd => 'لا يمكن إضافة الصنف';

  @override
  String get kanbanFilterTitle => 'الفلاتر';

  @override
  String kanbanFilterActiveCount(Object count) {
    return '$count نشط';
  }

  @override
  String get kanbanFilterClearAll => 'مسح الكل';

  @override
  String get kanbanFilterSearch => 'بحث';

  @override
  String get kanbanFilterSearchHint => 'بحث في الطلبات...';

  @override
  String get kanbanFilterAllCustomers => 'كل العملاء';

  @override
  String get kanbanFilterAllStatuses => 'كل الحالات';

  @override
  String get kanbanFilterDateRange => 'نطاق التاريخ';

  @override
  String get kanbanFilterFromDate => 'من تاريخ';

  @override
  String get kanbanFilterToDate => 'إلى تاريخ';

  @override
  String get kanbanFilterAllDates => 'كل التواريخ';

  @override
  String get kanbanFilterAmountRange => 'نطاق المبلغ';

  @override
  String get kanbanFilterMinAmount => 'الحد الأدنى';

  @override
  String get kanbanFilterMaxAmount => 'الحد الأقصى';

  @override
  String get kanbanFilterAllAmounts => 'كل المبالغ';

  @override
  String get kanbanFilterActiveLabel => 'الفلاتر النشطة:';

  @override
  String get kanbanFilterByBranches => 'تصفية حسب الفروع';

  @override
  String get kanbanFilterCustomerTitle => 'العميل';

  @override
  String get kanbanFilterCustomerName => 'اسم العميل';

  @override
  String get kanbanFilterCustomerHint => 'أدخل اسم العميل';

  @override
  String get kanbanFilterStatusTitle => 'الحالة';

  @override
  String get kanbanFilterFromAmount => 'من مبلغ';

  @override
  String get kanbanFilterToAmount => 'إلى مبلغ';

  @override
  String get kanbanFilterApply => 'تطبيق';

  @override
  String get kanbanRefreshOrders => 'تحديث الطلبات';

  @override
  String get kanbanOrdersRefreshed => 'تم تحديث الطلبات';

  @override
  String get kanbanHideFilters => 'إخفاء الفلاتر';

  @override
  String get kanbanShowFilters => 'إظهار الفلاتر';

  @override
  String get kanbanMoreActions => 'المزيد';

  @override
  String get kanbanMenu => 'القائمة';

  @override
  String get kanbanMenuReceipts => 'إيصالات الدفع';

  @override
  String get kanbanMenuPrinters => 'الطابعات';

  @override
  String get kanbanMenuCouriers => 'أرصدة المناديب';

  @override
  String get kanbanMenuProfile => 'الملف الشخصي';

  @override
  String get kanbanMenuPos => 'نقطة البيع';

  @override
  String get kanbanPaymentReceipts => 'إيصالات الدفع';

  @override
  String get kanbanCourierBalances => 'أرصدة المناديب';

  @override
  String get kanbanUserProfile => 'الملف الشخصي';

  @override
  String get kanbanOpenPos => 'فتح نقطة البيع';

  @override
  String get kanbanTitleShort => 'كانبان';

  @override
  String get kanbanTitleFull => 'كانبان المبيعات';

  @override
  String get kanbanPrinterBle => 'BLE';

  @override
  String get kanbanPrinterClassic => 'كلاسيك';

  @override
  String get kanbanPrinterConnecting => 'جارٍ الاتصال...';

  @override
  String get kanbanPrinterNotConnected => 'غير متصل';

  @override
  String get kanbanErrorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get kanbanNoColumnsConfigured => 'لم يتم تكوين أعمدة';

  @override
  String get kanbanEnsureStateField => 'تأكد من تكوين حقل الحالة بشكل صحيح.';

  @override
  String get kanbanSelectPosProfileFirst => 'اختر ملف نقطة البيع أولاً';

  @override
  String get kanbanSelectPosProfile => 'اختر ملف نقطة البيع';

  @override
  String get kanbanNoPosProfiles => 'لا توجد ملفات نقطة بيع متاحة';

  @override
  String kanbanWarehouse(Object warehouse) {
    return 'المستودع: $warehouse';
  }

  @override
  String get kanbanCourierAndMode => 'المندوب والطريقة';

  @override
  String get kanbanNoCouriersAvailable => 'لا يوجد مناديب';

  @override
  String get kanbanCreateCourierHint => 'أنشئ مندوباً للمتابعة.';

  @override
  String get kanbanNewCourier => 'مندوب جديد';

  @override
  String get kanbanFirstName => 'الاسم الأول';

  @override
  String get kanbanLastName => 'اسم العائلة';

  @override
  String get kanbanPhone => 'الهاتف';

  @override
  String get kanbanType => 'النوع';

  @override
  String get kanbanEmployee => 'موظف';

  @override
  String get kanbanSupplier => 'مورّد';

  @override
  String get kanbanBack => 'رجوع';

  @override
  String kanbanCreateFailed(Object error) {
    return 'فشل الإنشاء: $error';
  }

  @override
  String get kanbanMode => 'الطريقة';

  @override
  String get kanbanPayNowCash => 'ادفع الآن (نقدي)';

  @override
  String get kanbanSettleLater => 'تسوية لاحقاً';

  @override
  String get kanbanSettleLaterSubtitle => 'المندوب يسوي مع الفرع لاحقاً';

  @override
  String get kanbanContinue => 'متابعة';

  @override
  String get kanbanSettleLaterMissingParty =>
      'فشلت التسوية اللاحقة: طرف المندوب مفقود.';

  @override
  String get kanbanSettleLaterPreviewExpired =>
      'التسوية اللاحقة: انتهت صلاحية المعاينة. أعد المحاولة.';

  @override
  String get kanbanSettleLaterFailed => 'فشلت التسوية اللاحقة';

  @override
  String get kanbanMarkedSettleLater => 'تم التحديد للتسوية لاحقاً';

  @override
  String kanbanSettleLaterError(Object error) {
    return 'خطأ في التسوية اللاحقة: $error';
  }

  @override
  String get kanbanSettlementMissingParty => 'فشلت التسوية: طرف المندوب مفقود.';

  @override
  String get kanbanPreviewExpired => 'انتهت صلاحية المعاينة. أعد المحاولة.';

  @override
  String get kanbanConfirmingSettlement => 'جارٍ تأكيد التسوية...';

  @override
  String get kanbanSettlementFailed => 'فشلت التسوية';

  @override
  String get kanbanSettlementConfirmed => 'تم تأكيد التسوية';

  @override
  String kanbanSettlementError(Object error) {
    return 'خطأ في التسوية: $error';
  }

  @override
  String kanbanPreviewFailed(Object error) {
    return 'فشلت المعاينة: $error';
  }

  @override
  String get kanbanPickupNoSettlement => 'طلبات الاستلام لا تحتاج تسوية';

  @override
  String get kanbanCannotMoveBackward => 'لا يمكن التراجع للخلف';

  @override
  String get kanbanMoveOneStage => 'يمكن التقدم مرحلة واحدة فقط';

  @override
  String get kanbanAllBranches => 'كل الفروع';

  @override
  String kanbanBranchCount(Object count) {
    return '$count فروع';
  }

  @override
  String get kanbanLoadingBranches => 'جارٍ تحميل الفروع...';

  @override
  String get kanbanTapToRefreshBalance => 'اضغط لتحديث الرصيد';

  @override
  String get kanbanPressBackAgain => 'اضغط رجوع مرة أخرى للخروج';

  @override
  String get invoiceDeliveryAddress => 'عنوان التوصيل';

  @override
  String get invoiceItems => 'الأصناف';

  @override
  String get invoiceNetTotal => 'الإجمالي الصافي';

  @override
  String get invoiceShippingIncome => 'إيراد الشحن';

  @override
  String get invoiceShippingExpense => 'مصاريف الشحن';

  @override
  String get invoiceGrandTotal => 'الإجمالي الكلي';

  @override
  String invoiceAlreadyStatus(Object status) {
    return 'الفاتورة بالفعل $status';
  }

  @override
  String get invoiceSelectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get invoiceWallet => 'محفظة';

  @override
  String get invoiceSubmit => 'إرسال';

  @override
  String get invoiceNoPosProfileCash =>
      'لم يتم اختيار ملف نقطة بيع للدفع النقدي';

  @override
  String invoiceProcessingPayment(Object method) {
    return 'جارٍ معالجة دفع $method...';
  }

  @override
  String invoicePaymentSuccess(Object entry) {
    return 'تم الدفع بنجاح ($entry)';
  }

  @override
  String get invoiceReceiptAmountWarning =>
      'تحذير: تعذر الحصول على مبلغ الدفع للإيصال';

  @override
  String get invoiceReceiptNoPosProfile =>
      'تحذير: لم يتم العثور على ملف نقطة بيع - لم يتم إنشاء الإيصال. يرجى اختيار ملف نقطة بيع.';

  @override
  String invoiceReceiptCreated(Object receipt) {
    return 'تم إنشاء إيصال الدفع ($receipt) - يرجى رفع صورة الإيصال من الرأس';
  }

  @override
  String invoiceReceiptReturnedWarning(Object message) {
    return 'تحذير: إنشاء الإيصال أرجع: $message';
  }

  @override
  String invoiceReceiptCreationFailed(Object error) {
    return 'تحذير: فشل إنشاء الإيصال: $error';
  }

  @override
  String get invoicePaymentFailed => 'فشل الدفع';

  @override
  String invoicePaymentError(Object error) {
    return 'خطأ في الدفع: $error';
  }

  @override
  String get invoiceCollectCashTitle => 'تحصيل النقد';

  @override
  String invoiceCollectCashBody(Object amount, Object invoiceId) {
    return 'يرجى التحصيل من العميل:\n\nالمبلغ الإجمالي: $amount جنيه\n\nيشمل:\n• أصناف الطلب\n• رسوم الشحن\n\nفاتورة: $invoiceId';
  }

  @override
  String get invoiceSelectPosFirst => 'اختر ملف نقطة البيع أولاً';

  @override
  String get invoiceCollectingCashPartner =>
      'جارٍ تحصيل النقد والإرسال (شريك مبيعات)...';

  @override
  String get invoiceCashCollectedOfd => 'تم تحصيل النقد وإرسال الطلب للتوصيل';

  @override
  String invoiceOfdFailed(Object error) {
    return 'فشل: $error';
  }

  @override
  String invoiceOfdError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get invoiceSentOfd => 'تم الإرسال للتوصيل (سيتم إنشاء إذن التسليم)';

  @override
  String invoiceActionFailed(Object error) {
    return 'فشل الإجراء: $error';
  }

  @override
  String get invoiceSettleLaterMissingParty =>
      'فشلت التسوية اللاحقة: طرف المندوب مفقود.';

  @override
  String get invoiceMarkedSettleLater => 'تم التحديد للتسوية لاحقاً';

  @override
  String get invoiceSettleLaterFailed => 'فشلت التسوية اللاحقة';

  @override
  String invoiceSettleLaterError(Object error) {
    return 'خطأ في التسوية اللاحقة: $error';
  }

  @override
  String get invoiceSettlementMissingParty =>
      'فشلت التسوية: طرف المندوب مفقود.';

  @override
  String get invoicePreviewExpired => 'انتهت صلاحية المعاينة. أعد المحاولة.';

  @override
  String get invoiceConfirmingSettlement => 'جارٍ تأكيد التسوية...';

  @override
  String get invoiceSettlementConfirmed => 'تم تأكيد التسوية';

  @override
  String get invoiceSettlementFailed => 'فشلت التسوية';

  @override
  String invoiceSettlementError(Object error) {
    return 'خطأ في التسوية: $error';
  }

  @override
  String get invoiceProcessingDelivery => 'جارٍ معالجة التوصيل...';

  @override
  String get invoiceUpdated => 'تم التحديث';

  @override
  String get invoiceDeliveryFailed => 'فشل إجراء التوصيل';

  @override
  String invoiceDeliveryError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get invoiceDeliveryTitle => 'التوصيل';

  @override
  String get invoiceUnpaidWarning =>
      'الفاتورة غير مدفوعة. اختر تحصيل المندوب للنقد الآن لتسجيل دفعة نقدية قبل تحديد خارج للتوصيل.';

  @override
  String get invoiceCannotSettleParty =>
      'لا يمكن التسوية: لم يتم تحديد طرف المندوب. عيّن مندوباً أو أعد المحاولة.';

  @override
  String get invoiceNothingToSettle => 'لا يوجد شيء للتسوية';

  @override
  String get invoiceSettlementComplete => 'اكتملت التسوية';

  @override
  String get invoiceEditAddress => 'تعديل عنوان العميل';

  @override
  String get invoicePhoneNumber => 'رقم الهاتف';

  @override
  String get invoiceDeliveryAddressLabel => 'عنوان التوصيل';

  @override
  String get invoiceAddressHelper => 'أدخل عنوان التوصيل الكامل';

  @override
  String get invoiceAddressUpdateInfo =>
      'سيتم تحديث العنوان ورقم الهاتف الافتراضي للعميل.';

  @override
  String get invoiceAddressEmpty => 'العنوان لا يمكن أن يكون فارغاً';

  @override
  String get invoiceUpdatingAddress => 'جارٍ تحديث عنوان العميل...';

  @override
  String get invoiceAddressUpdated => 'تم تحديث عنوان العميل بنجاح';

  @override
  String get invoiceAddressUpdateFailed => 'فشل تحديث العنوان';

  @override
  String invoiceCopiedNumber(Object number) {
    return 'تم النسخ: $number';
  }

  @override
  String get invoiceCopy => 'نسخ';

  @override
  String get invoiceCannotCall => 'تعذر إجراء المكالمة';

  @override
  String get invoiceCall => 'اتصال';

  @override
  String get invoiceSettleBeforeCancel =>
      'قم بتسوية أو استرداد المدفوعات الجزئية قبل إلغاء هذا الطلب.';

  @override
  String get invoiceCancelFailed => 'فشل إلغاء الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String invoiceCancelledWithCn(Object creditNote) {
    return 'تم إلغاء الطلب. تم إنشاء إشعار دائن $creditNote.';
  }

  @override
  String get invoiceCancelledSuccess => 'تم إلغاء الطلب بنجاح.';

  @override
  String get invoiceNoPosProfile => 'لم يتم اختيار ملف نقطة بيع';

  @override
  String get invoiceAssignBranch => 'تعيين إلى فرع';

  @override
  String invoiceCustomerName(Object name) {
    return 'العميل: $name';
  }

  @override
  String invoiceInvoiceLabel(Object name) {
    return 'الفاتورة: $name';
  }

  @override
  String get invoiceTransferInfo =>
      'سيتم نقل الطلب إلى الفرع المحدد وإعادة تعيينه إلى حالة مستلم.';

  @override
  String get invoiceTransferring => 'جارٍ نقل الطلب...';

  @override
  String invoiceTransferSuccess(Object branch) {
    return 'تم نقل الطلب بنجاح إلى $branch';
  }

  @override
  String get invoiceTransferFailed => 'فشل النقل. يرجى المحاولة مرة أخرى.';

  @override
  String get invoiceCannotDetermineProfile =>
      'تعذر تحديد ملف نقطة البيع لهذه الفاتورة';

  @override
  String get invoiceLoadingSlots => 'جارٍ تحميل مواعيد التوصيل...';

  @override
  String get invoiceNoSlots => 'لا توجد مواعيد توصيل متاحة لهذا الفرع';

  @override
  String get invoiceChangeSlot => 'تغيير موعد التوصيل';

  @override
  String invoiceCurrentSlot(Object slot) {
    return 'الحالي: $slot';
  }

  @override
  String get invoiceSlotUpdateInfo => 'سيتم تحديث موعد التوصيل لهذا الطلب.';

  @override
  String get invoiceNoChanges => 'لم يتم إجراء تغييرات';

  @override
  String get invoiceUpdatingSlot => 'جارٍ تحديث موعد التوصيل...';

  @override
  String invoiceSlotUpdated(Object slot) {
    return 'تم تحديث موعد التوصيل إلى $slot';
  }

  @override
  String get invoiceSlotUpdateFailed => 'فشل تحديث موعد التوصيل';
}
