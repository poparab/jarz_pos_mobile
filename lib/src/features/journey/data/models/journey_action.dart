// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'journey_action.freezed.dart';
part 'journey_action.g.dart';

/// One thing a rep owes somebody on a given day.
///
/// Two things produce an action and the calendar shows both: a journey note's
/// dated next action ([source] `journey`), and the plain follow-up date stamped
/// on the account itself ([source] `followup`, which has no note behind it —
/// hence the empty [note]). The app never re-derives either; the server folds
/// them into one list so a day cell counts what a rep would count.
@freezed
class JourneyAction with _$JourneyAction {
  const JourneyAction._();

  const factory JourneyAction({
    /// 'journey' | 'followup'.
    @Default('') String source,

    /// The journey note behind this action; empty when [source] is 'followup'.
    @Default('') String note,
    @JsonKey(name: 'reference_doctype') @Default('') String referenceDoctype,
    @JsonKey(name: 'reference_name') @Default('') String referenceName,

    /// The account's display name — what the rep recognises, not the id.
    @Default('') String title,

    /// Due date, ISO `yyyy-MM-dd`.
    @Default('') String date,
    @Default('') String action,
    @JsonKey(name: 'contact_person') @Default('') String contactPerson,
    @JsonKey(name: 'entry_type') @Default('') String entryType,
    @Default(false) bool done,

    /// Past due AND not done — the server decides against ITS clock, which is
    /// the one the reminders run on.
    @Default(false) bool overdue,
    @Default('') String owner,
    @JsonKey(name: 'owner_name') @Default('') String ownerName,

    /// Whether the CURRENT user may tick this off from the calendar.
    @JsonKey(name: 'can_complete') @Default(false) bool canComplete,
  }) = _JourneyAction;

  factory JourneyAction.fromJson(Map<String, dynamic> json) =>
      _$JourneyActionFromJson(json);

  /// Only a journey-backed action can be toggled through the journey endpoint;
  /// a bare follow-up has no note to stamp.
  bool get isJourney => source == 'journey' && note.isNotEmpty;

  /// A stable identity for list keys and for finding the row again after a
  /// refetch — a follow-up has no note name, so it falls back to the account.
  String get key =>
      note.isNotEmpty ? note : '$source:$referenceDoctype:$referenceName:$date';

  /// Whether the CURRENT user may tick this off, whichever endpoint that takes.
  /// A `followup` row completes through the record-level endpoint and cannot be
  /// re-opened, so an already-done one offers nothing.
  bool get canToggle => canComplete && (isJourney || !done);
}

/// The counts the header shows for the requested window, straight from the
/// server so the badge cannot disagree with the rows.
@freezed
class JourneyActionCounts with _$JourneyActionCounts {
  const JourneyActionCounts._();

  const factory JourneyActionCounts({
    @Default(0) int pending,
    @Default(0) int overdue,
    @Default(0) int done,
  }) = _JourneyActionCounts;

  factory JourneyActionCounts.fromJson(Map<String, dynamic> json) =>
      _$JourneyActionCountsFromJson(json);

  /// Pending that is NOT yet overdue.
  ///
  /// The server counts `overdue` as a SUBSET of `pending` (everything not done
  /// is pending; the overdue ones are the subset dated before today). Showing
  /// both raw would count the same promise twice, so the header shows this
  /// instead — which also matches the grid's dots, where a day's overdue and
  /// pending markers are already disjoint.
  int get upcoming {
    final rest = pending - overdue;
    return rest < 0 ? 0 : rest;
  }
}

/// Everything due in one date window — the payload behind the month grid.
@freezed
class JourneyActionCalendar with _$JourneyActionCalendar {
  const JourneyActionCalendar._();

  const factory JourneyActionCalendar({
    @JsonKey(name: 'from_date') @Default('') String fromDate,
    @JsonKey(name: 'to_date') @Default('') String toDate,

    /// 'mine' | 'all' — echoed back so the screen can trust that what it
    /// rendered is what it asked for.
    @Default('mine') String scope,
    @Default(<JourneyAction>[]) List<JourneyAction> actions,
    @Default(JourneyActionCounts()) JourneyActionCounts counts,
  }) = _JourneyActionCalendar;

  factory JourneyActionCalendar.fromJson(Map<String, dynamic> json) =>
      _$JourneyActionCalendarFromJson(json);

  bool get isEmpty => actions.isEmpty;

  /// The actions bucketed by their ISO day, which is exactly how the grid
  /// reads them: one lookup per cell instead of a scan of the whole list.
  Map<String, List<JourneyAction>> get byDay {
    final map = <String, List<JourneyAction>>{};
    for (final action in actions) {
      final day = action.date.trim();
      if (day.isEmpty) continue;
      (map[day] ??= <JourneyAction>[]).add(action);
    }
    return map;
  }
}
