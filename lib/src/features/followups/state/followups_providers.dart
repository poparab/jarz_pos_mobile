import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/followups_repository.dart';
import '../data/models/followup_models.dart';

/// Today's follow-up list. Hand-written notifier (no `@riverpod` codegen, like
/// the reports feature) so a handled touch can be dropped locally without a
/// reload. Refresh with [FollowupsTodayNotifier.refresh].
class FollowupsTodayNotifier extends AutoDisposeAsyncNotifier<FollowupsToday> {
  @override
  Future<FollowupsToday> build() =>
      ref.watch(followupsRepositoryProvider).fetchToday();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(followupsRepositoryProvider).fetchToday(),
    );
  }

  /// Logs a touch; on success the card leaves the list. Errors propagate to
  /// the caller so the sheet can show the server's reason.
  Future<FollowupLogResult> logTouch({
    required String name,
    required FollowupOutcome outcome,
    FollowupReach? reached,
    String? notes,
  }) async {
    final result = await ref.read(followupsRepositoryProvider).logTouch(
          name: name,
          outcome: outcome,
          reached: reached,
          notes: notes,
        );
    _remove(name);
    return result;
  }

  Future<void> skipTouch({required String name, String? reason}) async {
    await ref
        .read(followupsRepositoryProvider)
        .skipTouch(name: name, reason: reason);
    _remove(name);
  }

  /// Fetches (or re-fetches with [refresh]) the Claude message for [name] and
  /// stores it on the row so it is not fetched again.
  Future<FollowupDraftResult> draftMessage(
    String name, {
    bool refresh = false,
  }) async {
    final result = await ref
        .read(followupsRepositoryProvider)
        .draftMessage(name, refresh: refresh);
    final current = state.valueOrNull;
    if (current != null && result.messageText.trim().isNotEmpty) {
      state = AsyncData(current.updating(
        name,
        (r) => r.copyWithAi(
          messageText: result.messageText,
          aiMessage: result.isClaude ? result.messageText : null,
        ),
      ));
    }
    return result;
  }

  /// Stores a fetched brief on the row so reopening the sheet is instant.
  void rememberBrief(String name, String brief) {
    final current = state.valueOrNull;
    if (current == null || brief.trim().isEmpty) return;
    state = AsyncData(
      current.updating(name, (r) => r.copyWithAi(aiBrief: brief)),
    );
  }

  void _remove(String name) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.without(name));
  }
}

final followupsTodayProvider =
    AsyncNotifierProvider.autoDispose<FollowupsTodayNotifier, FollowupsToday>(
  FollowupsTodayNotifier.new,
);

/// Follow-up stats for the last 7 days, today included.
final followupStatsLast7DaysProvider =
    FutureProvider.autoDispose<FollowupStats>((ref) {
  final fmt = DateFormat('yyyy-MM-dd');
  final today = DateTime.now();
  return ref.watch(followupsRepositoryProvider).fetchStats(
        fromDate: fmt.format(today.subtract(const Duration(days: 6))),
        toDate: fmt.format(today),
      );
});
