// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerCreditProfileImpl _$$CustomerCreditProfileImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerCreditProfileImpl(
  customer: json['customer'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
  creditAllowed: json['credit_allowed'] == null
      ? false
      : creditBool(json['credit_allowed']),
  creditDays: json['credit_days'] == null ? 0 : creditInt(json['credit_days']),
  creditLimit: json['credit_limit'] == null
      ? 0.0
      : creditDouble(json['credit_limit']),
  currentBalance: json['current_balance'] == null
      ? 0.0
      : creditDouble(json['current_balance']),
  availableCredit: json['available_credit'] == null
      ? 0.0
      : creditDouble(json['available_credit']),
  currency: json['currency'] as String? ?? '',
);

Map<String, dynamic> _$$CustomerCreditProfileImplToJson(
  _$CustomerCreditProfileImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'credit_allowed': instance.creditAllowed,
  'credit_days': instance.creditDays,
  'credit_limit': instance.creditLimit,
  'current_balance': instance.currentBalance,
  'available_credit': instance.availableCredit,
  'currency': instance.currency,
};

_$CreditLedgerFiltersImpl _$$CreditLedgerFiltersImplFromJson(
  Map<String, dynamic> json,
) => _$CreditLedgerFiltersImpl(
  customer: json['customer'] as String? ?? '',
  posProfile: json['pos_profile'] as String? ?? '',
  fromDate: json['from_date'] as String? ?? '',
  toDate: json['to_date'] as String? ?? '',
  limit: json['limit'] == null ? 0 : creditInt(json['limit']),
);

Map<String, dynamic> _$$CreditLedgerFiltersImplToJson(
  _$CreditLedgerFiltersImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'pos_profile': instance.posProfile,
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'limit': instance.limit,
};

_$CreditLedgerSummaryImpl _$$CreditLedgerSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$CreditLedgerSummaryImpl(
  totalOutstanding: json['total_outstanding'] == null
      ? 0.0
      : creditDouble(json['total_outstanding']),
  customerCount: json['customer_count'] == null
      ? 0
      : creditInt(json['customer_count']),
  invoiceCount: json['invoice_count'] == null
      ? 0
      : creditInt(json['invoice_count']),
  currency: json['currency'] as String? ?? '',
  outstandingIsAllTime: json['outstanding_is_all_time'] == null
      ? true
      : creditAllTimeFlag(json['outstanding_is_all_time']),
);

Map<String, dynamic> _$$CreditLedgerSummaryImplToJson(
  _$CreditLedgerSummaryImpl instance,
) => <String, dynamic>{
  'total_outstanding': instance.totalOutstanding,
  'customer_count': instance.customerCount,
  'invoice_count': instance.invoiceCount,
  'currency': instance.currency,
  'outstanding_is_all_time': instance.outstandingIsAllTime,
};

_$CreditCustomerRowImpl _$$CreditCustomerRowImplFromJson(
  Map<String, dynamic> json,
) => _$CreditCustomerRowImpl(
  customer: json['customer'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
  totalOutstanding: json['total_outstanding'] == null
      ? 0.0
      : creditDouble(json['total_outstanding']),
  invoiceCount: json['invoice_count'] == null
      ? 0
      : creditInt(json['invoice_count']),
  oldestInvoiceDate: json['oldest_invoice_date'] as String? ?? '',
  currency: json['currency'] as String? ?? '',
);

Map<String, dynamic> _$$CreditCustomerRowImplToJson(
  _$CreditCustomerRowImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'total_outstanding': instance.totalOutstanding,
  'invoice_count': instance.invoiceCount,
  'oldest_invoice_date': instance.oldestInvoiceDate,
  'currency': instance.currency,
};

_$CreditInvoiceImpl _$$CreditInvoiceImplFromJson(Map<String, dynamic> json) =>
    _$CreditInvoiceImpl(
      invoice: readInvoiceId(json, 'invoice') as String? ?? '',
      wooOrderId: json['woo_order_id'],
      customer: json['customer'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      postingDate: json['posting_date'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      grandTotal: json['grand_total'] == null
          ? 0.0
          : creditDouble(json['grand_total']),
      outstandingAmount: json['outstanding_amount'] == null
          ? 0.0
          : creditDouble(json['outstanding_amount']),
      status: json['status'] as String? ?? '',
      posProfile: json['pos_profile'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
    );

Map<String, dynamic> _$$CreditInvoiceImplToJson(_$CreditInvoiceImpl instance) =>
    <String, dynamic>{
      'invoice': instance.invoice,
      'woo_order_id': instance.wooOrderId,
      'customer': instance.customer,
      'customer_name': instance.customerName,
      'posting_date': instance.postingDate,
      'due_date': instance.dueDate,
      'grand_total': instance.grandTotal,
      'outstanding_amount': instance.outstandingAmount,
      'status': instance.status,
      'pos_profile': instance.posProfile,
      'branch': instance.branch,
      'currency': instance.currency,
    };

_$CreditLedgerImpl _$$CreditLedgerImplFromJson(
  Map<String, dynamic> json,
) => _$CreditLedgerImpl(
  success: json['success'] as bool? ?? true,
  filters: json['filters'] == null
      ? const CreditLedgerFilters()
      : CreditLedgerFilters.fromJson(json['filters'] as Map<String, dynamic>),
  summary: json['summary'] == null
      ? const CreditLedgerSummary()
      : CreditLedgerSummary.fromJson(json['summary'] as Map<String, dynamic>),
  customers:
      (json['customers'] as List<dynamic>?)
          ?.map((e) => CreditCustomerRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CreditCustomerRow>[],
  invoices:
      (json['invoices'] as List<dynamic>?)
          ?.map((e) => CreditInvoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CreditInvoice>[],
  noticeCode: json['notice_code'] as String?,
  notice: json['notice'] as String?,
);

Map<String, dynamic> _$$CreditLedgerImplToJson(_$CreditLedgerImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'filters': instance.filters,
      'summary': instance.summary,
      'customers': instance.customers,
      'invoices': instance.invoices,
      'notice_code': instance.noticeCode,
      'notice': instance.notice,
    };

_$CreditPaymentAllocationImpl _$$CreditPaymentAllocationImplFromJson(
  Map<String, dynamic> json,
) => _$CreditPaymentAllocationImpl(
  invoice: readInvoiceId(json, 'invoice') as String? ?? '',
  wooOrderId: json['woo_order_id'],
  allocatedAmount: readAllocatedAmount(json, 'allocated_amount') == null
      ? 0.0
      : creditDouble(readAllocatedAmount(json, 'allocated_amount')),
  outstandingBefore: json['outstanding_before'] == null
      ? 0.0
      : creditDouble(json['outstanding_before']),
  fullySettled: json['fully_settled'] as bool? ?? false,
  postingDate: json['posting_date'] as String? ?? '',
);

Map<String, dynamic> _$$CreditPaymentAllocationImplToJson(
  _$CreditPaymentAllocationImpl instance,
) => <String, dynamic>{
  'invoice': instance.invoice,
  'woo_order_id': instance.wooOrderId,
  'allocated_amount': instance.allocatedAmount,
  'outstanding_before': instance.outstandingBefore,
  'fully_settled': instance.fullySettled,
  'posting_date': instance.postingDate,
};

_$CreditPaymentResultImpl _$$CreditPaymentResultImplFromJson(
  Map<String, dynamic> json,
) => _$CreditPaymentResultImpl(
  success: json['success'] as bool? ?? true,
  paymentEntry: json['payment_entry'] as String? ?? '',
  customer: json['customer'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
  amount: json['amount'] == null ? 0.0 : creditDouble(json['amount']),
  totalAllocated: readTotalAllocated(json, 'total_allocated') == null
      ? 0.0
      : creditDouble(readTotalAllocated(json, 'total_allocated')),
  unallocatedAmount: readUnallocatedAmount(json, 'unallocated_amount') == null
      ? 0.0
      : creditDouble(readUnallocatedAmount(json, 'unallocated_amount')),
  remainingBalance: creditDoubleOrNull(json['remaining_balance']),
  allocations:
      (readAllocations(json, 'allocations') as List<dynamic>?)
          ?.map(
            (e) => CreditPaymentAllocation.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <CreditPaymentAllocation>[],
  currency: json['currency'] as String? ?? '',
);

Map<String, dynamic> _$$CreditPaymentResultImplToJson(
  _$CreditPaymentResultImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'payment_entry': instance.paymentEntry,
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'amount': instance.amount,
  'total_allocated': instance.totalAllocated,
  'unallocated_amount': instance.unallocatedAmount,
  'remaining_balance': instance.remainingBalance,
  'allocations': instance.allocations,
  'currency': instance.currency,
};
