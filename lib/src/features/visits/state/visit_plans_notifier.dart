import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journey/presentation/journey_format.dart';
import '../data/models/visit_plan.dart';
import '../data/visits_repository.dart';

/// What the visit calendar is asking the server for.
///
/// A value type rather than three loose providers, for the same reason
/// [ActionCalendarQuery] is one: every field is a server-side filter, so a
/// change to any of them is the same event — a refetch of a different window.
/// Keying the data provider on the whole query makes that automatic and stops
/// a stale month painting over a fresh one.
class VisitPlansQuery {
  const VisitPlansQuery({required this.month, this.scope = 'mine'});

  /// Any day inside the visible month; only year and month are ever read.
  final DateTime month;

  /// 'mine' | 'all'. A manager watching the whole team wants 'all'.
  final String scope;

  DateTime get firstDay => DateTime(month.year, month.month, 1);

  /// Day 0 of the NEXT month is the last day of this one, which sidesteps
  /// leap years and 30/31-day arithmetic entirely.
  DateTime get lastDay => DateTime(month.year, month.month + 1, 0);

  String get fromDate => JourneyFormat.iso(firstDay);
  String get toDate => JourneyFormat.iso(lastDay);

  VisitPlansQuery copyWith({DateTime? month, String? scope}) =>
      VisitPlansQuery(month: month ?? this.month, scope: scope ?? this.scope);

  VisitPlansQuery shiftedBy(int months) =>
      copyWith(month: DateTime(month.year, month.month + months, 1));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitPlansQuery &&
          other.month.year == month.year &&
          other.month.month == month.month &&
          other.scope == scope);

  @override
  int get hashCode => Object.hash(month.year, month.month, scope);

  @override
  String toString() => 'VisitPlansQuery($fromDate..$toDate, $scope)';
}

/// The calendar's current query. Held in a provider rather than screen state so
/// the month arrows and the scope toggle mutate one object.
final visitPlansQueryProvider =
    NotifierProvider.autoDispose<VisitPlansQueryNotifier, VisitPlansQuery>(
        VisitPlansQueryNotifier.new);

class VisitPlansQueryNotifier extends AutoDisposeNotifier<VisitPlansQuery> {
  @override
  VisitPlansQuery build() => VisitPlansQuery(month: DateTime.now());

  void nextMonth() => state = state.shiftedBy(1);
  void previousMonth() => state = state.shiftedBy(-1);
  void goToMonth(DateTime month) => state = state.copyWith(month: month);
  void setScope(String scope) => state = state.copyWith(scope: scope);
}

/// The plans in the visible window.
final visitPlansProvider =
    FutureProvider.autoDispose<List<VisitPlan>>((ref) async {
  final query = ref.watch(visitPlansQueryProvider);
  return ref.watch(visitsRepositoryProvider).getPlans(
        fromDate: query.fromDate,
        toDate: query.toDate,
        scope: query.scope,
      );
});

/// Plans bucketed by their date, for painting the month grid.
///
/// Derived rather than fetched separately: one request feeds both the grid and
/// the day list under it, so the two can never disagree about what is on a day.
final visitPlansByDayProvider =
    Provider.autoDispose<Map<String, List<VisitPlan>>>((ref) {
  final plans = ref.watch(visitPlansProvider).valueOrNull ?? const <VisitPlan>[];
  final byDay = <String, List<VisitPlan>>{};
  for (final plan in plans) {
    final date = (plan.visitDate ?? '').trim();
    if (date.isEmpty) continue;
    byDay.putIfAbsent(date, () => <VisitPlan>[]).add(plan);
  }
  return byDay;
});

/// Which routing engine is answering. Cached for the session: it changes when
/// an operator changes a setting, not while a rep is looking at a route.
final routeEngineStatusProvider =
    FutureProvider<RouteEngineStatus>((ref) async {
  try {
    return await ref.watch(visitsRepositoryProvider).getEngineStatus();
  } catch (_) {
    // A status call that fails must not take the planner down with it — the
    // fallback engine is exactly what the default describes.
    return const RouteEngineStatus();
  }
});
