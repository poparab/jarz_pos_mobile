import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/b2b_repository.dart';
import '../data/models/b2b_models.dart';

/// Loads the B2B sales pipeline and supports advancing cards between stages
/// with an optimistic update + server confirmation (rollback on failure).
final b2bPipelineProvider =
    AsyncNotifierProvider<B2bPipelineNotifier, B2bPipeline>(
      B2bPipelineNotifier.new,
    );

class B2bPipelineNotifier extends AsyncNotifier<B2bPipeline> {
  B2bRepository get _repo => ref.read(b2bRepositoryProvider);

  @override
  Future<B2bPipeline> build() async {
    return _repo.getPipeline();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getPipeline);
  }

  /// Optimistically moves [card] to [stage], then confirms with the server.
  /// Rolls back to the previous pipeline if the server call fails.
  Future<void> advanceStage(
    B2bCard card,
    String stage, {
    String? reason,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (card.stage == stage) return;

    final optimistic = _moveCard(current, card, stage);
    state = AsyncValue.data(optimistic);

    try {
      await _repo.advanceStage(
        doctype: card.doctype,
        name: card.name,
        stage: stage,
        reason: reason,
      );
    } catch (error, stack) {
      // Roll back to the pre-move pipeline and surface the error.
      state = AsyncValue.error(error, stack);
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  /// Pure helper: returns a new pipeline with [card] removed from its old stage
  /// and inserted (with updated stage) at the front of [newStage].
  static B2bPipeline _moveCard(
    B2bPipeline pipeline,
    B2bCard card,
    String newStage,
  ) {
    final columns = <String, List<B2bCard>>{};
    pipeline.columns.forEach((stage, cards) {
      columns[stage] = cards
          .where((c) => !(c.doctype == card.doctype && c.name == card.name))
          .toList();
    });
    final moved = card.copyWith(stage: newStage);
    final target = List<B2bCard>.from(columns[newStage] ?? const []);
    target.insert(0, moved);
    columns[newStage] = target;
    return pipeline.copyWith(columns: columns);
  }
}
