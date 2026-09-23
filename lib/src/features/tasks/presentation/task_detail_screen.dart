import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../models/task_models.dart';
import '../state/tasks_providers.dart';
import 'task_labels.dart';
import 'widgets/task_attachments.dart';
import 'widgets/task_common_widgets.dart';
import 'widgets/task_create_sheet.dart';
import 'widgets/task_entry_composer.dart';
import 'widgets/task_subtask_sheet.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskName;

  const TaskDetailScreen({super.key, required this.taskName});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  /// The activity tab the user picked; null until they pick one.
  String? _pickedActivity;

  /// Logs by default; Comments when the user may comment but not log (a Done
  /// task takes comments only), so the one thing they can add is in front.
  String _activityFor(TaskPermissions perms) =>
      _pickedActivity ??
      (!perms.canLog && perms.canComment
          ? TaskEntryKind.comment
          : TaskEntryKind.log);

  TaskDetailNotifier get _notifier =>
      ref.read(taskDetailProvider(widget.taskName).notifier);

  /// Runs a mutation and reports a refusal with the server's own reason.
  Future<bool> _guard(
    Future<void> Function() action, {
    String? success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
      return true;
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(taskErrorMessage(context, e))),
        );
      }
      return false;
    }
  }

  Future<void> _transition(TaskBundle bundle, String target) async {
    final l10n = context.l10n;
    String? reason;
    if (bundle.permissions.needsReason(target)) {
      reason = await showTaskReasonDialog(
        context,
        title: taskReasonTitle(context, bundle.task.status),
      );
      if (reason == null || !mounted) return;
    }
    await _guard(
      () => _notifier.setStatus(target, reason: reason),
      success: l10n.tasksStatusChanged(taskStatusLabel(l10n, target)),
    );
  }

  Future<void> _edit(TaskBundle bundle, TaskBoardContext boardContext) async {
    await showTaskEditSheet(
      context,
      boardContext: boardContext,
      bundle: bundle,
    );
  }

  Future<void> _toggleArchive(TaskBundle bundle) async {
    final l10n = context.l10n;
    final archive = !bundle.task.summary.archived;
    if (archive) {
      final ok = await confirmTaskAction(
        context,
        message: l10n.tasksArchiveConfirm,
        confirmLabel: l10n.tasksActionArchive,
      );
      if (!ok || !mounted) return;
    }
    await _guard(() => _notifier.setArchived(archive));
  }

  Future<void> _addAttachment() async {
    final files = await pickTaskFiles(context);
    if (files.isEmpty || !mounted) return;
    final l10n = context.l10n;
    for (final file in files) {
      final ok = await _guard(
        () => _notifier.uploadAttachment(
          filename: file.filename,
          bytes: file.bytes,
        ),
      );
      if (!ok || !mounted) return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tasksUploaded)));
  }

  Future<void> _removeAttachment(TaskAttachment attachment) async {
    final l10n = context.l10n;
    final ok = await confirmTaskAction(
      context,
      message: l10n.tasksRemoveAttachmentConfirm(attachment.fileName),
      confirmLabel: l10n.tasksRemoveAttachment,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _guard(() => _notifier.removeAttachment(attachment.name));
  }

  Future<void> _deleteSubtask(TaskSubtask subtask) async {
    final l10n = context.l10n;
    final ok = await confirmTaskAction(
      context,
      message: l10n.tasksDeleteSubtaskConfirm(subtask.title),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _guard(() => _notifier.deleteSubtask(subtask.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(taskDetailProvider(widget.taskName));
    final boardContext = ref.watch(taskBoardContextProvider).valueOrNull;
    final bundle = state.bundle;

    return Scaffold(
      appBar: AppBar(
        // Opened from a push the stack can be empty; give a way to the board.
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => context.go(AppRoutes.tasks),
              ),
        title: Text(bundle?.task.name ?? widget.taskName),
        actions: [
          if (bundle != null &&
              bundle.permissions.canEdit &&
              boardContext != null &&
              !bundle.task.summary.archived)
            IconButton(
              tooltip: l10n.tasksActionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: state.isSubmitting
                  ? null
                  : () => _edit(bundle, boardContext),
            ),
          if (bundle != null && bundle.permissions.canArchive)
            IconButton(
              tooltip: bundle.task.summary.archived
                  ? l10n.tasksActionUnarchive
                  : l10n.tasksActionArchive,
              icon: Icon(
                bundle.task.summary.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              onPressed: state.isSubmitting
                  ? null
                  : () => _toggleArchive(bundle),
            ),
        ],
      ),
      body: _body(context, state, boardContext),
    );
  }

  Widget _body(
    BuildContext context,
    TaskDetailState state,
    TaskBoardContext? boardContext,
  ) {
    final bundle = state.bundle;
    if (bundle == null) {
      if (state.error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 8),
                Text(
                  taskErrorMessage(context, state.error!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _notifier.load,
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (state.isSubmitting || state.isLoading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _notifier.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                TaskDetailHeader(bundle: bundle),
                const SizedBox(height: 12),
                TaskTransitionButtons(
                  bundle: bundle,
                  enabled: !state.isSubmitting,
                  onTransition: (target) => _transition(bundle, target),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: context.l10n.tasksDescription,
                  child: Text(
                    bundle.task.description.trim().isEmpty
                        ? context.l10n.tasksNoDescription
                        : bundle.task.description,
                  ),
                ),
                _subtasksSection(context, bundle, boardContext),
                _attachmentsSection(context, bundle),
                _activitySection(context, bundle, boardContext),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _subtasksSection(
    BuildContext context,
    TaskBundle bundle,
    TaskBoardContext? boardContext,
  ) {
    final l10n = context.l10n;
    final done = bundle.subtasks.where((s) => s.isDone).length;
    final perms = bundle.permissions;
    final users = boardContext?.users ?? const <TaskUserRef>[];
    return _Section(
      title: l10n.tasksSubtasksTitle(done, bundle.subtasks.length),
      action: perms.canAddSubtask
          ? TextButton.icon(
              onPressed: () => showTaskSubtaskSheet(
                context,
                taskName: bundle.task.name,
                users: users,
                canAssignToOthers: perms.canAssignSubtaskToOthers,
                me: boardContext?.me,
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.tasksAddSubtask),
            )
          : null,
      child: bundle.subtasks.isEmpty
          ? Text(l10n.tasksNoSubtasks)
          : Column(
              children: [
                for (final s in bundle.subtasks)
                  _SubtaskRow(
                    subtask: s,
                    onToggle: s.canToggle
                        ? (v) => _guard(
                            () => _notifier.setSubtaskDone(s.id, v),
                          )
                        : null,
                    onEdit: s.canEdit
                        ? () => showTaskSubtaskSheet(
                            context,
                            taskName: bundle.task.name,
                            users: users,
                            canAssignToOthers: perms.canAssignSubtaskToOthers,
                            me: boardContext?.me,
                            existing: s,
                          )
                        : null,
                    onDelete: s.canEdit ? () => _deleteSubtask(s) : null,
                  ),
              ],
            ),
    );
  }

  Widget _attachmentsSection(BuildContext context, TaskBundle bundle) {
    final l10n = context.l10n;
    return _Section(
      title: l10n.tasksAttachmentsTitle(bundle.attachments.length),
      action: bundle.permissions.canUpload
          ? TextButton.icon(
              onPressed: _addAttachment,
              icon: const Icon(Icons.attach_file),
              label: Text(l10n.tasksAddAttachment),
            )
          : null,
      child: bundle.attachments.isEmpty
          ? Text(l10n.tasksNoAttachments)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final a in bundle.attachments)
                    TaskAttachmentTile(
                      attachment: a,
                      onRemove: a.canRemove ? () => _removeAttachment(a) : null,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _activitySection(
    BuildContext context,
    TaskBundle bundle,
    TaskBoardContext? boardContext,
  ) {
    final l10n = context.l10n;
    final perms = bundle.permissions;
    final activity = _activityFor(perms);
    final entries = bundle.entriesOfKind(activity);
    final canAdd = switch (activity) {
      TaskEntryKind.log => perms.canLog,
      TaskEntryKind.comment => perms.canComment,
      _ => false,
    };
    // An entry's files ride on the entry's own permission: a comment on a
    // Done task may carry photos even though card uploads are closed.
    final canAttach = taskEntryCanAttach(perms, activity);
    final empty = switch (activity) {
      TaskEntryKind.log => l10n.tasksNoLogs,
      TaskEntryKind.comment => l10n.tasksNoComments,
      _ => l10n.tasksNoHistory,
    };
    return _Section(
      title: l10n.tasksActivityTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: TaskEntryKind.log,
                icon: const Icon(Icons.build_outlined, size: 18),
                label: Text(l10n.tasksTabLogs),
              ),
              ButtonSegment(
                value: TaskEntryKind.comment,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(l10n.tasksTabComments),
              ),
              ButtonSegment(
                value: TaskEntryKind.history,
                icon: const Icon(Icons.history, size: 18),
                label: Text(l10n.tasksTabHistory),
              ),
            ],
            selected: {activity},
            onSelectionChanged: (s) =>
                setState(() => _pickedActivity = s.first),
          ),
          const SizedBox(height: 10),
          if (canAdd)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                onPressed: () => showTaskEntryComposer(
                  context,
                  taskName: bundle.task.name,
                  kind: activity,
                  mentionable: bundle.mentionable,
                  canUpload: canAttach,
                  me: boardContext?.me?.user,
                ),
                icon: const Icon(Icons.add_comment_outlined),
                label: Text(
                  activity == TaskEntryKind.comment
                      ? l10n.tasksAddComment
                      : l10n.tasksAddLog,
                ),
              ),
            ),
          const SizedBox(height: 6),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(empty),
            )
          else
            // Newest first to read; the API sends oldest first.
            for (final e in entries.reversed)
              activity == TaskEntryKind.history
                  ? _HistoryRow(entry: e)
                  : _EntryCard(entry: e, mentionable: bundle.mentionable),
        ],
      ),
    );
  }
}

/// Whether the composer for [kind] may carry files. Attachments on an entry
/// follow that entry's permission (`can_comment` / `can_log`), not the card's
/// `can_upload`, which closes on a Done task while comments stay open.
@visibleForTesting
bool taskEntryCanAttach(TaskPermissions perms, String kind) => switch (kind) {
  TaskEntryKind.comment => perms.canComment,
  TaskEntryKind.log => perms.canLog,
  _ => false,
};

/// Title, status, priority and the people / dates block.
class TaskDetailHeader extends StatelessWidget {
  final TaskBundle bundle;
  const TaskDetailHeader({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final task = bundle.task;
    final s = task.summary;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.archived)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.archive_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.tasksArchivedBanner)),
              ],
            ),
          ),
        Text(task.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TaskStatusChip(status: s.status),
            TaskPriorityChip(priority: s.priority, dense: false),
            if (s.dueDate != null)
              TaskDueDate(
                dueDate: s.dueDate,
                isOverdue: s.isOverdue,
                fontSize: 13,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoRow(
          label: l10n.tasksAssignee,
          child: Row(
            children: [
              TaskAvatar(name: s.assigneeDisplay),
              const SizedBox(width: 6),
              Flexible(child: Text(s.assigneeDisplay)),
            ],
          ),
        ),
        _InfoRow(
          label: l10n.tasksCreator,
          child: Row(
            children: [
              TaskAvatar(name: s.creatorDisplay),
              const SizedBox(width: 6),
              Flexible(child: Text(s.creatorDisplay)),
            ],
          ),
        ),
        _InfoRow(
          label: l10n.tasksDueDate,
          child: Text(
            s.dueDate == null
                ? l10n.tasksNoDueDate
                : formatDate(context, s.dueDate!),
            style: s.isOverdue
                ? const TextStyle(
                    color: taskOverdueColor,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ),
        _InfoRow(
          label: l10n.tasksBranch,
          child: Text(s.branch ?? l10n.tasksNoBranch),
        ),
        if (task.startedOn != null)
          _InfoRow(
            label: l10n.tasksStartedOnLabel,
            child: Text(formatDateTime(context, task.startedOn!)),
          ),
        if (s.completedOn != null)
          _InfoRow(
            label: l10n.tasksCompletedLabel,
            child: Text(
              task.completedByName != null || task.completedBy != null
                  ? l10n.tasksCompletedBy(
                      task.completedByName ?? task.completedBy!,
                      formatDateTime(context, s.completedOn!),
                    )
                  : formatDateTime(context, s.completedOn!),
            ),
          ),
      ],
    );
  }
}

/// One button per move the server allows, labelled by what the move means
/// from here ("Approve", "Send back", ...), never by the raw target status.
class TaskTransitionButtons extends StatelessWidget {
  final TaskBundle bundle;
  final bool enabled;
  final ValueChanged<String> onTransition;

  const TaskTransitionButtons({
    super.key,
    required this.bundle,
    required this.onTransition,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final from = bundle.task.status;
    final targets = bundle.permissions.allowedTransitions
        .where((t) => t != from)
        .toList();
    if (targets.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final target in targets)
          _buttonFor(context, from, target),
      ],
    );
  }

  Widget _buttonFor(BuildContext context, String from, String target) {
    final l10n = context.l10n;
    final label = taskTransitionLabel(l10n, from, target);
    final icon = Icon(taskTransitionIcon(from, target));
    final onPressed = enabled ? () => onTransition(target) : null;
    // The forward move is the primary action; going back is secondary.
    final isForward =
        TaskStatus.all.indexOf(target) > TaskStatus.all.indexOf(from);
    return isForward
        ? FilledButton.icon(onPressed: onPressed, icon: icon, label: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
          );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _Section({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  final TaskSubtask subtask;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SubtaskRow({
    required this.subtask,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = subtask;
    final meta = <String>[
      s.assigneeDisplay ?? l10n.tasksUnassigned,
      if (s.isDone && (s.doneByName ?? s.doneBy) != null)
        l10n.tasksSubtaskDoneBy(s.doneByName ?? s.doneBy!),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: s.isDone,
          onChanged: onToggle == null ? null : (v) => onToggle!(v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: s.isDone
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 10,
                  children: [
                    Text(
                      meta.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (s.dueDate != null && !s.isDone)
                      TaskDueDate(dueDate: s.dueDate, isOverdue: s.isOverdue),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit?.call();
              if (v == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => [
              if (onEdit != null)
                PopupMenuItem(value: 'edit', child: Text(l10n.tasksEditSubtask)),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.tasksDeleteSubtask),
                ),
            ],
          ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final TaskEntry entry;
  final List<TaskUserRef> mentionable;

  const _EntryCard({required this.entry, required this.mentionable});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final mentionNames = [
      for (final m in entry.mentions)
        mentionable
                .where((u) => u.user == m)
                .map((u) => u.displayName)
                .firstOrNull ??
            m,
    ];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TaskAvatar(name: entry.authorDisplay),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.authorDisplay,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (entry.creation != null)
                  Text(
                    formatDateTime(context, entry.creation!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SelectableText(entry.content),
            if (mentionNames.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.tasksMentioned(mentionNames.join(', ')),
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (entry.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in entry.attachments)
                    TaskAttachmentTile(attachment: a, size: 72),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final TaskEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final detail = entry.content.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            taskHistoryIcon(entry.event),
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskHistorySentence(l10n, entry.event, entry.authorDisplay),
                ),
                if (detail.isNotEmpty)
                  Text(
                    taskLocalizeHistoryContent(l10n, detail),
                    style: theme.textTheme.bodySmall,
                  ),
                if (entry.creation != null)
                  Text(
                    formatDateTime(context, entry.creation!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
