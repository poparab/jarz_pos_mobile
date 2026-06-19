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
      stage: json['stage'] as String,
      owner: json['owner'] as String?,
      leadScore: (json['lead_score'] as num?)?.toInt(),
      customer: json['customer'] as String?,
      lastActivity: json['last_activity'] as String?,
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
  postingDate: json['posting_date'] as String?,
  grandTotal: (json['grand_total'] as num?)?.toDouble(),
  orderPurpose: json['custom_order_purpose'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$$B2bRecentInvoiceImplToJson(
  _$B2bRecentInvoiceImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'posting_date': instance.postingDate,
  'grand_total': instance.grandTotal,
  'custom_order_purpose': instance.orderPurpose,
  'status': instance.status,
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
      stage: json['stage'] as String,
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
      orderPurpose: json['order_purpose'] as String,
      priceList: json['price_list'] as String?,
    );

Map<String, dynamic> _$$OrderBindingImplToJson(_$OrderBindingImpl instance) =>
    <String, dynamic>{
      'customer': instance.customer,
      'order_purpose': instance.orderPurpose,
      'price_list': instance.priceList,
    };
