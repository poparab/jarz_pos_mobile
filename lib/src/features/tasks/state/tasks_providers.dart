import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../approvals/state/pending_approvals_provider.dart';
import '../data/tasks_repository.dart';
import '../models/task_models.dart';

/// Who the caller is on the board, and the pickers' option lists.
///
/// `get_board_context` never throws for a non-board user; it answers
/// `can_access: false`, which the screens render as a friendly refusal.
final taskBoardContextProvider = FutureProvider.autoDispose<TaskBoardContext>((
  ref,
) async {
  return ref.watch(tasksRepositoryProvider).fetchContext();
});

// ── Board ───────────────────────────────────────────────────────────────

class TaskBoardState {
  final TaskBoardFilter filter;
  final TaskBoard? board;
  final bool isLoading;
  final Object? error;

  /// Card names with a `set_status` in flight, so the card can dim.
  final Set<String> moving;

  const TaskBoardState({
    this.filter = const TaskBoardFilter(),
    this.board,
    this.isLoading = false,
    this.error,
    this.moving = const {},
  });

  TaskBoardState copyWith({
    TaskBoardFilter? filter,
    TaskBoard? board,
    bool? isLoading,
    Object? error,
    bool clearError = false,
    Set<String>? moving,
  }) => TaskBoardState(
    filter: filter ?? this.filter,
    board: board ?? this.board,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    moving: moving ?? this.moving,
  );
}

final taskBoardProvider =
    StateNotifierProvider.autoDispose<TaskBoardNotifier, TaskBoardState>((
      ref,
    ) {
      return TaskBoardNotifier(
        ref.watch(tasksRepositoryProvider),
        onChanged: () => ref.invalidate(pendingApprovalsProvider),
      );
    });

class TaskBoardNotifier extends StateNotifier<TaskBoardState> {
  final TasksRepository _repository;
  final void Function() _onChanged;
  int _generation = 0;

  TaskBoardNotifier(this._repository, {required void Function() onChanged})
    : _onChanged = onChanged,
      super(const TaskBoardState());

  /// Reloads with the current filter. A response to an older filter that
  /// lands after a newer one is dropped rather than painted over it.
  Future<void> refresh() async {
    final generation = ++_generation;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final board = await _repository.fetchBoard(state.filter);
      if (!mounted || generation != _generation) return;
      state = state.copyWith(board: board, isLoading: false);
    } catch (e) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> setFilter(TaskBoardFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> setView(String view) =>
      setFilter(state.filter.copyWith(view: TaskBoardView.normalize(view)));

  /// Moves a card, optimistically. On refusal the board is reloaded from the
  /// server (so the card snaps back) and the error is rethrown for the
  /// screen to show the server's own sentence.
  Future<void> moveCard(
    TaskCardSummary card,
    String status, {
    String? reason,
  }) async {
    if (card.status == status) return;
    final before = state.board;
    state = state.copyWith(
      board: before?.moveCard(card.name, status),
      moving: {...state.moving, card.name},
    );
    try {
      await _repository.setStatus(card.name, status, reason: reason);
      _onChanged();
    } catch (_) {
      if (mounted && before != null) state = state.copyWith(board: before);
      rethrow;
    } finally {
      if (mounted) {
        state = state.copyWith(
          moving: {...state.moving}..remove(card.name),
        );
        await refresh();
      }
    }
  }
}

// ── Task detail ─────────────────────────────────────────────────────────

class TaskDetailState {
  final TaskBundle? bundle;
  final bool isLoading;
  final bool isSubmitting;
  final Object? error;

  const TaskDetailState({
    this.bundle,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  TaskDetailState copyWith({
    TaskBundle? bundle,
    bool? isLoading,
    bool? isSubmitting,
    Object? error,
    bool clearError = false,
  }) => TaskDetailState(
    bundle: bundle ?? this.bundle,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: clearError ? null : (error ?? this.error),
  );
}

final taskDetailProvider = StateNotifierProvider.autoDispose
    .family<TaskDetailNotifier, TaskDetailState, String>((ref, name) {
      return TaskDetailNotifier(
        ref.watch(tasksRepositoryProvider),
        name,
        onChanged: () {
          ref.invalidate(pendingApprovalsProvider);
          // An open board behind the detail screen shows the change on return.
          if (ref.exists(taskBoardProvider)) {
            ref.read(taskBoardProvider.notifier).refresh();
          }
        },
      )..load();
    });

/// One task, and every action on it.
///
/// Every mutation answers with the full `get_task` shape, which replaces the
/// state wholesale — so permissions, history and counts are always the
/// server's, never a client guess. Mutations rethrow: the screen hands the
/// original exception to the error presenter, which needs the
/// `DioException` itself to surface the server's sentence.
class TaskDetailNotifier extends StateNotifier<TaskDetailState> {
  final TasksRepository _repository;
  final String name;
  final void Function() _onChanged;

  TaskDetailNotifier(
    this._repository,
    this.name, {
    required void Function() onChanged,
  }) : _onChanged = onChanged,
       super(const TaskDetailState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bundle = await _repository.fetchTask(name);
      if (!mounted) return;
      state = state.copyWith(bundle: bundle, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<TaskBundle> _run(Future<TaskBundle> Function() call) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final bundle = await call();
      if (mounted) state = state.copyWith(bundle: bundle);
      _onChanged();
      return bundle;
    } finally {
      if (mounted) state = state.copyWith(isSubmitting: false);
    }
  }

  Future<TaskBundle> setStatus(String status, {String? reason}) =>
      _run(() => _repository.setStatus(name, status, reason: reason));

  Future<TaskBundle> update({
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? branch,
    String? assignedTo,
    bool clearDueDate = false,
    bool clearBranch = false,
  }) => _run(
    () => _repository.updateTask(
      name,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      branch: branch,
      assignedTo: assignedTo,
      clearDueDate: clearDueDate,
      clearBranch: clearBranch,
    ),
  );

  Future<TaskBundle> setArchived(bool archived) =>
      _run(() => _repository.archiveTask(name, archived: archived));

  Future<TaskBundle> addSubtask({
    required String title,
    String? assignedTo,
    DateTime? dueDate,
  }) => _run(
    () => _repository.addSubtask(
      name,
      title: title,
      assignedTo: assignedTo,
      dueDate: dueDate,
    ),
  );

  Future<TaskBundle> updateSubtask(
    String subtaskId, {
    String? title,
    String? assignedTo,
    DateTime? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) => _run(
    () => _repository.updateSubtask(
      name,
      subtaskId,
      title: title,
      assignedTo: assignedTo,
      dueDate: dueDate,
      clearAssignee: clearAssignee,
      clearDueDate: clearDueDate,
    ),
  );

  Future<TaskBundle> deleteSubtask(String subtaskId) =>
      _run(() => _repository.deleteSubtask(name, subtaskId));

  Future<TaskBundle> setSubtaskDone(String subtaskId, bool done) =>
      _run(() => _repository.setSubtaskDone(name, subtaskId, done));

  Future<TaskBundle> uploadAttachment({
    required String filename,
    required Uint8List bytes,
  }) => _run(
    () => _repository.uploadAttachment(name, filename: filename, bytes: bytes),
  );

  Future<TaskBundle> removeAttachment(String file) =>
      _run(() => _repository.removeAttachment(name, file));

  /// Adds a Log or Comment, then uploads each file onto that entry.
  ///
  /// The entry is the `entry` name `add_entry` returns; only if an older
  /// server omits it is the new entry found as the one entry of [kind] by
  /// [me] that was not there before. If an upload fails the entry itself
  /// still stands; the error is rethrown so the screen can say the files did
  /// not all make it.
  Future<TaskBundle> addEntry({
    required String kind,
    required String content,
    List<String> mentions = const [],
    List<({String filename, Uint8List bytes})> files = const [],
    String? me,
  }) {
    return _run(() async {
      final before = {
        for (final e in state.bundle?.entries ?? const <TaskEntry>[]) e.name,
      };
      final added = await _repository.addEntry(
        name,
        kind: kind,
        content: content,
        mentions: mentions,
      );
      var bundle = added.bundle;
      if (files.isEmpty) return bundle;
      if (mounted) state = state.copyWith(bundle: bundle);
      final entryName =
          added.entry ??
          findNewEntryName(
            before: before,
            after: bundle.entries,
            kind: kind,
            author: me,
          );
      for (final file in files) {
        bundle = await _repository.uploadAttachment(
          name,
          filename: file.filename,
          bytes: file.bytes,
          entry: entryName,
        );
        if (mounted) state = state.copyWith(bundle: bundle);
      }
      return bundle;
    });
  }
}

/// The entry `add_entry` just created: new since [before], of [kind], and by
/// [author] when known. The last match wins (entries come oldest first).
String? findNewEntryName({
  required Set<String> before,
  required List<TaskEntry> after,
  required String kind,
  String? author,
}) {
  String? found;
  for (final entry in after) {
    if (before.contains(entry.name) || entry.kind != kind) continue;
    if (author != null && entry.author.isNotEmpty && entry.author != author) {
      continue;
    }
    found = entry.name;
  }
  return found;
}

// ── Create ──────────────────────────────────────────────────────────────

class TaskCreateNotifier extends StateNotifier<bool> {
  final TasksRepository _repository;
  final void Function() _onChanged;

  TaskCreateNotifier(this._repository, this._onChanged) : super(false);

  Future<TaskBundle> create({
    required String title,
    required String assignedTo,
    String? description,
    String priority = TaskPriority.normal,
    DateTime? dueDate,
    String? branch,
    List<NewSubtaskDraft> subtasks = const [],
  }) async {
    state = true;
    try {
      final bundle = await _repository.createTask(
        title: title,
        assignedTo: assignedTo,
        description: description,
        priority: priority,
        dueDate: dueDate,
        branch: branch,
        subtasks: subtasks,
      );
      _onChanged();
      return bundle;
    } finally {
      if (mounted) state = false;
    }
  }
}

/// True while a create is in flight.
final taskCreateProvider =
    StateNotifierProvider.autoDispose<TaskCreateNotifier, bool>((ref) {
      return TaskCreateNotifier(ref.watch(tasksRepositoryProvider), () {
        ref.invalidate(pendingApprovalsProvider);
        if (ref.exists(taskBoardProvider)) {
          ref.read(taskBoardProvider.notifier).refresh();
        }
      });
    });

// ── Overview & attachments ──────────────────────────────────────────────

final taskOverviewProvider = FutureProvider.autoDispose
    .family<TaskOverview, int>((ref, days) async {
      return ref.watch(tasksRepositoryProvider).fetchOverview(days: days);
    });

/// An attachment's bytes, fetched once per file while something shows it.
final taskAttachmentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>((ref, file) async {
      final bytes = await ref
          .watch(tasksRepositoryProvider)
          .downloadAttachment(file);
      // Thumbnails scroll in and out of view; keep the bytes a few minutes
      // after the last viewer goes, rather than re-downloading on every
      // scroll or holding every image for the rest of the session.
      final link = ref.keepAlive();
      Timer? release;
      ref.onCancel(() => release = Timer(const Duration(minutes: 5), link.close));
      ref.onResume(() => release?.cancel());
      ref.onDispose(() => release?.cancel());
      return bytes;
    });

/// Called by the push bridge on a `task_notification`: refresh whatever task
/// state is already alive, and nothing that is not (a device whose user never
/// opened the board must not start fetching it because of a push).
void refreshTasksAfterPush(Ref ref, {String? taskId}) {
  ref.invalidate(pendingApprovalsProvider);
  if (ref.exists(taskBoardProvider)) {
    ref.read(taskBoardProvider.notifier).refresh();
  }
  final id = taskId?.trim() ?? '';
  if (id.isNotEmpty && ref.exists(taskDetailProvider(id))) {
    ref.read(taskDetailProvider(id).notifier).load();
  }
}
