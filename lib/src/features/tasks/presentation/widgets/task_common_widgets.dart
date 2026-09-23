import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/task_models.dart';
import '../task_labels.dart';

const taskOverdueColor = Color(0xFFC62828);

class TaskAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const TaskAvatar({super.key, required this.name, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        taskInitials(name),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class TaskPriorityChip extends StatelessWidget {
  final String priority;
  final bool dense;

  const TaskPriorityChip({super.key, required this.priority, this.dense = true});

  @override
  Widget build(BuildContext context) {
    final color = taskPriorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: dense ? 12 : 14, color: color),
          const SizedBox(width: 3),
          Text(
            taskPriorityLabel(context.l10n, priority),
            style: TextStyle(
              fontSize: dense ? 11 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskStatusChip extends StatelessWidget {
  final String status;

  const TaskStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = taskStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(taskStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            taskStatusLabel(context.l10n, status),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// "Due 3 Oct", red when overdue.
class TaskDueDate extends StatelessWidget {
  final DateTime? dueDate;
  final bool isOverdue;
  final double fontSize;

  const TaskDueDate({
    super.key,
    required this.dueDate,
    required this.isOverdue,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final due = dueDate;
    if (due == null) return const SizedBox.shrink();
    final color = isOverdue
        ? taskOverdueColor
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final text = isOverdue
        ? '${context.l10n.tasksOverdueLabel} · ${formatDate(context, due, pattern: 'd MMM')}'
        : context.l10n.tasksDueOn(formatDate(context, due, pattern: 'd MMM'));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.warning_amber_rounded : Icons.event,
          size: fontSize + 2,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

/// One card on the board.
class TaskCardTile extends StatelessWidget {
  final TaskCardSummary card;
  final VoidCallback? onTap;

  /// The statuses the card's menu offers to move it to. Empty hides the menu.
  final List<String> moveTargets;
  final ValueChanged<String>? onMove;
  final bool busy;

  const TaskCardTile({
    super.key,
    required this.card,
    this.onTap,
    this.moveTargets = const [],
    this.onMove,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final borderColor = card.isOverdue
        ? taskOverdueColor.withValues(alpha: 0.7)
        : theme.dividerColor;
    return Opacity(
      opacity: busy ? 0.5 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: card.isOverdue ? 1.4 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        card.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (moveTargets.isNotEmpty && onMove != null)
                      SizedBox(
                        width: 32,
                        height: 28,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          tooltip: l10n.tasksMoveTo,
                          icon: const Icon(Icons.more_vert),
                          onSelected: onMove,
                          itemBuilder: (_) => [
                            for (final status in moveTargets)
                              PopupMenuItem(
                                value: status,
                                child: Text(
                                  l10n.tasksMoveToStatus(
                                    taskStatusLabel(l10n, status),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TaskPriorityChip(priority: card.priority),
                    if (card.branch != null)
                      _Meta(Icons.store_outlined, card.branch!),
                    if (card.archived)
                      _Meta(Icons.archive_outlined, l10n.tasksArchivedTag),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TaskAvatar(name: card.assigneeDisplay, radius: 10),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        card.assigneeDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    if (card.dueDate != null)
                      TaskDueDate(
                        dueDate: card.dueDate,
                        isOverdue: card.isOverdue,
                      ),
                    if (card.subtasksTotal > 0)
                      _Meta(
                        Icons.checklist,
                        '${card.subtasksDone}/${card.subtasksTotal}',
                      ),
                    if (card.attachmentsCount > 0)
                      _Meta(Icons.attach_file, '${card.attachmentsCount}'),
                    if (card.entriesCount > 0)
                      _Meta(
                        Icons.chat_bubble_outline,
                        '${card.entriesCount}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for the reason a send-back or reopen requires. Null when cancelled.
Future<String?> showTaskReasonDialog(
  BuildContext context, {
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(title: title),
  );
}

class _ReasonDialog extends StatefulWidget {
  final String title;
  const _ReasonDialog({required this.title});

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: l10n.tasksReasonHint,
          errorText: _showError ? l10n.tasksErrorReasonRequired : null,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonConfirm)),
      ],
    );
  }
}

/// The reason dialog's title for a move into [to] from [from].
String taskReasonTitle(BuildContext context, String from) =>
    from == TaskStatus.done
    ? context.l10n.tasksReasonTitleReopen
    : context.l10n.tasksReasonTitleSendBack;

/// A yes/no confirmation. False when dismissed.
Future<bool> confirmTaskAction(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A dropdown of people. [allowNone] adds a leading "none" row whose value is
/// null, labelled [noneLabel].
class TaskUserDropdown extends StatelessWidget {
  final List<TaskUserRef> users;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool allowNone;
  final String? noneLabel;
  final String? Function(String?)? validator;

  const TaskUserDropdown({
    super.key,
    required this.users,
    required this.value,
    required this.onChanged,
    required this.label,
    this.allowNone = false,
    this.noneLabel,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // A value that is not in the list (a user who left the board) would make
    // the dropdown assert; show it as unset instead.
    final known = users.any((u) => u.user == value);
    return DropdownButtonFormField<String?>(
      initialValue: known ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      items: [
        if (allowNone)
          DropdownMenuItem<String?>(
            value: null,
            child: Text(noneLabel ?? context.l10n.tasksNone),
          ),
        for (final u in users)
          DropdownMenuItem<String?>(
            value: u.user,
            child: Row(
              children: [
                TaskAvatar(name: u.displayName, radius: 10),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(u.displayName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// A date field with a picker and a clear button.
class TaskDateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;

  const TaskDateField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value == null
              ? const Icon(Icons.event)
              : IconButton(
                  tooltip: l10n.tasksClearDate,
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(
          value == null ? l10n.tasksNoDueDate : formatDate(context, value!),
        ),
      ),
    );
  }
}
