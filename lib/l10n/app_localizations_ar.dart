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
  String get menuB2bMode => 'وضع الأعمال (B2B)';

  @override
  String get drawerGroupPosSales => 'نقاط البيع / المبيعات';

  @override
  String get drawerGroupCrm => 'إدارة العملاء / B2B';

  @override
  String get drawerGroupDelivery => 'التوصيل / الخدمات اللوجستية';

  @override
  String get drawerGroupFinance => 'المالية / المصروفات';

  @override
  String get drawerGroupPurchasing => 'المشتريات / المخزون';

  @override
  String get drawerGroupManagement => 'الإدارة / التقارير';

  @override
  String get drawerGroupPricing => 'التسعير';

  @override
  String get menuPriceLists => 'قوائم الأسعار';

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
  String get menuAbout => 'حول التطبيق';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutAppSection => 'التطبيق';

  @override
  String get aboutReleaseSection => 'الإصدار';

  @override
  String get aboutShorebirdSection => 'Shorebird';

  @override
  String get aboutAppName => 'اسم التطبيق';

  @override
  String get aboutPackageName => 'اسم الحزمة';

  @override
  String get aboutPlatform => 'المنصة';

  @override
  String get aboutEnvironment => 'البيئة';

  @override
  String get aboutBuildName => 'اسم البناء';

  @override
  String get aboutBuildNumber => 'رقم البناء';

  @override
  String get aboutReleaseId => 'معرّف الإصدار';

  @override
  String get aboutReleaseDist => 'توزيع الإصدار';

  @override
  String get aboutPatchNumber => 'رقم التصحيح';

  @override
  String get aboutPatchStatus => 'حالة التصحيح';

  @override
  String get aboutLastChecked => 'آخر فحص';

  @override
  String get aboutNotAvailable => 'غير متوفر';

  @override
  String get aboutPatchNotInstalled => 'الإصدار الأساسي فقط';

  @override
  String get aboutPatchUnavailable => 'غير متاح على هذه المنصة';

  @override
  String get aboutPatchStatusUpToDate => 'محدّث';

  @override
  String get aboutPatchStatusUpdateAvailable => 'يوجد تحديث';

  @override
  String get aboutPatchStatusRestartRequired => 'إعادة التشغيل مطلوبة';

  @override
  String get aboutPatchStatusUnavailable => 'غير متاح';

  @override
  String get aboutPatchStatusUnknown => 'غير معروف';

  @override
  String get aboutPatchStatusUnknownDetail => 'خطأ في فحص التحديث';

  @override
  String get aboutRefresh => 'تحديث';

  @override
  String get aboutCopyDiagnostics => 'نسخ معلومات التشخيص';

  @override
  String get aboutCopiedDiagnostics => 'تم نسخ معلومات التشخيص';

  @override
  String get aboutRetry => 'إعادة المحاولة';

  @override
  String aboutError(Object error) {
    return 'خطأ: $error';
  }

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
  String get postingDateConfirmationTitle => 'تأكيد تاريخ الترحيل';

  @override
  String get postingDateConfirmationMessage =>
      'يرجى تأكيد تاريخ الترحيل قبل الإرسال.';

  @override
  String postingDateConfirmationDate(Object date) {
    return 'تاريخ الترحيل: $date';
  }

  @override
  String get postingDateConfirmationDates => 'تواريخ الترحيل:';

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
  String get inventoryCountSetupStep => 'الإعداد';

  @override
  String get inventoryCountBlindEntryStep => 'إدخال الكميات';

  @override
  String get inventoryCountReviewStep => 'مراجعة الفروقات';

  @override
  String get inventoryCountSpotCount => 'جرد جزئي';

  @override
  String get inventoryCountSpotCountDescription =>
      'أرسل فقط الأصناف التي قمت بعدّها.';

  @override
  String get inventoryCountFullWarehouseCountDescription =>
      'يجب عد كل الأصناف المحملة قبل الإرسال النهائي.';

  @override
  String get inventoryCountWarehouseLabel => 'المخزن';

  @override
  String get inventoryCountPostingDateLabel => 'تاريخ الترحيل';

  @override
  String get inventoryCountCountModeLabel => 'نوع الجرد';

  @override
  String get inventoryCountContinueCount => 'متابعة الجرد';

  @override
  String get inventoryCountStartCount => 'بدء الجرد';

  @override
  String get inventoryCountBackToSetup => 'العودة إلى الإعداد';

  @override
  String get inventoryCountReviewButton => 'مراجعة الفروقات';

  @override
  String get inventoryCountBackToCounting => 'العودة إلى العد';

  @override
  String inventoryCountFilteredItems(int visible, int total) {
    return '$visible من $total صنف';
  }

  @override
  String get inventoryCountCountedStatus => 'تم العد';

  @override
  String get inventoryCountPendingStatus => 'قيد الانتظار';

  @override
  String get inventoryCountClearEntry => 'مسح الإدخال';

  @override
  String get inventoryCountSummaryCountedItems => 'الأصناف المعدودة';

  @override
  String get inventoryCountSummaryChangedItems => 'الأصناف المتغيرة';

  @override
  String get inventoryCountSummaryMissingItems => 'الأصناف غير المعدودة';

  @override
  String get inventoryCountReviewDiscrepancies => 'الفروقات';

  @override
  String get inventoryCountReviewNoCountedItems => 'لم يتم عد أي صنف بعد.';

  @override
  String get inventoryCountReviewNoDiscrepancies => 'لا توجد فروقات حتى الآن.';

  @override
  String get inventoryCountReviewUnchanged => 'الأصناف المعدودة بدون فرق';

  @override
  String get inventoryCountReviewMissing => 'الأصناف غير المعدودة';

  @override
  String inventoryCountCountedAmount(Object amount, Object uom) {
    return 'المعدود: $amount $uom';
  }

  @override
  String inventoryCountStockEquivalent(Object amount, Object uom) {
    return 'المعادِل بالمخزون: $amount $uom';
  }

  @override
  String get inventoryCountMissingItemNote => 'لم يتم عد هذا الصنف بعد';

  @override
  String get inventoryCountBatchTracked => 'يتتبع بالدفعات';

  @override
  String get inventoryCountSerialTracked => 'يتتبع بالأرقام التسلسلية';

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
  String get commonCustomerLabel => 'العميل';

  @override
  String get commonPosProfileLabel => 'ملف نقطة البيع';

  @override
  String get commonTotalLabel => 'الإجمالي';

  @override
  String get commonAmountLabel => 'المبلغ';

  @override
  String get commonDateLabel => 'التاريخ';

  @override
  String get commonCourierLabel => 'الساعي';

  @override
  String get commonDeliveryLabel => 'التوصيل';

  @override
  String get commonItemsLabel => 'الأصناف';

  @override
  String get commonItemLabel => 'صنف';

  @override
  String get commonNotesLabel => 'ملاحظات';

  @override
  String get commonPaymentLabel => 'الدفع';

  @override
  String get commonOutstandingLabel => 'المتبقي';

  @override
  String get commonUploadedByLabel => 'تم الرفع بواسطة';

  @override
  String get commonReasonLabel => 'السبب';

  @override
  String get ofdShortageDialogTitle => 'اعتماد عجز المخزون قبل الإرسال';

  @override
  String get ofdShortageDialogMessage =>
      'هذه الأصناف بها عجز في مخزن التسليم. أضف سببًا للمتابعة إلى حالة خارج للتوصيل.';

  @override
  String ofdShortageLine(
    String item,
    String required,
    String available,
    String warehouse,
  ) {
    return '$item: المطلوب $required، المتاح $available، المخزن $warehouse';
  }

  @override
  String get ofdShortageReasonHint => 'اشرح لماذا يجب متابعة الإرسال رغم العجز';

  @override
  String get ofdShortageReasonRequired => 'أدخل سبب العجز للمتابعة';

  @override
  String get ofdShortageApprove => 'اعتماد والمتابعة';

  @override
  String get commonNotSpecified => 'غير محدد';

  @override
  String get commonWalkIn => 'عميل مباشر';

  @override
  String get commonScheduled => 'مجدول';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonNew => 'جديد';

  @override
  String get commonPreview => 'معاينة';

  @override
  String commonByUser(Object user) {
    return 'بواسطة $user';
  }

  @override
  String commonQtyWithUom(Object uom) {
    return 'الكمية ($uom)';
  }

  @override
  String orderAlertTitle(Object invoiceId) {
    return 'طلب جديد: $invoiceId';
  }

  @override
  String get orderAlertNoLineItems => 'لا توجد بنود';

  @override
  String orderAlertMoreItems(Object count) {
    return '+$count صنف إضافي';
  }

  @override
  String get orderAlertMuteAlarm => 'كتم التنبيه';

  @override
  String get orderAlertUnmuteAlarm => 'إلغاء كتم التنبيه';

  @override
  String get orderAlertAccepting => 'جارٍ القبول...';

  @override
  String get orderAlertAcceptOrder => 'قبول الطلب';

  @override
  String get posDraftDeleteTitle => 'حذف المسودة';

  @override
  String posDraftDeleteBody(Object label) {
    return 'هل تريد حذف \"$label\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String posDraftLimitReached(Object max) {
    return 'تم الوصول إلى الحد الأقصى للمسودات ($max). احذف مسودة لإنشاء مسودة جديدة.';
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
  String get expensesReasonRequired => 'اختر سببًا';

  @override
  String get expensesPaymentSourceRequired => 'اختر مصدر الدفع';

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
  String get shiftOpeningPrompt => 'قم بعدّ نقدية البداية ثم أدخلها:';

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
  String get shiftCountedOpeningAmount => 'النقدية المعدودة عند البداية';

  @override
  String shiftDifferenceAmount(Object amount) {
    return 'الفرق: $amount';
  }

  @override
  String get shiftClosingPrompt => 'قم بعدّ نقدية الإغلاق ثم أدخلها:';

  @override
  String get shiftClosingAmountLabel => 'رصيد الإغلاق';

  @override
  String get shiftCountedClosingAmount => 'النقدية المعدودة عند الإغلاق';

  @override
  String get shiftBlindCountHint => 'قم بعدّ النقدية في الدرج ثم أدخل المبلغ.';

  @override
  String get shiftNoClosingPaymentMethodsTitle =>
      'تعذر إظهار حقل إدخال النقدية';

  @override
  String get shiftNoClosingPaymentMethodsBody =>
      'لا توجد وسيلة دفع متاحة لإغلاق هذا الشيفت. أعد فتح الشيفت أو تواصل مع الدعم.';

  @override
  String get shiftCashCountRequired => 'أدخل مبلغ النقدية المعدودة.';

  @override
  String get shiftCashCountInvalid => 'أدخل مبلغ نقدية صحيح.';

  @override
  String get shiftCashCountNegative => 'لا يمكن أن تكون قيمة النقدية سالبة.';

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
  String get shiftUnexpectedStartResponse =>
      'استجابة غير متوقعة من الخادم أثناء بدء الشيفت.';

  @override
  String get shiftUnexpectedSummaryResponse =>
      'استجابة غير متوقعة من الخادم أثناء تحميل ملخص الشيفت.';

  @override
  String get shiftUnexpectedEndResponse =>
      'استجابة غير متوقعة من الخادم أثناء إنهاء الشيفت.';

  @override
  String get shiftCourierBlockTitle => 'سوِّ أرصدة المندوبين قبل إنهاء الشيفت';

  @override
  String shiftCourierBlockBody(
    int transactions,
    int couriers,
    int invoices,
    Object profile,
  ) {
    return 'لا يزال هذا الشيفت يحتوي على $transactions حركة مندوب غير مسواة تخص $couriers مندوبًا عبر $invoices فاتورة على ملف نقطة البيع $profile.';
  }

  @override
  String get shiftCourierBlockHint =>
      'افتح أرصدة المندوبين، سوِّ ما يزال معلقًا، ثم ارجع لإكمال إنهاء الشيفت.';

  @override
  String get shiftCourierReviewButton => 'مراجعة وتسوية المندوبين';

  @override
  String shiftCourierBlockPartySummary(
    Object name,
    int transactions,
    int invoices,
  ) {
    return '$name: عدد $transactions حركة على $invoices فاتورة';
  }

  @override
  String shiftCourierBlockNetBalance(Object amount) {
    return 'صافي الرصيد: $amount';
  }

  @override
  String shiftCourierBlockMore(int count) {
    return '+$count مندوب إضافي';
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
  String get shiftAlreadyOpenByAnotherTitle => 'الشيفت مفتوح بالفعل';

  @override
  String shiftAlreadyOpenByAnotherBody(Object branch, Object user) {
    return 'نقطة البيع \"$branch\" بها شيفت مفتوح بدأه $user. يجب إغلاق هذا الشيفت أولاً.';
  }

  @override
  String get shiftRefresh => 'تحديث';

  @override
  String get shiftLogout => 'تسجيل الخروج';

  @override
  String get shiftSwitchToActiveProfile => 'التبديل لملف الشيفت المفتوح';

  @override
  String shiftOpenOnOtherProfile(Object otherProfile, Object shiftName) {
    return 'لديك شيفت مفتوح ($shiftName) على ملف \"$otherProfile\". أغلق هذا الشيفت أولاً قبل بدء شيفت جديد هنا.';
  }

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
  String get posCartPricingTitle => 'تسعير المدير';

  @override
  String get posCartPriceListLabel => 'قائمة الأسعار';

  @override
  String get posCartPriceListHint =>
      'استخدم القائمة الافتراضية للفرع أو اختر قائمة B2B.';

  @override
  String get posCartPriceListDefaultChip => 'افتراضي';

  @override
  String get posCartOrderPurposeLabel => 'غرض الطلب';

  @override
  String get posCartOrderPurposeHint =>
      'طبّق سياسة تجارية أو اترك الطلب عاديًا.';

  @override
  String get posCartOrderPurposeStandard => 'عادي';

  @override
  String get posCartOrderPurposeWaivesShipping => 'تم إعفاء إيراد الشحن';

  @override
  String get posCartOrderPurposeNoCourier => 'بدون مصروف مندوب';

  @override
  String get posCartOrderPurposeReasonLabel => 'السبب (اختياري)';

  @override
  String get posCartOrderPurposeReasonHint =>
      'أضف ملاحظة توضّح سبب تطبيق هذا الغرض.';

  @override
  String get posCartZeroShippingTitle => 'بدون إيراد شحن';

  @override
  String get posCartZeroShippingDescription =>
      'لا تضف إيراد الشحن على هذا الطلب.';

  @override
  String get posCartZeroShippingPriceListDefault =>
      'مفعّل تلقائيًا لهذه القائمة السعرية.';

  @override
  String get posCartZeroShippingManagedByPickup =>
      'الاستلام من الفرع يلغي رسوم التوصيل بالفعل.';

  @override
  String get posCartZeroShippingManagedByPartner =>
      'طلبات شريك البيع تلغي إيراد الشحن بالفعل.';

  @override
  String get posSubtotalLabel => 'الإجمالي الفرعي:';

  @override
  String get posDeliveryLabel => 'التوصيل:';

  @override
  String get posTotalLabel => 'الإجمالي:';

  @override
  String get posCheckoutButton => 'إتمام الطلب';

  @override
  String get posCheckoutStockExceedTitle => 'الأصناف تتجاوز المخزون المتاح';

  @override
  String get posCheckoutStockExceedMessage =>
      'الأصناف التالية في السلة تتجاوز المخزون الحالي في النظام. يمكن إنشاء الطلب، لكن التنفيذ قد يحتاج مخزونًا واردًا أو تصحيح جرد.';

  @override
  String posCheckoutStockExceedLine(
    String item,
    String requested,
    String available,
  ) {
    return '$item: المطلوب $requested، المتاح $available';
  }

  @override
  String get posCheckoutProceedAnyway => 'متابعة الطلب';

  @override
  String get posTerritoryMismatchTitle => 'عدم تطابق الفرع';

  @override
  String get posTerritoryMismatchBody => 'منطقة العميل مرتبطة بفرع POS مختلف.';

  @override
  String posTerritoryMismatchUseSelected(String profile) {
    return 'الاستمرار بالفرع المحدد: $profile';
  }

  @override
  String posTerritoryMismatchUseTerritory(String profile) {
    return 'التحويل لفرع المنطقة: $profile';
  }

  @override
  String posTerritoryMismatchNoTerritory(String profile) {
    return 'لا يوجد فرع مرتبط بالمنطقة — الاستمرار بالفرع المحدد: $profile';
  }

  @override
  String get posTerritoryMismatchCancel => 'إلغاء';

  @override
  String get posTerritoryMismatchConfirm => 'متابعة';

  @override
  String get posAmendmentDraftButton => 'إرسال التعديل';

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
  String get posCartItemPricingDialogTitle => 'تعديل تسعير السطر';

  @override
  String posCartItemPricingBaseRate(String amount) {
    return 'سعر الكتالوج الحالي: $amount';
  }

  @override
  String get posCartItemPricingCustomRateLabel => 'سعر وحدة مخصص';

  @override
  String get posCartItemPricingDiscountAmountLabel => 'قيمة الخصم';

  @override
  String get posCartItemPricingDiscountPercentLabel => 'نسبة الخصم';

  @override
  String get posCartItemPricingDiscountHint =>
      'استخدم قيمة الخصم أو نسبة الخصم فقط، وليس الاثنين معًا.';

  @override
  String get posCartItemPricingReset => 'إلغاء التسعير';

  @override
  String get posCartItemPricingSave => 'تطبيق';

  @override
  String posCartItemCustomPriceApplied(String amount) {
    return 'سعر مخصص $amount';
  }

  @override
  String posCartItemDiscountAmountApplied(String amount) {
    return 'خصم $amount';
  }

  @override
  String posCartItemDiscountPercentApplied(String amount) {
    return 'خصم $amount%';
  }

  @override
  String get posCartItemPricingInvalidNumber => 'أدخل رقمًا صالحًا.';

  @override
  String get posCartItemPricingInvalidCustomRate =>
      'يجب أن يكون السعر المخصص صفرًا أو أكثر.';

  @override
  String get posCartItemPricingInvalidDiscountAmount =>
      'يجب أن تكون قيمة الخصم صفرًا أو أكثر.';

  @override
  String get posCartItemPricingInvalidDiscountPercent =>
      'يجب أن تكون نسبة الخصم بين 0 و100.';

  @override
  String get posCartItemPricingChooseSingleDiscount =>
      'استخدم قيمة الخصم أو نسبة الخصم فقط، وليس الاثنين معًا.';

  @override
  String get posCartItemPricingDiscountTooHigh =>
      'لا يمكن أن تتجاوز قيمة الخصم سعر الوحدة الفعلي.';

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
  String get printerCompatibilityTooltip => 'إعدادات توافق الطابعة';

  @override
  String get printerCompatibilityTitle => 'التوافق';

  @override
  String get printerCompatibilitySubtitle =>
      'الإعدادات الآمنة تُبقي الإيصالات العادية كنص وتستخدم الرسم النقطي فقط عند الحاجة.';

  @override
  String get printerCompatibilitySaved => 'تم حفظ إعدادات توافق الطابعة';

  @override
  String get printerCompatibilityReset => 'استعادة الإعدادات الافتراضية';

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
  String get printerPaperSizeLabel => 'مقاس الورق';

  @override
  String get printerPaper58mm => '58 مم';

  @override
  String get printerPaper80mm => '80 مم';

  @override
  String get printerPrintLogo => 'طباعة الشعار';

  @override
  String get printerPrintLogoHint =>
      'عطّل هذا أولًا إذا ظهرت رموز غير مفهومة أعلى الإيصال.';

  @override
  String get printerRasterizeArabic => 'تحويل النص العربي إلى صورة';

  @override
  String get printerRasterizeArabicHint =>
      'مطلوب للطابعات التي لا تدعم العربية مباشرة.';

  @override
  String get printerRasterizeStyledText => 'تحويل النص المنسق إلى صورة';

  @override
  String get printerRasterizeStyledTextHint =>
      'فعّل هذا فقط إذا كانت الطابعة تدعم النص النقطي بثبات.';

  @override
  String get printerRasterWidthLabel => 'عرض الصورة النقطية (بكسل)';

  @override
  String get printerCodeTableLabel => 'جدول الترميز';

  @override
  String get printerBleChunkSizeLabel => 'حجم حزمة BLE';

  @override
  String get printerBleChunkDelayLabel => 'مهلة حزمة BLE (مللي ثانية)';

  @override
  String get printerClassicChunkSizeLabel => 'حجم حزمة Classic';

  @override
  String get printerClassicChunkDelayLabel => 'مهلة حزمة Classic (مللي ثانية)';

  @override
  String get printerClassicTailDelayLabel => 'مهلة نهاية Classic (مللي ثانية)';

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
  String get settlementOnlineUnconfirmedNote =>
      'العميل هيدفع أونلاين — المندوب محصلش أي فلوس. اللي بيتسوّى هنا هو مصاريف الشحن بس.';

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
      'الدفعة اللي على الطلب ده هتترجع. سلّم الفلوس للعميل قبل ما تأكد.';

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
  String get invoiceAddNote => 'الملاحظات';

  @override
  String get invoiceNotesTitle => 'ملاحظات الفاتورة';

  @override
  String get invoiceNotesTooltip => 'عرض ملاحظات الفاتورة';

  @override
  String get invoiceNotesHint => 'أضف ملاحظة تشغيلية لهذه الفاتورة';

  @override
  String get invoiceNotesEmpty => 'لا توجد ملاحظات لهذه الفاتورة بعد.';

  @override
  String get invoiceLatestNoteLabel => 'آخر ملاحظة';

  @override
  String invoiceLatestNoteLabelWithCount(Object count) {
    return 'آخر ملاحظة (من $count)';
  }

  @override
  String get invoiceLatestNoteTapToRead => 'اضغط تقرأ ملاحظات الطلب';

  @override
  String get invoiceAddingNote => 'جارٍ الإضافة...';

  @override
  String get invoiceNoteAdded => 'تمت إضافة الملاحظة';

  @override
  String invoiceNotesLoadFailed(Object error) {
    return 'تعذر تحميل ملاحظات الفاتورة: $error';
  }

  @override
  String invoiceNoteAddFailed(Object error) {
    return 'تعذر إضافة الملاحظة: $error';
  }

  @override
  String get invoiceEditInvoice => 'تعديل الفاتورة';

  @override
  String get invoiceEditInvoiceFailed =>
      'تعذر فتح مسودة تعديل الفاتورة. حاول مرة أخرى.';

  @override
  String get invoiceAmendmentUnavailable =>
      'تعديل الفاتورة غير متاح لهذا الطلب.';

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
  String get manufacturingInsufficientInventory => 'المخزون غير كافٍ';

  @override
  String get manufacturingSubmissionBlocked =>
      'تم إيقاف الإرسال حتى يتم حل العجز.';

  @override
  String manufacturingLineShortageSummary(Object components, Object item) {
    return '$item: $components';
  }

  @override
  String manufacturingComponentRequired(Object quantity, Object uom) {
    return 'المطلوب: $quantity $uom';
  }

  @override
  String manufacturingComponentMissing(Object quantity, Object uom) {
    return 'العجز: $quantity $uom';
  }

  @override
  String get menuProductionBoard => 'لوحة الإنتاج';

  @override
  String get productionBoardTitle => 'لوحة الإنتاج';

  @override
  String get productionTabPlan => 'الخطة';

  @override
  String get productionTabDaily => 'اليوم';

  @override
  String get dailyPlanNoItems =>
      'لا توجد أصناف قابلة للتعبئة لها قائمة مكونات افتراضية.';

  @override
  String get dailyPlanNoMix => 'بدون خليط تشيز كيك';

  @override
  String dailyPlanPerBatch(int count) {
    return '$count للتشغيلة';
  }

  @override
  String dailyPlanTotalJars(int count) {
    return '$count برطمان مخطط';
  }

  @override
  String get dailyPlanEnterQuantities => 'اكتب عدد البرطمانات اللي هتعبيها.';

  @override
  String dailyPlanMixTotal(String qty, String uom, String batches) {
    return '$qty $uom خليط = $batches تشغيلة';
  }

  @override
  String get dailyPlanNoRuns => 'العجان مش متظبط، فمش هينفع نحسب التقسيم.';

  @override
  String get dailyPlanRunPreferred => 'مظبوط';

  @override
  String get dailyPlanRunAcceptable => 'زيادة شوية';

  @override
  String get dailyPlanRunPoor => 'مش بيخلط كويس';

  @override
  String dailyPlanSpareMix(String batches) {
    return '$batches تشغيلة خليط زيادة بسبب التقريب.';
  }

  @override
  String get dailyPlanCheckMaterials => 'راجع المخزون';

  @override
  String get dailyPlanSave => 'احفظ الخطة';

  @override
  String dailyPlanSaved(String name) {
    return 'الخطة $name اتحفظت.';
  }

  @override
  String dailyPlanShortages(int count) {
    return '$count خامات ناقصة';
  }

  @override
  String dailyPlanShortageLine(String item, String qty, String uom) {
    return '$item: ناقص $qty $uom';
  }

  @override
  String dailyPlanShortagesMore(int count) {
    return 'و$count كمان';
  }

  @override
  String get dailyPlanMaterialsUnavailable =>
      'مش قادرين نراجع المخزون للخطة دي.';

  @override
  String dailyPlanBomIssues(int count) {
    return '$count قائمة مكونات محتاجة مراجعة عشان إجمالي الخليط يبقى صح';
  }

  @override
  String get dailyPlanBomIssuesTitle =>
      'مشاكل قوائم المكونات المؤثرة على الخطة';

  @override
  String get productionTabBatch => 'التشغيلة';

  @override
  String get productionAccessDenied => 'مطلوب صلاحية الإنتاج';

  @override
  String get productionSearchHint => 'دوّر على صنف له BOM';

  @override
  String get productionFilterAll => 'الكل';

  @override
  String get productionStatusCritical => 'حرج';

  @override
  String get productionStatusLow => 'قليل';

  @override
  String get productionStatusOk => 'مغطى';

  @override
  String get productionStatusOverstocked => 'زيادة';

  @override
  String get productionStatusNoVelocity => 'مفيش بيانات بيع';

  @override
  String get productionOnHand => 'المتاح';

  @override
  String get productionSellsPerDay => 'بيبيع / يوم';

  @override
  String get productionCover => 'التغطية';

  @override
  String productionCoverDays(Object days) {
    return '$days يوم';
  }

  @override
  String get productionCoverUnknown => '—';

  @override
  String get productionTrend => 'الاتجاه';

  @override
  String productionMakeBatches(Object batches, Object units, Object uom) {
    return 'اعمل $batches تشغيلة · $units $uom';
  }

  @override
  String productionReachCover(Object days) {
    return 'علشان توصل لتغطية $days يوم';
  }

  @override
  String productionCappedBy(Object capped, Object limiter, Object wanted) {
    return 'الحد $capped — $limiter ناقص (المطلوب $wanted)';
  }

  @override
  String productionSeasonApplied(Object name, Object value) {
    return 'موسم $name: ×$value';
  }

  @override
  String get productionAddToBatch => 'أضف';

  @override
  String get productionFillTheDay => 'املأ اليوم';

  @override
  String productionFillTheDayResult(Object added, Object batches) {
    return 'اتضاف $added صنف · $batches تشغيلة';
  }

  @override
  String productionFillTheDaySkipped(Object skipped) {
    return '$skipped اتخطّت — مفيش خامات';
  }

  @override
  String get productionFillTheDayNothing => 'مفيش حاجة تتضاف';

  @override
  String get productionNoSuggestions => 'مفيش حاجة محتاجة إنتاج';

  @override
  String get productionVelocityNever =>
      'معدل البيع لسه ماتحسبش — الاقتراحات هتفضل فاضية لحد ما يشتغل';

  @override
  String productionVelocityUpdated(Object when) {
    return 'المعدل اتحدّث $when';
  }

  @override
  String productionBelowCover(Object count) {
    return '$count صنف تحت التغطية';
  }

  @override
  String get productionBasketEmpty => 'مفيش حاجة في التشغيلة';

  @override
  String productionBasketTitle(Object count) {
    return 'التشغيلة ($count)';
  }

  @override
  String get productionPostingDate => 'تاريخ الإنتاج';

  @override
  String get productionClearBasket => 'مسح';

  @override
  String get productionBatchesLabel => 'تشغيلات';

  @override
  String get productionPickListTitle => 'قائمة الصرف المجمّعة';

  @override
  String productionPickListShort(Object quantity, Object uom) {
    return 'ناقص $quantity $uom';
  }

  @override
  String get productionPickListOk => 'كل الخامات متوفرة';

  @override
  String productionSharedAcrossLines(Object count) {
    return 'مشترك بين $count بند';
  }

  @override
  String get productionSubmitting => 'بيتبعت…';

  @override
  String get productionScaleToFit => 'قلّل للمتاح من الخامات';

  @override
  String productionTargetDays(Object days) {
    return 'الهدف $days يوم';
  }

  @override
  String get productionNoSourceWarehouse => 'مفيش مخزن مصدر متظبّط';

  @override
  String productionStockElsewhere(Object quantity, Object warehouse) {
    return '$quantity موجودة في $warehouse — محتاجة تحويل مخزني مش شراء';
  }

  @override
  String productionStockElsewhereMore(
    Object count,
    Object quantity,
    Object warehouse,
  ) {
    return '$quantity موجودة في $warehouse و$count مخزن كمان — محتاجة تحويل مخزني مش شراء';
  }

  @override
  String get productionStockNowhere =>
      'مفيش منها في أي مخزن تاني — لازم تتشترى';

  @override
  String get productionNegativeStock => 'الرصيد بالسالب — اعمل جرد للصنف ده';

  @override
  String productionMakeUnits(Object units, Object uom) {
    return 'اعمل $units $uom';
  }

  @override
  String productionCannotStart(Object limiter) {
    return 'مش هيبدأ — $limiter ناقص';
  }

  @override
  String productionBatchTotals(Object batches, Object units) {
    return '$batches تشغيلة · $units وحدة';
  }

  @override
  String get productionTabRunning => 'شغال';

  @override
  String get productionStart => 'ابدأ التشغيلة';

  @override
  String get productionQuickProduce => 'إنتاج سريع';

  @override
  String get productionFinish => 'إنهاء';

  @override
  String get productionFinishTitle => 'إنهاء التشغيلة';

  @override
  String get productionActualQty => 'الكمية الفعلية';

  @override
  String get productionScrapQty => 'الهالك';

  @override
  String get productionBatchNotes => 'ملاحظات';

  @override
  String productionActualExceedsPlanned(Object planned) {
    return 'أكتر من المخطط $planned';
  }

  @override
  String get productionQtyMustBePositive => 'اكتب اللي طلع فعلاً';

  @override
  String get productionRunningEmpty => 'مفيش تشغيلات شغالة';

  @override
  String productionRunningSince(Object when, Object who) {
    return 'بدأت $when بواسطة $who';
  }

  @override
  String productionElapsed(Object hours, Object minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String productionElapsedMinutes(Object minutes) {
    return '$minutes دقيقة';
  }

  @override
  String productionPlannedVsProduced(Object planned, Object produced) {
    return '$planned مخطط · $produced منتَج';
  }

  @override
  String productionWipLeftover(Object quantity, Object uom) {
    return 'متبقي $quantity $uom تحت التشغيل';
  }

  @override
  String get productionReturnToStore => 'رجّع للمخزن';

  @override
  String get productionReturnedToStore => 'الخامات رجعت للمخزن';

  @override
  String get productionCostTitle => 'تكلفة التشغيلة';

  @override
  String get productionMaterialCost => 'الخامات';

  @override
  String get productionCostPerUnit => 'للوحدة';

  @override
  String get productionStandardCost => 'المعياري';

  @override
  String get productionVariance => 'الفرق';

  @override
  String productionVarianceOver(Object percent) {
    return '$percent% أعلى من المعياري';
  }

  @override
  String productionVarianceUnder(Object percent) {
    return '$percent% أقل من المعياري';
  }

  @override
  String get productionCostUnavailable => 'مفيش تكلفة لسه — مفيش إنتاج';

  @override
  String get productionPrintBatchSheet => 'اطبع ورقة التشغيلة';

  @override
  String get productionBackDateNotAllowed => 'مش مسموح تسجّل إنتاج بتاريخ قديم';

  @override
  String productionStarted(Object workOrder) {
    return 'التشغيلة بدأت · $workOrder';
  }

  @override
  String productionFinished(Object quantity, Object uom) {
    return 'التشغيلة خلصت · $quantity $uom';
  }

  @override
  String get productionNotStartedYet => 'التشغيلة دي ماابتدتش أصلاً';

  @override
  String get productionTabBases => 'الأساسات';

  @override
  String get basesHeaderHint =>
      'الأساسات مش بتتباع، فالخطة عمرها ما هتقترحها. اختار واحد وحدد عايز تعجن كام تشغيلة.';

  @override
  String get basesEmpty => 'مفيش أساسات متظبّطة';

  @override
  String basesSummaryShort(Object count) {
    return '$count أقل من اللي البرطمانات محتاجاه';
  }

  @override
  String basesSummaryBlocked(Object count) {
    return '$count متوقف — مفيش خامات';
  }

  @override
  String basesBatchYield(Object quantity, Object uom) {
    return 'التشغيلة الواحدة = $quantity $uom';
  }

  @override
  String get basesInFreezer => 'في الفريزر';

  @override
  String basesBatchesValue(Object batches) {
    return '$batches تشغيلة';
  }

  @override
  String basesQtyValue(Object quantity, Object uom) {
    return '$quantity $uom';
  }

  @override
  String get basesCanMakeNow => 'ينفع دلوقتي';

  @override
  String basesDemandHint(Object needed, Object onHand) {
    return 'الخطة محتاجة $needed تشغيلة · عندك $onHand';
  }

  @override
  String basesDemandDriver(Object driver) {
    return 'من $driver';
  }

  @override
  String basesUseBatches(Object batches) {
    return 'خُد $batches';
  }

  @override
  String get basesRunSizes => 'أحجام العجّان';

  @override
  String get basesRunSizeOff =>
      'مش من أحجام العجّان المعتادة — راجع قبل ما تعجن';

  @override
  String basesMakes(Object quantity, Object uom) {
    return 'هيطلع $quantity $uom';
  }

  @override
  String get basesConsumes => 'هياخد من الخامات';

  @override
  String basesEstimatedCost(Object amount) {
    return 'تكلفة الخامات تقريباً $amount';
  }

  @override
  String get basesChecking => 'بيراجع الخامات…';

  @override
  String basesPreviewFailed(Object reason) {
    return 'مش قادر يراجع الخامات — $reason';
  }

  @override
  String basesShortage(Object component, Object quantity, Object uom) {
    return '$component ناقص $quantity $uom';
  }

  @override
  String basesReduceTo(Object batches) {
    return 'قلّلها لـ $batches';
  }

  @override
  String get basesNothingPossible => 'الخامات مش كفاية ولا لنص تشغيلة';

  @override
  String get sopTitle => 'تعليمات التشغيل';

  @override
  String get sopViewSop => 'شوف التعليمات';

  @override
  String get sopNoSopForItem => 'مفيش تعليمات للصنف ده';

  @override
  String sopStepOf(Object current, Object total) {
    return 'خطوة $current من $total';
  }

  @override
  String get sopNext => 'التالي';

  @override
  String get sopPrevious => 'السابق';

  @override
  String get sopConfirmStep => 'تم';

  @override
  String get sopCaptureNumber => 'اكتب القراءة';

  @override
  String get sopCaptureTemperature => 'اكتب درجة الحرارة';

  @override
  String get sopCapturePhoto => 'صوّر';

  @override
  String get sopCaptureRequired => 'سجّل ده قبل ما تكمّل';

  @override
  String sopCaptureOutOfRange(Object from, Object to) {
    return 'المسموح من $from لـ $to';
  }

  @override
  String sopDurationMins(Object minutes) {
    return '$minutes دقيقة';
  }

  @override
  String sopTotalDuration(Object minutes) {
    return 'حوالي $minutes دقيقة إجمالاً';
  }

  @override
  String sopScaledFor(Object batches) {
    return 'محسوبة لـ $batches تشغيلة';
  }

  @override
  String get sopEquipment => 'المعدات';

  @override
  String sopExpectedYield(Object percent) {
    return 'الناتج المتوقع $percent%';
  }

  @override
  String sopVersionLabel(Object version) {
    return 'إصدار $version';
  }

  @override
  String get sopFinishExecution => 'إنهاء التعليمات';

  @override
  String get sopExitConfirm => 'هتسيب التعليمات؟ مكانك مش هيتحفظ.';

  @override
  String sopUnresolvedTokens(Object count) {
    return '$count مرجع في التعليمات مش متعرَّف';
  }

  @override
  String get sopPhotoCaptured => 'الصورة اتسجلت';

  @override
  String get sopCameraPermissionDenied => 'محتاج إذن الكاميرا عشان تصوّر';

  @override
  String get sopImageUnavailable =>
      'الصورة مش متاحة — يمكن ماعندكش صلاحية ليها';

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
  String get paymentMethodCard => 'بطاقة';

  @override
  String get paymentMethodInstapay => 'إنستاباي';

  @override
  String get paymentMethodMobileWallet => 'محفظة إلكترونية';

  @override
  String get paymentMethodSettleLater => 'سداد لاحق';

  @override
  String get paymentMethodOnline => 'دفع إلكتروني';

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
  String itemGridInCart(Object count) {
    return 'في السلة: $count';
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
  String get kanbanFilterSearchHint => 'رقم الطلب أو العميل أو التليفون';

  @override
  String kanbanFilterMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب مطابق',
      few: '$count طلبات مطابقة',
      two: 'طلبان مطابقان',
      one: 'طلب واحد مطابق',
      zero: 'مفيش طلبات مطابقة',
    );
    return '$_temp0';
  }

  @override
  String get kanbanFilterDone => 'تم';

  @override
  String get kanbanFilterDateToday => 'النهاردة';

  @override
  String get kanbanFilterDateLast7Days => 'آخر ٧ أيام';

  @override
  String get kanbanFilterDateLast30Days => 'آخر ٣٠ يوم';

  @override
  String get kanbanFilterDateThisMonth => 'الشهر ده';

  @override
  String get kanbanFilterDateCustom => 'نطاق مخصص…';

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
  String get kanbanCancelViaMenuOnly =>
      'مش هينفع تلغي الطلب بالسحب. افتح قائمة الكارت واختار \"إلغاء الطلب\".';

  @override
  String get kanbanReturnViaMenuOnly =>
      'مش هينفع ترجّع الطلب بالسحب. افتح قائمة الكارت واختار \"مرتجع الطلب\".';

  @override
  String get kanbanFullyReturnedLocked =>
      'الطلب ده اترجع بالكامل ومش هينفع يتحرك تاني.';

  @override
  String get kanbanPinBadgePinned => 'الموقع متحدد';

  @override
  String get kanbanPinBadgePinnedTooltip =>
      'العنوان ده عليه إحداثيات على الخريطة';

  @override
  String get kanbanPinBadgeMissing => 'مفيش موقع';

  @override
  String get kanbanPinBadgeMissingTooltip =>
      'لسه مفيش موقع على الخريطة — ضيف رابط الموقع قبل الخروج للتوصيل';

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
  String get invoiceChangeCollectionMethod => 'تغيير طريقة التحصيل';

  @override
  String get invoiceRequestedPaymentMethod => 'الطريقة المطلوبة';

  @override
  String get invoiceActualCollectionMethod => 'التحصيل الفعلي';

  @override
  String get invoiceCollectionReferenceLabel => 'رقم المرجع';

  @override
  String get invoiceCollectionReferenceRequired =>
      'التحصيل الإلكتروني يتطلب رقم مرجع.';

  @override
  String get invoiceCollectionCashAtBranchNotice =>
      'مندوب التوصيل لهذا الطلب أغلق حسابه بالفعل، لذلك يُسجل هذا المبلغ كنقدية مُستلمة في الفرع وسيُطلب في جرد الدرج القادم.';

  @override
  String get invoiceChangingCollectionMethod => 'جارٍ تغيير طريقة التحصيل...';

  @override
  String invoiceCollectionMethodChanged(Object method) {
    return 'تم تغيير طريقة التحصيل إلى $method';
  }

  @override
  String invoiceCollectionMethodChangeError(Object error) {
    return 'خطأ في تغيير طريقة التحصيل: $error';
  }

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
  String get customerShippingAddressTitle => 'اختر عنوان الشحن';

  @override
  String get customerShippingAddressSubtitle =>
      'اختر عنوان شحن محفوظًا أو أضف عنوانًا جديدًا لهذا العميل.';

  @override
  String get customerShippingAddressSavedTab => 'العناوين المحفوظة';

  @override
  String get customerShippingAddressNewTab => 'إضافة عنوان جديد';

  @override
  String get customerShippingAddressEmpty => 'لا توجد عناوين شحن محفوظة بعد.';

  @override
  String get customerShippingAddressSelectRequired =>
      'اختر عنوان شحن أو أضف عنوانًا جديدًا.';

  @override
  String get customerShippingAddressLoadFailed => 'فشل تحميل عناوين الشحن.';

  @override
  String get customerShippingAddressEditTab => 'تعديل العنوان';

  @override
  String get customerShippingAddressEditTitle => 'تعديل عنوان الشحن';

  @override
  String get customerShippingAddressDeleteConfirm =>
      'حذف هذا العنوان؟ لا يمكن التراجع عن هذا.';

  @override
  String get customerShippingAddressDeleteSuccess => 'تم حذف العنوان.';

  @override
  String get customerShippingAddressDeleteFailed => 'فشل حذف العنوان.';

  @override
  String get customerShippingAddressUpdateSuccess => 'تم تحديث العنوان.';

  @override
  String get customerShippingAddressUpdateFailed => 'فشل تحديث العنوان.';

  @override
  String get customerShippingAddressLine1Label => 'سطر العنوان 1';

  @override
  String get customerShippingAddressLine2Label => 'سطر العنوان 2 (اختياري)';

  @override
  String get customerShippingAddressTerritoryLabel => 'المنطقة';

  @override
  String get customerShippingAddressPincodeLabel => 'الرمز البريدي (اختياري)';

  @override
  String get customerShippingAddressTerritoryRequired => 'يرجى اختيار المنطقة.';

  @override
  String get customerShippingAddressLine1Required => 'سطر العنوان 1 مطلوب.';

  @override
  String get posAmendmentDraftTitle => 'مسودة تعديل الفاتورة';

  @override
  String get posAmendmentDraftMessage =>
      'راجع التغييرات بعناية ثم أرسل التعديل لاستبدال الفاتورة الأصلية.';

  @override
  String get posAmendmentCheckoutBlocked =>
      'إرسال التعديل غير متاح لهذه المسودة. ارجع إلى الطلب وافتح التعديل مرة أخرى.';

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
  String invoiceAddressUpdatedWithShipping(
    Object oldExpense,
    Object newExpense,
  ) {
    return 'تم تحديث العنوان. الشحن: $oldExpense ← $newExpense ج.م';
  }

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

  @override
  String get tripsDeliveryTripsTitle => 'رحلات التوصيل';

  @override
  String get tripsActiveTab => 'نشطة';

  @override
  String get tripsCompletedTab => 'مكتملة';

  @override
  String get tripsCreateTripTitle => 'إنشاء رحلة توصيل';

  @override
  String get tripsCreateTripButton => 'إنشاء رحلة';

  @override
  String tripsCreateTripFailed(Object error) {
    return 'فشل إنشاء الرحلة: $error';
  }

  @override
  String get tripsOrdersLabel => 'الطلبات';

  @override
  String get tripsTotalAmount => 'إجمالي المبلغ';

  @override
  String get tripsTotalShipping => 'إجمالي الشحن';

  @override
  String tripsSameTerritory(Object territory) {
    return 'نفس المنطقة: $territory';
  }

  @override
  String get tripsSelectCourier => 'اختر الساعي';

  @override
  String get tripsNoTrips => 'لا توجد رحلات';

  @override
  String tripsOrdersCount(Object count) {
    return '$count طلب';
  }

  @override
  String get tripsDoubleShippingLabel => 'شحن مضاعف';

  @override
  String get tripsNotesLabel => 'ملاحظات';

  @override
  String get tripsMarkTripAsDeliveredTitle => 'تعليم الرحلة كمسلمة';

  @override
  String tripsMarkTripAsDeliveredContent(Object tripName, Object count) {
    return 'تعليم \"$tripName\" مع $count طلبات كمسلمة؟';
  }

  @override
  String tripsTripMarkedAsDelivered(Object tripName) {
    return 'تم تعليم $tripName كمسلمة';
  }

  @override
  String tripsFailed(Object error) {
    return 'فشل: $error';
  }

  @override
  String get tripsSendForDeliveryTitle => 'إرسال للتوصيل';

  @override
  String tripsSendForDeliveryContent(Object count, Object courierName) {
    return 'إرسال $count طلبات للتوصيل؟\n\nالساعي: $courierName';
  }

  @override
  String get tripsSentForDeliverySuccess => 'تم إرسال الرحلة للتوصيل';

  @override
  String get tripsMarkAsDeliveredButton => 'تعليم كمسلمة';

  @override
  String tripsMarkAllAsDeliveredContent(Object count) {
    return 'تعليم جميع $count طلبات كمسلمة؟\n\nسيؤدي ذلك إلى إتمام الرحلة.';
  }

  @override
  String get tripsTripMarkedSuccess => 'تم تعليم الرحلة كمسلمة';

  @override
  String get tripsSending => 'جارٍ الإرسال...';

  @override
  String get tripsMarking => 'جارٍ التعليم...';

  @override
  String tripsSubTerritoryRequired(Object invoices) {
    return 'يرجى اختيار منطقة فرعية للطلبات التالية قبل إنشاء رحلة: $invoices';
  }

  @override
  String tripsInvoicesCount(Object count) {
    return 'الفواتير ($count)';
  }

  @override
  String get subTerritorySelectTitle => 'اختر المنطقة الفرعية';

  @override
  String subTerritoryForTerritory(Object territory) {
    return 'لـ $territory';
  }

  @override
  String get subTerritoryNoResults => 'لم يتم العثور على مناطق فرعية';

  @override
  String get subTerritoryLoadFailed => 'تعذر تحميل المناطق الفرعية';

  @override
  String get customShippingBadgePending => 'الشحن المخصص قيد الانتظار';

  @override
  String get customShippingBadgeApproved => 'تمت الموافقة على الشحن المخصص';

  @override
  String customShippingBadgeAmount(Object amount) {
    return 'شحن مخصص $amount';
  }

  @override
  String get customShippingBadgeRejected => 'تم رفض الشحن المخصص';

  @override
  String get returnBadgeFull => 'مرتجع بالكامل';

  @override
  String get returnBadgePartial => 'مرتجع جزئي';

  @override
  String returnBadgeFullAmount(Object amount) {
    return 'مرتجع بالكامل $amount';
  }

  @override
  String returnBadgePartialAmount(Object amount) {
    return 'مرتجع جزئي $amount';
  }

  @override
  String get receiptSelectImageSource => 'اختر مصدر الصورة';

  @override
  String get receiptCamera => 'الكاميرا';

  @override
  String get receiptGallery => 'المعرض';

  @override
  String get receiptUploading => 'جارٍ رفع صورة الإيصال...';

  @override
  String get receiptUploadedSuccess => 'تم رفع صورة الإيصال بنجاح';

  @override
  String get receiptUploadFailed => 'فشل رفع صورة الإيصال';

  @override
  String receiptUploadError(Object error) {
    return 'خطأ في رفع الصورة: $error';
  }

  @override
  String get receiptConfirming => 'جارٍ تأكيد الإيصال...';

  @override
  String get receiptConfirmedSuccess => 'تم تأكيد الإيصال بنجاح';

  @override
  String get receiptConfirmFailed => 'فشل تأكيد الإيصال';

  @override
  String receiptConfirmError(Object error) {
    return 'خطأ في تأكيد الإيصال: $error';
  }

  @override
  String get receiptAllProfiles => 'جميع الملفات الشخصية';

  @override
  String get receiptFilterByPosProfile => 'تصفية حسب ملف نقطة البيع';

  @override
  String get receiptNoReceiptsFound => 'لا توجد إيصالات دفع';

  @override
  String get receiptUploadImageButton => 'رفع صورة الإيصال';

  @override
  String get receiptReplaceImageButton => 'استبدال الصورة';

  @override
  String get receiptRemoveImageButton => 'حذف الصورة';

  @override
  String get receiptRemoveConfirmTitle => 'حذف صورة الإيصال؟';

  @override
  String get receiptRemoveConfirmBody =>
      'سيتم حذف الصورة المرفوعة، ويمكنك رفع صورة جديدة بعد ذلك.';

  @override
  String get receiptRemoving => 'جارٍ حذف صورة الإيصال...';

  @override
  String get receiptRemovedSuccess => 'تم حذف صورة الإيصال';

  @override
  String get receiptRemoveFailed => 'فشل حذف صورة الإيصال';

  @override
  String receiptRemoveError(Object error) {
    return 'خطأ في حذف الصورة: $error';
  }

  @override
  String get receiptPreviewTitle => 'معاينة الإيصال';

  @override
  String get receiptPreviewButton => 'معاينة الإيصال';

  @override
  String get commonPrint => 'طباعة';

  @override
  String get statusCreated => 'تم الإنشاء';

  @override
  String get statusOutForDelivery => 'خارج للتوصيل';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusReturn => 'مرتجع';

  @override
  String get statusReturned => 'مرتجع بالكامل';

  @override
  String get statusReturnedToSender => 'تم الإرجاع إلى المرسل';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusUnpaid => 'غير مدفوع';

  @override
  String get statusOverdue => 'متأخر';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusUnconfirmed => 'غير مؤكد';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusPendingApproval => 'قيد الاعتماد';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get kanbanNoInvoices => 'مفيش فواتير';

  @override
  String get kanbanTripCreatedSuccess => 'تم إنشاء رحلة التوصيل بنجاح';

  @override
  String kanbanPartOfTripWarning(Object tripName) {
    return 'هذا الطلب جزء من رحلة $tripName. أرسل الرحلة كاملة للتوصيل من شاشة الرحلات.';
  }

  @override
  String get kanbanOfdAwaitingInstapay => 'خرج للتوصيل — في انتظار إنستاباي';

  @override
  String kanbanOfdAwaitingInstapayWithCourier(Object courier) {
    return 'خرج للتوصيل مع $courier — في انتظار إنستاباي';
  }

  @override
  String get kanbanDeliveryPartnerCourier => 'ساعي شريك التوصيل';

  @override
  String get kanbanDeliveryPartnerCourierSubtitle =>
      'هذا الساعي تابع لشريك توصيل';

  @override
  String get kanbanRequestCustomShipping => 'طلب شحن مخصص';

  @override
  String get customShippingCurrentShipping => 'الشحن الحالي';

  @override
  String get customShippingRequestedAmount => 'المبلغ المطلوب';

  @override
  String get customShippingReasonHint => 'لماذا تحتاج إلى شحن مخصص...';

  @override
  String get customShippingAmountRequired => 'المبلغ مطلوب';

  @override
  String get customShippingAmountInvalid => 'أدخل مبلغًا موجبًا صحيحًا';

  @override
  String get customShippingReasonRequired =>
      'يرجى كتابة سبب واضح (10 أحرف على الأقل)';

  @override
  String get customShippingSubmitRequest => 'إرسال الطلب';

  @override
  String get kanbanCustomShippingSubmitted => 'تم تقديم طلب الشحن المخصص';

  @override
  String kanbanCustomShippingFailed(Object error) {
    return 'فشل تقديم الطلب: $error';
  }

  @override
  String get settlementPartnerDeliveryTitle => 'تسوية شريك التوصيل';

  @override
  String get settlementPartnerInfoTitle => 'معلومات تسوية الشريك';

  @override
  String settlementPartnerLabel(Object name) {
    return 'الشريك: $name';
  }

  @override
  String get settlementPartnerCollectFull => 'استلم كامل مبلغ الطلب من الساعي:';

  @override
  String get settlementPartnerOnlinePaid =>
      'مدفوع إلكترونياً — لا يوجد تبادل نقدي مع الساعي';

  @override
  String get settlementPartnerCollectFullChip => 'استلام (المبلغ الكامل)';

  @override
  String get settlementNoExchange => 'لا يوجد تبادل نقدي';

  @override
  String settlementPartnerFeeTracked(Object amount) {
    return 'رسوم الشريك (محسوبة): $amount';
  }

  @override
  String get settlementPartnerCollectedFull =>
      'تم تحصيل مبلغ الطلب كاملاً من السائق';

  @override
  String get settlementPartnerFullAmountChip => 'المبلغ الكامل';

  @override
  String get settlementPartnerOnlinePaidInfo => 'دفع إلكتروني — لا تبادل نقدي';

  @override
  String get managerPendingCustomShipping => 'طلبات الشحن المخصص المعلقة';

  @override
  String get managerNoPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String managerReasonLabel(Object reason) {
    return 'السبب: $reason';
  }

  @override
  String get managerCustomShippingApproved => 'تمت الموافقة على الشحن المخصص';

  @override
  String managerApproveFailed(Object error) {
    return 'فشلت الموافقة: $error';
  }

  @override
  String get managerRejectCustomShippingTitle => 'رفض الشحن المخصص';

  @override
  String get managerReject => 'رفض';

  @override
  String get managerCustomShippingRejected => 'تم رفض الشحن المخصص';

  @override
  String managerRejectFailed(Object error) {
    return 'فشل الرفض: $error';
  }

  @override
  String get managerRejectReasonHint => 'سبب الرفض (اختياري)';

  @override
  String get managerPendingCustomShippingLoadFailed =>
      'فشل تحميل طلبات الشحن المخصص المعلقة';

  @override
  String get managerTransferBranchesLoadFailed => 'فشل تحميل فروع التحويل';

  @override
  String get managerApproveDefaultError => 'تعذر اعتماد الطلب.';

  @override
  String get managerRejectDefaultError => 'تعذر رفض الطلب.';

  @override
  String get purchaseNoInvoicesYet => 'لا توجد فواتير شراء بعد';

  @override
  String get purchaseReorderFromSupplier => 'إعادة الطلب من نفس المورد';

  @override
  String get purchaseHistoryTitle => 'سجل المشتريات';

  @override
  String get posCreateCustomer => 'إنشاء عميل';

  @override
  String get posCustomerCreatedSuccess => 'تم إنشاء العميل بنجاح!';

  @override
  String get settingsUserProfileTitle => 'الملف الشخصي';

  @override
  String get settingsRolesTitle => 'الأدوار';

  @override
  String get settingsNoRolesAssigned => 'لا توجد أدوار مخصصة';

  @override
  String get settingsNotificationSettings => 'إعدادات الإشعارات';

  @override
  String get settingsNoAlarmSounds => 'لا توجد أصوات تنبيه متاحة';

  @override
  String get settingsAlarmSoundLabel => 'صوت التنبيه';

  @override
  String settingsFailedToLoadAlarmSounds(Object error) {
    return 'فشل تحميل أصوات التنبيه: $error';
  }

  @override
  String settingsAlarmSoundChanged(Object title) {
    return 'تم تغيير صوت التنبيه إلى $title';
  }

  @override
  String settingsAlarmSoundUnavailable(Object title) {
    return 'لا يمكن استخدام $title على هذا الجهاز. سيتم الإبقاء على صوت التنبيه الافتراضي.';
  }

  @override
  String settingsCustomAlarmSoundSet(Object title) {
    return 'تم تعيين صوت التنبيه المخصص: $title';
  }

  @override
  String get settingsNoFileSelected => 'لم يتم اختيار ملف';

  @override
  String get settingsBrowseCustomSoundFile => 'استعراض ملف صوت مخصص';

  @override
  String get settingsCustomSoundTitle => 'الصوت المخصص';

  @override
  String itemGridStockLimitReached(Object stockQty) {
    return 'تم الوصول لحد المخزون. المتوفر $stockQty فقط.';
  }

  @override
  String get menuDeliveryTrips => 'رحلات التوصيل';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get printingPrintersTitle => 'الطابعات';

  @override
  String get printingUseBitmapReceipt => 'استخدام الإيصال النقطي الجديد';

  @override
  String get printingUseBitmapReceiptHint =>
      'يعرض الإيصال الكامل كصورة ويساعد في حل مشاكل العربية والبيانات الناقصة والنص غير المقروء.';

  @override
  String kanbanOrdersSelectedCount(int count) {
    return '$count طلبات محددة';
  }

  @override
  String get loginModeDialogTitle => 'اختر وضع الدخول';

  @override
  String get loginModeLineManager => 'مدير خط';

  @override
  String get loginModeLineManagerDesc =>
      'تخطي فتح الوردية — إدارة العمليات مباشرة';

  @override
  String get loginModeEmployee => 'موظف';

  @override
  String get loginModeEmployeeDesc => 'فتح وردية قبل بدء العمل';

  @override
  String get customerSearchByPhone => '...بحث برقم الهاتف';

  @override
  String get customerSearchByName => '...بحث باسم العميل';

  @override
  String get quickAddCustomerTitle => 'إضافة عميل سريع';

  @override
  String get quickAddCustomerTap => 'اضغط لإنشاء عميل جديد';

  @override
  String get customerNameLabel => 'اسم العميل *';

  @override
  String get customerNameRequired => 'اسم العميل مطلوب';

  @override
  String get customerTypeLabel => 'نوع العميل';

  @override
  String get customerTypeIndividual => 'فرد';

  @override
  String get customerTypeCompany => 'شركة';

  @override
  String get customerGroupLabel => 'مجموعة العميل';

  @override
  String get customerGroupRequired => 'يرجى اختيار مجموعة العميل';

  @override
  String get mobileNumberLabel => 'رقم الهاتف *';

  @override
  String get mobileNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get secondaryPhoneLabel => 'هاتف ثانوي (اختياري)';

  @override
  String get secondaryPhoneHint => 'رقم تواصل إضافي';

  @override
  String get locationLinkLabel => 'رابط الموقع (اختياري)';

  @override
  String get locationLinkHint => 'رابط خرائط جوجل، إلخ.';

  @override
  String get locationLinkFieldLabel => 'رابط الموقع';

  @override
  String get locationLinkPasteHint =>
      'الصق رابط خرائط جوجل أو 30.0444, 31.2357';

  @override
  String get locationLinkChecking => 'بنراجع الموقع…';

  @override
  String get locationLinkConfirmed => 'الموقع اتأكد';

  @override
  String get locationLinkUnconfirmed => 'الموقع لسه ما اتأكدش';

  @override
  String get locationLinkClear => 'امسح رابط الموقع';

  @override
  String get locationLinkRetry => 'راجع تاني';

  @override
  String locationLinkDistanceKm(Object value) {
    return '$value كم من الفرع';
  }

  @override
  String locationLinkDistanceMeters(Object value) {
    return '$value متر من الفرع';
  }

  @override
  String get locationLinkErrorUnrecognized =>
      'ده مش شكل رابط خرائط. الصق رابط من خرائط جوجل أو إحداثيات زي 30.0444, 31.2357.';

  @override
  String get locationLinkErrorUnresolved =>
      'مقدرناش نطلع موقع من الرابط ده. افتحه في الخرائط وشيره تاني والصق الرابط الجديد.';

  @override
  String locationLinkErrorTooFar(Object distance) {
    return 'النقطة دي $distance — بعيدة أوي على إنها عنوان توصيل. راجع الرابط.';
  }

  @override
  String get locationLinkErrorNetwork => 'مقدرناش نراجع الموقع. جرب تاني.';

  @override
  String get detailedAddressRequired => 'العنوان التفصيلي *';

  @override
  String get detailedAddressOptional => 'العنوان التفصيلي (اختياري)';

  @override
  String get addressOptionalPartner => 'اختياري عند اختيار شريك مبيعات';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get territoryLabel => 'المنطقة *';

  @override
  String get territorySelectRequired => 'يرجى اختيار منطقة';

  @override
  String get territoryLoadFailed => 'فشل تحميل المناطق';

  @override
  String get unknownTerritory => 'منطقة غير معروفة';

  @override
  String get customerCreateFailed => 'فشل إنشاء العميل';

  @override
  String get authUsernameLabel => 'اسم المستخدم';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authInvalidCredentials => 'بيانات الاعتماد غير صحيحة';

  @override
  String get authCannotReachServer =>
      'تعذر الوصول إلى الخادم. تحقق من شبكة Wi-Fi أو الـ VPN وعنوان الخادم ثم حاول مرة أخرى.';

  @override
  String get authConnectionFailed =>
      'فشل الاتصال. يرجى التحقق من الشبكة وتوفر الخادم.';

  @override
  String get authLoginFailed => 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get menuReports => 'التقارير';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get reportsFinalProducts => 'المنتجات النهائية';

  @override
  String get reportsFinalProductsDesc =>
      'جرد المخزون حسب المستودع للأصناف المتوسطة والكبيرة';

  @override
  String get reportsMaterials => 'المواد والمستهلكات';

  @override
  String get reportsMaterialsDesc =>
      'المواد الخام والتجميعات الفرعية والمستهلكات';

  @override
  String get reportsRawMaterials => 'المواد الخام';

  @override
  String get reportsSubAssemblies => 'التجميعات الفرعية';

  @override
  String get reportsConsumables => 'المستهلكات';

  @override
  String get reportsItemName => 'الصنف';

  @override
  String get reportsItemGroup => 'المجموعة';

  @override
  String get reportsTotal => 'الإجمالي';

  @override
  String get reportsNoData => 'لا توجد بيانات';

  @override
  String get reportsRetry => 'إعادة المحاولة';

  @override
  String get reportsComingSoon => 'قريباً';

  @override
  String get reportsFrom => 'من';

  @override
  String get reportsTo => 'إلى';

  @override
  String get reportsRangeThisMonth => 'هذا الشهر';

  @override
  String get reportsRangeLast30Days => 'آخر 30 يوماً';

  @override
  String get reportsRangeLast90Days => 'آخر 90 يوماً';

  @override
  String get reportShippingTitle => 'تحليلات الشحن';

  @override
  String get reportShippingSubtitle =>
      'تكلفة التوصيل وتسويات المندوبين وأرباح الشحن';

  @override
  String get reportInventoryTitle => 'ذكاء المخزون';

  @override
  String get reportInventorySubtitle =>
      'سرعة دوران المخزون والأصناف الحرجة والأكثر حركة';

  @override
  String get reportProductTitle => 'تحليلات المنتجات';

  @override
  String get reportProductSubtitle =>
      'الإيرادات والربح الإجمالي والأكثر مبيعاً حسب المنتج';

  @override
  String get reportCustomerTitle => 'تحليلات العملاء';

  @override
  String get reportCustomerSubtitle =>
      'الشرائح والاحتفاظ والعملاء المعرضون للخطر';

  @override
  String get reportExecutiveTitle => 'النظرة التنفيذية';

  @override
  String get reportExecutiveSubtitle => 'أهم مؤشرات الأداء عبر النشاط بالكامل';

  @override
  String get reportB2bTitle => 'مبيعات وعملاء الجملة';

  @override
  String get reportB2bSubtitle => 'إيرادات الجملة وخط الأنابيب وصحة العملاء';

  @override
  String get reportNoData => 'لا توجد بيانات لهذه الفترة';

  @override
  String get reportError => 'تعذّر تحميل التقرير';

  @override
  String get reportAlerts => 'التنبيهات';

  @override
  String get reportShipKpiTotalOrders => 'إجمالي الطلبات';

  @override
  String get reportShipKpiDeliveryOrders => 'طلبات التوصيل';

  @override
  String get reportShipKpiPickupOrders => 'طلبات الاستلام';

  @override
  String get reportShipKpiExpense => 'مصروف الشحن';

  @override
  String get reportShipKpiIncome => 'إيراد التوصيل';

  @override
  String get reportShipKpiNetPl => 'صافي الربح/الخسارة';

  @override
  String get reportShipKpiAvgCost => 'متوسط التكلفة لكل طلب';

  @override
  String get reportShipKpiPendingOverrides => 'التعديلات المعلقة';

  @override
  String get reportShipKpiUnsettled => 'غير مسوّى';

  @override
  String get reportCostByTerritory => 'التكلفة حسب المنطقة';

  @override
  String get reportCostBySubTerritory => 'التكلفة حسب المنطقة الفرعية';

  @override
  String get reportCostByBranch => 'التكلفة حسب الفرع';

  @override
  String get reportCostByCourier => 'التكلفة حسب المندوب';

  @override
  String get reportShippingOverrides => 'تعديلات الشحن';

  @override
  String get reportDoubleShipping => 'أثر ازدواج الشحن';

  @override
  String get reportDailyTrend => 'الاتجاه اليومي';

  @override
  String get reportPickupVsDelivery => 'الاستلام مقابل التوصيل';

  @override
  String get reportUnsettledBalances => 'أرصدة المندوبين غير المسوّاة';

  @override
  String get reportPickupDeliveryTrend => 'اتجاه الاستلام / التوصيل';

  @override
  String get reportInvKpiStockItems => 'أصناف المخزون';

  @override
  String get reportInvKpiCritical => 'حرجة';

  @override
  String get reportInvKpiWatch => 'قائمة المراقبة';

  @override
  String get reportInvKpiSlow => 'بطيئة الحركة';

  @override
  String get reportInvKpiOverstock => 'مخزون زائد';

  @override
  String get reportInvKpiStockValue => 'قيمة المخزون';

  @override
  String get reportStockVelocity => 'سرعة دوران المخزون';

  @override
  String get reportTopMovers => 'الأكثر حركة';

  @override
  String get reportRestockAlerts => 'تنبيهات إعادة التخزين';

  @override
  String get reportCriticalItems => 'حرجة';

  @override
  String get reportWatchList => 'قائمة المراقبة';

  @override
  String get reportSlowMovers => 'بطيئة الحركة';

  @override
  String get reportOverstocked => 'مخزون زائد';

  @override
  String get reportTopSellers => 'الأكثر مبيعاً';

  @override
  String get reportKpiTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get reportKpiTotalOrders => 'إجمالي الطلبات';

  @override
  String get reportKpiGrossProfit => 'إجمالي الربح';

  @override
  String get reportKpiGrossMargin => 'هامش الربح الإجمالي';

  @override
  String get reportKpiAov => 'متوسط قيمة الطلب';

  @override
  String get reportKpiBestSeller => 'الأكثر مبيعاً';

  @override
  String get reportKpiTopTerritory => 'أعلى منطقة';

  @override
  String get reportRevenueByType => 'الإيرادات حسب النوع';

  @override
  String get reportTopProducts => 'أفضل المنتجات';

  @override
  String get reportByTerritory => 'حسب المنطقة';

  @override
  String get reportRevenueTrend => 'اتجاه الإيرادات';

  @override
  String get reportBundleComposition => 'تكوين الباقات';

  @override
  String get reportKpiTotalCustomers => 'إجمالي العملاء';

  @override
  String get reportKpiActive => 'نشط';

  @override
  String get reportKpiNew => 'جديد';

  @override
  String get reportKpiRepeatRate => 'معدل تكرار الشراء';

  @override
  String get reportKpiChampions => 'العملاء المميزون';

  @override
  String get reportKpiAtRisk => 'معرضون للخطر';

  @override
  String get reportKpiLost => 'مفقودون';

  @override
  String get reportSegmentDistribution => 'توزيع الشرائح';

  @override
  String get reportSegmentDetail => 'تفاصيل الشريحة';

  @override
  String get reportTopCustomers => 'أفضل العملاء';

  @override
  String get reportAtRiskWinBack => 'المعرضون للخطر / الاستعادة';

  @override
  String get reportNewCustomerAcquisition => 'اكتساب عملاء جدد';

  @override
  String get reportKpiRevenue => 'الإيرادات';

  @override
  String get reportKpiOrders => 'الطلبات';

  @override
  String get reportKpiNetShippingPl => 'صافي ربح/خسارة الشحن';

  @override
  String get reportKpiCustomers => 'العملاء';

  @override
  String get reportKpiCriticalStock => 'المخزون الحرج';

  @override
  String get reportProductMix => 'مزيج المنتجات';

  @override
  String get reportCustomerSegments => 'شرائح العملاء';

  @override
  String get reportTopTerritories => 'أعلى المناطق';

  @override
  String get reportKpiB2bRevenue => 'إيرادات الجملة';

  @override
  String get reportKpiB2bOrders => 'طلبات الجملة';

  @override
  String get reportKpiActiveClients => 'العملاء النشطون';

  @override
  String get reportKpiNewClients => 'عملاء جدد';

  @override
  String get reportKpiReorderDue => 'إعادة الطلب مستحقة';

  @override
  String get reportSalesPipeline => 'خط أنابيب المبيعات';

  @override
  String get reportTopClients => 'أفضل العملاء';

  @override
  String get reportRevenueByPolicy => 'الإيرادات حسب السياسة التجارية';

  @override
  String get reportClientsByGroup => 'العملاء حسب المجموعة';

  @override
  String get reportReorderDue => 'إعادة الطلب مستحقة';

  @override
  String get reportAtRiskClients => 'العملاء المعرضون للخطر';

  @override
  String get reportConversion => 'التحويل';

  @override
  String get menuMasterOrders => 'جميع الطلبات';

  @override
  String get masterOrdersTitle => 'جميع الطلبات';

  @override
  String get masterOrdersSearchHint => 'بحث برقم الطلب أو العميل...';

  @override
  String get masterOrdersNoResults => 'لا توجد طلبات';

  @override
  String get masterOrdersClearFilters => 'مسح الفلاتر';

  @override
  String masterOrdersResultCount(int count) {
    return '$count طلب';
  }

  @override
  String get masterOrdersFilterStatus => 'الحالة';

  @override
  String get masterOrdersFilterBranch => 'الفرع';

  @override
  String get masterOrdersFilterPayment => 'الدفع';

  @override
  String get masterOrdersFilterDate => 'نطاق التاريخ';

  @override
  String get masterOrdersFilterDateFrom => 'من';

  @override
  String get masterOrdersFilterDateTo => 'إلى';

  @override
  String get masterOrdersOutstanding => 'المتبقي';

  @override
  String get masterOrdersCurrency => 'ج.م';

  @override
  String get menuShiftMonitor => 'متابعة الشيفتات';

  @override
  String get shiftMonitorTitle => 'متابعة شيفتات نقاط البيع';

  @override
  String get shiftMonitorAccessRequired => 'يلزم صلاحية مدير';

  @override
  String get shiftMonitorAccessDeniedBody =>
      'هذه الصفحة متاحة لأدوار JARZ Manager وما فوق فقط.';

  @override
  String get shiftMonitorFiltersTitle => 'الفلاتر';

  @override
  String get shiftMonitorToday => 'اليوم';

  @override
  String get shiftMonitorLast7Days => 'آخر 7 أيام';

  @override
  String get shiftMonitorCustomRange => 'فترة مخصصة';

  @override
  String get shiftMonitorPickDateRange => 'اختر الفترة';

  @override
  String shiftMonitorDateRangeValue(Object from, Object to) {
    return '$from إلى $to';
  }

  @override
  String get shiftMonitorProfileFilter => 'ملف نقطة البيع';

  @override
  String get shiftMonitorStatusFilter => 'الحالة';

  @override
  String get shiftMonitorStatusAll => 'الكل';

  @override
  String get shiftMonitorStatusOpen => 'مفتوح';

  @override
  String get shiftMonitorStatusClosed => 'مغلق';

  @override
  String get shiftMonitorNoData => 'لا توجد شيفتات للفلاتر المحددة.';

  @override
  String get shiftMonitorOpenCount => 'الشيفتات المفتوحة';

  @override
  String get shiftMonitorClosedCount => 'الشيفتات المغلقة';

  @override
  String get shiftMonitorDiscrepancyCount => 'حالات الفرق';

  @override
  String get shiftMonitorDiscrepancyTotal => 'إجمالي الفروق';

  @override
  String shiftMonitorLatestStart(Object value) {
    return 'آخر بداية: $value';
  }

  @override
  String shiftMonitorShiftCount(Object count) {
    return '$count شيفت';
  }

  @override
  String get shiftMonitorOpenedAt => 'وقت الفتح';

  @override
  String get shiftMonitorOpenedBy => 'تم الفتح بواسطة';

  @override
  String get shiftMonitorClosedAt => 'وقت الإغلاق';

  @override
  String get shiftMonitorClosedBy => 'تم الإغلاق بواسطة';

  @override
  String get shiftMonitorCashAccount => 'الحساب النقدي';

  @override
  String get shiftMonitorOpeningCash => 'نقدية البداية';

  @override
  String get shiftMonitorExpectedClosingCash => 'إقفال متوقع';

  @override
  String get shiftMonitorActualClosingCash => 'إقفال فعلي';

  @override
  String get shiftMonitorDifference => 'الفرق';

  @override
  String get shiftMonitorDifferenceSurplus => 'زيادة';

  @override
  String get shiftMonitorDifferenceShortage => 'عجز';

  @override
  String get shiftMonitorNoDiscrepancy => 'لا يوجد فرق';

  @override
  String get shorebirdUpdateBannerMessage =>
      'يتوفر إصدار جديد — أغلق التطبيق تمامًا ثم أعد فتحه لتطبيقه.';

  @override
  String get aboutRestartInstruction =>
      'أغلق التطبيق تماماً وأعد فتحه لتطبيق التحديث المُنزَّل.';

  @override
  String get aboutPatchPending => 'التصحيح المُعلَّق (بعد إعادة التشغيل)';

  @override
  String get menuLeads => 'العملاء المحتملون';

  @override
  String get leadFieldEmail => 'البريد الإلكتروني';

  @override
  String get leadFieldSource => 'المصدر';

  @override
  String get leadFieldTerritory => 'المنطقة';

  @override
  String get leadB2bStage => 'مرحلة B2B';

  @override
  String get leadFitScore => 'درجة الملاءمة';

  @override
  String get b2bMoveTo => 'نقل إلى';

  @override
  String get shiftMonitorForceCloseAction => 'إقفال هذه الوردية';

  @override
  String shiftMonitorForceCloseTitle(String user) {
    return 'إقفال وردية $user';
  }

  @override
  String shiftMonitorForceCloseIntro(String user, String branch) {
    return 'أنت تقوم بإقفال وردية فتحها $user في $branch. أدخل النقدية المعدودة فعليًا في الدرج — أي فرق هيتسجل في حساب العجز/الزيادة، زي الإقفال العادي بالظبط.';
  }

  @override
  String get shiftMonitorForceCloseReasonLabel => 'السبب (مطلوب)';

  @override
  String get shiftMonitorForceCloseReasonHint =>
      'مثلاً: الموظف مشي من غير ما يقفل';

  @override
  String get shiftMonitorForceCloseReasonRequired =>
      'من فضلك اكتب سبب إقفال وردية شخص تاني.';

  @override
  String shiftMonitorForceCloseCountLabel(String mode) {
    return 'المبلغ المعدود — $mode';
  }

  @override
  String shiftMonitorForceCloseCountRequired(String mode) {
    return 'أدخل المبلغ المعدود لـ $mode.';
  }

  @override
  String shiftMonitorForceCloseExpected(String amount) {
    return 'المتوقع من النظام: $amount';
  }

  @override
  String shiftMonitorForceCloseCourierWarning(int transactions, int invoices) {
    return 'الفرع لسه عنده $transactions معاملة مندوب غير مسواة على $invoices طلب. هتفضل مفتوحة بعد الإقفال ولازم تتسوى.';
  }

  @override
  String get shiftMonitorForceCloseCourierAck => 'أنا فاهم وعايز أقفل برضه';

  @override
  String get shiftMonitorForceCloseConfirm => 'إقفال الوردية';

  @override
  String get shiftMonitorForceCloseSuccess => 'تم إقفال الوردية.';

  @override
  String get returnOrderTitle => 'مرتجع الطلب';

  @override
  String get returnOrderLinesLabel => 'الأصناف الراجعة';

  @override
  String returnOrderLineAvailable(String qty) {
    return 'تقدر ترجّع لحد $qty';
  }

  @override
  String returnOrderLineAvailableAfterPrior(String qty, String returned) {
    return 'تقدر ترجّع لحد $qty (اترجع قبل كده $returned)';
  }

  @override
  String get returnOrderLineFullyReturned => 'اترجع بالكامل';

  @override
  String get returnOrderCreditAmountLabel => 'هيتحسب للعميل';

  @override
  String get returnOrderFullNotice =>
      'الطلب راجع بالكامل. البضاعة هترجع للفرع والطلب هيتحسب كله للعميل.';

  @override
  String get returnOrderPartialNotice =>
      'جزء من الطلب راجع. الأصناف المختارة بس هي اللي هتترجع للمخزن وتتحسب للعميل.';

  @override
  String get returnOrderTypeLabel => 'نوع المرتجع';

  @override
  String get returnTypeCustomerReturn => 'العميل رجّع الطلب';

  @override
  String get returnTypeFailedDelivery => 'التوصيل فشل';

  @override
  String get returnTypeDamaged => 'تالف';

  @override
  String get returnTypeWrongItem => 'صنف غلط';

  @override
  String get returnOrderReasonLabel => 'السبب';

  @override
  String get returnOrderReasonRequired => 'من فضلك اكتب سبب رجوع الطلب';

  @override
  String get returnOrderNotesOptional => 'ملاحظات إضافية (اختياري)';

  @override
  String get returnOrderPayCourierTitle => 'ادفع للمندوب أجر الرحلة دي';

  @override
  String get returnOrderPayCourierYes => 'المندوب هياخد أجر التوصيل بتاعه.';

  @override
  String get returnOrderPayCourierNo => 'أجر التوصيل هيتشال من حساب المندوب.';

  @override
  String get returnOrderRefundLabel => 'الفلوس اللي اتحصلت';

  @override
  String get returnOrderRefundCredit => 'تفضل رصيد للعميل';

  @override
  String get returnOrderRefundNow => 'ارجع الفلوس دلوقتي';

  @override
  String get returnOrderRefundUnavailable => 'مفيش فلوس متحصلة عشان تترد.';

  @override
  String get returnOrderConfirmButton => 'تأكيد المرتجع';

  @override
  String get returnOrderProcessing => 'بنعمل المرتجع…';

  @override
  String get returnOrderPreviewFailed => 'مقدرناش نحمّل تفاصيل المرتجع.';

  @override
  String get returnOrderNotAvailable => 'الطلب ده مينفعش يترجع.';

  @override
  String get returnOrderFailed => 'المرتجع ماتمّش.';

  @override
  String get returnOrderSuccess => 'تم المرتجع.';

  @override
  String returnOrderSuccessWithCn(String creditNote) {
    return 'تم المرتجع. اتعمل إشعار دائن $creditNote.';
  }

  @override
  String get menuItemRequests => 'طلبات الأصناف';

  @override
  String get requestsTitle => 'طلبات الأصناف';

  @override
  String get requestsFilterOpen => 'المفتوحة';

  @override
  String get requestsFilterMine => 'طلباتي';

  @override
  String get requestsFilterAll => 'الكل';

  @override
  String get requestsEmptyOpen => 'مفيش حاجة مطلوبة دلوقتي';

  @override
  String get requestsEmptyMine => 'لسه ماطلبتش حاجة';

  @override
  String get requestsEmptyAll => 'مفيش طلبات';

  @override
  String get requestsEmptyHint => 'دوس + عشان تطلب حاجة قربت تخلص.';

  @override
  String get requestsNewTitle => 'اطلب أصناف';

  @override
  String get requestsAddItems => 'ضيف أصناف';

  @override
  String get requestsNeededBy => 'محتاجها قبل';

  @override
  String get requestsNoteLabel => 'ملاحظة (اختياري)';

  @override
  String get requestsNoteHint => 'الماركة، المقاس، الاستعجال';

  @override
  String get requestsSubmit => 'ابعت الطلب';

  @override
  String requestsSubmitted(Object name) {
    return 'الطلب $name اتبعت';
  }

  @override
  String requestsSubmitFailed(Object error) {
    return 'الطلب مابعتش: $error';
  }

  @override
  String get requestsNoItemsYet => 'لسه مفيش أصناف';

  @override
  String requestsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String requestsRequestedBy(Object name) {
    return 'من $name';
  }

  @override
  String get requestsOverdue => 'متأخر';

  @override
  String get requestsStatusPending => 'مستني';

  @override
  String get requestsStatusPartiallyReceived => 'اتشرى جزء';

  @override
  String get requestsStatusReceived => 'اتشرى';

  @override
  String get requestsStatusStopped => 'مرفوض';

  @override
  String get requestsStatusCancelled => 'ملغي';

  @override
  String get requestsStatusOrdered => 'اتطلب';

  @override
  String get requestsReject => 'ارفض';

  @override
  String get requestsRejectTitle => 'ترفض الطلب ده؟';

  @override
  String get requestsRejectReason => 'السبب (اختياري)';

  @override
  String get requestsRejected => 'الطلب اترفض';

  @override
  String get requestsReopen => 'افتحه تاني';

  @override
  String get requestsReopened => 'الطلب اتفتح تاني';

  @override
  String requestsLineProgress(Object received, Object requested, Object uom) {
    return '$received من $requested $uom';
  }

  @override
  String get requestsBranchLabel => 'الفرع';

  @override
  String get purchaseFromRequests => 'من الطلبات';

  @override
  String get purchaseFromRequestsTitle => 'اشتري الأصناف المطلوبة';

  @override
  String get purchaseFromRequestsEmpty => 'مفيش طلبات مفتوحة';

  @override
  String get purchaseFromRequestsHint =>
      'الكميات متملية بالباقي المطلوب. غيّر اللي انت عايزه قبل الإضافة.';

  @override
  String purchaseRequestedQty(Object qty) {
    return 'مطلوب $qty';
  }

  @override
  String purchaseBuyingLess(Object requested, Object buying) {
    return 'مطلوب $requested، هتشتري $buying';
  }

  @override
  String purchaseOnHand(Object qty) {
    return 'المتاح $qty';
  }

  @override
  String purchaseLastPaid(Object rate) {
    return 'آخر سعر $rate';
  }

  @override
  String purchaseAddSelected(Object count) {
    return 'ضيف $count للسلة';
  }

  @override
  String purchaseNeededBy(Object date) {
    return 'محتاجها $date';
  }

  @override
  String get purchaseRequestSources => 'طلبها';

  @override
  String get purchaseUrgent => 'مستعجل';

  @override
  String get purchasePaymentCredit => 'على الحساب (تدفع بعدين)';

  @override
  String get purchasePaymentCreditSubtitle => 'هيفضل رصيد مستحق للمورد';

  @override
  String get purchaseBillNoLabel => 'رقم فاتورة المورد';

  @override
  String get purchaseBillNoHint => 'من فاتورة المورد نفسها';

  @override
  String get purchaseBillDateLabel => 'تاريخ الفاتورة';

  @override
  String get purchaseTaxesLabel => 'الضرايب';

  @override
  String get purchaseTaxesNone => 'بدون ضريبة';

  @override
  String get purchaseNoVat => 'بدون ضريبة قيمة مضافة';

  @override
  String purchaseVatValue(Object amount) {
    return 'ض.ق.م: $amount';
  }

  @override
  String purchaseNetTotalValue(Object amount) {
    return 'الصافي: $amount';
  }

  @override
  String get purchaseNewSupplier => 'مورد جديد';

  @override
  String get purchaseNewSupplierName => 'اسم المورد';

  @override
  String get purchaseNewSupplierGroup => 'مجموعة المورد';

  @override
  String get purchaseNewSupplierPhone => 'التليفون (اختياري)';

  @override
  String purchaseSupplierCreated(Object name) {
    return 'المورد $name اتعمل';
  }

  @override
  String get purchaseSubmitting => 'بيعمل الشراء';

  @override
  String get purchaseOutstandingLabel => 'المستحق';

  @override
  String get purchasePayNow => 'ادفع دلوقتي';

  @override
  String purchasePaid(Object entry) {
    return 'الدفع اتسجل ($entry)';
  }

  @override
  String get purchaseReturnAction => 'مرتجع للمورد';

  @override
  String get purchaseReturnTitle => 'مرتجع للمورد';

  @override
  String get purchaseReturnReason => 'السبب';

  @override
  String get purchaseReturnQtyLabel => 'كمية المرتجع';

  @override
  String get purchaseReturnSubmit => 'اعمل المرتجع';

  @override
  String purchaseReturned(Object name) {
    return 'المرتجع $name اتعمل';
  }

  @override
  String get purchaseHistoryFilterSupplier => 'المورد';

  @override
  String get purchaseHistoryFilterStatus => 'الحالة';

  @override
  String get purchaseHistoryFilterAll => 'الكل';

  @override
  String get purchaseHistoryFilterClear => 'امسح الفلاتر';

  @override
  String get purchaseHistorySearchHint => 'رقم الفاتورة أو فاتورة المورد';

  @override
  String purchaseItemsInvoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String kanbanRunProgressLabel(int delivered, int total) {
    return '$delivered/$total اتسلّم';
  }

  @override
  String kanbanRunProgressTooltip(String courier, int delivered, int total) {
    return '$courier: سلّم $delivered من $total محطة على البورد';
  }

  @override
  String get kanbanRunProgressComplete => 'خلّص الخط';

  @override
  String kanbanRunStopLabel(int sequence) {
    return 'محطة $sequence';
  }

  @override
  String kanbanRunFailedLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محطات فاتوا',
      one: 'محطة فاتت',
    );
    return '$_temp0';
  }

  @override
  String kanbanRunFailedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محطات اتجرب يوصلهم ومحصلش تسليم',
      one: 'محطة واحدة اتجرب يوصلها ومحصلش تسليم',
    );
    return '$_temp0';
  }

  @override
  String get kanbanRunAttemptFailedLabel => 'التسليم فات';

  @override
  String kanbanRunAttemptFailedTooltip(int attempts) {
    String _temp0 = intl.Intl.pluralLogic(
      attempts,
      locale: localeName,
      other: '$attempts مرات',
      one: 'مرة',
    );
    return 'المحطة دي اتجرب فيها $_temp0 ولسه مش متسلمة';
  }

  @override
  String get menuLiveCourierMap => 'خريطة المندوبين لايف';

  @override
  String get fleetTitle => 'خريطة المندوبين لايف';

  @override
  String get fleetRefreshTooltip => 'حدّث دلوقتي';

  @override
  String fleetUpdatedAgo(String ago) {
    return 'اتحدّث $ago';
  }

  @override
  String get fleetUpdating => 'بيحدّث…';

  @override
  String fleetCouriersOnMap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مندوبين على الخريطة',
      one: 'مندوب واحد على الخريطة',
    );
    return '$_temp0';
  }

  @override
  String get fleetRefreshFailed =>
      'التحديث فشل — المواقع اللي شايفها بتقدم وبتبقى أقدم';

  @override
  String get fleetLegendTitle => 'كل نقطة عمرها قد إيه';

  @override
  String fleetLegendFresh(int minutes) {
    return 'جديدة · أقل من $minutes دقيقة';
  }

  @override
  String fleetLegendAgeing(int from, int to) {
    return 'بتقدم · من $from لـ $to دقيقة';
  }

  @override
  String fleetLegendStale(int minutes) {
    return 'قديمة · أكتر من $minutes دقيقة، متعتمدش عليها';
  }

  @override
  String get fleetFreshnessFresh => 'جديدة';

  @override
  String get fleetFreshnessAgeing => 'بتقدم';

  @override
  String get fleetFreshnessStale => 'قديمة';

  @override
  String get fleetStaleWarning =>
      'فيه مندوبين مبعتوش موقعهم من مدة — اتأكد قبل ما تبعتلهم طلب';

  @override
  String get fleetAgeJustNow => 'دلوقتي';

  @override
  String fleetAgeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'من $minutes دقيقة',
      one: 'من دقيقة',
    );
    return '$_temp0';
  }

  @override
  String fleetAgeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'من $hours ساعة',
      one: 'من ساعة',
    );
    return '$_temp0';
  }

  @override
  String fleetAgeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'من $days يوم',
      one: 'من يوم',
    );
    return '$_temp0';
  }

  @override
  String get fleetAgeUnknown => 'من غير وقت';

  @override
  String get fleetAgeShortNow => 'دلوقتي';

  @override
  String fleetAgeShortMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String fleetAgeShortHours(int hours) {
    return '$hours س';
  }

  @override
  String fleetAgeShortDays(int days) {
    return '$days ي';
  }

  @override
  String get fleetBranchLabel => 'الفرع';

  @override
  String get fleetBranchUnknown => 'من غير فرع';

  @override
  String get fleetLastFixLabel => 'آخر موقع';

  @override
  String get fleetAccuracyLabel => 'الدقة';

  @override
  String fleetAccuracyValue(String meters) {
    return '±$meters متر';
  }

  @override
  String get fleetAccuracyUnknown => 'مش متبعتة';

  @override
  String get fleetEmptyNoCouriersTitle => 'مفيش مندوبين على الشيفت';

  @override
  String get fleetEmptyNoCouriersBody =>
      'محدش داخل على أبليكيشن المندوبين دلوقتي، يعني مفيش حاجة نتابعها. المواقع هتظهر هنا أول ما مندوب يبدأ شيفته.';

  @override
  String get fleetEmptyNoPositionsTitle => 'على الشيفت بس لسه مبعتوش موقع';

  @override
  String get fleetEmptyNoPositionsBody =>
      'المندوبين دول داخلين بس تليفوناتهم مبعتتش موقع. اتأكد إن أبليكيشن المندوب واخد إذن الموقع وإن فيه شبكة.';

  @override
  String fleetEmptyNoPositionsNames(String names) {
    return 'مستنيين: $names';
  }

  @override
  String fleetUnlocatedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مندوبين على الشيفت مبعتوش موقع',
      one: 'مندوب واحد على الشيفت مبعتش موقع',
    );
    return '$_temp0';
  }

  @override
  String get fleetForbiddenTitle => 'للمشرفين بس';

  @override
  String get fleetForbiddenBody =>
      'مواقع المندوبين اللايف متاحة للمديرين والمشرفين بس. إعادة المحاولة مش هتفرق — كلّم مدير يفتحلك الشاشة دي.';

  @override
  String get fleetErrorTitle => 'مش قادر يجيب مواقع المندوبين';

  @override
  String get labelsTitle => 'ليبلات العملاء';

  @override
  String get labelsHelpTooltip => 'الشاشة دي بتشتغل إزاي';

  @override
  String get labelsRefreshTooltip => 'تحديث';

  @override
  String get labelsSetUpCustomer => 'ضيف عميل';

  @override
  String get labelsSetupNothingNew => 'مفيش حاجة جديدة نتابعها';

  @override
  String labelsSetupTrackingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بنتابع دلوقتي $count نكهات',
      one: 'بنتابع دلوقتي نكهة واحدة',
    );
    return '$_temp0';
  }

  @override
  String labelsSetupSkippedSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' ($count كانوا متتابعين قبل كده)',
      one: ' (واحدة كانت متتابعة قبل كده)',
    );
    return '$_temp0';
  }

  @override
  String labelsPrintOrderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرخ اتبعتوا للمطبعة',
      one: 'فرخ واحد اتبعت للمطبعة',
    );
    return '$_temp0';
  }

  @override
  String labelsPrintOrderDueBack(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرخ اتطلبوا — مفروض يرجعوا $date',
      one: 'فرخ واحد اتطلب — مفروض يرجع $date',
    );
    return '$_temp0';
  }

  @override
  String get labelsHelpTitle => 'متابعة الليبلات بتشتغل إزاي';

  @override
  String get labelsHelpRows =>
      'كل نكهة ليها تصميم ليبل خاص بيها، فكل واحدة بتتتابع في سطر لوحدها. الليبلات بتتخصم من المخزن لوحدها أول ما فاتورة تتعمل لعميل إحنا اللي بنطبعله. العملاء اللي بيجيبوا ليبلاتهم بنفسهم بيتعلّموا \"العميل بيطبع\" وعمرهم ما بيتحسبوا.';

  @override
  String labelsHelpSheets(Object medium, Object large) {
    return 'الطباعة بتتطلب بالفرخ — $medium ليبل ميديم أو $large ليبل لارج في الفرخ.';
  }

  @override
  String labelsHelpLeadTime(
    Object min,
    Object max,
    String restDay,
    Object buffer,
  ) {
    return 'الطباعة بتاخد من $min لـ $max يوم شغل من غير $restDay، فالليبل بيتعلّم \"اطبع دلوقتي\" أول ما الرصيد اللي فاضل ميكفيش المدة دي — و\"اطبع قريب\" قبلها بـ $buffer يوم.';
  }

  @override
  String get labelsHelpQuiet =>
      'أول ما الدفعة تروح المطبعة الليبل بيسكت وبيوريك تاريخ رجوعه بدل التنبيه، عشان نفس النقص ميتقالش عليك كل يوم الصبح.';

  @override
  String get labelsHelpAlertsOff =>
      'التنبيهات اليومية مقفولة حاليًا من إعدادات Jarz POS.';

  @override
  String get labelsHelpGotIt => 'تمام';

  @override
  String labelsSummaryUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل لازم يروحوا المطبعة دلوقتي',
      one: 'ليبل واحد لازم يروح المطبعة دلوقتي',
    );
    return '$_temp0';
  }

  @override
  String labelsSummarySoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل محتاجين طباعة قريب',
      one: 'ليبل واحد محتاج طباعة قريب',
    );
    return '$_temp0';
  }

  @override
  String get labelsSummaryNothing => 'مفيش حاجة محتاجة طباعة';

  @override
  String labelsSummaryLeadTime(Object min, Object max, String restDay) {
    return 'الطباعة بتاخد من $min لـ $max يوم شغل · من غير $restDay';
  }

  @override
  String labelsSummaryReadySuffix(String date) {
    return ' · اطلب النهارده، يجهز $date';
  }

  @override
  String get labelsFilterNeedsPrinting => 'محتاج طباعة';

  @override
  String get labelsFilterAll => 'الكل';

  @override
  String get labelsFilterAtPrinter => 'في المطبعة';

  @override
  String get labelsFilterCustomerPrints => 'العميل بيطبع';

  @override
  String labelsFilterWithCount(String text, int count) {
    return '$text ($count)';
  }

  @override
  String get labelsAllLocations => 'كل الأماكن';

  @override
  String get labelsSearchHint => 'دوّر على عميل أو نكهة';

  @override
  String get labelsEmptyNoneTitle => 'لسه مفيش ليبلات متتابعة';

  @override
  String get labelsEmptyNoneBody =>
      'ضيف عملاء الجملة اللي JARZ بتطبعلهم ليبل البرطمانات — ليبل لكل نكهة. بعد كده الرصيد بينزل لوحده مع كل فاتورة ليهم.';

  @override
  String get labelsEmptyEnoughCover => 'كل الليبلات رصيدها مكفي';

  @override
  String get labelsEmptyNoMatch => 'مفيش حاجة مطابقة للفلتر ده';

  @override
  String get labelsShowAll => 'وريني كل الليبلات';

  @override
  String get labelStatusOutOfStock => 'خلصان';

  @override
  String get labelStatusOutOfStockWhy =>
      'مفيش ليبلات خالص. العميل ده مش هينفع يتعبّى.';

  @override
  String get labelStatusPrintNow => 'اطبع دلوقتي';

  @override
  String labelStatusPrintNowWhy(int days) {
    return 'الرصيد هيخلص قبل ما دفعة جديدة توصل ($days يوم شغل).';
  }

  @override
  String get labelStatusPrintSoon => 'اطبع قريب';

  @override
  String get labelStatusPrintSoonWhy =>
      'قرّبنا على النقطة اللي مفيش بعدها رجوع.';

  @override
  String get labelStatusAtPrinter => 'في المطبعة';

  @override
  String get labelStatusAtPrinterWhy => 'فيه دفعة جاية بالفعل.';

  @override
  String get labelStatusOk => 'تمام';

  @override
  String get labelStatusOkWhy => 'الرصيد مريح.';

  @override
  String get labelStatusCustomerPrints => 'العميل بيطبع';

  @override
  String get labelStatusCustomerPrintsWhy =>
      'العميل ده بيجيب ليبلاته بنفسه، فمفيش حاجة بتتحسب.';

  @override
  String get labelStatusUnknown => 'غير معروف';

  @override
  String labelCardFlavours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نكهات',
      one: 'نكهة واحدة',
    );
    return '$_temp0';
  }

  @override
  String labelCardNeedPrintingSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count محتاجين طباعة',
      one: ' · واحدة محتاجة طباعة',
    );
    return '$_temp0';
  }

  @override
  String get labelCardCustomerActions => 'إجراءات العميل';

  @override
  String get labelCardAddFlavour => 'ضيف نكهة';

  @override
  String get labelCardOnHand => 'بالمخزن';

  @override
  String get labelCardOfCover => 'تغطية';

  @override
  String labelCardOrderSheets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اطلب $count فرخ',
      one: 'اطلب فرخ واحد',
    );
    return '$_temp0';
  }

  @override
  String get labelCardOrderBatch => 'اطلب دفعة';

  @override
  String get labelCardCoverOver99 => '‏99+ يوم';

  @override
  String labelCardCoverDays(String days) {
    return '$days يوم';
  }

  @override
  String get labelCardCoverNone => '—';

  @override
  String get labelCardCustomerSupplies => 'العميل بيجيب ليبلاته بنفسه';

  @override
  String labelCardSheetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرخ',
      one: 'فرخ واحد',
    );
    return '$_temp0';
  }

  @override
  String labelCardLabelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل',
      one: 'ليبل واحد',
    );
    return '$_temp0';
  }

  @override
  String labelCardAtPrinter(String what) {
    return '$what في المطبعة';
  }

  @override
  String labelCardOverdueSince(String what, String date) {
    return '$what متأخرين في المطبعة من $date';
  }

  @override
  String labelCardDueBack(String what, String date) {
    return '$what مفروض يرجعوا $date';
  }

  @override
  String labelCardRunsOutAround(String date) {
    return 'هيخلص حوالي $date';
  }

  @override
  String get labelCardNoUsage => 'لسه مفيش استهلاك مسجّل';

  @override
  String labelCardOrderAhead(int days) {
    return 'اطلب قبلها بـ $days يوم شغل';
  }

  @override
  String get labelPrintStatusRequested => 'متطلبة';

  @override
  String get labelPrintStatusPrinting => 'بتتطبع';

  @override
  String get labelPrintStatusReady => 'جاهزة';

  @override
  String get labelPrintStatusReceived => 'اتستلمت';

  @override
  String get labelPrintStatusCancelled => 'ملغية';

  @override
  String get labelMovementConsumed => 'اتستخدمت على برطمانات';

  @override
  String get labelMovementPrintReceived => 'اتستلمت من المطبعة';

  @override
  String get labelMovementScrapped => 'تلفت أو اترمت';

  @override
  String get labelMovementAdjustment => 'تصحيح (+/-)';

  @override
  String get labelDetailFallbackTitle => 'ليبل';

  @override
  String get labelDetailSettingsTooltip => 'إعدادات الليبل';

  @override
  String labelDetailLoadFailed(String error) {
    return 'مش قادر يفتح الليبل ده.\n$error';
  }

  @override
  String labelDetailSentToPrinter(String what) {
    return '$what اتبعتوا للمطبعة';
  }

  @override
  String get labelDetailCountSaved => 'الجرد اتحفظ';

  @override
  String get labelDetailMovementRecorded => 'الحركة اتسجّلت';

  @override
  String labelDetailReceivedAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل اتضافوا للمخزن',
      one: 'ليبل واحد اتضاف للمخزن',
    );
    return '$_temp0';
  }

  @override
  String labelDetailBatchMarked(String status) {
    return 'الدفعة اتعلّمت $status';
  }

  @override
  String get labelDetailBillRecorded =>
      'الفاتورة اتسجّلت — واتعملت فاتورة شراء';

  @override
  String get labelDetailSettingsSaved => 'الإعدادات اتحفظت';

  @override
  String labelDetailStoredAt(String location) {
    return 'متخزّن في $location';
  }

  @override
  String get labelDetailLabelsOnHand => 'ليبل بالمخزن';

  @override
  String get labelDetailDaysOfCover => 'أيام التغطية';

  @override
  String get labelDetailUnknownValue => 'مش معروف';

  @override
  String get labelDetailUsedPerDay => 'الاستهلاك اليومي';

  @override
  String get labelDetailRunsOut => 'هيخلص';

  @override
  String labelDetailUsedInDays(int days) {
    return 'اتستهلك في $days يوم';
  }

  @override
  String get labelDetailStockValue => 'قيمة المخزون';

  @override
  String get labelDetailAvgCost => 'متوسط تكلفة الليبل';

  @override
  String get labelDetailRetired =>
      'الليبل ده متوقف. رجّعه من إعدادات الليبل عشان العد يكمّل.';

  @override
  String get labelDetailCustomerSupplies =>
      'العميل ده بيجيب ليبلاته بنفسه، فمفيش حاجة بتتحسب ولا تنبيهات بتطلع. شغّل \"إحنا بنطبع الليبل ده\" من الإعدادات لو الوضع اتغيّر.';

  @override
  String get labelDetailActionOrder => 'اطلب';

  @override
  String get labelDetailActionCount => 'جرد';

  @override
  String get labelDetailActionRecord => 'سجّل';

  @override
  String get labelDetailSectionBatches => 'دفعات الطباعة';

  @override
  String labelDetailOrderedOn(String date) {
    return 'اتطلبت $date';
  }

  @override
  String labelDetailOverdueSince(String date) {
    return 'متأخرة من $date';
  }

  @override
  String labelDetailDueOn(String date) {
    return 'موعدها $date';
  }

  @override
  String labelDetailReceivedOn(String date) {
    return 'اتستلمت $date';
  }

  @override
  String labelDetailReceivedOnQty(String date, int qty) {
    return 'اتستلمت $date ($qty)';
  }

  @override
  String get labelDetailReceiveIntoStock => 'استلام للمخزن';

  @override
  String get labelDetailMarkPrinting => 'علّمها بتتطبع';

  @override
  String get labelDetailMarkReady => 'علّمها جاهزة';

  @override
  String get labelDetailRecordBill => 'سجّل فاتورة المطبعة';

  @override
  String get labelDetailCancelBatch => 'إلغاء الدفعة';

  @override
  String get labelDetailBilled => 'متفوترة';

  @override
  String labelDetailBilledWithInvoice(String invoice) {
    return 'متفوترة · $invoice';
  }

  @override
  String get labelDetailUnbilled => 'مش متفوترة';

  @override
  String labelDetailUnbilledQuoted(String amount) {
    return 'مش متفوترة · عرض سعر $amount';
  }

  @override
  String get labelDetailPolicyFlavour => 'النكهة';

  @override
  String get labelDetailPolicySize => 'المقاس';

  @override
  String get labelDetailPolicyStoredAt => 'مكان التخزين';

  @override
  String get labelDetailPolicyNotSet => 'مش متحدد';

  @override
  String get labelDetailPolicyMinStock => 'الحد الأدنى للمخزون';

  @override
  String get labelDetailPolicyUsualBatch => 'دفعة الطباعة المعتادة';

  @override
  String get labelDetailPolicyLabelsPerSheet => 'ليبل في الفرخ';

  @override
  String get labelDetailPolicyLabelsPerJar => 'ليبل في البرطمان';

  @override
  String get labelDetailPolicyLeadTime => 'مدة الطباعة';

  @override
  String labelDetailPolicyLeadTimeValue(
    Object min,
    Object max,
    String restDay,
  ) {
    return 'من $min لـ $max يوم شغل (من غير $restDay)';
  }

  @override
  String get labelDetailPolicyLastCounted => 'آخر جرد';

  @override
  String get labelDetailPolicyLastMovement => 'آخر حركة';

  @override
  String get labelDetailSectionSetup => 'الإعداد';

  @override
  String get labelDetailSectionHistory => 'السجل';

  @override
  String get labelDetailHistoryEmpty =>
      'لسه مفيش حاجة متسجّلة. الليبلات بتتخصم لوحدها مع كل فاتورة للعميل ده.';

  @override
  String get labelDetailAutoPosted => 'اتسجّلت أوتوماتيك من الفاتورة';

  @override
  String get labelSheetSupplierOptional => 'مورّد الطباعة (اختياري)';

  @override
  String get labelSheetPrintSupplier => 'مورّد الطباعة';

  @override
  String get labelSheetCountTitle => 'جرد الليبلات';

  @override
  String get labelSheetCountSubtitle =>
      'اكتب اللي موجود فعلًا على الرف. الفرق بيتسجّل في السجل، فالليبل اللي بيقل على طول بيبان كسلسلة تصحيحات مش بيضيع في الساكت.';

  @override
  String get labelSheetCountedQty => 'الكمية المعدودة';

  @override
  String labelSheetSystemShows(int qty) {
    return 'النظام مسجّل حاليًا $qty.';
  }

  @override
  String labelSheetDeltaMore(int count) {
    return '$count أكتر من المسجّل';
  }

  @override
  String labelSheetDeltaFewer(int count) {
    return '$count أقل من المسجّل';
  }

  @override
  String get labelSheetNoteOptional => 'ملاحظة (اختياري)';

  @override
  String get labelSheetNotesOptional => 'ملاحظات (اختياري)';

  @override
  String get labelSheetSaveCount => 'احفظ الجرد';

  @override
  String get labelSheetOrderTitle => 'اطلب دفعة طباعة';

  @override
  String labelSheetLeadPlain(Object min, Object max, String restDay) {
    return 'الطباعة بتاخد من $min لـ $max يوم شغل (من غير $restDay).';
  }

  @override
  String labelSheetLeadReady(
    String date,
    Object min,
    Object max,
    String restDay,
  ) {
    return 'لو اتطلبت النهارده هتجهز حوالي $date — من $min لـ $max يوم شغل، من غير $restDay.';
  }

  @override
  String get labelSheetSheetsToPrint => 'عدد الفروخ للطباعة';

  @override
  String labelSheetSuggestedSheets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المقترح $count فرخ، على أساس الاستهلاك الحالي والدفعة المعتادة.',
      one: 'المقترح فرخ واحد، على أساس الاستهلاك الحالي والدفعة المعتادة.',
    );
    return '$_temp0';
  }

  @override
  String labelSheetSheetsEquals(String sheets, String labels) {
    return '$sheets = $labels';
  }

  @override
  String get labelSheetNetCostOptional => 'التكلفة الصافية (اختياري)';

  @override
  String get labelSheetNetCostQuoteHelper =>
      'السعر اللي المطبعة قالته على الدفعة، قبل الضريبة. الفاتورة نفسها بتتسجّل أول ما توصل.';

  @override
  String get labelSheetSendToPrinter => 'ابعت للمطبعة';

  @override
  String get labelSheetReceiveTitle => 'استلام دفعة';

  @override
  String labelSheetReceiveSubtitle(String name, String ordered) {
    return '$name · المطلوب $ordered';
  }

  @override
  String get labelSheetLabelsReceived => 'الليبلات المستلمة';

  @override
  String get labelSheetReceivedHelper =>
      'عدّل الرقم لو المطبعة سلّمت ناقص. العدد ده بس هو اللي هيتضاف للمخزن.';

  @override
  String get labelSheetAddToStock => 'ضيف للمخزن';

  @override
  String get labelSheetBillTitle => 'سجّل فاتورة المطبعة';

  @override
  String labelSheetBillSubtitle(String name, String ordered) {
    return '$name · $ordered. ده بيعمل فاتورة شراء للمورّد، فالدفعة بتتسجّل في الدفاتر بتكلفتها الحقيقية.';
  }

  @override
  String get labelSheetNetCost => 'التكلفة الصافية';

  @override
  String get labelSheetNetCostBillHelper =>
      'المبلغ اللي المطبعة حاسبته على الدفعة دي، قبل الضريبة.';

  @override
  String get labelSheetBillNoOptional => 'رقم فاتورة المورّد (اختياري)';

  @override
  String get labelSheetRecordBill => 'سجّل الفاتورة';

  @override
  String get labelSheetMovementTitle => 'سجّل حركة';

  @override
  String get labelSheetWhatHappened => 'اللي حصل';

  @override
  String get labelSheetQuantity => 'الكمية';

  @override
  String get labelSheetAdjustmentHelper => 'حط علامة ناقص عشان تقلّل المخزون.';

  @override
  String get labelSheetQtyHelper =>
      'اكتب رقم عادي — الاتجاه بيتحدد من نوع الحركة.';

  @override
  String get labelSheetLabelName => 'اسم الليبل';

  @override
  String get labelSheetWePrint => 'إحنا بنطبع الليبل ده';

  @override
  String get labelSheetWePrintHelp =>
      'لو مقفول يبقى العميل بيجيب ليبلاته بنفسه — بيوقف كل العد والتنبيهات من غير ما يضيّع السجل.';

  @override
  String get labelSheetActive => 'شغّال';

  @override
  String get labelSheetActiveHelp => 'اقفله عشان توقف تصميم مابقاش بيتستخدم.';

  @override
  String get labelSheetStoredAtHelper =>
      'الفرع أو المصنع اللي الليبل ده متخزّن فيه فعلًا.';

  @override
  String get labelSheetUsualBatchSheets => 'الدفعة المعتادة (فروخ)';

  @override
  String get labelSheetLabelsPerSheetHelper =>
      'سيبها 0 عشان تاخد الافتراضي حسب المقاس: 21 ميديم، 18 لارج.';

  @override
  String get labelSheetLabelsPerJarHelper => 'عادةً 1.';

  @override
  String get labelWizardTitle => 'إعداد ليبلات العميل';

  @override
  String get labelWizardStartTracking => 'ابدأ المتابعة';

  @override
  String get labelWizardContinue => 'كمّل';

  @override
  String get labelWizardBack => 'رجوع';

  @override
  String get labelWizardStepCustomer => 'العميل';

  @override
  String get labelWizardStepFlavours => 'النكهات';

  @override
  String labelWizardPickedCount(int count) {
    return 'متختار $count';
  }

  @override
  String get labelWizardStepLocation => 'مكان تخزين الليبلات';

  @override
  String get labelWizardStepConfirm => 'تأكيد';

  @override
  String get labelWizardChange => 'غيّر';

  @override
  String labelWizardCustomerPriceList(String customer, String priceList) {
    return '$customer · قائمة الأسعار: $priceList';
  }

  @override
  String get labelWizardSearchCustomers => 'دوّر على عملاء';

  @override
  String get labelWizardSearching => 'بيدوّر…';

  @override
  String get labelWizardNoCustomers => 'مفيش عملاء شركات مطابقين.';

  @override
  String labelWizardPriceList(String priceList) {
    return 'قائمة الأسعار: $priceList';
  }

  @override
  String labelWizardFlavoursLoadFailed(String error) {
    return 'مش قادر يجيب النكهات.\n$error';
  }

  @override
  String get labelWizardPickCustomerFirst => 'اختار عميل الأول.';

  @override
  String get labelWizardNoFlavours =>
      'مفيش نكهات للعميل ده — لا حاجة في قائمة أسعاره ولا طلبات سابقة.';

  @override
  String get labelWizardSizeOther => 'أخرى';

  @override
  String get labelWizardFlavourHelp =>
      'علّم على كل نكهة JARZ بتطبع ليبلها. واكتب اللي موجود على الرف دلوقتي عشان محدش يبدأ خلصان.';

  @override
  String get labelWizardAlreadyTracked => 'متتابعة بالفعل';

  @override
  String get labelWizardOnPriceList => 'في قائمة الأسعار';

  @override
  String get labelWizardOrderedBefore => 'اتطلبت قبل كده';

  @override
  String get labelWizardLabelsInStock => 'الليبلات الموجودة دلوقتي';

  @override
  String get labelWizardLocationsLoadFailed =>
      'مش قادر يجيب الأماكن — تقدر تحدد مكان لكل ليبل بعدين.';

  @override
  String get labelWizardStoredAtHelper =>
      'الفرع أو المصنع اللي الليبلات دي متخزّنة فيه فعلًا.';

  @override
  String get labelWizardUsualBatchSheets => 'دفعة الطباعة المعتادة (فروخ)';

  @override
  String get labelWizardUsualBatchHelper =>
      'بتتطبق على كل النكهات، وتقدر تغيّرها لكل ليبل بعدين.';

  @override
  String get labelWizardConfirmPriceList => 'قائمة الأسعار';

  @override
  String get labelWizardConfirmUsualBatch => 'الدفعة المعتادة';

  @override
  String get labelWizardSafeToRerun =>
      'النكهات المتتابعة بالفعل مش بتتلمس — تقدر تعيد ده في أي وقت من غير قلق.';

  @override
  String get b2bStageLead => 'عميل محتمل';

  @override
  String get b2bStageQualify => 'تأهيل';

  @override
  String get b2bStageSample => 'عينة';

  @override
  String get b2bStageApproved => 'موافقة';

  @override
  String get b2bStageTrial => 'تجربة';

  @override
  String get b2bStageCheckup => 'متابعة';

  @override
  String get b2bStageActive => 'نشط';

  @override
  String get b2bStageLostOnHold => 'خسران/معلّق';

  @override
  String get leadsTitle => 'العملاء المحتملين';

  @override
  String get leadsMapTitle => 'خريطة العملاء المحتملين';

  @override
  String get leadsMapViewTooltip => 'عرض الخريطة';

  @override
  String get leadsListViewTooltip => 'عرض القايمة';

  @override
  String get leadsRefreshTooltip => 'تحديث';

  @override
  String get leadsAddLead => 'ضيف عميل محتمل';

  @override
  String get leadsStatShowing => 'المعروض';

  @override
  String get leadsStatTierA => 'الفئة A';

  @override
  String get leadsStatBranches => 'الفروع';

  @override
  String get leadsSearchHint => 'دوّر على عميل محتمل…';

  @override
  String get leadsAdvancedFilters => 'فلاتر متقدمة';

  @override
  String get leadsEmptyFiltered => 'مفيش عملاء محتملين مطابقين للفلاتر دي';

  @override
  String leadsDistanceMetres(String value) {
    return '$value م';
  }

  @override
  String leadsDistanceKm(String value) {
    return '$value كم';
  }

  @override
  String get leadsLocationServicesOff =>
      'خدمات الموقع مقفولة. شغّلها من إعدادات الجهاز.';

  @override
  String get leadsLocationBlocked => 'إذن الموقع محظور للتطبيق ده.';

  @override
  String get leadsLocationDenied => 'إذن الموقع اترفض.';

  @override
  String get leadsLocationNoFix => 'مش قادر يحدد موقعك. جرّب تاني وإنت برّه.';

  @override
  String get leadsLocationSettings => 'الإعدادات';

  @override
  String leadsOnMapCount(int count) {
    return '$count على الخريطة';
  }

  @override
  String leadsOnMapWithStages(int count, String stages) {
    return '$count على الخريطة  ·  $stages';
  }

  @override
  String leadsStageSummaryCount(int count) {
    return '$count مراحل';
  }

  @override
  String get leadsHideLegend => 'اخفي المفتاح';

  @override
  String get leadsCategoryLegend => 'مفتاح التصنيفات';

  @override
  String get leadsShowMyLocation => 'وريني موقعي';

  @override
  String leadsBranchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فروع',
      one: 'فرع واحد',
    );
    return '$_temp0';
  }

  @override
  String leadsDistanceAway(String distance) {
    return 'على بعد $distance (خط مستقيم)';
  }

  @override
  String leadsFilterActiveCount(int count) {
    return '$count مفعّلين';
  }

  @override
  String get leadsFilterPipelineStage => 'مرحلة المسار';

  @override
  String get leadsFilterRatingRange => 'نطاق التقييم';

  @override
  String leadsFilterMinReviews(int count) {
    return 'أقل عدد تقييمات: $count';
  }

  @override
  String get leadsFilterMinBranches => 'أقل عدد فروع';

  @override
  String get leadsFilterHasSahel => 'عنده فروع في الساحل';

  @override
  String get leadsFilterSpecialtyOnly => 'سبيشالتي بس';

  @override
  String get leadsFilterTakeawayOnly => 'تيك أواي مؤكد';

  @override
  String get leadsFilterTalabat => 'طلبات';

  @override
  String get leadsFilterTalabatOn => 'على طلبات';

  @override
  String get leadsFilterTalabatOff => 'مش على طلبات';

  @override
  String get leadsTalabatBadge => 'طلبات';

  @override
  String get leadsTalabatRatingFromGoogle =>
      'التقييم من جوجل — مفيش تقييم على طلبات لسه';

  @override
  String get leadsTalabatUnrated => 'موجود على طلبات، لسه من غير تقييم';

  @override
  String get leadsFilterHasPhone => 'عنده تليفون';

  @override
  String get leadsFilterHasInstagram => 'عنده إنستجرام';

  @override
  String get leadsFilterHasWebsite => 'عنده موقع';

  @override
  String get leadsFilterShowNotSuitable => 'وريني غير المناسبين';

  @override
  String get leadsFilterPriceBand => 'شريحة السعر';

  @override
  String get leadsFilterClearAll => 'امسح الكل';

  @override
  String leadsAreaClearCount(int count) {
    return 'امسح ($count)';
  }

  @override
  String get leadsAreaSearchHint => 'دوّر على مناطق';

  @override
  String leadsAreaNoMatch(String query) {
    return 'مفيش منطقة مطابقة لـ \"$query\"';
  }

  @override
  String get leadsAreaAll => 'كل المناطق';

  @override
  String leadsAreaSelectedCount(int count) {
    return '$count مناطق';
  }

  @override
  String leadsMergeConfirmTitle(int count, String survivor) {
    return 'تدمج $count في \"$survivor\"؟';
  }

  @override
  String leadsMergeConfirmBody(String survivor) {
    return 'فروعهم ومناطقهم وأي بيانات ناقصة عند \"$survivor\" هتتنقل ليه. العملاء المدموجين هيفضلوا محفوظين للمراجعة بس هيخرجوا من الكتالوج ومن بورد المسار.';
  }

  @override
  String leadsMergeFailed(String error) {
    return 'الدمج فشل: $error';
  }

  @override
  String get leadsMergeTitle => 'دمج المكرر';

  @override
  String leadsMergeSubtitle(String name) {
    return 'ادمج سجلات تانية لنفس البراند في \"$name\".';
  }

  @override
  String get leadsMergeSearchHint =>
      'دوّر بالاسم، أو سيبها فاضية عشان تشوف اقتراحات';

  @override
  String leadsMergeAction(int count) {
    return 'ادمج $count';
  }

  @override
  String get leadsMergeNoDuplicates =>
      'مفيش مكرر محتمل. دوّر بالاسم لو تعرف واحد.';

  @override
  String get leadsMergeNoMatch => 'مفيش عملاء محتملين مطابقين للبحث ده.';

  @override
  String get leadsMergedSuccess => 'العملاء المحتملين اتدمجوا';

  @override
  String get leadsAllStages => 'كل المراحل';

  @override
  String get leadsFilterTitle => 'الفلاتر';

  @override
  String get leadsFilterAreas => 'المناطق';

  @override
  String get leadsFilterAny => 'أي';

  @override
  String get leadsFilterAll => 'الكل';

  @override
  String get leadsFilterDone => 'تمام';

  @override
  String get leadDetailTitle => 'عميل محتمل';

  @override
  String leadDetailBranchesCount(int count) {
    return 'الفروع ($count)';
  }

  @override
  String get leadDetailStatusNotes => 'الحالة والملاحظات';

  @override
  String get leadDetailStatusField => 'الحالة';

  @override
  String get leadDetailCategoryField => 'التصنيف';

  @override
  String get leadDetailCategoryNone => 'بدون';

  @override
  String get leadDetailUpdated => 'العميل المحتمل اتحدّث';

  @override
  String leadDetailFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get leadDetailFitScoreUpdated => 'درجة الملاءمة اتحدّثت';

  @override
  String leadDetailScoreOutOf(int score) {
    return '$score / 100';
  }

  @override
  String leadDetailStageUpdated(String stage) {
    return 'المرحلة اتغيّرت لـ $stage';
  }

  @override
  String get leadDetailReasonTitle => 'السبب';

  @override
  String get leadDetailReasonHint => 'ليه ده خسران / معلّق؟';

  @override
  String get leadDetailNotSuitable => 'غير مناسب';

  @override
  String leadDetailByWhom(String user) {
    return 'بواسطة $user';
  }

  @override
  String leadDetailOnDate(String date) {
    return 'بتاريخ $date';
  }

  @override
  String get leadDetailMarkedNotSuitable => 'اتعلّم غير مناسب';

  @override
  String get leadDetailRestoreTitle => 'ترجّع العميل المحتمل؟';

  @override
  String get leadDetailRestoreBody =>
      'ده بيشيل حكم \"غير مناسب\" ويرجّع العميل للكتالوج عند مرحلة \"عميل محتمل\".';

  @override
  String get leadDetailRestore => 'رجّع';

  @override
  String get leadDetailRestored => 'العميل المحتمل رجع';

  @override
  String get leadDetailSuitability => 'الملاءمة';

  @override
  String get leadDetailSuitabilityMarked =>
      'العميل ده اتحكم عليه إنه غير مناسب بعد معاينة يدوية. مخفي من الكتالوج وبرّه بورد المسار.';

  @override
  String get leadDetailSuitabilityPrompt =>
      'عاينت العميل ده ولقيته مش مستاهل؟ علّمه غير مناسب عشان يخرج من كتالوج الشغل.';

  @override
  String get leadDetailRestoreLead => 'رجّع العميل المحتمل';

  @override
  String get leadDetailMarkNotSuitable => 'علّمه غير مناسب';

  @override
  String get leadDetailNotesOptional => 'ملاحظات (اختياري)';

  @override
  String get leadDetailInspectionHint => 'المعاينة أظهرت إيه؟';

  @override
  String get leadDetailMergedAway => 'اتدمج في عميل محتمل تاني';

  @override
  String get leadDetailOpenSurvivor => 'افتح العميل الأصلي';

  @override
  String get leadDetailDuplicates => 'المكرر';

  @override
  String get leadDetailDuplicatesBody =>
      'الكتالوج اتبنى لكل فرع لوحده، فالبراند الواحد ممكن يظهر كذا عميل محتمل. ادمجهم هنا عشان كل الفروع تبقى على سجل واحد.';

  @override
  String get leadDetailAddresses => 'العناوين';

  @override
  String get leadDetailPrimaryAddress => 'العنوان الأساسي';

  @override
  String get leadDetailShippingAddress => 'عنوان الشحن';

  @override
  String leadDetailAddressSaved(String title) {
    return '$title اتحفظ';
  }

  @override
  String leadDetailSaveAddress(String title) {
    return 'احفظ $title';
  }

  @override
  String get leadFieldAddressLine1 => 'العنوان سطر 1';

  @override
  String get leadFieldAddressLine2 => 'العنوان سطر 2';

  @override
  String get leadFieldCity => 'المدينة';

  @override
  String get leadFieldState => 'المحافظة';

  @override
  String get leadFieldCountry => 'الدولة';

  @override
  String get leadFieldPincode => 'الرمز البريدي';

  @override
  String get leadFieldPhone => 'التليفون';

  @override
  String get leadFormEditTitle => 'تعديل عميل محتمل';

  @override
  String get leadFormSaved => 'العميل المحتمل اتحفظ';

  @override
  String get leadFormNewCategory => 'تصنيف جديد';

  @override
  String get leadFormCategoryName => 'اسم التصنيف';

  @override
  String get leadFormAddCategory => 'ضيف تصنيف';

  @override
  String get leadFormLeadName => 'اسم العميل المحتمل *';

  @override
  String get leadFormCompanyName => 'اسم الشركة';

  @override
  String get leadFormPrimaryArea => 'المنطقة الأساسية';

  @override
  String get leadFormPriceBand => 'شريحة السعر';

  @override
  String leadFormFitScoreRange(String label) {
    return '$label (0–100)';
  }

  @override
  String get leadFormSaveChanges => 'احفظ التعديلات';

  @override
  String get leadFormCreate => 'اعمل عميل محتمل';

  @override
  String get leadFormCardBrand => 'البراند';

  @override
  String get leadFormCardClassification => 'التصنيف';

  @override
  String get leadFormCardContact => 'بيانات التواصل';

  @override
  String get leadFormTier => 'الفئة';

  @override
  String get leadFormSpecialty => 'سبيشالتي';

  @override
  String get leadFieldMobile => 'الموبايل';

  @override
  String get leadFieldWebsite => 'الموقع';

  @override
  String get leadFieldInstagram => 'إنستجرام';

  @override
  String get leadFieldFacebook => 'فيسبوك';

  @override
  String get leadFormRequired => 'مطلوب';

  @override
  String get leadFormScoreRangeError => '0–100';

  @override
  String get leadFormCategoryLabel => 'التصنيف';

  @override
  String get leadsSortTooltip => 'ترتيب';

  @override
  String get leadsSortScore => 'الدرجة';

  @override
  String get leadsSortRating => 'التقييم';

  @override
  String get leadsSortReviews => 'المراجعات';

  @override
  String get leadsSortBranches => 'الفروع';

  @override
  String get leadsSortName => 'الاسم';

  @override
  String get leadsSortNearest => 'الأقرب';

  @override
  String get leadsMapCategories => 'التصنيفات';

  @override
  String get leadActionCall => 'اتصل';

  @override
  String get leadActionInstagram => 'إنستجرام';

  @override
  String get leadActionWebsite => 'الموقع';

  @override
  String get leadActionMap => 'الخريطة';

  @override
  String get leadsMergeConfirmAction => 'ادمج';

  @override
  String get b2bAccountTitle => 'الحساب';

  @override
  String b2bAccountLoadFailed(String error) {
    return 'مش قادر يفتح الحساب.\n$error';
  }

  @override
  String b2bFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get b2bLogCall => 'سجّل مكالمة';

  @override
  String get b2bLogCallHint => 'اتكلمتوا في إيه؟';

  @override
  String get b2bActivityLogged => 'النشاط اتسجّل';

  @override
  String b2bLogActivityFailed(String error) {
    return 'مش قادر يسجّل النشاط: $error';
  }

  @override
  String get b2bMarkLostTitle => 'علّمه خسران / معلّق';

  @override
  String get b2bReasonHint => 'السبب';

  @override
  String get b2bMarkedLost => 'اتعلّم خسران/معلّق';

  @override
  String get b2bCreateCustomerTitle => 'اعمل عميل للعميل المحتمل';

  @override
  String get b2bCustomerName => 'اسم العميل';

  @override
  String get b2bAddress => 'العنوان';

  @override
  String get b2bContinue => 'كمّل';

  @override
  String get b2bLoadingTerritories => 'بيحمّل المناطق…';

  @override
  String get b2bTerritoriesFailed => 'مش قادر يجيب المناطق';

  @override
  String get b2bOpenLeadPage => 'افتح صفحة العميل المحتمل';

  @override
  String get b2bSectionContact => 'بيانات التواصل';

  @override
  String get b2bSectionInsights => 'تحليلات';

  @override
  String get b2bSectionRecentInvoices => 'آخر الفواتير';

  @override
  String get b2bSectionOpenTodos => 'المهام المفتوحة';

  @override
  String get b2bNone => 'مفيش';

  @override
  String get b2bPredictedNextOrder => 'الطلب الجاي المتوقع';

  @override
  String get b2bAvgOrderCycle => 'متوسط دورة الطلب';

  @override
  String b2bDaysValue(String days) {
    return '$days يوم';
  }

  @override
  String get b2bSendSample => 'ابعت عينة';

  @override
  String get b2bPlaceOrder => 'اعمل طلب';

  @override
  String get b2bMarkLost => 'علّمه خسران';

  @override
  String get b2bViewPricing => 'شوف الأسعار';

  @override
  String get b2bLabelsSection => 'الليبلات';

  @override
  String b2bLabelsNeedPrinting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محتاجين طباعة',
      one: 'واحد محتاج طباعة',
    );
    return '$_temp0';
  }

  @override
  String get b2bNoLabelsTracked => 'لسه مفيش ليبلات متتابعة للعميل ده.';

  @override
  String get b2bSetUpLabels => 'جهّز الليبلات';

  @override
  String get b2bLoadingLeadProfile => 'بيحمّل ملف العميل المحتمل…';

  @override
  String get b2bLeadProfile => 'ملف العميل المحتمل';

  @override
  String b2bMoreBranches(int count) {
    return '+ $count كمان';
  }

  @override
  String get b2bPipelineTitle => 'مسار الجملة';

  @override
  String get b2bMyFollowUps => 'متابعاتي';

  @override
  String get b2bRefresh => 'تحديث';

  @override
  String get b2bSwitchMode => 'غيّر الوضع';

  @override
  String get b2bGoToPos => 'روح لنقطة البيع (تجزئة)';

  @override
  String get b2bGoToKanban => 'روح لبورد التوصيل';

  @override
  String get b2bNewLead => 'عميل محتمل جديد';

  @override
  String b2bMovedToStage(String title, String stage) {
    return '\"$title\" اتنقل لـ $stage';
  }

  @override
  String b2bAdvanceStageFailed(String error) {
    return 'مش قادر ينقل المرحلة: $error';
  }

  @override
  String get b2bFollowUpReminder => 'تذكير متابعة';

  @override
  String b2bFollowUpPrompt(String stage) {
    return 'هتتابع إمتى بعد النقل لـ \"$stage\"؟';
  }

  @override
  String get b2bSkip => 'تخطّي';

  @override
  String get b2bSetReminder => 'اضبط التذكير';

  @override
  String get b2bLostReasonHint => 'ليه ده خسران / معلّق؟';

  @override
  String b2bPipelineLoadFailed(String error) {
    return 'مش قادر يفتح المسار.\n$error';
  }

  @override
  String get b2bTodayTitle => 'النهارده';

  @override
  String b2bTodayLoadFailed(String error) {
    return 'مش قادر يجيب المتابعات.\n$error';
  }

  @override
  String get b2bNoFollowUpsToday => 'مفيش متابعات النهارده';

  @override
  String get b2bNoReordersDue => 'مفيش طلبات إعادة مستحقة';

  @override
  String get b2bFollowUpDone => 'المتابعة اتعلّمت خلصت';

  @override
  String b2bFollowUpFailed(String error) {
    return 'مش قادر يخلّص المتابعة: $error';
  }

  @override
  String get b2bDone => 'تمام';

  @override
  String b2bOverdueSuffix(String date) {
    return '$date · متأخرة';
  }

  @override
  String b2bAvgBasket(String amount) {
    return 'المتوسط: $amount';
  }

  @override
  String b2bScoreLabel(int score) {
    return 'الدرجة $score';
  }

  @override
  String get b2bNoAccounts => 'مفيش حسابات';

  @override
  String b2bLabelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل',
      one: 'ليبل واحد',
    );
    return '$_temp0';
  }

  @override
  String b2bLastOrder(String date) {
    return 'آخر طلب: $date';
  }

  @override
  String b2bNextOrder(String date) {
    return 'الجاي: $date';
  }

  @override
  String get b2bCardLead => 'عميل محتمل';

  @override
  String get b2bCardOpportunity => 'فرصة';

  @override
  String b2bLabelsNeedPrintingTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليبل محتاجين طباعة',
      one: 'ليبل واحد محتاج طباعة',
    );
    return '$_temp0';
  }

  @override
  String get pricingTitle => 'قوايم الأسعار';

  @override
  String get pricingCustomerLookup => 'بحث أسعار العميل';

  @override
  String get pricingRefresh => 'تحديث';

  @override
  String get pricingNewPriceList => 'قايمة أسعار جديدة';

  @override
  String get pricingNoPriceLists => 'لسه مفيش قوايم أسعار.';

  @override
  String get pricingNameField => 'الاسم';

  @override
  String get pricingCurrencyField => 'العملة';

  @override
  String get pricingCreate => 'اعمل';

  @override
  String pricingCreated(String name) {
    return 'اتعمل \"$name\"';
  }

  @override
  String pricingCreateFailed(String error) {
    return 'مش قادر يعمل قايمة أسعار: $error';
  }

  @override
  String get pricingDefaultBadge => 'الافتراضية';

  @override
  String pricingLoadFailed(String error) {
    return 'مش قادر يجيب قوايم الأسعار.\n$error';
  }

  @override
  String pricingDetailLoadFailed(String name, String error) {
    return 'مش قادر يفتح \"$name\".\n$error';
  }

  @override
  String pricingSetRateTitle(String category) {
    return 'حدد سعر $category';
  }

  @override
  String pricingRateUpdated(String category) {
    return 'سعر $category اتحدّث';
  }

  @override
  String pricingRateSet(String category) {
    return 'سعر $category اتحدد';
  }

  @override
  String get pricingAllCategoriesHaveRows => 'كل التصنيفات ليها سطر بالفعل.';

  @override
  String pricingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String pricingOverrideTitle(String item) {
    return 'استثناء $item';
  }

  @override
  String get pricingOverrideUpdated => 'الاستثناء اتحدّث';

  @override
  String get pricingRemoveOverrideTitle => 'تشيل الاستثناء؟';

  @override
  String pricingRemoveOverrideBody(String item) {
    return '$item هيرجع لسعر تصنيفه.';
  }

  @override
  String get pricingRemove => 'شيل';

  @override
  String get pricingOverrideRemoved => 'الاستثناء اتشال';

  @override
  String get pricingAddOverride => 'ضيف استثناء';

  @override
  String get pricingItemCode => 'كود الصنف';

  @override
  String get pricingRateField => 'السعر';

  @override
  String get pricingOverrideAdded => 'الاستثناء اتضاف';

  @override
  String get pricingUnassignTitle => 'تشيل ربط العميل؟';

  @override
  String pricingUnassignBody(String customer) {
    return '$customer هيرجع لافتراضي مجموعته.';
  }

  @override
  String get pricingUnassign => 'شيل الربط';

  @override
  String get pricingCustomerUnassigned => 'ربط العميل اتشال';

  @override
  String pricingFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get pricingCategoryPrices => 'أسعار التصنيفات';

  @override
  String get pricingAddCategory => 'ضيف تصنيف';

  @override
  String get pricingNoCategoryRates => 'مفيش أسعار تصنيفات متحددة.';

  @override
  String pricingEditRateTooltip(String category) {
    return 'عدّل سعر $category';
  }

  @override
  String get pricingPerFlavorOverrides => 'استثناءات لكل نكهة';

  @override
  String pricingOverrideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count استثناءات',
      one: 'استثناء واحد',
    );
    return '$_temp0';
  }

  @override
  String get pricingNoOverrides => 'مفيش استثناءات لأصناف.';

  @override
  String get pricingEditOverride => 'عدّل الاستثناء';

  @override
  String get pricingRemoveOverride => 'شيل الاستثناء';

  @override
  String get pricingAssignedCustomers => 'العملاء المربوطين';

  @override
  String pricingCustomerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملاء',
      one: 'عميل واحد',
    );
    return '$_temp0';
  }

  @override
  String get pricingNoCustomers => 'مفيش عملاء بيستخدموا القايمة دي.';

  @override
  String pricingViaGroup(String group) {
    return 'عن طريق مجموعة $group';
  }

  @override
  String get pricingDirectAssignment => 'ربط مباشر';

  @override
  String get customerPricingTitle => 'أسعار العميل';

  @override
  String get customerPricingSearchHint => 'دوّر على عملاء الشركات…';

  @override
  String customerPricingSearchFailed(String error) {
    return 'البحث فشل.\n$error';
  }

  @override
  String get customerPricingNoCustomers => 'مفيش عملاء.';

  @override
  String customerPricingLoadFailed(String customer, String error) {
    return 'مش قادر يجيب أسعار \"$customer\".\n$error';
  }

  @override
  String get customerPricingEffective => 'الأسعار السارية';

  @override
  String get customerPricingNoResolved => 'مفيش أسعار محسوبة.';

  @override
  String customerPricingSource(String group, String source) {
    return '$group · المصدر: $source';
  }

  @override
  String get pricingNoCategoryRatesShort => 'مفيش أسعار تصنيفات متحددة';

  @override
  String pricingCardSummary(String customers, String currency) {
    return '$customers · $currency';
  }

  @override
  String get pricingDisabledSuffix => ' · متوقفة';

  @override
  String customerPricingGroupLine(
    String group,
    String priceList,
    String assignment,
  ) {
    return 'المجموعة: $group\nقايمة الأسعار: $priceList ($assignment)';
  }

  @override
  String get pricingNoneValue => '(مفيش)';

  @override
  String get pricingDash => '—';

  @override
  String get journeyToday => 'النهارده';

  @override
  String get journeyYesterday => 'امبارح';

  @override
  String get journeyTomorrow => 'بكره';

  @override
  String journeyDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'من $count أيام',
      one: 'من يوم',
    );
    return '$_temp0';
  }

  @override
  String journeyWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'من $count أسابيع',
      one: 'من أسبوع',
    );
    return '$_temp0';
  }

  @override
  String journeyMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'من $count شهور',
      one: 'من شهر',
    );
    return '$_temp0';
  }

  @override
  String journeyOverdueByDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متأخر بـ $count أيام',
      one: 'متأخر بيوم',
    );
    return '$_temp0';
  }

  @override
  String get journeyOverdue => 'متأخر';

  @override
  String journeyInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count أيام',
      one: 'بعد يوم',
    );
    return '$_temp0';
  }

  @override
  String journeyInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count شهور',
      one: 'بعد شهر',
    );
    return '$_temp0';
  }

  @override
  String get journeyTypeVisit => 'زيارة';

  @override
  String get journeyTypeCall => 'مكالمة';

  @override
  String get journeyTypeWhatsapp => 'واتساب';

  @override
  String get journeyTypeSampleDrop => 'تسليم عينة';

  @override
  String get journeyTypeMeeting => 'اجتماع';

  @override
  String get journeyTypeEmail => 'إيميل';

  @override
  String get journeyTypeOther => 'غير كده';

  @override
  String get journeyOutcomeInterested => 'مهتم';

  @override
  String get journeyOutcomeNeedsFollowUp => 'محتاج متابعة';

  @override
  String get journeyOutcomeSampleRequested => 'طلب عينة';

  @override
  String get journeyOutcomeOrderPlaced => 'عمل طلب';

  @override
  String get journeyOutcomeNotNow => 'مش دلوقتي';

  @override
  String get journeyOutcomeRejected => 'مرفوض';

  @override
  String get journeyEditorEditTitle => 'تعديل ملاحظة الزيارة';

  @override
  String get journeyEditorNewTitle => 'سجّل زيارة أو مكالمة';

  @override
  String get journeyEditorSubtitle =>
      'اللي حصل، ومين اللي اتكلمت معاه، وإيه الخطوة الجاية.';

  @override
  String get journeyEditorDate => 'التاريخ';

  @override
  String get journeyEditorType => 'النوع';

  @override
  String get journeyEditorNote => 'الملاحظة';

  @override
  String get journeyEditorNoteHint => 'عجبهم الماتشا وسألوا عن أسعار الجملة…';

  @override
  String get journeyEditorWhoSpoke => 'مين اللي اتكلمت معاه';

  @override
  String get journeyEditorWhoHint => 'دوس على اللي قابلته، أو ضيف حد جديد.';

  @override
  String get journeyEditorNewPerson => 'شخص جديد';

  @override
  String journeyEditorContactFailed(String error) {
    return 'مش قادر يحفظ جهة الاتصال: $error';
  }

  @override
  String get journeyEditorPerson => 'الشخص';

  @override
  String get journeyEditorPersonHint => 'مصطفى';

  @override
  String get journeyEditorRole => 'الوظيفة';

  @override
  String get journeyEditorRoleHint => 'مدير الفرع';

  @override
  String get journeyEditorTheirPhone => 'تليفونه';

  @override
  String get journeyEditorOutcome => 'النتيجة';

  @override
  String get journeyEditorNextAction => 'الخطوة الجاية';

  @override
  String get journeyEditorNextActionHelp =>
      'التاريخ هنا كمان بيظبط تذكير المتابعة على الحساب ده.';

  @override
  String get journeyEditorWhatToDo => 'المفروض تعمل إيه';

  @override
  String get journeyEditorWhatToDoHint =>
      'كلّم المدير عشان يأكد الطلب التجريبي';

  @override
  String get journeyEditorWhen => 'إمتى';

  @override
  String get journeyEditorNoReminder => 'من غير تذكير';

  @override
  String get journeyEditorLogIt => 'سجّلها';

  @override
  String get journeyEditorPickDate => 'اختار تاريخ';

  @override
  String get journeyEditorClear => 'امسح';

  @override
  String get journeySectionTitle => 'سجل الزيارات';

  @override
  String get journeyLogVisit => 'سجّل زيارة';

  @override
  String get journeyNoteAdded => 'الملاحظة اتضافت';

  @override
  String get journeyNoteUpdated => 'الملاحظة اتحدّثت';

  @override
  String get journeyNoteDeleted => 'الملاحظة اتمسحت';

  @override
  String get journeyDeleteTitle => 'تمسح الملاحظة دي؟';

  @override
  String get journeyDeleteBody => 'سجل الزيارة هيتشال للكل. مفيش رجوع بعد كده.';

  @override
  String journeyFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get journeyEdit => 'تعديل';

  @override
  String journeyLoggedBy(String user) {
    return 'سجّلها $user';
  }

  @override
  String get journeyEmptyTitle => 'لسه مفيش زيارات متسجلة.';

  @override
  String get journeyEmptyBody =>
      'سجّل اللي اتقال ومين قاله وإمتى تتابع — والخطوة الجاية بتاريخ بتظبط كمان تذكير الحساب ده.';

  @override
  String get journeyLoadFailed => 'مش قادر يجيب سجل الزيارات.';

  @override
  String get journeyMarkDone => 'خلصتها';

  @override
  String get journeyMarkNotDone => 'رجّعها لسه';

  @override
  String get journeyDoneLabel => 'خلصت';

  @override
  String journeyDoneOn(String date) {
    return 'خلصت $date';
  }

  @override
  String journeyDoneByOn(String date, String user) {
    return 'خلصت $date · $user';
  }

  @override
  String get journeyActionMarkedDone => 'الخطوة اتقفلت';

  @override
  String get journeyActionReopened => 'الخطوة رجعت مفتوحة';

  @override
  String get journeyCalendarTitle => 'تقويم المتابعات';

  @override
  String get journeyCalendarPreviousMonth => 'الشهر اللي فات';

  @override
  String get journeyCalendarNextMonth => 'الشهر الجاي';

  @override
  String get journeyCalendarScopeMine => 'بتاعتي';

  @override
  String get journeyCalendarScopeAll => 'الكل';

  @override
  String get journeyCalendarShowDone => 'ورّي اللي خلص';

  @override
  String journeyCalendarPendingCount(int count) {
    return 'مفتوحة $count';
  }

  @override
  String journeyCalendarOverdueCount(int count) {
    return 'متأخرة $count';
  }

  @override
  String journeyCalendarDoneCount(int count) {
    return 'خلصت $count';
  }

  @override
  String journeyCalendarDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مطلوبة',
      one: 'مطلوبة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get journeyCalendarNothingOnDay => 'مفيش حاجة مطلوبة اليوم ده.';

  @override
  String get journeyCalendarEmptyMonth => 'مفيش حاجة مطلوبة الشهر ده.';

  @override
  String get journeyCalendarLoadFailed => 'مش قادر يجيب التقويم.';

  @override
  String get journeyCalendarSourceFollowup => 'تذكير';

  @override
  String get journeyCalendarNoAction => 'مفيش خطوة متكتوبة';

  @override
  String get errorConsoleCopyError => 'انسخ الخطأ';

  @override
  String get errorConsoleCopied => 'تفاصيل الخطأ اتنسخت';

  @override
  String get errorConsoleSummary => 'الملخص';

  @override
  String get errorConsoleFatal => 'قاتل';

  @override
  String get errorConsoleYes => 'أيوه';

  @override
  String get errorConsoleNo => 'لأ';

  @override
  String get errorConsoleOccurrences => 'عدد المرات';

  @override
  String get errorConsoleDetails => 'التفاصيل';

  @override
  String get errorConsoleStackTrace => 'تتبّع الخطأ';

  @override
  String get menuInstapayReconciliation => 'تسوية إنستاباي';

  @override
  String get instapayTitle => 'تسوية إنستاباي';

  @override
  String get instapayNoOrders => 'مفيش طلبات مستنية تأكيد إنستاباي';

  @override
  String get instapayCourierRequired => 'لازم مندوب عشان تحصيل الكاش';

  @override
  String get instapayConvertedToCod => 'اتحوّل لدفع عند الاستلام';

  @override
  String get instapayCollectedCashInstead => 'اتحصّل كاش بدالها';

  @override
  String get instapayConfirmReceived => 'أكّد الاستلام';

  @override
  String get instapayPaymentConfirmed => 'الدفع اتأكد';

  @override
  String get instapayBankReference => 'رقم مرجع البنك';

  @override
  String get kanbanMoveAction => 'انقل';

  @override
  String get kanbanDeliveryPartnerField => 'شريك التوصيل';

  @override
  String get kanbanSetDeliveryIncome => 'حدد دخل التوصيل';

  @override
  String get kanbanDeliveryIncomeField => 'دخل التوصيل';

  @override
  String get kanbanInvalidAmount => 'اكتب مبلغ صحيح مش بالسالب';

  @override
  String get kanbanUpdatingDeliveryIncome => 'بيحدّث دخل التوصيل…';

  @override
  String kanbanErrorWithMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get posShowHeaderTooltip => 'وريني الهيدر';

  @override
  String get posCartDeliveryAmountField => 'مبلغ التوصيل';

  @override
  String get posCartResetToDefault => 'رجّع الافتراضي';

  @override
  String get posCartSetAction => 'حدد';

  @override
  String get posCartPromoCode => 'كود الخصم';

  @override
  String get posCartPromoCodeHint => 'مثلاً EGY2026';

  @override
  String get reportsColumnSegment => 'الشريحة';

  @override
  String get reportsColumnRecencyDays => 'آخر شراء (يوم)';

  @override
  String get reportsColumnFrequency => 'التكرار';

  @override
  String get reportsColumnAov => 'متوسط الطلب';

  @override
  String get tripsOneBranchOnly =>
      'اختار فواتير من فرع واحد بس عشان تعمل رحلة.';

  @override
  String get webPushOnlyInWebApp => 'إشعارات الويب متاحة في نسخة الويب بس.';

  @override
  String get webPushEnabled => 'إشعارات الويب مفعّلة على الجهاز ده.';

  @override
  String get webPushDisabledForEnv => 'إشعارات الويب مقفولة في البيئة دي.';

  @override
  String get webPushNotConfigured => 'إشعارات الويب مش متظبطة في البيئة دي.';

  @override
  String get webPushUnsupportedPrompt =>
      'المتصفح ده مش بيدعم طلب إذن الإشعارات.';

  @override
  String get webPushPermissionRequired =>
      'دوس على تفعيل الإشعارات عشان تسمح بإشعارات الويب على الجهاز ده.';

  @override
  String get webPushPermissionDenied => 'إذن الإشعارات اترفض.';

  @override
  String get webPushNoToken =>
      'لسه مفيش توكن لإشعارات الويب. جرّب تاني بعد ما تقفل التطبيق وتفتحه.';

  @override
  String get webPushTokenReady => 'توكن إشعارات الويب جاهز للتسجيل.';

  @override
  String get webPushEnableFailed =>
      'مش قادر يفعّل الإشعارات. اقفل التطبيق من الشاشة الرئيسية وافتحه وجرّب تاني.';

  @override
  String get b2bCustomerLabelsTooltip => 'ليبلات العملاء';

  @override
  String get b2bFollowUpsHeader => 'المتابعات';

  @override
  String get b2bReorderDueHeader => 'طلبات إعادة مستحقة';

  @override
  String get expensesEmptyManagerHint =>
      'اعمل مصروف جديد عشان تسجّل مصاريف التشغيل.';

  @override
  String get expensesEmptyStaffHint => 'قدّم مصروف جديد والمدير هيراجعه.';

  @override
  String get expenseSourceCash => 'كاش';

  @override
  String get expenseSourceBank => 'بنك';

  @override
  String get expenseSourceMobileWallet => 'محفظة موبايل';

  @override
  String get expenseSourcePosProfile => 'بروفايل نقطة البيع';

  @override
  String get expenseSourceAccount => 'حساب';

  @override
  String get instapayConvertFailed => 'مش قادر يحوّل الطلب لكاش';

  @override
  String get instapayConfirmFailed => 'مش قادر يأكد الدفع';

  @override
  String get instapayConfirmSheetTitle => 'أكّد استلام إنستاباي';

  @override
  String get instapayAwaitingBadge => 'في انتظار إنستاباي';

  @override
  String get inventoryCountSubmitting => 'بيقدّم التسوية';

  @override
  String get inventoryCountSubmitError => 'خطأ في تقديم التسوية';

  @override
  String get kanbanExitSelection => 'اخرج من التحديد';

  @override
  String get kanbanSelectOrders => 'اختار طلبات';

  @override
  String get kanbanMoveOrderTitle => 'نقل الطلب';

  @override
  String get kanbanCreateFailedFallback => 'الإنشاء فشل';

  @override
  String get kanbanDeliveryIncomeHelp =>
      'اكتب دخل توصيل مخصص للطلب ده. سيبها فاضية عشان ترجع لافتراضي المنطقة. ده هيعمل تعديل للطلب.';

  @override
  String get kanbanCannotAmend => 'الطلب ده مينفعش يتعدّل';

  @override
  String get kanbanDeliveryIncomeReset => 'دخل التوصيل رجع لافتراضي المنطقة';

  @override
  String get kanbanAmendmentFailed => 'التعديل فشل';

  @override
  String get kanbanShippingNotUpdated =>
      'تكلفة الشحن ماتحدّثتش. صلّح منطقة العنوان.';

  @override
  String get leadsNotSuitableBadge => 'غير مناسب';

  @override
  String get bundleSelectionTitle => 'اختيار الباقة';

  @override
  String get bundleUpdateAction => 'حدّث الباقة';

  @override
  String get bundleAddToCartAction => 'ضيف للسلة';

  @override
  String get bundleSelectFromGroups => 'اختار أصناف من كل مجموعة تحت:';

  @override
  String get bundleCatalogDriftWarning =>
      'خيارات الباقة يمكن تكون اتغيّرت من ساعة ما الطلب اتعمل. راجع اختياراتك وأكّدها.';

  @override
  String get bundleNoItemsInGroup => 'مفيش أصناف متاحة في المجموعة دي';

  @override
  String get bundleUnknownItem => 'صنف غير معروف';

  @override
  String get bundleUnknownBundle => 'باقة غير معروفة';

  @override
  String get bundleNoItemGroups => 'مفيش مجموعات أصناف';

  @override
  String get bundleNoItemGroupsBody => 'الباقة دي مفيهاش مجموعات أصناف متاحة';

  @override
  String get posCartPromoDiscount => 'خصم الكود';

  @override
  String get posCartFreeDelivery => 'توصيل مجاني';

  @override
  String get posCartDeliveryAmountHelp =>
      'اكتب مبلغ توصيل مخصص. سيبها فاضية عشان ترجع لافتراضي المنطقة.';

  @override
  String get posCartBundleLoadFailed =>
      'محتويات الباقة مش قادرة تتحمّل. عدّل الباقة واختار الأصناف تاني قبل ما تبعت.';

  @override
  String get posCartPromoApplied => 'اتطبق';

  @override
  String get posCartPromoNotEligible => 'مش مؤهل';

  @override
  String get posSalesPartnerFallback => 'شريك المبيعات';

  @override
  String get reportsColumnBomCost => 'تكلفة قائمة المواد';

  @override
  String get reportsColumnTimesInBundle => 'مرات في الباقات';

  @override
  String get settingsIosWebPushTitle => 'إشعارات الويب على الآيفون';

  @override
  String get settingsIosWebPushBody =>
      'نزّل التطبيق على الشاشة الرئيسية للآيفون، وبعدين دوس على تفعيل الإشعارات عشان توصلك التنبيهات.';

  @override
  String get settingsEnablingNotifications => 'بيفعّل الإشعارات...';

  @override
  String get settingsEnableNotifications => 'فعّل الإشعارات';

  @override
  String get settingsNotificationAlerts => 'تنبيهات الإشعارات';

  @override
  String get settingsAlarmsMutedAll => 'كل تنبيهات الطلبات مكتومة حاليًا';

  @override
  String get settingsAlarmsActive => 'تنبيهات الطلبات شغّالة';

  @override
  String get settingsAlarmsEnabledDevice =>
      'تنبيهات الإشعارات اتفعّلت على الجهاز ده';

  @override
  String get settingsAlarmsMutedDevice =>
      'تنبيهات الإشعارات اتكتمت على الجهاز ده';

  @override
  String get settingsChooseAlarmSound =>
      'اختار صوت تنبيه الموظفين جوه التطبيق:';

  @override
  String get settingsAlarmSoundNote =>
      'الصوت ده بيتستخدم لتنبيه الموظفين جوه التطبيق. إشعارات الطلبات والتطبيق مقفول بتستخدم نغمة الطلبات.';

  @override
  String get settingsProfileLoadFailed => 'مش قادر يجيب ملف المستخدم';

  @override
  String get shiftUnknownUser => 'مستخدم غير معروف';

  @override
  String kanbanDeliveryIncomeUpdated(String amount) {
    return 'دخل التوصيل اتحدّث لـ $amount';
  }

  @override
  String kanbanAddressNoTerritory(String city) {
    return 'العنوان اتحفظ، بس \"$city\" مش مطابق لأي منطقة — تكلفة الشحن ماتحدّثتش. صلّح منطقة العنوان.';
  }

  @override
  String get reportsColumnComponent => 'المكوّن';

  @override
  String get leadContactsTitle => 'جهات الاتصال';

  @override
  String leadContactsTitleCount(int count) {
    return 'جهات الاتصال ($count)';
  }

  @override
  String get leadContactsEmpty =>
      'لا يوجد أشخاص مسجلون بعد. أضف المالك أو المدير أو أي شخص تقابله في الزيارة.';

  @override
  String get leadContactsAdd => 'إضافة جهة اتصال';

  @override
  String get leadContactsEdit => 'تعديل جهة الاتصال';

  @override
  String get leadContactsRemove => 'حذف';

  @override
  String get leadContactsRemoveTitle => 'حذف جهة الاتصال؟';

  @override
  String leadContactsRemoveBody(String name) {
    return 'حذف $name من هذا العميل المحتمل؟';
  }

  @override
  String get leadContactsMakePrimary => 'تعيين كجهة أساسية';

  @override
  String get leadContactsPrimary => 'جهة الاتصال الأساسية';

  @override
  String get leadContactsPrimaryHint => 'الشخص الذي يتم الاتصال به أولاً.';

  @override
  String get leadContactsSaved => 'تم تحديث جهات الاتصال';

  @override
  String get leadContactsName => 'الاسم';

  @override
  String get leadContactsRole => 'الوظيفة / المسمى';

  @override
  String get leadContactsRoleHint => 'مالك، مدير، باريستا…';

  @override
  String get leadContactsPhone => 'الهاتف';

  @override
  String get leadContactsEmail => 'البريد الإلكتروني';

  @override
  String get leadContactsNotes => 'ملاحظات';

  @override
  String get leadContactsPickFromPhone => 'اختيار من جهات اتصال الهاتف';

  @override
  String get leadContactsNeedNameOrPhone => 'أضف اسمًا أو رقم هاتف.';

  @override
  String get leadContactRoleOwner => 'مالك';

  @override
  String get leadContactRoleManager => 'مدير';

  @override
  String get leadContactRoleShiftManager => 'مدير وردية';

  @override
  String get leadContactRoleBarista => 'باريستا';

  @override
  String get leadContactRolePurchasing => 'مشتريات';

  @override
  String get leadContactRoleAccountant => 'محاسب';

  @override
  String get visitPlannerTitle => 'مخطط الزيارات';

  @override
  String get visitPlanDay => 'خطّط يوماً';

  @override
  String get visitBuildDay => 'تكوين يوم';

  @override
  String get visitRouteTitle => 'المسار';

  @override
  String visitRouteFallbackTitle(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString محطة',
      few: '$countString محطات',
      two: 'محطتان',
      one: 'محطة واحدة',
      zero: 'مسار فارغ',
    );
    return '$_temp0';
  }

  @override
  String get visitScopeMine => 'مساراتي';

  @override
  String get visitScopeAll => 'مسارات الجميع';

  @override
  String get visitNoRoutesOnDay => 'لا يوجد مسار مخطط لهذا اليوم.';

  @override
  String get visitPlansLoadFailed =>
      'تعذّر تحميل المسارات. اسحب للأسفل للمحاولة مرة أخرى.';

  @override
  String visitStopsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString محطة',
      few: '$countString محطات',
      two: 'محطتان',
      one: 'محطة واحدة',
      zero: 'بدون محطات',
    );
    return '$_temp0';
  }

  @override
  String visitDistanceKm(String km) {
    return '$km كم';
  }

  @override
  String visitDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String visitDayTotal(String duration) {
    return 'اليوم $duration';
  }

  @override
  String visitLeg(String km, int minutes) {
    return '$km كم · $minutes دقيقة';
  }

  @override
  String get visitNextStop => 'المحطة التالية';

  @override
  String get visitGo => 'انطلق';

  @override
  String get visitNavigate => 'التوجيه';

  @override
  String get visitCall => 'اتصال';

  @override
  String get visitCheckIn => 'تسجيل الزيارة';

  @override
  String get visitSkip => 'تخطّي';

  @override
  String get visitReopen => 'إعادة فتح';

  @override
  String get visitPin => 'تثبيت في هذا الترتيب';

  @override
  String get visitUnpin => 'إلغاء التثبيت';

  @override
  String get visitRemoveStop => 'إزالة من المسار';

  @override
  String get visitOptimise => 'تحسين المسار';

  @override
  String get visitOptimiseFromHere => 'التحسين من موقعي الحالي';

  @override
  String get visitNavigateWholeRoute => 'فتح المسار كاملاً في الخرائط';

  @override
  String get visitDeleteRoute => 'حذف المسار';

  @override
  String get visitDeleteRouteConfirm =>
      'سيُحذف المسار. الزيارات المسجّلة تبقى في سجل الرحلة.';

  @override
  String get visitNoStops => 'لا توجد محطات في هذا المسار بعد.';

  @override
  String get visitLocationUnavailable => 'تعذّر تحديد موقعك.';

  @override
  String visitRouteTruncated(int handed, int total) {
    return 'الخرائط تقبل $handed من $total محطة دفعة واحدة. استخدم التوجيه محطة بمحطة لبقية المسار.';
  }

  @override
  String get visitOutcome => 'النتيجة';

  @override
  String get visitLogJourneyNote => 'تسجيل ملاحظة رحلة';

  @override
  String get visitLogJourneyNoteHint =>
      'تُسجّل الزيارة في سجل العميل المحتمل وتحدّد تذكير المتابعة.';

  @override
  String get visitNoteWhatHappened => 'ماذا حدث';

  @override
  String get visitNextAction => 'الإجراء التالي';

  @override
  String get visitNextActionDate => 'اختر تاريخاً';

  @override
  String get visitMarkVisited => 'تمت الزيارة';

  @override
  String get visitSuggestDay => 'خطّط يومي';

  @override
  String get visitMaxStops => 'أقصى عدد محطات';

  @override
  String get visitDayHours => 'اليوم (ساعات)';

  @override
  String get visitStartFromMyLocation => 'البدء من موقعي';

  @override
  String get visitStartFromMyLocationHint =>
      'عند الإيقاف يخطّط حول أفضل تجمّع في أي مكان.';

  @override
  String get visitIncludeCustomers => 'تضمين العملاء الحاليين';

  @override
  String get visitIncludeCustomersHint =>
      'زيارات متابعة للحسابات النشطة في الطريق.';

  @override
  String get visitCandidateDoors => 'أماكن تستحق الزيارة';

  @override
  String get visitClearSelection => 'مسح';

  @override
  String get visitNoCandidates => 'لا توجد نتائج مطابقة لهذه الفلاتر.';

  @override
  String get visitTargetsLoadFailed => 'تعذّر تحميل المرشحين.';

  @override
  String visitProposedDay(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString محطة مقترحة',
      few: '$countString محطات مقترحة',
      two: 'محطتان مقترحتان',
      one: 'محطة واحدة مقترحة',
    );
    return '$_temp0';
  }

  @override
  String visitConsidered(int count) {
    return 'تمت دراسة $count مكان';
  }

  @override
  String visitDroppedForTime(int count) {
    return 'تم استبعاد $count لتناسب اليوم';
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
      other: '$countString محطة محدّدة',
      few: '$countString محطات محدّدة',
      two: 'محطتان محدّدتان',
      one: 'محطة واحدة محدّدة',
    );
    return '$_temp0';
  }

  @override
  String get visitCreateRoute => 'إنشاء المسار';

  @override
  String get visitEngineRoadExplained =>
      'المسافات والأزمنة مأخوذة من شبكة الطرق.';

  @override
  String get visitEngineEstimateExplained =>
      'المسافات تقديرية بخط مستقيم معدّلة للقيادة داخل المدينة. ترتيب الزيارات محسوب بدقة، أما الدقائق فتقريبية.';

  @override
  String get visitEngineRecheck => 'إعادة الفحص';

  @override
  String get materialsSectionTitle => 'قائمة الأسعار والمواد';

  @override
  String get materialsSendCta => 'إرسال قائمة الأسعار';

  @override
  String get materialsSendTitle => 'إرسال المواد';

  @override
  String get materialsRecipientLabel => 'إرسال إلى';

  @override
  String get materialsNoRecipient =>
      'لا توجد جهات اتصال على هذا العميل. أضف واحدة أولاً، أو أرسل واختر المحادثة داخل واتساب.';

  @override
  String get materialsPickLabel => 'المواد المرسلة';

  @override
  String get materialsPreparing => 'قيد التجهيز';

  @override
  String get materialsMessageLabel => 'الرسالة';

  @override
  String get materialsSending => 'جارٍ إنشاء الرابط…';

  @override
  String get materialsLinkReady => 'تم إنشاء الرابط وتسجيله على العميل.';

  @override
  String get materialsCopyLink => 'نسخ الرابط';

  @override
  String get materialsLinkCopied => 'تم نسخ الرابط';

  @override
  String get materialsLibraryEmpty =>
      'لا توجد مواد في المكتبة بعد. اطلب من المدير رفع قائمة الأسعار.';

  @override
  String get materialsRetry => 'إعادة المحاولة';

  @override
  String get materialsNothingSent => 'لم يتم إرسال أي شيء بعد.';

  @override
  String get materialsHistoryUnavailable => 'تعذّر تحميل سجل الإرسال السابق.';

  @override
  String get materialsNotOpenedYet => 'لم يُفتح بعد';

  @override
  String materialsPageCount(Object count) {
    return '$count صفحات';
  }

  @override
  String materialsStillPreparing(Object count) {
    return '$count من هذه الملفات ما زالت قيد التجهيز. الرابط يعمل الآن، لكن أول فتح قد يستغرق ثوانٍ.';
  }

  @override
  String materialsOpenedCount(Object count) {
    return 'فُتح $count مرة';
  }

  @override
  String materialsSendFailed(Object error) {
    return 'تعذّر إنشاء الرابط: $error';
  }

  @override
  String materialsLoadFailed(Object error) {
    return 'تعذّر تحميل مكتبة المواد: $error';
  }

  @override
  String materialsLinkPlaceholderHint(Object token) {
    return 'اترك $token في مكان الرابط؛ سيتم استبداله تلقائيًا عند الإرسال.';
  }

  @override
  String get appUpdateRequiredTitle => 'التحديث مطلوب';

  @override
  String get appUpdateRequiredBody =>
      'هذا الإصدار من Jarz POS قديم ولم يعد قابلاً للاستخدام. ثبّت أحدث إصدار للمتابعة.';

  @override
  String appUpdateBuildLine(Object current, Object minimum) {
    return 'الإصدار المثبّت $current · الإصدار المطلوب $minimum';
  }

  @override
  String get appUpdateDownloadButton => 'تنزيل التحديث';

  @override
  String get appUpdateRecheckButton => 'قمت بالتثبيت — أعد المحاولة';

  @override
  String get appUpdateOpenFailed =>
      'تعذّر فتح صفحة التنزيل. اطلب رابط التثبيت من المدير.';

  @override
  String get appUpdateInstallHint =>
      'سيطلب المتصفّح إذناً لتثبيت التطبيقات من هذا المصدر. اسمح بذلك، ثم افتح الملف المُنزّل للتثبيت.';

  @override
  String get appUpdateAvailableBanner => 'يتوفر إصدار جديد — اضغط للتنزيل.';

  @override
  String get materialsZoomedIn => 'قرّب على التفاصيل';

  @override
  String get materialsDownloadedFile => 'حمّل الملف';

  @override
  String materialsReadFor(Object time) {
    return 'قرأها لمدة $time';
  }

  @override
  String materialsPagesRead(Object count) {
    return '$count صفحات';
  }

  @override
  String get commonDone => 'تم';

  @override
  String get visitAddToRoute => 'إضافة إلى مسار';

  @override
  String get visitAddStop => 'إضافة';

  @override
  String get visitAddedToRoute => 'تمت الإضافة إلى المسار';

  @override
  String get visitOpenRoute => 'فتح';

  @override
  String visitWhichDoor(int count) {
    return 'أي فرع؟ ($count بموقع محدد)';
  }

  @override
  String get visitWhichDay => 'أي يوم';

  @override
  String get visitNewRoute => 'مسار جديد…';

  @override
  String visitNewRouteOn(String date) {
    return 'مسار جديد يوم $date';
  }

  @override
  String get visitNoUpcomingRoutes => 'لا توجد مسارات قادمة بعد.';

  @override
  String get visitNoDoorsToRoute => 'لا يوجد هنا ما يمكن التوجه إليه.';

  @override
  String get visitNoDoorsToRouteHint =>
      'لا يحتوي هذا السجل على فرع بموقع محدد. أضف الموقع أولاً ليصبح محطة.';

  @override
  String get visitFilters => 'عوامل التصفية';

  @override
  String get visitClearFilters => 'مسح الكل';

  @override
  String get visitFilterTier => 'فئة الملاءمة';

  @override
  String get visitFilterCategory => 'التصنيف';

  @override
  String get visitFilterArea => 'المنطقة';

  @override
  String visitFilterMinFit(int score) {
    return 'أقل درجة ملاءمة: $score';
  }

  @override
  String get visitFilterSpecialty => 'التخصصية فقط';

  @override
  String get visitFilterNeverVisited => 'التي لم تُزر من قبل فقط';

  @override
  String get visitFilterNeverVisitedHint => 'أماكن لم يدخلها أحد بعد.';

  @override
  String get visitEmptyDayHint =>
      'اختر الأماكن بالأسفل، أو اضغط «خطّط يومي». يتكوّن المسار أثناء اختيارك.';

  @override
  String get visitCostingDay => 'جارٍ حساب المسار…';

  @override
  String get visitManualOrderNote =>
      'ترتيبك أنت — اضغط «تحسين المسار» لإعادته تلقائياً.';

  @override
  String visitSkippedNoPin(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مكاناً بلا موقع ولن تظهر على المسار',
      few: '$countString أماكن بلا موقع ولن تظهر على المسار',
      two: 'مكانان بلا موقع ولن يظهرا على المسار',
      one: 'مكان واحد بلا موقع ولن يظهر على المسار',
    );
    return '$_temp0';
  }

  @override
  String get visitSaveDraft => 'حفظ كمسودة';

  @override
  String get shiftCourierCarryTitle => 'أموال ما زالت مع المندوبين';

  @override
  String shiftCourierCarryBody(int transactions, Object amount, int couriers) {
    return '$transactions طلب بقيمة $amount ما زالت مع $couriers مندوب. أكِّد كل طلب أو سوِّه الآن.';
  }

  @override
  String get shiftCourierCarryHint =>
      'علّم كل طلب ما زال نقده مع المندوب. أي طلب تتركه بدون تأكيد يجب تسويته قبل إغلاق الشيفت.';

  @override
  String get shiftCourierCarryConfirmAll => 'تأكيد الكل';

  @override
  String get shiftCourierCarryClearAll => 'إلغاء الكل';

  @override
  String get shiftCourierCarrySettleNow => 'تسوية مندوب الآن';

  @override
  String shiftCourierCarryConfirmedOf(int confirmed, int total) {
    return 'تم تأكيد $confirmed من $total';
  }

  @override
  String shiftCourierCarryRowLabel(Object invoice, Object customer) {
    return '$invoice — $customer';
  }

  @override
  String get shiftCourierCarryCheckboxLabel => 'النقد ما زال مع المندوب';

  @override
  String shiftCourierCarryCarriedBadge(int count, int days) {
    return 'مرحّل عبر $count شيفت · $days يوم خارج الفرع';
  }

  @override
  String get shiftCourierCarryUnconfirmed =>
      'أكِّد كل طلب ما زال مع مندوب، أو سوِّه، قبل إغلاق الشيفت.';

  @override
  String shiftCourierCarriedSummary(int count, Object amount) {
    return '$count طلب بقيمة $amount خرجت من الشيفت وما زالت مع المندوبين، وتبقى مفتوحة حتى تتم تسويتها.';
  }

  @override
  String shiftMonitorCarriedOut(int count, Object amount) {
    return 'مُرحَّل للخارج: $count · $amount';
  }

  @override
  String shiftMonitorSettledIn(int count, Object amount) {
    return 'محصَّل من شيفتات سابقة: $count · $amount';
  }

  @override
  String get shiftMonitorCourierOutstandingTitle => 'مع المندوبين الآن';

  @override
  String shiftMonitorCourierOutstandingSummary(
    Object amount,
    int transactions,
    int days,
  ) {
    return '$amount على $transactions طلب، وأقدمها $days يوم.';
  }

  @override
  String get shiftMonitorCourierOutstandingEmpty =>
      'لا يوجد مندوب يحمل نقدًا حاليًا.';

  @override
  String shiftMonitorCourierRow(Object name, Object branch) {
    return '$name · $branch';
  }

  @override
  String shiftMonitorCourierRowDetail(int count, Object amount, int days) {
    return '$count طلب · $amount · أقدمها $days يوم';
  }

  @override
  String get expensesAdvanceTabExpenses => 'المصروفات';

  @override
  String get expensesAdvanceTabAdvances => 'سلف الموظفين';

  @override
  String get expensesAdvanceNewRequest => 'سلفة جديدة';

  @override
  String get expensesAdvanceFormTitle => 'طلب سلفة لموظف';

  @override
  String get expensesAdvanceEmployeeLabel => 'الموظف';

  @override
  String get expensesAdvanceEmployeeRequired => 'اختر موظفًا';

  @override
  String get expensesAdvanceEmployeeHint => 'اضغط لاختيار موظف';

  @override
  String get expensesAdvanceEmployeePickerTitle => 'اختيار الموظف';

  @override
  String get expensesAdvanceEmployeeSearchHint =>
      'ابحث بالاسم أو الفرع أو القسم';

  @override
  String get expensesAdvanceEmployeeNoMatches => 'لا يوجد موظف مطابق للبحث';

  @override
  String get expensesAdvanceAmountLabel => 'قيمة السلفة';

  @override
  String get expensesAdvanceAmountInvalid => 'من فضلك أدخل قيمة صحيحة';

  @override
  String get expensesAdvancePurposeLabel => 'الغرض من السلفة';

  @override
  String get expensesAdvancePurposeRequired => 'اكتب سبب طلب السلفة';

  @override
  String get expensesAdvancePayFromLabel => 'الصرف من';

  @override
  String get expensesAdvancePaymentSourceRequired => 'اختر مصدر الصرف';

  @override
  String get expensesAdvanceDateLabel => 'تاريخ السلفة (اختياري)';

  @override
  String get expensesAdvanceDateNotSet => 'اليوم';

  @override
  String get expensesAdvanceDateClear => 'مسح التاريخ';

  @override
  String get expensesAdvanceSubmit => 'إرسال الطلب';

  @override
  String get expensesAdvanceNoOptions =>
      'لا يمكن طلب سلفة قبل توفر قائمة الموظفين ومصدر للصرف.';

  @override
  String get expensesAdvanceSubmitted => 'تم إرسال طلب السلفة للاعتماد';

  @override
  String get expensesAdvanceMonthLabel => 'الشهر';

  @override
  String get expensesAdvanceStatusFilterLabel => 'الحالة';

  @override
  String get expensesAdvanceStatusFilterAll => 'كل الحالات';

  @override
  String get expensesAdvanceEmptyTitle => 'لا توجد سلف موظفين لهذا الشهر.';

  @override
  String get expensesAdvanceEmptyApproverBody =>
      'ستظهر هنا طلبات مديري الخطوط في انتظار الاعتماد.';

  @override
  String get expensesAdvanceEmptyRequesterBody =>
      'استخدم زر سلفة جديدة لطلب نقدية لموظف.';

  @override
  String get expensesAdvanceEmptyReadOnlyBody =>
      'لا تملك صلاحية طلب أو اعتماد السلف.';

  @override
  String get expensesAdvanceUnavailableTitle => 'سلف الموظفين غير متاحة';

  @override
  String get expensesAdvanceUnavailableBody =>
      'وحدة الموارد البشرية غير مثبتة على هذا الموقع، لذلك لا يمكن طلب السلف من هنا.';

  @override
  String get expensesAdvanceSummaryTotal => 'الإجمالي';

  @override
  String get expensesAdvanceSummaryPending => 'في انتظار الاعتماد';

  @override
  String get expensesAdvanceSummaryApproved => 'المعتمدة';

  @override
  String get expensesAdvanceSummaryOutstanding => 'المتبقي';

  @override
  String expensesAdvanceSummaryCount(int count) {
    return '$count طلب';
  }

  @override
  String expensesAdvanceSummaryPendingValue(int count, Object amount) {
    return '$count | $amount';
  }

  @override
  String get expensesAdvanceApprove => 'اعتماد وصرف';

  @override
  String get expensesAdvanceReject => 'رفض';

  @override
  String get expensesAdvanceApproveTitle => 'اعتماد السلفة؟';

  @override
  String expensesAdvanceApproveBody(
    Object amount,
    Object employee,
    Object source,
  ) {
    return 'الاعتماد يصرف $amount إلى $employee الآن من $source. تخرج النقدية من هذا الحساب فورًا ولا يمكن التراجع عن ذلك من هذه الشاشة.';
  }

  @override
  String get expensesAdvanceApproveConfirm => 'اعتماد وصرف الآن';

  @override
  String get expensesAdvanceApproved => 'تم اعتماد السلفة وصرفها';

  @override
  String expensesAdvanceApprovedWithEntry(Object entry) {
    return 'تم اعتماد السلفة وصرفها · $entry';
  }

  @override
  String get expensesAdvanceRejectTitle => 'رفض طلب السلفة؟';

  @override
  String get expensesAdvanceRejectHint => 'وضح لمقدم الطلب سبب الرفض';

  @override
  String get expensesAdvanceRejectReasonRequired => 'السبب مطلوب';

  @override
  String get expensesAdvanceRejected => 'تم رفض طلب السلفة';

  @override
  String get expensesAdvanceIdLabel => 'رقم السلفة';

  @override
  String get expensesAdvancePostingDateLabel => 'تاريخ السلفة';

  @override
  String get expensesAdvanceBranchLabel => 'الفرع';

  @override
  String get expensesAdvancePayingAccountLabel => 'حساب الصرف';

  @override
  String get expensesAdvancePaidLabel => 'المصروف';

  @override
  String get expensesAdvanceClaimedLabel => 'المسوى';

  @override
  String get expensesAdvanceReturnedLabel => 'المرتجع';

  @override
  String get expensesAdvanceBalanceLabel => 'الرصيد المتبقي';

  @override
  String get expensesAdvanceRequestedByLabel => 'مقدم الطلب';

  @override
  String get expensesAdvanceApprovedByLabel => 'المعتمد';

  @override
  String get expensesAdvanceApprovedOnLabel => 'تاريخ الاعتماد';

  @override
  String get expensesAdvancePaymentEntryLabel => 'سند الدفع';

  @override
  String get expensesAdvanceStatusDraft => 'في انتظار الاعتماد';

  @override
  String get expensesAdvanceStatusPaid => 'مصروفة';

  @override
  String get expensesAdvanceStatusPartiallyPaid => 'مصروفة جزئيا';

  @override
  String get expensesAdvanceStatusUnpaid => 'غير مصروفة';

  @override
  String get expensesAdvanceStatusClaimed => 'تمت التسوية';

  @override
  String get expensesAdvanceStatusReturned => 'مرتجعة';

  @override
  String get expensesAdvanceStatusPartlyClaimedAndReturned =>
      'تسوية جزئية وإرجاع';

  @override
  String get expensesAdvanceStatusCancelled => 'ملغاة';

  @override
  String get managerEmployeeLedgerTitle => 'حساب الموظفين';

  @override
  String get managerEmployeeLedgerSubtitle =>
      'المستحق على كل موظف: السلف النقدية + الطلبات غير المدفوعة';

  @override
  String get managerEmployeeLedgerPeriodLabel => 'الفترة';

  @override
  String get managerEmployeeLedgerWindow30 => 'آخر 30 يوم';

  @override
  String get managerEmployeeLedgerWindow90 => 'آخر 90 يوم';

  @override
  String get managerEmployeeLedgerWindow180 => 'آخر 180 يوم';

  @override
  String get managerEmployeeLedgerWindow365 => 'آخر 365 يوم';

  @override
  String managerEmployeeLedgerActivityRange(Object from, Object to) {
    return 'الحركة المعروضة: من $from إلى $to';
  }

  @override
  String get managerEmployeeLedgerActivityInPeriod => 'الحركة في الفترة دي';

  @override
  String get managerEmployeeLedgerTotalOutstanding =>
      'إجمالي المستحق في الفترة دي';

  @override
  String get managerEmployeeLedgerTotalOutstandingAllTime =>
      'إجمالي المستحق (كل الفترات)';

  @override
  String get managerEmployeeLedgerAllTimeHint =>
      'كل المستحقات المفتوحة مهما كان تاريخها. الفترة تحت بتحدد السطور المعروضة بس.';

  @override
  String get managerEmployeeLedgerAdvancesLabel => 'السلف النقدية';

  @override
  String get managerEmployeeLedgerOrdersLabel => 'طلبات غير مدفوعة';

  @override
  String managerEmployeeLedgerAdvanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سلفة',
      few: '$count سلف',
      two: 'سلفتين',
      one: 'سلفة واحدة',
      zero: 'مفيش سلف',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      few: '$count طلبات',
      two: 'طلبين',
      one: 'طلب واحد',
      zero: 'مفيش طلبات',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص عليهم مستحقات',
      few: '$count أشخاص عليهم مستحقات',
      two: 'شخصين عليهم مستحقات',
      one: 'شخص واحد عليه مستحقات',
      zero: 'مفيش حد عليه مستحقات',
    );
    return '$_temp0';
  }

  @override
  String managerEmployeeLedgerSplit(Object advances, Object orders) {
    return 'سلف $advances • طلبات $orders';
  }

  @override
  String get managerEmployeeLedgerOutstandingLabel => 'المستحق';

  @override
  String get managerEmployeeLedgerOrderTotalLabel => 'إجمالي الطلب';

  @override
  String get managerEmployeeLedgerAdvanceAmountLabel => 'السلفة';

  @override
  String get managerEmployeeLedgerEmpty =>
      'مفيش مستحقات، ومفيش حركة في الفترة دي';

  @override
  String get managerEmployeeLedgerNoAdvances => 'مفيش سلف نقدية في الفترة دي';

  @override
  String get managerEmployeeLedgerNoOrders =>
      'مفيش طلبات غير مدفوعة في الفترة دي';

  @override
  String get managerEmployeeLedgerBalancePredatesPeriod =>
      'مفيش حاجة معروضة في الفترة دي. الرصيد فوق أقدم من كده، فوسع الفترة عشان تشوف السطور اللي وراه.';

  @override
  String get managerEmployeeLedgerUnmatched => 'مش مربوط بموظف';

  @override
  String get managerEmployeeLedgerLoadFailed => 'تعذر تحميل حساب الموظفين';

  @override
  String get managerEmployeeLedgerNoticeNoBranchAssigned =>
      'مفيش فرع متخصص ليك، فمفيش حاجة تتعرض هنا لسه.';

  @override
  String get managerEmployeeLedgerNoticeBranchNotPermitted =>
      'مش مسموح لك تشوف الفرع ده، فاتم تجاهله.';

  @override
  String get managerEmployeeLedgerNoticeHrmsUnavailable =>
      'نظام HRMS مش متثبت، فالسلف النقدية مش بتتسجل. الطلبات غير المدفوعة لسه بتتعرض.';

  @override
  String get managerEmployeeLedgerNoticeResultsTruncated =>
      'بتتعرض أول النتائج بس. ضيق الفرع أو الفترة عشان تشوف الباقي.';

  @override
  String get kanbanStateReceived => 'مستلم';

  @override
  String get kanbanStateInProgress => 'بيتجهز';

  @override
  String get kanbanStateReady => 'جاهز';

  @override
  String get cancelReasonCustomerRequested => 'العميل طلب الإلغاء';

  @override
  String get cancelReasonCreatedInError => 'الطلب اتعمل بالغلط أو مكرر';

  @override
  String get cancelReasonInventoryUnavailable => 'البضاعة مش متوفرة';

  @override
  String get cancelReasonPaymentIssue => 'مشكلة في الدفع';

  @override
  String get cancelReasonOther => 'سبب تاني';

  @override
  String get notSuitableReasonOutOfBusiness => 'قافل خلاص';

  @override
  String get notSuitableReasonWrongCategory => 'نشاط مش مناسب';

  @override
  String get notSuitableReasonTooSmall => 'صغير أوي';

  @override
  String get notSuitableReasonNoContactInfo => 'مفيش بيانات تواصل';

  @override
  String get notSuitableReasonUnreachable => 'مش بيرد';

  @override
  String get notSuitableReasonAlreadySupplied => 'متعامل مع مورّد تاني';

  @override
  String get notSuitableReasonPriceMismatch => 'السعر مش مناسب';

  @override
  String get notSuitableReasonOutsideDeliveryArea => 'برة نطاق التوصيل';

  @override
  String get notSuitableReasonDuplicate => 'مكرر';

  @override
  String get notSuitableReasonNotInterested => 'مش مهتم';

  @override
  String get notSuitableReasonOther => 'سبب تاني';

  @override
  String get leadSourceWalkIn => 'جه بنفسه';

  @override
  String get leadSourceReference => 'ترشيح';

  @override
  String get leadSourceCampaign => 'حملة إعلانية';

  @override
  String get leadSourceExistingCustomer => 'عميل حالي';

  @override
  String get leadSourceColdCall => 'اتصال مباشر';

  @override
  String get leadSourceSocialMedia => 'سوشال ميديا';

  @override
  String get customerSegmentChampion => 'أفضل العملاء';

  @override
  String get customerSegmentLoyal => 'عميل وفي';

  @override
  String get customerSegmentPotentialLoyalist => 'قرّب يبقى وفي';

  @override
  String get customerSegmentNewCustomer => 'عميل جديد';

  @override
  String get customerSegmentAtRisk => 'في خطر';

  @override
  String get customerSegmentCantLoseThem => 'مينفعش نخسرهم';

  @override
  String get customerSegmentLost => 'خسرناه';

  @override
  String get customerSegmentOneTime => 'طلب مرة واحدة';

  @override
  String get customerSegmentUnclassified => 'غير مصنّف';

  @override
  String get velocityTrendAccelerating => 'بيزيد';

  @override
  String get velocityTrendStable => 'ثابت';

  @override
  String get velocityTrendDeclining => 'بيقل';

  @override
  String get velocityTrendNewItem => 'صنف جديد';

  @override
  String get velocityTrendNoSales => 'مفيش مبيعات';

  @override
  String get visitStatusPlanned => 'مخططة';

  @override
  String get visitStatusInProgress => 'جارية';

  @override
  String get visitStatusVisited => 'اتزارت';

  @override
  String get visitStatusSkipped => 'اتخطّت';

  @override
  String get materialTypePriceList => 'قائمة أسعار';

  @override
  String get materialTypeProductPhotos => 'صور المنتجات';

  @override
  String get materialTypeCatalog => 'كتالوج';

  @override
  String get materialTypeCertificate => 'شهادة';

  @override
  String get materialTypeOther => 'غير كده';

  @override
  String get b2bStageShortLead => 'محتمل';

  @override
  String get b2bStageShortQualify => 'تأهيل';

  @override
  String get b2bStageShortSample => 'عينة';

  @override
  String get b2bStageShortApproved => 'موافقة';

  @override
  String get b2bStageShortTrial => 'تجربة';

  @override
  String get b2bStageShortCheckup => 'متابعة';

  @override
  String get b2bStageShortActive => 'نشط';

  @override
  String get b2bStageShortLostOnHold => 'خسران';

  @override
  String get statusChanged => 'اتغيّر';

  @override
  String get statusSettled => 'متسوّي';

  @override
  String get statusUnsettled => 'لسه متسوّاش';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusPaused => 'متوقف مؤقتاً';

  @override
  String get statusEnded => 'منتهي';

  @override
  String get statusClosed => 'مقفول';

  @override
  String get statusInProgress => 'جاري';

  @override
  String get reportsColumnItem => 'الصنف';

  @override
  String get reportsColumnVelocity30d => 'سرعة ٣٠ ي';

  @override
  String get reportsColumnVelocity60d => 'سرعة ٦٠ ي';

  @override
  String get reportsColumnTrend => 'الاتجاه';

  @override
  String get reportsColumnStock => 'الرصيد';

  @override
  String get reportsColumnCover => 'أيام التغطية';

  @override
  String get reportsColumnSold => 'المُباع';

  @override
  String get reportsColumnRevenue => 'الإيراد';

  @override
  String get reportsColumnVelocity => 'السرعة';

  @override
  String get menuShiftDistribution => 'توزيع الشيفتات';

  @override
  String get rosterTitle => 'توزيع الشيفتات';

  @override
  String get rosterAccessDenied =>
      'توزيع الشيفتات متاح للمديرين ومديري الخطوط فقط.';

  @override
  String get rosterHoursTitle => 'الساعات والوقت الإضافي';

  @override
  String get rosterHoursBasis =>
      'ساعات حسب الجدول — الشيفتات المخصصة فعليًا. الوقت الإضافي يُحتسب بمعدل كل موظف.';

  @override
  String get rosterPreviousMonth => 'الشهر السابق';

  @override
  String get rosterNextMonth => 'الشهر التالي';

  @override
  String get rosterAllBranches => 'كل الفروع';

  @override
  String get rosterEmployeeColumn => 'الموظف';

  @override
  String get rosterHrmsMissing =>
      'تطبيق الموارد البشرية غير مثبت على هذا الموقع، لذا لا يوجد جدول للعرض.';

  @override
  String get rosterNobodyRostered => 'لا يوجد أحد مُدرج في جدول هذا الشهر بعد.';

  @override
  String get rosterScopeUnconfigured =>
      'لا توجد فروع مرتبطة بملفات نقاط البيع الخاصة بك، لذا لا يوجد من يُعرض. اطلب من المسؤول ضبط موقع الشيفت في ملف نقطة البيع.';

  @override
  String rosterUncoveredWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام إجازة بدون تغطية',
      two: 'يوما إجازة بدون تغطية',
      one: 'يوم إجازة واحد بدون تغطية',
    );
    return '$_temp0';
  }

  @override
  String rosterStandardDay(Object hours) {
    return 'اليوم العادي: $hours ساعة';
  }

  @override
  String get rosterOffShort => 'إجازة';

  @override
  String get rosterHolidayShort => 'عطلة';

  @override
  String get rosterChangeShift => 'تغيير الشيفت';

  @override
  String get rosterMarkDayOff => 'تسجيل يوم إجازة';

  @override
  String get rosterClearDayOff => 'إلغاء يوم الإجازة';

  @override
  String get rosterNoShiftTypes => 'لم يتم إعداد أي أنواع شيفتات بعد.';

  @override
  String rosterShiftWindow(Object window, Object hours) {
    return '$window · $hours ساعة';
  }

  @override
  String rosterWorkingShift(Object shiftType, Object hours, Object location) {
    return 'على $shiftType · $hours ساعة · $location';
  }

  @override
  String rosterOffCoveredBy(Object offType, Object name) {
    return 'إجازة ($offType) — يغطيها $name';
  }

  @override
  String rosterOffUncovered(Object offType) {
    return 'إجازة ($offType) — لا أحد يغطي هذا اليوم';
  }

  @override
  String get rosterHoliday => 'عطلة رسمية';

  @override
  String get rosterUnrosteredWarning =>
      'غير مُدرج في الجدول — لن يتمكن هذا الموظف من تسجيل الحضور في هذا اليوم.';

  @override
  String get rosterOffType => 'السبب';

  @override
  String get rosterCoveredBy => 'التغطية بواسطة';

  @override
  String get rosterCoverHelper => 'من يتحمل هذا اليوم في الفرع.';

  @override
  String get rosterNobodyCovers => 'لا أحد';

  @override
  String get rosterCoverShift => 'شيفت التغطية';

  @override
  String get rosterCoverShiftHelper =>
      'الشيفت الذي ينتقل إليه في هذا اليوم، عادةً شيفت اليوم الكامل الأطول.';

  @override
  String get rosterNotes => 'ملاحظات (اختياري)';

  @override
  String get rosterOffTypeWeekly => 'راحة أسبوعية';

  @override
  String get rosterOffTypeVacation => 'إجازة';

  @override
  String get rosterOffTypeSick => 'إجازة مرضية';

  @override
  String get rosterOffTypeUnpaid => 'إجازة بدون أجر';

  @override
  String get rosterOffTypeOther => 'أخرى';

  @override
  String get rosterWorkedHours => 'ساعات العمل';

  @override
  String get rosterOvertimeHours => 'الوقت الإضافي';

  @override
  String get rosterCreditedOvertime => 'الإضافي المحتسب';

  @override
  String get rosterCreditedHours => 'الساعات المدفوعة';

  @override
  String rosterCourierTag(Object multiplier) {
    return 'مندوب ×$multiplier';
  }

  @override
  String rosterRowDays(Object worked, Object off, Object cover) {
    return '$worked عمل · $off إجازة · $cover تغطية';
  }

  @override
  String get rosterLegendWorking => 'عمل';

  @override
  String get rosterLegendOff => 'إجازة';

  @override
  String get rosterLegendUnrostered => 'غير مُدرج';

  @override
  String get rosterLegendHoliday => 'عطلة';

  @override
  String get settlementPartnerFeeInputLabel => 'تكلفة التوصيل لدى الشريك';

  @override
  String get settlementPartnerFeeInputHint => 'اقرأها من تطبيق الشريك';

  @override
  String get settlementPartnerFeeRequired =>
      'أدخل تكلفة التوصيل لدى الشريك لهذا الطلب';

  @override
  String get settlementPartnerFeeInvalid => 'أدخل مبلغًا صحيحًا';

  @override
  String get settlementPartnerFeeWhy =>
      'أسعار مناطقنا لا تنطبق على الشريك — فهو يسعّر هذا العنوان بنفسه.';

  @override
  String get settlementPartnerNoDeduction =>
      'المندوب يسلّم المبلغ كاملًا. لا يُخصم شيء مقابل أجرته — تُحاسب شركته أسبوعيًا.';
}
