// Task Board screens: the board renders its four columns (side by side when
// wide, as tabs when narrow), refuses a non-board user politely, and the
// detail screen's action buttons come from `permissions.allowed_transitions`
// — labelled by what the move means from the current status.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/approvals/models/pending_approvals.dart';
import 'package:jarz_pos/src/features/tasks/data/tasks_repository.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';
import 'package:jarz_pos/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:jarz_pos/src/features/tasks/presentation/tasks_board_screen.dart';
import 'package:jarz_pos/src/features/tasks/presentation/widgets/task_subtask_sheet.dart';

class _FakeRepo extends TasksRepository {
  TaskBoardContext context;
  TaskBoard board;
  TaskBundle? bundle;
  final List<String> calls = [];
  String? lastReason;

  _FakeRepo({required this.context, required this.board, this.bundle})
    : super(Dio());

  @override
  Future<TaskBoardContext> fetchContext() async => context;

  @override
  Future<TaskBoard> fetchBoard(TaskBoardFilter filter) async {
    calls.add('board:${filter.view}');
    return board;
  }

  @override
  Future<TaskBundle> fetchTask(String name) async => bundle!;

  @override
  Future<TaskBundle> setStatus(
    String name,
    String status, {
    String? reason,
  }) async {
    calls.add('status:$status');
    lastReason = reason;
    return bundle!;
  }
}

Map<String, dynamic> _card(String name, String status, {int overdue = 0}) => {
  'name': name,
  'title': 'Task $name',
  'status': status,
  'priority': 'High',
  'assigned_to': 'lm@x',
  'assigned_to_name': 'Line Manager',
  'created_by': 'boss@x',
  'created_by_name': 'Boss',
  'due_date': '2026-09-01',
  'is_overdue': overdue,
  'subtasks_total': 2,
  'subtasks_done': 1,
};

final _board = TaskBoard.fromJson({
  'columns': {
    'To Do': [_card('A', 'To Do', overdue: 1)],
    'In Progress': [_card('B', 'In Progress')],
    'In Review': [],
    'Done': [_card('C', 'Done')],
  },
  'counts': {'To Do': 1, 'In Progress': 1, 'In Review': 0, 'Done': 1},
});

final _ctx = TaskBoardContext.fromJson({
  'can_access': 1,
  'is_manager': 1,
  'can_create': 1,
  'can_view_overview': 1,
  'me': {'user': 'boss@x', 'full_name': 'Boss'},
  'users': [
    {'user': 'boss@x', 'full_name': 'Boss'},
    {'user': 'lm@x', 'full_name': 'Line Manager'},
  ],
});

TaskBundle _bundle({
  required String status,
  required List<String> transitions,
  List<String> needsReason = const [],
}) => TaskBundle.fromJson({
  'task': {..._card('TASK-9', status), 'description': 'Do it'},
  'subtasks': [
    {'id': 's1', 'title': 'First step', 'is_done': 1, 'can_toggle': 1},
  ],
  'attachments': [],
  'entries': [
    {
      'name': 'h1',
      'kind': 'History',
      'event': 'created',
      'author_name': 'Boss',
      'content': '',
    },
  ],
  'mentionable': [],
  'permissions': {
    'can_edit': 1,
    'can_log': 1,
    'can_comment': 1,
    'allowed_transitions': transitions,
    'needs_reason_for': needsReason,
  },
});

Future<void> _pump(
  WidgetTester tester,
  _FakeRepo repo,
  Widget home, {
  Size size = const Size(1400, 900),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tasksRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Board', () {
    testWidgets('should render the four columns side by side when wide', (
      tester,
    ) async {
      final repo = _FakeRepo(context: _ctx, board: _board);
      await _pump(tester, repo, const TasksBoardScreen(initialView: 'mine'));

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('In Review'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Task A'), findsOneWidget);
      expect(find.text('Task B'), findsOneWidget);
      expect(find.text('Task C'), findsOneWidget);
      // The view came from the query parameter.
      expect(repo.calls, contains('board:mine'));
      // Overdue card is flagged; the subtask progress shows.
      expect(find.textContaining('Overdue'), findsOneWidget);
      expect(find.text('1/2'), findsNWidgets(3));
      // Manager with can_create gets the FAB.
      expect(find.text('New task'), findsOneWidget);
      expect(find.byTooltip('Team overview'), findsOneWidget);
    });

    testWidgets('should use one tab per column on a phone', (tester) async {
      final repo = _FakeRepo(context: _ctx, board: _board);
      await _pump(
        tester,
        repo,
        const TasksBoardScreen(),
        size: const Size(400, 800),
      );

      expect(find.byType(Tab), findsNWidgets(4));
      expect(find.text('To Do (1)'), findsOneWidget);
      expect(find.text('In Review (0)'), findsOneWidget);
      expect(find.text('Task A'), findsOneWidget);
      expect(repo.calls, contains('board:all'));
    });

    testWidgets('should refuse a non-board user without the board', (
      tester,
    ) async {
      final repo = _FakeRepo(
        context: TaskBoardContext.denied,
        board: _board,
      );
      await _pump(tester, repo, const TasksBoardScreen());

      expect(
        find.text('The task board is for managers and line managers only.'),
        findsOneWidget,
      );
      expect(find.text('Task A'), findsNothing);
      expect(find.text('New task'), findsNothing);
    });

    testWidgets('should hide New task for a user who may not create', (
      tester,
    ) async {
      final repo = _FakeRepo(
        context: TaskBoardContext.fromJson({'can_access': 1, 'can_create': 0}),
        board: _board,
      );
      await _pump(tester, repo, const TasksBoardScreen());
      expect(find.text('New task'), findsNothing);
      expect(find.text('Task A'), findsOneWidget);
    });
  });

  testWidgets('should lay out the board and detail in Arabic on a phone', (
    tester,
  ) async {
    final repo = _FakeRepo(
      context: _ctx,
      board: _board,
      bundle: _bundle(
        status: 'In Review',
        transitions: ['Done', 'In Progress'],
      ),
    );
    await _pump(
      tester,
      repo,
      const TasksBoardScreen(),
      size: const Size(360, 740),
      locale: const Locale('ar'),
    );
    expect(find.text('لوحة المهام'), findsOneWidget);
    expect(find.text('لسه (1)'), findsOneWidget);

    await _pump(
      tester,
      repo,
      const TaskDetailScreen(taskName: 'TASK-9'),
      size: const Size(360, 740),
      locale: const Locale('ar'),
    );
    expect(find.text('موافقة'), findsOneWidget);
    expect(find.text('رجّعها'), findsOneWidget);
  });

  group('Detail action buttons', () {
    testWidgets('should offer Approve and Send back on a task in review', (
      tester,
    ) async {
      final repo = _FakeRepo(
        context: _ctx,
        board: _board,
        bundle: _bundle(
          status: 'In Review',
          transitions: ['Done', 'In Progress'],
          needsReason: ['In Progress'],
        ),
      );
      await _pump(tester, repo, const TaskDetailScreen(taskName: 'TASK-9'));

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Send back'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
      expect(find.text('Submit for review'), findsNothing);
      // Sections render from the bundle.
      expect(find.text('Subtasks (1/1)'), findsOneWidget);
      expect(find.text('Do it'), findsOneWidget);
    });

    testWidgets('should ask for a reason before sending back', (tester) async {
      final repo = _FakeRepo(
        context: _ctx,
        board: _board,
        bundle: _bundle(
          status: 'In Review',
          transitions: ['Done', 'In Progress'],
          needsReason: ['In Progress'],
        ),
      );
      await _pump(tester, repo, const TaskDetailScreen(taskName: 'TASK-9'));

      await tester.tap(find.text('Send back'));
      await tester.pumpAndSettle();
      expect(find.text('Why are you sending it back?'), findsOneWidget);

      // Empty reason is refused locally.
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('A reason is required.'), findsOneWidget);
      expect(repo.calls, isNot(contains('status:In Progress')));

      await tester.enterText(find.byType(TextField).last, 'Missing photos');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(repo.calls, contains('status:In Progress'));
      expect(repo.lastReason, 'Missing photos');
    });

    testWidgets('should offer Start and Submit on a task to do', (
      tester,
    ) async {
      final repo = _FakeRepo(
        context: _ctx,
        board: _board,
        bundle: _bundle(
          status: 'To Do',
          transitions: ['In Progress', 'In Review'],
        ),
      );
      await _pump(tester, repo, const TaskDetailScreen(taskName: 'TASK-9'));

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Submit for review'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      // No reason asked for a forward move.
      expect(find.byType(AlertDialog), findsNothing);
      expect(repo.calls, contains('status:In Progress'));
    });

    testWidgets('should show no action buttons when none are allowed', (
      tester,
    ) async {
      final repo = _FakeRepo(
        context: _ctx,
        board: _board,
        bundle: _bundle(status: 'Done', transitions: const []),
      );
      await _pump(tester, repo, const TaskDetailScreen(taskName: 'TASK-9'));
      expect(find.text('Reopen'), findsNothing);
      expect(find.text('Approve'), findsNothing);
      // History renders as a readable sentence, not the event code.
      await tester.ensureVisible(find.text('History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Boss created the task'), findsOneWidget);
    });
  });

  testWidgets('should offer only comments, with files, on a Done task', (
    tester,
  ) async {
    final done = TaskBundle.fromJson({
      'task': _card('TASK-9', 'Done'),
      'permissions': {
        'can_log': 0,
        'can_comment': 1,
        'can_upload': 0,
        'can_add_subtask': 0,
        'allowed_transitions': ['In Progress'],
        'needs_reason_for': ['In Progress'],
      },
    });
    final repo = _FakeRepo(context: _ctx, board: _board, bundle: done);
    await _pump(tester, repo, const TaskDetailScreen(taskName: 'TASK-9'));

    // Card-level uploads and subtask changes are closed.
    expect(find.text('Attach'), findsNothing);
    expect(find.text('Add subtask'), findsNothing);
    // The activity opens on Comments, and only a comment can be added.
    expect(find.text('Add comment'), findsOneWidget);
    expect(find.text('Add what I did'), findsNothing);

    await tester.ensureVisible(find.text('What I did'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('What I did'));
    await tester.pumpAndSettle();
    expect(find.text('Add what I did'), findsNothing);

    await tester.tap(find.text('Comments'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add comment'));
    await tester.pumpAndSettle();
    // The comment composer may carry files even though can_upload is off.
    expect(find.text('Attach'), findsOneWidget);
    expect(find.text('Mention'), findsOneWidget);
  });

  group('subtaskAssigneeOptions', () {
    const me = TaskUserRef(user: 'lm@x', fullName: 'LM');
    const users = [
      TaskUserRef(user: 'boss@x', fullName: 'Boss'),
      TaskUserRef(user: 'lm@x', fullName: 'LM'),
      TaskUserRef(user: 'other@x', fullName: 'Other'),
    ];

    test('should offer everyone to a user who may assign others', () {
      expect(
        subtaskAssigneeOptions(users: users, canAssignToOthers: true, me: me),
        users,
      );
    });

    test('should offer only me otherwise', () {
      final options = subtaskAssigneeOptions(
        users: users,
        canAssignToOthers: false,
        me: me,
      );
      expect(options.map((u) => u.user), ['lm@x']);
    });

    test('should keep an existing assignee selectable when editing', () {
      final options = subtaskAssigneeOptions(
        users: users,
        canAssignToOthers: false,
        me: me,
        currentAssignee: 'other@x',
      );
      expect(options.map((u) => u.user), ['lm@x', 'other@x']);
    });
  });

  group('Pending approvals task queues', () {
    test('should keep the two task queues the server sends', () {
      final parsed = PendingApprovals.fromJson({
        'eligible': true,
        'queues': [
          {'key': 'tasks_assigned', 'count': 3},
          {'key': 'tasks_review', 'count': 1},
        ],
      });
      expect(parsed.waiting.map((q) => q.key), [
        PendingApprovalKeys.tasksAssigned,
        PendingApprovalKeys.tasksReview,
      ]);
      expect(parsed.total, 4);
    });
  });
}
