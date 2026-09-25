// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettlementTermsImpl _$$SettlementTermsImplFromJson(
  Map<String, dynamic> json,
) => _$SettlementTermsImpl(
  customer: json['customer'] == null ? '' : settlementString(json['customer']),
  enabled: json['enabled'] == null
      ? true
      : settlementBoolDefaultTrue(json['enabled']),
  cycle: json['cycle'] == null ? '' : settlementString(json['cycle']),
  weekdays: json['weekdays'] == null ? '' : settlementCsv(json['weekdays']),
  weekInterval: json['week_interval'] == null
      ? 1
      : settlementIntDefaultOne(json['week_interval']),
  monthDays: json['month_days'] == null
      ? ''
      : settlementCsv(json['month_days']),
  intervalDays: creditIntOrNull(json['interval_days']),
  anchorDate: json['anchor_date'] == null
      ? ''
      : settlementString(json['anchor_date']),
  remindDaysBefore: creditIntOrNull(json['remind_days_before']),
  overdueRepeatDays: creditIntOrNull(json['overdue_repeat_days']),
  responsibleUser: json['responsible_user'] == null
      ? ''
      : settlementString(json['responsible_user']),
  notes: json['notes'] == null ? '' : settlementString(json['notes']),
  exists: json['exists'] == null
      ? true
      : settlementBoolDefaultTrue(json['exists']),
);

Map<String, dynamic> _$$SettlementTermsImplToJson(
  _$SettlementTermsImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'enabled': instance.enabled,
  'cycle': instance.cycle,
  'weekdays': instance.weekdays,
  'week_interval': instance.weekInterval,
  'month_days': instance.monthDays,
  'interval_days': instance.intervalDays,
  'anchor_date': instance.anchorDate,
  'remind_days_before': instance.remindDaysBefore,
  'overdue_repeat_days': instance.overdueRepeatDays,
  'responsible_user': instance.responsibleUser,
  'notes': instance.notes,
  'exists': instance.exists,
};

_$SettlementStatusImpl _$$SettlementStatusImplFromJson(
  Map<String, dynamic> json,
) => _$SettlementStatusImpl(
  state: json['state'] == null ? '' : settlementString(json['state']),
  nextDueDate: json['next_due_date'] == null
      ? ''
      : settlementString(json['next_due_date']),
  nextDueAmount: json['next_due_amount'] == null
      ? 0.0
      : creditDouble(json['next_due_amount']),
  dueNowAmount: json['due_now_amount'] == null
      ? 0.0
      : creditDouble(json['due_now_amount']),
  overdueAmount: json['overdue_amount'] == null
      ? 0.0
      : creditDouble(json['overdue_amount']),
  openBalance: json['open_balance'] == null
      ? 0.0
      : creditDouble(json['open_balance']),
  oldestOverdueDate: json['oldest_overdue_date'] == null
      ? ''
      : settlementString(json['oldest_overdue_date']),
  upcomingDates: json['upcoming_dates'] == null
      ? const <String>[]
      : settlementStringList(json['upcoming_dates']),
  collectOnNextDelivery: creditDoubleOrNull(json['collect_on_next_delivery']),
);

Map<String, dynamic> _$$SettlementStatusImplToJson(
  _$SettlementStatusImpl instance,
) => <String, dynamic>{
  'state': instance.state,
  'next_due_date': instance.nextDueDate,
  'next_due_amount': instance.nextDueAmount,
  'due_now_amount': instance.dueNowAmount,
  'overdue_amount': instance.overdueAmount,
  'open_balance': instance.openBalance,
  'oldest_overdue_date': instance.oldestOverdueDate,
  'upcoming_dates': instance.upcomingDates,
  'collect_on_next_delivery': instance.collectOnNextDelivery,
};

_$SettlementTermsResponseImpl _$$SettlementTermsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SettlementTermsResponseImpl(
  success: json['success'] as bool? ?? true,
  customer: json['customer'] == null ? '' : settlementString(json['customer']),
  customerName: json['customer_name'] == null
      ? ''
      : settlementString(json['customer_name']),
  partyType: json['party_type'] == null
      ? ''
      : settlementString(json['party_type']),
  party: json['party'] == null ? '' : settlementString(json['party']),
  terms: json['terms'] == null
      ? null
      : SettlementTerms.fromJson(json['terms'] as Map<String, dynamic>),
  description: json['description'] == null
      ? ''
      : settlementString(json['description']),
  status: json['status'] == null
      ? const SettlementStatus()
      : SettlementStatus.fromJson(json['status'] as Map<String, dynamic>),
  currency: json['currency'] == null ? '' : settlementString(json['currency']),
  canEdit: json['can_edit'] == null ? false : creditBool(json['can_edit']),
);

Map<String, dynamic> _$$SettlementTermsResponseImplToJson(
  _$SettlementTermsResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'party_type': instance.partyType,
  'party': instance.party,
  'terms': instance.terms,
  'description': instance.description,
  'status': instance.status,
  'currency': instance.currency,
  'can_edit': instance.canEdit,
};

_$CollectionDueRowImpl _$$CollectionDueRowImplFromJson(
  Map<String, dynamic> json,
) => _$CollectionDueRowImpl(
  customer: json['customer'] == null ? '' : settlementString(json['customer']),
  customerName: json['customer_name'] == null
      ? ''
      : settlementString(json['customer_name']),
  cycle: json['cycle'] == null ? '' : settlementString(json['cycle']),
  description: json['description'] == null
      ? ''
      : settlementString(json['description']),
  state: json['state'] == null ? '' : settlementString(json['state']),
  nextDueDate: json['next_due_date'] == null
      ? ''
      : settlementString(json['next_due_date']),
  nextDueAmount: json['next_due_amount'] == null
      ? 0.0
      : creditDouble(json['next_due_amount']),
  dueNowAmount: json['due_now_amount'] == null
      ? 0.0
      : creditDouble(json['due_now_amount']),
  overdueAmount: json['overdue_amount'] == null
      ? 0.0
      : creditDouble(json['overdue_amount']),
  openBalance: json['open_balance'] == null
      ? 0.0
      : creditDouble(json['open_balance']),
  responsibleUser: json['responsible_user'] == null
      ? ''
      : settlementString(json['responsible_user']),
);

Map<String, dynamic> _$$CollectionDueRowImplToJson(
  _$CollectionDueRowImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'cycle': instance.cycle,
  'description': instance.description,
  'state': instance.state,
  'next_due_date': instance.nextDueDate,
  'next_due_amount': instance.nextDueAmount,
  'due_now_amount': instance.dueNowAmount,
  'overdue_amount': instance.overdueAmount,
  'open_balance': instance.openBalance,
  'responsible_user': instance.responsibleUser,
};

_$CollectionsDueCountsImpl _$$CollectionsDueCountsImplFromJson(
  Map<String, dynamic> json,
) => _$CollectionsDueCountsImpl(
  overdue: json['overdue'] == null ? 0 : creditInt(json['overdue']),
  dueToday: json['due_today'] == null ? 0 : creditInt(json['due_today']),
  dueSoon: json['due_soon'] == null ? 0 : creditInt(json['due_soon']),
);

Map<String, dynamic> _$$CollectionsDueCountsImplToJson(
  _$CollectionsDueCountsImpl instance,
) => <String, dynamic>{
  'overdue': instance.overdue,
  'due_today': instance.dueToday,
  'due_soon': instance.dueSoon,
};

_$CollectionsDueImpl _$$CollectionsDueImplFromJson(
  Map<String, dynamic> json,
) => _$CollectionsDueImpl(
  success: json['success'] as bool? ?? true,
  currency: json['currency'] == null ? '' : settlementString(json['currency']),
  rows:
      (json['rows'] as List<dynamic>?)
          ?.map((e) => CollectionDueRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CollectionDueRow>[],
  counts: json['counts'] == null
      ? const CollectionsDueCounts()
      : CollectionsDueCounts.fromJson(json['counts'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CollectionsDueImplToJson(
  _$CollectionsDueImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'currency': instance.currency,
  'rows': instance.rows,
  'counts': instance.counts,
};
