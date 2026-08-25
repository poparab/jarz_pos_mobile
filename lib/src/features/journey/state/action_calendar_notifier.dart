import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/journey_repository.dart';
import '../data/models/journey_action.dart';
import '../presentation/journey_format.dart';

/// What the calendar is currently asking the server for.
///
/// A value type, not three loose providers: every field is a server-side
/// filter, so a change to any of them is the SAME thing — a refetch of a
/// different window. Keying the data provider on the whole query makes that
/// automatic and keeps a stale month from painting over a new one.
class ActionCalendarQuery {
  const ActionCalendarQuery({
    required this.month,
    this.scope = 'mine',
    this.includeDone = false,
  });

  /// Any day inside the visible month; only year+month are ever used.
  final DateTime month;

  /// 'mine' | 'all'.
  final String scope;
  final bool includeDone;

  /// First day of the visible month — the window's `from_date`.
  DateTime get firstDay => DateTime(month.year, month.month, 1);

  /// Last day of the visible month. Day 0 of the NEXT month is the last day of
  /// this one, which sidesteps leap years and 30/31-day arithmetic.
  DateTime get lastDay => DateTime(month.year, month.month + 1, 0);

  String get fromDate => JourneyFormat.iso(firstDay);
  String get toDate => JourneyFormat.iso(lastDay);

  ActionCalendarQuery copyWith({
    DateTime? month,
    String? scope,
    bool? includeDone,
  }) =>
      ActionCalendarQuery(
        month: month ?? this.month,
        scope: scope ?? this.scope,
        includeDone: includeDone ?? this.includeDone,
      );

  ActionCalendarQuery shiftedBy(int months) =>
      copyWith(month: DateTime(month.year, month.month + months, 1));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionCalendarQuery &&
          other.month.year == month.year &&
          other.month.month == month.month &&
          other.scope == scope &&
          other.includeDone == includeDone);

  @override
  int get hashCode => Object.hash(month.year, month.month, scope, includeDone);

  @override
  String toString() =>
      'ActionCalendarQuery($fromDate..$toDate, $scope, done=$includeDone)';
}

/// The screen's current query. Held in a provider rather than screen state so
/// the month arrows, the scope toggle and the done toggle all mutate one
/// object and the data provider re-keys off it.
final actionCalendarQueryProvider = NotifierProvider.autoDispose<
    ActionCalendarQueryNotifier,
    ActionCalendarQuery>(ActionCalendarQueryNotifier.new);

class ActionCalendarQueryNotifier
    extends AutoDisposeNotifier<ActionCalendarQuery> {
  @override
  ActionCalendarQuery build() => ActionCalendarQuery(month: DateTime.now());

  void nextMonth() => state = state.shiftedBy(1);
  void previousMonth() => state = state.shiftedBy(-1);
  void setScope(String scope) => state = state.copyWith(scope: scope);
  void setIncludeDone(bool includeDone) =>
      state = state.copyWith(includeDone: includeDone);
}

/// Everything due in the queried window.
///
/// autoDispose + family: paging back through months must not pin a year of
/// payloads in memory, and returning to a month refetches — a rep ticking
/// actions off elsewhere in the app is the normal case, not the exception.
final actionCalendarProvider = FutureProvider.autoDispose
    .family<JourneyActionCalendar, ActionCalendarQuery>((ref, query) {
  return ref.read(journeyRepositoryProvider).getActionCalendar(
        fromDate: query.fromDate,
        toDate: query.toDate,
        scope: query.scope,
        includeDone: query.includeDone,
      );
});
