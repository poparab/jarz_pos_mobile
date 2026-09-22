// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b2b_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$B2bCardImpl _$$B2bCardImplFromJson(Map<String, dynamic> json) =>
    _$B2bCardImpl(
      doctype: json['doctype'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      stage: json['stage'] as String? ?? 'Lead',
      owner: json['owner'] as String?,
      leadScore: (json['lead_score'] as num?)?.toInt(),
      customer: json['customer'] as String?,
      lastActivity: json['last_activity'] as String?,
      labelAlert: (json['label_alert'] as num?)?.toInt() ?? 0,
      journeyCount: (json['journey_count'] as num?)?.toInt() ?? 0,
      lastJourneyDate: json['last_journey_date'] as String?,
      lastJourneyType: json['last_journey_type'] as String?,
      lastJourneyNote: json['last_journey_note'] as String?,
      lastJourneyContact: json['last_journey_contact'] as String?,
      nextActionDate: json['next_action_date'] as String?,
      nextAction: json['next_action'] as String?,
    );

Map<String, dynamic> _$$B2bCardImplToJson(_$B2bCardImpl instance) =>
    <String, dynamic>{
      'doctype': instance.doctype,
      'name': instance.name,
      'title': instance.title,
      'stage': instance.stage,
      'owner': instance.owner,
      'lead_score': instance.leadScore,
      'customer': instance.customer,
      'last_activity': instance.lastActivity,
      'label_alert': instance.labelAlert,
      'journey_count': instance.journeyCount,
      'last_journey_date': instance.lastJourneyDate,
      'last_journey_type': instance.lastJourneyType,
      'last_journey_note': instance.lastJourneyNote,
      'last_journey_contact': instance.lastJourneyContact,
      'next_action_date': instance.nextActionDate,
      'next_action': instance.nextAction,
    };

_$B2bContactImpl _$$B2bContactImplFromJson(Map<String, dynamic> json) =>
    _$B2bContactImpl(
      mobileNo: json['mobile_no'] as String?,
      emailId: json['email_id'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$B2bContactImplToJson(_$B2bContactImpl instance) =>
    <String, dynamic>{
      'mobile_no': instance.mobileNo,
      'email_id': instance.emailId,
      'phone': instance.phone,
    };

_$B2bRecentInvoiceImpl _$$B2bRecentInvoiceImplFromJson(
  Map<String, dynamic> json,
) => _$B2bRecentInvoiceImpl(
  name: json['name'] as String,
  wooOrderId: const _NullableIntConverter().fromJson(json['woo_order_id']),
  postingDate: json['posting_date'] as String?,
  grandTotal: const _NullableDoubleConverter().fromJson(json['grand_total']),
  outstandingAmount: const _NullableDoubleConverter().fromJson(
    json['outstanding_amount'],
  ),
  orderPurpose: json['custom_order_purpose'] as String?,
  paymentMethod: const _NullableStringConverter().fromJson(
    json['custom_payment_method'],
  ),
  status: json['status'] as String?,
  isReturn: json['is_return'] == null
      ? false
      : const _BoolConverter().fromJson(json['is_return']),
  branchAddress: const _NullableStringConverter().fromJson(
    json['branch_address'],
  ),
  branchName: const _NullableStringConverter().fromJson(json['branch_name']),
);

Map<String, dynamic> _$$B2bRecentInvoiceImplToJson(
  _$B2bRecentInvoiceImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'woo_order_id': const _NullableIntConverter().toJson(instance.wooOrderId),
  'posting_date': instance.postingDate,
  'grand_total': const _NullableDoubleConverter().toJson(instance.grandTotal),
  'outstanding_amount': const _NullableDoubleConverter().toJson(
    instance.outstandingAmount,
  ),
  'custom_order_purpose': instance.orderPurpose,
  'custom_payment_method': const _NullableStringConverter().toJson(
    instance.paymentMethod,
  ),
  'status': instance.status,
  'is_return': const _BoolConverter().toJson(instance.isReturn),
  'branch_address': const _NullableStringConverter().toJson(
    instance.branchAddress,
  ),
  'branch_name': const _NullableStringConverter().toJson(instance.branchName),
};

_$B2bBranchStatsImpl _$$B2bBranchStatsImplFromJson(Map<String, dynamic> json) =>
    _$B2bBranchStatsImpl(
      invoiceCount: json['invoice_count'] == null
          ? 0
          : const _IntConverter().fromJson(json['invoice_count']),
      totalBilled: json['total_billed'] == null
          ? 0.0
          : const _DoubleConverter().fromJson(json['total_billed']),
      outstanding: json['outstanding'] == null
          ? 0.0
          : const _DoubleConverter().fromJson(json['outstanding']),
      lastOrderDate: const _NullableStringConverter().fromJson(
        json['last_order_date'],
      ),
    );

Map<String, dynamic> _$$B2bBranchStatsImplToJson(
  _$B2bBranchStatsImpl instance,
) => <String, dynamic>{
  'invoice_count': const _IntConverter().toJson(instance.invoiceCount),
  'total_billed': const _DoubleConverter().toJson(instance.totalBilled),
  'outstanding': const _DoubleConverter().toJson(instance.outstanding),
  'last_order_date': const _NullableStringConverter().toJson(
    instance.lastOrderDate,
  ),
};

_$B2bBranchImpl _$$B2bBranchImplFromJson(
  Map<String, dynamic> json,
) => _$B2bBranchImpl(
  addressName: const _NullableStringConverter().fromJson(json['address_name']),
  branchName: const _NullableStringConverter().fromJson(json['branch_name']),
  addressLine1: const _NullableStringConverter().fromJson(
    json['address_line1'],
  ),
  addressLine2: const _NullableStringConverter().fromJson(
    json['address_line2'],
  ),
  city: const _NullableStringConverter().fromJson(json['city']),
  phone: const _NullableStringConverter().fromJson(json['phone']),
  territory: const _NullableStringConverter().fromJson(json['territory']),
  territoryMissing: json['territory_missing'] == null
      ? false
      : const _BoolConverter().fromJson(json['territory_missing']),
  isPrimaryAddress: json['is_primary_address'] == null
      ? false
      : const _BoolConverter().fromJson(json['is_primary_address']),
  latitude: const _NullableDoubleConverter().fromJson(json['latitude']),
  longitude: const _NullableDoubleConverter().fromJson(json['longitude']),
  memberAddressNames: json['member_address_names'] == null
      ? const <String>[]
      : const _StringListConverter().fromJson(json['member_address_names']),
  invoiceCount: json['invoice_count'] == null
      ? 0
      : const _IntConverter().fromJson(json['invoice_count']),
  totalBilled: json['total_billed'] == null
      ? 0.0
      : const _DoubleConverter().fromJson(json['total_billed']),
  outstanding: json['outstanding'] == null
      ? 0.0
      : const _DoubleConverter().fromJson(json['outstanding']),
  lastOrderDate: const _NullableStringConverter().fromJson(
    json['last_order_date'],
  ),
);

Map<String, dynamic> _$$B2bBranchImplToJson(
  _$B2bBranchImpl instance,
) => <String, dynamic>{
  'address_name': const _NullableStringConverter().toJson(instance.addressName),
  'branch_name': const _NullableStringConverter().toJson(instance.branchName),
  'address_line1': const _NullableStringConverter().toJson(
    instance.addressLine1,
  ),
  'address_line2': const _NullableStringConverter().toJson(
    instance.addressLine2,
  ),
  'city': const _NullableStringConverter().toJson(instance.city),
  'phone': const _NullableStringConverter().toJson(instance.phone),
  'territory': const _NullableStringConverter().toJson(instance.territory),
  'territory_missing': const _BoolConverter().toJson(instance.territoryMissing),
  'is_primary_address': const _BoolConverter().toJson(
    instance.isPrimaryAddress,
  ),
  'latitude': const _NullableDoubleConverter().toJson(instance.latitude),
  'longitude': const _NullableDoubleConverter().toJson(instance.longitude),
  'member_address_names': const _StringListConverter().toJson(
    instance.memberAddressNames,
  ),
  'invoice_count': const _IntConverter().toJson(instance.invoiceCount),
  'total_billed': const _DoubleConverter().toJson(instance.totalBilled),
  'outstanding': const _DoubleConverter().toJson(instance.outstanding),
  'last_order_date': const _NullableStringConverter().toJson(
    instance.lastOrderDate,
  ),
};

_$B2bAccountInvoicesImpl _$$B2bAccountInvoicesImplFromJson(
  Map<String, dynamic> json,
) => _$B2bAccountInvoicesImpl(
  customer: const _NullableStringConverter().fromJson(json['customer']),
  branch: const _NullableStringConverter().fromJson(json['branch']),
  invoices:
      (json['invoices'] as List<dynamic>?)
          ?.map((e) => B2bRecentInvoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <B2bRecentInvoice>[],
  summary: json['summary'] == null
      ? const B2bBranchStats()
      : B2bBranchStats.fromJson(json['summary'] as Map<String, dynamic>),
  truncated: json['truncated'] == null
      ? false
      : const _BoolConverter().fromJson(json['truncated']),
);

Map<String, dynamic> _$$B2bAccountInvoicesImplToJson(
  _$B2bAccountInvoicesImpl instance,
) => <String, dynamic>{
  'customer': const _NullableStringConverter().toJson(instance.customer),
  'branch': const _NullableStringConverter().toJson(instance.branch),
  'invoices': instance.invoices,
  'summary': instance.summary,
  'truncated': const _BoolConverter().toJson(instance.truncated),
};

_$B2bMergeCandidateImpl _$$B2bMergeCandidateImplFromJson(
  Map<String, dynamic> json,
) => _$B2bMergeCandidateImpl(
  doctype: json['doctype'] as String? ?? 'Lead',
  name: json['name'] as String,
  title: const _NullableStringConverter().fromJson(json['title']),
  customer: const _NullableStringConverter().fromJson(json['customer']),
  stage: const _NullableStringConverter().fromJson(json['stage']),
  area: const _NullableStringConverter().fromJson(json['area']),
  mobileNo: const _NullableStringConverter().fromJson(json['mobile_no']),
  branchCount: json['branch_count'] == null
      ? 0
      : const _IntConverter().fromJson(json['branch_count']),
);

Map<String, dynamic> _$$B2bMergeCandidateImplToJson(
  _$B2bMergeCandidateImpl instance,
) => <String, dynamic>{
  'doctype': instance.doctype,
  'name': instance.name,
  'title': const _NullableStringConverter().toJson(instance.title),
  'customer': const _NullableStringConverter().toJson(instance.customer),
  'stage': const _NullableStringConverter().toJson(instance.stage),
  'area': const _NullableStringConverter().toJson(instance.area),
  'mobile_no': const _NullableStringConverter().toJson(instance.mobileNo),
  'branch_count': const _IntConverter().toJson(instance.branchCount),
};

_$B2bMergePartyImpl _$$B2bMergePartyImplFromJson(Map<String, dynamic> json) =>
    _$B2bMergePartyImpl(
      doctype: const _NullableStringConverter().fromJson(json['doctype']),
      name: const _NullableStringConverter().fromJson(json['name']),
      title: const _NullableStringConverter().fromJson(json['title']),
      lead: const _NullableStringConverter().fromJson(json['lead']),
      customer: const _NullableStringConverter().fromJson(json['customer']),
    );

Map<String, dynamic> _$$B2bMergePartyImplToJson(_$B2bMergePartyImpl instance) =>
    <String, dynamic>{
      'doctype': const _NullableStringConverter().toJson(instance.doctype),
      'name': const _NullableStringConverter().toJson(instance.name),
      'title': const _NullableStringConverter().toJson(instance.title),
      'lead': const _NullableStringConverter().toJson(instance.lead),
      'customer': const _NullableStringConverter().toJson(instance.customer),
    };

_$B2bMergePlanImpl _$$B2bMergePlanImplFromJson(Map<String, dynamic> json) =>
    _$B2bMergePlanImpl(
      customerAction: const _NullableStringConverter().fromJson(
        json['customer_action'],
      ),
      leadAction: const _NullableStringConverter().fromJson(
        json['lead_action'],
      ),
      requiresManager: json['requires_manager'] == null
          ? false
          : const _BoolConverter().fromJson(json['requires_manager']),
      finalCustomer: const _NullableStringConverter().fromJson(
        json['final_customer'],
      ),
    );

Map<String, dynamic> _$$B2bMergePlanImplToJson(
  _$B2bMergePlanImpl instance,
) => <String, dynamic>{
  'customer_action': const _NullableStringConverter().toJson(
    instance.customerAction,
  ),
  'lead_action': const _NullableStringConverter().toJson(instance.leadAction),
  'requires_manager': const _BoolConverter().toJson(instance.requiresManager),
  'final_customer': const _NullableStringConverter().toJson(
    instance.finalCustomer,
  ),
};

_$B2bMergeCustomerSummaryImpl _$$B2bMergeCustomerSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$B2bMergeCustomerSummaryImpl(
  name: const _NullableStringConverter().fromJson(json['name']),
  customerName: const _NullableStringConverter().fromJson(
    json['customer_name'],
  ),
  invoiceCount: json['invoice_count'] == null
      ? 0
      : const _IntConverter().fromJson(json['invoice_count']),
  totalBilled: json['total_billed'] == null
      ? 0.0
      : const _DoubleConverter().fromJson(json['total_billed']),
  outstanding: json['outstanding'] == null
      ? 0.0
      : const _DoubleConverter().fromJson(json['outstanding']),
  addressCount: json['address_count'] == null
      ? 0
      : const _IntConverter().fromJson(json['address_count']),
  creditAllowed: json['credit_allowed'] == null
      ? false
      : const _BoolConverter().fromJson(json['credit_allowed']),
);

Map<String, dynamic> _$$B2bMergeCustomerSummaryImplToJson(
  _$B2bMergeCustomerSummaryImpl instance,
) => <String, dynamic>{
  'name': const _NullableStringConverter().toJson(instance.name),
  'customer_name': const _NullableStringConverter().toJson(
    instance.customerName,
  ),
  'invoice_count': const _IntConverter().toJson(instance.invoiceCount),
  'total_billed': const _DoubleConverter().toJson(instance.totalBilled),
  'outstanding': const _DoubleConverter().toJson(instance.outstanding),
  'address_count': const _IntConverter().toJson(instance.addressCount),
  'credit_allowed': const _BoolConverter().toJson(instance.creditAllowed),
};

_$B2bMergePreviewImpl _$$B2bMergePreviewImplFromJson(
  Map<String, dynamic> json,
) => _$B2bMergePreviewImpl(
  source: json['source'] == null
      ? const B2bMergeParty()
      : B2bMergeParty.fromJson(json['source'] as Map<String, dynamic>),
  target: json['target'] == null
      ? const B2bMergeParty()
      : B2bMergeParty.fromJson(json['target'] as Map<String, dynamic>),
  plan: json['plan'] == null
      ? const B2bMergePlan()
      : B2bMergePlan.fromJson(json['plan'] as Map<String, dynamic>),
  sourceCustomer: json['source_customer'] == null
      ? null
      : B2bMergeCustomerSummary.fromJson(
          json['source_customer'] as Map<String, dynamic>,
        ),
  targetCustomer: json['target_customer'] == null
      ? null
      : B2bMergeCustomerSummary.fromJson(
          json['target_customer'] as Map<String, dynamic>,
        ),
  canExecute: json['can_execute'] == null
      ? false
      : const _BoolConverter().fromJson(json['can_execute']),
  warnings: json['warnings'] == null
      ? const <String>[]
      : const _StringListConverter().fromJson(json['warnings']),
  blockers: json['blockers'] == null
      ? const <String>[]
      : const _StringListConverter().fromJson(json['blockers']),
);

Map<String, dynamic> _$$B2bMergePreviewImplToJson(
  _$B2bMergePreviewImpl instance,
) => <String, dynamic>{
  'source': instance.source,
  'target': instance.target,
  'plan': instance.plan,
  'source_customer': instance.sourceCustomer,
  'target_customer': instance.targetCustomer,
  'can_execute': const _BoolConverter().toJson(instance.canExecute),
  'warnings': const _StringListConverter().toJson(instance.warnings),
  'blockers': const _StringListConverter().toJson(instance.blockers),
};

_$B2bTodoImpl _$$B2bTodoImplFromJson(Map<String, dynamic> json) =>
    _$B2bTodoImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$B2bTodoImplToJson(_$B2bTodoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'date': instance.date,
    };

_$B2bAccountImpl _$$B2bAccountImplFromJson(Map<String, dynamic> json) =>
    _$B2bAccountImpl(
      doctype: json['doctype'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      stage: json['stage'] as String? ?? 'Customer',
      owner: json['owner'] as String?,
      contact: json['contact'] == null
          ? const B2bContact()
          : B2bContact.fromJson(json['contact'] as Map<String, dynamic>),
      customer: json['customer'] as String?,
      predictedNextOrder: json['predicted_next_order'] as String?,
      avgOrderCycleDays: (json['avg_order_cycle_days'] as num?)?.toDouble(),
      recentInvoices:
          (json['recent_invoices'] as List<dynamic>?)
              ?.map((e) => B2bRecentInvoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <B2bRecentInvoice>[],
      openTodos:
          (json['open_todos'] as List<dynamic>?)
              ?.map((e) => B2bTodo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <B2bTodo>[],
      branches:
          (json['branches'] as List<dynamic>?)
              ?.map((e) => B2bBranch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <B2bBranch>[],
      unassignedInvoices: json['unassigned_invoices'] == null
          ? null
          : B2bBranchStats.fromJson(
              json['unassigned_invoices'] as Map<String, dynamic>,
            ),
      journeyNotes:
          (json['journey_notes'] as List<dynamic>?)
              ?.map((e) => JourneyNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <JourneyNote>[],
    );

Map<String, dynamic> _$$B2bAccountImplToJson(_$B2bAccountImpl instance) =>
    <String, dynamic>{
      'doctype': instance.doctype,
      'name': instance.name,
      'title': instance.title,
      'stage': instance.stage,
      'owner': instance.owner,
      'contact': instance.contact,
      'customer': instance.customer,
      'predicted_next_order': instance.predictedNextOrder,
      'avg_order_cycle_days': instance.avgOrderCycleDays,
      'recent_invoices': instance.recentInvoices,
      'open_todos': instance.openTodos,
      'branches': instance.branches,
      'unassigned_invoices': instance.unassignedInvoices,
      'journey_notes': instance.journeyNotes,
    };

_$FollowupItemImpl _$$FollowupItemImplFromJson(Map<String, dynamic> json) =>
    _$FollowupItemImpl(
      name: json['name'] as String,
      referenceType: json['reference_type'] as String?,
      referenceName: json['reference_name'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$FollowupItemImplToJson(_$FollowupItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'reference_type': instance.referenceType,
      'reference_name': instance.referenceName,
      'description': instance.description,
      'date': instance.date,
    };

_$ReorderDueItemImpl _$$ReorderDueItemImplFromJson(Map<String, dynamic> json) =>
    _$ReorderDueItemImpl(
      name: json['name'] as String,
      customerName: json['customer_name'] as String?,
      lastOrderDate: json['last_order_date'] as String?,
      avgBasketValue: (json['avg_basket_value'] as num?)?.toDouble(),
      predictedNextOrder: json['predicted_next_order'] as String?,
    );

Map<String, dynamic> _$$ReorderDueItemImplToJson(
  _$ReorderDueItemImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'customer_name': instance.customerName,
  'last_order_date': instance.lastOrderDate,
  'avg_basket_value': instance.avgBasketValue,
  'predicted_next_order': instance.predictedNextOrder,
};

_$B2bFollowupsImpl _$$B2bFollowupsImplFromJson(Map<String, dynamic> json) =>
    _$B2bFollowupsImpl(
      todos:
          (json['todos'] as List<dynamic>?)
              ?.map((e) => FollowupItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FollowupItem>[],
      reorderDue:
          (json['reorder_due'] as List<dynamic>?)
              ?.map((e) => ReorderDueItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReorderDueItem>[],
    );

Map<String, dynamic> _$$B2bFollowupsImplToJson(_$B2bFollowupsImpl instance) =>
    <String, dynamic>{
      'todos': instance.todos,
      'reorder_due': instance.reorderDue,
    };

_$OrderBindingImpl _$$OrderBindingImplFromJson(Map<String, dynamic> json) =>
    _$OrderBindingImpl(
      customer: json['customer'] as String,
      customerName: json['customer_name'] as String?,
      orderPurpose: json['order_purpose'] as String,
      priceList: json['price_list'] as String?,
      addressBook:
          json['address_book'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      requiresShippingAddressSelection:
          json['requires_shipping_address_selection'] as bool? ?? false,
      shippingAddressName: json['shipping_address_name'] as String?,
    );

Map<String, dynamic> _$$OrderBindingImplToJson(_$OrderBindingImpl instance) =>
    <String, dynamic>{
      'customer': instance.customer,
      'customer_name': instance.customerName,
      'order_purpose': instance.orderPurpose,
      'price_list': instance.priceList,
      'address_book': instance.addressBook,
      'requires_shipping_address_selection':
          instance.requiresShippingAddressSelection,
      'shipping_address_name': instance.shippingAddressName,
    };
