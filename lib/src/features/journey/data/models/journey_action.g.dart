// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JourneyActionImpl _$$JourneyActionImplFromJson(Map<String, dynamic> json) =>
    _$JourneyActionImpl(
      source: json['source'] as String? ?? '',
      note: json['note'] as String? ?? '',
      referenceDoctype: json['reference_doctype'] as String? ?? '',
      referenceName: json['reference_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      action: json['action'] as String? ?? '',
      contactPerson: json['contact_person'] as String? ?? '',
      entryType: json['entry_type'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      overdue: json['overdue'] as bool? ?? false,
      owner: json['owner'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      canComplete: json['can_complete'] as bool? ?? false,
    );

Map<String, dynamic> _$$JourneyActionImplToJson(_$JourneyActionImpl instance) =>
    <String, dynamic>{
      'source': instance.source,
      'note': instance.note,
      'reference_doctype': instance.referenceDoctype,
      'reference_name': instance.referenceName,
      'title': instance.title,
      'date': instance.date,
      'action': instance.action,
      'contact_person': instance.contactPerson,
      'entry_type': instance.entryType,
      'done': instance.done,
      'overdue': instance.overdue,
      'owner': instance.owner,
      'owner_name': instance.ownerName,
      'can_complete': instance.canComplete,
    };

_$JourneyActionCountsImpl _$$JourneyActionCountsImplFromJson(
  Map<String, dynamic> json,
) => _$JourneyActionCountsImpl(
  pending: (json['pending'] as num?)?.toInt() ?? 0,
  overdue: (json['overdue'] as num?)?.toInt() ?? 0,
  done: (json['done'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$JourneyActionCountsImplToJson(
  _$JourneyActionCountsImpl instance,
) => <String, dynamic>{
  'pending': instance.pending,
  'overdue': instance.overdue,
  'done': instance.done,
};

_$JourneyActionCalendarImpl _$$JourneyActionCalendarImplFromJson(
  Map<String, dynamic> json,
) => _$JourneyActionCalendarImpl(
  fromDate: json['from_date'] as String? ?? '',
  toDate: json['to_date'] as String? ?? '',
  scope: json['scope'] as String? ?? 'mine',
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => JourneyAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <JourneyAction>[],
  counts: json['counts'] == null
      ? const JourneyActionCounts()
      : JourneyActionCounts.fromJson(json['counts'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$JourneyActionCalendarImplToJson(
  _$JourneyActionCalendarImpl instance,
) => <String, dynamic>{
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'scope': instance.scope,
  'actions': instance.actions,
  'counts': instance.counts,
};
