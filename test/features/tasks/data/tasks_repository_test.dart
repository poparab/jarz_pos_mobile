// The Task Board repository's wire shape: which method each call hits, what
// body it sends (lists as JSON strings, checks as 0/1, clear flags instead of
// empty values), and that the `message` envelope is unwrapped.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/tasks/data/tasks_repository.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';

class _Recorded {
  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Object? data;
  _Recorded(this.method, this.path, this.query, this.data);

  Map<String, dynamic> get body =>
      data is Map ? Map<String, dynamic>.from(data as Map) : const {};
}

class _Adapter implements HttpClientAdapter {
  final List<_Recorded> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};
  List<int>? bytes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _Recorded(
        options.method,
        options.path,
        Map<String, dynamic>.from(options.queryParameters),
        options.data,
      ),
    );
    if (bytes != null) {
      return ResponseBody.fromBytes(
        bytes!,
        200,
        headers: {
          Headers.contentTypeHeader: ['image/png'],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'message': respond(options)}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _bundle = {
  'task': {'name': 'TASK-1', 'title': 'T', 'status': 'To Do'},
  'subtasks': [],
  'attachments': [],
  'entries': [],
  'mentionable': [],
  'permissions': {
    'allowed_transitions': ['In Progress'],
  },
};

const _base = '/api/method/jarz_pos.api.tasks';

void main() {
  late _Adapter adapter;
  late TasksRepository repo;

  setUp(() {
    adapter = _Adapter()..respond = (_) => _bundle;
    final dio = Dio(BaseOptions(baseUrl: 'https://erp.example.test'));
    dio.httpClientAdapter = adapter;
    repo = TasksRepository(dio);
  });

  _Recorded last() => adapter.requests.last;

  test('should unwrap the board context from the message envelope', () async {
    adapter.respond = (_) => {
      'can_access': 1,
      'can_create': 1,
      'users': [
        {'user': 'a@x', 'full_name': 'A'},
      ],
    };
    final ctx = await repo.fetchContext();
    expect(last().path, '$_base.get_board_context');
    expect(ctx.canAccess, isTrue);
    expect(ctx.users.single.user, 'a@x');
  });

  test('should send the board filter as get_board params', () async {
    adapter.respond = (_) => {
      'columns': {
        'To Do': [
          {'name': 'TASK-1', 'title': 'T'},
        ],
      },
      'counts': {'To Do': 1},
    };
    final board = await repo.fetchBoard(
      const TaskBoardFilter(view: 'review', priority: 'Urgent'),
    );
    expect(last().method, 'POST');
    expect(last().path, '$_base.get_board');
    expect(last().body['view'], 'review');
    expect(last().body['priority'], 'Urgent');
    expect(last().body['overdue_only'], 0);
    expect(board.column('To Do').single.name, 'TASK-1');
  });

  test('should send initial subtasks as one JSON string', () async {
    await repo.createTask(
      title: '  Clean  ',
      assignedTo: 'lm@x',
      dueDate: DateTime(2026, 10, 3),
      subtasks: const [
        NewSubtaskDraft(title: 'Racks'),
        NewSubtaskDraft(title: 'Door', assignedTo: 'lm@x'),
      ],
    );
    final body = last().body;
    expect(last().path, '$_base.create_task');
    expect(body['title'], 'Clean');
    expect(body['due_date'], '2026-10-03');
    expect(body['priority'], 'Normal');
    expect(body.containsKey('description'), isFalse);
    expect(body['subtasks'], isA<String>());
    expect(jsonDecode(body['subtasks'] as String), [
      {'title': 'Racks'},
      {'title': 'Door', 'assigned_to': 'lm@x'},
    ]);
  });

  test('should clear a due date with the flag, never an empty value', () async {
    await repo.updateTask('TASK-1', clearDueDate: true, clearBranch: true);
    final body = last().body;
    expect(last().path, '$_base.update_task');
    expect(body['clear_due_date'], 1);
    expect(body['clear_branch'], 1);
    expect(body.containsKey('due_date'), isFalse);
    expect(body.containsKey('branch'), isFalse);
  });

  test('should send a set_status reason only when given', () async {
    final bundle = await repo.setStatus(
      'TASK-1',
      'In Progress',
      reason: ' fix it ',
    );
    expect(last().path, '$_base.set_status');
    expect(last().body, {
      'name': 'TASK-1',
      'status': 'In Progress',
      'reason': 'fix it',
    });
    expect(bundle.permissions.allowedTransitions, ['In Progress']);

    await repo.setStatus('TASK-1', 'In Review');
    expect(last().body.containsKey('reason'), isFalse);
  });

  test('should hit each subtask endpoint with its id', () async {
    await repo.addSubtask('TASK-1', title: 'A', assignedTo: 'me@x');
    expect(last().path, '$_base.add_subtask');
    expect(last().body['assigned_to'], 'me@x');

    await repo.updateSubtask('TASK-1', 'row1', clearAssignee: true);
    expect(last().path, '$_base.update_subtask');
    expect(last().body['subtask_id'], 'row1');
    expect(last().body['clear_assignee'], 1);

    await repo.setSubtaskDone('TASK-1', 'row1', true);
    expect(last().path, '$_base.set_subtask_done');
    expect(last().body['done'], 1);

    await repo.deleteSubtask('TASK-1', 'row1');
    expect(last().path, '$_base.delete_subtask');
  });

  test('should return the new entry name from add_entry', () async {
    adapter.respond = (_) => {..._bundle, 'entry': 'ENTRY-42'};
    final added = await repo.addEntry('TASK-1', kind: 'Log', content: 'x');
    expect(added.entry, 'ENTRY-42');
    expect(added.bundle.task.name, 'TASK-1');

    adapter.respond = (_) => _bundle;
    final legacy = await repo.addEntry('TASK-1', kind: 'Log', content: 'x');
    expect(legacy.entry, isNull);
  });

  test('should send mentions as a JSON string on add_entry', () async {
    await repo.addEntry(
      'TASK-1',
      kind: 'Comment',
      content: 'hi @Boss',
      mentions: const ['boss@x'],
    );
    expect(last().path, '$_base.add_entry');
    expect(last().body['kind'], 'Comment');
    expect(jsonDecode(last().body['mentions'] as String), ['boss@x']);
  });

  test('should upload attachments as base64 with the entry', () async {
    await repo.uploadAttachment(
      'TASK-1',
      filename: 'a.png',
      bytes: Uint8List.fromList([1, 2, 3]),
      entry: 'e1',
    );
    expect(last().path, '$_base.upload_attachment');
    expect(last().body['file_data'], base64Encode([1, 2, 3]));
    expect(last().body['entry'], 'e1');
  });

  test('should archive and remove through their endpoints', () async {
    await repo.archiveTask('TASK-1', archived: false);
    expect(last().path, '$_base.archive_task');
    expect(last().body['archived'], 0);

    await repo.removeAttachment('TASK-1', 'FILE-1');
    expect(last().path, '$_base.remove_attachment');
    expect(last().body['file'], 'FILE-1');
  });

  test('should read the overview and the counts', () async {
    adapter.respond = (_) => {'period_days': 7, 'people': [], 'totals': {}};
    final overview = await repo.fetchOverview(days: 7);
    expect(last().path, '$_base.get_overview');
    expect(last().body['days'], 7);
    expect(overview.periodDays, 7);

    adapter.respond = (_) => {'assigned_open': 2, 'review_waiting': 1};
    final counts = await repo.fetchCounts();
    expect(last().path, '$_base.get_task_counts');
    expect(counts.assignedOpen, 2);
  });

  test('should download attachment bytes with a GET', () async {
    adapter.bytes = [137, 80, 78, 71];
    final bytes = await repo.downloadAttachment('FILE-1');
    expect(last().method, 'GET');
    expect(last().path, '$_base.download_attachment');
    expect(last().query['file'], 'FILE-1');
    expect(bytes, [137, 80, 78, 71]);
  });

  test('should build an absolute, encoded download URL', () {
    expect(
      repo.downloadUrl('FILE 1'),
      'https://erp.example.test$_base.download_attachment?file=FILE+1',
    );
  });
}
