import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../data/manufacturing_service.dart';
import '../data/models/running_batch.dart';

/// Tab index of the Plan tab on the Production Board.
///
/// The board's home and the only tab that takes a quantity. Daily, Plan and
/// Batch were one thought split across three tabs — the target on one, the
/// ranking on the next, the queue on the third, and nothing carried between
/// them — so they are now one list: pick the flavours, see what is running low,
/// start the batches.
const int kProductionPlanTabIndex = 0;

/// Tab index of the Bases tab on the Production Board.
///
/// Bases (Fudge Cake, Sponge Cake, Savoiardi, …) are never sold, so the
/// sales-driven jar rows compute zero for them and hide their action panel.
/// They get their own tab, ordered right before Running because making a base
/// is the step immediately upstream of a run.
const int kProductionBasesTabIndex = 1;

/// Tab index of the Running tab on the Production Board.
///
/// Named rather than inlined because three files agree on it: the host builds
/// the tabs, and the Plan tab and the Bases card both ask to be moved here
/// after a successful start.
///
/// Order is Plan, Bases, Running. It was Daily, Plan, Batch, Bases, Running
/// until the first three merged (4 → 2); `kProductionBatchTabIndex` is gone
/// with them, because the queue is no longer somewhere else to be sent to.
const int kProductionRunningTabIndex = 2;

/// How many tabs the Production Board has. Kept next to the indices above so a
/// new tab cannot be added without the `TabController` length and the deep-link
/// clamp moving with it.
const int kProductionTabCount = 3;

/// The tab a `/manufacturing?tab=N` link should open.
///
/// Deep links outlive tab layouts. The board carried five tabs and now carries
/// three, so a link somebody saved — or an old build's notification — can name
/// an index that no longer exists. Clamped into range rather than thrown or
/// silently ignored: landing one tab off is recoverable, a crashed board is
/// not. A negative index means a malformed query string, and the board's home
/// is the honest answer to that.
int productionTabForDeepLink(int requested) {
  if (requested < 0) return kProductionPlanTabIndex;
  if (requested >= kProductionTabCount) return kProductionTabCount - 1;
  return requested;
}

/// A one-shot request to move the Production Board to another tab.
///
/// Set by the Plan tab and the Bases card after starting a batch, and cleared
/// by the host as soon as it has animated. A `StateProvider<int?>` rather than
/// a callback so a tab does not need a handle on the host's `TabController`.
final productionTabRequestProvider = StateProvider<int?>((ref) => null);

/// Batches that are started but not finished.
///
/// Loads once and is refreshed explicitly, exactly like
/// `productionSuggestionsProvider` — the list is small and a poll would fight
/// the operator's own actions.
final runningBatchesProvider =
    AsyncNotifierProvider<RunningBatchesNotifier, List<RunningBatch>>(
  RunningBatchesNotifier.new,
);

class RunningBatchesNotifier extends AsyncNotifier<List<RunningBatch>> {
  ManufacturingService get _service => ref.read(manufacturingServiceProvider);

  @override
  Future<List<RunningBatch>> build() => _service.listRunningWorkOrders();

  /// Pull-to-refresh, and the single way the list is brought back in sync after
  /// a write.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.listRunningWorkOrders());
  }

  /// Files the Manufacture entry for [workOrder].
  ///
  /// Errors are deliberately allowed to propagate: the caller is a sheet that
  /// must stay open and say why, and swallowing the failure here would leave the
  /// operator believing stock moved when it did not. The list is only refreshed
  /// once the server has confirmed.
  Future<FinishBatchResult> finish({
    required String workOrder,
    required double actualQty,
    double scrapQty = 0,
    String? scheduledAt,
    String? notes,
    bool returnLeftover = false,
  }) async {
    final result = await _service.finishProductionBatch(
      workOrder: workOrder,
      actualQty: actualQty,
      scrapQty: scrapQty,
      scheduledAt: scheduledAt,
      notes: notes,
      returnLeftover: returnLeftover,
    );

    // The cost of a finished batch is a different number from the cost of a
    // running one, so the cached panel must not survive the finish.
    ref.invalidate(batchCostProvider(workOrder));
    await refresh();
    return result;
  }

  /// Returns un-consumed WIP material to its source warehouse.
  ///
  /// Manager-only server-side; see [canManageProductionWipProvider] for the
  /// matching client gate.
  Future<void> returnWip(String workOrder) async {
    await _service.returnWipToStore(workOrder);
    ref.invalidate(batchCostProvider(workOrder));
    await refresh();
  }

  /// Aborts [workOrder]: WIP goes back to the store and the Work Order stops.
  ///
  /// Errors propagate for the same reason [finish] lets them: the caller has to
  /// be able to show the server's refusal, which is the message that tells the
  /// operator to finish the batch instead.
  Future<void> cancel({
    required String workOrder,
    required String reason,
  }) async {
    await _service.cancelProductionBatch(
      workOrder: workOrder,
      reason: reason,
    );
    ref.invalidate(batchCostProvider(workOrder));
    await refresh();
  }
}

/// One batch's material cost, cached briefly while its card is on screen.
///
/// Kept alive for a minute so expanding and collapsing the panel — or scrolling
/// the card out of view and back — does not re-cost the batch server-side on
/// every tap.
final batchCostProvider =
    FutureProvider.autoDispose.family<BatchCost, String>((ref, workOrder) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), link.close);
  ref.onDispose(timer.cancel);

  return ref.read(manufacturingServiceProvider).getBatchCost(workOrder);
});
