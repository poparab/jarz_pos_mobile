// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JourneyNoteImpl _$$JourneyNoteImplFromJson(Map<String, dynamic> json) =>
    _$JourneyNoteImpl(
      name: json['name'] as String,
      referenceDoctype: json['reference_doctype'] as String? ?? '',
      referenceName: json['reference_name'] as String? ?? '',
      entryDate: json['entry_date'] as String?,
      entryType: json['entry_type'] as String? ?? '',
      note: json['note'] as String? ?? '',
      contactPerson: json['contact_person'] as String? ?? '',
      contactRole: json['contact_role'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      nextAction: json['next_action'] as String? ?? '',
      nextActionDate: json['next_action_date'] as String?,
      outcome: json['outcome'] as String? ?? '',
      loggedBy: json['logged_by'] as String? ?? '',
      loggedByName: json['logged_by_name'] as String? ?? '',
      creation: json['creation'] as String?,
      modified: json['modified'] as String?,
      canEdit: json['can_edit'] as bool? ?? false,
    );

Map<String, dynamic> _$$JourneyNoteImplToJson(_$JourneyNoteImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'reference_doctype': instance.referenceDoctype,
      'reference_name': instance.referenceName,
      'entry_date': instance.entryDate,
      'entry_type': instance.entryType,
      'note': instance.note,
      'contact_person': instance.contactPerson,
      'contact_role': instance.contactRole,
      'contact_phone': instance.contactPhone,
      'next_action': instance.nextAction,
      'next_action_date': instance.nextActionDate,
      'outcome': instance.outcome,
      'logged_by': instance.loggedBy,
      'logged_by_name': instance.loggedByName,
      'creation': instance.creation,
      'modified': instance.modified,
      'can_edit': instance.canEdit,
    };

_$JourneySummaryImpl _$$JourneySummaryImplFromJson(Map<String, dynamic> json) =>
    _$JourneySummaryImpl(
      journeyCount: (json['journey_count'] as num?)?.toInt() ?? 0,
      lastJourneyDate: json['last_journey_date'] as String?,
      lastJourneyType: json['last_journey_type'] as String?,
      lastJourneyNote: json['last_journey_note'] as String?,
      lastJourneyContact: json['last_journey_contact'] as String?,
      nextActionDate: json['next_action_date'] as String?,
      nextAction: json['next_action'] as String?,
    );

Map<String, dynamic> _$$JourneySummaryImplToJson(
  _$JourneySummaryImpl instance,
) => <String, dynamic>{
  'journey_count': instance.journeyCount,
  'last_journey_date': instance.lastJourneyDate,
  'last_journey_type': instance.lastJourneyType,
  'last_journey_note': instance.lastJourneyNote,
  'last_journey_contact': instance.lastJourneyContact,
  'next_action_date': instance.nextActionDate,
  'next_action': instance.nextAction,
};

_$JourneyOptionsImpl _$$JourneyOptionsImplFromJson(Map<String, dynamic> json) =>
    _$JourneyOptionsImpl(
      entryTypes:
          (json['entry_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      outcomes:
          (json['outcomes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$JourneyOptionsImplToJson(
  _$JourneyOptionsImpl instance,
) => <String, dynamic>{
  'entry_types': instance.entryTypes,
  'outcomes': instance.outcomes,
};

_$JourneyContactsImpl _$$JourneyContactsImplFromJson(
  Map<String, dynamic> json,
) => _$JourneyContactsImpl(
  contacts:
      (json['contacts'] as List<dynamic>?)
          ?.map((e) => LeadContact.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LeadContact>[],
  lead: json['lead'] as String? ?? '',
  canAdd: json['can_add'] as bool? ?? false,
  added: json['added'] == null
      ? null
      : LeadContact.fromJson(json['added'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$JourneyContactsImplToJson(
  _$JourneyContactsImpl instance,
) => <String, dynamic>{
  'contacts': instance.contacts,
  'lead': instance.lead,
  'can_add': instance.canAdd,
  'added': instance.added,
};
