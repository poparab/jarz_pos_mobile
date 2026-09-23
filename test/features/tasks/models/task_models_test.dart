// Task Board wire models: Frappe sends Checks as 0/1, Ints sometimes as
// strings, and missing values as null. Every model must survive all three.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';
import 'package:jarz_pos/src/features/tasks/state/tasks_providers.dart';

Map<String, dynamic> _card({
  String name = 'TASK-2026-00001',
  String status = 'To Do',
  Object? overdue = 0,
}) => {
  'name': name,
  'title': 'Clean the oven',
  'status': status,
  'priority': 'Urgent',
  'assigned_to': 'lm@jarz.test',
  'assigned_to_name': 'Line Manager',
  'created_by': 'boss@jarz.test',
  'created_by_name': 'Boss',
  'due_date': '2026-09-20',
  'is_overdue': overdue,
  'branch': 'Nasr City',
  'subtasks_total': '3',
  'subtasks_done': 1,
  'attachments_count': null,
  'entries_count': 2.0,
  'archived': '0',
  'modified': '2026-09-22 10:15:00.123456',
  'submitted_on': null,
  'completed_on': null,
};

void main() {
  group('TaskCardSummary.fromJson', () {
    test('should parse ints as strings, bools as 0/1 and nulls', () {
      final card = TaskCardSummary.fromJson(_card(overdue: 1));
      expect(card.isOverdue, isTrue);
      expect(card.subtasksTotal, 3);
      expect(card.subtasksDone, 1);
      expect(card.attachmentsCount, 0);
      expect(card.entriesCount, 2);
      expect(card.archived, isFalse);
      expect(card.dueDate, DateTime(2026, 9, 20));
      expect(card.modified?.hour, 10);
      expect(card.submittedOn, isNull);
      expect(card.branch, 'Nasr City');
    });

    test('should fall back to defaults for an empty map', () {
      final card = TaskCardSummary.fromJson(const {});
      expect(card.status, TaskStatus.toDo);
      expect(card.priority, TaskPriority.normal);
      expect(card.dueDate, isNull);
      expect(card.branch, isNull);
      expect(card.assigneeDisplay, '');
    });

    test('should accept "true"/"false" strings for bools', () {
      final card = TaskCardSummary.fromJson(_card(overdue: 'true'));
      expect(card.isOverdue, isTrue);
    });
  });

  group('TaskBundle.fromJson', () {
    final json = {
      'task': {
        ..._card(status: 'In Review'),
        'description': 'Deep clean',
        'started_on': '2026-09-21 09:00:00',
        'completed_by': null,
        'completed_by_name': null,
        'archived_on': null,
        'archived_by': null,
      },
      'subtasks': [
        {
          'id': 'row1',
          'title': 'Racks',
          'assigned_to': null,
          'is_done': 1,
          'done_by': 'lm@jarz.test',
          'done_by_name': 'Line Manager',
          'created_by': 'boss@jarz.test',
          'is_overdue': 0,
          'can_edit': 1,
          'can_toggle': true,
        },
        {'id': 'row2', 'title': 'Door', 'is_done': '0'},
      ],
      'attachments': [
        {
          'name': 'FILE-1',
          'file_name': 'oven.jpg',
          'file_size': '2048',
          'content_type': 'image/jpeg',
          'uploaded_by': 'lm@jarz.test',
          'uploaded_by_name': 'Line Manager',
          'creation': '2026-09-21 09:05:00',
          'entry': null,
          'can_remove': 0,
        },
      ],
      'entries': [
        {
          'name': 'e1',
          'kind': 'History',
          'content': 'To Do → In Progress',
          'event': 'status',
          'author': 'lm@jarz.test',
          'author_name': 'Line Manager',
          'creation': '2026-09-21 09:00:00',
          'mentions': [],
          'attachments': [],
        },
        {
          'name': 'e2',
          'kind': 'Comment',
          'content': '@Boss look',
          'author': 'lm@jarz.test',
          // The raw column shape: a JSON string, not a list.
          'mentions': '["boss@jarz.test"]',
          'attachments': [
            {'name': 'FILE-2', 'file_name': 'a.pdf', 'is_image': 0},
          ],
        },
      ],
      'mentionable': [
        {'user': 'boss@jarz.test', 'full_name': 'Boss', 'is_manager': 1},
      ],
      'permissions': {
        'can_edit': 0,
        'can_archive': '0',
        'can_add_subtask': 1,
        'can_assign_subtask_to_others': 0,
        'can_log': 1,
        'can_comment': 1,
        'can_upload': 1,
        'allowed_transitions': ['Done', 'In Progress'],
        'needs_reason_for': ['In Progress'],
      },
    };

    test('should parse every section of the get_task shape', () {
      final bundle = TaskBundle.fromJson(json);
      expect(bundle.task.status, TaskStatus.inReview);
      expect(bundle.task.description, 'Deep clean');
      expect(bundle.task.startedOn, DateTime(2026, 9, 21, 9));
      expect(bundle.subtasks, hasLength(2));
      expect(bundle.subtasks.first.isDone, isTrue);
      expect(bundle.subtasks.first.canToggle, isTrue);
      expect(bundle.subtasks.last.isDone, isFalse);
      expect(bundle.hasOpenSubtasks, isTrue);
      expect(bundle.attachments.single.fileSize, 2048);
      // No is_image flag: derived from the content type.
      expect(bundle.attachments.single.isImage, isTrue);
      expect(bundle.entriesOfKind(TaskEntryKind.history), hasLength(1));
      final comment = bundle.entriesOfKind(TaskEntryKind.comment).single;
      expect(comment.mentions, ['boss@jarz.test']);
      expect(comment.attachments.single.isImage, isFalse);
      expect(bundle.mentionable.single.isManager, isTrue);
    });

    test('should parse permissions and needs-reason lists', () {
      final perms = TaskBundle.fromJson(json).permissions;
      expect(perms.canEdit, isFalse);
      expect(perms.canAddSubtask, isTrue);
      expect(perms.canAssignSubtaskToOthers, isFalse);
      expect(perms.allowedTransitions, ['Done', 'In Progress']);
      expect(perms.needsReason('In Progress'), isTrue);
      expect(perms.needsReason('Done'), isFalse);
    });

    test('should survive a missing permissions block', () {
      final bundle = TaskBundle.fromJson({'task': _card()});
      expect(bundle.permissions.allowedTransitions, isEmpty);
      expect(bundle.subtasks, isEmpty);
    });
  });

  group('TaskBoard', () {
    final board = TaskBoard.fromJson({
      'columns': {
        'To Do': [_card(name: 'A'), _card(name: 'B')],
        'In Progress': [],
        'In Review': null,
      },
      'counts': {'To Do': '2', 'Done': 40},
    });

    test('should fill every column even when the server omits one', () {
      expect(board.column(TaskStatus.toDo), hasLength(2));
      expect(board.column(TaskStatus.inReview), isEmpty);
      expect(board.column(TaskStatus.done), isEmpty);
      expect(board.countFor(TaskStatus.done), 40);
      expect(board.countFor(TaskStatus.inProgress), 0);
    });

    test('should move a card optimistically and keep counts in step', () {
      final moved = board.moveCard('A', TaskStatus.inProgress);
      expect(moved.column(TaskStatus.toDo).map((c) => c.name), ['B']);
      expect(moved.column(TaskStatus.inProgress).single.status, 'In Progress');
      expect(moved.countFor(TaskStatus.toDo), 1);
    });

    test('should leave the board alone for an unknown card', () {
      expect(identical(board.moveCard('nope', TaskStatus.done), board), isTrue);
    });
  });

  group('TaskStatus.needsReason', () {
    test('should need a reason only to send back or reopen', () {
      expect(TaskStatus.needsReason('In Review', 'In Progress'), isTrue);
      expect(TaskStatus.needsReason('Done', 'In Progress'), isTrue);
      expect(TaskStatus.needsReason('To Do', 'In Progress'), isFalse);
      expect(TaskStatus.needsReason('In Review', 'Done'), isFalse);
    });
  });

  group('context, overview and counts', () {
    test('should parse the board context with defaults', () {
      final ctx = TaskBoardContext.fromJson({
        'can_access': 1,
        'is_manager': 0,
        'can_create': '1',
        'can_view_all': false,
        'can_view_overview': null,
        'me': {'user': 'lm@jarz.test', 'full_name': 'LM', 'is_manager': 0},
        'users': [
          {'user': 'lm@jarz.test', 'full_name': 'LM'},
          {'user': 'boss@jarz.test', 'full_name': '', 'is_manager': 1},
        ],
        'branches': ['Nasr City', null, ''],
      });
      expect(ctx.canAccess, isTrue);
      expect(ctx.canCreate, isTrue);
      expect(ctx.canViewOverview, isFalse);
      expect(ctx.me?.user, 'lm@jarz.test');
      expect(ctx.users.last.displayName, 'boss@jarz.test');
      expect(ctx.branches, ['Nasr City']);
      expect(ctx.statuses, TaskStatus.all);
      expect(ctx.priorities, TaskPriority.all);
    });

    test('should parse the overview with a null on-time rate', () {
      final o = TaskOverview.fromJson({
        'period_days': '7',
        'people': [
          {
            'user': 'lm@jarz.test',
            'full_name': 'LM',
            'open': '4',
            'overdue': 1,
            'done_in_period': 2,
            'on_time_rate': 0.5,
          },
          {'user': 'x@jarz.test', 'on_time_rate': null},
        ],
        'totals': {'open': 4, 'overdue': '1', 'in_review': 0},
      });
      expect(o.periodDays, 7);
      expect(o.people.first.open, 4);
      expect(o.people.first.onTimeRate, 0.5);
      expect(o.people.last.onTimeRate, isNull);
      expect(o.totalOverdue, 1);
      expect(o.totalDoneInPeriod, 0);
    });

    test('should parse task counts', () {
      final c = TaskCounts.fromJson({
        'assigned_open': '3',
        'review_waiting': 1,
      });
      expect(c.assignedOpen, 3);
      expect(c.reviewWaiting, 1);
      expect(c.overdue, 0);
    });
  });

  group('TaskBoardFilter', () {
    test('should send only what is set, with checks as 0/1', () {
      const filter = TaskBoardFilter(
        view: 'mine',
        branch: 'Nasr City',
        overdueOnly: true,
        search: '  oven ',
      );
      expect(filter.toParams(), {
        'view': 'mine',
        'branch': 'Nasr City',
        'overdue_only': 1,
        'include_archived': 0,
        'search': 'oven',
        'done_days': 30,
      });
      expect(filter.activeCount, 2);
    });

    test('should clear the sheet filters but keep view and search', () {
      const filter = TaskBoardFilter(
        view: 'review',
        search: 'x',
        priority: 'High',
        includeArchived: true,
      );
      final cleared = filter.cleared();
      expect(cleared.view, 'review');
      expect(cleared.search, 'x');
      expect(cleared.activeCount, 0);
    });

    test('should normalize an unknown view to all', () {
      expect(TaskBoardView.normalize('weird'), TaskBoardView.all);
      expect(TaskBoardView.normalize(null), TaskBoardView.all);
      expect(TaskBoardView.normalize('review'), TaskBoardView.review);
    });
  });

  group('findNewEntryName', () {
    const entries = [
      TaskEntry(name: 'old', kind: 'Comment', author: 'me@x'),
      TaskEntry(name: 'h1', kind: 'History', author: 'me@x'),
      TaskEntry(name: 'other', kind: 'Comment', author: 'you@x'),
      TaskEntry(name: 'mine', kind: 'Comment', author: 'me@x'),
    ];

    test('should pick the new entry of the kind by the author', () {
      expect(
        findNewEntryName(
          before: {'old'},
          after: entries,
          kind: 'Comment',
          author: 'me@x',
        ),
        'mine',
      );
    });

    test('should return null when nothing new matches', () {
      expect(
        findNewEntryName(
          before: {'old', 'mine', 'other'},
          after: entries,
          kind: 'Comment',
          author: 'me@x',
        ),
        isNull,
      );
    });
  });
}
