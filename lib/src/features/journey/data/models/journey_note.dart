// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'journey_note.freezed.dart';
part 'journey_note.g.dart';

/// One dated touch in a rep's field diary: a visit, a call, a sample drop.
///
/// The point of a journey note is the DATE and the PERSON. [entryDate] is when
/// the touch happened (not when the row was written — a rep logs yesterday's
/// visit this morning), [contactPerson]/[contactRole] is who was spoken to, and
/// [nextAction] on [nextActionDate] is what was promised. The backend stamps
/// that next-action date onto the lead's follow-up field, so a note saying
/// "call the manager Thursday" also produces the Thursday reminder.
@freezed
class JourneyNote with _$JourneyNote {
  const JourneyNote._();

  const factory JourneyNote({
    required String name,
    @JsonKey(name: 'reference_doctype') @Default('') String referenceDoctype,
    @JsonKey(name: 'reference_name') @Default('') String referenceName,
    @JsonKey(name: 'entry_date') String? entryDate,
    @JsonKey(name: 'entry_type') @Default('') String entryType,
    @Default('') String note,
    @JsonKey(name: 'contact_person') @Default('') String contactPerson,
    @JsonKey(name: 'contact_role') @Default('') String contactRole,
    @JsonKey(name: 'contact_phone') @Default('') String contactPhone,
    @JsonKey(name: 'next_action') @Default('') String nextAction,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @Default('') String outcome,
    @JsonKey(name: 'logged_by') @Default('') String loggedBy,
    @JsonKey(name: 'logged_by_name') @Default('') String loggedByName,
    String? creation,
    String? modified,
    /// Whether the CURRENT user may edit/delete this note — the server decides
    /// (author or manager), the app only honours the answer.
    @JsonKey(name: 'can_edit') @Default(false) bool canEdit,
  }) = _JourneyNote;

  factory JourneyNote.fromJson(Map<String, dynamic> json) =>
      _$JourneyNoteFromJson(json);

  /// Who to chase, formatted for a single line: "Mostafa (Branch Manager)".
  String get contactLabel {
    final person = contactPerson.trim();
    final role = contactRole.trim();
    if (person.isEmpty) return role;
    if (role.isEmpty) return person;
    return '$person ($role)';
  }

  bool get hasNextAction =>
      (nextActionDate ?? '').isNotEmpty || nextAction.trim().isNotEmpty;
}

/// The compact journey summary a pipeline card / catalog row carries: when the
/// prospect was last touched and what is due next.
///
/// Parsed from the SAME flat keys the backend folds into the card and lead
/// payloads, so it is constructed from those maps rather than owning an
/// endpoint of its own.
@freezed
class JourneySummary with _$JourneySummary {
  const JourneySummary._();

  const factory JourneySummary({
    @JsonKey(name: 'journey_count') @Default(0) int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
  }) = _JourneySummary;

  factory JourneySummary.fromJson(Map<String, dynamic> json) =>
      _$JourneySummaryFromJson(json);

  bool get isEmpty => journeyCount == 0 && (lastJourneyDate ?? '').isEmpty;
  bool get hasNextAction => (nextActionDate ?? '').isNotEmpty;
}

/// The Select options the note editor offers, served by the backend so the app
/// never drifts from the DocType.
@freezed
class JourneyOptions with _$JourneyOptions {
  const factory JourneyOptions({
    @JsonKey(name: 'entry_types') @Default(<String>[]) List<String> entryTypes,
    @Default(<String>[]) List<String> outcomes,
  }) = _JourneyOptions;

  factory JourneyOptions.fromJson(Map<String, dynamic> json) =>
      _$JourneyOptionsFromJson(json);
}
