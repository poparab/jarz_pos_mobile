import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../data/manufacturing_service.dart';
import '../data/models/running_batch.dart';

/// Tab index of the Running tab on the Production Board.
///
/// Named rather than inlined because two files agree on it: the host builds the
/// tabs and the Batch tab asks to be moved here after a successful start.
///
/// Order is Daily, Plan, Batch, Running — Daily was added at the front because
/// it is what the floor opens the board for first thing in the morning, which
/// pushed this index from 2 to 3.
const int kProductionRunningTabIndex = 3;

/// A one-shot request to move the Production Board to another tab.
///
/// Set by the Batch tab after starting a batch and cleared by the host as soon
/// as it has animated. A `StateProvider<int?>` rather than a callback so the tab
/// does not need a handle on the host's `TabController`.
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
  }) async {
    final result = await _service.finishProductionBatch(
      workOrder: workOrder,
      actualQty: actualQty,
      scrapQty: scrapQty,
      scheduledAt: scheduledAt,
      notes: notes,
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
