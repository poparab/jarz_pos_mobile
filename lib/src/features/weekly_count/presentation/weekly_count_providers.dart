import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../approvals/state/pending_approvals_provider.dart';
import '../data/weekly_count_models.dart';
import '../data/weekly_count_service.dart';

/// How old the status may get before the banner or an app resume re-asks.
/// The banner is a reminder, not a live view: a few minutes is plenty, and it
/// keeps a cashier's device from asking on every screen change.
const weeklyCountStatusMaxAge = Duration(minutes: 3);

/// This week's count status for every branch the user can count.
///
/// Keep-alive: the banner (POS / Kanban home) and the drawer both read it,
/// so one fetch serves both. Refreshed when stale (banner mount, app resume),
/// and invalidated after a submit / approve / reject, on a weekly-count push,
/// and on logout.
final weeklyCountStatusProvider = FutureProvider<WeeklyCountStatus>((ref) {
  return ref.watch(weeklyCountServiceProvider).getStatus();
});

/// Re-ask for the status only when the cached one is older than
/// [weeklyCountStatusMaxAge] (or failed). Safe to call often.
void refreshWeeklyCountStatusIfStale(WidgetRef ref) {
  final current = ref.read(weeklyCountStatusProvider);
  final value = current.valueOrNull;
  if (current.isLoading && value == null) return;
  if (value == null ||
      current.hasError ||
      DateTime.now().difference(value.fetchedAt) > weeklyCountStatusMaxAge) {
    ref.invalidate(weeklyCountStatusProvider);
  }
}

/// The blind count sheet for one branch (no quantities).
final weeklyCountSheetProvider = FutureProvider.autoDispose
    .family<WeeklyCountSheet, String>((ref, posProfile) {
      return ref.watch(weeklyCountServiceProvider).getSheet(posProfile);
    });

/// How many pending counts the approvals list asks for. Pending is fetched on
/// its own so a burst of recent counts can never push one off the list.
const weeklyCountPendingLimit = 200;

/// How many recent counts (any status) the approvals list shows as history.
const weeklyCountRecentLimit = 50;

/// The approvals list: every pending count first, then the recent history.
final weeklyCountListProvider =
    FutureProvider.autoDispose<List<WeeklyCountSummary>>((ref) async {
      final service = ref.watch(weeklyCountServiceProvider);
      final results = await Future.wait([
        service.list(
          status: WeeklyCountDocStatus.pendingApproval,
          limit: weeklyCountPendingLimit,
        ),
        service.list(limit: weeklyCountRecentLimit),
      ]);
      return mergeWeeklyCountLists(pending: results[0], recent: results[1]);
    });

/// Pending first (in the server's order), then the recent rows not already
/// listed. De-duplicated by name: a pending count is in both answers.
List<WeeklyCountSummary> mergeWeeklyCountLists({
  required List<WeeklyCountSummary> pending,
  required List<WeeklyCountSummary> recent,
}) {
  final seen = <String>{};
  return [
    for (final row in pending)
      if (seen.add(row.name)) row,
    for (final row in recent)
      if (seen.add(row.name)) row,
  ];
}

/// One count with its lines.
final weeklyCountDetailProvider = FutureProvider.autoDispose
    .family<WeeklyCountDetail, String>((ref, name) {
      return ref.watch(weeklyCountServiceProvider).getDetail(name);
    });

/// After a submit / approve / reject: everything that shows a count's state.
void invalidateWeeklyCountState(WidgetRef ref, {String? name}) {
  ref.invalidate(weeklyCountStatusProvider);
  ref.invalidate(weeklyCountListProvider);
  ref.invalidate(pendingApprovalsProvider);
  if (name != null && name.isNotEmpty) {
    ref.invalidate(weeklyCountDetailProvider(name));
  }
}
