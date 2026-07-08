import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/b2b_models.dart';
import '../../state/b2b_pipeline_notifier.dart';
import '../widgets/b2b_pipeline_column.dart';

/// The B2B sales Pipeline Kanban: columns are stages, cards are draggable to
/// advance a Lead/Opportunity to a new stage. This is a SEPARATE board from the
/// dispatch (fulfillment) Kanban.
class B2bPipelineScreen extends ConsumerWidget {
  const B2bPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(b2bPipelineProvider);
    final notifier = ref.read(b2bPipelineProvider.notifier);
    final rolesAsync = ref.watch(userRolesFutureProvider);
    final isManager = rolesAsync.maybeWhen(
      data: (r) => r.canAccessManagerDashboard,
      orElse: () => false,
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('B2B Pipeline'),
        actions: [
          IconButton(
            tooltip: 'My follow-ups',
            icon: const Icon(Icons.today),
            onPressed: () => context.push(AppRoutes.b2bToday),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
          // Managers can switch back to the B2C POS/Kanban flows.
          if (isManager)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch mode',
              onSelected: (value) {
                if (value == 'pos') context.go(AppRoutes.pos);
                if (value == 'kanban') context.go(AppRoutes.kanban);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'pos', child: Text('Go to POS (B2C)')),
                PopupMenuItem(
                  value: 'kanban',
                  child: Text('Go to Dispatch Kanban'),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.leadForm),
        icon: const Icon(Icons.add),
        label: const Text('New lead'),
      ),
      body: pipelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error,
          onRetry: () => notifier.refresh(),
        ),
        data: (pipeline) => _Board(
          pipeline: pipeline,
          onAdvance: (card, stage) =>
              _advance(context, ref, card, stage),
          onCardTap: (card) => _openAccount(context, card),
        ),
      ),
    );
  }

  void _openAccount(BuildContext context, B2bCard card) {
    context.push(
      AppRoutes.b2bAccount,
      extra: <String, dynamic>{'doctype': card.doctype, 'name': card.name},
    );
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    B2bCard card,
    String stage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    String? reason;
    if (stage == 'Lost/On-hold') {
      reason = await _promptReason(context);
      if (reason == null) return; // cancelled
    }
    try {
      await ref
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, stage, reason: reason);
      messenger.showSnackBar(
        SnackBar(content: Text('Moved "${card.title}" to $stage')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to advance stage: $e')),
      );
    }
  }

  Future<String?> _promptReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Why is this lost / on hold?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final B2bPipeline pipeline;
  final void Function(B2bCard card, String stage) onAdvance;
  final void Function(B2bCard card) onCardTap;

  const _Board({
    required this.pipeline,
    required this.onAdvance,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final stage in pipeline.stages)
            B2bPipelineColumn(
              stage: stage,
              cards: _sortByScoreDesc(pipeline.columns[stage] ?? const []),
              stages: pipeline.stages,
              onAccept: (card) => onAdvance(card, stage),
              onMove: onAdvance,
              onCardTap: onCardTap,
            ),
        ],
      ),
    );
  }
}

/// Sorts a column's cards by lead score descending, keeping cards with no score
/// LAST. The sort is stable: cards that tie (or share the "no score" bucket)
/// keep their original server order. Done client-side so the board is robust
/// even before the backend score sort ships.
List<B2bCard> _sortByScoreDesc(List<B2bCard> cards) {
  final entries = cards.asMap().entries.toList();
  entries.sort((a, b) {
    final sa = a.value.leadScore;
    final sb = b.value.leadScore;
    if (sa == null && sb == null) return a.key.compareTo(b.key);
    if (sa == null) return 1; // a has no score → after b
    if (sb == null) return -1; // b has no score → after a
    final byScore = sb.compareTo(sa); // descending
    return byScore != 0 ? byScore : a.key.compareTo(b.key);
  });
  return [for (final e in entries) e.value];
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Could not load the pipeline.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
