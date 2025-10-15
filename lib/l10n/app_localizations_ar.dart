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
  String get menuPurchaseInvoice => 'فواتير الشراء';

  @override
  String get menuManufacturing => 'التصنيع';

  @override
  String get menuStockTransfer => 'تحويل المخزون';

  @override
  String get menuCashTransfer => 'تحويل النقدية';

  @override
  String get menuInventoryCount => 'جرد المخزون';

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
  String get commonOk => 'حسنًا';

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
  String get courierBalancesPreviewTooltip => 'معاينة التسوية';

  @override
  String courierBalancesPreviewFailed(Object error) {
    return 'فشل تحميل معاينة التسوية: $error';
  }

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
}
