import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/user_error_message.dart';
import '../models/task_models.dart';

/// Display mapping for the Task Board's API enums. The raw value is what goes
/// back to the server; these only decide what the reader sees.

String taskStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      TaskStatus.toDo => l10n.tasksStatusToDo,
      TaskStatus.inProgress => l10n.tasksStatusInProgress,
      TaskStatus.inReview => l10n.tasksStatusInReview,
      TaskStatus.done => l10n.tasksStatusDone,
      _ => status,
    };

String taskPriorityLabel(AppLocalizations l10n, String priority) =>
    switch (priority) {
      TaskPriority.normal => l10n.tasksPriorityNormal,
      TaskPriority.high => l10n.tasksPriorityHigh,
      TaskPriority.urgent => l10n.tasksPriorityUrgent,
      _ => priority,
    };

String taskViewLabel(AppLocalizations l10n, String view) => switch (view) {
  TaskBoardView.mine => l10n.tasksViewMine,
  TaskBoardView.created => l10n.tasksViewCreated,
  TaskBoardView.review => l10n.tasksViewReview,
  _ => l10n.tasksViewAll,
};

Color taskStatusColor(String status) => switch (status) {
  TaskStatus.toDo => const Color(0xFF607D8B),
  TaskStatus.inProgress => const Color(0xFF1E88E5),
  TaskStatus.inReview => const Color(0xFFF57C00),
  TaskStatus.done => const Color(0xFF2E7D32),
  _ => Colors.grey,
};

Color taskPriorityColor(String priority) => switch (priority) {
  TaskPriority.urgent => const Color(0xFFC62828),
  TaskPriority.high => const Color(0xFFEF6C00),
  _ => const Color(0xFF546E7A),
};

IconData taskStatusIcon(String status) => switch (status) {
  TaskStatus.toDo => Icons.radio_button_unchecked,
  TaskStatus.inProgress => Icons.autorenew,
  TaskStatus.inReview => Icons.rate_review_outlined,
  TaskStatus.done => Icons.check_circle_outline,
  _ => Icons.help_outline,
};

/// The button label for moving a task from [from] to [to]. The same target
/// reads differently by where the task is: In Progress is "Start" from To Do,
/// "Send back" from review, and "Reopen" from Done.
String taskTransitionLabel(AppLocalizations l10n, String from, String to) {
  switch (to) {
    case TaskStatus.inProgress:
      if (from == TaskStatus.inReview) return l10n.tasksActionSendBack;
      if (from == TaskStatus.done) return l10n.tasksActionReopen;
      return l10n.tasksActionStart;
    case TaskStatus.inReview:
      return l10n.tasksActionSubmit;
    case TaskStatus.done:
      return from == TaskStatus.inReview
          ? l10n.tasksActionApprove
          : l10n.tasksActionMarkDone;
    case TaskStatus.toDo:
      return l10n.tasksActionMoveToDo;
  }
  return l10n.tasksMoveToStatus(taskStatusLabel(l10n, to));
}

IconData taskTransitionIcon(String from, String to) {
  switch (to) {
    case TaskStatus.inProgress:
      if (from == TaskStatus.inReview) return Icons.undo;
      if (from == TaskStatus.done) return Icons.replay;
      return Icons.play_arrow;
    case TaskStatus.inReview:
      return Icons.send;
    case TaskStatus.done:
      return Icons.check;
    case TaskStatus.toDo:
      return Icons.pause;
  }
  return Icons.arrow_forward;
}

/// The readable sentence for a History entry's `event` code.
String taskHistorySentence(
  AppLocalizations l10n,
  String? event,
  String actor,
) => switch (event) {
  'created' => l10n.tasksHistoryCreated(actor),
  'reassigned' => l10n.tasksHistoryReassigned(actor),
  'status' => l10n.tasksHistoryStatus(actor),
  'due_date' => l10n.tasksHistoryDueDate(actor),
  'priority' => l10n.tasksHistoryPriority(actor),
  'title' => l10n.tasksHistoryTitle(actor),
  'branch' => l10n.tasksHistoryBranch(actor),
  'subtask_added' => l10n.tasksHistorySubtaskAdded(actor),
  'subtask_done' => l10n.tasksHistorySubtaskDone(actor),
  'subtask_undone' => l10n.tasksHistorySubtaskUndone(actor),
  'subtask_removed' => l10n.tasksHistorySubtaskRemoved(actor),
  'attachment_added' => l10n.tasksHistoryAttachmentAdded(actor),
  'attachment_removed' => l10n.tasksHistoryAttachmentRemoved(actor),
  'archived' => l10n.tasksHistoryArchived(actor),
  'unarchived' => l10n.tasksHistoryUnarchived(actor),
  _ => l10n.tasksHistoryOther(actor),
};

IconData taskHistoryIcon(String? event) => switch (event) {
  'created' => Icons.add_task,
  'reassigned' => Icons.person_outline,
  'status' => Icons.swap_horiz,
  'due_date' => Icons.event,
  'priority' => Icons.flag_outlined,
  'title' => Icons.title,
  'branch' => Icons.store_outlined,
  'subtask_added' => Icons.playlist_add,
  'subtask_done' => Icons.check_box_outlined,
  'subtask_undone' => Icons.check_box_outline_blank,
  'subtask_removed' => Icons.playlist_remove,
  'attachment_added' => Icons.attach_file,
  'attachment_removed' => Icons.link_off,
  'archived' => Icons.archive_outlined,
  'unarchived' => Icons.unarchive_outlined,
  _ => Icons.history,
};

/// A History entry's detail line, with any status or priority names in it
/// shown in the reader's language (the server writes them in English).
String taskLocalizeHistoryContent(AppLocalizations l10n, String content) {
  var text = content;
  // Longest first, so "In Progress" is not half-replaced by a shorter name.
  final names = [...TaskStatus.all, ...TaskPriority.all]
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final name in names) {
    final label = TaskStatus.all.contains(name)
        ? taskStatusLabel(l10n, name)
        : taskPriorityLabel(l10n, name);
    if (label != name) text = text.replaceAll(name, label);
  }
  return text;
}

/// The server's refusal, in the reader's language.
///
/// The task rules the backend enforces are recognised and shown as our own
/// sentence in either language. Anything else: an English UI shows the
/// server's own sentence (it names the thing that is wrong); an Arabic UI goes
/// through the shared presenter, which never shows an English sentence.
String taskErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final server = detailedServerMessage(error);
  if (server != null) {
    final mapped = _mapTaskRule(l10n, server);
    if (mapped != null) return mapped;
    if (l10n.localeName.startsWith('en') && server.length <= 240) {
      return server;
    }
  }
  return context.userErrorMessage(error);
}

String? _mapTaskRule(AppLocalizations l10n, String message) {
  final text = message.toLowerCase();
  if (text.contains('open subtask')) return l10n.tasksErrorOpenSubtasks;
  if (text.contains('reason') &&
      (text.contains('required') || text.contains('mandatory'))) {
    return l10n.tasksErrorReasonRequired;
  }
  if (text.contains('archived')) return l10n.tasksErrorArchived;
  if (text.contains('mention')) return l10n.tasksErrorMentionNotVisible;
  if (text.contains('10 mb') || text.contains('too large')) {
    return l10n.tasksErrorFileTooLarge;
  }
  return null;
}

/// Initials for an avatar: the first letters of the first two words.
String taskInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'[\s@._-]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
}
