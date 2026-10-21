import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../../pos/state/pos_notifier.dart';
import '../../shift/state/shift_notifier.dart';
import '../data/stock_handover_models.dart';
import '../data/stock_transfer_service.dart';

/// The POS Profile the user has selected, or null.
final handoverSelectedProfileProvider = Provider<String?>((ref) {
  final name = ref.watch(
    posNotifierProvider.select(
      (s) => (s.selectedProfile?['name'] ?? '').toString(),
    ),
  );
  return name.isEmpty ? null : name;
});

/// The branch profile this user may declare for: the selected profile, when
/// THEY hold the open shift on it. Null otherwise.
///
/// This is only the client's guess for showing the drawer tile; the server
/// re-derives the branch side from `pos_profile` + the open shift on every
/// call, so a stale value here cannot act for a branch.
final handoverShiftProfileProvider = Provider<String?>((ref) {
  final profile = ref.watch(handoverSelectedProfileProvider);
  if (profile == null) return null;
  final shift = ref.watch(activeShiftProvider).valueOrNull;
  if (shift == null || !shift.isCurrentUser) return null;
  if (shift.posProfile != profile) return null;
  return profile;
});

/// Whether the Stock Transfer entry is offered at all: the transfer managers,
/// the production team (factory side), or whoever holds an open shift on a
/// branch. What the screen then shows is decided by `get_context`.
final canOpenStockTransferProvider = Provider<bool>((ref) {
  if (ref.watch(canAccessStockHandoverProvider)) return true;
  return ref.watch(handoverShiftProfileProvider) != null;
});

/// `get_context` for the selected profile.
final stockHandoverContextProvider =
    FutureProvider.autoDispose<HandoverContext>((ref) async {
  final profile = ref.watch(handoverSelectedProfileProvider);
  return ref
      .read(stockTransferServiceProvider)
      .getHandoverContext(posProfile: profile);
});

/// Which handovers to list: [myWarehouse] null = every side the user may act
/// for (and, for managers, every branch).
typedef HandoverListQuery = ({String? myWarehouse, String? posProfile});

final stockHandoverListsProvider = FutureProvider.autoDispose
    .family<StockHandoverLists, HandoverListQuery>((ref, query) async {
  return ref.read(stockTransferServiceProvider).listHandovers(
        myWarehouse: query.myWarehouse,
        posProfile: query.posProfile,
      );
});

/// `list_items` for one pair of sides. Search is done on the client: the list
/// is a few dozen jars, and filtering locally keeps typing instant.
/// [counterpartWarehouse] is null for "I sent out" (no destination yet) and
/// for an "I received" whose sender is unknown; [direction] tells the two
/// unions apart.
typedef HandoverItemsQuery = ({
  String myWarehouse,
  String? counterpartWarehouse,
  String direction,
});

final stockHandoverItemsProvider = FutureProvider.autoDispose
    .family<List<HandoverItemOption>, HandoverItemsQuery>((ref, query) async {
  return ref.read(stockTransferServiceProvider).listHandoverItems(
        myWarehouse: query.myWarehouse,
        counterpartWarehouse: query.counterpartWarehouse,
        direction: query.direction,
      );
});

/// The manager's Transit board for [posProfile] (may be null).
final transitBoardProvider = FutureProvider.autoDispose
    .family<TransitBoard, String?>((ref, posProfile) async {
  return ref
      .read(stockTransferServiceProvider)
      .getTransitBoard(posProfile: posProfile);
});

/// Called after a `stock_handover` push: refreshes any open handover list
/// and the Transit board. Invalidating an autoDispose provider nobody
/// watches costs nothing.
void refreshStockHandoversAfterPush(Ref ref) {
  ref.invalidate(stockHandoverListsProvider);
  ref.invalidate(transitBoardProvider);
}
