import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/task_models.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(dioProvider));
});

/// Largest file the server accepts, after base64 decoding.
const int taskAttachmentMaxBytes = 10 * 1024 * 1024;

/// HTTP access to `jarz_pos.api.tasks.*`.
///
/// Lists (`subtasks`, `mentions`) are sent as JSON strings: Dio form-encodes
/// a Dart List as repeated keys on some paths, which Frappe flattens to the
/// last value, and `frappe.parse_json` accepts the string form everywhere.
class TasksRepository {
  final Dio _dio;
  TasksRepository(this._dio);

  /// The server origin the Dio instance talks to (for the web "open in a new
  /// tab" path, which relies on the same session cookie).
  String get baseUrl => _dio.options.baseUrl;

  Future<TaskBoardContext> fetchContext() async {
    final message = await _post(ApiEndpoints.tasksBoardContext, const {});
    return TaskBoardContext.fromJson(message);
  }

  Future<TaskBoard> fetchBoard(TaskBoardFilter filter) async {
    final message = await _post(ApiEndpoints.tasksBoard, filter.toParams());
    return TaskBoard.fromJson(message);
  }

  Future<TaskBundle> fetchTask(String name) =>
      _bundle(ApiEndpoints.tasksGetTask, {'name': name});

  Future<TaskBundle> createTask({
    required String title,
    required String assignedTo,
    String? description,
    String priority = TaskPriority.normal,
    DateTime? dueDate,
    String? branch,
    List<NewSubtaskDraft> subtasks = const [],
  }) {
    return _bundle(ApiEndpoints.tasksCreateTask, {
      'title': title.trim(),
      'assigned_to': assignedTo,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'priority': priority,
      if (dueDate != null) 'due_date': taskFormatApiDate(dueDate),
      if (branch != null && branch.isNotEmpty) 'branch': branch,
      if (subtasks.isNotEmpty)
        'subtasks': jsonEncode(subtasks.map((s) => s.toJson()).toList()),
    });
  }

  /// Only the fields passed are changed. A due date or branch is removed with
  /// [clearDueDate] / [clearBranch], never by sending an empty value.
  Future<TaskBundle> updateTask(
    String name, {
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? branch,
    String? assignedTo,
    bool clearDueDate = false,
    bool clearBranch = false,
  }) {
    return _bundle(ApiEndpoints.tasksUpdateTask, {
      'name': name,
      if (title != null) 'title': title.trim(),
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (dueDate != null && !clearDueDate)
        'due_date': taskFormatApiDate(dueDate),
      if (branch != null && !clearBranch) 'branch': branch,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (clearDueDate) 'clear_due_date': 1,
      if (clearBranch) 'clear_branch': 1,
    });
  }

  Future<TaskBundle> setStatus(String name, String status, {String? reason}) {
    return _bundle(ApiEndpoints.tasksSetStatus, {
      'name': name,
      'status': status,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
  }

  Future<TaskBundle> addSubtask(
    String name, {
    required String title,
    String? assignedTo,
    DateTime? dueDate,
  }) {
    return _bundle(ApiEndpoints.tasksAddSubtask, {
      'name': name,
      'title': title.trim(),
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (dueDate != null) 'due_date': taskFormatApiDate(dueDate),
    });
  }

  Future<TaskBundle> updateSubtask(
    String name,
    String subtaskId, {
    String? title,
    String? assignedTo,
    DateTime? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) {
    return _bundle(ApiEndpoints.tasksUpdateSubtask, {
      'name': name,
      'subtask_id': subtaskId,
      if (title != null) 'title': title.trim(),
      if (assignedTo != null && !clearAssignee) 'assigned_to': assignedTo,
      if (dueDate != null && !clearDueDate)
        'due_date': taskFormatApiDate(dueDate),
      if (clearAssignee) 'clear_assignee': 1,
      if (clearDueDate) 'clear_due_date': 1,
    });
  }

  Future<TaskBundle> deleteSubtask(String name, String subtaskId) =>
      _bundle(ApiEndpoints.tasksDeleteSubtask, {
        'name': name,
        'subtask_id': subtaskId,
      });

  Future<TaskBundle> setSubtaskDone(String name, String subtaskId, bool done) =>
      _bundle(ApiEndpoints.tasksSetSubtaskDone, {
        'name': name,
        'subtask_id': subtaskId,
        'done': done ? 1 : 0,
      });

  /// [kind] is `Log` or `Comment`. Answers with the task and, when the
  /// server sends it, the new entry's name (top-level `entry`), which is what
  /// the entry's attachments are uploaded against.
  Future<({TaskBundle bundle, String? entry})> addEntry(
    String name, {
    required String kind,
    required String content,
    List<String> mentions = const [],
  }) async {
    final message = await _post(ApiEndpoints.tasksAddEntry, {
      'name': name,
      'kind': kind,
      'content': content.trim(),
      if (mentions.isNotEmpty) 'mentions': jsonEncode(mentions),
    });
    return (
      bundle: TaskBundle.fromJson(message),
      entry: taskParseNullableString(message['entry']),
    );
  }

  /// Uploads [bytes] as a private file on the task, or on one of its entries
  /// when [entry] is given.
  Future<TaskBundle> uploadAttachment(
    String name, {
    required String filename,
    required Uint8List bytes,
    String? entry,
  }) {
    return _bundle(ApiEndpoints.tasksUploadAttachment, {
      'name': name,
      'filename': filename,
      'file_data': base64Encode(bytes),
      if (entry != null) 'entry': entry,
    });
  }

  Future<TaskBundle> removeAttachment(String name, String file) =>
      _bundle(ApiEndpoints.tasksRemoveAttachment, {
        'name': name,
        'file': file,
      });

  Future<TaskBundle> archiveTask(String name, {required bool archived}) =>
      _bundle(ApiEndpoints.tasksArchiveTask, {
        'name': name,
        'archived': archived ? 1 : 0,
      });

  Future<TaskOverview> fetchOverview({int days = 30}) async {
    final message = await _post(ApiEndpoints.tasksOverview, {'days': days});
    return TaskOverview.fromJson(message);
  }

  Future<TaskCounts> fetchCounts() async {
    final message = await _post(ApiEndpoints.tasksCounts, const {});
    return TaskCounts.fromJson(message);
  }

  /// The attachment's bytes, through the same authenticated Dio instance
  /// (session cookie). Files are private; there is no public URL to load.
  Future<Uint8List> downloadAttachment(String file) async {
    final response = await _dio.get<List<int>>(
      ApiEndpoints.tasksDownloadAttachment,
      queryParameters: {'file': file},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': '*/*'},
      ),
    );
    final data = response.data;
    if (data == null) throw Exception('Empty attachment response');
    return data is Uint8List ? data : Uint8List.fromList(data);
  }

  /// Absolute download URL, for the browser to open with its own cookie.
  String downloadUrl(String file) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final query = Uri(queryParameters: {'file': file}).query;
    return '$base${ApiEndpoints.tasksDownloadAttachment}?$query';
  }

  Future<TaskBundle> _bundle(String endpoint, Map<String, dynamic> body) async {
    final message = await _post(endpoint, body);
    return TaskBundle.fromJson(message);
  }

  /// Frappe wraps a whitelisted method's return in `{"message": ...}`.
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(endpoint, data: body);
    final payload = response.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected task board response');
  }
}
