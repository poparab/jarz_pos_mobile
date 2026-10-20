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

/// Recent counts (pending first is the screen's job), for the approvals list.
final weeklyCountListProvider =
    FutureProvider.autoDispose<List<WeeklyCountSummary>>((ref) {
      return ref.watch(weeklyCountServiceProvider).list(limit: 50);
    });

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
