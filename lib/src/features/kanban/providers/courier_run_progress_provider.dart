/// Run progress for every courier currently on the Kanban board.
///
/// Manual `Provider` — this app's Riverpod usage is hand-written, with no
/// `@riverpod` codegen anywhere in `lib/`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/courier_run_progress.dart';
import 'kanban_provider.dart';

/// Derived view over [kanbanProvider]: one O(N) pass over the board, shared by
/// every card that wants to render its courier's progress.
///
/// Watching the whole `invoices` map (rather than a per-courier family) is
/// deliberate. The map is rebuilt on every board mutation regardless, so a family
/// would recompute just as often while making each card pay for its own pass.
///
/// The count reflects **what is on the board**, which is the dispatcher's own
/// frame of reference — the cards in front of them. That is also its one
/// limitation: filtering the Delivered column out of view shrinks the
/// denominator. That is the correct behaviour for a board-scoped summary, and the
/// reason the badge is labelled against the board rather than presented as an
/// absolute run manifest.
final courierRunProgressProvider = Provider<CourierRunProgressIndex>((ref) {
  final invoices = ref.watch(kanbanProvider.select((state) => state.invoices));
  if (invoices.isEmpty) {
    return const CourierRunProgressIndex.empty();
  }
  return CourierRunProgressIndex.fromInvoices(
    invoices.values.expand((column) => column),
  );
});
