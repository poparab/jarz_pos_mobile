import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/task_models.dart';
import '../state/tasks_providers.dart';
import 'task_labels.dart';
import 'widgets/task_common_widgets.dart';
import 'widgets/task_create_sheet.dart';
import 'widgets/task_filter_sheet.dart';

/// Screens at least this wide show the four columns side by side; narrower
/// ones get one tab per column.
const double _wideBoardBreakpoint = 900;
const double _columnWidth = 300;

class TasksBoardScreen extends ConsumerStatefulWidget {
  /// `all | mine | created | review`, from the `view` query parameter.
  final String? initialView;

  const TasksBoardScreen({super.key, this.initialView});

  @override
  ConsumerState<TasksBoardScreen> createState() => _TasksBoardScreenState();
}

class _TasksBoardScreenState extends ConsumerState<TasksBoardScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(taskBoardProvider.notifier)
          .setView(TaskBoardView.normalize(widget.initialView));
    });
  }

  @override
  void didUpdateWidget(covariant TasksBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A push or the side menu can re-open the board on another view while
    // it is already showing; follow the link.
    if (oldWidget.initialView != widget.initialView) {
      ref
          .read(taskBoardProvider.notifier)
          .setView(TaskBoardView.normalize(widget.initialView));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final notifier = ref.read(taskBoardProvider.notifier);
      notifier.setFilter(
        ref.read(taskBoardProvider).filter.copyWith(search: value),
      );
    });
  }

  Future<void> _move(TaskCardSummary card, String target) async {
    if (card.status == target) return;
    String? reason;
    if (TaskStatus.needsReason(card.status, target)) {
      reason = await showTaskReasonDialog(
        context,
        title: taskReasonTitle(context, card.status),
      );
      if (reason == null || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(taskBoardProvider.notifier)
          .moveCard(card, target, reason: reason);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.tasksStatusChanged(taskStatusLabel(l10n, target)),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(context, e))));
    }
  }

  Future<void> _openFilters(TaskBoardContext boardContext) async {
    final current = ref.read(taskBoardProvider).filter;
    final next = await showTaskFilterSheet(
      context,
      filter: current,
      boardContext: boardContext,
    );
    if (next == null || !mounted) return;
    await ref.read(taskBoardProvider.notifier).setFilter(next);
  }

  Future<void> _create(TaskBoardContext boardContext) async {
    final created = await showTaskCreateSheet(context, boardContext);
    if (created == null || !mounted) return;
    context.push(AppRoutes.taskDetailFor(created.task.name));
  }

  void _openTask(TaskCardSummary card) {
    context.push(AppRoutes.taskDetailFor(card.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contextAsync = ref.watch(taskBoardContextProvider);
    final boardContext = contextAsync.valueOrNull;
    final filter = ref.watch(taskBoardProvider.select((s) => s.filter));
    final canAccess = boardContext?.canAccess ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasksBoardTitle),
        actions: [
          if (canAccess && boardContext!.canViewOverview)
            IconButton(
              tooltip: l10n.tasksOverviewTitle,
              icon: const Icon(Icons.insights),
              onPressed: () => context.push(AppRoutes.tasksOverview),
            ),
          if (canAccess)
            IconButton(
              tooltip: l10n.tasksFilters,
              onPressed: () => _openFilters(boardContext!),
              icon: Badge(
                isLabelVisible: filter.activeCount > 0,
                label: Text('${filter.activeCount}'),
                child: const Icon(Icons.filter_list),
              ),
            ),
          if (canAccess)
            IconButton(
              tooltip: l10n.commonRetry,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(taskBoardProvider.notifier).refresh(),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: canAccess && boardContext!.canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _create(boardContext),
              icon: const Icon(Icons.add_task),
              label: Text(l10n.tasksNewTask),
            )
          : null,
      body: contextAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: context.userErrorMessage(error),
          onRetry: () => ref.invalidate(taskBoardContextProvider),
        ),
        data: (ctx) {
          if (!ctx.canAccess) return _NoAccessView();
          return Column(
            children: [
              _ViewBar(
                view: filter.view,
                searchController: _searchController,
                onViewChanged: (v) =>
                    ref.read(taskBoardProvider.notifier).setView(v),
                onSearchChanged: _onSearchChanged,
              ),
              const Divider(height: 1),
              Expanded(
                child: _BoardBody(onMove: _move, onOpen: _openTask),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewBar extends StatelessWidget {
  final String view;
  final TextEditingController searchController;
  final ValueChanged<String> onViewChanged;
  final ValueChanged<String> onSearchChanged;

  const _ViewBar({
    required this.view,
    required this.searchController,
    required this.onViewChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final v in TaskBoardView.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: ChoiceChip(
                      label: Text(taskViewLabel(l10n, v)),
                      selected: view == v,
                      onSelected: (_) => onViewChanged(v),
                    ),
                  ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: l10n.tasksSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _MoveCallback =
    Future<void> Function(TaskCardSummary card, String target);

class _BoardBody extends ConsumerWidget {
  final _MoveCallback onMove;
  final ValueChanged<TaskCardSummary> onOpen;

  const _BoardBody({required this.onMove, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskBoardProvider);
    final board = state.board;
    if (board == null) {
      if (state.error != null) {
        return _ErrorView(
          message: taskErrorMessage(context, state.error!),
          onRetry: () => ref.read(taskBoardProvider.notifier).refresh(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _wideBoardBreakpoint) {
                return _WideBoard(
                  board: board,
                  moving: state.moving,
                  onMove: onMove,
                  onOpen: onOpen,
                );
              }
              return _TabbedBoard(
                board: board,
                moving: state.moving,
                onMove: onMove,
                onOpen: onOpen,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WideBoard extends ConsumerWidget {
  final TaskBoard board;
  final Set<String> moving;
  final _MoveCallback onMove;
  final ValueChanged<TaskCardSummary> onOpen;

  const _WideBoard({
    required this.board,
    required this.moving,
    required this.onMove,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Columns share the width when it is enough; otherwise they keep a
        // readable width and the row scrolls sideways.
        final fits = constraints.maxWidth >= _columnWidth * 4 + 40;
        final columns = [
          for (final status in TaskStatus.all)
            SizedBox(
              width: fits
                  ? (constraints.maxWidth - 40) / 4
                  : _columnWidth,
              child: _BoardColumn(
                status: status,
                cards: board.column(status),
                count: board.countFor(status),
                moving: moving,
                onMove: onMove,
                onOpen: onOpen,
                useLongPress: false,
              ),
            ),
        ];
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in columns)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: SizedBox(
                      height: constraints.maxHeight - 16,
                      child: c,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabbedBoard extends StatelessWidget {
  final TaskBoard board;
  final Set<String> moving;
  final _MoveCallback onMove;
  final ValueChanged<TaskCardSummary> onOpen;

  const _TabbedBoard({
    required this.board,
    required this.moving,
    required this.onMove,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: TaskStatus.all.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final status in TaskStatus.all)
                // Each tab is a drop target too: long-press a card, drag it
                // up onto another column's tab.
                DragTarget<TaskCardSummary>(
                  onWillAcceptWithDetails: (d) => d.data.status != status,
                  onAcceptWithDetails: (d) => onMove(d.data, status),
                  builder: (context, candidates, _) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: candidates.isNotEmpty
                        ? BoxDecoration(
                            color: taskStatusColor(
                              status,
                            ).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Tab(
                      text:
                          '${taskStatusLabel(l10n, status)} (${board.countFor(status)})',
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final status in TaskStatus.all)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: _BoardColumn(
                      status: status,
                      cards: board.column(status),
                      count: board.countFor(status),
                      moving: moving,
                      onMove: onMove,
                      onOpen: onOpen,
                      useLongPress: true,
                      showHeader: false,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardColumn extends ConsumerWidget {
  final String status;
  final List<TaskCardSummary> cards;
  final int count;
  final Set<String> moving;
  final _MoveCallback onMove;
  final ValueChanged<TaskCardSummary> onOpen;
  final bool useLongPress;
  final bool showHeader;

  const _BoardColumn({
    required this.status,
    required this.cards,
    required this.count,
    required this.moving,
    required this.onMove,
    required this.onOpen,
    required this.useLongPress,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final color = taskStatusColor(status);
    final targets = TaskStatus.all.where((s) => s != status).toList();

    Widget cardFor(TaskCardSummary card) {
      final tile = TaskCardTile(
        card: card,
        busy: moving.contains(card.name),
        onTap: () => onOpen(card),
        moveTargets: targets,
        onMove: (target) => onMove(card, target),
      );
      final feedback = Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: _columnWidth - 20, child: tile),
      );
      final dragging = Opacity(opacity: 0.3, child: tile);
      return useLongPress
          ? LongPressDraggable<TaskCardSummary>(
              data: card,
              feedback: feedback,
              childWhenDragging: dragging,
              child: tile,
            )
          : Draggable<TaskCardSummary>(
              data: card,
              feedback: feedback,
              childWhenDragging: dragging,
              child: tile,
            );
    }

    return DragTarget<TaskCardSummary>(
      onWillAcceptWithDetails: (d) => d.data.status != status,
      onAcceptWithDetails: (d) => onMove(d.data, status),
      builder: (context, candidates, _) {
        final highlighted = candidates.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: highlighted
                ? color.withValues(alpha: 0.12)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(
                    children: [
                      Icon(taskStatusIcon(status), size: 18, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          taskStatusLabel(l10n, status),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      Text('$count', style: TextStyle(color: color)),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(taskBoardProvider.notifier).refresh(),
                  child: cards.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  l10n.tasksEmptyColumn,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(6, 0, 6, 80),
                          itemCount: cards.length,
                          itemBuilder: (_, i) => cardFor(cards[i]),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoAccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            Text(context.l10n.tasksNoAccess, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
