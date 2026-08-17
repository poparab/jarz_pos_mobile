import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/b2b_models.dart';
import '../../../labels/state/labels_notifier.dart';
import '../../state/b2b_pipeline_notifier.dart';
import '../widgets/b2b_pipeline_column.dart';

/// The B2B sales Pipeline Kanban: columns are stages, cards are draggable to
/// advance a Lead/Opportunity to a new stage. This is a SEPARATE board from the
/// dispatch (fulfillment) Kanban.
class B2bPipelineScreen extends ConsumerStatefulWidget {
  const B2bPipelineScreen({super.key});

  @override
  ConsumerState<B2bPipelineScreen> createState() => _B2bPipelineScreenState();
}

class _B2bPipelineScreenState extends ConsumerState<B2bPipelineScreen> {
  @override
  void initState() {
    super.initState();
    // Revalidate on every entry.
    //
    // b2bPipelineProvider is a keep-alive AsyncNotifier that nothing
    // invalidates, so its build() ran exactly ONCE per app process: whatever
    // that first attempt produced — stale columns, or an error from a cold
    // start before the session was attached — was then frozen for the rest of
    // the session, and the header Refresh button was the only way out. That is
    // the "doesn't load automatically" report.
    //
    // Its sibling b2bTodayProvider is autoDispose and re-fetches on every
    // visit; this board was simply the odd one out. Refreshing here gives the
    // same behaviour without changing the provider's lifetime, which several
    // other screens call refresh() on. The refresh keeps the current columns
    // on screen, so this is invisible when nothing changed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(b2bPipelineProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Printed-label stock. Surfaced here as well as in the drawer because
          // the rep who owns these accounts lives on this board, and a label
          // that needs printing is a days-long lead time, not a same-day fix.
          const _LabelAlertAction(),
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
          onOpenLead: _openLead,
        ),
      ),
    );
  }

  /// Opens an account and revalidates on the way back, so a stage change made
  /// in there is on the board immediately rather than after a manual refresh.
  Future<void> _openAccount(BuildContext context, B2bCard card) async {
    await context.push(
      AppRoutes.b2bAccount,
      extra: <String, dynamic>{'doctype': card.doctype, 'name': card.name},
    );
    if (mounted) ref.read(b2bPipelineProvider.notifier).refresh();
  }

  /// Opens a Lead card's full catalog page (profile, branches, addresses,
  /// journey diary) straight from the board, then revalidates: a stage change
  /// or a logged visit made there belongs on the board without a manual
  /// refresh. Opportunity cards have no lead page, so this is a no-op for them.
  Future<void> _openLead(B2bCard card) async {
    if (card.doctype != 'Lead') return;
    await context.push('/leads/${Uri.encodeComponent(card.name)}');
    if (mounted) ref.read(b2bPipelineProvider.notifier).refresh();
  }

  /// The forward stages that warrant a follow-up reminder, with a smart default
  /// number of days from today for each.
  static const Map<String, int> _forwardStageDefaults = {
    'Qualify': 2,
    'Sample': 3,
    'Approved': 5,
    'Trial': 7,
    'Check-up': 7,
    'Active': 14,
  };

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    B2bCard card,
    String stage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    String? reason;
    String? followUpDate;
    if (stage == 'Lost/On-hold') {
      reason = await _promptReason(context);
      if (reason == null) return; // cancelled
    } else if (_forwardStageDefaults.containsKey(stage)) {
      if (!context.mounted) return;
      final result = await _promptFollowUpDate(context, stage);
      if (result.cancelled) return; // aborted
      followUpDate = result.date; // may be null when the rep skips
    }
    try {
      await ref.read(b2bPipelineProvider.notifier).advanceStage(
            card,
            stage,
            reason: reason,
            followUpDate: followUpDate,
          );
      messenger.showSnackBar(
        SnackBar(content: Text('Moved "${card.title}" to $stage')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to advance stage: $e')),
      );
    }
  }

  /// Formats a [DateTime] as the backend-expected ISO `yyyy-MM-dd`.
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Prompts for an optional follow-up reminder date, pre-filled with a smart
  /// default for the target [stage]. Returns `(cancelled, date)`:
  ///  - cancelled == true  → abort the whole advance,
  ///  - cancelled == false, date == null → proceed WITHOUT a reminder (skip),
  ///  - cancelled == false, date != null → proceed WITH that reminder.
  Future<({bool cancelled, String? date})> _promptFollowUpDate(
    BuildContext context,
    String stage,
  ) async {
    final now = DateTime.now();
    final defaultDays = _forwardStageDefaults[stage] ?? 3;
    var selected = DateTime(now.year, now.month, now.day)
        .add(Duration(days: defaultDays));

    final result = await showDialog<({bool cancelled, String? date})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Follow-up reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('When should you follow up after moving to "$stage"?'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(_isoDate(selected)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selected,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: DateTime(now.year + 1, now.month, now.day),
                  );
                  if (picked != null) setState(() => selected = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, (cancelled: true, date: null)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, (cancelled: false, date: null)),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                (cancelled: false, date: _isoDate(selected)),
              ),
              child: const Text('Set reminder'),
            ),
          ],
        ),
      ),
    );
    return result ?? (cancelled: true, date: null);
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
  final void Function(B2bCard card) onOpenLead;

  const _Board({
    required this.pipeline,
    required this.onAdvance,
    required this.onCardTap,
    required this.onOpenLead,
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
              onOpenLead: onOpenLead,
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

/// Header shortcut to the customer-label board, badged with how many labels
/// need printing. Renders as a plain icon while the count is loading or if the
/// call fails — a wrong badge is worse than no badge.
class _LabelAlertAction extends ConsumerWidget {
  const _LabelAlertAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(labelAlertCountProvider).maybeWhen(
          data: (summary) => summary.needsAttention,
          orElse: () => 0,
        );

    return IconButton(
      tooltip: count == 0
          ? 'Customer labels'
          : '$count label${count == 1 ? '' : 's'} need printing',
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.label_important_outline),
      ),
      onPressed: () => context.push(AppRoutes.labels),
    );
  }
}
